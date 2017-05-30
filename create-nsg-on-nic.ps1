#Login to Azure account
Login-AzureRmAccount

# To select a default subscription for your current session
Set-AzureRmContext -SubscriptionName "Developer Program Benefit" 

#=====================================================================
#create a new resource group
$locationName ="Southeast Asia"
$resourceGroup = "day2"
#New-AzureRmResourceGroup -Name $resourceGroup -Location $locationName

#create a storage account and test the uniqueness of storage account name (return False indicates unique)
#$storageAccName = "day2storageacc"
#Test-AzureName -Storage $storageAccName

#create storage account
$storageAccName = "deliverystorageacc"
<#$storageAcc = New-AzureRmStorageAccount -ResourceGroupName $resourceGroup `
                    -Name $storageAccName `
                    -Type "Standard_LRS" `
                    -Location $locationName
#>
$storageAcc=Get-AzureRmStorageAccount -ResourceGroupName $resourceGroup `
                    -Name $storageAccName
#==========================================================================================

#create a virtual network
$frontendSubnet = New-AzureRmVirtualNetworkSubnetConfig -Name FrontEndSubnet `
                    -AddressPrefix 10.0.0.0/24


$vnet = New-AzureRmVirtualNetwork -Name VNET-Delivery `
                    -ResourceGroupName $resourceGroup `
                    -Location $locationName `
                    -AddressPrefix '10.0.0.0/16' `
                    -Subnet $frontendSubnet

#====================================================================================
#Create an NSG
#NSG Rule to Deny RDP on port 3389
$inboundRdpRule = New-AzureRmNetworkSecurityRuleConfig -Name 'Rdp-rule' `
                        -Description "Allow RDP" `
                        -Access Allow `
                        -Protocol Tcp `
                        -Direction Inbound `
                        -Priority 100 `
                        -SourceAddressPrefix Internet `
                        -SourcePortRange * `
                        -DestinationAddressPrefix * `
                        -DestinationPortRange 3389

#NSG Rule for Allowing HTTP on port 80
$inboundHttpRule = New-AzureRmNetworkSecurityRuleConfig -Name 'Http-rule' `
                        -Description "Allow HTTP" `
                        -Access Allow `
                        -Protocol Tcp `
                        -Direction Inbound `
                        -Priority 101 `
                        -SourceAddressPrefix Internet `
                        -SourcePortRange * `
                        -DestinationAddressPrefix * `
                        -DestinationPortRange 80

$nsg=New-AzureRmNetworkSecurityGroup -Name 'VNET-NSG' `
                        -ResourceGroupName $resourceGroup `
                        -Location 'SouthEast Asia' `
                        -SecurityRules $inboundRdpRule, $inboundHttpRule 
#==============================================================================================
#create public IP address and network interface
$pip = New-AzureRmPublicIpAddress -Name 'VM-PIP' `
                    -ResourceGroupName $resourceGroup `
                    -Location $locationName `
                    -AllocationMethod Dynamic

$nic = New-AzureRmNetworkInterface -Name "VM-NIC" `
                    -ResourceGroupName $resourceGroup `
                    -Location $locationName `
                    -SubnetId $vnet.Subnets[0].Id `
                    -PublicIpAddressId $pip.Id

$nic.NetworkSecurityGroup=$nsg
Set-AzureRmNetworkInterface -NetworkInterface $nic

#Create a virtual machine
#Run the command to set the administrator account name and password for the virtual machine.
$cred = Get-Credential -Message "Type the name and password of the local administrator account."

$vm = New-AzureRmVMConfig -VMName 'VM-MYPC' `
                    -VMSize "Standard_A1"

#run the commands to define the operating system to use.
$vm = Set-AzureRmVMOperatingSystem -VM $vm `
                    -Windows `
                    -ComputerName 'MYPC' `
                    -Credential $cred `
                    -ProvisionVMAgent `
                    -EnableAutoUpdate

#Run the command to define the image to use to provision the virtual machine.
$vm = Set-AzureRmVMSourceImage -VM $vm `
                    -PublisherName MicrosoftWindowsServer `
                    -Offer WindowsServer `
                    -Skus 2012-R2-Datacenter `
                    -Version "latest"

#add the network interface created to the virtual machine configuration.
$vm = Add-AzureRmVMNetworkInterface -VM $vm `
                    -Id $nic.Id

$osDiskUri = $storageAcc.PrimaryEndpoints.Blob.ToString() + "vhds/WindowsR2DC.vhd"
$diskName = "windowsvmosdisk"
$vm = Set-AzureRmVMOSDisk -VM $vm `
                    -Name $diskName `
                    -VhdUri $osDiskUri `
                    -CreateOption fromImage

New-AzureRmVM -ResourceGroupName $resourceGroup `
                    -Location $locationName `
                    -VM $vm


