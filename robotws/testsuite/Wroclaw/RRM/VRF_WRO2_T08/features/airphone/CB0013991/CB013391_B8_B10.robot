*** Settings ***
Force Tags    CLOUD_5G_O_E_AP_LOO    PY310    NoResUsage    RF50    VARIANT_PRIVATE_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_RJIO_5_2

Documentation    :copyright: Nokia
...              :author: Anna Roskosz
...              :maintainer: Piotr Bebel
...              :contact: piotr.bebel@nokia.com

Resource     ./resources/CB013391_Keywords_And_Variables.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/reports/reporting_portal.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T023/uuf/Jakub_Magier/UUF_keywords_and_variables.robot
Library      ./resources/CB013391_Keywords.py

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/SetupLogs
...            AND             Perform Parameter Commissioning    parameter=actDisableUPIPFor64kPreferred    value=true
...            AND             Perform Parameter Commissioning    parameter=srbInactivityTimerSA    value=120
...            AND             Perform Parameter Commissioning    parameter=drbInactivityTimerSA    value=120
...            AND             Perform Parameter Commissioning    parameter=drbInactivityTimerSA5qi1    value=120
...            AND             Perform Parameter Commissioning    parameter=drbInactivityTimerSA5qi5    value=120
...            AND             Perform Parameter Commissioning    parameter=actPucchF3BasedTaGrantsRed       value=false
...            AND             Backup And Modify Swconfig File    parameters_list=@{CB007208_OFF_FLAG}
...            AND             Perform Parameter Commissioning    parameter=reportingIntervalPm    value=15min
...                            dist_name=MRBTS-1/MNL-1/MNLENT-1/PMCADM-1
...            AND             Trigger Site Reset
...            AND             Check Radios Availability
...            AND             Install Bsr Package For UUF Test     BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471.zip
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             Start Xn And Ng Interfaces For Second Gnb
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_CB013391.cfg    mplane_cells=2
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/SetupLogs

Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs

*** Test Cases ***
CB013391_B8_41_Intra_gNB_HO_with_UPIP_activated_and_IP_preferred_64kbps_AES
    [Documentation]    This test case aims to check the behavior of Nokia gNB in SA mode during the intra gNB Handover
    ...                with UPIP activated and multiple PDU Sessions each configured with Integrity protection Indication
    ...                value set to ?preferred? and Maximum IP Data rate in DL set as ?maximum-UE-rate?
    ...                Test case covers requirement: 5G_RAN_USR_RRM_25808

    [Setup]    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

    Set Internal Traffic Type With Qfi    ue=1-5
    Set Smf Param Maximum UE Rate
    Attach Ue    ue_id=1
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    Establish Pdu Session    ue_id=1    pdu_id=2    gw_id=2
    Verify Ngap Messages    packet_filter=${ICS_PREFERRED_MAXIMUM_UE_RATE}
    Verify Ngap Messages    packet_filter=${PDU_SESSION_RESOURCE_SETUP_REQUEST_PREFERRED_MAXIMUM_UE_RATE}
    Verify Tcpdump Log    packet_filter=${E1AP_BEARER_CONTEXT_MODIFICATION_REQ_NEW_UL_INFO_REQ}    number_of_messages=0
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_MODIFICATION_REQUEST_INTEGRITY_PROTECTION}    number_of_messages=0
    Start Data Traffic With Qfi    ue=1    pdu=1
    ${TRAFFIC_BEFORE_HO}    Get Cell Dl Data Traffic    ue_id=1
    Perform HO Meas Type A3    pass_regexp=Intra-eNB handover from EXT_ENB-2.3 to EXT_ENB-2.1 performed
    Waiting For Messages Collection

    Verify Tcpdump Log    packet_filter=${E1AP_BEARER_CONTEXT_MODIFICATION_REQ_NEW_UL_INFO_REQ}
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_MODIFICATION_REQUEST_INTEGRITY_PROTECTION}
    Check If Message Rrc Reestablishment Complete Is Visible
    Assert Traffic After Procedure    ue_id=1    checked_traffic=${TRAFFIC_BEFORE_HO}

    Pdu Session Ue Release    ue=1    pdu=1
    Pdu Session Ue Release    ue=1    pdu=2

    Wait For Next Full Pm Interval
    ${PM_COUNTER_FILE} =    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55122C00003   +2    PDU_SES_STP_ATT_UPIP_PREF
    ...    M55122C00004   +0    PDU_SES_STP_ATT_UPIP_REQD
    ...    M55122C00005   +2    PDU_SES_STP_SUC_UPIP_ACT_PREF
    ...    M55122C00006   +0    PDU_SES_STP_SUC_UPIP_NACT_PREF
    ...    M55122C00007   +0    PDU_SES_STP_SUC_UPIP_ACT_REQD
    ...    M55147C00001   +1    TOT_INTRA_FREQ_HO_DECISION_A3S
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    file_path=${PM_COUNTER_FILE}
    ...     taf.sw.reporting_portal.Report Pm Counter=True

     [Teardown]  Run Keywords
     ...         reporting_portal.Add scout external execution id to the reporting portal     AND
     ...         Deregister Ue Without Confirmation    ue_id=1                                AND
     ...         Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

CB013391_B10_46_RRC_Reestablishment_via_RRC_Setup_without_UPIP_preferred_64kbps_AES
    [Documentation]    This test case aims to check the behavior of Nokia gNB in SA mode during the RRC Reestablishment
    ...                without UPIP activated and multiple PDU Sessions each configured with Integrity protection Indication value set to ?preferred?
    ...                and Maximum IP Data rate in DL set as ?64kbps?.
    ...                Test case covers requirement: 5G_RAN_USR_RRM_25823

    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        AND             Change Ue Location Without Confirmation    ue_id=1    dst_enb=2    dst_cell=3

    Set Internal Traffic Type With Qfi    ue=1-5
    Set Internal Traffic Type With Qfi    ue=1-5    pdu=2
    Set Smf Param 64kbps
    Attach Ue    ue_id=1
    Attach Ue    ue_id=2
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    Establish Pdu Session    ue_id=1    pdu_id=2    gw_id=2
    Start Data Traffic With Qfi
    Start Data Traffic With Qfi    pdu=2
    ${TRAFFIC_BEFORE_REESTABLISHMENT}    Get Cell Dl Data Traffic    ue_id=1
    Initiate Ue Rrc Reestablishment    ue_id=1    cause=otherFailure    cell=3    pass_regexp=criticalExtensions rrcReconfigurationComplete
    Waiting For Messages Collection

    Verify Ngap Messages    packet_filter=${ICS_PREFERRED_64KBPS_UE_RATE}
    Verify Ngap Messages    packet_filter=${PDU_SESSION_RESOURCE_SETUP_REQUEST_PREFERRED_64KBPS_UE_RATE}
    Verify Tcpdump Log    packet_filter=${RRC_REESTABLISHMENT_REQUEST_OTHER_FAILURE}
    Check If Message Rrc Reestablishment Complete Is Visible
    Assert Traffic After Procedure    ue_id=1    checked_traffic=${TRAFFIC_BEFORE_REESTABLISHMENT}

    Pdu Session Ue Release    ue=1    pdu=1
    Pdu Session Ue Release    ue=1    pdu=2
    Deregister Ue Without Confirmation    ue_id=1
    Wait For Next Full Pm Interval
    ${PM_COUNTER_FILE} =    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55124C00505   +1    RRC_REESTAB_OTHER_FAILURE
    ...    M55124C00516   +1    REESTAB_RRCRECONFIG_SUCC
    ...    M55122C00003   +2    PDU_SES_STP_ATT_UPIP_PREF
    ...    M55122C00004   +0    PDU_SES_STP_ATT_UPIP_REQD
    ...    M55122C00005   +0    PDU_SES_STP_SUC_UPIP_ACT_PREF
    ...    M55122C00006   +2    PDU_SES_STP_SUC_UPIP_NACT_PREF
    ...    M55122C00007   +0    PDU_SES_STP_SUC_UPIP_ACT_REQD
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    file_path=${PM_COUNTER_FILE}
    ...    taf.sw.reporting_portal.Report Pm Counter=True

    [Teardown]  Run Keywords
     ...        reporting_portal.Add scout external execution id to the reporting portal     AND
     ...        Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
