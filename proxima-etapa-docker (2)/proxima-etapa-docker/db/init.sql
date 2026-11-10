-- Dados FICTÍCIOS (LGPD) - sintaxe MySQL/MariaDB (compatível com XAMPP)
SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS students (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(120) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS courses (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(120) NOT NULL,
  description TEXT,
  workload_hours INT NOT NULL,
  location VARCHAR(120)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS sessions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  course_id INT NOT NULL,
  session_date DATE NOT NULL,
  start_time TIME NOT NULL,
  FOREIGN KEY (course_id) REFERENCES courses(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS enrollments (
  student_id INT NOT NULL,
  course_id INT NOT NULL,
  PRIMARY KEY (student_id, course_id),
  FOREIGN KEY (student_id) REFERENCES students(id),
  FOREIGN KEY (course_id) REFERENCES courses(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS attendance (
  id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  session_id INT NOT NULL,
  checked_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_student_session (student_id, session_id),   -- evita presença duplicada
  FOREIGN KEY (student_id) REFERENCES students(id),
  FOREIGN KEY (session_id) REFERENCES sessions(id)
) ENGINE=InnoDB;

INSERT INTO students (name, email) VALUES
  ('Aluno Teste 1', 'aluno1@exemplo.com'),
  ('Aluno Teste 2', 'aluno2@exemplo.com');

INSERT INTO courses (title, description, workload_hours, location) VALUES
  ('Introdução à Programação', 'Lógica e primeiros passos', 20, 'Sala 101'),
  ('Orientação Profissional', 'Carreiras e mercado de trabalho', 12, 'Auditório'),
  ('Excel Básico', 'Planilhas para o dia a dia', 16, 'Lab 3');

INSERT INTO sessions (course_id, session_date, start_time) VALUES
  (1, '2026-11-20', '14:00'), (1, '2026-11-27', '14:00'),
  (2, '2026-11-22', '09:00'), (3, '2026-11-25', '10:00');

INSERT INTO enrollments (student_id, course_id) VALUES (1,1),(1,2),(2,3);
