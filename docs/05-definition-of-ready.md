# 5 · Definition of Ready — CiudadAlerta (Sprint 0)

> Una historia entra al Sprint Backlog solo si cumple la Definition of Ready.
> Se revisa en el Refinamiento (cierre del día 5 de cada sprint).

## Checklist de Ready

- [ ] La historia tiene formato **"Como [rol] quiero [acción] para [beneficio]"**.
- [ ] Tiene **criterios de aceptación verificables** (se pueden probar en la app).
- [ ] Está **estimada en puntos** (escala Fibonacci: 1, 2, 3, 5, 8).
- [ ] **No depende** de algo que aún no existe, o la dependencia está identificada
      (por ejemplo: HU-14 requiere la API key de Google Maps del proyecto de la nube).
- [ ] **Cabe en un sprint** y el equipo entiende cómo probarla.

## Dependencias externas conocidas (Sprint 0)

| Historia | Dependencia externa | Responsable |
|---|---|---|
| HU-11, HU-18 | Cuenta y bucket de AWS S3 / Lambda con presupuesto configurado | Docente + equipo |
| HU-14, HU-15, HU-20 | Proyecto de Google Cloud con Maps Platform y alerta de presupuesto | Docente + equipo |
| HU-17 | Proyecto de Firebase (FCM) | Docente + equipo |
| HU-08 a HU-13 | Proyecto de Supabase con esquema y RLS | Docente (guía) + equipo |

## Ejemplos de historias NO listas (y cómo se corrigen)

1. *"Mejorar la app"* → sin rol ni beneficio; se reescribe como HU-23 (fluida y accesible).
2. *"Poner mapa"* → sin criterios; se corrige como HU-14 (marcadores + toque abre detalle).
3. *"API de IA"* → sin estimación ni dependencia; se estima con Planning Poker y se
   identifica la dependencia de AWS (HU-18).
