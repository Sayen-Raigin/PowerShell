cls
$Csv = Import-Csv -Delimiter ";" -Path ($PSScriptRoot+'\Audite.csv')


$Win32OS= Get-WmiObject -Class Win32_OperatingSystem -Property *



$Csv | ForEach-Object {
    
    <#Infos générales
    ---------------
    Computer Role
    Computer Workgroup
    Operating System
    Service Pack
    System Root
    Manufacturer
    Model
    Number of Processors
    Memory	
    Registered User	
    Last System Boot
    #>

    Write-Host ($_.Name+": "+($Win32OS).[string]$_.Value) 
}