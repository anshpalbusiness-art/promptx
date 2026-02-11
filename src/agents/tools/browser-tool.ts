import { chromium } from "playwright-extra";
import stealth from "puppeteer-extra-plugin-stealth";
chromium.use(stealth());

import type { AnyAgentTool } from "./common.js";
import { saveMediaBuffer } from "../../media/store.js";
import { BrowserToolSchema } from "./browser-tool.schema.js";
import { jsonResult, readStringParam } from "./common.js";

// Store browser instance for chaining actions
let browserInstance: Awaited<ReturnType<typeof chromium.launch>> | null = null;
let pageInstance: Awaited<
  ReturnType<ReturnType<typeof chromium.launch>["newContext"]>["newPage"]
> | null = null;

export function createBrowserTool(_opts?: {
  sandboxBridgeUrl?: string;
  allowHostControl?: boolean;
}): AnyAgentTool {
  return {
    label: "Browser",
    name: "browser",
    description: [
      "Control a real browser using Playwright with stealth mode enabled.",
      "Actions: goto, type, click, screenshot, evaluate, close.",
      "Stealth mode bypasses bot detection.",
    ].join(" "),
    parameters: BrowserToolSchema,
    execute: async (_toolCallId, args) => {
      const params = args as Record<string, unknown>;
      const action = readStringParam(params, "action", { required: true });

      let result: Record<string, unknown> = {};

      // Parse action and execute
      const actionParts = action.split(" ");
      const command = actionParts[0];
      const urlOrSelector = actionParts[1];
      const text = actionParts.slice(2).join(" ");

      switch (command) {
        case "start":
        case "launch":
          if (!browserInstance) {
            browserInstance = await chromium.launch({
              headless: false,
              args: ["--no-sandbox", "--disable-setuid-sandbox", "--disable-dev-shm-usage"],
            });
            const context = await browserInstance.newContext({
              userAgent:
                "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
              viewport: { width: 1920, height: 1080 },
            });
            pageInstance = await context.newPage();
          }
          result = { status: "started", message: "Browser launched with stealth mode" };
          break;

        case "goto":
          if (!browserInstance || !pageInstance) {
            // Auto-start if not running
            browserInstance = await chromium.launch({
              headless: false,
              args: ["--no-sandbox", "--disable-setuid-sandbox", "--disable-dev-shm-usage"],
            });
            const context = await browserInstance.newContext({
              userAgent:
                "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
              viewport: { width: 1920, height: 1080 },
            });
            pageInstance = await context.newPage();
          }
          if (!urlOrSelector) {
            throw new Error("goto requires a URL");
          }
          await pageInstance.goto(urlOrSelector, { waitUntil: "networkidle" });
          result = { status: "navigated", url: urlOrSelector };
          break;

        case "type":
          if (!pageInstance) {
            throw new Error('Browser not started. Use action="start" first');
          }
          if (!urlOrSelector || !text) {
            throw new Error("type requires selector and text");
          }
          await pageInstance.type(urlOrSelector, text);
          result = { status: "typed", selector: urlOrSelector, text };
          break;

        case "click":
          if (!pageInstance) {
            throw new Error('Browser not started. Use action="start" first');
          }
          if (!urlOrSelector) {
            throw new Error("click requires a selector");
          }
          await pageInstance.click(urlOrSelector);
          result = { status: "clicked", selector: urlOrSelector };
          break;

        case "screenshot":
          if (!pageInstance) {
            throw new Error('Browser not started. Use action="start" first');
          }
          const screenshotPath = ".promptx/last_browser.png";
          await pageInstance.screenshot({ path: screenshotPath, fullPage: true });
          result = { status: "screenshot", path: screenshotPath };
          break;

        case "evaluate":
          if (!pageInstance) {
            throw new Error('Browser not started. Use action="start" first');
          }
          if (!urlOrSelector) {
            throw new Error("evaluate requires JavaScript code");
          }
          const evalResult = await pageInstance.evaluate((code: string) => {
            return eval(code);
          }, urlOrSelector);
          result = { status: "evaluated", result: evalResult };
          break;

        case "close":
        case "stop":
          if (browserInstance) {
            await browserInstance.close();
            browserInstance = null;
            pageInstance = null;
          }
          result = { status: "closed" };
          return jsonResult(result);

        default:
          throw new Error(
            `Unknown action: ${command}. Use: start, goto, type, click, screenshot, evaluate, close`,
          );
      }

      // Take screenshot for proof if browser is running
      if (pageInstance) {
        const screenshotBuffer = await pageInstance.screenshot({ fullPage: true });
        const saved = await saveMediaBuffer(
          screenshotBuffer,
          "image/png",
          "browser",
          screenshotBuffer.byteLength,
        );
        result.screenshot = saved.path;
      }

      return jsonResult(result);
    },
  };
}

export function browserTool(): AnyAgentTool {
  return createBrowserTool();
}
