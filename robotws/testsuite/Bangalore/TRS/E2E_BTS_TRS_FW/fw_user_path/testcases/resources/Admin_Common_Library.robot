*** Settings ***
Documentation
...		[Author]     	"Nandini R"
...		[Maintenance]	"TRS I & V Tools Bangalore Team"

Variables		ta_e2e_bts_trs_fw
Resource		taf/rfrl/trs_e2e_fw/setup/framework.robot
Library			SSHLibrary

*** Variables ***
${enb_root_user}			toor4nsn
${enb_root_passwd}			oZPS0POrRieRtu
${bts_root_user}			ute
${bts_root_passwd}			ute
${wft_profile}          ${CURDIR}/wft_filters.json

*** Keywords ***
Configure Certificate in Admin
	[Arguments]			${Cert_file}		${Cert_type}		${Cert_format}		${password}=None	${alias}=default
	Certificate Configure		operation=install_certificate		cert_file=${Cert_file}		cert_type=${Cert_type}
	...     cert_format=${Cert_format}		password=${password}	timeout=300		alias=${alias}


Update VLAN ID's of Commissioning File
	[Arguments]     ${directory_path}	${Comm_file}
	Run     sudo sed -i "s/{{vlan_id_1}}/@{tl.vlan_ids}[0]/g" ${directory_path}/${Comm_file}
	Run     sudo sed -i "s/{{vlan_id_2}}/@{tl.vlan_ids}[1]/g" ${directory_path}/${Comm_file}
	Run     sudo sed -i "s/{{vlan_id_3}}/@{tl.vlan_ids}[2]/g" ${directory_path}/${Comm_file}
	Run     sudo sed -i "s/{{vlan_id_4}}/@{tl.vlan_ids}[3]/g" ${directory_path}/${Comm_file}

Execute command on ENodeB
    [Arguments]    ${cmd}           ${enb_ip}=192.168.255.129		${enb_root_user}=toor4nsn    ${enb_root_passwd}=oZPS0POrRieRtu
    ${ssh_enb_handle}      SSHLibrary.Open Connection    ${enb_ip}
    SSHLibrary.Login                  ${enb_root_user}    ${enb_root_passwd}
    SSHLibrary.Switch Connection      ${ssh_enb_handle}
    ${stdout}  ${stderr}   SSHLibrary.Execute Command       ${cmd}    return_stdout=${True}  return_stderr=${True}
    Set Suite Variable    ${stdout}
    Set Suite Variable    ${stderr}
    SSHLibrary.Close Connection

Execute command on btsip
    [Arguments]    ${cmd_bts}           ${bts_ip}		${bts_root_user}=ute    ${bts_root_passwd}=ute
    ${ssh_enb_handle}      SSHLibrary.Open Connection    ${bts_ip}
    SSHLibrary.Login                  ${bts_root_user}    ${bts_root_passwd}
    SSHLibrary.Switch Connection      ${ssh_bts_handle}
    ${stdout}  ${stderr}   SSHLibrary.Execute Command       ${cmd_bts}    return_stdout=${True}  return_stderr=${True}
    Set Suite Variable    ${stdout}
    Set Suite Variable    ${stderr}
    SSHLibrary.Close Connection


Get File for ENodeB
	[Arguments]		${source_file}		${destination_file}		${enb_ip}=192.168.255.129
	${ssh_enb_handle}      SSHLibrary.Open Connection    ${enb_ip}
    SSHLibrary.Login                  ${enb_root_user}    ${enb_root_passwd}
    SSHLibrary.Switch Connection      ${ssh_enb_handle}
    SSHLibrary.Get File       ${source_file}   ${destination_file}
    SSHLibrary.Close Connection

Put File for ENodeB
	[Arguments]		${source_file}		${destination_file}		${enb_ip}=192.168.255.129
	${ssh_enb_handle}      SSHLibrary.Open Connection    ${enb_ip}
    SSHLibrary.Login                  ${enb_root_user}    ${enb_root_passwd}
    SSHLibrary.Switch Connection      ${ssh_enb_handle}
    SSHLibrary.Get File       ${source_file}   ${destination_file}
    SSHLibrary.Close Connection

Collect Snapshot Logs
	Collect Im Snapshot
	Collect Snapshot

HW reboot of I-PHY and eNB
	Setup Pdu       ${tl.pdu_ip}        ${tl.pdu_type}
	Pdu Outlet Reset    ${tl.enb_pdu_outlet}
	Sleep    50
	Pdu Outlet Reset    ${tl.iphy_pdu_outlet}
	Teardown Pdu

Download BTS_TRS File from eNB
	[Arguments]    	${alias}=default
	Generate Scf	target_file=/tmp/192.168.255.129_scf.xml	alias=${alias}

Perform Full Commissioning
	[Arguments]		${commissioning_file}		${alias}=default
	Perform Commissioning		scf_file=${commissioning_file}	verify_bts_status=False     timeout=400     alias=${alias}

Perform Delta Commissioning
	[Arguments]		${commissioning_file}		${alias}=default
	Perform Recommissioning		type=delta		delta_file=${commissioning_file}		skip_parameter_relation_errors=${True}
	...     timeout=300		alias=${alias}

Perform Parameter Commissioning
	[Arguments]		${Param_value}	 ${alias}=default
	@{Parameter_List}=		 Split String        ${Param_value}      :       max_split=3
	Perform Recommissioning		type=param		param_path=@{Parameter_List}[0]:@{Parameter_List}[1]	operation=@{Parameter_List}[2]
	...      value=@{Parameter_List}[3]		timeout=300		alias=${alias}


Get UCMS Planes' IPs
    Download BTS_TRS File from eNB
    ${s1linkIP}=   Get Element Text  	/tmp/192.168.255.129_scf.xml 	.//managedObject[@distName="MRBTS-1/LNBTS-1/LNMME-0"]/p[@name="ipAddrPrim"]

    ${enb_mPlane_ip_pointer}=   Get Element Text
    ...     /tmp/192.168.255.129_scf.xml    .//managedObject[@distName="MRBTS-1/MNL-1/MNLENT-1/MPLANENW-1"]/p[@name="mPlaneIpv4AddressDN"]
    ${enb_sPlane_ip_pointer}=	Get Element Text
    ...     /tmp/192.168.255.129_scf.xml    .//managedObject[@distName="MRBTS-1/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1"]/p[@name="sPlaneIpAddressDN"]

    ${enb_mPlane_ip}=		Get Element Text     /tmp/192.168.255.129_scf.xml
    ...     .//managedObject[@distName="${enb_mPlane_ip_pointer}"]/p[@name="localIpAddr"]
    ${enb_sPlane_ip}=   	Get Element Text     /tmp/192.168.255.129_scf.xml
    ...    .//managedObject[@distName="${enb_sPlane_ip_pointer}"]/p[@name="localIpAddr"]

	${status}=   Run Keyword And Return Status		Get Element Text
	...    /tmp/192.168.255.129_scf.xml    .//managedObject[@distName="MRBTS-1/LNBTS-1/TRSNW-0"]/list[@name="uPlane"]/item/p[@name="ipV4AddressDN1"]
	${TRSNW_MOC}=		Set Variable If		'${status}' == 'True'		TRSNW-0		TRSNW-1
	${enb_uPlane_ip_pointer}=   Get Element Text    /tmp/192.168.255.129_scf.xml
	...         .//managedObject[@distName="MRBTS-1/LNBTS-1/${TRSNW_MOC}"]/list[@name="uPlane"]/item/p[@name="ipV4AddressDN1"]
    ${enb_cPlane_ip_pointer}=   Get Element Text     /tmp/192.168.255.129_scf.xml
    ...      .//managedObject[@distName="MRBTS-1/LNBTS-1/${TRSNW_MOC}"]/list[@name="cPlane"]/item/p[@name="ipV4AddressDN1"]
    ${enb_uPlane_ip}=           Get Element Text     /tmp/192.168.255.129_scf.xml
    ...        .//managedObject[@distName="${enb_uPlane_ip_pointer}"]/p[@name="localIpAddr"]
    ${enb_cPlane_ip}=		Get Element Text     /tmp/192.168.255.129_scf.xml
    ...       .//managedObject[@distName="${enb_cPlane_ip_pointer}"]/p[@name="localIpAddr"]

    Set Suite Variable		${enb_uPlane_ip}
    Set Suite Variable  	${enb_cPlane_ip}
    Set Suite Variable  	${enb_mPlane_ip}
    Set Suite Variable  	${enb_sPlane_ip}
    Set Suite Variable  	${s1linkIP}

Get UCMS Planes' IPv6 IP's
    Download BTS_TRS File from eNB
    ${s1linkIPv6}=   Get Element Text  	/tmp/192.168.255.129_scf.xml 	.//managedObject[@distName="MRBTS-1/LNBTS-1/LNMME-0"]/p[@name="ipAddrPrim"]

    ${enb_mPlane_ip_pointer}=   Get Element Text     /tmp/192.168.255.129_scf.xml
    ...       .//managedObject[@distName="MRBTS-1/MNL-1/MNLENT-1/MPLANENW-1"]/p[@name="mPlaneIpv6AddressDN"]
    ${enb_sPlane_ip_pointer}=	Get Element Text     /tmp/192.168.255.129_scf.xml
    ...            .//managedObject[@distName="MRBTS-1/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1"]/p[@name="sPlaneIpAddressDN"]
    ${enb_mPlane_ipv6}=		Get Element Text     /tmp/192.168.255.129_scf.xml
    ...             .//managedObject[@distName="${enb_mPlane_ip_pointer}"]/p[@name="localIpAddr"]
    ${enb_sPlane_ip}=   	Get Element Text     /tmp/192.168.255.129_scf.xml
    ...     .//managedObject[@distName="${enb_sPlane_ip_pointer}"]/p[@name="localIpAddr"]

	${status}=   Run Keyword And Return Status		Get Element Text     /tmp/192.168.255.129_scf.xml
	...      .//managedObject[@distName="MRBTS-1/LNBTS-1/TRSNW-0"]/list[@name="uPlane"]/item/p[@name="ipV6AddressDN1"]
	${TRSNW_MOC}=		Set Variable If		'${status}' == 'True'		TRSNW-0		TRSNW-1

	${enb_uPlane_ip_pointer}=   Get Element Text     /tmp/192.168.255.129_scf.xml
	...    .//managedObject[@distName="MRBTS-1/LNBTS-1/${TRSNW_MOC}"]/list[@name="uPlane"]/item/p[@name="ipV6AddressDN1"]
    ${enb_cPlane_ip_pointer}=   Get Element Text     /tmp/192.168.255.129_scf.xml
    ...      .//managedObject[@distName="MRBTS-1/LNBTS-1/${TRSNW_MOC}"]/list[@name="cPlane"]/item/p[@name="ipV6AddressDN1"]
    ${enb_uPlane_ipv6}=		Get Element Text     /tmp/192.168.255.129_scf.xml
    ...      .//managedObject[@distName="${enb_uPlane_ip_pointer}"]/p[@name="localIpAddr"]
    ${enb_cPlane_ipv6}=		Get Element Text     /tmp/192.168.255.129_scf.xml
    ...       .//managedObject[@distName="${enb_cPlane_ip_pointer}"]/p[@name="localIpAddr"]
    Set Suite Variable		${enb_uPlane_ipv6}
    Set Suite Variable  	${enb_cPlane_ipv6}
    Set Suite Variable  	${enb_mPlane_ipv6}
    Set Suite Variable  	${enb_sPlane_ip}
    Set Suite Variable  	${s1linkIPv6}

Sofware downgrade and upgrade the build for trunk
	Perform Software Download And Update    wft_profile=sbtstrunk_00      package=auto    activate_sw=True    update_timeout=1800


Verify ping test success
    [Arguments]     ${Interface_IP}    ${Destination_IP}
    ${output}=  Run     ping -I ${Interface_IP} ${Destination_IP} -c 5
	Should Contain     ${output}    5 packets transmitted, 5 received, 0% packet loss

Verify ping test failure
    [Arguments]     ${Interface_IP}    ${Destination_IP}
    ${output}=  Run     ping -I ${Interface_IP} ${Destination_IP} -c 5
    Should Contain     ${output}    100% packet loss

Ping test
	[Arguments]    ${cmd}		${expected_output}		${version}
	${output}=   Run Keyword If		'${version}'=='IPv4'			ping ${cmd}
	...			 ELSE IF		'${version}'=='IPv6'			ping -6 ${cmd}
	#Set Suite Variable		${ping_test_output}		${output}
	Should contain		${output}		${expected_output}
