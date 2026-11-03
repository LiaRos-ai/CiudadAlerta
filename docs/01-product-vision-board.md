# 1 · Product Vision Board — CiudadAlerta (Sprint 0)

> Artefacto del Día 1 (laboratorio guiado). El Product Vision Board resume la visión del
> producto y la hipótesis de valor. Fuente: plan de la asignatura (Proyecto Guía).

## Visión

**Para** ciudadanos de La Paz y El Alto que necesitan reportar problemas urbanos
(baches, luminarias, basura, riesgos), **CiudadAlerta** es una **app móvil** que
**permite crear reportes geolocalizados con foto y voz**, a diferencia de los canales
actuales dispersos, y **da seguimiento transparente al estado de cada reporte**.

## Producto (qué es)

- App móvil multiplataforma (Android primero; iOS vía CI en la nube).
- Reportes urbanos con **categoría, foto, descripción (texto o dictado por voz),
  ubicación GPS y dirección**.
- Mapa de reportes, estadísticas por categoría y estado, notificaciones al cambiar de estado.
- Panel de moderación para autoridades (cambio de estado de reportes).

## Usuarios y clientes (para quién)

| Segmento | Necesidad principal |
|---|---|
| Ciudadanos de La Paz y El Alto | Reportar y seguir problemas de su zona sin trámites dispersos. |
| Autoridades / moderadores municipales | Priorizar y gestionar la atención de reportes con estadísticas. |
| Comunidad vecinal | Conocer el estado real del barrio (transparencia). |

## Necesidades que atiende (problema)

- Los canales de reporte actuales están **dispersos** (teléfono, presencialidad, redes sociales).
- No hay **seguimiento** del reporte: el ciudadano no sabe si fue atendido.
- Sin evidencia estructurada (foto + ubicación) es difícil priorizar obras y mantenimientos.

## Valor diferencial (a diferencia de...)

- Reporte en **menos de 1 minuto**: ubicación automática + foto + dictado por voz.
- **Estado público y trazable** de cada reporte (recibido → en atención → resuelto).
- Estadísticas agregadas que apoyan decisiones de las autoridades locales.

## Beneficios y costos aproximados

| Concepto | Estimación |
|---|---|
| Beneficio ciudadano | Canal único de reportes con seguimiento en tiempo real. |
| Beneficio institucional | Datos agregados (GROUP BY categoría/estado) para priorizar. |
| Costo de desarrollo | Tiempo del equipo del curso (4 sprints). |
| Costo de operación | Plan gratuito de Supabase + cuota gratuita de Google Maps (con alertas de presupuesto) + capa gratuita AWS (monitoreada). |

## Meta del producto (Product Goal)

Un producto instalable (APK/AAB) estable, con base de datos y al menos 2 APIs externas,
documentado y probado con usuarios reales, sustentado en el Demo Day del Día 20.

## Hipótesis a validar con usuarios (pruebas beta del Sprint 4)

1. Un reporte con foto y ubicación se crea en menos de 1 minuto y sin errores.
2. El ciudadano entiende el estado de su reporte sin ayuda adicional.
3. Las estadísticas por categoría son útiles para priorizar la atención.
