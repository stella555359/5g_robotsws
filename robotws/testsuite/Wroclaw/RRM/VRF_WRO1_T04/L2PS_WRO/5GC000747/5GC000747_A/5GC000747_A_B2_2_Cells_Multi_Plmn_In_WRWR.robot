*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO   VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE    CONFIGURED
...           RAN_5G_TDD    RAN_5G    SBTS00    SBTS23R1

Documentation    :copyright: Nokia
...              :authors: Joachim Otto
...              :contact: joachim.otto@nokia.com


Resource     ../../resources/5G_SW_WRO_Keywords.robot
Resource     5GC000747_A_Keywords.robot
Variables    ta5g_global_var
Library      ../../resources/Python/webem_alarms.py
Library      ta5g_enb
Library      ta5g_tshark
Library      ta5g_iphy
Library      ta5g_testline_management

Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
    ...                        iphy_xml_filepath=${CURDIR}/config/iphy_2AEQE.xml
    ...        AND             Start Default Logging
    ...        AND             Find Scfc And Fix And Send Full Commissioning
    ...                        scfc_filename=full_scf_multi_PLMN_multi_AMF.xml
    ...        AND             Check Radios Availability
    ...        AND             Start Vm Ethernet Interface    if_name=eth3:ng    ip_with_mask=10.0.1.112/24
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_2c_tdd_sansa.lua

Suite Teardown   Run Keywords    Print Active Alarms
    ...    AND   Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${NGAP_WRITE_REPLACE_WARNING_RESPONSE_INCLUDING_BOTH_PLMNS} =    ngap.WriteReplaceWarningResponse_element &&
...                         ngap.tAIBroadcastNR == 2 && ngap.pLMNIdentity == 13:41:98 && ngap.pLMNIdentity == 45:f0:10

*** Test Cases ***
5GC000747_A_B2_2_Cells_Multi_Plmn_In_WRWR_Secondary_Notification
    [Documentation]   Correct handling of secondary ETWS notification procedure with multi plmn configuration.
    ...               The test covers requirement 5G_RAN_USR_14598 for 5GC000747_A_B2_2_Cells_Empty_Cell_List_In_WRWR_Secondary_Notification

    Trigger Secondary ETWS Multi Plmn
    Check ETWS broadcast    msg=test1   status=COMPLETED
    Verify Ngap Messages    packet_filter=${NGAP_WRITE_REPLACE_WARNING_RESPONSE_INCLUDING_BOTH_PLMNS}

*** Keywords ***

Trigger Secondary ETWS Multi Plmn
    Execute Egate Command
    ...    cmd=cbs_broadcast_start amf=1 etws_warn_type=1 type=etws_sec tai=311:489|200,540:01|210 warning_msg=test1

Check ETWS broadcast
    [Arguments]    ${msg}   ${status}
    Sleep    5s    Wait For Action Before To Complete
    Execute Egate Command And Wait For Data
    ...    cmd=cbs_broadcast_disp amf=1
    ...    pass_regexp=${msg}${SPACE}${SPACE}${SPACE}${SPACE}GNB-2, ${status}
    ...    fail_regexp=${msg}${SPACE}${SPACE}${SPACE}${SPACE}GNB-2, FAILED
