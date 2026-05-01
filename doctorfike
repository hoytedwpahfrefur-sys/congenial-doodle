FROM kalilinux/kali-rolling

ENV PORT=7681
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates wget curl git \
    python3 python3-pip python3-venv \
    tini fastfetch unzip nano vim htop \
    chromium chromium-driver tmux \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    arch="$(uname -m)"; \
    case "$arch" in \
      x86_64|amd64) ttyd_asset="ttyd.x86_64" ;; \
      aarch64|arm64) ttyd_asset="ttyd.aarch64" ;; \
      *) echo "Unsupported arch: $arch" >&2; exit 1 ;; \
    esac; \
    wget -qO /usr/local/bin/ttyd \
      "https://github.com/tsl0922/ttyd/releases/latest/download/${ttyd_asset}" \
    && chmod +x /usr/local/bin/ttyd

RUN pip install --break-system-packages \
    flask selenium requests flask-cors

RUN echo "fastfetch || true" >> /root/.bashrc && \
    echo "alias python=python3" >> /root/.bashrc && \
    echo "alias pip='pip --break-system-packages'" >> /root/.bashrc

WORKDIR /root

RUN cat > /root/index.html << 'HTMLEOF'
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<title>Aurex Terminal</title>
<link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@xterm/xterm@5.3.0/css/xterm.css">
<style>
*{box-sizing:border-box;margin:0;padding:0}
:root{--red:#c0392b;--bg:#0a0a0a;--surface:#111;--border:#2a0d09;--text:#e8e0dc;--muted:#6b5a57}
html,body{height:100%;width:100%;overflow:hidden;background:var(--bg);font-family:'JetBrains Mono',monospace;-webkit-tap-highlight-color:transparent}
#hdr{position:fixed;top:0;left:0;right:0;height:44px;background:var(--surface);border-bottom:1px solid var(--border);display:flex;align-items:center;gap:10px;padding:0 12px;z-index:100}
#burger{background:none;border:none;width:36px;height:36px;display:flex;flex-direction:column;justify-content:center;align-items:center;gap:5px;cursor:pointer;border-radius:6px}
#burger:active{background:var(--border)}
#burger span{display:block;width:20px;height:2px;background:#e74c3c;border-radius:2px;transition:transform .25s,opacity .25s}
#burger.open span:nth-child(1){transform:translateY(7px) rotate(45deg)}
#burger.open span:nth-child(2){opacity:0}
#burger.open span:nth-child(3){transform:translateY(-7px) rotate(-45deg)}
#title{flex:1;font-size:12px;font-weight:700;letter-spacing:2px;color:var(--muted)}
#title span{color:#e74c3c}
#dot{width:8px;height:8px;border-radius:50%;background:#333;transition:background .3s}
#dot.ok{background:#2ecc71;box-shadow:0 0 6px #2ecc71}
#dot.err{background:var(--red);box-shadow:0 0 6px var(--red)}
#overlay{position:fixed;inset:0;z-index:199;background:rgba(0,0,0,.6);opacity:0;pointer-events:none;transition:opacity .25s}
#overlay.show{opacity:1;pointer-events:all}
#drawer{position:fixed;top:0;left:0;bottom:0;width:270px;z-index:200;background:var(--surface);border-right:1px solid var(--border);transform:translateX(-100%);transition:transform .28s cubic-bezier(.4,0,.2,1);display:flex;flex-direction:column}
#drawer.open{transform:none}
.dh{padding:14px;border-bottom:1px solid var(--border)}
.dh h2{font-size:10px;font-weight:700;letter-spacing:3px;color:#e74c3c;margin-bottom:2px}
.dh p{font-size:10px;color:var(--muted)}
.ds{padding:12px 14px;border-bottom:1px solid var(--border)}
.dl{font-size:9px;font-weight:700;letter-spacing:2px;color:var(--muted);text-transform:uppercase;margin-bottom:8px;display:flex;align-items:center;justify-content:space-between}
.row{display:flex;gap:6px}
#nsn{flex:1;background:var(--bg);border:1px solid var(--border);border-radius:5px;color:var(--text);font-family:'JetBrains Mono',monospace;font-size:12px;padding:6px 10px;outline:none}
#nsn:focus{border-color:var(--red)}
.btn{background:#5a1008;border:1px solid var(--red);color:var(--text);font-family:'JetBrains Mono',monospace;font-size:10px;font-weight:700;padding:6px 10px;border-radius:5px;cursor:pointer;white-space:nowrap}
.btn:active{background:var(--red)}
.btn.g{background:transparent;border-color:var(--border);color:var(--muted)}
.btn.g:active{background:var(--border);color:var(--text)}
.grid{display:grid;grid-template-columns:1fr 1fr;gap:5px}
.grid .btn{text-align:center;padding:8px 5px}
#slist{display:flex;flex-direction:column;gap:4px}
.si{display:flex;align-items:center;gap:8px;padding:8px 10px;border-radius:6px;background:var(--bg);border:1px solid var(--border);cursor:pointer}
.si.act{border-color:var(--red);background:#1a0a08}
.sd{width:6px;height:6px;border-radius:50%;background:var(--muted);flex-shrink:0}
.si.act .sd{background:#e74c3c;box-shadow:0 0 4px #e74c3c}
.sn{flex:1;font-size:11px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.sk{background:none;border:none;color:var(--muted);font-size:14px;cursor:pointer;padding:0 2px}
.sk:active{color:#e74c3c}
#term-wrap{position:fixed;top:44px;left:0;right:0;bottom:52px;background:#0c0c0c}
#term{width:100%;height:100%;padding:4px}
.xterm{height:100%!important}
#keys{position:fixed;bottom:0;left:0;right:0;height:52px;background:var(--surface);border-top:1px solid var(--border);display:flex;align-items:center;padding:0 6px;gap:4px;overflow-x:auto;scrollbar-width:none;z-index:90}
#keys::-webkit-scrollbar{display:none}
.k{flex-shrink:0;min-width:44px;height:38px;background:var(--bg);border:1px solid var(--border);color:var(--text);font-family:'JetBrains Mono',monospace;font-size:10px;font-weight:700;border-radius:6px;cursor:pointer;display:flex;align-items:center;justify-content:center;padding:0 8px;user-select:none;-webkit-user-select:none}
.k:active{background:#1e0a08;border-color:var(--red)}
.k.mod{color:var(--muted)}
.k.mod.on{background:#5a1008;border-color:#e74c3c;color:var(--text);box-shadow:0 0 8px rgba(192,57,43,.5)}
.ksep{flex-shrink:0;width:1px;height:24px;background:var(--border);margin:0 2px}
</style>
</head>
<body>
<div id="hdr">
  <button id="burger" onclick="toggleDrawer()">
    <span></span><span></span><span></span>
  </button>
  <div id="title"><span>AUREX</span> TERMINAL</div>
  <div id="dot"></div>
</div>

<div id="overlay" onclick="closeDrawer()"></div>

<div id="drawer">
  <div class="dh"><h2>SESSIONS</h2><p>tmux session manager</p></div>
  <div class="ds">
    <div class="dl">New Session</div>
    <div class="row">
      <input id="nsn" type="text" placeholder="session name" maxlength="32" autocomplete="off" spellcheck="false">
      <button class="btn" onclick="newSession()">NEW</button>
    </div>
  </div>
  <div class="ds" style="flex:1;overflow-y:auto">
    <div class="dl">Active Sessions
      <button class="btn g" style="font-size:9px;padding:3px 7px" onclick="refreshSessions()">↺ REFRESH</button>
    </div>
    <div id="slist"><div style="font-size:11px;color:var(--muted);padding:6px 2px">Tap REFRESH to list sessions</div></div>
  </div>
  <div class="ds">
    <div class="dl">Tmux Quick Actions</div>
    <div class="grid">
      <button class="btn g" onclick="tmuxCmd('new-window')">⊞ New Win</button>
      <button class="btn g" onclick="tmuxCmd('split-window -h')">⬜ Split H</button>
      <button class="btn g" onclick="tmuxCmd('split-window -v')">▬ Split V</button>
      <button class="btn g" onclick="tmuxCmd('next-window')">→ Next</button>
      <button class="btn g" onclick="tmuxCmd('prev-window')">← Prev</button>
      <button class="btn g" onclick="tmuxCmd('kill-window')">✕ Kill Win</button>
    </div>
  </div>
</div>

<div id="term-wrap"><div id="term"></div></div>

<div id="keys">
  <button class="k mod" id="kctrl" onclick="toggleMod('ctrl')">CTRL</button>
  <button class="k mod" id="kalt"  onclick="toggleMod('alt')">ALT</button>
  <button class="k" onclick="send('\x1b')">ESC</button>
  <button class="k" onclick="send('\t')">TAB</button>
  <div class="ksep"></div>
  <button class="k" onclick="send('\x1b[A')">↑</button>
  <button class="k" onclick="send('\x1b[B')">↓</button>
  <button class="k" onclick="send('\x1b[D')">←</button>
  <button class="k" onclick="send('\x1b[C')">→</button>
  <div class="ksep"></div>
  <button class="k" onclick="send('\x1b[H')">HOME</button>
  <button class="k" onclick="send('\x1b[F')">END</button>
  <button class="k" onclick="send('\x1b[5~')">PgUp</button>
  <button class="k" onclick="send('\x1b[6~')">PgDn</button>
  <div class="ksep"></div>
  <button class="k" style="border-color:var(--red);color:#e74c3c" onclick="send('\x02')">^B</button>
  <button class="k" onclick="send('\x03')">^C</button>
  <button class="k" onclick="send('\x04')">^D</button>
  <button class="k" onclick="send('\x0c')">^L</button>
  <button class="k" onclick="send('\x1a')">^Z</button>
</div>

<script src="https://cdn.jsdelivr.net/npm/@xterm/xterm@5.3.0/lib/xterm.js"></script>
<script src="https://cdn.jsdelivr.net/npm/@xterm/addon-fit@0.8.0/lib/addon-fit.js"></script>
<script>
var ws, term, fit, mod={ctrl:false,alt:false}, curSess='main', drawerOpen=false, retryTimer;

function init(){
  term=new Terminal({
    fontFamily:'"JetBrains Mono",monospace',
    fontSize:13,lineHeight:1.2,
    cursorBlink:true,cursorStyle:'block',
    allowTransparency:true,scrollback:5000,
    theme:{background:'#0c0c0c',foreground:'#e8e0dc',cursor:'#e74c3c',
           selectionBackground:'rgba(192,57,43,0.3)',
           black:'#1a1a1a',red:'#c0392b',green:'#27ae60',yellow:'#f39c12',
           blue:'#2980b9',magenta:'#8e44ad',cyan:'#16a085',white:'#e8e0dc',
           brightBlack:'#4a4a4a',brightRed:'#e74c3c',brightGreen:'#2ecc71',
           brightYellow:'#f1c40f',brightBlue:'#3498db',brightMagenta:'#9b59b6',
           brightCyan:'#1abc9c',brightWhite:'#ffffff'}
  });
  fit=new FitAddon.FitAddon();
  term.loadAddon(fit);
  term.open(document.getElementById('term'));
  fit.fit();
  window.addEventListener('resize',()=>fit.fit());
  term.onData(onInput);
  term.onResize(({cols,rows})=>wsSend('1',JSON.stringify({columns:cols,rows:rows})));
  connect();
}

function connect(){
  var proto=location.protocol==='https:'?'wss:':'ws:';
  var url=proto+'//'+location.host+'/ws';
  term.write('\r\n\x1b[33mConnecting...\x1b[0m\r\n');
  try{ ws=new WebSocket(url); }
  catch(e){ term.write('\x1b[31mFailed: '+e.message+'\x1b[0m\r\n'); retry(); return; }
  ws.binaryType='arraybuffer';
  ws.onopen=function(){
    document.getElementById('dot').className='ok';
    setTimeout(()=>wsSend('1',JSON.stringify({columns:term.cols,rows:term.rows})),150);
    term.focus();
  };
  ws.onmessage=function(ev){
    var buf=new Uint8Array(ev.data);
    if(!buf.length)return;
    var cmd=buf[0], data=buf.slice(1);
    if(cmd===48) term.write(data);
  };
  ws.onclose=function(){ document.getElementById('dot').className='err'; retry(); };
  ws.onerror=function(){ document.getElementById('dot').className='err'; };
}

function retry(){ if(retryTimer)clearTimeout(retryTimer); retryTimer=setTimeout(connect,3000); }

function wsSend(type,data){
  if(!ws||ws.readyState!==1)return;
  var enc=new TextEncoder();
  ws.send(enc.encode(type+data));
}

function onInput(data){
  if(mod.ctrl||mod.alt){
    var out='';
    for(var i=0;i<data.length;i++){
      if(mod.ctrl){
        var c=data[i].toUpperCase().charCodeAt(0);
        out+=(c>=64&&c<=95)?String.fromCharCode(c-64):data[i];
      } else {
        out+='\x1b'+data[i];
      }
    }
    wsSend('0',out);
    clearMod();
  } else {
    wsSend('0',data);
  }
}

function send(seq){ wsSend('0',seq); term.focus(); }

function toggleMod(m){
  mod[m]=!mod[m];
  document.getElementById('k'+m).classList.toggle('on',mod[m]);
}
function clearMod(){
  mod.ctrl=false; mod.alt=false;
  document.getElementById('kctrl').classList.remove('on');
  document.getElementById('kalt').classList.remove('on');
}

function toggleDrawer(){ drawerOpen?closeDrawer():openDrawer(); }
function openDrawer(){
  drawerOpen=true;
  document.getElementById('drawer').classList.add('open');
  document.getElementById('overlay').classList.add('show');
  document.getElementById('burger').classList.add('open');
}
function closeDrawer(){
  drawerOpen=false;
  document.getElementById('drawer').classList.remove('open');
  document.getElementById('overlay').classList.remove('show');
  document.getElementById('burger').classList.remove('open');
}

function newSession(){
  var n=document.getElementById('nsn').value.trim().replace(/[^a-zA-Z0-9_-]/g,'')||'s'+Date.now().toString(36);
  document.getElementById('nsn').value='';
  wsSend('0','\x02:new-session -d -s '+n+'\r');
  setTimeout(()=>{ wsSend('0','\x02:switch-client -t '+n+'\r'); curSess=n; },300);
  closeDrawer(); term.focus();
}

function refreshSessions(){ wsSend('0','tmux ls\r'); closeDrawer(); term.focus(); }

function tmuxCmd(c){ wsSend('0','\x02:'+c+'\r'); closeDrawer(); term.focus(); }

var tx=0;
document.addEventListener('touchstart',e=>{tx=e.touches[0].clientX;},{passive:true});
document.addEventListener('touchend',e=>{
  var dx=e.changedTouches[0].clientX-tx;
  if(tx<30&&dx>60&&!drawerOpen)openDrawer();
  if(dx<-60&&drawerOpen)closeDrawer();
},{passive:true});

document.getElementById('nsn').addEventListener('keydown',e=>{ if(e.key==='Enter')newSession(); });

init();
</script>
</body>
</html>
HTMLEOF

EXPOSE 7681

ENTRYPOINT ["/usr/bin/tini", "--"]

CMD ["/bin/bash", "-lc", \
    "/usr/local/bin/ttyd --writable -i 0.0.0.0 -p ${PORT} -c ${USERNAME}:${PASSWORD} --index /root/index.html tmux new-session -A -s main"]
