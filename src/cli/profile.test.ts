import path from "node:path";
import { describe, expect, it } from "vitest";
import { formatCliCommand } from "./command-format.js";
import { applyCliProfileEnv, parseCliProfileArgs } from "./profile.js";

describe("parseCliProfileArgs", () => {
  it("leaves gateway --dev for subcommands", () => {
    const res = parseCliProfileArgs([
      "node",
      "promptx",
      "gateway",
      "--dev",
      "--allow-unconfigured",
    ]);
    if (!res.ok) {
      throw new Error(res.error);
    }
    expect(res.profile).toBeNull();
    expect(res.argv).toEqual(["node", "promptx", "gateway", "--dev", "--allow-unconfigured"]);
  });

  it("still accepts global --dev before subcommand", () => {
    const res = parseCliProfileArgs(["node", "promptx", "--dev", "gateway"]);
    if (!res.ok) {
      throw new Error(res.error);
    }
    expect(res.profile).toBe("dev");
    expect(res.argv).toEqual(["node", "promptx", "gateway"]);
  });

  it("parses --profile value and strips it", () => {
    const res = parseCliProfileArgs(["node", "promptx", "--profile", "work", "status"]);
    if (!res.ok) {
      throw new Error(res.error);
    }
    expect(res.profile).toBe("work");
    expect(res.argv).toEqual(["node", "promptx", "status"]);
  });

  it("rejects missing profile value", () => {
    const res = parseCliProfileArgs(["node", "promptx", "--profile"]);
    expect(res.ok).toBe(false);
  });

  it("rejects combining --dev with --profile (dev first)", () => {
    const res = parseCliProfileArgs(["node", "promptx", "--dev", "--profile", "work", "status"]);
    expect(res.ok).toBe(false);
  });

  it("rejects combining --dev with --profile (profile first)", () => {
    const res = parseCliProfileArgs(["node", "promptx", "--profile", "work", "--dev", "status"]);
    expect(res.ok).toBe(false);
  });
});

describe("applyCliProfileEnv", () => {
  it("fills env defaults for dev profile", () => {
    const env: Record<string, string | undefined> = {};
    applyCliProfileEnv({
      profile: "dev",
      env,
      homedir: () => "/home/peter",
    });
    const expectedStateDir = path.join(path.resolve("/home/peter"), ".promptx-dev");
    expect(env.PROMPTX_PROFILE).toBe("dev");
    expect(env.PROMPTX_STATE_DIR).toBe(expectedStateDir);
    expect(env.PROMPTX_CONFIG_PATH).toBe(path.join(expectedStateDir, "promptx.json"));
    expect(env.PROMPTX_GATEWAY_PORT).toBe("19001");
  });

  it("does not override explicit env values", () => {
    const env: Record<string, string | undefined> = {
      PROMPTX_STATE_DIR: "/custom",
      PROMPTX_GATEWAY_PORT: "19099",
    };
    applyCliProfileEnv({
      profile: "dev",
      env,
      homedir: () => "/home/peter",
    });
    expect(env.PROMPTX_STATE_DIR).toBe("/custom");
    expect(env.PROMPTX_GATEWAY_PORT).toBe("19099");
    expect(env.PROMPTX_CONFIG_PATH).toBe(path.join("/custom", "promptx.json"));
  });

  it("uses PROMPTX_HOME when deriving profile state dir", () => {
    const env: Record<string, string | undefined> = {
      PROMPTX_HOME: "/srv/promptx-home",
      HOME: "/home/other",
    };
    applyCliProfileEnv({
      profile: "work",
      env,
      homedir: () => "/home/fallback",
    });

    const resolvedHome = path.resolve("/srv/promptx-home");
    expect(env.PROMPTX_STATE_DIR).toBe(path.join(resolvedHome, ".promptx-work"));
    expect(env.PROMPTX_CONFIG_PATH).toBe(path.join(resolvedHome, ".promptx-work", "promptx.json"));
  });
});

describe("formatCliCommand", () => {
  it("returns command unchanged when no profile is set", () => {
    expect(formatCliCommand("promptx doctor --fix", {})).toBe("promptx doctor --fix");
  });

  it("returns command unchanged when profile is default", () => {
    expect(formatCliCommand("promptx doctor --fix", { PROMPTX_PROFILE: "default" })).toBe(
      "promptx doctor --fix",
    );
  });

  it("returns command unchanged when profile is Default (case-insensitive)", () => {
    expect(formatCliCommand("promptx doctor --fix", { PROMPTX_PROFILE: "Default" })).toBe(
      "promptx doctor --fix",
    );
  });

  it("returns command unchanged when profile is invalid", () => {
    expect(formatCliCommand("promptx doctor --fix", { PROMPTX_PROFILE: "bad profile" })).toBe(
      "promptx doctor --fix",
    );
  });

  it("returns command unchanged when --profile is already present", () => {
    expect(
      formatCliCommand("promptx --profile work doctor --fix", { PROMPTX_PROFILE: "work" }),
    ).toBe("promptx --profile work doctor --fix");
  });

  it("returns command unchanged when --dev is already present", () => {
    expect(formatCliCommand("promptx --dev doctor", { PROMPTX_PROFILE: "dev" })).toBe(
      "promptx --dev doctor",
    );
  });

  it("inserts --profile flag when profile is set", () => {
    expect(formatCliCommand("promptx doctor --fix", { PROMPTX_PROFILE: "work" })).toBe(
      "promptx --profile work doctor --fix",
    );
  });

  it("trims whitespace from profile", () => {
    expect(formatCliCommand("promptx doctor --fix", { PROMPTX_PROFILE: "  jbpromptx  " })).toBe(
      "promptx --profile jbpromptx doctor --fix",
    );
  });

  it("handles command with no args after promptx", () => {
    expect(formatCliCommand("promptx", { PROMPTX_PROFILE: "test" })).toBe("promptx --profile test");
  });

  it("handles pnpm wrapper", () => {
    expect(formatCliCommand("pnpm promptx doctor", { PROMPTX_PROFILE: "work" })).toBe(
      "pnpm promptx --profile work doctor",
    );
  });
});
