CREATE OR REPLACE procedure update_record_finisher(in _feed_id bigint,in _feed_load_id bigint,inout ttl_cnt bigint DEFAULT 0) LANGUAGE plpgsql
AS $BODY$
DECLARE 
	feedConfig record ;
	tmpTblNm text;
	duplGrpngCols text default '';
	feedCol record ;
	tmpTblQry text;
	temprow record;
	duplMarkQry text; 
	duplMarkQry1 text;
	markCol text;
	duplDelQry text;
	duplDelQry1 text default '';
	ki record;
	affected_rows  numeric;
BEGIN
	select * into feedConfig from feed_config_tbl where feed_id = _feed_id;
	tmpTblNm := ''||feedConfig.source_tbl||'_'||_feed_id||'_'||_feed_load_id;
	FOR feedCol IN  select actual_col_name from feed_column_tbl where feed_id= _feed_id and key_4_update='Yes' LOOP
		duplGrpngCols := duplGrpngCols || feedCol.actual_col_name || ',';
    END LOOP;
	tmpTblQry := 'CREATE TEMP TABLE "'||tmpTblNm||'"  on commit drop AS with CTE1 as (SELECT feed_id,feed_load_Id,feed_record_id, RANK() OVER (PARTITION BY ' || substr(duplGrpngCols,1, length(duplGrpngCols)-1)  || ' ORDER BY feed_record_id desc) AS rank FROM '||feedConfig.source_tbl||' where feed_id = '||_feed_id||') select * from cte1 where rank = 1 ';
	execute 'DROP TABLE IF EXISTS '|| tmpTblNm;
	execute tmpTblQry;
	if feedConfig.updt_rec_actn='UPDATE_N_MARK' then
		select actual_col_name into markCol from feed_column_tbl where feed_id= _feed_id and updt_rec_mark='Yes' limit 1;
		duplMarkQry := 'update '||feedConfig.source_tbl||' as t1 set '||markCol||'='||quote_literal(feedConfig.updt_rec_mark_val) ||' from ' ||tmpTblNm||' as t2 where t1.feed_id=t2.feed_id and t1.feed_load_id=t2.feed_load_id and t1.feed_record_id!=t2.feed_record_id and t1.feed_load_id !='||_feed_load_id;
		execute duplMarkQry;
		duplMarkQry1 := 'update '||feedConfig.source_tbl||' as t1 set '||markCol||'='||quote_literal(feedConfig.updt_rec_mark_val) ||' from ' ||tmpTblNm||' as t2 where t1.feed_id=t2.feed_id and t1.feed_load_id=t2.feed_load_id and t1.feed_record_id!=t2.feed_record_id and t1.feed_load_id='||_feed_load_id;
		execute duplMarkQry1;
		GET DIAGNOSTICS affected_rows = ROW_COUNT;
		ttl_cnt := ttl_cnt + affected_rows;
	else
	     duplDelQry := 'delete from '||feedConfig.source_tbl||' as t1 using '||tmpTblNm||' as t2 where t1.feed_id=t2.feed_id and t1.feed_load_id=t2.feed_load_id and  t1.feed_record_id=t2.feed_record_id and t1.feed_load_id !='||_feed_load_id;
	     execute duplDelQry;
		 duplDelQry1 := 'delete from '||feedConfig.source_tbl||' as t1 using '||tmpTblNm||' as t2 where t1.feed_id=t2.feed_id and t1.feed_load_id=t2.feed_load_id and t1.feed_record_id=t2.feed_record_id and t1.feed_load_id ='||_feed_load_id;
	     execute duplDelQry1;
		GET DIAGNOSTICS affected_rows = ROW_COUNT;
		ttl_cnt := ttl_cnt + affected_rows;
	END if;

END 
$BODY$;