Clear-Host;cd $PSScriptRoot;

#Chargement du plugin
. ".\Plug-Fonction.ps1"

$VersionAideLanceur = $Form.text

$CheminPackage = $TextBox1.Text

$MST = ls $CheminPackage | Where-Object -Property "Name" -like "*.mst"
$MSI = ls $CheminPackage | Where-Object -Property "Name" -like "*.msi"

$CDCV = Get-MSIProperty -PathBinaire $CheminPackage -Property 'ProductCDCV'
$ProductCode = Get-MSIProperty -PathBinaire $CheminPackage -Property 'ProductCode'
$NomRepertoireParentRac = Get-MSIProperty -PathBinaire $CheminPackage -Property 'NomRepertoireParentRac'
$TypeApplication = Get-MSIProperty -PathBinaire $CheminPackage -Property 'TypeApplication'
$TemplateVersion_MST = Get-MSIProperty -PathBinaire $CheminPackage -Property 'TemplateVersion'
$INSTALLDIR = Get-MSIProperty -PathBinaire $CheminPackage -QuerySQL "SELECT DefaultDir FROM Directory WHERE Directory_Parent = 'ProgramFilesFolder'"

$ProductCode = ($ProductCode | Where-Object { $_ -notmatch '^\s*$' })
$NomRepertoireParentRac = ($NomRepertoireParentRac | Where-Object { $_ -notmatch '^\s*$' })
$CDCV = ($CDCV | Where-Object { $_ -notmatch '^\s*$' })
$TypeApplication = ($TypeApplication | Where-Object { $_ -notmatch '^\s*$' })
$TemplateVersion_MST = ($TemplateVersion_MST | Where-Object { $_ -notmatch '^\s*$' })

# Favoris oui si c'est firefoxe si non si c'est pour IE
if($TemplateVersion_MST -eq "12.12"){$appliType_FireFox=$true}else{$appliType_FireFox=$false}


#On splite car la valeur retourné ressemble à cela : SYLEXT~1|Sylex TRAM
$INSTALLDIR = if( ($INSTALLDIR | Where-Object { $_ -notmatch '^\s*$' }).Contains("|") ){
    ($INSTALLDIR | Where-Object { $_ -notmatch '^\s*$' }).Split('|')[1]
}else{
    ($INSTALLDIR | Where-Object { $_ -notmatch '^\s*$' })
}
$INSTALLDIR = "ProgramFilesFolder\$INSTALLDIR"

$NomTemplateXML="TemplateLanceur-Web.xml" 
$NomTemplateReplaceXML="SIT-TemplateReplace.Tmpxml"
$NomAideLanceurWeb="AideLanceur-Web.SitTmp";


# --------------------------------------- Partie Installdir Building ---------------------------------------

$Tab_VarEnv = @{

    'ProgramFilesFolder'='${env:ProgramFiles(x86)}';
    'ProgramFiles64Folder'='$env:ProgramFiles';
    'CommonAppDataFolder'='$env:ProgramData';
    'AppDataFolder'='$env:APPDATA';
    'CommonFiles64Folder'='$env:CommonProgramFiles';
    'CommonFilesFolder'='$env:CommonProgramFiles(x86)';
    'LocalAppDataFolder'='$env:LOCALAPPDATA';
    'System64Folder'='C:\Windows\SysWOW64';
    'SystemFolder'='C:\Windows\System32';
    'ALLUSERSPROFILE'='$env:ALLUSERSPROFILE'
}

$INSTALLDIR= $Tab_VarEnv.($INSTALLDIR.Split('\')[0])+$INSTALLDIR.Substring($INSTALLDIR.IndexOf('\'))+"#!"

if($INSTALLDIR.LastIndexOf('\#!') -gt -1){
    $INSTALLDIR=$INSTALLDIR.Replace( $INSTALLDIR.Substring( $INSTALLDIR.LastIndexOf('\#!') ),'' )
}else{
    $INSTALLDIR=$INSTALLDIR.Replace( $INSTALLDIR.Substring( $INSTALLDIR.LastIndexOf('#!') ),'' )
}#Si le retour est > -1 sa veux dire que la méthode LastIndexOf a trouvée un \ à la fin est donc il faut le supprimer ! Si non on laisse tel quel.


${appli.ico}="$INSTALLDIR\appli.ico"

# --------------------------------------- Partie Installdir Building ---------------------------------------



# --------------------------------------- Partie Raccourcie Building ---------------------------------------

$RATP_NomRepertoireRac=1     # 1 => ® APPLICATIONS METIER (Les applications web doivent avoir cette valeur)
switch($RATP_NomRepertoireRac){
    1{$RATP_NomRepertoireRac="® APPLICATIONS METIER"}
    2{$RATP_NomRepertoireRac="® UTILITAIRES"}
    3{$RATP_NomRepertoireRac="® APPLICATIONS BUREAUTIQUE"}
    4{$RATP_NomRepertoireRac="® OUTILS DE MAINTENANCE"}
}

$arboRac = "$RATP_NomRepertoireRac\$NomRepertoireParentRac";
$Uninstall_RemoveRepertoireRac = "Remove-Item -Path `"C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$NomRepertoireParentRac`" -Recurse"

# --------------------------------------- Partie Raccourcie Building ---------------------------------------



# --------------------------------------- Partie LigneCommande Building ---------------------------------------

if($ProductCode.Contains("{")){
    $MsiExec_Uninstall = "/x `"$ProductCode`" /qn /norestart /L*V `"%RATPLOGS%\APPLIS\${CDCV}_DESINSTALL.log`""
}else{
    $MsiExec_Uninstall = "/x `"Remplacer par le ProductCode`" /qn /norestart /L*V `"%RATPLOGS%\APPLIS\${CDCV}_DESINSTALL.log`""
}


if($MST){
    $MstName = $MST.Name
    $MsiName = $MSI.Name
    $MsiExec_Install = "/i `"$MsiName`" TRANSFORMS=`"`" /qn /norestart /L*V `"%RATPLOGS%\APPLIS\$CDCV.log`""
    $MsiExec_Install = $MsiExec_Install.Replace( 'TRANSFORMS="',"TRANSFORMS=`""+$($MstName | ForEach-Object{"$_;"})+"" ).Replace('; ',';').Replace(';"','"')

}else{
    $MsiExec_Install = "/i `"${CDCV}.msi`" /qn /norestart /L*V `"%RATPLOGS%\APPLIS\$CDCV.log`""
}

# --------------------------------------- Partie LigneCommande Building ---------------------------------------



# --------------------------------------- Partie Favoris Building ---------------------------------------

$FavorisIE=$null;
if($appliType_FireFox -eq $false){
    $FavorisIE ="#------------ Partie Favoris IE -------------
    `$INSTALLDIR = `"$INSTALLDIR`"; `$INSTALLDIR = ('`"')+`$INSTALLDIR+('`"');
    `$CheminActSetVBS= (`"$env:RATPPKGAPPS\$CDCV\ActiveSetup.vbs`");
    `$dataString = Get-Content `$CheminActSetVBS;
    `$i=0;`$dataString | foreach {if(`$_ -like '*=`"C:\*'){ `$Replace = `$_.replace(`$_.Substring(`$_.LastIndexOf('=`"')),`"=`$INSTALLDIR`"); `$dataString[`$i] = `$Replace };`$i++};
    Set-Content -Path `$CheminActSetVBS -Value `$dataString;"
}

# --------------------------------------- Partie Favoris Building ---------------------------------------



#if( Get-Item `$TestFolderRATPPKGAPPS -ErrorAction Ignore ){ if( (Get-Item `$TestFolderRATPPKGAPPS).GetType().Name -eq 'FileInfo' ){} Remove-Item -Path `$TestFolderRATPPKGAPPS -Recurse }





"#-------------------------------------------------------------------------------------------------------------------------------------#
#                                                        Install (Installation)                                                       #
#-------------------------------------------------------------------------------------------------------------------------------------#

#À mettre dans la première partie : instruction ligne de commande
#KeyInstExec
$MsiExec_Install


#KeyInstLot1
#---------------------------- Lot 1 => OS cible (Partie Reg, ASP) : ALL ----------------------------
# Version AideLanceur-Web : $VersionAideLanceur

`$ErrorActionPreference = `"Continue`";



switch( (Get-CimInstance -ClassName win32_operatingsystem).OSArchitecture ){

    {`$_ -like `"32*`"} {
        `${Reg_AppliType_32} = `$null #Cas où la machine est une 32 et donc toute les applies sont codées en 32 !
        `${appli.ico}=('""${appli.ico}""').Replace(`"(x86)`",'')
        `${appli.ico} = Invoke-Expression `${appli.ico}
    }
    { (`$_ -like `"64*`") -and (`$TypeApplication -eq `"64`") } {
        `${Reg_AppliType_32} = `$null #Cas où la machine est une 64 et donc les applies sont codées en 64 !
        `${appli.ico}=`"${appli.ico}`"
    }
    Default {
        `${Reg_AppliType_32} = `"WOW6432Node\`" #Cas où la machine est une 64 et les applies sont codées en 32 !
        `${appli.ico}=`"${appli.ico}`"
    }
}



Copy-Item `".\Uninstall\${CDCV}_uninstall.ps1`" -Destination `".\${CDCV}_uninstall_ASP.ps1`"
`$Elem = (ls `".\${CDCV}_uninstall_ASP.ps1`"); `$content=Get-Content `$Elem;`$i=0;
1..`$content.Count | ForEach-Object{
    if(`$content[`$i] -like '*/qn*'){`$content[`$i]=`$content[`$i].replace('/qn','/qb');};`$i++;
}; Set-Content `$Elem -Value `$content;

`$TestFolderRATPPKGAPPS=`"`$env:RATPPKGAPPS\$CDCV`"
Move-Item -Path `".\${CDCV}_uninstall_ASP.ps1`" -Destination `"`$TestFolderRATPPKGAPPS\`"



Set-ItemProperty -Path `"HKLM:\SOFTWARE\`${`Reg_AppliType_32}Microsoft\Windows\CurrentVersion\Uninstall\$ProductCode`" -Name UninstallString -Value ('`"'+`"`$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe`"+'`"' + ' -WindowStyle Hidden –ExecutionPolicy Bypass –File ' + '`"'+`"`$env:RATPPKGAPPS\$CDCV\${CDCV}_uninstall_ASP.ps1`"+'`"')
Set-ItemProperty -Path `"HKLM:\SOFTWARE\`${`Reg_AppliType_32}Microsoft\Windows\CurrentVersion\Uninstall\$ProductCode`" -Name WindowsInstaller -Value '0'
New-ItemProperty -Path `"HKLM:\SOFTWARE\`${`Reg_AppliType_32}Microsoft\Windows\CurrentVersion\Uninstall\$ProductCode`" -Name DisplayIcon -Value `"`${appli.ico}`"
#KeyInstLot1Fin

#KeyInstLot2
#---------------------------- Lot 2 => OS cible : W10 (Raccourci) ----------------

`$PatharboRac = `"`$env:ProgramData\Microsoft\Windows\Start Menu\Programs\$arboRac`"
`$Test_PatharboRac = `"`$env:ProgramData\Microsoft\Windows\Start Menu\Programs\`$(`$PatharboRac.Split('\')[-1])`"
if( Get-Item `$Test_PatharboRac -ErrorAction Ignore ){ Remove-Item -Path `$Test_PatharboRac -Recurse }
Move-Item -Path `$PatharboRac -Destination `"`$env:ProgramData\Microsoft\Windows\Start Menu\Programs\`"

Remove-Item `"`$env:ProgramData\Microsoft\Windows\Start Menu\Programs\$RATP_NomRepertoireRac`" -Recurse

$FavorisIE
#KeyInstLot2Fin



#-------------------------------------------------------------------------------------------------------------------------------------#
#                                                      Uninstall (Désinstallation)                                                    #
#-------------------------------------------------------------------------------------------------------------------------------------#

#À mettre dans la première partie : instruction ligne de commande
#KeyUninstExec
$MsiExec_Uninstall

#KeyUninstLot1
#---------------------------- Lot 1 => OS cible : W10 ----------------------------
$Uninstall_RemoveRepertoireRac
#KeyUninstLot1Fin




#-------------------------------------------------------------------------------------------------------------------------------------#
#                                                      LigneDeCommandeInstall.txt                                                     #
#-------------------------------------------------------------------------------------------------------------------------------------#

#KeyCommandetxt
#------------------------------------------ Install ----------------------------
powershell.exe –ExecutionPolicy Bypass –File .\${CDCV}_install.ps1

#------------------------------------------ Uninstall ----------------------------
powershell.exe –ExecutionPolicy Bypass –File .\Uninstall\${CDCV}_uninstall.ps1
#KeyCommandetxtFin" > ".\$NomAideLanceurWeb";



#------------------------------------------------------------------------ Partie Gen File (XML, TXT) ---------------------------------------------------------------------------

if( $CheminPackage -like "*\5_MSI_MST" ){
    #----------------------------------------------------------------------------------------------------------------------------------
    #On copie le modèle xml afin d'instancier un nouveau xml
    $Modele = ".\$NomTemplateXML"
    $NewModeleXML = ".\$NomTemplateReplaceXML"
    Copy-Item -Path $Modele -Destination $NewModeleXML
    $content = Get-Content $NewModeleXML | foreach { $_ -replace "SIT-Replace-RATP_155",$CDCV } 
    Set-Content -Path $NewModeleXML -Value $content

    #On execute le script pour auto alimenter notre fichier xml copié à partir du modèle xml
    . ".\AlimenteXmlAuto.ps1"

    $CommandeTxt > ("$CheminPackage\LigneDeCommandeInstall.txt")

    #On copie notre fichier vers le chemin des binaires
    cd $PSScriptRoot
    if(Get-Item "$CheminPackage\${CDCV}.xml" -ErrorAction Ignore){
        [System.Windows.Forms.MessageBox]::Show("Fichier XML non crée, car il existe !")
    }else{
        Move-Item -Path $NewModeleXML -Destination ("$CheminPackage\")
        Rename-Item -Path ("$CheminPackage\$NomTemplateReplaceXML") -NewName ("$CDCV.xml")
        [System.Windows.Forms.MessageBox]::Show("Fichier XML crée.")
    }
    if(!(Test-Path -Path ("$CheminPackage\Uninstall"))){New-Item -Name "Uninstall" -Path ("$CheminPackage\") -ItemType Directory}
}else{
    [System.Windows.Forms.MessageBox]::Show("Fichier XML non crée, vérifier votre chemin !`n`nexemple de chemin :`n\\sa-pacmat1.info.ratp\pkg$\Qual\Applications\_PACKAGING_R\MonAppli\_Version\_1\5_MSI_MST ","Error",0,48)
}