import type { PromptXPluginApi } from "promptx/plugin-sdk";
import { emptyPluginConfigSchema } from "promptx/plugin-sdk";
import { createDiagnosticsOtelService } from "./src/service.js";

const plugin = {
  id: "diagnostics-otel",
  name: "Diagnostics OpenTelemetry",
  description: "Export diagnostics events to OpenTelemetry",
  configSchema: emptyPluginConfigSchema(),
  register(api: PromptXPluginApi) {
    api.registerService(createDiagnosticsOtelService());
  },
};

export default plugin;
