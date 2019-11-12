$NameRegKeyAppli = $PSCommandPath.Split("\")[-1]
$PathRegKeyAppli = "HKCU:\$NameRegKeyAppli"

if( Get-Item $PathRegKeyAppli -ErrorAction Ignore ){
    
    
    $ie = New-Object -COMObject InternetExplorer.Application
    $ie.visible = $true
    

    $ie.Navigate( 'https://lap.info.ratp/' );
    while($ie.busy){Start-Sleep 1} #Attente du chargement de la page Web

    $ie.Navigate( "https://lap.info.ratp/Poste/InfoPa?value=$env:COMPUTERNAME" );
    while($ie.busy){Start-Sleep 1} #Attente du chargement de la page Web
    
    <#
    ($ie.Document.IHTMLDocument3_getElementsByTagName('input') | Where-Object -Property 'id' -eq 'cherc').value = $env:COMPUTERNAME
    while($ie.busy){Start-Sleep 1} #Attente du chargement de la page Web

    ($ie.Document.IHTMLDocument3_getElementsByTagName('button') | Where-Object -Property 'id' -eq 'PosteCher').click()
    while($ie.busy){Start-Sleep 1} #Attente du chargement de la page Web
    #>
    Start-Sleep 3
    $MdpInnerText = ($ie.Document.IHTMLDocument3_getElementsByTagName('tr') | Where-Object -Property 'innerText' -like '*Mot de passe administrateur local *').innerText.split(':')[-1]

    $MdpTab = @()
    $i=0;
    0..$MdpInnerText.Length | ForEach-Object{
        if( ($MdpInnerText[$i] -match '[a-z]') -or ($MdpInnerText[$i] -match '[0-9]') ){ $MdpTab += $MdpInnerText[$i]}
        $i++
    }

    $MdpinLaps = $MdpTab -join ''

    $ie.Quit()

    $Login="$env:COMPUTERNAME\Administrateur"
    $cred = new-object -typename System.Management.Automation.PSCredential -ArgumentList $Login, $($MdpinLaps | ConvertTo-SecureString -AsPlainText -Force);

    Start-Process powershell.exe -Credential $cred -NoNewWindow -ArgumentList (
        "Add-LocalGroupMember -Group Administrateurs -Member $env:USERNAME;
        if(`$Error[0] -ne `$null){ `$Error[0] > 'C:\Users\$env:USERNAME\Desktop\Error_Be_ADM.txt'}; logoff.exe"
    ) -PassThru;

    Remove-Item $PathRegKeyAppli

}else{
    
    $p=Start-Process powershell "& {$PSCommandPath}" -Verb runas -PassThru

    if($p){
        New-Item -Path "HKCU:" -Name $NameRegKeyAppli
    }
}


