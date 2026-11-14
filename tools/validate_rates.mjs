// Functional fixed-render-rate regression, not a performance benchmark.
import { readFileSync, mkdirSync, writeFileSync } from 'node:fs';
import { spawnSync } from 'node:child_process';
import { resolve, join } from 'node:path';
const root = resolve(import.meta.dirname, '..');
const config = JSON.parse(readFileSync(join(root, '.vscode/settings.json'), 'utf8'));
const engine = (process.env.GODOT_PATH || config['godotTools.editorPath.godot4']).replace(/(?<!_console)\.exe$/i, '_console.exe');
const out = join(root, '.godot/validation');
mkdirSync(out, { recursive: true });
const results = [];
for (const fps of [30, 144]) for (const script of ['test_echo.gd', 'test_puzzle_m1.gd']) {
  const result = spawnSync(engine, ['--headless', '--path', root, '--fixed-fps', String(fps), '--log-file', join(out, 'rate_' + fps + '_' + script + '.log'), '--script', 'res://scripts/tests/' + script], { cwd: root, windowsHide: true, timeout: 60000, encoding: 'utf8', maxBuffer: 8 * 1024 * 1024 });
  const output = (result.stdout || '') + (result.stderr || '');
  const passed = result.status === 0 && !result.error && !/ERROR:|SCRIPT ERROR:|WARNING:/.test(output) && output.includes('PASS ') && (script !== 'test_puzzle_m1.gd' || output.includes('win_tick=271'));
  results.push({ fps, script, passed, exitCode: result.status, output });
  console.log((passed ? 'PASS ' : 'FAIL ') + fps + ' render FPS / 60 physics Hz: ' + script);
  if (!passed) console.log(output);
}
writeFileSync(join(out, 'rates.json'), JSON.stringify(results, null, 2));
process.exitCode = results.every(r => r.passed) ? 0 : 1;
