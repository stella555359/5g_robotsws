*** Settings ***
Documentation
...     [Author]        "kamal"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
...     [Feature_ID]            "5GC000541"
...     [Requirement ID]    "TT_IPT.1842,TT_IPT.1845,TT_IPT.1847,TT_IPT.1848,TT_L2.1418,TT_L2.1433,TT_L2.1453,TT_L2.1454,TT_L2.1455,
...     TT_L2.1650,TT_L2.1671,TT_L2.1649, TT_L2.1648,TT_L2.1670,  TT_L2.1663, TT_L2.1661, TT_L2.1662, TT_L2.1456,TT_L2.1429,TT_L2.1430,
...     TT_L2.1431,TT_L2.1510, TT_L2.1512 , TT_L2.1513 , TT_L2.1675, TT_L2.1514, TT_L2.2596,  TT_L2.1672,  TT_L2.1432, TT_L2.1653, TT_L2.1647,
...     TT_L2.1427, TT_L2.2600, TT_L2.1547,TT_L2.1646,TT_L2.1459,TT_L2.1523,TT_L2.1541"
...     [Validated_TestLine]    "TBU"
...     [Config]    "This testscript expects IPV4 basic configurations, scf should not have pcp/dscp mapping initially."
...	    [Runtime param]	  "bts_id is provided at run time."


variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
Resource        ${CURDIR}/../resources/common_keywords.robot


Suite Setup     Run Keywords        Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions
...     AND     Teardown Oamops





*** Test Cases ***

[1]5GC000541_TRS PcP marking

    Perform Commissioning       scf_file=${ETHERNET_VLAN}   verify_bts_status=False     timeout=400     alias=default
    sleep   900
    Read mplane and gateway IP
    Read vlan ID
	check wireshark for dscp2pcp values mapping for no pcp
	Perform Recommissioning     type=delta      rat=common     delta_file=${dscp_2_qmap_and_pcpmap}  timeout=300
	sleep   30
	check wireshark for dscp2pcp values mapping for pcp
	Perform Recommissioning     type=delta      rat=common     delta_file=${change_dscp_2_pcpmap}  timeout=300

    check wireshark for dscp2pcp values mapping for changedpcp
	Reset Bts      verify_bts=False       should_be_onair=False   wait_for=300
    sleep   900
	check wireshark for dscp2pcp values mapping for changedpcp

    Perform Recommissioning     type=delta      rat=common     delta_file=${change_dscp_2_pcpmap_1}  timeout=300

    check wireshark for arp dscp2pcp values for arp pcp

    verify counters for vlanif

    Perform Commissioning       scf_file=${ETHERNET_WITHOUT_VLAN}   verify_bts_status=False     timeout=400     alias=default
    sleep   900

    verify counters for ethif ethlk


***Keywords***

check wireshark for dscp2pcp values mapping for no pcp
    Traffic Capture Start   capture_device=bts     alias=wo_pcp_pcap
    ping from vlan interface ip to core
    Sleep   20
    ${wo_pcp_pcap}=       Traffic Capture Stop        alias=wo_pcp_pcap
    Analyse pcap            pcap_filename=${wo_pcp_pcap}      analysis=wo_pcp      filter_file_name=${wo_vlan_filter_file}
    [Teardown]     Run Keyword And Ignore Error      Traffic capture stop     alias=wo_pcp_pcap

ping from vlan interface ip to core
    verify ping test success '${mplaneIP}' for '${gatewayIP}'


verify ping test success '${InterfaceIP}' for '${coreIP}'
    Execute command on ENodeB   ping -I ${InterfaceIP} ${coreIP} -c 5 -Q 40
    Should Contain     ${stdout}    5 packets transmitted, 5 received, 0% packet loss

verify ping test success1 '${InterfaceIP}' for '${coreIP}'
    Execute command on ENodeB   ping -I ${InterfaceIP} ${coreIP} -c 5 -Q 40

check wireshark for dscp2pcp values mapping for pcp
    Read vlan Priority
    Traffic Capture Start   capture_device=bts     alias=pcp_pcap
    ping from vlan interface ip to core

    ${pcp_pcap}=       Traffic Capture Stop        alias=pcp_pcap
    Analyse pcap            pcap_filename=${pcp_pcap}      analysis=icmp_dscp_pcp      filter_file_name=${wo_vlan_filter_file}
    [Teardown]     Run Keyword And Ignore Error      Traffic capture stop     alias=pcp_pcap

check wireshark for dscp2pcp values mapping for changedpcp
    Read vlan Priority
    Traffic Capture Start   capture_device=bts     alias=change_pcp_pcap
    ping from vlan interface ip to core
    ${change_pcp_pcap}=       Traffic Capture Stop        alias=change_pcp_pcap
    Analyse pcap            pcap_filename=${change_pcp_pcap}      analysis=change_icmp_dscp_pcp      filter_file_name=${wo_vlan_filter_file}
    [Teardown]     Run Keyword And Ignore Error      Traffic capture stop     alias=change_pcp_pcap

check wireshark for arp dscp2pcp values for arp pcp
    Traffic Capture Start   capture_device=bts     alias=arp_pcp_pcap
    Perform Recommissioning     type=param      rat=common     param_path=${ethlk1_moc_locked}  operation=update    value=locked     timeout=300
    sleep   30
    Perform Recommissioning     type=param      rat=common     param_path=${ethlk1_moc_unlocked}  operation=update    value=unlocked     timeout=300
    sleep   30
    ping from vlan interface ip to core

    ${arp_pcp_pcap}=       Traffic Capture Stop        alias=arp_pcp_pcap
    Analyse pcap            pcap_filename=${arp_pcp_pcap}      analysis=arp_pcp      filter_file_name=${wo_vlan_filter_file}
    [Teardown]     Run Keyword And Ignore Error      Traffic capture stop     alias=arp_pcp_pcap


verify counters for vlanif
    Set reference counter values    1..*
    Pm Counters Start     analysis=vlan_statistics       counter_analysis_file=${counters_json}
    Execute command on ENodeB   ping -I ${mplaneIP} ${gatewayIP} -c 100
    Verify Pm Counters    analysis=vlan_statistics       counter_analysis_file=${counters_json}


verify counters for ethif ethlk
    Set reference counter values    1..*
    Pm Counters Start     analysis=ethernet_link_statistics       counter_analysis_file=${counters_json}
    Pm Counters Start     analysis=ethernet_interface_statistics       counter_analysis_file=${counters_json}
    Execute command on ENodeB   ping -I ${mplaneIP} ${gatewayIP} -c 100
    Verify Pm Counters    analysis=ethernet_link_statistics       counter_analysis_file=${counters_json}
    Verify Pm Counters    analysis=ethernet_interface_statistics       counter_analysis_file=${counters_json}


Read mplane and gateway IP
        ${mplaneIP}=     Get Parameter   param_path=${mplane_ipv4_moc}
        Set Suite Variable          ${mplaneIP}
        ${gatewayIP}=     Get Parameter   param_path=${GWIP_moc}
        Set Suite Variable          ${gatewayIP}

Read vlan ID
        ${vlan_ID}=      Get Parameter   param_path=${vlan_interface_moc}-*:vlanId
        Set Suite Variable          ${vlan_ID}

Read vlan Priority
        ${vlan_priority}=      Get Parameter   param_path=${vlan_prio_for_dscp_moc}${vlan_dscp}
        Set Suite Variable          ${vlan_priority}


Set reference counter values
        [Arguments]     ${Class1}
        Set Suite Variable      ${Class1}       ${Class1}
