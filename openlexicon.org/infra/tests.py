"""Tests : `python manage.py test infra_query`.

Ils créent leurs propres petites bases (codes Lexique-Infra-*, Lexique383) dans la base de TEST
de Django ; votre vraie base n'est pas touchée.
"""
import json

from django.test import TestCase
from django.urls import reverse

from . import conf, services

Database, DatabaseObject, DatabaseColumn = None, None, None

PSEUDO = ["let_ty_dec", "let_ty_mean", "let_to_dec", "let_to_mean",
          "bigr_ty_dec", "bigr_ty_mean", "bigr_to_dec", "bigr_to_mean",
          "trigr_ty_dec", "trigr_ty_mean", "trigr_to_dec", "trigr_to_mean"]
WORD_COLS = ["a1", "a2", "a3", "a4"] + PSEUDO + ["z1", "z2"]


def letter_row(ch):
    b = ord(ch) - 96
    return {"letTyI": b, "letTyM": b * 10, "letTyF": b * 100,
            "letToI": b + 0.5, "letToM": b * 10 + 0.5, "letToF": b * 100 + 0.5}


class InfraQueryTests(TestCase):
    @classmethod
    def setUpTestData(cls):
        global Database, DatabaseObject, DatabaseColumn
        Database, DatabaseObject, DatabaseColumn = services.get_models()

        def mkdb(code, cols=()):
            db = Database.objects.create(code=code, name=code)
            for c in cols:
                DatabaseColumn.objects.create(database=db, code=c, name=c.upper(),
                                              description="tip " + c)
            return db

        words = mkdb("Lexique-Infra-word_frequency", WORD_COLS)
        letters = mkdb("Lexique-Infra-lettres")
        bigrams = mkdb("Lexique-Infra-bigrammes")
        trigrams = mkdb("Lexique-Infra-trigrammes")
        lex = mkdb("Lexique383")

        DatabaseObject.objects.create(database=words, ortho="chat",
                                      jsonData={c: i for i, c in enumerate(WORD_COLS)})
        for ch in "abcdefghijklmnopqrstuvwxyzé":
            DatabaseObject.objects.create(
                database=letters, ortho=ch,
                jsonData=letter_row(ch if ch != "é" else "e"))
        DatabaseObject.objects.create(database=bigrams, ortho="ch", jsonData={
            "bigrTyI": 1.5, "bigrTyM": 2.5, "bigrTyF": 3.5,
            "bigrToI": 10, "bigrToM": 20, "bigrToF": 30})
        DatabaseObject.objects.create(database=bigrams, ortho="ot", jsonData={
            "bigrTyI": 4, "bigrTyM": 5, "bigrTyF": 6,
            "bigrToI": 40, "bigrToM": 50, "bigrToF": 60})
        # "chat" apparaît deux fois (ex. plusieurs catégories grammaticales) : les voisins
        # doivent être dédoublonnés.
        for i, w in enumerate(["chat", "chut", "chas", "coat", "chats", "chat", "bout"]):
            DatabaseObject.objects.create(database=lex, ortho=w, jsonData={"x": len(w), "i": i})

    # ------------------------------------------------------------------ parsing
    def test_parse_items(self):
        items, ignored = services.parse_items("Chat chat\tCHOT\n\n a-priori l'eau  Zorg ")
        self.assertEqual(items, ["chat", "chot", "zorg"])
        self.assertEqual(ignored, ["a-priori", "l'eau"])

    # ------------------------------------------------------------------ mot
    def test_word_row(self):
        res = services.run_query("chat")
        self.assertEqual([c["code"] for c in res["columns"]][:2], ["_item", "_type"])
        self.assertEqual(len(res["columns"]), 2 + len(WORD_COLS))
        row = res["rows"][0]
        self.assertEqual(row[:2], ["chat", "Word"])
        self.assertEqual(row[2:], list(range(len(WORD_COLS))))
        self.assertEqual(res["columns"][2]["description"], "tip a1")
        self.assertEqual((res["n_words"], res["n_pseudowords"]), (1, 0))

    # ------------------------------------------------------------------ pseudomot
    def test_pseudoword_values(self):
        """chot : c(3) h(8) o(15) t(20)  -> I M M F"""
        res = services.run_query("chot")
        row = res["rows"][0]
        props = dict(zip(WORD_COLS, row[2:]))
        self.assertEqual(row[:2], ["chot", "Pseudoword"])
        # colonnes hors tranche vides
        for c in ("a1", "a2", "a3", "a4", "z1", "z2"):
            self.assertEqual(props[c], "")
        # lettres Ty : 3 / 80 / 150 / 2000
        self.assertEqual(props["let_ty_dec"], "3-80-150-2000")
        self.assertEqual(props["let_ty_mean"], 558.25)
        # lettres To : 3.5 / 80.5 / 150.5 / 2000.5
        self.assertEqual(props["let_to_dec"], "3.5-80.5-150.5-2000.5")
        self.assertEqual(props["let_to_mean"], 558.75)
        # bigrammes ch(I) ho(M, absent -> 0) ot(F)
        self.assertEqual(props["bigr_ty_dec"], "1.5-0-6")
        self.assertEqual(props["bigr_ty_mean"], 2.5)
        self.assertEqual(props["bigr_to_dec"], "10-0-60")
        self.assertEqual(props["bigr_to_mean"], round(70 / 3, 6))
        # trigrammes : aucun dans la table -> 0-0
        self.assertEqual(props["trigr_ty_dec"], "0-0")
        self.assertEqual(props["trigr_ty_mean"], 0.0)

    def test_short_pseudoword(self):
        res = services.run_query("é")           # 1 lettre : ni bigramme ni trigramme
        props = dict(zip(WORD_COLS, res["rows"][0][2:]))
        self.assertEqual(props["let_ty_dec"], "5")        # lettre unique -> position I (e = 5)
        self.assertEqual(props["bigr_ty_dec"], "")
        self.assertEqual(props["trigr_to_mean"], "")

    def test_exact_match_ignores_accent_collation(self):
        """'e' ne doit pas récupérer la ligne 'é'."""
        res = services.run_query("e")
        props = dict(zip(WORD_COLS, res["rows"][0][2:]))
        self.assertEqual(props["let_ty_dec"], "5")

    # ------------------------------------------------------------------ voisins
    def test_neighbors(self):
        res = services.run_query("chat chot zzzz", options=["neighbors"])
        self.assertEqual([c["code"] for c in res["columns"]][2:4], ["_nb_neighbors", "_neighbors"])
        by_item = {r[0]: r for r in res["rows"]}
        self.assertEqual(by_item["chat"][2:4], [3, "chas,chut,coat"])   # chat lui-même exclu
        self.assertEqual(by_item["chot"][2:4], [2, "chat,chut"])        # pseudomot
        self.assertEqual(by_item["zzzz"][2:4], [0, ""])
        # sans l'option, pas de colonnes de voisins
        res = services.run_query("chat")
        self.assertNotIn("_neighbors", [c["code"] for c in res["columns"]])

    # ------------------------------------------------------------------ http
    def test_http_endpoint(self):
        client = self.client
        self.assertEqual(client.get(reverse("infra_query:index")).status_code, 200)
        url = reverse("infra_query:query")
        r = client.post(url, json.dumps({"items": "chat chot", "options": []}),
                        content_type="application/json")
        self.assertEqual(r.status_code, 200)
        data = r.json()
        self.assertEqual(len(data["rows"]), 2)
        r = client.post(url, json.dumps({"items": " ,; "}), content_type="application/json")
        self.assertEqual(r.status_code, 400)
        self.assertIn("error", r.json())
        self.assertEqual(client.get(url).status_code, 405)

    def test_max_items(self):
        with self.settings(INFRA_QUERY={"MAX_ITEMS": 2}):
            with self.assertRaises(services.InfraError):
                services.run_query("a b c")
