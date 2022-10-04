[DSCLocalConfigurationManager()]
configuration LCMConfigNames #Configuring the LCM for pull mode configurations using configuration names
{
    param
    (
        [Parameter(Mandatory= $true)]
        [string[]]$ComputerName,

        [Parameter(Mandatory= $true)]
        [string]$regKey,

        [Parameter(Mandatory= $true)]
        [string]$pullThumbprint
    )
    
    Node $ComputerName
    {
        Settings
        {
            RefreshMode             = 'Pull'
            RefreshFrequencyMins    = 30
            RebootNodeIfNeeded      = $true
            AllowModuleOverwrite    = $true
            ConfigurationMode       = 'ApplyAndAutoCorrect'
        }
        ConfigurationRepositoryWeb DSCHTTPS
        {
            ServerURL = 'https://vm-iac.iiasa.ac.at/psdscpullserver.svc'
            RegistrationKey = $regKey
            ConfigurationNames = @('conf1')
            CertificateID = $pullThumbprint
            AllowUnsecureConnection = $false
        }

        ReportServerWeb DSCReports
        {
            ServerURL = 'https://vm-iac.iiasa.ac.at/psdscpullserver.svc'
        }
    }
}

$Computers = Get-content C:\IIASA\scripts\MOF\DisableFirewall\computers.txt

#$Computers = 'limpopo4'

# Get the cert thumbprint
$pullThumbprint = Get-ChildItem Cert:\LocalMachine\My |
    Where-Object {$_.FriendlyName -eq 'dscpull'} |
    Select-Object -ExpandProperty Thumbprint

# Get the registration key
$regkey = Get-content "$env:ProgramFiles\WindowsPowerShell\DscService\RegistrationKeys.txt"

#$fqdn = 'vm-iac.iiasa.ac.at'

# Loop through the list of computers and set the LCM
Foreach ($computer in $computers){
    $session = New-CimSession -ComputerName $computer
    LCMConfigNames -ComputerName $computer -pullThumbprint $pullThumbprint -regKey $regkey -OutputPath C:\IIASA\scripts\MOF\DisableFirewall\
    Set-DscLocalConfigurationManager -CimSession $session -Path C:\IIASA\scripts\MOF\DisableFirewall\ -Force -Verbose
}

# Check the progress on the Endpoint
$session = New-CimSession -ComputerName limpopo4, tejo7

Get-DscConfigurationStatus -CimSession $session

# Manually force the LCM to run 
Update-DscConfiguration -CimSession $session -Verbose -Wait