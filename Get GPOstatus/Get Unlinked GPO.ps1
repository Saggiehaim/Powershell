function Get-GPOstatus () {
    [cmdletbinding()]
    param (
        [parameter(Position = 0,
            Mandatory = $false)]
        [switch]$Delete = $false
    )
    ## $MarkedGPOs = New-Object System.Collections.ArrayList
    try {
        Write-Verbose -Message "Importing GroupPolicy module"
        Import-Module GroupPolicy -ErrorAction Stop
    }
    catch {
        Write-Error -Message "GroupPolicy Module not found. Make sure RSAT (Remote Server Admin Tools) is installed"
        exit
    }
    try {
        Write-Verbose -Message "Importing GroupPolicy Policies"  
        $GPOs = Get-GPO -All  
        Write-Verbose -Message "Found '$($GPOs.Count)' policies to check"
    }
    catch {
        Write-Error -Message "Can't Load GPO's Please make sure you have connection to Domain Controllers"
        exit
    }
    ForEach ($gpo  in $GPOs) { 
        Write-Verbose -Message "Checking '$($gpo.DisplayName)' link"
        [xml]$GPOXMLReport = $gpo | Get-GPOReport -ReportType xml
        if ($null -eq $GPOXMLReport.GPO.LinksTo) { 
            Write-Warning "'$($gpo.DisplayName)' is not linked" 
        }
        if ($null -eq $GPOXMLReport.gpo.User.ExtensionData -and $null -eq $GPOXMLReport.gpo.Computer.ExtensionData) {
            Write-Warning "'$($gpo.DisplayName)' is empty"
        }
        If ($GPO.User.Enabled) {
            $GPOPermissionForAuthUsers = Get-GPPermission -Guid $GPO.Id -All | Select-Object -ExpandProperty Trustee | Where-Object {$_.Name -eq "Authenticated Users"}
            $GPOPermissionForDomainComputers = Get-GPPermission -Guid $GPO.Id -All | Select-Object -ExpandProperty Trustee | Where-Object {$_.Name -eq "Domain Computers"}
            If (!$GPOPermissionForAuthUsers -and !$GPOPermissionForDomainComputers) {
                Write-Warning "'$($GPo.DisplayName)' do not grant any permissions to the 'Authenticated Users' or 'Domain Computers' groups"
            }
        }
    }
}  
