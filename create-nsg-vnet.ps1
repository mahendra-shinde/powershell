
Login-AzureRmAccount 

Set-AzureRmContext -SubscriptionName "Developer Program Benefit"

$resourceGroup="DeliveryGroup"

$frontendSubnet=New-AzureRmVirtualNetworkSubnetConfig -Name "FrontEndSubnet" `
                        -AddressPrefix "10.0.1.0/24" 
                       
$backendSubnet=New-AzureRmVirtualNetworkSubnetConfig -Name "BackEndSubnet" `
                        -AddressPrefix "10.0.2.0/24" 

#Create the VNET
New-AzureRmVirtualNetwork -Name "VNET1" `
                        -ResourceGroupName $resourceGroup `
                        -AddressPrefix "10.0.0.0/16" `
                        -Subnet $frontendSubnet, $backendSubnet `
                        -Location "SouthEast Asia"

#Get the VNET object
$vnet=Get-AzureRmVirtualNetwork -ResourceGroupName $resourceGroup `
                        -Name 'VNET1'

#Create an NSG
#NSG Rule to Allow RDP on port 3389
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
                        
#Associate the NSG to the frontend subnet of the VNET
#Name is the name of the subnet you want to apply NSG
Set-AzureRmVirtualNetworkSubnetConfig -Name 'FrontEndSubnet' `
                        -VirtualNetwork $vnet `
                        -AddressPrefix '10.0.1.0/24' `
                        -NetworkSecurityGroup $nsg

#Save subnet change to Virtual network
Set-AzureRmVirtualNetwork -VirtualNetwork $vnet
      
                  