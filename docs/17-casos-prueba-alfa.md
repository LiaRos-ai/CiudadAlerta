# 17 · Planilla de casos de prueba alfa — Sprint 1 (Día 5)

> Instrumento del laboratorio del Día 5. Una **prueba alfa** es la prueba interna que
> el propio equipo ejecuta antes de mostrar el incremento a los usuarios (Sprint Review).
> Cada caso tiene pasos reproducibles, un resultado esperado verificable contra los
> criterios de aceptación de las HU-01 a HU-06 y un resultado real que se registra con
> evidencia (captura o texto). Los fallos se convierten en **issues** de GitHub.

## Cómo registrar un caso

| Campo | Qué se escribe |
|---|---|
| **Resultado real** | Exactamente lo que pasó (no "funcionó"): qué se vio, qué texto apareció. |
| **Estado** | ✅ PASA · ❌ FALLA · ⚠️ PASA CON OBSERVACIÓN |
| **Bug** | Si FALLA: issue en GitHub con pasos, esperado vs. real, severidad (bloqueante / mayor / menor / cosmético) y captura. |

## Planilla del Sprint 1 (10 casos)

| # | Caso de prueba | Criterio que verifica | Pasos | Resultado esperado | Resultado real | Estado |
|---|---|---|---|---|---|---|
| CP-01 | Bienvenida sin errores de layout | HU-01 | Abrir la app en emulador vertical; rotar a horizontal; repetir en un dispositivo pequeño (o vista de pantalla pequeña del emulador). | Logo, campos y botón visibles y alineados en los 2 tamaños; sin overflow amarillo/negro. | _completar_ | _._ |
| CP-02 | Navegación por 4 pestañas | HU-02 | Tocar Inicio → Mapa → Nuevo → Perfil → Inicio. | Las 4 pestañas responden; la pestaña activa queda marcada; la barra siempre visible. | _completar_ | _._ |
| CP-03 | El estado de las pestañas se conserva | HU-02 | Entrar a Inicio (esperar la carga de 600 ms), ir a Nuevo y volver a Inicio. | La lista NO se recarga (sin indicador de carga de nuevo): el shell conserva el estado. | _completar_ | _._ |
| CP-04 | Lista con datos mock | HU-03 | Abrir Inicio y contar las tarjetas; observar el indicador de carga inicial. | 8 tarjetas con título, categoría y fecha; primero se ve el CircularProgressIndicator. | _completar_ | _._ |
| CP-05 | Detalle muestra TODOS los campos | HU-04 | Tocar el reporte RPT-001 en la lista. | Se ven: id, título, categoría, zona, fecha, estado, urgencia y descripción completa. | _completar_ | _._ |
| CP-06 | Detalle con id inexistente (borde) | HU-04 | Navegar manualmente a `/reporte/RPT-999` (o tocar un reporte borrado). | Mensaje claro "No existe el reporte…"; sin pantalla roja de crash. | _completar_ | _._ |
| CP-07 | Formulario no envía datos inválidos | HU-05 | En Nuevo, enviar vacío; luego enviar con título de 4 letras. | Mensajes de error claros por campo; nunca aparece el SnackBar de éxito. | _completar_ | _._ |
| CP-08 | Formulario válido confirma y limpia | HU-05 | Llenar título (≥5), categoría y descripción (≥10); enviar. | SnackBar "Reporte registrado (demo)" y los 3 campos quedan vacíos. | _completar_ | _._ |
| CP-09 | Tema claro/oscuro del sistema | HU-06 | Activar el modo oscuro del emulador (Ajustes → Pantalla); volver a modo claro. | La app cambia sola en ambos sentidos; textos legibles y contraste correcto en los dos modos. | _completar_ | _._ |
| CP-10 | Áreas táctiles y lector de pantalla | HU-23 (avance) | Activar TalkBack (Ajustes → Accesibilidad) y recorrer HU-01 → lista. | Los botones y filas anuncian su contenido; las áreas de toque se sienten grandes (≥48 dp). | _completar_ | _._ |

## Pruebas exploratorias (15 min, sin guion)

Además de los casos, explorar libremente buscando lo que el guion no cubre:
entrar y salir rápido de pestañas, girar el teléfono a mitad de la carga del
mock, escribir 500 caracteres en la descripción, tocar dos veces el botón
Enviar, cambiar el idioma del sistema. Cada hallazgo se registra igual que un
caso fallido: issue con pasos y severidad.

## Cierre

- Casos ejecutados: ___ / 10 · Pasan: ___ · Fallan: ___ · Con observación: ___
- Issues abiertos al cierre: ___ (bloqueantes: ___)
- Responsable del registro: _______________ · Fecha: ___________
