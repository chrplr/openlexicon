"""Logique métier : port Django de app.R (Lexique Infra).

Pour chaque item saisi :
  * si c'est un mot de DB_WORDS  -> on renvoie ses propriétés (jsonData) ;
  * sinon c'est un pseudomot     -> on calcule, à partir des tables de lettres, bigrammes et
    trigrammes, la décomposition (valeurs séparées par « - ») et la moyenne par position
    (I = initiale, M = médiane, F = finale), pour les types Ty (type) et To (token).
Optionnellement, on ajoute les voisins orthographiques (distance de Hamming = 1) calculés sur
DB_NEIGHBORS (Lexique383).
"""
import string
import time
import unicodedata
from itertools import chain

from django.apps import apps
from django.db.models import Q
from django.db.models.functions import Length

from . import conf

TYPE_WORD = "Word"
TYPE_PSEUDO = "Pseudoword"
ITEM_LABEL = "Item"
TYPE_LABEL = "Type Item"
NEIGHBORS_COUNT_LABEL = "Number of Ortho Neighbors"
NEIGHBORS_LABEL = "Ortho Neighbors"

# (clé du type dans les noms de colonnes, longueur de l'n-gramme, réglage de la base)
NGRAM_TYPES = (("let", 1, "DB_LETTERS"), ("bigr", 2, "DB_BIGRAMS"), ("trigr", 3, "DB_TRIGRAMS"))
SUBTYPES = ("Ty", "To")

_PUNCT = set(string.punctuation)


class InfraError(Exception):
    """Erreur affichable à l'utilisateur."""


# --------------------------------------------------------------------------- modèles

def get_models():
    """Retrouve Database, DatabaseObject, DatabaseColumn où qu'ils soient dans le projet."""
    label = conf.get("MODELS_APP_LABEL")
    found = {}
    for model in apps.get_models():
        if model.__name__ in ("Database", "DatabaseObject", "DatabaseColumn"):
            if label and model._meta.app_label != label:
                continue
            found.setdefault(model.__name__, model)
    missing = {"Database", "DatabaseObject", "DatabaseColumn"} - set(found)
    if missing:
        raise InfraError(
            "Modèles introuvables : %s. Vérifiez INSTALLED_APPS ou INFRA_QUERY['MODELS_APP_LABEL']."
            % ", ".join(sorted(missing)))
    return found["Database"], found["DatabaseObject"], found["DatabaseColumn"]


def get_database(setting_name):
    Database, _, _ = get_models()
    ident = conf.get(setting_name)
    db = Database.objects.filter(Q(code=ident) | Q(name=ident)).first()
    if db is None:
        raise InfraError("Base « %s » introuvable (réglage %s)." % (ident, setting_name))
    return db


# --------------------------------------------------------------------------- items

def norm(text):
    return unicodedata.normalize("NFC", text)


def parse_items(text):
    """Équivalent des lignes strsplit / str_subset / grepl / unique de app.R.

    Retourne (items, ignorés) : items en minuscules, sans doublon, ordre de saisie conservé.
    Les items contenant un signe de ponctuation sont ignorés (comme dans l'app Shiny) et
    renvoyés dans `ignorés` pour pouvoir être signalés à l'utilisateur.
    """
    items, ignored, seen = [], [], set()
    for raw in (text or "").split():          # coupe sur tout espace, tabulation, retour ligne
        raw = norm(raw)
        if any(c in _PUNCT for c in raw):
            if raw not in ignored:
                ignored.append(raw)
            continue
        word = raw.lower()
        if word not in seen:
            seen.add(word)
            items.append(word)
    return items, ignored


# --------------------------------------------------------------------------- colonnes

def word_columns(words_db):
    """Colonnes « propriétés » de DB_WORDS, dans l'ordre de DatabaseColumn.id."""
    _, _, DatabaseColumn = get_models()
    skip = {c.lower() for c in conf.get("WORD_COLUMN_CODES")}
    cols = []
    for c in DatabaseColumn.objects.filter(database=words_db).order_by("id"):
        if c.code.lower() in skip:
            continue
        cols.append({"code": c.code, "name": c.name or c.code, "description": c.description or ""})
    return cols


def pseudo_column_codes(cols):
    explicit = conf.get("PSEUDO_COLUMNS")
    if explicit:
        if len(explicit) != 12:
            raise InfraError("INFRA_QUERY['PSEUDO_COLUMNS'] doit contenir 12 codes de colonnes.")
        return list(explicit)
    start, end = conf.get("PSEUDO_SLICE")
    codes = [c["code"] for c in cols[start:end]]
    if len(codes) != 12:
        raise InfraError(
            "La table des mots ne contient pas les 12 colonnes attendues pour les pseudomots "
            "(PSEUDO_SLICE=%s, %d colonnes trouvées)." % (conf.get("PSEUDO_SLICE"), len(codes)))
    return codes


# --------------------------------------------------------------------------- accès base

def _chunks(seq, n):
    seq = list(seq)
    for i in range(0, len(seq), n):
        yield seq[i:i + n]


def fetch_by_ortho(db, orthos):
    """{ortho: [jsonData, ...]} pour les ortho demandés.

    Le filtre exact est refait en Python : selon la collation de la base (MySQL *_ci / *_ai)
    « e » peut aussi renvoyer « é », ce qu'on ne veut pas (R comparait exactement).
    """
    _, DatabaseObject, _ = get_models()
    wanted = set(orthos)
    out = {}
    for chunk in _chunks(wanted, conf.get("CHUNK")):
        qs = DatabaseObject.objects.filter(database=db, ortho__in=chunk).order_by("id")
        for obj in qs.values_list("ortho", "jsonData"):
            ortho = norm(obj[0])
            if ortho in wanted:
                out.setdefault(ortho, []).append(obj[1] or {})
    return out


# --------------------------------------------------------------------------- voisins

_neighbor_cache = {}   # longueur -> (timestamp, {motif: [mots]})


def _neighbor_index(length):
    """Index {motif avec un joker -> mots} pour trouver les voisins à distance de Hamming 1."""
    entry = _neighbor_cache.get(length)
    if entry and time.time() - entry[0] < conf.get("CACHE_SECONDS"):
        return entry[1]
    db = get_database("DB_NEIGHBORS")
    _, DatabaseObject, _ = get_models()
    words = set(
        DatabaseObject.objects.filter(database=db)
        .annotate(_len=Length("ortho")).filter(_len=length)
        .values_list("ortho", flat=True).distinct())
    index = {}
    for w in words:
        w = norm(w)
        if len(w) != length:
            continue
        for i in range(length):
            index.setdefault(w[:i] + "\0" + w[i + 1:], []).append(w)
    _neighbor_cache[length] = (time.time(), index)
    return index


def clear_neighbor_cache():
    _neighbor_cache.clear()


def neighbors(word):
    index = _neighbor_index(len(word))
    found = set(chain.from_iterable(
        index.get(word[:i] + "\0" + word[i + 1:], ()) for i in range(len(word))))
    found.discard(word)
    return sorted(found)


# --------------------------------------------------------------------------- pseudomots

def _fmt(value):
    """Équivalent de as.character() de R pour un nombre (15 chiffres significatifs)."""
    if isinstance(value, bool):
        return str(int(value))
    if isinstance(value, (int, float)):
        return format(value, ".15g")
    return str(value)


def _num(value):
    try:
        return float(value)
    except (TypeError, ValueError):
        return 0.0


def _ngram_tables(pseudos):
    """Charge, pour tous les pseudomots à la fois, les lignes de lettres/bigrammes/trigrammes."""
    tables = {}
    for key, n, setting in NGRAM_TYPES:
        needed = {w[i:i + n] for w in pseudos for i in range(len(w) - n + 1)}
        rows = fetch_by_ortho(get_database(setting), needed) if needed else {}
        tables[key] = {k: v[0] for k, v in rows.items()}   # première ligne si doublon
    return tables


def pseudoword_values(word, tables, decimals):
    """Liste de 12 valeurs : [décomposition, moyenne] x (type n-gramme x Ty/To).

    Même algorithme que app.R : pour un n-gramme de taille n = count+1, on parcourt les
    len(word)-count positions ; position 1 -> « I », dernière -> « F », sinon « M ».
    Un n-gramme absent de la table compte pour 0. Si l'item est plus court que le n-gramme,
    les cellules restent vides.
    """
    out = []
    for key, n, _ in NGRAM_TYPES:
        count = n - 1
        positions = len(word) - count
        for subtype in SUBTYPES:
            if positions < 1:
                out += ["", ""]
                continue
            total, parts = 0.0, []
            for pos in range(1, positions + 1):
                spec = "I" if pos == 1 else ("F" if pos == positions else "M")
                row = tables[key].get(word[pos - 1:pos - 1 + n])
                value = row.get(f"{key}{subtype}{spec}") if row else None
                if value is None:
                    parts.append("0")
                else:
                    parts.append(_fmt(value))
                    total += _num(value)
            out += ["-".join(parts), round(total / positions, decimals)]
    return out


# --------------------------------------------------------------------------- requête

def run_query(text, options=()):
    items, ignored = parse_items(text)
    if not items:
        raise InfraError("Aucun item valide à rechercher.")
    if len(items) > conf.get("MAX_ITEMS"):
        raise InfraError("Trop d'items (%d). Maximum : %d." % (len(items), conf.get("MAX_ITEMS")))

    with_neighbors = "neighbors" in options

    words_db = get_database("DB_WORDS")
    cols = word_columns(words_db)
    pseudo_codes = pseudo_column_codes(cols)
    pseudo_slot = {code: i for i, code in enumerate(pseudo_codes)}

    found = fetch_by_ortho(words_db, items)
    pseudos = [w for w in items if w not in found]
    tables = _ngram_tables(pseudos) if pseudos else {}
    decimals = conf.get("MEAN_DECIMALS")

    columns = [{"code": "_item", "name": ITEM_LABEL, "description": ""},
               {"code": "_type", "name": TYPE_LABEL, "description": TYPE_LABEL}]
    if with_neighbors:
        columns += [{"code": "_nb_neighbors", "name": NEIGHBORS_COUNT_LABEL,
                     "description": NEIGHBORS_COUNT_LABEL},
                    {"code": "_neighbors", "name": NEIGHBORS_LABEL, "description": NEIGHBORS_LABEL}]
    columns += cols

    rows = []
    for word in items:
        if word in found:
            kind = TYPE_WORD
            variants = [[(d or {}).get(c["code"], "") for c in cols] for d in found[word]]
        else:
            kind = TYPE_PSEUDO
            vals = pseudoword_values(word, tables, decimals)
            variants = [[vals[pseudo_slot[c["code"]]] if c["code"] in pseudo_slot else ""
                         for c in cols]]
        for props in variants:
            row = [word, kind]
            if with_neighbors:
                nb = neighbors(word)
                row += [len(nb), ",".join(nb)]
            row += ["" if v is None else v for v in props]
            rows.append(row)

    return {
        "columns": columns,
        "rows": rows,
        "ignored": ignored,
        "n_words": sum(1 for w in items if w in found),
        "n_pseudowords": len(pseudos),
    }
