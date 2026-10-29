*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CONFIGURED    RAN_5G_TDD    RAN_5G    PY36    PY39_ready
...           CRT    SBTS00    NoResUsage

Documentation    :copyright: Nokia
...              :authors: Alexandru Goman
...              :contact: alexandru.goman@nokia.com

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
2_CB010545-E_Verify_WebEM_Remote_Commands_getBTSInformation
    [Documentation]    This test case validates active UE object returned by command getBTSInformation
    ...                5G_RAN_USR_COM_2141
    ...                5G_RAN_USR_COM_20990

    Log to console     Test part

    Set PDU Param Internal Traffic    ue_id=1
    Attach Ue And Establish PDU Session   ue_id=1    gw_id=1
    Start Data Traffic    ues=1    direction=both    pdu=1    throughput=10kbps

    Sleep   5

    Wait For Next Full Pm Interval
    Wait For Next Full Pm Interval

    Sleep   10

    Send getBtsInfo Command and extract active UEs counter from each cell        total_ues=1

    Deregister Ue Without Confirmation    ue_id=1

    Wait For Next Full Pm Interval

    Send getBtsInfo Command and extract active UEs counter from each cell        total_ues=0

