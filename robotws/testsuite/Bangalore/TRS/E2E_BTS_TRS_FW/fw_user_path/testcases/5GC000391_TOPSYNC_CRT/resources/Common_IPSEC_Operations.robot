*** Settings ***
Documentation
...		[Author]     	"Nandini R"
...		[Maintenance]	"TRS I & V Tools Bangalore Team"

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

	Run        sudo ifconfig eth3 inet6 add fc00::1/116
	Run        sudo ip link add link eth3 name eth3.@{tl.vlan_ids}[0] type vlan id @{tl.vlan_ids}[0]
	Run        sudo ip addr add 10.0.3.209/30 brd 10.0.3.211 dev eth3.@{tl.vlan_ids}[0]
	Run        sudo ip -6 addr add fc00::3:6/126 dev eth3.@{tl.vlan_ids}[0]
	Run        sudo ip link set dev eth3.@{tl.vlan_ids}[0] up
	Run        sudo ip link add link eth3 name eth3.@{tl.vlan_ids}[1] type vlan id @{tl.vlan_ids}[1]
	Run        sudo ip addr add 10.0.3.213/30 brd 10.0.3.215 dev eth3.@{tl.vlan_ids}[1]
	Run        sudo ip -6 addr add fc00::3:a/126 dev eth3.@{tl.vlan_ids}[1]
	Run        sudo ip link set dev eth3.@{tl.vlan_ids}[1] up
	Run        sudo ip link add link eth3 name eth3.@{tl.vlan_ids}[2] type vlan id @{tl.vlan_ids}[2]
	Run        sudo ip addr add 10.0.3.217/30 brd 10.0.3.219 dev eth3.@{tl.vlan_ids}[2]
	Run        sudo ip -6 addr add fc00::3:e/126 dev eth3.@{tl.vlan_ids}[2]
	Run        sudo ip link set dev eth3.@{tl.vlan_ids}[2] up
	Run        sudo ip link add link eth3 name eth3.@{tl.vlan_ids}[3] type vlan id @{tl.vlan_ids}[3]
	Run        sudo ip addr add 10.0.3.221/30 brd 10.0.3.223 dev eth3.@{tl.vlan_ids}[3]
	Run        sudo ip -6 addr add fc00::3:12/126 dev eth3.@{tl.vlan_ids}[3]
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
	Run		sudo ipsec restart
Disable Ipsec on SecureGW
	Run		sudo ipsec stop

Enable Ipsec on Admin
	[Arguments]		${alias}=default
	Perform Recommissioning		type=param		rat=lte		param_path=IPSECC-1:ipSecEnabled	operation=update	value=true
    ...		timeout=300		alias=${alias}
	Sleep	120
Disable Ipsec on Admin
	[Arguments]		${alias}=default
	Perform Recommissioning		type=param		rat=lte		param_path=IPSECC-1:ipSecEnabled	operation=update	value=false
    ...		timeout=300		alias=${alias}
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

Verify IPSEC Security Association
	[Arguments]		${policy}=${default_policy} 		${no_association}=${False}		${Enb_IP}=192.168.255.129
	:FOR	${i}	IN		@{policy}
    \		Execute command on ENodeB		ipsec status | grep conn${i}		${Enb_IP}
    \		Run Keyword If		${no_association}==${False}		Should Match Regexp		${stdout}	.*ESTABLISHED.*
	\		Run Keyword If		${no_association}==${False}		Should Match Regexp		${stdout}	.*INSTALLED.*
	\		Run Keyword If		${no_association}==${True}		Should Not Match Regexp		${stdout}	.*ESTABLISHED.*
	\		Run Keyword If		${no_association}==${True}		Should Not Match Regexp		${stdout}	.*INSTALLED.*

	:FOR	${i}	IN		@{policy}
    \		${a}=   Run		sudo ipsec status | grep conn${i}
    \		Run Keyword If		${no_association}==${False}		Should Match Regexp		${a}	.*ESTABLISHED.*
	\		Run Keyword If		${no_association}==${False}		Should Match Regexp		${a}	.*INSTALLED.*
	\		Run Keyword If		${no_association}==${True}		Should Not Match Regexp		${a}	.*ESTABLISHED.*
	\		Run Keyword If		${no_association}==${True}		Should Not Match Regexp		${a}	.*INSTALLED.*
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
