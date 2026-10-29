*** Settings ***
Documentation
...              [Maintenance] "TRS I & V Tools Bangalore Team"

*** Variables ***
${tc_variables}     testcase_variables.json

*** Keywords ***
Copy configuration files
    Run     sudo mv /etc/ipsec.conf /etc/ipsec_vm.conf
    Run     sudo cp ${ipsec_9741_config} /etc/ipsec.conf
    Run     sudo cp ${ipsec_9741_secrets} /etc/ipsec.secrets

Add remote tunnel routes
    Run     sudo ip a a ${remote_tunnel_endpoint_Mplanev4}/24 dev eth3.${vlan_1}
    Run     sudo ip a a ${remote_tunnel_endpoint_Mplanev6}/120 dev eth3.${vlan_1}
    Run     sudo ip a a ${remote_tunnel_endpoint_UPlanev4}/24 dev eth3.${vlan_2}
    Run     sudo ip a a ${remote_tunnel_endpoint_Uplanev6}/120 dev eth3.${vlan_2}

Verify cmp certificate state
    Certificate Configure       operation=install_cmp_certificate     timeout=240

Verify tunnel establishment with valid certificate
    Run    sudo cp ${ipsec_9741_EE_install} /etc/ipsec.d/certs/
    Run    sudo cp ${ipsec_9741_priv_install} /etc/ipsec.d/private/
    Run    sudo cp ${ipsec_9741_TA_install} /etc/ipsec.d/cacerts/
    Run     sudo cp ${ipsec_9741_CA11_install} /etc/ipsec.d/cacerts/
    Run     sudo cp ${ipsec_9741_CA12_install} /etc/ipsec.d/cacerts/
    Run     sudo cp ${ipsec_9741_CA13_install} /etc/ipsec.d/cacerts/
    Run    sudo rm -rf ${cert_Btspem}
    Run    sudo rm -rf ${cert_PrivateKey}
    Sleep   10
    Run    sudo ln -s ${Cert_1} ${cert_Btspem}
    Run    sudo ln -s ${Cert_2} ${cert_PrivateKey}
    Sleep   10

Verify tunnel status with expired cert
    Run    sudo cp ${ipsec_9741_EE_expiry} /etc/ipsec.d/certs/
    Run    sudo cp ${ipsec_9741_priv_expiry} /etc/ipsec.d/private/
    Run    sudo cp ${ipsec_9741_TA_expiry} /etc/ipsec.d/cacerts/
    Run     sudo cp ${ipsec_9741_CA11_expiry} /etc/ipsec.d/cacerts/
    Run     sudo cp ${ipsec_9741_CA12_expiry} /etc/ipsec.d/cacerts/
    Run     sudo cp ${ipsec_9741_CA13_expiry} /etc/ipsec.d/cacerts/
    Run    sudo rm -rf ${cert_Btspem}
    Run    sudo rm -rf ${cert_PrivateKey}
    Sleep   10
    Run    sudo ln -s ${Cert_3} ${cert_Btspem}
    Run    sudo ln -s ${Cert_4} ${cert_PrivateKey}
    Sleep   10
    Run    sudo ipsec restart
    Sleep   10

Get Ipsec Tunnels Status for disbale
    @{parent_tunnel_moc_list} =     Query Admin Infomodel       query=get list ${ike_sa_l_moc_path}
    FOR     ${ike_tunnel}   IN  @{parent_tunnel_moc_list}
        ${parent_tunnel_stateInfo}=     Get From Dictionary     dictionary=${ike_tunnel}        key=stateInfo
        ${parent_tunnel_proceduralState}=   Get From Dictionary     dictionary=${parent_tunnel_stateInfo}       key=proceduralState
        Should Be True  '${parent_tunnel_proceduralState}'=='Connecting'
    END
    @{child_tunnel_moc_list} =  Query Admin Infomodel       query=get list ${ipsec_sa_l_moc_path}
    FOR     ${child_tunnel} IN  @{child_tunnel_moc_list}
        ${child_tunnel_stateInfo}=  Get From Dictionary     dictionary=${child_tunnel}      key=stateInfo
        ${child_tunnel_proceduralState}=    Get From Dictionary     dictionary=${child_tunnel_stateInfo}        key=proceduralState
        Should Be True  '${child_tunnel_proceduralState}'=='Connecting'
    END


Read parameter BTS
    ${remote_tunnel_endpoint_Mplanev4}=       Get Parameter   param_path=${Mplane_ipv4_remote_tunnel_path}
    Set Suite Variable       ${remote_tunnel_endpoint_Mplanev4}
    ${remote_tunnel_endpoint_Mplanev6}=       Get Parameter   param_path=${Mplane_ipv6_remote_tunnel_path}
    Set Suite Variable       ${remote_tunnel_endpoint_Mplanev6}
    ${remote_tunnel_endpoint_UPlanev4}=       Get Parameter   param_path=${Uplane_ipv4_remote_tunnel_path}
    Set Suite Variable       ${remote_tunnel_endpoint_UPlanev4}
    ${remote_tunnel_endpoint_Uplanev6}=       Get Parameter   param_path=${Uplane_ipv6_remote_tunnel_path}
    Set Suite Variable       ${remote_tunnel_endpoint_Uplanev6}
    ${vlan_1}=       Get Parameter   param_path=${Mplane_vlan_1}
    Set Suite Variable       ${vlan_1}
    ${vlan_2}=       Get Parameter   param_path=${Mplane_vlan_2}
    Set Suite Variable       ${vlan_2}

Get Ipsec Tunnels Status
	@{parent_tunnel_moc_list} = 	Query Admin Infomodel		query=get list ${ike_sa_l_moc_path}
	FOR 	${ike_tunnel}	IN 	@{parent_tunnel_moc_list}
		${parent_tunnel_stateInfo}=	Get From Dictionary		dictionary=${ike_tunnel}		key=stateInfo
		${parent_tunnel_proceduralState}=	Get From Dictionary		dictionary=${parent_tunnel_stateInfo}		key=proceduralState
		Should Be True	'${parent_tunnel_proceduralState}'=='Established'
    END
	@{child_tunnel_moc_list} = 	Query Admin Infomodel		query=get list ${ipsec_sa_l_moc_path}
	FOR 	${child_tunnel}	IN 	@{child_tunnel_moc_list}
		${child_tunnel_stateInfo}=	Get From Dictionary		dictionary=${child_tunnel}		key=stateInfo
		${child_tunnel_proceduralState}=	Get From Dictionary		dictionary=${child_tunnel_stateInfo}		key=proceduralState
		Should Be True	'${child_tunnel_proceduralState}'=='Installed'
    END

Get Ipsec Tunnels Status Of Mplane
    @{parent_tunnel_moc_list} =     Query Admin Infomodel       query=get list ${ike_sa_l_moc_path}
    FOR     ${ike_tunnel}   IN  @{parent_tunnel_moc_list}
        ${parent_tunnel_stateInfo}=     Get From Dictionary     dictionary=${parent_tunnel_moc_list[0]}        key=stateInfo
        ${parent_tunnel_proceduralState}=       Get From Dictionary     dictionary=${parent_tunnel_stateInfo}       key=proceduralState
        Should Be True  '${parent_tunnel_proceduralState}'=='Established'
    END
    @{child_tunnel_moc_list} =      Query Admin Infomodel       query=get list ${ipsec_sa_l_moc_path}
    FOR 	${child_tunnel}	IN 	@{child_tunnel_moc_list}
        ${child_tunnel_stateInfo}=      Get From Dictionary     dictionary=${child_tunnel_moc_list[0]}      key=stateInfo
        ${child_tunnel_proceduralState}=        Get From Dictionary     dictionary=${child_tunnel_stateInfo}        key=proceduralState
        Should Be True  '${child_tunnel_proceduralState}'=='Installed'
    END

    FOR     ${ike_tunnel}   IN  @{parent_tunnel_moc_list}
        ${parent_tunnel_stateInfo}=     Get From Dictionary     dictionary=${parent_tunnel_moc_list[2]}        key=stateInfo
        ${parent_tunnel_proceduralState}=       Get From Dictionary     dictionary=${parent_tunnel_stateInfo}       key=proceduralState
        Should Be True  '${parent_tunnel_proceduralState}'=='Established'
    END
    FOR 	${child_tunnel}	IN 	@{child_tunnel_moc_list}
        ${child_tunnel_stateInfo}=      Get From Dictionary     dictionary=${child_tunnel_moc_list[1]}      key=stateInfo
        ${child_tunnel_proceduralState}=        Get From Dictionary     dictionary=${child_tunnel_stateInfo}        key=proceduralState
        Should Be True  '${child_tunnel_proceduralState}'=='Installed'
    END

Perform software upgrade
    Perform Software Download And Update       package=${profile}      activate_sw=true      update_timeout=2800



Verify alarm with Peer certificate lifetime is Expired
	Setup Oamops	dut=bts		alias=bts
	${AlarmList}=	Verify Alarm	faultid=${faultnum_mplane_invalidpeercert}  occurrences=1	should_exist=${True}	load_history=${TRUE}	dut=bts      alias=bts
#	${AlarmList}=	Verify Alarm	dut=vcu      alias=vcu
	FOR	${alarm}	IN	@{AlarmList}
		${Fault_ID}=	Get From Dictionary	${alarm}	faultId
		Continue For Loop If	${Fault_ID}!=${faultnum_mplane_invalidpeercert}
		${additional_info}=	Get From Dictionary	${alarm}	supplAlarmInfo
		Should Be Equal		${additional_info}	Peer certificate lifetime is Expired
		Exit For Loop If    ${fault_id}==61012
	END
	Verify Alarm	faultid=61644       occurrences=1	dut=bts      alias=bts
