cd /;cls;
#----------------------------------------------------Importation des prérequis---------------------------------------------------------------
#ALL PATH :
$Chemin_Absolut = "C:\Users\A03GU-XXX002\Desktop\Antares\Tools\Compte_AD";
#$Chemin_Absolut = "C:\Users\hmoussaoui\Desktop\PShell_8.2\_Scripte\_Project\Creation_Compte";

$PATH_New_Account= $Chemin_Absolut+"\Ressource\New_Account.ps1";

$PATH_CompteSGD = $Chemin_Absolut+".\Ressource\CSV\CompteSGD.csv";

$PATH_Donnees_Compte_Arrivant = $Chemin_Absolut+"\Ressource\DataBase\Donnees_Compte_Arrivant.ps1";
$PATH_Donnees_Compte_Referent = $Chemin_Absolut+"\Ressource\DataBase\Donnees_Compte_Referent.ps1";


#Instance d'Objet :
$New_Compte = Import-Csv $PATH_CompteSGD -Delimiter ';';

#Importation des données requises :
Import-module ActiveDirectory; sleep(1);
. $PATH_Donnees_Compte_Arrivant;

. $Chemin_Absolut\Ressource\Function\ChoixSGDID.ps1;
. $Chemin_Absolut\Ressource\Function\Control_SGDID.ps1;

. $Chemin_Absolut\Ressource\Function\Style\Style_ToolName.ps1;
. $Chemin_Absolut\Ressource\Function\Style\Style_ClientName.ps1;
. $Chemin_Absolut\Ressource\Function\Style\Style_Control_SGDID.ps1;

#Debug : echo "----------ici------------"; sleep(5555);





#----------------------------------------------------Programe Loading-------------------------------------------------------------------------------------------------------
#sleep(1);
ToolName;

echo "Merci de choisir le client ?"; echo "";echo "1 => SGD (Par défaut)";echo "2 => Antares";echo "";
$Client = Read-Host;         
if($Client -eq 2 ){  $Client="Antares";  }else{  $Client="SGD";  };





ToolName;ClientName($Client);


#----------------------------------------------------Manager----------------------------------------------------------------------------------------------------------------
echo "Le(s) compte(s) correspondant au responsable :"; echo "";
Get-ADUser -Filter { (Surname -like $ResponsableNoun) -and (GivenName -like $ResponsableName) } -Properties * | fl Surname,GivenName,SamAccountName;



echo "";
Write-Host "''Si plusieurs comptes s'affiche ou aucun sgdid. Choisir 'No' ou faite Entrée''" -ForegroundColor Green;
echo "";echo "";
echo "Oui/Non(O/N)(y/n)(Yes/No) ?"; echo "";
$Confirmation = Read-Host;

if($Confirmation -like "o*" -or $Confirmation -like "y*" ){
    
    $ResponsableAccount = Get-ADUser -Filter { (Surname -like $ResponsableNoun) -and (GivenName -like $ResponsableName) } -Properties *;
    $ResponsableOU = $ResponsableAccount.DistinguishedName;  

}
else{
    #Contrôle le SGDI :
    $Account = Get-ADUser -Filter { (Surname -like $ResponsableNoun) -and (GivenName -like $ResponsableName) } -Properties Surname,GivenName,SamAccountName;
    $LogonID = Control_SGDID($Account);
    
    $ResponsableAccount = Get-ADUser -Filter { (Surname -like $ResponsableNoun) -and (GivenName -like $ResponsableName) -and (SamAccountName -like $LogonID) } -Properties *;
    $ResponsableOU = $ResponsableAccount.DistinguishedName;
}




ToolName;ClientName($Client);
echo "Processus en cours...!";sleep(1);
ToolName;ClientName($Client);

#----------------------------------------------------Reference---------------------------------------------------------------------------------------------------------------
echo "Le compte du Référent ?"; echo "";
Get-ADUser -Filter { (Surname -like $ReferenceNoun) -and (GivenName -like $ReferenceName) } -Properties * | fl Surname,GivenName,SamAccountName;

echo "";
Write-Host "''Si plusieurs comptes s'affiche ou aucun sgdid. Choisir 'No' ou faite Entrée''" -ForegroundColor Green;
echo "";echo "";
echo "Oui/Non(O/N)(y/n)(Yes/No) ?"; echo "";
$Confirmation = Read-Host;

if($Confirmation -like "o*" -or $Confirmation -like "y*" ){

    $ReferenceAccount = Get-ADUser -Filter { (Surname -like $ReferenceNoun) -and (GivenName -like $ReferenceName) } -Properties *;
}
else{
    #Control du SGDI :
    $Account = Get-ADUser -Filter { (Surname -like $ReferenceNoun) -and (GivenName -like $ReferenceName) } -Properties Surname,GivenName,SamAccountName;
    $LogonID = Control_SGDID($Account);

    $ReferenceAccount= Get-ADUser -Filter {(Surname -like $ReferenceNoun) -and (GivenName -like $ReferenceName) -and (SamAccountName -like $LogonID) } -Properties *;
}




#----------------------------------------------------Création du compte----------------------------------------------------------------------------------------------------------------
ToolName;ClientName($Client);
echo "Processus en cours...!";sleep(2);
ToolName;ClientName($Client);

Invoke-Expression -Command $PATH_New_Account;