function Set-NicMAC {
    [cmdletbinding()]
    param (
    [parameter(,
    Mandatory=$false, ValueFromPipeline)]
    [Microsoft.Management.Infrastructure.CimInstance]$nic = $null,

     [parameter(
     Mandatory=$false)]
     [string]$Mac = $false ,

     [Parameter(
     Mandatory=$false)]
     [string]$Name = $false
    )
    if ($Mac -eq $false)
    {
            Write-Warning "No MAC provided, Please provide MAC Address"
            $mac = Read-Host -Prompt "Mac address"
    }
    if ($null -eq $nic -and $Name -eq $false)
    {
            Write-Warning "No Nic provided, Please provide Nic Name"
            (Get-NetAdapter).Name
            $Name = Read-Host -Prompt "Nic Name"
    }
    if ($null -ne $nic)
    {
        Write-Host "Setting the $($nic.name) mac address to $mac"
        Set-NetAdapter -Name $($nic.name) -MacAddress $Mac
    }
    if ($Name -ne $false)
    {
        Write-Host "Setting the $Name mac address to $mac"
        Set-NetAdapter -Name $Name -MacAddress $Mac
    }
}
