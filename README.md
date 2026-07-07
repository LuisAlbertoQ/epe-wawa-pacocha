# EPE — Wawa Pacocha

Sitio de documentación (MkDocs Material) con los entregables de la **Evaluación de Perfil de Egreso** de Ingeniería de Sistemas (UPeU), organizados por línea: **Software**, **Gestión de TI** e **Infraestructura**.

Publicado con GitHub Pages: `https://LuisAlbertoQ.github.io/epe-wawa-pacocha/`

## Estructura

```
docs/
├─ index.md                → portada
├─ software/               → E1, E2, presentación + files/ (PDF, Word, SQL)
├─ gestion/                → E1–E4 + files/
└─ infraestructura/        → plantilla (en desarrollo)
```

## Ver el sitio en local

```bash
pip install -r requirements.txt
mkdocs serve      # abre http://127.0.0.1:8000
```

## Publicar en GitHub Pages

1. Crea el repo en GitHub con el nombre **epe-wawa-pacocha**.
2. Sube el proyecto (ver "Subir por primera vez").
3. En **Settings → Pages**, elige la rama **gh-pages** como fuente (el workflow la crea sola en el primer push a `main`).
4. Reemplaza `LuisAlbertoQ` por tu usuario de GitHub en `mkdocs.yml` (site_url) y en este README.

## Subir por primera vez

```bash
cd epe-wawa-pacocha
git init -b main
git add .
git commit -m "EPE Wawa Pacocha: sitio inicial con entregables"
git remote add origin https://github.com/LuisAlbertoQ/epe-wawa-pacocha.git
git push -u origin main
```

El workflow `.github/workflows/deploy.yml` construye y publica el sitio automáticamente en cada push a `main`.

## Topics del repositorio (estándar de la Escuela)

Configúralos en la página del repo (About → ⚙️) o por línea de comandos:

```bash
gh repo edit LuisAlbertoQ/epe-wawa-pacocha \
  --add-topic campus-juliaca \
  --add-topic semestre-2026-1 \
  --add-topic linea-software \
  --add-topic tipo-epe \
  --add-topic seccion-XX \
  --add-topic grupo-N-wawa-pacocha
```

> Ajusta `seccion-XX` y `grupo-N-...` con tu sección y número de grupo reales.
> Si tu Escuela exige un repositorio por línea, replica esta estructura por línea con su topic `linea-...` correspondiente.
