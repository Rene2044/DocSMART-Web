-- Base de datos para DocSMART
CREATE TABLE IF NOT EXISTS usuarios (
    id SERIAL PRIMARY KEY,
    nombre_completo VARCHAR(120) NOT NULL,
    correo VARCHAR(120) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    rol VARCHAR(20) NOT NULL CHECK (rol IN ('doctor', 'paciente')),
    especialidad VARCHAR(100),
    codigo_jvpm VARCHAR(40),
    grupo_sanguineo VARCHAR(10),
    telefono VARCHAR(30),
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS anexo_salud (
    id SERIAL PRIMARY KEY,
    paciente_id INT NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    categoria VARCHAR(80) NOT NULL,
    nombre_condicion VARCHAR(150) NOT NULL,
    anio_aprox VARCHAR(20),
    estado_actual VARCHAR(60),
    observaciones TEXT,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS citas (
    id SERIAL PRIMARY KEY,
    paciente_id INT NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    doctor_id INT REFERENCES usuarios(id) ON DELETE SET NULL,
    especialidad VARCHAR(100) NOT NULL,
    modalidad VARCHAR(30) DEFAULT 'Teleconsulta HD',
    fecha_cita DATE NOT NULL,
    hora_cita VARCHAR(20) NOT NULL,
    motivo TEXT,
    estado VARCHAR(30) DEFAULT 'Confirmada',
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS historial_clinico (
    id SERIAL PRIMARY KEY,
    paciente_id INT NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    doctor_id INT REFERENCES usuarios(id) ON DELETE SET NULL,
    diagnostico VARCHAR(200) NOT NULL,
    presion_arterial VARCHAR(20),
    frecuencia_cardiaca VARCHAR(20),
    temperatura VARCHAR(20),
    notas_clinicas TEXT NOT NULL,
    fecha_atencion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS recetas_medicas (
    id SERIAL PRIMARY KEY,
    consulta_id INT REFERENCES historial_clinico(id) ON DELETE CASCADE,
    paciente_id INT NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    doctor_id INT REFERENCES usuarios(id) ON DELETE SET NULL,
    folio VARCHAR(40) UNIQUE NOT NULL,
    medicamentos_json JSONB NOT NULL,
    emitida_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS examenes (
    id SERIAL PRIMARY KEY,
    paciente_id INT NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    nombre_estudio VARCHAR(150) NOT NULL,
    laboratorio VARCHAR(120),
    resultado_resumen TEXT,
    estado_revision VARCHAR(50) DEFAULT 'Pendiente de revisión médica',
    fecha_estudio DATE DEFAULT CURRENT_DATE
);

CREATE TABLE IF NOT EXISTS referencias_medicas (
    id SERIAL PRIMARY KEY,
    paciente_id INT NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    doctor_remitente_id INT REFERENCES usuarios(id) ON DELETE SET NULL,
    especialidad_destino VARCHAR(100) NOT NULL,
    motivo TEXT NOT NULL,
    estado VARCHAR(30) DEFAULT 'Activa',
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);