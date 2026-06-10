// mon-app-custom : petite app web qui compte les visites.
// Tu n'as PAS besoin de modifier ce fichier. C'est l'app que tu vas apprendre
// a faire vivre dans un port a conteneurs.
//
// Ou est stocke le total des visites, par ordre de priorite :
//   1. dans Redis si REDIS_HOST est defini (l'entrepot de donnees, via un pont) ;
//   2. sinon dans un fichier sur disque, dans le dossier DATA_DIR (defaut /data) ;
//      ce dossier ne survit a la disparition du batiment que s'il est monte sur
//      un conteneur maritime (un volume) ;
//   3. en dernier recours en memoire (perdu des que le batiment ferme).
//
// Variables d'environnement reconnues :
//   PORT         port d'ecoute               (defaut : 3000)
//   APP_MESSAGE  enseigne affichee            (defaut : "Bonjour le monde")
//   REDIS_HOST   hote de l'entrepot Redis     (si absent : stockage sur disque)
//   REDIS_PORT   port de Redis                (defaut : 6379)
//   DATA_DIR     dossier de stockage disque   (defaut : /data)

const express = require("express");
const fs = require("fs");
const path = require("path");
const { createClient } = require("redis");

const PORT = process.env.PORT || 3000;
const APP_MESSAGE = process.env.APP_MESSAGE || "Bonjour le monde";
const REDIS_HOST = process.env.REDIS_HOST;
const REDIS_PORT = process.env.REDIS_PORT || 6379;
const DATA_DIR = process.env.DATA_DIR || "/data";
const DATA_FILE = path.join(DATA_DIR, "count.json");

let memoryCount = 0;
let redisReady = false;
let redis = null;

if (REDIS_HOST) {
  redis = createClient({
    socket: {
      host: REDIS_HOST,
      port: Number(REDIS_PORT),
      reconnectStrategy: (retries) => Math.min(retries * 200, 3000),
    },
  });
  redis.on("ready", () => { redisReady = true; console.log(`Redis connecte sur ${REDIS_HOST}:${REDIS_PORT}`); });
  redis.on("end", () => { redisReady = false; });
  redis.on("error", () => { redisReady = false; });
  redis.connect().catch(() => { redisReady = false; });
} else {
  // Mode disque : on s'assure que le dossier existe (best effort).
  try { fs.mkdirSync(DATA_DIR, { recursive: true }); } catch (e) {}
}

function readFileCount() {
  try { return JSON.parse(fs.readFileSync(DATA_FILE, "utf8")).count || 0; }
  catch (e) { return 0; }
}
function writeFileCount(n) {
  fs.writeFileSync(DATA_FILE, JSON.stringify({ count: n }));
}

async function nextCount() {
  if (redis && redisReady) {
    try { return await redis.incr("visits"); } catch (e) {}
  }
  if (!REDIS_HOST) {
    try { const n = readFileCount() + 1; writeFileCount(n); return n; } catch (e) {}
  }
  memoryCount += 1;
  return memoryCount;
}

function storeLabel() {
  if (redis && redisReady) return ["ok", "stocké dans l'entrepôt Redis (via le pont)"];
  if (REDIS_HOST) return ["warn", "entrepôt Redis injoignable : pas de pont ? (registre en mémoire)"];
  try { fs.accessSync(DATA_DIR, fs.constants.W_OK); return ["disk", `stocké sur disque : ${DATA_FILE}`]; }
  catch (e) { return ["warn", "stockage disque indisponible (registre en mémoire)"]; }
}

function page(count) {
  const [kind, text] = storeLabel();
  const cls = kind === "ok" ? "ok" : kind === "disk" ? "disk" : "warn";
  return `<!doctype html>
<html lang="fr">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>mon-app-custom</title>
  <style>
    body { background:#1a1a2e; color:#eee; font-family:"Courier New",monospace;
           display:flex; min-height:100vh; margin:0; align-items:center;
           justify-content:center; text-align:center; }
    .box { border:4px solid #e94560; padding:2rem 3rem; border-radius:8px;
           box-shadow:0 0 0 4px #1a1a2e, 0 0 0 8px #e94560; }
    h1 { color:#e94560; letter-spacing:2px; }
    .count { font-size:4rem; color:#0f9; margin:1rem 0; }
    .ok { color:#0f9; } .disk { color:#7fd1d6; } .warn { color:#fc4; }
    small { opacity:.8; }
  </style>
</head>
<body>
  <div class="box">
    <h1>${APP_MESSAGE}</h1>
    <div class="count">${count}</div>
    <p>visite(s) comptée(s)</p>
    <p><small><span class="${cls}">${text}</span></small></p>
  </div>
</body>
</html>`;
}

const app = express();
app.get("/", async (req, res) => { res.send(page(await nextCount())); });
app.get("/health", (req, res) => {
  const [kind] = storeLabel();
  res.json({ status: "ok", store: kind, redis: Boolean(redis && redisReady) });
});
app.listen(PORT, () => { console.log(`mon-app-custom ecoute sur le port ${PORT}`); });
