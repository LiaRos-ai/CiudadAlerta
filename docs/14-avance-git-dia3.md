# Avance del Día 3 · Clase 3 — cómo subirlo al repositorio

> Guía de commits del **Día 3** para el equipo. Complementa `docs/07-convenciones-git.md`.
> Regla del curso: ramas `feature/*`, commits convencionales, Pull Request a `dev`.

## 1. Qué entrega el equipo al final del Día 3

| # | Artefacto | Carpeta en el repo | Commit |
|---|---|---|---|
| 1 | Tema propio con ThemeData y Material 3 | `app/lib/theme/` | `feat: tema propio con ThemeData y Material 3 (semilla verde del curso)` |
| 2 | Widgets reutilizables (CustomButton, CustomInput) | `app/lib/widgets/` | `feat: widgets reutilizables CustomButton y CustomInput` |
| 3 | ReportCard (primer StatelessWidget con datos) | `app/lib/widgets/` | `feat: ReportCard, primer StatelessWidget con datos de reporte` |
| 4 | Pantalla de bienvenida / login solo UI (HU-01) | `app/lib/screens/` | `feat: pantalla de bienvenida e inicio de sesión solo UI (HU-01)` |
| 5 | Prueba de widgets de la HU-01 | `app/test/` | `test: prueba de widgets de la pantalla de bienvenida (HU-01)` |
| 6 | Bitácora del día completada | `docs/13-bitacora-dia3.md` | `docs: bitácora del día 3` |
| 7 | Tarjetas y burndown actualizados | tablero | (sin commit; mover tarjetas a "Hecho" o "En revisión") |

## 2. Secuencia exacta de comandos (desde la carpeta de tu equipo)

```bash
# 0) Ubícate en tu copia local del repositorio del proyecto paralelo
cd mi-proyecto

# 1) Rama de trabajo del día
git checkout dev
git pull origin dev
git checkout -b feature/dia3-widgets-y-login

# 2) Estructura de carpetas del día
mkdir -p app/lib/theme app/lib/widgets app/lib/screens

# 3) Construir con el laboratorio (Guía Práctica pasos A1-A6):
#    app_theme.dart -> CustomInput/CustomButton -> ReportCard -> WelcomeScreen

# 4) Verificar ANTES del commit
fvm flutter analyze      # sin advertencias
fvm flutter test         # pruebas en verde
git status               # confirmar que NO se suben build/, .dart_tool/ ni claves

# 5) Commits (uno por pieza, convención del curso)
git add app/lib/theme app/lib/main.dart
git commit -m "feat: tema propio con ThemeData y Material 3 (semilla verde del curso)"
git add app/lib/widgets
git commit -m "feat: widgets reutilizables CustomButton y CustomInput"
git commit -m "feat: ReportCard, primer StatelessWidget con datos de reporte"
git add app/lib/screens app/test
git commit -m "feat: pantalla de bienvenida e inicio de sesión solo UI (HU-01)"
git commit -m "test: prueba de widgets de la pantalla de bienvenida (HU-01)"
git add docs/13-bitacora-dia3.md docs/14-avance-git-dia3.md
git commit -m "docs: bitácora del día 3"

# 6) Subir y abrir el Pull Request a dev
git push -u origin feature/dia3-widgets-y-login
# → GitHub: "Compare & pull request" → base: dev → asignar a otro equipo (revisión cruzada)
# → el revisor deja al menos 1 comentario: qué está bien / qué cambiaría / por qué
# → al aprobar: "Squash and merge" y borrar la rama
```

## 3. Checklist antes del Pull Request

- [ ] El estado cambia dentro de `setState` (prueba el botón mostrar/ocultar contraseña)
- [ ] HU-01 sin errores de layout en el emulador vertical **y** rotado (2 capturas)
- [ ] Todo el estilo nace de `ThemeData` (nada de colores hex sueltos en pantallas)
- [ ] Espaciado con la escala del curso (4 / 8 / 12 / 16 / 24), nada de números arbitrarios
- [ ] `fvm flutter analyze` sin advertencias y `fvm flutter test` en verde
- [ ] Commits convencionales y atómicos (uno por pieza, no un commit gigante)
- [ ] No hay claves ni tokens en ningún archivo del commit

## 4. Qué verá el docente en la revisión (Matriz 1, 20 pts)

- Nivel **Resolutivo (9-12)**: implementa HU-01 con los widgets reutilizables siguiendo el laboratorio; sube commits convencionales con PR abierto.
- Nivel **Autónomo (13-16)**: implementa y adapta los widgets a su proyecto paralelo sin supervisión; PR revisado y merge a dev.
- Nivel **Estratégico (17-20)**: diseña su propia librería de widgets con tema coherente, revisa el PR de otro equipo con criterio y documenta la decisión técnica.
