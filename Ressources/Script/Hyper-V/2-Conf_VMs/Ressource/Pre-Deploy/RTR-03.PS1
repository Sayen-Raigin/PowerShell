Cd \;cls;#gip | fl InterfaceAlias,IPv4Address
$Name='RTR-03'
#---------------------------Interface--------------------------------------
#Interface d'usine
$NetAdapter1='Ethernet';
$NetAdapter2='Ethernet 2';

#Interface Réseau
$Wan = 'WAN';
$Externe='Externe';

#-------------------Config TCP/IP------------------------------------------
#Adresse IP
$IPWan='192.168.255.254';

$Aston='fdae:0709:2017:';
$IPWan6=($Aston+'ffff::254');

$Mask='24';
$Mask6='64';


#Adresse SRV
$DNS_Server='192.168.8.1';
$DNS_Server6=($Aston+'9400::1');
$SuffixeDNS= 'aston.local';


#Passerelle
$Gateway_Arc= '192.168.255.8';
$Gateway_Bou= '192.168.255.128';

$Gateway_Arc6=($Aston+'ffff::9400');
$Gateway_Bou6=($Aston+'ffff::9200');


#Route
$DestinationPrefix_Arc= '192.168.8.0/21';
$DestinationPrefix_Bou= '192.168.128.0/24';

$DestinationPrefix_Arc6= ($Aston+'9400::/56');
$DestinationPrefix_Bou6= ($Aston+'9200::/56');




#----------Renommage des interfaces ---------------------------------------
Rename-NetAdapter -Name $NetAdapter1 -NewName $Wan;
Rename-NetAdapter -Name $NetAdapter2 -NewName $Externe;
#netsh interface set interface "Ethernet"    newname="WAN";

Get-NetIPInterface -AddressFamily IPv4 | Remove-NetIPAddress;
Get-NetIPInterface -AddressFamily IPv6 | Remove-NetIPAddress;Start-Sleep(1);

#--------- Attribution des adresses IP -----------------------------------
New-NetIPAddress -AddressFamily IPv4 -InterfaceAlias $Wan -IPAddress $IPWan -PrefixLength $Mask;
New-NetIPAddress -AddressFamily IPv6 -InterfaceAlias $Wan -IPAddress $IPWan6 -PrefixLength $Mask6;
#netsh interface ipv4 	set address "WAN"          static  192.168.1.253/24;

Set-NetIPInterface -AddressFamily IPv4 -InterfaceAlias $Externe -Dhcp Enabled;
#Set-NetIPInterface -AddressFamily IPv6 -InterfaceAlias $Externe -Dhcp Enabled;


Set-DnsClientServerAddress -InterfaceAlias $Wan -ServerAddresses $DNS_Server;
Set-DnsClient -InterfaceAlias $Wan -ConnectionSpecificSuffix $SuffixeDNS;

Set-DnsClientServerAddress -InterfaceAlias $Wan -ServerAddresses $DNS_Server6;
Set-DnsClient -InterfaceAlias $Wan -ConnectionSpecificSuffix $SuffixeDNS6;


#----------Forwarding ------------------------------------------------------
netsh interface ipv4 set interface $Wan forwarding=enabled;
netsh interface ipv4 set interface $Externe forwarding=enabled;



#---------- Ajout des routes -----------------------------------------------
#Pour IPV6 si l'agent dhcp est installé, il s'active auto.
New-NetRoute -AddressFamily IPv6 –DestinationPrefix $DestinationPrefix_Arc -InterfaceAlias $Wan –NextHop $Gateway_Arc;
New-NetRoute -AddressFamily IPv6 –DestinationPrefix $DestinationPrefix_Bou -InterfaceAlias $Wan –NextHop $Gateway_Bou;

New-NetRoute -AddressFamily IPv6 –DestinationPrefix $DestinationPrefix_Arc6 -InterfaceAlias $Wan –NextHop $Gateway_Arc6;
New-NetRoute -AddressFamily IPv6 –DestinationPrefix $DestinationPrefix_Bou6 -InterfaceAlias $Wan –NextHop $Gateway_Bou6;

#---------- Disabled firewall rule ICMP ------------------------------------
Enable-NetFirewallRule -Name "*ERQ-In";
Get-NetFirewallRule -Enabled True -Direction Inbound | Set-NetFirewallRule -Profile Any;



#-----------------NAT------------------------------------------------
Get-WindowsFeature -Name '*rout*' | Install-WindowsFeature -IncludeManagementTools;



#-------------------- NAt ------------------------------------------------
netsh routing ip nat add interface name=$Wan mode=private;
netsh routing ip nat add interface name=$Externe mode=full;



#----------Renommage de la machine-----------------------------------
Rename-Computer -NewName $Name -Confirm;



#----------Other-----------------------------------------------------
$Path_Desktop = "C:\Users\$env:USERNAME\Desktop";
Copy-Item 'C:\backinfo' -Recurse -Destination $Path_Desktop;
Start-Process -FilePath "$Path_Desktop\backinfo\BackInfo.exe";
Read-Host 'Appuis sur entrée pour continuer';
restart-computer -force;;