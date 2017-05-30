#Login to Azure account
Login-AzureRmAccount

# To select a default subscription for your current session
Set-AzureRmContext -SubscriptionName "Subscription Name" 

#create a new resource group
$locationName ="Southeast Asia"
$resourceGroup = "day2"
New-AzureRmResourceGroup -Name $resourceGroup -Location $locationName

#create a storage account and test the uniqueness of storage account name (return False indicates unique)
#$storageAccName = "Day2storageacc"
#Test-AzureName -Storage $storageAccName

#create storage account
$storageAccName = "day2storageacc"
$storageAcc = New-AzureRmStorageAccount -ResourceGroupName $resourceGroup -Name $storageAccName -Type "Standard_LRS" -Location $locationName

#create a virtual network
$subnetName = "day2VNet"
$singleSubnet = New-AzureRmVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix 10.0.0.0/24
$vnetName = "Day2VNetZ"
$vnet = New-AzureRmVirtualNetwork -Name $vnetName -ResourceGroupName $resourceGroup -Location $locationName -AddressPrefix 10.0.0.0/16 -Subnet $singleSubnet

#create public IP address and network interface
$ipName = "Day2IP"
$pip = New-AzureRmPublicIpAddress -Name $ipName -ResourceGroupName $resourceGroup -Location $locationName -AllocationMethod Dynamic
$nicName = "Day2VNIntf"
$nic = New-AzureRmNetworkInterface -Name $nicName -ResourceGroupName $resourceGroup -Location $locationName -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id

#Create a virtual machine
#Run the command to set the administrator account name and password for the virtual machine.
$cred = Get-Credential -Message "Type the name and password of the local administrator account."
$vmName = "Day2VM1"
$vm = New-AzureRmVMConfig -VMName $vmName -VMSize "Standard_A1"

#run the commands to define the operating system to use.
$compName = "Day2VM1-comp"
$vm = Set-AzureRmVMOperatingSystem -VM $vm -Windows -ComputerName $compName -Credential $cred -ProvisionVMAgent -EnableAutoUpdate

#Run the command to define the image to use to provision the virtual machine.
$vm = Set-AzureRmVMSourceImage -VM $vm -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2012-R2-Datacenter -Version "latest"

#add the network interface created to the virtual machine configuration.
$vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic.Id

$blobPath = "vhds/WindowsR2DC.vhd"
$osDiskUri = $storageAcc.PrimaryEndpoints.Blob.ToString() + $blobPath

$diskName = "windowsvmosdisk"
$vm = Set-AzureRmVMOSDisk -VM $vm -Name $diskName -VhdUri $osDiskUri -CreateOption fromImage

New-AzureRmVM -ResourceGroupName $resourceGroup -Location $locationName -VM $vm