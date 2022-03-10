function Get-DatabaseSpaceUsedByPool
{
    param
    (
        [string]
        [Parameter(Mandatory = $true)]
        $ResourceGroupName,

        [string]
        [Parameter(Mandatory = $true)]
        $ServerName,

        [string]
        [Parameter(Mandatory = $true)]
        $PoolName,

        [string]
        [Parameter(Mandatory = $true)]
        $UserName,

        [string]
        [Parameter(Mandatory = $true)]
        $Password
    )

    $DatabasesInPool = Get-AzSqlElasticPoolDatabase -ResourceGroupName $ResourceGroupName -ServerName $ServerName -ElasticPoolName $PoolName

    $Query = "SELECT DB_NAME() as DatabaseName, `
        SUM(size/128.0) AS DatabaseDataSpaceAllocatedInMB, `
        SUM(size/128.0 - CAST(FILEPROPERTY(name, 'SpaceUsed') AS int)/128.0) AS DatabaseDataSpaceAllocatedUnusedInMB `
        FROM sys.database_files `
        GROUP BY type_desc `
        HAVING type_desc = 'ROWS'"

    $ServerFqdn = "$($ServerName).database.windows.net"

    $DatabaseStorageMetrics = @()

    foreach ($database in $DatabasesInPool) {
        $DatabaseStorageMetrics += (Invoke-Sqlcmd -ServerInstance $ServerFqdn -Database $database.DatabaseName -Username $UserName -Password $Password -Query $Query)
    }

    Write-Output "`n" "ElasticPoolName: $PoolName"
    Write-Output $DatabaseStorageMetrics | Sort -Property DatabaseDataSpaceAllocatedUnusedInMB -Descending | Format-Table

}