function Reponse-Bot{
    param($RTMSession, $RTM, $user, [array]$param)

    $prefixe = "-"

    $cmdList1 = @("h","help","?"," => Affiche l'aide")
    $cmdList2 = @("list"," => Permet d'afficher la liste des liens (existants) par filtre")
    $cmdList3 = @("logsccm"," => Permet d'afficher l'explication des logs SCCM Serveur/Client")

    $TestcmdList1 = @(1 | ForEach-Object{ $cmdlistn = Invoke-Expression "`$cmdList$_";$( $cmdlistn | ForEach-Object{ if( $_ -ne $cmdlistn[-1]){$prefixe+$_} } ) })
    $TestcmdList2 = @(2 | ForEach-Object{ $cmdlistn = Invoke-Expression "`$cmdList$_";$( $cmdlistn | ForEach-Object{ if( $_ -ne $cmdlistn[-1]){$prefixe+$_} } ) })
    $TestcmdList3 = @(3 | ForEach-Object{ $cmdlistn = Invoke-Expression "`$cmdList$_";$( $cmdlistn | ForEach-Object{ if( $_ -ne $cmdlistn[-1]){$prefixe+$_} } ) })

    Switch ($param[0]){ # On envoie le paramètre du bot ex : -list
        
        { $TestcmdList1 -contains $_ }{
            
            if( $param.Count -eq 1 ){

                1..3 | ForEach-Object{
                    
                    $cmdlistn = Invoke-Expression "`$cmdList$_"
                    Msg-SlackBot -channel $RTM.channel -text "
                        $( $cmdlistn | ForEach-Object{ if( $_ -ne $cmdlistn[-1]){$prefixe+$_}else{$_} } )
                    "
                }

            }else{
                Msg-SlackBot -channel $RTM.channel -text "Syntaxe incorrecte ! Exemple : @$($RTMSession.self.name) $($prefixe+$cmdList1[0])" 
            }
            
        }

        { $TestcmdList2 -contains $_ }{
            
            if( $param.Count -eq 2 ){

                $Liens = $(Get-Content LienBot.txt) -like "*$($param[-1])*"
                if($Liens){
                    $Liens | ForEach-Object{ Msg-SlackBot -channel $RTM.channel -text $_ }
                }else{
                    Msg-SlackBot -channel $RTM.channel -text "Aucun resultat !"
                }

            }else{
                
                Msg-SlackBot -channel $RTM.channel -text "Syntaxe incorrecte ! Exemple : @$($RTMSession.self.name) $($prefixe+$cmdList2[0]) PowerShell" 
            }

        }

        { $TestcmdList3 -contains $_ }{
            
            if( ($param.Count -eq 2) -or ($param.Count -eq 3) ){
                

                $LogSCCMName = Import-Csv -Path .\SCCM_All-Logs.csv -Delimiter ";" -Encoding ASCII

                #if(!$param){ $param="" }
             
                switch ($param[1]) #la seconde valeur correspond au critère exemple osd, client, serv
                {
                    {@("cli","clie","clien","Client","clients") -contains $_ }{
        
                        if( $param.Count -eq 3 ){

                            "Liste des Logs $($param[2]) : ";
                            if( $LogSCCMName.Client -like "*#$($param[2])*" ){
                                $LogSCCMName.Client -like "*#$($param[2])*" | ForEach-Object{ Msg-SlackBot -channel $RTM.channel -text $_}
                            }else{ Msg-SlackBot -channel $RTM.channel -text "Il n'y a pas de Logs (Client) pour $($param[2])"; }

                        }else{
            
                            "Liste des Logs du Client : "; " ";
                            $LogSCCMName.Client | ForEach-Object{ Msg-SlackBot -channel $RTM.channel -text $_}
                        }
                    }
                    {@("ser","serv","serve","Server","serveur") -contains $_ }{
                        if( $param.Count -eq 3 ){

                            "Liste des Logs $($param[2]) : ";
                            if( $LogSCCMName.Server -like "*#$($param[2])*" ){
                                
                                $LogSCCMName.Server -like "*#$($param[2])*" | ForEach-Object{ Msg-SlackBot -channel $RTM.channel -text $_}
                            }else{ Msg-SlackBot -channel $RTM.channel -text "Il n'y a pas de Logs (Serveur) pour $($param[2])"; }
                            
                        }else{

                            "Liste des Logs du Serveur : "; " ";
                            $LogSCCMName.Server | ForEach-Object{ Msg-SlackBot -channel $RTM.channel -text $_}
                        }
                    }
                    default{ 
        
                        if( ($LogSCCMName.Server -like "*#$($param[1])*") -or ($LogSCCMName.Client -like "*#$($param[1])*") ){
                            
                            Msg-SlackBot -channel $RTM.channel -text "($($param[1]) Srv)";
                            $LogSCCMName.Server -like "*#$($param[1])*" | ForEach-Object{ Msg-SlackBot -channel $RTM.channel -text $_}

                            Msg-SlackBot -channel $RTM.channel -text "-------------------------";

                            Msg-SlackBot -channel $RTM.channel -text "($($param[1]) Client)";
                            $LogSCCMName.Client -like "*#$($param[1])*" | ForEach-Object{ Msg-SlackBot -channel $RTM.channel -text $_}
                        }else{
            
                            Msg-SlackBot -channel $RTM.channel -text "Aucun resultat !";
                            Msg-SlackBot -channel $RTM.channel -text "
                                Essayer :
                                @$($RTMSession.self.name) $($prefixe+$cmdList3[0]) OSD
                                @$($RTMSession.self.name) $($prefixe+$cmdList3[0]) client osd
                                @$($RTMSession.self.name) $($prefixe+$cmdList3[0]) serveur sql
                            ";
                        }
                    }
                }

            }else{
                
                Msg-SlackBot -channel $RTM.channel -text "Syntaxe incorrecte ! Exemple : @$($RTMSession.self.name) $($prefixe+$cmdList3[0]) client";

            }

        }

        default { Msg-SlackBot -channel $RTM.channel -text ":sleepy: => I have no response for you !" }
    }
}


function Msg-SlackBot{
    param($channel, $text)
    #Partie send (il faut invité le bot dans le channel afin qu'il puisse écrire)
    $Prop = @{
        'id'      = (get-date).ticks;
        'type'    = 'message';
        'text'    = $text;
        'channel' = $channel;
    }

    $Reply = (New-Object –TypeName PSObject –Prop $Prop) | ConvertTo-Json

    $Array = @()
    $Reply.ToCharArray() | ForEach { $Array += [byte]$_ }          
    $Reply = New-Object System.ArraySegment[byte]  -ArgumentList @(,$Array)

    $Conn = $WS.SendAsync($Reply, [System.Net.WebSockets.WebSocketMessageType]::Text, [System.Boolean]::TrueString, $CT)
    While (!$Conn.IsCompleted) { Start-Sleep -Milliseconds 100 }
}


<#

Envoie en privé à travailler :

$Token = "xoxb-226100207429-794597235282-gfhpbLbkz759h3SwC352IRgn"
Invoke-RestMethod -Uri "https://slack.com/api/chat.postMessage" -Body @{token="$Token";channel="UF06MHXD3";text="Bonsoir";as_user=$true} `
-ContentType 'application/json'

#>