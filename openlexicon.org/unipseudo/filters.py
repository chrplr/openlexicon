"""
Constraints applied to generated pseudowords (port of filterFunctions.R).

Each constraint is "at most N of something"; the value ``None`` (empty string
in the form) means "no constraint".
"""
import unicodedata
from dataclasses import dataclass, field
from typing import Callable

NO_CONSTRAINT = ""

# Characters kept as "not a consonant" once accents have been stripped
_NON_CONSONANTS = set("aeiouyøœɔɛəɯαεıơ'.- \t\n")


def _skeleton(word):
    """Lower-case, strip accents, and map every consonant to 'C'."""
    decomposed = unicodedata.normalize("NFD", word.lower())
    base = "".join(ch for ch in decomposed if not unicodedata.combining(ch))
    return "".join(ch if ch in _NON_CONSONANTS else "C" for ch in base)


def check_consonants(pseudoword, max_consecutive):
    if len(pseudoword) <= max_consecutive:
        return True
    return "C" * (max_consecutive + 1) not in _skeleton(pseudoword)


def check_same_letter(pseudoword, max_times):
    if len(pseudoword) <= max_times:
        return True
    run, prev = 0, None
    for ch in pseudoword.lower():
        run = run + 1 if ch == prev else 1
        prev = ch
        if run > max_times:
            return False
    return True


# https://en.wikipedia.org/wiki/List_of_Unicode_characters (same ranges as the R app)
_ACCENT_RANGES = [
    (192, 197), (200, 214), (217, 221), (224, 229), (232, 246), (249, 253),
    (255, 255), (256, 304), (308, 329), (332, 337), (340, 382),
]


def _is_accented(ch):
    code = ord(ch)
    return any(lo <= code <= hi for lo, hi in _ACCENT_RANGES)


def check_diacritics(pseudoword, max_accents):
    if len(pseudoword) <= max_accents:
        return True
    count = 0
    for ch in pseudoword.lower():
        if _is_accented(ch):
            count += 1
            if count > max_accents:
                return False
    return True


@dataclass
class FilterSpec:
    name: str
    label: str
    options: list
    tooltip: str
    check: Callable
    # Database.language value -> preselected option
    presets: dict = field(default_factory=dict)


# Languages (values of Database.language, see models.Lang) that get the
# "latin script" defaults. Mirrors latin_languages in loadingDatasets.R.
_LATIN = ["French", "English", "Dutch", "German", "Spanish", "Italian", "Portuguese", "Catalan"]
_NO_CONSONANT_PRESET = {"Dutch", "German", "Danish", "Norwegian", "Swedish", "Welsh"}

FILTERS = [
    FilterSpec(
        name="filterConsonants",
        label="Max. consecutive consonants",
        options=[1, 2, 3, 4],
        tooltip=(
            "Your pseudowords will not contain more consecutive consonants than the "
            "number specified below. We advise to set this constraint to 3 for latin languages."
        ),
        check=check_consonants,
        presets={lang: 3 for lang in _LATIN if lang not in _NO_CONSONANT_PRESET},
    ),
    FilterSpec(
        name="filterSameLetter",
        label="Max. same letter consecutive",
        options=[1, 2, 3],
        tooltip=(
            "Your pseudowords will not contain the same consecutive letter more than the "
            "number specified below. We advise to set this constraint to 2 for all latin languages."
        ),
        check=check_same_letter,
        presets={lang: 2 for lang in _LATIN},
    ),
    FilterSpec(
        name="filterDiacritic",
        label="Max. diacritical letters",
        options=[1, 2, 3],
        tooltip=(
            "Your pseudowords will not contain more diacritical letters than the number "
            "specified below. We advise to set this constraint to 1 for Spanish."
        ),
        check=check_diacritics,
        presets={"Spanish": 1},
    ),
]

FILTERS_BY_NAME = {f.name: f for f in FILTERS}


def presets_for(language):
    """Default constraint values ({filter name: int}) for a Database.language."""
    return {f.name: f.presets[language] for f in FILTERS if language in f.presets}


def build_checks(values):
    """
    values: {filter name: int | '' | None}. Returns the list of check callables
    for the constraints that are active.
    """
    checks = []
    for name, value in (values or {}).items():
        spec = FILTERS_BY_NAME.get(name)
        if spec is None or value in (None, NO_CONSTRAINT):
            continue
        try:
            limit = int(value)
        except (TypeError, ValueError):
            continue
        checks.append(lambda w, s=spec, n=limit: s.check(w, n))
    return checks
