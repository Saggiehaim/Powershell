function Get-GPOUnlinked {
    [cmdletbinding()]
    param (
        [parameter(Position = 0,
            Mandatory = $false, ValueFromPipeline)]
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
        $UnlinkedGPO = New-Object System.Collections.ArrayList
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
            if ($null -eq $GPOXMLReport.GPO.LinksTo) { 
                $UnlinkedGPO += $gpo
            }
        }
        if (($UnlinkedGPO).Count -ne 0) {
            return $UnlinkedGPO
        }
        else {
            return Write-Host "No Unlinked GPO found"
        }
    }
    else {
        Write-Verbose -Message "Checking '$($gpo.DisplayName)' link"
        [xml]$GPOXMLReport = $gpo | Get-GPOReport -ReportType xml
        if ($null -eq $GPOXMLReport.GPO.LinksTo) { 
            return Write-Warning "'$($gpo.DisplayName)' is not linked" 
        }
        else {
            return Write-Host "'$($gpo.DisplayName)' is linked"
        }
    }
}