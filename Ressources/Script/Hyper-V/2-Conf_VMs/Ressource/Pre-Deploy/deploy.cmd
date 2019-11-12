powershell.exe set-executionpolicy -scope CurrentUser -executionPolicy Bypass -force;
powershell.exe c:\conf\deploy.ps1 >> c:\conf\deploy-log.txt;
