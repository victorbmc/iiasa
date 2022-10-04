configuration InstallChoco
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
    #Install-Module -Name PSDesiredStateConfiguration
    #Install-Module -Name xPSDesiredStateConfiguration
    #Install-WindowsFeature -name Web-Server -IncludeManagementTools

    Import-DscResource -ModuleName cChoco
    Import-DSCResource -ModuleName PSDesiredStateConfiguration
    Import-DSCResource -ModuleName xPSDesiredStateConfiguration

    Node $NodeName
    {
        WindowsFeature DSCServiceFeature
        {
            Ensure = "Present"
            Name   = "DSC-Service"
        }

        cChocoInstaller InstallChoco
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
            InstallDir = "c:\choco"
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

$config = InstallChoco

$Computers = Get-content E:\IIASA\Computers\computers.txt #$Computers = 'limpopo4'

# To find the Thumbprint for an installed SSL certificate for use with the pull server list all
# certificates in your local store and then copy the thumbprint for the appropriate certificate
# by     reviewing the certificate subjects

dir Cert:\LocalMachine\my

#$cert = Get-ChildItem Cert:\LocalMachine\my | Where-Object CN -eq 'PullDSC'

#generate Registration Key

[guid]::newGuid()

# Then include this thumbprint when running the configuration
InstallChoco -certificateThumbprint 'B20AF545037C9C9248DA469C940BCC61E3E5572D' -RegistrationKey '15da222f-9ed3-4051-a16c-3b63f37b91a7' -OutputPath c:\Configs\PullServer

# Run the compiled configuration to make the target node a DSC Pull Server
#Start-DscConfiguration -Path c:\Configs\PullServer -Wait -Verbose
$session = New-CimSession -ComputerName limpopo4

Foreach ($computer in $computers){
    $session = New-CimSession -ComputerName $computer
    Start-DscConfiguration -Path $config.psparentpath -Wait -Verbose -Force
}
