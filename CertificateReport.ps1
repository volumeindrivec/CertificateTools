Import-Module ~\Documents\GitHub\CertificateTools

$Urls = 'https://www.google.com','https://www.apple.com','https://www.yahoo.com'
$Results = Get-WebCertificate -Urls $Urls
$Threshold = 45
$AboveThreshold = @()
$BelowThreshold = @()

foreach ($Result in $Results)
{
 
    $Url = $Result.Url
    $ExpiresInDays = $Result.ExpiresInDays

    if ($Result.ExpiresInDays -lt $Threshold)
    {        
        $BelowThreshold += $Result
    }
    else
    {
        $AboveThreshold += $Result
    }

}

   # CSS - Doesn't format well with Windows version of Outlook due to Word being used as rendering engine
    $css = '<style>
            table { width:98%; }
            td { text-align:center; padding:5px; }
            th { background-color:blue; color:white; }
            h3 { text-align:center }
            h6 { text-align:center }
            </style>'

$BelowThresholdHtml = $BelowThreshold | Select-Object -Property Url,Thumbprint,ExpirationDate,ExpiresInDays | ConvertTo-Html -Fragment -PreContent "<h3>BELOW THRESHOLD - These certs expire in less than $Threshold days</h3>" | Out-String
$AboveThresholdHtml = $AboveThreshold | Select-Object -Property Url,Thumbprint,ExpirationDate,ExpiresInDays | ConvertTo-Html -Fragment -PreContent "<h3>ABOVE THRESHOLD - These certs expire in $Threshold days or more</h3>" | Out-String
$FooterHtml = ConvertTo-Html -Fragment -PostContent "<h6>This report was run from:  $env:COMPUTERNAME on $(Get-Date)</h6>" | Out-String

$Report = ConvertTo-Html -Title "Certificate Expiration Report" -Body "$BelowThresholdHtml $AboveThresholdHtml $FooterHtml $css" | Out-String
$Report | Out-File ~\Documents\Github\Certs.html
