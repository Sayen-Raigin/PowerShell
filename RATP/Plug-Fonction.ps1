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


function Convert-GuidToCompressedGuid {
	[CmdletBinding()]
	[OutputType()]
	param (
		[Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Mandatory)]
		[string]$Guid
	)
	begin {
		$Guid = $Guid.Replace('-', '').Replace('{', '').Replace('}', '')
	}
	process {
		try {
			$Groups = @(
				$Guid.Substring(0, 8).ToCharArray(),
				$Guid.Substring(8, 4).ToCharArray(),
				$Guid.Substring(12, 4).ToCharArray(),
				$Guid.Substring(16, 16).ToCharArray()
			)
			$Groups[0..2] | foreach {
				[array]::Reverse($_)
			}
			$CompressedGuid = ($Groups[0..2] | foreach { $_ -join '' }) -join ''
			
			$chararr = $Groups[3]
			for ($i = 0; $i -lt $chararr.count; $i++) {
				if (($i % 2) -eq 0) {
					$CompressedGuid += ($chararr[$i+1] + $chararr[$i]) -join ''
				}
			}
			$CompressedGuid
		} catch {
			Write-Error $_.Exception.Message	
		}
	}
}


function Sit-unzip{

    param($SourceCompress,$DestinationPath)
    [Reflection.Assembly]::LoadWithPartialName( "System.IO.Compression.FileSystem" )
    [System.IO.Compression.ZipFile]::ExtractToDirectory($SourceCompress, $DestinationPath)

    #Exemple : Sit-unzip -SourceCompress "C:\Users\g23004\Desktop\t.zip" -DestinationPath "C:\Users\g23004\Desktop\"
}

<# ---------------------- ---------------------- ---------------------- OLD ---------------------- ---------------------- ----------------------


function Get-MSIProperty{

    param( [string]$PathBinaire, [string]$MSI_Name, [string]$MST_Name, [string]$Property, [switch]$Exemple, [switch]$Debug  )



    #----------- Suppression des "" (cela plante la methode invokemember !) -----------
    
    $PathBinaire=$PathBinaire.Replace('"','');

    # si le chemin a pour dernier charactère un '\', alors on le supprime !
    if( ($PathBinaire.Length -1) -eq $PathBinaire.lastindexOf('\')){ 
        $PathBinaire=$PathBinaire.Remove( $PathBinaire.lastindexOf('\') )
    }
    
    $MSI_Name = $MSI_Name.Replace('"','')
    $MST_Name = $MST_Name.Replace('"','')

    #----------------------------------------------------------------------------------


    $MSI = (ls ($PathBinaire+"\$MSI_Name.msi") ).FullName
    $MST = (ls ($PathBinaire+"\$MST_Name.mst") ).FullName

    $WindowsInstaller = New-Object -ComObject WindowsInstaller.Installer

    $msiOpenDatabaseModeReadOnly = 0
    $msiTransformErrorViewTransform = 5

    if( !$Debug -and !$Exemple -and ( ($MSI -ne $null) -or ($MST -ne $null ) ) ){

        $MSIDatabase = $WindowsInstaller.GetType().InvokeMember("OpenDatabase", "InvokeMethod", $null, $WindowsInstaller, @($MSI,$msiOpenDatabaseModeReadOnly))
        $MSIDatabase.GetType().InvokeMember("ApplyTransform", "InvokeMethod", $null, $MSIDatabase , @($MST, $msiTransformErrorViewTransform))

        $Query = "SELECT Value FROM Property WHERE Property = '$($Property)'"
        $View = $MSIDatabase.GetType().InvokeMember("OpenView", "InvokeMethod", $null, $MSIDatabase, ($Query))
        $View.GetType().InvokeMember("Execute", "InvokeMethod", $null, $View, $null)
        $Record = $View.GetType().InvokeMember("Fetch", "InvokeMethod", $null, $View, $null)
        $Value = $Record.GetType().InvokeMember("StringData", "GetProperty", $null, $Record, 1)

        return $Value
                                                
    }
    if($Exemple){
       return "TypeApplication","ProductCode","ProductName","ProductCDCV"
    }
    if($Debug){
        $ofs="`r`n" # Saut de ligne
        ("Chemin binaire : "+$PathBinaire, "Nom du MSI : "+$MSI_Name, "Nom du MST : "+$MST_Name, "Chemin du MSI : "+$MSI, "Chemin du MSI : "+$MST) | Out-File  ".\debugVar.log"
    }
}

#>