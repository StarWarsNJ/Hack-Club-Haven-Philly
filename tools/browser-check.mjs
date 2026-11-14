// Optional development-only browser checks. Runtime remains one independent HTML file.
// Uses installed desktop Chrome/Edge headless CLI; no package, CDP, or UI automation.
import { readFile, writeFile, mkdir } from 'node:fs/promises';
import { existsSync } from 'node:fs';
import { spawn } from 'node:child_process';
import { resolve, join } from 'node:path';
import { pathToFileURL } from 'node:url';
import { createServer } from 'node:http';
import { createHash } from 'node:crypto';
const root = resolve(import.meta.dirname, '..');
const edge = process.argv.includes('--edge');
const out = join(root, '.godot/snapback_browser', edge ? 'edge' : '');
await mkdir(out, { recursive: true });
const candidates = [process.env.SNAPBACK_BROWSER, ...(edge ? ['C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe'] : ['C:/Program Files/Google/Chrome/Application/chrome.exe','C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe'])].filter(Boolean);
const browser = candidates.find(existsSync);
if (!browser) throw new Error('No installed supported browser found; set SNAPBACK_BROWSER to an existing Chrome/Edge executable.');
const original = await readFile(join(root, 'index.html'), 'utf8');
const quick = process.argv.includes('--quick');
const selectedScenes=process.argv.find(arg=>arg.startsWith('--only-captures='));
const onlyCaptures=selectedScenes?selectedScenes.substring(selectedScenes.indexOf('=')+1).split(','):null;
const sourceSha256 = createHash('sha256').update(original).digest('hex');
const passiveErrors = `<script>(function(){window.__qaErrors=[];window.__qaWarnings=[];addEventListener('error',e=>window.__qaErrors.push(e.message));addEventListener('unhandledrejection',e=>window.__qaErrors.push(String(e.reason)));const err=console.error.bind(console),warn=console.warn.bind(console);console.error=(...a)=>{window.__qaErrors.push(a.join(' '));err(...a);};console.warn=(...a)=>{window.__qaWarnings.push(a.join(' '));warn(...a);};})();</script>`;
const prefix = `<script>
window.__SNAPBACK_TEST__=true;
window.__qaErrors=[];window.__qaWarnings=[];
window.addEventListener('error',e=>window.__qaErrors.push(e.message));
window.addEventListener('unhandledrejection',e=>window.__qaErrors.push(String(e.reason)));
const originalError=console.error.bind(console);console.error=(...a)=>{window.__qaErrors.push(a.join(' '));originalError(...a);};
const originalWarn=console.warn.bind(console);console.warn=(...a)=>{window.__qaWarnings.push(a.join(' '));originalWarn(...a);};
// Test fixtures drive the real fixed-step scheduler without wall-clock races.
window.requestAnimationFrame=()=>0;
</script>`;
const suite = String.raw`
const api=window.SnapbackTest,s=api.getState(),results=[];
function assert(value,message){if(!value)throw new Error(message);}
function test(name,fn){try{fn();results.push({name,passed:true});}catch(e){results.push({name,passed:false,error:e.message});}}
function key(code,down=true,repeat=false){const e=new KeyboardEvent(down?'keydown':'keyup',{code,key:code,bubbles:true,cancelable:true,repeat});window.dispatchEvent(e);return e;}
function release(){for(const code of Object.keys(api.input.held))key(code,false);}
function begin(){release();api.startMatch(s);api.input.clear();api.driver.reset();}
function ticks(n){api.driver.reset();api.driver.frame(0);for(let i=1;i<=n;i++)api.driver.frame(i*1000/60);}
test('real local document and Canvas startup',()=>{assert(s.phase==='TITLE','expected title');assert(document.getElementById('game').getContext('2d'),'Canvas unavailable');assert(!window.__qaErrors.length,'startup script error');});
test('Space key starts once; title input does not leak',()=>{key('Space');assert(s.phase==='RALLY','Space did not start');assert(!Object.keys(api.input.held).length,'start key leaked');assert(s.players.every(p=>p.netPressTick===api.NEVER),'bounce buffer leaked');key('Space',false);});
test('simultaneous opposing player movement through DOM listeners',()=>{begin();key('KeyA');key('ArrowRight');ticks(10);assert(s.players[0].x<api.CONFIG.player.spawnX[0],'P1 did not move');assert(s.players[1].x>api.CONFIG.player.spawnX[1],'P2 did not move');release();});
test('both players dive through their own held keys',()=>{begin();key('KeyS');key('ArrowDown');ticks(10);assert(s.players.every(p=>p.diving&&p.vy>api.CONFIG.player.gravity*10),'dive not applied independently');release();});
test('bounce actions are fresh edges; repeats and holds suppressed',()=>{begin();key('KeyW');key('ArrowUp');const first=api.input.take();assert(first.pressed.includes('KeyW')&&first.pressed.includes('ArrowUp'),'missing simultaneous edges');key('KeyW',true,true);key('ArrowUp',true,true);assert(api.input.take().pressed.length===0,'OS repeat created an edge');key('KeyW',false);key('KeyW');assert(api.input.take().pressed.includes('KeyW'),'new press missing after release');release();});
test('recognized keys prevent page scrolling',()=>{for(const code of ['Space','ArrowLeft','ArrowRight','ArrowUp','ArrowDown']){assert(key(code).defaultPrevented,code+' scroll was not prevented');key(code,false);}assert(scrollX===0&&scrollY===0,'page scrolled');});
test('Escape pause freezes all authoritative state and safely resumes',()=>{begin();ticks(10);key('KeyA');key('KeyW');key('Escape');key('Escape',false);assert(s.phase==='PAUSED','not paused');assert(Object.keys(api.input.held).length===0,'held inputs stuck after pause');const before=JSON.stringify(s);ticks(30);assert(JSON.stringify(s)===before,'paused simulation advanced');key('Escape');key('Escape',false);assert(s.phase==='RALLY','did not resume');assert(s.players.every(p=>p.netPressTick===api.NEVER),'stale bounce after resume');});
test('blur automatically pauses and clears held controls',()=>{begin();key('KeyD');key('ArrowLeft');window.dispatchEvent(new Event('blur'));assert(s.phase==='PAUSED','blur did not pause');assert(Object.keys(api.input.held).length===0,'blur left held inputs');key('Escape');key('Escape',false);});
test('visibility loss automatically pauses and clears input',()=>{begin();key('KeyD');Object.defineProperty(document,'hidden',{configurable:true,value:true});document.dispatchEvent(new Event('visibilitychange'));delete document.hidden;assert(s.phase==='PAUSED','hidden document did not pause');assert(Object.keys(api.input.held).length===0,'hidden document left input');key('Escape');key('Escape',false);});
test('focused DOM buttons retain native Space and Enter key defaults',()=>{begin();const button=document.getElementById('sound');button.focus();for(const code of ['Space','Enter'])for(const type of ['keydown','keyup']){const e=new KeyboardEvent(type,{code,bubbles:true,cancelable:true});button.dispatchEvent(e);assert(!e.defaultPrevented,type+' '+code+' blocked on focused button');}assert(s.phase==='RALLY','focused button keys changed game phase');assert(!api.input.held.Space&&!api.input.held.Enter,'focused button input leaked into held map');document.getElementById('game').focus();});
test('pause and winner aria-live status update immediately',()=>{begin();key('Escape');assert(document.getElementById('status').textContent.includes('Paused'),'pause live region lagged until next frame');key('Escape',false);key('Escape');key('Escape',false);s.scores=[0,2];s.players[0].y=api.CONFIG.canvas.height+1;ticks(1);assert(s.phase==='MATCH_OVER','winner fixture failed');assert(document.getElementById('status').textContent.includes('Mint wins'),'winner live region not current on scoring tick');});
test('M and V toggles ignore OS repeat and expose status',()=>{begin();const mute=s.muted,motion=s.reducedMotion;key('KeyM');key('KeyM',true,true);assert(s.muted!==mute,'mute did not toggle exactly once');assert(document.getElementById('sound').getAttribute('aria-pressed')===String(s.muted),'mute accessibility state');key('KeyM',false);key('KeyV');key('KeyV',true,true);assert(s.reducedMotion!==motion,'reduced motion repeat toggle');assert(document.getElementById('motion').getAttribute('aria-pressed')===String(s.reducedMotion),'motion accessibility state');key('KeyV',false);});
test('point transition resets runtime held inputs and abilities',()=>{begin();key('KeyA');s.players[0].y=api.CONFIG.canvas.height+1;ticks(1);assert(s.phase==='POINT_FREEZE','point phase missing');const index=s.rallyIndex;ticks(Math.ceil(api.CONFIG.scoring.pointPresentationSeconds*api.CONFIG.simulation.hz)+2);assert(s.phase==='RALLY'&&s.rallyIndex===index+1,'next rally did not start');assert(Object.keys(api.input.held).length===0,'held input carried into next rally');assert(s.players.every(p=>p.recoveryCharge===1&&p.tier===api.CONFIG.bounce.startTier),'ability reset incomplete');});
test('complete real scoring loop and Enter rematch',()=>{begin();for(let i=0;i<3;i++){s.players[0].y=api.CONFIG.canvas.height+1;ticks(1);if(i<2)ticks(Math.ceil(api.CONFIG.scoring.pointPresentationSeconds*api.CONFIG.simulation.hz)+2);}assert(s.phase==='MATCH_OVER'&&s.scores[1]===3,'match winner missing');const scores=JSON.stringify(s.scores);ticks(60);assert(JSON.stringify(s.scores)===scores,'score changed after winner');key('Enter');key('Enter',false);assert(s.phase==='RALLY'&&s.scores.every(n=>n===0),'Enter rematch did not reset');assert(s.players.every(p=>p.recoveryCharge===1),'rematch charge reset');});
test('rendering is pure',()=>{begin();ticks(20);const before=JSON.stringify(s);api.render();assert(JSON.stringify(s)===before,'render mutated simulation');});
test('synthetic browser input cannot autoplay Web Audio',()=>{assert(!api.audio.inspect().initialized,'untrusted synthetic input initialized audio');});
test('uniform responsive Canvas and no overflow',()=>{window.dispatchEvent(new Event('resize'));const r=document.getElementById('game').getBoundingClientRect();assert(Math.abs(r.width/r.height-960/540)<.002,'aspect ratio distorted');assert(r.width<=innerWidth+.5&&r.height<=innerHeight+.5,'Canvas exceeds viewport');assert(document.documentElement.scrollHeight<=innerHeight&&document.documentElement.scrollWidth<=innerWidth,'page overflow');});
release();api.pause(true);
const payload={results,errors:window.__qaErrors,warnings:window.__qaWarnings,userAgent:navigator.userAgent,viewport:{width:innerWidth,height:innerHeight,dpr:devicePixelRatio},physicalKeyboard:'NOT RUN: synthetic DOM input only',humanPlaytest:'NOT RUN',audibility:'NOT RUN'};
const result=document.createElement('pre');result.id='qa-result';result.hidden=true;result.textContent=JSON.stringify(payload);document.body.appendChild(result);
`;
const fixture = String.raw`
const api=window.SnapbackTest,s=api.getState();
function key(code){window.dispatchEvent(new KeyboardEvent('keydown',{code,bubbles:true,cancelable:true}));window.dispatchEvent(new KeyboardEvent('keyup',{code,bubbles:true,cancelable:true}));}
function step(){api.driver.reset();api.driver.frame(0);api.driver.frame(1000/60);}
const scene=SCENE;
if(scene!=='title')key('Space');
if(scene==='rally')for(let i=0;i<20;i++)step();
if(scene==='perfect'){s.players[0].y=368;s.players[0].vy=4;key('KeyW');step();}
if(scene==='stomp'){Object.assign(s.players[0],{x:475,y:200,vy:15});Object.assign(s.players[1],{x:485,y:250,vy:0});step();}
if(scene==='save'||scene==='reduced'){if(scene==='reduced')key('KeyV');Object.assign(s.players[0],{x:110,y:330,vx:-9,vy:4});key('KeyW');step();}
if(scene==='save_ready'){Object.assign(s.players[0],{x:145,y:300,vx:-7,vy:4});step();}
if(scene==='wave'){Object.assign(s.players[0],{x:370,y:368,vy:12});window.dispatchEvent(new KeyboardEvent('keydown',{code:'KeyS',bubbles:true,cancelable:true}));step();window.dispatchEvent(new KeyboardEvent('keyup',{code:'KeyS',bubbles:true,cancelable:true}));for(let i=0;i<5;i++)step();}
if(scene==='overdrive'){s.rallyTicks=Math.round((api.CONFIG.overdrive.beginSeconds+api.CONFIG.overdrive.shrinkSeconds/2)*60);step();}
if(scene==='high'){s.players[0].tier=4;s.players[0].y=368;s.players[0].vy=4;const n=api.sampleNetAt(s,s.players[0].x);s.net.v[n.i]=-api.CONFIG.trampoline.maxVelocity;s.net.v[n.i+1]=-api.CONFIG.trampoline.maxVelocity;key('KeyW');step();let guard=0;while(s.players[0].vy<0&&guard++<100)step();}
if(scene==='pause'){for(let i=0;i<15;i++)step();key('Escape');}
if(scene==='point'){s.players[0].y=541;step();}
if(scene==='winner'){s.scores=[2,0];s.players[1].y=541;step();}
api.render();
const payload={scenario:scene,phase:s.phase,events:s.events,errors:window.__qaErrors,warnings:window.__qaWarnings,viewport:{width:innerWidth,height:innerHeight},scores:s.scores,syntheticFixture:true,reducedMotion:s.reducedMotion,players:s.players.map(p=>({x:p.x,y:p.y,vy:p.vy,tier:p.tier,recoveryCharge:p.recoveryCharge})),netMaxDeflection:Math.max(...s.net.d.map(Math.abs)),effectTypes:s.effects.map(e=>e.type),stats:s.stats,canvasPng:document.getElementById('game').toDataURL('image/png')};
const result=document.createElement('pre');result.id='qa-result';result.hidden=true;result.textContent=JSON.stringify(payload);document.body.appendChild(result);
`;
function makePage(script) { return original.replace('<script>', prefix+'\n<script>').replace('</body>', '<script>\n'+script+'\n</script></body>'); }
function decode(text) { return text.replace(/&lt;/g,'<').replace(/&gt;/g,'>').replace(/&amp;/g,'&').replace(/&quot;/g,'"'); }
let windowFrameCorrection=[0,0];
async function runBrowser(name, url, size, screenshot=true) {
 const profile=join(out,'profile_'+name+'_'+Date.now());
 const args=['--headless=new','--no-first-run','--no-default-browser-check','--disable-background-networking','--disable-component-update','--disable-sync','--disable-extensions','--disable-gpu','--mute-audio','--hide-scrollbars','--force-device-scale-factor=1','--window-size='+size.map((v,i)=>v+windowFrameCorrection[i]).join(','),'--user-data-dir='+profile,'--virtual-time-budget=350','--dump-dom'];
 if(screenshot)args.push('--screenshot='+join(out,name+'.png'));
 args.push(url);
 const started=Date.now();
 const result=await new Promise(resolveResult=>{
  const child=spawn(browser,args,{cwd:root,windowsHide:true});let stdout='',stderr='',timedOut=false;let settled=false;
  const timer=setTimeout(()=>{timedOut=true;const killer=spawn('taskkill.exe',['/PID',String(child.pid),'/T','/F'],{windowsHide:true});killer.on('error',()=>{});},60000);
  child.stdout.on('data',chunk=>stdout+=chunk);child.stderr.on('data',chunk=>stderr+=chunk);
  child.on('error',error=>{if(settled)return;settled=true;clearTimeout(timer);resolveResult({exitCode:null,stdout,stderr,error:String(error),timedOut});});
  child.on('close',exitCode=>{if(settled)return;settled=true;clearTimeout(timer);resolveResult({exitCode,stdout,stderr,timedOut});});
 });
 await writeFile(join(out,name+'.html'),result.stdout);
 await writeFile(join(out,name+'.stderr.txt'),result.stderr);
 const match=result.stdout.match(/<pre id="qa-result" hidden="">([\s\S]*?)<\/pre>/);
 let evidence=null;if(match){try{evidence=JSON.parse(decode(match[1]));}catch(error){result.parseError=String(error);}}
 if(evidence?.canvasPng){const data=evidence.canvasPng;delete evidence.canvasPng;if(data.startsWith('data:image/png;base64,')){await writeFile(join(out,name+'.canvas.png'),Buffer.from(data.substring(data.indexOf(',')+1),'base64'));evidence.canvasArtifact=name+'.canvas.png';}}
 return {name,url,size,elapsedSeconds:(Date.now()-started)/1000,exitCode:result.exitCode,timedOut:result.timedOut,error:result.error||result.parseError||null,evidence};
}
// Chrome's native Windows window dimensions may include a frame. Measure once.
const probePath=join(out,'viewport-probe.html');
await writeFile(probePath,makePage(`const p=document.createElement('pre');p.id='qa-result';p.hidden=true;p.textContent=JSON.stringify({errors:window.__qaErrors,viewport:{width:innerWidth,height:innerHeight}});document.body.appendChild(p);`));
const probe=await runBrowser('viewport_probe',pathToFileURL(probePath).href,[960,540],false);
if(probe.exitCode!==0||!probe.evidence)throw new Error('Browser viewport probe failed; see '+out);
windowFrameCorrection=[960-probe.evidence.viewport.width,540-probe.evidence.viewport.height];
const results=[];
if(!onlyCaptures){
const standalone=await runBrowser('standalone',pathToFileURL(join(root,'index.html')).href,[960,540]);
const directDom=await readFile(join(out,'standalone.html'),'utf8');
standalone.passed=standalone.exitCode===0&&!standalone.timedOut&&directDom.includes('Snapback')&&/data-ready="true"/.test(directDom);
standalone.readinessMarker=/data-ready="true"/.test(directDom);
results.push(standalone);console.log((standalone.passed?'PASS':'FAIL')+' actual index.html direct file launch');
const suitePath=join(out,'suite-source.html');await writeFile(suitePath,makePage(suite));
for(const size of (quick?[[960,540]]:[[960,540],[1280,720],[640,400]])){
 const name='suite_'+size.join('x'),result=await runBrowser(name,pathToFileURL(suitePath).href,size);
 result.viewportExact=result.evidence?.viewport.width===size[0]&&result.evidence?.viewport.height===size[1];
 result.passed=result.exitCode===0&&!result.timedOut&&!!result.evidence&&result.evidence.errors.length===0&&result.evidence.results.every(x=>x.passed);results.push(result);
 console.log((result.passed?'PASS':'FAIL')+' '+name+' '+(result.evidence?.results.filter(x=>x.passed).length||0)+'/'+(result.evidence?.results.length||0)+' browser assertions');
 for(const failure of result.evidence?.results.filter(x=>!x.passed)||[])console.log('  '+failure.name+': '+failure.error);
 if(result.error||result.evidence?.errors.length)console.log(JSON.stringify(result));
}
}
if(!quick&&!process.argv.includes('--no-captures'))for(const scene of (onlyCaptures||['title','rally','perfect','stomp','save','save_ready','wave','reduced','high','overdrive','pause','point','winner'])){
 const source=join(out,'fixture_'+scene+'.html');await writeFile(source,makePage(fixture.replace('SCENE',JSON.stringify(scene))));
 const result=await runBrowser('capture_'+scene,pathToFileURL(source).href,[960,540]);
 const expected={title:'TITLE',rally:'RALLY',perfect:'RALLY',stomp:'RALLY',save:'RALLY',save_ready:'RALLY',wave:'RALLY',reduced:'RALLY',high:'RALLY',overdrive:'RALLY',pause:'PAUSED',point:'POINT_FREEZE',winner:'MATCH_OVER'};
 const eventExpected={perfect:'PERFECT',stomp:'STOMP',save:'SNAPBACK',reduced:'SNAPBACK',point:'POINT',winner:'VICTORY'};
 result.passed=result.exitCode===0&&!result.timedOut&&!!result.evidence&&result.evidence.errors.length===0&&result.evidence.phase===expected[scene]&&(!eventExpected[scene]||result.evidence.events.some(e=>e.type===eventExpected[scene]))&&(scene!=='wave'||result.evidence.netMaxDeflection>0&&result.evidence.effectTypes.includes('BOUNCE'))&&(scene!=='save_ready'||result.evidence.players[0].recoveryCharge===1&&result.evidence.stats.saves[0]===0);results.push(result);console.log((result.passed?'PASS':'FAIL')+' capture '+scene);
}
if(!quick&&!onlyCaptures){
 const embedScript=String.raw`
 const f=document.getElementById('embed');f.addEventListener('load',()=>{const results=[];function test(name,fn){try{fn();results.push({name,passed:true});}catch(e){results.push({name,passed:false,error:e.message});}}function assert(n,m){if(!n)throw new Error(m);}const w=f.contentWindow,a=w.SnapbackTest,s=a?.getState();const params=new URL(location.href).searchParams,expectedWidth=Number(params.get('w')),expectedHeight=Number(params.get('h'));
 test('actual HTTP runtime opens inside iframe',()=>assert(a&&s.phase==='TITLE','embedded title failed'));
 test('embedded exact requested viewport',()=>assert(w.innerWidth===expectedWidth&&w.innerHeight===expectedHeight,'iframe viewport does not match request'));
 test('embedded aspect and bounds',()=>{const r=w.document.getElementById('game').getBoundingClientRect();assert(Math.abs(r.width/r.height-960/540)<.002,'iframe ratio');assert(r.width<=w.innerWidth+.5&&r.height<=w.innerHeight+.5,'iframe overflow');});
 test('embedded actual keyboard handlers start both players',()=>{for(const code of ['Space','KeyA','ArrowRight'])w.dispatchEvent(new w.KeyboardEvent('keydown',{code,bubbles:true,cancelable:true}));a.driver.reset();a.driver.frame(0);for(let t=1;t<=10;t++)a.driver.frame(t*1000/60);assert(s.phase==='RALLY','embedded start failed');assert(s.players[0].x<a.CONFIG.player.spawnX[0]&&s.players[1].x>a.CONFIG.player.spawnX[1],'embedded simultaneous steering failed');});
 test('embedded focus loss clears and pauses',()=>{w.dispatchEvent(new w.Event('blur'));assert(s.phase==='PAUSED'&&!Object.keys(a.input.held).length,'iframe blur failed');});
 const result=document.createElement('pre');result.id='qa-result';result.hidden=true;result.textContent=JSON.stringify({results,errors:w.__qaErrors||['Missing error instrumentation'],warnings:w.__qaWarnings||[],userAgent:navigator.userAgent,viewport:{width:w.innerWidth,height:w.innerHeight},syntheticInput:true,canvasPng:w.document.getElementById('game').toDataURL('image/png')});document.body.appendChild(result);});
 `;
 const requests=[];
 const server=createServer((req,res)=>{requests.push(req.url);const url=new URL(req.url,'http://127.0.0.1'),pathname=url.pathname;if(pathname==='/index.html'){res.writeHead(200,{'Content-Type':'text/html; charset=utf-8'});res.end(original.replace('<script>',passiveErrors+'<script>'));}else if(pathname==='/iframe.html'){const w=Number(url.searchParams.get('w'))||640,h=Number(url.searchParams.get('h'))||360;res.writeHead(200,{'Content-Type':'text/html; charset=utf-8'});res.end('<!doctype html><html><head><meta charset="utf-8"><style>html,body{margin:0;background:#0C1114;color:#F6EEDF;height:100%;display:grid;place-items:center}iframe{width:'+w+'px;height:'+h+'px;border:0}</style></head><body><iframe id="embed" title="Snapback iframe check" src="/index.html?test=1"></iframe><script>'+embedScript+'</script></body></html>');}else{res.writeHead(404);res.end();}});
 await new Promise(resolveListening=>server.listen(0,'127.0.0.1',resolveListening));
 try{for(const size of [[960,540],[1280,720],[640,400],[640,360]]){const name='iframe_http_'+size.join('x'),result=await runBrowser(name,'http://127.0.0.1:'+server.address().port+'/iframe.html?w='+size[0]+'&h='+size[1],[size[0]+160,size[1]+220]);result.passed=result.exitCode===0&&!result.timedOut&&!!result.evidence&&result.evidence.results.every(x=>x.passed)&&result.evidence.errors.length===0;results.push(result);console.log((result.passed?'PASS':'FAIL')+' '+name+' '+(result.evidence?.results.filter(x=>x.passed).length||0)+'/'+(result.evidence?.results.length||0));}}finally{await new Promise(resolveClosed=>server.close(resolveClosed));}
 results.push({name:'localhost_request_inventory',passed:requests.every(url=>/^\/(iframe\.html|index\.html|favicon\.ico)(\?|$)/.test(url)),requests});
}
const report={browser,sourceSha256,windowFrameCorrection,createdAt:new Date().toISOString(),results};
const reportName=onlyCaptures?'results_captures_'+onlyCaptures.join('_')+'.json':quick&&!edge?'results_core.json':'results.json';
await writeFile(join(out,reportName),JSON.stringify(report,null,2));
if(!quick&&!onlyCaptures)await writeFile(join(out,'results_full.json'),JSON.stringify(report,null,2));
if(quick)await writeFile(join(out,'results_core.json'),JSON.stringify(report,null,2));
process.exitCode=results.every(r=>r.passed)?0:1;
