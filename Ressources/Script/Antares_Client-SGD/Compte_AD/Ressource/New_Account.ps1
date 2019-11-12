# A03GEN-HD-02 @ntares2017
#Détermination du type de contrat :
if ($TypeContrat -eq "CDI"){
    $accountExpires = 0; #Le compte n'expire jamais.
}else{
    $accountExpires = $DateDeFin;
};

#Initialisation et traitement des données du compte référent :
. $PATH_Donnees_Compte_Referent;


#----------------------------------------------------------------------------------------------------------------------
#création de l'adresse mai du user :
$NS_Adresse_MAil = $EmailAddress.split('@')[1];
$NS_Adresse_MAil = '@'+$NS_Adresse_MAil;
$EmailAddress = $UserNoun +'.'+$UserName +$NS_Adresse_MAil;

#déclaration du nom complet :
$FullName  = ($UserNoun+", " + $UserName);
$mdp = "Bonjour2017" | ConvertTo-SecureString -AsPlainText -Force;


#Création du compte du user :
New-ADUser -Path $OU -name $FullName -Enabled $true `
    -GivenName $UserName `
    -Surname $UserNoun `
    -DisplayName $FullName `
    -Description $Service `
    -Office $Bureau `
    -EmailAddress $EmailAddress `
    -StreetAddress $Adresse `
    -City $Site `
    -PostalCode $CodePostal `
    -Country $Country `
    -Department $Departement `
    -Company $Company `
    -Manager $ResponsableOU `
    -SamAccountName $Logon `
    -AccountPassword $mdp `
    -ChangePasswordAtLogon $false `
    -AccountExpirationDate $accountExpires;


#echo "----------ici------------"; sleep(9555);



sleep(1);
#------------------------------------- Partie modification des attributs ------------------------------------------
$NewUser = Get-ADUser -Filter {SamAccountName -eq $Logon} -Properties *;

#Activation du compte :
$NewUser.'msRTCSIP-UserEnabled' = $true;

$NewUser.'msRTCSIP-PrimaryUserAddress' = "sip:"+$EmailAddress; #Adresse Mail utilisée par exchenge



#Création d'un tableau :
$SMTP = "SMTP:"+$EmailAddress;
$SIP = "sip:"+$EmailAddress;

cls;
Write-Host "L'utilisateur aura t il une adresse mail ? (Par défaut No)" -ForegroundColor Green;
Write-Host "";Write-Host "";
echo "Oui/Non(O/N)(y/n)(Yes/No) ?"; echo "";

$Confirmation = read-host;

if($Confirmation -like "o*" -or $Confirmation -like "y*" ){

    $NewUser.proxyAddresses = @($SMTP,$SIP);
}else{
    
    $NewUser.proxyAddresses = @($SIP);
}


$NewUser.UserPrincipalName = $Logon+"@sgdgroup.com";
$NewUser.telephoneNumber = $telephoneNumber;
$NewUser.Title = $Fonction;
$NewUser.PasswordExpired = $true;

#Création d'une nouvel instance d'objet (Mise à jours de l'objet utilisateur) :
Set-ADUser -instance $NewUser;

sleep(1);

#Groupe
$MembreDe | Add-ADGroupMember -Members $Logon;