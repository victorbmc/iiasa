configuration DisableFirewall {
    param ()
    Import-DscResource –ModuleName NetworkingDsc
    Import-DscResource -ModuleName PsDesiredStateConfiguration
    Import-DSCResource -ModuleName xNetworking

    Node conf1
    {
        FirewallProfile DisableFirewall
        {
            Name = 'Domain'
            Enabled = 'True'
        }

        xFirewall EnableV4PingIn
        {
            Name = "FPS-ICMP4-ERQ-In"
            Enabled = "True"
        }

        xFirewall EnableV4PingOut
        {
            Name = "FPS-ICMP4-ERQ-Out"
            Enabled = "True"
        }

        xFirewall EnableV6PingIn
        {
            Name = "FPS-ICMP6-ERQ-In"
            Enabled = "True"
        }

        xFirewall EnableV6PingOut
        {
            Name = "FPS-ICMP6-ERQ-Out"
            Enabled = "True"
        }
    }
}

# **NOTE:** The code above is the actual node configuration, everything below is used to create and stage the mof files

# Set the output path
$outputPath = 'C:\IIASA\DSC\Conf1\1'

# Generate the MOF
DisableFirewall -outputPath $outputPath

# Generate the Checksum for the MOF
New-DscChecksum -Path $outputPath -OutPath $outputPath -Verbose

# Move Config to Configurations folder on Pull Server
# $session = New-PSSession SVR19
$source = "$outputPath\*"
$Dest = 'C:\Program Files\WindowsPowerShell\DscService\Configuration'

Copy-Item -Path $Source -Destination $Dest -Recurse -Force -Verbose

# Package and Publish the NetworkingDsc Module 
$ModuleList = @("NetworkingDsc", "PsDesiredStateConfiguration", "xNetworking" )
Publish-DscModuleAndMof -Source $outputPath -ModuleNameList $ModuleList -Force