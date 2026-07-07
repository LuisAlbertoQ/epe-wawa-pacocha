# Diagramas del proyecto — Wawa Pacocha (código Mermaid)

> Pégalos en https://mermaid.live para verlos y exportarlos como **PNG** o **SVG** (alta resolución).
> Luego se pueden insertar en los entregables E1 y E2.

---

## ENTREGABLE 2 — Diagrama Entidad–Relación (ER)

```mermaid
erDiagram
    usuarios ||--o{ animales : registra
    animales ||--o{ producciones : produce
    animales ||--o{ animales : "padre/madre"
    animales ||--o{ lotes : "origen fibra"
    lotes ||--o{ procesos_lote : tiene
    lotes ||--o{ productos : origina
    artesanos ||--o{ productos : confecciona
    productos ||--o{ variantes_producto : tiene
    variantes_producto ||--o{ precios_temporada : tiene
    variantes_producto ||--o{ detalle_pedido : aparece
    pedidos ||--o{ detalle_pedido : agrupa
    pedidos ||--|| pagos : tiene
    usuarios ||--o{ pagos : confirma

    usuarios {
        bigint id PK
        varchar telefono UK
        varchar password
        tinyint is_staff
    }
    animales {
        bigint id PK
        char uid UK
        varchar arete UK
        bigint usuario_id FK
        varchar especie
        varchar sexo
        varchar raza
        bigint padre_id FK
        bigint madre_id FK
        tinyint activo
    }
    producciones {
        bigint id PK
        bigint animal_id FK
        date fecha_esquila
        decimal peso_vellon_kg
    }
    artesanos {
        bigint id PK
        varchar nombre
    }
    lotes {
        bigint id PK
        varchar codigo_lote UK
        varchar tipo_fibra
        bigint animal_id FK
    }
    procesos_lote {
        bigint id PK
        bigint lote_id FK
        varchar etapa
        tinyint orden_secuencia
    }
    productos {
        bigint id PK
        varchar nombre
        varchar categoria
        bigint artesano_id FK
        bigint lote_id FK
    }
    variantes_producto {
        bigint id PK
        bigint producto_id FK
        varchar talla
        varchar color
        varchar sku UK
        decimal precio_base
        int stock
    }
    precios_temporada {
        bigint id PK
        bigint variante_id FK
        decimal precio_especial
        date fecha_inicio
        date fecha_fin
    }
    pedidos {
        bigint id PK
        varchar cliente_nombre
        varchar estado
        decimal total
    }
    detalle_pedido {
        bigint id PK
        bigint pedido_id FK
        bigint variante_id FK
        int cantidad
    }
    pagos {
        bigint id PK
        bigint pedido_id FK "UK 1:1"
        varchar metodo
        varchar estado
        bigint confirmado_por FK
    }
```

---

## ENTREGABLE 1 — Arquitectura (estilo C4: contexto + contenedores)

```mermaid
flowchart TB
    subgraph Personas
        Criador["Criador / Veterinario"]
        Admin["Administrador"]
        Comprador["Comprador"]
    end
    subgraph Contenedores
        App["App Movil (Flutter, offline-first)"]
        Web["Tienda Web (React / Next.js)"]
        Backoffice["Backoffice (Admin de Django)"]
        API["API REST (Django REST Framework)"]
        DB[("Base de Datos MySQL 8")]
    end
    Criador --> App
    Comprador --> Web
    Admin --> Backoffice
    App -->|JSON/HTTPS sync| API
    Web -->|JSON/HTTPS| API
    API -->|ORM/SQL| DB
    Backoffice -->|ORM| DB
```

---

## ENTREGABLE 1 — Casos de Uso

```mermaid
flowchart LR
    Criador(["Criador"])
    Vet(["Veterinario"])
    Admin(["Administrador"])
    Prop(["Propietario"])
    Comp(["Comprador"])

    Criador --- U1((Registrar animal))
    Criador --- U2((Ver arbol genealogico))
    Criador --- U3((Sincronizar datos))
    Criador --- U4((Registrar produccion))
    Vet --- U1
    Vet --- U2
    Admin --- U5((Gestionar roles))
    Admin --- U6((Confirmar pago))
    Admin --- U7((Gestionar catalogo y precios))
    Prop --- U8((Generar reporte))
    Comp --- U9((Consultar catalogo))
    Comp --- U10((Ver trazabilidad producto))
    Comp --- U11((Agregar al carrito))
    Comp --- U12((Generar pedido))
    Comp --- U13((Subir comprobante))
```

---

## ENTREGABLE 1 — Clases (Módulo Ganadería)

```mermaid
classDiagram
    class Usuario {
        +BigInt id
        +String telefono
        +Enum rol
        +Bool is_staff
        +es_admin() Bool
        +animales_registrados() int
    }
    class Animal {
        +BigInt id
        +UUID uid
        +String arete
        +Enum especie
        +Enum sexo
        +Enum raza
        +Decimal diametro_fibra
        +Bool seleccionado
        +Bool activo
        +verificar_padres() void
    }
    class Produccion {
        +BigInt id
        +Date fecha_esquila
        +Decimal peso_vellon_kg
        +Decimal rendimiento_pct
    }
    Usuario "1" --> "N" Animal : registra
    Animal "0..1" --> "N" Animal : padre/madre
    Animal "1" --> "N" Produccion : produce
```

---

## ENTREGABLE 1 — Clases (Módulo Tienda)

```mermaid
classDiagram
    class Lote {
        +BigInt id
        +String codigo_lote
        +Enum tipo_fibra
    }
    class ProcesoLote {
        +Enum etapa
        +int orden_secuencia
    }
    class Artesano {
        +String nombre
    }
    class Producto {
        +String nombre
        +Enum categoria
    }
    class VarianteProducto {
        +String talla
        +String color
        +String sku
        +Decimal precio_base
        +int stock
    }
    class PrecioTemporada {
        +Decimal precio
        +Date fecha_inicio
        +Date fecha_fin
    }
    class Pedido {
        +String cliente_nombre
        +Enum estado
        +Decimal total
    }
    class DetallePedido {
        +int cantidad
        +Decimal precio_unitario
    }
    class Pago {
        +Enum metodo
        +Enum estado
    }
    Lote "1" --> "N" ProcesoLote
    Lote "1" --> "N" Producto
    Artesano "1" --> "N" Producto
    Producto "1" --> "N" VarianteProducto
    VarianteProducto "1" --> "N" PrecioTemporada
    VarianteProducto "1" --> "N" DetallePedido
    Pedido "1" --> "N" DetallePedido
    Pedido "1" --> "1" Pago
```

---

## ENTREGABLE 1 — Secuencia: Sincronización Offline

```mermaid
sequenceDiagram
    participant App as App Movil
    participant API as API REST
    participant DB as Base de Datos
    Note over App: usuario sin conexion
    App->>App: registra animal (SQLite, sync_status=PEN)
    Note over App: recupera internet
    App->>API: POST /sync/ {last_sync, changes[]}
    API->>DB: UPSERT animales
    DB-->>API: OK
    API->>DB: SELECT updated_at > last_sync
    DB-->>API: server_changes
    API-->>App: {server_changes, sync_timestamp}
    App->>App: actualiza SQLite (sync_status=SINC)
```

---

## ENTREGABLE 1 — Secuencia: Compra y Pago Manual

```mermaid
sequenceDiagram
    participant C as Comprador (Web)
    participant API as API REST (tienda)
    participant A as Administrador
    C->>API: agrega al carrito / valida stock
    API-->>C: stock OK
    C->>API: POST /pedidos/ (crea Pedido pendiente)
    API-->>C: pedido_id
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

### Cómo exportarlos como imagen
1. Entra a https://mermaid.live
2. Pega un bloque de código (sin los ``` de arriba y abajo).
3. Menú **Actions → PNG** (o SVG) para descargar la imagen en alta resolución.
4. Esa imagen se puede insertar en el entregado correspondiente.
