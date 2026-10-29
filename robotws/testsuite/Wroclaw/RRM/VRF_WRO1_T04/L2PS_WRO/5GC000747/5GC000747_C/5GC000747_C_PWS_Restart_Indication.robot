*** Settings ***
Force Tags    CLOUD_5G_I_MP_AP_LO   VARIANT_SANSA_FS_ECPRI_CMWV_TDD    CONFIGURED
...           RAN_5G_TDD    RAN_5G    SBTS00    SBTS23R1

Documentation    :copyright: Nokia
...              :authors: Katarzyna Wisniewska
...              :contact: katarzyna.wisniewska@nokia.com

Resource     ../../resources/5G_SW_WRO_Keywords.robot

Variables    ta5g_global_var
Library      ../../resources/Python/webem_alarms.py
Library      ta5g_tshark
Library      ta5g_pm_counters
Library      ta5g_cell_operations
Resource     ../../resources/configuration_id.robot

Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
    ...                        iphy_xml_filepath=${CURDIR}/config/iphy_2AEQE.xml
    ...        AND             Find Scfc And Fix And Send Full Commissioning
    ...                        scfc_filename=full_ETWS_activated.xml
    ...        AND             Check Radios Availability
    ...        AND             Start Vm Ethernet Interface    if_name=eth3:ng    ip_with_mask=10.0.1.112/24
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/../../resources/egate_2c_tdd_sansa.lua
    ...        AND             Start Default Logging
    ...        AND             Set Counter Collecting Interval To Five Minutes
    ...        AND             Wait For Next Full Pm Interval
    ...        AND             Attach Ue    ue_id=1
    ...        AND             Trigger Secondary ETWS

Suite Teardown   Run Keywords    Print Active Alarms
    ...    AND   Stop Default Processes And Gather Logs And Compress Logs

*** Test Cases ***
5GC000747_C_3_PWS_Restart_Indication_With_Secondary_ETWS_Ongoing
    [Tags]    CRT
    [Documentation]   Correct handling of PWS Restart Indication procedure with ETWS ongoing.

    Lock Single Cell    cell_id=1      timeout=60
    Unlock Single Cell    cell_id=1      timeout=60
    Verify Ngap Messages    packet_filter=${NGAP_PWS_RESTART_INDICATION}
    Check ETWS broadcast    msg=test1   status=COMPLETED
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
        ...    M55119C02006    +1    NNGCB_PWS_REST_IND_SENT
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
        ...    file_path=${pm_counter_file}
    [Teardown]    Send Configuration ID To Scout

*** Keywords ***
Trigger Secondary ETWS
    Execute Egate Command
    ...    cmd=cbs_broadcast_start amf=1 etws_warn_type=1 type=etws_sec tai=311:489|200 warning_msg=test1 repetition=30

Check ETWS broadcast
    [Arguments]    ${msg}   ${status}
    Sleep    5s    Wait For Action Before To Complete
    Execute Egate Command And Wait For Data
    ...    cmd=cbs_broadcast_disp amf=1
    ...    pass_regexp=${msg}${SPACE}${SPACE}${SPACE}${SPACE}GNB-2, ${status}
    ...    fail_regexp=${msg}${SPACE}${SPACE}${SPACE}${SPACE}GNB-2, FAILED
