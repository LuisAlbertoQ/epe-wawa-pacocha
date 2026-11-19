"""Genera los 4 diagramas ER de E2 (DOT) a partir de wawapacocha_schema.sql."""
import re
import sys
from pathlib import Path

schema = Path(sys.argv[1]).read_text(encoding='utf-8')
OUT = Path(sys.argv[2])

# ---------- parseo ----------
tables = {}
for m in re.finditer(r'CREATE TABLE `(\w+)` \((.*?)\n\)', schema, re.S):
    name, body = m.group(1), m.group(2)
    cols, uniques, fks = [], [], {}
    for line in body.splitlines():
        line = line.strip().rstrip(',')
        cm = re.match(r'`(\w+)`\s+([a-z]+(?:\(\d+(?:,\d+)?\))?(?:\s+unsigned)?)(.*)$', line)
        if cm:
            col, typ, rest = cm.groups()
            cols.append({'name': col, 'type': typ, 'pk': 'PRIMARY KEY' in rest,
                         'uk': re.search(r'\bUNIQUE\b', rest) is not None,
                         'null': 'NOT NULL' not in rest})
            continue
        um = re.match(r'UNIQUE \((.*)\)', line)
        if um:
            uniques.append([c.strip(' `') for c in um.group(1).split(',')])
        fm = re.match(r'FOREIGN KEY \(`(\w+)`\) REFERENCES `(\w+)`', line)
        if fm:
            fks[fm.group(1)] = fm.group(2)
    tables[name] = {'cols': cols, 'uniques': uniques, 'fks': fks}

# ---------- decisión v1.2: hato único ----------
an = tables['animales']
an['uniques'] = [u for u in an['uniques'] if u != ['usuario_id', 'arete']]
for c in an['cols']:
    if c['name'] == 'arete':
        c['uk'] = True

for t in tables.values():
    for c in t['cols']:
        if len(t['uniques']) and any(len(u) == 1 and u[0] == c['name'] for u in t['uniques']):
            c['uk'] = True
    t['uniques'] = [u for u in t['uniques'] if len(u) > 1]



NAVY, GRAY_H, BODY, GRAY_B = '#1F3864', '#8C8C8C', '#F4F7FB', '#F0F0F0'
KEYC = {'PK': '#B22222', 'FK': '#1B6E20', 'UK': '#8A5A00'}
HIDE = {'created_at', 'updated_at', 'observaciones', 'password', 'last_login', 'is_superuser',
        'first_name', 'last_name', 'email', 'is_active', 'date_joined', 'imagen_url', 'video_url',
        'logo_url', 'descripcion', 'resumen', 'subtitulo', 'texto', 'cta_texto', 'cta_enlace',
        'etiqueta', 'alineacion', 'oscurecer', 'por_defecto', 'motivo_estado', 'fecha_estado',
        'longitud_mecha_nacimiento_cm', 'peso_nacimiento_kg', 'foto', 'imagen', 'video'}


def esc(s):
    return s.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')


def keys(t, c):
    ks = []
    if c['pk']:
        ks.append('PK')
    if c['name'] in t['fks']:
        ks.append('FK')
    if c['uk'] and not c['pk']:
        ks.append('UK')
    return ks


def visible(t, n_business, show=(), group=False):
    keyed = [c for c in t['cols'] if keys(t, c)]
    rest = [c for c in t['cols'] if not keys(t, c)]
    forced = [c for c in rest if c['name'] in show]
    cand = [c for c in rest if c['name'] not in HIDE and c not in forced]
    biz = forced + cand[:max(0, n_business - len(forced))]
    if group:  # configuracion_tienda: grupos por prefijo
        groups = {}
        for c in rest:
            groups.setdefault(c['name'].split('_')[0], []).append(c)
        biz = [{'name': (p + '_*') if len(g) > 1 else g[0]['name'],
                'type': f'{len(g)} col.' if len(g) > 1 else g[0]['type'],
                'pk': False, 'uk': False, 'null': False}
               for p, g in sorted(groups.items(), key=lambda kv: -len(kv[1]))][:n_business]
        hidden = len(rest) - sum(int(b['type'].split()[0]) if b['type'].endswith('col.') else 1 for b in biz)
    else:
        hidden = len(rest) - len(biz)
    order = {c['name']: i for i, c in enumerate(t['cols'])}
    shown = sorted(keyed + [b for b in biz if b['name'] in order], key=lambda c: order[c['name']])
    if group:
        shown = keyed + biz
    return shown, hidden


def node(name, n_business=5, ref=False, show=(), group=False):
    t = tables[name]
    if ref:
        cols = [c for c in t['cols'] if c['pk'] or c['name'] in show]
        hidden = 0
    else:
        cols, hidden = visible(t, n_business, show, group)
    head = GRAY_H if ref else NAVY
    body = GRAY_B if ref else BODY
    rows = [f'<TR><TD COLSPAN="3" BGCOLOR="{head}" CELLPADDING="5">'
            f'<FONT COLOR="white" POINT-SIZE="13"><B>{name}</B></FONT></TD></TR>']
    for c in cols:
        ks = keys(t, c) if c['name'] in {x['name'] for x in t['cols']} else []
        ktxt = ' '.join(f'<FONT COLOR="{KEYC[k]}"><B>{k}</B></FONT>' for k in ks) or ' '
        nm = esc(c['name']) + (' <I>(opt)</I>' if c['name'] in t['fks'] and c['null'] else '')
        rows.append(f'<TR><TD ALIGN="LEFT" BGCOLOR="{body}">{ktxt}</TD>'
                    f'<TD ALIGN="LEFT" BGCOLOR="{body}">{nm}</TD>'
                    f'<TD ALIGN="LEFT" BGCOLOR="{body}"><FONT COLOR="#767676" POINT-SIZE="10">{esc(c["type"])}</FONT></TD></TR>')
    if hidden > 0:
        rows.append(f'<TR><TD COLSPAN="3" ALIGN="LEFT" BGCOLOR="{body}"><FONT COLOR="#767676" POINT-SIZE="10">'
                    f'<I>… +{hidden} columnas</I></FONT></TD></TR>')
    if t['uniques'] and not ref:
        u = '; '.join('(' + ', '.join(x) + ')' for x in t['uniques'])
        rows.append(f'<TR><TD COLSPAN="3" ALIGN="LEFT" BGCOLOR="{body}"><FONT COLOR="{KEYC["UK"]}" POINT-SIZE="10">'
                    f'<B>UK</B> {esc(u)}</FONT></TD></TR>')
    label = (f'<<TABLE BORDER="1" COLOR="{head}" CELLBORDER="0" CELLSPACING="0" CELLPADDING="3">'
             + ''.join(rows) + '</TABLE>>')
    return f'  "{name}" [label={label}];'


def edges(names, refs):
    out = []
    for child in names:
        t = tables[child]
        for col, parent in t['fks'].items():
            if parent not in names or (child in refs and col not in refs[child]):
                continue
            c = next(x for x in t['cols'] if x['name'] == col)
            child_end = 'teeodot' if (c['uk'] or c['pk']) else 'crowodot'
            parent_end = 'teeodot' if c['null'] else 'teetee'
            attrs = (f'dir=both, arrowtail={parent_end}, arrowhead={child_end}, '
                     f'label=<<FONT POINT-SIZE="10" COLOR="#1B6E20">{col}</FONT>>')
            if child == parent:
                lab = 'padre_id / madre_id (opt)' if col == 'padre_id' else ''
                attrs = attrs.split(', label=')[0] + f', label=<<FONT POINT-SIZE="10" COLOR="#1B6E20">{lab}</FONT>>, tailport=w, headport=w'
            out.append(f'  "{parent}" -> "{child}" [{attrs}];')
    return out


def graph(fname, title, main, refs=None, rankdir='TB', extra='', group=(), n=5, show=None,
          nodesep=0.5, ranksep=0.7):
    refs = refs or {}
    show = show or {}
    lines = [f'digraph "{fname}" {{',
             f'  graph [rankdir={rankdir}, fontname="Helvetica", fontsize=20, labelloc=t, '
             f'nodesep={nodesep}, ranksep={ranksep}, pad=0.2, '
             'bgcolor=white, newrank=true];',
             '  node [shape=plain, fontname="Helvetica", fontsize=12];',
             '  edge [color="#555555", penwidth=1.2, arrowsize=1.0, fontname="Helvetica"];']
    for m in main:
        lines.append(node(m, 16 if m in group else n, group=m in group, show=show.get(m, ())))
    for r, only in refs.items():
        lines.append(node(r, ref=True, show=only))
    lines += edges(list(main) + list(refs), refs)
    lines.append(extra)
    lines.append('}')
    (OUT / f'{fname}.dot').write_text('\n'.join(lines), encoding='utf-8')
    print('ok', fname)


graph('e2_er_ganaderia', 'Diagrama Entidad-Relación — Módulo Ganadería (hato único)',
      ['usuarios', 'razas', 'animales', 'producciones', 'analisis_fibra', 'animales_en_venta', 'fotos_animal'], n=6,
      show={'usuarios': ['username', 'is_staff', 'rol'], 'animales': ['especie', 'sexo', 'fecha_nacimiento', 'raza', 'estado', 'sync_status'],
            'analisis_fibra': ['dmf', 'cv', 'desviacion_estandar', 'factor_confort', 'indice_curvatura', 'fecha_analisis']},
      extra='  {rank=same; usuarios; razas}\n  {rank=same; animales; animales_en_venta; fotos_animal}\n  {rank=same; producciones; analisis_fibra}\n'
            '  razas -> animales [style=dashed, arrowhead=none, label=<<FONT POINT-SIZE="10" COLOR="#767676">raza (texto, sin FK)</FONT>>];')
graph('e2_er_tienda1', 'Diagrama Entidad-Relación — Tienda Virtual (1/2): catálogo y trazabilidad',
      ['artesanos', 'lotes', 'procesos_lote', 'productos', 'imagenes_producto', 'variantes_producto',
       'precios_temporada'], n=4,
      refs={'animales': ['arete'], 'producciones': ['animal_id']},
      show={'variantes_producto': ['talla', 'color', 'tipo_prenda', 'precio_base', 'stock', 'stock_reservado'],
            'productos': ['nombre', 'categoria', 'unidad_venta', 'activo']},
      ranksep=0.55, extra='  {rank=same; animales; producciones; artesanos}\n  {rank=same; lotes; productos}\n  {rank=same; procesos_lote; imagenes_producto}\n  {rank=same; variantes_producto; precios_temporada}\n  procesos_lote -> variantes_producto [style=invis]; imagenes_producto -> precios_temporada [style=invis]')
graph('e2_er_tienda2', 'Diagrama Entidad-Relación — Tienda Virtual (2/2): pedidos, pagos y contenido informativo',
      ['pedidos', 'detalle_pedido', 'pagos', 'eventos_feria', 'publicaciones'], n=5,
      refs={'variantes_producto': ['sku'], 'usuarios': ['rol']},
      show={'pagos': ['metodo', 'comprobante_imagen', 'estado', 'fecha_confirmacion', 'huella_comprobante']},
      extra='  {rank=same; pedidos; variantes_producto; usuarios}\n  {rank=same; eventos_feria; publicaciones}\n'
            '  pagos -> eventos_feria [style=invis];')
# v1.4: los menús del navbar y del pie son modelos proxy de enlaces_navegacion
# (campo `ubicacion`), no tablas; se suman las tres tablas de la página «Conócenos».
graph('e2_er_cms', 'CMS', ['configuracion_tienda', 'pasos_proceso', 'cifras_inicio', 'enlaces_navegacion',
      'textos_interfaz', 'convenios', 'equipo', 'reconocimientos', 'bloques_inicio', 'diapositivas',
      'tarjetas_categoria', 'secciones_pagina'], n=4, group={'configuracion_tienda'}, rankdir='LR',
      nodesep=0.35, ranksep=0.6,
      show={'enlaces_navegacion': ['ubicacion', 'grupo', 'texto', 'enlace'],
            'reconocimientos': ['direccion', 'titulo', 'entidad', 'fecha']},
      extra='  {rank=same; configuracion_tienda; pasos_proceso; cifras_inicio}\n'
            '  {rank=same; enlaces_navegacion; textos_interfaz; convenios; equipo; reconocimientos}\n'
            '  {rank=same; bloques_inicio; diapositivas; tarjetas_categoria; secciones_pagina}\n'
            '  configuracion_tienda -> enlaces_navegacion -> bloques_inicio [style=invis];\n'
            '  configuracion_tienda -> pasos_proceso -> cifras_inicio [style=invis];\n'
            '  enlaces_navegacion -> textos_interfaz -> convenios -> equipo -> reconocimientos [style=invis];\n'
            '  bloques_inicio -> diapositivas -> tarjetas_categoria -> secciones_pagina [style=invis];')
