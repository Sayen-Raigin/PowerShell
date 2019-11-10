#----------------------------------------------- Initialisation des variables et fonction -----------------------------------------------
. "Get-MSIProperty.ps1"

$SrcMsiMst= "$Chemin\5_MSI_MST"
$urllogin = "http://baquaras.info.ratp/applications"

#--------------------------------------------------------------------------------------------
if( ls $SrcMsiMst -ErrorAction Ignore | Where-Object -Property Name -like "*.mst"){
    $CodageAppli = Get-MSIProperty -PathBinaire $SrcMsiMst -MstTrue -Property "TypeApplication"
    $Lettre = Get-MSIProperty -PathBinaire $SrcMsiMst -MstTrue -Property "ProductCDCV";
    $ProductName = Get-MSIProperty -PathBinaire $SrcMsiMst -MstTrue -Property "ProductName";
    $ProductCode = Get-MSIProperty -PathBinaire $SrcMsiMst -MstTrue -Property "ProductCode";
    $CDCV = Get-MSIProperty -PathBinaire $SrcMsiMst -MstTrue -Property "ProductCDCV";
    $TemplateVersion = Get-MSIProperty -PathBinaire $SrcMsiMst -MstTrue -Property "TemplateVersion";
    $Editeur = Get-MSIProperty -PathBinaire $SrcMsiMst -MstTrue -Property "Manufacturer";
    $PackageType = "MSI + MST"
}else{
    $CodageAppli = Get-MSIProperty -PathBinaire $SrcMsiMst -Property "TypeApplication"
    $Lettre = Get-MSIProperty -PathBinaire $SrcMsiMst -Property "ProductCDCV"
    $ProductName = Get-MSIProperty -PathBinaire $SrcMsiMst -Property "ProductName";
    $ProductCode = Get-MSIProperty -PathBinaire $SrcMsiMst -Property "ProductCode";
    $CDCV = Get-MSIProperty -PathBinaire $SrcMsiMst -Property "ProductCDCV";
    $TemplateVersion = Get-MSIProperty -PathBinaire $SrcMsiMst -Property "TemplateVersion";
    $Editeur = Get-MSIProperty -PathBinaire $SrcMsiMst -Property "Manufacturer";
    $PackageType = "MSI"
}
$CodageAppli = ($CodageAppli | Where-Object { $_ -notmatch '^\s*$' })
$Lettre = ($Lettre | Where-Object { $_ -notmatch '^\s*$' })[0]
$ProductName = ($ProductName | Where-Object { $_ -notmatch '^\s*$' })
$ProductCode = ($ProductCode | Where-Object { $_ -notmatch '^\s*$' })
$CDCV= ($CDCV | Where-Object { $_ -notmatch '^\s*$' })
$TemplateVersion = ($TemplateVersion | Where-Object { $_ -notmatch '^\s*$' })
$Editeur = ($Editeur | Where-Object { $_ -notmatch '^\s*$' })
#--------------------------------------------------------------------------------------------

$NomAppli = $($ProductName.Split(')')[1].Split('(')[0]).Remove(0,1)
$VersionAppli = $($ProductName.Split('')[-1].Split('_')[0])
$Codage_VersionOs = $( "($CodageAppli bits) ($(if( $CodageAppli -eq "64" ){"W7-64 W10-64"}else{"W7-32 W7-64 W10-64"}))" )

$NomAppliComplet =$NomAppli + $Codage_VersionOs
$NomPublication = $($ProductName.Split(')')[1].Split('(')[0]).Remove(0,1) + "$VersionAppli $Codage_VersionOs"

[int]$TaillePackage=0
(ls $SrcMsiMst)|ForEach-Object{
    $_.Length /1MB
    $TaillePackage = $TaillePackage + ($_.Length /1MB)
}

switch ($SrcMsiMst)
{
    { ($(ls $_).Name -like "*.ps1") } {
        $ligneCommande_Install = "powershell.exe -ExecutionPolicy Bypass -File `".\$($CDCV)_install.ps1`""
        $ligneCommande_Uninstall = "powershell.exe -ExecutionPolicy Bypass -File `".\Uninstall\$($CDCV)_uninstall.ps1`""
    }
    { !($(ls $_).Name -like "*.ps1") -and !($(ls $_).Name -like "*.Mst") } {
        $ligneCommande_Install = "msiexec.exe /i `"$($(ls $SrcMsiMst).Name -like "*.msi")`" /qn /norestart /L*V `"%RATPLOGS%\APPLIS\$($CDCV).log`""
        $ligneCommande_Uninstall = "msiexec.exe /x `"$($ProductCode)`" /qn /norestart /L*V `"%RATPLOGS%\APPLIS\$($CDCV)_DESINSTALL.log`""
    }
    Default{
        $ligneCommande_Install = "msiexec.exe /i `"$($(ls $SrcMsiMst).Name -like "*.msi")`" TRANSFORMS=`"$($(ls $SrcMsiMst).Name -like "*.Mst")`" /qn /norestart /L*V `"%RATPLOGS%\APPLIS\$($CDCV).log`""
        $ligneCommande_Uninstall = "msiexec.exe /x `"$($ProductCode)`" /qn /norestart /L*V `"%RATPLOGS%\APPLIS\$($CDCV)_DESINSTALL.log`""
    }
}

$Champ = @{
    "input"="baquaras_testbundle_application_nom|$NomAppliComplet","baquaras_testbundle_application_editeur|$Editeur","baquaras_testbundle_application_version|$VersionAppli",
            "baquaras_testbundle_application_correctifQualif|1","baquaras_testbundle_application_codeConvergence|$CDCV","baquaras_testbundle_application_packages_0_nom|$ProductName",
            "baquaras_testbundle_application_packages_0_nomPublication|$NomPublication","baquaras_testbundle_application_packages_0_taille|$TaillePackage","baquaras_testbundle_application_packages_0_chemin|  ICI  ",
            "baquaras_testbundle_application_packages_0_productCode|$ProductCode","baquaras_testbundle_application_packages_0_ligneCommandePublication|$ligneCommande_Install","baquaras_testbundle_application_packages_0_ligneCommandeTeledistribution|$ligneCommande_Uninstall";


    "textarea"="baquaras_testbundle_application_description";


    "select"="baquaras_testbundle_application_packages_0_type|$PackageType","baquaras_testbundle_application_packages_0_versionOutilPackaging|AdminStudio 2013",
             "baquaras_testbundle_application_packages_0_versionTemplate|$TemplateVersion",
             "baquaras_testbundle_application_status|Pré-production",
             "baquaras_testbundle_application_type|Métier",

             "baquaras_testbundle_application_packages_0_qualification_dateDemarragePackaging_day|$(if( (Get-Item -Path "$SrcMsiMst\..\").LastWriteTime.Day -ge '10' ){ (Get-Item -Path "$SrcMsiMst\..\").LastWriteTime.Day }else{'0'+(Get-Item -Path "$SrcMsiMst\..\").LastWriteTime.Day })",
             "baquaras_testbundle_application_packages_0_qualification_dateDemarragePackaging_month|$(if( (Get-Item -Path "$SrcMsiMst\..\").LastWriteTime.Month -ge '10' ){ (Get-Item -Path "$SrcMsiMst\..\").LastWriteTime.Month }else{'0'+(Get-Item -Path "$SrcMsiMst\..\").LastWriteTime.Month })",
             "baquaras_testbundle_application_packages_0_qualification_dateDemarragePackaging_year|$(if( (Get-Item -Path "$SrcMsiMst\..\").LastWriteTime.Year -ge '10' ){ (Get-Item -Path "$SrcMsiMst\..\").LastWriteTime.Year }else{'0'+(Get-Item -Path "$SrcMsiMst\..\").LastWriteTime.Year })",

             "baquaras_testbundle_application_packages_0_qualification_datePVQualification_day|$(if( (Get-Date).Day -ge '10' ){ (Get-Date).Day }else{'0'+(Get-Date).Day })",
             "baquaras_testbundle_application_packages_0_qualification_datePVQualification_month|$(if( (Get-Date).Month -ge '10' ){ (Get-Date).Month }else{'0'+(Get-Date).Month })",
             "baquaras_testbundle_application_packages_0_qualification_datePVQualification_year|$(if( (Get-Date).Year -ge '10' ){ (Get-Date).Year }else{'0'+(Get-Date).Year })"
}
#----------------------------------------------- Initialisation des variables et fonction -----------------------------------------------


$ie = New-Object -COMObject InternetExplorer.Application
$ie.visible = $true

$ie.Navigate($urllogin);
Load-object -Object $ie -SymboleLoad "=Nav1> " #Attente du chargement de la page Web



#--------------------- Partie authentification ----------------------------------------------
( $ie.Document.IHTMLDocument3_getElementsByTagName('a') | Where-Object -Property 'outerHTML' -like "*dentifier*" ).click()
Load-object -Object $ie -SymboleLoad "=S'identifier> " #Attente du chargement de la page Web


if( !( $ie.Document.IHTMLDocument3_getElementsByTagName('div') | Where-Object -Property "outerHTML" -like "<div style=*>*Bonjour*" ).outerHTML ){

    ( $ie.Document.IHTMLDocument3_getElementsByTagName('input') | Where-Object -Property 'id' -like "login" ).value = $Login
    ( $ie.Document.IHTMLDocument3_getElementsByTagName('input') | Where-Object -Property 'id' -like "password" ).value = $Password
    ( $ie.Document.IHTMLDocument3_getElementsByTagName('input') | Where-Object -Property 'outerHTML' -like '*identifier*' ).click()
    Load-object -Object $ie -SymboleLoad "=Authentification> " #Attente du chargement de la page Web
}
#--------------------------------------------------------------------------------------------



if($Lettre -notmatch "[a-z]" ){$ie.Navigate("http://baquaras.info.ratp/applications/lettre/@")}else{$ie.Navigate("http://baquaras.info.ratp/applications/lettre/$Lettre")}
Load-object -Object $ie -SymboleLoad "=Nav2> " #Attente du chargement de la page Web

( $ie.Document.IHTMLDocument3_getElementsByTagName('a') | Where-Object -Property 'href' -like "http://baquaras.info.ratp/application/*" ) | % {
    if($_.innerText -like "*$($ProductName.Split(" ")[1])*"){
        $urllogin = $_.href;
        $urlloginSplit =  $urllogin.Split("/")
        $urlloginSplit[4]  = "edit/$($urlloginSplit[4])"
        $urllogin = $urlloginSplit -join "/"
    }
}

$ie.Navigate($urllogin);
Load-object -Object $ie -SymboleLoad "=Nav3> " #Attente du chargement de la page Web




if($CodageAppli -eq '32'){$i=1}else{$i=2}
($ie.Document.IHTMLDocument3_getElementsByTagName('input') | Where-Object -Property 'id' -eq "baquaras_testbundle_application_codage_$i").checked = $true

#Validé sur OS (100 => W10-64  ; 39 W7-32; 51 W7-32 et 64 ; 50 W7-64)
( ($ie.Document.IHTMLDocument3_getElementsByTagName('input')) | Where-Object -Property 'id' -like "baquaras_testbundle_application_oscible_51" ).checked = $true

# Justifie un OS 64 bits (1 Oui, 2 Non et 3  Dérogation)
( $ie.Document.IHTMLDocument3_getElementsByTagName('input') | Where-Object -Property 'id' -eq 'baquaras_testbundle_application_justifieos_2' ).checked = $true



$Champ.input | %{
    ($ie.Document.IHTMLDocument3_getElementsByTagName('input') | Where-Object -Property 'id' -eq $_.Split("|")[0]).value = $_.Split("|")[1]
}; Write-Host ""
$Champ.textarea | %{
    ($ie.Document.IHTMLDocument3_getElementsByTagName('textarea') | Where-Object -Property 'id' -eq $_).value = "TextArea"
}
$Champ.select | %{
    $SelectedNumber = (($ie.Document.IHTMLDocument3_getElementsByTagName('select') | Where-Object -Property 'id' -eq $_.Split("|")[0]) | Where-Object -Property "outerText" -eq $_.Split("|")[1]).value
    ($ie.Document.IHTMLDocument3_getElementsByTagName('select') | Where-Object -Property 'id' -eq $_.Split("|")[0]).value = $SelectedNumber
}