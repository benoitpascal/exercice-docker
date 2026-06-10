// Cockpit du Port des Conteneurs : petit serveur local.
// Il sert l'interface (index.html) et exécute de VRAIES commandes docker sur
// cette machine, puis renvoie l'état réel de Docker pour l'affichage.
//
// Lancement :
//   cd  (dans ton dossier de travail, celui qui contient ton Dockerfile)
//   node /chemin/vers/cockpit/server.js
//   puis ouvre http://localhost:8099
//
// Sécurité : le serveur n'écoute que sur 127.0.0.1 et n'exécute QUE le binaire
// "docker" (jamais de shell, donc pas de ; && | qui s'interprètent). C'est un
// outil local que tu lances toi-même sur ta propre machine.

const http = require("http");
const fs = require("fs");
const path = require("path");
const { execFile } = require("child_process");

const PORT = process.env.PORT || 8099;
const HTML = path.join(__dirname, "index.html");

// Mémoire des évènements (pour les étapes qui sont des transitions).
const flags = { removedContainer: false, pushed: false, stoppedOnce: false, stoppedThenStarted: false };

function dockerExec(args, opts, cb) {
  execFile("docker", args, { timeout: opts.timeout || 20000, maxBuffer: 10 * 1024 * 1024, cwd: process.cwd() },
    (err, stdout, stderr) => cb(err, stdout || "", stderr || ""));
}

// Découpage type shell (gère les guillemets), sans jamais passer par un shell.
function tokenize(line) {
  const out = []; let cur = "", q = null, has = false;
  for (let i = 0; i < line.length; i++) {
    const ch = line[i];
    if (q) { if (ch === q) q = null; else cur += ch; has = true; }
    else if (ch === '"' || ch === "'") { q = ch; has = true; }
    else if (/\s/.test(ch)) { if (has) { out.push(cur); cur = ""; has = false; } }
    else { cur += ch; has = true; }
  }
  if (has) out.push(cur);
  return out;
}

/* ---------- ETAT REEL DE DOCKER ---------- */
function parseContainer(o) {
  const name = (o.Name || "").replace(/^\//, "");
  const ports = [];
  const P = (o.NetworkSettings && o.NetworkSettings.Ports) || {};
  for (const k in P) {
    const binds = P[k];
    if (binds && binds.length) ports.push(`${binds[0].HostPort}:${k.split("/")[0]}`);
  }
  const networks = Object.keys((o.NetworkSettings && o.NetworkSettings.Networks) || {});
  const volumes = (o.Mounts || []).filter(m => m.Type === "volume" && m.Name).map(m => m.Name);
  const env = {};
  ((o.Config && o.Config.Env) || []).forEach(e => { const i = e.indexOf("="); if (i > 0) env[e.slice(0, i)] = e.slice(i + 1); });
  const labels = (o.Config && o.Config.Labels) || {};
  return {
    name,
    image: (o.Config && o.Config.Image) || "",
    running: !!(o.State && o.State.Running),
    ports, networks, volumes, env,
    compose: !!labels["com.docker.compose.project"],
    composeProject: labels["com.docker.compose.project"] || null
  };
}

function getState(cb) {
  const state = { containers: [], images: [], networks: [], volumes: [], flags, dockerOk: true, error: null };
  dockerExec(["ps", "-aq"], { timeout: 15000 }, (err, ids) => {
    if (err) { state.dockerOk = false; state.error = err.code === "ENOENT" ? "Docker introuvable sur cette machine." : String(err.message || err); return cb(state); }
    const idList = ids.split("\n").map(s => s.trim()).filter(Boolean);
    const afterContainers = () => {
      dockerExec(["network", "ls", "--format", "{{.Name}}"], { timeout: 10000 }, (e2, nets) => {
        if (!e2) state.networks = nets.split("\n").map(s => s.trim()).filter(Boolean);
        dockerExec(["volume", "ls", "--format", "{{.Name}}"], { timeout: 10000 }, (e3, vols) => {
          if (!e3) state.volumes = vols.split("\n").map(s => s.trim()).filter(Boolean);
          dockerExec(["images", "--format", "{{.Repository}}:{{.Tag}}\t{{.Size}}"], { timeout: 10000 }, (e4, imgs) => {
            if (!e4) state.images = imgs.split("\n").map(s => s.trim()).filter(Boolean)
              .filter(l => !l.startsWith("<none>"))
              .map(l => { const [n, s] = l.split("\t"); return { name: n, size: s || "" }; });
            cb(state);
          });
        });
      });
    };
    if (!idList.length) return afterContainers();
    dockerExec(["inspect", ...idList], { timeout: 15000 }, (e1, js) => {
      if (!e1) { try { state.containers = JSON.parse(js).map(parseContainer); } catch (_) {} }
      afterContainers();
    });
  });
}

/* ---------- SERVEUR ---------- */
function sendJSON(res, obj) { const b = JSON.stringify(obj); res.writeHead(200, { "Content-Type": "application/json" }); res.end(b); }

const server = http.createServer((req, res) => {
  if (req.method === "GET" && (req.url === "/" || req.url === "/index.html")) {
    fs.readFile(HTML, (e, data) => { if (e) { res.writeHead(500); res.end("index.html introuvable"); } else { res.writeHead(200, { "Content-Type": "text/html; charset=utf-8" }); res.end(data); } });
    return;
  }
  if (req.method === "GET" && req.url === "/api/state") { getState(state => sendJSON(res, state)); return; }
  if (req.method === "POST" && req.url === "/api/run") {
    let body = "";
    req.on("data", c => { body += c; if (body.length > 1e5) req.destroy(); });
    req.on("end", () => {
      let command = "";
      try { command = (JSON.parse(body).command || "").trim(); } catch (_) {}
      const argv = tokenize(command);
      if (argv[0] !== "docker") { sendJSON(res, { stdout: "", stderr: "Ce poste n'exécute que des commandes docker.", code: 1 }); return; }
      const args = argv.slice(1);
      dockerExec(args, { timeout: 300000 }, (err, stdout, stderr) => {
        const code = err ? (err.code === "ENOENT" ? 127 : (typeof err.code === "number" ? err.code : 1)) : 0;
        let extra = "";
        if (err && err.code === "ENOENT") extra = "Docker introuvable sur cette machine.";
        // suivi des transitions
        if (code === 0 && args[0] === "rm") flags.removedContainer = true;
        if (code === 0 && args[0] === "stop") flags.stoppedOnce = true;
        if (code === 0 && args[0] === "start" && flags.stoppedOnce) flags.stoppedThenStarted = true;
        if (code === 0 && args[0] === "push" && (args.find(a => a.includes("/")))) flags.pushed = true;
        sendJSON(res, { stdout, stderr: stderr + (extra ? "\n" + extra : ""), code });
      });
    });
    return;
  }
  if (req.method === "POST" && req.url === "/api/writefile") {
    let body = "";
    req.on("data", c => { body += c; if (body.length > 5e5) req.destroy(); });
    req.on("end", () => {
      let name = "", content = "";
      try { const j = JSON.parse(body); name = (j.name || "").trim(); content = String(j.content || ""); } catch (_) {}
      const allowed = ["Dockerfile", ".dockerignore", "compose.yaml", "compose.yml"];
      if (!allowed.includes(name)) { sendJSON(res, { ok: false, error: "Nom de fichier non autorisé." }); return; }
      try { fs.writeFileSync(path.join(process.cwd(), name), content); sendJSON(res, { ok: true, dir: process.cwd() }); }
      catch (e) { sendJSON(res, { ok: false, error: String((e && e.message) || e) }); }
    });
    return;
  }
  res.writeHead(404); res.end("not found");
});

server.listen(PORT, "127.0.0.1", () => {
  console.log(`Cockpit du Port des Conteneurs : http://localhost:${PORT}`);
  console.log(`Dossier de travail (pour build/compose) : ${process.cwd()}`);
});
