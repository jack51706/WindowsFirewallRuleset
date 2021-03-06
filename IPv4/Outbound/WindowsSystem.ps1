
<#
MIT License

Copyright (c) 2019 metablaster zebal@protonmail.ch

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
#>

# Includes
. $PSScriptRoot\DirectionSetup.ps1
. $PSScriptRoot\..\IPSetup.ps1
Import-Module -Name $PSScriptRoot\..\..\FirewallModule

#
# Setup local variables:
#
$Group = "Windows System"
$Profile = "Private, Public"

# Ask user if he wants to load these rules
Update-Context $IPVersion $Direction $Group
if (!(Approve-Execute)) { exit }

# First remove all existing rules matching group
Remove-NetFirewallRule -PolicyStore $PolicyStore -Group $Group -Direction $Direction -ErrorAction SilentlyContinue

#
# Windows system rules
# Rules that apply to Windows programs and utilities, which are not handled by predefined rules
#

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Activation Client" -Service Any -Program "%SystemRoot%\System32\slui.exe" `
-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 80, 443 `
-LocalUser Any `
-Description "Used to activate Windows."

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Activation KMS" -Service Any -Program "%SystemRoot%\System32\SppExtComObj.Exe" `
-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 1688 `
-LocalUser Any `
-Description "Activate Office and KMS based software."

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Application Block Detector" -Service Any -Program "%SystemRoot%\System32\CompatTel\QueryAppBlock.exe" `
-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 80 `
-LocalUser Any `
-Description "Its purpose is to scans your hardware, devices, and installed programs for known compatibility issues
with a newer Windows version by comparing them against a specific database."

# TODO: need to check if port 22 is OK.
New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Background task host" -Service Any -Program "%SystemRoot%\System32\backgroundTaskHost.exe" `
-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 22, 80 `
-LocalUser Any `
-Description "backgroundTaskHost.exe is the process that starts background tasks.
So Cortana and the other Microsoft app registered a background task which is now started by Windows.
Port 22 is most likely used for installation.
https://docs.microsoft.com/en-us/windows/uwp/launch-resume/support-your-app-with-background-tasks"

# TODO: no comment
New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Cortana Speach Runtime" -Service Any -Program "%SystemRoot%\System32\Speech_OneCore\common\SpeechRuntime.exe" `
-PolicyStore $PolicyStore -Enabled True -Action Block -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 443 `
-LocalUser Any `
-Description ""

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Cortana Speach Model" -Service Any -Program "%SystemRoot%\System32\Speech_OneCore\common\SpeechModelDownload.exe" `
-PolicyStore $PolicyStore -Enabled True -Action Block -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 443 `
-LocalUser $NT_AUTHORITY_NetworkService `
-Description ""

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Customer Experience Improvement Program" -Service Any -Program "%SystemRoot%\System32\wsqmcons.exe" `
-PolicyStore $PolicyStore -Enabled True -Action Block -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 80, 443 `
-LocalUser Any `
-Description "This program collects and sends usage data to Microsoft, can be disabled in GPO."

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Microsoft Compatibility Telemetry" -Service Any -Program "%SystemRoot%\System32\CompatTelRunner.exe" `
-PolicyStore $PolicyStore -Enabled True -Action Block -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 443 `
-LocalUser $NT_AUTHORITY_System `
-Description "The CompatTelRunnere.exe process is used by Windows to perform system diagnostics to determine if there are any compatibility issues.
It also collects program telemetry information (if that option is selected) for the Microsoft Customer Experience Improvement Program.
This allows Microsoft to ensure compatibility when installing the latest version of the Windows operating system.
This process also takes place when upgrading the operating system.
To disable this program: Task Scheduler Library > Microsoft > Windows > Application Experience
In the middle pane, you will see all the scheduled tasks, such as Microsoft Compatibility Appraiser, ProgramDataUpdater and SartupAppTask.
Right-click on the Microsoft Compatibility Appraiser and select Disable."

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Windows Indexing Service" -Service Any -Program "%SystemRoot%\System32\SearchProtocolHost.exe" `
-PolicyStore $PolicyStore -Enabled True -Action Block -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 443 `
-LocalUser Any `
-Description "SearchProtocolHost.exe is part of the Windows Indexing Service,
an application that indexes files on the local drive making them easier to search."

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Error Reporting" -Service Any -Program "%SystemRoot%\System32\WerFault.exe" `
-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 443 `
-LocalUser Any `
-Description "Report Windows errors back to Microsoft."

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Error Reporting" -Service Any -Program "%SystemRoot%\System32\wermgr.exe" `
-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 443 `
-LocalUser Any `
-Description "Report Windows errors back to Microsoft."

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "File Explorer" -Service Any -Program "%SystemRoot%\explorer.exe" `
-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 80 `
-LocalUser Any `
-Description "File explorer checks for digital signatures verification, windows update."

# TODO: possible deprecate
New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "File Explorer" -Service Any -Program "%SystemRoot%\explorer.exe" `
-PolicyStore $PolicyStore -Enabled True -Action Block -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 443 `
-LocalUser Any `
-Description "Smart Screen Filter, possible no longer needed since windows 10."

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "FTP Client" -Service Any -Program "%SystemRoot%\System32\ftp.exe" `
-PolicyStore $PolicyStore -Enabled True -Action Block -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4, LocalSubnet4 -LocalPort Any -RemotePort 21 `
-LocalUser Any `
-Description "File transfer protocol client."

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Help pane" -Service Any -Program "%SystemRoot%\HelpPane.exe" `
-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 80 `
-LocalUser Any `
-Description "Get online help, looks like windows 10+ no longer uses this, it opens edge now to show help."

# TODO: program possibly no longer uses networking since windows 10
New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "DLL host process" -Service Any -Program "%SystemRoot%\System32\rundll32.exe" `
-PolicyStore $PolicyStore -Enabled False -Action Block -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 80, 443 `
-LocalUser Any `
-Description "Loads and runs 32-bit dynamic-link libraries (DLLs), There are no configurable settings for Rundll32.
possibly no longer uses networking since windows 10."

# TODO: no comment
New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Install Compability Advisor Inventory Tool" -Service Any -Program "%SystemRoot%\System32\CompatTel\wicainventory.exe" `
-PolicyStore $PolicyStore -Enabled True -Action Block -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 80 `
-LocalUser Any `
-Description ""

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Installer" -Service Any -Program "%SystemRoot%\System32\msiexec.exe" `
-PolicyStore $PolicyStore -Enabled True -Action Block -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 80 `
-LocalUser Any `
-Description "msiexec automatically check for updates for the program it is installing."

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Local Security Authority Process" -Service Any -Program "%SystemRoot%\System32\lsass.exe" `
-PolicyStore $PolicyStore -Enabled True -Action Block -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 80 `
-LocalUser Any `
-Description "Lsas.exe a process in Microsoft Windows operating systems that is responsible for enforcing the security policy on the system.
It specifically deals with local security and login policies.It verifies users logging on to a Windows computer or server,
handles password changes, and creates access tokens."

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "MMC Help Viewer" -Service Any -Program "%SystemRoot%\System32\mmc.exe" `
-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 443 `
-LocalUser Any `
-Description "Display webpages in Microsoft MMC help view."

# TODO: no comment
New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Name server lookup" -Service Any -Program "%SystemRoot%\System32\nslookup.exe" `
-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress Internet4, DefaultGateway4 -LocalPort Any -RemotePort 53 `
-LocalUser Any -LocalOnlyMapping $false -LooseSourceMapping $false `
-Description ""

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Settings sync" -Service Any -Program "%SystemRoot%\System32\SettingSyncHost.exe" `
-PolicyStore $PolicyStore -Enabled True -Action Block -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 80, 443 `
-LocalUser Any `
-Description "Host process for setting synchronization. Open your PC Settings and go to the 'Sync your Settings' section.
There are on/off switches for all the different things you can choose to sync.
Just turn off the ones you don't want. Or you can just turn them all off at once at the top."

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Smartscreen" -Service Any -Program "%SystemRoot%\System32\smartscreen.exe" `
-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 443 `
-LocalUser Any `
-Description ""

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "SystemSettings" -Service Any -Program "%SystemRoot%\ImmersiveControlPanel\SystemSettings.exe" `
-PolicyStore $PolicyStore -Enabled True -Action Block -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 443 `
-LocalUser Any `
-Description "Seems like it's connecting to display some 'useful tips' on the right hand side of the settings menu,
NOTE: Configured the gpo 'Control Panel\allow online tips' to 'disabled'."

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "taskhostw" -Service Any -Program "%SystemRoot%\System32\taskhostw.exe" `
-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 443 `
-LocalUser Any `
-Description "The main function of taskhostw.exe is to start the Windows Services based on DLLs whenever the computer boots up.
It is a host for processes that are responsible for executing a DLL rather than an Exe."

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Service Initiated Healing" -Service Any -Program "%SystemRoot%\System32\sihclient.exe" `
-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 443 `
-LocalUser Any `
-Description "sihclient.exe SIH Client is the client for fixing system components that are important for automatic Windows updates.
This daily task runs the SIHC client (initiated by the healing server) to detect and repair system components that are vital to
automatically update Windows and the Microsoft software installed on the computer.
The task can go online, assess the usefulness of the healing effect,
download the necessary equipment to perform the action, and perform therapeutic actions.)"

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Windows Update (Devicecensus)" -Service Any -Program "%SystemRoot%\System32\DeviceCensus.exe" `
-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 443 `
-LocalUser Any `
-Description "Devicecensus is used to gather information about your PC to target builds through Windows Update,
In order to target builds to your machine, we need to know a few important things:
- OS type (home, pro, enterprise, etc.)
- region
- language
- x86 or x64
- selected Insider ring
- etc."

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Update Session Orchestrator" -Service Any -Program "%SystemRoot%\System32\usocoreworker.exe" `
-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 443 `
-LocalUser Any `
-Description "wuauclt.exe is deprecated on Windows 10 (and Server 2016 and newer). The command line tool has been replaced by usoclient.exe.
When the system starts an update session, it launches usoclient.exe, which in turn launches usocoreworker.exe.
Usocoreworker is the worker process for usoclient.exe and essentially it does all the work that the USO component needs done."

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Update Session Orchestrator" -Service Any -Program "%SystemRoot%\System32\usoclient.exe" `
-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 443 `
-LocalUser $NT_AUTHORITY_System `
-Description "wuauclt.exe is deprecated on Windows 10 (and Server 2016 and newer). The command line tool has been replaced by usoclient.exe.
When the system starts an update session, it launches usoclient.exe, which in turn launches usocoreworker.exe.
Usocoreworker is the worker process for usoclient.exe and essentially it does all the work that the USO component needs done."

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Windows Defender" -Service Any -Program "%ALLUSERSPROFILE%\Microsoft\Windows Defender\Platform\4.18.1911.3-0\MsMpEng.exe" `
-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 443 `
-LocalUser $NT_AUTHORITY_System `
-Description "Anti malware service executable."

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Windows Defender" -Service Any -Program "%ALLUSERSPROFILE%\Microsoft\Windows Defender\Platform\4.18.1910.4-0\MsMpEng.exe" `
-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 443 `
-LocalUser $NT_AUTHORITY_System `
-Description "Anti malware service executable."

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Windows Defender CLI" -Service Any -Program "%ALLUSERSPROFILE%\Microsoft\Windows Defender\Platform\4.18.1911.3-0\MpCmdRun.exe" `
-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 443 `
-LocalUser $NT_AUTHORITY_System `
-Description "This utility can be useful when you want to automate Windows Defender Antivirus use."

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "WMI Provider Host" -Service Any -Program "%SystemRoot%\System32\wbem\WmiPrvSE.exe" `
-PolicyStore $PolicyStore -Enabled True -Action Block -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 22 `
-LocalUser Any `
-Description ""

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "OpenSSH" -Service Any -Program "%SystemRoot%\System32\OpenSSH\ssh.exe" `
-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 22 `
-LocalUser Any `
-Description ""

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Console Host" -Service Any -Program "%SystemRoot%\System32\conhost.exe" `
-PolicyStore $PolicyStore -Enabled True -Action Block -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 443 `
-LocalUser Any `
-Description ""

#
# Windows Device Management (predefined rules)
#

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Windows Device Management Certificate Installer" -Service Any -Program "%SystemRoot%\System32\dmcertinst.exe" `
-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort Any `
-LocalUser Any `
-Description "Allow outbound TCP traffic from Windows Device Management Certificate Installer."

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Windows Device Management Device Enroller" -Service Any -Program "%SystemRoot%\System32\deviceenroller.exe" `
-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 80, 443 `
-LocalUser Any `
-Description "Allow outbound TCP traffic from Windows Device Management Device Enroller"

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Windows Device Management Enrollment Service" -Service DmEnrollmentSvc -Program $ServiceHost `
-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort Any `
-LocalUser Any `
-Description "Allow outbound TCP traffic from Windows Device Management Enrollment Service."

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Windows Device Management Sync Client" -Service Any -Program "%SystemRoot%\System32\omadmclient.exe" `
-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort Any `
-LocalUser Any `
-Description "Allow outbound TCP traffic from Windows Device Management Sync Client."
