# Write csv files containing databases that are in one pool that don't have a corresponding secondary database in another pool
# Used to calculate drift from Primary and Secondary Azure sql servers with Failover Groups and Elastic Pools
function Get-DatabaseDifferentialByPool
{
    param 
    (
        [string]
        [Parameter(Mandatory = $true)]
        $PrimaryResourceGroupName, 

        [string]
        [Parameter(Mandatory = $true)]
        $SecondaryResourceGroupName,

        [string]
        [Parameter(Mandatory = $true)]
        $PrimarySqlServerName,

        [string]
        [Parameter(Mandatory = $true)]
        $SecondarySqlServerName,

        [string]
        [Parameter(Mandatory = $true)]
        $PrimaryPoolName,

        [string]
        [Parameter(Mandatory = $true)]
        $SecondaryPoolName
    )

    $PrimaryDatabases = Get-AzSqlDatabase -ResourceGroupName $PrimaryResourceGroupName -ServerName $PrimarySqlServerName | Where-Object { $_.ElasticPoolName -eq $PrimaryPoolName }
    $SecondaryDatabases = Get-AzSqlDatabase -ResourceGroupName $SecondaryResourceGroupName -ServerName $SecondarySqlServerName | Where-Object { $_.ElasticPoolName -eq $SecondaryPoolName }

    $PrimaryDatabasesNames = $PrimaryDatabases | ForEach-Object { $_.DatabaseName }
    $SecondaryDatabasesNames = $SecondaryDatabases | ForEach-Object { $_.DatabaseName }
    
    $PrimaryDiff = @()
    $SecondaryDiff = @()

    $PrimaryDatabasesNames | Where-Object {$SecondaryDatabasesNames -notcontains $_} | ForEach-Object {
        $PrimaryDiff += [PSCustomObject]@{
            Name = $_
        }
    }
    $SecondaryDatabasesNames | Where-Object {$PrimaryDatabasesNames  -notcontains $_} | ForEach-Object {
        $SecondaryDiff += [PSCustomObject]@{
            Name = $_
        }
    }

    $PrimaryDiff | Export-Csv -Path "PrimaryDiff.csv" -NoTypeInformation
    $SecondaryDiff | Export-Csv -Path "SecondaryDiff.csv" -NoTypeInformation
}