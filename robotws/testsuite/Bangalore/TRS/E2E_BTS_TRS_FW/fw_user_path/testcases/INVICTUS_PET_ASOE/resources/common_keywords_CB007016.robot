*** Settings ***
Documentation
...            [Author]         "Vimala"

Variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../../resources/common_keywords.robot
Resource        ${CURDIR}/../../resources/Admin_Common_Library.robot

*** Keywords ***
Verify ipsec status for deletion of x2 MOCS
    Execute command on ENodeB    ipsec statusall | grep 10.0.1.2 | grep 10.0.1.5 |    grep 10.0.4.* | wc -l
    Should contain    ${stdout}    0
    Execute command on ENodeB    ipsec statusall | grep 10.0.1.2 | grep 10.0.1.5 | grep 10.0.4.* | wc -l
    Should contain    ${stdout}    0
#    Execute command on ENodeB    ipsec statusall | grep ${lte_v4_cplane_ip_source} | grep 10.0.4.*| grep -i ike | wc -l
#    Should contain    ${stdout}    0

Verify ipsec status for no deletion of x2 MOCS
#    Execute command on ENodeB    ipsec statusall | grep ${lte_v4_cplane_ip_source} | grep ${lte_v4_uplane_ip_source} | grep 10.0.4.* | wc -l
    Execute command on ENodeB    ipsec statusall | grep 10.0.1.2 | grep 10.0.1.5 | grep 10.0.4.* | wc -l
    Should contain    ${stdout}    394

Verify ipsec status for no deletion of NSA x2 MOCS
#    Execute command on ENodeB    ipsec statusall | grep ${lte_v4_cplane_ip_source} | grep ${lte_v4_uplane_ip_source} | grep 10.0.4.* | wc -l
    Execute command on ENodeB    ipsec statusall | grep 10.0.1.7 | grep 10.0.4.* | wc -l
    Should contain    ${stdout}    244

Verify ipsec status for deletion of NSA x2 MOCS
#    Execute command on ENodeB    ipsec statusall | grep ${lte_v4_cplane_ip_source} | grep ${lte_v4_uplane_ip_source} | grep 10.0.4.* | wc -l
    Execute command on ENodeB    ipsec statusall | grep 10.0.1.7 | grep 10.0.4.* | wc -l
    Should contain    ${stdout}    0

Perform NSA X2
    Call Setup    lte=sim_enb:data    parallel=${False}    verify_attach=${False}    attach=${False}    timeout=1000
    Sleep    5
    ${enb_id}=    Convert To Integer    15
    FOR    ${i}    IN RANGE    15    20
        ${enb_id}=    Evaluate    ${enb_id} + 1
        Configure UE    lte=sim_enb:data    command=enb_conf_transfer id=${enb_id} mme=1 tgt_gnb_id=2
        Configure UE    lte=sim_enb:data    command=enb_x2_link_up enb=${enb_id} target=2 x2_link_addr=10.0.1.7
    END

Perform 5G call
    Call Setup
    ...    lte=sim_enb:data
    ...    parallel=${False}
    ...    verify_attach=${False}
    ...    ipv4_or_6=ipv4
    ...    attach=${False}
    ...    timeout=600
    ...    alias=remote
    Configure UE    5g=sim_enb_eda:data    command=ue_register id=1
    Configure UE    5g=sim_enb_eda:data    command=ue_pdu_session_setup pdu=1 gw=51 ue=1 nwslice=1

Verify Calls
    Block    operation=Cell    rat=LTE
    Sleep    120
    Unblock    operation=Cell    rat=LTE
    Traffic Capture Start
    ...    capture_device=oam_device
    ...    mode=file
    ...    measurement_point=NE_Terminated
    ...    uplane_capturing=True
    ...    timeout=120
    ...    alias=pointA
    Make Call For x2 connection
    ${capture_X2_Conn}=    Traffic Capture Stop
    ...    capture_device=oam_device
    ...    mode=file
    ...    timeout=180
    ...    alias=pointA
    Set Suite Variable    ${capture_X2_Conn}

Verify X2 Link Status on LNADJ
    [Arguments]    ${status}    ${alias}=default
    @{lnadj_moc_list}=    Query Admin Infomodel    query=get list ${lnadj_moc_path}    timeout=60    alias=${alias}
    FOR    ${lnadj_moc}    IN    @{lnadj_moc_list}
        ${x2_target_cplane_ip}=    Get From Dictionary    dictionary=${lnadj_moc}    key=cPlaneIpAddr
        ${x2_link_status}=    Get From Dictionary    dictionary=${lnadj_moc}    key=x2LinkStatus
        Should Be Equal    ${x2_link_status}    ${status}
        Log to console    LTE-LTE X2 Link Is ${status}
    END

Verify X2 Link Status on LTEENB
    [Arguments]    ${status}    ${alias}=default
    @{lnadj_moc_list}=    Query Admin Infomodel    query=get list //LTEENB_R-*    timeout=60    alias=${alias}
    FOR    ${lteenb_moc}    IN    @{lnadj_moc_list}
        ${x2_target_cplane_ip}=    Get From Dictionary    dictionary=${lteenb_moc}    key=localCuIpAddr
        ${x2_link_status}=    Get From Dictionary    dictionary=${lteenb_moc}    key=x2LinkStatus
        Should Be Equal    ${x2_link_status}    ${status}
        Log to console    LTE-ENB X2 Link Is ${status}
    END

Verify nglink status
    [Arguments]    ${status}    ${AMFID}
    ${nglink}=    Query Admin Infomodel    query=get object //SERVEDAMF_R-${AMFID}
    Should Be Equal    ${nglink["ngLinkStatus"]}    ${status}

Verify X2 Link Status on LNADJGNB
    [Arguments]    ${status}    ${alias}=default
    @{lnadj_moc_list}=    Query Admin Infomodel    query=get list ${lnadjgnb_moc_path}    timeout=60    alias=${alias}
    FOR    ${lnadjgnb_moc}    IN    @{lnadj_moc_list}
        ${x2_target_cplane_ip}=    Get From Dictionary    dictionary=${lnadjgnb_moc}    key=cPlaneIpAddr
        ${x2_link_status}=    Get From Dictionary    dictionary=${lnadjgnb_moc}    key=x2ToGnbLinkStatus
        Should Be Equal    ${x2_link_status}    available
        Log to console    LTE-GNB X2 Link Is ${status}
    END

Trigger ANR for LTE-LTE
#    [Arguments]    ${alias_suffix}

    Block    operation=Cell    rat=LTE
    Sleep    120
    Unblock    operation=Cell    rat=LTE
    Traffic Capture Start
    ...    capture_device=oam_device
    ...    mode=file
    ...    measurement_point=Transport_Interface
    ...    uplane_capturing=True
    ...    timeout=120
    ...    alias=pointA
    Make Call For x2 connection
    ${capture_X2_Conn}=    Traffic Capture Stop
    ...    capture_device=oam_device
    ...    mode=file
    ...    timeout=180
    ...    alias=pointA
    Set Suite Variable    ${capture_X2_Conn}

Make Call For x2 connection
    Call Setup
    ...    lte=device1_for_x2_conn:data
    ...    parallel=${False}
    ...    attach=${False}
    ...    verify_attach=${false}
    ...    timeout=600
    Sleep    20
    Block    operation=Cell    rat=LTE
    Sleep    60
    Unblock    operation=Cell    rat=LTE
    Sleep    10
    Configure UE
    ...    lte=device1_for_x2_conn:data
    ...    command=ue_rrc_reconf_param id=1 if_contains=purpose with_value=reportStrongestCells action=measurement_send phycell_id=13 nrsrp=97
    ...    nrsrq=34 earfcn=38000 strongest=eutra son=true ecgi=234:77|0x204 tac=124
    Sleep    10
    Configure UE
    ...    lte=device1_for_x2_conn:data
    ...    command=ue_attach id=1 cell=11 ue_eutra_capabilities=DE20009E0008206102860E2048A163069022489942A58B983268D9D3CA56BF3C7
    ...    800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E0000
    ...    00007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001
    ...    E000000007800000001E0000000078000000037F7FFD9001003838AD78000000080B8401D0100200082100042080021840011020008A10004608002384001202
    ...    0009210004A080025840013020009A10005008002884001482000A610005408002A84001582000AE10005808002C84001682000B610005D08002F04001B42000
    ...    FE100E9E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000
    ...    007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E0
    ...    00000007800000001E000000007800000000F3A00000000000000000000000000000000000000000000000000000000000202288425340C3D555555555555555
    ...    74141500230C1080A58088080000002096340211807135E0000018800000094408200002100
    Sleep    10
    Configure UE
    ...    lte=device1_for_x2_conn:data
    ...    command=ue_measurement_send id=1 event=A3 srsrp=60 srsrq=15 phycell_id=13 nrsrp=90 nrsrq=34
    Sleep    250

Read parameter values
    ${lte_v4_cplane_ip}=    Get Parameter    param_path=${lte_cplane_v4_moc_path}
    Set Suite Variable    ${lte_v4_cplane_ip_source}    ${lte_v4_cplane_ip}
#    ${lte_v4_cplane_ip}=    Get Parameter    param_path=${lte_cplane_v4_moc_path}    alias=remote
#    Set Suite Variable    ${lte_v4_cplane_ip_target}    ${lte_v4_cplane_ip}
#    ${lte_v6_cplane_ip}=    Get Parameter    param_path=${lte_cplane_v6_moc_path}
#    Set Suite Variable    ${lte_v6_cplane_ip}
    ${lte_v4_uplane_ip}=    Get Parameter    param_path=${lte_uplane_v4_moc_path}
    Set Suite Variable    ${lte_v4_uplane_ip_source}    ${lte_v4_uplane_ip}
#    ${lte_v6_uplane_ip}=    Get Parameter    param_path=${lte_uplane_v6_moc_path}
#    Set Suite Variable    ${lte_v6_uplane_ip}
#    ${lte_v4_cplane_ip_neigh}=    Get Parameter    param_path=${lte_cplane_v4_moc_path}    alias=remote
#    Set Suite Variable    ${lte_v4_cplane_ip_neigh}
#    ${lte_v6_cplane_ip_neigh}=    Get Parameter    param_path=${lte_cplane_v6_moc_path}    alias=remote
#    Set Suite Variable    ${lte_v6_cplane_ip_neigh}
#    ${lte_v4_uplane_ip_neigh}=    Get Parameter    param_path=${lte_uplane_v4_moc_path}    alias=remote
#    Set Suite Variable    ${lte_v4_uplane_ip_neigh}
#    ${lte_v6_uplane_ip_neigh}=    Get Parameter    param_path=${lte_uplane_v6_moc_path}    alias=remote
#    Set Suite Variable    ${lte_v6_uplane_ip_neigh}
#    ${x2_v4_cplane_ip}=    Get Parameter    param_path=${x2_cplane_v4_moc_path}    alias=remote
#    Set Suite Variable    ${x2_v4_cplane_ip_target}    ${x2_v4_cplane_ip}
#    ${x2_v6_cplane_ip}=    Get Parameter    param_path=${x2_cplane_v6_moc_path}    alias=remote
#    Set Suite Variable    ${x2_v6_cplane_ip}
#    ${x2_v4_uplane_ip}=    Get Parameter    param_path=${x2_uplane_v4_moc_path}    alias=remote
#    Set Suite Variable    ${x2_v4_uplane_ip}
#    ${x2_v6_uplane_ip}=    Get Parameter    param_path=${x2_uplane_v6_moc_path}    alias=remote
#    Set Suite Variable    ${x2_v6_uplane_ip}
    ${lnmme_v4}=    Get Parameter    param_path=${lnmme_v4_moc_path}
    Set Suite Variable    ${lnmme_v4}
#    ${lnmme_v6}=    Get Parameter    param_path=${lnmme_v6_moc_path}
#    Set Suite Variable    ${lnmme_v6}

Get Ipsec Tunnels Status
    [Arguments]    ${alias}=default
    @{parent_tunnel_moc_list}=    Query Admin Infomodel    query=get list ${ike_sa_l_moc_path}    alias=${alias}
    :FOR    ${ike_tunnel}    IN    @{parent_tunnel_moc_list}
    \    ${parent_tunnel_stateInfo}= Get From Dictionary    dictionary=${ike_tunnel}    key=stateInfo
    \
    ...    ${parent_tunnel_proceduralState}=
    ...    Get From Dictionary
    ...    dictionary=${parent_tunnel_stateInfo}
    ...    key=proceduralState
    \    Should Be True    '${parent_tunnel_proceduralState}'=='Established'

    @{child_tunnel_moc_list}=    Query Admin Infomodel    query=get list ${ipsec_sa_l_moc_path}
    :FOR    ${child_tunnel} IN    @{child_tunnel_moc_list}
    \    ${child_tunnel_stateInfo}=    Get From Dictionary    dictionary=${child_tunnel}    key=stateInfo
    \
    ...    ${child_tunnel_proceduralState}=
    ...    Get From Dictionary
    ...    dictionary=${child_tunnel_stateInfo}
    ...    key=proceduralState
    \    Should Be True    '${child_tunnel_proceduralState}'=='Installed'

Verify PRF methods and analyse pcap
    FOR    ${VAL}    IN    @{ikeAuthMethods}
        IF    '${VAL}'=='AUTH_HMAC_SHA1_96'
            ${prf}=    Set variable    2
        ELSE IF    '${VAL}'=='AUTH_HMAC_SHA2_256_128'
            ${prf}=    Set variable    5
        ELSE IF    '${VAL}'=='AUTH_HMAC_SHA2_384_192'
            ${prf}=    Set variable    6
        ELSE IF    '${VAL}'=='AUTH_HMAC_SHA2_512_256'
            ${prf}=    Set variable    7
        ELSE IF    '${VAL}'=='AUTH_AES_XCBC_MAC_96'
            ${prf}=    Set variable    4
        ELSE IF    '${VAL}'=='AUTH_AES_GCM_ICV16_128'
            ${prf}=    Set variable    5
        ELSE IF    '${VAL}'=='AUTH_AES_GCM_ICV16_256'
            ${prf}=    Set variable    5
        ELSE
            ${prf}=    Set Variable    ${None}
        END
        Traffic Capture Start    capture_device=bts
        Perform Recommissioning    type=param    param_path=${ike_auth_source}    operation=update    value=${VAL}
        Perform Recommissioning
        ...    type=param
        ...    param_path=${ike_auth_target}
        ...    operation=update
        ...    value=${VAL}
        ...    alias=remote
        IF    '${VAL}'=='AUTH_AES_GCM_ICV16_128'
            Perform Recommissioning
            ...    type=param
            ...    param_path=${ike_encryption}
            ...    operation=update
            ...    value=ENC_AES_GCM_ICV16_128
        ELSE IF    '${VAL}'=='AUTH_AES_GCM_ICV16_256'
            Perform Recommissioning
            ...    type=param
            ...    param_path=${ike_encryption}
            ...    operation=update
            ...    value=ENC_AES_GCM_ICV16_256
        ELSE IF    '${VAL}'=='AUTH_HMAC_SHA1_96'
            Perform Recommissioning
            ...    type=param
            ...    param_path=${ike_encryption}
            ...    operation=update
            ...    value=ENC_AES_128_CBC
        END
        IF    '${VAL}'=='AUTH_AES_GCM_ICV16_128'
            Perform Recommissioning
            ...    type=param
            ...    param_path=${ike_encryption_remote}
            ...    operation=update
            ...    value=ENC_AES_GCM_ICV16_128
            ...    alias=remote
        ELSE IF    '${VAL}'=='AUTH_AES_GCM_ICV16_256'
            Perform Recommissioning
            ...    type=param
            ...    param_path=${ike_encryption_remote}
            ...    operation=update
            ...    value=ENC_AES_GCM_ICV16_256
            ...    alias=remote
        ELSE IF    '${VAL}'=='AUTH_HMAC_SHA1_96'
            Perform Recommissioning
            ...    type=param
            ...    param_path=${ike_encryption}
            ...    operation=update
            ...    value=ENC_AES_128_CBC
            ...    alias=remote
        END
        ${pcap_file_mode_IKEP}=    Traffic Capture Stop
        Analyse Pcap
        ...    pcap_filename=${pcap_file_mode_IKEP}
        ...    analysis=verify_prf_method
        ...    filter_file_name=${traffic_filter_file_name}
    END

Verify user label value
    ${Secpol_dict}=    Query Admin Infomodel
    ...    query=get object ${secpol_a_moc_path} is [trafficSelectorList[?].remoteIpAddress=${lte_v4_cplane_ip_target}]
    ${user_label}=    Get From Dictionary    dictionary=${Secpol_dict}    key=userLabel
    Should Be True    ${user_label}==2
    ${Secpol_dict}=    Query Admin Infomodel
    ...    query=get object ${secpol_a_moc_path} is [trafficSelectorList[?].remoteIpAddress=${x2_v4_cplane_ip_target}]
    ${user_label}=    Get From Dictionary    dictionary=${Secpol_dict}    key=userLabel
    Should Be True    ${user_label}==2
#    ${Secpol_dict} =    Query Admin Infomodel    query=get object ${secpol_a_moc_path} is [trafficSelectorList[?].remoteIpAddress=$
    ...    {x2_v4_cplane_ip_source}]    remote
#    ${user_label}=    Get From Dictionary    dictionary=${Secpol_dict}    key=userLabel
#    Should Be True    ${user_label}==1
#    ${Secpol_dict} =    Query Admin Infomodel    query=get object ${secpol_a_moc_path} is [trafficSelectorList[?].remoteIpAddress=$
    ...    {x2_v4_cplane_ip_source}]    remote
#    ${user_label}=    Get From Dictionary    dictionary=${Secpol_dict}    key=userLabel
#    Should Be True    ${user_label}==1

Verify IPSEC MOC does not exist on target GNB
    ${Secpol_dict}=    Query Admin Infomodel
    ...    query=get object ${secpol_a_moc_path} is [trafficSelectorList[?].remoteIpAddress=${lte_v4_cplane_ip_target}]
    ...    alias=remote
    Should Be True    ${Secpol_dict}==None

Get the USER label value
    ${Secpol_dict}=    Query Admin Infomodel
    ...    query=get object ${secpol_a_moc_path} is [trafficSelectorList[?].remoteIpAddress=${target_lte_cplane_ip}]
    ${ikep_moc}=    Get From Dictionary    dictionary=${Secpol_dict}    key=ikePDN
    @{ikep_path}=    Split String From Right    string=${ikep_a_moc_path}    separator=/
    ${ikep_value}=    Set Variable    @{ikep_path}[-1]
    Set Suite Variable    ${ikep_value}    ${ikep_value}
    ${ikep}=    Replace String Using Regexp
    ...    string=${ikep_value}
    ...    pattern=${pattern_to_replace_in_moc}
    ...    replace_with=${EMPTY}
    Set Suite Variable    ${ikep}    ${ikep}