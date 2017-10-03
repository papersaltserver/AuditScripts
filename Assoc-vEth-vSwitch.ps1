$net_adapters = Get-NetAdapter
foreach($ethernet_port in gwmi -Namespace Root\Virtualization\V2 -Class Msvm_InternalEthernetPort){
	$endpoint_physical = gwmi -Namespace Root\Virtualization\V2 -Query "ASSOCIATORS OF {$ethernet_port} WHERE ResultClass=Msvm_LANEndpoint AssocClass=Msvm_EthernetDeviceSAPImplementation"
	$endpoint_virtual = gwmi -Namespace Root\Virtualization\V2 -Query "ASSOCIATORS OF {$endpoint_physical} where ResultClass=Msvm_LANEndpoint assocclass=Msvm_ActiveConnection"
	$ethernetswitchport = gwmi -Namespace Root\Virtualization\V2 -Query "ASSOCIATORS OF {$endpoint_virtual}  WHERE ResultClass=Msvm_EthernetSwitchPort AssocClass=Msvm_EthernetDeviceSAPImplementation"
	$vswitch = gwmi -Namespace Root\Virtualization\V2 -Query "ASSOCIATORS OF {$ethernetswitchport} WHERE ResultClass=Msvm_VirtualEthernetSwitch"
	
	$net_adapter = $net_adapters | ?{($_).MacAddress -replace '-','' -eq $ethernet_port.PermanentAddress}
	Write-Host "Adapter:" $net_adapter.Name 
	Write-Host "Switch:" $vswitch.ElementName
	Write-Host
}

