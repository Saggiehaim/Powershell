function get-ADUnuserdgroups () {
    [cmdletbinding()]
        param (
            # Parameter help description
            [parameter(Position=0,
            Mandatory=$false)]
            [switch]$Delete = $false,
            # Parameter help description
            [parameter(position=1,
            Mandatory=$false)]
            [string]$searchbase = $null,
            # Parameter help description
            [Parameter(Position=2,
            Mandatory=$false)]
            [ValidateNotNull()]
            [System.Management.Automation.PSCredential]
            [System.Management.Automation.Credential()]
            $Credential = [System.Management.Automation.PSCredential]::Empty   
        )

    if($Credential -ne [System.Management.Automation.PSCredential]::Empty) {
        Invoke-Command -ComputerName:$ComputerName -Credential:$Credential  {
            Set-ItemProperty -Path $using:Path -Name $using:Name -Value $using:Value
        }
    }    
}