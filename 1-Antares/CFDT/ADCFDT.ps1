cls
#Import-Module -Name activedi*
#oy#@w@#e
#Détermination du type de contrat :
$Nom = "Moussaoui";
$Prenom ="Houssam";
$Surname = '*'+$Nom+'*';
$GivenName = '*'+$Prenom+'*';
Get-ADUser -Filter { (Surname -like $Surname) -and (GivenName -like $GivenName) } | fl Surname,GivenName,SamAccountName;

Invoke-Command -ComputerName cfdt-srv-filer1 -Credential confederation\antares  -port 5985  -ScriptBlock {
           New-Item -Path D:\F\Users\ -Name "Moussaoui1" -ItemType Directory;
};
<#
if ($TypeContrat -eq "CDI"){
    $accountExpires = 0; #Le compte n'expire jamais.
}else{
    $accountExpires = $DateDeFin;
};
#>
#sleep(555);

#------------------------------------- Partie modification des attributs ------------------------------------------
$NewUser = Get-ADUser -Filter { (Surname -like $Nom) -and (GivenName -like $Prenom) } -Properties *;
$NewUser.ScriptPath = "LogonScript.ps1";

$NewUser.AccountExpirationDate = "30/07/2017 20:15:35" ;
$NewUser.PasswordExpired = $true;
$NewUser.PasswordNeverExpires = $true;
$NewUser.HomeDirectory = "\\cfdt-srv-filer1\Users\"+$Nom;
$NewUser.HomeDrive = "U:";

#$NewUser.telephoneNumber ="" ;
#$NewUser.Title ="" ;

#Création d'une nouvel instance d'objet (Mise à jours de l'objet utilisateur) :
Set-ADUser -instance $NewUser;




sleep(1);

#Groupe
#$MembreDe | Add-ADGroupMember -Members $NewUser.SID;