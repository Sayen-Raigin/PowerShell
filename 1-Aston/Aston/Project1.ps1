#Déclara des variables
$PathAbsolut=('C:\Users\Sayen-Raigin\Desktop')
$PathDirectory=($PathAbsolut+'\'+'Test3900')
$ItemObjet = @{}
$TailleTotal=0;

#Création du répertoire
New-Item -ItemType directory -Path $PathDirectory

#Création des 100 fichiers
for ($i=1;$i -lt 101 ;$i++){ New-Item -ItemType file -Path ($PathDirectory+'\'+$i+'.3900') }


#Renomme les fichiers créer
for ($i=1;$i -lt 101 ;$i++){
    if(($i/2).gettype().name -eq 'Double' ){
        Rename-Item -Path ($PathDirectory+'\'+$i+'.3900') -NewName ('Impaire'+$i+'.old')
    }
}

#Récupération des fichiers .old
$FileOld = Get-ChildItem -Path $PathDirectory | Where-Object { $_.Name -like '*.old'  }


#Incrémentation des files old dans un objet
$i=0;
ForEach($Item in $FileOld) {
    $ItemObjet[$i] = $Item;
    Write-Host '-------------------';
    Write-Host ('Taille du fichier '+$ItemObjet[$i].Length+' Octet') -ForegroundColor red
    Write-Host ('Nom du fichier '+$ItemObjet[$i].Name) -ForegroundColor green
    Write-Host '-------------------';Write-Host '';Write-Host '';
    
    if($ItemObjet[$i].Length -gt 0){
        
        $TailleTotal +=  $ItemObjet[$i].Length
    }
    $i++
}

Write-Host ('Totale du poind est ' + $TailleTotal)