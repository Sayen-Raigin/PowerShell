Cd \;cls;#gip | fl InterfaceAlias,IPv4Address
$Name='RTR-01'
#---------------------------Interface--------------------------------------
#Interface d'usine
$NetAdapter1='Ethernet';
$NetAdapter2='Ethernet 2';
$NetAdapter3='Ethernet 3';

#Interface Réseau
$Wan = 'WAN';
$Arc1='Arc-Cli';
$Arc2= 'Arc-SRV';

#-------------------Config TCP/IP------------------------------------------
#Adresse IP
$IPWan='192.168.255.8';
$IPCli='192.168.12.254';
$IPSRV='192.168.8.254';

$Aston='fdae:0709:2017:';
$IPWan6=($Aston+'ffff::9400');
$IPCli6=($Aston+'9420::254');
$IPSRV6=($Aston+'9410::254');

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
$Gateway= '192.168.255.128';

$Gateway_Default6= ($Aston+'ffff::254');
$Gateway6= ($Aston+'ffff::9200');


#Route
$DestinationPrefix= '192.168.128.0/24';
$DestinationPrefix6= ($Aston+'9200::/56');



#----------Renommage des interfaces ---------------------------------------
Rename-NetAdapter -Name $NetAdapter3 -NewName $Wan;
Rename-NetAdapter -Name $NetAdapter2 -NewName $Arc1;
Rename-NetAdapter -Name $NetAdapter1 -NewName $Arc2;
#netsh interface set interface "Ethernet"    newname="WAN";

Get-NetIPInterface -AddressFamily IPv4 | Remove-NetIPAddress;
Get-NetIPInterface -AddressFamily IPv6 | Remove-NetIPAddress;Start-Sleep(1);

#--------- Attribution des adresses IP -----------------------------------
New-NetIPAddress -AddressFamily IPv4 -InterfaceAlias $Wan  -IPAddress $IPWan -PrefixLength $Mask;
New-NetIPAddress -AddressFamily IPv4 -InterfaceAlias $Arc1 -IPAddress $IPCli -PrefixLength $Mask;
New-NetIPAddress -AddressFamily IPv4 -InterfaceAlias $Arc2 -IPAddress $IPSRV -PrefixLength $Mask;
#netsh interface ipv4 	set address "WAN"          static  192.168.1.253/24;

New-NetIPAddress -AddressFamily IPv6 -InterfaceAlias $Wan  -IPAddress $IPWan6 -PrefixLength $Mask6;
New-NetIPAddress -AddressFamily IPv6 -InterfaceAlias $Arc1 -IPAddress $IPCli6 -PrefixLength $Mask6;
New-NetIPAddress -AddressFamily IPv6 -InterfaceAlias $Arc2 -IPAddress $IPSRV6 -PrefixLength $Mask6;


Set-DnsClientServerAddress -InterfaceAlias $Arc2 -ServerAddresses $DNS_Server;
Set-DnsClient -InterfaceAlias $Arc2 -ConnectionSpecificSuffix $SuffixeDNS;

Set-DnsClientServerAddress -InterfaceAlias $Arc2 -ServerAddresses $DNS_Server6;
Set-DnsClient -InterfaceAlias $Arc2 -ConnectionSpecificSuffix $SuffixeDNS6;


#---------- Forwarding ------------------------------------------------------
#Pour IPV6 si l'agent dhcp est installé, il s'active auto.
netsh interface ipv4 set interface $Wan forwarding=enabled;
netsh interface ipv4 set interface $Arc1 forwarding=enabled;
netsh interface ipv4 set interface $Arc2 forwarding=enabled;



#---------- Ajout des routes -----------------------------------------------
New-NetRoute –DestinationPrefix '0.0.0.0/0'   -InterfaceAlias $Wan –NextHop $Gateway_Default;
New-NetRoute –DestinationPrefix $DestinationPrefix -InterfaceAlias $Wan –NextHop $Gateway;
#route add -p 0.0.0.0/0 192.168.1.254;

New-NetRoute -AddressFamily IPv6 –DestinationPrefix '::0/0' -InterfaceAlias $Wan –NextHop $Gateway_Default6;
New-NetRoute -AddressFamily IPv6 –DestinationPrefix $DestinationPrefix6 -InterfaceAlias $Wan –NextHop $Gateway6;

#---------- Disabled firewall rule ICMP ------------------------------------
Enable-NetFirewallRule -Name "*ERQ-In";
Get-NetFirewallRule -Enabled True -Direction Inbound | Set-NetFirewallRule -Profile Any;



#-----------------Routing------------------------------------------------
Get-WindowsFeature -Name '*rout*' | Install-WindowsFeature -IncludeManagementTools;

#Activer le service Routage d'accès à distance
<#Set-Service RemoteAccess -StartupType Automatic
Start-Service RemoteAccess

netsh routing ip relay install;
netsh routing ip relay add dhcpserver $DHCP_Server;
netsh routing ip relay add interface name=$Arc1;
netsh routing ip relay set interface name=$Arc1 minsecs=0;#>


#----------Renommage de la machine-----------------------------------
Rename-Computer -NewName $Name -Confirm;


#----------Other-----------------------------------------------------
$Path_Desktop = "C:\Users\$env:USERNAME\Desktop";
Copy-Item 'C:\backinfo' -Recurse -Destination $Path_Desktop;
Start-Process -FilePath "$Path_Desktop\backinfo\BackInfo.exe";
Read-Host 'Appuis sur entrée pour continuer';
restart-computer -force;