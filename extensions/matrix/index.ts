import type { PromptXPluginApi } from "promptx/plugin-sdk";
import { emptyPluginConfigSchema } from "promptx/plugin-sdk";
import { matrixPlugin } from "./src/channel.js";
import { setMatrixRuntime } from "./src/runtime.js";

const plugin = {
  id: "matrix",
  name: "Matrix",
  description: "Matrix channel plugin (matrix-js-sdk)",
  configSchema: emptyPluginConfigSchema(),
  register(api: PromptXPluginApi) {
    setMatrixRuntime(api.runtime);
    api.registerChannel({ plugin: matrixPlugin });
  },
};

export default plugin;
