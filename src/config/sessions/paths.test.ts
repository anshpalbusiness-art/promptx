import path from "node:path";
import { afterEach, describe, expect, it, vi } from "vitest";
import { resolveStorePath } from "./paths.js";

describe("resolveStorePath", () => {
  afterEach(() => {
    vi.unstubAllEnvs();
  });

  it("uses PROMPTX_HOME for tilde expansion", () => {
    vi.stubEnv("PROMPTX_HOME", "/srv/promptx-home");
    vi.stubEnv("HOME", "/home/other");

    const resolved = resolveStorePath("~/.promptx/agents/{agentId}/sessions/sessions.json", {
      agentId: "research",
    });

    expect(resolved).toBe(
      path.resolve("/srv/promptx-home/.promptx/agents/research/sessions/sessions.json"),
    );
  });
});
