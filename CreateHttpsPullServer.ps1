configuration DscWebServiceRegistration
{
    param
    (
        [string[]]$NodeName = 'vm-iac.iiasa.ac.at',

        [ValidateNotNullOrEmpty()]
        [string] $certificateThumbPrint,

        [Parameter(HelpMessage='This should be a string with enough entropy (randomness) to protect the registration of clients to the pull server.  We will use new GUID by default.')]
        [ValidateNotNullOrEmpty()]
        [string] $RegistrationKey   # A guid that clients use to initiate conversation with pull server
    )
    #Install-Module -Name PSDesiredStateConfiguration -Force
    #Install-Module -Name xPSDesiredStateConfiguration
    #Install-WindowsFeature -name Web-Server -IncludeManagementTools

    Import-DSCResource -ModuleName PSDesiredStateConfiguration
    Import-DSCResource -ModuleName xPSDesiredStateConfiguration

    Node $NodeName
    {
        WindowsFeature DSCServiceFeature
        {
            Ensure = "Present"
            Name   = "DSC-Service"
        }

        xDscWebService PSDSCPullServer
        {
            Ensure                  = "Present"
            EndpointName            = "PSDSCPullServer"
            Port                    = 443
            PhysicalPath            = "$env:SystemDrive\inetpub\PSDSCPullServer"
            CertificateThumbPrint   = $certificateThumbPrint
            ModulePath              = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Modules"
            ConfigurationPath       = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Configuration"
            State                   = "Started"
            DependsOn               = "[WindowsFeature]DSCServiceFeature"
            RegistrationKeyPath     = "$env:PROGRAMFILES\WindowsPowerShell\DscService"
            AcceptSelfSignedCertificates = $true
            UseSecurityBestPractices     = $true
            Enable32BitAppOnWin64   = $false
        }

        File RegistrationKeyFile
        {
            Ensure          = 'Present'
            Type            = 'File'
            DestinationPath = "$env:ProgramFiles\WindowsPowerShell\DscService\RegistrationKeys.txt"
            Contents        = $RegistrationKey 
        }
    }
}



# To find the Thumbprint for an installed SSL certificate for use with the pull server list all
# certificates in your local store and then copy the thumbprint for the appropriate certificate
# by     reviewing the certificate subjects

dir Cert:\LocalMachine\my

#$cert = Get-ChildItem Cert:\LocalMachine\my | Where-Object CN -eq 'PullDSC'

#generate Registration Key

[guid]::newGuid()   

# Then include this thumbprint when running the configuration
DscWebServiceRegistration -certificateThumbprint 'B20AF545037C9C9248DA469C940BCC61E3E5572D' -RegistrationKey '8daca114-bd24-4f76-ac87-4169eafae4fe' -OutputPath c:\Configs\PullServer

# Run the compiled configuration to make the target node a DSC Pull Server
Start-DscConfiguration -Path c:\Configs\PullServer -Wait -Verbose

