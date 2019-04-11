function Set-NicMAC {
    [cmdletbinding()]
    param (
    [parameter(Position=0,
    Mandatory=$false, ValueFromPipeline)]
    [Microsoft.Management.Infrastructure.CimInstance]$nic = $null,

     [parameter(Position=1,
     Mandatory=$false)]
     [string]$Mac = $false ,

     [Parameter(Position=1,
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
        Set-NetAdapter -Name $nic.name -MacAddress $Mac
    }
    if ($nicName -ne $false)
    {
        Write-Host "Setting the $Name mac address to $mac"
        Set-NetAdapter -Name $Name -MacAddress $Mac
    }
}

Get-NetAdapter -name "Wi-Fi" | Set-NicMAC
