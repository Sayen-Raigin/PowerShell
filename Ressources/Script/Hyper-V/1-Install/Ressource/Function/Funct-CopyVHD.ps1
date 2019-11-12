function Copy-VHD{
    param($VM);

    $Clients = $VMs | Where-Object -Property Name -like 'Cli*';
    $Servers = $VMs | Where-Object -Property Name -like 'SRV*';
    $Routers = $VMs | Where-Object -Property Name -like 'RTR*';
    

    $Clients.Name | ForEach-Object{
        $PathCli= $Path_VHD+'\'+$_+".vhdx";
        Copy-Item $PATH_OSclient -Destination $PathCli;
    };
    $Servers.Name | ForEach-Object{
        $PathSRV= $Path_VHD+'\'+$_+".vhdx";
        Copy-Item $PATH_OSServer -Destination $PathSRV;
    };
    $Routers.Name | ForEach-Object{
        $PathRTR= $Path_VHD+'\'+$_+".vhdx";
        Copy-Item $PATH_OSServer -Destination $PathRTR
    };
}