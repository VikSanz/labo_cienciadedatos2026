-- ============================================================
-- Carga reproducible de Synthea en PostgreSQL
-- ============================================================

-- Permite ejecutar este script múltiples veces sin duplicar datos.
DROP TABLE IF EXISTS observations;
DROP TABLE IF EXISTS medications;
DROP TABLE IF EXISTS conditions;
DROP TABLE IF EXISTS encounters;
DROP TABLE IF EXISTS patients;


-- ============================================================
-- PATIENTS
-- ============================================================

CREATE TABLE patients (
    id                  UUID PRIMARY KEY,
    birthdate           DATE NOT NULL,
    deathdate           DATE,
    ssn                 TEXT,
    drivers             TEXT,
    passport            TEXT,
    prefix              TEXT,
    first               TEXT,
    middle              TEXT,
    last                TEXT,
    suffix              TEXT,
    maiden              TEXT,
    marital             TEXT,
    race                TEXT,
    ethnicity           TEXT,
    gender              TEXT,
    birthplace          TEXT,
    address             TEXT,
    city                TEXT,
    state               TEXT,
    county              TEXT,
    fips                TEXT,
    zip                 TEXT,
    lat                 DOUBLE PRECISION,
    lon                 DOUBLE PRECISION,
    healthcare_expenses NUMERIC,
    healthcare_coverage NUMERIC,
    income              NUMERIC
);


-- ============================================================
-- ENCOUNTERS
-- ============================================================

CREATE TABLE encounters (
    id                  UUID PRIMARY KEY,
    start               TIMESTAMPTZ NOT NULL,
    stop                TIMESTAMPTZ,
    patient             UUID NOT NULL,
    organization        UUID,
    provider            UUID,
    payer               UUID,
    encounterclass      TEXT,
    code                TEXT,
    description         TEXT,
    base_encounter_cost NUMERIC,
    total_claim_cost    NUMERIC,
    payer_coverage      NUMERIC,
    reasoncode          TEXT,
    reasondescription   TEXT,

    CONSTRAINT fk_encounters_patient
        FOREIGN KEY (patient) REFERENCES patients(id)
);


-- ============================================================
-- CONDITIONS
-- ============================================================

CREATE TABLE conditions (
    start       DATE NOT NULL,
    stop        DATE,
    patient     UUID NOT NULL,
    encounter   UUID,
    system      TEXT,
    code        TEXT,
    description TEXT,

    CONSTRAINT fk_conditions_patient
        FOREIGN KEY (patient) REFERENCES patients(id),

    CONSTRAINT fk_conditions_encounter
        FOREIGN KEY (encounter) REFERENCES encounters(id)
);


-- ============================================================
-- MEDICATIONS
-- ============================================================

CREATE TABLE medications (
    start             TIMESTAMPTZ NOT NULL,
    stop              TIMESTAMPTZ,
    patient           UUID NOT NULL,
    payer             UUID,
    encounter         UUID,
    code              TEXT,
    description       TEXT,
    base_cost         NUMERIC,
    payer_coverage    NUMERIC,
    dispenses         INTEGER,
    totalcost         NUMERIC,
    reasoncode        TEXT,
    reasondescription TEXT,

    CONSTRAINT fk_medications_patient
        FOREIGN KEY (patient) REFERENCES patients(id),

    CONSTRAINT fk_medications_encounter
        FOREIGN KEY (encounter) REFERENCES encounters(id)
);


-- ============================================================
-- OBSERVATIONS
-- ============================================================

CREATE TABLE observations (
    date        TIMESTAMPTZ NOT NULL,
    patient     UUID NOT NULL,
    encounter   UUID,
    category    TEXT,
    code        TEXT,
    description TEXT,
    value       TEXT,
    units       TEXT,
    type        TEXT,

    CONSTRAINT fk_observations_patient
        FOREIGN KEY (patient) REFERENCES patients(id),

    CONSTRAINT fk_observations_encounter
        FOREIGN KEY (encounter) REFERENCES encounters(id)
);


-- ============================================================
-- CARGA
-- ============================================================

COPY patients
FROM '/data/csv/patients.csv'
WITH (FORMAT CSV, HEADER TRUE);

COPY encounters
FROM '/data/csv/encounters.csv'
WITH (FORMAT CSV, HEADER TRUE);

COPY conditions
FROM '/data/csv/conditions.csv'
WITH (FORMAT CSV, HEADER TRUE);

COPY medications
FROM '/data/csv/medications.csv'
WITH (FORMAT CSV, HEADER TRUE);

COPY observations
FROM '/data/csv/observations.csv'
WITH (FORMAT CSV, HEADER TRUE);


-- ============================================================
-- ÍNDICES
-- ============================================================

CREATE INDEX idx_encounters_patient
ON encounters(patient);

CREATE INDEX idx_conditions_patient
ON conditions(patient);

CREATE INDEX idx_conditions_encounter
ON conditions(encounter);

CREATE INDEX idx_medications_patient
ON medications(patient);

CREATE INDEX idx_medications_encounter
ON medications(encounter);

CREATE INDEX idx_observations_patient
ON observations(patient);

CREATE INDEX idx_observations_encounter
ON observations(encounter);

CREATE INDEX idx_observations_code
ON observations(code);


-- ============================================================
-- CONTEO FINAL
-- ============================================================

SELECT 'patients' AS tabla, COUNT(*) AS filas
FROM patients

UNION ALL

SELECT 'encounters', COUNT(*)
FROM encounters

UNION ALL

SELECT 'conditions', COUNT(*)
FROM conditions

UNION ALL

SELECT 'medications', COUNT(*)
FROM medications

UNION ALL

SELECT 'observations', COUNT(*)
FROM observations

ORDER BY tabla;

