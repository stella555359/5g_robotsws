*** Settings ***
Documentation
...     [Documentation]
...     [Author]                "Pavithra C"
...     [Function_Hash_Tags]            "CB009408"
variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot
Suite Setup    Setup Oamops
Suite Teardown     Teardown Oamops


***Test Cases***
[1]TRS_CB009408-A-B2_Verification_of_B2split_In_Multiple_Scnearios_ASIM
#Split B2 verification
       Perform Commissioning    scf_file=${CB009408_config}    verify_bts_status=False    timeout=400    alias=default
       Perform Recommissioning   type=delta    delta_file=${JIRA_RDI_33381}    verify_bts_status=False     timeout=300     alias=default
       Sleep    300
       ${mplane1_ipv6}=     Get Parameter    rat=5g    param_path=${mplane1_ipv6_moc_path}
       Set Suite Variable   ${mplane1_ipv6}    ${mplane1_ipv6}
       Verify IP connectivity
       Perform Recommissioning   type=param    param_path=LNBTS-${bts_id}:actEndcAutoX2Setup     operation=update      value=true      timeout=300
       Perform Recommissioning   type=param    param_path=LNBTS-${bts_id}:actEndcAutoX2SetupSbts     operation=update    value=true    timeout=300
       ${5g_x2cplane1_ipv4}=     Get Parameter    rat=5g    param_path=${5g_nsa_x2clane1_ipv4_moc_path}
       Set Suite Variable   ${5g_x2cplane1_ipv4}    ${5g_x2cplane1_ipv4}
       Verify X2 link status    available
       Reset Bts    req_rat=lte    wait_for=400
       Sleep   120
       Verify Bts Status     req_rat=lte
       Sleep    180
       Verify X2 link status    available
       Perform Recommissioning   type=delta    delta_file=${DELETE_LNADJ_INT}    verify_bts_status=False     timeout=300     alias=default
       Run Keyword and expect error    *Matching objects not found*    Query Admin Infomodel     query=get list //LNADJGNB_A-31   timeout=30
       ...  alias=default
###Split B1 Verification
       Perform Recommissioning   type=param    param_path=LNBTS-${bts_id}:actEndcAutoX2SetupSbts     operation=update    value=false   timeout=300
       Verify gNB ID conflict scenario for oamcontrolled
       Verify gNB ID conflict scneario for enbcontrolled
       Verify IP conflict scenario
       Update PLMN and verify if its reflected in LNADJGNB
       Update cplane ip address and check if its reflected and x2link is coming up
       Add LNAJD with x2cplane ip and verify for alarm
##Split B3 Verification
       Perform Recommissioning   type=param    param_path=LNBTS-${bts_id}:actEndcAutoX2Setup     operation=update      value=false    timeout=300
       Perform Recommissioning   type=param    param_path=LNBTS-${bts_id}:actEndcAutoX2SetupSbts     operation=update    value=false  timeout=300
       Perform Recommissioning   type=param    param_path=LNBTS-${bts_id}:actEndcAutoX2Setup     operation=update      value=true     timeout=300
       Perform Recommissioning   type=param    param_path=LNBTS-${bts_id}:actEndcAutoX2SetupSbts     operation=update    value=true   timeout=300
       Perform Recommissioning   type=delta    delta_file=${Create_LNRELGNBCELL}    verify_bts_status=False    timeout=300     alias=default
       Verify X2 link status    available
       Perform Recommissioning   type=delta    delta_file=${Delete_LNRELGNBCELL}    verify_bts_status=False    timeout=300     alias=default
       Verify X2 link status    available
       Perform Recommissioning   type=param    param_path=LNBTS-${bts_id}:actEndcAutoX2SetupSbts     operation=update    value=false  timeout=300
       Perform Recommissioning   type=delta    delta_file=${Create_LNRELGNBCELL}    verify_bts_status=False    timeout=300     alias=default
       Verify X2 link status    available
       Perform Recommissioning   type=delta    delta_file=${Delete_LNRELGNBCELL}    verify_bts_status=False    timeout=300     alias=default
       Run Keyword and expect error        *Matching objects not found*    Query Admin Infomodel       query=get list //LNADJGNB_A-31   timeout=30
       ...   alias=default
####jira
       Perform Recommissioning   type=delta    delta_file=${JIRA_RDI_33381}    verify_bts_status=False     timeout=300     alias=default
       Sleep    300
       ${mplane1_ipv6}=     Get Parameter    rat=nr    param_path=${mplane1_ipv6_moc_path}
       Set Suite Variable   ${mplane1_ipv6}    ${mplane1_ipv6}
       Verify IP connectivity

***Keywords***
Verify X2 link status
       [Arguments]      ${status}
       ${x2linkstatus}=   Get Parameter    param_path=MRBTS-${bts_id}/LNBTS-{bts_id}/LNADJGNB-31:x2ToGnbLinkStatus     alias=default
       Should Be Equal    ${x2linkstatus}    ${status}

Verify gNB ID conflict scenario for oamcontrolled
       Perform Recommissioning   type=delta    delta_file=${GNB_ID_CONFLICT_OAM}    verify_bts_status=False     timeout=300     alias=default
       Perform Recommissioning   type=param    param_path=LNBTS-${bts_id}:actEndcAutoX2SetupSbts     operation=update    value=true   timeout=300
       Sleep    30
       ${gnb_id}=    Get Parameter    rat=5g    param_path=MRBTS-${bts_id}/LNBTS-{bts_id}/LNADJGNB-127:adjGnbId
       Should Not Be Equal    ${gnb_id}    ${bts_id}
       ${x2linkstatus}=   Get Parameter    param_path=MRBTS-${bts_id}/LNBTS-{bts_id}/LNADJGNB-127:x2ToGnbLinkStatus     alias=default
       Should Be Equal    ${x2linkstatus}  unavailable
       Perform Recommissioning   type=delta    delta_file=${DELETE_GNB_ID_CONFLICT_OAM}    verify_bts_status=False     timeout=300   alias=default
       Perform Recommissioning   type=delta    delta_file=${DELETE_LNADJ_INT}    verify_bts_status=False     timeout=300     alias=default
       Perform Recommissioning   type=param    param_path=LNBTS-${bts_id}:actEndcAutoX2SetupSbts     operation=update    value=false   timeout=300

Verify gNB ID conflict scneario for enbcontrolled
       Perform Recommissioning   type=delta    delta_file=${GNB_ID_CONFLICT_ENB}    verify_bts_status=False     timeout=300     alias=default
       Perform Recommissioning   type=param    param_path=LNBTS-${bts_id}:actEndcAutoX2SetupSbts     operation=update    value=true   timeout=300
       Verify X2 link status    available
       Sleep    120
       ${gnb_id}=    Get Parameter    rat=5g    param_path=MRBTS-${bts_id}/LNBTS-{bts_id}/LNADJGNB-127:adjGnbId
       Should Not Be Equal    ${gnb_id}    ${bts_id}
        ${x2linkstatus}=   Get Parameter    param_path=MRBTS-${bts_id}/LNBTS-{bts_id}/LNADJGNB-127:x2ToGnbLinkStatus     alias=default
       Should Be Equal    ${x2linkstatus}  unavailable
       ${cplane_ip_addr}=    Get Parameter    rat=5g    param_path=MRBTS-${bts_id}/LNBTS-{bts_id}/LNADJGNB-127:cPlaneIpAddr
       Should Contain   ${cplane_ip_addr}    ${5g_x2cplane1_ipv4}
       Perform Recommissioning   type=delta    delta_file=${DELETE_GNB_ID_CONFLICT_OAM}    verify_bts_status=False     timeout=300   alias=default
       Perform Recommissioning   type=param    param_path=LNBTS-${bts_id}:actEndcAutoX2SetupSbts     operation=update    value=false   timeout=300

Verify IP conflict scenario
       Perform Recommissioning   type=delta    delta_file=${GNB_IP_CONFLICT}    verify_bts_status=False     timeout=300     alias=default
       Perform Recommissioning   type=param    param_path=LNBTS-${bts_id}:actEndcAutoX2SetupSbts     operation=update    value=true    timeout=300
       Verify X2 link status    unavailable
       Verify Alarm    faultid=${5518_ALARM}   occurrences=1
       Perform Recommissioning   type=delta    delta_file=${DELETE_GNB_ID_IP_CONFLICT}    verify_bts_status=False     timeout=300    alias=default
       Perform Recommissioning   type=param    param_path=LNBTS-${bts_id}:actEndcAutoX2SetupSbts     operation=update    value=false  timeout=300

Update PLMN and verify if its reflected in LNADJGNB
       Perform Recommissioning   type=param    param_path=LNBTS-${bts_id}:actEndcAutoX2SetupSbts     operation=update    value=true   timeout=300
       Verify X2 link status    available
       Perform Recommissioning   type=delta    delta_file=${PLMN_MODIFY}    verify_bts_status=False     timeout=300     alias=default
       Sleep    120
       Perform Recommissioning   type=param    param_path=MRBTS-${bts_id}/NRBTS-${bts_id}:mcc     operation=update    value=400       timeout=300
       Perform Recommissioning   type=param    param_path=MRBTS-${bts_id}/NRBTS-${bts_id}:mnc     operation=update    value=98       timeout=300
       Sleep    120
       ${mcc_updated}=    Get Parameter    rat=5g    param_path=MRBTS-${bts_id}/LNBTS-${bts_id}/LNADJGNB-31:plmnId:mcc
       Should Be Equal As Integers    ${mcc_updated}    400
       ${mnc_updated}=    Get Parameter    rat=5g    param_path=MRBTS-${bts_id}/LNBTS-${bts_id}/LNADJGNB-31:plmnId:mnc
       Should Be Equal As Integers    ${mnc_updated}    98
       Perform Recommissioning   type=param    param_path=LNBTS-${bts_id}:actEndcAutoX2SetupSbts     operation=update   value=false   timeout=300
       Perform Recommissioning   type=delta    delta_file=${DELETE_LNADJ_INT}    verify_bts_status=False     timeout=300     alias=default

Update cplane ip address and check if its reflected and x2link is coming up
       Perform Recommissioning   type=param    param_path=LNBTS-${bts_id}:actEndcAutoX2SetupSbts     operation=update    value=true    timeout=300
       Verify X2 link status    available
       Perform Recommissioning   type=delta    delta_file=${X2C_X2U_SWAP_IPADDRESS}    verify_bts_status=False     timeout=300     alias=default
       Sleep    300
       ${5g_x2cplane1_ipv4}=     Get Parameter    rat=5g    param_path=${5g_nsa_x2clane1_ipv4_moc_path}
       Set Suite Variable    ${5g_x2cplane1_ipv4}    ${5g_x2cplane1_ipv4}
       Verify X2 link status    available
       Perform Recommissioning   type=param    param_path=LNBTS-${bts_id}:actEndcAutoX2SetupSbts     operation=update    value=false   timeout=300
       Perform Recommissioning   type=delta    delta_file=${DELETE_LNADJ_INT}    verify_bts_status=False     timeout=300     alias=default
       Perform Recommissioning   type=delta    delta_file=${X2C_X2U_SWAP_IPADDRESS_ORIGINAL}    verify_bts_status=False   timeout=300
      ...    alias=default
       Sleep    30

Add LNAJD with x2cplane ip and verify for alarm
       Perform Recommissioning   type=delta    delta_file=${LNADJ_WITH_SAME_X2C}    verify_bts_status=False     timeout=300     alias=default
       Perform Recommissioning   type=param    param_path=LNBTS-${bts_id}:actEndcAutoX2SetupSbts     operation=update    value=true    timeout=300
       Sleep    200
       Verify Alarm    faultid=${5518_ALARM}   occurrences=1
       Perform Recommissioning   type=delta    delta_file=${DELETE_LNADJ_SAME_X2C}    verify_bts_status=False     timeout=300     alias=default
       Perform Recommissioning   type=param    param_path=LNBTS-${bts_id}:actEndcAutoX2SetupSbts     operation=update    value=false   timeout=300

Verify IP connectivity
    FOR   ${DSCP}   IN RANGE   3
        ${changed_dscp}=         Evaluate    random.choice(range(0, 64))  random
        Set Suite Variable      ${changed_dscp}      ${changed_dscp}
    END
    FOR    ${payload_size}   IN RANGE   3
        ${changed_payload_size}=         Evaluate    random.choice(range(16, 61411))  random
        Set Suite Variable      ${changed_payload_size}      ${changed_payload_size}
    END
    Test Ipconnectivity     dut=bts     remote_address=${mplane1_ipv6}    payload_size=${changed_payload_size}
        ...   dscp=${changed_dscp}     source_address=${v6gateway}