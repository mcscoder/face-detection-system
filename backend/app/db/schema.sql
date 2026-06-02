CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS vector;

CREATE TABLE IF NOT EXISTS roles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  description text NOT NULL DEFAULT ''
);

CREATE TABLE IF NOT EXISTS users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  username text NOT NULL UNIQUE,
  password_hash text NOT NULL,
  display_name text NOT NULL,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS user_roles (
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  role_id uuid NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
  PRIMARY KEY (user_id, role_id)
);

CREATE TABLE IF NOT EXISTS devices (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  api_key_hash text,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS people (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  employee_code text UNIQUE,
  display_name text NOT NULL,
  job_title text,
  access_status text NOT NULL DEFAULT 'active',
  extra_data jsonb NOT NULL DEFAULT '{}'::jsonb,
  is_deleted boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS face_templates (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  person_id uuid NOT NULL REFERENCES people(id),
  embedding vector(512) NOT NULL,
  model_pack text NOT NULL,
  model_version text NOT NULL,
  source_image_path text,
  is_active boolean NOT NULL DEFAULT true,
  quality_score double precision,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS recognition_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  device_id uuid REFERENCES devices(id),
  person_id uuid REFERENCES people(id),
  face_template_id uuid REFERENCES face_templates(id),
  matched boolean NOT NULL,
  decision text NOT NULL,
  similarity_score double precision,
  threshold double precision NOT NULL,
  failure_reason text,
  probe_image_path text,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS system_settings (
  key text PRIMARY KEY,
  value jsonb NOT NULL,
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_people_name ON people USING gin (to_tsvector('simple', display_name));
CREATE INDEX IF NOT EXISTS idx_people_extra_data ON people USING gin (extra_data);
CREATE INDEX IF NOT EXISTS idx_templates_active ON face_templates (person_id) WHERE is_active;
CREATE INDEX IF NOT EXISTS idx_templates_embedding ON face_templates USING ivfflat (embedding vector_cosine_ops);
CREATE INDEX IF NOT EXISTS idx_events_created_at ON recognition_events (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_events_person ON recognition_events (person_id, created_at DESC);

INSERT INTO roles (name, description) VALUES
  ('admin', 'Full local system administration'),
  ('operator', 'Recognition operation'),
  ('enrollment_operator', 'People and face enrollment')
ON CONFLICT (name) DO NOTHING;

INSERT INTO system_settings (key, value) VALUES
  ('recognition_threshold', '0.45'::jsonb),
  ('probe_retention_days', '0'::jsonb)
ON CONFLICT (key) DO NOTHING;

INSERT INTO system_settings (key, value) VALUES
  ('model_pack', '"buffalo_l"'::jsonb)
ON CONFLICT (key) DO UPDATE SET value = excluded.value, updated_at = now();
