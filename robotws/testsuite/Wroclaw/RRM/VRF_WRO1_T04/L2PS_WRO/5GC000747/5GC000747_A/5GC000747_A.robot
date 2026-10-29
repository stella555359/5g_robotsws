*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO   VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE    CONFIGURED
...           RAN_5G_TDD    RAN_5G    SBTS00    SBTS23R1

Documentation    :copyright: Nokia
...              :author: Pawel Gniewek, Joachim Otto
...              :contact: pawel.gniewek@nokia.com, joachim.otto@nokia.com

Resource     ../../resources/5G_SW_WRO_Keywords.robot
Library      ../../resources/Python/webem_alarms.py
Library      ta5g_tshark
Library      ta5g_ue_mobility
Library      ta5g_egate
Library      ta5g_file_system
Library      ta5g_enb
Library      ta5g_pm_counters

Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
    ...                        iphy_xml_filepath=${CURDIR}/config/iphy_2AEQE.xml
    ...        AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/suite_setup_logs
    ...        AND             Find Scfc And Fix And Send Full Commissioning
    ...                        scfc_filename=full_ETWS_activated.xml
    ...        AND             Check Radios Availability
    ...        AND             Set Counter Collecting Interval To Five Minutes
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/../../resources/egate_2c_tdd_sansa.lua
    ...        AND             Stop Default Logging     output_dirpath=${OUTPUT_DIR}/suite_setup_logs

Test Setup       Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Test Teardown    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Suite Teardown   Run Keywords    Print Active Alarms
    ...    AND   Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${NGAP_NUMBER_OF_BROADCASTS_REQUESTED_EQUALS_FIVE}=    ngap.NumberOfBroadcastsRequested == 5
${F1AP_NUMBER_OF_BROADCASTS_REQUESTED_EQUALS_FIVE}=    f1ap.NumberofBroadcastRequest == 5

*** Test Cases ***
5GC000747_A_B1_Successful_ETWS_Primary_Notification_Broadcast
    [Tags]    CIT     CDRT
    [Documentation]   Correct handling of primary ETWS notification procedure.

    Trigger Primary ETWS
    Attach Ue    ue_id=1
    Trigger Primary ETWS
    Verify Ngap Messages    packet_filter=${NGAP_WRITE_REPLACE_WARNING_REQUEST}     number_of_messages=2
    Verify Ngap Messages    packet_filter=${NGAP_WRITE_REPLACE_WARNING_RESPONSE}    number_of_messages=2
    Verify Ngap Messages    packet_filter=${NGAP_WRITE_REPLACE_WARNING_RESPONSE_BROADCAST_LIST_IE}  number_of_messages=2
    Check ETWS broadcast    msg=test1   status=COMPLETED
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
        ...    M55119C02001    +2    NNGCB_WRWR_REQ_RECD
        ...    M55119C02002    +2    NNGCB_WRWR_RESP_SENT
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
        ...    file_path=${pm_counter_file}

5GC000747_A_EC4_Error_Case_Handling_Special_Values_Handling_For_ETWS_Secondary_Notification_1
    [Tags]    CRT
    Trigger ETWS Secondary Notification
    Attach Ue    ue_id=2
    Trigger ETWS Secondary Notification
    Verify Ngap Messages    packet_filter=${NGAP_WRITE_REPLACE_WARNING_RESPONSE}     number_of_messages=2
    Verify Tcpdump Log    packet_filter=${F1AP_WRITE_REPLACE_WARNING_REQUEST}    number_of_messages=0
    Verify Ngap Messages    packet_filter=${NGAP_BROADCAST_COMPLETED_AREA_LIST}     number_of_messages=0
    Check ETWS broadcast    msg=test3   status=REQUESTED

5GC000747_A_B2_Controlled_ETWS_Broadcast_Repetitions
    [Tags]    CRT
    Trigger ETWS Secondary Notification With Five Repetitions
    Attach Ue    ue_id=3
    Trigger ETWS Secondary Notification With Five Repetitions
    Verify Ngap Messages    packet_filter=${NGAP_NUMBER_OF_BROADCASTS_REQUESTED_EQUALS_FIVE}     number_of_messages=2
    Verify Tcpdump Log    packet_filter=${F1AP_NUMBER_OF_BROADCASTS_REQUESTED_EQUALS_FIVE}    number_of_messages=2
    Check ETWS broadcast    msg=test6   status=COMPLETED

5GC000747_A_B2_Successful_ETWS_Secondary_Notification_Broadcast
    [Tags]    CRT
    [Documentation]   Correct handling of secondary ETWS notification procedure.

    Trigger Secondary ETWS
    Attach Ue    ue_id=4
    Trigger Secondary ETWS
    Verify Ngap Messages    packet_filter=${NGAP_WRITE_REPLACE_WARNING_REQUEST}     number_of_messages=2
    Verify Ngap Messages    packet_filter=${NGAP_WRITE_REPLACE_WARNING_RESPONSE}    number_of_messages=2
    Verify Ngap Messages    packet_filter=${NGAP_WRITE_REPLACE_WARNING_RESPONSE_BROADCAST_LIST_IE}  number_of_messages=2
    Check ETWS broadcast    msg=test2   status=COMPLETED

5GC000747_A_B4_Feature_Online_Deactivated_While_ETWS_Notification_Broadcast_Procedure
    [Tags]    CRT
    Trigger ETWS Secondary Notification Without Repetitions
    Attach Ue    ue_id=6
    Trigger ETWS Secondary Notification Without Repetitions
    Perform Parameter Commissioning    parameter=actETWS    value=false
    Trigger ETWS Secondary Notification Without Repetitions
    Verify Ngap Messages     packet_filter=${NGAP_WRITE_REPLACE_WARNING_RESPONSE}    number_of_messages=2
    Verify Ngap Messages     packet_filter=${NGAP_ERROR_INDICATION}    number_of_messages=1
    Check ETWS broadcast    msg=test4   status=REQUESTED

*** Keywords ***
Trigger Primary ETWS
    Execute Egate Command And Wait For Data
    ...    cmd=cbs_broadcast_start amf=1 etws_warn_type=0 type=etws_prim tai=311:489|200 warning_msg=test1
    ...    pass_regexp=SystemInformationBlockType6-NR updated

Trigger Secondary ETWS
    Execute Egate Command And Wait For Data
    ...    cmd=cbs_broadcast_start amf=1 etws_warn_type=1 type=etws_sec tai=311:489|200 warning_msg=test2
    ...    pass_regexp=SystemInformationBlockType7-NR updated

Trigger ETWS Secondary Notification
    Execute Egate Command    cmd=cbs_broadcast_start amf=1 etws_warn_type=1 type=etws_sec tai=311:489|200 warning_msg=test3 repetition=indefinite

Trigger ETWS Secondary Notification Without Repetitions
    Sleep    5s    Wait For Action Before To Complete
    Execute Egate Command    cmd=cbs_broadcast_start amf=1 etws_warn_type=1 type=etws_sec tai=311:489|200 warning_msg=test4
    Sleep    10s    Wait For ETWS Repetitions

Trigger ETWS Primary Notification Without Repetitions
    Execute Egate Command    cmd=cbs_broadcast_start amf=1 type=etws_prim etws_warn_type=2 nrcgi=311:489|200 warning_msg=test5

Trigger ETWS Secondary Notification With Five Repetitions
    Sleep    5s    Wait For Action Before To Complete
    Execute Egate Command    cmd=cbs_broadcast_start amf=1 etws_warn_type=1 type=etws_sec tai=311:489|200 warning_msg=test6 repetition=5
    Sleep    10s    Wait For ETWS Repetitions

Check ETWS broadcast
    [Arguments]    ${msg}   ${status}
    Sleep    5s    Wait For Action Before To Complete
    Execute Egate Command And Wait For Data
    ...    cmd=cbs_broadcast_disp amf=1
    ...    pass_regexp=${msg}${SPACE}${SPACE}${SPACE}${SPACE}GNB-2, ${status}
    ...    fail_regexp=${msg}${SPACE}${SPACE}${SPACE}${SPACE}GNB-2, FAILED
