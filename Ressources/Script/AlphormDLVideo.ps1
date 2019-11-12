#Indiqué toujours le dernier \ pour le chemin ex :  L:\..\Vidéo\
$CheminAbsolut= ('\\depot.formation.test\CSP\Library\Formation\AlPhorm\')


$urllogin = "https://www.alphorm.com/account/login"
$Login = 'Alphorm2'
$Password = 'mdp15'
$ShowName ='Alphorm 2'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
[void] [System.Reflection.Assembly]::LoadWithPartialName("'System.Windows.Forms")
[void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic");

if( !(Get-Process | Where-Object { $_.MainWindowHandle -eq $ie.HWND})  ){ 
    $ie = New-Object -COMObject InternetExplorer.Application
    $ie.visible = $true
    $ie.silent = $true
}


$ie.Navigate($urllogin)
while($ie.busy){Start-Sleep 1} #chargement de la page

if($ie.LocationURL -match 'https://www.alphorm.com/account/login'){

    #--------------------- Partie authentification ----------------------------------------------
    ($ie.Document.getElementsByTagName('input') | Where-Object -Property 'outerHTML' -like "*username*").value = $Login
    ($ie.Document.getElementsByTagName('input') | Where-Object -Property 'outerHTML' -like "*Password*").value = $Password
    $loginBtn = $ie.Document.getElementsByTagName('button') | Where-Object -Property 'outerHTML' -like '*btn-connect*'
    $loginBtn.click()
    #--------------------- Partie authentification ----------------------------------------------

    #Il termine la connexion
    while($ie.busy){Start-Sleep 1}
}

cls
Write-Host "Dans un premier temps, placer vous dans un cours (si non bug !!!)" -ForegroundColor Yellow;
Write-Host "Ps : Exemple d'url pour internet explorer : https://www.alphorm.com/tutoriel/formation-en-ligne-powershell-2-0" -ForegroundColor Cyan; Write-Host '';
Write-Host "Dès que vous êtes dans le cours voulue et que la page est fini de charger, appuiez sur entrée !" -ForegroundColor Green;Write-Host "";
Write-Host "Un dossier sera créer portant le nom de la formation. Si il porte comme nom de fin 'CSP', c'est qu'il existe déjà et donc une copie sera créer pour ne pas écraser les vidéos existantes" -ForegroundColor red;
Read-Host;


Do{
    
    #----------------------------------------- Partie vidéo -----------------------------------------

    $ElemClass =($ie.Document.documentElement.getElementsByClassName('course-title') | Select-Object -Property outerhtml).outerhtml;
    $Elem      =($ie.Document.documentElement.getElementsByTagName('h1') | Select-Object -Property outerhtml).outerhtml;
    if($Elem -eq $ElemClass ){
        $NameFormation = ($ie.Document.getElementsByTagName('h1') | Select-Object -Property outertext).outertext;
        $NameFormation = $NameFormation.replace('/','-').replace(':',' -')

    }else{ $NameFormation = 'CSP_Nom_Inexistant' }

    $Div = $ie.Document.documentElement.getElementsByTagName('div')
    $Titre_Plan_Detail = ($Div | Where-Object { ($_.outerhtml -like "<div class=`"detail-point`">*") }).outerhtml;

    $VideoName = @()
    $Titre_Plan_Detail | foreach{
        $NameVidéoConstruct =$_.Substring($_.LastIndexOf("`">")).replace("</a></div>","").replace("`">", "")
        $NameVidéoConstruct =$NameVidéoConstruct.Replace('?','').replace(':','-')
        if( ($NameVidéoConstruct | Select-String -SimpleMatch '<')){ $NameVidéoConstruct = $NameVidéoConstruct.remove($NameVidéoConstruct.IndexOf('<')) }
        $NameVidéoConstruct =$NameVidéoConstruct.Replace('/','-').Replace('\','-').Replace('"','').Replace('amp;','')
        $VideoName += $NameVidéoConstruct
    }
    
    Write-Host "Pause Sleep";sleep(555)
    if( !(Test-Path ($CheminAbsolut+$NameFormation)) ){New-Item -Path  $CheminAbsolut -Name $NameFormation -ItemType Directory}else{ $NameFormation=($NameFormation+'_CSP');New-Item -Path  $CheminAbsolut -Name $NameFormation -ItemType Directory }
    $CheminDownload = ($CheminAbsolut+$NameFormation+'\')
    $CheminDownload = $CheminDownload.Replace(' \','\')
    sleep(1)
    #------------- Boucle téléchargement des vidéos ---------------------#
    $LiensVidéos = @();$LiensVidéos += 'https:\\nulle';
    $ieProcess = Get-Process | Where-Object { $_.MainWindowHandle -eq $ie.HWND }           
    $ApplicationCourante = [Microsoft.VisualBasic.Interaction]::AppActivate($ieProcess.id)
    $TabulationFirst = 24;#On commence à 24 car c'est la première vidéos après 24 tabulation
    $PefixeVideo=1;$i=0;
    $VideoName | ForEach-Object {

        1..$TabulationFirst | foreach {
            Start-Sleep -Milliseconds 53
            $ApplicationCourante.[System.Windows.Forms.SendKeys]::Sendwait("{TAB}");
        }

        Start-Sleep -Seconds 1
        $ApplicationCourante.[System.Windows.Forms.SendKeys]::Sendwait("{ENTER}");
        
        #sleep(555)
        
        Start-Sleep -Seconds 3
        $Div = $ie.Document.documentElement.getElementsByTagName('div')
        $DivLienVideo = $Div | Where-Object { $_.outerhtml -like ('<div class="jw-media jw-reset"><video class="jw-video jw-reset"*') } | Select-Object -First 1;
        Start-Sleep -Seconds 1
        #Cette partie permet d'extraire uniquement le lien de la vidéo
        $ConstructDivLien =$DivLienVideo.outerHTML
        $ConstructDivLien =$ConstructDivLien.Substring($ConstructDivLien.IndexOf('http'))
        $ConstructDivLien =$ConstructDivLien.Split('"')[0];
        $ConstructDivLien =$ConstructDivLien.Replace('amp;','')

        Write-Host ''; $ConstructDivLien;

        $LiensVidéos += $ConstructDivLien

        #Partie téléchargement de la vidéos
        Start-Sleep -Seconds 3
        if($ConstructDivLien -ne $LiensVidéos[($PefixeVideo-1)]){
            try{ Invoke-WebRequest -Uri $ConstructDivLien -OutFile ($CheminDownload+$PefixeVideo+'_'+$_+'.mp4') }catch{ ("Vidéo "+$PefixeVideo+" : Lien de la viéo ( $ConstructDivLien ) - Erreur => "+$Error[0]) >> '.\ErreurDL_Vidéo.log' }
        }else{ ("vidéo N°"+$PefixeVideo+" : Ne c'est pas DL, car le lien de la vidéo $_ est idem que le lien de la vidéo d'avant  : "+$VideoName[($i-1)]) >> '.\DoublonsVidéo.log' }

        $TabulationFirst = 1
        $i++;$PefixeVideo++;
    }
    ($VideoName.Length) > ($CheminDownload+'TotalVidéo.txt')
    #>
    #----------------------------------------- Partie PPT -------------------------------------------
    $iframe = $ie.Document.documentElement.getElementsByTagName('iframe')[0]
    $urlPPT = ($iframe.attributes | Where-Object -Property name -eq 'src').value

    $ie.Navigate($urlPPT)
    while($ie.busy){Start-Sleep 1}
    Start-Sleep -Seconds 1


    New-Item -Path  $CheminDownload -Name 'PPT' -ItemType Directory
    $CheminPPT = ($CheminDownload+'PPT\')
    $CheminPPT = $CheminPPT.Replace(' \','\')


    $urlSlidePPT =($ie.Document.documentElement.getElementsByTagName('div')[0].getElementsByClassName("slide show") | Select-Object -Property outerhtml).outerhtml
    $urlSlidePPT = $urlSlidePPT.Substring($urlSlidePPT.IndexOf('data-full=')).split('"')[1]

    $currentSlidePPT  = $ie.Document.getElementById('current-slide').outerhtml
    $currentSlidePPT   = $currentSlidePPT.Split('>').split('<')[2]

    $TotalSlidePPT    = $ie.Document.getElementById('total-slides').outerhtml
    $TotalSlidePPT    = $TotalSlidePPT.Split('>').split('<')[2]
    #sleep(555)
    [int32]$i=$currentSlidePPT;
    $currentSlidePPT..$TotalSlidePPT | ForEach-Object{
        $url = $urlSlidePPT.Replace('-1-1024',('-'+$i+'-1024'))
        try{ Invoke-WebRequest -Uri $url -OutFile ($CheminPPT+$i+'.jpg') }catch{ ("PPT "+$i+" : "+$Error[0]) >> '.\ErreurDL_PPT.log' }
        $i++;
    }
    #>
    cls
    $ie.Navigate('https://www.alphorm.com/formations')
    while($ie.busy){Start-Sleep 1}
    Write-Host 'Terminer le téléchargement des vidéos ?'; Write-Host "Oui => Entrée 1"; Write-Host "Non => Enrée une valeur différent de 1";Write-Host '';
    Write-Host "Si vous souhaitez continuer, n'oublié pas de vous rediriger vers la formation souhaité avec Internet explorer, si non cela risque de provoquer des surprises !!!" -ForegroundColor Cyan
    $Verif = Read-Host
    Write-Host ''; Write-Host '';

}Until($Verif -eq '1')