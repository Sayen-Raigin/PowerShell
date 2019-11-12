$User = 'TKORICHI'
$User=  Get-ADUser -Filter { SamAccountName -like $User }
$User = $User.SamAccountName;

$CCIHotes = Get-ADComputer -Filter * | Select-Object -Property Name;
$CCIHotes | ForEach-Object { 

    $UserWMI = Get-WmiObject  -ComputerName  $_.Name -class win32_computersystem | Select-Object UserName
    $UserWMI=$UserWMI.UserName;
    $SamAccountNameWMI = $UserWMI.Remove(0,14);
    
    if($SamAccountNameWMI -eq $User){
        $Station = Get-WmiObject  -ComputerName $_  -class win32_computersystem | Select-Object -Property Name
    }

}