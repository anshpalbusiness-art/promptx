import Foundation
import Testing
@testable import PromptX

@Suite(.serialized)
struct PromptXConfigFileTests {
    @Test
    func configPathRespectsEnvOverride() async {
        let override = FileManager().temporaryDirectory
            .appendingPathComponent("promptx-config-\(UUID().uuidString)")
            .appendingPathComponent("promptx.json")
            .path

        await TestIsolation.withEnvValues(["PROMPTX_CONFIG_PATH": override]) {
            #expect(PromptXConfigFile.url().path == override)
        }
    }

    @MainActor
    @Test
    func remoteGatewayPortParsesAndMatchesHost() async {
        let override = FileManager().temporaryDirectory
            .appendingPathComponent("promptx-config-\(UUID().uuidString)")
            .appendingPathComponent("promptx.json")
            .path

        await TestIsolation.withEnvValues(["PROMPTX_CONFIG_PATH": override]) {
            PromptXConfigFile.saveDict([
                "gateway": [
                    "remote": [
                        "url": "ws://gateway.ts.net:19999",
                    ],
                ],
            ])
            #expect(PromptXConfigFile.remoteGatewayPort() == 19999)
            #expect(PromptXConfigFile.remoteGatewayPort(matchingHost: "gateway.ts.net") == 19999)
            #expect(PromptXConfigFile.remoteGatewayPort(matchingHost: "gateway") == 19999)
            #expect(PromptXConfigFile.remoteGatewayPort(matchingHost: "other.ts.net") == nil)
        }
    }

    @MainActor
    @Test
    func setRemoteGatewayUrlPreservesScheme() async {
        let override = FileManager().temporaryDirectory
            .appendingPathComponent("promptx-config-\(UUID().uuidString)")
            .appendingPathComponent("promptx.json")
            .path

        await TestIsolation.withEnvValues(["PROMPTX_CONFIG_PATH": override]) {
            PromptXConfigFile.saveDict([
                "gateway": [
                    "remote": [
                        "url": "wss://old-host:111",
                    ],
                ],
            ])
            PromptXConfigFile.setRemoteGatewayUrl(host: "new-host", port: 2222)
            let root = PromptXConfigFile.loadDict()
            let url = ((root["gateway"] as? [String: Any])?["remote"] as? [String: Any])?["url"] as? String
            #expect(url == "wss://new-host:2222")
        }
    }

    @Test
    func stateDirOverrideSetsConfigPath() async {
        let dir = FileManager().temporaryDirectory
            .appendingPathComponent("promptx-state-\(UUID().uuidString)", isDirectory: true)
            .path

        await TestIsolation.withEnvValues([
            "PROMPTX_CONFIG_PATH": nil,
            "PROMPTX_STATE_DIR": dir,
        ]) {
            #expect(PromptXConfigFile.stateDirURL().path == dir)
            #expect(PromptXConfigFile.url().path == "\(dir)/promptx.json")
        }
    }
}
