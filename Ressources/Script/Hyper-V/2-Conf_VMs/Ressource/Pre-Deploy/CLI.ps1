#Modifier
$ComputerNbr='1';
$Name='Cli-0'+$ComputerNbr;
$Ethernet='Ethernet';


#---------- Disabled firewall rule ICMP -----------------------------
#netsh firewall set icmpsetting type=8 profile=CURRENT mode=ENABLE;
Enable-NetFirewallRule -Name "*ERQ-In";

#---------- Attribution des adresses IP -----------------------------
#Set-NetIPInterface -InterfaceAlias $Ethernet -Dhcp Enabled;

#Set-DnsClient -InterfaceAlias $Ethernet -ConnectionSpecificSuffix $Domaine;

#----------Renommage de la machine-----------------------------------
#Rename-Computer -NewName $Name -Force;
#restart-computer -force;