import path from "node:path";
import { describe, expect, it } from "vitest";
import { resolveGatewayStateDir } from "./paths.js";

describe("resolveGatewayStateDir", () => {
  it("uses the default state dir when no overrides are set", () => {
    const env = { HOME: "/Users/test" };
    expect(resolveGatewayStateDir(env)).toBe(path.join("/Users/test", ".promptx"));
  });

  it("appends the profile suffix when set", () => {
    const env = { HOME: "/Users/test", PROMPTX_PROFILE: "rescue" };
    expect(resolveGatewayStateDir(env)).toBe(path.join("/Users/test", ".promptx-rescue"));
  });

  it("treats default profiles as the base state dir", () => {
    const env = { HOME: "/Users/test", PROMPTX_PROFILE: "Default" };
    expect(resolveGatewayStateDir(env)).toBe(path.join("/Users/test", ".promptx"));
  });

  it("uses PROMPTX_STATE_DIR when provided", () => {
    const env = { HOME: "/Users/test", PROMPTX_STATE_DIR: "/var/lib/promptx" };
    expect(resolveGatewayStateDir(env)).toBe(path.resolve("/var/lib/promptx"));
  });

  it("expands ~ in PROMPTX_STATE_DIR", () => {
    const env = { HOME: "/Users/test", PROMPTX_STATE_DIR: "~/promptx-state" };
    expect(resolveGatewayStateDir(env)).toBe(path.resolve("/Users/test/promptx-state"));
  });

  it("preserves Windows absolute paths without HOME", () => {
    const env = { PROMPTX_STATE_DIR: "C:\\State\\promptx" };
    expect(resolveGatewayStateDir(env)).toBe("C:\\State\\promptx");
  });
});
