import type {
  AnyAgentTool,
  PromptXPluginApi,
  PromptXPluginToolFactory,
} from "../../src/plugins/types.js";
import { createLobsterTool } from "./src/lobster-tool.js";

export default function register(api: PromptXPluginApi) {
  api.registerTool(
    ((ctx) => {
      if (ctx.sandboxed) {
        return null;
      }
      return createLobsterTool(api) as AnyAgentTool;
    }) as PromptXPluginToolFactory,
    { optional: true },
  );
}
