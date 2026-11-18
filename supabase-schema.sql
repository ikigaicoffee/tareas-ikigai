-- ===========================================
-- TAREAS IKIGAI - Schema para Supabase
-- Ejecutar este SQL en el SQL Editor de Supabase
-- ===========================================

-- Tabla de usuarios (auth con username/password, sin email)
CREATE TABLE public.users (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  username text UNIQUE NOT NULL,
  password_hash text NOT NULL,
  salt text NOT NULL,
  start_time text DEFAULT '09:00',
  end_time text DEFAULT '18:00',
  is_admin boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

-- Tabla de tareas (configuración)
CREATE TABLE public.tasks (
  id text PRIMARY KEY,
  title text NOT NULL,
  detail text,
  phase text NOT NULL DEFAULT 'dia', -- apertura, dia, cierre
  kind text NOT NULL DEFAULT 'check', -- check, number, text, info, hourly
  due text,
  who text[] DEFAULT '{}',
  active boolean DEFAULT true,
  suggested boolean DEFAULT false,
  unit text,
  placeholder text,
  from_hour int DEFAULT 9,
  to_hour int DEFAULT 19,
  sort_order int DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

-- Registros de tareas completadas
CREATE TABLE public.task_logs (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  log_date text NOT NULL,
  task_id text NOT NULL,
  slot text DEFAULT '',
  person_name text NOT NULL,
  completed_time text NOT NULL,
  completed_ts bigint NOT NULL,
  value text,
  user_id uuid REFERENCES public.users(id),
  created_at timestamptz DEFAULT now(),
  UNIQUE(log_date, task_id, slot)
);

-- Faltantes
CREATE TABLE public.faltantes (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  item text NOT NULL,
  qty text,
  person_name text NOT NULL,
  falt_date text NOT NULL,
  falt_time text NOT NULL,
  done boolean DEFAULT false,
  user_id uuid REFERENCES public.users(id),
  created_at timestamptz DEFAULT now()
);

-- Configuración general
CREATE TABLE public.config (
  key text PRIMARY KEY,
  value text
);

-- Insertar config inicial
INSERT INTO public.config (key, value) VALUES ('whatsapp', '') ON CONFLICT DO NOTHING;

-- ===========================================
-- Row Level Security (RLS) - acceso público
-- ===========================================

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.task_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.faltantes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.config ENABLE ROW LEVEL SECURITY;

-- Políticas: lectura pública, escritura pública (auth es app-level)
CREATE POLICY "users_read" ON public.users FOR SELECT USING (true);
CREATE POLICY "users_insert" ON public.users FOR INSERT WITH CHECK (true);
CREATE POLICY "users_update" ON public.users FOR UPDATE USING (true);

CREATE POLICY "tasks_read" ON public.tasks FOR SELECT USING (true);
CREATE POLICY "tasks_insert" ON public.tasks FOR INSERT WITH CHECK (true);
CREATE POLICY "tasks_update" ON public.tasks FOR UPDATE USING (true);
CREATE POLICY "tasks_delete" ON public.tasks FOR DELETE USING (true);

CREATE POLICY "logs_read" ON public.task_logs FOR SELECT USING (true);
CREATE POLICY "logs_insert" ON public.task_logs FOR INSERT WITH CHECK (true);
CREATE POLICY "logs_delete" ON public.task_logs FOR DELETE USING (true);

CREATE POLICY "faltantes_read" ON public.faltantes FOR SELECT USING (true);
CREATE POLICY "faltantes_insert" ON public.faltantes FOR INSERT WITH CHECK (true);
CREATE POLICY "faltantes_update" ON public.faltantes FOR UPDATE USING (true);

CREATE POLICY "config_read" ON public.config FOR SELECT USING (true);
CREATE POLICY "config_update" ON public.config FOR UPDATE USING (true);
CREATE POLICY "config_insert" ON public.config FOR INSERT WITH CHECK (true);

-- Índices para performance
CREATE INDEX idx_task_logs_date ON public.task_logs(log_date);
CREATE INDEX idx_task_logs_lookup ON public.task_logs(log_date, task_id, slot);
CREATE INDEX idx_faltantes_done ON public.faltantes(done);
