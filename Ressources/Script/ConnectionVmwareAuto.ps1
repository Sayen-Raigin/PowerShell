Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();

[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'
function Hide-Console
{
    $consolePtr = [Console.Window]::GetConsoleWindow()
    #0 hide
    [Console.Window]::ShowWindow($consolePtr, 0)
}
Hide-Console
while((Get-Process -Name chromedriver -ErrorAction Ignore)){ (Get-Process -Name chromedriver -ErrorAction Ignore)| Stop-Process }



$Pathroot='C:\Temp'
$PathDirectory=($Pathroot+'\Selenium');
Add-Type -Path ("$PathDirectory\Selenium.WebDriverBackedSelenium.dll")
Add-Type -Path ("$PathDirectory\ThoughtWorks.Selenium.Core.dll")
Add-Type -Path ("$PathDirectory\WebDriver.dll")
Add-Type -Path ("$PathDirectory\WebDriver.Support.dll");


Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = '343,183'
$Form.text                       = "Form"
$Form.TopMost                    = $false

$URLUser                         = New-Object system.Windows.Forms.TextBox
$URLUser.multiline               = $false
$URLUser.width                   = 246
$URLUser.height                  = 20
$URLUser.location                = New-Object System.Drawing.Point(42,51)
$URLUser.Font                    = 'Microsoft Sans Serif,10'
$URLUser.text                    = 'URL de votre Dossier';

$MDP                             = New-Object system.Windows.Forms.TextBox
$MDP.multiline                   = $false
$MDP.width                       = 246
$MDP.height                      = 20
$MDP.location                    = New-Object System.Drawing.Point(42,($URLUser.location.y + 35))
$MDP.Font                        = 'Microsoft Sans Serif,10'
$MDP.text                        = 'mot de passe';


$Form.controls.AddRange(@($URLUser,$MDP))




    

$path_Absolut = 'HKCU:\';
$Name_CSPKey = 'CSP_Script'
$path_CSP = ('HKCU:\'+$Name_CSPKey+'\');
$Name_ScriptKey = 'Run-Auto-ConnectionVmware';
$path_regkey = $path_CSP+$Name_ScriptKey;
$chaineVmware='VmWare-login';$chaineUrl='VmWare-Url' ;




$password =(Get-ItemProperty -Path $path_regKey -Name $chaineVmware).$chaineVmware
$UrlUser =(Get-ItemProperty -Path $path_regKey -Name $chaineUrl).$chaineUrl


$DecodedText = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($password))
$username=($env:USERNAME+'@'+$env:USERDNSDOMAIN)

[Reflection.Assembly]::LoadFile("C:\Users\x2019308\Desktop\RessourceHoussam\PShell\_Script\Project\_Logware\ConnectionChrome\Selenium\WebDriver.dll")
$chrome = New-Object OpenQA.Selenium.Chrome.ChromeDriver

$chrome.Navigate().GoToUrl('https://csmsrvvct01.csm.logware.fr/')
    
$Demarrage = $chrome.FindElementsByLinkText('vSphere Client (HTML5) - fonctionnalité partielle')
$Demarrage.Click()
while( $chrome.Url -notlike '*websso*'){sleep(1)}

$Login = $chrome.FindElementById('username')
$mdp = $chrome.FindElementById('password')
$connexion = $chrome.FindElementById('submit')

$Login.SendKeys($username)
$mdp.SendKeys($DecodedText)
$connexion.Click()
while( $chrome.Url -notlike '*/ui/*'){sleep(1)}
    
$chrome.Navigate().GoToUrl($Urluser)

$checkpowershell = (Get-Process powershell -ErrorAction Ignore)
if($checkpowershell){ $checkpowershell| Stop-Process }