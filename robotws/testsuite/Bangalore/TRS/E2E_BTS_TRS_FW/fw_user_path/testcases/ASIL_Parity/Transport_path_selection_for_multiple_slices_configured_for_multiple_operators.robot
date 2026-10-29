***Settings ***
Documentation
    ...     [Procedure]             "The test case is planned to validate Transport path selection for multiple slices
    ...                             for a multiple operator"
    ...     [Date]                  "30-03-31"
    ...     [Author]                "Monika Parasar"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Feature_ID]            "RP002488"
    ...     [Validation_status]     "Validated and Passed"
    ...     [Validated_TestLine]    "CLOUD_R4P_IPSEC"


Force Tags     CLOUD_R4P_IPSEC    CA_E2ET_BTSTRSPZ        SBTS00        [SBTS23R1]     RAN_4G    RAN_4G_FDD
...     QCD_MN_RAN        QCP_RAN_VRF        CRT


Resource        ${CURDIR}/../resources/common_keywords.robot
#aResource        ${CURDIR}/../resources/Admin_Common_Library.robot
#aVariables       config

Suite Setup     Pre-conditions for testsuite
Suite Teardown      Post-conditions for testteardown
#Suite Setup       Setup Oamops
#Suite Teardown    Teardown Oamops


*** Test Cases ***
[1][1.0] Transport path selection for multiple slices configured for multiple operators.
    Perform Commissioning       scf_file=${base_scf_multi_op}   verify_bts_status=true     timeout=400     alias=default
    Sleep    300
    Perform multiple operator configuration
    Get IP Address
    Bring Up SGW and MME VM Interface
    Call Setup  lte=RP002488_IPV4_IPV6_multi_operator_Lua:data   parallel=${False}    verify_attach=${False}
    ...    attach=${False}     timeout=120
    Run Keyword And Ignore Error    Configure UE        lte=RP002488_IPV4_IPV6_multi_operator_Lua:data
    ...      command=ue_detach all
    Unlock other MME and verify status
    Enable RP002488 activation flag
    Sleep   60
    Verify GTP Path Supervison
    Send UL Traffic verify wireshark            2


***Keywords***

Get IP Address
    @{GTP_Sgw_ip_addr}=         Create List
    @{NWSLICE_SGW}=         	Create List
    @{NW_SLICE_ip}=         	Create List
    @{MME_ip_addr}=         	Create List
    @{uplane}=             Create List
    @{cplane}=             Create List

    ${Ipv4_uplane1} =        Get Parameter          param_path=${UPLANE_IP}
    ${Uplane_IP_value}=           Get Dictionary Values              ${Ipv4_uplane1}
    FOR            ${i}        IN      @{Uplane_IP_value}
            ${Uplane_Ip_addr}=      Get Dictionary Values       ${i['uPlane']['ipV4AddressDN1']}
            Append To List     ${uplane}         ${Uplane_Ip_addr}[0]
    END

    ${Ipv6_uplane1} =        Get Parameter          param_path=${UPLANE_IPV6}
    ${Uplane_IP_value}=           Get Dictionary Values              ${Ipv6_uplane1}
    FOR            ${i}        IN      @{Uplane_IP_value}
            ${Uplane_Ip_addr}=      Get Dictionary Values       ${i['uPlane']['ipV6AddressDN1']}
            Append To List     ${uplane}         ${Uplane_Ip_addr}[0]
    END

    ${Ipv4_cplane1} =        Get Parameter          param_path=${CPLANE_IP}
    ${Cplane_IP_value}=           Get Dictionary Values              ${Ipv4_cplane1}
    FOR            ${i}        IN      @{Cplane_IP_value}
            ${Cplane_Ip_addr}=      Get Dictionary Values       ${i['cPlane']['ipV4AddressDN1']}
            Append To List     ${cplane}         ${Cplane_Ip_addr}[0]
    END

    ${Ipv6_cplane1} =        Get Parameter          param_path=${CPLANE_IPV6}
    ${Cplane_IP_value}=           Get Dictionary Values              ${Ipv6_cplane1}
    FOR            ${i}        IN      @{Cplane_IP_value}
            ${Cplane_Ip_addr}=      Get Dictionary Values       ${i['cPlane']['ipV6AddressDN1']}
            Append To List     ${cplane}         ${Cplane_Ip_addr}[0]
    END

    ${Sgw_ip_addr_list}=     Get Parameter           param_path=${GTPU_address}
    FOR    ${Sgw_ip}         IN      @{Sgw_ip_addr_list}
           ${Sgw_ip_address}=      Get From Dictionary             dictionary=${Sgw_ip}             key=sgwIpAddress
           Append To List      ${GTP_Sgw_ip_addr}          ${Sgw_ip_address}
    END
    FOR            ${i}        IN RANGE            0          6
           ${UplaneIP}=     Get Parameter           param_path=NWSLICE-${i}:ipV4AddressDN1:localIpAddr
           Append To List      ${NW_SLICE_ip}          ${Uplane_Ip}
           ${sgwIP}=       Get Parameter           param_path=NWSLICE-${i}:sgwIpAddress
           Append To List      ${NWSLICE_SGW}          ${sgwIp}
    END
    FOR            ${i}        IN RANGE            6          12
           ${UplaneIP}=     Get Parameter           param_path=NWSLICE-${i}:ipV6AddressDN1:localIpAddr
           Append To List      ${NW_SLICE_ip}          ${Uplane_Ip}
           ${sgwIP}=       Get Parameter           param_path=NWSLICE-${i}:sgwIpAddress
           Append To List      ${NWSLICE_SGW}          ${sgwIp}
    END

    ${MME_DICT}=     Get Parameter           param_path=${MME}
    ${MME_value}=           Get Dictionary Values       ${MME_DICT}
    FOR            ${i}        IN      @{MME_value}
           ${MMEIp}=      Get From Dictionary      ${i}                                       ipAddrPrim
           Append To List      ${MME_ip_addr}          ${MMEIp}
    END

    Set Suite Variable      @{GTP_Sgw_ip_addr}          @{GTP_Sgw_ip_addr}
    Set Suite Variable      @{NWSLICE_SGW}              @{NWSLICE_SGW}
    Set Suite Variable      @{NW_SLICE_ip}              @{NW_SLICE_ip}
    Set Suite Variable      @{uplane}                   @{uplane}
    Set Suite Variable      @{cplane}              @{cplane}
    Set Suite Variable      @{MME_ip_addr}          @{MME_ip_addr}

Unlock other MME and verify status
	FOR		${i}			IN RANGE	1		12
    		Perform Recommissioning     type=param    param_path=LNMME-${i}:administrativeState    operation=update
    ...     value=unlocked     timeout=300
    END
    sleep       60
    FOR   ${i}        IN RANGE        0       12
           ${status}=     Get Parameter           param_path=LNMME-${i}:s1LinkStatus
           Should Be True      '${status}'=='available'
    END


Ipsec configuration on Strongswan
    Run         sudo cp ${ipsec_conf_ipv4_ipv6_noncollapsed} ${ipsec_conf}
    Run         sudo ipsec restart


Perform multiple operator configuration
    Copy File     ${delta_dir}/${Multi_IPIF_IPRT}    ${delta_dir}/${Multi_IPIF_IPRT_copy}
    ${vlan_id}=    Set Variable     ${vlan_ids}[1]
    FOR        ${i}        IN RANGE        0       6
           Run     sudo sed -i "s/{{vlan_id${i}}}/${vlan_id}/g" ${delta_dir}/${Multi_IPIF_IPRT}
           ${vlan_id}=      Evaluate      ${vlan_id}+1
    END
    ${interface_adddress_last_octet}=        Set Variable       209
    ${interface_adddress_last_octet_IPv6}=      Set Variable        0X2
    ${Application_adddress_last_octet_IPv6}=    Set Variable        0X3

    FOR        ${i}        IN RANGE    1       7
           ${broadcast_adddress_last_octet}=       Evaluate        ${interface_adddress_last_octet}+2
           ${application_adddress_last_octet}=       Evaluate        ${interface_adddress_last_octet}+1
           Bring IPv4 VLAN VM Interfaces       ${vlan_ids}[${i}]            10.0.3.${interface_adddress_last_octet}     30
    ...     sudo ip route add 10.0.4.${application_adddress_last_octet} via 10.0.3.${application_adddress_last_octet}
           Run
    ...     sudo ip route add 10.0.5.${application_adddress_last_octet} via 10.0.3.${application_adddress_last_octet}
           ${interface_adddress_last_octet_IPv6_hex}=      Evaluate
    ...     hex(${interface_adddress_last_octet_IPv6}).lstrip("0x")
           ${var}=      Catenate        sudo ifconfig eth3.${vlan_ids}[${i}] inet6 add
    ...     fc00::3:${interface_adddress_last_octet_IPv6_hex}/126
           Run	        ${var}
           ${Application_adddress_last_octet_IPv6_hex}=        Evaluate
    ...     hex(${Application_adddress_last_octet_IPv6}).lstrip("0x")
           ${var}=      Catenate       sudo ip -6 route add fc00::4:${Application_adddress_last_octet_IPv6_hex}
    ...     via fc00::3:${Application_adddress_last_octet_IPv6_hex}
           Run         ${var}
           ${var}=      Catenate       sudo ip -6 route add fc00::5:${Application_adddress_last_octet_IPv6_hex}
    ...     via fc00::3:${Application_adddress_last_octet_IPv6_hex}
           Run       ${var}
           ${interface_adddress_last_octet}=               Evaluate        ${interface_adddress_last_octet}+4
           ${interface_adddress_last_octet_IPv6}=          Evaluate        hex(${interface_adddress_last_octet_IPv6}+4)
           ${Application_adddress_last_octet_IPv6}=        Evaluate
    ...     hex(${Application_adddress_last_octet_IPv6}+4)
    END

    [Teardown]           Copy File     ${delta_dir}/${Multi_IPIF_IPRT_copy}    ${delta_dir}/${Multi_IPIF_IPRT}

Bring Up SGW and MME VM Interface
    ${No_of_SGW}=      Get Length       ${GTP_Sgw_ip_addr}
    FOR    ${i}        IN RANGE        0       ${No_of_SGW}
           Run Keyword IF          ${i}<6          Run
    ...        sudo ifconfig eth3.${vlan_ids}[0]:${i} ${GTP_Sgw_ip_addr}[${i}] netmask 255.255.255.0
    ...        ELSE              Run         sudo ifconfig eth3.${vlan_ids}[0] inet6 add ${GTP_Sgw_ip_addr}[${i}]/116
    END

    ${No_of_MME}=      Get Length       ${MME_ip_addr}
    FOR    ${i}        IN RANGE        0       ${No_of_MME}        2
            Run     sudo ifconfig eth3.${vlan_ids}[0]:1${i} ${MME_ip_addr}[${i}] netmask 255.255.255.0
           ${i}=       Evaluate        ${i}+1
            Run         sudo ifconfig eth3.${vlan_ids}[0] inet6 add ${MME_ip_addr}[${i}]/116
    END
    Run         sudo ifconfig eth3.${vlan_ids}[0] inet6 add fc00::1/116


Bring IPv4 VLAN VM Interfaces
    [Arguments]             ${Vlan_ID}         ${interface_address}       ${broadcast_ip_address}       ${sunbet_mask}
    Run     sudo ip link add link eth3 name eth3.${Vlan_ID} type vlan id ${Vlan_ID}
    Run     sudo ip addr add ${interface_address}/${sunbet_mask} brd ${broadcast_ip_address} dev eth3.${Vlan_ID}
    Run     sudo ip link set dev eth3.${Vlan_ID} up


Enable RP002488 activation flag
    Perform Recommissioning     type=param  param_path=${activation_flag}    operation=update    value=true

Disable RP2488 activation flag
    Perform Recommissioning     type=param  param_path=${activation_flag}    operation=update    value=false

Verify GTP Path Supervison
    ${mac_address}=    Run     sudo ifconfig eth1| grep ether | awk -F ' ' '{print $2}'
    Traffic Capture Start   capture_device=vm_eth3_interface     alias=eth1_pcap
    Sleep    120
    ${Wireshark_file}=       Traffic Capture Stop        alias=eth1_pcap
    FOR    ${i}        IN RANGE    0      6
           Set Suite Variable          ${Uplane_addr}          ${uplane}[${i}]
           Set Suite Variable          ${Sgw_ip_addr}          ${GTP_Sgw_ip_addr}[${i}]
           Verify GTP request and response         ${Wireshark_file}
           Set Suite Variable          ${Uplane_addr}          ${NW_SLICE_ip}[${i}]
           Set Suite Variable          ${Sgw_ip_addr}          ${NWSLICE_SGW}[${i}]
           Verify GTP request and response         ${Wireshark_file}
    END

    FOR    ${i}        IN RANGE    6      12
           Set Suite Variable          ${Uplane_addr}          ${uplane}[${i}]
           Set Suite Variable          ${Sgw_ip_addr}          ${GTP_Sgw_ip_addr}[${i}]
           Verify GTP IPv6 request and response            ${Wireshark_file}
           Set Suite Variable          ${Uplane_addr}          ${NW_SLICE_ip}[${i}]
           Set Suite Variable          ${Sgw_ip_addr}          ${NWSLICE_SGW}[${i}]
           Verify GTP IPv6 request and response         ${Wireshark_file}
    END

Verify GTP request and response
    [Arguments]         ${Wireshark_file}
    Analyse Pcap        pcap_filename=${Wireshark_file}            analysis=GTP_Echo_request
    ...     filter_file_name=${pcap_file}
    Analyse Pcap        pcap_filename=${Wireshark_file}            analysis=GTP_Echo_response
    ...     filter_file_name=${pcap_file}

Verify GTP IPv6 request and response
    [Arguments]         ${Wireshark_file}
    Analyse Pcap        pcap_filename=${Wireshark_file}            analysis=GTP_Echo_request_IPv6
    ...     filter_file_name=${pcap_file}
    Analyse Pcap        pcap_filename=${Wireshark_file}            analysis=GTP_Echo_response_IPv6
    ...     filter_file_name=${pcap_file}


Send UL Traffic verify wireshark
    [Arguments]             ${No_of_calls}
    Traffic Capture Start   capture_device=vm_eth3_interface     alias=eth3_pcap
    FOR    ${i}        IN RANGE    0   ${No_of_calls}
           ${ID}=      Evaluate        ${i}+1
           ${QCI}=     Evaluate        ${i}+128
           ${bearer_ID}=       Evaluate        ${i}+10
           Sleep    60
           Execute cmd on egate      lte=RP002488_IPV4_IPV6_multi_operator_Lua:data    cmd=ue_mme_param id=${ID} sgw_id=${ID}   timeout=60
           sleep       10
		   Execute cmd on egate      lte=RP002488_IPV4_IPV6_multi_operator_Lua:data    cmd=ue_sgw_param id=${ID} s1u_preferred_ip_ver=v4
           sleep       10
           Configure UE        lte=RP002488_IPV4_IPV6_multi_operator_Lua:data       command=ue_attach id=${ID} cell=11
           sleep       20
           Configure UE        lte=RP002488_IPV4_IPV6_multi_operator_Lua:data
           ...     command=bearer_add ue=${ID} qci=${QCI} mbr_dl=10 mbr_ul=10 gbr_dl=10 gbr_ul=10
           sleep       20
           Configure UE        lte=RP002488_IPV4_IPV6_multi_operator_Lua:data
           ...     command=trf_data_start ue=${ID} qci=${QCI} Mbps=10 dir=ul protocol=udp      timeout=60
           sleep       60
    END
    ${pcap_file}=       Traffic Capture Stop        alias=eth3_pcap
    FOR    ${i}        IN RANGE    0   ${No_of_calls}
           Verify Data Rate in wireshark           ${pcap_file}
    ...     ((ip.src == ${NW_SLICE_ip}[${i}]) && (ip.dst == ${NWSLICE_SGW}[${i}]))          7000
    END

Verify Data Rate in wireshark
    [Arguments]         ${pcap_file}        ${filter}       ${expected_data_rate}
    Run  tshark -r ${pcap_file} -Y "${filter}" -w ${EXECDIR}/ue_shaping 2>/dev/null
    ${data_rate}=  Run  capinfos ${EXECDIR}/ue_shaping -i | tail -1 | awk '{ print $4 }'
    ${data_rate}=        Remove String       ${data_rate}     ,
    Set Suite Variable     ${data_rate}
    ${higher_limit}=        Evaluate        ${expected_data_rate}+900
    ${lower_limit}=         Evaluate            ${expected_data_rate}-900

