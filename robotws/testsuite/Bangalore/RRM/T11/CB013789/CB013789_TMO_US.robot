*** Settings ***
Force Tags      CLOUD_5G_O_E_AP_LOOO   CRT  RAN_5G    5G_RAN_TDD    5G_RAN   SBTS00    CONFIGURED

Documentation    :copyright: Nokia
...              :author: Vinay
...              :contact:vinay.vinay@nokia.com
...
...             INTRODUCTION:This user scenario describes Verification of PCMD trace records
...                          with tracePCMDSetting set to NSA related trace records in gNB-CU-CP.
...             TEST SET NAME: CB013789
...             TESTING SPLIT: Refer CB013789 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES: CB013789 CFAM
...             Requirement ID: 12453631

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../5G_CRT/resources/common_Resource.robot
Resource         ../5G_CRT/resources/common_keywords.robot
Library          ta_pcmd
Resource          ./resources/CB013789_keywords.robot
Library		     taf.sbts.oam.coam.admin
Library          ta5g_cell_operations
Library          taf.sw.syslog
Resource        ../../../resources/robot/configuration_id.robot
Library          taf.analyzer.pdml

#Suite Setup         Suite setup from scratch

*** Variables ***
${sgnb_addition_record}=       SEPARATOR=
...   (nsetapx.ver_Id == 1)

${bearer_record}=       SEPARATOR=
...   (nsetapx.ver_Id == 10) && (nsetapx.erabId == 5) && (nsetapx.drb_Id == 4) &&
...   (nsetapx.qci == 9) && (nsetapx.priorityLevel == 15) && (nsetapx.preemptionCapability == 0) &&
...   (nsetapx.preemptionVulnerability == 0)

${menb_init_sgnb_modification}=       SEPARATOR=
...   (nsetapx.ver_Id == 7) && (nsetapx.sgnbModificationReason == 0) && (nsetapx.result == 0)

${sgnb_init_sgnb_modification}=       SEPARATOR=
...   (nsetapx.ver_Id == 5) && (nsetapx.sgnbModificationReason == 3) && (nsetapx.result == 0)

${sgnb_release}=       SEPARATOR=
...   (nsetapx.ver_Id == 2) && (nsetapx.sgnbReleaseReason == 0)

${enable_pcmd}    ${CURDIR}/config/scf/A_TC2_Delta_pcmd.json
${disable_pcmd}   ${CURDIR}/config/scf/A_TC2_Delta_disable_pmcd.json
${A_TC2_wts_file}     ${CURDIR}/config/wts/A_TC2_basis_setup.cfg
${nsa_st_ue_id}   101
${nsa_en_ue_id}   104
${nsa_last_ue_id}   105
${delta_configuration}       ${CURDIR}/config/scf/Configuration_scf_MRBTS-1_CA.json
${wts_cfg_file_TC3}          ${CURDIR}/config/wts/CB013789_FR1_WTS_CFG.cfg


*** Test Cases ***
USCB013789_A_B1_TC2_Monitoring_of_PCMD_selected_content_for_gNB-CU-CP_with_tracePCMDSetting_for_FR1_NSA_call
    [Documentation]  This user scenario describes behaviour of NBR IWK with MU MIMO.
    [Setup]    Run keywords
    ...        Log to console    "start"
    ...        AND    Suite setup from scratch
    ...        AND    Start Log   btslog
    ...        AND    Start WTS Using WTS_Runner      ${A_TC2_wts_file}
    ...        AND     sleep   60s
    ${TEST_NAME}    Set Variable   TC2
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    Log to console    ${bearer_record}
    X2AP Link Should be UP
    Start DCAP service on the testline
    Send Delta Commissioning    ${enable_pcmd}
    Start Tcp Pcap
    sleep   10s
    log to console   "Multiple NSA UE attache and fetech rnti"
    ${rnti_list}    MultiUE NSA Attach should be Successful and Fetch CRNTI    ${nsa_st_ue_id}    ${nsa_en_ue_id}    1
    ${rnti_list1}    MultiUE NSA Attach should be Successful and Fetch CRNTI    ${nsa_last_ue_id}    ${nsa_last_ue_id}    1
    Log to console   ${rnti_list}
    Add new LTE Bearer for Multiple UE     ${nsa_st_ue_id}    ${nsa_en_ue_id}   7    7
    Multiple NSA UE start and validate DL Traffic     ${nsa_st_ue_id}    ${nsa_last_ue_id}    10
    Multiple NSA UE start and validate UL Traffic     ${nsa_st_ue_id}    ${nsa_last_ue_id}    10
    Log to console     ${rnti_list}
    Log to console     ${rnti_list1}
    sleep   5s
    Multiple NSA UE Detach   ${nsa_st_ue_id}    ${nsa_last_ue_id}
    sleep    5s
    FOR   ${ue_rnti}   IN    @{rnti_list}
        ${packet_filter_with_rnti}     Set Variable     (${sgnb_addition_record} && (nsetapx.crnti == ${ue_rnti}))
        Log to console   ${packet_filter_with_rnti}
        Run keyword and continue on failure    Verify PCMD Trace Records for a Trace Record     packet_filter=${packet_filter_with_rnti}
        ${packet_filter_with_rnti}     Set Variable     (${bearer_record} && (nsetapx.crnti == ${ue_rnti}))
        Log to console   ${packet_filter_with_rnti}
        Run keyword and continue on failure    Verify PCMD Trace Records for a Trace Record     packet_filter=${packet_filter_with_rnti}
        ${packet_filter_with_rnti}     Set Variable     (${sgnb_init_sgnb_modification} && (nsetapx.crnti == ${ue_rnti}))
        Log to console   ${packet_filter_with_rnti}
        Run keyword and continue on failure    Verify PCMD Trace Records for a Trace Record     packet_filter=${packet_filter_with_rnti}
        ${packet_filter_with_rnti}     Set Variable     (${menb_init_sgnb_modification} && (nsetapx.crnti == ${ue_rnti}))
        Log to console   ${packet_filter_with_rnti}
        Run keyword and continue on failure    Verify PCMD Trace Records for a Trace Record     packet_filter=${packet_filter_with_rnti}
        ${packet_filter_with_rnti}     Set Variable     (${sgnb_release} && (nsetapx.crnti == ${ue_rnti}))
        Log to console   ${packet_filter_with_rnti}
        Run keyword and continue on failure    Verify PCMD Trace Records for a Trace Record     packet_filter=${packet_filter_with_rnti}
    END
    FOR   ${ue_rnti}   IN    @{rnti_list1}
        ${packet_filter_with_rnti}     Set Variable     (${sgnb_addition_record} && (nsetapx.crnti == ${ue_rnti}))
        Log to console   ${packet_filter_with_rnti}
        Run keyword and continue on failure    Verify PCMD Trace Records for a Trace Record     packet_filter=${packet_filter_with_rnti}
        ${packet_filter_with_rnti}     Set Variable     (${bearer_record} && (nsetapx.crnti == ${ue_rnti}))
        Log to console   ${packet_filter_with_rnti}
        Run keyword and continue on failure    Verify PCMD Trace Records for a Trace Record     packet_filter=${packet_filter_with_rnti}
        ${packet_filter_with_rnti}     Set Variable     (${sgnb_init_sgnb_modification} && (nsetapx.crnti == ${ue_rnti}))
        Log to console   ${packet_filter_with_rnti}
        Run keyword and continue on failure    Verify PCMD Trace Records for a Trace Record     packet_filter=${packet_filter_with_rnti}
        ${packet_filter_with_rnti}     Set Variable     (${menb_init_sgnb_modification} && (nsetapx.crnti == ${ue_rnti}))
        Log to console   ${packet_filter_with_rnti}
        Run keyword and continue on failure    Verify No PCMD Trace Records for a Trace Record     packet_filter=${packet_filter_with_rnti}
        ${packet_filter_with_rnti}     Set Variable     (${sgnb_release} && (nsetapx.crnti == ${ue_rnti}))
        Log to console   ${packet_filter_with_rnti}
        Run keyword and continue on failure    Verify PCMD Trace Records for a Trace Record     packet_filter=${packet_filter_with_rnti}
    END
    [Teardown]    Run Keywords
    ...     Link SCOUT SCF to Configuration ID for Reporting
#    ...     Multiple NSA UE Detach   ${nsa_st_ue_id}    ${nsa_en_ue_id}
    ...     AND   Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
    ...     AND   Send Delta Commissioning    ${disable_pcmd}
    ...     AND   Stop Log   btslog   snapshot    sosreport
    ...     AND   Stop Tcp Pcap
    ...     AND   Stop And Teardown PCMD



USCB013789-A_B_C_TC22_Robustness_Monitoring_PCMD_selected_content_between_gNB-CU-CP_And_gNB-CU-UP_And_gNB_DU_for_MBA
     [Documentation]    The scope of this test case is to validate MBA traces for CU-CP,CU-UP,DU.
          ...                  :author: sujeets
          ...              :contact:sujeet.sharma.com
     [Setup]    Run keywords
    ...        Log to console    "Setting up Testline"
     ...       AND    Configure Routes in WTS
    ...        AND    Run cfg file      ${wts_cfg_file_TC3}
    taf.sw.syslog.teardown_all_aliases_for_syslog
    taf.sw.syslog.Start Syslog    log_dir=/tmp    log_name=feat_act.log    alias=feat_act  ip=192.168.255.126       ports=51000
    Delta file commissioning for CA
    Sleep    20s
    Check SIB messagges for all cells
    Start DCAP service on the testline
    sleep    60s
    Start Tshark on eth3
    Start PDU Session AND Traffic ON UE-73
    Detach UE_73
    Verify 3CC CA
    Stop Tshark on eth3
  	Sleep    5s
    Start Tshark on br-utf_lab_net
    sleep    10s
    Start PDU Session AND Traffic ON UE-73
    sleep  10s
    Detach UE_73
    verify vendor_extention_records for DU_CA_Records
    verify vendor_extention_records for CU_UP_Records
    verify vendor_extention_records for CU_CP_Records
    sleep    30s
    Stop Tshark on br-utf_lab_net
    ta5g_cell_operations.block_all_cells
    sleep    10s
    ta5g_cell_operations.unblock_all_cells
    Start Tshark on br-utf_lab_net_1
    Start PDU Session AND Traffic ON UE-72
    Start PDU Session AND Traffic ON UE-92
    Fetch C-RNTI of all UEs
    Detach all UEs
    sleep     10s
    verify vendor_extention_records for CU_CP_Records_multi-UE
    verify vendor_extention_records for DU_CA Records_multi-UE
    verify vendor_extention_records for CU_UP_Records_multi-UE

    sleep    10s
    Stop Tshark on br-utf_lab_net_1

	 [Teardown]     Run Keywords    syslog crash verification
    ...    AND    taf.sw.syslog.Collect Syslog Results   destination=${OUTPUTDIR}${/}feat_act.log    unzip=True    alias=feat_act
    ...    AND    taf.sw.syslog.teardown_all_aliases_for_syslog
	...    AND    Link SCOUT SCF to Configuration ID for Reporting
	...    AND    Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

*** Keywords ***

Start DCAP service on the testline
     Run     utf_lab-controller start
     Sleep    60s

Start PCMD
    Configure PCMD    technology=5G    asn1per_decoding=${True}
    Start collecting PCMD reports

Start Tcp Pcap
    Start tshark
    ...    log_filename=eth3_tcp.pcap
    ...    eth_interface=eth3
    ...    capture_filter='tcp'
    ...    log_dirpath=${OUTPUT_DIR}/tshark
    ...    alias=tcp_pcap

Stop Tcp Pcap
    [Arguments]    ${alias}=tcp_pcap
    Stop tshark    alias=${alias}

Stop And Teardown PCMD
    Stop collecting PCMD reports
    Deconfigure PCMD

Verify PCMD Trace Records for a Trace Record
    [Arguments]    ${packet_filter}    ${pcap_file_path}=${None}    ${timeout}=10
    ...            ${alias}=tcp_pcap    ${continue_on_failure}=${True}
    Verify Tshark
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}
     ...   pass_criteria= >=1
    ...    pcap_file_path=${pcap_file_path}
    ...    timeout=${timeout}
    ...    continue_on_failure=${continue_on_failure}


Verify No PCMD Trace Records for a Trace Record
    [Arguments]    ${packet_filter}    ${pcap_file_path}=${None}    ${timeout}=10
    ...            ${alias}=tcp_pcap    ${continue_on_failure}=${True}
    Verify Tshark
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}
     ...   pass_criteria= ==0
    ...    pcap_file_path=${pcap_file_path}
    ...    timeout=${timeout}
    ...    continue_on_failure=${continue_on_failure}
