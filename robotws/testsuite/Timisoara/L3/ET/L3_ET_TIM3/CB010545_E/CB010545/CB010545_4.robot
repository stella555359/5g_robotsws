*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CONFIGURED    RAN_5G_TDD    RAN_5G    PY36    PY39_ready
...           CRT    SBTS00    NoResUsage

Documentation    :copyright: Nokia
...              :authors: Radu Turcu
...              :contact: radu.turcu@nokia.com

Resource    ../CB010545_Keywords.robot

Suite Setup    Run Keywords    log to console     Suite Setup Keywords
...            AND             Start Vm Ethernet Interfaces
...            AND             Find Scfc And Send Delta Commissioning  scfc_filename=delta_enable_CB010545.json
...            AND             Reach Onair    lua_cfg=/opt/iphy/latest/basic_setup.cfg      check_edaemon_port=True

#Suite Teardown    Run Keywords      log to console     Suite Tear Down Keywords
#...            AND         Stop Default Processes And Gather Logs And Compress Logs
#...            AND         Stop Vm Ethernet Interfaces
#...            AND         Find Scfc And Send Delta Commissioning  scfc_filename=delta_disable_CB010545.json


#Test Setup       Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
#Test Teardown    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}


*** Test Cases ***
4_CB010545-E_ROBUSTNESS_Verify_WebEM_Remote_Commands_ getCellList
    [Documentation]    This test case validates active UE object returned by command getCellList and counter M55181C00007
    ...                 when multipe UEs are connected
    ...                5G_RAN_USR_COM_2141
    ...                5G_RAN_USR_COM_20990

    Log to console     Test part

    Set PDU Param Internal Traffic    ue_id=1
    Attach Ue And Establish PDU Session   ue_id=1    gw_id=1
    Start Data Traffic    ues=1    direction=both    pdu=1    throughput=10kbps

    Sleep   5

    Set PDU Param Internal Traffic    ue_id=2
    Attach Ue And Establish PDU Session   ue_id=2    gw_id=2
    Start Data Traffic    ues=2    direction=both    pdu=2    throughput=10kbps

    Sleep   5

    Wait For Next Full Pm Interval
    Wait For Next Full Pm Interval
#
#    ${pm_counter_file}=    Get Latest Unpacked Raw Pm Counters File
#
    Sleep     5
#
#    Verify Any Counters In File
#    ...    M55181C00007    +1    ActiveUeValue
#    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
#    ...    file_path=${pm_counter_file}
#
#    Sleep   5
#
    Send getCellList Command and check active UEs from each cell        total_ues=2
    Sleep   5
    Deregister Ue Without Confirmation    ue_id=1
    Sleep   5
    Deregister Ue Without Confirmation    ue_id=2

    Wait For Next Full Pm Interval
#    Wait For Next Full Pm Interval
#
#    ${pm_counter_file}=    Get Latest Unpacked Raw Pm Counters File
#
#    Verify Any Counters In File
#    ...    M55181C00007    +0    ActiveUeValue
#    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
#    ...    file_path=${pm_counter_file}
#
    Send getCellList Command and check active UEs from each cell        total_ues=0

