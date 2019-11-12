cd $PSScriptRoot;

$AideLanceurWebTxT = Get-Content $NomAideLanceurWeb;
$FileXML = cat $NomTemplateReplaceXML
$ofs="`r`n" # Saut de ligne
$i=0;
if($FileXML){
    $AideLanceurWebTxT | ForEach-Object{
    
        #exec install
        if($_ -eq "#KeyInstExec"){
            $CommandeInstallExec = $AideLanceurWebTxT[$i+1]
        }

        #install => Lot1
        if($_ -eq "#KeyInstLot1"){
            $i2=0;
            $AideLanceurWebTxT | ForEach-Object{
                if($_ -eq "#KeyInstLot1Fin"){
                    $Fin=$i2;
                }
                $i2++;
            }
            $debut=$i;
            $InstallLot1=$AideLanceurWebTxT[($debut+1)..($Fin-1)]
        }

        #install => Lot2
        if($_ -eq "#KeyInstLot2"){
            $i2=0;
            $AideLanceurWebTxT | ForEach-Object{
                if($_ -eq "#KeyInstLot2Fin"){
                    $Fin=$i2;
                }
                $i2++;
            }
            $debut=$i;
            $InstallLot2=$AideLanceurWebTxT[($debut+1)..($Fin-1)]

        }

        #exec Uninstall
        if($_ -eq "#KeyUninstExec"){
            $CommandeUninstallExec = $AideLanceurWebTxT[$i+1]
        }

        #Uninstall => Lot1
        if($_ -eq "#KeyUninstLot1"){
            $i2=0;
            $AideLanceurWebTxT | ForEach-Object{
                if($_ -eq "#KeyUninstLot1Fin"){
                    $Fin=$i2;
                }
                $i2++;
            }
            $debut=$i;
            $UninstallLot1=$AideLanceurWebTxT[($debut+1)..($Fin-1)]
        }


        #CommandeInstallFichierTxt
        if($_ -eq "#KeyCommandetxt"){
            $i2=0;
            $AideLanceurWebTxT | ForEach-Object{
                if($_ -eq "#KeyCommandetxtFin"){
                    $Fin=$i2;
                }
                $i2++;
            }
            $debut=$i;
            $CommandeTxt=$AideLanceurWebTxT[($debut+1)..($Fin-1)]
        }
        $i++
    }
    $i=0
    $FileXML | ForEach-Object{
    
        if($_ -like '*#KeyInstExec*'){
            $FileXML[$i]="      <parametre nomparametre=`"lignecomparams`">$CommandeInstallExec</parametre>"
        }
        if($_ -like '*#KeyInstLot1*'){
            $FileXML[$i]="      <parametre nomparametre=`"scriptlot`">$InstallLot1</parametre>"
        }
        if($_ -like '*#KeyInstLot2*'){
            $FileXML[$i]="      <parametre nomparametre=`"scriptlot`">$InstallLot2</parametre>"
        }


        if($_ -like '*#KeyUninstExec*'){
            $FileXML[$i]="      <parametre nomparametre=`"lignecomparams`">$CommandeUninstallExec</parametre>"
        }
        if($_ -like '*#KeyUninstLot1*'){
            $FileXML[$i]="      <parametre nomparametre=`"scriptlot`">$UninstallLot1</parametre>"
            #$FileXML[$i]="      <parametre nomparametre=`"scriptlot`">"+ ($UninstallLot1|ForEach-Object{$ofs+"            "+$_}) +$ofs+"      </parametre>"
        }
        $i++
    }
    Set-Content -Encoding UTF8 -Path $NomTemplateReplaceXML -Value $FileXML
}else{
    "Fichier SIT-TemplateReplace introuvable dans le dossier Ressource !
    `$FileXML : $FileXML
    " > "Debug-AlimenteXmlAuto.txt"
}
Remove-Item $NomAideLanceurWeb