const express = require("express")
const cors = require("cors")
const { Pool } = require("pg")
require("dotenv").config()

const app = express()
const port = process.env.PORT || 3000

const getDatabaseConfig = () => {
  console.log("=== DEBUG: Variables de entorno ===")
  console.log("DATABASE_URL existe:", !!process.env.DATABASE_URL)
  console.log("DB_HOST:", process.env.DB_HOST || "NO DEFINIDO")
  console.log("DB_USER:", process.env.DB_USER || "NO DEFINIDO")
  console.log("DB_NAME:", process.env.DB_NAME || "NO DEFINIDO")
  console.log("NODE_ENV:", process.env.NODE_ENV || "NO DEFINIDO")
  console.log("===================================")

  // Si existe DATABASE_URL, úsala (formato: postgresql://user:password@host:port/database)
  if (process.env.DATABASE_URL) {
    console.log("Usando DATABASE_URL para conexión")
    return {
      connectionString: process.env.DATABASE_URL,
      ssl: process.env.NODE_ENV === "production" ? { rejectUnauthorized: false } : false,
    }
  }

  // Fallback a variables individuales
  console.log("Usando variables individuales para conexión")
  const config = {
    user: process.env.DB_USER || "postgres",
    host: process.env.DB_HOST || "34.63.169.53",
    database: process.env.DB_NAME || "retoqueplan",
    password: process.env.DB_PASSWORD || "Vbv6kax0ktc!",
    port: process.env.DB_PORT || 5432,
    ssl: process.env.NODE_ENV === "production" ? { rejectUnauthorized: false } : false,
  }

  console.log("Configuración final (sin password):", {
    user: config.user,
    host: config.host,
    database: config.database,
    port: config.port,
    ssl: !!config.ssl,
  })

  return config
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

app.get("/api/test-db", async (req, res) => {
  try {
    // Probar conexión básica
    const connectionTest = await pool.query("SELECT NOW() as current_time, version() as postgres_version")

    // Verificar si la tabla existe
    const tableCheck = await pool.query(`
      SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'note'
      ) as table_exists
    `)

    // Contar registros en la tabla
    let recordCount = 0
    if (tableCheck.rows[0].table_exists) {
      const countResult = await pool.query("SELECT COUNT(*) as count FROM note")
      recordCount = Number.parseInt(countResult.rows[0].count)
    }

    // Información de configuración (sin mostrar credenciales sensibles)
    const config = getDatabaseConfig()
    const configInfo = {
      host: config.host || "usando DATABASE_URL",
      database: config.database || "desde DATABASE_URL",
      user: config.user || "desde DATABASE_URL",
      port: config.port || "desde DATABASE_URL",
      ssl_enabled: !!config.ssl,
      using_connection_string: !!process.env.DATABASE_URL,
    }

    res.json({
      status: "success",
      message: "Conexión a base de datos exitosa",
      timestamp: new Date().toISOString(),
      database_info: {
        current_time: connectionTest.rows[0].current_time,
        postgres_version: connectionTest.rows[0].postgres_version,
        table_exists: tableCheck.rows[0].table_exists,
        record_count: recordCount,
      },
      connection_config: configInfo,
    })
  } catch (err) {
    console.error("Error en prueba de base de datos:", err)
    res.status(500).json({
      status: "error",
      message: "Error conectando a la base de datos",
      error: err.message,
      timestamp: new Date().toISOString(),
    })
  }
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
    console.log(`Servidor corriendo en http://localhost:${port}`)
  })
}

startServer()
