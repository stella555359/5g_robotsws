*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO   VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE    CONFIGURED
...           RAN_5G_TDD    RAN_5G    SBTS00    SBTS23R1

Documentation    :copyright: Nokia
...              :authors: Joachim Otto
...              :contact: joachim.otto@nokia.com

Resource     ../../resources/5G_SW_WRO_Keywords.robot
Library      ../../resources/Python/webem_alarms.py
Library      ta5g_tshark
Library      ta5g_iphy
Library      ta5g_ue_mobility
Library      ta5g_file_system
Library      ta5g_enb
Library      ta5g_cell_operations
Library      ta5g_testline_management


Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
    ...                        iphy_xml_filepath=${CURDIR}/config/iphy_2AEQE.xml
    ...        AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/suite_setup_logs
    ...        AND             Wait For Testline Icmp Echo Replies And Ssh Services
    ...        AND             Find Scfc And Fix And Send Full Commissioning
    ...                        scfc_filename=full_scf_multi_PLMN_multi_AMF.xml
    ...        AND             Check Radios Availability
    ...        AND             Start Vm Ethernet Interface    if_name=eth3:ng    ip_with_mask=10.0.1.112/24
    ...        AND             Set Counter Collecting Interval To Five Minutes
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_2c_tdd_sansa_2tacs.lua
    ...                            align_tac_values=False
    ...        AND             Wait Until Keyword Succeeds     300      10     Check If Both AMF Have NG Link Connection
    ...        AND             Attach Ue    ue_id=1
    ...        AND             Stop Default Logging     output_dirpath=${OUTPUT_DIR}/suite_setup_logs

Test Setup        Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
Test Teardown     Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Suite Teardown    Run Keywords    Print Active Alarms
    ...           AND             Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${F1AP_PWS_FAILURE_INDICATION} =    f1ap.PWSFailureIndication_element
${NGAP_PWS_FAILURE_INDICATION} =    ngap.PWSFailureIndication_element
${NGAP_PWS_FAILURE_INDICATION_CELLIDLISTFORFAIL} =    ngap.NRCellIdentity == 0x0000004001 && ${NGAP_PWS_FAILURE_INDICATION}
${NGAP_PWS_FAILURE_INDICATION_CELLIDLISTFORBROADCAST} =    ngap.NRCellIdentity == 0x0000004002 && ${NGAP_WRITE_REPLACE_WARNING_RESPONSE}
${AMF1_IS_UP} =    (.*AMF-1: AMF - IP:10.0.1.2 NG link is Up)
${AMF2_IS_UP} =    (.*AMF-2: AMF - IP:10.0.1.2 NG link is Up)

*** Test Cases ***
5GC000747-B_9_PWS_Failure_Indication_2cells_Multi_Plmn_Secondary_ETWS_UE_CONNECTED
    [Documentation]   The test covers requirement 5G_RAN_USR_14542 for the 5GC000747-B_4_PWS_Failure_Indication_1cell_Secondary_ETWS_UE_CONNECTED
    Trigger Secondary ETWS Multi Plmn
    Lock Single Cell    cell_id=1      timeout=60
    Unlock Single Cell    cell_id=1      timeout=60
    Check ETWS broadcast    msg=test1   status=COMPLETED
    Verify Ngap Messages    packet_filter=${NGAP_PWS_FAILURE_INDICATION}
    ...                     packet_filter=${NGAP_PWS_FAILURE_INDICATION_CELLIDLISTFORFAIL}      number_of_messages=2
    Verify Tcpdump Log      packet_filter=${F1AP_PWS_FAILURE_INDICATION}
    Verify Ngap Messages    packet_filter=${NGAP_PWS_FAILURE_INDICATION_CELLIDLISTFORBROADCAST}

*** Keywords ***
Trigger Secondary ETWS Multi Plmn
    Execute Egate Command
    ...    cmd=cbs_broadcast_start amf=1 etws_warn_type=1 type=etws_sec tai=311:489|200,540:01|210 warning_msg=test1 repetition=50


Check If Both AMF Have NG Link Connection
    Verify Egate Content    expected_pattern=${AMF1_IS_UP}
    Verify Egate Content    expected_pattern=${AMF2_IS_UP}


Add Multi Plmn And Multi Amf By Sending Delta Comissioning
    [Arguments]     ${scfc_filename}
    Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1/SNSSAI-1    parameter=administrativeState    value=Locked
    Find Scfc And Send Delta Commissioning    scfc_filename=${scfc_filename}
    Reset Testline
    Check Radios Availability
    Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1/SNSSAI-1    parameter=administrativeState    value=Unlocked

Check ETWS broadcast
    [Arguments]    ${msg}   ${status}
    Sleep    5s    Wait For Action Before To Complete
    Execute Egate Command And Wait For Data
    ...    cmd=cbs_broadcast_disp amf=1
    ...    pass_regexp=${msg}${SPACE}${SPACE}${SPACE}${SPACE}GNB-2, ${status}
    ...    fail_regexp=${msg}${SPACE}${SPACE}${SPACE}${SPACE}GNB-2, FAILED
