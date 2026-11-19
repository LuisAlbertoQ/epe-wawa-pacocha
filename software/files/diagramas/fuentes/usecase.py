"""Diagrama de casos de uso (E1 §10.1, v1.2) como SVG."""
from pathlib import Path

EW, EH, RS = 232, 40, 50          # elipse: ancho, alto, separación entre filas
COLW, GAP = 250, 62
X0 = 120                           # inicio del recuadro del sistema
TOP = 92                           # primera fila
FONT = 'Helvetica, Arial, sans-serif'
NAVY, FILL, LINE = '#1F3864', '#EAF0FA', '#555555'

col1 = ['CU01 Registrarse', 'CU03 Registrar animal', 'CU26 Verificar consanguinidad', 'CU04 Editar animal',
        'CU05 Dar de baja animal', 'CU07 Ver árbol genealógico', 'CU12 Registrar producción',
        'CU25 Registrar análisis de fibra', 'CU08 Sincronizar datos', 'CU02 Iniciar sesión',
        'CU06 Listar animales', 'CU09 Generar reporte']
col2 = ['CU10 Gestionar roles', 'CU19 Gestionar catálogo y precios', 'CU20 Poner animal en venta',
        'CU21 Gestionar contenido', 'CU18 Confirmar pago', 'CU22 Marcar pedido entregado',
        'CU24 Monitorear plataformas']
col3 = ['CU11 Gestionar tienda virtual', 'CU13 Consultar catálogo', 'CU14 Ver trazabilidad de producto',
        'CU15 Agregar al carrito', 'CU16 Generar pedido', 'CU17 Subir comprobante',
        'CU23 Consultar pedido por código']
shared = {'CU02 Iniciar sesión', 'CU06 Listar animales', 'CU09 Generar reporte'}
headers = ['Gestión ganadera (app móvil)', 'Administración (panel)', 'Tienda virtual (web)']

cx = [X0 + 20 + COLW / 2 + i * (COLW + GAP) for i in range(3)]
pos = {}
for c, items in enumerate([col1, col2, col3]):
    for r, name in enumerate(items):
        pos[name] = (cx[c], TOP + 40 + r * RS)

bottom = TOP + 40 + (len(col1) - 1) * RS + EH / 2 + 22
BX1 = cx[2] + COLW / 2 + 20
W = BX1 + 120
ADM = (cx[1] - EW / 2 - 7, bottom + 70)
H = ADM[1] + 75
svg = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{W:.0f}" height="{H:.0f}" viewBox="0 0 {W:.0f} {H:.0f}" '
       f'font-family="{FONT}">',
       '<defs><marker id="open" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="9" markerHeight="9" orient="auto">'
       f'<path d="M0,0 L10,5 L0,10" fill="none" stroke="{LINE}" stroke-width="1.4"/></marker></defs>',
       f'<rect x="0" y="0" width="{W:.0f}" height="{H:.0f}" fill="white"/>',
       f'<rect x="{X0}" y="28" width="{BX1 - X0:.0f}" height="{bottom - 28:.0f}" rx="12" fill="none" '
       f'stroke="{NAVY}" stroke-width="1.6"/>',
       f'<text x="{(X0 + BX1) / 2:.0f}" y="50" text-anchor="middle" font-size="15" font-weight="bold" '
       f'fill="{NAVY}">Sistema Wawa Pacocha</text>']
for i, h in enumerate(headers):
    x = cx[i]
    svg.append(f'<rect x="{x - COLW / 2 + 4:.0f}" y="{TOP - 30}" width="{COLW - 8}" '
               f'height="{bottom - TOP + 18:.0f}" fill="none" stroke="#B8C4D8" stroke-dasharray="4 3"/>')
    svg.append(f'<text x="{x:.0f}" y="{TOP - 12}" text-anchor="middle" font-size="13" font-weight="bold" '
               f'fill="{NAVY}">{h}</text>')


def actor(x, y, name):
    s = ['<g stroke="#222" stroke-width="2" fill="none">',
         f'<circle cx="{x}" cy="{y - 30}" r="9" fill="white"/>',
         f'<line x1="{x}" y1="{y - 21}" x2="{x}" y2="{y + 6}"/>',
         f'<line x1="{x - 15}" y1="{y - 12}" x2="{x + 15}" y2="{y - 12}"/>',
         f'<line x1="{x}" y1="{y + 6}" x2="{x - 12}" y2="{y + 26}"/>',
         f'<line x1="{x}" y1="{y + 6}" x2="{x + 12}" y2="{y + 26}"/></g>',
         f'<text x="{x}" y="{y + 44}" text-anchor="middle" font-size="13" font-weight="bold">{name}</text>']
    return s


lines = []
cri = (55, (TOP + 40 + TOP + 40 + (len(col1) - 1) * RS) / 2)
com = (BX1 + 62, TOP + 40 + 3 * RS)
for n in col1:
    x, y = pos[n]
    lines.append((cri[0] + 16, cri[1] - 8, x - EW / 2, y))
for n in col3:
    x, y = pos[n]
    lines.append((com[0] - 16, com[1] - 8, x + EW / 2, y))
TX = cx[1] - EW / 2 - 7                      # troncal del Administrador
lines.append((TX, ADM[1] - 42, TX, pos[col2[0]][1]))
lines.append((ADM[0], ADM[1] - 42, TX, ADM[1] - 42))
for n in col2:
    x, y = pos[n]
    lines.append((TX, y, x - EW / 2, y))
for n in shared:
    x, y = pos[n]
    lines.append((TX, y, x + EW / 2, y))
for x1, y1, x2, y2 in lines:
    svg.append(f'<line x1="{x1:.0f}" y1="{y1:.0f}" x2="{x2:.0f}" y2="{y2:.0f}" stroke="{LINE}" stroke-width="1.1"/>')

for n, (x, y) in pos.items():
    fill = '#FFF4E0' if n.startswith('CU26') else FILL
    svg.append(f'<ellipse cx="{x:.0f}" cy="{y:.0f}" rx="{EW / 2}" ry="{EH / 2}" fill="{fill}" stroke="{NAVY}" stroke-width="1.2"/>')
    svg.append(f'<text x="{x:.0f}" y="{y + 4.5:.0f}" text-anchor="middle" font-size="12.5">{n}</text>')

for src, dst in [('CU26 Verificar consanguinidad', 'CU03 Registrar animal'),
                 ('CU25 Registrar análisis de fibra', 'CU12 Registrar producción')]:
    (x1, y1), (x2, y2) = pos[src], pos[dst]
    xe = x1 + EW / 2 - 18
    svg.append(f'<path d="M{xe:.0f},{y1 - 14:.0f} C{xe + 30:.0f},{y1 - 25:.0f} {xe + 30:.0f},{y2 + 25:.0f} {xe + 2:.0f},{y2 + 15:.0f}" '
               f'fill="none" stroke="{LINE}" stroke-dasharray="5 3" stroke-width="1.2" marker-end="url(#open)"/>')
    svg.append(f'<text x="{xe + 34:.0f}" y="{(y1 + y2) / 2 + 4:.0f}" font-size="11" fill="#333">«extend»</text>')

svg += actor(*cri, 'Criador') + actor(*com, 'Comprador') + actor(*ADM, 'Administrador')
svg.append('</svg>')
Path('out/e1_casos_uso.svg').write_text('\n'.join(svg), encoding='utf-8')
print('ok', W, H)

