const express = require("express")
const cors = require("cors")
const { Pool } = require("pg")
require("dotenv").config()

const app = express()
const port = process.env.PORT || 3000

const getDatabaseConfig = () => {
  
  if (process.env.DATABASE_URL) {
    return {
      connectionString: process.env.DATABASE_URL,
      ssl: process.env.NODE_ENV === "production" ? { rejectUnauthorized: false } : false,
    }
  }

  // Fallback a variables individuales
  return {
    user: process.env.DB_USER || "postgres",
    host: process.env.DB_HOST || "/cloudsql/queplan-468417:us-central1:retoqueplan",
    database: process.env.DB_NAME || "retoqueplan",
    password: process.env.DB_PASSWORD || "Vbv6kax0ktc!",
    port: process.env.DB_PORT || 5432,
    ssl: process.env.NODE_ENV === "production" ? { rejectUnauthorized: false } : false,
  }
}

const pool = new Pool(getDatabaseConfig())

app.use(
  cors({
    origin: [
      "https://queplan-frontend-416665410997.us-central1.run.app",
      "http://localhost:4200", // Para desarrollo local
    ],
    credentials: true,
  }),
)

app.use(express.json())

app.get("/health", (req, res) => {
  res.status(200).json({ status: "OK", timestamp: new Date().toISOString() })
})

// Crear tabla si no existe
const initDB = async () => {
  try {
    await pool.query(`
      CREATE TABLE IF NOT EXISTS note (
        id SERIAL PRIMARY KEY,
        title VARCHAR(255) NOT NULL,
        content TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `)

    // Crear trigger para actualizar updated_at automáticamente
    await pool.query(`
      CREATE OR REPLACE FUNCTION update_updated_at_column()
      RETURNS TRIGGER AS $$
      BEGIN
        NEW.updated_at = CURRENT_TIMESTAMP;
        RETURN NEW;
      END;
      $$ language 'plpgsql';
    `)

    await pool.query(`
      DROP TRIGGER IF EXISTS update_note_updated_at ON note;
      CREATE TRIGGER update_note_updated_at
        BEFORE UPDATE ON note
        FOR EACH ROW
        EXECUTE FUNCTION update_updated_at_column();
    `)

    console.log("Base de datos inicializada correctamente")
  } catch (err) {
    console.error("Error inicializando la base de datos:", err)
  }
}

// Rutas CRUD

// GET - Obtener todas las notas
app.get("/api/notes", async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM note ORDER BY updated_at DESC")
    res.json(result.rows)
  } catch (err) {
    console.error(err)
    res.status(500).json({ error: "Error interno del servidor" })
  }
})

// GET - Obtener una nota por ID
app.get("/api/notes/:id", async (req, res) => {
  try {
    const { id } = req.params
    const result = await pool.query("SELECT * FROM note WHERE id = $1", [id])

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "Nota no encontrada" })
    }

    res.json(result.rows[0])
  } catch (err) {
    console.error(err)
    res.status(500).json({ error: "Error interno del servidor" })
  }
})

// POST - Crear una nueva nota
app.post("/api/notes", async (req, res) => {
  try {
    const { title, content } = req.body

    if (!title) {
      return res.status(400).json({ error: "El título es requerido" })
    }

    const result = await pool.query("INSERT INTO note (title, content) VALUES ($1, $2) RETURNING *", [
      title,
      content || "",
    ])

    res.status(201).json(result.rows[0])
  } catch (err) {
    console.error(err)
    res.status(500).json({ error: "Error interno del servidor" })
  }
})

// PUT - Actualizar una nota
app.put("/api/notes/:id", async (req, res) => {
  try {
    const { id } = req.params
    const { title, content } = req.body

    if (!title) {
      return res.status(400).json({ error: "El título es requerido" })
    }

    const result = await pool.query("UPDATE note SET title = $1, content = $2 WHERE id = $3 RETURNING *", [
      title,
      content || "",
      id,
    ])

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "Nota no encontrada" })
    }

    res.json(result.rows[0])
  } catch (err) {
    console.error(err)
    res.status(500).json({ error: "Error interno del servidor" })
  }
})

// DELETE - Eliminar una nota
app.delete("/api/notes/:id", async (req, res) => {
  try {
    const { id } = req.params
    const result = await pool.query("DELETE FROM note WHERE id = $1 RETURNING *", [id])

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "Nota no encontrada" })
    }

    res.json({ message: "Nota eliminada correctamente" })
  } catch (err) {
    console.error(err)
    res.status(500).json({ error: "Error interno del servidor" })
  }
})

// Inicializar servidor
const startServer = async () => {
  await initDB()
  app.listen(port, () => {
    console.log(`Servidor corriendo en http://${process.env.DB_HOST}:${port}`)
  })
}

startServer()
