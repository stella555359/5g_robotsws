*** Settings ***
Documentation       copyright:nokia

*** Keywords ***

Recover Config Files To Testline
    [Documentation]    This keyword is used to send 6 config files to GNB and Airphone.
    [Arguments]    ${config_path}
    ${gnb_scf}    ${gnb_swconfig}    ${iphy}    ${ap_swconfig}    ${lua_cfg}    ${ap_config}=    Get Config File Path From Folder    ${config_path}
    Send Swconfig for GNB    ${gnb_swconfig}
    Send Swconfig for AP    ${ap_swconfig}
    Send IPHY XML for AP    ${iphy}
    Copy Lua Cfg And Airphone Xml To WTS Directory    ${lua_cfg}    ${ap_config}
    #Send SCFC for GNB    ${gnb_scf}
    Full Commission With SCF File    ${gnb_scf}

Recover Config Files To Testline 2
    [Documentation]    This keyword is used to send 6 config files to GNB and Airphone.
    [Arguments]    ${gnb_scf}    ${gnb_swconfig}    ${iphy}    ${ap_swconfig}    ${lua_cfg}    ${ap_config}
    Send Swconfig for GNB    ${gnb_swconfig}
    Send Swconfig for AP    ${ap_swconfig}
    Send IPHY XML for AP    ${iphy}
    Copy Lua Cfg And Airphone Xml To WTS Directory    ${lua_cfg}    ${ap_config}
    #Send SCFC for GNB    ${gnb_scf}
    Full Commission With SCF File    ${gnb_scf}

Get Config File Path From Folder
    [Arguments]    ${config_path}
    ${rc}	${gnb_scf}=    OperatingSystem.Run And Return Rc And Output    ls ${config_path}/SCF_1.xml
    ${rc}	${gnb_swconfig}=    OperatingSystem.Run And Return Rc And Output    ls ${config_path}/swconfig_enb.txt
    ${rc}	${iphy}=    OperatingSystem.Run And Return Rc And Output    ls ${config_path}/iphy.xml
    ${rc}	${ap_swconfig}=    OperatingSystem.Run And Return Rc And Output    ls ${config_path}/swconfig_ap.txt
    ${rc}	${lua_cfg}=    OperatingSystem.Run And Return Rc And Output    ls ${config_path}/basic_*.cfg
    ${rc}	${ap_config}=    OperatingSystem.Run And Return Rc And Output    ls ${config_path}/AirPhoneConfig_*.xml
    [Return]    ${gnb_scf}    ${gnb_swconfig}    ${iphy}    ${ap_swconfig}    ${lua_cfg}    ${ap_config}

Copy Lua Cfg And Airphone Xml To QT Directory
    [Arguments]    ${lua_cfg}    ${ap_config}    ${log_path}
    [Documentation]    This keyword is used to copy QT config files to QT directory.
    ${cfg_path_qt}    ${xml_path_qt}    ${QT_Folder}=    Get AirPhone QT File By SCF    ${log_path}
    ${rc}	${output}=    OperatingSystem.Run And Return Rc And Output    cp ${lua_cfg} ${QT_Folder}
    ${rc}	${output}=    OperatingSystem.Run And Return Rc And Output    cp ${ap_config} ${QT_Folder}

Copy Lua Cfg And Airphone Xml To WTS Directory
    [Arguments]    ${lua_cfg}    ${ap_config}
    [Documentation]    This keyword is used to copy QT config files to WTS directory.
    ${rc}	${output}=    OperatingSystem.Run And Return Rc And Output    cp ${lua_cfg} ${WTS_DIR}
    ${rc}	${output}=    OperatingSystem.Run And Return Rc And Output    cp ${ap_config} ${WTS_DIR}

Send SCFC for GNB
    [Arguments]    ${gnb_scfc}
    [Documentation]    This keyword is used to send SCF.xml to GNB.
    ...    | Input Parameters | Man. | Description |
    ...    | ${gnb_scfc} | Yes | gnb_swconfig.txt with absolute path |
    ...
    ...    Examples:
    ...    | Send SCFC for GNB | ${CURDIR}/config_files/gnb_scfc.xml |
    COAM.Setup Admin
    COAM.Perform Commissioning
    ...    bts_id=1
    ...    scf_file=${gnb_scfc}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=300
    COAM.Teardown

Send Swconfig for GNB
    [Arguments]    ${gnb_swconfig}
    [Documentation]    This keyword is used to put swconfig.txt to GNB.
    ...    | Input Parameters | Man. | Description |
    ...    | ${gnb_swconfig} | Yes | gnb_swconfig.txt with absolute path |
    ...
    ...    Examples:
    ...    | Send Swconfig for GNB | ${CURDIR}/config_files/gnb_swconfig.txt |
    ute_fsmaccess.Setup Enb Fsm Access
    ute_fsmaccess.Put Enb Swconfig File    ${gnb_swconfig}    partition=active
    ute_fsmaccess.Execute Command On Enb    crasign /ffs/run/swconfig.txt
    ute_fsmaccess.Teardown Enb Fsm Access

Send Swconfig for AP
    [Arguments]    ${ap_swconfig}
    [Documentation]    This keyword is used to put swconfig.txt to Airphone.
    ...    | Input Parameters | Man. | Description |
    ...    | ${ap_swconfig} | Yes | ap_swconfig.txt with absolute path |
    ...
    ...    Examples:
    ...    | Send Swconfig for AP | ${CURDIR}/config_files/ap_swconfig.txt |
    ute_fsmaccess.Setup Wts Fsm Access
    ute_fsmaccess.Put Wts File    ${ap_swconfig}    /ffs/run/swconfig.txt    partition=active
    ute_fsmaccess.Execute Command On Wts    crasign /ffs/run/swconfig.txt
    ute_fsmaccess.Teardown Wts Fsm Access

Send IPHY XML for AP
    [Arguments]    ${ap_iphy}
    [Documentation]    This keyword is used to put iphy.xml to Airphone.
    ...    | Input Parameters | Man. | Description |
    ...    | ${ap_iphy} | Yes | iphy.xml with absolute path |
    ...
    ...    Examples:
    ...    | Send IPHY XML for AP | ${CURDIR}/config_files/iphy.xml |
    ute_fsmaccess.Setup Wts Fsm Access
    ute_fsmaccess.Put Wts File    ${ap_iphy}    /ffs/run/simmode/new_iphy.xml
    ute_fsmaccess.Teardown Wts Fsm Access

Get Current Testline Config Files
    [Arguments]    ${log_path}=${SUITE_LOG_DIRECTORY}/mylogs/
    [Documentation]    This keyword is used to collect 6 config files to a directory.
    ...    | Input Parameters | Man. | Description |
    ...    | ${log_path} | No | local directory |
    ...
    ...    Examples:
    ...    | Get Current Testline Config Files | |
    ...    | Get Current Testline Config Files | ${OUTPUT_DIR}/mylogs/ |
    OperatingSystem.Run And Return Rc And Output    mkdir -p ${log_path}
    Get TargetDB File    ${log_path}
    Get GNB SCF File    ${log_path}
    Get GNB Swconfig File    ${log_path}
    Get IPHY XML File And Swconfig File    ${log_path}
    Get AirPhoneConfig And Lua Cfg File 2    ${log_path}
    [Return]    ${log_path}

Get AirPhone QT File By SCF
    [Arguments]    ${log_path}
    ${CELLTECHNOLOGY}=    Get Single Value From Scf File    ${log_path}/SCF_1.xml    MRBTS-1/NRBTS-1/NRCELL-1    cellTechnology
    Set Suite Variable    ${CELLTECHNOLOGY}
    Get Software Version
    ${folder_name}=    Get QT Folder Name By Testline Type
    ${QT_Folder}=    Set Variable    ${WTS_CONFIG_PATH}/${folder_name}/${SW_VERSION}/
    ${cfg_path}    ${xml_path}=    Get Airphone QT File Absolute Path    ${folder_name}
    [Return]    ${cfg_path}    ${xml_path}    ${QT_Folder}

Get GNB SCF File
    [Arguments]    ${log_path}
    [Documentation]    This keyword is used to collect SCF file from GNB.
    ...    | Input Parameters | Man. | Description |
    ...    | ${log_path} | Yes | local directory |
    ...
    ...    Examples:
    ...    | Get GNB SCF File | ${OUTPUT_DIR}/mylogs/ |
    Backup Scf    ${log_path}    1

Get AirPhoneConfig And Lua Cfg File
    [Arguments]    ${log_path}
    [Documentation]    This keyword is used to get lua.cfg and AirphoneConfig.xml from /opt/iphy/latest/.
    ...    You can use it after Keyword "Suite Setup Copy WTS Config Files From QT", there are no files in original /opt/iphy/latest/.
    ...    | Input Parameters | Man. | Description |
    ...    | ${log_path} | Yes | local directory |
    ...
    ...    Examples:
    ...    | Get AirPhoneConfig And Lua Cfg File | ${OUTPUT_DIR}/mylogs/ |
    ${WTS_CFG}=    Run    ls ${WTS_DIR}/wts_config*.cfg 2>/dev/null
    Run Keyword If    "${WTS_CFG}"==""    Suite Setup Update GNB    log=none
    Run Keyword If    "${WTS_CFG}"==""    Suite Setup Copy WTS Config Files From QT
    ${WTS_CFG}=    Run    ls ${WTS_DIR}/wts_config*.cfg 2>/dev/null
    ${WTS_AP_XML}=    Run    ls ${WTS_DIR}/wts_ap_config*.xml 2>/dev/null
    Run    cp ${WTS_AP_XML} "${log_path}";cp ${WTS_CFG} "${log_path}"

Get AirPhoneConfig And Lua Cfg File 2
    [Arguments]    ${log_path}
    [Documentation]    This keyword is used to get lua.cfg and AirphoneConfig.xml from /opt/iphy/latest/.
    ...    You can use it after Keyword "Suite Setup Copy WTS Config Files From QT", there are no files in original /opt/iphy/latest/.
    ...    | Input Parameters | Man. | Description |
    ...    | ${log_path} | Yes | local directory |
    ...
    ...    Examples:
    ...    | Get AirPhoneConfig And Lua Cfg File | ${OUTPUT_DIR}/mylogs/ |
    Run    cp /opt/iphy/latest/*.cfg /opt/iphy/latest/*.xml "${log_path}";

Copy AirPhoneConfig And Lua Cfg File From WTS DIR
    [Arguments]    ${log_path}
    OperatingSystem.Run And Return Rc And Output    cp ${WTS_DIR}/${WTS_AP_XML} "${log_path}"
    OperatingSystem.Run And Return Rc And Output    cp ${WTS_DIR}/${WTS_CFG} "${log_path}"

Get TargetDB File
    [Arguments]    ${log_path}
    Run    sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.255.1:/ffs/run/TargetBD_SBTS*.xml ${log_path}

Get GNB Swconfig File
    [Arguments]    ${log_path}
    [Documentation]    This keyword is used to get swconfig.txt from GNB.
    ...    | Input Parameters | Man. | Description |
    ...    | ${log_path} | Yes | local directory |
    ...
    ...    Examples:
    ...    | Get GNB Swconfig File | ${OUTPUT_DIR}/mylogs/ |
    setup_enb_fsm_access
    get_enb_swconfig_file    ${log_path}/swconfig_gnb.txt    partition=active
    [Teardown]    teardown_enb_fsm_access

Get IPHY XML File And Swconfig File
    [Arguments]    ${log_path}
    [Documentation]    This keyword is used to get iphy.xml and swconfig.txt from Airphone.
    ...    | Input Parameters | Man. | Description |
    ...    | ${log_path} | Yes | local directory |
    ...
    ...    Examples:
    ...    | Get IPHY XML File And Swconfig File | ${OUTPUT_DIR}/mylogs/ |
    setup_wts_fsm_access
    get_wts_file    /ffs/run/simmode/iphy.xml    ${log_path}/iphy.xml    partition=active
    get_wts_file    /ffs/run/swconfig.txt    ${log_path}/swconfig_ap.txt    partition=active
    [Teardown]    teardown_wts_fsm_access

Get Feature Name
    [Documentation]    This keyword is used to get feature name from ${SUITE_NAME}.
    Log To Console     ${SUITE_NAME}
    @{ret}=    String.Split String    ${SUITE_NAME}    ${SPACE}
    ${feature_name}=    Set Variable     @{ret}[0]
    [Return]    ${feature_name}

Put Testline Config Files to Local Log Server
    [Arguments]    ${log_path}
    [Documentation]    This keyword is used to copy local directory to Hangzhou log server,config files,error prints for example.
    ...    remote log server is 10.57.215.253    username: nokia    password: nokia123
    ...    | Input Parameters | Man. | Description |
    ...    | ${log_path} | Yes | local directory |
    ...
    ...    Examples:
    ...    | Put Testline Config Files to Local Log Server | ${OUTPUT_DIR}/mylogs/ |
    ${feature_name}=    Get Feature Name
    ${path1}    ${dir1}=    OperatingSystem.Split Path    ${SUITE_LOG_DIRECTORY}
    ${local_log_server_path}=    Set Variable    /home/nokia/LogServer/CRT_config_file/${feature_name}/${dir1}/
    ${cmd}=    Set Variable    sshpass -p nokia123 ssh nokia@10.57.215.253 mkdir -p ${local_log_server_path}
    OperatingSystem.Run And Return Rc And Output    ${cmd}
    ${cmd}=    Set Variable    sshpass -p nokia123 scp -r ${log_path} nokia@10.57.215.253:${local_log_server_path}
    OperatingSystem.Run And Return Rc And Output    ${cmd}

Get Config Files And Put To Local Log Server
    [Documentation]    This keyword is used to collect 6 config files into one folder and put it to Hangzhou log server.
    ${log_path}=    Get Current Testline Config Files    ${SUITE_LOG_DIRECTORY}/mylogs/
    Put Testline Config Files to Local Log Server    ${log_path}