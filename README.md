# Le Port des Conteneurs : apprends Docker en pratiquant

Bienvenue. Ce dépôt est un parcours d'apprentissage de Docker, du tout début
jusqu'à la mise en ligne d'une image sur un registry. Tu vas prendre une petite
application web déjà écrite (un compteur de visites) et apprendre, étape par
étape, à la faire tourner dans des conteneurs.

Tu n'as pas besoin de savoir coder. L'application est fournie complète, tu ne
touches pas à son code : tu apprends seulement à la conteneuriser.

## Ce dont tu as besoin

- Docker installé sur ta machine (Docker Desktop sur Windows ou macOS, Docker
  Engine sur Linux). La phase 0 du carnet t'aide à vérifier.
- Un terminal.
- Un navigateur web.
- Pour la toute dernière mission : un compte gratuit sur un registry d'images
  (Docker Hub par exemple).

## Ce que tu vas trouver ici

- `carnet.md` : ta feuille de route. C'est le document central. Ouvre-le et lis
  la phase 0 en entier avant toute autre chose.
- `memo-commandes.md` : ta boîte à outils. La liste des commandes Docker et de
  leurs options, à garder ouverte à côté du carnet. Ce ne sont pas les solutions,
  ce sont les briques à assembler.
- `starter-app/` : la petite application web que tu vas faire vivre. Tu copies
  ce dossier dans ton espace de travail et tu travailles dessus.
- `checks/` : des scripts qui te disent, mission par mission, si tu as atteint
  l'objectif. Tu les lances toi-même quand le carnet te le demande.

## Première étape

Ouvre `carnet.md` et suis la phase 0, ligne par ligne.

```bash
cat carnet.md
```

(Ou ouvre `carnet.md` dans ton éditeur, ce sera plus confortable.)

Bonne traversée.
