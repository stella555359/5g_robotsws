*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO   VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE    CONFIGURED
...           RAN_5G_TDD    RAN_5G    SBTS00    SBTS23R1

Documentation    :copyright: Nokia
...              :author: Michał Fluder
...              :contact: Michał.Fluder@nokia.com

Resource     ../../resources/5G_SW_WRO_Keywords.robot
Library      ../../resources/Python/webem_alarms.py
Library      ta5g_tshark
Library      ta5g_pm_counters

Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
    ...                        iphy_xml_filepath=${CURDIR}/config/iphy_2AEQE.xml
    ...        AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/suite_setup_logs
    ...        AND             Find Scfc And Fix And Send Full Commissioning
    ...                        scfc_filename=full_ETWS_activated.xml
    ...        AND             Check Radios Availability
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/../../resources/egate_2c_tdd_sansa.lua
    ...        AND             Stop Default Logging     output_dirpath=${OUTPUT_DIR}/suite_setup_logs

Test Setup       Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
Test Teardown    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Suite Teardown   Run Keywords    Print Active Alarms
    ...    AND   Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${WRW_REQUEST_HAS_NO_CONCURRENT_WARNING_MESSAGE_IND_FIELD} =    ${NGAP_WRITE_REPLACE_WARNING_REQUEST} && !ngap.ConcurrentWarningMessageInd
${WRW_RESPONSE_HAS_BOTH_CELLS_ID_IN_BROADCAST_NR_FIELD} =    ${NGAP_WRITE_REPLACE_WARNING_RESPONSE} && ngap.cellIDBroadcastNR == 2

*** Test Cases ***
5GC000747_A_B1_2_Cells_Empty_Cell_List_In_WRWR_Primary_Notification
    [Documentation]   The test covers requirement 5G_RAN_USR_12946 for 5GC000747_A_B1_2_Cells_Multi_Plmn_In_WRWR_Primary_Notification

    Wait For Next Full Pm Interval
    Start Primary ETWS With Empty Cell List
    Check ETWS broadcast    msg=test1   status=REQUESTED
    Verify Tshark Messages And Check Counters

*** Keywords ***
Verify Tshark Messages And Check Counters
    Verify Tcpdump Log    packet_filter=${F1AP_WRITE_REPLACE_WARNING_REQUEST}
    Verify Ngap Messages    packet_filter=${NGAP_WRITE_REPLACE_WARNING_REQUEST}
    Verify Ngap Messages    packet_filter=${WRW_REQUEST_HAS_NO_CONCURRENT_WARNING_MESSAGE_IND_FIELD}
    Verify Ngap Messages    packet_filter=${NGAP_WRITE_REPLACE_WARNING_RESPONSE}
    Verify Ngap Messages    packet_filter=${WRW_RESPONSE_HAS_BOTH_CELLS_ID_IN_BROADCAST_NR_FIELD}
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55119C02001  +1  NNGCB_WRWR_REQ_RECD
    ...    M55119C02002  +1  NNGCB_WRWR_RESP_SENT
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
    ...    file_path=${pm_counter_file}

Start Primary ETWS With Empty Cell List
    Execute Egate Command    cmd=cbs_broadcast_start amf=1 type=etws_prim etws_warn_type=0 warning_msg=test1

Check ETWS broadcast
    [Arguments]    ${msg}   ${status}
    Sleep    5s    Wait For Action Before To Complete
    Execute Egate Command And Wait For Data
    ...    cmd=cbs_broadcast_disp amf=1
    ...    pass_regexp=${msg}${SPACE}${SPACE}${SPACE}${SPACE}GNB-2, ${status}
    ...    fail_regexp=${msg}${SPACE}${SPACE}${SPACE}${SPACE}GNB-2, FAILED
