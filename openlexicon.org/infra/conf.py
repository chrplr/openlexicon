"""Réglages de l'app infra_query.

Tout est surchargeable dans settings.py du projet :

    INFRA_QUERY = {
        "DB_NEIGHBORS": "Lexique383",
        "MAX_ITEMS": 5000,
    }
"""
from django.conf import settings

DEFAULTS = {
    # Codes (Database.code, à défaut Database.name) des bases utilisées.
    # Ce sont les mêmes identifiants que dans loadingDatasets.R (dataset_ids).
    "DB_WORDS": "Lexique-Infra-word_frequency",   # table des mots (une ligne par mot)
    "DB_LETTERS": "Lexique-Infra-lettres",        # table des lettres
    "DB_BIGRAMS": "Lexique-Infra-bigrammes",      # table des bigrammes
    "DB_TRIGRAMS": "Lexique-Infra-trigrammes",    # table des trigrammes
    "DB_NEIGHBORS": "Lexique4",                 # base de référence pour les voisins orthographiques

    # Colonnes de DB_WORDS qui reçoivent, pour un pseudomot, la décomposition et la moyenne.
    # Dans app.R : colonnes 7 à 18 de la table (hors colonne TypeItem ajoutée), soit
    # (lettres Ty, lettres To, bigrammes Ty, bigrammes To, trigrammes Ty, trigrammes To)
    # x (décomposition, moyenne) = 12 colonnes.
    #   - PSEUDO_COLUMNS : liste explicite de 12 codes de colonnes (prioritaire), ou None
    #   - PSEUDO_SLICE   : sinon, tranche (début, fin) dans la liste ordonnée des colonnes de
    #                      DB_WORDS, SANS la colonne du mot lui-même.
    "PSEUDO_COLUMNS": None,
    "PSEUDO_SLICE": (4, 16),

    # Noms des colonnes de mot qu'on ne veut pas voir comme "propriété" (si présentes dans
    # DatabaseColumn). Comparaison insensible à la casse.
    "WORD_COLUMN_CODES": ("word", "ortho", "item"),

    "MAX_ITEMS": 10000,       # nombre maximum d'items par requête
    "MEAN_DECIMALS": 6,       # arrondi des moyennes calculées pour les pseudomots
    "CACHE_SECONDS": 3600,    # durée de vie de l'index des voisins orthographiques
    "CHUNK": 500,             # taille des paquets pour les requêtes IN (...)

    # Label de l'app Django qui contient models.py (Database, DatabaseObject, DatabaseColumn).
    # None = détection automatique.
    "MODELS_APP_LABEL": None,
}


def get(name):
    user = getattr(settings, "INFRA_QUERY", {}) or {}
    return user.get(name, DEFAULTS[name])
