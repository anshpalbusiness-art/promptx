import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import { describe, expect, it, vi } from "vitest";
import {
  resolveDefaultConfigCandidates,
  resolveConfigPath,
  resolveOAuthDir,
  resolveOAuthPath,
  resolveStateDir,
} from "./paths.js";

describe("oauth paths", () => {
  it("prefers PROMPTX_OAUTH_DIR over PROMPTX_STATE_DIR", () => {
    const env = {
      PROMPTX_OAUTH_DIR: "/custom/oauth",
      PROMPTX_STATE_DIR: "/custom/state",
    } as NodeJS.ProcessEnv;

    expect(resolveOAuthDir(env, "/custom/state")).toBe(path.resolve("/custom/oauth"));
    expect(resolveOAuthPath(env, "/custom/state")).toBe(
      path.join(path.resolve("/custom/oauth"), "oauth.json"),
    );
  });

  it("derives oauth path from PROMPTX_STATE_DIR when unset", () => {
    const env = {
      PROMPTX_STATE_DIR: "/custom/state",
    } as NodeJS.ProcessEnv;

    expect(resolveOAuthDir(env, "/custom/state")).toBe(path.join("/custom/state", "credentials"));
    expect(resolveOAuthPath(env, "/custom/state")).toBe(
      path.join("/custom/state", "credentials", "oauth.json"),
    );
  });
});

describe("state + config path candidates", () => {
  it("uses PROMPTX_STATE_DIR when set", () => {
    const env = {
      PROMPTX_STATE_DIR: "/new/state",
    } as NodeJS.ProcessEnv;

    expect(resolveStateDir(env, () => "/home/test")).toBe(path.resolve("/new/state"));
  });

  it("uses PROMPTX_HOME for default state/config locations", () => {
    const env = {
      PROMPTX_HOME: "/srv/promptx-home",
    } as NodeJS.ProcessEnv;

    const resolvedHome = path.resolve("/srv/promptx-home");
    expect(resolveStateDir(env)).toBe(path.join(resolvedHome, ".promptx"));

    const candidates = resolveDefaultConfigCandidates(env);
    expect(candidates[0]).toBe(path.join(resolvedHome, ".promptx", "promptx.json"));
  });

  it("prefers PROMPTX_HOME over HOME for default state/config locations", () => {
    const env = {
      PROMPTX_HOME: "/srv/promptx-home",
      HOME: "/home/other",
    } as NodeJS.ProcessEnv;

    const resolvedHome = path.resolve("/srv/promptx-home");
    expect(resolveStateDir(env)).toBe(path.join(resolvedHome, ".promptx"));

    const candidates = resolveDefaultConfigCandidates(env);
    expect(candidates[0]).toBe(path.join(resolvedHome, ".promptx", "promptx.json"));
  });

  it("orders default config candidates in a stable order", () => {
    const home = "/home/test";
    const resolvedHome = path.resolve(home);
    const candidates = resolveDefaultConfigCandidates({} as NodeJS.ProcessEnv, () => home);
    const expected = [
      path.join(resolvedHome, ".promptx", "promptx.json"),
      path.join(resolvedHome, ".promptx", "clawdbot.json"),
      path.join(resolvedHome, ".promptx", "moltbot.json"),
      path.join(resolvedHome, ".promptx", "moldbot.json"),
      path.join(resolvedHome, ".clawdbot", "promptx.json"),
      path.join(resolvedHome, ".clawdbot", "clawdbot.json"),
      path.join(resolvedHome, ".clawdbot", "moltbot.json"),
      path.join(resolvedHome, ".clawdbot", "moldbot.json"),
      path.join(resolvedHome, ".moltbot", "promptx.json"),
      path.join(resolvedHome, ".moltbot", "clawdbot.json"),
      path.join(resolvedHome, ".moltbot", "moltbot.json"),
      path.join(resolvedHome, ".moltbot", "moldbot.json"),
      path.join(resolvedHome, ".moldbot", "promptx.json"),
      path.join(resolvedHome, ".moldbot", "clawdbot.json"),
      path.join(resolvedHome, ".moldbot", "moltbot.json"),
      path.join(resolvedHome, ".moldbot", "moldbot.json"),
    ];
    expect(candidates).toEqual(expected);
  });

  it("prefers ~/.promptx when it exists and legacy dir is missing", async () => {
    const root = await fs.mkdtemp(path.join(os.tmpdir(), "promptx-state-"));
    try {
      const newDir = path.join(root, ".promptx");
      await fs.mkdir(newDir, { recursive: true });
      const resolved = resolveStateDir({} as NodeJS.ProcessEnv, () => root);
      expect(resolved).toBe(newDir);
    } finally {
      await fs.rm(root, { recursive: true, force: true });
    }
  });

  it("CONFIG_PATH prefers existing config when present", async () => {
    const root = await fs.mkdtemp(path.join(os.tmpdir(), "promptx-config-"));
    const previousHome = process.env.HOME;
    const previousUserProfile = process.env.USERPROFILE;
    const previousHomeDrive = process.env.HOMEDRIVE;
    const previousHomePath = process.env.HOMEPATH;
    const previousPromptXConfig = process.env.PROMPTX_CONFIG_PATH;
    const previousPromptXState = process.env.PROMPTX_STATE_DIR;
    try {
      const legacyDir = path.join(root, ".promptx");
      await fs.mkdir(legacyDir, { recursive: true });
      const legacyPath = path.join(legacyDir, "promptx.json");
      await fs.writeFile(legacyPath, "{}", "utf-8");

      process.env.HOME = root;
      if (process.platform === "win32") {
        process.env.USERPROFILE = root;
        const parsed = path.win32.parse(root);
        process.env.HOMEDRIVE = parsed.root.replace(/\\$/, "");
        process.env.HOMEPATH = root.slice(parsed.root.length - 1);
      }
      delete process.env.PROMPTX_CONFIG_PATH;
      delete process.env.PROMPTX_STATE_DIR;

      vi.resetModules();
      const { CONFIG_PATH } = await import("./paths.js");
      expect(CONFIG_PATH).toBe(legacyPath);
    } finally {
      if (previousHome === undefined) {
        delete process.env.HOME;
      } else {
        process.env.HOME = previousHome;
      }
      if (previousUserProfile === undefined) {
        delete process.env.USERPROFILE;
      } else {
        process.env.USERPROFILE = previousUserProfile;
      }
      if (previousHomeDrive === undefined) {
        delete process.env.HOMEDRIVE;
      } else {
        process.env.HOMEDRIVE = previousHomeDrive;
      }
      if (previousHomePath === undefined) {
        delete process.env.HOMEPATH;
      } else {
        process.env.HOMEPATH = previousHomePath;
      }
      if (previousPromptXConfig === undefined) {
        delete process.env.PROMPTX_CONFIG_PATH;
      } else {
        process.env.PROMPTX_CONFIG_PATH = previousPromptXConfig;
      }
      if (previousPromptXConfig === undefined) {
        delete process.env.PROMPTX_CONFIG_PATH;
      } else {
        process.env.PROMPTX_CONFIG_PATH = previousPromptXConfig;
      }
      if (previousPromptXState === undefined) {
        delete process.env.PROMPTX_STATE_DIR;
      } else {
        process.env.PROMPTX_STATE_DIR = previousPromptXState;
      }
      if (previousPromptXState === undefined) {
        delete process.env.PROMPTX_STATE_DIR;
      } else {
        process.env.PROMPTX_STATE_DIR = previousPromptXState;
      }
      await fs.rm(root, { recursive: true, force: true });
      vi.resetModules();
    }
  });

  it("respects state dir overrides when config is missing", async () => {
    const root = await fs.mkdtemp(path.join(os.tmpdir(), "promptx-config-override-"));
    try {
      const legacyDir = path.join(root, ".promptx");
      await fs.mkdir(legacyDir, { recursive: true });
      const legacyConfig = path.join(legacyDir, "promptx.json");
      await fs.writeFile(legacyConfig, "{}", "utf-8");

      const overrideDir = path.join(root, "override");
      const env = { PROMPTX_STATE_DIR: overrideDir } as NodeJS.ProcessEnv;
      const resolved = resolveConfigPath(env, overrideDir, () => root);
      expect(resolved).toBe(path.join(overrideDir, "promptx.json"));
    } finally {
      await fs.rm(root, { recursive: true, force: true });
    }
  });
});
