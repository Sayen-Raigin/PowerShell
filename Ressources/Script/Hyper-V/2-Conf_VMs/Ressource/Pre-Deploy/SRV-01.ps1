$Name = 'SRV-01';
$IP = '192.168.8.1';
$Mask = '24';
$Gateway = '192.168.8.254';
$Ethernet = 'Ethernet';
$DNS_Server='192.168.8.1';
#$SuffixeDNS= 'aston.local';
$Roles='AD-Domain-Services','*dns*','*dhcp*';




Get-NetIPInterface -AddressFamily IPv4 | Remove-NetIPAddress;Start-Sleep(1);
#---------- Attribution des adresses IP -----------------------------
New-NetIPAddress -InterfaceAlias $Ethernet -IPAddress $IP -PrefixLength $Mask -DefaultGateway $Gateway;


Set-DnsClientServerAddress -InterfaceAlias $Ethernet -ServerAddresses $DNS_Server;
#Set-DnsClient -InterfaceAlias $Ethernet -ConnectionSpecificSuffix $SuffixeDNS;



#---------- Disabled firewall rule ICMP -----------------------------
Enable-NetFirewallRule -Name "*ERQ-In";
Get-NetFirewallRule -Enabled True -Direction Inbound | Set-NetFirewallRule -Profile Any;



#----------Renommage de la machine-----------------------------------
Rename-Computer -NewName $Name -Force;



#----------Roles-----------------------------------------------------
Get-WindowsFeature -Name $Roles | Install-WindowsFeature -IncludeManagementTools;



#------------------- Other ------------------------------------------
$Path_Desktop = "C:\Users\$env:USERNAME\Desktop";
Copy-Item 'C:\backinfo' -Recurse -Destination $Path_Desktop;
Start-Process -FilePath "$Path_Desktop\backinfo\BackInfo.exe";
Read-Host 'Appuis sur entrée pour continuer';
restart-computer -force;