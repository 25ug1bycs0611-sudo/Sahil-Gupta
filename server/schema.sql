CREATE TABLE IF NOT EXISTS users (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(160) NOT NULL,
  email VARCHAR(254) NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  role VARCHAR(16) NOT NULL CHECK (role IN ('student', 'faculty', 'admin')),
  student_id VARCHAR(24) UNIQUE,
  employee_id VARCHAR(24) UNIQUE,
  department VARCHAR(120),
  year VARCHAR(24),
  phone VARCHAR(32),
  date_of_birth DATE,
  address TEXT,
  status VARCHAR(16) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS users_role_created_idx ON users (role, created_at DESC);

CREATE TABLE IF NOT EXISTS courses (
  id BIGSERIAL PRIMARY KEY,
  title VARCHAR(180) NOT NULL,
  department VARCHAR(120) NOT NULL,
  degree VARCHAR(80),
  description TEXT,
  published BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS course_faculty (
  course_id BIGINT NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  faculty_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  PRIMARY KEY (course_id, faculty_id)
);

CREATE TABLE IF NOT EXISTS notices (
  id BIGSERIAL PRIMARY KEY,
  title VARCHAR(180) NOT NULL,
  body TEXT NOT NULL,
  audience VARCHAR(16) NOT NULL DEFAULT 'all' CHECK (audience IN ('all', 'students', 'faculty')),
  author_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
  published BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS admission_applications (
  id BIGSERIAL PRIMARY KEY,
  applicant_name VARCHAR(160) NOT NULL,
  email VARCHAR(254) NOT NULL,
  phone VARCHAR(32) NOT NULL,
  date_of_birth DATE,
  qualification VARCHAR(180),
  grade VARCHAR(64),
  preferred_course VARCHAR(180) NOT NULL,
  preferred_department VARCHAR(120),
  address TEXT,
  status VARCHAR(20) NOT NULL DEFAULT 'under_review' CHECK (status IN ('under_review', 'accepted', 'rejected')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS admissions_status_created_idx ON admission_applications (status, created_at DESC);

CREATE TABLE IF NOT EXISTS leave_applications (
  id BIGSERIAL PRIMARY KEY,
  student_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL CHECK (end_date >= start_date),
  reason VARCHAR(2000) NOT NULL,
  status VARCHAR(16) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS leave_student_created_idx ON leave_applications (student_id, created_at DESC);

CREATE TABLE IF NOT EXISTS attendance (
  id BIGSERIAL PRIMARY KEY,
  student_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  course_id BIGINT NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  class_date DATE NOT NULL,
  status VARCHAR(12) NOT NULL CHECK (status IN ('present', 'absent', 'leave')),
  marked_by BIGINT REFERENCES users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (student_id, course_id, class_date)
);

CREATE TABLE IF NOT EXISTS student_marks (
  id BIGSERIAL PRIMARY KEY,
  student_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  course_id BIGINT NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  assessment VARCHAR(180) NOT NULL,
  score NUMERIC(7, 2) NOT NULL CHECK (score >= 0),
  max_score NUMERIC(7, 2) NOT NULL CHECK (max_score > 0 AND score <= max_score),
  entered_by BIGINT REFERENCES users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS contact_messages (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(160) NOT NULL,
  email VARCHAR(254) NOT NULL,
  subject VARCHAR(120) NOT NULL,
  message TEXT NOT NULL,
  rating SMALLINT CHECK (rating BETWEEN 1 AND 5),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
