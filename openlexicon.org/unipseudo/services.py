"""Access to the word databases (Database / DatabaseObject / DatabaseColumn)."""
from functools import lru_cache

from django.apps import apps
from django.core.cache import cache
from django.db.models.functions import Length

from . import conf


@lru_cache(maxsize=1)
def get_models():
    """Return (Database, DatabaseObject, DatabaseColumn), wherever they live."""
    label = conf.get("MODELS_APP")
    if label:
        cfg = apps.get_app_config(label)
        return tuple(cfg.get_model(n) for n in ("Database", "DatabaseObject", "DatabaseColumn"))
    for cfg in apps.get_app_configs():
        try:
            return tuple(cfg.get_model(n) for n in ("Database", "DatabaseObject", "DatabaseColumn"))
        except LookupError:
            continue
    raise LookupError(
        "unipseudo: cannot find the Database/DatabaseObject/DatabaseColumn models. "
        "Set UNIPSEUDO['MODELS_APP'] in settings."
    )


def list_languages():
    """
    Distinct values of Database.language over all existing databases:
    TOP_LANGUAGES first (English, French, Dutch), then the others alphabetically.
    """
    Database = get_models()[0]
    found = set(Database.objects.values_list("language", flat=True).distinct())
    top = [lang for lang in conf.get("TOP_LANGUAGES") if lang in found]
    return top + sorted(found - set(top))


def get_database_for_language(language):
    """
    The single database used to pick words for ``language``:
    the one configured in LANGUAGE_DATABASES (French -> Lexique4, English ->
    English_Lexicon_Project), otherwise the first database of that language whose
    name starts with DEFAULT_DATABASE_PREFIX ("Worldlex"). None if there is none.
    """
    if not language:
        return None
    Database = get_models()[0]
    qs = Database.objects.filter(language=language)
    configured = conf.get("LANGUAGE_DATABASES").get(language)
    if configured:
        return qs.filter(name__iexact=configured).first()
    return qs.filter(name__istartswith=conf.get("DEFAULT_DATABASE_PREFIX")).order_by("name").first()


def _column_codes(database):
    DatabaseColumn = get_models()[2]
    return set(DatabaseColumn.objects.filter(database=database).values_list("code", flat=True))


class FrequencyColumnError(LookupError):
    """The frequency column of a database could not be found (message shown to the user)."""


def _find_frequency_column(database, codes):
    """Frequency column code for this database, or None. See FREQ_COLUMN_RULES in conf.py."""
    override = conf.get("DATABASE_OVERRIDES").get(database.code, {})
    if override.get("freq_column"):
        return override["freq_column"] if override["freq_column"] in codes else None
    rule = conf.get("FREQ_COLUMN_RULES").get(database.language, conf.get("FREQ_COLUMN_DEFAULT"))
    if "exact" in rule:
        return rule["exact"] if rule["exact"] in codes else None
    needle = rule["contains"].lower()
    matches = sorted((c for c in codes if needle in c.lower()), key=lambda c: (len(c), c))
    return matches[0] if matches else None


def _describe_rule(database):
    rule = conf.get("FREQ_COLUMN_RULES").get(database.language, conf.get("FREQ_COLUMN_DEFAULT"))
    return 'named "%s"' % rule["exact"] if "exact" in rule else 'containing "%s"' % rule["contains"]


def database_settings(database):
    """
    Which column holds the frequency / how strict to be, for this database.
    Returns {"freq_column": str | None, "freq_threshold": float, "gram_column": str | None}
    """
    codes = _column_codes(database)
    override = conf.get("DATABASE_OVERRIDES").get(database.code, {})
    gram = conf.get("GRAM_COLUMN")
    return {
        "freq_column": _find_frequency_column(database, codes),
        "freq_threshold": override.get("freq_threshold", conf.get("FREQ_THRESHOLD")),
        "gram_column": gram if gram in codes else None,
    }


def _to_float(value):
    try:
        return float(value)
    except (TypeError, ValueError):
        return None


def get_words(database, length, gram_class=None, need_full_list=False):
    """
    Words of ``length`` letters from ``database``.

    need_full_list=False  words used as *models*: frequency > threshold (and of the
                          chosen grammatical class, if any). Raises FrequencyColumnError
                          if the database has no frequency column.
    need_full_list=True   every word of that length, used to *exclude* real
                          words from the generated pseudowords
    Returns a de-duplicated, lower-cased list (order preserved).
    """
    DatabaseObject = get_models()[1]
    qs = (
        DatabaseObject.objects.filter(database=database)
        .annotate(_nchar=Length("ortho"))
        .filter(_nchar=length)
    )

    if need_full_list:
        words = qs.values_list("ortho", flat=True)
        return list(dict.fromkeys(w.lower() for w in words if len(w) == length))

    cfg = database_settings(database)
    if cfg["freq_column"] is None:
        raise FrequencyColumnError(
            'Frequency column not found: database "%s" has no column %s, '
            "so words cannot be filtered by frequency." % (database.name, _describe_rule(database))
        )
    use_gram = bool(gram_class) and cfg["gram_column"] is not None

    out = {}
    for ortho, data in qs.values_list("ortho", "jsonData").iterator():
        data = data if isinstance(data, dict) else {}
        freq = _to_float(data.get(cfg["freq_column"]))
        if freq is None or freq <= cfg["freq_threshold"]:
            continue  # unknown frequency, or too rare
        if use_gram and data.get(cfg["gram_column"]) != gram_class:
            continue
        word = ortho.lower()
        if len(word) == length:
            out[word] = None
    return list(out)


def get_gram_classes(database):
    """Distinct values of the grammatical-class column (cached), or []."""
    cfg = database_settings(database)
    if cfg["gram_column"] is None:
        return []
    key = "unipseudo:gram:%s" % database.pk

    def compute():
        DatabaseObject = get_models()[1]
        values = set()
        for data in DatabaseObject.objects.filter(database=database).values_list("jsonData", flat=True).iterator():
            if isinstance(data, dict) and data.get(cfg["gram_column"]):
                values.add(str(data[cfg["gram_column"]]))
        return sorted(values)

    return cache.get_or_set(key, compute, 3600)
