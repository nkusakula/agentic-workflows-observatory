const http = require("http");

const tasks = new Map();
let nextId = 1;

function send(res, status, body) {
  res.writeHead(status, { "Content-Type": "application/json" });
  res.end(JSON.stringify(body));
}

function readBody(req) {
  return new Promise((resolve, reject) => {
    let data = "";
    req.on("data", (chunk) => (data += chunk));
    req.on("end", () => {
      try {
        resolve(data ? JSON.parse(data) : {});
      } catch (err) {
        reject(err);
      }
    });
    req.on("error", reject);
  });
}

const server = http.createServer(async (req, res) => {
  const url = new URL(req.url, `http://${req.headers.host}`);

  if (req.method === "GET" && url.pathname === "/health") {
    return send(res, 200, { status: "ok" });
  }

  if (req.method === "GET" && url.pathname === "/tasks") {
    return send(res, 200, { tasks: [...tasks.values()] });
  }

  if (req.method === "POST" && url.pathname === "/tasks") {
    const body = await readBody(req);
    if (!body.title || typeof body.title !== "string" || body.title.trim() === "") {
      return send(res, 400, { error: "title must be a non-empty string" });
    }
    const task = { id: nextId++, title: body.title, done: false };
    tasks.set(task.id, task);
    return send(res, 201, task);
  }

  if (req.method === "PATCH" && url.pathname.startsWith("/tasks/")) {
    const id = Number(url.pathname.split("/")[2]);
    const task = tasks.get(id);
    if (!task) return send(res, 404, { error: "not found" });
    const body = await readBody(req);
    if (typeof body.done === "boolean") task.done = body.done;
    if (typeof body.title === "string") task.title = body.title;
    return send(res, 200, task);
  }

  send(res, 404, { error: "not found" });
});

if (require.main === module) {
  const port = process.env.PORT || 3000;
  server.listen(port, () => console.log(`TaskFlow API listening on :${port}`));
}

module.exports = { server, tasks };

