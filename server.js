const express = require('express');
const path = require('path');
const cors = require('cors');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const pool = require('./db');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;
const JWT_SECRET = process.env.JWT_SECRET || 'clave_secreta_docsmart';

app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

app.get('/api/health', async (req, res) => {
    try {
        await pool.query('SELECT 1');
        res.json({ ok: true, message: 'Servidor y PostgreSQL activos' });
    } catch (error) {
        res.status(500).json({ ok: false, error: error.message });
    }
});

app.post('/api/login', async (req, res) => {
    const { correo, password } = req.body;
    try {
        const result = await pool.query('SELECT * FROM usuarios WHERE correo = $1', [correo]);
        if (result.rows.length === 0) {
            return res.status(401).json({ message: 'Credenciales inválidas' });
        }

        const user = result.rows[0];
        const validPassword = await bcrypt.compare(password, user.password_hash);
        if (!validPassword) {
            return res.status(401).json({ message: 'Credenciales inválidas' });
        }

        const token = jwt.sign(
            { id: user.id, rol: user.rol, nombre: user.nombre_completo },
            JWT_SECRET,
            { expiresIn: '8h' }
        );

        const redirectTo = user.rol === 'doctor'
            ? '/doctor-dashboard.html'
            : '/paciente-dashboard.html';

        res.json({
            token,
            rol: user.rol,
            nombre: user.nombre_completo,
            redirectTo
        });
    } catch (error) {
        res.status(500).json({ message: 'Error en servidor', error: error.message });
    }
});

app.get('/api/paciente/:id/anexo', async (req, res) => {
    try {
        const { rows } = await pool.query(
            'SELECT * FROM anexo_salud WHERE paciente_id = $1 ORDER BY id DESC',
            [req.params.id]
        );
        res.json(rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.post('/api/paciente/:id/anexo', async (req, res) => {
    const { categoria, nombre_condicion, anio_aprox, estado_actual, observaciones } = req.body;
    try {
        const { rows } = await pool.query(
            `INSERT INTO anexo_salud (paciente_id, categoria, nombre_condicion, anio_aprox, estado_actual, observaciones)
             VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`,
            [req.params.id, categoria, nombre_condicion, anio_aprox, estado_actual, observaciones]
        );
        res.status(201).json(rows[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.listen(PORT, () => {
    console.log(`DocSMART corriendo en http://localhost:${PORT}`);
});