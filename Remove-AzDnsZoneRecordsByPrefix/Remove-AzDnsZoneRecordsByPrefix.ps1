function Remove-AzDnsZoneRecordsByPrefix 
{
    param
    (
        [string]
        [Parameter(Mandatory = $true)]
        $RecordPrefix,

        [string]
        [Parameter(Mandatory = $true)]
        $ZoneName,

        [string]
        [Parameter(Mandatory = $true)]
        $ResourceGroupName,

        [string]
        [Parameter(Mandatory = $true)]
        $RecordType
    )

    $Records = Get-AzDnsRecordSet -ZoneName $ZoneName -ResourceGroupName $ResourceGroupName -RecordType $RecordType | Where-Object {$_.Name -match "$($RecordPrefix)(.*)"}

    if ($Records)
    {
        $Records | ForEach-Object {$_ | Remove-AzDnsRecordSet}
    }
    else
    {
        throw "No records found in DNS Zone $($ZoneName) with a prefix of $($RecordPrefix)"
    }
}