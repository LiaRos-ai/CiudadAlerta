-- CiudadAlerta · Día 14 / HU-17: tokens de notificación y aviso de estado
-- Ejecutar en el SQL Editor de Supabase (después de schema.sql,
-- rls_dia9.sql y ubicaciones_dia12.sql).
--
-- Dos piezas:
--   1. push_tokens: el token FCM de cada dispositivo, LIGADO AL USUARIO.
--      El token no es secreto (no abre nada por sí solo), pero es un
--      dato personal: RLS por auth.uid() — cada usuario guarda y lee
--      SOLO su fila (la app hace UPSERT con la política de abajo).
--   2. El ciclo del aviso: cuando el estado de un reporte CAMBIA, un
--      trigger deja la tarea en avisos_pendientes. La Edge Function
--      notificar-cambio-estado (docs/60) la consume y envía el push
--      por FCM con service_role en SECRETO del servidor, nunca en la
--      app. Sin Edge Function, la fila queda en la cola: el aviso no
--      se pierde, queda pendiente (mismo criterio del borrador HU-07).

-- ---------------------------------------------------------------- push_tokens
create table if not exists push_tokens (
  usuario_id uuid primary key references auth.users(id) on delete cascade,
  token text not null,
  plataforma text not null default 'android' check (plataforma in ('android','ios')),
  actualizado_en timestamptz not null default now()
);

alter table push_tokens enable row level security;

create policy "guardar mi token"
  on push_tokens for insert
  with check (auth.uid() = usuario_id);

create policy "actualizar mi token"
  on push_tokens for update
  using (auth.uid() = usuario_id)
  with check (auth.uid() = usuario_id);

create policy "leer mi token"
  on push_tokens for select
  using (auth.uid() = usuario_id);

-- ------------------------------------------------------- cola de avisos
create table if not exists avisos_pendientes (
  id bigserial primary key,
  reporte_id uuid not null references reports(id) on delete cascade,
  usuario_id uuid,
  codigo text,
  titulo text,
  estado_anterior text,
  estado_nuevo text not null,
  creado_en timestamptz not null default now(),
  enviado boolean not null default false
);

alter table avisos_pendientes enable row level security;

-- El servicio (service_role) la lee; los clientes anon NO (sin policy).

create or replace function notificar_cambio_estado()
returns trigger
language plpgsql
as $$
begin
  -- La MISMA regla de aviso_estado.dart: solo si el estado cambió.
  insert into avisos_pendientes (reporte_id, usuario_id, codigo, titulo,
                                 estado_anterior, estado_nuevo)
  values (new.id, new.usuario_id, new.codigo, new.titulo,
          old.estado, new.estado);
  return new;
end;
$$;

create trigger trg_estado_cambio
  after update of estado on reports
  for each row
  when (old.estado is distinct from new.estado)
  execute function notificar_cambio_estado();

-- ---------------------------------------------------------- verificación
-- select count(*) from push_tokens;             -- 0 hasta que la app registre
-- update reports set estado = 'En proceso'
--  where codigo = 'RPT-001';                    -- dispara el trigger
-- select codigo, estado_anterior, estado_nuevo, enviado
--   from avisos_pendientes order by creado_en desc limit 3;
