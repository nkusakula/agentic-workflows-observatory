const test = require("node:test");
const assert = require("node:assert");
const { tasks } = require("./server");

test("tasks map starts empty", () => {
  assert.strictEqual(tasks.size, 0);
});
