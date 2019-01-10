# Vars
$SubscriptionName = "Microsoft Azure Internal Consumption" #adjust to your Subscription Name
$RGName = "AZ-RG"
$Location = "West Europe"
$VMName = "AZ-VM"

# Connect to Azure with Device Login
Connect-AzAccount

# Set Subscription Context
Set-AzContext -SubscriptionName $SubscriptionName

# Create RG
New-AzResourceGroup -name $RGName -location $Location

# Create VM
New-AzVM -Name $VMName -ResourceGroupName $RGName -Location $Location -Credential (Get-Credential) `
-VirtualNetworkName ("VNET-" + $VMName) -SubnetName ("VNET-" + $VMName) `
-Size "Standard_B2ms" -Image "Win2019Datacenter" `
-PublicIpAddressName ("PublicIP-" + $VMName) -SecurityGroupName ("NSG-" + $VMName) -OpenPorts "3389"

Write-Host "Public IP: " (Get-AzPublicIpAddress -ResourceGroupName $RGName -name ("PublicIP-" + $VMName)).IpAddress

# https://www.youtube.com/watch?v=st6-DgWeuos
Read-Host "To continue with VM Cleanup process press the any key... (where is the any key?!)"

Remove-AzResourceGroup -Name $RGName -Force:$true


# Helper Commands
# Get-InstalledModule
# Get-Command -Module Az.Resources
# Get-Command -Module Az.Compute
# Get-Command -Module Az.Network 
