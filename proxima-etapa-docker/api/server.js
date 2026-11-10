const express = require("express");
const mysql = require("mysql2/promise");

const app = express();
app.use(express.json());

// Configuração 100% via variáveis de ambiente (sem credenciais no código)
const pool = mysql.createPool({
  host: process.env.DB_HOST,
  port: Number(process.env.DB_PORT || 3306),
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  waitForConnections: true,
  connectionLimit: 10,
});

// Log simples de requisições
app.use((req, _res, next) => {
  console.log(`${new Date().toISOString()} ${req.method} ${req.url}`);
  next();
});

app.get("/health", async (_req, res) => {
  try {
    await pool.query("SELECT 1");
    res.json({ status: "ok", database: "up" });
  } catch (e) {
    res.status(503).json({ status: "error", database: "down" });
  }
});

// RFM03 - Cursos
app.get("/api/courses", async (_req, res) => {
  try {
    const [rows] = await pool.execute(
      "SELECT id, title, description, workload_hours, location FROM courses ORDER BY id"
    );
    res.json(rows);
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: "Erro ao consultar cursos" });
  }
});

// RFM05 - Agenda do aluno (consulta parametrizada contra SQL Injection)
app.get("/api/students/:id/schedule", async (req, res) => {
  try {
    const [rows] = await pool.execute(
      `SELECT c.title, s.session_date, s.start_time, c.location
         FROM enrollments e
         JOIN courses c  ON c.id = e.course_id
         JOIN sessions s ON s.course_id = c.id
        WHERE e.student_id = ?
        ORDER BY s.session_date, s.start_time`,
      [req.params.id]
    );
    res.json(rows);
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: "Erro ao consultar agenda" });
  }
});

// RFM06 - Registro de presença (evita duplicidade pela UNIQUE do banco)
app.post("/api/attendance", async (req, res) => {
  const { student_id, session_id } = req.body || {};
  if (!Number.isInteger(student_id) || !Number.isInteger(session_id)) {
    return res.status(400).json({ error: "student_id e session_id obrigatórios (inteiros)" });
  }
  try {
    await pool.execute(
      "INSERT INTO attendance (student_id, session_id) VALUES (?, ?)",
      [student_id, session_id]
    );
    res.status(201).json({ message: "Presença registrada" });
  } catch (e) {
    if (e.code === "ER_DUP_ENTRY") return res.status(409).json({ error: "Presença já registrada" });
    console.error(e);
    res.status(500).json({ error: "Erro ao registrar presença" });
  }
});

app.listen(process.env.PORT || 3000, () => console.log("API Próxima Etapa no ar"));
