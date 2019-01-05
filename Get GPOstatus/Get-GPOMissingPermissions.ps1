function Get-GPOMissingPermissions {
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
        $MissingPermissionsGPOArray = New-Object System.Collections.ArrayList
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
            If ($GPO.User.Enabled) {
                $GPOPermissionForAuthUsers = Get-GPPermission -Guid $GPO.Id -All | Select-Object -ExpandProperty Trustee | Where-Object {$_.Name -eq "Authenticated Users"}
                $GPOPermissionForDomainComputers = Get-GPPermission -Guid $GPO.Id -All | Select-Object -ExpandProperty Trustee | Where-Object {$_.Name -eq "Domain Computers"}
                If (!$GPOPermissionForAuthUsers -and !$GPOPermissionForDomainComputers) {
                    $MissingPermissionsGPOArray += Write-Warning "'$($GPo.DisplayName)' do not grant any permissions to the 'Authenticated Users' or 'Domain Computers' groups"
                }
            }
        }
        return $MissingPermissionsGPOArray
    }
    else {
        Write-Verbose -Message "Checking '$($gpo.DisplayName)' link"
        [xml]$GPOXMLReport = $gpo | Get-GPOReport -ReportType xml
        If ($GPO.User.Enabled) {
            $GPOPermissionForAuthUsers = Get-GPPermission -Guid $GPO.Id -All | Select-Object -ExpandProperty Trustee | Where-Object {$_.Name -eq "Authenticated Users"}
            $GPOPermissionForDomainComputers = Get-GPPermission -Guid $GPO.Id -All | Select-Object -ExpandProperty Trustee | Where-Object {$_.Name -eq "Domain Computers"}
            If (!$GPOPermissionForAuthUsers -and !$GPOPermissionForDomainComputers) {
                return Write-Warning "'$($GPo.DisplayName)' do not grant any permissions to the 'Authenticated Users' or 'Domain Computers' groups"
            }
        }
    }
}