import Foundation

// Stable identifier used for both the macOS LaunchAgent label and Nix-managed defaults suite.
// nix-promptx writes app defaults into this suite to survive app bundle identifier churn.
let launchdLabel = "ai.promptx.mac"
let gatewayLaunchdLabel = "ai.promptx.gateway"
let onboardingVersionKey = "promptx.onboardingVersion"
let onboardingSeenKey = "promptx.onboardingSeen"
let currentOnboardingVersion = 7
let pauseDefaultsKey = "promptx.pauseEnabled"
let iconAnimationsEnabledKey = "promptx.iconAnimationsEnabled"
let swabbleEnabledKey = "promptx.swabbleEnabled"
let swabbleTriggersKey = "promptx.swabbleTriggers"
let voiceWakeTriggerChimeKey = "promptx.voiceWakeTriggerChime"
let voiceWakeSendChimeKey = "promptx.voiceWakeSendChime"
let showDockIconKey = "promptx.showDockIcon"
let defaultVoiceWakeTriggers = ["promptx"]
let voiceWakeMaxWords = 32
let voiceWakeMaxWordLength = 64
let voiceWakeMicKey = "promptx.voiceWakeMicID"
let voiceWakeMicNameKey = "promptx.voiceWakeMicName"
let voiceWakeLocaleKey = "promptx.voiceWakeLocaleID"
let voiceWakeAdditionalLocalesKey = "promptx.voiceWakeAdditionalLocaleIDs"
let voicePushToTalkEnabledKey = "promptx.voicePushToTalkEnabled"
let talkEnabledKey = "promptx.talkEnabled"
let iconOverrideKey = "promptx.iconOverride"
let connectionModeKey = "promptx.connectionMode"
let remoteTargetKey = "promptx.remoteTarget"
let remoteIdentityKey = "promptx.remoteIdentity"
let remoteProjectRootKey = "promptx.remoteProjectRoot"
let remoteCliPathKey = "promptx.remoteCliPath"
let canvasEnabledKey = "promptx.canvasEnabled"
let cameraEnabledKey = "promptx.cameraEnabled"
let systemRunPolicyKey = "promptx.systemRunPolicy"
let systemRunAllowlistKey = "promptx.systemRunAllowlist"
let systemRunEnabledKey = "promptx.systemRunEnabled"
let locationModeKey = "promptx.locationMode"
let locationPreciseKey = "promptx.locationPreciseEnabled"
let peekabooBridgeEnabledKey = "promptx.peekabooBridgeEnabled"
let deepLinkKeyKey = "promptx.deepLinkKey"
let modelCatalogPathKey = "promptx.modelCatalogPath"
let modelCatalogReloadKey = "promptx.modelCatalogReload"
let cliInstallPromptedVersionKey = "promptx.cliInstallPromptedVersion"
let heartbeatsEnabledKey = "promptx.heartbeatsEnabled"
let debugPaneEnabledKey = "promptx.debugPaneEnabled"
let debugFileLogEnabledKey = "promptx.debug.fileLogEnabled"
let appLogLevelKey = "promptx.debug.appLogLevel"
let voiceWakeSupported: Bool = ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 26
