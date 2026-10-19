"""
Settings of the app, read from ``settings.UNIPSEUDO`` (a dict, all keys optional).

UNIPSEUDO = {
    # app label that contains Database / DatabaseObject / DatabaseColumn.
    # Auto-detected when omitted.
    "MODELS_APP": "openlexicon",

    # Which DatabaseColumn holds the word frequency, by Database.language. Only words whose
    # frequency is > FREQ_THRESHOLD are used as models. {"exact": code} or {"contains": text}.
    # Languages not listed use FREQ_COLUMN_DEFAULT (WorldLex).
    "FREQ_COLUMN_RULES": {
        "French": {"contains": "FreqMot"},     # Lexique4
        "English": {"exact": "SUBTLWF"},       # English_Lexicon_Project
    },
    "FREQ_COLUMN_DEFAULT": {"exact": "BlogFreqPm"},
    "FREQ_THRESHOLD": 0.5,

    # Per-database overrides, keyed by Database.code.
    "DATABASE_OVERRIDES": {
        "WorldLex-Greenlandic": {"freq_threshold": -1},   # no usable frequencies
        # "MyDb": {"freq_column": "some_code", "freq_threshold": 1},
    },

    # Column holding the grammatical class (shows the "grammatical class" menu)
    "GRAM_COLUMN": "cgram",

    # Which database feeds "Use words from database" for a language (Database.language).
    # Languages not listed here use the first database (by name) whose name starts
    # with DEFAULT_DATABASE_PREFIX.
    "LANGUAGE_DATABASES": {"French": "Lexique4", "English": "English_Lexicon_Project"},
    "DEFAULT_DATABASE_PREFIX": "Worldlex",

    # Language menu: these come first (in this order), the others follow alphabetically;
    # DEFAULT_LANGUAGE is preselected when the page opens.
    "TOP_LANGUAGES": ["English", "French", "Dutch"],
    "DEFAULT_LANGUAGE": "English",

    "MIN_PSEUDOWORDS": 1,
    "MAX_PSEUDOWORDS": 5000,
    "MAX_MODEL_WORDS": 200000,
}
"""
from django.conf import settings

DEFAULTS = {
    "MODELS_APP": None,
    "FREQ_COLUMN_RULES": {"French": {"contains": "FreqMot"}, "English": {"exact": "SUBTLWF"}},
    "FREQ_COLUMN_DEFAULT": {"exact": "BlogFreqPm"},
    "FREQ_THRESHOLD": 0.5,
    "DATABASE_OVERRIDES": {},
    "GRAM_COLUMN": "cgram",
    "LANGUAGE_DATABASES": {"French": "Lexique4", "English": "English_Lexicon_Project"},
    "DEFAULT_DATABASE_PREFIX": "Worldlex",
    "TOP_LANGUAGES": ["English", "French", "Dutch"],
    "DEFAULT_LANGUAGE": "English",
    "MIN_PSEUDOWORDS": 1,
    "MAX_PSEUDOWORDS": 5000,
    "DEFAULT_PSEUDOWORDS": 20,
    "MAX_MODEL_WORDS": 200000,
}


def get(key):
    return getattr(settings, "UNIPSEUDO", {}).get(key, DEFAULTS[key])
