import type { PromptXPluginApi } from "promptx/plugin-sdk";
import { emptyPluginConfigSchema } from "promptx/plugin-sdk";
import { slackPlugin } from "./src/channel.js";
import { setSlackRuntime } from "./src/runtime.js";

const plugin = {
  id: "slack",
  name: "Slack",
  description: "Slack channel plugin",
  configSchema: emptyPluginConfigSchema(),
  register(api: PromptXPluginApi) {
    setSlackRuntime(api.runtime);
    api.registerChannel({ plugin: slackPlugin });
  },
};

export default plugin;
