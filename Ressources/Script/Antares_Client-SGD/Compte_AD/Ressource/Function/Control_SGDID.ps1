function Control_SGDID{
    
    param ($Find_Account);


    Style_Control_SGDID;

    do{
        #Fonction pour ajouter SGDID :
        ChoixSGDID ($Find_Account);
        $ID = Read-Host;


        $Control_Chars = $false;
        $Control_Letter = $false;

        #------------------------------------------------------Contrôle 1-----------------------------------------------------
        #Contrôle du nombre de caractère :
        if ( $ID.Length -eq 8 ){

            $Control_Chars = $true;
        }
        else{
 
            Write-Host "";
            Write-Host "Le SGDID ne correspond pas à 8 caractères" -ForegroundColor DarkYellow;
            Write-Host "Vous en avez saisie }=> " $ID.Length -ForegroundColor Cyan;
            $Control_Chars = $false;
        };


        #------------------------------------------------------Contrôle 2-----------------------------------------------------
        #Test la première valeur du tableau afin d'identifier si c'est une lettre

        $Lettre =@('a','z','e','r','t','y','u','i','o','p','q','s','d','f','g','h','j','k','l','m','w','x','c','v','b','n') ;
        $Lettre | ForEach-Object{
            $test = $_;        
            if($ID[0] -eq $test){

                $Control_Letter= $true;
                $Message = $false;
            }
        }
        if($Control_Letter -eq $false){
        
            $Control_Letter = $false;
            $Message = $true;
        }

        if($Message -eq $true){ Write-Host "";Write-Host ""; Write-Host "Le SGDID doit avoir pour première valeur une lettre" -ForegroundColor DarkYellow; };

    
        #-------------------------------------------------------------------------------------------------------------------
    
        if(($Control_Chars -eq $false) -or ($Control_Letter -eq $false)){sleep(3);cls;};

    }until( ($Control_Chars -eq $true) -AND ($Control_Letter -eq $true) );

    return $ID;
}