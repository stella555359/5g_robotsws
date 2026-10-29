*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO   VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE    CONFIGURED
...           RAN_5G_TDD    RAN_5G    SBTS00    SBTS23R1

Documentation    :copyright: Nokia
...              :authors: Katarzyna Wisniewska
...              :contact: katarzyna.wisniewska@nokia.com
...              :testsuite description: FGCR-12238 provides possibility to request broadcast of both SIB6 and SIB7
...              in single Write Replace Warning Request, during one Write Replace Warning procedure.

Resource     ../resources/5G_SW_WRO_Keywords.robot
Library      ../resources/Python/webem_alarms.py

Library      ta5g_testline_management
Library      ta5g_cell_operations
Library      ta5g_iphy
Library      ta5g_enb
Resource     ../resources/configuration_id.robot

Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
    ...                        iphy_xml_filepath=${CURDIR}/config/iphy_2AEQE.xml
    ...        AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/suite_setup_logs
    ...        AND             Find Scfc And Fix And Send Full Commissioning
    ...                        scfc_filename=full_ETWS_activated.xml
    ...        AND             Check Radios Availability
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_2c_tdd_sansa.lua
    ...        AND             Stop Default Logging     output_dirpath=${OUTPUT_DIR}/suite_setup_logs

Suite Teardown   Run Keywords    Print Active Alarms
    ...    AND   Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${NGAP_WRW_REQ_WARNING_TYPE} =    ${NGAP_WRITE_REPLACE_WARNING_REQUEST} && ngap.WarningType == 03:80
${NGAP_WRW_REQ_DATA_CODING_SCHEME} =    ${NGAP_WRITE_REPLACE_WARNING_REQUEST} && ngap.id == 20
${NGAP_WRW_REQ_WARNING_MESSAGE_CONTENTS} =    ${NGAP_WRITE_REPLACE_WARNING_REQUEST} && ngap.id == 123
${NGAP_WRW_REQ_NUMBER_OF_BROADCASTS} =    ${NGAP_WRITE_REPLACE_WARNING_REQUEST} && ngap.NumberOfBroadcastsRequested == 0
${NGAP_WRW_RESP_BROADCAST_COMPLETED_AREA_LIST} =    ${NGAP_WRITE_REPLACE_WARNING_RESPONSE} && ngap.id == 13
${F1AP_WRW_REQ_SIB6} =    ${F1AP_WRITE_REPLACE_WARNING_REQUEST} && f1ap.sIBtype == 6
${F1AP_WRW_REQ_SIB7} =    ${F1AP_WRITE_REPLACE_WARNING_REQUEST} && f1ap.sIBtype == 7

${F1AP_PWS_FAILURE_INDICATION} =    f1ap.PWSFailureIndication_element
${F1AP_PWS_RESTART_INDICATION} =    f1ap.PWSRestartIndication_element
${F1AP_PWS_RESTART_INDICATION_TRANSACTIONID} =    f1ap.id == 78 && ${F1AP_PWS_RESTART_INDICATION}
${F1AP_PWS_RESTART_INDICATION_CELLIDLISTFORRESTART} =    f1ap.id == 152 && ${F1AP_PWS_RESTART_INDICATION}

${NGAP_PWS_RESTART_INDICATION_CELLIDLISTFORRESTART} =    ngap.NRCellIdentity == 0x0000004001 &&
...     ${NGAP_PWS_RESTART_INDICATION}
${NGAP_PWS_RESTART_INDICATION_GLOBALRANNODEID} =    ngap.gNB_ID == 00:00:04 && ${NGAP_PWS_RESTART_INDICATION}
${NGAP_PWS_RESTART_INDICATION_TAILISTFORRESTART} =    ngap.id == 104 && ${NGAP_PWS_RESTART_INDICATION}
${NGAP_PWS_RESTART_INDICATION_EMERGENCYAREAIDLISTFORRESTART} =    ngap.EmergencyAreaID == 00:00:01 &&
...     ${NGAP_PWS_RESTART_INDICATION}

*** Test Cases ***
FGCR_12238_A_1_Successful_ETWS_Primary_And_Secondary_Notification_Broadcast
    [Tags]    CRT
    [Documentation]   Correct handling of Primary and Secondary ETWS Notification Broadcast.
    ...               Broadcast of SIB6 and SIB7 is expected.

    [Setup]    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

    Attach Ue    ue_id=1
    Trigger Primary And Secondary ETWS    repetition=10
    Check ETWS broadcast    msg=test1   status=COMPLETED
    Verify Ngap Messages    packet_filter=${NGAP_WRW_REQ_WARNING_TYPE}
    Verify Ngap Messages    packet_filter=${NGAP_WRW_REQ_DATA_CODING_SCHEME}
    Verify Ngap Messages    packet_filter=${NGAP_WRW_REQ_WARNING_MESSAGE_CONTENTS}
    Verify Ngap Messages    packet_filter=${NGAP_WRW_RESP_BROADCAST_COMPLETED_AREA_LIST}
    Verify Tcpdump Log    packet_filter=${F1AP_WRW_REQ_SIB6}
    Verify Tcpdump Log    packet_filter=${F1AP_WRW_REQ_SIB7}

    [Teardown]    Run Keywords    Deregister Ue Without Confirmation   ue_id=1
        ...       AND             Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
        ...    AND    Send Configuration ID To Scout

FGCR_12238_A_9_Successful_ETWS_Primary_And_Secondary_Notification_Broadcast_PWS_Restart_Indcation
    [Tags]    CRT
    [Documentation]   Correct handling of PWS Restart Indication procedure during ETWS Primary and
    ...               Secondary Notification Broadcast.
    ...               PWS Failure Indication and PWS Restart Indication are expected after unclocking cell.

    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
        ...    AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_PWSRestIndEnabled.json

    Attach Ue    ue_id=2
    Trigger Primary And Secondary ETWS    repetition=100
    Lock Single Cell    cell_id=1      timeout=60
    Unlock Single Cell    cell_id=1      timeout=60
    Check ETWS broadcast    msg=test1   status=COMPLETED
    Verify Restart Indication On F1AP
    Verify Restart Indication On NGAP

    [Teardown]    Run Keywords    Deregister Ue Without Confirmation   ue_id=2
        ...       AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_PWSRestIndDisabled.json
        ...       AND             Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
        ...    AND    Send Configuration ID To Scout

FGCR_12238_A_7_Successful_ETWS_Primary_And_Secondary_Notification_Broadcast_Logical_Error_1
    [Tags]    CRT
    [Documentation]   Correct handling of logical error during ETWS Primary and Secondary Notification Broadcast.
    ...               Expected is only broadcast of SIB6.

    [Setup]    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

    Attach Ue    ue_id=3
    Trigger Logical Error During Primary And Secondary ETWS
    Check ETWS broadcast    msg=test2   status=COMPLETED
    Verify Tcpdump Log    packet_filter=${F1AP_WRW_REQ_SIB6}
    Verify Tcpdump Log    packet_filter=${F1AP_WRW_REQ_SIB7}    number_of_messages=0
    Verify Ngap Messages    packet_filter=${NGAP_WRW_REQ_WARNING_TYPE}
    Verify Ngap Messages    packet_filter=${NGAP_WRW_REQ_DATA_CODING_SCHEME}
    Verify Ngap Messages    packet_filter=${NGAP_WRW_REQ_WARNING_MESSAGE_CONTENTS}
    Verify Ngap Messages    packet_filter=${NGAP_WRW_REQ_NUMBER_OF_BROADCASTS}
    Verify Ngap Messages    packet_filter=${NGAP_WRW_RESP_BROADCAST_COMPLETED_AREA_LIST}

    [Teardown]    Run Keywords    Deregister Ue Without Confirmation   ue_id=3
        ...       AND             Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
        ...    AND    Send Configuration ID To Scout

*** Keywords ***
Trigger Primary And Secondary ETWS
    [Arguments]    ${repetition}=10
    Execute Egate Command And Wait For Data
    ...    cmd=cbs_broadcast_start amf=1 etws_warn_type=1 type=etws_prim_sec tai=311:489|200 warning_msg=test1 repetition=${repetition}
    ...    pass_regexp=SystemInformationBlockType6-NR updated((.|\s)*)SystemInformationBlockType7-NR updated

Trigger Logical Error During Primary And Secondary ETWS
    Execute Egate Command And Wait For Data
    ...    cmd=cbs_broadcast_start amf=1 etws_warn_type=1 type=etws_prim_sec tai=311:489|200 warning_msg=test2 repetition=indefinite
    ...    pass_regexp=SystemInformationBlockType6-NR updated

Verify Restart Indication On F1AP
    Verify Tcpdump Log    packet_filter=${F1AP_WRW_REQ_SIB6}
    Verify Tcpdump Log    packet_filter=${F1AP_WRW_REQ_SIB7}
    Verify Tcpdump Log    packet_filter=${F1AP_PWS_FAILURE_INDICATION}
    Verify Tcpdump Log    packet_filter=${F1AP_PWS_RESTART_INDICATION}
    Verify Tcpdump Log    packet_filter=${F1AP_PWS_RESTART_INDICATION_TRANSACTIONID}
    Verify Tcpdump Log    packet_filter=${F1AP_PWS_RESTART_INDICATION_CELLIDLISTFORRESTART}

Verify Restart Indication On NGAP
    Verify Ngap Messages    packet_filter=${NGAP_WRITE_REPLACE_WARNING_REQUEST}
    Verify Ngap Messages    packet_filter=${NGAP_WRITE_REPLACE_WARNING_RESPONSE}
    Verify Ngap Messages    packet_filter=${NGAP_PWS_FAILURE_INDICATION}
    Verify Ngap Messages    packet_filter=${NGAP_PWS_RESTART_INDICATION}
    Verify Ngap Messages    packet_filter=${NGAP_PWS_RESTART_INDICATION_CELLIDLISTFORRESTART}
    Verify Ngap Messages    packet_filter=${NGAP_PWS_RESTART_INDICATION_GLOBALRANNODEID}
    Verify Ngap Messages    packet_filter=${NGAP_PWS_RESTART_INDICATION_TAILISTFORRESTART}
    Verify Ngap Messages    packet_filter=${NGAP_PWS_RESTART_INDICATION_EMERGENCYAREAIDLISTFORRESTART}

Check ETWS broadcast
    [Arguments]    ${msg}   ${status}
    Sleep    5s    Wait For Action Before To Complete
    Execute Egate Command And Wait For Data
    ...    cmd=cbs_broadcast_disp amf=1
    ...    pass_regexp=${msg}${SPACE}${SPACE}${SPACE}${SPACE}GNB-2, ${status}
    ...    fail_regexp=${msg}${SPACE}${SPACE}${SPACE}${SPACE}GNB-2, FAILED
