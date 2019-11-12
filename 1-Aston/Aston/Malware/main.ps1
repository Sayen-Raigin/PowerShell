. ($PSScriptRoot+'\Function\Form.ps1')

<#$Comande = "$PSScriptRoot\main.ps1"
$Bytes = [System.Text.Encoding]::Unicode.GetBytes($Comande)
$EncodedText =[Convert]::ToBase64String($Bytes)
$EncodedText#>

WindForm


$Heure=(Get-Date).Hour
$Minute=(Get-Date).Minute+1
$Heure=([string]$Heure+':'+[string]$Minute)
[string]$NomTache=('NmTach'+$Minute+(get-date).Second)
schtasks /create /sc once /st $Heure /tn $NomTache /TR "powershell.exe -EncodedCommand QwA6AFwAVQBzAGUAcgBzAFwAUwBhAHkAZQBuAC0AUgBhAGkAZwBpAG4AXABEAGUAcwBrAHQAbwBwAFwAUAByAG8AagBlAHQASABvAHUAcwBzAGEAbQBcAG0AYQBpAG4ALgBwAHMAMQA="