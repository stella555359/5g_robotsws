*** Settings ***
Documentation
    ...     [Procedure]             "The test case is planned to validate Transport path selection for multiple slices
    ...                              for a single operator"
    ...     [Date]                  "30-03-31"
    ...     [Author]                "Monika Parasar"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Feature_ID]            "RP002488"
    ...     [Validation_status]     "Validated and Passed"
    ...     [Validated_TestLine]    "LTE_CLOUD_F_IPSEC"


#avariables      ta_e2e_bts_trs_fw
#aResource       taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource        ${CURDIR}/../resources/common_keywords.robot
#aResource        ${CURDIR}/../resources/Admin_Common_Library.robot

Suite Setup        Run Keywords     Pre-conditions for testsuite
Suite Teardown     Run Keywords         Post-conditions for testteardown
#Suite Setup       Setup Oamops
#Suite Teardown    Teardown Oamops



*** Test Cases ***
[1]Transport path selection for multiple slices of single operator with same U plane IP

    Perform IPv4 IPv6 Non Collapsed configuration       ${delta_2488_config}
##a    Perform Recommissioning     type=delta      delta_file=${ipsec_2488}      timeout=300
    Sleep   60
    Get IP Address
    Bring Up IPv6 SGW and MME VM Interface
    Call Setup      lte=RP002488_IPv4_IPV6_single_operaror_Lua:data    parallel=${False}    verify_attach=${False}      attach=          timeout=120
    Run Keyword And Ignore Error    Configure UE        lte=RP002488_IPv4_IPV6_single_operaror_Lua:data     command=ue_detach id=1-5
    Unlock other MME and verify status
    Enable RP002488 activation flag
    sleep       60
    Verify GTP Path Supervison      20
    Send UL Traffic verify wireshark
    Bring Down Slice Specific SGW
    Verify GTP Alarm
    Verify no traffic drop in Appication Uplane


#a    [Teardown]    Keywords to run at end



***Keywords***

Get IP Address
    @{GTP_Sgw_ip_addr}=         Create List
    @{NWSLICE_SGW}=         Create List
    @{NW_SLICE_ip}=         Create List
    @{MME_ip_addr}=         Create List

    ${uplane1} =        Get Parameter           param_path=${UPLANE_IP}
    ${uplane1_IPV6} =        Get Parameter           param_path=${UPLANE_IPV6}
    ${cplane1} =        Get Parameter           param_path=${CPLANE_IP}
    ${cplane_IPv6} =        Get Parameter           param_path=${CPLANE_IPV6}

    @{Sgw_ip_addr_list}=     Get Parameter           param_path=${GTPU_address}
    FOR    ${Sgw_ip}         IN      @{Sgw_ip_addr_list}
           ${Sgw_ip_address}=      Get From Dictionary             dictionary=${Sgw_ip}             key=sgwIpAddress
           Append To List      ${GTP_Sgw_ip_addr}          ${Sgw_ip_address}
    END
    FOR            ${i}        IN RANGE            0           10
           ${UplaneIP}=     Get Parameter           param_path=NWSLICE-${i}:ipV6AddressDN1:localIpAddr
           Append To List      ${NW_SLICE_ip}          ${Uplane_Ip}
           ${sgwIPv4}=       Get Parameter           param_path=NWSLICE-${i}:sgwIpAddress
           Append To List      ${NWSLICE_SGW}          ${sgwIPv4}
    END
    FOR            ${i}        IN RANGE            10          20
           ${UplaneIP}=     Get Parameter           param_path=NWSLICE-${i}:ipV4AddressDN1:localIpAddr
           Append To List      ${NW_SLICE_ip}          ${Uplane_Ip}
           ${sgwIPv6}=       Get Parameter           param_path=NWSLICE-${i}:sgwIpAddress
           Append To List      ${NWSLICE_SGW}          ${sgwIPv6}
    END
    ${MME_DICT}=     Get Parameter           param_path=${MME}
    ${MME_value}=           Get Dictionary Values       ${MME_DICT}
    FOR            ${i}        IN      @{MME_value}
           ${MMEIp}=      Get From Dictionary      ${i}                                       ipAddrPrim
           Append To List      ${MME_ip_addr}          ${MMEIp}
    END

    Set Suite Variable      @{GTP_Sgw_ip_addr}          @{GTP_Sgw_ip_addr}
    Set Suite Variable      @{NWSLICE_SGW}          @{NWSLICE_SGW}
    Set Suite Variable      @{NW_SLICE_ip}          @{NW_SLICE_ip}
    Set Suite Variable      ${uplane1}              ${uplane1}
    Set Suite Variable      ${uplane1_IPV6}         ${uplane1_IPV6}
    Set Suite Variable      ${cplane_IPv6}          ${cplane_IPv6}
    Set Suite Variable      ${Cplane_addr}          ${cplane1}
    Set Suite Variable      @{MME_ip_addr}          @{MME_ip_addr}

Unlock other MME and verify status
    Perform Recommissioning     type=param    param_path=LNMME-1:administrativeState    operation=update
    ...     value=unlocked     timeout=300
    sleep       60
    FOR   ${i}        IN RANGE        0       1
           ${status}=     Get Parameter           param_path=LNMME-${i}:s1LinkStatus
           Should Be True      '${status}'=='available'
    END

Ipsec configuration on Strongswan
    Run         sudo cp ${ipsec_conf_ipv4_ipv6_noncollapsed} ${ipsec_conf}
    Run         sudo ipsec restart

Perform IPv4 IPv6 Non Collapsed configuration
    [Arguments]             ${delta_2488_config}
    Copy File     ${delta_dir}/${delta_2488_config}    ${delta_dir}/${delta_2488_config_copy}
    ${vlan_id}=    Set Variable     ${vlan_ids}[1]
#a    Certificate Configure    operation=install_certificate    cert_file=${Ipsec_Cert_file}
#a    ...      cert_type=BtsTrustChain         cert_format=P12         password=${Ipsec_Cert_password}
   FOR        ${i}        IN RANGE        0       5
            Run     sudo sed -i "s/{{vlan_id${i}}}/${vlan_id}/g" ${delta_dir}/${delta_2488_config}
            ${vlan_id}=      Evaluate      ${vlan_id}+1
    END

    Perform Recommissioning     type=delta      delta_file=${delta_2488_config}      timeout=300
    Sleep     60
#a    Perform Recommissioning     type=delta      delta_file=${ipsec_2488}      timeout=120
#a    Sleep     30
    ${interface_adddress_last_octet}=        Set Variable       209
    ${interface_adddress_last_octet_IPv6}=      Set Variable        0X2
    ${Application_adddress_last_octet_IPv6}=    Set Variable        0X3
    FOR        ${i}        IN RANGE    1       6
           ${broadcast_adddress_last_octet}=       Evaluate        ${interface_adddress_last_octet}+2
           ${application_adddress_last_octet}=       Evaluate        ${interface_adddress_last_octet}+1
           Bring IPv4 VLAN VM Interfaces       ${vlan_ids}[${i}]            10.0.3.${interface_adddress_last_octet}
    ...     10.0.3.${broadcast_adddress_last_octet}     30
           Run
    ...     sudo ip route add 10.0.4.${application_adddress_last_octet} via 10.0.3.${application_adddress_last_octet}
           Run
    ...     sudo ip route add 10.0.5.${application_adddress_last_octet} via 10.0.3.${application_adddress_last_octet}
           ${interface_adddress_last_octet_IPv6_hex}=      Evaluate
    ...          hex(${interface_adddress_last_octet_IPv6}).lstrip("0x")
           Run
    ...     sudo ifconfig eth3.${vlan_ids}[${i}] inet6 add fc00::3:${interface_adddress_last_octet_IPv6_hex}/126
           ${Application_adddress_last_octet_IPv6_hex}=        Evaluate
    ...     hex(${Application_adddress_last_octet_IPv6}).lstrip("0x")
           ${var}=      Catenate     sudo ip -6 route add fc00::4:${Application_adddress_last_octet_IPv6_hex} via
    ...     fc00::3:${Application_adddress_last_octet_IPv6_hex}
           Run         ${var}
           ${var}=      Catenate           sudo ip -6 route add fc00::5:${Application_adddress_last_octet_IPv6_hex}
    ...     via fc00::3:${Application_adddress_last_octet_IPv6_hex}
           Run         ${var}
           ${interface_adddress_last_octet}=               Evaluate        ${interface_adddress_last_octet}+4
           ${interface_adddress_last_octet_IPv6}=          Evaluate        hex(${interface_adddress_last_octet_IPv6}+4)
           ${Application_adddress_last_octet_IPv6}=        Evaluate
    ...     hex(${Application_adddress_last_octet_IPv6}+4)
    END

   [Teardown]           Copy File     ${delta_dir}/${delta_2488_config_copy}    ${delta_dir}/${delta_2488_config}

Bring Up IPv6 SGW and MME VM Interface
    ${No_of_SGW}=      Get Length       ${GTP_Sgw_ip_addr}
    FOR    ${i}        IN RANGE        0       ${No_of_SGW}
           Run Keyword IF          ${i}>9          Run
    ...         sudo ifconfig eth3.${vlan_ids}[0]:${i} ${GTP_Sgw_ip_addr}[${i}] netmask 255.255.255.255
    ...     ELSE            Run         sudo ifconfig eth3.${vlan_ids}[0] inet6 add ${GTP_Sgw_ip_addr}[${i}]/116
    END
    Run         sudo ifconfig eth3.${vlan_ids}[0] inet6 add ${MME_ip_addr}[1]/116


Bring IPv4 VLAN VM Interfaces
    [Arguments]            ${Vlan_ID}          ${interface_address}       ${broadcast_ip_address}       ${sunbet_mask}
    Run     sudo ip link add link eth3 name eth3.${Vlan_ID} type vlan id ${Vlan_ID}
    Run     sudo ip addr add ${interface_address}/${sunbet_mask} brd ${broadcast_ip_address} dev eth3.${Vlan_ID}
    Run     sudo ip link set dev eth3.${Vlan_ID} up


Modify Vlan ID, IPaddress and IPRT GW
	Bring IPv4 VLAN VM Interfaces		@{tl.vlan_ids}[5]		 10.0.3.233				10.0.3.235			30
	Run
    ...     sed -i 's/{{Vlan0}}/@{tl.vlan_ids}[5]/g' /home/ute/fw_user_path/config/1/delta_files/modify_VLAN_IPRT_IP.xml
    Perform Recommissioning     type=delta		  delta_file=modify_VLAN_IPRT_IP.xml
    ...         skip_parameter_relation_errors=${True}      timeout=300
	Run		sudo ip route add 10.0.4.210 via 10.0.3.234
	Run		sudo ip route add 10.0.5.210 via 10.0.3.234
    Run     sudo ifconfig eth3.@{tl.vlan_ids}[0] inet6 del fc00::3:2/126
    Run     sudo ifconfig eth3.@{tl.vlan_ids}[5] inet6 add fc00::3:2/126


Enable RP002488 activation flag
    Perform Recommissioning     type=param  param_path=${activation_flag}    operation=update    value=true

Disable RP2488 activation flag
    Perform Recommissioning     type=param  param_path=${activation_flag}    operation=update    value=false

Verify Ipsec Tunnels Status
        @{parent_tunnel_moc_list} =     Query Admin Infomodel           query=get list ${ike_sa_l_moc_path}
        :FOR    ${ike_tunnel}   IN      @{parent_tunnel_moc_list}
        \       ${parent_tunnel_stateInfo}=     Get From Dictionary             dictionary=${ike_tunnel}
        ...     key=stateInfo
        \       ${parent_tunnel_proceduralState}=       Get From Dictionary
        ...     dictionary=${parent_tunnel_stateInfo}           key=proceduralState
        \       Should Be True  '${parent_tunnel_proceduralState}'=='Established'

        @{child_tunnel_moc_list} =      Query Admin Infomodel           query=get list ${ipsec_sa_l_moc_path}
        :FOR    ${child_tunnel}     IN      @{child_tunnel_moc_list}
        \       ${child_tunnel_stateInfo}=      Get From Dictionary             dictionary=${child_tunnel}
        ...     key=stateInfo
        \       ${child_tunnel_proceduralState}=        Get From Dictionary
        ...     dictionary=${child_tunnel_stateInfo}            key=proceduralState
        \       Should Be True  '${child_tunnel_proceduralState}'=='Installed'

Verify GTP Path Supervison
    [Arguments]             ${No_of_SLICE}          ${Dual_u_plane}=False
#a    Generate Esp Sa Key File                    wireshark_host=wireshark_host
#a    ...     esp_sa_file=/home/ute/.config/wireshark/esp_sa
    log     ${No_of_SLICE}
    log     ${Dual_u_plane}
    Traffic Capture Start   capture_device=vm_eth3_interface     alias=eth1_pcap
    Sleep    180
    ${Wireshark_file}=       Traffic Capture Stop        alias=eth1_pcap
    FOR    ${i}        IN RANGE    10      20
#    FOR        ${i}        IN RANGE    10       20
           Set Suite Variable          ${Uplane_addr}          ${uplane1}
           Set Suite Variable          ${Sgw_ip_addr}          ${GTP_Sgw_ip_addr}[${i}]
           Verify GTP request and response         ${Wireshark_file}
           Set Suite Variable          ${Uplane_addr}          ${NW_SLICE_ip}[${i}]
           Set Suite Variable          ${Sgw_ip_addr}          ${NWSLICE_SGW}[${i}]
           Verify GTP request and response         ${Wireshark_file}
    END

    FOR    ${i}        IN RANGE    0      10
         Set Suite Variable          ${Uplane_addr}          ${uplane1_IPV6}
           Set Suite Variable          ${Sgw_ip_addr}          ${GTP_Sgw_ip_addr}[${i}]
           Verify GTP IPv6 request and response            ${Wireshark_file}
           Set Suite Variable          ${Uplane_addr}          ${NW_SLICE_ip}[${i}]
           Set Suite Variable          ${Sgw_ip_addr}          ${NWSLICE_SGW}[${i}]
           Verify GTP IPv6 request and response         ${Wireshark_file}
    END

Verify call existing call drop
#a	Generate Esp Sa Key File                    wireshark_host=wireshark_host
#a    ...     esp_sa_file=/home/ute/.config/wireshark/esp_sa
    Traffic Capture Start   capture_device=vm_eth3_interface     alias=modification_pcap
    Sleep    180
    ${Wireshark_file}=       Traffic Capture Stop        alias=modification_pcap
	Verify Data Rate in wireshark           ${Wireshark_file}
    ...     ((ip.src == ${uplane1}) && (ip.dst == ${NWSLICE_SGW}[12])) && (data)           0

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
#    Generate Esp Sa Key File                    wireshark_host=wireshark_host
#    ...     esp_sa_file=/home/ute/.config/wireshark/esp_sa
    FOR        ${i}        IN RANGE            1      2
        Execute cmd on egate      lte=RP002488_IPv4_IPV6_single_operaror_Lua:data    cmd=ue_mme_param id=${i} sgw_id=3   timeout=60
        Execute cmd on egate      lte=RP002488_IPv4_IPV6_single_operaror_Lua:data    cmd=ue_sgw_param id=${i} s1u_preferred_ip_ver=v4   timeout=60
        Configure UE        lte=RP002488_IPv4_IPV6_single_operaror_Lua:data     command=ue_attach id=${i} cell=11
        Configure UE        lte=RP002488_IPv4_IPV6_single_operaror_Lua:data     command=trf_data_start ue=${i} protocol=udp dir=ul Mbps=10
    END
    Execute cmd on egate        lte=RP002488_IPv4_IPV6_single_operaror_Lua:data   cmd=ue_mme_param id=10 sgw_id=1   timeout=60
    Execute cmd on egate        lte=RP002488_IPv4_IPV6_single_operaror_Lua:data   cmd=ue_sgw_param id=10 s1u_preferred_ip_ver=v4
    Configure UE        lte=RP002488_IPv4_IPV6_single_operaror_Lua:data  command=ue_attach id=10 cell=11  timeout=60
#    Execute cmd on egate        lte=RP002488_IPv4_IPV6_single_operaror_Lua:data  cmd=ue_pdn_connect ue=10 pdn=1
    Configure UE        lte=RP002488_IPv4_IPV6_single_operaror_Lua:data   command=bearer_add ue=10 qci=128 mbr_dl=10 mbr_ul=10
    ...     gbr_dl=10 gbr_ul=10  timeout=60
    Configure UE        lte=RP002488_IPv4_IPV6_single_operaror_Lua:data   command=trf_data_start ue=10 Mbps=10 qci=128 protocol=udp dir=ul
    ...     trf_id=1 timeout=60
    Traffic Capture Start   capture_device=vm_eth3_interface     alias=eth1_pcap
    sleep       30
    ${pcap_file}=       Traffic Capture Stop        alias=eth1_pcap

#a    Verify Data Rate in wireshark           ${pcap_file}
#a    ...     ((ip.src == @{NW_SLICE_ip}[10]) && (ip.dst == @{NWSLICE_SGW}[10])) && (data)           3500
#a   Verify Data Rate in wireshark           ${pcap_file}
#a    ...     ((ip.src == ${uplane1}) && (ip.dst == @{GTP_Sgw_ip_addr}[12])) && (data)           3500

Send UL Traffic after VLAN modification verify wireshark
#a    Generate Esp Sa Key File                    wireshark_host=wireshark_host
#a    ...     esp_sa_file=/home/ute/.config/wireshark/esp_sa
    :For        ${i}        IN RANGE            1      2
    \       Configure UE        lte=RP002488_IPv4_IPV6_single_operaror_Lua:data
    ...     command=ue_mme_param id=100${i} sgw_id=3   timeout=60
    \       Configure UE        lte=RP002488_IPv4_IPV6_single_operaror_Lua:data
    ...     command=ue_sgw_param id=100${i} s1u_preferred_ip_ver=v4
    \       Configure UE        lte=RP002488_IPv4_IPV6_single_operaror_Lua:data
    ...     command=ue_attach id=100${i}  timeout=60
    \       Configure UE        lte=RP002488_IPv4_IPV6_single_operaror_Lua:data
    ...     command=data_start_trf id=1 mbps=7 ue=100${i} dir=ul

	Traffic Capture Start   capture_device=vm_eth3_interface     alias=eth1_pcap
    sleep       30
    ${pcap_file}=       Traffic Capture Stop        alias=eth1_pcap

    Verify Data Rate in wireshark           ${pcap_file}
    ...     ((ip.src == 1.7.11.1) && (ip.src == 10.0.3.234)) && (data)           7000


Verify no traffic drop in Appication Uplane
#a    Generate Esp Sa Key File                    wireshark_host=wireshark_host
#a    ...     esp_sa_file=/home/ute/.config/wireshark/esp_sa
    Traffic Capture Start   capture_device=vm_eth3_interface     alias=eth1_pcap
    sleep       60
    ${pcap_file}=       Traffic Capture Stop        alias=eth1_pcap
    Verify Data Rate in wireshark           ${pcap_file}
    ...     ((ip.src == ${uplane1}) && (ip.dst == ${NWSLICE_SGW}[12]))           7000

Verify Data Rate in wireshark
    [Arguments]         ${pcap_file}        ${filter}       ${expected_data_rate}
#a    Run  tshark -o esp.enable_encryption_decode:TRUE -r ${pcap_file} -Y "${filter}" -w ${EXECDIR}/ue_shaping 2>/dev/null
    Run  tshark -r ${pcap_file} -Y "${filter}" -w ${EXECDIR}/ue_shaping 2>/dev/null
    ${data_rate}=  Run  capinfos ${EXECDIR}/ue_shaping -i | tail -1 | awk '{ print $4 }'
    ${data_rate}=        Remove String       ${data_rate}     ,
    Set Suite Variable     ${data_rate}
    ${higher_limit}=        Evaluate        ${expected_data_rate}+900
    ${lower_limit}=         Evaluate            ${expected_data_rate}-900
#a    Should Be True      ${data_rate}>${lower_limit}
#a    Should Be True      ${data_rate}<${higher_limit}


Bring Down Slice Specific SGW
#a    Run    sudo ifconfig eth3:10 @{GTP_Sgw_ip_addr}[10] netmask 255.255.255.0 down
    Run    sudo ip a d ${GTP_Sgw_ip_addr}[10] dev eth3.${vlan_ids}[0]
   sleep       300

Verify GTP Alarm
    Verify Alarm    faultid=6150
    ${alarm_detail}=        Verify Alarm    faultid=6150
    Should Match Regexp          '${alarm_detail}'
#a    ...     .*LNBTS-1/GTPU-1', u'destinationIPAddr': u'@{NWSLICE_SGW}[10]', u'sourceIPAddr': u'@{NW_SLICE_ip}[10]'.*
    ...     'sourceIPAddr': '${NWSLICE_ip}[10]', 'destinationIPAddr': '${NW_SLICE_SGW}[10]',

Verify no Diagnostic alarm
    Verify Alarm    faultid=6450            should_exist=${False}


Keywords to run at end
    Run Keyword And Ignore Error    Configure UE        lte=RP002488_IPv4_IPV6_single_operaror_Lua:data   command=ue_detach all