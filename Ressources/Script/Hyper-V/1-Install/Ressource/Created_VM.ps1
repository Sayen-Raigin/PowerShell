#---------------------------------- Déclarartion des variables ------------------------------------------------------
#Les variables sont tirées du fichier '_Install.ps1'

#Déclaration des Chemins :
$PATH_OSclient =($Path_VHD+'\'+$W8);
$PATH_OSServer =($Path_VHD+'\'+$W2012);

$Path_Function = ($PSScriptRoot+'\Function');
$Path_CSV= ($PSScriptRoot+'\CSV');

#Intégration des fonctions dans le script
. "$Path_Function\Funct-CopyVHD.ps1";

#Importations du CSV
$VMs = import-csv -Path ($Path_CSV+'\VMs.csv') -Delimiter ';';

#Création des VHD
Copy-VHD -VM $VMs


#---------------------------------- Création des switchs virtuel -------------------------------------------------------

New-VMSwitch -Name $ArcCli -SwitchType Private;
New-VMSwitch -Name $ArcSrv -SwitchType Private;
New-VMSwitch -Name $BouLan -SwitchType Private;
New-VMSwitch -Name $Wan -SwitchType Private;
New-VMSwitch -Name $Externe -SwitchType Private | Set-VMSwitch -NetAdapterName "Ethernet";


#---------------------------------- Création des VMs -------------------------------------------------------------------
sleep(1);

$VMs | foreach{
    
    $VMName = $_.Name;
    $Gen = $_.Generation;
    [int]$VMRam = $_.Ram;
    $RAM = $VMRam * 1MB;
    $Path_VMVHD = ($Path_VHD+'\'+$VMName+".vhdx");
    $Nic=$_.NIC;

    $Network=$_.Network;
    switch ($Network){
        $ArcCli{ $Network = $ArcCli;break}
        $ArcSrv{ $Network = $ArcSrv;break}
        $BouLan{ $Network = $BouLan;break}
        default{ $Network = $Wan;break}
     }

    New-VM -Path $Path_VM -Name $VMName -MemoryStartupBytes $RAM -Generation $Gen -VHDPath $Path_VMVHD;
    Set-vm $VMName -ProcessorCount 2 -DynamicMemory;
    Get-VM -Name $VMName | Get-VMNetworkAdapter | Connect-VMNetworkAdapter -SwitchName $Network;

    #On Ajoute une carte réseaux à une VM si elle doit avoir plus d'une 1 carte
    if($Nic -gt 1){
        #On limite avec 2, la boucle, car les VM ont déjà une carte lors de leur création
        2..$Nic | ForEach-Object{           
            Add-VMNetworkAdapter -VMName $VMName
        }
     }

}