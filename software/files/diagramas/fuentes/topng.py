"""SVG -> PNG con Chrome headless. Uso: python topng.py out/a.svg [out/b.svg ...]"""
import re
import subprocess
import sys
from pathlib import Path

CHROME = r'C:\Program Files\Google\Chrome\Application\chrome.exe'
PAD = 12
SCALE = 2


def size_px(svg):
    head = svg[:2000]
    w = re.search(r'width="([\d.]+)(pt|px)?"', head)
    h = re.search(r'height="([\d.]+)(pt|px)?"', head)
    k = 4 / 3 if (w and w.group(2) == 'pt') else 1
    return round(float(w.group(1)) * k), round(float(h.group(1)) * k)


for f in sys.argv[1:]:
    p = Path(f).resolve()
    svg = p.read_text(encoding='utf-8')
    svg = re.sub(r'<\?xml[^>]*>|<!DOCTYPE[^>]*>', '', svg)
    w, h = size_px(svg)
    html = p.with_suffix('.html')
    html.write_text(
        '<!doctype html><html><head><meta charset="utf-8"><style>'
        f'html,body{{margin:0;padding:0;background:#fff}}body{{padding:{PAD}px}}'
        'svg{display:block}</style></head><body>' + svg + '</body></html>', encoding='utf-8')
    png = p.with_suffix('.png')
    W, H = w + 2 * PAD, h + 2 * PAD
    subprocess.run([CHROME, '--headless=new', '--disable-gpu', '--hide-scrollbars',
                    f'--force-device-scale-factor={SCALE}', f'--window-size={W},{H}',
                    f'--screenshot={png}', '--default-background-color=FFFFFFFF',
                    html.as_uri()], check=True, capture_output=True, timeout=120)
    print('png', png.name, f'{W}x{H}px (x{SCALE})')
