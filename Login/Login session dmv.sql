-- details of current user session
SELECT des.session_id,des.host_name, des.program_name, des.login_name,des.nt_domain, des.nt_user_name,
    des.login_time,des.last_request_start_time, des.last_request_end_time,
    DATEDIFF(mm,des.login_time,des.last_request_start_time) ElapsedMinute,
    reads, des.writes, des.logical_reads
FROM sys.dm_exec_sessions des
WHERE des.original_login_name = ORIGINAL_LOGIN() AND status = 'running'

-- details of all active transactions in current database server. It returns transaction begin time, transaction status, etc.
Select transaction_id,name,transaction_begin_time,transaction_type,transaction_uow,transaction_state,
transaction_status,transaction_status2,dtc_state,dtc_status,dtc_isolation_level,
	filestream_transaction_id 
from sys.dm_tran_active_transactions

-- details about current transaction only.
Select transaction_id,transaction_sequence_num,transaction_is_snapshot,first_snapshot_sequence_num,
last_transaction_sequence_num,first_useful_sequence_num 
from sys.dm_tran_current_transaction