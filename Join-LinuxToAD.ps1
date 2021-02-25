# Add CentOS 7 machine to Active Directory

function Join-LinuxToAD {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$DomainName,
        [Parameter(Mandatory=$true)]
        [string]$UserName 
    )
        #Is this host Linux?
        if (!$IsLinux)
        {
            Write-Error -Message 'This host is not Linux. Exiting'
            exit
        }
        #Ensure you can lookup AD DNS
        nslookup $DomainName | Out-Null
        if ($LASTEXITCODE -ne 0)
        {
            Write-Error -Message 'Could not find domain in DNS. Checking settings'
            exit
        }

        #Ensure Samba and dependencies installed
        yum install sssd realmd oddjob oddjob-mkhomedir adcli samba-common samba-common-tools krb5-workstation openldap-clients policycoreutils-python -y | Out-Null
        if ($LASTEXITCODE -ne 0)
        {
            Write-Error -Message 'Could not install one or more dependencies'
            exit
        }

        #Join domain with realm
        realm join $DomainName --user=$UserName
        if ($LASTEXITCODE -ne 0)
        {
            Write-Error -Message "Could not join domain $DomainName. See error output"
            exit
        }
        if ($LASTEXITCODE -eq 0)
        {
            Write-Output 'Yay! Your host is joined!'
        }
}