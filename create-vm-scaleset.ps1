#Get-AzureLocation | Sort Name | Select Name, AvailableServices


#Create a resource group
$locName = "Southeast Asia"
$rgName = "day2"
#New-AzureRmResourceGroup -Name $rgName -Location $locName

#Create a storage account
`$storgeAccountName="vmssstorage"
#New-AzureRmStorageAccount -Name $storgeAccountName -ResourceGroupName $rgName -Location $locName -Type Standard_LRS

#Create a virtual network
$subnetName="vmsssubnet"
$subnet = New-AzureRmVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix 10.0.0.0/24
$netName="vmssnet"
$vnet = New-AzureRmVirtualNetwork -Name $netName -ResourceGroupName $rgName -Location $locName -AddressPrefix 10.0.0.0/16 -Subnet $subnet


#Before a network interface can be created, you need to create a public IP address.
$domName = "vmssdemo"
Test-AzureRmDnsAvailability -DomainQualifiedName $domName -Location "Southeast Asia" #True means unique and available
$pipName = "vmsspip"
$pip = New-AzureRmPublicIpAddress -Name $pipName -ResourceGroupName $rgName -Location $locName -AllocationMethod Dynamic -DomainNameLabel $domName
$nicName = "vmssnic"
$nic = New-AzureRmNetworkInterface -Name $nicName -ResourceGroupName $rgName -Location $locName -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id

#configure scaleset
$ipName = "vmssipconfig"
$ipConfig = New-AzureRmVmssIpConfig -Name $ipName -LoadBalancerBackendAddressPoolsId $null -SubnetId $vnet.Subnets[0].Id
$vmssConfig = "vmssconfig"
$vmss = New-AzureRmVmssConfig -Location $locName -SkuCapacity 3 -SkuName "Standard_A0" -UpgradePolicyMode "manual"
Add-AzureRmVmssNetworkInterfaceConfiguration -VirtualMachineScaleSet $vmss -Name $vmssConfig -Primary $true -IPConfiguration $ipConfig
#OS config details
$computerName = "VMSSM"
$adminName = "myadmin"
$adminPassword = "namaste@2017"
Set-AzureRmVmssOsProfile -VirtualMachineScaleSet $vmss -ComputerNamePrefix $computerName -AdminUsername $adminName -AdminPassword $adminPassword
#storage profile
$storeProfile = "vmssstorageprofile"
$imagePublisher = "MicrosoftWindowsServer"
$imageOffer = "WindowsServer"
$imageSku = "2012-R2-Datacenter"
$vhdContainer = "https://vmssstorage.blob.core.windows.net/vmssvhds"
Set-AzureRmVmssStorageProfile -VirtualMachineScaleSet $vmss -ImageReferencePublisher $imagePublisher -ImageReferenceOffer $imageOffer -ImageReferenceSku $imageSku -ImageReferenceVersion "latest" -Name $storeProfile -VhdContainer $vhdContainer -OsDiskCreateOption "FromImage" -OsDiskCaching "None"  

#VM Scale set
$vmssName = "vmscaleset"
New-AzureRmVmss -ResourceGroupName $rgName -Name $vmssName -VirtualMachineScaleSet $vmss