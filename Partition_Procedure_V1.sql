CREATE OR REPLACE procedure add_partitioned_feed(in _feed_id bigint,in _partition_val text) LANGUAGE plpgsql
AS $BODY$
DECLARE 
feed_cols text default '';
feedConfig record;
colAddQry text;
tmpTblQry text;
attachPartitionQry text;
datainsertQry text;
feedCol record ;
updtfeedconfigGenToDedQry text;
updtFeedColTblQry text;
deletedatafromdatatblQry text;
renameDedDataTbl text;

BEGIN
	select * into feedConfig from feed_config_tbl where feed_id = _feed_id;
	tmpTblNm := ''||feedConfig.source_tbl||'_'||_feed_id;
	
	colAddQry := 'insert into FEED_COLUMN_TBL(FEED_COL_ID,FEED_ID ,COLUMN_NAME,ACTUAL_COL_NAME,START_POS,END_POS,COL_POS,DATA_TYPE,DATE_TIME_FORMAT,DEFAULT_VAL,PARSE,KEY_4_DUPL,KEY_4_UPDATE,RESP_PATH) values ( nextval(''FEED_COL_SEQ''),_feed_id,''partition_col'',''partition_col'',1,1,100,''STRING'',null,null,''No'',''No'',''No'',null))';
    execute colAddQry;
	
	FOR feedCol IN  select column_name as col_name from feed_column_tbl where feed_id=_feed_id
	LOOP
		feed_cols := feed_cols || feedCol.col_name || ',';
    END LOOP;
	

 IF upper(feedConfig.data_storage) = 'GENERIC' THEN
    
    
    tmpTblQry := 'create table '|| feedConfig.feed_name ||'( like ( select '|| feed_cols || ',partition_col from feed_data_tbl where feed_id ='||
_feed_id ||	'limit 0) partition by list(partition_col)';
  execute tmpTblQry;
  
  attachPartitionQry='create table '|| feedConfig.feed_name||'_part_1'||' partition of ' feedConfig.feed_name||' for values in('||_partition_val||')';
  execute attachPartitionQry;
  
 datainsertQry := 'insert into ' || feedConfig.source_tbl || 
                ' select ' || substr(REPLACE(feed_cols,',partition_col',''), 1, length(REPLACE(feed_cols,',partition_col','')) - 1) || 
                ',' '''' || _partition_val || ''''' as partition_col ' || 
                ' from feed_data_tbl where feed_id = ' || _feed_id;
				
 execute datainsertQry;	
 
 updtfeedconfigGenToDedQry :='update feed_config_tbl set source_tbl = '''''||feedConfig.feed_name||''''', data_storage='DEDICATED' where feed_id='||_feed_id;
 execute updtfeedconfigGenToDedQry;
 updtFeedColTblQry :='update feed_column_tbl set actual_col_name = column_name where feed_id='||_feed_id;
 execute updtfeedconfigGenToDedQry;
 
 deletedatafromdatatblQry := 'delete from feed_data_tbl where feed_id='||_feed_id;
 execute deletedatafromdatatblQry;
	
 END IF;
 ELSIF upper(Oprn_Type) = 'DEDICATED' THEN
 
     renameDedDataTbl :='alter table '|| feedConfig.feed_name || 'rename to '|| feedConfig.feed_name || '_old';
   execute renameDedDataTbl ;
     tmpTblQry := 'create table '|| feedConfig.feed_name ||'( like ( select '|| feed_cols || ',partition_col from'|| feedConfig.feed_name ||'_old limit 0) partition by list(partition_col)';
  execute tmpTblQry;
 
 END IF;
 
