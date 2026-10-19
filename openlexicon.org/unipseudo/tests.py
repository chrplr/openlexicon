import json
import random
from io import BytesIO

from django.core.cache import cache
from django.test import SimpleTestCase, TestCase
from django.urls import reverse

from . import filters, services
from .generator import (
    BIGRAM,
    TRIGRAM,
    GenerationError,
    allowed_algorithms,
    default_algorithm,
    generate_pseudowords,
)

MODELS = ["table", "cable", "fable", "sable", "tamer", "tapir", "later", "lapel"]


class GeneratorTests(SimpleTestCase):
    def test_length_and_sources(self):
        for algo, sub in ((BIGRAM, 2), (TRIGRAM, 3)):
            res = generate_pseudowords(10, 5, MODELS, algo, rng=random.Random(1))
            self.assertTrue(res.pseudowords)
            for p in res.pseudowords:
                self.assertEqual(len(p.pseudoword), 5)
                self.assertEqual(len(p.sources), 5 - sub + 1)
                self.assertNotIn(p.pseudoword, MODELS)

    def test_letters_come_from_sources(self):
        res = generate_pseudowords(20, 5, MODELS, TRIGRAM, rng=random.Random(2))
        k = 3
        for p in res.pseudowords:
            self.assertEqual(p.pseudoword[:k], p.sources[0][:k])
            for step in range(1, 5 - k + 1):
                # the (k-1) previous letters and the new one are all in the source word
                self.assertEqual(p.pseudoword[step:step + k], p.sources[step][step:step + k])

    def test_exclude_and_checks(self):
        res = generate_pseudowords(
            50, 5, MODELS, BIGRAM, exclude={"tabel"}, checks=[lambda w: w[0] != "t"],
            rng=random.Random(3), time_out=0.2,
        )
        self.assertTrue(all(p.pseudoword[0] != "t" and p.pseudoword != "tabel" for p in res.pseudowords))
        self.assertEqual(len({p.pseudoword for p in res.pseudowords}), len(res.pseudowords))

    def test_not_enough_words_returns_partial(self):
        res = generate_pseudowords(1000, 5, MODELS, BIGRAM, time_out=0.1)
        self.assertFalse(res.complete)
        self.assertGreater(len(res.pseudowords), 0)

    def test_errors(self):
        with self.assertRaises(GenerationError):
            generate_pseudowords(5, 5, [], BIGRAM)
        with self.assertRaises(GenerationError):
            generate_pseudowords(5, 3, ["abc", "abd"], TRIGRAM)  # trigram needs length >= 4

    def test_algorithm_defaults(self):
        self.assertEqual(allowed_algorithms(3), [BIGRAM])
        self.assertEqual(default_algorithm(5), BIGRAM)
        self.assertEqual(default_algorithm(6), TRIGRAM)


class FilterTests(SimpleTestCase):
    def test_consonants(self):
        self.assertFalse(filters.check_consonants("abstrct", 3))     # strct = 5 consonants
        self.assertTrue(filters.check_consonants("astra", 3))        # str = 3
        self.assertTrue(filters.check_consonants("éèà", 1))
        self.assertFalse(filters.check_consonants("ébcd", 2))

    def test_same_letter(self):
        self.assertFalse(filters.check_same_letter("baaad", 2))
        self.assertTrue(filters.check_same_letter("baad", 2))

    def test_diacritics(self):
        self.assertFalse(filters.check_diacritics("éèa", 1))
        self.assertTrue(filters.check_diacritics("éea", 1))

    def test_build_checks_ignores_no_constraint(self):
        self.assertEqual(filters.build_checks({"filterConsonants": "", "filterSameLetter": None}), [])
        self.assertEqual(len(filters.build_checks({"filterConsonants": "3", "unknown": 2})), 1)

    def test_presets(self):
        self.assertEqual(filters.presets_for("French"), {"filterConsonants": 3, "filterSameLetter": 2})
        self.assertEqual(filters.presets_for("Dutch"), {"filterSameLetter": 2})
        self.assertEqual(filters.presets_for("Multiple languages"), {})


class ViewTests(TestCase):
    @classmethod
    def setUpTestData(cls):
        Database, DatabaseObject, DatabaseColumn = services.get_models()
        cls.db = Database.objects.create(code="Lexique4", name="Lexique4", language="French", info="<p>Hello</p>")
        # a second French database that must NOT be used
        cls.other_fr = Database.objects.create(code="Lexique383", name="Lexique383", language="French")
        cls.en = Database.objects.create(code="ELP", name="English_Lexicon_Project", language="English")
        cls.nl_other = Database.objects.create(code="Other", name="AAA_other_dutch", language="Dutch")
        cls.nl = Database.objects.create(code="WorldLex-Dutch", name="WorldLex-Dutch", language="Dutch")
        cls.no_base = Database.objects.create(code="Misc", name="Misc", language="Multiple languages")

        for code in ("FreqMotFilms", "cgram"):
            DatabaseColumn.objects.create(database=cls.db, code=code, name=code)
        DatabaseColumn.objects.create(database=cls.nl, code="BlogFreqPm", name="BlogFreqPm")
        # English_Lexicon_Project deliberately has NO SUBTLWF column
        rows = [
            ("table", 12.0, "NOM"), ("cable", 3.0, "NOM"), ("fable", 1.2, "NOM"), ("sable", 4.4, "NOM"),
            ("tamer", 0.9, "VER"), ("tapir", 0.8, "NOM"), ("later", 0.7, "VER"), ("lapel", 0.1, "NOM"),  # lapel: too rare
            ("table", 12.0, "VER"),  # duplicated ortho
            ("tabla", 5.0, "NOM"),
            ("shama", 0.3, "NOM"),   # too rare
            ("sharp", 0.5, "NOM"),   # exactly at the threshold: excluded (must be > 0.5)
            ("abc", 9.0, "NOM"),
        ]
        for ortho, freq, gram in rows:
            DatabaseObject.objects.create(database=cls.db, ortho=ortho, jsonData={"FreqMotFilms": freq, "cgram": gram})
        # real word, never frequent enough to be a model, but must never be generated
        DatabaseObject.objects.create(database=cls.db, ortho="Tabel", jsonData={"FreqMotFilms": 0.0, "cgram": "NOM"})
        # words of the other French database: must not appear
        DatabaseObject.objects.create(database=cls.other_fr, ortho="zzzzz", jsonData={})
        DatabaseObject.objects.create(database=cls.nl, ortho="hoeden", jsonData={"BlogFreqPm": 3.2})
        DatabaseObject.objects.create(database=cls.nl, ortho="rarely", jsonData={"BlogFreqPm": 0.1})
        DatabaseObject.objects.create(database=cls.nl_other, ortho="nooit", jsonData={})

    def setUp(self):
        cache.clear()

    def post(self, name, payload):
        return self.client.post(reverse("unipseudo:" + name), json.dumps(payload), content_type="application/json")

    def test_index_lists_distinct_languages(self):
        r = self.client.get(reverse("unipseudo:index"))
        self.assertEqual(r.context["languages"], ["English", "French", "Dutch", "Multiple languages"])  # top languages first
        self.assertContains(r, '<option value="English" selected>English</option>', html=True)
        self.assertContains(r, '<option value="Dutch">Dutch</option>', html=True)
        self.assertNotContains(r, "Lexique4")  # database names are no longer menu entries

    def test_database_chosen_for_language(self):
        self.assertEqual(services.get_database_for_language("French"), self.db)
        self.assertEqual(services.get_database_for_language("English"), self.en)
        self.assertEqual(services.get_database_for_language("Dutch"), self.nl)   # name starts with WorldLex
        self.assertIsNone(services.get_database_for_language("Multiple languages"))
        self.assertIsNone(services.get_database_for_language("Klingon"))
        self.assertIsNone(services.get_database_for_language(""))

    def test_language_detail(self):
        data = self.client.get(reverse("unipseudo:language"), {"language": "French"}).json()
        self.assertEqual(data["database"]["name"], "Lexique4")
        self.assertEqual(data["gram_classes"], ["NOM", "VER"])
        self.assertEqual(data["presets"], {"filterConsonants": 3, "filterSameLetter": 2})
        dutch = self.client.get(reverse("unipseudo:language"), {"language": "Dutch"}).json()
        self.assertEqual(dutch["database"]["name"], "WorldLex-Dutch")
        self.assertEqual(dutch["presets"], {"filterSameLetter": 2})
        none = self.client.get(reverse("unipseudo:language"), {"language": "Multiple languages"}).json()
        self.assertIsNone(none["database"])

    def test_words_use_only_the_chosen_database(self):
        url = reverse("unipseudo:words")
        words = self.client.get(url, {"language": "French", "length": 5}).json()["words"]
        self.assertEqual(sorted(words), ["cable", "fable", "later", "sable", "tabla", "table", "tamer", "tapir"])  # no zzzzz, lapel, shama, sharp
        verbs = self.client.get(url, {"language": "French", "length": 5, "gram_class": "VER"}).json()["words"]
        self.assertEqual(sorted(verbs), ["later", "table", "tamer"])
        self.assertEqual(self.client.get(url, {"language": "Dutch", "length": 6}).json()["words"], ["hoeden"])  # "rarely" is too rare
        self.assertEqual(self.client.get(url, {"language": "", "length": 5}).json()["words"], [])
        self.assertEqual(self.client.get(url, {"language": "French", "length": 2}).status_code, 400)

    def test_frequency_column_rules(self):
        self.assertEqual(services.database_settings(self.db)["freq_column"], "FreqMotFilms")   # French: contains "FreqMot"
        self.assertEqual(services.database_settings(self.nl)["freq_column"], "BlogFreqPm")     # WorldLex: exact
        self.assertIsNone(services.database_settings(self.en)["freq_column"])                  # English: SUBTLWF missing

    def test_missing_frequency_column_is_reported(self):
        r = self.client.get(reverse("unipseudo:words"), {"language": "English", "length": 5})
        self.assertEqual(r.status_code, 400)
        self.assertIn("English_Lexicon_Project", r.json()["error"])
        self.assertIn('named "SUBTLWF"', r.json()["error"])
        with self.assertRaises(services.FrequencyColumnError):
            services.get_words(self.en, 5)
        # exclusion list does not need a frequency column
        services.get_words(self.en, 5, need_full_list=True)

    def test_exact_rule_does_not_match_similar_names(self):
        Database, DatabaseObject, DatabaseColumn = services.get_models()
        DatabaseColumn.objects.create(database=self.en, code="SUBTLWF_log", name="x")
        self.assertIsNone(services.database_settings(self.en)["freq_column"])
        DatabaseColumn.objects.create(database=self.en, code="SUBTLWF", name="x")
        self.assertEqual(services.database_settings(self.en)["freq_column"], "SUBTLWF")

    def test_full_list_for_exclusion(self):
        full = services.get_words(self.db, 5, need_full_list=True)
        self.assertIn("lapel", full)
        self.assertIn("tabel", full)  # lower-cased

    def test_generate(self):
        words = "\n".join(MODELS)
        r = self.post("generate", {"n": 5, "length": 5, "algorithm": "bigram", "words": words,
                                   "language": "French", "filters": {"filterSameLetter": "2"}})
        self.assertEqual(r.status_code, 200)
        data = r.json()
        self.assertTrue(data["rows"])
        for row in data["rows"]:
            self.assertEqual(len(row["p"]), 5)
            self.assertNotIn(row["p"], MODELS + ["tabel", "lapel", "tabla", "shama", "sharp"])  # real words of Lexique4 excluded
            self.assertEqual(len(row["s"]), 4)

    def test_generate_errors(self):
        base = {"n": 5, "length": 5, "algorithm": "bigram", "words": "table\ncable"}
        self.assertEqual(self.post("generate", dict(base, n=0)).status_code, 400)
        self.assertEqual(self.post("generate", dict(base, n=99999)).status_code, 400)
        self.assertEqual(self.post("generate", dict(base, length=2)).status_code, 400)
        self.assertEqual(self.post("generate", dict(base, algorithm="x")).status_code, 400)
        self.assertEqual(self.post("generate", dict(base, length=3, algorithm="trigram")).status_code, 400)
        r = self.post("generate", dict(base, words="abc"))
        self.assertEqual(r.status_code, 400)
        self.assertIn("Words to use", r.json()["error"])
        self.assertEqual(self.client.post(reverse("unipseudo:generate"), "nope", content_type="application/json").status_code, 400)

    def test_download_xlsx_and_tsv(self):
        from openpyxl import load_workbook

        rows = [["abcde", "abcdf", "=SUM(1)"], ["abcdx", "abcdy", "z"]]
        r = self.post("download", {"rows": rows, "detail": True, "format": "xlsx", "tz": "Europe/Paris"})
        self.assertEqual(r.status_code, 200)
        self.assertIn("Pseudowords-details-query-", r["Content-Disposition"])
        ws = load_workbook(BytesIO(r.content)).active
        self.assertEqual([c.value for c in ws[1]], ["Pseudoword", "Word.1", "Word.2"])
        self.assertEqual(ws["C2"].value, "=SUM(1)")
        self.assertEqual(ws["C2"].data_type, "s")

        r = self.post("download", {"rows": [["abcde"], ["abcdx"]], "detail": False, "format": "tsv"})
        self.assertEqual(r.content.decode().splitlines(), ["Pseudoword", "abcde", "abcdx"])
        self.assertEqual(self.post("download", {"rows": []}).status_code, 400)
