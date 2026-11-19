"""Mermaid (.mmd) -> SVG usando Chrome headless (--dump-dom). Uso: python mermaid_svg.py src/a.mmd ..."""
import html
import json
import re
import subprocess
import sys
from pathlib import Path

CHROME = r'C:\Program Files\Google\Chrome\Application\chrome.exe'
CONFIG = {
    'startOnLoad': False, 'theme': 'base', 'fontFamily': 'Helvetica, Arial, sans-serif',
    'themeVariables': {'primaryColor': '#DCE6F4', 'primaryBorderColor': '#1F3864', 'primaryTextColor': '#111111',
                       'actorBkg': '#DCE6F4', 'actorTextColor': '#1F3864', 'labelTextColor': '#1F3864', 'actorBorder': '#1F3864',
                       'actorLineColor': '#8A8A8A', 'signalColor': '#333333', 'signalTextColor': '#111111',
                       'noteBkgColor': '#FFF4E0', 'noteBorderColor': '#B26A00', 'labelBoxBkgColor': '#EAF0FA',
                       'labelBoxBorderColor': '#1F3864', 'loopTextColor': '#1F3864', 'activationBkgColor': '#EAF0FA',
                       'sequenceNumberColor': '#FFFFFF', 'fontSize': '15px'},
    'sequence': {'mirrorActors': False, 'actorMargin': 26, 'messageMargin': 30, 'boxMargin': 8, 'messageFontSize': 18, 'actorFontSize': 18, 'noteFontSize': 17,
                 'noteMargin': 8, 'wrap': True, 'width': 185, 'useMaxWidth': False},
}

for f in sys.argv[1:]:
    p = Path(f).resolve()
    text = p.read_text(encoding='utf-8')
    page = p.with_suffix('.render.html')
    page.write_text(f'''<!doctype html><html><head><meta charset="utf-8"></head><body><div id="out"></div>
<script type="module">
import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@11.4.1/dist/mermaid.esm.min.mjs';
mermaid.initialize({json.dumps(CONFIG)});
const src = {json.dumps(text)};
try {{ const r = await mermaid.render('d', src); document.getElementById('out').innerHTML = r.svg; }}
catch (e) {{ document.getElementById('out').textContent = 'ERROR ' + e.message; }}
</script></body></html>''', encoding='utf-8')
    dom = subprocess.run([CHROME, '--headless=new', '--disable-gpu', '--virtual-time-budget=20000',
                          '--dump-dom', page.as_uri()], capture_output=True, text=True, encoding='utf-8',
                         timeout=120).stdout
    m = re.search(r'<svg[\s\S]*</svg>', dom)
    if not m:
        err = re.search(r'ERROR[^<]*', dom)
        print('FALLO', p.name, err.group(0) if err else dom[-300:])
        continue
    svg = m.group(0)
    vb = re.search(r'viewBox="([-\d.]+) ([-\d.]+) ([\d.]+) ([\d.]+)"', svg)
    w, h = float(vb.group(3)), float(vb.group(4))
    svg = re.sub(r'^<svg', f'<svg xmlns="http://www.w3.org/2000/svg" width="{w:.0f}" height="{h:.0f}"', svg, count=1)
    svg = re.sub(r'(<svg[^>]*?)\swidth="100%"', r'\1', svg, count=1)
    svg = re.sub(r'(<svg[^>]*?)\sstyle="max-width:[^"]*"', r'\1', svg, count=1)
    out = Path('out') / (p.stem + '.svg')
    out.write_text(svg, encoding='utf-8')
    print('svg', out.name, f'{w:.0f}x{h:.0f}')


