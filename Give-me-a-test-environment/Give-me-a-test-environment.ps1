### Global Vars
$SubscriptionName = "Microsoft Azure Internal Consumption"
$EnvironmentName = "MyTesting"

### Naming Vars
$RGName = "RG-" + $EnvironmentName
$VMName = $EnvironmentName + "-VM"

### VM Settings
$VMSize = "Standard_B2ms"
$Location = "West Europe"
$username = "vmadmin"
$password = "`$ecurity#123"
$netprefix = "10.10.10.0/24"
$sku = "2019-Datacenter"
### Find out possible SKUs with
# Get-AzVMImageSku -Location $Location -Publisher 'MicrosoftWindowsServer' -Offer "WindowsServer" | Select Skus

### Function
function New-VMEnvironment {
    $vmcount = Read-Host -Prompt "How many virtual machines do you need?"
    
    Write-Host "Creating Resource Group: $RGName ..." -ForegroundColor Green
    New-AzResourceGroup -name $RGName -location $Location

    Write-Host "Creating VNET: VNET-$EnvironmentName ..." -ForegroundColor Green
    $subnet = New-AzVirtualNetworkSubnetConfig -Name default -AddressPrefix $netprefix
    $vnet = New-AzVirtualNetwork -Name ("VNET-" + $EnvironmentName) -ResourceGroupName $RGName -location $Location -AddressPrefix $netprefix -Subnet $subnet

    for ($i=1; $i -le $vmcount; $i++)
    {
        $cVMName = $VMName + "-$i"
        Write-Host "Creating Azure virtual machine $cVMName as background job ..." -ForegroundColor Green
        
        $PIP = New-AzPublicIpAddress -Name ("PublicIP-" + $cVMName) -ResourceGroupName $RGName -Location $Location -AllocationMethod Dynamic
        $NSGRule = New-AzNetworkSecurityRuleConfig -Name rdp-rule -Description "Allow RDP" -Access Allow -Protocol Tcp -Direction Inbound -Priority 100 -SourceAddressPrefix Internet -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389
        $NSG = New-AzNetworkSecurityGroup -Name ("NSG-" + $cVMName) -ResourceGroupName $RGName -Location $Location -SecurityRules $NSGRule
        $NIC = New-AzNetworkInterface -Name ("NIC-" + $cVMName) -ResourceGroupName $RGName -Location $Location -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $PIP.Id -NetworkSecurityGroupId $NSG.id
       
        $VirtualMachine = New-AzVMConfig -VMName $cVMName -VMSize $VMSize
        $VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $cVMName -Credential $mycreds -ProvisionVMAgent -EnableAutoUpdate
        $VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $NIC.Id
        $VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus $sku -Version latest

        $job = New-AzVM -VM $VirtualMachine -ResourceGroupName $RGName -Location $Location -asJob
        
    }

    ### Check Jobs until finished
    while ((Get-Job -State Running).count -ge 1)
    {
        Start-Sleep 5
        Clear-Host
        Write-Host "Running VM Provisioning Jobs Overview" -ForegroundColor Yellow
        Write-Host ""
        Get-Job | Format-Table
    }

    Write-Host "Provisioning completed" -ForegroundColor Green

}

### Connect to Azure with Device Login
Connect-AzAccount

### Set Subscription Context
Set-AzContext -SubscriptionName $SubscriptionName

### Create credentials object
$secpasswd = ConvertTo-SecureString $password -AsPlainText -Force
$mycreds = New-Object System.Management.Automation.PSCredential ($username, $secpasswd)

### Check if the Testing RG already exists
$RGCheck = Get-AzResourceGroup -Name $RGName -ErrorAction SilentlyContinue

if ($RGCheck.count -eq 0) {
    New-VMEnvironment
}
elseif ($RGCheck.count -eq 1) {
    Write-Host "Ressource Group $RGName already exists"
    Write-Host "(D)elete existing environment"
    Write-Host "(R)ecreate a fresh environment after deleting (!!!) the existing environment"
    Write-Host "(A)bort"
    $answer = Read-Host -Prompt "Action"

    if (($answer -eq "R") -or ($answer -eq "r"))
    {
        ### Path Recreate
        Write-Host "Deleting Resource Group: $RGName ..." -ForegroundColor Red
        Remove-AzResourceGroup -Name $RGName -Force

        New-VMEnvironment
    }
    elseif (($answer -eq "D") -or ($answer -eq "d"))
    {
        ### Path Delete
        Write-Host "Deleting Resource Group: $RGName ..." -ForegroundColor Red
        Remove-AzResourceGroup -Name $RGName -Force
        Write-Host "Completed!"
    }
    else
    {
        ### Path Abort
        Write-Host "Script Execution aborted" -ForegroundColor Yellow
        Exit
    }
}
else {
    Write-Host "Something went terribly wrong in the Azure universe..."
}
