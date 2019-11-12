function Boxmsg{ #Petite fonction qui permet de rappeler un message
    cd 'C:/';cls;
    Write-Host "P.S : La liste des imprimantes se trouve dans C:\Temp\___PRINTERS_Name.txt, si besoin !" -ForegroundColor Green;
    Write-Host '';
}

$ScriptName='___ClearPrint_1.5.ps1';
$Imprimantes= Get-WmiObject -class win32_Printer | Where-Object -Property Name -like '\\*';
$DefaultPrinter= Get-WmiObject -class win32_Printer | Where-Object -Property Name -like '\\*'| Where-Object -Property Default -EQ $true;
$TempPath = 'C:\Temp';

#Si le user a des queux d'impression sur sa machine, alors on lance le script. Si non on termine avec un petit message
if($Imprimantes){
    if(Get-Item -Path ($TempPath+'\'+'N1_Session.3900') -ErrorAction Ignore){
        Get-Item -Path ($TempPath+'\'+'N1_Session.3900') | Remove-Item;
    }

    #On créer un fichier de backup des printers si jamais l'opération c'est mal déroulé
    New-Item -Path $TempPath -ItemType File -Name '___PRINTERS_Name.txt';

    #On save dans le fichier txt et supprime les printers
    $i=0;
    $Imprimantes | ForEach-Object{
        Add-Content -Path ($TempPath+'\'+'___PRINTERS_Name.txt') -Value $_.Name;
        Get-WmiObject -class win32_Printer | Where-Object -Property Name -like $_.Name | Remove-WmiObject;
        $i++;
    }

    Boxmsg;
    Write-Host "Appuyer sur A (si c'est demandé) et faite entrée" -ForegroundColor Cyan;
    Remove-Item -Path "C:\Users\$env:USERNAME\TOSHIBA" -Confirm;
    Write-Host '';
    Write-Host 'Suppression faite !' -ForegroundColor Green; Write-Host '';




    #--------------------------------------- Partie Adm -----------------------------------------------------------------------
    Boxmsg;
    #On propose au Tech trois essaie pour s'authent avec le compte Adm.
    $i=0;$CompteurFin=$false;$debutEssaie=1;$FinEssaie=3;
    $Compteur = $debutEssaie..$FinEssaie;
    $Compteur|ForEach-Object{
        $Cred=$null;$Error.Clear();
        if($CompteurFin -eq $false){
            Write-Host "Merci de saisir un compte Admin afin d'Arrêter/Redémarrer le service du spooler !" -ForegroundColor Cyan


            #Le fichier N1_Session.3900 permet de sortire de la boucle mais surtous de pouvoir attendre le processus de nettoyage au niveau du spooler
            Start-Process powershell.exe -Credential ($Cred=Get-Credential ($env:USERDOMAIN+'\adm_') -ErrorAction Ignore ) -NoNewWindow -ArgumentList (
                "Start-Process powershell.exe -Verb runAs -WindowStyle Hidden -ArgumentList {
                    ls 'C:\Windows\System32\spool\PRINTERS\*' | Remove-Item; Start-Sleep(1);
                    Get-Service -Name 'spooler' | Stop-Service -Force; Start-Sleep(1);
                    Get-Service -Name 'spooler' | Start-Service; Start-Sleep -Seconds 1;
                    New-Item -Path 'C:\Temp' -ItemType File -Name 'N1_Session.3900';
                }"
            ) -PassThru;
            
            if($Cred -notlike $null){
                #On arréte la boucle si il n'y a aucune erreur. Si non , on indique l'erreur.
                if($Error[0] -eq $null){
                    $CompteurFin=$true;
                }else{
                    cls;Write-Host "Nom d'utilisateur ou mot de passe incorrect" -ForegroundColor Cyan;
                }
            }else{
                cls;Write-Host "Vous avez annulé l'authentification" -ForegroundColor Cyan;
            }

            #Processus d'indication d'essaie restant !
            $i++;
            if($Error[0] -notlike $null){
                [int]$Essaie = $FinEssaie-$i;
                if($Essaie -ne 0){ Write-Host "Il vous reste $Essaie Essaie !"};Write-Host '';
            }
        }
    }
    if($Essaie -ne 0){
        do{
            Write-Host "1" -ForegroundColor Green;Start-Sleep -Seconds 1;
            Write-Host '0' -ForegroundColor Cyan;Start-Sleep -Seconds 1;
        }until( (Get-Item -Path ($TempPath+'\'+'N1_Session.3900') -ErrorAction Ignore) )
        Start-Sleep -Seconds 3
        Get-Item -Path ($TempPath+'\'+'N1_Session.3900') | Remove-Item -Force;
    }




    #-------------------------------------------Partie installation et nettoyage-------------------------------------------------------------------------------
    cls;
    Write-Host 'Installation en cours...';
    $Printer = New-Object -ComObject WScript.Network;
    $i=0
    $Imprimantes | ForEach-Object{
        $Printer.AddWindowsPrinterConnection($_.Name);
        $i++;
    }
    $Printer.SetDefaultPrinter($DefaultPrinter.Name);
    Write-Host 'Imprimante installé !!!';


    Remove-Item -Path ($TempPath+'\'+'___PRINTERS_Name.txt'); Write-Host '';
    Write-Host 'La liste des imprimantes situé dans C:\Temp\___PRINTERS_Name.txt, est maitenant supprimé !' -ForegroundColor Cyan; Write-Host '';
    Read-Host 'Entrée pour terminer';

}else{
    
    Write-Host "Aucune imprimante réseau, installée sur la station !" -ForegroundColor Cyan; Write-Host '';
    Read-Host 'Appuis sur entrée pour quitter';
}


<#
[Environment]::SetEnvironmentVariable('___PrinterName'+$i,$_.Name,'User');
$Delet=ls env: | where-object -Property Name -like '___PrinterName*';
$i=0;$Delet|ForEach-Object{ [Environment]::SetEnvironmentVariable('___PrinterName'+$i,$null,'User');$i++;};
#>