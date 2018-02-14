##########################################################
## This Script Written by Saggie Haim                   ##
## The script is exporting all Disabled Users from the  ##
## Active Directory, without the Service accounts       ##
## Please dont make any changes if you don't know what  ##
## to change                                            ##
##                                                      ##
## Thanks, Saggie                                       ##
##                                                      ##
##########################################################
Import-Module ActiveDirectory

$reportname = "DisabledUsers " + (Get-date -Format d-M-yy) + ".csv"
$ReportLocation = "C:\Temp\" + $reportname
$Report = @()

$users = Get-ADUser -filter * -Properties EmployeeID,Department,Company,whenCreated | Where-object {$_.Enabled -eq $false}
foreach ($user in $users) {
    if ($user.EmployeeID -ne $null) {
         $ReportLine = [PSCustomObject][Ordered]@{
            'Full Name'           = $user.Name
            'Employee ID'         = $user.EmployeeID
            'Department'          = $user.Department
            'Company'             = $user.Company
            'When Created'        = $user.whenCreated
        }
    $Report += $ReportLine
    }
}
$Report | export-csv -NoTypeInformation -Path $ReportLocation
