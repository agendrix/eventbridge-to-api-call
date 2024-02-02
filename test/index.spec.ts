import assert from "assert";
import { PAYLOAD } from "./mocks";

describe("formatEvent", () => {
  it("has a type headers", async () => {
    const { headers } = PAYLOAD
    assert.ok(headers.Authorization);
  });

  it("has a text property", async () => {
    const { data } = PAYLOAD;
    assert.ok(JSON.stringify(data));
  });
});