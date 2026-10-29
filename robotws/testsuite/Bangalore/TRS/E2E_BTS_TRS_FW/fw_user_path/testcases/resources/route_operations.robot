*** Settings ***
Resource    taf/rfrl/trs_e2e_fw/setup/framework.robot

*** Keywords ***
Add Routes for Strongswan
	Configure Switch	device=edge_router		command_profile=add_${ip_count}_route_to_strongswan
	
Remove Routes for Strongswan
	Configure Switch	device=edge_router		command_profile=del_${ip_count}_route_to_strongswan

Add Routes For Virtual IPs
	Configure Switch	device=l3_router		command_profile=add_${ip_count}_route_for_virtual_config

Remove Routes For Virtual IPs
	Configure Switch	device=l3_router		command_profile=del_${ip_count}_route_for_virtual_config

Add Routes For Alias IPs
	Configure Switch	device=BFD_router		command_profile=add_${ip_count}_route_for_alias_config

Remove Routes For Alias IPs
	Configure Switch	device=BFD_router		command_profile=del_${ip_count}_route_for_alias_config

