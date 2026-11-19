// DOT -> SVG con Graphviz (viz.js). Uso: node render.mjs src/a.dot src/b.dot ...
// Si existe src/a.images.json ([{name, width, height}]) se pasa como imágenes disponibles.
import { instance } from '@viz-js/viz';
import { readFileSync, writeFileSync, existsSync } from 'node:fs';
import { basename } from 'node:path';

const viz = await instance();
for (const f of process.argv.slice(2)) {
  const dot = readFileSync(f, 'utf8');
  const side = f.replace(/\.dot$/, '.images.json');
  const images = existsSync(side) ? JSON.parse(readFileSync(side, 'utf8')) : undefined;
  const r = viz.render(dot, { format: 'svg', engine: 'dot', images });
  if (r.status !== 'success') {
    console.error('ERROR', f, r.errors.map(e => e.message).join(' | '));
    process.exitCode = 1;
    continue;
  }
  writeFileSync(`out/${basename(f, '.dot')}.svg`, r.output);
  console.log('svg', basename(f));
}
