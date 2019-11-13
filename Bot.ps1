cd $PSScriptRoot
. ".\Send-SlackBot.ps1"

#------------------------------                   ------------------------------
#------------------------------ Connection du Bot ------------------------------
#------------------------------                   ------------------------------
$Token = "xoxb-815597475253-815610936645-lpQQH13ZkSJrON155xMrcV6L"

$RTMSession = Invoke-RestMethod -Uri https://slack.com/api/rtm.start -Body @{token="$Token"}
Write-Verbose "I am $($RTMSession.self.name)" -Verbose

$WS = New-Object System.Net.WebSockets.ClientWebSocket                                                
$CT = New-Object System.Threading.CancellationToken                                                   

$Conn = $WS.ConnectAsync($RTMSession.URL, $CT)                                                  
While (!$Conn.IsCompleted) { Start-Sleep -Milliseconds 100 }

Write-Verbose "Connected to $($RTMSession.URL)" -Verbose

$Size = 1024
$Array = [byte[]] @(,0) * $Size
$Recv = New-Object System.ArraySegment[byte] -ArgumentList @(,$Array)
#------------------------------                   ------------------------------
#------------------------------ Connection du Bot ------------------------------
#------------------------------                   ------------------------------



While ($WS.State -eq 'Open') {

    $RTM = ""

    Do {
        $Conn = $WS.ReceiveAsync($Recv, $CT)
        While (!$Conn.IsCompleted) { Start-Sleep -Milliseconds 100 }

        #Traduction du code ascii en lettre et chiffre. Le é est indisponible (warning bug)
        $Recv.Array[0..($Conn.Result.Count - 1)] | ForEach-Object { $RTM = $RTM + [char]$_ } 

    } Until ($Conn.Result.Count -lt $Size)

    Write-Verbose "$RTM" -Verbose

    If ($RTM){

        $RTM = ($RTM | convertfrom-json)
        
        Switch ($RTM){
            {($_.type -eq 'message') -and (!$_.reply_to)} { 

                If ( ($_.text -Match "<@$($RTMSession.self.id)>") -or $_.channel.StartsWith('D') ){ #D message directe !
                    #A message was sent to the bot

                    # *** Responses go here, for example..***
                    $words = "$($_.text)".ToLower()
                    while ($words -match '  '){
                        $words = $words -replace '  ',' '
                    }
                    $words = $words -split ' '
                    

                    # Preference du bot MyEcc
                    Reponse-Bot -RTMSession $RTMSession -RTM $RTM -user $words[0] -param $words[1..$words.Count]



                }else{
                    Write-Verbose "Message ignored as it wasn't sent to @$($RTMSession.self.name) or in a DM channel" -Verbose
                }
            }

            {$_.type -eq 'reconnect_url'} { $RTMSession.URL = $RTM.url }

            default { Write-Verbose "No action specified for $($RTM.type) event" -Verbose }            
        }
    }
}

#$WS.Dispose()