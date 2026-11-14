import { readFile, writeFile, mkdir } from 'node:fs/promises'
import { existsSync } from 'node:fs'
import { spawn } from 'node:child_process'
import { resolve, join } from 'node:path'
import { pathToFileURL } from 'node:url'
import { createServer } from 'node:http'
import { createHash } from 'node:crypto'

const root = resolve(import.meta.dirname, '..')
const edge = process.argv.includes('--edge')
const out = join(root, '.godot/overhaul/browser', edge ? 'edge' : '')
const quick = process.argv.includes('--quick')
const captures = process.argv.find(arg => arg.startsWith('--only-captures='))
const scenes = captures ? captures.slice(captures.indexOf('=') + 1).split(',') : null
const candidates = [process.env.SNAPBACK_BROWSER, ...(edge
  ? ['C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe']
  : ['C:/Program Files/Google/Chrome/Application/chrome.exe', 'C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe'])].filter(Boolean)
const browser = candidates.find(existsSync)
if (!browser) throw new Error('Set SNAPBACK_BROWSER to an installed Chrome or Edge executable')
await mkdir(out, { recursive: true })
const original = await readFile(join(root, 'index.html'), 'utf8')
const sourceSha256 = createHash('sha256').update(original).digest('hex')

const errorScript = String.raw`
window.__qaErrors = []
window.__qaWarnings = []
addEventListener('error', e => window.__qaErrors.push(e.message))
addEventListener('unhandledrejection', e => window.__qaErrors.push(String(e.reason)))
const originalError = console.error.bind(console)
const originalWarn = console.warn.bind(console)
console.error = (...args) => {
  window.__qaErrors.push(args.join(' '))
  originalError(...args)
}
console.warn = (...args) => {
  window.__qaWarnings.push(args.join(' '))
  originalWarn(...args)
}
`
const prefix = `<script>${errorScript}
window.__SNAPBACK_TEST__ = true
window.requestAnimationFrame = () => 0
</script>`
const helpers = String.raw`
const api = window.SnapbackTest
const s = api.getState()
const results = []
function assert(value, message) {
  if (!value) throw new Error(message)
}
function test(name, fn) {
  try {
    fn()
    results.push({ name, passed: true })
  } catch (error) {
    results.push({ name, passed: false, error: error.message })
  }
}
function key(code, down = true, repeat = false) {
  const event = new KeyboardEvent(down ? 'keydown' : 'keyup', { code, key: code, bubbles: true, cancelable: true, repeat })
  window.dispatchEvent(event)
  return event
}
function tap(code) {
  key(code)
  key(code, false)
}
function release() {
  for (const code of Object.keys(api.input.held)) key(code, false)
}
function begin() {
  release()
  api.startMatch(s)
  api.input.clear()
  api.driver.reset()
}
function ticks(count) {
  api.driver.reset()
  api.driver.frame(0)
  for (let tick = 1; tick <= count; tick++) api.driver.frame(tick * 1000 / api.CONFIG.simulation.hz)
}
function visible(element) {
  return element.getClientRects().length > 0 && getComputedStyle(element).visibility !== 'hidden'
}
function drawTexts() {
  const ctx = document.getElementById('game').getContext('2d')
  const texts = []
  const fill = ctx.fillText
  const stroke = ctx.strokeText
  ctx.fillText = function(text, ...args) {
    texts.push(String(text))
    return fill.call(this, text, ...args)
  }
  ctx.strokeText = function(text, ...args) {
    texts.push(String(text))
    return stroke.call(this, text, ...args)
  }
  try {
    api.render()
  } finally {
    ctx.fillText = fill
    ctx.strokeText = stroke
  }
  return texts
}
function gameplayText() {
  const texts = drawTexts()
  assert(texts.length > 0, 'score is missing')
  assert(texts.every(text => /^[\d\s:Â·.-]+$/.test(text)), 'active text: ' + texts.join(' | '))
  assert(!visible(document.getElementById('sound')) && !visible(document.getElementById('motion')), 'settings visible in gameplay')
  return texts
}
`
const suite = helpers + String.raw`
test('local document and Canvas start without errors', () => {
  assert(s.phase === 'TITLE', 'expected title')
  assert(document.getElementById('game').getContext('2d'), 'Canvas unavailable')
  assert(!window.__qaErrors.length, 'startup error')
})
test('Space starts immediately and clears the start edge', () => {
  tap('Space')
  assert(s.phase === 'RALLY', 'Space did not start')
  assert(s.players.every(player => player.vy < 0), 'opening is a passive fall')
  assert(!Object.keys(api.input.held).length, 'start input leaked')
  assert(s.players.every(player => player.netPressTick === api.NEVER), 'start bounce edge leaked')
})
test('each player can start from their bounce key', () => {
  for (const code of ['KeyW', 'ArrowUp']) {
    s.phase = 'TITLE'
    tap(code)
    assert(s.phase === 'RALLY', code + ' did not start')
    assert(s.players.every(player => player.netPressTick === api.NEVER), 'start action leaked into bounce')
  }
})
test('both held movement inputs run independently', () => {
  begin()
  key('KeyA')
  key('ArrowRight')
  ticks(10)
  assert(s.players[0].x < api.CONFIG.player.spawnX[0], 'P1 did not move')
  assert(s.players[1].x > api.CONFIG.player.spawnX[1], 'P2 did not move')
  release()
})
test('opening supports an aerial encounter within one second', () => {
  begin()
  key('KeyD')
  key('ArrowLeft')
  let nearest = Infinity
  for (let tick = 0; tick < 60; tick++) {
    ticks(1)
    nearest = Math.min(nearest, Math.abs(s.players[1].x - s.players[0].x))
  }
  assert(nearest <= api.CONFIG.player.width + 2, 'players could not reach each other')
  assert(s.stats.bounces.every(count => count > 0), 'first rebound took longer than one second')
  release()
})
test('both dive controls accelerate falling players', () => {
  begin()
  for (const player of s.players) Object.assign(player, { y: 150, vy: 1 })
  key('KeyS')
  key('ArrowDown')
  ticks(8)
  assert(s.players.every(player => player.diving && player.vy > 1 + api.CONFIG.player.gravity * 8), 'independent dive missing')
  release()
})
test('bounce inputs use edges and ignore repeat', () => {
  begin()
  key('KeyW')
  key('ArrowUp')
  const first = api.input.take()
  assert(first.pressed.includes('KeyW') && first.pressed.includes('ArrowUp'), 'simultaneous press missing')
  key('KeyW', true, true)
  key('ArrowUp', true, true)
  assert(api.input.take().pressed.length === 0, 'repeat created a press')
  key('KeyW', false)
  key('KeyW')
  assert(api.input.take().pressed.includes('KeyW'), 'release and press failed')
  release()
})
test('game keys prevent scrolling', () => {
  for (const code of ['Space', 'ArrowLeft', 'ArrowRight', 'ArrowUp', 'ArrowDown']) {
    assert(key(code).defaultPrevented, code + ' can scroll')
    key(code, false)
  }
  assert(scrollX === 0 && scrollY === 0, 'page moved')
})
test('active drawing contains score numerals only', () => {
  begin()
  ticks(1)
  gameplayText()
})
test('action drawings remain free of labels', () => {
  for (const type of ['PERFECT', 'BOUNCE', 'STOMP', 'SNAPBACK', 'RELEASE']) {
    begin()
    s.effects = [{ type, id: 0, x: s.players[0].x, y: 400, tick: s.totalTicks, tier: 3 }]
    gameplayText()
  }
})
test('Escape freezes the simulation and clears inputs', () => {
  begin()
  ticks(10)
  key('KeyA')
  key('KeyW')
  tap('Escape')
  assert(s.phase === 'PAUSED', 'not paused')
  assert(Object.keys(api.input.held).length === 0, 'held inputs after pause')
  const before = JSON.stringify(s)
  ticks(30)
  assert(JSON.stringify(s) === before, 'paused physics advanced')
  assert(visible(document.getElementById('sound')) && visible(document.getElementById('motion')), 'pause settings unavailable')
  tap('Escape')
  assert(s.phase === 'RALLY', 'did not resume')
  assert(s.players.every(player => player.netPressTick === api.NEVER), 'stale bounce after pause')
})
test('blur pauses and clears both players', () => {
  begin()
  key('KeyD')
  key('ArrowLeft')
  window.dispatchEvent(new Event('blur'))
  assert(s.phase === 'PAUSED', 'blur did not pause')
  assert(Object.keys(api.input.held).length === 0, 'blur left input')
  tap('Escape')
})
test('hidden document pauses and clears input', () => {
  begin()
  key('KeyD')
  Object.defineProperty(document, 'hidden', { configurable: true, value: true })
  document.dispatchEvent(new Event('visibilitychange'))
  delete document.hidden
  assert(s.phase === 'PAUSED', 'hidden document did not pause')
  assert(Object.keys(api.input.held).length === 0, 'hidden document left input')
  tap('Escape')
})
test('focused pause buttons keep native Space and Enter behavior', () => {
  begin()
  tap('Escape')
  const button = document.getElementById('sound')
  button.focus()
  for (const code of ['Space', 'Enter']) for (const type of ['keydown', 'keyup']) {
    const event = new KeyboardEvent(type, { code, bubbles: true, cancelable: true })
    button.dispatchEvent(event)
    assert(!event.defaultPrevented, type + ' ' + code + ' blocked on button')
  }
  assert(s.phase === 'PAUSED', 'button keys changed game phase')
  assert(!api.input.held.Space && !api.input.held.Enter, 'button input leaked')
  document.getElementById('game').focus()
  tap('Escape')
})
test('pause and winner live region updates immediately', () => {
  begin()
  tap('Escape')
  assert(document.getElementById('status').textContent.includes('Paused'), 'pause announcement delayed')
  tap('Escape')
  s.scores = [0, 2]
  s.players[0].y = api.CONFIG.canvas.height + 1
  ticks(1)
  assert(s.phase === 'MATCH_OVER', 'winner fixture failed')
  assert(document.getElementById('status').textContent.includes('Mint wins'), 'winner announcement delayed')
})
test('M and V toggle once and expose accessible state', () => {
  begin()
  const muted = s.muted
  const reduced = s.reducedMotion
  key('KeyM')
  key('KeyM', true, true)
  assert(s.muted !== muted, 'mute did not toggle once')
  assert(document.getElementById('sound').getAttribute('aria-pressed') === String(s.muted), 'mute aria state')
  key('KeyM', false)
  key('KeyV')
  key('KeyV', true, true)
  assert(s.reducedMotion !== reduced, 'motion did not toggle once')
  assert(document.getElementById('motion').getAttribute('aria-pressed') === String(s.reducedMotion), 'motion aria state')
  key('KeyV', false)
})
test('point transition stays clean and resets inputs and charges', () => {
  begin()
  key('KeyA')
  s.players[0].y = api.CONFIG.canvas.height + 1
  ticks(1)
  assert(s.phase === 'POINT_FREEZE', 'point phase missing')
  gameplayText()
  const rally = s.rallyIndex
  ticks(Math.ceil(api.CONFIG.scoring.pointPresentationSeconds * api.CONFIG.simulation.hz) + 2)
  assert(s.phase === 'RALLY' && s.rallyIndex === rally + 1, 'next rally missing')
  assert(Object.keys(api.input.held).length === 0, 'held input carried across rally')
  assert(s.players.every(player => player.recoveryCharge === 1 && player.tier === api.CONFIG.bounce.startTier), 'reset incomplete')
})
test('scoring ends at three and Enter rematches immediately', () => {
  begin()
  for (let point = 0; point < 3; point++) {
    s.players[0].y = api.CONFIG.canvas.height + 1
    ticks(1)
    if (point < 2) ticks(Math.ceil(api.CONFIG.scoring.pointPresentationSeconds * api.CONFIG.simulation.hz) + 2)
  }
  assert(s.phase === 'MATCH_OVER' && s.scores[1] === 3, 'winner missing')
  const scores = JSON.stringify(s.scores)
  ticks(60)
  assert(JSON.stringify(s.scores) === scores, 'extra scoring after winner')
  tap('Enter')
  assert(s.phase === 'RALLY' && s.scores.every(score => score === 0), 'rematch failed')
  assert(s.players.every(player => player.recoveryCharge === 1), 'charge reset failed')
})
test('draw is read only', () => {
  begin()
  ticks(20)
  const before = JSON.stringify(s)
  api.render()
  assert(JSON.stringify(s) === before, 'draw changed simulation')
})
test('synthetic input cannot unlock audio', () => {
  assert(!api.audio.inspect().initialized, 'synthetic key autoplayed audio')
})
test('Canvas scales uniformly without page overflow', () => {
  window.dispatchEvent(new Event('resize'))
  const bounds = document.getElementById('game').getBoundingClientRect()
  assert(Math.abs(bounds.width / bounds.height - 960 / 540) < .002, 'distorted aspect')
  assert(bounds.width <= innerWidth + .5 && bounds.height <= innerHeight + .5, 'canvas overflow')
  assert(document.documentElement.scrollHeight <= innerHeight && document.documentElement.scrollWidth <= innerWidth, 'page overflow')
})
release()
api.pause(true)
const payload = {
  results,
  errors: window.__qaErrors,
  warnings: window.__qaWarnings,
  userAgent: navigator.userAgent,
  viewport: { width: innerWidth, height: innerHeight, dpr: devicePixelRatio },
  physicalKeyboard: 'NOT RUN: synthetic DOM input only',
  humanPlaytest: 'NOT RUN',
  audibility: 'NOT RUN'
}
const result = document.createElement('pre')
result.id = 'qa-result'
result.hidden = true
result.textContent = JSON.stringify(payload)
document.body.appendChild(result)
`

const fixture = helpers + String.raw`
const scene = SCENE
if (scene !== 'title') tap('Space')
const c = api.CONFIG
function landing(perfect, dive = false) {
  Object.assign(s.players[0], { x: c.player.spawnX[0], y: c.trampoline.equilibriumY - c.player.height - 2, vy: dive ? 12 : 4 })
  if (perfect) tap('KeyW')
  if (dive) key('KeyS')
  ticks(1)
  if (dive) key('KeyS', false)
}
if (scene === 'rally') ticks(12)
if (scene === 'perfect' || scene === 'compression') {
  landing(true)
  if (scene === 'compression') ticks(2)
}
if (scene === 'release') {
  landing(true)
  let guard = 0
  while (s.players[0].compression && guard++ < 20) ticks(1)
}
if (scene === 'stomp') {
  Object.assign(s.players[0], { x: 475, y: 200, vy: 15 })
  Object.assign(s.players[1], { x: 485, y: 250, vy: 0 })
  ticks(1)
}
if (['save', 'reduced', 'miss'].includes(scene)) {
  if (scene === 'reduced') tap('KeyV')
  Object.assign(s.players[0], { x: c.bumper.leftX + c.player.width / 2 + 6, y: 330, vx: -9, vy: 4 })
  if (scene !== 'miss') tap('KeyW')
  ticks(1)
  if (scene === 'miss') ticks(c.bumper.postContactGraceTicks + 1)
}
if (scene === 'save_right') {
  Object.assign(s.players[1], { x: c.bumper.rightX - c.player.width / 2 - 6, y: 330, vx: 9, vy: 4 })
  tap('ArrowUp')
  ticks(1)
}
if (scene === 'save_ready') {
  Object.assign(s.players[0], { x: c.bumper.leftX + 60, y: 300, vx: -7, vy: 4 })
  ticks(1)
}
if (scene === 'wave') {
  landing(false, true)
  ticks(5)
}
if (scene === 'high' || scene === 'high_wave') {
  s.players[0].tier = c.bounce.maxTier - 1
  if (scene === 'high_wave') {
    const net = api.sampleNetAt(s, s.players[0].x)
    s.net.v[net.i] = -c.trampoline.maxVelocity
    s.net.v[net.i + 1] = -c.trampoline.maxVelocity
  }
  landing(true)
  let guard = 0
  while (s.players[0].compression && guard++ < 20) ticks(1)
  while (s.players[0].vy < 0 && guard++ < 120) ticks(1)
}
if (scene === 'pause') {
  ticks(15)
  tap('Escape')
}
if (scene === 'point') {
  s.players[0].y = c.canvas.height + 1
  ticks(1)
}
if (scene === 'winner') {
  s.scores = [2, 1]
  s.players[1].y = c.canvas.height + 1
  ticks(1)
}
const drawnText = drawTexts()
const payload = {
  scenario: scene,
  phase: s.phase,
  events: s.events,
  errors: window.__qaErrors,
  warnings: window.__qaWarnings,
  viewport: { width: innerWidth, height: innerHeight },
  scores: s.scores,
  syntheticFixture: true,
  reducedMotion: s.reducedMotion,
  players: s.players.map(player => ({ x: player.x, y: player.y, vy: player.vy, tier: player.tier, recoveryCharge: player.recoveryCharge, compression: player.compression })),
  netMaxDeflection: Math.max(...s.net.d.map(Math.abs)),
  effectTypes: s.effects.map(event => event.type),
  stats: s.stats,
  drawnText,
  settingsVisible: visible(document.getElementById('sound')) || visible(document.getElementById('motion')),
  canvasPng: document.getElementById('game').toDataURL('image/png')
}
const result = document.createElement('pre')
result.id = 'qa-result'
result.hidden = true
result.textContent = JSON.stringify(payload)
document.body.appendChild(result)
`

function page(script) {
  return original.replace('<script>', prefix + '\n<script>').replace('</body>', '<script>\n' + script + '\n</script></body>')
}
function decode(text) {
  return text.replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&amp;/g, '&').replace(/&quot;/g, '"')
}
let correction = [0, 0]
async function run(name, url, size, screenshot = true) {
  const profile = join(out, 'profile_' + name + '_' + Date.now())
  const args = [
    '--headless=new', '--no-first-run', '--no-default-browser-check', '--disable-background-networking',
    '--disable-component-update', '--disable-sync', '--disable-extensions', '--disable-gpu', '--mute-audio',
    '--hide-scrollbars', '--force-device-scale-factor=1', '--window-size=' + size.map((value, index) => value + correction[index]).join(','),
    '--user-data-dir=' + profile, '--virtual-time-budget=350', '--dump-dom'
  ]
  if (screenshot) args.push('--screenshot=' + join(out, name + '.png'))
  args.push(url)
  const started = Date.now()
  const result = await new Promise(resolveResult => {
    const child = spawn(browser, args, { cwd: root, windowsHide: true })
    let stdout = ''
    let stderr = ''
    let timedOut = false
    let settled = false
    const timer = setTimeout(() => {
      timedOut = true
      const killer = spawn('taskkill.exe', ['/PID', String(child.pid), '/T', '/F'], { windowsHide: true })
      killer.on('error', () => {})
    }, 60000)
    child.stdout.on('data', chunk => stdout += chunk)
    child.stderr.on('data', chunk => stderr += chunk)
    child.on('error', error => {
      if (settled) return
      settled = true
      clearTimeout(timer)
      resolveResult({ exitCode: null, stdout, stderr, error: String(error), timedOut })
    })
    child.on('close', exitCode => {
      if (settled) return
      settled = true
      clearTimeout(timer)
      resolveResult({ exitCode, stdout, stderr, timedOut })
    })
  })
  await writeFile(join(out, name + '.html'), result.stdout)
  await writeFile(join(out, name + '.stderr.txt'), result.stderr)
  const match = result.stdout.match(/<pre id="qa-result" hidden="">([\s\S]*?)<\/pre>/)
  let evidence = null
  if (match) {
    try {
      evidence = JSON.parse(decode(match[1]))
    } catch (error) {
      result.parseError = String(error)
    }
  }
  if (evidence?.canvasPng) {
    const data = evidence.canvasPng
    delete evidence.canvasPng
    if (data.startsWith('data:image/png;base64,')) {
      await writeFile(join(out, name + '.canvas.png'), Buffer.from(data.slice(data.indexOf(',') + 1), 'base64'))
      evidence.canvasArtifact = name + '.canvas.png'
    }
  }
  return { name, url, size, elapsedSeconds: (Date.now() - started) / 1000, exitCode: result.exitCode, timedOut: result.timedOut, error: result.error || result.parseError || null, evidence }
}
const probePath = join(out, 'viewport-probe.html')
await writeFile(probePath, page(`
const result = document.createElement('pre')
result.id = 'qa-result'
result.hidden = true
result.textContent = JSON.stringify({ errors: window.__qaErrors, viewport: { width: innerWidth, height: innerHeight } })
document.body.appendChild(result)
`))
const probe = await run('viewport_probe', pathToFileURL(probePath).href, [960, 540], false)
if (probe.exitCode !== 0 || !probe.evidence) throw new Error('Browser probe failed. See ' + out)
correction = [960 - probe.evidence.viewport.width, 540 - probe.evidence.viewport.height]
const results = []
function report(result, description) {
  results.push(result)
  console.log((result.passed ? 'PASS ' : 'FAIL ') + description)
  for (const failure of result.evidence?.results?.filter(item => !item.passed) || []) console.log('  ' + failure.name + ': ' + failure.error)
  if (result.error || result.evidence?.errors.length) console.log(JSON.stringify(result))
}
function valid(result) {
  return result.exitCode === 0 && !result.timedOut && !!result.evidence && result.evidence.errors.length === 0 && (result.evidence.warnings || []).length === 0
}
if (!scenes) {
  const standalone = await run('standalone', pathToFileURL(join(root, 'index.html')).href, [960, 540])
  const dom = await readFile(join(out, 'standalone.html'), 'utf8')
  standalone.readinessMarker = /data-ready="true"/.test(dom)
  standalone.passed = standalone.exitCode === 0 && !standalone.timedOut && standalone.readinessMarker
  report(standalone, 'actual index.html direct-file launch')
  const suitePath = join(out, 'suite-source.html')
  await writeFile(suitePath, page(suite))
  for (const size of (quick ? [[960, 540]] : [[960, 540], [1280, 720], [640, 400]])) {
    const result = await run('suite_' + size.join('x'), pathToFileURL(suitePath).href, size)
    result.passed = valid(result) && result.evidence.results.every(item => item.passed)
    report(result, result.name + ' ' + (result.evidence?.results.filter(item => item.passed).length || 0) + '/' + (result.evidence?.results.length || 0) + ' assertions')
  }
}
if (!quick && !process.argv.includes('--no-captures')) {
  for (const scene of (scenes || ['title', 'opening', 'rally', 'perfect', 'compression', 'release', 'stomp', 'save', 'save_right', 'save_ready', 'miss', 'wave', 'reduced', 'high', 'high_wave', 'pause', 'point', 'winner'])) {
    const source = join(out, 'fixture_' + scene + '.html')
    await writeFile(source, page(fixture.replace('SCENE', JSON.stringify(scene))))
    const result = await run('capture_' + scene, pathToFileURL(source).href, [960, 540])
    const expected = { title: 'TITLE', pause: 'PAUSED', point: 'POINT_FREEZE', winner: 'MATCH_OVER' }[scene] || 'RALLY'
    const event = { perfect: 'PERFECT', release: 'RELEASE', stomp: 'STOMP', save: 'SNAPBACK', save_right: 'SNAPBACK', reduced: 'SNAPBACK', point: 'POINT', winner: 'VICTORY' }[scene]
    const evidence = result.evidence
    result.passed = valid(result) && evidence.phase === expected && (!event || evidence.events.some(item => item.type === event))
    if (result.passed && ['RALLY', 'POINT_FREEZE'].includes(expected)) result.passed = evidence.drawnText.length > 0 && evidence.drawnText.every(text => /^[\d\s:Â·.-]+$/.test(text)) && !evidence.settingsVisible
    if (result.passed && scene === 'compression') result.passed = !!evidence.players[0].compression && evidence.netMaxDeflection > 0
    if (result.passed && scene === 'wave') result.passed = evidence.netMaxDeflection > 0 && evidence.effectTypes.includes('BOUNCE')
    if (result.passed && ['save_ready', 'miss'].includes(scene)) result.passed = evidence.players[0].recoveryCharge === 1 && evidence.stats.saves[0] === 0
    report(result, 'capture ' + scene)
  }
}
if (!quick && !scenes) {
  const embedScript = String.raw`
const frame = document.getElementById('embed')
frame.addEventListener('load', () => {
  const results = []
  function assert(value, message) {
    if (!value) throw new Error(message)
  }
  function test(name, fn) {
    try {
      fn()
      results.push({ name, passed: true })
    } catch (error) {
      results.push({ name, passed: false, error: error.message })
    }
  }
  const w = frame.contentWindow
  const api = w.SnapbackTest
  const s = api?.getState()
  const params = new URL(location.href).searchParams
  test('HTTP game opens in iframe', () => assert(api && s.phase === 'TITLE', 'title failed'))
  test('iframe has exact requested dimensions', () => assert(w.innerWidth === Number(params.get('w')) && w.innerHeight === Number(params.get('h')), 'wrong viewport'))
  test('iframe Canvas keeps aspect and bounds', () => {
    const bounds = w.document.getElementById('game').getBoundingClientRect()
    assert(Math.abs(bounds.width / bounds.height - 960 / 540) < .002, 'wrong aspect')
    assert(bounds.width <= w.innerWidth + .5 && bounds.height <= w.innerHeight + .5, 'overflow')
  })
  test('iframe keyboard starts both players', () => {
    for (const code of ['Space', 'KeyA', 'ArrowRight']) w.dispatchEvent(new w.KeyboardEvent('keydown', { code, bubbles: true, cancelable: true }))
    api.driver.reset()
    api.driver.frame(0)
    for (let tick = 1; tick <= 10; tick++) api.driver.frame(tick * 1000 / 60)
    assert(s.phase === 'RALLY', 'start failed')
    assert(s.players[0].x < api.CONFIG.player.spawnX[0] && s.players[1].x > api.CONFIG.player.spawnX[1], 'simultaneous movement failed')
  })
  test('iframe blur pauses and clears inputs', () => {
    w.dispatchEvent(new w.Event('blur'))
    assert(s.phase === 'PAUSED' && !Object.keys(api.input.held).length, 'blur failed')
  })
  const result = document.createElement('pre')
  result.id = 'qa-result'
  result.hidden = true
  result.textContent = JSON.stringify({ results, errors: w.__qaErrors || ['Missing error instrumentation'], warnings: w.__qaWarnings || [], userAgent: navigator.userAgent, viewport: { width: w.innerWidth, height: w.innerHeight }, syntheticInput: true, canvasPng: w.document.getElementById('game').toDataURL('image/png') })
  document.body.appendChild(result)
})
`
  const requests = []
  const server = createServer((req, res) => {
    requests.push(req.url)
    const url = new URL(req.url, 'http://127.0.0.1')
    if (url.pathname === '/index.html') {
      res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' })
      res.end(original.replace('<script>', '<script>' + errorScript + '</script><script>'))
    } else if (url.pathname === '/iframe.html') {
      const width = Number(url.searchParams.get('w')) || 640
      const height = Number(url.searchParams.get('h')) || 360
      res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' })
      res.end('<!doctype html><html><head><meta charset="utf-8"><style>html,body{margin:0;background:#101417;color:#F2EDE3;height:100%;display:grid;place-items:center}iframe{width:' + width + 'px;height:' + height + 'px;border:0}</style></head><body><iframe id="embed" title="Snapback iframe check" src="/index.html?test=1"></iframe><script>' + embedScript + '</script></body></html>')
    } else {
      res.writeHead(404)
      res.end()
    }
  })
  await new Promise(listening => server.listen(0, '127.0.0.1', listening))
  try {
    for (const size of [[960, 540], [1280, 720], [640, 400], [640, 360]]) {
      const result = await run('iframe_http_' + size.join('x'), 'http://127.0.0.1:' + server.address().port + '/iframe.html?w=' + size[0] + '&h=' + size[1], [size[0] + 160, size[1] + 220])
      result.passed = valid(result) && result.evidence.results.every(item => item.passed)
      report(result, result.name + ' ' + (result.evidence?.results.filter(item => item.passed).length || 0) + '/5 assertions')
    }
  } finally {
    await new Promise(closed => server.close(closed))
  }
  report({ name: 'localhost_request_inventory', passed: requests.every(url => /^\/(iframe\.html|index\.html|favicon\.ico)(\?|$)/.test(url)), requests }, 'local-only request inventory')
}
const output = { browser, sourceSha256, windowFrameCorrection: correction, createdAt: new Date().toISOString(), results }
const reportName = scenes ? 'results_captures_' + scenes.join('_') + '.json' : quick ? 'results_core.json' : 'results_full.json'
await writeFile(join(out, reportName), JSON.stringify(output, null, 2))
process.exitCode = results.every(result => result.passed) ? 0 : 1