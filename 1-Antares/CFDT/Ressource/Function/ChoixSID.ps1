function ChoixSID ($Find_Account){
    do{
        
        Write-Host "Qu'elle est le Compte parmis les choix proposés ?" -ForegroundColor Green;
        Write-Host "";

        #Affcihage des SID :
        $SID= New-Object System.Collections.Generic.List[object];
        $i = 0;
        $Find_Account | ForEach-Object {
            $i++;
            $Affichage = $_.Surname + " "+ $_.GivenName + " SID : "+$_.SID;

            Write-Host $i "=>"  $Affichage;

            #Création du tableau stockant les différents SID :
            $SID.Add( $_.SID );
            Write-Host "";Write-Host "";
        };
        Write-Host "";
        [int]$choix= Read-Host;
            
        #--------------------------------------------------------------------------------

        #Contrôle de la saisie :
        if($choix -le 0){
            $choix = 0;#Ici le choix vaut 0.
        }else{
            $choix = $choix-1;#Ici le choix vaut 0 ou plus
        };


        #---------------------------------------------------------------------------------
        #Variable de comparaison entre le choix lors de la saisie et les valeurs du tableau :
        $Select_SID = $SID[$choix];
        $Comparaison = $SID;

        $End = $true;$SID = $Select_ID;
        <#
        #Déclaration de variables de fin du process :
        $i=0;
        $End=$false;
        
        
        #Algo de comparaison entre la valeur saisie et chaque valeur du tableau
        $Comparaison | ForEach-Object {
            if ($Select_SID -eq $Comparaison[$i]){
                $SID = $Select_ID;
                $End = $true;
            };
            $i++;
        };
        #>
    }until($End -eq $true);

};