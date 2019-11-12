Cd \;cls;#gip | fl InterfaceAlias,IPv4Address
$Name='RTR-02'
#---------------------------Interface--------------------------------------
#Interface d'usine
$NetAdapter1='Ethernet';
$NetAdapter2='Ethernet 2';

#Interface Réseau
$Wan = 'WAN';
$BouLan='Bou-LAN';


#-------------------Config TCP/IP------------------------------------------
#Adresse IP
$IPWan='192.168.255.128';
$IPBouLan='192.168.128.254';

$Aston='fdae:0709:2017:';
$IPWan6=($Aston+'ffff::9200');
$IPBouLan6=($Aston+'9201::254');

$Mask='24';
$Mask6='64';


#Adresse SRV
$DNS_Server='192.168.8.1';
$DHCP_Server='192.168.8.1';

$DNS_Server6=($Aston+'9400::1');
$DHCP_Server6=($Aston+'9400::1');

$SuffixeDNS= 'aston.local';


#Passerelle
$Gateway_Default= '192.168.255.254';
$Gateway= '192.168.255.8';

$Gateway_Default6=($Aston+'ffff::254');
$Gateway6=($Aston+'ffff::9400');

#Route
$DestinationPrefix= '192.168.8.0/21';
$DestinationPrefix6= ($Aston+'9400::/56');





#----------Renommage des interfaces ---------------------------------------
Rename-NetAdapter -Name $NetAdapter1 -NewName $Wan;
Rename-NetAdapter -Name $NetAdapter2 -NewName $BouLan;
#netsh interface set interface "Ethernet"    newname="WAN";

Get-NetIPInterface -AddressFamily IPv4 | Remove-NetIPAddress;
Get-NetIPInterface -AddressFamily IPv6 | Remove-NetIPAddress;Start-Sleep(1);

#--------- Attribution des adresses IP -----------------------------------
New-NetIPAddress -AddressFamily IPv4 -InterfaceAlias $Wan -IPAddress $IPWan -PrefixLength $Mask;
New-NetIPAddress -AddressFamily IPv4 -InterfaceAlias $BouLan -IPAddress $IPBouLan -PrefixLength $Mask;
#netsh interface ipv4 	set address "WAN"          static  192.168.1.253/24;

New-NetIPAddress -AddressFamily IPv6 -InterfaceAlias $Wan -IPAddress $IPWan6 -PrefixLength $Mask6;
New-NetIPAddress -AddressFamily IPv6 -InterfaceAlias $BouLan -IPAddress $IPBouLan6 -PrefixLength $Mask6;

Set-DnsClientServerAddress -InterfaceAlias $Wan -ServerAddresses $DNS_Server;
Set-DnsClient -InterfaceAlias $Wan -ConnectionSpecificSuffix $SuffixeDNS;

Set-DnsClientServerAddress -InterfaceAlias $Wan -ServerAddresses $DNS_Server6;
Set-DnsClient -InterfaceAlias $Wan -ConnectionSpecificSuffix $SuffixeDNS6;

#----------Forwarding ------------------------------------------------------
#Pour IPV6 si l'agent dhcp est installé, il s'active auto.
netsh interface ipv4 set interface $Wan forwarding=enabled;
netsh interface ipv4 set interface $BouLan forwarding=enabled;


#---------- Ajout des routes -----------------------------------------------
New-NetRoute –DestinationPrefix "0.0.0.0/0"   -InterfaceAlias $Wan –NextHop $Gateway_Default;
New-NetRoute –DestinationPrefix $DestinationPrefix -InterfaceAlias $Wan –NextHop $Gateway;

New-NetRoute -AddressFamily IPv6 –DestinationPrefix '::0/0' -InterfaceAlias $Wan –NextHop $Gateway_Default6;
New-NetRoute -AddressFamily IPv6 –DestinationPrefix $DestinationPrefix6 -InterfaceAlias $Wan –NextHop $Gateway6;


#---------- Disabled firewall rule ICMP ------------------------------------
Enable-NetFirewallRule -Name "*ERQ-In";
Get-NetFirewallRule -Enabled True -Direction Inbound | Set-NetFirewallRule -Profile Any;



#-----------------NAT------------------------------------------------
Get-WindowsFeature -Name '*rout*' | Install-WindowsFeature -IncludeManagementTools;



#----------Renommage de la machine-----------------------------------
Rename-Computer -NewName $Name -Confirm;



#----------Other-----------------------------------------------------
$Path_Desktop = "C:\Users\$env:USERNAME\Desktop";
Copy-Item 'C:\backinfo' -Recurse -Destination $Path_Desktop;
Start-Process -FilePath "$Path_Desktop\backinfo\BackInfo.exe";
Read-Host 'Appuis sur entrée pour continuer';
restart-computer -force;