## Function to process the Snapshot size
function Get-SnapshotSize ($Snapshot) {
    if ($snapshot.SizeGB -ge "1") {
        $Snapshotsize = [string]([math]::Round($snapshot.SizeGB, 3)) + " GB"
    }
    else {
        $Snapshotsize = [string]([math]::Round($snapshot.SizeMB, 3)) + " MB"
    }
    Return $Snapshotsize
}
## Function to decide the color of the snapshot row
function Get-SnapshotDateStyle ($snapshot) {
    $greenValue = (get-date).AddDays(-7)
    $RedValue = (get-date).AddDays(-14)
    
    if ($snapshot.created -gt $greenValue) {
        $backgroundcolor = "green"
    }
    elseif ($snapshot.Created -lt $greenValue -and $snapshot.Created -gt $RedValue) {
        $backgroundcolor = "yellow"
    }
    else {
        $backgroundcolor = "red"
    }
    return $backgroundcolor
}

## Add conditional formating to our HTML
function Format-HTMLBody ($body) {
    $newbody = @()
    foreach ($line in $body) {
        ## Remove the Format Header
        if ($line -like "*<th>Format</th>*") {
            $line = $line -replace '<th>Format</th>', ''
        }
        ## Format all the Red rows
        if ($line -like "*<td>red</td>*") {
            $line = $line -replace '<td>red</td>', '' 
            $line = $line -replace '<tr>', '<tr style="background-color:Tomato;">'
        }
        ## Formating all the Yellow Rows
        elseif ($line -like "*<td>yellow</td>*") {
            $line = $line -replace '<td>yellow</td>', '' 
            $line = $line -replace '<tr>', '<tr style="background-color:Orange;">'
        }
        ## Formating all the Green Rows
        elseif ($line -like "*<td>green</td>*") {
            $line = $line -replace '<td>green</td>', '' 
            $line = $line -replace '<tr>', '<tr style="background-color:MediumSeaGreen;">'
        }
        ## Building the new HTML file
        $newbody += $line
    }
    return $newbody
}

## Connecting to the VCenter or ESXi
$PasswordFile = "Password.txt"
$securePassword = Get-Content $PasswordFile | ConvertTo-SecureString
$credentials = New-Object System.Management.Automation.PSCredential ("Username", $securePassword)
Connect-VIServer -Server myvc01 -Credential $credentials

## Getting all Snapshots for all VM's
$Snapshots = Get-VM | Get-Snapshot | Select-Object Description, Created, VM, SizeMB, SizeGB
$date = (get-date -Format d/M/yyyy)
$header = @"
 <Title>Snapshot Report - $date</Title>
<style>
body {   font-family: 'Helvetica Neue', Helvetica, Arial;
         font-size: 14px;
         line-height: 20px;
         font-weight: 400;
         color: black;
    }
table{
  margin: 0 0 40px 0;
  width: 100%;
  box-shadow: 0 1px 3px rgba(0,0,0,0.2);
  display: table;
  border-collapse: collapse;
  border: 1px solid black;
}
th {
    font-weight: 900;
    color: #ffffff;
    background: black;
   }
td {
    border: 0px;
    border-bottom: 1px solid black
    }
</style>
"@
## Setting Title to our table
$PreContent = "<H1> Snapshot Report for " + $date + "</H1>"
## Creating the HTML File
$html = $Snapshots | Select-Object VM, Created, @{Label = "Size"; Expression = {Get-SnapshotSize($_)}}, Description, @{Label = "Format"; Expression = {Get-SnapshotDateStyle($_)}}| Sort-Object Created -Descending | ConvertTo-Html -Head $header -PreContent $PreContent
## Changing the Style for the rows
$Report = Format-HTMLBody ($html)
## MailParam
$MailParam = @{ 
    To         = "EMail" 
    From       = "EMail"
    SmtpServer = "SMTP Server"
    Subject    = "VMware Snapshot Report for " + (get-date -Format d/M/yyyy)
    body       = ([string]$Report)
}
## Sending the Email
Send-MailMessage @MailParam -BodyAsHtml
## Disconnecting from the VCenter ESXi
Disconnect-VIServer -Confirm:$false