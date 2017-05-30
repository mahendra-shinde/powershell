
Login-AzureRmAccount 

Set-AzureRmContext -SubscriptionName "Developer Program Benefit"

$resourceGroup="Day2"


$pip=New-AzureRmPublicIpAddress -Name "LBPIP" `
                                -ResourceGroupName $resourceGroup `
                                -Location "SouthEast Asia" `
                                -AllocationMethod Dynamic

$frontend=New-AzureRmLoadBalancerFrontendIpConfig -Name "FrontendLB" -PublicIpAddress $pip

$backendPool=New-AzureRmLoadBalancerBackendAddressPoolConfig -Name "LBBackendPoolConfig"

$probe=New-AzureRmLoadBalancerProbeConfig -Name "LBProbeConfig" `
                        -Protocol Http `
                        -Port 80 `
                        -IntervalInSeconds 60 `
                        -RequestPath "index.html" `
                        -ProbeCount 2

$lbrule = New-AzureRmLoadBalancerRuleConfig -Name "LBRuleConfig" `
                -FrontendIPConfiguration $frontend `
                -BackendAddressPool $backendPool `
                -Probe $probe `
                -Protocol Tcp `
                -FrontendPort 80 `
                -BackendPort 8080 `
                -IdleTimeoutInMinutes 15 `
                -EnableFloatingIP `
                -LoadDistribution SourceIP

$lb = New-AzureRmLoadBalancer -Name "LB1" `
                -ResourceGroupName $resourceGroup `
                -Location 'SouthEast Asia' `
                -FrontendIpConfiguration $frontend `
                -BackendAddressPool $backendPool `
                -Probe $probe `
                -LoadBalancingRule $lbrule