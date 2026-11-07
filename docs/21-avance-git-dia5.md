# 21 · Avance del Día 5 · Clase 5 — cómo cerrar el Sprint 1 en el repositorio

> Guía de commits del **Día 5** para el equipo. Complementa `docs/07-convenciones-git.md`.
> Hoy además de subir el avance se ejecuta el cierre formal del sprint: merge de la rama
> a `dev`, revisión del PR, etiqueta del día y **release v0.1** en GitHub.

## 1. Qué entrega el equipo al final del Día 5

| # | Artefacto | Carpeta en el repo | Commit |
|---|---|---|---|
| 1 | Tema claro/oscuro que respeta el sistema (HU-06) | `app/lib/theme/`, `app/lib/main.dart` | `feat: tema claro y oscuro con ThemeMode.system (HU-06)` |
| 2 | Versión 0.4.0 del paquete | `app/pubspec.yaml` | `chore: versión 0.4.0+1 para el cierre del Sprint 1` |
| 3 | Pruebas alfa automatizadas (intro a pruebas de widgets) | `app/test/alfa_test.dart` | `test: pruebas alfa de widgets (HU-06, conteo HU-03, borde HU-04)` |
| 4 | Planilla de casos de prueba alfa | `docs/17-casos-prueba-alfa.md` | `docs: planilla de casos de prueba alfa del Sprint 1` |
| 5 | Acta del Sprint Review 1 | `docs/18-sprint-review-1.md` | `docs: acta del Sprint Review 1 con el resultado contra la meta` |
| 6 | Acta de la Retrospectiva 1 | `docs/19-retrospectiva-1.md` | `docs: retrospectiva 1 con Start/Stop/Continue y 2 acciones` |
| 7 | **Informe 1 (entregable del Hito 1)** | `docs/20-informe-1.md` | `docs: Informe 1 del Hito 1 (matriz, wireframes, app, pruebas alfa)` |
| 8 | Bitácora del día | `docs/22-bitacora-dia5.md` | `docs: bitácora del día 5` |
| 9 | README raíz y de la app actualizados | `README.md`, `app/README.md` | `docs: README del proyecto actualizado al cierre del Sprint 1` |

**Evidencia oficial del Día 5 (Hito 1):** Informe 1 + app sencilla con framework,
evaluados con la **Matriz 1 (20 pts)** durante la sustentación de 5 min por equipo.

## 2. GitFlow simplificado del curso

```
main        ← solo releases (v0.x); se actualiza por merge desde dev al cierre del sprint
dev         ← integración continua del sprint (todos los PR del día apuntan aquí)
feature/*   ← una rama por día de laboratorio (hoy: feature/dia5-pruebas-alfa-cierre)
```

Regla del Día 5 (nueva): al cierre del sprint `dev` se fusiona a `main` y el resultado
se etiqueta como release. Así el historial queda: cada día una feature-branch, cada
sprint un release.

## 3. Secuencia exacta de comandos

```bash
# 1) Rama del día
git switch dev && git pull origin dev
git switch -c feature/dia5-pruebas-alfa-cierre

# 2) Construir con el laboratorio (Guía Práctica pasos A-G):
#    HU-06 (temas) -> pruebas alfa -> planilla y actas -> Informe 1
#    con un commit por pieza (tabla de la sección 1)

# 3) Verificar ANTES de subir
fvm flutter analyze     # sin advertencias
fvm flutter test        # 9 pruebas en verde

# 4) Pull Request hacia dev
git push -u origin feature/dia5-pruebas-alfa-cierre
# Abre el PR en GitHub: título del día, descripción con los 9 artefactos,
# capturas de la demo y el checklist de code review (sección 4).

# 5) Revisión cruzada: OTRO equipo revisa tu PR y tú el de otro (checklist abajo).
#    Corrige lo observado y fusiona con squash merge.

# 6) Cierre del sprint: dev -> main + release v0.1
git switch dev && git pull origin dev
git switch main  && git pull origin main
git merge --no-ff dev -m "release: v0.1 del producto - cierre del Sprint 1 (Hito 1)"
git tag -a v0.4.0-dia5 -m "Release v0.1: app sencilla con 6 HU, 9 pruebas verdes y pruebas alfa"
git push origin main --follow-tags
# En GitHub: Releases -> Draft a new release -> elige el tag -> notas de la versión.
```

## 4. Checklist de code review (con qué se revisa el PR del Día 5)

- [ ] `fvm flutter analyze` sin advertencias y `fvm flutter test` en verde (9 pruebas).
- [ ] Los dos temas usan la MISMA semilla y `main.dart` declara `themeMode: ThemeMode.system`.
- [ ] Las pruebas nuevas prueban comportamiento, no implementación (finders por texto/rol, no por índice de widget).
- [ ] Los commits son convencionales y atómicos (uno por pieza; nada de "avance del día").
- [ ] `docs/17` a `docs/22` completos, sin secciones vacías ni "TODO".
- [ ] El tablero está actualizado: HU-06 y las tarjetas técnicas en "Hecho".

## 5. Notas del release v0.1 (plantilla para GitHub Releases)

```markdown
## CiudadAlerta v0.1 — cierre del Sprint 1 (Hito 1)

### Qué puede hacer la app
- Bienvenida e inicio de sesión (HU-01) · 4 pestañas (HU-02)
- Lista de reportes con datos simulados de La Paz y El Alto (HU-03)
- Detalle de cada reporte (HU-04) · Formulario validado (HU-05)
- Tema claro/oscuro que respeta el sistema (HU-06)

### Calidad
- 9 pruebas de widgets en verde · flutter analyze sin advertencias
- 10 casos de prueba alfa ejecutados (docs/17)

### Conocido / pendiente para el Sprint 2
- El envío del formulario es demo: persistencia con Supabase (HU-07..HU-13)
- Mapa y perfil siguen como placeholders (HU-14 y HU-08)
```
