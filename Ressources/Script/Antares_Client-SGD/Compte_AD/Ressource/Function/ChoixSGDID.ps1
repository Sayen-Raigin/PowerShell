function ChoixSGDID ($Find_Account){
    do{
        $End=$false;
        Write-Host "Qu'elle est le SGDID parmis les choix proposés ?" -ForegroundColor Green;
        Write-Host "";

        #Affichage des SGDID :
        $SGDID= New-Object System.Collections.Generic.List[object];
        $i = 0;
        $Find_Account | ForEach-Object {
            $i++;
            $Affichage = $_.Surname + " "+ $_.GivenName + " (SGDID : "+ $_.SamAccountName+")";

            Write-Host $i "=>"  $Affichage;

            #Création du tableau stockant les différents SGDID :
            $SGDID.Add( $_.SamAccountName );
            Write-Host "";Write-Host "";
        };
        
        Write-Host "";
        [int]$choix= Read-Host;

        #----------------------------------------------------------------------------------------------------------------------------------------
         
        if($choix -le 0){
            $choix = 0; #Si le choix est < ou = à 0.
        }elseif($choix -ge $i){
            $choix = $i-1; #Si non si le choix est > ou = à $i (dernière valeur possible).
        }else{
            $choix = $choix-1; #Si non il sera toujours < à $i(valeurs possible parmi les résultats retournés).
        }

        $Select_ID = $SGDID[$choix];
        

        #----------------------------------------------------------------------------------------------------------------------------------------
        Write-Host "";Write-Host "";
        Write-Host "LE SGDID est le : "$Select_ID -ForegroundColor Cyan; Write-Host "";Write-Host "";
        Write-Host "Oui/Non(O/N)(y/n)(Yes/No) ?";Write-Host "";
        $Confirmation = Read-Host;

        if ($Confirmation -like "o*" -or $Confirmation -like "y*"){ 
            
            Write-Host "Merci de le copier et le coller ici : " -BackgroundColor DarkMagenta;Write-Host "";
            $End=$true;
        }else{
            
            cls;
        }
        
    }until($End -eq $true);

};