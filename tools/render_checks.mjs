// Optional native render artifact check. No exports or publishing.
import { readFileSync, mkdirSync, writeFileSync } from 'node:fs';
import { spawnSync } from 'node:child_process';
import { resolve, join } from 'node:path';
const root = resolve(import.meta.dirname, '..');
const config = JSON.parse(readFileSync(join(root, '.vscode/settings.json'), 'utf8'));
const engine = (process.env.GODOT_PATH || config['godotTools.editorPath.godot4']).replace(/(?<!_console)\.exe$/i, '_console.exe');
const out = join(root, '.godot/validation/renders');
mkdirSync(out, { recursive: true });
let ok = true;
for (const phase of process.argv.slice(2).length ? process.argv.slice(2) : ['base', 'finale']) {
  const started = Date.now();
  const result = spawnSync(engine, ['--path', root, '--rendering-method', 'gl_compatibility', '--rendering-driver', 'opengl3_angle', '--audio-driver', 'Dummy', '--fixed-fps', '60', '--disable-vsync', '--resolution', '1152x648', '--position', '4000,4000', '--log-file', join(out, phase + '.log'), '--script', 'res://scripts/tests/render_capture.gd', '--', phase], { cwd: root, windowsHide: true, timeout: 180000, encoding: 'utf8', maxBuffer: 8 * 1024 * 1024 });
  const output = (result.stdout || '') + (result.stderr || '');
  writeFileSync(join(out, phase + '_output.txt'), output);
  console.log(output);
  console.log(JSON.stringify({ phase, exitCode: result.status, elapsedSeconds: (Date.now() - started) / 1000, error: result.error?.message || null }));
  if (result.status !== 0 || result.error || /ERROR:|SCRIPT ERROR:|WARNING:/.test(output) || !output.includes('PASS render ' + phase)) { ok = false; break; }
}
process.exitCode = ok ? 0 : 1;
