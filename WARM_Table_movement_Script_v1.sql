DO $$
DECLARE
    v_feed_id BIGINT;
    v_feed_name TEXT := 'ded_purge_test_feed_p10';
    v_hot_table TEXT := v_feed_name;
	
    v_max_capacity INT := 2;
    v_total_count INT;
    v_overflow INT;

    v_active_warm TEXT;
    v_active_run_count INT;
    v_remaining_space INT;
	v_total_warm_pushed int;

    v_move_count INT;
    v_next_seq INT;
    v_new_warm TEXT;

BEGIN

    -- 1. Get feed_id
    SELECT feed_id INTO v_feed_id
    FROM feed_config_tbl
    WHERE lower(feed_name) = lower(v_feed_name);
	RAISE NOTICE 'feedid-:%',v_feed_id;

    -- 2. Get max_capacity
	SELECT COALESCE((
	    SELECT max_capacity
	    FROM warm_table_metadata
	    WHERE source_id = v_feed_id
	    ORDER BY id DESC
	    LIMIT 1
	), v_max_capacity)
	INTO v_max_capacity;
	RAISE NOTICE 'max_capacity-:%',v_max_capacity;
	
    -- 3. Count DISTINCT feed_load_id (IMPORTANT FIX)
    SELECT COUNT(DISTINCT feed_load_id)
    INTO v_total_count
    FROM feed_run_result_tbl
    WHERE feed_id = v_feed_id;

	SELECT COALESCE((
	    SELECT sum(run_count)
	    FROM warm_table_metadata
	    WHERE source_id = v_feed_id), 0)
	INTO v_total_warm_pushed;

    RAISE NOTICE 'runResult count-:%',v_total_count;
	RAISE NOTICE 'v_total_warm_pushed-:%',v_total_warm_pushed;
    v_overflow := v_total_count - v_max_capacity - v_total_warm_pushed;
	RAISE NOTICE 'Overflow Val-:%',v_overflow;

    IF v_overflow <= 0 THEN
        RETURN;
		RAISE NOTICE 'Inside overflow if';
    END IF;

    WHILE v_overflow > 0 LOOP
		RAISE NOTICE 'Inside overflow Loop';

        -- 4. Get active warm table
        SELECT table_name, COALESCE(run_count,0)
        INTO v_active_warm, v_active_run_count
        FROM warm_table_metadata
        WHERE source_id = v_feed_id
          AND is_active = TRUE
        ORDER BY id DESC
        LIMIT 1;

		RAISE NOTICE 'v_active_warm62--%',v_active_warm;
		RAISE NOTICE 'v_active_run_count--%',v_active_run_count;

        -- 5. If no warm exists → create WARM_1
        IF v_active_warm IS NULL THEN
		RAISE NOTICE 'Inside v_active_warm is null';

            v_next_seq := 1;
            v_active_warm := lower(format('warm_feed_%s_%s', v_next_seq, v_feed_name));

            EXECUTE format(
                'CREATE TABLE %I (LIKE %I INCLUDING ALL)',
                v_active_warm,
                v_hot_table
            );

			
			INSERT INTO warm_table_metadata (
                table_name,source_id,type, run_count,
                max_capacity, is_active,
                created_at, updated_at
            )
            VALUES (
                v_active_warm,v_feed_id,'feed', 0,
                v_max_capacity, TRUE,
                CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
            );


            v_active_run_count := 0;
        END IF;

        -- 6. Calculate space
        v_remaining_space := v_max_capacity - v_active_run_count;
		raise notice 'v_remaining_space--%',v_remaining_space;
		
        -- 7. If warm full → create next
        IF v_remaining_space = 0 THEN

            UPDATE warm_table_metadata
            SET is_active = FALSE
            WHERE table_name = v_active_warm;

			SELECT COALESCE(MAX(
				CASE 
					WHEN table_name ~ 'warm_feed_(\d+)' THEN
						regexp_replace(table_name, '.*warm_feed_(\d+).*', '\1')::int
					ELSE 0
				END
			), 0) + 1
			INTO v_next_seq
			FROM warm_table_metadata
			WHERE source_id = v_feed_id;

            v_active_warm := lower(format('warm_feed_%s_%s', v_next_seq, v_feed_name));

			raise notice 'v_active_warm---%',v_active_warm;

            EXECUTE format(
                'CREATE TABLE %I (LIKE %I INCLUDING ALL)',
                v_active_warm,
                v_hot_table
            );

            /*INSERT INTO warm_table_metadata (
                source_id, table_name, run_count,
                max_capacity, is_active, type,
                created_at, updated_at
            )
            VALUES (
                v_feed_id, v_active_warm, 0,
                v_max_capacity, TRUE, 'feed',
                CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
            );
			*/

			INSERT INTO warm_table_metadata (
                table_name,source_id,type, run_count,
                max_capacity, is_active,
                created_at, updated_at
            )
            VALUES (
                v_active_warm,v_feed_id,'feed', 0,
                v_max_capacity, TRUE,
                CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
            );
			
            v_remaining_space := v_max_capacity;

        END IF;

		        -- 8. Decide how many FEED_LOAD_ID to move
		        v_move_count := LEAST(v_overflow, v_remaining_space);
				raise notice 'v_remaining_space--%',v_remaining_space;
				raise notice 'v_move_count--%',v_move_count;
		
		     
		       EXECUTE format(
		    'INSERT INTO %I
		     SELECT *
		     FROM %I
		     WHERE feed_load_id IN (
		         SELECT DISTINCT feed_load_id
		         FROM feed_run_result_tbl
		         WHERE feed_id = %s
		         ORDER BY feed_load_id ASC
				 offset %s
		         LIMIT %s
		     )',
		    v_active_warm,
		    v_hot_table,
		    v_feed_id,
			v_total_warm_pushed,
		    v_move_count
		);
		
	
		EXECUTE format(
		    'DELETE FROM %I h
		     USING (
		         SELECT DISTINCT feed_load_id
		         FROM feed_run_result_tbl
		         WHERE feed_id = %s
		         ORDER BY feed_load_id ASC
				 offset %s
		         LIMIT %s
		     ) d
		     WHERE h.feed_load_id = d.feed_load_id
		       AND h.feed_id = %s',
		    v_hot_table,
		    v_feed_id,
			v_total_warm_pushed,
			v_move_count,
		    v_feed_id
		);

        -- 11. Update metadata
        UPDATE warm_table_metadata
        SET run_count = run_count + v_move_count,
            updated_at = CURRENT_TIMESTAMP
        WHERE table_name = v_active_warm;

        -- 12. Reduce overflow
        v_overflow := v_overflow - v_move_count;
		raise notice 'v_overflow--%',v_overflow;
		v_total_warm_pushed:= v_total_warm_pushed+v_move_count;
		

    END LOOP;

END $$;