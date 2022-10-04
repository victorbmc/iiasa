# Ensure we can run everything
Set-ExecutionPolicy Bypass -Scope Process -Force

# Copy the packages to the Chocolatey.Server repo folder
Copy-Item "$env:SystemDrive\choco-setup\packages\Push\*" -Destination "$env:SystemDrive\tools\Chocolatey.Server\App_Data\Packages\" -Force -Recurse

# Copy the license to the Chocolatey.Server repo (for v0.2.3+ downloads)
#New-Item "$env:ChocolateyToolsLocation\Chocolatey.Server\App_Data\Downloads" -ItemType Directory -Force
#Copy-Item "$env:SystemDrive\choco-setup\files\chocolatey.license.xml" -Destination "$env:ChocolateyToolsLocation\Chocolatey.Server\App_Data\Downloads\chocolatey.license.xml" -Force -Recurse