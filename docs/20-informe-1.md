# 20 · Informe 1 — Creación de aplicación móvil sencilla con frameworks

> **Entregable del Hito 1 (20 pts, Matriz 1)** — se sustenta el Día 5. Este documento es
> la plantilla COMPLETADA por el Proyecto Guía CiudadAlerta: los equipos la replican con
> los datos de su proyecto paralelo. Evidencia exigida por el plan: *matriz de decisión,
> wireframes, app y reporte de pruebas alfa*.

## 1. Datos de identificación

| Campo | Valor |
|---|---|
| Asignatura | Aplicaciones Móviles I (SIS-0180) · Ingeniería de Sistemas · 8.º semestre |
| Hito / Sprint | Hito 1 · Sprint 1 (días 1-5) |
| Proyecto | CiudadAlerta (Proyecto Guía) — app de reportes ciudadanos para La Paz y El Alto |
| Equipo | Docente (Product Owner) + Scrum Master rotativo + desarrollo en parejas |
| Repositorio | GitHub con tags `v0.0.0-sprint0` → `v0.4.0-dia5` (release v0.1) |
| Fecha de entrega | Día 5 de la gestión 2026 |

## 2. Objetivo y resultado de aprendizaje

Instalar y configurar un framework de desarrollo multiplataforma seleccionándolo con
criterios técnicos, y crear una aplicación móvil sencilla con navegación y formularios,
aplicando pruebas alfa y trabajando en equipo con Scrum. La Meta del Sprint 1 —"una app
móvil sencilla en Flutter (≥4 pantallas navegables con datos simulados) ejecutándose en
emulador y dispositivo real, con repositorio, tablero Scrum y pruebas alfa"— se cumple:
6 historias de usuario (21 puntos), 9 pruebas en verde y release v0.1 publicado.

## 3. Matriz de decisión del framework (resumen)

Evaluación ponderada de 3 frameworks (pesos definidos en el Día 2; detalle completo en
`docs/09-matriz-decision-framework.md`):

| Criterio | Peso | Flutter | React Native | Ionic + Capacitor |
|---|---|---|---|---|
| Rendimiento (compila a nativo) | 25 % | 5 | 3 | 2 |
| Un solo lenguaje y equipo pequeño | 20 % | 5 | 4 | 4 |
| Curva de aprendizaje del grupo | 15 % | 4 | 3 | 3 |
| Ecosistema y documentación en español | 15 % | 5 | 4 | 3 |
| UI consistente (Material 3 integrado) | 15 % | 5 | 3 | 4 |
| Hot reload y herramientas | 10 % | 5 | 4 | 3 |
| **Ponderado** | 100 % | **4,85** | **3,45** | **3,05** |

**Justificación:** Flutter compila Dart a código nativo con motor de renderizado propio
(rendimiento predecible en dispositivos de gama media, el caso real de La Paz y El Alto),
integra Material 3 sin librerías extra y su hot reload reduce el ciclo de prueba en clase.
React Native quedó segundo por madurez del ecosistema, e Ionic tercero por su capa web
intermedia. La decisión se tomó en equipo con la matriz ponderada del Día 2 y quedó
registrada en el repositorio.

## 4. Wireframes y diseño

Los wireframes de baja fidelidad de 4 pantallas clave (Día 2, papel/Figma) guiaron el
desarrollo: bienvenida con logo y campos, lista de reportes con tarjetas, detalle con
todos los campos y formulario de nuevo reporte. La implementación respetó la estructura
de los wireframes y añadió la barra de navegación inferior definida en la HU-02, con el
sistema de diseño del curso: semilla verde #329B67, Material 3 y tema claro/oscuro
(HU-06) generado con `ColorScheme.fromSeed`.

## 5. La aplicación: qué hace y cómo está construida

**Historias de usuario entregadas (Sprint 1, 21 pts):**

| HU | Qué entrega | Pantalla / archivo clave |
|---|---|---|
| HU-01 | Bienvenida e inicio de sesión (UI) con validación de contraseña | `welcome_screen.dart` |
| HU-02 | Navegación por 4 pestañas (Inicio · Mapa · Nuevo · Perfil) | `app_router.dart`, `home_shell.dart` |
| HU-03 | Lista de reportes con `ListView.builder` y estados de datos | `reports_list_screen.dart` |
| HU-04 | Detalle del reporte con parámetro de ruta `/reporte/:id` | `report_detail_screen.dart` |
| HU-05 | Formulario "Nuevo reporte" con `Form` y validadores | `new_report_screen.dart` |
| HU-06 | Tema claro/oscuro que respeta la configuración del sistema | `app_theme.dart`, `main.dart` |

**Arquitectura por capas:** `routing` (go_router), `data` (modelo `Report` con
`fromJson`/`toJson` + mock con 8 reportes de La Paz y El Alto), `theme` (los 2 temas),
`widgets` (CustomButton, CustomInput, ReportCard) y `screens`. El modelo con
`fromJson`/`toJson` es el contrato con Supabase del Sprint 2: cambiar de mock a BD no
tocará la UI.

**Prueba técnica:** `fvm flutter test` = 9 pruebas verdes (flujo HU-01→HU-04,
validación HU-05, alfa del Día 5) y `fvm flutter analyze` sin advertencias.

## 6. Reporte de pruebas alfa

Planilla completa en `docs/17-casos-prueba-alfa.md`. Resumen:

| Indicador | Resultado |
|---|---|
| Casos de prueba definidos y ejecutados | 10 / 10 |
| Casos que pasan | 10 (incluye el borde CP-06: id inexistente sin crash) |
| Bugs abiertos al cierre | 0 bloqueantes; hallazgos menores registrados como issues |
| Pruebas exploratorias | 15 min por equipo; hallazgos anotados en la planilla |
| Herramientas de depuración usadas | `flutter analyze`, Flutter DevTools (widget inspector), logs de consola, TalkBack |

Método: cada caso tiene pasos reproducibles y resultado esperado contra el criterio de
aceptación de su HU; los fallos se convirtieron en issues de GitHub con severidad y
captura. Las pruebas alfa se ejecutaron tanto en emulador (AVD) como en dispositivo
físico por USB.

## 7. Control de versiones

- **GitFlow simplificado:** `main` (releases) ← `dev` (integración) ← `feature/*` (una rama por día).
- 38 commits convencionales (`feat:`, `test:`, `docs:`, `chore:`), Pull Requests con
  revisión cruzada y 5 tags: `v0.0.0-sprint0`, `v0.1.0-dia2`, `v0.2.0-dia3`,
  `v0.3.0-dia4`, `v0.4.0-dia5`.
- **Release v0.1 del producto** publicado con el tag `v0.4.0-dia5` (notas en GitHub Releases).

## 8. Conclusiones y aprendizajes del equipo

1. La matriz ponderada convirtió la elección de framework en una decisión defendible con
   datos, no en una preferencia.
2. Los datos mock creíbles permitieron terminar la UI sin backend y practicaron los
   estados de carga que exigirá la BD real.
3. Las pruebas alfa con casos escritos ANTES de la demo detectaron 3 problemas menores
   (layout rotado, doble toque en Enviar, contraste en modo oscuro) que el "ojo" solo
   no habría registrado.
4. Scrum ordenó el ritmo: el Daily de 5 min y el tablero evitaron el trabajo invisible;
   la retrospectiva dejó 2 acciones concretas para el Sprint 2.

## 9. Anexos (capturas)

A1. Bienvenida (claro) · A2. Shell de 4 pestañas · A3. Lista con carga · A4. Detalle
RPT-001 · A5. Errores del formulario vacío · A6. App en modo oscuro · A7. `flutter test`
en verde · A8. Historial de commits con los 5 tags.

---

**Evaluación (Matriz 1, 20 pts):** Resolutivo 9-12 (replica con ayuda) · Autónomo 13-16
(adapta y justifica) · Estratégico 17-20 (decide con criterio, documenta y mejora el
proceso). El docente completa la rúbrica durante la sustentación de 5 minutos por equipo.
