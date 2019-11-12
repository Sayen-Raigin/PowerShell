function ChoiceMAchine{
    param ($FileSRV);
    $Tab = New-Object System.Collections.Generic.List[object];
    $label.Text =  "Choisir le SERVEUR de fichier parmi la liste proposé : ?";
    $i = 0;
    $FileSRV| ForEach-Object{
        $i++;
        [string]$Number = $i;
        $Number = $Number+'=>'+$_.SRV+'('+$_.OS+'[Port:'+$_.Port+'])';
        [void]$ListBox.Items.Add($Number);
    };
    return $Tab;
}


function ValidSRV{
    
    [string]$choix = $listBox.SelectedItem[0];
    $Global:Port = $FileSRV[$choix-1].port;
    $Global:PATH = $FileSRV[$choix-1].DossierUser;
    $Global:SRV_Name = $FileSRV[$choix-1].SRV;
    $listBox.Visible = $false;
    $button.Visible = $false;        
    $label.text ="Tentative de connexion vers : "+$SRV_Name;
    #sleep(1);
    $textBox.Visible = $true; 
    $textBox.Clear();
    $ADTOOLS.controls.Add($button2);

    $label.text = "Veuillez-saisir le SGDID";#"M9987791"

    return $SRV_Name,$Port,$PATH
    #----------Methode----------------------------
}

function Entree{
    #----------Attribut---------------------------
    $Name= $textBox.text;

    if ( $Name.Length -eq 8 ){
        $label.text = "Le SGDID est bon !";
        $button2.Visible = $false;
        $password = Get-Content $PATH_Password | ConvertTo-SecureString -AsPlainText -Force;
        $CompteAdmin = "DA\A03GU-XXX002";
        $cred = new-object -typename System.Management.Automation.PSCredential -ArgumentList  $CompteAdmin, $password

        Invoke-Command -ComputerName $SRV_Name -Credential $Cred  -port $Port  -ScriptBlock {
            param($PATH,$Name);

            $RepertoirPersonnel= $PATH+$Name;
            $Account= $env:USERDOMAIN+"\"+ $Name;
          
            #Création du répertoire : 
            New-Item -Path $PATH -Name $Name -ItemType Directory;
            sleep(1);

            #----------------Partie Samba (SMB) : Attribution en Full uniquement pour le user--------------
	        $PATH = $PATH+$Name;
            $Droit=$Name+",FULL"; sleep(1);
            net share $Name=$PATH /Grant:$Droit;

            #----------------Partie NTFS : Attribution en Full pour le user--------------------------------
            Add-NTFSAccess -Path $RepertoirPersonnel -Account $Account -AccessRights FullControl -AccessType Allow;

        } -ArgumentList $PATH,$Name;
    }
    else{
        $label.text = "Le SGDID ne correspond pas à 8 caractères";
    };

}
<#Par défaut, PowerShell utilisera les ports suivants pour la communication (ils sont les mêmes ports que WinRM)
TCP / 5985 = HTTP
TCP / 5986 = HTTPS
Set-Item WSMan:\localhost\Service\EnableCompatibilityHttpListener -Value true
Set-Item WSMan:\localhost\Service\EnableCompatibilityHttpsListener -Value true
telnet $FileSrv 80
#>