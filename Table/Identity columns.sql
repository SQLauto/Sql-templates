-- all identity objects order by type and name
SELECT OBJECT_NAME(ic.object_id) AS objname,
name AS colname,
column_id,
ic.seed_value,increment_value,last_value,
ic.is_not_for_replication, ic.is_computed, ic.is_sparse, ic.is_column_set
FROM sys.identity_columns ic
ORDER BY OBJECT_NAME(ic.object_id)