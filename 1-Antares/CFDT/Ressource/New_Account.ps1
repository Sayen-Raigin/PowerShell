#Détermination du type de contrat :
if ($TypeContrat -eq "CDI"){
    $accountExpires = 0; #Le compte n'expire jamais.
}else{
    $accountExpires = $DateDeFin;
};




#------------------------------------- Partie modification des attributs ------------------------------------------
$NewUser = Get-ADUser -Filter {SamAccountName -eq $Logon} -Properties *;


$NewUser.telephoneNumber = $telephoneNumber;
$NewUser.Title = $Fonction;

#Création d'une nouvel instance d'objet (Mise à jours de l'objet utilisateur) :
Set-ADUser -instance $NewUser;





sleep(1);

#Groupe
#$MembreDe | Add-ADGroupMember -Members $Logon;