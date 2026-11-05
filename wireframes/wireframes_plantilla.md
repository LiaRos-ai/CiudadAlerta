# 11 · Wireframes de baja fidelidad — Día 2 — CiudadAlerta

> Entregable del **Día 2** (45 min del proyecto paralelo): wireframes de las
> **4 pantallas clave** de la app, en papel o Figma. Sirven de insumo para las
> 2 primeras pantallas del Día 3 (HU-01 y HU-02) y para el Informe 1.
> Regla: baja fidelidad = cajas, textos y flechas; nada de colores ni logos.

## Qué es un wireframe

Un wireframe ("wire" = cable, "frame" = marco) es el esqueleto de una pantalla:
muestra **qué elementos existen y dónde van** (encabezado, lista, botón, menú),
sin entrar en diseño visual. Se dibuja rápido y se descarta barato: es normal
hacer 2-3 versiones antes de acertar.

## Nivel de detalle exigido en el Día 2

- Solo 4 pantallas: las que resuelven el corazón del problema de su proyecto.
- Elementos: barras, botones, campos de texto, listas, íconos como cajas con X.
- Etiquetas de texto simples. Anotaciones al margen (ej.: "aquí pide permiso de ubicación").
- Herramienta libre: papel + lápiz y foto, o Figma (plan Educación) o Excalidraw.

## Ejemplo de referencia — CiudadAlerta (Proyecto Guía)

```
┌──────────────────┐   ┌──────────────────┐   ┌──────────────────┐   ┌──────────────────┐
│ W1 · INICIO      │   │ W2 · NUEVO       │   │ W3 · DETALLE DE  │   │ W4 · MI PERFIL   │
│                  │   │      REPORTE     │   │      REPORTE     │   │                  │
│ [logo texto]     │   │ [título campo]   │   │ [foto grande]    │   │ [nombre usuario] │
│ [buscar reporte] │→  │ [descripción]    │→  │ [estado: chip]   │→  │ [mis reportes]   │
│ [lista reportes] │   │ [botón cámara]   │   │ [mapa miniatura] │   │ [puntos]         │
│  ┌────────────┐  │   │ [botón voz]      │   │ [comentarios]    │   │ [config]         │
│  │foto│título│  │   │ [mapa: ubicación]│   │ [botón comentar] │   │ [cerrar sesión]  │
│  └────────────┘  │   │ [botón ENVIAR]   │   │                  │   │                  │
│ [tab inferior]   │   │                  │   │                  │   │                  │
└──────────────────┘   └──────────────────┘   └──────────────────┘   └──────────────────┘
```

## Plantilla para cada pantalla del proyecto paralelo

Copia este bloque por cada pantalla y complétalo:

```
Pantalla N: [nombre]
Objetivo de la pantalla: [qué puede hacer el usuario aquí]
Elementos y ubicación (de arriba hacia abajo):
  1. ____
  2. ____
  3. ____
  4. ____
Navegación: desde ____ llega aquí; desde aquí va a ____
Anotaciones técnicas: [permisos, datos que necesitará, si depende de BD/API]
```

## Cómo se conecta con los siguientes días

| Día | Qué se hará con los wireframes |
|---|---|
| Día 3 | Las pantallas 1 y 2 se implementan con widgets Flutter (HU-01, HU-02). |
| Día 4 | Navegación entre pantallas (go_router) y formularios según el flujo. |
| Día 5 | Capturas comparativas wireframe vs app para el Informe 1. |
