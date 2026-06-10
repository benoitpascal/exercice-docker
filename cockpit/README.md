# Le cockpit live

Ce dossier ajoute une interface visuelle qui exécute de **vraies** commandes
Docker sur ta machine et affiche l'état réel de ton port (tes conteneurs, leurs
ports, leurs réseaux, leurs volumes) en direct. C'est la même chose que le
carnet : les mêmes étapes, mais avec un quai qui réagit pour de vrai.

Tu peux taper les commandes dans l'interface, ou dans ton propre terminal : le
quai se met à jour dans les deux cas, puisque tout pointe vers le même Docker.

## Ce qu'il te faut

- Docker installé et démarré.
- Node.js installé (n'importe quelle version récente). Aucune dépendance à
  installer, le serveur n'utilise que la bibliothèque standard de Node.

## Comment le lancer

Le serveur exécute les commandes depuis le dossier où tu le lances. Pour que
`docker build` et `docker compose` trouvent ton Dockerfile et ton compose.yaml,
lance-le depuis ton dossier de travail.

```bash
# 1. place-toi dans ton dossier de travail (celui qui contiendra ton Dockerfile)
cd ~/mon-app-custom

# 2. lance le cockpit (adapte le chemin vers ce dossier cockpit)
node ~/exercice-docker/cockpit/server.js

# 3. ouvre le cockpit dans ton navigateur
#    http://localhost:8099
```

Pour changer de port : `PORT=9000 node server.js`.

## Comment ça marche

- L'interface interroge l'état de Docker toutes les 1,5 seconde et redessine le
  quai.
- Quand tu valides une commande dans le poste de commande, elle est envoyée au
  serveur, qui lance le vrai `docker` et te renvoie sa sortie.
- La feuille de route valide chaque étape en regardant l'état réel (un
  conteneur nginx tourne avec un port publié, un réseau relie deux conteneurs,
  un volume est monté, la stack Compose est montée, etc.).

## Sécurité

C'est un outil local que tu lances toi-même sur ta propre machine. Par
précaution, le serveur :

- n'écoute que sur `127.0.0.1` (personne d'autre sur le réseau ne l'atteint),
- n'exécute QUE le binaire `docker`, jamais un shell. Les caractères comme
  `;`, `&&` ou `|` ne sont donc pas interprétés et ne peuvent pas enchaîner
  d'autres commandes.

Ne l'expose pas sur Internet et ne le mets pas derrière une URL publique.

## Deux façons de s'entraîner

Ce dossier contient en fait deux interfaces, pour deux usages :

- `index.html` + `server.js` : le **cockpit réel**. Il exécute tes commandes sur
  ta machine et reflète ton vrai Docker. C'est l'outil pour pratiquer.
- `demo-hors-ligne.html` : un **simulateur**. Tu l'ouvres directement dans un
  navigateur (double-clic, aucun serveur, aucun Docker requis). Les commandes ne
  font rien de réel, mais le quai réagit comme si. Parfait pour découvrir les
  commandes sans risque, ou tant que Docker n'est pas encore installé.

Même thème, même parcours, mêmes étapes. Le simulateur fait répéter, le
cockpit fait pratiquer pour de vrai.
