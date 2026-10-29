*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO   VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE    CONFIGURED
...           RAN_5G_TDD    RAN_5G    SBTS00    SBTS23R1

Documentation    :copyright: Nokia
...              :authors: Kamila Białczyk
...              :contact: kamila.bialczyk@nokia.com

Variables    ta5g_global_var
Library      ta5g_tshark
Library      ../../resources/Python/webem_alarms.py
Resource     ../../resources/5G_SW_WRO_Keywords.robot

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

*** Test Cases ***
5GC000747_A_EC2_Error_Case_Handling_Cells_Not_Found_Primary_Notification_NRCGI
    [Documentation]   The test covers requirement 5G_RAN_USR_14602 for 5GC000747_A_EC2_Error_Case_Handling_Cells_Not_Found_Primary_Notification_TAI
    Trigger Primary ETWS Procedure NRCGI
    Attach Ue    ue_id=1
    Trigger Primary ETWS Procedure NRCGI
    Check ETWS broadcast    msg=test1   status=REQUESTED
    Verify Ngap Messages In Test

*** Keywords ***
Verify Ngap Messages In Test
    Verify Ngap Messages       packet_filter=${NGAP_WRITE_REPLACE_WARNING_RESPONSE}    number_of_messages=2
    Verify Tshark For No Messages    alias=${DEFAULT_NG_XN_TSHARK_ALIAS}    packet_filter=${NGAP_BROADCAST_COMPLETED_AREA_LIST}

Trigger Primary ETWS Procedure NRCGI
      Execute Egate Command    cmd=cbs_broadcast_start amf=1 type=etws_prim etws_warn_type=2 nrcgi=514:131|99 warning_msg=test1

Trigger Secondary ETWS Procedure Emergency
    Execute Egate Command    cmd=cbs_broadcast_start amf=1 type=etws_sec etws_warn_type=1 emergency_area=99 warning_msg=test2

Check ETWS broadcast
    [Arguments]    ${msg}   ${status}
    Sleep    5s    Wait For Action Before To Complete
    Execute Egate Command And Wait For Data
    ...    cmd=cbs_broadcast_disp amf=1
    ...    pass_regexp=${msg}${SPACE}${SPACE}${SPACE}${SPACE}GNB-2, ${status}
    ...    fail_regexp=${msg}${SPACE}${SPACE}${SPACE}${SPACE}GNB-2, FAILED

