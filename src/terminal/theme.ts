import chalk, { Chalk } from "chalk";
import { PROMPTX_PALETTE } from "./palette.js";

const hasForceColor =
  typeof process.env.FORCE_COLOR === "string" &&
  process.env.FORCE_COLOR.trim().length > 0 &&
  process.env.FORCE_COLOR.trim() !== "0";

const baseChalk = process.env.NO_COLOR && !hasForceColor ? new Chalk({ level: 0 }) : chalk;

const hex = (value: string) => baseChalk.hex(value);

export const theme = {
  accent: hex(PROMPTX_PALETTE.accent),
  accentBright: hex(PROMPTX_PALETTE.accentBright),
  accentDim: hex(PROMPTX_PALETTE.accentDim),
  info: hex(PROMPTX_PALETTE.info),
  success: hex(PROMPTX_PALETTE.success),
  warn: hex(PROMPTX_PALETTE.warn),
  error: hex(PROMPTX_PALETTE.error),
  muted: hex(PROMPTX_PALETTE.muted),
  heading: baseChalk.bold.hex(PROMPTX_PALETTE.accent),
  command: hex(PROMPTX_PALETTE.accentBright),
  option: hex(PROMPTX_PALETTE.warn),
} as const;

export const isRich = () => Boolean(baseChalk.level > 0);

export const colorize = (rich: boolean, color: (value: string) => string, value: string) =>
  rich ? color(value) : value;
