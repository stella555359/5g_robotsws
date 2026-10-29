*** Settings ***
Documentation
...     [Author]                "Vishal G"
...     [Maintenance]           "TRS I & V Tools Bangalore Team"
...     [Feature_ID]            "5GC000541"
...     [Requirement ID]        "TT_IPT.1842,TT_IPT.1845,TT_IPT.1847,TT_IPT.1848,TT_L2.1418,TT_L2.1433,TT_L2.1453,TT_L2.1454,TT_L2.1455,TT_L2.1650,
...                              TT_L2.1671,TT_L2.1649, TT_L2.1648,TT_L2.1670,  TT_L2.1663, TT_L2.1661, TT_L2.1662, TT_L2.1456,TT_L2.1429,TT_L2.1430,
...                              TT_L2.1431,TT_L2.1510, TT_L2.1512 , TT_L2.1513 , TT_L2.1675, TT_L2.1514, TT_L2.2596,  TT_L2.1672,
...     TT_L2.1432, TT_L2.1653,
...                              TT_L2.1647, TT_L2.1427, TT_L2.2600, TT_L2.1547,TT_L2.1646,TT_L2.1459,TT_L2.1523,TT_L2.1541"
...     [Validated_TestLine]    "TBU"
...     [Config]                "This testscript expects IPV4 basic configurations, scf should not have pcp/dscp mapping initially"


variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot



Suite Setup     Run Keywords        Suite Setup Preconditions        AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions       AND     Teardown Oamops


***Test Cases***
[1][1.0] 5GC000541_TRS PcP marking
    Perform Commissioning       scf_file=${ETHERNET_VLAN}   verify_bts_status=True     timeout=400     alias=default
    sleep   300
    Read mplane and gateway IP
    Read vlan from admin

	check wireshark for dscp2pcp values mapping for no pcp
	Perform Recommissioning     type=delta      rat=common     delta_file=${dscp_2_qmap_and_pcpmap}  timeout=300

	sleep   30
	check wireshark for dscp2pcp values mapping for pcp
	Perform Recommissioning     type=delta      rat=common     delta_file=${change_dscp_2_pcpmap}  timeout=300
 	sleep   30
	check wireshark for dscp2pcp values mapping for changedpcp

    Perform Recommissioning     type=delta      rat=common     delta_file=${change_dscp_2_pcpmap_1}  timeout=300
    Sleep   30
    check wireshark for arp dscp2pcp values for arp pcp

    verify counters for vlanif



***Keywords***

check wireshark for dscp2pcp values mapping for no pcp
    Traffic Capture Start   capture_device=bts     alias=wo_pcp_pcap
    ping from vlan interface ip to core
    Sleep   20
    ${wo_pcp_pcap}=       Traffic Capture Stop        alias=wo_pcp_pcap
    Analyse pcap            pcap_filename=${wo_pcp_pcap}      analysis=wo_pcp      filter_file_name=${wo_vlan_filter_file}
    [Teardown]     Run Keyword And Ignore Error      Traffic capture stop    alias=wo_pcp_pcap

ping from vlan interface ip to core
    verify ping test success '${mplaneIP}' for '${gatewayIP}'


verify ping test success '${InterfaceIP}' for '${coreIP}'
    Execute command on GNB   ping -I ${InterfaceIP} ${coreIP} -c 50 -Q 40
    Should Contain     ${stdout}    50 packets transmitted, 50 received
verify ping test success1 '${InterfaceIP}' for '${coreIP}'
    Execute command on GNB   ping -I ${InterfaceIP} ${coreIP} -c 50 -Q 40

check wireshark for dscp2pcp values mapping for pcp
    Read vlan Priority
    Traffic Capture Start   capture_device=bts     alias=pcp_pcap
    ping from vlan interface ip to core

    ${pcp_pcap}=       Traffic Capture Stop        alias=pcp_pcap
    Analyse pcap            pcap_filename=${pcp_pcap}      analysis=icmp_dscp_pcp      filter_file_name=${wo_vlan_filter_file}
    [Teardown]     Run Keyword And Ignore Error      Traffic capture stop

check wireshark for dscp2pcp values mapping for changedpcp
    Read vlan Priority
    Traffic Capture Start   capture_device=bts     alias=change_pcp_pcap
    ping from vlan interface ip to core
    ${change_pcp_pcap}=       Traffic Capture Stop        alias=change_pcp_pcap
    Analyse pcap            pcap_filename=${change_pcp_pcap}      analysis=change_icmp_dscp_pcp      filter_file_name=${wo_vlan_filter_file}
    [Teardown]     Run Keyword And Ignore Error      Traffic capture stop     alias=change_pcp_pcap

check wireshark for arp dscp2pcp values for arp pcp
    Read vlan Priority
    Traffic Capture Start   capture_device=bts     alias=arp_pcp_pcap
    Perform Recommissioning     type=param      rat=lte     param_path=${ethlk1_moc_locked}  operation=update    value=locked     timeout=300
    sleep   30
    Perform Recommissioning     type=param      rat=lte     param_path=${ethlk1_moc_unlocked}  operation=update    value=unlocked     timeout=300
    sleep   30
    ping from vlan interface ip to core

    ${arp_pcp_pcap}=       Traffic Capture Stop        alias=arp_pcp_pcap
    Analyse pcap            pcap_filename=${arp_pcp_pcap}      analysis=arp_pcp      filter_file_name=${wo_vlan_filter_file}
    [Teardown]     Run Keyword And Ignore Error      Traffic capture stop     alias=arp_pcp_pcap


verify counters for vlanif
    Set reference counter values    1..*
    Pm Counters Start     analysis=vlan_statistics       counter_analysis_file=${counters_json}
    Execute command on GNB   ping -I ${mplaneIP} ${gatewayIP} -c 200
    Sleep   30
    Verify Pm Counters    analysis=vlan_statistics       counter_analysis_file=${counters_json}

verify counters for ethlk
    Set reference counter values    1..*
    Pm Counters Start     analysis=ethernet_link_statistics       counter_analysis_file=${counters_json}
    Execute command on GNB   ping -I ${Plane_mplaneIP} ${Plane_gatewayIP} -c 100
    Verify Pm Counters    analysis=ethernet_link_statistics       counter_analysis_file=${counters_json}


Read mplane and gateway IP
        ${mplaneIP}=     Get Parameter   param_path=${mplane_ipv4_moc}

        Set Suite Variable          ${mplaneIP}
        ${gatewayIP}=     Get Parameter   param_path=${GWIP_moc}
        Set Suite Variable          ${gatewayIP}


Read Plane mplane and gateway IP
        ${Plane_mplaneIP}=     Get Parameter   param_path=${Pmplane_ipv4_moc}

        Set Suite Variable          ${Plane_mplaneIP}
        ${Plane_gatewayIP}=     Get Parameter   param_path=${PGWIP_moc}
        Set Suite Variable          ${Plane_gatewayIP}


Read vlan ID
        ${vlan_ID}=      Get Parameter   param_path=${vlan_interface_moc}-*:vlanId
        Set Suite Variable          ${vlan_ID}

Read vlan Priority
        ${vlan_priority}=      Get Parameter   param_path=${vlan_prio_for_dscp_moc}${vlan_dscp}
        Set Suite Variable          ${vlan_priority}


Set reference counter values
        [Arguments]     ${Class1}
        Set Suite Variable      ${Class1}       ${Class1}
Read vlan from admin
    ${mplane1} =            Get Parameter       rat=common      param_path=${mplane1_ip_moc_path}
    ${mplane1_ipif_dict} =      Query Admin Infomodel       query=get object ${ipif_moc_path} is [localIpAddr=${mplane1}]
    ${mplane1_ipif_moc}=        Get From Dictionary   dictionary=${mplane1_ipif_dict}     key=dist_name
    ${mplane1_ipif}=            Replace String Using Regexp     string=${mplane1_ipif_moc}      pattern=${pattern_to_replace_in_moc}
...     replace_with=${EMPTY}
    @{mplane1_ipif_path}=       Split String From Right     string=${mplane1_ipif}  separator=/
    ${mplane_ipif_id}=  Set Variable    @{mplane1_ipif_path}[-2]
    ${mplane1_vlan_value} =     Get Parameter       rat=common          param_path=${mplane_ipif_id}:interfaceDN:vlanId
    ${mplane1_vlanif_dict} =        Query Admin Infomodel       query=get object ${vlanif_moc_path} is [vlanId=${mplane1_vlan_value}]
    ${mplane1_vlanif_moc}=     Get From Dictionary   dictionary=${mplane1_vlanif_dict}   key=dist_name
    ${mplane1_vlanif}=         Replace String Using Regexp  string=${mplane1_vlanif_moc}    pattern=${pattern_to_replace_in_moc}
...     replace_with=${EMPTY}
    @{mplane1_vlanif_path}=     Split String From Right     string=${mplane1_vlanif}    separator=/
    ${mplane_vlanif_id}=    Set Variable    @{mplane1_vlanif_path}[-1]
    @{vlanId_temp}=     Split String From Right     string=${mplane_vlanif_id}    separator=-
    ${vlan_ID}=      Set Variable     @{vlanId_temp}[-1]
    Set Suite Variable          ${vlan_ID}





















