function Remove-AzLACustomFieldName {
    <#
     .SYNOPSIS
     Removing custom field names
     .DESCRIPTION
     With this function you can remove custom fields names from Azure Log Analytics
     .PARAMETER subscriptionId
     Enter the subscription ID
     .PARAMETER resourceGroupName
     Enter the Resource Group of the workspace
     .PARAMETER workspaceName
     Enter the name of the workspace
     .PARAMETER tableName
     Enter the name of the table
     .PARAMETER customFieldsName
     Enter the name of the custom field that you want to delete
     .NOTES
     Created by Saggie Haim
     Contact@saggiehaim.net
     .EXAMPLE
     $subscriptionId = "XXXXX-XXXX-XXXX-XXXX-XXXXXX"
     $resourceGroupName = "test-rg"
     $workspaceName = "test-la"
     $tableName = "test_table_CL"
     $customFieldsName = "testfield_s"
     Remove-AzLACustomFieldName -workspaceName $workspaceName -resourceGroupName $resourceGroupName -subscriptionId $subscriptionId -tableName $tableName -customFieldsName $customFieldsName
     
     In this example the function will delete the testfield_s from the test_table_CL on the test-la Workspace.
   #>
   [CmdletBinding()]
   param (
       [Parameter(Mandatory)]
       [ValidateNotNullOrEmpty()]
       [string]$workspaceName,

       [Parameter(Mandatory)]
       [ValidateNotNullOrEmpty()]
       [string]$resourceGroupName,

       [Parameter(Mandatory)]
       [ValidateNotNullOrEmpty()]
       [string]$subscriptionId,

       [Parameter(Mandatory)]
       [ValidateNotNullOrEmpty()]
       [string]$tableName,
       
       [Parameter(Mandatory)]
       [ValidateNotNullOrEmpty()]
       $customFieldsName
   )

   $method = "DELETE"
   $contentType = "application/json"
   $uri = "https://management.azure.com/subscriptions/$($subscriptionId)/resourceGroups/$($resourceGroupName)/providers/Microsoft.OperationalInsights/workspaces/$($workspaceName)/customfields/$($tableName)!$($customFieldsName)?api-version=2020-08-01"
   
   write-verbose "[$(Get-Date -Format 'dd/MM/yy hh:mm')] - Pushing $($logs.count) new events to Log Analytics"
   $AzContext = Get-AzContext
   $ArmToken = [Microsoft.Azure.Commands.Common.Authentication.AzureSession]::Instance.AuthenticationFactory.Authenticate(
       $AzContext.'Account',
       $AzContext.'Environment',
       $AzContext.'Tenant'.'Id',
       $null,
       [Microsoft.Azure.Commands.Common.Authentication.ShowDialog]::Never,
       $null,
       'https://management.azure.com/'
   )
   $headers = @{
       "Authorization" = 'Bearer  ' + $ArmToken.AccessToken;
   }
   $response = Invoke-WebRequest -Uri $uri -Method $method -ContentType $contentType -Headers $headers
   if ($response.StatusCode -ge 200 -and $response.StatusCode -le 299) {
       write-verbose "[$(Get-Date -Format 'dd/MM/yy hh:mm')] - Accepted"
       if (($response.Content | ConvertFrom-Json).Error.message -like "Unknown custom field*") {
           return  ($response.Content | ConvertFrom-Json).Error.message
       }
       else {
           return "[$(Get-Date -Format 'dd/MM/yy hh:mm')] - Successfully deleted $($customFieldsName) field from $($tableName) table"
       }
   }
   else {
       return "[$(Get-Date -Format 'dd/MM/yy hh:mm')] - Failed to deleted $($customFieldsName) field from $($tableName) table: $($response.body)"
   }
}