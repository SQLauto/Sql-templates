-- show triggers
SELECT OBJECT_NAME(triggers.parent_id) AS object_name,
	triggers.name AS trigger_name,
	triggers.parent_class_desc,
	triggers.type_desc,
	triggers.is_disabled,
	triggers.is_instead_of_trigger,
	object_name(triggers.object_id) as trigger_definition
FROM sys.triggers
ORDER BY OBJECT_NAME(triggers.parent_id)