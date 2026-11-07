# Avance del Día 4 · Clase 4 — cómo subirlo al repositorio

> Guía de commits del **Día 4** para el equipo. Complementa `docs/07-convenciones-git.md`.
> Regla del curso: ramas `feature/*`, commits convencionales, Pull Request a `dev`.

## 1. Qué entrega el equipo al final del Día 4

| # | Artefacto | Carpeta en el repo | Commit |
|---|---|---|---|
| 1 | go_router integrado + shell de 4 pestañas (HU-02) | `app/lib/routing/`, `app/lib/screens/` | `feat: navegación por pestañas con go_router y ShellRoute (HU-02)` |
| 2 | Modelo Report + datos simulados | `app/lib/data/` | `feat: modelo Report y datos mock del curso` |
| 3 | Lista de reportes con ListView.builder (HU-03) | `app/lib/screens/reports_list_screen.dart` | `feat: lista de reportes con ListView.builder y estados de carga (HU-03)` |
| 4 | Detalle con parámetro de ruta (HU-04) | `app/lib/screens/report_detail_screen.dart` | `feat: detalle de reporte con parámetro de ruta (HU-04)` |
| 5 | Formulario validado (HU-05) | `app/lib/screens/new_report_screen.dart` | `feat: formulario de nuevo reporte con validación (HU-05)` |
| 6 | Pruebas de flujo y de validación | `app/test/` | `test: pruebas de navegación y de validación del formulario` |
| 7 | Bitácora del día completada | `docs/15-bitacora-dia4.md` | `docs: bitácora del día 4` |
| 8 | Tablero actualizado (HU-02..HU-05 en "Hecho") | GitHub Projects | (sin commit; mover tarjetas) |

**Evidencia oficial del Día 4:** lista de cotejo de funcionalidades del Sprint 1
(distribuida por el docente y aplicada al cierre del laboratorio).

## 2. Secuencia exacta de comandos (desde la carpeta de tu equipo)

```bash
# 0) Ubícate en tu copia local del repositorio del proyecto paralelo
cd mi-proyecto

# 1) Rama de trabajo del día
git checkout dev
git pull origin dev
git checkout -b feature/dia4-navegacion-listas-formularios

# 2) Dependencia del día (navegación declarativa)
cd app && fvm flutter pub add go_router && cd ..

# 3) Construir con el laboratorio (Guía Práctica pasos A-F):
#    router + shell (HU-02) -> modelo y mocks -> lista (HU-03)
#    -> detalle (HU-04) -> formulario (HU-05)

# 4) Verificar ANTES del commit
fvm flutter analyze      # sin advertencias
fvm flutter test         # 6 pruebas en verde
git status               # confirmar que NO se suben build/, .dart_tool/ ni claves

# 5) Commits (uno por pieza, convención del curso)
git add app/pubspec.yaml app/lib/routing app/lib/main.dart
git add app/lib/screens/home_shell.dart app/lib/screens/map_placeholder_screen.dart app/lib/screens/profile_screen.dart
git commit -m "feat: navegación por pestañas con go_router y ShellRoute (HU-02)"
git add app/lib/data
git commit -m "feat: modelo Report y datos mock del curso"
git add app/lib/screens/reports_list_screen.dart app/lib/widgets/report_card.dart
git commit -m "feat: lista de reportes con ListView.builder y estados de carga (HU-03)"
git add app/lib/screens/report_detail_screen.dart
git commit -m "feat: detalle de reporte con parámetro de ruta (HU-04)"
git add app/lib/screens/new_report_screen.dart app/lib/screens/welcome_screen.dart
git commit -m "feat: formulario de nuevo reporte con validación (HU-05)"
git add app/test
git commit -m "test: pruebas de navegación y de validación del formulario"
git add docs/15-bitacora-dia4.md docs/16-avance-git-dia4.md
git commit -m "docs: bitácora del día 4"

# 6) Subir y abrir el Pull Request a dev
git push -u origin feature/dia4-navegacion-listas-formularios
# → GitHub: "Compare & pull request" → base: dev → revisión cruzada entre equipos
# → al aprobar: "Squash and merge" y borrar la rama
```

## 3. Checklist antes del Pull Request (lista de cotejo del Sprint 1)

- [ ] Las 4 pestañas (Inicio, Mapa, Nuevo, Perfil) funcionan y la activa queda resaltada
- [ ] Volver a Inicio NO recarga la lista (ShellRoute conserva el estado)
- [ ] La lista usa `ListView.builder` (no `children:`) con tarjetas título + categoría + fecha
- [ ] Tocar un reporte abre `/reporte/:id` y muestra TODOS los campos
- [ ] Un id inexistente (p. ej. `/reporte/RPT-999`) muestra mensaje, no crash
- [ ] El formulario NO envía si es inválido y muestra mensajes claros por campo
- [ ] `fvm flutter analyze` sin advertencias y `fvm flutter test` (6 pruebas) en verde
- [ ] Commits convencionales y atómicos; sin claves ni tokens en el diff

## 4. Qué verá el docente en la revisión (Matriz 1, 20 pts)

- Nivel **Resolutivo (9-12)**: replica el laboratorio — shell de pestañas, lista mock
  y formulario validado de CiudadAlerta con commits convencionales.
- Nivel **Autónomo (13-16)**: adapta el flujo a su proyecto paralelo (≥4 pantallas,
  rutas con nombres propios del dominio) y las pruebas pasan sin supervisión.
- Nivel **Estratégico (17-20)**: justifica decisiones (¿por qué go_router y no
  Navigator?, ¿por qué builder y no children?), documenta las rutas en el README
  del equipo y revisa el PR de otro equipo proponiendo mejoras concretas.
