type StateDirEnvSnapshot = {
  promptxStateDir: string | undefined;
  clawdbotStateDir: string | undefined;
};

export function snapshotStateDirEnv(): StateDirEnvSnapshot {
  return {
    promptxStateDir: process.env.PROMPTX_STATE_DIR,
    clawdbotStateDir: process.env.CLAWDBOT_STATE_DIR,
  };
}

export function restoreStateDirEnv(snapshot: StateDirEnvSnapshot): void {
  if (snapshot.promptxStateDir === undefined) {
    delete process.env.PROMPTX_STATE_DIR;
  } else {
    process.env.PROMPTX_STATE_DIR = snapshot.promptxStateDir;
  }
  if (snapshot.clawdbotStateDir === undefined) {
    delete process.env.CLAWDBOT_STATE_DIR;
  } else {
    process.env.CLAWDBOT_STATE_DIR = snapshot.clawdbotStateDir;
  }
}

export function setStateDirEnv(stateDir: string): void {
  process.env.PROMPTX_STATE_DIR = stateDir;
  delete process.env.CLAWDBOT_STATE_DIR;
}
