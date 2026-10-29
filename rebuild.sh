#!/bin/bash
# Re-export the live web app from ~/Projects/pots-and-plans-5b (live .env.local) and publish to app.getpotsandplans.com.
set -e
MSG="${1:-Live app update}"
OUT=$(mktemp -d)
cd ~/Projects/pots-and-plans-5b/apps/mobile && npx expo export --platform web --output-dir "$OUT/web" > "$OUT/export.log" 2>&1
cd ~/Projects/pp-live-pages
rm -rf _expo assets items index.html 404.html phone.html metadata.json
cp -R "$OUT/web/_expo" "$OUT/web/assets" "$OUT/web/items" "$OUT/web/metadata.json" "$OUT/web/phone.html" .
python3 - "$OUT/web/index.html" <<'PY'
import sys
s=open(sys.argv[1]).read()
redir='<script>if(window.top===window&&window.innerWidth>600&&!/standalone/.test(location.search)){location.replace("/phone.html"+location.search)}</script>'
tags='''<link rel="manifest" href="/manifest.json"/>
    <link rel="apple-touch-icon" href="/apple-touch-icon.png"/>
    <meta name="apple-mobile-web-app-capable" content="yes"/>
    <meta name="mobile-web-app-capable" content="yes"/>
    <meta name="apple-mobile-web-app-title" content="Pots & Plans"/>
    <meta name="apple-mobile-web-app-status-bar-style" content="default"/>
'''
s=s.replace("<head>","<head>\n"+redir,1).replace("</head>",tags+"</head>",1)
open("index.html","w").write(s)
PY
cp index.html 404.html
git add -A && git commit -qm "$MSG" && git push -q && git log -1 --format=%h
