# 40 · Acta del Sprint Review 2 — CiudadAlerta (Día 10)

> Evento Scrum de cierre del Sprint 2 (Hito 2). 20 minutos, facilitados por
> el Product Owner (docente). El equipo muestra el incremento INSTALABLE en
> un teléfono real y el PO decide qué entra al Informe 2.

## Datos

| Campo | Valor |
|---|---|
| Sprint | 2 (Hito 2: "Aplicaciones híbridas y conexión a base de datos") |
| Meta del sprint | App híbrida con autenticación, CRUD y consultas contra PostgreSQL (Supabase), un recurso nativo y un APK release instalable |
| Duración | 20 min (10 demo + 5 discusión + 5 acuerdos) |
| Asistentes | Equipo de developers + Product Owner (docente) + Scrum Master del día |
| Incremento | `v0.9.0-dia10`: app-release.apk instalado en dispositivo real |

## Demo por historia (lo mostrado en el teléfono)

| HU | Historia | Estado | Evidencia mostrada |
|---|---|---|---|
| HU-07 | Borradores locales (shared_preferences) | Hecha | Cierre de app + reabrir: "Borrador restaurado" |
| HU-08 | Registro e inicio de sesión (Supabase Auth) | Hecha | Rosa entra, JWT en secure storage, cierre de sesión |
| HU-09 | Lista desde la BD con filtro y orden | Hecha | Chips de categoría + pull-to-refresh con la BD real |
| HU-10 | Crear / editar / eliminar reportes | Hecha | INSERT firmado con auth.uid(); edición y CASCADE |
| HU-11 | Foto con permisos y Storage | Hecha | Foto del aula subida a fotos-reportes + miniatura |
| HU-12 | APK release instalable | Hecha (hoy) | Ícono y splash propios; instalación con adb |
| HU-13 | Estadísticas con GROUP BY y gráfico | Hecha | BarChart por categoría se actualiza tras el CRUD |

**Puntos comprometidos 31 / puntos hechos 31** — meta del sprint cumplida.

## Observaciones del Product Owner (para el trabajo autónomo)

1. La lista debe **recordar el filtro activo** tras volver del detalle
   (pequeño pulido de UX para el Sprint 3, no bloquea el Hito 2).
2. En la demo del teléfono falló una subida de foto por red lenta: el
   reporte sobrevivió y la foto se reintentó (deterioro elegante OK);
   documentar el caso en el Informe 2 como lección.
3. El ícono adaptativo se ve cortado en un launcher con máscara circular:
   regenerar mipmaps revisando la zona segura del foreground.
4. Falta un texto de "¿qué puedo reportar?" en la primera pantalla:
   candidato a HU nueva para el Sprint 3 (se evalúa en el refinamiento).

## Decisiones

- **Hito 2 se entrega hoy**: Informe 2 (docs/42) + APK instalable
  sustentados en el proyecto paralelo (5 min por equipo).
- Las observaciones 1 y 3 pasan al Sprint Backlog 3 (refinamiento del
  cierre); la 4 se agrega como candidato a HU del Product Backlog.
- Tag de cierre: `v0.9.0-dia10` (95 → 112 commits).
