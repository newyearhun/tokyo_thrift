import { writeFileSync } from "node:fs";
import { resolve } from "node:path";

const supabaseUrl = process.env.SUPABASE_URL ?? "";
const supabaseAnonKey = process.env.SUPABASE_ANON_KEY ?? "";
const output = `window.__SUPABASE_URL__ = ${JSON.stringify(supabaseUrl)};\nwindow.__SUPABASE_ANON_KEY__ = ${JSON.stringify(supabaseAnonKey)};\n`;

writeFileSync(resolve("config.js"), output, "utf8");
