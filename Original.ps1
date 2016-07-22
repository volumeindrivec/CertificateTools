##  ORIGINAL CODE AND CONCEPT FROM HERE:  http://iamoffthebus.wordpress.com/2014/02/04/powershell-to-get-remote-websites-ssl-certificate-expiration/
##  This code is what I based my Get-WebCertificate tool off of.

$minimumCertAgeDays                                             = 60
 $timeoutMilliseconds                                           = 10000
 $urls                                                          = @(
  "https://www.yahoo.com",
  "https://www.google.com",
  "https://www.apple.com"
 )
#disabling the cert validation check. This is what makes this whole thing work with invalid certs...
 [Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
foreach ($url in $urls)
 {
  Write-Host Checking $url -f Green
  $req                  = [Net.HttpWebRequest]::Create($url)
  $req.Timeout          = $timeoutMilliseconds
  try {$req.GetResponse() |Out-Null} catch {Write-Host Exception while checking URL $url`: $_ -f Red}
  [datetime]$expiration = $req.ServicePoint.Certificate.GetExpirationDateString()
  [int]$certExpiresIn   = ($expiration - $(get-date)).Days
  $certName             = $req.ServicePoint.Certificate.GetName()
  $certPublicKeyString  = $req.ServicePoint.Certificate.GetPublicKeyString()
  $certSerialNumber     = $req.ServicePoint.Certificate.GetSerialNumberString()
  $certThumbprint       = $req.ServicePoint.Certificate.GetCertHashString()
  $certEffectiveDate    = $req.ServicePoint.Certificate.GetEffectiveDateString()
  $certIssuer           = $req.ServicePoint.Certificate.GetIssuerName()
  
  if ($certExpiresIn -gt $minimumCertAgeDays)
  {Write-Host Cert for site $url expires in $certExpiresIn days [on $expiration] -f Green}
  else
  {Write-Host Cert for site $url expires in $certExpiresIn days [on $expiration] Threshold is $minimumCertAgeDays days. Check details:`n`nCert name: $certName`nCert public key: $certPublicKeyString`nCert serial number: $certSerialNumber`nCert thumbprint: $certThumbprint`nCert effective date: $certEffectiveDate`nCert issuer: $certIssuer -f Red}
  #Remove-Variable req
  Remove-Variable expiration
  Remove-Variable certExpiresIn
 }