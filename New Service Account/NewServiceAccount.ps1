# Check if User is valid in Active Directory
function Get-account ($EmployeeID) {
    $user = Get-ADUser -Properties EmployeeID, EmailAddress -Filter {EmployeeID -eq $EmployeeID} | Select-Object Name, EmailAddress, EmployeeID
    if ($null -eq $user) {
        return $false
    }
    else {
        return $user
    }
}
# Create a new password
function new-Password() {
    $inputRange = 48..122
    $inputRange += 33, 35
    $exclude = 91..96
    $exclude += 58..63
    $randomRange = $inputRange | Where-Object { $exclude -notcontains $_}
    for ($i = 0; $i -lt 12; $i++) {
        $rnd = (Get-Random -InputObject $randomRange) 
        $char = [char]$rnd
        $pass += $char
    }
    return $pass
}
#Create the Service Account
function new-ADServiceAccount ($SAName, $Description, $Creatoruser, $Manageruser) {
    # OU to create the Service Account
    $path = 'OU=Global Service Accounts,DC=SaggieHaim,DC=Net'
    $password = new-Password
    $ManagedBy = 'Managed By ' + $Manageruser.Name + ' (' + $Manageruser.EmployeeID + ')' 
    try {
        New-ADUser -SamAccountName $SAName -UserPrincipalName $SAName -DisplayName $SAName -GivenName $SAName -Name $SAName -Description $Description -Office $ManagedBy -AccountPassword (ConvertTo-SecureString -AsPlainText $password -Force) -Enabled $true -ChangePasswordAtLogon $true -Path $path  
    }
    catch {
        return $false
    }
    $NewUser = Get-ADUser -Identity $SAName -Properties Office, Description
    Send-DoneEmail $Creatoruser $Manageruser $NewUser $password
    return $true
    
    
}
## Send Mail on Complition
function Send-DoneEmail ($Creatoruser, $Manageruser, $NewUser, $password) {
    ##configure SMTP Settings
    $From = "contact@saggiehaim.net"
    $SMTPServer = "saggiehaim.net"
    $SMTPPort = "25"
    $AdministratorsSMTPAddress = "Contact@saggiehaim.net"
    $usersSMTPAddress = $Manageruser.EmailAddress, $Creatoruser.EmailAddress

    #Create email and send it to Users.
    $SubjectAdministrators = "New Service Account Has been created for you"
    $bodyToAD = "Hello,<br><br>"
    $bodyToAD += "New Service account has been created for you by: " + $Creator.name + "<br><br>"
    $bodyToAD += "<b>Service account Name:</b> " + $NewUser.SamAccountName + "<br>" 
    $bodyToAD += "<b>Service account Password:</b> " + $password + "<br>"
    $bodyToAD += "<b>You will be asked to change the password after first logon</b><br><br>"
    $bodyToAD += "For Any further assist please contact " + $Creatoruser.name + " by Mail: " + $Creatoruser.EmailAddress + "<br>"
    $bodyToAD += "<br>" 
    $bodyToAD += "Thanks,<br>"
    $bodyToAD += "ServIT<br>"				
			
    Send-MailMessage -From $From -to $usersSMTPAddress -Subject $SubjectAdministrators ` -Body $bodyToAD -BodyAsHtml -Encoding UTF8 -SmtpServer $SMTPServer -port $SMTPPort
            
    #Create email and send it to administrators.
    $SubjectAdministrators = "New Service Account Has been Created"
    $bodyToAD = "Hello,<br><br>"
    $bodyToAD += "New Service Account has beem created.<br>"
    $bodyToAD += "<b>Service Account Name:</b> " + $NewUser.name + "<br>"
    $bodyToAD += "<b>Service Account Description:</b> " + $NewUser.Description + "<br>"
    $bodyToAD += "<b>Service Account Managed by:</b>" + $NewUser.Office + "<br>"
    $bodyToAD += "<b>Service Account Created for:</b> " + $Manageruser.name + "<br>"
    $bodyToAD += "<b>Service Account Created by:</b>" + $Creatoruser.name + "<br>"
    $bodyToAD += "<br>" 
    $bodyToAD += "Active Directory Team<br>"				
	
    Send-MailMessage -From $From -to $AdministratorsSMTPAddress -Subject $SubjectAdministrators ` -Body $bodyToAD -BodyAsHtml -Encoding UTF8 -SmtpServer $SMTPServer -port $SMTPPort
    
}

<# This form was created using POSHGUI.com  a free online gui designer for PowerShell
.NAME
    Untitled
#>

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

#region begin GUI{ 

$Form = New-Object system.Windows.Forms.Form
$Form.ClientSize = '495,216'
$Form.text = "Service Account Creator"
$Form.TopMost = $false
$Form.StartPosition = "CenterScreen" #loads the window in the center of the screen
$Form.FormBorderStyle = 'Fixed3D' #modifies the window border

$SAccountName = New-Object system.Windows.Forms.TextBox
$SAccountName.multiline = $false
$SAccountName.text = "Srvc"
$SAccountName.width = 309
$SAccountName.height = 20
$SAccountName.location = New-Object System.Drawing.Point(156, 25)
$SAccountName.Font = 'Microsoft Sans Serif,10'

$AccountName = New-Object system.Windows.Forms.Label
$AccountName.text = "Service Account Name"
$AccountName.AutoSize = $true
$AccountName.width = 20
$AccountName.height = 10
$AccountName.location = New-Object System.Drawing.Point(18, 25)
$AccountName.Font = 'Microsoft Sans Serif,10'

$ManagerEmployee = New-Object system.Windows.Forms.Label
$ManagerEmployee.text = "Manger Employee ID"
$ManagerEmployee.AutoSize = $true
$ManagerEmployee.width = 25
$ManagerEmployee.height = 10
$ManagerEmployee.location = New-Object System.Drawing.Point(18, 55)
$ManagerEmployee.Font = 'Microsoft Sans Serif,10'

$ManagerEmployeeID = New-Object system.Windows.Forms.TextBox
$ManagerEmployeeID.multiline = $false
$ManagerEmployeeID.width = 309
$ManagerEmployeeID.height = 20
$ManagerEmployeeID.location = New-Object System.Drawing.Point(156, 55)
$ManagerEmployeeID.Font = 'Microsoft Sans Serif,10'

$CreatorEmployee = New-Object system.Windows.Forms.Label
$CreatorEmployee.text = "Creator Employee ID"
$CreatorEmployee.AutoSize = $true
$CreatorEmployee.width = 25
$CreatorEmployee.height = 10
$CreatorEmployee.location = New-Object System.Drawing.Point(18, 82)
$CreatorEmployee.Font = 'Microsoft Sans Serif,10'

$CreatorEmployeeID = New-Object system.Windows.Forms.TextBox
$CreatorEmployeeID.multiline = $false
$CreatorEmployeeID.width = 309
$CreatorEmployeeID.height = 20
$CreatorEmployeeID.location = New-Object System.Drawing.Point(156, 82)
$CreatorEmployeeID.Font = 'Microsoft Sans Serif,10'

$Description = New-Object system.Windows.Forms.Label
$Description.text = "Description"
$Description.AutoSize = $true
$Description.width = 25
$Description.height = 10
$Description.location = New-Object System.Drawing.Point(18, 110)
$Description.Font = 'Microsoft Sans Serif,10'

$TDescription = New-Object system.Windows.Forms.TextBox
$TDescription.multiline = $false
$TDescription.text = "Service Account For"
$TDescription.width = 309
$TDescription.height = 20
$TDescription.location = New-Object System.Drawing.Point(156, 110)
$TDescription.Font = 'Microsoft Sans Serif,10'

$Create = New-Object system.Windows.Forms.Button
$Create.text = "Create Account"
$Create.width = 111
$Create.height = 30
$Create.location = New-Object System.Drawing.Point(178, 154)
$Create.Font = 'Microsoft Sans Serif,10'


$StatusBar = New-Object System.Windows.Forms.Label
$StatusBar.width = 495
$StatusBar.height = 20
$StatusBar.location = New-Object System.Drawing.Point(1, 192)
$StatusBar.Font = 'Microsoft Sans Serif,10'
$StatusBar.Text = 'Ready'
$StatusBar.Enabled = $true

$Form.controls.AddRange(@($SAccountName, $AccountName, $ManagerEmployee, $ManagerEmployeeID, $CreatorEmployee, $CreatorEmployeeID, $Description, $TDescription, $Create, $StatusBar))

#region gui events {
$Create.Add_Click( {
        if ($SAccountName.Text -eq $null -or $SAccountName.Text -eq '' -or $SAccountName.Text -eq "Srvc") {
            $StatusBar.ForeColor = "#ff0000"
            $StatusBar.Text = "Please Make sure you set Service Account name"
            return
        
        }
        elseif ($SAccountName.Text -notlike "Srvc*") {
            $StatusBar.ForeColor = "#ff0000"
            $StatusBar.Text = "Please Make sure Service Account Name start with 'Srvc'"
            return
        }
        if ($TDescription.Text -eq $null -or $TDescription.Text -eq '' -or $TDescription.Text -eq "Service Account For") {
            $StatusBar.ForeColor = "#ff0000"
            $StatusBar.Text = "Please Make sure to insert Service Account Description!"
            return
        }
        elseif ($TDescription.Text -notlike "Service Account For*") {
            $StatusBar.ForeColor = "#ff0000"
            $StatusBar.Text = "Please Start Description with 'Service Account For'"
            return
        }
        if ($ManagerEmployeeID.Text -eq $null -or $ManagerEmployeeID.Text -eq '') {
            $StatusBar.ForeColor = "#ff0000"
            $StatusBar.Text = "Please Enter Manager Employee ID"
            return
        }
        if ($CreatorEmployeeID.Text -eq $null -or $creatorEmployeeID.Text -eq '') {
            $StatusBar.ForeColor = "#ff0000"
            $StatusBar.Text = "Please Enter Creator Employee ID"
            return
        }
        $Creator = Get-account $CreatorEmployeeID.text
        $Manager = Get-account $ManagerEmployeeID.text
        if ($Creator -eq $false) {
            $StatusBar.ForeColor = "#ff0000"
            $StatusBar.Text = "Please Validate Creator Employee ID"
            return 
        }
        if ($Manager -eq $false) {
            $StatusBar.ForeColor = "#ff0000"
            $StatusBar.Text = "Please Validate Manager Employee ID"
            return
        }
        $run = new-ADServiceAccount $SAccountName.text $TDescription.text $Creator $Manager
        if ($run -eq $false) {
            $StatusBar.ForeColor = "#ff0000"
            $StatusBar.Text = "Process Failed. Please verify you have permissions"
            return
        }
        else {
            $StatusBar.ForeColor = "#00b300"
            $StatusBar.Text = "Process Finished with no errors"
        }

    })
#endregion events }

#endregion GUI }




[void]$Form.ShowDialog()