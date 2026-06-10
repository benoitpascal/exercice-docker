# Carnet de bord du gestionnaire de port

## Où tu es, et ce qu'on attend de toi

Bienvenue au **Port des Conteneurs**. Ici tournent des applications en ligne
(une page web, une base de données, et d'autres) que des **visiteurs** viennent
utiliser. Les faire tourner, leur ouvrir l'accès, les relier et les garder en vie :
c'est ton métier.

Tu viens d'être nommé **gestionnaire du port**. Concrètement, tu mets des
applications en service, tu leur ouvres un **quai** pour que les **bateaux** (les
visiteurs) puissent les atteindre, tu les relies quand il le faut, et tu fais en
sorte qu'elles tiennent dans le temps. Une application tourne à l'intérieur d'un
**bâtiment** que tu lèves à partir d'un **plan** ; certains plans sont prêts à
l'emploi, d'autres, tu les rédiges toi-même.

L'autorité portuaire (ce carnet) t'apprend le métier sur le tas, au fil des
arrivées. Tu ne lis pas un cours : tu réagis à des situations. À chaque étape, on te
donne le contexte et la règle du port, puis on te laisse agir. Tu ne reçois jamais
la commande toute faite : tu as l'objectif et des indices, à toi de trouver les bons
gestes. Quand tu bloques :

1. `memo-commandes.md` est ton manuel d'opérations (toutes les commandes et leurs
   options). Les outils sont là, à toi de choisir.
2. `docker NOM --help` détaille une commande.
3. La doc officielle (docs.docker.com) est claire et pleine d'exemples.

À la fin de chaque étape, lance le contrôle indiqué (`bash checks/check-N.sh`).
Tu peux tout faire dans ton terminal, ou dans le **cockpit visuel** (dossier
`cockpit/`) : ce sont les mêmes 10 étapes, et la rade te montre ton port en
direct.

## Le vocabulaire du port

- **Image** : le plan figé d'un service. On en récupère des tout faits, publiés
  par d'autres, ou on rédige les siens.
- **Bâtiment** (un conteneur, lancé par `docker run`) : l'enveloppe dans laquelle
  tourne un service. Le service est **en marche** ou **à l'arrêt** ; à l'arrêt, il
  ne conserve rien en propre.
- **Bateau** : un visiteur qui vient utiliser un service (une requête qui accoste).
- **Quai** (un port publié) : l'accès où les bateaux accostent. Chaque quai porte
  un numéro, et deux quais ne peuvent pas avoir le même numéro, sinon les bateaux
  ne savent plus où aller.
- **Conteneur maritime** (un volume) : la caisse scellée qui garde les données,
  même quand le bâtiment qui s'en servait ferme ou est démoli.
- **Pont** (un réseau) : deux bâtiments ne se parlent que reliés par un pont.
  Sans pont, ce sont des îles séparées par l'eau.
- **Quartier** (un projet Docker Compose) : tout un ensemble de bâtiments, ponts
  et conteneurs maritimes, posé d'un seul geste à partir d'un plan.
- **Entrepôt central** (un registry) : là où l'on dépose ses plans pour qu'un
  autre port puisse les récupérer.

## Noms à respecter

Les contrôles attendent ces noms.

- Bâtiment d'accueil (prêt à l'emploi) : `accueil` (image `nginx`)
- Ton image : `mon-app-custom:1.0`
- Ton bâtiment : `app`, quai `3000`
- Entrepôt de données : `cache` (image `redis:7-alpine`)
- Pont : `app-net`
- Conteneur maritime : `app-data`

## Avant de prendre ton poste

Vérifie que le port est sous tension : une commande affiche la version de Docker.
Si tu obtiens un numéro, tu peux commencer. Récupère ce dépôt, copie le dossier
`starter-app/` ailleurs et renomme la copie `mon-app-custom` : c'est ton chantier,
tu y rédigeras tes plans, et c'est de là que tu lanceras tes commandes.

---

## Étape 1 : accueillir les bateaux

> Des bateaux se présentent déjà à l'entrée du port, et personne pour les
> accueillir. Ta première affaire : leur ouvrir un accueil. Pas la peine d'en
> bâtir un sur mesure, un accueil standard, déjà tout équipé, fera très bien
> l'affaire pour commencer.

Ce qu'on attend de toi :

- Ouvrir un bâtiment nommé `accueil` à partir de l'image `nginx`, en arrière-plan.
- Vérifier qui occupe le port (lister les bâtiments ouverts).

La règle du jour : une **image** est un plan ; le **bâtiment** est ce que tu
obtiens quand tu lances ce plan. On peut ouvrir plusieurs bâtiments à partir du
même plan.

Indices :

- Pour transformer une image en bâtiment qui tourne, le mémo liste la commande qui lance une image, et l'option qui la laisse tourner en fond (mot-clé anglais : detached).
- Pour savoir qui occupe le port, une commande affiche les bâtiments en marche (regarde la section "voir ce qui tourne" du mémo).

Contrôle : `bash checks/check-1.sh`

---

## Étape 2 : ton propre établissement

> Cet accueil standard dépanne, mais il n'est pas fait pour ton port. Le moment
> est venu d'ouvrir le tien, conçu pour tes besoins. Tu n'en trouveras nulle
> part de tout prêt : il faut le bâtir, d'après tes propres plans.

Ce qu'on attend de toi :

- Rédiger les plans de ton établissement : un fichier `Dockerfile` à la racine de ton
  chantier.
- Construire ton image, nommée `mon-app-custom:1.0`.
- Ouvrir ton établissement, nommé `app`, en arrière-plan.
- Rédiger aussi un `.dockerignore` pour ne pas embarquer l'inutile dans le plan.

Pour l'instant ton établissement tourne, mais aucun bateau ne peut encore l'atteindre :
on s'occupe du quai bientôt.

La règle du jour : un **Dockerfile** décrit, étape par étape, comment fabriquer
ton image. On la fabrique avec `build`.

Indices :

- Un Dockerfile se lit comme une recette, de haut en bas : partir d'une base, installer, copier le code, dire quoi lancer au démarrage. Le mémo liste les instructions disponibles ; l'ordre, c'est à toi.
- L'app est en Node.js : choisis une image de base Node officielle, plutôt légère.
- Astuce de performance : copie d'abord le fichier des dépendances et installe-les, le code seulement après. Cherche pourquoi (le cache des couches).
- Construire une image se fait avec une commande dédiée (mot-clé : build) et un nom donné par une option ; le .dockerignore sert à ne pas embarquer l'inutile (le gros dossier des dépendances en tête).

Contrôle : `bash checks/check-2.sh`

---

## Étape 3 : faire le ménage

> Ton établissement est ouvert ; le vieil accueil de dépannage n'a plus lieu
> d'être. Avant de le fermer pour de bon, c'est l'occasion d'apprendre à
> t'occuper d'un service au quotidien : voir ce qu'il raconte, y entrer un
> instant, l'arrêter. Puis débarrasse le port de cet accueil devenu inutile.

Ce qu'on attend de toi, sur le bâtiment `accueil` :

1. Lire ses journaux (logs).
2. Y entrer (ouvrir un shell à l'intérieur), regarder, ressortir.
3. Le fermer, puis l'évacuer (le supprimer).

La règle du jour : **fermer** un bâtiment (arrêter) n'est pas l'**évacuer**
(supprimer). Et un service en marche ne s'évacue pas directement : arrête-le d'abord,
ou force.

Indices :

- Trois familles de gestes : lire ce que le bâtiment raconte (ses journaux), entrer dedans pour regarder, puis l'arrêter et le supprimer. Le mémo a une commande pour chacun.
- Entrer dans un bâtiment, c'est y lancer un shell de façon interactive (deux options vont ensemble pour obtenir un vrai terminal ; le mémo les signale). Le shell s'appelle souvent sh.
- Garde en tête la différence entre arrêter et supprimer : un bâtiment en marche refuse d'être supprimé sans qu'on force.

Contrôle : `bash checks/check-3.sh`

---

## Étape 4 : ouvrir un quai

> Ton établissement tourne, mais aucun bateau ne peut l'atteindre : il n'a pas
> d'accès sur la mer. Ouvre-lui un quai pour que les bateaux viennent y
> accoster. Et retiens la règle d'or : deux quais ne peuvent pas porter le même
> numéro, sinon les bateaux ne savent plus où aller.

Ce qu'on attend de toi :

- Ouvrir un quai sur ton établissement `app` : relier le numéro `3000` de ta
  machine au port `3000` du bâtiment. Comme un quai se fixe à l'ouverture du
  bâtiment, tu devras fermer et rouvrir `app` avec son quai.
- Vérifier en allant voir `http://localhost:3000` : le total s'affiche et
  monte à chaque visite.

La règle du jour : un numéro de quai est **unique** sur le port. Deux bâtiments ne
peuvent pas réclamer le même numéro, sinon les bateaux ne savent plus où accoster
(c'est l'erreur "port already allocated"). Un bateau, lui, peut très bien accoster
à un quai puis laisser la place au suivant.

Indices :

- Tu veux qu'un accès extérieur (un quai numéroté) pointe vers le port interne du bâtiment. Cherche dans le mémo l'option de publication d'un port (mot-clé anglais : publish).
- Cette option se règle à l'ouverture du bâtiment, pas après coup : il faut donc évacuer `app` et le rouvrir avec son quai.

Contrôle : `bash checks/check-4.sh`

---

## Étape 5 : l'enseigne

> Les premiers bateaux accostent, et ton établissement les accueille avec un mot
> affiché en façade. Tu voudras pouvoir le changer selon l'occasion, sans tout
> rebâtir à chaque fois. Glisse-lui son message au moment de l'ouvrir.

Ce qu'on attend de toi :

- Rouvrir `app` (même image, même quai) en lui donnant une enseigne
  personnalisée via la variable d'environnement `APP_MESSAGE`.
- Vérifier sur `http://localhost:3000` : ton message s'affiche, sans
  reconstruction.

La règle du jour : l'**image** dit ce qu'est le bâtiment ; la **configuration**
(les variables d'environnement) dit comment il se comporte aujourd'hui. On change
la configuration sans toucher au plan.

Indices :

- Tu veux passer une valeur au bâtiment au moment de l'ouvrir, sans retoucher au plan. Cherche l'option des variables d'environnement (mot-clé : environment).
- Le nom exact de la variable attendue est écrit en haut de `server.js`.

Contrôle : `bash checks/check-5.sh`

---

## Étape 6 : la mémoire qui survit

> On aurait besoin de garder la liste des bateaux déjà passés. Problème : tout
> ce que ton établissement enregistre est perdu dès que tu le fermes, il ne
> retient rien d'une fois sur l'autre. Pour conserver ces informations, il lui
> faut de quoi les stocker au-dehors. Amarre-lui à côté un conteneur scellé où
> ranger ce qui doit durer.

Ce qu'on attend de toi :

- Créer un conteneur maritime (volume) nommé `app-data`.
- Rouvrir `app` en l'amarrant : le conteneur maritime se monte sur le dossier
  où le bâtiment écrit ses registres, soit `/data` à l'intérieur.
- Prouver la persistance : note le total, évacue `app` (pas le volume),
  rouvre-le amarré au même conteneur maritime, recharge la page. Le total
  reprend où il en était.

La règle du jour : les données rangées dans un **conteneur maritime** survivent à
la fermeture et même à la démolition du bâtiment. Celles laissées dans le bâtiment
disparaissent avec lui.

Indices :

- Deux temps : créer un conteneur maritime nommé, puis l'amarrer au bâtiment à l'ouverture. Le mémo a une famille de commandes dédiée aux volumes, et une option d'amarrage.
- L'amarrage relie un nom de conteneur maritime à un dossier interne du bâtiment (ici `/data`).

Contrôle : `bash checks/check-6.sh`

---

## Étape 7 : un entrepôt, et un pont

> Ton conteneur fait l'affaire, mais tout y est entassé en vrac : dès qu'il y a
> du monde, retrouver une information dedans devient lent. Tu installes alors un
> voisin spécialisé là-dedans, un entrepôt de données, qui range tout
> méthodiquement et retrouve ce qu'on lui demande bien plus vite. Seulement, ton
> établissement et l'entrepôt sont sur deux îles séparées : tant qu'aucun pont
> ne les relie, ils ne peuvent pas se parler.

Ce qu'on attend de toi :

- Construire un pont (réseau) nommé `app-net`.
- Ouvrir l'entrepôt : un bâtiment `cache`, image `redis:7-alpine`, sur le pont
  `app-net`. Démarre-le en mode "appendonly" pour qu'il écrive ses données.
- Rouvrir `app` sur le même pont, et lui indiquer où trouver l'entrepôt via
  la variable `REDIS_HOST` (sa valeur, c'est le nom du bâtiment entrepôt).

Quand c'est bon, ton établissement range désormais ses registres dans l'entrepôt
Redis, joignable par le pont.

La règle du jour : sur un **pont** (réseau), un bâtiment en joint un autre par son
nom. Sans pont commun, aucune communication possible.

Indices :

- Trois temps : créer un pont (le mémo a une famille de commandes réseau), poser l'entrepôt dessus, puis rouvrir ton établissement sur le même pont.
- Sur un pont, un bâtiment en joint un autre par son nom : c'est cette valeur que tu donnes à `REDIS_HOST`.
- Pour que l'entrepôt écrive ses données sur disque, on lui passe une commande de démarrage : `redis-server --appendonly yes` (le mémo montre comment ajouter une commande après le nom de l'image).
- N'oublie pas de rouvrir `app` avec son quai 3000 ET la variable de connexion.

Contrôle : `bash checks/check-7.sh`

---

## Étape 8 : encaisser une coupure

> Imprévu : l'entrepôt doit fermer un moment pour entretien. Ferme-le, vois ce
> qui se passe côté établissement, puis rouvre-le sans rien reconstruire. Tu le
> constateras : les registres n'ont pas bougé. Fermer n'est pas démolir.

Ce qu'on attend de toi :

- Fermer un bâtiment (par exemple l'entrepôt `cache`), constater que le service
  ne répond plus.
- Le rouvrir (le redémarrer), et vérifier que les registres sont toujours là
  grâce à son conteneur maritime.

La règle du jour : fermer puis rouvrir un bâtiment ne perd pas les données qui
sont dans un conteneur maritime. Le cycle de vie du bâtiment et la durée de vie
des données sont deux choses séparées.

Indices :

- Deux gestes opposés : fermer un bâtiment, puis le rouvrir sans le recréer. Le mémo distingue bien arrêter, supprimer, et redémarrer un bâtiment qui existe déjà.
- Ferme, va constater que le service ne répond plus, puis rouvre : tu n'as rien perdu, parce que tu n'as pas démoli.

Contrôle : `bash checks/check-8.sh`

---

## Étape 9 : le plan d'ensemble

> Tu as tout ouvert à la main, l'un après l'autre, avec de longues consignes. On
> te confie un second port à dresser à l'identique, sans rien oublier. Plutôt
> que tout refaire pièce par pièce, couche sur un seul plan l'ensemble de
> l'installation, et fais tout ouvrir d'un seul ordre.

Ce qu'on attend de toi :

- Écrire un fichier `compose.yaml` dans ton chantier, décrivant deux services :
  ton application (construite depuis ton Dockerfile) et l'entrepôt Redis.
- Y remettre ce que tu montais à la main : le pont (Compose en crée un tout seul),
  le conteneur maritime `app-data` pour l'entrepôt, l'enseigne (`APP_MESSAGE`),
  la connexion (`REDIS_HOST`), le quai 3000.
- D'abord, fais le ménage : évacue les bâtiments `app` et `cache` lancés à la
  main (sinon le quai 3000 est déjà pris).
- Tout ouvrir d'une seule commande, en arrière-plan.

La règle du jour : un seul **plan d'ensemble** (`compose.yaml`) décrit toute
l'installation, et l'ouvre ou la ferme d'un geste. C'est ainsi qu'on redresse le
même port ailleurs, sans le remonter pièce par pièce. Sur la carte, l'ensemble
apparaît regroupé en quartier.

Indices :

- Le plan d'ensemble se décrit dans un fichier `compose.yaml` : chaque bâtiment devient un service, avec son plan ou son image, son quai, ses variables, son conteneur maritime. Le mémo liste les clés utiles.
- Un service qui se construit depuis ton Dockerfile n'utilise pas la même clé qu'un service qui part d'une image déjà prête.
- Pense à libérer le quai 3000 avant de tout ouvrir (évacue les bâtiments lancés à la main).
- La commande de montage tient en deux mots, suivis d'une sous-commande qui monte tout en arrière-plan ; le mémo la donne.

Contrôle : `bash checks/check-9.sh`

---

## Étape 10 : expédier le plan

> Un port lointain veut faire tourner exactement le même établissement que le
> tien. Tu ne lui envoies pas le bâtiment, tu lui envoies son plan. Dépose-le à
> l'entrepôt central, sous ton nom, pour qu'il puisse l'y récupérer.

Ce qu'on attend de toi :

- Avoir un compte sur un entrepôt central (Docker Hub propose un compte gratuit).
- Te connecter depuis le terminal.
- Donner à ton plan un nom compatible : `TON_IDENTIFIANT/mon-app-custom:1.0`
  (re-tag de l'image existante).
- L'expédier (le pousser).

La règle du jour : un plan se nomme `entrepôt/identifiant/image:tag`. Sans ton
identifiant, l'entrepôt central ne sait pas chez qui ranger ton plan.

Indices :

- Avant d'expédier, ton plan doit porter un nom qui inclut ton identifiant. Cherche la commande qui ajoute un nom à une image existante (mot-clé : tag).
- Ensuite, deux gestes : se connecter à l'entrepôt, puis pousser (mots-clés : login, push). Récupérer ailleurs, ce serait pull.

Contrôle : `bash checks/check-10.sh`

---

## Fin de service

Tu sais désormais lancer des services tout prêts, construire les tiens
(images et Dockerfile), gérer leur cycle de vie, ouvrir des
quais (ports), changer leurs enseignes (configuration), entreposer durablement
(conteneurs maritimes), relier les bâtiments (ponts), ouvrir tout un ensemble d'un seul plan (Compose) et expédier tes plans (registry). C'est le métier au
quotidien.

Pour aller plus loin : les contrôles de santé dans Compose, les images
multi-étapes (multi-stage build) pour des plans plus légers, les variables dans un
fichier `.env`, et le grand ménage avec `docker system prune`.

Bon quart, gestionnaire.
