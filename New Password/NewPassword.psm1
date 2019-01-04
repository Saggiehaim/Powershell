## Generate Password Function
Function New-Password()
{
    <# 
 .SYNOPSIS 
     Password Generator 
 
 .DESCRIPTION 
     The New-Password cmdlet allow you to generate random passwords. 
   
 .PARAMETER NumberofPasswords 
     Specifies Number of passwored to generate. Default is 1 random password. 

 .PARAMETER AsSecureString
     Return passwords as secure strings.
 
 .PARAMETER Length 
     Specifies the passwored length. Defualt is 12 chars 
  
 .EXAMPLE 
        New-Password 
        S0XOxe8SvaYW

  .EXAMPLE
        New-Password -NumberofPasswords 10
        VMLMu2DVLg6a
        H0faw#W6N@@H
        WZ0FV7U7jbVB
        p6vDelWGmefS
        HR9Ewjg#WQt3
        qrHYJdRTWaex
        q6meEJztl80R
        oNDals6@DrI7
        kKJVCbvAhFXm
        f4@8xTsUYpAI

    .EXAMPLE
            New-Password -Length 20
            e00yosTnRvthCHiJYKJs

    .EXAMPLE
            New-Password -NumberofPasswords 5 -Length 6
            ZSQHsL
            RqU5cY
            F7STnb
            DD34@O
            9drhe4
    
    .EXAMPLE
            New-Password -NumberofPasswords 1 -Length 10 -AsSecureString
            WARNING: Converting the Password 3@jedeVcjoBf to secure string, this is the last time you will see it.
            System.Security.SecureString

 .NOTES 
  Author: Saggie Haim 
  Contact@saggiehaim.net
 #>
    [cmdletbinding()]
    param (
    [parameter(Position=0,
    Mandatory=$false)]
    [string]$NumberofPasswords = 1,

     [parameter(Position=1,
     Mandatory=$false)]
     [string]$Length = 12,

     [Parameter(Position=1,
     Mandatory=$false)]
     [switch]$AsSecureString = $false
    )
    $passwords = @()
    $inputRange = 48..122
    $inputRange += 33,35
    $exclude = 91..96
    $exclude += 58..63
    $randomRange = $inputRange | Where-Object { $exclude -notcontains $_}
    For($j=0;$j -lt $NumberofPasswords; $j++)
    {
        $pass = $null
        For($i=0;$i -lt $Length; $i++){
        $rnd=(Get-Random -InputObject $randomRange) 
        $char=[char]$rnd
        $pass += $char
        }
        $passwords += $pass
        
     }
     if ($AsSecureString -eq $true)
     {
         $passwords = $passwords |  ForEach-Object {Write-Warning "Converting the Password $_ to secure string, this is the last time you will see it."; ConvertTo-SecureString -String $_ -AsPlainText -Force}
         return $passwords
     }
     Return $Passwords
    }
