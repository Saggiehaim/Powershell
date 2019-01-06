function Get-GPODisabled {
    [cmdletbinding()]
    param (
        [parameter(Position = 0,
            Mandatory = $false)]
        [Microsoft.GroupPolicy.Gpo]$GPO = $null
    )
    try {
        Write-Verbose -Message "Importing GroupPolicy module"
        Import-Module GroupPolicy -ErrorAction Stop
    }
    catch {
        Write-Error -Message "GroupPolicy Module not found. Make sure RSAT (Remote Server Admin Tools) is installed"
        exit
    }
    if ($null -eq $GPO) {
        $DisabledGPO = New-Object System.Collections.ArrayList
        try {
            Write-Verbose -Message "Importing GroupPolicy Policies"  
            $GPOs = Get-GPO -All  
            Write-Verbose -Message "Found '$($GPOs.Count)' policies to check"
        }
        catch {
            Write-Error -Message "Can't Load GPO's Please make sure you have connection to the Domain Controllers"
            exit
        }
        ForEach ($gpo  in $GPOs) { 
            Write-Verbose -Message "Checking '$($gpo.DisplayName)' status"
            switch ($gpo.GpoStatus) {
                ComputerSettingsDisabled {$DisabledGPO += "in '$($gpo.DisplayName)' the Computer Settings Disabled"}
                UserSettingsDisabled {$DisabledGPO += "in '$($gpo.DisplayName)' the User Settings Disabled"}
                AllSettingsDisabled {$DisabledGPO += "in '$($gpo.DisplayName)' the All Settings Disabled"}
            }
        }
        if (($DisabledGPO).Count -ne 0) {
            Write-Host "The Following GPO's have settings disabled:"
            return $DisabledGPO
        }
        else {
            return "No Empty GPO's Found"
        }
        
    }
    else {
        Write-Verbose -Message "Checking '$($gpo.DisplayName)' link"
        switch ($gpo.GpoStatus) {
            ComputerSettingsDisabled {return "in '$($gpo.DisplayName)' the Computer Settings Disabled"}
            UserSettingsDisabled {return "in '$($gpo.DisplayName)' the User Settings Disabled"}
            AllSettingsDisabled {return "in '$($gpo.DisplayName)' the All Settings Disabled"}
        }
        else {
            return Write-Host "in '$($gpo.DisplayName)' all settings enabled"
        }
    }
}