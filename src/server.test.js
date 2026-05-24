const test = require("node:test");
const assert = require("node:assert");
const { server, tasks } = require("./server");

function request(method, path) {
  return new Promise((resolve, reject) => {
    const address = server.address();
    const req = require("http").request(
      {
        host: "127.0.0.1",
        port: address.port,
        path,
        method,
      },
      (res) => {
        let body = "";
        res.on("data", (chunk) => (body += chunk));
        res.on("end", () => resolve({ res, body: JSON.parse(body) }));
      },
    );
    req.on("error", reject);
    req.end();
  });
}

test("tasks map starts empty", () => {
  assert.strictEqual(tasks.size, 0);
});

test("unsupported collection methods return 405 with Allow header", async () => {
  await new Promise((resolve) => server.listen(0, "127.0.0.1", resolve));
  try {
    const { res, body } = await request("PUT", "/tasks");

    assert.strictEqual(res.statusCode, 405);
    assert.strictEqual(res.headers.allow, "GET, POST");
    assert.deepStrictEqual(body, { error: "method not allowed" });
  } finally {
    await new Promise((resolve) => server.close(resolve));
  }
});

test("unsupported item methods return 405 with Allow header", async () => {
  await new Promise((resolve) => server.listen(0, "127.0.0.1", resolve));
  try {
    const { res, body } = await request("DELETE", "/tasks/1");

    assert.strictEqual(res.statusCode, 405);
    assert.strictEqual(res.headers.allow, "GET, PATCH");
    assert.deepStrictEqual(body, { error: "method not allowed" });
  } finally {
    await new Promise((resolve) => server.close(resolve));
  }
});
