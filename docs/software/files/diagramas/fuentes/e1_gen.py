"""DOT de los diagramas de E1 (v1.2): componentes, C4, despliegue, clases y estados."""
from pathlib import Path

OUT = Path('src')
NAVY, BLUE_L, GREEN_L, AMBER_L, GRAY_L = '#1F3864', '#DCE6F4', '#E3F1E4', '#FCEFD9', '#EDEDED'
HEAD = ('  graph [fontname="Helvetica", fontsize=12, bgcolor=white, pad=0.2, {extra}];\n'
        '  node [fontname="Helvetica", fontsize=12];\n'
        '  edge [fontname="Helvetica", fontsize=10, color="#555555", penwidth=1.1];\n')


def esc(s):
    return s.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')


def write(name, body, extra='rankdir=TB, nodesep=0.5, ranksep=0.6'):
    (OUT / f'{name}.dot').write_text(f'digraph "{name}" {{\n' + HEAD.format(extra=extra) + body + '\n}\n',
                                     encoding='utf-8')
    print('ok', name)


def box(title, lines=(), stereo=''):
    st = f'<FONT POINT-SIZE="9" COLOR="#555555">{esc(stereo)}</FONT><BR/>' if stereo else ''
    ls = ''.join(f'<BR/><FONT POINT-SIZE="10">{esc(l)}</FONT>' for l in lines)
    return f'<{st}<B>{esc(title)}</B>{ls}>'


# ------------------------------------------------------------------ componentes
write('e1_componentes', f'''
  compound=true;
  node [shape=box, style="rounded,filled", fillcolor="{BLUE_L}", color="{NAVY}"];
  subgraph cluster_cli {{ label=<<B>Capa cliente</B>>; style="rounded,dashed"; color="#7F9CC7";
    app [label={box("App móvil GeneApp", ["Flutter 3.29 · Riverpod · GoRouter · Dio", "SQLite local (sqflite) + cola de sincronización"], "«componente»")}];
    nav [label={box("Navegador del comprador", ["tienda pública, sin cuenta"], "«cliente web»")}];
    navadm [label={box("Navegador del Administrador", ["panel de administración"], "«cliente web»")}];
  }}
  subgraph cluster_srv {{ label=<<B>Servidor en la nube (Docker Compose)</B>>; style=rounded; color="#5B9B5F"; bgcolor="#F7FBF7";
    nginx [label={box("Nginx", ["proxy reverso · SSL · /static", "/media público (fotos)", "comprobantes: ubicación interna"], "«componente»")}, fillcolor="{GREEN_L}", color="#2E6B33"];
    next [label={box("Tienda web", ["Next.js 15 · React 19 · Tailwind 4", "SSR + SEO · carrito persistente"], "«componente»")}, fillcolor="{GREEN_L}", color="#2E6B33"];
    subgraph cluster_dj {{ label=<<B>Backend Django 4.2 + Gunicorn</B>>; style=rounded; color="#2E6B33"; bgcolor="#EEF7EE";
      api [label={box("API REST /api/v1", ["Django REST Framework", "SimpleJWT · límites de peticiones"], "«componente»")}, fillcolor="{GREEN_L}", color="#2E6B33"];
      adm [label={box("Panel de administración", ["Django Admin + django-unfold", "backoffice del Administrador"], "«componente»")}, fillcolor="{GREEN_L}", color="#2E6B33"];
      docs [label={box("Documentación API", ["drf-spectacular · /api/docs"], "«componente»")}, fillcolor="{GREEN_L}", color="#2E6B33"];
      usr [shape=component, label={box("app usuarios", ["autenticación · roles"])}, fillcolor="{AMBER_L}", color="#8A5A00", style=filled];
      ani [shape=component, label={box("app animales", ["animales · esquilas · análisis", "árbol · consanguinidad · /sync/ · reportes"])}, fillcolor="{AMBER_L}", color="#8A5A00", style=filled];
      tie [shape=component, label={box("app tienda", ["catálogo · trazabilidad · pedidos", "pagos · ferias · contenido (CMS)"])}, fillcolor="{AMBER_L}", color="#8A5A00", style=filled];
      cmd [shape=component, label={box("Comandos programados", ["caducar_pedidos · respaldar"])}, fillcolor="{AMBER_L}", color="#8A5A00", style=filled];
    }}
    db [shape=cylinder, label={box("MySQL 8", ["base wawapacocha"])}, fillcolor="#FFE0B2", color="#B26A00", style=filled];
    media [shape=folder, label={box("Almacenamiento media", ["fotos (públicas)", "comprobantes (privados)"])}, fillcolor="#FFE0B2", color="#B26A00", style=filled];
  }}
  app -> nginx [label="HTTPS · JSON + JWT\\n/api/v1 · /sync/"];
  nav -> nginx [label="HTTPS"];
  navadm -> nginx [label="HTTPS · sesión"];
  nginx -> next [label="/"];
  nginx -> api [label="/api"];
  nginx -> adm [label="/admin"];
  next -> api [label="SSR · JSON", style=dashed];
  api -> usr; api -> ani; api -> tie; api -> docs [style=dashed, arrowhead=none];
  adm -> usr [style=dashed, label="gestiona"]; adm -> ani [style=dashed]; adm -> tie [style=dashed];
  cmd -> tie [style=dashed];
  usr -> db; ani -> db [label="ORM"]; tie -> db;
  tie -> media [style=dashed]; ani -> media [style=dashed];
  {{rank=same; app; nav; navadm}}
  {{rank=same; api; adm; docs}}
  {{rank=same; usr; ani; tie}}
  {{rank=same; cmd; media; db}}
''', extra='rankdir=TB, nodesep=0.35, ranksep=0.55, newrank=true')

# ------------------------------------------------------------------ C4
person = 'shape=box, style="rounded,filled", fillcolor="#08427B", fontcolor=white, color="#073B6F"'
cont = 'shape=box, style="rounded,filled", fillcolor="#438DD5", fontcolor=white, color="#3C7FC0"'
ext = 'shape=box, style="rounded,filled", fillcolor="#999999", fontcolor=white, color="#8A8A8A"'


def c4(title, kind, desc):
    return (f'<<B>{esc(title)}</B><BR/><FONT POINT-SIZE="9">[{esc(kind)}]</FONT>'
            + ''.join(f'<BR/><FONT POINT-SIZE="10">{esc(d)}</FONT>' for d in desc) + '>')


write('e1_c4', f'''
  cri [{person}, label={c4("Criador", "Persona", ["personal de campo", "registra el hato"])}];
  adm [{person}, label={c4("Administrador", "Persona", ["usuario único: gestiona", "usuarios, tienda y pagos"])}];
  com [{person}, label={c4("Comprador", "Persona", ["compra sin cuenta"])}];
  subgraph cluster_sys {{ label=<<B>Sistema Wawa Pacocha</B><BR/><FONT POINT-SIZE="9">[Sistema de software]</FONT>>; style="dashed,rounded"; color="#444444"; fontsize=13;
    app [{cont}, label={c4("App móvil GeneApp", "Contenedor: Flutter", ["registro del hato offline-first,", "árbol, esquilas, reportes"])}];
    web [{cont}, label={c4("Tienda web", "Contenedor: Next.js", ["catálogo, trazabilidad,", "pedidos y comprobantes"])}];
    pan [{cont}, label={c4("Panel de administración", "Contenedor: Django Admin", ["usuarios, catálogo, stock,", "pedidos, pagos, contenido"])}];
    api [{cont}, label={c4("API REST", "Contenedor: Django REST Framework", ["lógica de negocio, JWT,", "sincronización, reservas de stock"])}];
    db [{cont}, shape=cylinder, label={c4("Base de datos", "Contenedor: MySQL 8", ["hato, tienda y contenido"])}];
    med [{cont}, shape=folder, label={c4("Archivos subidos", "Contenedor: volumen media", ["fotos y comprobantes"])}];
  }}
  yape [{ext}, label={c4("Yape / Plin", "Sistema externo", ["billeteras digitales;", "pago manual, sin integración"])}];
  wsp [{ext}, label={c4("WhatsApp", "Sistema externo", ["coordinación opcional del pedido"])}];
  cri -> app [label="registra y consulta"];
  com -> web [label="compra y sigue su pedido"];
  adm -> pan [label="administra"];
  app -> api [label="JSON/HTTPS + JWT"];
  web -> api [label="JSON/HTTPS"];
  pan -> api [label="ORM y servicios", style=dashed];
  api -> db [label="lee y escribe (ORM)"];
  api -> med [label="guarda archivos"];
  com -> yape [label="transfiere el pago"];
  web -> wsp [label="envía el detalle (opcional)", style=dashed];
  {{rank=same; cri; com; adm}}
  {{rank=same; yape; wsp}}
''', extra='rankdir=TB, nodesep=0.45, ranksep=0.65, newrank=true')

# ------------------------------------------------------------------ despliegue
node3d = 'shape=box3d, style=filled, fillcolor="#DCE6F4", color="#1F3864"'
art = 'shape=note, style=filled, fillcolor="#FFFFFF", color="#555555"'
write('e1_despliegue', f'''
  subgraph cluster_and {{ label=<<B>«dispositivo» Smartphone Android 8+</B>>; style=filled; fillcolor="#EEF3FA"; color="#1F3864";
    apk [{art}, label={box("GeneApp.apk", ["Flutter"], "«artefacto»")}];
    sql [shape=cylinder, style=filled, fillcolor="#FFE0B2", color="#B26A00", label={box("SQLite local", ["cola de cambios"])}];
  }}
  subgraph cluster_pc {{ label=<<B>«dispositivo» PC / smartphone</B>>; style=filled; fillcolor="#EEF3FA"; color="#1F3864";
    bro [{art}, label={box("Navegador web", ["comprador o Administrador"], "«entorno»")}];
  }}
  subgraph cluster_vps {{ label=<<B>«nodo» Servidor VPS Ubuntu 22.04 (2 vCPU · 4 GB)</B>>; style=filled; fillcolor="#F4FAF4"; color="#2E6B33";
    subgraph cluster_dk {{ label=<<B>«entorno» Docker Compose</B>>; style="filled,rounded"; fillcolor="#E8F4E9"; color="#2E6B33";
      ngx [{node3d}, label={box("nginx:alpine", [":80 / :443 · Let's Encrypt", "proxy reverso · /static · /media", "/privado/ interna (comprobantes)"], "«contenedor»")}];
      fe [{node3d}, label={box("frontend", ["Next.js (Node.js) :3000"], "«contenedor»")}];
      be [{node3d}, label={box("backend", ["Django + Gunicorn :8000", "migrate y collectstatic al iniciar"], "«contenedor»")}];
      dbc [{node3d}, label={box("db", ["mysql:8.0 :3306"], "«contenedor»")}];
      v1 [shape=cylinder, style=filled, fillcolor="#FFE0B2", color="#B26A00", label="mysql_data"];
      v2 [shape=cylinder, style=filled, fillcolor="#FFE0B2", color="#B26A00", label="media_data"];
      v3 [shape=cylinder, style=filled, fillcolor="#FFE0B2", color="#B26A00", label="static_data"];
      v4 [shape=cylinder, style=filled, fillcolor="#FFE0B2", color="#B26A00", label="privado_data"];
    }}
    cron [{art}, label={box("Tareas programadas (diarias)", ["caducar_pedidos · respaldar"], "«cron»")}];
  }}
  bak [shape=box3d, style=filled, fillcolor="{GRAY_L}", color="#777777", label={box("Almacenamiento externo", ["copia cifrada de respaldos"], "«nodo»")}];
  apk -> sql [label="lee / escribe", dir=both];
  apk -> ngx [label="HTTPS 443 · JWT"];
  bro -> ngx [label="HTTPS 443"];
  ngx -> fe [label="HTTP /"];
  ngx -> be [label="HTTP /api · /admin"];
  fe -> be [label="HTTP (SSR)", style=dashed];
  be -> dbc [label="TCP 3306"];
  dbc -> v1 [style=dotted, arrowhead=none];
  be -> v2 [style=dotted, arrowhead=none]; ngx -> v2 [style=dotted, arrowhead=none];
  be -> v3 [style=dotted, arrowhead=none]; ngx -> v3 [style=dotted, arrowhead=none];
  be -> v4 [style=dotted, arrowhead=none]; ngx -> v4 [style=dotted, arrowhead=none];
  cron -> be [label="manage.py", style=dashed];
  cron -> bak [label="copia .zip", style=dashed];
  {{rank=same; fe; be}}
  {{rank=same; dbc; v1; v2; v3; v4}}
  {{rank=same; apk; sql}}
  dbc -> cron [style=invis];
  {{rank=same; cron; bak}}
''', extra='rankdir=TB, nodesep=0.35, ranksep=0.55, newrank=true')


# ------------------------------------------------------------------ clases
def cls(name, attrs=(), meths=(), stereo='', ref=False, enum=False):
    head = '#8C8C8C' if ref else ('#5B5B8F' if enum else NAVY)
    body = '#F2F2F2' if ref else ('#F3F3FA' if enum else '#F4F7FB')
    st = f'<FONT POINT-SIZE="9" COLOR="white">{esc(stereo)}</FONT><BR/>' if stereo else ''
    rows = [f'<TR><TD BGCOLOR="{head}" CELLPADDING="4">{st}<FONT COLOR="white"><B>{esc(name)}</B></FONT></TD></TR>']
    if attrs:
        rows.append('<TR><TD ALIGN="LEFT" BALIGN="LEFT" BGCOLOR="' + body + '">'
                    + '<BR/>'.join(f'<FONT POINT-SIZE="10">{esc(a)}</FONT>' for a in attrs) + '</TD></TR>')
    if meths:
        rows.append('<TR><TD ALIGN="LEFT" BALIGN="LEFT" BGCOLOR="' + body + '">'
                    + '<BR/>'.join(f'<FONT POINT-SIZE="10">{esc(m)}</FONT>' for m in meths) + '</TD></TR>')
    return (f'  "{name}" [shape=plain, label=<<TABLE BORDER="1" CELLBORDER="1" COLOR="{head}" CELLSPACING="0">'
            + ''.join(rows) + '</TABLE>>];')


def legend(items):
    rows = ['<TR><TD BGCOLOR="#5B5B8F" CELLPADDING="4"><FONT POINT-SIZE="9" COLOR="white">«enumeraciones»</FONT></TD></TR>']
    for n, vals in items:
        rows.append(f'<TR><TD ALIGN="LEFT" BGCOLOR="#F3F3FA"><FONT POINT-SIZE="10"><B>{esc(n)}</B>: {esc(", ".join(vals))}</FONT></TD></TR>')
    return ('  "Enumeraciones" [shape=plain, label=<<TABLE BORDER="1" CELLBORDER="1" COLOR="#5B5B8F" CELLSPACING="0">'
            + ''.join(rows) + '</TABLE>>];')


def rel(a, b, ta='', hb='', label='', kind='assoc'):
    """a -> b. kind: assoc, comp (rombo lleno en b), dep (punteada), self."""
    style = {'assoc': 'arrowhead=open, arrowsize=0.7',
             'comp': 'dir=back, arrowtail=diamond, arrowsize=1.1',
             'dep': 'style=dashed, arrowhead=open, arrowsize=0.7',
             'line': 'arrowhead=none'}[kind]
    if kind == 'comp':  # b es el todo: dibujar b -> a con rombo en b
        a, b, ta, hb = b, a, hb, ta
    lab = f', label=<<FONT POINT-SIZE="10">{esc(label)}</FONT>>' if label else ''
    return (f'  "{a}" -> "{b}" [{style}, taillabel="{ta}", headlabel="{hb}", '
            f'labeldistance=1.6, labelfontsize=10{lab}];')


g = [cls('Usuario', ['- telefono: str {único, login}', '- rol: RolUsuario', '- is_staff: bool',
                     '- created_at / updated_at: datetime'], ['+ administra_tienda(): bool'], '«AbstractUser»'),
     cls('Animal', ['- uid: UUID {único}', '- arete: str {único en el hato}', '- especie: Especie', '- sexo: Sexo',
                    '- fecha_nacimiento: date', '- nombre: str', '- raza: str', '- foto: Imagen',
                    '- estado: EstadoAnimal', '- fecha_estado: datetime', '- motivo_estado: str',
                    '- peso_nacimiento_kg: decimal', '- longitud_mecha_nacimiento_cm: decimal',
                    '- sync_status: SyncStatus', '- updated_at: datetime'],
         ['+ clean(): no es su propio padre/madre', '+ save(): registra fecha_estado', '+ /categoria_edad: str',
          '+ /edad_detallada: str']),
     cls('Produccion', ['- uid: UUID {único}', '- numero_esquila: int', '- fecha_esquila: date',
                        '- peso_vellon_lb: decimal', '- longitud_mecha_cm: decimal', '- observaciones: str',
                        '- sync_status: SyncStatus'], stereo='esquila'),
     cls('AnalisisFibra', ['- dmf: decimal (µm)', '- cv: decimal (%)', '- desviacion_estandar: decimal (µm)',
                           '- factor_confort: decimal (%)', '- indice_curvatura: decimal (°/mm)',
                           '- fecha_analisis: date', '- observaciones: str']),
     cls('Raza', ['- nombre: str', '- especie: Especie', '{único: nombre + especie}']),
     cls('FotoAnimal', ['- imagen: Imagen', '- descripcion: str', '- orden: int'], stereo='galería'),
     cls('ServiciosGenealogia', [], ['+ build_tree(animal, ≤ 3 generaciones): dict',
                                     '+ calcular_coi(padre, madre, max_depth = 3): COI'], '«servicio»'),
     legend([('RolUsuario', ['ADMINISTRADOR', 'CRIADOR']), ('Especie', ['ALPACA', 'LLAMA', 'OVINO']), ('Sexo', ['HEMBRA', 'MACHO']), ('EstadoAnimal', ['VIVO', 'VENDIDO', 'MUERTO']), ('SyncStatus', ['PENDIENTE', 'SINCRONIZADO', 'ERROR'])]),
     rel('Animal', 'Usuario', '0..*', '1', 'registrado por'),
     rel('Animal', 'Animal', '0..*', '0..1', 'padre / madre'),
     rel('Produccion', 'Animal', '0..*', '1', kind='comp'),
     rel('AnalisisFibra', 'Produccion', '0..1', '1', kind='comp'),
     rel('FotoAnimal', 'Animal', '0..*', '1', kind='comp'),
     rel('Animal', 'Raza', '', '', 'raza (catálogo)', kind='dep'),
     rel('ServiciosGenealogia', 'Animal', '', '', '«usa»', kind='dep'),
     '  {rank=same; ServiciosGenealogia; Enumeraciones}',
     '  {rank=same; Usuario; Raza}']
write('e1_clases_ganaderia', '\n'.join(g), extra='rankdir=TB, nodesep=0.4, ranksep=0.55, newrank=true')

t1 = [cls('Artesano', ['- nombre: str', '- contacto: str', '- localidad: str', '- activo: bool']),
      cls('Lote', ['- codigo_lote: str {único}', '- tipo_fibra: TipoFibra', '- fecha_ingreso: date',
                   '- cantidad_kg: decimal'], ['+ clean(): especie del animal = tipo_fibra;', '  esquila del mismo animal']),
      cls('ProcesoLote', ['- etapa: EtapaProceso', '- orden_secuencia: int', '- fecha_proceso: date',
                          '- observaciones: str', '{único: lote + orden}']),
      cls('Producto', ['- nombre: str', '- slug: str {único}', '- descripcion: str',
                       '- categoria: CategoriaProducto', '- unidad_venta: UnidadVenta', '- imagen_principal: Imagen', '- activo: bool',
                       '- destacado: bool', '- orden: int'], ['+ /tiene_stock: bool', '+ /precio_desde: decimal']),
      cls('ImagenProducto', ['- imagen: Imagen', '- orden: int']),
      cls('VarianteProducto', ['- talla: str', '- color: str', '- tipo_prenda: str', '- sku: str {único}',
                               '- precio_base: decimal', '- stock: int', '- stock_reservado: int {≤ stock}'],
          ['+ /stock_disponible: int', '+ /temporada_vigente: PrecioTemporada', '+ /precio_vigente: decimal']),
      cls('PrecioTemporada', ['- nombre_temporada: str', '- precio_especial: decimal', '- fecha_inicio: date',
                              '- fecha_fin: date {≥ inicio}', '- activo: bool']),
      cls('Animal', ['- arete', '- especie', '- raza'], stereo='«ganadería»', ref=True),
      cls('Produccion', ['- numero_esquila', '- fecha_esquila'], ['+ analisis: AnalisisFibra'], '«ganadería»', ref=True),
      legend([('CategoriaProducto', ['FIBRA', 'ARTESANAL', 'SEMI_INDUSTRIAL']), ('EtapaProceso', ['CLASIFICACION', 'LAVADO', 'ESCARMENADO', 'PEINADO']), ('', ['HILADO', 'EMPAREJADO', 'TORCIDO', 'ENCONADO']), ('TipoFibra', ['ALPACA', 'LLAMA', 'OVINO']), ('UnidadVenta', ['UNIDAD', 'KG', 'LB', 'MADEJA', 'OVILLO', 'ROLLO'])]),
      rel('Lote', 'Animal', '0..*', '0..1', 'animal de origen'),
      rel('Lote', 'Produccion', '0..*', '0..1', 'esquila de origen'),
      rel('ProcesoLote', 'Lote', '0..*', '1', kind='comp'),
      rel('Producto', 'Lote', '0..*', '0..1', 'trazabilidad'),
      rel('Producto', 'Artesano', '0..*', '0..1', 'confeccionado por'),
      rel('ImagenProducto', 'Producto', '0..*', '1', kind='comp'),
      rel('VarianteProducto', 'Producto', '1..*', '1', kind='comp'),
      rel('PrecioTemporada', 'VarianteProducto', '0..*', '1', kind='comp'),
      '  {rank=same; Animal; Produccion; Artesano}',
      '  {rank=same; Producto; Enumeraciones}']
write('e1_clases_tienda1', '\n'.join(t1), extra='rankdir=TB, nodesep=0.4, ranksep=0.55, newrank=true')

t2 = [cls('Pedido', ['- codigo: str {único, WP-#####}', '- cliente_nombre: str', '- cliente_contacto: str',
                     '- cliente_referencia: str', '- estado: EstadoPedido', '- total: decimal',
                     '- motivo_comprobante: str', '- created_at: datetime'], ['+ /reserva_expira: datetime']),
      cls('DetallePedido', ['- cantidad: int {> 0}', '- precio_unitario: decimal {histórico}'],
          ['+ /subtotal: decimal']),
      cls('Pago', ['- metodo: MetodoPago', '- comprobante_imagen: Imagen {privada}', '- estado: EstadoPago',
                   '- fecha_confirmacion: datetime', '- observaciones_admin: str',
                   "- gateway_transaccion_id: str {'' hasta integrar pasarela}",
                   '- huella_comprobante: str {SHA-256}'], ['+ comprobantes_iguales(): Pago[*]', '+ /url_comprobante: vista protegida']),
      cls('ServiciosPedido', [], ['+ crear_pedido(cliente, items): Pedido', '+ registrar_pago(pedido, metodo, comprobante)',
                                  '+ confirmar_pago(pago, usuario)', '+ rechazar_pago(pago, usuario)',
                                  '+ pedir_otro_comprobante(pago, motivo)', '+ marcar_entregado(pedido)',
                                  '+ cancelar_pedido(pedido)', '+ liberar_reserva(pedido)'], '«servicio» tienda/services.py'),
      cls('AnimalEnVenta', ['- precio: decimal', '- proposito: reproductor | cria | fibra', '- titulo: str',
                            '- descripcion: str', '- imagen: Imagen', '- destacado: bool', '- orden: int',
                            '- estado: no_en_venta | disponible | reservado | vendido']),
      cls('ConfiguracionTienda', ['- horas_reserva: int = 48', '- telefono_yape / telefono_plin: str',
                                  '- pedido_por_whatsapp: bool', '- tema_temporada · mapa_* · nosotros_*', '- … portada, SEO, trazabilidad'],
          stereo='«singleton» id = 1'),
      cls('EventoFeria', ['- titulo, fecha_evento, fecha_fin', '- ubicacion, enlace, destacado']),
      cls('Publicacion', ['- titulo, resumen, fuente', '- medio, fecha, enlace']),
      cls('VarianteProducto', ['- sku', '- stock', '- stock_reservado'], stereo='«tienda 1/2»', ref=True),
      cls('Usuario', ['- rol = ADMINISTRADOR'], stereo='«ganadería»', ref=True),
      cls('Animal', ['- arete', '- padre / madre'], ['+ producciones → análisis'], '«ganadería»', ref=True),
      legend([('EstadoPedido', ['PENDIENTE', 'PAGADO', 'ENTREGADO', 'CANCELADO']), ('EstadoPago', ['PENDIENTE', 'CONFIRMADO', 'RECHAZADO']), ('MetodoPago', ['YAPE', 'PLIN'])]),
      rel('DetallePedido', 'Pedido', '1..*', '1', kind='comp'),
      rel('DetallePedido', 'VarianteProducto', '0..*', '1'),
      rel('Pago', 'Pedido', '0..1', '1', kind='comp'),
      rel('Pago', 'Usuario', '0..*', '0..1', 'confirmado_por'),
      rel('AnimalEnVenta', 'Animal', '0..1', '1', 'publica (sin copiar datos)'),
      rel('ServiciosPedido', 'Pedido', '', '', '«gestiona»', kind='dep'),
      rel('ServiciosPedido', 'VarianteProducto', '', '', 'reserva / descuenta stock', kind='dep'),
      rel('ServiciosPedido', 'ConfiguracionTienda', '', '', 'horas_reserva', kind='dep'),
      '  {rank=same; Pedido; AnimalEnVenta}',
      '  {rank=same; ServiciosPedido; Enumeraciones}',
      '  {rank=same; Usuario; VarianteProducto; EventoFeria; Publicacion}',
      '  Animal -> EventoFeria [style=invis];']
write('e1_clases_tienda2', '\n'.join(t2), extra='rankdir=TB, nodesep=0.35, ranksep=0.55, newrank=true')

# ------------------------------------------------------------------ estados
st = 'shape=box, style="rounded,filled", fillcolor="#DCE6F4", color="#1F3864", fontsize=13'
write('e1_estados_pedido', f'''
  ini [shape=circle, style=filled, fillcolor=black, label="", width=0.22];
  fin [shape=doublecircle, style=filled, fillcolor=black, label="", width=0.16];
  pen [{st}, label=<<B>Pendiente</B><BR/><FONT POINT-SIZE="10">stock reservado · espera comprobante</FONT>>];
  pag [{st}, label=<<B>Pagado</B><BR/><FONT POINT-SIZE="10">stock físico descontado</FONT>>];
  ent [{st}, label=<<B>Entregado</B>>];
  can [{st}, fillcolor="#F6DADA", color="#9B2C2C", label=<<B>Cancelado</B><BR/><FONT POINT-SIZE="10">reserva liberada</FONT>>];
  ini -> pen [label="Comprador genera el pedido\\n[stock disponible] / reserva unidades, código WP-#####"];
  pen -> pen [label="sube comprobante / pago pendiente\\nAdmin pide otro comprobante / guarda motivo"];
  pen -> pag [label="Admin confirma el pago\\n/ stock −= cantidad, reservado −= cantidad"];
  pen -> can [label="Admin rechaza el comprobante,\\nel comprador cancela o vence la reserva\\n(horas_reserva, caducar_pedidos) / libera stock"];
  pag -> ent [label="Admin marca entregado"];
  ent -> fin; can -> fin;
  {{rank=same; pag; can}}
''', extra='rankdir=TB, nodesep=1.2, ranksep=0.6')


