# ----------------------------------------------------------------------------------
#
# Copyright Microsoft Corporation
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ----------------------------------------------------------------------------------

<#
.SYNOPSIS
    Run AzureStack subscription admin tests.

.DESCRIPTION
    Run AzureStack subscriptions admin tests using either mock client or our client.
	The mock client allows for recording and playback.  This allows for offline tests.

.PARAMETER RunRaw
    Run using our client creation path.

.EXAMPLE
    PS C:\> .\src\DirectoryTenant.Tests.ps1
	Describing DirectoryTenant
	  [+] TestListDirectoryTenants 1.33s
	  [+] TestGetAllDirectoryTenants 2.14s

.NOTES
    Author: Mike Giesler
	Copyright: Microsoft
    Date:   March 16, 2018
#>
param(
    [bool]$RunRaw = $false,
    [bool]$UseInstalled = $false
)
$Global:UseInstalled = $UseInstalled
$Global:RunRaw = $RunRaw

. $PSScriptRoot\CommonModules.ps1

InModuleScope Azs.Subscriptions.Admin {

    Describe "DirectoryTenant" -Tags @('DirectoryTenants', 'SubscriptionsAdmin') {

        BeforeEach {

            . $PSScriptRoot\Common.ps1

            function ValidateDirectoryTenant {
                param(
                    [Parameter(Mandatory = $true)]
                    $DirectoryTenant
                )
                # Overall
                $DirectoryTenant               | Should Not Be $null

                # Resource
                $DirectoryTenant.Id            | Should Not Be $null
                $DirectoryTenant.Name          | Should Not Be $null
                $DirectoryTenant.Type          | Should Not Be $null
                $DirectoryTenant.Location      | Should Not Be $null

                # DirectoryTenant
                $DirectoryTenant.TenantId      | Should Not Be $null
            }

            function AssertDirectoryTenantsSame {
                param(
                    [Parameter(Mandatory = $true)]
                    $Expected,

                    [Parameter(Mandatory = $true)]
                    $Found
                )
                if ($Expected -eq $null) {
                    $Found | Should Be $null
                } else {
                    $Found                | Should Not Be $null

                    # Resource
                    $Found.Id             | Should Be $Expected.Id
                    $Found.Location       | Should Be $Expected.Location
                    $Found.Name           | Should Be $Expected.Name
                    $Found.Type           | Should Be $Expected.Type

					# DirectoryTenant
					$Found.TenantId       | Should Be $Expected.TenantId
                }
            }
        }

        It "TestListDirectoryTenants" {
            $global:TestName = 'TestListDirectoryTenants'

            $allDirectoryTenants = Get-AzsDirectoryTenant -ResourceGroupName System.local

            foreach($DirectoryTenant in $allDirectoryTenants) {
				ValidateDirectoryTenant $DirectoryTenant
            }
        }

		It "TestGetAllDirectoryTenants" {
            $global:TestName = 'TestGetAllDirectoryTenants'

            $allDirectoryTenants = Get-AzsDirectoryTenant -ResourceGroupName System.local

            foreach($DirectoryTenant in $allDirectoryTenants) {
				$tenant2 = Get-AzsDirectoryTenant -Name $DirectoryTenant.Name -ResourceGroupName System.local
				AssertDirectoryTenantsSame $DirectoryTenant $tenant2
            }
		}
	}
}
