// No dependencies: run with Node.js. Uses the configured local Godot console build.
import { readFileSync, mkdirSync, readdirSync, writeFileSync } from 'node:fs';
import { spawnSync } from 'node:child_process';
import { resolve, join } from 'node:path';
const root = resolve(import.meta.dirname, '..');
const config = JSON.parse(readFileSync(join(root, '.vscode/settings.json'), 'utf8'));
const configured = process.env.GODOT_PATH || config['godotTools.editorPath.godot4'];
const engine = configured.replace(/(?<!_console)\.exe$/i, '_console.exe');
const logDir = join(root, '.godot/validation');
mkdirSync(logDir, { recursive: true });
const scripts = readdirSync(join(root, 'scripts/tests')).filter(s => /^test_.*\.gd$/.test(s)).sort();
const checks = [['import', ['--import']], ['startup', ['--quit-after', '120']], ...scripts.map(s => [s, ['--script', 'res://scripts/tests/' + s]])];
const knownHost = /Failed to read the root certificate store|Could not open 'user:\/\/' directory|Cannot open directory '\.\/Godot\/feature_profiles'/;
const results = [];
for (const [name, args] of checks) {
  const result = spawnSync(engine, ['--headless', '--path', root, '--log-file', join(logDir, name + '.log'), ...args], { cwd: root, windowsHide: true, timeout: 60000, encoding: 'utf8', maxBuffer: 8 * 1024 * 1024 });
  const output = (result.stdout || '') + (result.stderr || '');
  const errors = output.split(/\r?\n/).filter(s => /ERROR:|SCRIPT ERROR:|WARNING:/.test(s));
  const hostDiagnostics = errors.filter(s => knownHost.test(s));
  const projectDiagnostics = errors.filter(s => !knownHost.test(s));
  const passed = result.status === 0 && !result.error && projectDiagnostics.length === 0 && (!name.endsWith('.gd') || output.includes('PASS '));
  results.push({ name, passed, exitCode: result.status, error: result.error?.message, hostDiagnostics, projectDiagnostics, output });
  console.log((passed ? 'PASS ' : 'FAIL ') + name + ' (exit ' + result.status + ', host diagnostics ' + hostDiagnostics.length + ')');
  for (const line of output.split(/\r?\n/).filter(s => s.startsWith('PASS '))) console.log('  ' + line);
  if (!passed) console.log(output);
}
writeFileSync(join(logDir, 'results.json'), JSON.stringify(results, null, 2));
const hostMessages = [...new Set(results.flatMap(r => r.hostDiagnostics))];
if (hostMessages.length) console.log('Host diagnostics (not project test failures):\n' + hostMessages.join('\n'));
process.exitCode = results.every(r => r.passed) ? 0 : 1;
