# Carnet de bord : Le Port des Conteneurs

Ce carnet te guide de zéro à une application multi-conteneurs publiée sur un
registry. Chaque mission introduit une seule notion nouvelle. Tu n'auras jamais
la commande toute faite : tu auras l'objectif, le nom des outils à utiliser, et
des indices. À toi d'assembler. Quand tu bloques, deux réflexes :

1. `docker NOM_DE_COMMANDE --help` t'affiche toutes les options d'une commande.
2. La documentation officielle (docs.docker.com) est claire et pleine d'exemples.

À la fin de chaque mission, tu lances un script de vérification qui te dit si
c'est bon. Ne passe à la mission suivante que quand le script est content.

## Petit glossaire avant de commencer

- **Image** : un modèle figé, en lecture seule, qui contient tout ce qu'il faut
  pour faire tourner un programme (le système de base, le code, les
  dépendances). C'est comme un moule.
- **Conteneur** : une instance vivante d'une image, en train de tourner. C'est
  l'objet sorti du moule. On peut en lancer plusieurs à partir de la même image.
- **Dockerfile** : une recette texte qui décrit comment fabriquer ta propre
  image.
- **Volume** : un espace de stockage qui survit à la suppression d'un conteneur,
  pour ne pas perdre les données.
- **Réseau** : ce qui permet à plusieurs conteneurs de se parler entre eux.
- **Registry** : un entrepôt en ligne d'images (Docker Hub est le plus connu),
  d'où l'on télécharge et où l'on publie des images.

Quelques conventions de nommage utilisées tout au long du parcours. Respecte-les,
les scripts de vérification s'attendent à ces noms.

- Ton image d'application : `pixel-counter:1.0`
- Le conteneur de l'application : `compteur`, publié sur le port `3000`
- Le conteneur Redis : `cache`
- Le réseau : `pixel-net`
- Le volume : `pixel-data`

---

## Phase 0 : préparer le terrain

Objectif : confirmer que Docker fonctionne et installer ton espace de travail.

1. Vérifie que Docker répond. Une commande affiche sa version. Si tu obtiens un
   numéro de version, tu es prêt. Sinon, installe Docker (voir le README).
2. Fais le test de bienvenue officiel de Docker : il existe une toute petite
   image nommée `hello-world` que l'on peut lancer. Si un message de félicitations
   s'affiche, ton installation est saine.
3. Récupère ce dépôt sur ta machine (clone ou téléchargement du zip).
4. Copie le dossier `starter-app/` ailleurs et renomme la copie `pixel-counter`.
   C'est ton chantier. Tu travailleras toujours depuis ce dossier.

Indices :

- La sous-commande qui affiche la version est très courante, elle se devine.
- Pour lancer une image, la commande de base de Docker est `run`. Quel mot
  mets-tu après `docker` pour exécuter quelque chose ?

Vérifie-toi : `bash checks/check-0.sh`

---

## Mission 1 : ton premier vrai conteneur

Contexte : `hello-world` s'arrête tout de suite. On veut maintenant un conteneur
qui reste vivant et qui sert une page web qu'on voit dans le navigateur. On va
utiliser `nginx`, un serveur web très répandu, dont l'image officielle existe
déjà sur Docker Hub.

Objectif :

- Lancer un conteneur basé sur l'image `nginx`.
- Le faire tourner en arrière-plan (pour récupérer ton terminal).
- Le nommer `vitrine`.
- Rendre sa page visible sur `http://localhost:8080` de ta machine.

Quand tout est bon, tu ouvres `http://localhost:8080` et tu vois la page
d'accueil de nginx.

Notions : image officielle, lancer un conteneur, mode arrière-plan, nommage,
publication de port (faire correspondre un port de ta machine à un port du
conteneur), lister les conteneurs qui tournent.

Indices :

- nginx écoute sur le port `80` à l'intérieur du conteneur. Toi tu veux y accéder
  via le `8080` de ta machine. Il existe une option pour relier ces deux ports.
  Cherche-la dans `docker run --help` (pense à "publish").
- Le mode arrière-plan a une option d'une lettre (pense à "detached").
- Pour donner un nom, il y a une option `--name`.
- Pour voir ce qui tourne, une commande liste les conteneurs actifs.

Vérifie-toi : `bash checks/check-1.sh`

---

## Mission 2 : vivre avec un conteneur

Contexte : un conteneur, ça s'inspecte, ça se débogue, ça se range. On reste sur
le conteneur `vitrine` de la mission 1.

Objectif, dans l'ordre :

1. Afficher les logs du conteneur `vitrine`.
2. Ouvrir un shell À L'INTÉRIEUR du conteneur en marche, regarder un peu, puis en
   ressortir.
3. Arrêter le conteneur, puis le supprimer.
4. Lister les images présentes sur ta machine, puis supprimer l'image `nginx`
   (tu la retéléchargeras si besoin, ce n'est pas grave).

À la fin, plus aucun conteneur `vitrine`, et le port 8080 est libre.

Notions : `logs`, exécuter une commande dans un conteneur (`exec`), différence
arrêter / supprimer, gestion des images, ménage.

Indices :

- Pour entrer dans un conteneur, on exécute un shell dedans. La commande tourne
  autour de `exec`, avec deux options qui vont souvent ensemble pour avoir un
  terminal interactif (pense à "interactive" et "tty"). Le shell à lancer est
  souvent `sh` ou `bash`.
- Un conteneur en marche ne se supprime pas directement : il faut d'abord
  l'arrêter (ou forcer).
- Les commandes sur les images se trouvent sous `docker image ...` ou via des
  raccourcis comme `docker images` et `docker rmi`.

Vérifie-toi : `bash checks/check-2.sh`

---

## Mission 3 : fabrique ta propre image

Contexte : jusqu'ici tu as utilisé des images faites par d'autres. Maintenant tu
vas emballer l'application du dossier `pixel-counter` dans ta propre image.

Objectif :

- Écrire un fichier `Dockerfile` à la racine de ton dossier `pixel-counter`.
- Construire une image nommée `pixel-counter:1.0` à partir de ce Dockerfile.
- Lancer un conteneur `compteur` à partir de cette image, en arrière-plan,
  accessible sur `http://localhost:3000`.
- Écrire aussi un fichier `.dockerignore` pour ne pas embarquer ce qui ne sert
  à rien dans l'image.

Quand tout est bon, tu ouvres `http://localhost:3000`, tu vois le compteur
augmenter à chaque rechargement, et un bandeau "mode dégradé" (c'est normal, il
n'y a pas encore de Redis : on s'en occupe plus tard).

Notions : Dockerfile (image de base, dossier de travail, copie des fichiers,
installation des dépendances, port exposé, commande de démarrage), construction
d'image, cache des couches, `.dockerignore`.

Indices :

- L'application est en Node.js. Il existe des images de base officielles
  `node` (par exemple `node:22-alpine`, légère). Pars de l'une d'elles.
- Lis le haut de `server.js` : il liste les variables d'environnement reconnues
  et te rappelle que l'app écoute sur le port `3000` par défaut.
- Les instructions d'un Dockerfile que tu vas croiser : `FROM`, `WORKDIR`,
  `COPY`, `RUN`, `EXPOSE`, `CMD`. Cherche à quoi sert chacune.
- Ordre malin : copie d'abord `package.json` seul, installe les dépendances,
  PUIS copie le reste du code. Pose-toi la question "pourquoi cet ordre rend les
  reconstructions plus rapides ?" (réponse : le cache des couches).
- Pour installer les dépendances Node, la commande est `npm install`.
- Dans `.dockerignore`, le candidat évident à exclure est `node_modules`.
- La commande de construction d'image tourne autour de `build`, avec une option
  `-t` pour donner le nom et le tag.

Vérifie-toi : `bash checks/check-3.sh`

---

## Mission 4 : configure sans reconstruire

Contexte : ton image est figée, mais tu veux pouvoir changer le message affiché
sans refabriquer l'image. C'est exactement le rôle des variables d'environnement.

Objectif :

- Arrêter et supprimer ton conteneur `compteur` actuel.
- Relancer un conteneur `compteur` à partir de la MÊME image `pixel-counter:1.0`,
  mais en lui passant un message personnalisé via la variable d'environnement
  `APP_MESSAGE` (mets ce que tu veux, par exemple le nom de ta ville).

Quand tout est bon, `http://localhost:3000` affiche ton message à la place de
"Bonjour le monde", sans que tu aies reconstruit l'image.

Notions : variables d'environnement passées au lancement, séparation entre
l'image (le quoi) et la configuration (le comment).

Indices :

- L'option pour passer une variable d'environnement à `docker run` est une
  lettre (pense à "environment").
- Le nom exact de la variable est dans le commentaire en haut de `server.js`.

Vérifie-toi : `bash checks/check-4.sh`

---

## Mission 5 : deux conteneurs qui se parlent

Contexte : le compteur repart à zéro à chaque redémarrage, parce qu'il vit en
mémoire. On va lui donner une vraie mémoire externe : un serveur Redis, dans son
propre conteneur. Pour que ton app trouve Redis, les deux conteneurs doivent
être sur le même réseau et s'appeler par leur nom.

Objectif :

- Créer un réseau Docker nommé `pixel-net`.
- Lancer un conteneur Redis nommé `cache`, basé sur l'image `redis:7-alpine`,
  branché sur le réseau `pixel-net`. Démarre Redis en mode "appendonly" pour
  qu'il écrive ses données (utile à la mission suivante).
- Relancer ton conteneur `compteur` sur le même réseau `pixel-net`, en lui
  disant où trouver Redis grâce à la variable `REDIS_HOST` (la valeur, c'est le
  nom du conteneur Redis).

Quand tout est bon, le bandeau "mode dégradé" disparaît et affiche "stocké dans
Redis". Le compteur continue maintenant de monter même si tu redémarres le
conteneur `compteur`, tant que `cache` tourne.

Notions : réseau défini par l'utilisateur, résolution de nom (un conteneur joint
un autre par son nom sur le même réseau), variables d'environnement de connexion.

Indices :

- Les commandes de réseau sont sous `docker network ...` (pense à `create`).
- Pour brancher un conteneur sur un réseau au lancement : option `--network`.
- Pour activer l'appendonly de Redis, on passe une commande au conteneur :
  `redis-server --appendonly yes` (cherche comment ajouter une commande après
  le nom de l'image dans `docker run`).
- Le nom de la variable de connexion est, encore une fois, dans `server.js`.
- Rappel : ton app écoute le port 3000, pense à le republier quand tu relances
  `compteur`.

Vérifie-toi : `bash checks/check-5.sh`

---

## Mission 6 : que les données survivent

Contexte : ton compteur vit dans Redis, mais si tu supprimes le conteneur
`cache`, tout est perdu. On veut que les données survivent à la disparition du
conteneur. C'est le rôle d'un volume.

Objectif :

- Créer un volume nommé `pixel-data`.
- Relancer le conteneur `cache` en montant ce volume sur le dossier où Redis
  écrit ses données, c'est-à-dire `/data` à l'intérieur du conteneur.
- Prouver la persistance : note le compteur, supprime le conteneur `cache`
  (pas le volume), relance un nouveau `cache` avec le même volume, recharge la
  page. Le compteur doit reprendre là où il en était.

Notions : volume nommé, point de montage, persistance des données indépendante du
cycle de vie du conteneur, différence avec un "bind mount" (montage d'un dossier
de ta machine).

Indices :

- Les commandes de volume sont sous `docker volume ...` (pense à `create`).
- Pour monter un volume au lancement, l'option est `-v` (ou `--mount`), sous la
  forme `nom_du_volume:chemin_dans_le_conteneur`.
- Pour aller plus loin (facultatif) : un "bind mount" relie un dossier de TA
  machine à un dossier du conteneur. Compare avec le volume nommé. Lequel est le
  plus adapté pour des données de base de données ?

Vérifie-toi : `bash checks/check-6.sh`

---

## Mission 7 : tout orchestrer avec Compose

Contexte : relancer la main toutes les commandes (réseau, volume, deux
conteneurs, variables) à chaque fois, c'est pénible et fragile. Docker Compose
décrit toute la stack dans un seul fichier, et la monte d'une commande.

Objectif :

- Écrire un fichier `compose.yaml` dans ton dossier `pixel-counter` qui décrit
  deux services : l'application (construite depuis ton Dockerfile) et Redis.
- Le fichier doit recréer ce que tu as monté à la main : le réseau (Compose en
  crée un automatiquement), le volume `pixel-data` pour Redis, les variables
  d'environnement (`APP_MESSAGE`, `REDIS_HOST`), la publication du port 3000.
- D'abord, fais le ménage : arrête et supprime tes conteneurs `compteur` et
  `cache` lancés à la main, pour libérer le port et les noms.
- Monter toute la stack avec une seule commande, en arrière-plan.

Quand tout est bon, après la commande de montage, `http://localhost:3000` répond,
le compteur est en mode "stocké dans Redis", et tu n'as tapé qu'une commande.

Notions : fichier Compose, notion de service, build depuis un Dockerfile dans
Compose, dépendances entre services, volumes et variables dans Compose, monter
et démonter la stack, voir les logs de tous les services.

Indices :

- La commande moderne est `docker compose` (deux mots), pas l'ancien
  `docker-compose`.
- Dans le fichier, un service peut soit utiliser une `image` existante (cas de
  Redis), soit se faire `build` depuis un Dockerfile (cas de ton app).
- Les clés utiles dans un service : `build`, `image`, `ports`, `environment`,
  `volumes`, `depends_on`, `command`.
- Pour que ton app trouve Redis, `REDIS_HOST` doit valoir le NOM du service
  Redis tel que tu l'écris dans le fichier Compose.
- Monter la stack : sous-commande `up`, avec l'option arrière-plan. Démonter :
  sous-commande `down`. Voir les logs : sous-commande `logs`.

Vérifie-toi : `bash checks/check-7.sh`

---

## Mission 8 : publier ton image sur un registry

Contexte : ton image n'existe que sur ta machine. Pour la déployer ailleurs (un
serveur, un collègue), il faut la publier sur un registry. On prend Docker Hub,
mais n'importe quel registry fonctionne pareil.

Objectif :

- Avoir un compte sur un registry (Docker Hub propose un compte gratuit).
- Te connecter au registry depuis le terminal.
- Donner à ton image un nom compatible registry, de la forme
  `TON_IDENTIFIANT/pixel-counter:1.0` (re-tag de l'image existante).
- Pousser cette image sur le registry.

Quand tout est bon, ton image apparaît dans ton espace sur le registry, et
n'importe qui (ou ton serveur) peut la télécharger.

Notions : identité d'une image (`registre/utilisateur/image:tag`), connexion au
registry, re-tag, envoi (`push`), et l'opération inverse pour récupérer (`pull`).

Indices :

- Une image peut porter plusieurs noms (tags) qui pointent vers le même contenu.
  La commande pour ajouter un nom tourne autour de `tag`.
- Pour te connecter : commande autour de `login`.
- Pour envoyer : commande autour de `push`. Le nom poussé doit inclure ton
  identifiant sur le registry, sinon Docker ne sait pas où l'envoyer.

Vérifie-toi : `bash checks/check-8.sh`

---

## Tu es arrivé au bout

Tu sais maintenant : lancer des conteneurs, fabriquer tes propres images, les
configurer, les faire communiquer, persister leurs données, orchestrer une stack
avec Compose, et publier sur un registry. C'est le socle dont on se sert tous les
jours.

Pour aller plus loin : les health checks dans Compose, les images multi-étapes
(multi-stage build) pour des images plus petites, les variables dans un fichier
`.env`, et le nettoyage avec `docker system prune`.

Bonne continuation.
