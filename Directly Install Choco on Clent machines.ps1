# This is a base url and should not include the "/chocolatey" (for Chocolatey.Server) or any url path to a NuGet/Chocolatey Packages API
$baseUrl = "http://vm-iac.iiasa.ac.at"
# this is the sub path, it will combine the above with this in the script $baseUrl/$repositoryUrlPath
$repositoryUrlPath = "chocolatey"

# Ensure we can run everything
Set-ExecutionPolicy Bypass -Scope Process -Force;

# Reroute TEMP to a local location
New-Item $env:ALLUSERSPROFILE\choco-cache -ItemType Directory -Force
$env:TEMP = "$env:ALLUSERSPROFILE\choco-cache"

# Ignore proxies since we are using internal locations
$env:chocolateyIgnoreProxy = 'true'
# Set proxy settings if necessary
#$env:chocolateyProxyLocation = 'https://local/proxy/server'
#$env:chocolateyProxyUser = 'username'
#$env:chocolateyProxyPassword = 'password'

# Install Chocolatey
# This is for use with Chocolatey.Server only:
iex ((New-Object System.Net.WebClient).DownloadString("$baseUrl/install.ps1"))
# You'll need to also use the script you used for local installs to get Chocolatey installed.

# Are you military, government, or for some other reason have FIPS compliance turned on?
#choco feature enable --name="'useFipsCompliantChecksums'"

# Sources - Remove community repository
choco source remove --name="'internal_machine'"

# Sources - Add your internal repositories
# This is Chocolatey.Server specific (add other options like auth/allow self service as needed - https://docs.chocolatey.org/en-us/choco/commands/source):
choco source add --name="'internal_server'" --source="'$baseUrl/$repositoryUrlPath'" --priority="'1'" --bypass-proxy
choco source list
#TODO: Add other sources here

# Add license to setup and to local install
choco upgrade chocolatey-license -y

# Sources - Disable licensed source
choco source disable --name="'chocolatey.licensed'"
Write-Host "You can ignore the red text in the output above, as it is more of a warning until we have chocolatey.extension installed"

# Install Chocolatey Licensed Extension
choco upgrade chocolatey.extension -y --pre

# Set Configuration
choco config set cacheLocation $env:ALLUSERSPROFILE\choco-cache
choco config set commandExecutionTimeoutSeconds 14400
#TODO: Add other items you would configure here
# https://docs.chocolatey.org/en-us/configuration

# Set Licensed Configuration
choco feature enable --name="'internalizeAppendUseOriginalLocation'"
choco feature enable --name="'reduceInstalledPackageSpaceUsage'"
#TODO: Add other items you would configure here
# https://docs.chocolatey.org/en-us/configuration

#TODO: Are we installing the Chocolatey Agent Service?
# https://docs.chocolatey.org/en-us/agent/setup
# choco upgrade chocolatey-agent -y --pre
#choco feature disable --name="'showNonElevatedWarnings'"
#choco feature enable --name="'useBackgroundService'"
#choco feature enable --name="'useBackgroundServiceWithNonAdministratorsOnly'"
#TODO: Check out other options and features to set at the url above.
#TODO: Also make sure you set your sources to allow for self-service