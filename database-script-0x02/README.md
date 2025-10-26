# database-script-0x02

Contains `seed.sql` to populate the database with realistic sample data.

## How to run

1. Ensure `schema.sql` has been executed and your database is ready.
2. Run:
   ```bash
   psql -d alx_airbnb_db -f seed.sql
