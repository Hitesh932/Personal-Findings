CREATE OR REPLACE PROCEDURE generate_pivoted_table(
    table_name1 TEXT,
    num_months INT,
    column_name TEXT,
	comment_col_name Text
)
LANGUAGE plpgsql
AS
$$
DECLARE
    months TEXT[];
    sql_query TEXT;
	sql_query2 Text;
    i INT;
    month_column TEXT;
    view_name TEXT;
	column_names Text;

	
BEGIN
    -- Construct the view name
    view_name := 'Temp_view_' || lower(table_name1);
	column_names:=replace(column_name,',','||');
    raise notice 'column names are %',column_name;
    -- Check if the view exists and drop it if it does
    IF EXISTS (SELECT 1 FROM information_schema.views WHERE table_name = lower(view_name)) THEN
	    EXECUTE format('INSERT INTO variance_comment_tbl (var_id,feed_id, feed_load_id, cat_key, comment)
                       SELECT nextVal(''var_comment_seq''),feed_id, feed_load_id,%s AS cat_key,%I
                       FROM %I
                       where %I IS NOT NULL',
					   column_names,comment_col_name,lower(table_name1),comment_col_name);
        EXECUTE format('UPDATE %I SET %I=null WHERE %I IS not NULL',lower(table_name1),comment_col_name,comment_col_name);
		EXECUTE format('DROP VIEW IF EXISTS %I', lower(view_name));
		Raise notice 'deleted view';
    END IF;

    -- Get the distinct month-year values
    EXECUTE format('
        SELECT array_agg(Date2) 
        FROM (
            SELECT DISTINCT to_char(date, ''Mon-YYYY'') AS Date2, Date
            FROM %I 
            ORDER BY Date DESC  
            LIMIT %s
        ) tmp', table_name1, num_months) INTO months;

    -- Initialize the SQL query
    sql_query := 'CREATE OR REPLACE VIEW ' || view_name || ' AS with cte1 as (SELECT max(feed_id) as feed_id,max(feed_load_id) as feed_load_id,max(feed_record_id) as feed_record_id,'||column_names ||' as cat_key ,' || column_name||','||comment_col_name;

    -- Add the CASE statements for each month
    FOR i IN 1..array_length(months, 1) LOOP
        month_column := lower(replace(months[i], '-', '_'));
        sql_query := sql_query || ', sum(CASE WHEN mon_yr = ''' || months[i] || ''' THEN totalamount ELSE 0 END) AS ' || month_column;
    END LOOP;

    -- Complete the query with GROUP BY and ORDER BY
    sql_query := sql_query || ' FROM ' || table_name1 || ' GROUP BY ' || column_name||','|| comment_col_name || ' ORDER BY ' || column_name ||','|| comment_col_name ||')';
	sql_query2:= '(SELECT t.feed_id,t.cat_key, t.comment
                 FROM variance_comment_tbl t
                 JOIN (
                 SELECT cat_key, MAX(var_id) AS var_id,feed_id
				 FROM variance_comment_tbl
				 GROUP BY cat_key,feed_id
				 ) latest ON t.cat_key = latest.cat_key AND t.var_id = latest.var_id)';
				 
	sql_query:=sql_query || 'select t1.*,t2.comment as Latest_comment from  cte1 t1 left join '||sql_query2||' t2 on t1.feed_id=t2.feed_id and  t1.cat_key=t2.cat_key';

    -- Execute the dynamic SQL query to create the view
    EXECUTE sql_query;

END;
$$;

