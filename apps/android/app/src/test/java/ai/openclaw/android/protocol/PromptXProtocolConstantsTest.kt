package ai.openclaw.android.protocol

import org.junit.Assert.assertEquals
import org.junit.Test

class PromptXProtocolConstantsTest {
  @Test
  fun canvasCommandsUseStableStrings() {
    assertEquals("canvas.present", PromptXCanvasCommand.Present.rawValue)
    assertEquals("canvas.hide", PromptXCanvasCommand.Hide.rawValue)
    assertEquals("canvas.navigate", PromptXCanvasCommand.Navigate.rawValue)
    assertEquals("canvas.eval", PromptXCanvasCommand.Eval.rawValue)
    assertEquals("canvas.snapshot", PromptXCanvasCommand.Snapshot.rawValue)
  }

  @Test
  fun a2uiCommandsUseStableStrings() {
    assertEquals("canvas.a2ui.push", PromptXCanvasA2UICommand.Push.rawValue)
    assertEquals("canvas.a2ui.pushJSONL", PromptXCanvasA2UICommand.PushJSONL.rawValue)
    assertEquals("canvas.a2ui.reset", PromptXCanvasA2UICommand.Reset.rawValue)
  }

  @Test
  fun capabilitiesUseStableStrings() {
    assertEquals("canvas", PromptXCapability.Canvas.rawValue)
    assertEquals("camera", PromptXCapability.Camera.rawValue)
    assertEquals("screen", PromptXCapability.Screen.rawValue)
    assertEquals("voiceWake", PromptXCapability.VoiceWake.rawValue)
  }

  @Test
  fun screenCommandsUseStableStrings() {
    assertEquals("screen.record", PromptXScreenCommand.Record.rawValue)
  }
}
