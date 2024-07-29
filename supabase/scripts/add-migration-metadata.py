import os

source_folder = r"/clone-me-project/tmp/"
destination_folder = r"/clone-me-project/supabase/docker/"

def add_migration_meta_data(migration_source_folder, migration_destination_folder):
  for file_name in os.listdir(migration_source_folder):
    # construct full file path
    source = migration_source_folder + file_name
    destination = migration_destination_folder + file_name
    os.makedirs(os.path.dirname(destination), exist_ok=True)
    # copy only files
    if os.path.isfile(source):
        with open(source, 'r') as original:
            data = original.read()
        with open(source, 'w') as modified:
            modified.write("-- migrate:up\n\n" + data + "\n\n-- migrate:down")

add_migration_meta_data(source_folder + "migrations/", destination_folder + "db/migrations/")
                        

# # fetch all files
# for file_name in os.listdir(migration_source_folder):
#     # construct full file path
#     source = migration_source_folder + file_name
#     destination = migration_destination_folder + file_name
#     os.makedirs(os.path.dirname(destination), exist_ok=True)
#     # copy only files
#     if os.path.isfile(source):
#         with open(source, 'r') as original:
#             data = original.read()
#         with open(source, 'w') as modified:
#             modified.write("-- migrate:up\n\n" + data + "\n\n-- migrate:down")
#         shutil.copy(source, destination)