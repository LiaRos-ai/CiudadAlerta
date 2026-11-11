# 25 · Avance del Día 6 · Clase 6 — arquitectura por capas en el repositorio

> Guía de commits del **Día 6** para el equipo. Complementa `docs/07-convenciones-git.md`.
> El Día 6 abre el Sprint 2: la rama sale de `main` (release v0.1) o de `dev`
> actualizada, y el día cierra con PR revisado y el tag del día.

## 1. Qué entrega el equipo al final del Día 6

| # | Artefacto | Carpeta en el repo | Commit |
|---|---|---|---|
| 1 | Acta del Sprint Planning 2 + Sprint Backlog 2 | `docs/23-sprint-planning-2.md` | `docs: Sprint Planning 2 con la meta y el Sprint Backlog 2 (HU-07 a HU-13)` |
| 2 | Arquitectura por capas: repositorio de reportes | `app/lib/data/reports_repository.dart` | `feat: arquitectura por capas con repositorio de reportes` |
| 3 | Estado global con Riverpod (lista migrada) | `app/lib/providers/`, `app/lib/main.dart`, `app/lib/screens/reports_list_screen.dart`, `app/pubspec.yaml` | `feat: estado global con Riverpod (FutureProvider de reportes)` |
| 4 | Borradores de reporte (HU-07) | `app/lib/data/draft_store.dart`, `app/lib/screens/new_report_screen.dart`, `app/pubspec.yaml` | `feat: borradores de reporte con shared_preferences (HU-07)` |
| 5 | Versión 0.5.0 del paquete | `app/pubspec.yaml` | `chore: versión 0.5.0+1 para el inicio del Sprint 2` |
| 6 | Pruebas del borrador y del repositorio | `app/test/draft_provider_test.dart` | `test: pruebas del borrador (HU-07) y del repositorio/provider` |
| 7 | Registro de decisiones de arquitectura | `docs/24-arquitectura-capas.md` | `docs: decisión de arquitectura por capas y persistencia local` |
| 8 | Guía de commits del día | `docs/25-avance-git-dia6.md` | `docs: guía de commits del día 6` |
| 9 | Bitácora del día | `docs/26-bitacora-dia6.md` | `docs: bitácora del día 6 con el registro de HU-07` |
| 10 | README raíz y de la app actualizados | `README.md`, `app/README.md` | `docs: READMEs actualizados al inicio del Sprint 2` |

**Evidencia oficial del Día 6:** **Sprint Backlog 2 publicado en el tablero**
(captura del tablero + acta `docs/23`). La lista de cotejo del día verifica
además la arquitectura por capas, el borrador HU-07 y la higiene de Git.

## 2. Rama y flujo del día

```bash
# El Sprint 2 arranca desde lo estable del Sprint 1
git switch dev && git pull origin dev
git switch -c feature/dia6-arquitectura-persistencia

# Dependencias del día (arquitectura y persistencia local)
cd app
fvm flutter pub add flutter_riverpod shared_preferences
cd ..

# ... pasos de la Guía Práctica (A–F) con un commit por pieza ...

git push -u origin feature/dia6-arquitectura-persistencia
# Pull Request hacia dev con revisión por pares (regla del curso)
```

## 3. Los 10 commits del Día 6 (uno por pieza, nunca un commit gigante)

```text
docs:  Sprint Planning 2 con la meta y el Sprint Backlog 2 (HU-07 a HU-13)
feat:  arquitectura por capas con repositorio de reportes
feat:  estado global con Riverpod (FutureProvider de reportes)
feat:  borradores de reporte con shared_preferences (HU-07)
chore: versión 0.5.0+1 para el inicio del Sprint 2
test:  pruebas del borrador (HU-07) y del repositorio/provider
docs:  decisión de arquitectura por capas y persistencia local
docs:  guía de commits del día 6
docs:  bitácora del día 6 con el registro de HU-07
docs:  READMEs actualizados al inicio del Sprint 2
```

## 4. Etiqueta del día

```bash
git tag -a v0.5.0-dia6 -m "Inicio del Sprint 2 (Clase 6): arquitectura por capas, \
Riverpod y HU-07 (borradores con shared_preferences)"
git push origin v0.5.0-dia6
```

Historial de tags: `v0.0.0-sprint0` → `v0.1.0-dia2` → `v0.2.0-dia3` →
`v0.3.0-dia4` → `v0.4.0-dia5` → **`v0.5.0-dia6`**.

## 5. Qué revisa el docente en el PR del Día 6

1. La pantalla de lista **no importa** `mock_reports.dart` (solo providers).
2. `main.dart` envuelve la app en `ProviderScope`.
3. El borrador se guarda en cada cambio y se limpia al enviar con éxito.
4. `SharedPreferences.setMockInitialValues` en las pruebas (sin dispositivo).
5. `fvm flutter analyze` sin advertencias y `fvm flutter test` en verde
   (12 pruebas: 9 del Sprint 1 + 3 nuevas del Día 6... en este paquete:
   6 del Día 4 + 3 del Día 5 + 5 del Día 6).
6. Commits convencionales y atómicos (feat/test/chore/docs).
