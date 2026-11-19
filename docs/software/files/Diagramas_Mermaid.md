# Diagramas del proyecto — Wawa Pacocha (código Mermaid)

> Pégalos en https://mermaid.live para verlos y exportarlos como **PNG** o **SVG** (alta resolución).
> Luego se pueden insertar en los entregables E1 y E2.
>
> Actualizados según el MVP real: backend Django REST, app Flutter (offline-first), tienda Next.js, MySQL 8.

---

## ENTREGABLE 2 — Diagrama Entidad–Relación (ER)

> Modelo de datos completo (31 tablas) del sistema Wawa Pacocha.

![Diagrama 1](diagramas/mermaid_1.png)

```mermaid
erDiagram
    usuarios ||--o{ animales : registra
    animales ||--o{ producciones : produce
    animales ||--o{ animales : "padre/madre"
    animales ||--o{ fotos_animal : tiene
    animales ||--o{ animales_en_venta : "se ofrece"
    animales ||--o{ lotes : "origen fibra"
    producciones ||--|| analisis_fibra : tiene
    producciones ||--o{ lotes : "origen fibra"
    artesanos ||--o{ productos : confecciona
    lotes ||--o{ procesos_lote : tiene
    lotes ||--o{ productos : origina
    productos ||--o{ imagenes_producto : tiene
    productos ||--o{ variantes_producto : tiene
    variantes_producto ||--o{ precios_temporada : tiene
    variantes_producto ||--o{ detalle_pedido : aparece
    pedidos ||--o{ detalle_pedido : agrupa
    pedidos ||--|| pagos : tiene
    usuarios ||--o{ pagos : confirma

    usuarios {
        bigint id PK
        varchar username UK
        varchar telefono UK
        varchar rol
        tinyint is_staff
        tinyint is_active
    }
    razas {
        bigint id PK
        varchar nombre
        varchar especie
    }
    animales {
        bigint id PK
        char uid UK
        varchar arete UK
        varchar especie
        varchar sexo
        varchar raza
        varchar estado
        varchar sync_status
        bigint usuario_id FK
        bigint padre_id FK
        bigint madre_id FK
    }
    fotos_animal {
        bigint id PK
        varchar imagen
        smallint orden
        bigint animal_id FK
    }
    producciones {
        bigint id PK
        char uid UK
        date fecha_esquila
        decimal peso_vellon_lb
        decimal longitud_mecha_cm
        varchar sync_status
        bigint animal_id FK
    }
    analisis_fibra {
        bigint id PK
        decimal dmf
        decimal cv
        decimal factor_confort
        bigint produccion_id FK
    }
    animales_en_venta {
        bigint id PK
        decimal precio
        varchar proposito
        varchar estado
        tinyint destacado
        bigint animal_id FK
    }
    artesanos {
        bigint id PK
        varchar nombre
        varchar localidad
        tinyint activo
    }
    lotes {
        bigint id PK
        varchar codigo_lote UK
        varchar tipo_fibra
        decimal cantidad_kg
        bigint animal_id FK
        bigint produccion_id FK
    }
    procesos_lote {
        bigint id PK
        varchar etapa
        smallint orden_secuencia
        date fecha_proceso
        bigint lote_id FK
    }
    productos {
        bigint id PK
        varchar nombre
        varchar slug UK
        varchar categoria
        varchar unidad_venta
        tinyint destacado
        bigint artesano_id FK
        bigint lote_id FK
    }
    imagenes_producto {
        bigint id PK
        varchar imagen_url
        smallint orden
        bigint producto_id FK
    }
    variantes_producto {
        bigint id PK
        varchar sku UK
        varchar talla
        varchar color
        varchar tipo_prenda
        decimal precio_base
        int stock
        int stock_reservado
        bigint producto_id FK
    }
    precios_temporada {
        bigint id PK
        varchar nombre_temporada
        decimal precio_especial
        date fecha_inicio
        date fecha_fin
        tinyint activo
        bigint variante_id FK
    }
    pedidos {
        bigint id PK
        varchar codigo UK
        varchar cliente_nombre
        varchar cliente_contacto
        varchar estado
        decimal total
    }
    detalle_pedido {
        bigint id PK
        int cantidad
        decimal precio_unitario
        bigint pedido_id FK
        bigint variante_id FK
    }
    pagos {
        bigint id PK
        varchar metodo
        varchar estado
        varchar comprobante_imagen
        varchar huella_comprobante
        bigint pedido_id FK
        bigint confirmado_por_id FK
    }
    eventos_feria {
        bigint id PK
        varchar titulo
        date fecha_evento
        varchar ubicacion
        tinyint activo
    }
    publicaciones {
        bigint id PK
        varchar titulo
        varchar fuente
        date fecha
        tinyint activo
    }
```

---

## ENTREGABLE 1 — Arquitectura (estilo C4: contexto + contenedores)

![Diagrama 2](diagramas/mermaid_2.png)

```mermaid
flowchart TB
    subgraph Personas
        Criador["Criador / Veterinario"]
        Admin["Administrador"]
        Comprador["Comprador"]
    end
    subgraph Contenedores
        Nginx["Nginx (reverse proxy)"]
        App["App Movil (Flutter, offline-first, SQLite)"]
        Web["Tienda Web (Next.js / React)"]
        Backoffice["Backoffice (Admin de Django)"]
        API["API REST (Django REST Framework)"]
        DB[("Base de Datos MySQL 8")]
    end
    Criador --> App
    Comprador --> Web
    Admin --> Backoffice
    App -->|JSON/HTTPS + JWT| Nginx
    Web -->|JSON/HTTPS| Nginx
    Nginx -->|/api, /admin, /static| API
    Nginx -->|resto| Web
    API -->|ORM/SQL| DB
    Backoffice -->|ORM| DB
```

---

## ENTREGABLE 1 — Casos de Uso

![Diagrama 3](diagramas/mermaid_3.png)

```mermaid
flowchart LR
    Criador(["Criador"])
    Vet(["Veterinario"])
    Admin(["Administrador"])
    Comp(["Comprador"])

    Criador --- U1((Registrar animal))
    Criador --- U2((Ver arbol genealogico))
    Criador --- U3((Sincronizar datos offline))
    Criador --- U4((Registrar esquila))
    Criador --- U5((Analizar fibra))
    Criador --- U6((Exportar reportes))
    Vet --- U1
    Vet --- U2
    Vet --- U4
    Vet --- U5
    Admin --- U7((Gestionar roles y permisos))
    Admin --- U8((Confirmar pago))
    Admin --- U9((Gestionar catalogo y precios))
    Admin --- U10((Gestionar animales en venta))
    Admin --- U11((Gestionar contenido web))
    Admin --- U12((Publicar eventos y noticias))
    Comp --- U13((Consultar catalogo))
    Comp --- U14((Ver trazabilidad del producto))
    Comp --- U15((Agregar al carrito))
    Comp --- U16((Generar pedido))
    Comp --- U17((Subir comprobante))
```

---

## ENTREGABLE 1 — Clases (Módulo Ganadería)

![Diagrama 4](diagramas/mermaid_4.png)

```mermaid
classDiagram
    class Usuario {
        +BigInt id
        +String username
        +String telefono
        +Enum rol
        +Bool is_staff
        +Bool is_active
        +es_admin() Bool
    }
    class Raza {
        +BigInt id
        +String nombre
        +Enum especie
    }
    class Animal {
        +BigInt id
        +UUID uid
        +String arete
        +Enum especie
        +Enum sexo
        +String raza
        +Date fecha_nacimiento
        +Decimal peso_nacimiento_kg
        +Decimal longitud_mecha_nacimiento_cm
        +Enum estado
        +String sync_status
        +Bool activo
        +verificar_padres() void
    }
    class FotoAnimal {
        +BigInt id
        +String imagen
        +String descripcion
        +Int orden
    }
    class Produccion {
        +BigInt id
        +UUID uid
        +Date fecha_esquila
        +Int numero_esquila
        +Decimal peso_vellon_lb
        +Decimal longitud_mecha_cm
        +String sync_status
    }
    class AnalisisFibra {
        +BigInt id
        +Decimal dmf
        +Decimal cv
        +Decimal desviacion_estandar
        +Decimal factor_confort
        +Decimal indice_curvatura
        +Date fecha_analisis
    }
    Usuario "1" --> "N" Animal : registra
    Raza "1" --> "N" Animal : clasifica
    Animal "0..1" --> "N" Animal : padre/madre
    Animal "1" --> "N" FotoAnimal : tiene
    Animal "1" --> "N" Produccion : produce
    Produccion "1" --> "1" AnalisisFibra : tiene
```

---

## ENTREGABLE 1 — Clases (Módulo Tienda)

![Diagrama 5](diagramas/mermaid_5.png)

```mermaid
classDiagram
    class Artesano {
        +BigInt id
        +String nombre
        +String localidad
        +Bool activo
    }
    class Lote {
        +BigInt id
        +String codigo_lote
        +Enum tipo_fibra
        +Decimal cantidad_kg
        +Date fecha_ingreso
    }
    class ProcesoLote {
        +BigInt id
        +Enum etapa
        +Int orden_secuencia
        +Date fecha_proceso
    }
    class Producto {
        +BigInt id
        +String nombre
        +String slug
        +Enum categoria
        +String unidad_venta
        +Bool destacado
        +Bool activo
    }
    class ImagenProducto {
        +BigInt id
        +String imagen_url
        +Int orden
    }
    class VarianteProducto {
        +BigInt id
        +String sku
        +String talla
        +String color
        +String tipo_prenda
        +Decimal precio_base
        +Int stock
        +Int stock_reservado
    }
    class PrecioTemporada {
        +BigInt id
        +String nombre_temporada
        +Decimal precio_especial
        +Date fecha_inicio
        +Date fecha_fin
        +Bool activo
    }
    class Pedido {
        +BigInt id
        +String codigo
        +String cliente_nombre
        +String cliente_contacto
        +Enum estado
        +Decimal total
    }
    class DetallePedido {
        +BigInt id
        +Int cantidad
        +Decimal precio_unitario
    }
    class Pago {
        +BigInt id
        +Enum metodo
        +Enum estado
        +String comprobante_imagen
        +String huella_comprobante
    }
    class AnimalEnVenta {
        +BigInt id
        +Decimal precio
        +Enum proposito
        +Enum estado
        +Bool destacado
    }
    class EventoFeria {
        +BigInt id
        +String titulo
        +Date fecha_evento
        +String ubicacion
        +Bool activo
    }
    class Publicacion {
        +BigInt id
        +String titulo
        +Enum fuente
        +Date fecha
        +Bool activo
    }
    class ConfiguracionTienda {
        +BigInt id
        +String nombre_tienda
        +String hero_titulo
        +String telefono_yape
        +String telefono_plin
        +Int horas_reserva
    }
    Lote "1" --> "N" ProcesoLote
    Lote "1" --> "N" Producto
    Artesano "1" --> "N" Producto
    Producto "1" --> "N" ImagenProducto
    Producto "1" --> "N" VarianteProducto
    VarianteProducto "1" --> "N" PrecioTemporada
    VarianteProducto "1" --> "N" DetallePedido
    Pedido "1" --> "N" DetallePedido
    Pedido "1" --> "1" Pago
    Animal "1" --> "0..1" AnimalEnVenta : se ofrece
```

---

## ENTREGABLE 1 — Secuencia: Sincronización Offline

![Diagrama 6](diagramas/mermaid_6.png)

```mermaid
sequenceDiagram
    participant App as App Movil
    participant API as API REST
    participant DB as Base de Datos
    Note over App: usuario sin conexion
    App->>App: registra animal (SQLite, sync_status=PEN)
    Note over App: recupera internet
    App->>API: POST /sync/ {last_sync, changes[]}
    API->>DB: UPSERT animales, producciones, analisis
    DB-->>API: OK
    API->>DB: SELECT updated_at > last_sync
    DB-->>API: server_changes
    API-->>App: {server_changes, sync_timestamp}
    App->>App: actualiza SQLite (sync_status=SINC)
```

---

## ENTREGABLE 1 — Secuencia: Compra y Pago Manual

![Diagrama 7](diagramas/mermaid_7.png)

```mermaid
sequenceDiagram
    participant C as Comprador (Web)
    participant API as API REST (tienda)
    participant A as Administrador
    C->>API: agrega al carrito / valida stock
    API-->>C: stock OK
    C->>API: POST /pedidos/ (crea Pedido pendiente, reserva stock)
    API-->>C: codigo WP-#####
    Note over C: paga por Yape/Plin (fuera del sistema)
    C->>API: POST /pedidos/{id}/comprobante/
    API-->>C: comprobante recibido
    API->>A: notifica pedido nuevo
    A->>A: revisa comprobante
    A->>API: PATCH /pagos/{id}/ confirmar
    API->>API: Pago=confirmado, Pedido=pagado, descuenta stock
    API-->>C: pedido confirmado
```

---

## ENTREGABLE 1 — Secuencia: Trazabilidad del Producto

![Diagrama 8](diagramas/mermaid_8.png)

```mermaid
sequenceDiagram
    participant C as Comprador (Web)
    participant API as API REST (tienda)
    participant DB as Base de Datos
    C->>API: GET /productos/{slug}/trazabilidad/
    API->>DB: Producto -> Variante -> Lote -> Animal, Produccion, AnalisisFibra, ProcesosLote
    DB-->>API: datos de trazabilidad
    API-->>C: ficha con DMF, CV, factor confort, procesos y animal de origen
```

---

### Cómo exportarlos como imagen
1. Entra a https://mermaid.live
2. Pega un bloque de código (sin los ``` de arriba y abajo).
3. Menú **Actions → PNG** (o SVG) para descargar la imagen en alta resolución.
4. Esa imagen se puede insertar en el entregado correspondiente.