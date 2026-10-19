"""
Pseudoword generation by chaining bigrams / trigrams.

Pure-Python port of ``generate_pseudowords`` from the original Shiny app
(www/functions/generatePseudo.R). No Django dependency, so it can be unit-tested
and reused on its own.

Principle
---------
All source words ("models") have the same length L. With n-grams of size ``k``
(2 = bigram, 3 = trigram):

* step 0: pick a random model and keep its first ``k`` letters;
* step s (1 .. L-k): take the last ``k-1`` letters built so far, look at every
  model that has exactly those letters at positions s .. s+k-2 (0-based) and
  draw the next letter among the letters that follow them, proportionally to
  how many models give that letter.

The pseudoword therefore has length L, and ``L-k+1`` source words contribute to
it (one per step, plus the initial one).
"""
import random
import time
from dataclasses import dataclass, field

BIGRAM = "bigram"
TRIGRAM = "trigram"
ALGORITHMS = {BIGRAM: 2, TRIGRAM: 3}

MIN_LENGTH = 3
MAX_LENGTH = 15


class GenerationError(ValueError):
    """Raised when the request cannot be satisfied (bad parameters, no models...)."""


@dataclass
class Pseudoword:
    pseudoword: str
    # sources[i] is the model word that supplied the letter(s) at step i
    sources: list = field(default_factory=list)


@dataclass
class GenerationResult:
    pseudowords: list
    requested: int
    n_models: int
    sub_len: int

    @property
    def complete(self):
        return len(self.pseudowords) >= self.requested


def allowed_algorithms(length):
    """Algorithms usable for a pseudoword length (trigrams need length >= 4)."""
    return [BIGRAM] if length <= 3 else [BIGRAM, TRIGRAM]


def default_algorithm(length):
    """Same default as the Shiny app: bigram up to 5 letters, trigram beyond."""
    return BIGRAM if length <= 5 else TRIGRAM


class NgramModel:
    """Transition tables built from the source words."""

    def __init__(self, models, length, sub_len):
        self.models = models
        self.length = length
        self.sub_len = sub_len
        self.n_steps = length - sub_len  # letters added after the initial n-gram

        # tables[step][gram] = {next_letter: [count, [model indexes]]}
        raw = [dict() for _ in range(self.n_steps + 1)]
        for idx, model in enumerate(models):
            for step in range(1, self.n_steps + 1):
                gram = model[step:step + sub_len - 1]
                nxt = model[step + sub_len - 1]
                entry = raw[step].setdefault(gram, {}).setdefault(nxt, [0, []])
                entry[0] += 1
                entry[1].append(idx)

        # Freeze into (letters, cumulative weights, model indexes) for fast sampling
        self.tables = [dict() for _ in range(self.n_steps + 1)]
        for step in range(1, self.n_steps + 1):
            for gram, nexts in raw[step].items():
                letters, cum, srcs, total = [], [], [], 0
                for letter, (count, idxs) in nexts.items():
                    total += count
                    letters.append(letter)
                    cum.append(total)
                    srcs.append(idxs)
                self.tables[step][gram] = (letters, cum, srcs)

    def build(self, rng):
        """Build one candidate pseudoword; returns (string, [source words])."""
        k = self.sub_len
        first = rng.choice(self.models)
        letters = list(first[:k])
        sources = [first]
        for step in range(1, self.n_steps + 1):
            gram = "".join(letters[-(k - 1):])
            choices, cum, srcs = self.tables[step][gram]
            i = rng.choices(range(len(choices)), cum_weights=cum)[0]
            letters.append(choices[i])
            sources.append(self.models[rng.choice(srcs[i])])
        return "".join(letters), sources


def generate_pseudowords(
    n,
    length,
    models,
    algorithm,
    exclude=(),
    checks=(),
    time_out=0.5,
    rng=None,
):
    """
    Generate up to ``n`` distinct pseudowords.

    n          number of pseudowords wanted
    length     length of the pseudowords (and of every model)
    models     source words, all of length ``length`` (lower-cased, de-duplicated)
    algorithm  ``"bigram"`` or ``"trigram"``
    exclude    words that must not be produced (e.g. every real word of that length)
    checks     callables ``f(pseudoword) -> bool``; all must return True
    time_out   stop after this many seconds without finding a new valid
               pseudoword (same behaviour as the 500 ms limit of the R app)
    rng        optional ``random.Random`` (reproducible tests)
    """
    rng = rng or random.Random()

    if not models:
        raise GenerationError("no_models")
    if algorithm not in ALGORITHMS:
        raise GenerationError("Wrong substring type selected.")
    sub_len = ALGORITHMS[algorithm]
    if not (MIN_LENGTH <= length <= MAX_LENGTH) or length - sub_len < 1:
        raise GenerationError(
            "Pseudowords of length %d cannot be built with the %s algorithm." % (length, algorithm)
        )

    model = NgramModel(models, length, sub_len)
    forbidden = set(models)
    forbidden.update(exclude)

    found, seen = [], set()
    last_success = time.monotonic()
    while len(found) < n and (time.monotonic() - last_success) < time_out:
        pseudoword, sources = model.build(rng)
        if pseudoword in seen or pseudoword in forbidden:
            continue
        if any(not check(pseudoword) for check in checks):
            continue
        seen.add(pseudoword)
        found.append(Pseudoword(pseudoword, sources))
        last_success = time.monotonic()

    return GenerationResult(found, n, len(models), sub_len)
