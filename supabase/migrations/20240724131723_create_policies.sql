-- migrate:up

-- migrate:up

-- migrate:up

-- migrate:up

ALTER TABLE storage.buckets ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow authenticated users to upload metadata"
    ON "storage"."objects"
    TO authenticated
    WITH CHECK (
    auth.role() = 'authenticated'
        and bucket_id = 'errand_media'::text
    );

create policy "Allow authenticated users to retrieve buckets"
    on "storage"."buckets" for select
    to authenticated
    using (true);

create policy "Allow authenticated users to create buckets"
    on "storage"."buckets" for insert
    to authenticated
    with check (auth.role() = 'authenticated');

create policy "Allow authenticated users to update buckets"
    on "storage"."buckets" for update
    to authenticated
    with check (auth.role() = 'authenticated');

create policy "Allow authenticated users to delete buckets"
    on "storage"."buckets" for delete
    to authenticated
    using (true);

create policy "Allow authenticated users to retrieve buckets"
    on "storage"."objects" for select
    to authenticated
    using (true);

create policy "Allow authenticated users to create bucket objects"
    on "storage"."objects" for insert
    to authenticated
    with check (auth.role() = 'authenticated' and bucket_id = 'errand_media'::text);

create policy "Allow authenticated users to retrieve bucket objects"
    on storage.objects for select
    to authenticated
    using (auth.role() = 'authenticated'and bucket_id = 'errand_media'::text);

create policy "Allow authenticated users to update bucket objects"
    on "storage"."objects" for update
    to authenticated
    with check (auth.role() = 'authenticated' and bucket_id = 'errand_media'::text);

create policy "Allow authenticated users to delete bucket objects"
    on "storage"."objects" for delete
    to authenticated
    using (auth.role() = 'authenticated' and bucket_id = 'errand_media'::text);


-- migrate:down

-- migrate:down

-- migrate:down

-- migrate:down