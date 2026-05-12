WITH no_pk_tables AS (
    SELECT LOWER(c.relname) AS table_name
    FROM pg_class c
    JOIN pg_namespace n 
        ON n.oid = c.relnamespace
    WHERE c.relkind = 'r'
      AND NOT EXISTS (
            SELECT 1
            FROM pg_constraint con
            WHERE con.conrelid = c.oid
              AND con.contype = 'p'
      )
      AND n.nspname = 'public'
)

SELECT f.feed_name AS table_name
FROM feed_config_tbl f
JOIN no_pk_tables t 
  ON LOWER(f.feed_name) = t.table_name

UNION ALL

SELECT r.source_tbl
FROM recon_config_tbl r
JOIN no_pk_tables t 
  ON LOWER(r.source_tbl) = t.table_name

UNION ALL

SELECT r.output_tbl
FROM recon_config_tbl r
JOIN no_pk_tables t 
  ON LOWER(r.output_tbl) = t.table_name
  
  
  
  


-------------------------------------

DO $$
DECLARE 
    r record;
BEGIN
    FOR r IN 
    WITH no_pk_tables AS (
        SELECT c.oid, c.relname
        FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE c.relkind = 'r'
          AND n.nspname = 'public'
          AND NOT EXISTS (
                SELECT 1
                FROM pg_constraint con
                WHERE con.conrelid = c.oid
                  AND con.contype = 'p'
          )
    ),

    all_tables AS (
        SELECT 'FEED' AS type, lower(feed_name) AS table_name FROM feed_config_tbl
        UNION ALL
        SELECT 'RECON_SOURCE', lower(source_tbl) FROM recon_config_tbl
        UNION ALL
        SELECT 'RECON_OUTPUT', lower(output_tbl) FROM recon_config_tbl
    ),

    filtered AS (
        SELECT t.type, t.table_name
        FROM all_tables t
        JOIN no_pk_tables n
          ON LOWER(t.table_name) = LOWER(n.relname)
    )

    SELECT * FROM filtered
    LOOP

        IF r.type = 'FEED' THEN

            -- PK check
            IF NOT EXISTS (
                SELECT 1 FROM pg_constraint 
                WHERE conname = r.table_name || '_pkey'
            ) THEN
                EXECUTE format(
                    'ALTER TABLE %I ADD CONSTRAINT %I PRIMARY KEY (feed_id, feed_load_id, feed_record_id)',
                    r.table_name,
                    r.table_name || '_pkey'
                );
            END IF;

            -- INDEX
            EXECUTE format(
                'CREATE INDEX IF NOT EXISTS %I ON %I (feed_id ASC NULLS LAST, feed_load_id ASC NULLS LAST, feed_record_id ASC NULLS LAST)',
                r.table_name || '_indx_007',
                r.table_name
            );

        -- ===================== RECON SOURCE =====================
        ELSIF r.type = 'RECON_SOURCE' THEN

            IF NOT EXISTS (
                SELECT 1 FROM pg_constraint 
                WHERE conname = r.table_name || '_pkey'
            ) THEN
                EXECUTE format(
                    'ALTER TABLE %I ADD CONSTRAINT %I PRIMARY KEY (recon_id, recon_load_id, recon_record_id, recon_consolidated_key, recon_group_key)',
                    r.table_name,
                    r.table_name || '_pkey'
                );
            END IF;

            EXECUTE format(
                'CREATE INDEX IF NOT EXISTS %I ON %I (recon_id, recon_load_id, recon_group_key, recon_consolidated_key)',
                r.table_name || '_match_reader_indx',
                r.table_name
            );

            EXECUTE format(
                'CREATE INDEX IF NOT EXISTS %I ON %I (recon_record_id)',
                r.table_name || '_rec_data_rcd_indx',
                r.table_name
            );

        -- ===================== RECON OUTPUT =====================
        ELSIF r.type = 'RECON_OUTPUT' THEN

            IF NOT EXISTS (
                SELECT 1 FROM pg_constraint 
                WHERE conname = r.table_name || '_pkey'
            ) THEN
                EXECUTE format(
                    'ALTER TABLE %I ADD CONSTRAINT %I PRIMARY KEY (recon_id, recon_load_id, recon_record_id)',
                    r.table_name,
                    r.table_name || '_pkey'
                );
            END IF;

            EXECUTE format(
                'CREATE INDEX IF NOT EXISTS %I ON %I (recon_id, recon_load_id, matching_status)',
                r.table_name || '_match_out_status_ind',
                r.table_name
            );

            EXECUTE format(
                'CREATE INDEX IF NOT EXISTS %I ON %I (recon_record_id)',
                r.table_name || '_rec_mtch_out_rcd_ind',
                r.table_name
            );

        END IF;

    END LOOP;
END $$;