function Get-GPOEmpty {
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
        $EmptyGPO = New-Object System.Collections.ArrayList
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
            Write-Verbose -Message "Checking '$($gpo.DisplayName)' link"
            [xml]$GPOXMLReport = $gpo | Get-GPOReport -ReportType xml
            if ($null -eq $GPOXMLReport.gpo.User.ExtensionData -and $null -eq $GPOXMLReport.gpo.Computer.ExtensionData) {
                $EmptyGPO += $gpo
            }
        }
        if (($EmptyGPO).Count -ne 0) {
            Write-Host "The Following GPO's are empty:"
            return $EmptyGPO | Select-Object DisplayName
        }
        else {
            return "No Empty GPO's Found"
        }
        
    }
    else {
        Write-Verbose -Message "Checking '$($gpo.DisplayName)' link"
        [xml]$GPOXMLReport = $gpo | Get-GPOReport -ReportType xml
        if ($null -eq $GPOXMLReport.gpo.User.ExtensionData -and $null -eq $GPOXMLReport.gpo.Computer.ExtensionData) {
            return Write-Warning "'$($gpo.DisplayName)' is empty"
        }
        else {
            return Write-Host "'$($gpo.DisplayName)' is no empty"
        }
    }
}