#Lancer en tant qu'adm

cd 'C:/';cls;
$NameTemp='TempProfileUserCCI';
$TempPath = ('C:\Temp');
$UsernameFile='_3900.local';
if($env:USERNAME -notlike 'adm*'){
    New-Item -Path $TempPath -Name $UsernameFile -ItemType File;
    Set-Content -Path ($TempPath+'\'+$UsernameFile) -Value $env:USERNAME;
    Write-Host 'Valeur user fait !' -ForegroundColor Blue;
}else{
    #Write-Host 'Merci de saisir le login du user';$UserName=Read-Host;
    #Write-Host "Suppression des données temporaires, merci de tapper A => 'Yes to all'" -ForegroundColor Cyan;

    $UserName = Get-Content -Path ($TempPath+'\'+$UsernameFile);
    Remove-Item -Path ($TempPath+'\'+$UsernameFile) -Force;
    New-Item -Path ($TempPath+'\') -Name $NameTemp -ItemType Directory;
    Move-Item -Path ('C:\Users\'+$UserName+'\*') -Destination ($TempPath+'\'+$NameTemp+'\') -Recurse -PassThru

    # On fait les tâches autoriser uniquement avec un compte Adm
    Write-Host 'Appuis sur entrée pour supprimer le profile utilisateur' -BackgroundColor DarkGray;
    Read-Host;

    #Suppression du profile utilisateur
    $UserInstance = Get-CimInstance -Class Win32_UserProfile | Where-Object {$_.LocalPath -eq ('C:\Users\'+$UserName)}
    $UserInstance | Remove-CimInstance;

    Write-Host '';Write-Host '';Write-Host 'Processus terminé, appuis sur une touche du clavier pour fermer le programe et la session Windows...' -ForegroundColor Cyan;
    Get-ChildItem -Path $TempPath|Where-Object -Property Name -eq '___DeletProfil_CCI.ps1'|Remove-Item;
    logoff.exe

}

#Move-Item -Path ($TempPath+'\'+$UserName+'\*') -Destination ('C:\Users\'+$UserName+'\');


#[Environment]::SetEnvironmentVariable('___user',$null,'User');
#$NetProfile_Content= ls "\\administratif.sir\dfs$\USERS\CCIR\$env:USERNAME\PROFIL\";
#$LocalProfile_Content= ls "C:\Users\$env:USERNAME";
#Compare-Object -ReferenceObject $LocalProfile_Content -DifferenceObject $NetProfile_Content
#Start-Process powershell.exe -Credential (Get-Credential ($env:USERDNSDOMAIN+'\adm_hmoussaoui') ) -NoNewWindow -ArgumentList ("Start-Process powershell.exe -Verb runAs -ArgumentList {New-Item -Path 'C:\Users\' -Name $TempUser -ItemType Directory}");