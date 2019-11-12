#Déclaration des Objets (à modifier si besoin) :
$Letter=(Get-Disk -Number 0 | Get-Partition)[1].DriveLetter;
$W8='_W8.vhdx';
$W2012='_W2012.vhdx';
$VM='VMs.csv';

$ArcCli= 'Arcueil-CLi';
$ArcSrv= 'Arcueil-SRV';
$BouLan= 'Bou-Lan';
$Wan= 'WAN';
$Externe = 'Externe';





#----- PATH ---------------------------------------------
$hyperVroot = ($Letter+':');
$Path_VHD = ($hyperVroot+'\VHDs');
$Path_VM = ($hyperVroot+'\VMs');

$ScriptPath= ($PSScriptRoot+'\Ressource\Created_VM.ps1');

#--------------------------------------------------------
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force;
Invoke-Expression -Command $ScriptPath