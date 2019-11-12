function Alert{
    $TypeAlert=4
    $TypedeBox=64

    Add-Type -AssemblyName System.Windows.Forms

    $Alert = [System.Windows.Forms.MessageBox];

    #Yes ou No
    $Choix = $Alert::Show("Accepte tu mon cadeau ?", "???", $TypeAlert, $TypedeBox)

    switch($Choix){
    
        'Yes'{ calc.exe }
        'No'{Write-Host "Interdit de dire No !!!";Alert}

    }

}