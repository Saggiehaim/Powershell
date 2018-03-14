function get-GPOUnlinked () {
    [cmdletbinding()]
        param (
            [parameter(Position=0,
            Mandatory=$false)]
            [switch]$Delete = $false
        )
     $unlinkedGPO = @()
     import-module GroupPolicy
     Write-Verbose -Message "Importing GroupPolicy module"  
     $GPOs = Get-GPO -All  
     Write-Verbose -Message "Found " + $GPOs.Count + " to check"
     ForEach($gpo  in $GPOs)
     { 
         Write-Verbose -Message "Checking " + $gpo.name + " link"
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