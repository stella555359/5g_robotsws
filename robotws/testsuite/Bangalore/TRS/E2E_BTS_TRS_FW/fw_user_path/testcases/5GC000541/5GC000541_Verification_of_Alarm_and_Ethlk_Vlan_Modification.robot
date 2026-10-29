*** Settings ***
Documentation
...     [Author]        "kamal"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
...     [QC_Path]   "QC_Path in Test Plan"
...     [QC_ID]     ". . ."
...     [Feature_ID]            "5GC000541"
...     [Requirement ID]    "TT_IPT.1842,TT_IPT.1845,TT_IPT.1847,TT_IPT.1848,TT_L2.1418,TT_L2.1433,TT_L2.1453,TT_L2.1454,TT_L2.1455,
...     TT_L2.1650,TT_L2.1671 ,TT_L2.1649, TT_L2.1648,TT_L2.1670,  TT_L2.1663, TT_L2.1661, TT_L2.1662, TT_L2.1456,TT_L2.1429,TT_L2.1430,
...     TT_L2.1431,TT_L2.1510, TT_L2.1512 , TT_L2.1513 , TT_L2.1675, TT_L2.1514, TT_L2.2596,  TT_L2.1672,  TT_L2.1432, TT_L2.1653, TT_L2.1647,
...     TT_L2.1427, TT_L2.2600, TT_L2.1547,TT_L2.1646,TT_L2.1459,TT_L2.1523,TT_L2.1541"
...     [Validated_TestLine]    "TBU"
...     [Config]    "This testscript expects configuration with vlan,Non-Compliant SFP at eif2.  "
...	    [Runtime param]	  "bts_id is provided at run time."

variables       ta_e2e_bts_trs_fw

Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
Resource        ${CURDIR}/../resources/common_keywords.robot


Suite Setup     Run Keywords        Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions
...     AND     Teardown Oamops




*** Test Cases ***
[1]5GC000541_BTS_Transport Alarm Handling
    Perform Commissioning       scf_file=${ETHERNET_WITHOUT_VLAN}   verify_bts_status=False     timeout=400     alias=default
    sleep   900

    Read mplane and gateway IP
    wireshark check for ucms without vlan

    Perform Commissioning       scf_file=${ETHERNET_VLAN}   verify_bts_status=False     timeout=400     alias=default
    sleep    900

    Read vlan ID
    wireshark check for ucms with vlan

##ethlk_lock_unlock_mac_address_check
	Perform Recommissioning     type=param      rat=common     param_path=${ethlk1_moc_locked}  operation=update    value=locked     timeout=300
    sleep    30
    verify the op state for ethlk-1 is 'disabled'
    sleep    30
	Perform Recommissioning     type=param      rat=common     param_path=${ethlk1_moc_unlocked}  operation=update    value=unlocked     timeout=300
    sleep    30
    Verify Alarm            faultid=61050     should_exist=${False}      occurrences=${1}
	verify the op state for ethlk-1 is 'enabled'

    check the mac address of eif1 interface
	Reset Bts      verify_bts=False       should_be_onair=False   wait_for=300
	Sleep   900
	verify the op state for ethlk-1 is 'enabled'
	create los on ethlk1 and check the los alarm on eif1
	verify the op state for ethlk-1 is 'disabled'
    clear the los on ethlk1
	verify the op state for ethlk-1 is 'enabled'
	check the mac address of eif1 interface

	Perform Recommissioning     type=delta      rat=common     delta_file=${ethlk2_moc_locked}  timeout=300
	sleep   60
    Perform Recommissioning     type=param      rat=common     param_path=${ethlk2_moc_unlocked}  operation=update    value=unlocked     timeout=300
	check the non complaint sfp alarm on eif2


*** Keywords ***
wireshark check for ucms without vlan

    Traffic Capture Start   capture_device=bts     alias=wo_vlan_pcap
    ping from mplane interface ip to core
    ${wo_vlan_pcap}=       Traffic Capture Stop        alias=wo_vlan_pcap
    Analyse pcap            pcap_filename=${wo_vlan_pcap}      analysis=wo_vlan_tagging      filter_file_name=${wo_vlan_filter_file}
    [Teardown]     Run Keyword And Ignore Error      Traffic capture stop     alias=wo_vlan_pcap


ping from mplane interface ip to core
    verify ping test success '${mplaneIP}' for '${gatewayIP}'

verify ping test success '${InterfaceIP}' for '${coreIP}'
    Execute command on ENodeB   ping -I ${InterfaceIP} ${coreIP} -c 5
    Should Contain     ${stdout}    5 packets transmitted, 5 received, 0% packet loss

wireshark check for ucms with vlan
    Traffic Capture Start   capture_device=bts     alias=vlan_pcap
    ping from mplane interface ip to core
    ${vlan_pcap}=       Traffic Capture Stop        alias=vlan_pcap
    Analyse pcap            pcap_filename=${vlan_pcap}      analysis=vlan_tagging      filter_file_name=${wo_vlan_filter_file}
    [Teardown]     Run Keyword And Ignore Error      Traffic capture stop     alias=vlan_pcap


verify the op state for ethlk-1 is '${state}'
    ${op_status}=      Query Admin Infomodel    query=get object ${query_operational_state}    timeout=100
    Should be equal     ${op_status['operationalState']}    ${state}

check the non complaint sfp alarm on eif2
	verify alarm	faultid=${noncomplaintsfpfaultid}

create los on ethlk1 and check the los alarm on eif1
	login to switch for disable for '${du_bh_interface}'
    sleep   20
	verify alarm	faultid=${losfaultid}

clear the los on ethlk1
	login to switch for enable for '${du_bh_interface}'
    sleep   20
    verify alarm	faultid=${losfaultid}	should_exist=${false}

login to switch for enable for '${bh_interface}'
    Log     ${bh_interface}
	configure switch	bts_switch 	test_commands_enable

login to switch for disable for '${bh_interface}'
    Log    ${bh_interface}
	configure switch	bts_switch 	test_commands_disable

check the mac address of eif1 interface
	Execute command on ENodeB	ifconfig fp0 |grep ether |awk '{print $2}'
	${mac_eif1}=      Query Admin Infomodel	query=get object ${query_mac_addr}	timeout=100
	Should Be equal     ${stdout}	${mac_eif1['macAddr']}

Read mplane and gateway IP
        ${mplaneIP}=     Get Parameter   param_path=${mplane_ipv4_moc}
        Set Suite Variable          ${mplaneIP}
        ${gatewayIP}=     Get Parameter   param_path=${GWIP_moc}
        Set Suite Variable          ${gatewayIP}

Read vlan ID
        ${vlan_ID}=      Get Parameter   param_path=${vlan_interface_moc}-*:vlanId
        Set Suite Variable          ${vlan_ID}
