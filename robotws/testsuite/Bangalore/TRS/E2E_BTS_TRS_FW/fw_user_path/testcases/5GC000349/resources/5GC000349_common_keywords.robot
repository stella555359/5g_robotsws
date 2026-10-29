*** Settings ***
Documentation
...            [Author]         "Meghana J"

***Keywords***
Read mplane and gateway IP
        ${mplaneIP}=     Get Parameter   param_path=${mplane_ipv4_moc}
        Set Suite Variable          ${mplaneIP}
        ${gatewayIP}=     Get Parameter   param_path=${GWIP_moc}
        Set Suite Variable          ${gatewayIP}

Set reference counter values
        [Arguments]     ${Class1}
        Set Suite Variable      ${Class1}       ${Class1}

Read vlan from admin
	${mplane1} = 			Get Parameter       rat=common    	param_path=${mplane1_ip_moc_path}
	${mplane1_ipif_dict} = 		Query Admin Infomodel		query=get object ${ipif_moc_path} is [localIpAddr=${mplane1}]
	${mplane1_ipif_moc}=		Get From Dictionary	dictionary=${mplane1_ipif_dict}		key=dist_name
	${mplane1_ipif}=			Replace String Using Regexp		string=${mplane1_ipif_moc}		pattern=${pattern_to_replace_in_moc}
	...     replace_with=${EMPTY}
   	${mplane1_ipif_path}=		Split String From Right		string=${mplane1_ipif}	separator=/
	${mplane_ipif_id}=	Set Variable	${mplane1_ipif_path}[-2]
	${mplane1_vlan_value} = 	Get Parameter       rat=common  	 	param_path=${mplane_ipif_id}:interfaceDN:vlanId
	${mplane1_vlanif_dict} = 		Query Admin Infomodel		query=get object ${vlanif_moc_path} is [vlanId=${mplane1_vlan_value}]
	${mplane1_vlanif_moc}=				Get From Dictionary	dictionary=${mplane1_vlanif_dict}	key=dist_name
	${mplane1_vlanif}=				Replace String Using Regexp	string=${mplane1_vlanif_moc}	pattern=${pattern_to_replace_in_moc}
	...     replace_with=${EMPTY}
	${mplane1_vlanif_path}=		Split String From Right		string=${mplane1_vlanif}	separator=/
	${mplane_vlanif_id}=	Set Variable	${mplane1_vlanif_path}[-1]

    ${vlanId_temp}=     Split String From Right     string=${mplane_vlanif_id}    separator=-
    ${vlanId}=      Set Variable     ${vlanId_temp}[-1]
    Set Suite Variable          ${vlanId}