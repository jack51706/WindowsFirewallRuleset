
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
$Group = "Network Sharing"

# Ask user if he wants to load these rules
Update-Context $IPVersion $Direction $Group
if (!(Approve-Execute)) { exit }

# First remove all existing rules matching group
Remove-NetFirewallRule -PolicyStore $PolicyStore -Group $Group -Direction $Direction -ErrorAction SilentlyContinue

#
# File and Printer sharing predefined rules
# Rules apply to network sharing on LAN
#

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "NetBIOS Session" -Service Any -Program System `
-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile Private -InterfaceType $Interface `
-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress LocalSubnet4 -LocalPort 139 -RemotePort Any `
-EdgeTraversalPolicy Block -LocalUser $NT_AUTHORITY_System -LocalOnlyMapping $false -LooseSourceMapping $false `
-Description "Rule for File and Printer Sharing to allow NetBIOS Session Service connections."

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "NetBIOS Session" -Service Any -Program System `
-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile Domain -InterfaceType $Interface `
-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress Intranet4 -LocalPort 139 -RemotePort Any `
-EdgeTraversalPolicy Block -LocalUser $NT_AUTHORITY_System -LocalOnlyMapping $false -LooseSourceMapping $false `
-Description "Rule for File and Printer Sharing to allow NetBIOS Session Service connections."

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "SMB" -Service Any -Program System `
-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile Private -InterfaceType $Interface `
-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress LocalSubnet4 -LocalPort 445 -RemotePort Any `
-EdgeTraversalPolicy Block -LocalUser $NT_AUTHORITY_System `
-Description "Rule for File and Printer Sharing to allow Server Message Block transmission and reception via Named Pipes."

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "SMB" -Service Any -Program System `
-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile Domain -InterfaceType $Interface `
-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Intranet4 -LocalPort 445 -RemotePort Any `
-EdgeTraversalPolicy Block -LocalUser $NT_AUTHORITY_System `
-Description "Rule for File and Printer Sharing to allow Server Message Block transmission and reception via Named Pipes."

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Spooler Service (RPC)" -Service Spooler -Program $ServiceHost `
-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile Private -InterfaceType $Interface `
-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress LocalSubnet4 -LocalPort RPC -RemotePort Any `
-EdgeTraversalPolicy Block -LocalUser Any `
-Description "Rule for File and Printer Sharing to allow the Print Spooler Service to communicate via TCP/RPC.
Spooler service spools print jobs and handles interaction with the printer.
If you disable this rule, you won’t be able to print or see your printers."

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Spooler Service (RPC)" -Service Spooler -Program $ServiceHost `
-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile Domain -InterfaceType $Interface `
-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Intranet4 -LocalPort RPC -RemotePort Any `
-EdgeTraversalPolicy Block -LocalUser Any `
-Description "Rule for File and Printer Sharing to allow the Print Spooler Service to communicate via TCP/RPC.
Spooler service spools print jobs and handles interaction with the printer.
If you disable this rule, you won’t be able to print or see your printers."

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Spooler Service (RPC-EPMAP)" -Service RpcSs -Program $ServiceHost `
-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile Private -InterfaceType $Interface `
-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress LocalSubnet4 -LocalPort RPCEPMap -RemotePort Any `
-EdgeTraversalPolicy Block -LocalUser Any `
-Description "Rule for the RPCSS service to allow RPC/TCP traffic for the Spooler Service.
The RPCSS service is the Service Control Manager for COM and DCOM servers.
It performs object activations requests, object exporter resolutions and distributed garbage collection for COM and DCOM servers."

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "Spooler Service (RPC-EPMAP)" -Service RpcSs -Program $ServiceHost `
-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile Domain -InterfaceType $Interface `
-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Intranet4 -LocalPort RPCEPMap -RemotePort Any `
-EdgeTraversalPolicy Block -LocalUser Any `
-Description "Rule for the RPCSS service to allow RPC/TCP traffic for the Spooler Service.
The RPCSS service is the Service Control Manager for COM and DCOM servers.
It performs object activations requests, object exporter resolutions and distributed garbage collection for COM and DCOM servers."

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "SMBDirect (iWARP)" -Service Any -Program System `
-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile Private -InterfaceType $Interface `
-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress LocalSubnet4 -LocalPort 5445 -RemotePort Any `
-EdgeTraversalPolicy Block -LocalUser $NT_AUTHORITY_System `
-Description "Rule for File and Printer Sharing over SMBDirect to allow iWARP.
The RPCSS service is the Service Control Manager for COM and DCOM servers.
It performs object activations requests, object exporter resolutions and distributed garbage collection for COM and DCOM servers."

New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
-DisplayName "SMBDirect (iWARP)" -Service Any -Program System `
-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile Domain -InterfaceType $Interface `
-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Intranet4 -LocalPort 5445 -RemotePort Any `
-EdgeTraversalPolicy Block -LocalUser $NT_AUTHORITY_System `
-Description "Rule for File and Printer Sharing over SMBDirect to allow iWARP.
The RPCSS service is the Service Control Manager for COM and DCOM servers.
It performs object activations requests, object exporter resolutions and distributed garbage collection for COM and DCOM servers."
