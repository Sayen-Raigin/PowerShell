function Get-MSIProperty{

    param( [string]$PathBinaire, [string]$Property, [string]$QuerySQL, [switch]$MstTrue, [switch]$Exemple, [switch]$Debug  )

    $ofs="`r`n" # Saut de ligne
    

    #----------- Suppression des " (cela plante la methode invokeMethod !) -----------
    
    $PathBinaire=$PathBinaire.Replace('"','');
    # si le chemin a pour dernier charactère un '\', alors on le supprime !
    if( ($PathBinaire.Length -1) -eq $PathBinaire.lastindexOf('\')){ 
        $PathBinaire=$PathBinaire.Remove( $PathBinaire.lastindexOf('\') )
    }
    #----------------------------------------------------------------------------------

    $MSI = (ls ($PathBinaire) -Filter "*.msi")
    $MST = (ls ($PathBinaire) -Filter "*.mst")

    if( ($MSI.count -gt 1) -or ($MST.count -gt 1) ){
        cls
        Write-Host ("Il y a "+$MSI.count+" MSI")
        Write-Host ("Il y a "+$MST.count+" MST"); Write-Host ""
        Write-Host "Cette fonction ne gère pas plusieurs MSI ou/et MST" -ForegroundColor Green; Write-Host ""; Write-Host ""
    }elseif( ($MSI -ne $null) -or ($MST -ne $null ) ){

        if( !$Debug -and !$Exemple ){

            $WindowsInstaller = New-Object -ComObject WindowsInstaller.Installer
            $msiOpenDatabaseModeReadOnly = 0
            $msiTransformErrorViewTransform = 5

            $MSIDatabase = $WindowsInstaller.GetType().InvokeMember("OpenDatabase", "InvokeMethod", $null, $WindowsInstaller, @($MSI.FullName,$msiOpenDatabaseModeReadOnly))

            if($MstTrue){
                $MSIDatabase.GetType().InvokeMember("ApplyTransform", "InvokeMethod", $null, $MSIDatabase , @($MST.FullName, $msiTransformErrorViewTransform))                    
            }

            if($QuerySQL){
                $Query = $QuerySQL
            }else{
                $Query = "SELECT Value FROM Property WHERE Property = '$Property'"
            }
            $View = $MSIDatabase.GetType().InvokeMember("OpenView", "InvokeMethod", $null, $MSIDatabase, ($Query))
            $View.GetType().InvokeMember("Execute", "InvokeMethod", $null, $View, $null)
            $Record = $View.GetType().InvokeMember("Fetch", "InvokeMethod", $null, $View, $null)
            $Value = $Record.GetType().InvokeMember("StringData", "GetProperty", $null, $Record, 1)
            return $Value
        }

    }
    if($Exemple -and !$Debug){
       Write-Host "Les Propriétes attendus exemple : TypeApplication, ProductCode, ProductName, ProductCDCV, ...";Write-Host ""
       Write-Host "Exemple : $ofs`Get-MSIProperty -PathBinaire C:\Users\x1535308\Desktop -Property ProductCDCV -MstTrue";Write-Host ""
       Write-Host "-MstTrue : Ce paramètre ne sert uniquement, si vous souhaitez appliquer un MST sur le MSI";Write-Host "";
       Write-Host "-QuerySQL : Ce paramètre ne sert uniquement, si vous souhaitez ajouter une requête SQL personalliser et donc interroger une autre table que la table Property !";
       Write-Host "=> `"SELECT Directory FROM Directory WHERE Directory_Parent = 'ProgramFilesFolder'`""
    }
    if($Debug -and !$Exemple){
        ("Nom du MSI : "+$MSI.Name, "Nom du MST : "+$MST.Name, "Chemin du MSI : "+$MSI.FullName, "Chemin du MST : "+$MST.FullName) | Out-File  ".\Debug_Get-MSIProperty.log"
    }
}