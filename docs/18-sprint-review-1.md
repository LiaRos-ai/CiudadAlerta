# 18 · Acta del Sprint Review 1 — CiudadAlerta (Día 5)

> Evento Scrum de cierre del Sprint 1 (30 min según el plan del Día 5). El Sprint Review
> NO es una reunión de estado: es una **demo del incremento working** contra la Meta del
> Sprint, seguida de la actualización del Product Backlog por el Product Owner.

## Datos de la sesión

| Campo | Valor |
|---|---|
| Sprint | 1 (Hito 1) · días 1-5 |
| Meta del Sprint | Una app móvil sencilla en Flutter (≥4 pantallas navegables con datos simulados) ejecutándose en emulador y dispositivo real, con repositorio, tablero Scrum y pruebas alfa. |
| Duración | 30 min (15 demo + 10 ajustes al backlog + 5 cierre) |
| Participantes | Docente (Product Owner), Scrum Master rotativo del día, equipo completo |
| Evidencia | Este acta + demo en emulador + tag `v0.4.0-dia5` |

## 1. Resultado contra la meta (15 min de demo)

Orden del recorrido (el mismo para el Proyecto Guía y para cada proyecto paralelo):
bienvenida (HU-01) → 4 pestañas (HU-02) → lista con datos mock (HU-03) →
detalle con parámetro (HU-04) → formulario validado (HU-05) → tema oscuro del
sistema (HU-06). Cada demo termina mostrando `fvm flutter test` en verde y
`fvm flutter analyze` sin advertencias.

| HU | Historia (resumen) | Puntos | Estado | Evidencia |
|---|---|---|---|---|
| HU-01 | Bienvenida / inicio de sesión (UI) | 3 | ✅ Hecho | `welcome_screen.dart`, captura CP-01 |
| HU-02 | Navegación por 4 pestañas | 3 | ✅ Hecho | `app_router.dart` + `home_shell.dart`, CP-02/03 |
| HU-03 | Lista de reportes con datos mock | 5 | ✅ Hecho | `reports_list_screen.dart`, CP-04 |
| HU-04 | Detalle del reporte | 3 | ✅ Hecho | `report_detail_screen.dart`, CP-05/06 |
| HU-05 | Formulario con validación | 5 | ✅ Hecho | `new_report_screen.dart`, CP-07/08 |
| HU-06 | Tema claro/oscuro (Could) | 2 | ✅ Hecho | `app_theme.dart` + `main.dart`, CP-09 |

**Totales del sprint:** planificados 21 pts · completados 21 pts · 100 % de las
historias comprometidas (las 4 Must del día 4 + la Could del día 5).

## 2. Qué NO se hizo (transparencia)

- Persistencia real: el envío del formulario es demo (SnackBar); Supabase
  llega con el Sprint 2 (HU-07 a HU-13).
- Mapa y perfil siguen siendo placeholders por diseño (HU-14 y HU-08 son de
  sprints posteriores).
- Las pruebas alfa cubren el flujo feliz y los bordes del Sprint 1; las
  pruebas unitarias de lógica de negocio aparecen en el Sprint 4 (HU-22).

## 3. Ajustes al Product Backlog (10 min de PO)

- Refinamiento de HU-07 a HU-13 (Sprint 2): criterios reescritos en "dado /
  cuando / entonces" y dependencias marcadas (HU-09 y HU-10 requieren el
  esquema de BD del Día 7).
- El mock `cargarReportes()` se mantiene como contrato: en el Sprint 2 solo
  cambia la fuente de datos.
- Bugs menores de las pruebas alfa cruzadas se agregaron al backlog como
  tarjetas técnicas (sin puntos, se resuelven en el Sprint 2).

## 4. Cierre (5 min)

- El incremento cumple la **Definition of Done** (`docs/04-definition-of-done.md`):
  código en dev vía PR revisado, pruebas en verde, tablero actualizado.
- Aprobación del PO para **publicar el release v0.1** (tag `v0.4.0-dia5`).
- Siguiente evento: Retrospectiva 1 (`docs/19-retrospectiva-1.md`).

**Firmas / acuerdo del equipo:** ______________________
