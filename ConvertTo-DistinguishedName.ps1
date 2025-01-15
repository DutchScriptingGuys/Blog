Function ConvertTo-DistinguishedName {
	[CmdletBinding()]
	[OutputType([string])]
	Param (
		[parameter(Mandatory=$true)]
		[string]$CanonicalName
	)

    [System.Collections.Generic.List[string]]$DistinguishedNameObjectsList = @()
    $DistinguishedNameObjects = $CanonicalName.Split("/")

    $Domain = $DistinguishedNameObjects[0].split(".")
    [array]::Reverse($Domain)
    $Domain | ForEach-Object { $DistinguishedNameObjectsList.Add("DC=$_") }

    $DistinguishedNameObjects[1..$($DistinguishedNameObjects.count - 2)] | ForEach-Object { $DistinguishedNameObjectsList.Add("OU=$_") }
    $DistinguishedNameObjects[-1] | ForEach-Object { $DistinguishedNameObjectsList.Add("CN=$_") }

    $DistinguishedNameObjectsList.Reverse()

    $DistinguishedName = $DistinguishedNameObjectsList -join ","

    Return $DistinguishedName
}
