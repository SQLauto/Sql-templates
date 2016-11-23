-- need correct permissions on sql service
-- or sql agent to run cmd script to do the actions

DECLARE @FromDir varchar(100);

SET @FromDir = 'Rename C:\Users\watera1\Desktop\what.ps1' + ' NewFile.ps1';

EXEC xp_cmdshell @FromDir;



declare @cmdstring varchar(1000)

set @cmdstring = 'copy C:\Users\watera1\Desktop\what.ps1 C:\Users\watera1\Desktop\yeah.ps1'
exec master..xp_cmdshell @cmdstring