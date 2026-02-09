import { describe, expect, it } from "vitest";
import {
  buildParseArgv,
  getFlagValue,
  getCommandPath,
  getPrimaryCommand,
  getPositiveIntFlagValue,
  getVerboseFlag,
  hasHelpOrVersion,
  hasFlag,
  shouldMigrateState,
  shouldMigrateStateFromPath,
} from "./argv.js";

describe("argv helpers", () => {
  it("detects help/version flags", () => {
    expect(hasHelpOrVersion(["node", "promptx", "--help"])).toBe(true);
    expect(hasHelpOrVersion(["node", "promptx", "-V"])).toBe(true);
    expect(hasHelpOrVersion(["node", "promptx", "status"])).toBe(false);
  });

  it("extracts command path ignoring flags and terminator", () => {
    expect(getCommandPath(["node", "promptx", "status", "--json"], 2)).toEqual(["status"]);
    expect(getCommandPath(["node", "promptx", "agents", "list"], 2)).toEqual(["agents", "list"]);
    expect(getCommandPath(["node", "promptx", "status", "--", "ignored"], 2)).toEqual(["status"]);
  });

  it("returns primary command", () => {
    expect(getPrimaryCommand(["node", "promptx", "agents", "list"])).toBe("agents");
    expect(getPrimaryCommand(["node", "promptx"])).toBeNull();
  });

  it("parses boolean flags and ignores terminator", () => {
    expect(hasFlag(["node", "promptx", "status", "--json"], "--json")).toBe(true);
    expect(hasFlag(["node", "promptx", "--", "--json"], "--json")).toBe(false);
  });

  it("extracts flag values with equals and missing values", () => {
    expect(getFlagValue(["node", "promptx", "status", "--timeout", "5000"], "--timeout")).toBe(
      "5000",
    );
    expect(getFlagValue(["node", "promptx", "status", "--timeout=2500"], "--timeout")).toBe("2500");
    expect(getFlagValue(["node", "promptx", "status", "--timeout"], "--timeout")).toBeNull();
    expect(getFlagValue(["node", "promptx", "status", "--timeout", "--json"], "--timeout")).toBe(
      null,
    );
    expect(getFlagValue(["node", "promptx", "--", "--timeout=99"], "--timeout")).toBeUndefined();
  });

  it("parses verbose flags", () => {
    expect(getVerboseFlag(["node", "promptx", "status", "--verbose"])).toBe(true);
    expect(getVerboseFlag(["node", "promptx", "status", "--debug"])).toBe(false);
    expect(getVerboseFlag(["node", "promptx", "status", "--debug"], { includeDebug: true })).toBe(
      true,
    );
  });

  it("parses positive integer flag values", () => {
    expect(getPositiveIntFlagValue(["node", "promptx", "status"], "--timeout")).toBeUndefined();
    expect(
      getPositiveIntFlagValue(["node", "promptx", "status", "--timeout"], "--timeout"),
    ).toBeNull();
    expect(
      getPositiveIntFlagValue(["node", "promptx", "status", "--timeout", "5000"], "--timeout"),
    ).toBe(5000);
    expect(
      getPositiveIntFlagValue(["node", "promptx", "status", "--timeout", "nope"], "--timeout"),
    ).toBeUndefined();
  });

  it("builds parse argv from raw args", () => {
    const nodeArgv = buildParseArgv({
      programName: "promptx",
      rawArgs: ["node", "promptx", "status"],
    });
    expect(nodeArgv).toEqual(["node", "promptx", "status"]);

    const versionedNodeArgv = buildParseArgv({
      programName: "promptx",
      rawArgs: ["node-22", "promptx", "status"],
    });
    expect(versionedNodeArgv).toEqual(["node-22", "promptx", "status"]);

    const versionedNodeWindowsArgv = buildParseArgv({
      programName: "promptx",
      rawArgs: ["node-22.2.0.exe", "promptx", "status"],
    });
    expect(versionedNodeWindowsArgv).toEqual(["node-22.2.0.exe", "promptx", "status"]);

    const versionedNodePatchlessArgv = buildParseArgv({
      programName: "promptx",
      rawArgs: ["node-22.2", "promptx", "status"],
    });
    expect(versionedNodePatchlessArgv).toEqual(["node-22.2", "promptx", "status"]);

    const versionedNodeWindowsPatchlessArgv = buildParseArgv({
      programName: "promptx",
      rawArgs: ["node-22.2.exe", "promptx", "status"],
    });
    expect(versionedNodeWindowsPatchlessArgv).toEqual(["node-22.2.exe", "promptx", "status"]);

    const versionedNodeWithPathArgv = buildParseArgv({
      programName: "promptx",
      rawArgs: ["/usr/bin/node-22.2.0", "promptx", "status"],
    });
    expect(versionedNodeWithPathArgv).toEqual(["/usr/bin/node-22.2.0", "promptx", "status"]);

    const nodejsArgv = buildParseArgv({
      programName: "promptx",
      rawArgs: ["nodejs", "promptx", "status"],
    });
    expect(nodejsArgv).toEqual(["nodejs", "promptx", "status"]);

    const nonVersionedNodeArgv = buildParseArgv({
      programName: "promptx",
      rawArgs: ["node-dev", "promptx", "status"],
    });
    expect(nonVersionedNodeArgv).toEqual(["node", "promptx", "node-dev", "promptx", "status"]);

    const directArgv = buildParseArgv({
      programName: "promptx",
      rawArgs: ["promptx", "status"],
    });
    expect(directArgv).toEqual(["node", "promptx", "status"]);

    const bunArgv = buildParseArgv({
      programName: "promptx",
      rawArgs: ["bun", "src/entry.ts", "status"],
    });
    expect(bunArgv).toEqual(["bun", "src/entry.ts", "status"]);
  });

  it("builds parse argv from fallback args", () => {
    const fallbackArgv = buildParseArgv({
      programName: "promptx",
      fallbackArgv: ["status"],
    });
    expect(fallbackArgv).toEqual(["node", "promptx", "status"]);
  });

  it("decides when to migrate state", () => {
    expect(shouldMigrateState(["node", "promptx", "status"])).toBe(false);
    expect(shouldMigrateState(["node", "promptx", "health"])).toBe(false);
    expect(shouldMigrateState(["node", "promptx", "sessions"])).toBe(false);
    expect(shouldMigrateState(["node", "promptx", "memory", "status"])).toBe(false);
    expect(shouldMigrateState(["node", "promptx", "agent", "--message", "hi"])).toBe(false);
    expect(shouldMigrateState(["node", "promptx", "agents", "list"])).toBe(true);
    expect(shouldMigrateState(["node", "promptx", "message", "send"])).toBe(true);
  });

  it("reuses command path for migrate state decisions", () => {
    expect(shouldMigrateStateFromPath(["status"])).toBe(false);
    expect(shouldMigrateStateFromPath(["agents", "list"])).toBe(true);
  });
});
