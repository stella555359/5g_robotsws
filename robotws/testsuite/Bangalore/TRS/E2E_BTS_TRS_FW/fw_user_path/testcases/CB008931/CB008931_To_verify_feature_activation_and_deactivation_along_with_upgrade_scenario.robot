*** Settings ***
Documentation
    ...     [Procedure]             "The test case is planned to validate CB008931 Use case"
    ...     [Date]                  ""
    ...     [SCF]                   "plain_scf.xml"
    ...     [Author]                "Abhishek Patil"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Feature_ID]            "CB008931"
    ...     [Validation_status]     "draft"
    ...     [Validated_TestLine]    "ASIM_TL004_10.58.143.125"

#Force Tags        CLOUD_R4P       CA_E2ET_BTSTRSPZ        SBTS00    RAN_4G    RAN_4G_FDD       QCD_MN_RAN        QCP_RAN_ET        CRT

Resource        ${CURDIR}/../resources/common_keywords.robot

Suite Setup             Run Keywords    Pre-conditions for testsuite
Suite Teardown     Run Keywords         Post-conditions for testteardown

*** Test Cases ***
[1]CB008931_To_verify_feature_activation_deactivation_with_upgrade_and_verify_Initial_Context_Setup_and_mutiple_bearer_setup_request_and
#_No_DSCPPR_moc_present
    Perform Recommissioning     type=delta      delta_file=${CB008931_base_delta}       skip_parameter_relation_errors=${False}      timeout=300
	Call Setup  lte=plain_call:data   parallel=${False}   verify_attach=${False}      attach=
    Sleep    60
	Traffic Capture Start   capture_device=vm_eth3_interface     alias=ue_capture_1
	Configure UE        lte=plain_call:data  command=ue_attach id=1 cell=51
	Configure UE        lte=plain_call:data  command=trf_data_start ue=1 dir=ul Mbps=30 protocol=udp
	Configure UE        lte=plain_call:data  command=trf_data_start ue=1 qci=6 dir=ul Mbps=30 protocol=udp
	Configure UE        lte=plain_call:data  command=trf_data_start ue=1 qci=7 dir=ul Mbps=30 protocol=udp
	Configure UE        lte=plain_call:data  command=trf_data_start ue=1 qci=8 dir=ul Mbps=30 protocol=udp
    Sleep   5
	Configure UE        lte=plain_call:data  command=ue_detach id=1
	${Without_8931_call}=       Traffic Capture Stop      alias=ue_capture_1
    Verify DSCP from pcap   ${Without_8931_call}

    Perform Recommissioning     type=param      param_path=${ACT_QCI_ARP_flag}   skip_parameter_relation_errors=${True}    operation=update
    ...     value=true  timeout=60
    Traffic Capture Start   capture_device=vm_eth3_interface     alias=ue_capture_2
    Configure UE        lte=plain_call:data  command=ue_attach id=2 cell=51
    Configure UE        lte=plain_call:data  command=trf_data_start ue=2 dir=ul Mbps=30 protocol=udp
    Configure UE        lte=plain_call:data  command=trf_data_start ue=2 qci=6 dir=ul Mbps=30 protocol=udp
    Configure UE        lte=plain_call:data  command=trf_data_start ue=2 qci=7 dir=ul Mbps=30 protocol=udp
    Configure UE        lte=plain_call:data  command=trf_data_start ue=2 qci=8 dir=ul Mbps=30 protocol=udp
    Sleep   5
    Configure UE        lte=plain_call:data  command=ue_detach id=2
    ${With_8931_call}=       Traffic Capture Stop      alias=ue_capture_2
    Verify DSCP from pcap   ${With_8931_call}

    Perform software download and update     wft_profile=sbtstrunk_00    package=auto     activate_sw=true    update_timeout=4500
#@    Perform software download and update     wft_profile=branch_SBTS25R1    package=auto     activate_sw=true    update_timeout=4500
#@    Perform software download and update     wft_profile=branch_SBTS26R1    package=auto     activate_sw=true    update_timeout=4500
    Wait Until Keyword Succeeds  10 min     1 min    Verify Bts Status   should_be_onair=${True}
    Verify Alarm    faultid=6450     should_exist=
    Traffic Capture Start   capture_device=vm_eth3_interface     alias=ue_capture_3
    Configure UE        lte=plain_call:data  command=ue_attach id=3 cell=51
    Configure UE        lte=plain_call:data  command=trf_data_start ue=3 dir=ul Mbps=30 protocol=udp
    Configure UE        lte=plain_call:data  command=trf_data_start ue=3 qci=6 dir=ul Mbps=30 protocol=udp
    Configure UE        lte=plain_call:data  command=trf_data_start ue=3 qci=7 dir=ul Mbps=30 protocol=udp
    Configure UE        lte=plain_call:data  command=trf_data_start ue=3 qci=8 dir=ul Mbps=30 protocol=udp
    Sleep   5
    Configure UE        lte=plain_call:data  command=ue_detach id=3
    ${With_8931_call_1}=       Traffic Capture Stop      alias=ue_capture_3
    Verify DSCP from pcap   ${With_8931_call_1}

    Perform Recommissioning     type=param      param_path=${ACT_QCI_ARP_flag}      skip_parameter_relation_errors=${False}     operation=update
    ...     value=false     timeout=60
    Attach call and verify DSCP value   1   51
    Attach call and verify DSCP value   2   51
    Attach call and verify DSCP value   3   51
    [Teardown]    Keywords to run at end

***Keywords***
Attach call and verify DSCP value
    [Arguments]        ${UE}   ${Cell}
    Traffic Capture Start       capture_device=vm_eth3_interface      alias=ue_capture_common
    Configure UE    lte=plain_call:data  command=ue_attach id=${UE} cell=${Cell}
    Configure UE    lte=plain_call:data  command=trf_data_start ue=${UE} dir=ul Mbps=30 protocol=udp
    Configure UE    lte=plain_call:data  command=trf_data_start ue=${UE} qci=6 dir=ul Mbps=30 protocol=udp
    Configure UE    lte=plain_call:data  command=trf_data_start ue=${UE} qci=7 dir=ul Mbps=30 protocol=udp
    Configure UE    lte=plain_call:data  command=trf_data_start ue=${UE} qci=8 dir=ul Mbps=30 protocol=udp
    Configure UE    lte=plain_call:data  command=ue_detach id=${UE}
    ${Verify_DSCP_in_call}=    Traffic Capture Stop    alias=ue_capture_common
    Verify DSCP from pcap   ${Verify_DSCP_in_call}

Verify DSCP from pcap
    [Arguments]       ${pcap_file}
    ${Number_of_bearer_in_call}=      Execute command     tshark -n -r ${pcap_file} -Y "s1ap && s1ap.qCI" -T fields -e
    ...     s1ap.E_RABToBeSetupListCtxtSUReq 2>/tmp/stderr.txt
    @{qci_list}=    Create List
    @{arp_list}=    Create List
    ${qci}=     Execute command     tshark -n -r ${pcap_file} -Y "s1ap && s1ap.qCI" -T fields -e s1ap.qCI 2>/tmp/stderr.txt
    ${arp}=     Execute command     tshark -n -r ${pcap_file} -Y "s1ap && s1ap.qCI" -T fields -e s1ap.priorityLevel 2>/tmp/stderr.txt
    @{qci_list} =  Split String    ${qci}  ,
    @{arp_list} =  Split String    ${arp}  ,
    log    ${qci_list}
    log    ${arp_list}
    ${QCI_ARP_feature_flag}=    Get Parameter       param_path=${ACT_QCI_ARP_flag}
    FOR     ${i}    IN RANGE    0       ${Number_of_bearer_in_call}
        Run keyword If     '${QCI_ARP_feature_flag}'=='True'     Get DSCP value    ${qci_list}[${i}]    ${arp_list}[${i}]      ELSE
        ...     Get DSCP value from QCITAB    ${qci_list}[${i}]
        Analyse pcap            pcap_filename=${pcap_file}        analysis=GTP_UL_Traffic     filter_file_name=${CB008931_Traffic}
    END

Get DSCP value
    [Arguments]     ${QCI}      ${ARP}
    ${DSCP_Value}=      Get parameter       param_path=LNBTS-1:qciTab${QCI}
    ${values}=    Get Dictionary Values    ${DSCP_Value}
    log     ${values}
    ${ARP}      Convert To Integer  ${ARP}
    ${list}=    Get Dictionary Values    ${values}[0]
    Log    ${list}
    ${dscp}=    Get from Dictionary    ${list}[0]   dscpProfIdx
    Run keyword If     '${dscp}'=='None'     Get DSCP value from QCITAB     ${QCI}      ELSE
    ...     Get DSCP from DSCPPR    ${QCI}      ${ARP}      ${dscp}

Get DSCP from DSCPPR
    [Arguments]     ${QCI}      ${ARP}      ${dscp}
    ${DSCPPR}=      Get parameter       param_path=DSCPPR-${dscp}
    log     ${DSCPPR}
    ${1}=    Get Dictionary Items    ${DSCPPR}
    log     ${1}[0]
    log     ${1}[1]
    ${DSCPPR}=    Get from Dictionary    ${1}[1]       dscpMarking
    ${2}=      Get From List    ${DSCPPR}   0
    ${dscppr_len}=     Get Length  ${DSCPPR}
    Run keyword If     ${dscppr_len}==1     Get DSCP value from one DSCPPR      ${2}       ${ARP}      ${QCI}     ELSE
    ...     Get DSCP value from multiple DSCPPR    ${DSCPPR}       ${ARP}      ${QCI}

Get DSCP value from one DSCPPR
    [Arguments]     ${DSCPPR}      ${ARP}      ${QCI}
    ${start_arp}=       Get from Dictionary    ${DSCPPR}       arpValueStart
    ${stop_arp}=        Get from Dictionary    ${DSCPPR}       arpValueStop
    ${start_arp}     Convert To Integer  ${start_arp}
    ${stop_arp}     Convert To Integer  ${stop_arp}
    ${arp_count}=       Evaluate    ${stop_arp}-${start_arp}+1
#    Compare with ARP and get DSCP   ${DSCPPR}    ${arp_count}    ${start_arp}    ${stop_arp}     ${ARP}      ${QCI}
    Compare with ARP and get DSCP   ${DSCPPR}    ${arp_count}    ${start_arp}    ${ARP}
    ${1234}=      Run keyword IF      "${1234}"!="${EMPTY}"        Set Variable    ${1234}     ELSE       Get DSCP value from QCITAB    ${QCI}
    Set Suite variable  ${dscp_value_for_filter}    ${1234}

Get DSCP value from multiple DSCPPR
    [Arguments]     ${Multiple_DSCPPR}      ${ARP}      ${QCI}
    log     ${Multiple_DSCPPR}
    ${length_DSCPPR}=     Get Length  ${Multiple_DSCPPR}
    FOR     ${i}    IN RANGE    ${length_DSCPPR}
        ${start_arp}=       Get from Dictionary    ${Multiple_DSCPPR}[${i}]       arpValueStart
        ${stop_arp}=        Get from Dictionary    ${Multiple_DSCPPR}[${i}]       arpValueStop
        ${start_arp}     Convert To Integer  ${start_arp}
        ${stop_arp}     Convert To Integer  ${stop_arp}
        ${arp_count}=       Evaluate    ${stop_arp}-${start_arp}+1
        Compare with ARP and get DSCP   ${Multiple_DSCPPR}[${i}]    ${arp_count}    ${start_arp}    ${ARP}
    END
    ${1234}=      Run keyword IF      "${1234}"!="${EMPTY}"            Set Variable    ${1234}     ELSE       Get DSCP value from QCITAB    ${QCI}
    Set Suite variable  ${dscp_value_for_filter}    ${1234}1

Compare with ARP and get DSCP
    [Arguments]     ${DSCPPR}   ${arp_count}    ${start_arp}    ${ARP}
    @{ARP_list_dscppr}=    Create List
    FOR     ${j}    IN RANGE        ${arp_count}
        Append To List      ${ARP_list_dscppr}      ${start_arp}
        ${start_arp}=       Evaluate    ${start_arp}+1
        log     ${ARP_list_dscppr}
        ${arp_from_dscppr}=     Get From List    ${ARP_list_dscppr}    ${j}
        ${1234}=      Run keyword IF      ${arp_from_dscppr} == ${ARP}         DSCP_Fetch    ${DSCPPR}      ELSE    Set Variable    ${EMPTY}
        log     ${1234}
        Exit For Loop IF      "${1234}"!="${EMPTY}"
        Set Suite variable  ${1234}    ${1234}
    END
    Set Suite variable  ${1234}    ${1234}
    [Return]        ${1234}

DSCP_Fetch
    [Arguments]     ${DSCPPR}
    ${dscp}=    Get from Dictionary    ${dscppr}   dscpValue
    [Return]        ${dscp}

Get DSCP value from QCITAB
    [Arguments]     ${QCI}
    ${DSCP_Value}=      Get parameter       param_path=MRBTS-1/LNBTS-1:qciTab${QCI}:dscp
    log     ${DSCP_Value}
    Set Suite variable  ${dscp_value_for_filter}    ${DSCP_Value}
    [Return]        ${DSCP_Value}

Keywords to run at end
    Execute command     sudo killall edaemon egate
    Perform Recommissioning     type=delta      delta_file=${CB008931_remove_delta}       skip_parameter_relation_errors=${True}      timeout=300
    Execute command     rm -rf ${CURDIR}/execution_logs/*_A54.zip