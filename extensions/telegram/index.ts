import type { ChannelPlugin, PromptXPluginApi } from "promptx/plugin-sdk";
import { emptyPluginConfigSchema } from "promptx/plugin-sdk";
import { telegramPlugin } from "./src/channel.js";
import { setTelegramRuntime } from "./src/runtime.js";

const plugin = {
  id: "telegram",
  name: "Telegram",
  description: "Telegram channel plugin",
  configSchema: emptyPluginConfigSchema(),
  register(api: PromptXPluginApi) {
    setTelegramRuntime(api.runtime);
    api.registerChannel({ plugin: telegramPlugin as ChannelPlugin });
  },
};

export default plugin;
