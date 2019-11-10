$urllogin = "http://baquaras.info.ratp/applications"
$Login = 'x2019308'
#Convert your password : $ConvPass = [System.Text.Encoding]::Unicode.GetBytes("tatata"); [Convert]::ToBase64String($ConvPass)
$Password = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String("cBpAG4AZAHQAOQAA585DMANACA"))



if( !(Get-Process | Where-Object { $_.MainWindowHandle -eq $ie.HWND})  ){ 
    $ie = New-Object -COMObject InternetExplorer.Application
    $ie.visible = $true
    $ie.silent = $true
}

$ie.Navigate($urllogin);
while($ie.busy){Start-Sleep 1} #Attente du chargement de la page Web

#--------------------- Partie authentification ----------------------------------------------
( $ie.Document.getElementsByTagName('a') | Where-Object -Property 'outerHTML' -like "*dentifier*" ).click()
while($ie.busy){Start-Sleep 1} #Attente du chargement de la page Web


Read-Host "Pause"

($ie.Document.getElementsByTagName('input') | Where-Object -Property 'id' -like "login").value = $Login
($ie.Document.getElementsByTagName('input') | Where-Object -Property 'id' -like "password").value = $Password
($ie.Document.getElementsByTagName('input') | Where-Object -Property 'outerHTML' -like '*identifier*').click()

while($ie.busy){Start-Sleep 1} #Attente du chargement de la page Web
#--------------------------------------------------------------------------------------------

$Lettre = 'F' ;#$TabCSV.'Nom de l''application'[0]
if($Lettre -notmatch "[a-z]" ){$ie.Navigate("http://baquaras.info.ratp/applications/lettre/@")}else{$ie.Navigate("http://baquaras.info.ratp/applications/lettre/$Lettre")}
while($ie.busy){Start-Sleep 1} #Attente du chargement de la page Web
<#($ie.Document.getElementsByTagName('a') | Where-Object -Property 'outerHTML' -like ('*'+$Table.'Nom de publication'+'*'))
$FocusAppli = ($ie.Document.getElementsByTagName('a') | Where-Object -Property 'outerHTML' -like ('*'+$Table.'Nom de l''application'+'*'))
$FocusAppli = ($FocusAppli | Where-Object -Property "IHTMLElement_innerHTML" -eq $Table.'Nom de l''application').value
($ie.Document.getElementsByTagName('select') | Where-Object -Property 'id' -eq "form_nomListe").value = $FocusAppli
($ie.Document.getElementsByTagName('button') | Where-Object -Property 'id' -eq 'form_save').click()#>
Read-Host ("Cliquer sur modifier dans la ligne du package ("+$TabCSV.'Nom de publication'+') | Vers ('+$TabCSV.Version+"), puis faite Entrée")
while($ie.busy){Start-Sleep 1} #Attente du chargement de la page Web






($ie.Document.getElementsByTagName('input') | Where-Object -Property 'id' -eq "baquaras_testbundle_application_nom").value
($ie.Document.getElementsByTagName('input') | Where-Object -Property 'id' -eq "baquaras_testbundle_application_editeur").value
($ie.Document.getElementsByTagName('input') | Where-Object -Property 'id' -eq "baquaras_testbundle_application_version").value

# Permet de selectionner le type d'application (ex : Bureautique)
#( ($ie.Document.getElementsByTagName('select') | Where-Object -Property 'id' -eq "baquaras_testbundle_application_type") | Where-Object -Property 'outerHTML' -like ('*'+$Table.'Type de l''application'+"</option>*") ).outertext #.defaultSelected=$true

($ie.Document.getElementsByTagName('textarea') | Where-Object -Property 'id' -eq "baquaras_testbundle_application_description").value 
($ie.Document.getElementsByTagName('input') | Where-Object -Property 'id' -eq "baquaras_testbundle_application_correctifQualif").value
($ie.Document.getElementsByTagName('input') | Where-Object -Property 'id' -eq "baquaras_testbundle_application_codeConvergence").value = "FLASHPLAYER3200171_32"


$CodageAppli = "32"
if($CodageAppli -eq '32'){$i=1}else{$i=2}
($ie.Document.getElementsByTagName('input') | Where-Object -Property 'id' -eq "baquaras_testbundle_application_codage_$i").checked = $true

#Validé sur OS (100 => W10-64  ; 39 W7-32; 51 W7-32 et 64 ; 50 W7-64)
( ($ie.Document.getElementsByTagName('input')) | Where-Object -Property 'id' -like "baquaras_testbundle_application_oscible_51" ).checked = $true

# Justifie un OS 64 bits (1 Oui, 2 Non et 3  Dérogation)
( $ie.Document.getElementsByTagName('input') | Where-Object -Property 'id' -eq 'baquaras_testbundle_application_justifieos_' ).checked = $true


#MOE

(   $ie.Document.getElementsByTagName('select') | Where-Object -Property 'id' -eq 'listMOE'   ).childnodes | fl IHTMLOptionElement_value


(   $ie.Document.getElementsByTagName('td') | Where-Object -Property "outerHTML" -like '*<select id="listMOE" multiple="">*'   ) | fl outerHTML

$test = (   $ie.Document.getElementsByTagName('td') | Where-Object -Property "outerHTML" -like '*<select id="listMOE" multiple="">*'   )
$test.outerHTML = $test.outerHTML.Insert(85,'<option>HILTEBRAND  Philippe  PH88733</option')

#>