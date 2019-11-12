cls
#---------------------------------------Importation des prérequis----------------------------------------------------------------------
#All Path
$PATH_Absolut = $PSScriptRoot;
$PathFileSRV = $PATH_Absolut+"\Ressource\CSV\FileSRV.csv";
$PATH_Password = $PATH_Absolut+'\Ressource\CSV\mdp.txt' ;

#Path Fonction :
. $PATH_Absolut\Ressource\Function\Function.ps1;

#Instance d'objet :
$FileSRV = Import-Csv -Path $PathFileSRV -Delimiter ";";


#---------------------------------------------------------------------------------------------------
#Windows Form
Add-Type -AssemblyName System.Windows.Forms
$ADTOOLS = New-Object system.Windows.Forms.Form
$ADTOOLS.Text = "AD Tools"
$ADTOOLS.BackColor = "#efefff"
$ADTOOLS.TopMost = $true
$ADTOOLS.Width = 710
$ADTOOLS.Height = 350


#Label de dialogue
$label= New-Object System.Windows.Forms.Label;
$label.Location = New-Object System.Drawing.Point(15,15);
$label.Size = New-Object System.Drawing.Size(350,15);
$label.BackColor = "#ffffff";
$ADTOOLS.controls.Add($label)

#Liste des SRV
$ListBox= New-Object System.Windows.Forms.listBox;
$ListBox.Location = New-Object System.Drawing.Point(15,35);
$ListBox.Size = New-Object System.Drawing.Size(350,150);
$ListBox.BackColor = "#ffffff";
$ListBox.Font = 15;
$ADTOOLS.controls.Add($ListBox);

#Message texte
$textBox= New-Object System.Windows.Forms.TextBox;
$textBox.Location = New-Object System.Drawing.Point(15,35);
$textBox.Size = New-Object System.Drawing.Size(350,150);
$textBox.BackColor = "#ffffff"
$textBox.Font = 15
$textBox.Visible = $false;
$ADTOOLS.controls.Add($textBox)

#Bouton valider
$button = New-Object system.windows.Forms.Button
$button.Text = "Valider"
$button.Width = 100
$button.Height = 30
$button.location = new-object system.drawing.point(15,220)
$button.Font = "Microsoft Sans Serif,10"
$button.Add_Click({ValidSRV})
$ADTOOLS.controls.Add($button)

#Bouton Entrée
$button2 = New-Object system.windows.Forms.Button
$button2.Text = "Entrée"
$button2.Width = 100
$button2.Height = 30
$button2.location = new-object system.drawing.point(15,220)
$button2.Font = "Microsoft Sans Serif,10"
$button2.Add_Click({Entree})


#----------------------------------------------------------------------------------------------------
ChoiceMachine($FileSRV)
[void]$ADTOOLS.ShowDialog()
$ADTOOLS.Dispose()