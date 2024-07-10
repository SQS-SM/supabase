DROP TABLE IF EXISTS errand CASCADE;

CREATE TABLE
    IF NOT EXISTS errand (
        id SERIAL PRIMARY KEY,
        date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        status VARCHAR(55) DEFAULT NULL,
        voice_note_id VARCHAR(1024) DEFAULT NULL
    );

DROP TABLE IF EXISTS quote;

CREATE TABLE
    IF NOT EXISTS quote (
        id SERIAL PRIMARY KEY,
        errand_id BIGINT NOT NULL,
        cost DECIMAL(10, 2) DEFAULT NULL,
        distance_estimate DECIMAL(10, 2) DEFAULT NULL,
        time_estimate INT DEFAULT NULL,
        date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        CONSTRAINT fk_errand FOREIGN KEY (errand_id) REFERENCES errand (id) ON DELETE CASCADE
    );

DROP TABLE IF EXISTS account_information;

CREATE TABLE
    IF NOT EXISTS account_information (
        account_id VARCHAR(64) PRIMARY KEY,
        first_name VARCHAR(256) DEFAULT NULL,
        last_name VARCHAR(256) DEFAULT NULL,
        date_of_birth DATE DEFAULT NULL,
        terms_accepted BOOLEAN DEFAULT FALSE,
        terms_accepted_date TIMESTAMP DEFAULT NULL,
        date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        date_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        avatar_url VARCHAR(1024) DEFAULT NULL,
        user_role VARCHAR(55) DEFAULT NULL --'client' or 'runner'
    );

-- TODO: Create user role table and link via id