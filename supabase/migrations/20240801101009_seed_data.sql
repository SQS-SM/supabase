INSERT INTO user_roles
(id, role_type, description)
VALUES
    (1, 'client', 'The paying customer who creates the errands'),
    (2, 'runner', 'Person doing the errands'),
    (3, 'admin', 'System Administrator');

--bucket for errands
INSERT INTO
    storage.buckets (id, name, public, allowed_mime_types)
VALUES
    (
        'errand_media',
        'errand_media',
        true,
        '{"audio/mp4", "audio/mpeg", "audio/m4a", "audio/aac"}'
    );
