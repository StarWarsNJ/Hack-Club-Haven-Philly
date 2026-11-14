import assert from 'node:assert/strict'
import {
  readFileSync
}
from 'node:fs'
import {
  resolve
}
from 'node:path'
import vm from 'node:vm'
import test from 'node:test'
const root = resolve(import.meta.dirname, '..')
const html = readFileSync(resolve(root, 'index.html'), 'utf8')
const inline = html.match(/<script>([\s\S]*?)<\/script>/)
assert.ok(inline, 'self-contained inline script exists')
const sandbox = {
  __SNAPBACK_TEST__: true,
  console
}
vm.createContext(sandbox)
vm.runInContext(inline[1], sandbox, {
  filename: 'index.html',
  timeout: 10000
})
const G = sandbox.SnapbackTest
const C = G.CONFIG
const plain = value => JSON.parse(JSON.stringify(value))
const near = (actual, expected, epsilon = 1e-8) => assert.ok(Math.abs(actual - expected) <= epsilon, `${actual} differs from ${expected}`)
const match = () => {
  const s = G.createMatchState()
  G.startMatch(s)
  return s
}
const step = (s, held = {}, pressed = []) => G.stepSimulation(s, {
  held,
  pressed
})
const keys = (id, direction) => ({
  [G.PLAYER_KEYS[id][direction]]: true
})
function release(s, p, held = {}) {
  const start = s.rallyTicks
  while (p.compression && s.rallyTicks - start < 12) step(s, held)
  assert.equal(p.compression, null, 'compression must end promptly')
  assert.ok(p.vy < 0, 'release must launch upward')
  return -p.vy
}
const impulse = p => p.compression ? p.compression.launch : -p.vy
function landingFixture({
  tier = 2,
  age = null,
  id = 0,
  x = 400
}
= {}) {
  const s = match()
  s.rallyTicks = 100
  const p = s.players[id]
  Object.assign(p, {
    x,
    prevX: x,
    prevY: 350,
    y: 380,
    vy: 15,
    tier
  })
  if (age !== null) p.netPressTick = s.rallyTicks - age
  const other = s.players[1 - id]
  Object.assign(other, {
    x: x < 480 ? 680 : 280,
    prevX: x < 480 ? 680 : 280,
    y: 100,
    prevY: 100,
    vy: 0
  })
  return {
    s,
    p
  }
}
function stompFixture(attackerId, offset) {
  const s = match()
  const a = s.players[attackerId],
  d = s.players[1 - attackerId]
  Object.assign(a, {
    prevX: 480 + offset,
    x: 480 + offset,
    prevY: 200,
    y: 219,
    vx: 0,
    vy: 19
  })
  Object.assign(d, {
    prevX: 480,
    x: 480,
    prevY: 250,
    y: 250,
    vx: 0,
    vy: 0,
    tier: 5
  })
  return {
    s,
    a,
    d
  }
}
function bumperFixture(id, side, age = 0, narrowed = false) {
  const s = match()
  s.rallyTicks = narrowed ? Math.round((C.overdrive.beginSeconds + C.overdrive.shrinkSeconds) * C.simulation.hz) : 100
  s.overdriveInset = narrowed ? C.overdrive.maxInsetEachSide : 0
  const p = s.players[id]
  const plane = side === 0 ? C.bumper.leftX : C.bumper.rightX
  Object.assign(p, {
    prevX: plane + (side === 0 ? 30 : -30),
    x: plane + (side === 0 ? 10 : -10),
    prevY: 320,
    y: 320,
    vx: side === 0 ? -7 : 7,
    vy: 5
  })
  p.savePressTick = age === null ? G.NEVER : s.rallyTicks - age
  p.netPressTick = p.savePressTick
  const other = s.players[1 - id]
  other.x = other.prevX = side === 0 ? 680 : 280
  other.y = other.prevY = 100
  return {
    s,
    p,
    plane
  }
}
function stableState(s) {
  for (const p of s.players) {
    for (const field of ['x', 'y', 'vx', 'vy']) assert.ok(Number.isFinite(p[field]), `nonfinite player ${field}`)
    assert.ok(p.tier >= C.bounce.minTier && p.tier <= C.bounce.maxTier)
    assert.ok(p.recoveryCharge === 0 || p.recoveryCharge === 1)
    assert.ok(p.vy <= C.player.maxFallVy)
  }
  for (let i = 0; i < s.net.d.length; i++) {
    assert.ok(Number.isFinite(s.net.d[i]) && Number.isFinite(s.net.v[i]))
    assert.ok(Math.abs(s.net.d[i]) <= C.trampoline.maxDeflection)
    assert.ok(Math.abs(s.net.v[i]) <= C.trampoline.maxVelocity)
  }
  assert.ok(s.effects.length <= C.presentation.maxEffects)
  assert.ok(s.scores.every(n => n >= 0 && n <= C.scoring.pointsToWin))
}
test('runtime is standalone; test hooks are explicit opt-in', () => {
  assert.equal((html.match(/<script\b/g) || []).length, 1)
  assert.equal(/<script[^>]+src=|<link[^>]+href=|<img\b|fetch\s*\(|XMLHttpRequest|WebSocket|@import|url\s*\(\s*['"]?https?:/i.test(html), false)
  const normal = {}
  vm.createContext(normal)
  vm.runInContext(inline[1], normal)
  assert.equal(normal.SnapbackTest, undefined)
  assert.equal(G.createMatchState().phase, 'TITLE')
})
test('independent physical-code held states, edges, repeats, release and scroll prevention', () => {
  const input = G.createInput()
  let prevented = 0
  const event = (code, repeat = false) => ({
    code,
    repeat,
    preventDefault() {
      prevented++
    }
  })
  for (const code of ['KeyA', 'KeyW', 'ArrowRight', 'ArrowUp', 'ArrowDown']) assert.equal(input.keydown(event(code)), true)
  assert.equal(input.keydown(event('KeyW', true)), false)
  assert.equal(input.keydown(event('KeyW')), false)
  let current = input.take()
  assert.deepEqual(Array.from(current.pressed).sort(), ['ArrowDown', 'ArrowRight', 'ArrowUp', 'KeyA', 'KeyW'].sort())
  assert.equal(current.held.KeyA, true)
  assert.equal(current.held.ArrowRight, true)
  assert.equal(input.take().pressed.length, 0)
  input.keyup(event('KeyW'))
  assert.equal(input.keydown(event('KeyW')), true)
  assert.equal(input.take().pressed.length, 1)
  assert.equal(input.keydown(event('KeyQ')), false)
  input.clear()
  assert.deepEqual(plain(input.take()), {
    held: {},
    pressed: []
  })
  assert.equal(prevented, 9)
})
test('simultaneous opposing steering and diving are independent and order-insensitive', () => {
  const a = match(),
  b = match()
  const held = {
    KeyA: true,
    KeyS: true,
    ArrowRight: true,
    ArrowDown: true
  }
  for (let i = 0; i < 8; i++) {
    step(a, held, i === 0 ? ['KeyW', 'ArrowUp'] : [])
    step(b, held, i === 0 ? ['ArrowUp', 'KeyW'] : [])
  }
  assert.ok(a.players[0].vx < 0 && a.players[1].vx > 0)
  near(a.players[0].vx, -a.players[1].vx)
  near(a.players[0].vy, a.players[1].vy)
  assert.deepEqual(plain(a), plain(b))
})
test('dive adds falling acceleration only, keeps steering, and respects fall cap', () => {
  const normal = match(),
  dive = match()
  normal.players[0].vy = dive.players[0].vy = 5
  step(normal)
  step(dive, {
    KeyS: true,
    KeyD: true
  })
  near(dive.players[0].vy - normal.players[0].vy, C.player.diveGravityBonus)
  assert.ok(dive.players[0].vx > 0)
  const rising = G.createPlayer(0)
  rising.vy = -5
  G.steerAndMove(rising, {
    KeyS: true
  })
  near(rising.vy, -5 + C.player.gravity)
  rising.vy = C.player.maxFallVy
  G.steerAndMove(rising, {
    KeyS: true
  })
  near(rising.vy, C.player.maxFallVy)
})
for (const id of [0, 1]) {
  test(`P${id + 1}: normal auto-bounce and perfect timing boundary`, () => {
    const normal = landingFixture({
      id
    })
    assert.equal(G.resolveNetLandings(normal.s), 1)
    assert.equal(normal.p.tier, C.bounce.minTier)
    near(impulse(normal.p), C.bounce.baseImpulse + C.bounce.minTier * C.bounce.impulsePerTier)
    assert.ok(normal.p.compression)
    const boundary = landingFixture({
      id,
      age: C.bounce.perfectWindowTicks
    })
    G.resolveNetLandings(boundary.s)
    assert.equal(boundary.p.tier, 3)
    assert.ok(impulse(boundary.p) > impulse(normal.p))
    assert.equal(boundary.p.netPressTick, G.NEVER)
    const late = landingFixture({
      id,
      age: C.bounce.perfectWindowTicks + 1
    })
    G.resolveNetLandings(late.s)
    assert.equal(late.p.tier, C.bounce.minTier)
  })
}
test('tier endpoints and monotonic launch heights; no below-net or off-span false landing', () => {
  const launch = []
  for (let tier = C.bounce.minTier; tier <= C.bounce.maxTier; tier++) {
    const f = landingFixture({
      tier,
      age: 0
    })
    G.resolveNetLandings(f.s)
    assert.equal(f.p.tier, Math.min(tier + 1, C.bounce.maxTier))
    launch.push(impulse(f.p))
  }
  for (let i = 1; i < launch.length - 1; i++) assert.ok(launch[i] > launch[i - 1])
  const floor = landingFixture({
    tier: C.bounce.minTier
  })
  G.resolveNetLandings(floor.s)
  assert.equal(floor.p.tier, C.bounce.minTier)
  const below = landingFixture()
  below.p.prevY = 420
  below.p.y = 390
  below.p.vy = -10
  assert.equal(G.findNetLanding(below.s, below.p), null)
  below.p.vy = 10
  below.p.prevY = 390
  below.p.y = 420
  assert.equal(G.findNetLanding(below.s, below.p), null)
  const off = landingFixture({
    x: C.trampoline.left - C.player.width
  })
  assert.equal(G.findNetLanding(off.s, off.p), null)
})
test('swept net collision catches a fast downward crossing and uses authoritative surface', () => {
  const f = landingFixture()
  f.p.prevY = 200
  f.p.y = 500
  f.p.vy = 300
  const hit = G.findNetLanding(f.s, f.p)
  assert.ok(hit)
  near(hit.y, G.sampleNetAt(f.s, hit.x).y)
  G.resolveNetLandings(f.s)
  assert.ok(f.p.compression)
  near(f.p.y + C.player.height, hit.y - C.collision.epsilon)
  release(f.s, f.p)
})
test('one net attempt per flight blocks refresh spam and a later release rearms timing', () => {
  const s = match(),
  p = s.players[0]
  s.rallyTicks = 10
  G.acceptPresses(s, new Set(['KeyW']))
  assert.equal(p.netPressTick, 10)
  for (let tick = 11; tick < 90; tick++) {
    s.rallyTicks = tick
    G.acceptPresses(s, new Set(['KeyW']))
    assert.equal(p.netPressTick, 10)
    assert.equal(p.savePressTick, tick, 'save timing remains independent')
  }
  const f = landingFixture({
    age: 0
  })
  f.p.bouncePressed = true
  G.resolveNetLandings(f.s)
  release(f.s, f.p)
  assert.equal(f.p.bouncePressed, false)
  f.s.rallyTicks = Math.max(f.s.rallyTicks, f.p.netPressReady)
  G.acceptPresses(f.s, new Set([G.PLAYER_KEYS[f.p.id].bounce]))
  assert.equal(f.p.netPressTick, f.s.rallyTicks)
  for (let tier = C.bounce.minTier; tier <= C.bounce.maxTier; tier++) {
    const flight = landingFixture({
      tier,
      age: 0
    })
    G.resolveNetLandings(flight.s)
    release(flight.s, flight.p)
    const last = flight.p.lastLandingTick
    let elapsed = 0
    while (elapsed < 160 && flight.p.lastLandingTick === last) {
      step(flight.s)
      elapsed++
    }
    assert.ok(elapsed >= C.bounce.pressCooldownTicks && elapsed < 160, 'natural flight must outlast cooldown')
  }
})
test('one held bounce press cannot generate repeated perfects', () => {
  const s = match(),
  input = G.createInput()
  input.keydown({
    code: 'KeyW',
    repeat: false
  })
  for (let i = 0; i < 400; i++) {
    input.keydown({
      code: 'KeyW',
      repeat: true
    })
    G.stepSimulation(s, input.take())
  }
  assert.ok(s.stats.bounces[0] > 4)
  assert.ok(s.stats.perfect[0] <= 1)
})
test('shared net propagates an impact, decays, and modifies a second real launch within cap', () => {
  const s = match()
  G.impactNet(s, 400, C.trampoline.impactStrength)
  for (let i = 0; i < 8; i++) G.stepNet(s)
  assert.ok(s.net.d.some(v => Math.abs(v) > .1))
  const influence = G.sampleNetAt(s, 450).vy
  assert.ok(Math.abs(influence) > .001, `wave influence ${influence}`)
  const waved = landingFixture({
    x: 450,
    age: 0
  })
  waved.s.net = plain(s.net)
  const resting = landingFixture({
    x: 450,
    age: 0
  })
  G.resolveNetLandings(waved.s)
  G.resolveNetLandings(resting.s)
  const change = impulse(waved.p) - impulse(resting.p)
  assert.ok(Math.abs(change) > .001)
  assert.ok(Math.abs(change) <= C.bounce.netWaveGainMax + 1e-9)
  for (let i = 0; i < 2000; i++) G.stepNet(s)
  assert.ok(Math.max(...s.net.d.map(Math.abs)) < 1e-6)
  assert.ok(Math.max(...s.net.v.map(Math.abs)) < 1e-6)
})
test('simultaneous net landings use one snapshot; dive impact is stronger but bounded', () => {
  const a = match()
  a.rallyTicks = 100
  for (const p of a.players) Object.assign(p, {
    prevY: 350,
    y: 380,
    vy: 15,
    netPressTick: 100
  })
  const b = plain(a)
  b.players.reverse()
  assert.equal(G.resolveNetLandings(a), 2)
  assert.equal(G.resolveNetLandings(b), 2)
  for (let i = 0; i < a.net.v.length; i++) near(a.net.v[i], b.net.v[i])
  for (const p of a.players) near(impulse(p), impulse(b.players.find(q => q.id === p.id)))
  const normal = landingFixture(),
  dive = landingFixture()
  dive.p.diving = true
  G.resolveNetLandings(normal.s)
  G.resolveNetLandings(dive.s)
  assert.ok(dive.s.net.v.reduce((x,y) => x+y,0) > normal.s.net.v.reduce((x,y) => x+y,0))
  for (const velocity of [-C.trampoline.maxVelocity, C.trampoline.maxVelocity]) {
    const f = landingFixture({
      age: 0
    })
    f.s.net.v.fill(velocity)
    G.resolveNetLandings(f.s)
    near(Math.abs(impulse(f.p) - C.bounce.baseImpulse - 3 * C.bounce.impulsePerTier), C.bounce.netWaveGainMax)
  }
})
test('spring system stays bounded over 12000 representative impact steps', () => {
  const s = match()
  for (let i = 0; i < 12000; i++) {
    if (i % 17 === 0) G.impactNet(s, C.trampoline.left + 25 + (i * 31) % 550, C.trampoline.impactStrength * (i % 2 ? C.trampoline.diveImpactMultiplier : 1))
    G.stepNet(s)
    stableState(s)
  }
})
for (const id of [0, 1]) for (const offset of [-10, 10]) {
  test(`P${id + 1} stomp from ${offset < 0 ? 'left' : 'right'} has correct impulse and rebound`, () => {
    const {
      s,
      a,
      d
    }
    = stompFixture(id, offset)
    assert.equal(G.resolvePlayerContact(s), true)
    assert.equal(s.stats.stomps[id], 1)
    assert.equal(Math.sign(d.vx), -Math.sign(offset))
    assert.ok(Math.abs(d.vx) <= C.stomp.horizontalKnockMax)
    assert.ok(a.vy < 0 && d.vy >= C.stomp.defenderDownVy)
    assert.equal(d.tier, C.bounce.minTier)
    assert.equal(d.protection, C.stomp.protectionTicks)
    G.resolvePlayerContact(s)
    assert.equal(s.stats.stomps[id], 1)
    const oldVx = d.vx
    G.steerAndMove(d, keys(d.id, oldVx > 0 ? 'left' : 'right'))
    assert.equal(Math.sign(d.vx), Math.sign(oldVx))
    assert.ok(Math.abs(d.vx) > C.player.maxVx)
  })
}
test('fast player crossing is swept; exact-center stomp tie mirrors player roles', () => {
  for (const id of [0, 1]) {
    const f = stompFixture(id, 0)
    f.a.prevY = 50
    f.a.y = 350
    f.a.vy = 300
    assert.equal(G.resolvePlayerContact(f.s), true)
    assert.ok(f.a.y + C.player.height <= f.d.y)
    assert.equal(Math.sign(f.d.vx), f.d.id === 0 ? -1 : 1)
  }
})
test('side and upward contacts are not stomps; equal-height contact separates symmetrically', () => {
  const s = match(),
  [a,b] = s.players
  Object.assign(a, {
    prevX: 380,
    x: 400,
    prevY: 220,
    y: 220,
    vx: 20,
    vy: 0
  })
  Object.assign(b, {
    prevX: 420,
    x: 400,
    prevY: 220,
    y: 220,
    vx: -20,
    vy: 0
  })
  assert.equal(G.resolvePlayerContact(s), false)
  near(a.vx, -b.vx)
  near(a.x + b.x, 800)
  assert.ok(Math.abs(a.x-b.x) >= C.player.width)
  assert.equal(s.stats.stomps[0]+s.stats.stomps[1], 0)
  Object.assign(a, {
    prevX: 480,
    x: 480,
    prevY: 300,
    y: 240,
    vx: 0,
    vy: -60
  })
  Object.assign(b, {
    prevX: 480,
    x: 480,
    prevY: 250,
    y: 250,
    vx: 0,
    vy: 0
  })
  assert.equal(G.resolvePlayerContact(s), false)
  assert.equal(s.stats.stomps[0]+s.stats.stomps[1], 0)
})
test('anti-juggle immunity and relative-speed threshold suppress repeated hits', () => {
  const f = stompFixture(0, -10)
  f.d.protection = 8
  assert.equal(G.resolvePlayerContact(f.s), false)
  assert.equal(f.s.stats.stomps[0], 0)
  const slow = stompFixture(0, -10)
  slow.a.y = slow.a.prevY + 2
  slow.a.vy = C.stomp.minRelativeFallSpeed
  slow.d.prevY = slow.d.y = slow.a.prevY + C.player.height + 1
  assert.equal(G.resolvePlayerContact(slow.s), false)
  assert.equal(slow.s.stats.stomps[0], 0)
})
for (const id of [0, 1]) for (const side of [0, 1]) {
  test(`P${id + 1} ${side === 0 ? 'left' : 'right'} save: genuine contact, bounded impulse, one charge, then real net landing`, () => {
    const {
      s,
      p,
      plane
    }
    = bumperFixture(id, side, C.bumper.preContactTicks, true)
    const beforeY = p.y
    assert.equal(G.resolveBumperSave(s,p), true)
    assert.equal(p.recoveryCharge, 0)
    assert.equal(s.stats.saves[id], 1)
    near(p.vx, (side === 0 ? 1 : -1) * C.bumper.inwardLaunchVx)
    near(p.vy, -C.bumper.upwardLaunchVy)
    near(p.y, beforeY)
    near(p.x, plane + (side === 0 ? 1 : -1) * C.player.width/2)
    assert.equal(p.netPressTick, G.NEVER)
    assert.equal(p.savePressTick, G.NEVER)
    const direction = side === 0 ? 'right' : 'left'
    let landed = false
    for (let i = 0; i < 120 && s.phase === 'RALLY'; i++) {
      step(s, keys(id, direction))
      if (p.lastLandingTick > G.NEVER) {
        landed = true
        break
      }
    }
    assert.ok(landed, 'save must actually return to the narrowed net')
    assert.equal(p.recoveryCharge, 0)
    assert.equal(s.stats.saves[id], 1)
    const spent = bumperFixture(id, 1-side, 0)
    spent.p.recoveryCharge = p.recoveryCharge
    assert.equal(G.resolveBumperSave(spent.s, spent.p), false)
  })
}
test('bumper press outside the pre-window misses, no automatic powerful rescue, no contact teleport', () => {
  const f = bumperFixture(0,0,C.bumper.preContactTicks+1)
  assert.equal(G.resolveBumperSave(f.s,f.p), false)
  assert.equal(f.p.recoveryCharge, 1)
  assert.ok(f.p.vy > 0)
  assert.ok(Math.abs(f.p.vx) <= C.bumper.softReboundVx)
  const far = bumperFixture(0,0,0)
  far.p.x = far.p.prevX = 300
  assert.equal(G.resolveBumperSave(far.s,far.p), false)
  assert.equal(far.p.recoveryCharge, 1)
  assert.equal(far.p.x, 300)
  for (let i=0;i<100 && f.s.phase==='RALLY';i++) step(f.s)
  assert.equal(f.s.phase,'POINT_FREEZE')
  assert.equal(f.s.scores[1],1)
})
test('bumper post-contact grace works at the boundary and cannot be refreshed by continuous touch', () => {
  const within = bumperFixture(0,0,null)
  G.resolveBumperSave(within.s,within.p)
  const contactTick = within.p.contact.tick
  within.s.rallyTicks += C.bumper.postContactGraceTicks
  within.p.savePressTick = within.s.rallyTicks
  assert.equal(G.resolveBumperSave(within.s,within.p), true)
  assert.equal(within.s.stats.saves[0],1)
  const late = bumperFixture(1,1,null)
  G.resolveBumperSave(late.s,late.p)
  late.s.rallyTicks += C.bumper.postContactGraceTicks+1
  late.p.savePressTick=late.s.rallyTicks
  assert.equal(G.resolveBumperSave(late.s,late.p),false)
  assert.equal(late.p.recoveryCharge,1)
  assert.equal(late.p.contact,null)
  assert.ok(contactTick >= 0)
})
test('ordinary bounce anti-mash never suppresses an eligible fresh save', () => {
  const f = bumperFixture(0,0,null)
  f.p.netPressReady = f.s.rallyTicks+100
  G.acceptPresses(f.s,new Set(['KeyW']))
  assert.equal(f.p.netPressTick,G.NEVER)
  assert.equal(f.p.savePressTick,f.s.rallyTicks)
  assert.equal(G.resolveBumperSave(f.s,f.p),true)
  assert.equal(f.p.recoveryCharge,0)
})
test('KO requires entire collider below screen and scoring is idempotent', () => {
  const s=match()
  s.players[0].y=C.canvas.height
  assert.equal(G.resolveRallyOutcome(s),false)
  s.players[0].y=C.canvas.height+.001
  assert.equal(G.resolveRallyOutcome(s),true)
  assert.deepEqual(plain(s.scores),[0,1])
  for(let i=0;i<20;i++) assert.equal(G.resolveRallyOutcome(s),false)
  assert.equal(s.stats.points,1)
  const d=match()
  d.players.forEach(p=>p.y=C.canvas.height+1)
  assert.equal(G.resolveRallyOutcome(d),true)
  assert.deepEqual(plain(d.scores),[0,0])
  assert.equal(d.pendingPoint,null)
  assert.equal(d.stats.draws,1)
})
test('point delay resets rally-local state; third point locks match; rematch fully resets', () => {
  const s=match()
  s.players[0].recoveryCharge=0
  s.players[0].tier=5
  s.players[0].protection=10
  s.net.d[12]=20
  s.overdriveInset=40
  s.players[0].y=C.canvas.height+1
  G.resolveRallyOutcome(s)
  const delay=s.pointTicks
  for(let i=0;i<delay-1;i++) step(s)
  assert.equal(s.phase,'POINT_FREEZE')
  step(s)
  assert.equal(s.phase,'RALLY')
  assert.equal(s.rallyTicks,0)
  assert.equal(s.overdriveInset,0)
  assert.equal(s.players[0].recoveryCharge,1)
  assert.equal(s.players[0].tier,C.bounce.startTier)
  assert.equal(s.players[0].protection,0)
  assert.equal(s.players[0].netPressTick,G.NEVER)
  assert.ok(s.net.d.every(v=>v===0))
  assert.deepEqual(plain(s.scores),[0,1])
  s.scores[1]=2
  s.players[0].y=C.canvas.height+1
  G.resolveRallyOutcome(s)
  assert.equal(s.phase,'MATCH_OVER')
  assert.equal(s.winner,1)
  const frozen=JSON.stringify(s)
  for(let i=0;i<100;i++) step(s)
  assert.equal(JSON.stringify(s),frozen)
  G.startMatch(s)
  assert.deepEqual(plain(s.scores),[0,0])
  assert.equal(s.phase,'RALLY')
  assert.equal(s.winner,null)
  assert.equal(s.totalTicks,0)
  assert.equal(s.stats.points,0)
})
test('pause freezes ticks, net, protection and score; clears pending presses', () => {
  const s=match()
  for(let i=0;i<35;i++) step(s)
  s.players[0].netPressTick=s.rallyTicks
  s.players[0].savePressTick=s.rallyTicks
  G.setPaused(s,true)
  assert.equal(s.players[0].netPressTick,G.NEVER)
  const snapshot=JSON.stringify(s)
  for(let i=0;i<200;i++) assert.equal(step(s,{
    KeyD:true
  },['KeyW']),false)
  assert.equal(JSON.stringify(s),snapshot)
  G.setPaused(s,false)
  assert.equal(s.phase,'RALLY')
  const tick=s.rallyTicks
  step(s)
  assert.equal(s.rallyTicks,tick+1)
})
test('render cadence 60/75/120/144 produces identical 600-tick simulation', () => {
  const outputs=[]
  for(const fps of [60,75,120,144]) {
    const s=match()
    let ticks=0
    const driver=G.createFrameDriver(()=>{
      const i=ticks++
      step(s,{},i%59===0?['KeyW','ArrowUp']:[])
    })
    for(let frame=0;frame<=fps*10;frame++) driver.frame(frame*1000/fps,true)
    assert.equal(ticks,600,`${fps} Hz step count`)
    outputs.push(plain(s))
  }
  for(const output of outputs.slice(1))assert.deepEqual(output,outputs[0])
})
test('frame driver discards background catch-up and caps exceptional frame gaps', () => {
  let count=0
  const driver=G.createFrameDriver(()=>count++)
  driver.frame(0,true)
  driver.frame(1000/60,true)
  assert.equal(count,1)
  driver.frame(10000,false)
  driver.reset()
  driver.frame(20000,true)
  assert.equal(count,1)
  driver.frame(21000,true)
  assert.ok(count<=1+C.simulation.maxSteps)
})
test('arena remains stable during long rallies without timed rule changes', () => {
  const s=match()
  const original=plain(G.netBounds(s))
  for(let tick=0;tick<3600;tick++) {
    step(s)
    assert.deepEqual(plain(G.netBounds(s)),original)
    assert.equal(s.events.some(e=>e.type==='WARNING'||e.type==='OVERDRIVE'),false)
  }
  G.resetRally(s)
  assert.deepEqual(plain(G.netBounds(s)),original)
})
test('50 complete movement-driven matches, alternating loser, rematch cleanly', () => {
  const s=match()
  const durations=[]
  for(let game=0;game<50;game++) {
    if(game)G.startMatch(s)
    const loser=game%2,
    held=keys(loser,loser===0?'left':'right')
    let ticks=0
    while(s.phase!=='MATCH_OVER'&&ticks<5000){
      step(s,held)
      stableState(s)
      ticks++
    }
    assert.equal(s.phase,'MATCH_OVER',`game ${game} did not finish`)
    assert.equal(s.winner,1-loser)
    assert.equal(s.scores[1-loser],3)
    assert.equal(s.scores[loser],0)
    assert.equal(s.stats.points,3)
    durations.push(ticks)
  }
  console.log('EVIDENCE scripted complete-match ticks: '+JSON.stringify({
    matches:durations.length,
    min:Math.min(...durations),
    max:Math.max(...durations)
  }))
})
test('12000 full simulation steps stay finite; reduced motion does not alter gameplay', () => {
  const a=match(),
  b=match()
  b.reducedMotion=true
  for(let i=0;i<12000;i++) {
    const pressed=i%70===0?['KeyW','ArrowUp']:[]
    step(a,{},pressed)
    step(b,{},pressed)
    if(a.phase==='MATCH_OVER'){
      G.startMatch(a)
      G.startMatch(b)
    }
    stableState(a)
    stableState(b)
  }
  const normalized=plain(b)
  normalized.reducedMotion=false
  assert.deepEqual(plain(a),normalized)
})
test('rendering is read-only in title, rally, paused, point and match-over phases', () => {
  const ctx=new Proxy({
    measureText:text=>({
      width:String(text).length*10
    }),
    canvas:{
      width:960,
      height:540
    }
  }, {
    get(target,key){
      if(key in target)return target[key]
      return ()=>{}
    },
    set(target,key,value){
      target[key]=value
      return true
    }
  })
  for(const phase of ['TITLE','RALLY','PAUSED','POINT_FREEZE','MATCH_OVER']) {
    const s=match()
    s.phase=phase
    s.winner=0
    s.pendingPoint=1
    const before=JSON.stringify(s)
    G.drawGame(ctx,s,1.5)
    assert.equal(JSON.stringify(s),before,phase+' draw mutated game state')
  }
})
test('missing Web Audio has a harmless silent fallback', () => {
  const audio=G.createAudio()
  assert.doesNotThrow(()=>{
    audio.unlock()
    audio.event({
      type:'BOUNCE',
      tier:2
    })
    audio.setMuted(true)
    audio.setPaused(true)
    audio.setPaused(false)
  })
  assert.equal(audio.inspect().initialized,false)
})
test('diagonal exact-corner contact without horizontal overlap is not a stomp', () => {
  const s = match(),
  [a,b] = s.players
  Object.assign(a, {
    prevX:446,
    prevY:278,
    x:452,
    y:297,
    vx:6,
    vy:19
  })
  Object.assign(b, {
    prevX:480,
    prevY:350,
    x:480,
    y:337,
    vx:0,
    vy:-13
  })
  assert.equal(G.resolvePlayerContact(s), false)
  assert.equal(s.stats.stomps[0]+s.stats.stomps[1], 0)
  assert.equal(a.protection,0)
  assert.equal(b.protection,0)
})
test('resetting the frame driver from inside update discards old accumulated time', () => {
  let updates = 0
  const alphas = []
  const driver = G.createFrameDriver(() => {
    updates++
    if (updates === 1) driver.reset()
  }, alpha => alphas.push(alpha))
  driver.frame(0,true)
  assert.equal(driver.frame(1000/30,true),1)
  assert.equal(updates,1)
  driver.frame(1000/30+1000/60,true)
  assert.equal(updates,1)
  driver.frame(1000/30+2000/60,true)
  assert.equal(updates,2)
  assert.ok(alphas.every(a=>Number.isFinite(a)&&a>=0&&a<=1))
})
test('neutral vertical contact from below separates both bodies without added energy, in either role', () => {
  for (const upperId of [0,1]) {
    const s=match(),
    upper=s.players[upperId],
    lower=s.players[1-upperId]
    Object.assign(upper,{
      prevX:480,
      x:480,
      prevY:250,
      y:249,
      vx:0,
      vy:-1
    })
    Object.assign(lower,{
      prevX:480,
      x:480,
      prevY:300,
      y:281,
      vx:0,
      vy:-19
    })
    const energyBefore=upper.vy*upper.vy+lower.vy*lower.vy
    assert.equal(G.resolvePlayerContact(s),false)
    assert.ok(upper.y+C.player.height<=lower.y+1e-8,'CCD contact must leave bodies separated')
    assert.ok(upper.vy*upper.vy+lower.vy*lower.vy<=energyBefore+1e-8,'neutral contact must not create vertical energy')
    assert.equal(s.stats.stomps[0]+s.stats.stomps[1],0)
    for(let i=0;i<8;i++) {
      step(s)
      assert.ok(upper.y+C.player.height<=lower.y+1e-8,'body separation must persist after neutral contact')
      assert.equal(s.stats.stomps[0]+s.stats.stomps[1],0)
    }
  }
})
function audioRig(options = {}) {
  const contexts = []
  class Parameter {
    constructor() {
      this.value = 0
      this.calls = []
    }
    setValueAtTime(value,time) {
      this.value=value
      this.calls.push(['set',value,time])
    }
    exponentialRampToValueAtTime(value,time) {
      this.value=value
      this.calls.push(['ramp',value,time])
    }
  }
  class Node {
    constructor() {
      this.connections=[]
      this.disconnects=0
    }
    connect(target) {
      this.connections.push(target)
    }
    disconnect() {
      this.disconnects++
      this.connections=[]
    }
  }
  class Gain extends Node {
    constructor(){
      super()
      this.gain=new Parameter()
    }
  }
  class Oscillator extends Node {
    constructor() {
      super()
      this.frequency=new Parameter()
      this.starts=[]
      this.stops=[]
      this.type='sine'
      this.onended=null
    }
    start(time) {
      this.starts.push(time)
      if(options.startFailure)throw new Error('simulated start failure')
    }
    stop(time) {
      this.stops.push(time)
    }
    finish() {
      if(this.onended)this.onended()
    }
  }
  class AudioContext {
    constructor() {
      if(options.constructorFailure)throw new Error('simulated unavailable device')
      this.currentTime=10
      this.state=options.suspended?'suspended':'running'
      this.destination={}
      this.gains=[]
      this.oscillators=[]
      this.resumes=0
      contexts.push(this)
    }
    createGain(){
      const gain=new Gain()
      this.gains.push(gain)
      return gain
    }
    createOscillator(){
      if(options.oscillatorFailure)throw new Error('simulated node failure')
      const oscillator=new Oscillator()
      this.oscillators.push(oscillator)
      return oscillator
    }
    resume(){
      this.resumes++
      if(options.resumeReject)return Promise.reject(new Error('simulated blocked policy'))
      this.state='running'
      return Promise.resolve()
    }
  }
  const context={
    __SNAPBACK_TEST__:true,
    AudioContext
  }
  vm.createContext(context)
  vm.runInContext(inline[1],context,{
    filename:'index.html audio fixture'
  })
  return {
    audio:context.SnapbackTest.createAudio(),
    contexts,
    options
  }
}
test('audio context is lazy, constructor failure is silent, and rejected resume recovers on later unlock', async () => {
  const unavailable=audioRig({
    constructorFailure:true
  })
  assert.equal(unavailable.contexts.length,0)
  assert.doesNotThrow(()=>unavailable.audio.unlock())
  assert.equal(unavailable.audio.inspect().initialized,false)
  assert.doesNotThrow(()=>unavailable.audio.event({
    type:'STOMP'
  }))
  const rig=audioRig({
    suspended:true,
    resumeReject:true
  })
  rig.audio.event({
    type:'BOUNCE',
    tier:2
  })
  assert.equal(rig.contexts.length,0,'events must not create an AudioContext')
  rig.audio.unlock()
  await Promise.resolve()
  await Promise.resolve()
  assert.equal(rig.contexts.length,1)
  assert.equal(rig.contexts[0].resumes,1)
  assert.equal(rig.audio.inspect().state,'suspended')
  rig.audio.event({
    type:'STOMP'
  })
  assert.equal(rig.audio.inspect().voices,0)
  rig.options.resumeReject=false
  rig.audio.unlock()
  await Promise.resolve()
  rig.audio.event({
    type:'BOUNCE',
    tier:2
  })
  assert.equal(rig.contexts.length,1)
  assert.ok(rig.audio.inspect().voices>0)
})
test('six required synthesized effects have distinct scheduled signatures and release nodes', () => {
  const rig=audioRig()
  rig.audio.unlock()
  const context=rig.contexts[0],
  signatures=[]
  for(const type of ['BOUNCE','PERFECT','STOMP','SNAPBACK','POINT','VICTORY']) {
    const startIndex=context.oscillators.length
    rig.audio.event({
      type,
      tier:2
    })
    const notes=context.oscillators.slice(startIndex)
    assert.ok(notes.length>0,type+' scheduled no sound')
    signatures.push(JSON.stringify(notes.map(note=>({
      type:note.type,
      frequency:note.frequency.calls,
      start:note.starts,
      stop:note.stops
    }))))
    for(const note of notes) {
      assert.ok(Number.isFinite(note.starts[0]))
      assert.ok(note.stops[0]>note.starts[0])
      note.finish()
      assert.ok(note.disconnects>0)
    }
    assert.equal(rig.audio.inspect().voices,0)
  }
  assert.equal(new Set(signatures).size,6)
  assert.ok(context.gains.slice(1).every(gain=>gain.disconnects>0),'every voice gain must disconnect on natural end')
})
test('audio cap bounds voices; natural ends free capacity; mute and pause stop/disconnect all nodes', () => {
  const rig=audioRig()
  rig.audio.unlock()
  const context=rig.contexts[0],
  master=context.gains[0]
  for(let i=0;i<C.audio.maxVoices*2;i++)rig.audio.event({
    type:'PERFECT'
  })
  assert.equal(rig.audio.inspect().voices,C.audio.maxVoices)
  assert.equal(context.oscillators.length,C.audio.maxVoices)
  for(const note of context.oscillators)note.finish()
  assert.equal(rig.audio.inspect().voices,0)
  rig.audio.event({
    type:'BOUNCE',
    tier:2
  })
  assert.equal(rig.audio.inspect().voices,1)
  rig.audio.setMuted(true)
  assert.equal(rig.audio.inspect().voices,0)
  assert.equal(master.gain.value,0)
  const last=context.oscillators.at(-1)
  assert.equal(last.stops.at(-1),undefined,'mute must stop scheduled voice immediately')
  assert.ok(last.disconnects>0)
  assert.ok(context.gains.at(-1).disconnects>0)
  const count=context.oscillators.length
  rig.audio.event({
    type:'VICTORY'
  })
  assert.equal(context.oscillators.length,count)
  rig.audio.setMuted(false)
  near(master.gain.value,C.audio.masterGain)
  rig.audio.event({
    type:'STOMP'
  })
  assert.ok(rig.audio.inspect().voices>0)
  rig.audio.setPaused(true)
  assert.equal(rig.audio.inspect().voices,0)
  assert.equal(master.gain.value,0)
  assert.ok(context.oscillators.every(note=>note.disconnects>0))
  assert.ok(context.gains.slice(1).every(gain=>gain.disconnects>0))
  rig.audio.event({
    type:'SNAPBACK'
  })
  assert.equal(rig.audio.inspect().voices,0)
  rig.audio.setMuted(true)
  rig.audio.setPaused(false)
  assert.equal(master.gain.value,0,'unpausing must not undo mute')
})
test('partial Web Audio node/start failure releases connected nodes and voice capacity', () => {
  const startFailure=audioRig({
    startFailure:true
  })
  startFailure.audio.unlock()
  assert.doesNotThrow(()=>startFailure.audio.event({
    type:'VICTORY'
  }))
  assert.equal(startFailure.audio.inspect().voices,0)
  const context=startFailure.contexts[0]
  assert.ok(context.oscillators.every(node=>node.disconnects>0))
  assert.ok(context.gains.slice(1).every(node=>node.disconnects>0))
  const creationFailure=audioRig({
    oscillatorFailure:true
  })
  creationFailure.audio.unlock()
  assert.doesNotThrow(()=>creationFailure.audio.event({
    type:'SNAPBACK'
  }))
  assert.equal(creationFailure.audio.inspect().voices,0)
})
function mirrorInput(input) {
  const map={
    KeyA:'ArrowRight',
    KeyD:'ArrowLeft',
    KeyW:'ArrowUp',
    KeyS:'ArrowDown',
    ArrowLeft:'KeyD',
    ArrowRight:'KeyA',
    ArrowUp:'KeyW',
    ArrowDown:'KeyS'
  }
  return {
    held:Object.fromEntries(Object.entries(input.held).map(([key,value])=>[map[key],value])),
    pressed:input.pressed.map(key=>map[key])
  }
}
function generator(seed) {
  let state=seed>>>0
  return ()=>{
    state=(Math.imul(state,1664525)+1013904223)>>>0
    return state/4294967296
  }
}
test('mirrored role-swapped input traces preserve collision, scoring and net symmetry', () => {
  let maximumError=0,
  totalStomps=0,
  totalSaves=0,
  totalPoints=0
  for(let seed=1;seed<=20;seed++) {
    const a=match(),
    b=match(),
    random=generator(seed)
    let held={}
    for(let tick=0;tick<1200;tick++) {
      if(tick%9===0) {
        held={}
        for(let id=0;id<2;id++) {
          const direction=Math.floor(random()*3)-1
          if(direction)held[G.PLAYER_KEYS[id][direction<0?'left':'right']]=true
          if(random()<.4)held[G.PLAYER_KEYS[id].dive]=true
        }
      }
      const pressed=[]
      for(let id=0;id<2;id++)if(random()<.055)pressed.push(G.PLAYER_KEYS[id].bounce)
      const original={
        held,
        pressed
      },
      mirrored=mirrorInput(original)
      G.stepSimulation(a,original)
      G.stepSimulation(b,mirrored)
      assert.equal(a.phase,b.phase,`seed ${seed}, tick ${tick}: phase`)
      assert.equal(a.scores[0],b.scores[1])
      assert.equal(a.scores[1],b.scores[0])
      for(let id=0;id<2;id++) {
        const p=a.players[id],
        q=b.players[1-id]
        for(const error of [Math.abs(p.x+q.x-C.canvas.width),Math.abs(p.y-q.y),Math.abs(p.vx+q.vx),Math.abs(p.vy-q.vy)]) {
          maximumError=Math.max(maximumError,error)
          assert.ok(error<1e-6,`seed ${seed}, tick ${tick}, player ${id}: mirrored error ${error}`)
        }
        assert.equal(p.tier,q.tier)
        assert.equal(p.recoveryCharge,q.recoveryCharge)
        assert.equal(p.protection,q.protection)
      }
      for(let i=0;i<a.net.d.length;i++)near(a.net.d[i],b.net.d[a.net.d.length-1-i],1e-6)
      totalStomps+=a.events.filter(e=>e.type==='STOMP').length
      totalSaves+=a.events.filter(e=>e.type==='SNAPBACK').length
      totalPoints+=a.events.filter(e=>e.type==='POINT').length
      if(a.phase==='MATCH_OVER'){
        G.startMatch(a)
        G.startMatch(b)
      }
    }
  }
  console.log('EVIDENCE mirrored deterministic fuzz: '+JSON.stringify({
    traces:20,
    stepsPerTrace:1200,
    maximumError,
    totalStomps,
    totalSaves,
    totalPoints
  }))
})
test('measure actual bounce apex and maximum-wave top visibility without claiming human tuning', () => {
  const observations=[]
  for(let tier=C.bounce.minTier;tier<=C.bounce.maxTier;tier++) {
    const f=landingFixture({
      tier:tier>C.bounce.minTier?tier-1:C.bounce.minTier,
      age:tier>C.bounce.minTier?0:null
    })
    G.resolveNetLandings(f.s)
    const launch=release(f.s,f.p),
    last=f.p.lastLandingTick
    let minimumTop=f.p.y,
    clippedTicks=0,
    flightTicks=0,
    hitCeiling=false
    while(flightTicks<180) {
      step(f.s)
      flightTicks++
      minimumTop=Math.min(minimumTop,f.p.y)
      if(f.p.y<0)clippedTicks++
      if(f.p.y<=C.player.ceilingY)hitCeiling=true
      if(f.p.lastLandingTick!==last)break
    }
    assert.ok(flightTicks<180,'natural flight must land again')
    observations.push({
      tier,
      launch,
      minimumTop,
      clippedTicks,
      flightTicks,
      hitCeiling
    })
  }
  const max=landingFixture({
    tier:C.bounce.maxTier-1,
    age:0
  })
  max.s.net.v.fill(-C.trampoline.maxVelocity)
  G.resolveNetLandings(max.s)
  release(max.s,max.p)
  const last=max.p.lastLandingTick
  const maximumWave={
    tier:max.p.tier,
    launch:-max.p.vy,
    minimumTop:max.p.y,
    clippedTicks:0,
    flightTicks:0,
    hitCeiling:false
  }
  while(maximumWave.flightTicks<180) {
    step(max.s)
    maximumWave.flightTicks++
    maximumWave.minimumTop=Math.min(maximumWave.minimumTop,max.p.y)
    if(max.p.y<0)maximumWave.clippedTicks++
    if(max.p.y<=C.player.ceilingY)maximumWave.hitCeiling=true
    if(max.p.lastLandingTick!==last)break
  }
  assert.ok(maximumWave.flightTicks<180)
  assert.equal(maximumWave.clippedTicks,0,'strongest legal bounce stays visible')
  assert.equal(maximumWave.hitCeiling,false,'legal bounce must not need defensive ceiling clamp')
  console.log('EVIDENCE deterministic bounce apex metrics: '+JSON.stringify({
    restingNet:observations,
    maximumWave
  }))
})
test('opening starts in motion and permits an aerial meeting almost immediately', () => {
  const idle = match()
  const start = idle.players.map(p => p.y)
  assert.ok(idle.players.every(p => p.vy < 0))
  step(idle)
  assert.ok(idle.players.every((p, id) => p.y < start[id]))
  let firstBounce = null
  for (let tick = 2; tick <= 60; tick++) {
    step(idle)
    if (idle.stats.bounces.every(n => n > 0)) {
      firstBounce = tick
      break
    }
  }
  assert.ok(firstBounce !== null && firstBounce <= 45, `first contacts at ${firstBounce}`)
  const inward = match()
  let firstContact = null
  for (let tick = 1; tick <= 60; tick++) {
    step(inward, {
      KeyD: true,
      ArrowLeft: true
    })
    if (Math.abs(inward.players[0].x - inward.players[1].x) <= C.player.width + C.collision.epsilon * 2) {
      firstContact = tick
      break
    }
  }
  assert.ok(firstContact !== null && firstContact <= 20, `first aerial contact at ${firstContact}`)
  console.log('EVIDENCE opening fixed ticks: ' + JSON.stringify({
    firstBounce,
    firstContact
  }))
})
test('air steering accelerates promptly, reverses progressively, and settles after release', () => {
  for (const id of [0, 1]) {
    const p = G.createPlayer(id)
    const direction = id === 0 ? 'right' : 'left'
    const opposite = id === 0 ? 'left' : 'right'
    const sign = id === 0 ? 1 : -1
    for (let tick = 0; tick < 15; tick++) G.steerAndMove(p, keys(id, direction))
    near(p.vx, sign * C.player.maxVx)
    const old = p.vx
    G.steerAndMove(p, keys(id, opposite))
    assert.equal(Math.sign(p.vx), Math.sign(old), 'reversal must preserve a brief sense of momentum')
    assert.ok(Math.abs(p.vx) < Math.abs(old))
    let reverseTicks = 1
    while (Math.sign(p.vx) === sign && reverseTicks < 16) {
      G.steerAndMove(p, keys(id, opposite))
      reverseTicks++
    }
    assert.ok(reverseTicks <= 8, `reverse took ${reverseTicks} ticks`)
    p.vx = sign * C.player.maxVx
    for (let tick = 0; tick < 8; tick++) G.steerAndMove(p, {})
    assert.ok(Math.abs(p.vx) < C.player.maxVx * .3, 'neutral input must not leave a long slippery drift')
  }
})
test('landing loads the real mesh briefly before releasing the stored bounce', () => {
  for (const perfect of [false, true]) {
    const f = landingFixture({
      age: perfect ? 0 : null
    })
    G.resolveNetLandings(f.s)
    const saved = plain(f.p.compression)
    assert.ok(saved && saved.duration >= 2 && saved.duration <= 6)
    assert.equal(saved.perfect, perfect)
    const startX = f.p.x
    let attachedTicks = 0
    let maximumDepth = 0
    while (f.p.compression) {
      step(f.s, {
        KeyD: true
      })
      maximumDepth = Math.max(maximumDepth, G.sampleNetAt(f.s, f.p.x).y - C.trampoline.equilibriumY)
      if (f.p.compression) {
        near(f.p.y + C.player.height, G.sampleNetAt(f.s, f.p.x).y - C.collision.epsilon)
        near(f.p.compression.launch, saved.launch)
        attachedTicks++
      }
    }
    assert.ok(attachedTicks >= 1 && attachedTicks < 6)
    assert.ok(maximumDepth > .1, 'landing must visibly load the same surface used by collision')
    assert.ok(f.p.x > startX, 'steering remains available during compression')
    near(f.p.vy, -saved.launch)
    assert.ok(f.s.events.some(e => e.type === 'RELEASE' && e.id === f.p.id && e.perfect === perfect))
  }
})
test('compression cannot award a retroactive perfect or carry a player past the edge', () => {
  const late = landingFixture()
  G.resolveNetLandings(late.s)
  assert.equal(late.p.compression.perfect, false)
  const launch = late.p.compression.launch
  step(late.s, {}, ['KeyW'])
  assert.equal(late.s.stats.perfect[0], 0)
  if (late.p.compression) near(late.p.compression.launch, launch)
  release(late.s, late.p)
  const edge = landingFixture()
  G.resolveNetLandings(edge.s)
  edge.p.x = edge.p.prevX = C.trampoline.left - C.player.width / 2 + C.collision.epsilon
  edge.p.vx = -C.player.maxVx
  step(edge.s, {
    KeyA: true
  })
  assert.equal(edge.p.compression, null)
  assert.ok(edge.p.vy >= 0, 'stepping beyond the visible edge must fall instead of producing an air launch')
  assert.equal(edge.s.events.some(e => e.type === 'RELEASE' && e.id === edge.p.id), false)
})
test('a stomp interrupts loaded compression and protection prevents repeated awards', () => {
  for (const id of [0, 1]) {
    const f = stompFixture(id, -10)
    f.d.compression = {
      remaining: 3,
      duration: 3,
      launch: 15,
      perfect: true
    }
    assert.equal(G.resolvePlayerContact(f.s), true)
    assert.equal(f.d.compression, null)
    for (let tick = 1; tick < C.stomp.protectionTicks; tick++) {
      f.d.protection = C.stomp.protectionTicks - tick
      Object.assign(f.a, {
        prevX: 470,
        x: 470,
        prevY: 200,
        y: 219,
        vy: 19
      })
      Object.assign(f.d, {
        prevX: 480,
        x: 480,
        prevY: 250,
        y: 250,
        vy: 0
      })
      G.resolvePlayerContact(f.s)
    }
    assert.equal(f.s.stats.stomps[id], 1)
  }
})
test('save timing and recovery trajectory work at varied speeds for both players and bumpers', () => {
  let routes = 0
  for (const id of [0, 1]) for (const side of [0, 1]) for (const speed of [3, 7, 11, 19]) {
    const f = bumperFixture(id, side, 0)
    const outward = side === 0 ? -1 : 1
    f.p.prevX = f.plane - outward * (C.player.width / 2 + speed / 2)
    f.p.x = f.p.prevX + outward * speed
    f.p.vx = outward * speed
    f.p.prevY = f.p.y = 350
    assert.equal(G.resolveBumperSave(f.s, f.p), true, `role ${id}, side ${side}, speed ${speed}`)
    const held = keys(id, side === 0 ? 'right' : 'left')
    let landed = false
    for (let tick = 0; tick < 120 && f.s.phase === 'RALLY'; tick++) {
      step(f.s, held)
      if (f.p.lastLandingTick > G.NEVER) {
        landed = true
        break
      }
    }
    assert.ok(landed, `recovery route failed at role ${id}, side ${side}, speed ${speed}`)
    assert.equal(f.p.recoveryCharge, 0)
    assert.equal(f.s.stats.saves[id], 1)
    routes++
  }
  console.log('EVIDENCE varied-speed save-to-net routes: ' + routes)
})
test('no gameplay action draws text and the active HUD contains only score numerals', () => {
  const words = []
  const ctx = new Proxy({
    measureText: text => ({
      width: String(text).length * 10
    }),
    canvas: {
      width: 960,
      height: 540
    },
    fillText: text => words.push(String(text)),
    strokeText: text => words.push(String(text))
  }, {
    get(target, key) {
      return key in target ? target[key] : () => {}
    },
    set(target, key, value) {
      target[key] = value
      return true
    }
  })
  for (const type of ['BOUNCE', 'PERFECT', 'STOMP', 'SNAPBACK', 'BUMPER']) {
    const s = match()
    s.effects = [{
      type,
      id: 0,
      x: 450,
      y: 350,
      direction: 1,
      tick: s.totalTicks
    }]
    words.length = 0
    G.drawGame(ctx, s, 1)
    assert.ok(words.every(text => /^[0-3]$/.test(text)), `${type} drew non-score text: ${words.join(', ')}`)
    assert.ok(words.length >= 2 && words.length <= 4, 'only the compact scoreboard needs text')
  }
})
