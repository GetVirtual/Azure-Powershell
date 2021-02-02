<# 
Version: 1.1
Date: 02.02.2021

Description:
This script deploys an Azure NetApp Files sample environment.
VNET, Subnet, Subnet delegation, ANF Account & Pool & Volume (NFSv3)
Just state the target subscription ID as parameter and the deployment will use the defined variables.

Required Modules:
Install-Module -Name Az -AllowClobber -Force
Install-Module -Name Az.NetAppFiles -Force

Authors:
Jürgen Lobenz (Microsoft)
Dirk Ecker (Microsoft/NetApp)
Sebastian Brack (Microsoft/NetApp)
#> 
 

Param (
    [parameter(Mandatory=$true)][String]$SubscriptionId
)

Write-Host "Connecting to Azure subscription $SubscriptionId."
Connect-AzAccount -Subscription $SubscriptionId

# Variables
$Location = "westeurope"
$ResourceGroup = "ANF-PowerShell"

$VNETName = "ANF-VNET-PowerShell"
$VNETPrefix = "10.0.100.0/23"
$SubnetClientsPrefix = "10.0.100.0/24"
$SubnetANFPrefix = "10.0.101.0/24"

$ANFAccountName = "ANF-Account-PowerShell"

$ANFPoolName = "ANF-Pool-PowerShell"
$ANFServiceLevel = "Standard" # Valid values are Standard, Premium and Ultra
$ANFPoolSizeTiB = 4 # Valid values are 4 to 500
$ANFPoolSizeBytes = $ANFPoolSizeTiB * 1024 * 1024 * 1024 * 1024

$ANFVolumeName = "ANF-VolumeNFS-Powershell"
$ANFVolumePath = "volume-nfs"
$ANFVolumeProtocol = "NFSv3" # Valid values are "NFSv3", "NFSv4.1", "CIFS"
$ANFVolumeSizeGiB = 1024 # Valid values are 100 (100 GiB) to 102400 (100 TiB)
$ANFVolumeSizeBytes = $ANFVolumeSizeGiB * 1024 * 1024 * 1024

# Create Ressource Group
New-AzResourceGroup -Name $ResourceGroup -Location $Location

# Create VNET, Subnets and Delegation
$VNETRef = New-AzVirtualNetwork `
  -ResourceGroupName $ResourceGroup `
  -Location $Location `
  -Name $VNETName `
  -AddressPrefix $VNETPrefix

Add-AzVirtualNetworkSubnetConfig `
  -Name "Clients" `
  -AddressPrefix $SubnetClientsPrefix `
  -VirtualNetwork $VNETRef | Set-AzVirtualNetwork

Add-AzVirtualNetworkSubnetConfig `
  -Name "ANF" `
  -AddressPrefix $SubnetANFPrefix `
  -VirtualNetwork $VNETRef `
  -Delegation (New-AzDelegation -Name "ANFDelegation" -ServiceName "Microsoft.Netapp/volumes") `
  | Set-AzVirtualNetwork

# Create Azure NetApp Files Account
New-AzNetAppFilesAccount `
  -ResourceGroupName $ResourceGroup `
  -Location $Location `
  -Name $ANFAccountName

# Create Azure NetApp Files Capacity Pool
New-AzNetAppFilesPool -ResourceGroupName $ResourceGroup `
 -Location $Location `
 -AccountName $ANFAccountName `
 -Name $ANFPoolName `
 -PoolSize $ANFPoolSizeBytes `
 -ServiceLevel $ANFServiceLevel

# Create new Azure NetApp Files Volume
New-AzNetAppFilesVolume `
    -ResourceGroupName $ResourceGroup `
    -Location $Location `
    -AccountName $ANFAccountName `
    -PoolName $ANFPoolName `
    -Name $ANFVolumeName `
    -UsageThreshold $ANFVolumeSizeBytes `
    -SubnetId ((Get-AzVirtualNetworkSubnetConfig -Name "ANF" -VirtualNetwork (Get-AzVirtualNetwork -Name $VNETName)).Id) `
    -CreationToken $ANFVolumePath `
    -ServiceLevel $ANFServiceLevel `
    -ProtocolType $ANFVolumeProtocol

# Get information how to access the newly created Azure NetApp Files Volume
$vol = (Get-AzNetAppFilesVolume `
    -ResourceGroupName $ResourceGroup `
    -AccountName $ANFAccountName `
    -PoolName $ANFPoolName `
    -Name $ANFVolumeName)

$ANFVolumeMountTarget = $vol.MountTargets.IpAddress + ":/" + $vol.CreationToken

Write-Host "Azure NetApp Files volume can be mounted at $ANFVolumeMountTarget"
