DROP TYPE IF EXISTS errand_status CASCADE;

CREATE TYPE errand_status AS enum (
    'requested',
    'requested_queried',
    'quoted',
    'quote_accepted',
    'in_progress',
    'pending_completed',
    'disputed',
    'stale'
    );

DROP TYPE IF EXISTS query CASCADE;

CREATE TYPE query AS enum (
    'request_unclear',
    'time_unclear',
    'location_unclear'
    );

DROP TYPE IF EXISTS file_type CASCADE;

CREATE TYPE file_type AS enum ('voice_note', 'image');

DROP TABLE IF EXISTS user_roles CASCADE;

CREATE TABLE
    IF NOT EXISTS user_roles (
        id          BIGINT PRIMARY KEY,
        role_type   VARCHAR(16),
        description VARCHAR(256)
);
DROP TABLE IF EXISTS account_information CASCADE;

CREATE TABLE
    IF NOT EXISTS account_information (
        account_id VARCHAR(64) PRIMARY KEY,
        first_name VARCHAR(256) DEFAULT NULL,
        last_name VARCHAR(256) DEFAULT NULL,
        date_of_birth DATE DEFAULT NULL,
        cellphone_number VARCHAR(15) DEFAULT NULL,
        terms_accepted BOOLEAN DEFAULT FALSE,
        terms_accepted_date TIMESTAMP DEFAULT NULL,
        date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        date_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        avatar_url VARCHAR(1024) DEFAULT NULL,
        user_role_id BIGINT DEFAULT 1,
        CONSTRAINT fk_user_role FOREIGN KEY (user_role_id) REFERENCES user_roles (id) ON DELETE NO ACTION
);

DROP TABLE IF EXISTS errand CASCADE;

CREATE TABLE
    IF NOT EXISTS errand (
        id SERIAL PRIMARY KEY,
        client_account_id VARCHAR(64),
        date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        status_updated_time TIMESTAMP,
        status errand_status,
        queries query ARRAY,
        CONSTRAINT fk_client_id FOREIGN KEY (client_account_id) REFERENCES account_information (account_id) ON DELETE NO ACTION
);

DROP TABLE IF EXISTS quote CASCADE;

CREATE TABLE
    IF NOT EXISTS quote (
        id SERIAL PRIMARY KEY,
        errand_id BIGINT NOT NULL,
        cost DECIMAL(10, 2) DEFAULT NULL,
        distance_estimate DECIMAL(10, 2) DEFAULT NULL,
        time_estimate INT DEFAULT NULL,
        date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        runner_account_id VARCHAR(64),
        CONSTRAINT fk_runner_id FOREIGN KEY (runner_account_id) REFERENCES account_information (account_id) ON DELETE NO ACTION,
        CONSTRAINT fk_errand FOREIGN KEY (errand_id) REFERENCES errand (id) ON DELETE CASCADE
);

DROP TABLE IF EXISTS metadata CASCADE;

CREATE TABLE
    IF NOT EXISTS metadata (
        id SERIAL PRIMARY KEY,
        errand_id BIGINT,
        attachment_bucket_id VARCHAR(256),
        file_name VARCHAR(256),
        file_type file_type,
        CONSTRAINT fk_errand_metadata FOREIGN KEY (errand_id) REFERENCES errand (id) ON DELETE CASCADE
);
