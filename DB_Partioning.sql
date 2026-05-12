Without Partitioning :  
1st Run 16,151- 5cr Data 6:11 6:31- 20 Min 
1st Run-16,152-  5cr+5cr Data 6:32 6:58- 26 Min
1st Run-16,153-  5cr+5cr+5cr Data 6:58 7:32- 34 Min


Partitioning :  
1st Run 16,151- 5cr Data 12:46 12:56- 10 Min  20 Sec 
1st Run-16,152-  5cr+5cr Data 12:58 1:08- 10Min 10 Sec
1st Run-16,153-  5cr+5cr+5cr Data 1:51 2:01- 10 Min
2:02 2:12






Recon Without Partitioning 
02:29:26-03:15:23 -46Min Apprx, No rules,1 match level, No netting,1Cr total 1cr mismatch 0 match

Partitioning :   03:15:40 03:37:41 - 22 Min
                 06:41:30 07:05:50-  24 Min










http://13.235.114.20


create table public.test_recon_with_partition_p8_recon_data_tbl 
(like test_recon_with_partition_p6_recon_data_tbl) partition by list (recon_load_id);



create table public.test_recon_with_partition_p8_recon_data_tbl 
(like test_recon_with_partition_p6_recon_data_tbl) partition by list (recon_load_id);



create table public.test_recon_with_partition_p8_recon_match_output_tbl
(like test_recon_with_partition_p6_recon_match_output_tbl) partition by list (recon_load_id);
create table data_tbl_1056 partition of test_recon_with_partition_p8_recon_data_tbl for values in(1);




create table data_tbl_1057 partition of test_recon_with_partition_p8_recon_data_tbl for values in(2);
create table data_tbl_1058 partition of test_recon_with_partition_p8_recon_data_tbl for values in(3);
create table data_tbl_1059 partition of test_recon_with_partition_p8_recon_data_tbl for values in(4);
create table data_tbl_1060 partition of test_recon_with_partition_p8_recon_data_tbl for values in(5);

create table data_tbl_1061 partition of test_recon_with_partition_p8_recon_data_tbl for values in(1061);

create table output_tbl_1056 partition of test_recon_with_partition_p8_recon_match_output_tbl for values in(1056);
create table output_tbl_1057 partition of test_recon_with_partition_p8_recon_match_output_tbl for values in(1057);
create table output_tbl_1058 partition of test_recon_with_partition_p8_recon_match_output_tbl for values in(1058);
create table output_tbl_1059 partition of test_recon_with_partition_p8_recon_match_output_tbl for values in(1059);
create table output_tbl_1060 partition of test_recon_with_partition_p8_recon_match_output_tbl for values in(1060);
create table output_tbl_1061 partition of test_recon_with_partition_p8_recon_match_output_tbl for values in(1061);



create table public.Opt_Test_Lhs2_p2 
(like Opt_Test_Lhs2_p1) partition by list (Feed_load_id);
create table data_tbl_1069 partition of Opt_Test_Lhs2_p2 for values in(1069);
create table data_tbl_1070 partition of Opt_Test_Lhs2_p2 for values in(1070);





create table public.perf_test_feed_lhs_p2
(like perf_test_feed_lhs_p1) partition by list (feed_id);
create table lhs_tbl_267 partition of perf_test_feed_lhs_p1 for values in(267);

create table public.perf_test_feed_rhs_p1 (like perf_test_feed_rhs_p2) partition by list (feed_id);
create table rhs_tbl_268 partition of perf_test_feed_rhs_p1 for values in(268);


RECON_THREAD_POOL_SIZE   200
COPY_DATA_PARTITION_SIZE 20
COPY_DATA_FETCH_SIZE	 2000
COPY_DATA_CHUNK_SIZE	 2000
MATCHING_FETCH_SIZE 
RECON_MATCHING_GROUPS 

RECON_THREAD_POOL_SIZE,COPY_DATA_PARTITION_SIZE,COPY_DATA_FETCH_SIZE,COPY_DATA_CHUNK_SIZE,MATCHING_FETCH_SIZE,MATCHING_CHUNK_SIZE,RECON_MATCHING_GROUPS




az webapp deploysource config-zip --resource-group smartrecon_poc --name SmartReconPOC --src ROOT.war



create table public.Test_LHS_Feed_R2 (like Test_LHS_Feed_R1) partition by list (feed_id);

create table data_tbl_1 partition of Test_LHS_Feed_R2 for values in(1);


INSERT into BATCH_JOB_EXECUTION_PARAMS(JOB_EXECUTION_ID, KEY_NAME, TYPE_CD, STRING_VAL, DATE_VAL, LONG_VAL, DOUBLE_VAL, IDENTIFYING) values (?, ?, ?, ?, ?, ?, ?, ?)



ALTER TABLE BATCH_STEP_EXECUTION ADD CREATE_TIME TIMESTAMP NOT NULL DEFAULT '1970-01-01 00:00:00';
 
ALTER TABLE BATCH_STEP_EXECUTION ALTER COLUMN START_TIME DROP NOT NULL;
 
ALTER TABLE BATCH_JOB_EXECUTION_PARAMS DROP COLUMN DATE_VAL;
 
ALTER TABLE BATCH_JOB_EXECUTION_PARAMS DROP COLUMN LONG_VAL;
 
ALTER TABLE BATCH_JOB_EXECUTION_PARAMS DROP COLUMN DOUBLE_VAL;
 
ALTER TABLE BATCH_JOB_EXECUTION_PARAMS ALTER COLUMN TYPE_CD TYPE VARCHAR(100);
 
ALTER TABLE BATCH_JOB_EXECUTION_PARAMS RENAME TYPE_CD TO PARAMETER_TYPE;
 
ALTER TABLE BATCH_JOB_EXECUTION_PARAMS ALTER COLUMN KEY_NAME TYPE VARCHAR(100);
 
ALTER TABLE BATCH_JOB_EXECUTION_PARAMS RENAME KEY_NAME TO PARAMETER_NAME;



create table public.Test_LHS_PartByDate_R2 (like Test_LHS_PartByDate_R1) partition by list (exec_date);

create table data_tbl_29 partition of Test_LHS_PartByDate_R2 for values in(10/29/2024);
create table data_tbl_29 partition of Test_LHS_Feed_R2 for values in(10/30/2024);
create table data_tbl_29 partition of Test_LHS_Feed_R2 for values in(10/29/2024);
create table data_tbl_29 partition of Test_LHS_Feed_R2 for values in(10/29/2024);
create table data_tbl_29 partition of Test_LHS_Feed_R2 for values in(10/29/2024);
create table data_tbl_29 partition of Test_LHS_Feed_R2 for values in(10/29/2024);


NgBDADMAQwA4AEMAOABEAEMAMwA2AEUAOgA2AEMAMwBDADgAQwA4AEQAQwAzADYARgA

 -- -Xms30172M -Xmx40960M -Duser.language=en -Duser.country=IN -Duser.timezone=Asia/Calcutta"



CREATE TABLE Test_LHS_PartByDate_R2_2025_01_17 PARTITION OF Test_LHS_PartByDate_R2 FOR VALUES IN ('2025-01-17');
CREATE TABLE Test_LHS_PartByDate_R2_2025_01_18 PARTITION OF Test_LHS_PartByDate_R2 FOR VALUES IN ('2025-01-18');
CREATE TABLE Test_LHS_PartByDate_R2_2025_01_19 PARTITION OF Test_LHS_PartByDate_R2 FOR VALUES IN ('2025-01-19');
CREATE TABLE Test_LHS_PartByDate_R2_2025_01_20 PARTITION OF Test_LHS_PartByDate_R2 FOR VALUES IN ('2025-01-20');
CREATE TABLE Test_LHS_PartByDate_R2_2025_01_21 PARTITION OF Test_LHS_PartByDate_R2 FOR VALUES IN ('2025-01-21');
CREATE TABLE Test_LHS_PartByDate_R2_2025_01_22 PARTITION OF Test_LHS_PartByDate_R2 FOR VALUES IN ('2025-01-22');
CREATE TABLE Test_Execution_RHS_P2_2025_01_23 PARTITION OF Test_LHS_PartByDate_R2 FOR VALUES IN ('2025-01-23');
CREATE TABLE Test_Execution_RHS_P2_2025_01_24 PARTITION OF Test_LHS_PartByDate_R2 FOR VALUES IN ('2025-01-24');
CREATE TABLE Test_Execution_RHS_P2_2025_01_25 PARTITION OF Test_LHS_PartByDate_R2 FOR VALUES IN ('2025-01-25');
CREATE TABLE Test_Execution_RHS_P2_2025_01_26 PARTITION OF Test_LHS_PartByDate_R2 FOR VALUES IN ('2025-01-26');
CREATE TABLE Test_Execution_RHS_P2_2025_01_27 PARTITION OF Test_LHS_PartByDate_R2 FOR VALUES IN ('2025-01-27');
CREATE TABLE Test_Execution_RHS_P2_2025_01_28 PARTITION OF Test_LHS_PartByDate_R2 FOR VALUES IN ('2025-01-28');
CREATE TABLE Test_Execution_RHS_P2_2025_01_29 PARTITION OF Test_LHS_PartByDate_R2 FOR VALUES IN ('2025-01-29');
CREATE TABLE Test_Execution_RHS_P2_2025_01_30 PARTITION OF Test_LHS_PartByDate_R2 FOR VALUES IN ('2025-01-30');
CREATE TABLE Test_Execution_RHS_P2_2025_01_31 PARTITION OF Test_LHS_PartByDate_R2 FOR VALUES IN ('2025-01-31');
CREATE TABLE Test_Execution_RHS_P2_2025_02_01 PARTITION OF Test_LHS_PartByDate_R2 FOR VALUES IN ('2025-02-01');
CREATE TABLE Test_Execution_RHS_P2_2025_02_02 PARTITION OF Test_LHS_PartByDate_R2 FOR VALUES IN ('2025-02-02');
CREATE TABLE Test_Execution_RHS_P2_2025_02_03 PARTITION OF Test_LHS_PartByDate_R2 FOR VALUES IN ('2025-02-03');
CREATE TABLE Test_Execution_RHS_P2_2025_02_04 PARTITION OF Test_LHS_PartByDate_R2 FOR VALUES IN ('2025-02-04');
CREATE TABLE Test_Execution_RHS_P2_2025_02_05 PARTITION OF Test_LHS_PartByDate_R2 FOR VALUES IN ('2025-02-05');



feed_id,feed_load_id,feed_record_id,num2,num3,num4,num5,str1,str2,str3,str4,str5



create table public.Test_LHS_PartByDateAMPM_R1 (like Test_LHS_PartByDate_R3) partition by list (Date_Str);

CREATE TABLE Test_LHS_PartByDateAMPM_R105112024_PM PARTITION OF Test_LHS_PartByDateAMPM_R1 FOR VALUES IN ('05112024_PM')
CREATE TABLE Test_LHS_PartByDateAMPM_R105112024_AM PARTITION OF Test_LHS_PartByDateAMPM_R1 FOR VALUES IN ('05112024_AM')
CREATE TABLE Test_LHS_PartByDateAMPM_R106112024_PM PARTITION OF Test_LHS_PartByDateAMPM_R1 FOR VALUES IN ('06112024_PM')
CREATE TABLE Test_LHS_PartByDateAMPM_R106112024_AM PARTITION OF Test_LHS_PartByDateAMPM_R1 FOR VALUES IN ('06112024_AM')


