# Avance del Día 2 · Clase 2 — cómo subirlo al repositorio

> Guía de commits del **Día 2** para el equipo. Complementa `docs/07-convenciones-git.md`.
> Regla del curso: ramas `feature/*`, commits convencionales, Pull Request a `dev`.

## 1. Qué entrega el equipo al final del Día 2

| # | Artefacto | Carpeta en el repo | Commit |
|---|---|---|---|
| 1 | App contador creada con `flutter create` | `app/` | `chore: crear app Flutter con flutter create (app contador)` |
| 2 | Matriz de decisión del framework completada | `matriz_decision/` + `docs/09-…` | `docs: matriz de decisión del framework del equipo` |
| 3 | Wireframes de 4 pantallas (foto o PDF) | `wireframes/` | `docs: wireframes de baja fidelidad de 4 pantallas` |
| 4 | Bitácora del día completada | `docs/10-bitacora-dia2.md` | `docs: bitácora del día 2` |
| 5 | Tarjetas actualizadas en GitHub Projects | tablero | (sin commit; mover tarjetas a "Hecho") |

## 2. Secuencia exacta de comandos (desde la carpeta de tu equipo)

```bash
# 0) Ubícate en tu copia local del repositorio del proyecto paralelo
cd mi-proyecto

# 1) Rama de trabajo del día
git checkout dev
git pull origin dev
git checkout -b feature/dia2-entorno-y-matriz

# 2) Crear la app Flutter (si el docente no la compartió ya)
fvm flutter create app
cd app && fvm flutter pub get && cd ..

# 3) Copiar plantillas y completarlas con tu equipo
#    matriz_decision/plantilla_matriz_decision.xlsx  → matriz de SU proyecto
#    wireframes/wireframes_plantilla.md              → sus 4 pantallas

# 4) Verificar qué se va a subir (¡la app genera muchas carpetas!)
git status
git add app/pubspec.yaml app/lib app/test app/analysis_options.yaml app/.gitignore app/README.md
git add matriz_decision/ wireframes/ docs/
git status   # confirmar que NO se suben build/, .dart_tool/ ni claves

# 5) Commits (uno por artefacto, convención del curso)
git commit -m "chore: crear app Flutter con flutter create (app contador)"
git commit -m "docs: matriz de decisión del framework del equipo"
git commit -m "docs: wireframes de baja fidelidad de 4 pantallas"
git commit -m "docs: bitácora del día 2"

# 6) Subir y abrir el Pull Request a dev
git push -u origin feature/dia2-entorno-y-matriz
# → GitHub: "Compare & pull request" → base: dev → asignar al Scrum Master del día
# → al aprobar: "Squash and merge" y borrar la rama
```

## 3. Checklist antes del Pull Request

- [ ] `flutter doctor` sin errores (captura guardada para el Informe 1)
- [ ] La app contador corre en emulador **y** en un celular por USB
- [ ] Hot reload probado y registrado en la bitácora
- [ ] La matriz de decisión suma 100 % de pesos y compara ≥ 3 frameworks
- [ ] Los wireframes tienen las 4 pantallas con navegación anotada
- [ ] `.gitignore` del app evita subir `build/`, `.dart_tool/` y claves
- [ ] No hay claves ni tokens en ningún archivo del commit

## 4. Qué verá el docente en la revisión (Matriz 1, 20 pts)

- Nivel **Resolutivo (9-12)**: instala con supervisión, tomando en cuenta la mejor opción.
- Nivel **Autónomo (13-16)**: instala sin supervisión, con la mejor opción justificada.
- Nivel **Estratégico (17-20)**: compara varios frameworks y analiza la decisión con la matriz.
