"""Diagramas de E1 (v1.3, actualizados en v1.4): navegación, C4 (C1, C2, C3 x2), estados y capas."""
import json
from pathlib import Path

OUT = Path('src')
IMG = Path('img').resolve()
NAVY = '#1F3864'
HEAD = ('  graph [fontname="Helvetica", fontsize=12, bgcolor=white, pad=0.2, {extra}];\n'
        '  node [fontname="Helvetica", fontsize=12];\n'
        '  edge [fontname="Helvetica", fontsize=10, color="#555555", penwidth=1.1];\n')


def esc(s):
    return s.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')


def write(name, body, extra='rankdir=TB, nodesep=0.5, ranksep=0.6', images=None):
    (OUT / f'{name}.dot').write_text(f'digraph "{name}" {{\n' + HEAD.format(extra=extra) + body + '\n}\n',
                                     encoding='utf-8')
    side = OUT / f'{name}.images.json'
    if images:
        side.write_text(json.dumps(images), encoding='utf-8')
    elif side.exists():
        side.unlink()
    print('ok', name)


def lab(title, lines=(), stereo='', fs=10):
    st = f'<FONT POINT-SIZE="9" COLOR="#555555">{esc(stereo)}</FONT><BR/>' if stereo else ''
    ls = ''.join(f'<BR/><FONT POINT-SIZE="{fs}">{esc(l)}</FONT>' for l in lines)
    return f'<{st}<B>{esc(title)}</B>{ls}>'


# ------------------------------------------------------------------ navegación
def screen(nid, title, sub='', shot=None, w=0, h=0, planned=False, fill='#EAF0FA'):
    color = '#999999' if planned else NAVY
    style = 'dashed' if planned else 'solid'
    if shot:
        uri = (IMG / shot).as_uri()
        img = (f'<TR><TD FIXEDSIZE="TRUE" WIDTH="{w}" HEIGHT="{h}" BGCOLOR="white"><IMG SRC="{uri}" SCALE="TRUE"/></TD></TR>')
        images.append({'name': uri, 'width': f'{w}px', 'height': f'{h}px'})
    else:
        img = ''
    subtxt = f'<BR/><FONT POINT-SIZE="9" COLOR="#444444">{esc(sub)}</FONT>' if sub else ''
    return (f'  {nid} [shape=plain, label=<<TABLE BORDER="1" STYLE="rounded" COLOR="{color}" CELLBORDER="0" '
            f'CELLSPACING="0" CELLPADDING="5" BGCOLOR="{fill}">{img}<TR><TD><B>{esc(title)}</B>{subtxt}</TD></TR></TABLE>>'
            + (', style=dashed' if planned else '') + '];')


images = []
mov = [
    screen('login', 'Login', 'teléfono + contraseña'),
    screen('reg', 'Registro', 'teléfono, nombre, contraseña'),
    screen('dash', 'Dashboard', 'resumen del hato · barra inferior · franja de estado'),
    screen('sync', 'Sincronización', 'pendientes, rechazados · Sincronizar ahora'),
    screen('lista', 'Animales', 'lista, filtros, búsqueda', 'shot1.png', 75, 160),
    screen('form', 'Formulario de animal', 'crear / editar · padres · alerta COI'),
    screen('coi', 'Diálogo de consanguinidad', 'si COI ≥ 6,25 %: confirmar'),
    screen('det', 'Detalle del animal', 'datos, esquilas, acciones', 'shot2.png', 75, 160),
    screen('arbol', 'Árbol genealógico', 'hasta 3 generaciones', 'shot3.png', 75, 160),
    screen('esq', 'Hoja de esquila', 'número, fecha, peso, mecha'),
    screen('ana', 'Hoja de análisis de fibra', 'DMF, CV, DE, confort, curvatura'),
    screen('rep', 'Reportes', 'CSV / PDF · compartir'),
    screen('per', 'Perfil', 'datos del usuario · cerrar sesión'),
]
write('e1_nav_movil', '\n'.join(mov) + '''
  login -> reg [label="crear cuenta", dir=both];
  login -> dash [label="JWT válido o sesión guardada"];
  dash -> lista [label="pestaña Animales"];
  dash -> rep [label="pestaña Reportes"];
  dash -> per [label="pestaña Perfil"];
  dash -> sync [label="franja de estado"];
  per -> sync [label="Sincronización"];
  lista -> form [label="botón +"];
  lista -> det [label="tocar animal"];
  det -> form [label="editar"];
  det -> arbol [label="ver árbol"];
  det -> esq [label="registrar esquila"];
  esq -> ana [label="análisis (por esquila)"];
  form -> coi [label="al guardar", style=dashed];
  per -> login [label="cerrar sesión", style=dashed, constraint=false];
  {rank=same; lista; rep; per}
  {rank=same; form; det}
''', extra='rankdir=TB, nodesep=0.45, ranksep=0.55, newrank=true', images=images)

images = []
tie = [
    screen('ini', 'Inicio', 'portada editable (carrusel, cifras, destacados)'),
    screen('cat', 'Catálogo', 'filtros: categoría, talla, color, fibra, artesano', 'shot4.png', 170, 133),
    screen('prod', 'Ficha de producto', 'variantes, stock, precio, trazabilidad', 'shot5.png', 170, 119),
    screen('car', 'Carrito', 'persistente en el navegador'),
    screen('chk', 'Checkout', 'nombre, teléfono, Yape/Plin · sin cuenta', 'shot6.png', 170, 120),
    screen('ped', 'Mi pedido', 'código WP-#####, estado, motivo'),
    screen('pago', 'Pago', 'número Yape/Plin · subir comprobante'),
    screen('ani', 'Animales en venta', 'reproductores, crías, fibra'),
    screen('anid', 'Ficha del animal', 'genealogía + análisis de fibra'),
    screen('fer', 'Ferias y prensa', 'próximas e historial'),
    screen('seg', 'Seguimiento', 'buscar por código + teléfono'),
    '  wsp [shape=box, style="rounded,filled,dashed", fillcolor="#EDEDED", color="#888888", label=<<B>WhatsApp</B><BR/><FONT POINT-SIZE="9">externo, opcional</FONT>>];',
]
write('e1_nav_tienda', '\n'.join(t.replace('\\n', '<BR/>') for t in tie) + '''
  ini -> cat [label="menú / mosaicos"];
  ini -> ani [label="menú"];
  ini -> fer [label="menú"];
  ini -> seg [label="menú"];
  cat -> prod [label="elegir producto"];
  prod -> car [label="agregar variante"];
  car -> chk [label="finalizar compra"];
  chk -> ped [label="pedido creado\\n(stock reservado)"];
  ped -> pago [label="pagar"];
  pago -> ped [label="comprobante enviado", constraint=false];
  seg -> ped [label="pedido encontrado"];
  ani -> anid [label="ver animal"];
  anid -> wsp [label="consultar", style=dashed];
  chk -> wsp [label="detalle del pedido", style=dashed];
  {rank=same; cat; ani; fer; seg}
''', extra='rankdir=TB, nodesep=0.35, ranksep=0.5, newrank=true', images=images)

# ------------------------------------------------------------------ C4
P = 'shape=box, style="rounded,filled", fillcolor="#08427B", fontcolor=white, color="#073B6F"'
S = 'shape=box, style="rounded,filled", fillcolor="#1168BD", fontcolor=white, color="#0B4884"'
C = 'shape=box, style="rounded,filled", fillcolor="#438DD5", fontcolor=white, color="#3C7FC0"'
K = 'shape=box, style="rounded,filled", fillcolor="#85BBF0", fontcolor="#0B2A4A", color="#5D99D6"'
X = 'shape=box, style="rounded,filled", fillcolor="#999999", fontcolor=white, color="#8A8A8A"'
PL = 'shape=box, style="rounded,filled,dashed", fillcolor="#DCEBFA", fontcolor="#0B2A4A", color="#5D99D6"'


def c4(title, kind, desc=()):
    return (f'<<B>{esc(title)}</B><BR/><FONT POINT-SIZE="9">[{esc(kind)}]</FONT>'
            + ''.join(f'<BR/><FONT POINT-SIZE="10">{esc(d)}</FONT>' for d in desc) + '>')


write('e1_c4_c1', f'''
  cri [{P}, label={c4("Criador", "Persona", ["personal de campo:", "registra y consulta el hato"])}];
  adm [{P}, label={c4("Administrador", "Persona", ["usuario único: usuarios,", "tienda, pagos y monitoreo"])}];
  com [{P}, label={c4("Comprador", "Persona externa", ["compra sin crear cuenta"])}];
  sis [{S}, fontsize=14, label={c4("Sistema Wawa Pacocha", "Sistema de software", ["registro genealógico del ganado,", "esquilas y análisis de fibra,", "tienda con trazabilidad y pago manual"])}];
  yape [{X}, label={c4("Yape / Plin", "Sistema externo", ["billeteras digitales;", "sin integración automática"])}];
  wsp [{X}, label={c4("WhatsApp", "Sistema externo", ["coordinación opcional"])}];
  bak [{X}, label={c4("Almacenamiento externo", "Sistema externo", ["copia cifrada de respaldos"])}];
  cri -> sis [label="registra animales, esquilas,\\nanálisis; sincroniza"];
  adm -> sis [label="administra usuarios, catálogo,\\npedidos y pagos"];
  com -> sis [label="consulta catálogo y trazabilidad,\\ngenera y sigue pedidos"];
  com -> yape [label="transfiere el pago"];
  sis -> wsp [label="envía el detalle del pedido", style=dashed];
  sis -> bak [label="copia diaria", style=dashed];
  {{rank=same; cri; adm; com}}
  {{rank=same; yape; wsp; bak}}
''', extra='rankdir=TB, nodesep=0.6, ranksep=0.9, newrank=true')

write('e1_c4_c2', f'''
  cri [{P}, label={c4("Criador", "Persona")}];
  com [{P}, label={c4("Comprador", "Persona")}];
  adm [{P}, label={c4("Administrador", "Persona")}];
  subgraph cluster_and {{ label=<<B>Smartphone Android 8+</B><BR/><FONT POINT-SIZE="9">[Nodo de despliegue]</FONT>>; style="dashed"; color="#555555";
    app [{C}, label={c4("App móvil GeneApp", "Contenedor: Flutter / Dart", ["UI, estado y llamadas a la API"])}];
    sql [{C}, shape=cylinder, label={c4("Base local", "Contenedor: SQLite (sqflite)", ["datos offline + cola de cambios"])}];
  }}
  subgraph cluster_nav {{ label=<<B>Navegador web</B><BR/><FONT POINT-SIZE="9">[Nodo de despliegue]</FONT>>; style="dashed"; color="#555555";
    br [{K}, label={c4("Páginas de la tienda y del panel", "HTML / JS en el navegador")}];
  }}
  subgraph cluster_vps {{ label=<<B>Servidor VPS Ubuntu 22.04 · Docker Compose</B><BR/><FONT POINT-SIZE="9">[Nodo de despliegue: 2 vCPU, 4 GB]</FONT>>; style="dashed"; color="#555555";
    ngx [{C}, label={c4("Proxy inverso", "Contenedor: Nginx :80/:443", ["SSL Let's Encrypt · /static · /media", "/privado/: ubicación interna"])}];
    web [{C}, label={c4("Tienda web", "Contenedor: Next.js 15 :3000", ["SSR + SEO, carrito, checkout,", "seguimiento del pedido"])}];
    api [{C}, label={c4("API REST + Panel", "Contenedor: Django 4.2 + DRF + Gunicorn :8000", ["JWT, reglas de negocio, sincronización,", "reservas de stock, admin django-unfold"])}];
    db [{C}, shape=cylinder, label={c4("Base de datos", "Contenedor: MySQL 8 :3306", ["31 tablas: hato, tienda y CMS"])}];
    med [{C}, shape=folder, label={c4("Archivos públicos", "Volumen media_data", ["fotos y videos"])}];
    prv [{C}, shape=folder, label={c4("Comprobantes de pago", "Volumen privado_data", ["sin URL pública; solo vía el panel"])}];
    cron [{K}, label={c4("Tareas diarias", "cron: manage.py", ["caducar_pedidos · respaldar"])}];
  }}
  cri -> app [label="usa"];
  com -> br [label="usa"]; adm -> br [label="usa"];
  app -> sql [label="lee / escribe"];
  app -> ngx [label="JSON/HTTPS + JWT\\n/api/v1 · /sync/"];
  br -> ngx [label="HTTPS"];
  ngx -> web [label="/"];
  ngx -> api [label="/api · /admin"];
  web -> api [label="JSON (SSR)", style=dashed];
  api -> db [label="ORM / TCP 3306"];
  api -> med [label="guarda y lee archivos"];
  api -> prv [label="guarda; entrega con X-Accel-Redirect"];
  cron -> api [label="ejecuta comandos", style=dashed];
  {{rank=same; cri; com; adm}}
''', extra='rankdir=TB, nodesep=0.4, ranksep=0.6, newrank=true')

write('e1_c4_c3_api', f'''
  compound=true;
  app [{C}, label={c4("App móvil", "Contenedor: Flutter")}];
  br [{C}, label={c4("Navegador del Administrador", "Panel /admin")}];
  web [{C}, label={c4("Tienda web", "Contenedor: Next.js")}];
  subgraph cluster_api {{ label=<<B>API REST + Panel</B><BR/><FONT POINT-SIZE="9">[Contenedor: Django 4.2 + DRF]</FONT>>; style="dashed"; color="#333333"; fontsize=13;
    subgraph cluster_gan {{ label=<<B>Módulo ganadería</B> (apps usuarios y animales)>; style="rounded"; color="#5D99D6";
      auth [{K}, label={c4("Autenticación", "usuarios.views + SimpleJWT", ["register · login · refresh (rotación)", "logout (lista negra) · perfil"])}];
      ani [{K}, label={c4("Animales y genealogía", "AnimalViewSet", ["CRUD · árbol · candidatos", "consanguinidad · resumen"])}];
      esq [{K}, label={c4("Esquilas y análisis", "ProduccionViewSet", ["esquilas · análisis de fibra 1:1"])}];
      syn [{K}, label={c4("Sincronización", "SyncView  POST /sync/", ["valida cada cambio (serializers)", "procesados / rechazados · análisis"])}];
      rep [{K}, label={c4("Reportes", "ReporteView · ReporteProduccionView", ["CSV y PDF (ReportLab)"])}];
      gen [{K}, label={c4("Cálculos genealógicos", "animales/utils.py", ["calcular_coi · edad y categoría"])}];
    }}
    pan [{K}, label={c4("Panel de administración", "admin_site · admin · dashboard", ["backoffice con django-unfold"])}];
    subgraph cluster_tie {{ label=<<B>Módulo tienda</B> (app tienda)>; style="rounded"; color="#5D99D6";
      cat [{K}, label={c4("Catálogo público", "ProductoViewSet · FiltrosView", ["ferias · animales en venta", "artesanos · configuración"])}];
      ped [{K}, label={c4("Pedidos y pagos", "PedidoViewSet", ["crear · consultar · buscar", "comprobante · cancelar"])}];
      svc [{K}, label={c4("Servicios de pedido", "tienda/services.py", ["reserva y descuento de stock,", "confirmar / rechazar (transacción)"])}];
      cmd [{K}, label={c4("Comandos", "management/commands", ["caducar_pedidos · respaldar"])}];
      cmp [{K}, label={c4("Vista de comprobantes", "PagoAdmin.ver_comprobante", ["solo Administrador", "X-Accel-Redirect"])}];
    }}
    orm [{K}, label={c4("Modelos (ORM)", "usuarios · animales · tienda", ["validaciones de dominio"])}];
  }}
  db [{C}, shape=cylinder, label={c4("Base de datos", "MySQL 8")}];
  med [{C}, shape=folder, label={c4("Comprobantes", "almacenamiento privado")}];
  app -> auth [label="JSON + JWT"]; app -> ani; app -> syn;
  web -> cat [label="JSON"]; web -> ped;
  br -> pan [label="sesión"];
  ani -> gen; ped -> svc; cmd -> svc; pan -> svc [label="confirma pagos"]; pan -> cmp;
  rep -> orm [ltail=cluster_gan, label="ORM"];
  svc -> orm [ltail=cluster_tie, label="ORM"];
  pan -> orm;
  orm -> db [label="SQL"]; cmp -> med;
  ani -> esq [style=invis]; auth -> rep [style=invis]; esq -> rep [style=invis];
  rep -> pan [style=invis]; gen -> pan [style=invis]; pan -> cmd [style=invis]; pan -> cat [style=invis];
  cmd -> cmp [style=invis]; cat -> svc [style=invis];
''', extra='rankdir=TB, nodesep=0.3, ranksep=0.45')
write('e1_c4_c3_flutter', f'''
  cri [{P}, label={c4("Criador", "Persona")}];
  subgraph cluster_app {{ label=<<B>App móvil GeneApp</B><BR/><FONT POINT-SIZE="9">[Contenedor: Flutter 3.29 / Dart 3.8]</FONT>>; style="dashed"; color="#333333"; fontsize=13;
    ui [{K}, label={c4("Pantallas", "ui/features/*/views", ["auth · dashboard · animales · árbol", "esquilas · análisis · reportes · perfil", "sincronización"])}];
    rt [{K}, label={c4("Navegación", "routes/app_router.dart · GoRouter", ["redirección según la sesión"])}];
    pv [{K}, label={c4("Estado", "Riverpod providers", ["authProvider · animalProvider", "perfilProvider · syncProvider"])}];
    rp [{K}, label={c4("Repositorios", "data/repositories", ["AuthRepository · AnimalRepository (API)", "HatoRepository (offline-first)"])}];
    md [{K}, label={c4("Modelos", "data/models", ["Animal · Produccion · AnalisisFibra", "Consanguinidad · User"])}];
    api [{K}, label={c4("Cliente HTTP", "data/services/api_service.dart · Dio", ["interceptor JWT con renovación del token"])}];
    sec [{K}, label={c4("Almacén seguro", "flutter_secure_storage", ["access y refresh token"])}];
    loc [{K}, label={c4("Base local", "local_store.dart · sqflite", ["animales, esquilas, análisis + sync_status"])}];
    gen [{K}, label={c4("Cálculos genealógicos", "genealogia.dart", ["COI · árbol · edad, sin red"])}];
    syn [{K}, label={c4("Servicio de sincronización", "sync_service.dart", ["pendientes · rechazados · last_sync", "connectivity_plus"])}];
  }}
  back [{C}, label={c4("API REST", "Contenedor: Django + DRF")}];
  share [{X}, label={c4("Compartir del sistema", "share_plus", ["envía CSV / PDF"])}];
  cri -> ui [label="usa"];
  ui -> rt; ui -> pv; pv -> rp; rp -> md; rp -> api; api -> sec;
  rp -> loc; rp -> gen; rp -> syn; syn -> loc; syn -> api;
  api -> back [label="JSON/HTTPS + JWT"];
  ui -> share [label="reportes", style=dashed];
''', extra='rankdir=TB, nodesep=0.35, ranksep=0.5, newrank=true')

# ------------------------------------------------------------------ estados
st = 'shape=box, style="rounded,filled", fillcolor="#DCE6F4", color="#1F3864", fontsize=13'
ini = '  ini [shape=circle, style=filled, fillcolor=black, label="", width=0.22];\n  fin [shape=doublecircle, style=filled, fillcolor=black, label="", width=0.16];\n'
write('e1_estados_animal', ini + f'''
  vivo [{st}, label=<<B>Vivo</B><BR/><FONT POINT-SIZE="10">en el hato · puede ser padre/madre</FONT>>];
  vend [{st}, label=<<B>Vendido</B><BR/><FONT POINT-SIZE="10">baja lógica · conserva genealogía</FONT>>];
  muer [{st}, fillcolor="#F6DADA", color="#9B2C2C", label=<<B>Muerto</B><BR/><FONT POINT-SIZE="10">baja lógica · conserva genealogía</FONT>>];
  ini -> vivo [label="Criador registra el animal\\n/ fecha_estado = ahora"];
  vivo -> vend [label="cambio de estado con motivo\\n(o DELETE) / fecha_estado"];
  vivo -> muer [label="cambio de estado con motivo\\n/ fecha_estado"];
  vend -> vivo [label="corrección / fecha_estado", style=dashed];
  muer -> vivo [label="corrección / fecha_estado", style=dashed];
  vend -> fin; muer -> fin;
  {{rank=same; vend; muer}}
''', extra='rankdir=TB, nodesep=1.4, ranksep=0.7')

write('e1_estados_pago', ini + f'''
  pen [{st}, label=<<B>Pendiente</B><BR/><FONT POINT-SIZE="10">comprobante en revisión</FONT>>];
  con [{st}, label=<<B>Confirmado</B><BR/><FONT POINT-SIZE="10">inmutable · pedido pagado</FONT>>];
  rec [{st}, fillcolor="#F6DADA", color="#9B2C2C", label=<<B>Rechazado</B><BR/><FONT POINT-SIZE="10">pedido cancelado · stock liberado</FONT>>];
  dsc [{st}, fillcolor="#FFF4E0", color="#B26A00", label=<<B>Descartado</B><BR/><FONT POINT-SIZE="10">se borra la captura · pedido sigue pendiente</FONT>>];
  ini -> pen [label="Comprador sube comprobante\\n[pedido pendiente] / valida imagen"];
  pen -> con [label="Admin confirma\\n/ descuenta stock, guarda confirmado_por"];
  pen -> rec [label="Admin rechaza\\n/ motivo, cancela pedido"];
  pen -> dsc [label="Admin pide otro comprobante\\n/ guarda motivo en el pedido"];
  dsc -> ini [label="el comprador puede subir\\nuno nuevo", style=dashed, constraint=false];
  con -> fin; rec -> fin;
  {{rank=same; con; rec; dsc}}
''', extra='rankdir=TB, nodesep=0.8, ranksep=0.8')

# ------------------------------------------------------------------ capas / paquetes
def pkg(nid, title, lines, fill='#EAF0FA', planned=False):
    return (f'    {nid} [shape=tab, style="filled{",dashed" if planned else ""}", fillcolor="{fill}", '
            f'color="{"#888888" if planned else NAVY}", label={lab(title, lines)}];')


capas = f'''
  subgraph cluster_dj {{ label=<<B>Backend Django (back_GenApp)</B>>; style=rounded; color="#2E6B33"; bgcolor="#F4FAF4";
{pkg('d1', 'Presentación HTTP', ['urls.py · views.py (ViewSets DRF)', 'admin.py · admin_site.py (panel)'], '#E3F1E4')}
{pkg('d2', 'Serialización y validación', ['serializers.py', 'reglas de padres, imágenes, stock'], '#E3F1E4')}
{pkg('d3', 'Servicios de dominio', ['tienda/services.py (transacciones)', 'animales/utils.py (COI, edades)'], '#E3F1E4')}
{pkg('d4', 'Modelo / persistencia', ['models.py (ORM) · migrations/', 'MySQL 8'], '#E3F1E4')}
{pkg('d5', 'Configuración transversal', ['geneapp/settings.py · JWT · CORS', 'logging · management/commands'], '#F2F2F2')}
  }}
  subgraph cluster_fl {{ label=<<B>App móvil (front_genapp/lib)</B>>; style=rounded; color="#1F3864"; bgcolor="#F4F7FB";
{pkg('f1', 'Presentación', ['ui/features/*/views', 'ui/core (tema, widgets)'])}
{pkg('f2', 'Estado y navegación', ['ui/features/*/providers (Riverpod)', 'routes/app_router.dart (GoRouter)'])}
{pkg('f3', 'Datos', ['data/repositories', 'data/models'])}
{pkg('f4', 'Infraestructura', ['data/services/api_service.dart (Dio)', 'flutter_secure_storage'])}
{pkg('f5', 'Persistencia local y sincronización', ['data/services/local_store.dart (sqflite)', 'sync_service.dart · genealogia.dart'])}
  }}
  subgraph cluster_nx {{ label=<<B>Tienda web (front_TiendaVirtual/src)</B>>; style=rounded; color="#8A5A00"; bgcolor="#FFFBF3";
{pkg('n1', 'Páginas (App Router)', ['app/* (catálogo, producto, carrito,', 'checkout, pedido, ferias, animales)'], '#FCEFD9')}
{pkg('n2', 'Componentes', ['components/* (Header, FiltrosCatalogo,', 'TrazabilidadPanel, FormularioPago…)'], '#FCEFD9')}
{pkg('n3', 'Estado del cliente', ['store/CarritoContext.tsx', '(carrito persistente)'], '#FCEFD9')}
{pkg('n4', 'Acceso a la API', ['lib/api.ts · lib/types.ts', 'app/api/[...ruta] (proxy)'], '#FCEFD9')}
  }}
  d1 -> d2 -> d3 -> d4; d5 -> d1 [style=dashed, arrowhead=none];
  f1 -> f2 -> f3 -> f4; f3 -> f5;
  n1 -> n2 -> n3 -> n4; n1 -> n4 [style=dashed];
  f4 -> d1 [label="JSON + JWT", constraint=false];
  n4 -> d1 [label="JSON", constraint=false];
'''
write('e1_capas', capas, extra='rankdir=TB, nodesep=0.3, ranksep=0.35, newrank=true')




