*** Settings ***
Documentation   This file consists Keywords specific to Feature CB008033 Test Cases.

Library         BuiltIn
Library         Collections
Library         OperatingSystem
Library         String
Library         taf.wts.runner    WITH NAME    wtsrunner
Library         taf.config.scf    WITH NAME    scf
Library         taf.sw.syslog     WITH NAME    slog
Library         ute_fsmaccess
Library         ta5g_pm_counters
Library         taf.sbts.oam.coam.admin         WITH NAME    admin
Variables       ta5g_global_var
Resource        ${CURDIR}/../../../resources/Keywords/common_keywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/ap_Keywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/generic_kw.robot
Resource        ${CURDIR}/../../../resources/Keywords/gnb_Keywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/HO_KW.robot
Resource        ${CURDIR}/../../../resources/Keywords/ute_wts_runner.robot
Resource        ${CURDIR}/../../../resources/Variables/common_variables.robot


*** Variables ***
${PDU_SESSION_MOD_PATTERN}      Pdu Session Resource Modify Response Message with RAN UE NGAP ID 0 handled successfully
${PDU_SESSION_QOS_PATTERN}      PDU SESSION RESOURCE MODIFY RESPONSE
${WTS_WORKING_DIR}             /opt/iphy/latest
${GNB_IP}           ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${GNB_USERNAME}     ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${GNB_PASSWORD}     ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${TOPOLOGY}         CLOUD_5G_I_LOO_AP_LOOO
${DELTACONFIGDIR}       ${CURDIR}/../../config/scf
${APCONFIGDIR}          ${CURDIR}/../../config/ap_iphy
${AP_CONFIG_BASIC}          ${CURDIR}/../../config/wts


*** Keywords ***
UE Modification Should Be Successful
    [Documentation]		This keyword is used to check if UE modification is done successfully
    [Arguments]     ${UE_ID}    ${PDU_SESSION_ID}    ${QOSFLOWS_TO_ADD}=${QOS_ADD}
    wtsrunner.Ue Pdu Session Modify     ue=${UE_ID}     pdu=${PDU_SESSION_ID}
    ...    qosflows_to_add=${QOSFLOWS_TO_ADD}    by=amf
    ${output}    Read WTS Output Until Pattern Matches    ${PDU_SESSION_QOS_PATTERN}     timeout=20
    Print Matching Lines From Output File    ${output}    ${PDU_SESSION_MOD_PATTERN}
    Log To Console      ${PDU_SESSION_MOD_PATTERN}

Trigger VoNR Data
    [Documentation]		This keyword shall be used to start DL and UL rtp data
	[Arguments]    ${ue_id}   ${pdu_id}=${PDU_SESSION_ID}     ${trf_id}=${TRF_ID}     ${qfi_id}=${QFI_ID}   ${rtp_codec}=${RTP_COD}
	Log To Console    \nRunning VoNR DL/UL Traffic for ${rtp_codec}...
    wtsrunner.Trf Data Start     ue=${ue_id}    pdu=${pdu_id}   qfi=${qfi_id}
    ...    dir=dl    trf_id=${trf_id}    rtp_codec=${rtp_codec}
	${output}   wtsrunner.Read Wtsemu Output Until Re    expected=Started Downlink Internal traffic Receiver*
    ...        timeout=10
    ${output}   Get Lines Matching Regexp    ${output}    UDP DL TRF:    partial_match=${TRUE}
    Log To Console    ${output} VoNR_DL_traffic_data_is_started_successfully
    wtsrunner.Trf Data Start     ue=${ue_id}    pdu=${pdu_id}   qfi=${qfi_id}
    ...    dir=ul    trf_id=${trf_id}    rtp_codec=${rtp_codec}
    ${output}   wtsrunner.Read Wtsemu Output Until Re    expected=Started Uplink Internal traffic*
    ...      timeout=10
    ${output}   Get Lines Matching Regexp    ${output}    UDP UL TRF:    partial_match=${TRUE}
    Log To Console    ${output} VoNR_UL_traffic_data_is_started_successfully

Prepare For Testcase CB008033 TC5
    [Documentation]    This is Setup Keywords for Testcase CB008033_C_TC5
    ${LOG_PATH}      Create Log Directory    CB008033_C_TC5
    Link SCOUT SCF To Configuration ID For Reporting
    Set Test Variable    ${LOG_PATH}
    Create Basic Interface On UTE
    GNB Delta Commission     ${DELTACONFIGDIR}/Delta_Configuration_TMO_IADU_IAFR_NSA.json
    Wait Coam Site To Be Ready
    Start UTE WTS           basic_TMO_IADU_IAFR_NSA.cfg
    slog.Start Syslog       ${Log_Path}     CB008033_TC5.LOG

Teardown For TestCase CB008033 TC5
    [Documentation]    This is Teardown Keywords for Testcase CB008033_C_TC5
    slog.Stop Syslog
    Snapshot Collection     ${Log_Path}     Snapshot_TMO_C5.zip
    GNB Delta Commission    ${DELTACONFIGDIR}/Delta_Configuration_TMO_IADU_IAFR_NSA_reverse.json
    Copy Files      ${WTS_WORKING_DIR}/egate_console.log      ${LOG_PATH}
    Run     zip -r ${OUTPUTDIR}/CB008033_C_TC5.zip ${LOG_PATH}
    Delete Basic Interface On UTE
    RAT Block Unblock

Prepare For Testcase CB008033 TC6
    [Documentation]    This is Setup Keywords for Testcase CB008033_C_TC6
    ${LOG_PATH}      Create Log Directory    CB008033_C_TC6
    Link SCOUT SCF To Configuration ID For Reporting
    Set Test Variable    ${LOG_PATH}
    Create Basic Interface On UTE
    GNB Delta Commission    ${DELTACONFIGDIR}/Delta_Configuration_TMO_IADU_IAFR_NSA_SRB3.json
    Wait Coam Site To Be Ready
    Start UTE WTS     basic_TMO_IADU_IAFR_NSA.cfg
    slog.Start Syslog       ${Log_Path}     CB008033_TC6.LOG

Teardown For TestCase CB008033 TC6
    [Documentation]    This is Teardown Keywords for Testcase CB008033_C_TC6
    slog.Stop Syslog
    Snapshot Collection     ${Log_Path}     Snapshot_TMO_C6.zip
    GNB Delta Commission   ${DELTACONFIGDIR}/Delta_Configuration_TMO_IADU_IAFR_NSA_SRB3_reverse.json
    Copy Files      ${WTS_WORKING_DIR}/egate_console.log      ${LOG_PATH}
    Run     zip -r ${OUTPUTDIR}/CB008033_C_TC6.zip ${LOG_PATH}
    Delete Basic Interface On UTE
    RAT Block Unblock

Prepare For Testcase CB008033 TC7
    [Documentation]    This is Setup Keywords for Testcase CB008033_C_TC7
    ${LOG_PATH}      Create Log Directory    CB008033_C_7
    Link SCOUT SCF To Configuration ID For Reporting
    Set Test Variable    ${LOG_PATH}
    Create Basic Interface On UTE
    Create Interface For Xn HO
    GNB Delta Commission     ${DELTACONFIGDIR}/Delta_Configuration_APoABIO_IADU_IntergNB_IEFR_NSA_SRB3.json
    Sleep   30s
    GNB Reboot
    sleep               360s
    Wait Coam Site To Be Ready
    Start UTE WTS      basic_IADU_IEFR_IntergNB_NSA.cfg

Teardown For TestCase CB008033 TC7
    [Documentation]    This is Teardown Keywords for Testcase CB008033_C_TC7
    GNB Delta Commission    ${DELTACONFIGDIR}/Delta_Configuration_APoABIO_IADU_IntergNB_IEFR_NSA_SRB3_reverse.json
    Copy Files      ${WTS_WORKING_DIR}/egate_console.log      ${LOG_PATH}
    Run     zip -r ${OUTPUTDIR}/CB008033_C_TC7.zip ${LOG_PATH}
    Delete Basic Interface On UTE
    Delete Interface Created By Xn HO
    RAT Block Unblock

Prepare For Testcase CB008033 TC8
    [Documentation]    This is Setup Keywords for Testcase CB008033_C_TC8
    ${LOG_PATH}      Create Log Directory    CB008033_C_8
    Link SCOUT SCF To Configuration ID For Reporting
    Set Test Variable    ${LOG_PATH}
    Create Basic Interface On UTE
    Create Interface For Xn HO
    GNB Delta Commission     ${DELTACONFIGDIR}/Delta_Configuration_APoABIO_IADU_IntergNB_IAFR_NSA_SRB3.json
    Sleep   30s
    GNB Reboot
    sleep               360s
    Wait Coam Site To Be Ready
    Start UTE WTS      basic_IADU_IntergNB_NSA.cfg

Teardown For TestCase CB008033 TC8
    [Documentation]    This is Teardown Keywords for Testcase CB008033_C_TC8
    GNB Delta Commission    ${DELTACONFIGDIR}/Delta_Configuration_APoABIO_IADU_IntergNB_IAFR_NSA_SRB3_reverse.json
    Delete Basic Interface On UTE
    Delete Interface Created By Xn HO
    Collect Logs For The Test       ${LOG_PATH}
    Copy Files      ${WTS_WORKING_DIR}/egate_console.log      ${LOG_PATH}
    Run     zip -r ${OUTPUTDIR}/CB008033_C_TC8.zip ${LOG_PATH}
    RAT Block Unblock

Make ENDC Call
    [Documentation]     This keyword is TestCase specific Keyword for UE attach.
    [Arguments]    ${NSA_UE_ID}=11    ${Target_Cells}=1
    LTE Attach Should Be Successful For NSA     ${NSA_UE_ID}
    UE Attach Should Be Successful For NSA      ${NSA_UE_ID}       ${Target_Cells}

Basic Bring Up With RANSIM
    [Documentation]       This keyword is for basic Ng, X2 and AP cell setup
    X2AP Link Should Be UP
    Setup X2 With RANSIM GNB
    Sleep    100s
