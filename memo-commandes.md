# Mémo des commandes : ta boîte à outils

Ce mémo liste les commandes et les options dont tu auras besoin pendant le
parcours. Ce n'est PAS la solution des missions : tu y trouves les briques, mais
c'est à toi de choisir lesquelles utiliser et avec quelles valeurs pour atteindre
chaque objectif.

Notation utilisée :
- Les MOTS_EN_MAJUSCULES sont des trous à remplir (un nom, un port, une valeur).
- Les `[...]` sont des parties facultatives.

Pour voir toutes les options d'une commande, ajoute `--help`, par exemple
`docker run --help`.

## Lancer et observer des conteneurs

- `docker run [OPTIONS] IMAGE [COMMANDE]`
  Lance un conteneur à partir d'une image. Options utiles :
  - `-d` : en arrière-plan (detached), te rend la main dans le terminal.
  - `--name NOM` : donne un nom au conteneur.
  - `-p PORT_HOTE:PORT_CONTENEUR` : publie un port (ta machine vers le conteneur).
  - `-e VARIABLE=valeur` : passe une variable d'environnement.
  - `--network RESEAU` : branche le conteneur sur un réseau.
  - `-v VOLUME:CHEMIN_DANS_LE_CONTENEUR` : monte un volume.
- `docker ps` : liste les conteneurs en marche. `docker ps -a` : tous, même
  arrêtés.
- `docker logs NOM` : affiche les logs d'un conteneur.
- `docker exec -it NOM sh` : ouvre un shell interactif dans un conteneur en
  marche (`exit` pour ressortir). Parfois `bash` au lieu de `sh`.
- `docker stop NOM` : arrête un conteneur (il existe encore).
- `docker rm NOM` : supprime un conteneur arrêté. `docker rm -f NOM` force même
  s'il tourne.

## Gérer les images

- `docker images` : liste les images présentes sur ta machine.
- `docker build -t NOM:TAG .` : construit une image à partir du Dockerfile du
  dossier courant (le `.`), et la nomme `NOM:TAG`.
- `docker rmi NOM` : supprime une image.
- `docker tag SOURCE CIBLE` : ajoute un autre nom à une image existante.
- `docker pull NOM` : télécharge une image depuis un registry.
- `docker push NOM` : envoie une image vers un registry (nom au format
  `IDENTIFIANT/IMAGE:TAG`).
- `docker login` : te connecte à un registry (Docker Hub par défaut).

## Réseaux

- `docker network create NOM` : crée un réseau.
- `docker network ls` : liste les réseaux.
- Sur un réseau que tu as créé, un conteneur en joint un autre par son NOM.

## Volumes

- `docker volume create NOM` : crée un volume nommé.
- `docker volume ls` : liste les volumes.
- On monte un volume au lancement avec `-v NOM:CHEMIN_DANS_LE_CONTENEUR`.

## Docker Compose

La commande moderne est `docker compose` (deux mots).

- `docker compose up -d` : monte toute la stack décrite dans `compose.yaml`, en
  arrière-plan. Ajoute `--build` pour (re)construire les images au passage.
- `docker compose down` : démonte la stack. Ajoute `-v` pour effacer aussi les
  volumes.
- `docker compose ps` : liste les conteneurs de la stack.
- `docker compose logs -f` : suit les logs de tous les services.

## Les instructions d'un Dockerfile

Un Dockerfile est une recette. Les instructions que tu vas rencontrer :

- `FROM IMAGE` : l'image de base sur laquelle tu construis.
- `WORKDIR /chemin` : le dossier de travail à l'intérieur de l'image.
- `COPY source destination` : copie des fichiers dans l'image.
- `RUN commande` : exécute une commande pendant la construction (installer des
  dépendances, par exemple).
- `EXPOSE PORT` : documente le port sur lequel l'app écoute.
- `CMD ["programme", "argument"]` : la commande lancée au démarrage du conteneur.

## En cas de pépin

- "port is already allocated" : un conteneur occupe déjà ce port. `docker ps`
  pour le trouver, puis `stop`/`rm`, ou change le port côté hôte.
- "Cannot connect to the Docker daemon" : Docker n'est pas démarré.
- `docker-compose` introuvable : c'est l'ancienne version. Utilise
  `docker compose` (deux mots).
