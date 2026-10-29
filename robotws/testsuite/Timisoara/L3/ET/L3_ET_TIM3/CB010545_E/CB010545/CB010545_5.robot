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
5_CB010545-E_ROBUSTNESS_Verify_WebEM_Remote_Commands_Fails_When_Wrong_Cell_ID_is_Requested_getCellById
    [Documentation]    This test case validates error returned by command getCellById
    ...                5G_RAN_USR_COM_2141
    ...                5G_RAN_USR_COM_20990

    Log to console     Test part

    Send getCellById Command and expect error 70    MRBTS-1/NRBTS-1/NRCELL-3

