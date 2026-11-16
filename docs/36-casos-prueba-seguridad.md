# 36 · Casos de prueba de seguridad — Día 9 (EVIDENCIA OFICIAL)

> Evidencia del Día 9 según el Cronograma: **"Casos de prueba de seguridad
> (lista de cotejo)"**. Son 12 casos (SP-01..SP-12): los SP-01..SP-08
> ejecutan la app (modo real con tu proyecto Supabase), los SP-09..SP-12
> combinan app, SQL y Storage. La lista de cotejo del día (ítems 1-12)
> se llena con el RESULTADO de estos casos.
>
> Reglas del laboratorio:
> 1. Ejecuta primero `db/rls_dia9.sql` en tu proyecto (SQL Editor).
> 2. Crea las 2 cuentas de prueba desde la app (pantalla "Crear cuenta").
> 3. Anota `OK` / `FALLO` + captura en la columna Resultado: la captura
>    con el mensaje de error de RLS ES la evidencia del Hito 2.

## A. Autenticación (HU-08) — con las 2 cuentas creadas

| ID | Caso | Pasos | Esperado | Resultado |
|---|---|---|---|---|
| SP-01 | Registro crea cuenta y abre sesión | Crear cuenta `rosa.test@ciudadalerta.bo` / `Clave2026`; volver a la bienvenida | Perfil muestra nombre + correo + `auth.uid()` | OK / FALLO |
| SP-02 | Política de contraseña | Intentar registro con `abc123` | Mensaje "Mínimo 8 caracteres" / mayúscula / número; NO se crea la cuenta | OK / FALLO |
| SP-03 | Correo duplicado | Repetir el registro de SP-01 con el mismo correo | Mensaje "Ese correo ya tiene una cuenta"; no se duplica | OK / FALLO |
| SP-04 | Login con contraseña incorrecta | Login de rosa.test con `Incorrecta1` | "Credenciales inválidas" genérico (no revela si el correo existe) | OK / FALLO |
| SP-05 | Sesion persistente | Cerrar la app completamente y abrirla de nuevo | Botón "Continuar como …" en la bienvenida; el JWT sobrevivió (secure storage) | OK / FALLO |
| SP-06 | Cierre de sesión | Perfil → Cerrar sesión → confirmar | Regresa a Invitado; sin sesión no se puede INSERT (SP-08 lo prueba) | OK / FALLO |

## B. Autorización por RLS (la BD como última barrera)

| ID | Caso | Pasos | Esperado | Resultado |
|---|---|---|---|---|
| SP-07 | **Prueba cruzada**: editar reporte ajeno | Con carlos.test abrir RPT-001 (de rosa.test) y editar título | La app muestra error (RLS); en BD el título NO cambia: `select titulo from reports where codigo='RPT-001'` | OK / FALLO |
| SP-08 | DELETE ajeno + anon | Con carlos.test eliminar RPT-003 (de rosa.test); luego intentar crear reporte SIN sesión | 0 filas / error 403; sin JWT el INSERT se rechaza por `auth.uid() = usuario_id` | OK / FALLO |
| SP-09 | INSERT firmado por el dueño | Con rosa.test crear un reporte nuevo | INSERT OK; en BD `usuario_id` = auth.uid() de rosa (NO el seed del Día 7) | OK / FALLO |

## C. Recursos nativos y Storage (HU-11)

| ID | Caso | Pasos | Esperado | Resultado |
|---|---|---|---|---|
| SP-10 | Cámara con permiso denegado | Nuevo reporte → Cámara → negar permiso (y "no permitir") | Mensaje de ayuda (Ajustes); el formulario sigue usable sin foto | OK / FALLO |
| SP-11 | Subida y miniatura | Con rosa.test crear reporte con foto de galería | Miniatura en el formulario y en el detalle; archivo en Storage `fotos-reportes/{uid}/…`; fila en `report_photos` | OK / FALLO |
| SP-12 | Foto a reporte ajeno (SQL) | En SQL Editor, INSERT en `report_photos` apuntando a un reporte de rosa (con JWT de carlos) | Rechazado por política "fotos de mis reportes"; auditoría final con la última consulta del script | OK / FALLO |

## Consultas de apoyo (SQL Editor)

```sql
-- ¿De quién es cada reporte? (SP-07/SP-09)
select codigo, titulo, usuario_id,
       (usuario_id = auth.uid()) as es_mio
from reports order by creado_en desc;

-- Fotos por reporte (SP-11)
select r.codigo, p.url from report_photos p
join reports r on r.id = p.reporte_id
order by p.creado_en desc;

-- Inventario de políticas (SP-12, evidencia para el Informe 2)
select tablename, policyname, cmd from pg_policies
where schemaname = 'public' order by tablename, policyname;
```

## Cierre del día: prueba cruzada entre equipos (Daily Scrum del cierre)

- El equipo A intenta, desde SU app, modificar un reporte del equipo B
  (la BD es la del proyecto guía o la del propio B con credenciales de A).
- Resultado esperado: **todos los intentos fallan** y cada equipo muestra
  la captura del error RLS. Si alguien logra editar una fila ajena,
  la lista de cotejo del día NO se aprueba y la política se corrige en vivo.
