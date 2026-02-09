import type { PromptXPluginApi } from "promptx/plugin-sdk";
import { emptyPluginConfigSchema } from "promptx/plugin-sdk";
import { msteamsPlugin } from "./src/channel.js";
import { setMSTeamsRuntime } from "./src/runtime.js";

const plugin = {
  id: "msteams",
  name: "Microsoft Teams",
  description: "Microsoft Teams channel plugin (Bot Framework)",
  configSchema: emptyPluginConfigSchema(),
  register(api: PromptXPluginApi) {
    setMSTeamsRuntime(api.runtime);
    api.registerChannel({ plugin: msteamsPlugin });
  },
};

export default plugin;
