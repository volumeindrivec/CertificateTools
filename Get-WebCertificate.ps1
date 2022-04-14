function Get-WebCertificate
{
    [cmdletbinding()]

    param(
        $TimeoutMs = 5000,
        $Urls = @( 'https://www.apple.com' )
    )

    $Oids = @{
        # Public Key OID - https://msdn.microsoft.com/en-us/library/ff635835.aspx
        '1.2.840.113549.1.1.1' = 'RSA'
        '1.2.840.10040.4.1' = 'DSA'
        '1.2.840.10046.2.1' = 'DH'
        '1.2.840.113549.1.1.10' = 'RSASSA-PSS'
        '1.3.14.3.2.12' = 'DSA'
        '1.2.840.113549.1.3.1' = 'DH'
        '1.3.14.3.2.22' = 'RSA_KEYX'
        '2.16.840.1.101.2.1.1.20' = 'mosaicKMandUpdSig'
        '1.2.840.113549.1.9.16.3.5' = 'ESDH'
        '1.3.6.1.5.5.7.6.2' = 'NO_SIGN'
        '1.2.840.10045.2.1' = 'ECC'
        '1.2.840.10045.3.1.7' = 'ECDSA_P256'
        '1.3.132.0.34' = 'ECDSA_P384'
        '1.3.132.0.35' = 'ECDSA_P521'
        '1.2.840.113549.1.1.7' = 'RSAES_OAEP'
        '1.3.133.16.840.63.0.2' = 'ECDH_STD_SHA1_KDF'
        # Hash Algo OID - https://msdn.microsoft.com/en-us/library/ff635603.aspx
        '1.2.840.113549.1.1.5' = 'sha1RSA'
        '1.2.840.113549.1.1.4' = 'md5RSA'
        '1.2.840.10040.4.3' = 'sha1DSA'
        '1.3.14.3.2.29' = 'sha1RSA'
        '1.3.14.3.2.15' = 'shaRSA'
        '1.3.14.3.2.3' = 'md5RSA'
        '1.2.840.113549.1.1.2' = 'md2RSA'
        '1.2.840.113549.1.1.3' = 'md4RSA'
        '1.3.14.3.2.2' = 'md4RSA'
        '1.3.14.3.2.4' = 'md4RSA'
        '1.3.14.7.2.3.1' = 'md2RSA'
        '1.3.14.3.2.13' = 'sha1DSA'
        '1.3.14.3.2.27' = 'dsaSHA1'
        '2.16.840.1.101.2.1.1.19' = 'mosaicUpdatedSig'
        '1.3.14.3.2.26' = 'sha1NoSign'
        '1.2.840.113549.2.5' = 'md5NoSign'
        '2.16.840.1.101.3.4.2.1' = 'sha256NoSign'
        '2.16.840.1.101.3.4.2.2' = 'sha384NoSign'
        '2.16.840.1.101.3.4.2.3' = 'sha512NoSign'
        '1.2.840.113549.1.1.11' = 'sha256RSA'
        '1.2.840.113549.1.1.12' = 'sha384RSA'
        '1.2.840.113549.1.1.13' = 'sha512RSA'
#        '1.2.840.113549.1.1.10' = 'RSASSA-PSS'
        '1.2.840.10045.4.1' = 'sha1ECDSA'
        '1.2.840.10045.4.3.2' = 'sha256ECDSA'
        '1.2.840.10045.4.3.3' = 'sha384ECDSA'
        '1.2.840.10045.4.3.4' = 'sha512ECDSA'
        '1.2.840.10045.4.3' = 'specifiedECDSA'
    }

    # Disabling the Certificate Validation Check.
    [Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }

    foreach ($Url in $Urls)
    {
    
        $Request                  = [Net.HttpWebRequest]::Create($Url)
        $Request.Timeout          = $TimeoutMs
    
        Try
        {
            $Request.GetResponse() | Out-Null
        }
        Catch
        {
            Write-Verbose 'If you see this, there was an error of some sort.'
        }
    
    
        [datetime]$ExpirationDate = $Request.ServicePoint.Certificate.GetExpirationDateString()
        [int]$ExpiresInDays = ($ExpirationDate - $(Get-Date)).Days
        $SerialNumber = $Request.ServicePoint.Certificate.GetSerialNumberString()
        $Thumbprint = $Request.ServicePoint.Certificate.GetCertHashString()
        $EffectiveDate = $Request.ServicePoint.Certificate.GetEffectiveDateString()
        $Issuer = $Request.ServicePoint.Certificate.Issuer
        $Subject = $Request.ServicePoint.Certificate.Subject
        $Oid = $Request.ServicePoint.Certificate.GetKeyAlgorithm()
        $KeyAlgorithm = $Oids.Item($Oid)
        $KeyAlgorithmParameters = $Request.ServicePoint.Certificate.GetKeyAlgorithmParametersString()
        $Handle = $Request.ServicePoint.Certificate.Handle
        $PublicKey = $Request.ServicePoint.Certificate.GetPublicKeyString()
    
    
        $Properties = [ordered]@{
            'Url' = $Url
            'Subject' = $Subject
            'EffectiveDate' = $EffectiveDate
            'ExpirationDate' = $ExpirationDate
            'ExpiresInDays' = $ExpiresInDays
            'SerialNumber' = $SerialNumber
            'Thumbprint' = $Thumbprint
            'Issuer' = $Issuer
            'KeyAlgorithm' = $KeyAlgorithm
            'KeyAlgorithmParameters' = $KeyAlgorithmParameters
            'Handle' = $Handle
            'PublicKey' = $PublicKey

        } # End props (object definition)
  
        $Object = New-Object -TypeName PSObject -Property $Properties
        write-output $Object

        Remove-Variable -Name 'ExpirationDate','ExpiresInDays','SerialNumber','Thumbprint','EffectiveDate','Issuer','Subject'
    
    } # End foreach
} # End function

#Get-WebCertificate | Select-Object -Property Url,Thumbprint,KeyAlgorithm,ExpirationDate,ExpiresInDays