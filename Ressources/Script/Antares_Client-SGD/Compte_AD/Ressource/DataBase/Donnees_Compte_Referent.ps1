#Stockage des valeurs 
$Site = $ReferenceAccount.City;
$Adresse = $ReferenceAccount.StreetAddress;
$Company = $ReferenceAccount.Company;
$Country = $ReferenceAccount.Country;
$Departement = $ReferenceAccount.Department;
$Bureau = $ReferenceAccount.Office;
$MembreDe = $ReferenceAccount.memberof;
$CodePostal = $ReferenceAccount.PostalCode;
$EmailAddress = $ReferenceAccount.EmailAddress;
$Service = $ReferenceAccount.Description;

$ReferentNoun = $ReferenceAccount.Surname;
$ReferentName = $ReferenceAccount.GivenName;



#Récuperation de l'OU du compte référent :
#CN=David\, Amaury,OU=Users,OU=MER-Mers-les-Bains,OU=Locations,OU=A03-SGD,OU=Entities,OU=Perfumery,DC=DA,DC=SGD,DC=NET
$OUReferenceAccount= $ReferenceAccount.DistinguishedName;
$OU= $OUReferenceAccount.replace($ReferentNoun,$null).replace($ReferentName,$null).replace("CN",$null).replace("\",$null);
$OU= $OU.Remove(0,4);