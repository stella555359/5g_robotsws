*** Settings ***
Force Tags    CLOUD_5G_I_MP_AP_LO   VARIANT_SANSA_FS_ECPRI_CMWV_TDD    CONFIGURED
...           RAN_5G_TDD    RAN_5G    SBTS00    SBTS23R1

Documentation    :copyright: Nokia
...              :authors: Mateusz Wolowicz
...              :contact: mateusz.wolowicz@nokia.com

Resource     ../../resources/5G_SW_WRO_Keywords.robot
Variables    ta5g_global_var
Variables    config/variables.py
Library      ../../resources/Python/webem_alarms.py
Library      ta5g_enb
Library      ta5g_tshark
Library      ta5g_iphy
Library      ta5g_testline_management


Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/suite_setup_logs
    ...        AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_ETWS_activation.json
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/../../resources/egate_2c_tdd_sansa.lua
    ...        AND             Stop Default Logging     output_dirpath=${OUTPUT_DIR}/suite_setup_logs

Test Setup        Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Test Teardown     Run Keywords    Deregister Ue    ue_id=1
    ...           AND             Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Suite Teardown    Run Keywords    Find Scfc And Send Delta Commissioning    scfc_filename=delta_ETWS_deactivation.json
    ...           AND             Print Active Alarms
    ...           AND             Stop Default Processes And Gather Logs And Compress Logs

*** Test Cases ***
5GC000747_A_B3_Successful_ETWS_Notification_Broadcast_Replace_Primary_Notification
    Trigger Primary ETWS
    Attach Ue    ue_id=1
    Trigger Primary ETWS
    Verify Number Of Write Replace Warning Messages In NGAP And F1AP
    Check ETWS broadcast    msg=test1   status=COMPLETED
    Verify Existance Of Write Replace Warning Messages With Certain Serial Number

*** Keywords ***
Trigger Secondary ETWS
    Execute Egate Command
    ...    cmd=cbs_broadcast_start amf=1 etws_warn_type=1 type=etws_sec tai=311:489|200 warning_msg=test2 repetition=50
    Execute Egate Command And Wait For Data
    ...    cmd=cbs_broadcast_start amf=1 etws_warn_type=1 type=etws_sec tai=311:489|200 warning_msg=test2 repetition=5
    ...    timeout=3min
    ...    pass_regexp=SystemInformationBlockType7-NR updated

Trigger Primary ETWS
    Execute Egate Command
    ...    cmd=cbs_broadcast_start amf=1 type=etws_prim message_identifier=4352 etws_warn_type=0 tai=311:489|200 warning_msg=test1
    Execute Egate Command And Wait For Data
    ...    cmd=cbs_broadcast_start amf=1 type=etws_prim message_identifier=4352 etws_warn_type=0 tai=311:489|200 warning_msg=test1
    ...    timeout=3min
    ...    pass_regexp=SystemInformationBlockType6-NR updated

Verify Number Of Write Replace Warning Messages In NGAP And F1AP
    Verify Ngap Messages    packet_filter=${NGAP_WRITE_REPLACE_WARNING_REQUEST}   number_of_messages=4
    Verify Ngap Messages    packet_filter=${NGAP_WRITE_REPLACE_WARNING_RESPONSE}   number_of_messages=4
    Verify Tcpdump Log      packet_filter=${F1AP_WRITE_REPLACE_WARNING_REQUEST}    number_of_messages=4
    Verify Tcpdump Log      packet_filter=${F1AP_WRITE_REPLACE_WARNING_RESPONSE}    number_of_messages=4

Verify Existance Of Write Replace Warning Messages With Certain Serial Number
    [Documentation]    WRITE_REPLACE_WARNING_MESSAGE_SERIALS is a list type variable
    ...                to hold all available serial numbers found in WRW Requests.
    ...                Used for NGAP/TCPDUMP messages verification
    @{WRITE_REPLACE_WARNING_MESSAGE_SERIALS}=    Get Attribute Values From Tshark Messages    alias=${DEFAULT_NG_XN_TSHARK_ALIAS}
    ...    filter=${NGAP_WRITE_REPLACE_WARNING_REQUEST}   output_pdml_filepath=${OUTPUT_DIR}/${TEST_NAME}/serial.pdml
    ...    element_xpath=${xpath}     attribute_xpath=.    attribute=show
    FOR    ${serial}    IN    @{WRITE_REPLACE_WARNING_MESSAGE_SERIALS}
        Verify Ngap Messages    packet_filter=${NGAP_WRITE_REPLACE_WARNING_REQUEST} && ngap.SerialNumber == ${serial}
        Verify Ngap Messages    packet_filter=${NGAP_WRITE_REPLACE_WARNING_RESPONSE} && ngap.SerialNumber == ${serial}
        Verify Tcpdump Log    packet_filter=nr-rrc.serialNumber == ${serial}
    END

Check ETWS broadcast
    [Arguments]    ${msg}   ${status}
    Sleep    5s    Wait For Action Before To Complete
    Execute Egate Command And Wait For Data
    ...    cmd=cbs_broadcast_disp amf=1
    ...    pass_regexp=${msg}${SPACE}${SPACE}${SPACE}${SPACE}GNB-2, ${status}
    ...    fail_regexp=${msg}${SPACE}${SPACE}${SPACE}${SPACE}GNB-2, FAILED
