#!/bin/bash

echo "STARTING THE APPLICATION"
cd /clone-me-project/supabase/supabase
npx supabase stop
npx supabase start