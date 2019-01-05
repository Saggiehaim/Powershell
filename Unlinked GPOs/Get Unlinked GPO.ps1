function get-GPOUnlinked () {
    [cmdletbinding()]
        param (
            [parameter(Position=0,
            Mandatory=$false)]
            [switch]$Delete = $false
        )
     $unlinkedGPO = @()
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
        Write-Verbose -Message "Found $GPOs.Count policies to check"
     }
     catch {
        Write-Error -Message "Can't Load GPO's Please make sure you have connection to Domain Controllers"
        exit
     }
     ForEach($gpo  in $GPOs)
     { 
         Write-Verbose -Message "Checking $gpo.name link"
         [xml]$GPOXMLReport = $gpo | Get-GPOReport -ReportType xml 
         if ($GPOXMLReport.GPO.LinksTo -eq $null)
         { 
             $unlinkedGPO += $gpo 
         }
     }  
     if ($Delete -eq $True)
     {
        foreach ($gpo in $unlinkedGPO)
        {
             $remove = $True
             try {
                 $gpo | Remove-GPO
             }
             catch {
                 $remove = $false
             }
             if ($remove -eq $false)
             {
                 $Res += $gpo.name + " Remove failed"
             }
             Else {
                 $Res += $gpo.name + " Remove Success"
             }
         }
     }
}