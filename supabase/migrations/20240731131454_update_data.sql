DROP TABLE IF EXISTS bucket_metadata CASCADE;

CREATE TABLE
    IF NOT EXISTS bucket_metadata (
        id SERIAL PRIMARY KEY,
        errand_id BIGINT,
        attachment_bucket_id VARCHAR(256),
        file_name VARCHAR(256),
        file_type file_type,
        CONSTRAINT fk_errand_bucket_metadata FOREIGN KEY (errand_id) REFERENCES errand (id) ON DELETE CASCADE
);
