// Pixel Counter : petite app web qui compte les visites.
// Tu n'as PAS besoin de modifier ce fichier. C'est l'app que tu vas apprendre
// a conteneuriser. Lis juste les variables d'environnement qu'elle attend, ca
// te servira dans les missions.
//
// Variables d'environnement reconnues :
//   PORT         port d'ecoute               (defaut : 3000)
//   APP_MESSAGE  message affiche sur la page  (defaut : "Bonjour le monde")
//   REDIS_HOST   hote du serveur Redis        (si absent : compteur en memoire)
//   REDIS_PORT   port du serveur Redis        (defaut : 6379)

const express = require("express");
const { createClient } = require("redis");

const PORT = process.env.PORT || 3000;
const APP_MESSAGE = process.env.APP_MESSAGE || "Bonjour le monde";
const REDIS_HOST = process.env.REDIS_HOST;
const REDIS_PORT = process.env.REDIS_PORT || 6379;

// Compteur de secours, en memoire, utilise tant qu'aucun Redis n'est joignable.
let memoryCount = 0;
let redisReady = false;
let redis = null;

if (REDIS_HOST) {
  redis = createClient({
    socket: {
      host: REDIS_HOST,
      port: Number(REDIS_PORT),
      // On ne veut pas que l'app plante si Redis n'est pas (encore) la.
      reconnectStrategy: (retries) => Math.min(retries * 200, 3000),
    },
  });
  redis.on("ready", () => {
    redisReady = true;
    console.log(`Redis connecte sur ${REDIS_HOST}:${REDIS_PORT}`);
  });
  redis.on("end", () => {
    redisReady = false;
  });
  // On avale les erreurs de connexion pour ne pas spammer / planter.
  redis.on("error", () => {
    redisReady = false;
  });
  redis.connect().catch(() => {
    redisReady = false;
  });
}

async function nextCount() {
  if (redis && redisReady) {
    try {
      return await redis.incr("visits");
    } catch (e) {
      // Si Redis tombe en cours de route, on bascule en memoire.
    }
  }
  memoryCount += 1;
  return memoryCount;
}

function page(count, stored) {
  const badge = stored
    ? '<span class="ok">stocke dans Redis</span>'
    : '<span class="warn">mode degrade : compteur en memoire (perdu au redemarrage)</span>';
  return `<!doctype html>
<html lang="fr">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Pixel Counter</title>
  <style>
    body { background:#1a1a2e; color:#eee; font-family:"Courier New",monospace;
           display:flex; min-height:100vh; margin:0; align-items:center;
           justify-content:center; text-align:center; }
    .box { border:4px solid #e94560; padding:2rem 3rem; border-radius:8px;
           box-shadow:0 0 0 4px #1a1a2e, 0 0 0 8px #e94560; }
    h1 { color:#e94560; letter-spacing:2px; }
    .count { font-size:4rem; color:#0f9; margin:1rem 0; }
    .ok { color:#0f9; } .warn { color:#fc4; }
    small { opacity:.7; }
  </style>
</head>
<body>
  <div class="box">
    <h1>${APP_MESSAGE}</h1>
    <div class="count">${count}</div>
    <p>visite(s) comptee(s)</p>
    <p><small>${badge}</small></p>
  </div>
</body>
</html>`;
}

const app = express();

app.get("/", async (req, res) => {
  const count = await nextCount();
  const stored = Boolean(redis && redisReady);
  res.send(page(count, stored));
});

// Petit endpoint pratique pour les scripts de verification.
app.get("/health", (req, res) => {
  res.json({ status: "ok", redis: Boolean(redis && redisReady) });
});

app.listen(PORT, () => {
  console.log(`Pixel Counter ecoute sur le port ${PORT}`);
});
