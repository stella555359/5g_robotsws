*** Settings ***
Documentation
...		[Author]     	"Nandini R"
...		[Maintenance]	"TRS I & V Tools Bangalore Team"

#Library			${CURDIR}/../resources/ipsec_expert.py

*** Keywords ***

Perform vlan configuration
	[Arguments]		${Comm_file}
	Run		sudo sed -i "s/{{vlan_id_1}}/@{tl.vlan_ids}[0]/g" ${scf_dir}/${Comm_file}
	Run		sudo sed -i "s/{{vlan_id_2}}/@{tl.vlan_ids}[1]/g" ${scf_dir}/${Comm_file}
	Run		sudo sed -i "s/{{vlan_id_3}}/@{tl.vlan_ids}[2]/g" ${scf_dir}/${Comm_file}
	Run		sudo sed -i "s/{{vlan_id_4}}/@{tl.vlan_ids}[3]/g" ${scf_dir}/${Comm_file}

	Perform Commissioning		scf_file=${Comm_file}		verify_bts_status=False
	Sleep	180
	Configure Certificate in Admin		${Ipsec_Cert_file}		BtsTrustChain		P12		${Ipsec_Cert_password}

	Run        sudo ip link add link eth3 name eth3.@{tl.vlan_ids}[0] type vlan id @{tl.vlan_ids}[0]
	Run        sudo ip addr add 10.0.3.209/30 brd 10.0.3.211 dev eth3.@{tl.vlan_ids}[0]
	Run        sudo ip link set dev eth3.@{tl.vlan_ids}[0] up

	Run        sudo ip link add link eth3 name eth3.@{tl.vlan_ids}[1] type vlan id @{tl.vlan_ids}[1]
	Run        sudo ip addr add 10.0.3.213/30 brd 10.0.3.215 dev eth3.@{tl.vlan_ids}[1]
	Run        sudo ip link set dev eth3.@{tl.vlan_ids}[1] up

	Run        sudo ip link add link eth3 name eth3.@{tl.vlan_ids}[2] type vlan id @{tl.vlan_ids}[2]
	Run        sudo ip addr add 10.0.3.217/30 brd 10.0.3.219 dev eth3.@{tl.vlan_ids}[2]
	Run        sudo ip link set dev eth3.@{tl.vlan_ids}[2] up

	Run        sudo ip link add link eth3 name eth3.@{tl.vlan_ids}[3] type vlan id @{tl.vlan_ids}[3]
	Run        sudo ip addr add 10.0.3.221/30 brd 10.0.3.223 dev eth3.@{tl.vlan_ids}[3]
	Run        sudo ip link set dev eth3.@{tl.vlan_ids}[3] up

Perform vlan non collapsed configuration
	[Arguments]		${Comm_file}
	Run		sudo sed -i "s/{{vlan_id_1}}/@{tl.vlan_ids}[0]/g" ${scf_dir}/${Comm_file}
	Run		sudo sed -i "s/{{vlan_id_2}}/@{tl.vlan_ids}[1]/g" ${scf_dir}/${Comm_file}
	Run		sudo sed -i "s/{{vlan_id_3}}/@{tl.vlan_ids}[2]/g" ${scf_dir}/${Comm_file}
	Run		sudo sed -i "s/{{vlan_id_4}}/@{tl.vlan_ids}[3]/g" ${scf_dir}/${Comm_file}

	Perform Commissioning		scf_file=${Comm_file}		verify_bts_status=False
	Sleep	180
	Configure Certificate in Admin		${Ipsec_Cert_file}		BtsTrustChain		P12		${Ipsec_Cert_password}

	Run        sudo ip link add link eth3 name eth3.@{tl.vlan_ids}[0] type vlan id @{tl.vlan_ids}[0]
	Run        sudo ip addr add 10.0.3.233/30 brd 10.0.3.235 dev eth3.@{tl.vlan_ids}[0]
	Run        sudo ip link set dev eth3.@{tl.vlan_ids}[0] up

	Run        sudo ip link add link eth3 name eth3.@{tl.vlan_ids}[1] type vlan id @{tl.vlan_ids}[1]
	Run        sudo ip addr add 10.0.3.237/30 brd 10.0.3.239 dev eth3.@{tl.vlan_ids}[1]
	Run        sudo ip link set dev eth3.@{tl.vlan_ids}[1] up

	Run        sudo ip link add link eth3 name eth3.@{tl.vlan_ids}[2] type vlan id @{tl.vlan_ids}[2]
	Run        sudo ip addr add 10.0.3.241/30 brd 10.0.3.243 dev eth3.@{tl.vlan_ids}[2]
	Run        sudo ip link set dev eth3.@{tl.vlan_ids}[2] up

	Run        sudo ip link add link eth3 name eth3.@{tl.vlan_ids}[3] type vlan id @{tl.vlan_ids}[3]
	Run        sudo ip addr add 10.0.3.245/30 brd 10.0.3.247 dev eth3.@{tl.vlan_ids}[3]
	Run        sudo ip link set dev eth3.@{tl.vlan_ids}[3] up

    Run        sudo ip route add 10.0.3.210 via 10.0.3.234 dev eth3.@{tl.vlan_ids}[0]
	Run        sudo ip route add 10.0.3.214 via 10.0.3.238 dev eth3.@{tl.vlan_ids}[1]
	Run        sudo ip route add 10.0.3.218 via 10.0.3.242 dev eth3.@{tl.vlan_ids}[2]
	Run        sudo ip route add 10.0.3.222 via 10.0.3.246 dev eth3.@{tl.vlan_ids}[3]

Enable Ipsec on SecureGW
	Run		sudo ipsec start

Disable Ipsec on SecureGW
	Run		sudo ipsec stop

Restart Ipsec on SecureGW
	Setup Remote Access		remote_device=secure_gw
	${output}=		Remote Command Execute		command=sudo ipsec restart
	[Teardown]		Teardown Remote Access

Enable Ipsec on external SecureGW
	Setup Remote Access		remote_device=secure_gw
	${output}=		Remote Command Execute		command=sudo ipsec start
	Log	${output}
	[Teardown]		Teardown Remote Access

Disable Ipsec on external SecureGW
	Setup Remote Access		remote_device=secure_gw
	${output}=		Remote Command Execute		command=sudo ipsec stop
	Log	${output}
	[Teardown]		Teardown Remote Access

Restart Ipsec on external SecureGW
	Setup Remote Access		remote_device=secure_gw
	${output}=		Remote Command Execute		command=sudo ipsec restart
	Log	${output}
	[Teardown]		Teardown Remote Access

Configure ipsec file on external SecureGW
	[Arguments]		${file}
	Setup Remote Access		remote_device=secure_gw
	${output}=		Remote Command Execute		command=sudo unlink /etc/ipsec.conf ;sudo ln -s ${file} /etc/ipsec.conf     timeout=30
	Log	${output}
	[Teardown]		Teardown Remote Access

Enable Ipsec on Admin
	[Arguments]		${alias}=default
	Perform Recommissioning		type=param		rat=lte		param_path=IPSECC-1:ipSecEnabled	operation=update	value=true
	...        timeout=300		alias=${alias}
	Sleep	120

Disable Ipsec on Admin
	[Arguments]		${alias}=default
	Perform Recommissioning		type=param		rat=lte		param_path=IPSECC-1:ipSecEnabled	operation=update	value=false
	...                timeout=300		alias=${alias}


Initial Configuration for Ipsec Expert Mode
	Execute command on ENodeB		cp /ffs/run/swconfig.txt /tmp/swconfig.txt ; sed -i '$ a\'"0x45005A = 1" /ffs/run/swconfig.txt ; reboot
	Sleep	300

Ipsec Expert Mode Enable
	${output}=		Enable_Ipsec_Expert_Mode
	Should Match Regexp		'${output}'		'Ipsec Expert Mode Enabled'

Ipsec Expert Mode Disable
	${output}=		Disable_Ipsec_Expert_Mode
	Should Match Regexp		'${output}'		'Ipsec Expert Mode Disabled'

Ipsec Expert Mode Configure
	[Arguments]		${ipsec_value}=${EMPTY}
	${output}=		Configure_Ipsec_Expert_Mode		${ipsec_value}
	Should Match Regexp		'${output}'		'Ipsec Expert Mode Configuration Successful'

Verify Ipsec Tunnels Status
    [Arguments]    ${dut}=default
    @{parent_tunnel_moc_list} =    Query Admin Infomodel	query=get list ${ike_sa_l_moc_path}	    alias=${dut}
    FOR    ${ike_tunnel}	IN      @{parent_tunnel_moc_list}
     	${parent_tunnel_stateInfo}=     Get From Dictionary	dictionary=${ike_tunnel}	key=stateInfo
     	${parent_tunnel_proceduralState}=    Get From Dictionary	dictionary=${parent_tunnel_stateInfo}   	key=proceduralState
     	Should Be True	'${parent_tunnel_proceduralState}'=='Established'
    END

    @{child_tunnel_moc_list} =      Query Admin Infomodel	query=get list ${ipsec_sa_l_moc_path}	alias=${dut}
    FOR    ${child_tunnel}    IN       @{child_tunnel_moc_list}
     	${child_tunnel_stateInfo}=      Get From Dictionary	dictionary=${child_tunnel}	key=stateInfo
     	${child_tunnel_proceduralState}=        Get From Dictionary	dictionary=${child_tunnel_stateInfo}	key=proceduralState
     	Should Be True	'${child_tunnel_proceduralState}'=='Installed'
    END

Verify Ipsec Tunnels Status Not Exist
    [Arguments]    ${dut}=default
    @{parent_tunnel_moc_list} =    Query Admin Infomodel    query=get list ${ike_sa_l_moc_path}     alias=${dut}
    FOR    ${ike_tunnel}    IN      @{parent_tunnel_moc_list}
        ${parent_tunnel_stateInfo}=     Get From Dictionary     dictionary=${ike_tunnel}    key=stateInfo
        ${parent_tunnel_proceduralState}=    Get From Dictionary    dictionary=${parent_tunnel_stateInfo}       key=proceduralState
        Should Not Be True  '${parent_tunnel_proceduralState}'=='Established'
    END

    @{child_tunnel_moc_list} =      Query Admin Infomodel   query=get list ${ipsec_sa_l_moc_path}   alias=${dut}
    FOR    ${child_tunnel}    IN       @{child_tunnel_moc_list}
        ${child_tunnel_stateInfo}=      Get From Dictionary     dictionary=${child_tunnel}  key=stateInfo
        ${child_tunnel_proceduralState}=        Get From Dictionary dictionary=${child_tunnel_stateInfo}    key=proceduralState
        Should Not Be True  '${child_tunnel_proceduralState}'=='Installed'
    END


Get Local Tunnel IP
	[Arguments]	${local_ips}
	${plane_secpol_dict} = 	Query Admin Infomodel
	...     query=get object ${secpol_a_moc_path} is [trafficSelectorList[?].localIpAddress=${local_ips}]
	${plane_secpol_moc}=		Get From Dictionary	dictionary=${plane_secpol_dict}		key=dist_name
	${plane_ikep_moc}=		Get From Dictionary	dictionary=${plane_secpol_dict}		key=ikePDN
	${plane_secpol}=			Replace String Using Regexp		string=${plane_secpol_moc}		pattern=${pattern_to_replace_in_moc}
	...           replace_with=${EMPTY}

	@{plane_secpol_path}=	Split String From Right		string=${plane_secpol}	separator=/
	@{plane_ikep_path}=	Split String From Right		string=${plane_ikep_moc}	separator=/
	${plane_secpol}=	Set Variable	@{plane_secpol_path}[-1]
	${plane_ikep}=	Set Variable	@{plane_ikep_path}[-1]

	${plane_ikep_local_ip_dict} = 	Query Admin Infomodel	query=get object //${plane_ikep}
	${plane_local_ip_dn_path}=		Get From Dictionary	dictionary=${plane_ikep_local_ip_dict}		key=localTunnelEndpointDN
	@{plane_local_tunnel_path}=			Split String From Right		string=${plane_local_ip_dn_path}	separator=IPNO_A-1
	${plane_ipif_path}=	Set Variable	@{plane_local_tunnel_path}[-1]

	${local_ip_dict} = 	Query Admin Infomodel	query=get object /${plane_ipif_path}
	${local_tunnel_ip}=		Get From Dictionary	dictionary=${local_ip_dict}		key=localIpAddr
	Return From Keyword     ${local_tunnel_ip}

Get Secpol ID for IP
	[Arguments]	${local_ips}
	${plane_secpol_dict} = 	Query Admin Infomodel	query=get object ${secpol_a_moc_path} is [trafficSelectorList[?].localIpAddress=${local_ips}]
	${plane_secpol_moc}=		Get From Dictionary	dictionary=${plane_secpol_dict}		key=dist_name
	${plane_secpol}=			Replace String Using Regexp		string=${plane_secpol_moc}		pattern=${pattern_to_replace_in_moc}
	...          replace_with=${EMPTY}
	@{plane_secpol_path}=	Split String From Right		string=${plane_secpol}	separator=/
	${plane_secpol}=	Set Variable	@{plane_secpol_path}[-1]
	Return From Keyword     ${plane_secpol}

Verify IPSEC Security Association
	[Arguments]		${policy}=${default_policy} 		${no_association}=${False}		${Enb_IP}=192.168.255.129
	:FOR	${i}	IN		@{policy}
    \		Execute command on ENodeB		ipsec status | grep conn${i}		${Enb_IP}
    \		Run Keyword If		${no_association}==${False}		Should Match Regexp		${stdout}	.*ESTABLISHED .*
	\		Run Keyword If		${no_association}==${False}		Should Match Regexp		${stdout}	.*INSTALLED	.*
	\		Run Keyword If		${no_association}==${True}		Should Not Match Regexp		${stdout}	.*ESTABLISHED .*
	\		Run Keyword If		${no_association}==${True}		Should Not Match Regexp		${stdout}	.*INSTALLED	.*

	:FOR	${i}	IN		@{policy}
    \		${a}=   Run		sudo ipsec status | grep conn${i}
    \		Run Keyword If		${no_association}==${False}		Should Match Regexp		${a}	.*ESTABLISHED .*
	\		Run Keyword If		${no_association}==${False}		Should Match Regexp		${a}	.*INSTALLED	.*
	\		Run Keyword If		${no_association}==${True}		Should Not Match Regexp		${a}	.*ESTABLISHED .*
	\		Run Keyword If		${no_association}==${True}		Should Not Match Regexp		${a}	.*INSTALLED	.*

Verify IPSEC Security Association failure
	[Arguments]		${Enb_IP}=192.168.255.129
	:FOR	${i}	IN 		@{default_policy}
    \		Execute command on ENodeB		ipsec status | grep conn${i}	${Enb_IP}
    \		Should Not Match Regexp		${stdout}	.*ESTABLISHED.*
	\		Should Not Match Regexp		${stdout}	.*INSTALLED.*

	:FOR	${i}	IN 		@{default_policy}
    \		${a}=   Run		sudo ipsec status | grep conn${i}
    \		Should Not Match Regexp		${a}	.*ESTABLISHED.*
	\		Should Not Match Regexp		${a}	.*INSTALLED.*

Verify IPSEC Security Association after adding new policy
	Execute command on ENodeB		ipsec status | grep conn${new_policy}
	Should Match Regexp		${stdout}	.*ESTABLISHED.*
	Should Match Regexp		${stdout}	.*INSTALLED.*
	${new_policy_time_bts}=		Get Regexp Matches		${stdout}	.*ESTABLISHED\\s(\\d+)\\s.*	1
	${new_policy_time_bts}=		Get From List   		${new_policy_time_bts}      0

	${a}=   Run		sudo ipsec status | grep conn${new_policy}
    Should Match Regexp		${a}	.*ESTABLISHED.*
	Should Match Regexp		${a}	.*INSTALLED.*
	${new_policy_time_secgw}=		Get Regexp Matches		${a}	.*ESTABLISHED\\s(\\d+)\\s.*	1
	${new_policy_time_secgw}=		Get From List   		${new_policy_time_secgw}    0

	:FOR	${i}	IN		@{default_policy}
    \		Execute command on ENodeB		ipsec status | grep conn${i}
    \		Should Match Regexp		${stdout}	.*ESTABLISHED.*
	\		Should Match Regexp		${stdout}	.*INSTALLED.*
	\		${exis_policy_time_bts}=		Get Regexp Matches		${stdout}	.*ESTABLISHED\\s(\\d+)\\s.*	1
	\		${exis_policy_time_bts}=		Get From List   		${exis_policy_time_bts}     0
	\		Should be true		${exis_policy_time_bts}>${new_policy_time_bts}


	:FOR	${i}	IN		@{default_policy}
    \		${a}=   Run		sudo ipsec status | grep conn${i}
    \		Should Match Regexp		${a}	.*ESTABLISHED.*
	\		Should Match Regexp		${a}	.*INSTALLED.*
	\		${exis_policy_time_secgw}=		Get Regexp Matches		${a}	.*ESTABLISHED\\s(\\d+)\\s.*	1
	\		${exis_policy_time_secgw}=		Get From List   		${exis_policy_time_secgw}       0
	\		Should be true		${exis_policy_time_secgw}>${new_policy_time_secgw}

IPSEC Expert Mode Alarm should Exist
	Verify Alarm		faultid=61647

IPSEC Expert Mode Alarm should Not Exist
	Verify Alarm		faultid=61647		should_exist=${False}

Add Policy file in secureGW
	[Arguments]		${Policy_file}
    Run     sudo cp ${ipsec_config_path_secgw}/ipsec.conf ${ipsec_config_path_secgw}/ipsec_bkp.conf
    Run     sudo cp ${Policy_file} ${ipsec_config_path_secgw}/ipsec.conf
    Run     sudo ipsec restart
    Sleep	60

Restore Policy file in secureGW
	Run     sudo cp ${ipsec_config_path_secgw}/ipsec_bkp.conf ${ipsec_config_path_secgw}/ipsec.conf

Perform ipv6 vlan configuration
	[Arguments]		${Comm_file}
	Run		sudo sed -i "s/{{vlan_id_1}}/@{tl.vlan_ids}[0]/g" ${scf_dir}/${Comm_file}
	Run		sudo sed -i "s/{{vlan_id_2}}/@{tl.vlan_ids}[1]/g" ${scf_dir}/${Comm_file}
	Run		sudo sed -i "s/{{vlan_id_3}}/@{tl.vlan_ids}[2]/g" ${scf_dir}/${Comm_file}
	Run		sudo sed -i "s/{{vlan_id_4}}/@{tl.vlan_ids}[3]/g" ${scf_dir}/${Comm_file}

	Perform Commissioning		scf_file=${Comm_file}		verify_bts_status=False
	Configure Certificate in Admin		${Ipsec_Cert_file}		BtsTrustChain		P12		${Ipsec_Cert_password}

	Run        sudo ifconfig eth3 inet6 add fc00::1/116

	Run        sudo ip link add link eth3 name eth3.@{tl.vlan_ids}[0] type vlan id @{tl.vlan_ids}[0]
	Run        sudo ip -6 addr add fc00::3:6/126 dev eth3.@{tl.vlan_ids}[0]
	Run        sudo ip link set dev eth3.@{tl.vlan_ids}[0] up

	Run        sudo ip link add link eth3 name eth3.@{tl.vlan_ids}[1] type vlan id @{tl.vlan_ids}[1]
	Run        sudo ip -6 addr add fc00::3:a/126 dev eth3.@{tl.vlan_ids}[1]
	Run        sudo ip link set dev eth3.@{tl.vlan_ids}[1] up

	Run        sudo ip link add link eth3 name eth3.@{tl.vlan_ids}[2] type vlan id @{tl.vlan_ids}[2]
	Run        sudo ip -6 addr add fc00::3:e/126 dev eth3.@{tl.vlan_ids}[2]
	Run        sudo ip link set dev eth3.@{tl.vlan_ids}[2] up

	Run        sudo ip link add link eth3 name eth3.@{tl.vlan_ids}[3] type vlan id @{tl.vlan_ids}[3]
	Run        sudo ip -6 addr add fc00::3:12/126 dev eth3.@{tl.vlan_ids}[3]
	Run        sudo ip link set dev eth3.@{tl.vlan_ids}[3] up
