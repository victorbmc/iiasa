[DscLocalConfigurationManager()]
Configuration PartialConfigLcmConfigNames
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
        Settings
        {
            RefreshFrequencyMins            = 30;
            RefreshMode                     = "PULL";
            ConfigurationMode               ="ApplyAndAutocorrect";
            AllowModuleOverwrite            = $true;
            RebootNodeIfNeeded              = $true;
            ConfigurationModeFrequencyMins  = 60;
        }
        ConfigurationRepositoryWeb DSCHTTPS
        {
            ServerURL = 'https://vm-iac.iiasa.ac.at/psdscpullserver.svc'
            RegistrationKey = $regKey
            ConfigurationNames = @('conf1') # @("ServiceAccountConfig", "SharePointConfig") - Name of the configuration (Function) in the config file, NOT the name of the MOF
            CertificateID = $pullThumbprint
            AllowUnsecureConnection = $false
        }

        ReportServerWeb DSCReports
        {
            ServerURL = 'https://vm-iac.iiasa.ac.at/psdscpullserver.svc'
        }

        PartialConfiguration ServiceAccountConfig
        {
            Description                     = "ServiceAccountConfig" #Name of the Function in the partial config file
            ConfigurationSource             = @("[ConfigurationRepositoryWeb]DSCHTTPS")
            RefreshMode                     = 'Pull'
        }

        PartialConfiguration SharePointConfig
        {
            Description                     = "SharePointConfig" #Name of the Function in the partial config file
            ConfigurationSource             = @("[ConfigurationRepositoryWeb]DSCHTTPS")
            DependsOn                       = '[PartialConfiguration]ServiceAccountConfig' #May not need to depend on
            RefreshMode                     = 'Pull'
        }
}


# You can pull partial configurations from more than one pull server—you would just need to define each pull server, 
# and then refer to the appropriate pull server in each PartialConfiguration block.

$Computers = Get-content C:\IIASA\scripts\MOF\DisableFirewall\computers.txt

#$Computers = 'limpopo4'

# Get the cert thumbprint
$pullThumbprint = Get-ChildItem Cert:\LocalMachine\My |
    Where-Object {$_.FriendlyName -eq 'PullDSC'} |
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