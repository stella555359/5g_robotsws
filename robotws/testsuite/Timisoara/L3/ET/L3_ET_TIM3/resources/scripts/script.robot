*** Settings ***

Resource     ../5G_SW_WRO_Keywords.robot
Variables    create_aliases.py
Library      catch_signal.py
Library      ta5g_testline_management
Library      ta5g_iphy
Library      ta5g_enb
Library      ta5g_egate

*** Test Cases ***
Reset Site
    Trigger Site Reset

PDU Reset Testline
    Reset Testline

Put Iphy Xml
    Update And Put Iphy Xml    input_filepath=${SRC_IPHY_XML_PATH}    output_dirpath=${DST_UPDATED_IPHY_XML}

Get Iphy Xml
    Get Iphy Xml File    output_filepath=${DST_IPHY_XML_PATH}

Get Airphone Swconfig
    Get Iphy Swconfig File    output_filepath=${DST_AP_SWCONFIG_PATH}

Get gNB Swconfig
    Get Swconfig File    output_filepath=${DST_GNB_SWCONFIG_PATH}

Get Scf
    Get Scfc File    output_filepath=${DST_SCF_PATH}

Align nrarfcn To Scf
    Align Lua nrarfcn To Scf    lua_path=${SRC_LUA_PATH}

Start Logs
    [Teardown]    Stop Logs    ${OUTPUT_DIR}    SOS_REPORT=${SOS_REPORT}
    Start Man Logs
    Wait For Ctrl C

Start Logs And Reach Onair
    [Teardown]    Stop Logs    ${OUTPUT_DIR}    SOS_REPORT=${SOS_REPORT}
    Start Man Logs
    Man Reach Onair
    Wait For Ctrl C    msg=Onair successfull. Press Ctrl+C to stop logging.

Manual Reach Onair
    Man Reach Onair

*** Keywords ***
Start Man Logs
    Kill Wts
    Run Egate
    Start Default Logging    output_dirpath=${OUTPUT_DIR}
    Get Iphy Xml File    output_filepath=${OUTPUT_DIR}/iphy.xml
    Get Iphy Swconfig File    output_filepath=${OUTPUT_DIR}/AP_swconfig.txt
    Get Iphy TargetBd File    output_filepath=${OUTPUT_DIR}/AP_TargetBD.xml
    Get Swconfig File    output_filepath=${OUTPUT_DIR}/gNB_swconfig.txt
    Get Scfc File    output_filepath=${OUTPUT_DIR}/scfc.xml
    Get Targetbd File    output_filepath=${OUTPUT_DIR}/gNB_TargetBD.xml
    Collect Software Versions

Stop Logs
    [Arguments]    ${OUTPUT_DIR}    ${SOS_REPORT}
    Kill Wts
    Stop Default Logging    output_dirpath=${OUTPUT_DIR}
    Get Bts Snapshot    output_filepath=${OUTPUT_DIR}/bts_snapshot.zip
    Get Iphy Snapshot    output_filepath=${OUTPUT_DIR}/AP_snapshot.zip
    Run Keyword If    '${SOS_REPORT}' != 'None'    Collect Sos Report    output_dirpath=${OUTPUT_DIR}
    Copy Egate Console Log To Output Dir

Man Reach Onair
    Reach Onair    lua_cfg=${LUA_PATH}

Kill Wts
    Run Process    ${kill_wts_command}    shell=yes

Run Egate
    Run Process    ${start_egate_command}    cwd=/opt/iphy/latest    shell=yes
