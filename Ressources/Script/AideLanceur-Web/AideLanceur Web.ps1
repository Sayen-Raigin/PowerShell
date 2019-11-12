#cd $PSScriptRoot;
$CheminDesRessources = "$PWD\Ressource"
$RessourceIMG = "$CheminDesRessources\IMG"
$NameFilePS1AideLanceur = "$CheminDesRessources\AideLanceur-Web.ps1"
#-------------------------------------------------------------------------------------- FORM -----------------------------------------------------------------------------------

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

#region begin GUI{ 

$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = '475,195'
$Form.text                       = "AideLanceur-Web ($(Get-Content ("Ressource\*Vers*")))"
$Form.TopMost                    = $false
$Form.icon                       = "$RessourceIMG\appli.ico"
$FormImage = [system.drawing.image]::FromFile("$RessourceIMG\Back.jpg")
$Form.BackgroundImage = $FormImage

$Label1                          = New-Object system.Windows.Forms.Label
$Label1.text                     = "Chemin des binaires (..\5_MSI_MST)"
$Label1.AutoSize                 = $true
$Label1.width                    = 25
$Label1.height                   = 10
$Label1.location                 = New-Object System.Drawing.Point(51,42)
$Label1.Font                     = 'Microsoft Sans Serif,10'
$Label1.ForeColor                = "#ffffff"

$TextBox1                        = New-Object system.Windows.Forms.TextBox
$TextBox1.multiline              = $false
$TextBox1.width                  = 387
$TextBox1.height                 = 20
$TextBox1.location               = New-Object System.Drawing.Point(46,64)
$TextBox1.Font                   = 'Microsoft Sans Serif,10'

$Button1                         = New-Object system.Windows.Forms.Button
$Button1.BackColor               = "#ffffff"
$Button1.text                    = "Valider"
$Button1.width                   = 115
$Button1.height                  = 47
$Button1.location                = New-Object System.Drawing.Point(188,118)
$Button1.Font                    = 'Microsoft Sans Serif,10'
$Button1.ForeColor               = ""

$Labels=@('$Label1','$Label2','$Label3','$Label4','$Label1')
$i=1;
$Labels | ForEach-Object{
    $Label = Invoke-Expression $_
    $Colortmp = $Label.BackColor;
    $Label.BackColor = [System.Drawing.Color]::FromArgb(0, $Colortmp.R, $Colortmp.G, $Colortmp.B);
}

$Form.controls.AddRange(@($TextBox1, $Label1, $Button1))

#region gui events {
$Button1.Add_Click({
    #cd $PSScriptRoot;
    cls
    . $NameFilePS1AideLanceur
})
#endregion events }

[void]$Form.ShowDialog()

<#
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

<#
$Labels=@('$Label1','$Label2','$Label3','$Label4','$Label1')
$i=1;
$Labels | ForEach-Object{
    $Label = Invoke-Expression $_
    $Colortmp = $Label.BackColor;
    $Label.BackColor = [System.Drawing.Color]::FromArgb(0, $Colortmp.R, $Colortmp.G, $Colortmp.B);
}
#>