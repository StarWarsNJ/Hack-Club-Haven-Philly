// Original deterministic PCM synthesis. No third-party samples or packages.
import { mkdirSync, writeFileSync } from 'node:fs';
import { resolve, join } from 'node:path';
const directory = resolve(import.meta.dirname, '../assets/audio');
mkdirSync(directory, { recursive: true });
const rate = 22050;
let seed = 711;
const noise = () => { seed = (1664525 * seed + 1013904223) >>> 0; return seed / 2147483648 - 1; };
const sine = (f, t) => Math.sin(2 * Math.PI * f * t);
function write(name, duration, sample) {
  const count = Math.floor(duration * rate);
  const wav = Buffer.alloc(44 + count * 2);
  wav.write('RIFF', 0); wav.writeUInt32LE(36 + count * 2, 4); wav.write('WAVEfmt ', 8);
  wav.writeUInt32LE(16, 16); wav.writeUInt16LE(1, 20); wav.writeUInt16LE(1, 22);
  wav.writeUInt32LE(rate, 24); wav.writeUInt32LE(rate * 2, 28); wav.writeUInt16LE(2, 32); wav.writeUInt16LE(16, 34);
  wav.write('data', 36); wav.writeUInt32LE(count * 2, 40);
  for (let i = 0; i < count; i++) {
    const t = i / rate;
    const taper = Math.min(1, t / 0.004, (duration - t) / 0.012);
    const value = Math.max(-0.95, Math.min(0.95, sample(t) * taper));
    wav.writeInt16LE(Math.round(value * 32767), 44 + i * 2);
  }
  writeFileSync(join(directory, name + '.wav'), wav);
}
write('echo_1', 0.16, t => (Math.sin(2 * Math.PI * (150 * t + 80 * (1 - Math.exp(-45 * t)) / 45)) * 0.38 + noise() * Math.exp(-60 * t) * 0.10) * Math.exp(-24 * t));
write('echo_2', 0.18, t => (sine(440, t) + 0.3 * sine(880, t) * Math.exp(-40 * t) + 0.15 * sine(1320, t)) * Math.exp(-24 * t) * 0.35);
write('echo_3', 0.20, t => (sine(110, t) + 0.12 * sine(330, t)) * Math.exp(-15 * t) * 0.40);
write('echo_4', 0.23, t => (sine(660, t) + 0.25 * sine(1788.6, t) + 0.12 * sine(2725.8, t)) * Math.exp(-18 * t) * 0.32);
write('sync', 0.30, t => (sine(523.25, t) + sine(659.25, t) + sine(783.99, t)) * Math.exp(-14 * t) * 0.18);
write('imprint', 0.42, t => { const notes = [261.63, 329.63, 392, 523.25]; return sine(notes[Math.min(3, Math.floor(t / 0.105))], t) * Math.exp(-t * 4) * 0.30; });
write('clockwork_loop', 8.0, t => { const beat = t % 0.5; return (sine(130.8128, t) + 0.6 * sine(155.5635, t) + 0.4 * sine(196, t)) * 0.025 + sine(880, beat) * Math.exp(-beat * 70) * 0.05; });
console.log('Generated seven original 22.05kHz mono PCM assets.');
