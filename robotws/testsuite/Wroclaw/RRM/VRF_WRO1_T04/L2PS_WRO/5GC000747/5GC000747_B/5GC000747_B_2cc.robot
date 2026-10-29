*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO   VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE    CONFIGURED
...           RAN_5G_TDD    RAN_5G    SBTS00    SBTS23R1


Documentation    :copyright: Nokia
...              :author: Joachim Otto
...              :contact: joachim.otto@nokia.com

Resource     ../../resources/5G_SW_WRO_Keywords.robot
Library      ../../resources/Python/webem_alarms.py
Library      ta5g_tshark
Library      ta5g_iphy
Library      ta5g_ue_mobility
Library      ta5g_egate
Library      ta5g_file_system
Library      ta5g_enb
Library      ta5g_pm_counters
Library      ta5g_cell_operations
Library      ta5g_testline_management
Library      ta5g_delta

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
${FULL_COMMISSIONING} =    False
${RESET_TL} =    False
${DELTA_TRACKING_AREA} =    delta_trackingarea.json
${F1AP_PWS_FAILURE_INDICATION} =    f1ap.PWSFailureIndication_element
${NGAP_PWS_FAILURE_INDICATION} =    ngap.PWSFailureIndication_element
${NGAP_PWS_FAILURE_INDICATION_CELLIDLISTFORFAIL} =    ngap.NRCellIdentity == 0x0000004001 && ${NGAP_PWS_FAILURE_INDICATION}
${NGAP_PWS_FAILURE_INDICATION_CELLIDLISTFORBROADCAST} =    ngap.NRCellIdentity == 0x0000004002 && ${NGAP_WRITE_REPLACE_WARNING_RESPONSE}


*** Test Cases ***
5GC000747-B_10_PWS_Failure_Indication_2cells_Secondary_ETWS_UE_CONNECTED
    Attach Ue    ue_id=1    cell=1    enb='2'
    Attach Ue    ue_id=2    cell=2    enb='2'
    Trigger Secondary ETWS with repetitions    tac=200
    Lock Single Cell    cell_id=1      timeout=60
    Unlock Single Cell    cell_id=1      timeout=60
    Check ETWS broadcast    msg=test1   status=COMPLETED
    Verify Ngap Messages    packet_filter=${NGAP_PWS_FAILURE_INDICATION}                         number_of_messages=1
    ...                     packet_filter=${NGAP_PWS_FAILURE_INDICATION_CELLIDLISTFORFAIL}       number_of_messages=1
    Verify Tcpdump Log      packet_filter=${F1AP_PWS_FAILURE_INDICATION}                         number_of_messages=1
    Verify Ngap Messages    packet_filter=${NGAP_PWS_FAILURE_INDICATION_CELLIDLISTFORBROADCAST}  number_of_messages=1
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
        ...    M55119C02003   +1    NNGCB_PWS_FAIL_IND_SENT
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
        ...    file_path=${pm_counter_file}

5GC000747-B_12_PWS_Failure_Indication_2cells_Primary_and_Secondary_ETWS_UE_CONNECTED
    Attach Ue    ue_id=3
    Attach Ue    ue_id=4
    Trigger Secondary ETWS With Repetitions    tac=200
    Lock Single Cell    cell_id=1      timeout=60
    Trigger Primary ETWS On Second Cell Without Confirmation
    Unlock Single Cell    cell_id=1      timeout=60
    Check ETWS broadcast    msg=test2   status=REQUESTED
    Verify Ngap Messages    packet_filter=${NGAP_PWS_FAILURE_INDICATION}                         number_of_messages=1
    ...                     packet_filter=${NGAP_PWS_FAILURE_INDICATION_CELLIDLISTFORFAIL}       number_of_messages=1
    Verify Tcpdump Log      packet_filter=${F1AP_PWS_FAILURE_INDICATION}                         number_of_messages=1
    Verify Ngap Messages    packet_filter=${NGAP_PWS_FAILURE_INDICATION_CELLIDLISTFORBROADCAST}  number_of_messages=1

*** Keywords ***
Trigger Secondary ETWS With Repetitions
    [Arguments]     ${tac}
    Execute Egate Command And Wait For Data
    ...    cmd=cbs_broadcast_start amf=1 etws_warn_type=2 type=etws_sec tai=311:489|${tac} repetition=50 warning_msg=test1
    ...    pass_regexp=SystemInformationBlockType7-NR updated

Trigger Primary ETWS On Second Cell
    Execute Egate Command And Wait For Data
    ...    cmd=cbs_broadcast_start amf=1 etws_warn_type=0 type=etws_prim tai=311:489|201
    ...    pass_regexp=SystemInformationBlockType6-NR updated((.|\s)*)SystemInformationBlockType1-NR updated

Trigger Primary ETWS On Second Cell Without Confirmation
    Execute Egate Command And Wait For Data
    ...    cmd=cbs_broadcast_start amf=1 etws_warn_type=0 type=etws_prim tai=311:489|201 warning_msg=test2

Reset Testline And Wait For Rmods
    Reset Testline
    Wait For Testline Icmp Echo Replies And Ssh Services
    Check Radios Availability

Check ETWS broadcast
    [Arguments]    ${msg}   ${status}
    Sleep    5s    Wait For Action Before To Complete
    Execute Egate Command And Wait For Data
    ...    cmd=cbs_broadcast_disp amf=1
    ...    pass_regexp=${msg}${SPACE}${SPACE}${SPACE}${SPACE}GNB-2, ${status}
    ...    fail_regexp=${msg}${SPACE}${SPACE}${SPACE}${SPACE}GNB-2, FAILED
