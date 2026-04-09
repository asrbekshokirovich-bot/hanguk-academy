-- Supabase Schema for Hanguk Academy
-- Run this in the Supabase SQL Editor

-- Enable pgcrypto for UUIDs
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- === ENUMS ===
CREATE TYPE user_role AS ENUM ('student', 'teacher', 'admin');

-- === TABLES ===

-- 1. Profiles (Extends Supabase Auth Auth.users)
CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  first_name TEXT,
  last_name TEXT,
  role user_role DEFAULT 'student'::user_role NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Cohorts (Class Groups)
CREATE TABLE cohorts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  teacher_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
  level TEXT NOT NULL, -- e.g., 'Beginner', 'Intermediate'
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Enrollments (Students in Cohorts)
CREATE TABLE enrollments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  student_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  cohort_id UUID REFERENCES cohorts(id) ON DELETE CASCADE,
  enrolled_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(student_id, cohort_id)
);

-- 4. Schedules (Individual live sessions)
CREATE TABLE schedules (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  cohort_id UUID REFERENCES cohorts(id) ON DELETE CASCADE,
  topic TEXT NOT NULL,
  start_time TIMESTAMPTZ NOT NULL,
  duration_minutes INTEGER DEFAULT 60,
  livekit_room_name TEXT, -- Will be generated before class starts
  recording_url TEXT, -- Egress output destination
  created_at TIMESTAMPTZ DEFAULT NOW()
);


-- === ROW LEVEL SECURITY (RLS) ===

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE cohorts ENABLE ROW LEVEL SECURITY;
ALTER TABLE enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE schedules ENABLE ROW LEVEL SECURITY;

-- Profiles: 
-- Students can read their own. Teachers/Admins can read all.
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

-- Cohorts:
-- Anyone authenticated can view cohorts (for browsing/joining). 
-- Only Teachers/Admins can create/update.
CREATE POLICY "Anyone can view cohorts" ON cohorts
  FOR SELECT USING (auth.role() = 'authenticated');

-- Enrollments:
-- Students view their own enrollments. Teachers view enrollments for their cohorts.
CREATE POLICY "Students view own enrollments" ON enrollments
  FOR SELECT USING (student_id = auth.uid());

CREATE POLICY "Teachers view their cohort enrollments" ON enrollments
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM cohorts 
      WHERE cohorts.id = enrollments.cohort_id 
      AND cohorts.teacher_id = auth.uid()
    )
  );

-- Schedules:
-- Students view schedules for their enrolled cohorts. Teachers view schedules for their cohorts.
CREATE POLICY "Students view enrolled schedules" ON schedules
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM enrollments 
      WHERE enrollments.cohort_id = schedules.cohort_id 
      AND enrollments.student_id = auth.uid()
    )
  );

CREATE POLICY "Teachers view their own schedules" ON schedules
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM cohorts 
      WHERE cohorts.id = schedules.cohort_id 
      AND cohorts.teacher_id = auth.uid()
    )
  );

-- === TRIGGERS ===
-- Automatically create profile on user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, email, first_name, last_name, role)
  VALUES (
    new.id, 
    new.email, 
    new.raw_user_meta_data->>'first_name', 
    new.raw_user_meta_data->>'last_name',
    COALESCE((new.raw_user_meta_data->>'role')::user_role, 'student'::user_role)
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
