$Letter=(Get-Disk -Number 0 | Get-Partition)[1].DriveLetter;

$VHDRoot =($Letter+':\VHDs');
$ConfPath=($PSScriptRoot +'\Ressource\Pre-Deploy');
$VMs=import-csv -Path ($PSScriptRoot + '\Ressource\VMs.csv') -Delimiter ';';
cd /;cls;

$VMs | ForEach-Object{

    $VMName=$_.Name;
    $VMType=$_.TypeMachine
    $VHDPath = ($VHDRoot + '\' +$VMName+'.vhdx');
    

    #-------------------------- Mount VHD -----------------------------------------------------------------
    #On stocke le résultat du montage du disque :
    $Mount = Mount-VHD -Path $VHDPath -Passthru;

    #On récupére la lettre du lecteur monté :
    $MountedDisk=($Mount| Get-Disk  | Get-Partition);
    $MountedDisk = $MountedDisk |  Where-Object { $_.Size -gt 7GB }
    $winvhd=$MountedDisk.DriveLetter

    #-------------------------- Copier fichiers -----------------------------------------------------------
    #Unattend - tous OS
    # Pour les OS client,  Unattend par client
    # Pour les OS serveurs  unatted générique (qui lance le fichier de conf)

    #OS Client
    if($VMType -eq 'Client'){

        #On copie l'unattend
        $confsource= ($ConfPath + '\Unattend-' +$VMName + '.xml');
        $confDestination= ($winvhd + ':\Windows\Panther\Unattend.xml');
        Copy-Item $confsource $confDestination;
        Write-Host "Copie du fichier Unattend du Client $confsource ==> $confDestination " -ForegroundColor Cyan;

        #On créer le dossier de conf (c:\conf)
        $Conf= ($winvhd +':\conf');
        New-Item $Conf -ItemType 'directory';
        Write-Host "création du dossier de conf => $Conf" -ForegroundColor White;

        #On Copie le fichier de conf
        $confsource= ($ConfPath + '\CLI.ps1');
        $confDestination= ($Conf+'\'+'deploy.ps1');
        Copy-Item $confsource $confDestination;
        Write-Host "Copie du fichier de conf du Client $confsource ==> $confDestination " -ForegroundColor Green;

        #On Copie le fichier executable deploy.cmd
        $confsourceCMD=($ConfPath + '\deploy.cmd');
        $confDestinationCMD= ($Conf+'\'+'deploy.cmd');
        Copy-Item $confsourceCMD $confDestinationCMD;
        Write-Host "Copie de l'éxecutable $confsourceCMD ==> $confDestinationCMD " -ForegroundColor Gray;
        	
    }
    else{#OS Serveur
        Write-Host '';
        #On copie l'unattend
        $confsource= ($ConfPath + '\Unattend-2012.xml');
        $confDestination= ($winvhd + ':\Windows\Panther\Unattend.xml');
        Copy-Item $confsource $confDestination;
        Write-Host "Copie du fichier Unattend du Serveur $confsource ==> $confDestination " -ForegroundColor Cyan;


        #On créer le dossier de conf (c:\conf)
        $Conf= ($winvhd +':\conf');
        New-Item $Conf -ItemType 'directory';
        Write-Host "création du dossier de conf => $Conf" -ForegroundColor White;

        #On Copie le fichier de conf
        $confsource= ($ConfPath + '\'+$VMName+'.ps1');
        $confDestination= ($Conf+'\'+'deploy.ps1');
        Copy-Item $confsource $confDestination;
        Write-Host "Copie du fichier de conf du Serveur $confsource ==> $confDestination " -ForegroundColor Green;

        #On Copie le fichier executable deploy.cmd
        $confsourceCMD=($ConfPath + '\deploy.cmd');
        $confDestinationCMD= ($Conf+'\'+'deploy.cmd');
        Copy-Item $confsourceCMD $confDestinationCMD;
        Write-Host "Copie de l'éxecutable $confsourceCMD ==> $confDestinationCMD " -ForegroundColor Gray;


    }

    #--------------------------- Dismount VHD -------------------------------------------------------------
    sleep(1);
    Dismount-VHD -Path $VHDPath;
}

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned;



#Partie fonction
    <#function Deploy-SetContent{
        param($FilePath,$ValRecherch1,$ValRecherch2,$VMName)
        $Content = Get-Content $FilePath;
        $Construct = $Content | Where-Object { $_ -match $ValRecherch1 -or $_ -match $ValRecherch2 };
        $LigneDeLaChaine=$Construct.Split(' ')[1];
        $ValeurRechercher = $LigneDeLaChaine.Split('\')[2].split('.')[0];
        $Content=$Content.Replace($ValeurRechercher,$VMName);
        Set-Content -Path $FilePath -Value $Content;
    } Deploy-SetContent -FilePath $DeployFilePath -ValRecherch1 'RTR-' -ValRecherch2 'SRV-' -VMName $VMName;
#>