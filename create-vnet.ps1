
Login-AzureRmAccount 

Set-AzureRmContext -SubscriptionName "Developer Program Benefit"

$resourceGroup="Day2"

$frontendSubnet=New-AzureRmVirtualNetworkSubnetConfig -Name "FrontEndSubnet" `
                        -AddressPrefix "10.0.1.0/24" 
                       
$backendSubnet=New-AzureRmVirtualNetworkSubnetConfig -Name "BackEndSubnet" `
                        -AddressPrefix "10.0.2.0/24" 

New-AzureRmVirtualNetwork -Name "VNET1" `
                        -ResourceGroupName $resourceGroup `
                        -AddressPrefix "10.0.0.0/16" `
                        -Subnet $frontendSubnet, $backendSubnet `
                        -Location "SouthEast Asia"
