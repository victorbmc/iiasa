# Copyright (c) 2017 Chocolatey Software, Inc.
# Copyright (c) 2013 - 2017 Lawrence Gripper & original authors/contributors from https://github.com/chocolatey/cChoco
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#Install-Module -Name cChocoInstaller

Configuration InstallChoco
{
    Import-DscResource -ModuleName cChoco

    Node localhost
    {
        cChocoInstaller InstallChoco
        {
            InstallDir = "c:\choco"

        }
    }
}
InstallChoco

$config = InstallChoco

$Computers = Get-content E:\IIASA\Computers\computers.txt #$Computers = 'limpopo4'

Start-DscConfiguration -Path $config.psparentpath -Wait -Verbose -Force

# Loop through the list of computers and set the LCM
Foreach ($computer in $computers){
    $session = New-CimSession -ComputerName $computer
    Start-DscConfiguration -Path $config.psparentpath -Wait -Verbose -Force
}

# Check the progress on the Endpoint
$session = New-CimSession -ComputerName limpopo4, tejo7

Get-DscConfigurationStatus -CimSession $session