*** Settings ***
Documentation
...    Note: Please DO NOT call this file again. The suggsetion is to call DevNJ_sbts_keywords.py file.
...    Note: Please DO NOT call this file again. The suggsetion is to call DevNJ_sbts_keywords.py file.
...    Note: Please DO NOT call this file again. The suggsetion is to call DevNJ_sbts_keywords.py file.
...    author: Cuicui Wang
...    contact: cuicui.wang@nokia-sbell.com
...    Purpose: This file is internal source file, wont suggest feature team use it.

Library           Collections
Library           OperatingSystem
Library           ../python/DevNJ_get_tl_configuration.py    WITH NAME    Get_TL_Configuration
Library           ../python/DevNJ_download_build_from_LS.py

Resource          ./DevNJ_upgrade.robot
Resource          ./DevNJ_testline.robot

*** Variables ***
${WTS_DIR}        /opt/iphy/latest    # can not change because it is hardcode in TA lib
${BTS_STARTUP_RETRY}    1
@{PARAMS_IN_SCF}    @{EMPTY}
@{PARAMS_IN_SWCONFIG}    @{EMPTY}
${ENB_BUILD}    null

*** Keywords ***

Setup OAM Env
    [Arguments]    ${subtype}    ${FLAG}
    [Documentation]  Cuicui Wang: This Keyword Is To Setup Oam Env And Bringup GNB.
    ...    | 1 | Setup Env |
    ...    | 2 | Get Testline info |
    ...    | 3 | change swconfig file defined in @{PARAMS_IN_SWCONFIG} |
    ...    | 4 | full commissioning SCFC with @{PARAMS_IN_SCF} |
    ...    | 5 | modify or generate cfg file |
    ...    | 6 | Wait BTS onair |

    OAM Setup NJ
    ${onair_status_1}    Run Keyword If  ${FLAG}==${True}  Start BTS For The First Time    ${subtype}
    ${onair_status}    Set Variable If  ${FLAG}==${False} or ${FLAG}==${false}  ${True}  ${onair_status_1}
    Run Keyword Unless    ${onair_status}    Retry To Start BTS

OAM Setup NJ
    AirScale.Connect To Gnb
    Run Keyword If  'DAS' not in '${tl_type}' and 'CDD' not in '${tl_type}'
    ...  AsiMgr.Connect to AsiMgr
    Set Suite Variables

Start BTS For The First Time
    [Arguments]    ${subtype}
    [Documentation]  Cuicui Wang: This Keyword Is To Bringup GNB.
    ...    | 1 | Get Testline info |
    ...    | 2 | change swconfig file defined in @{PARAMS_IN_SWCONFIG} |
    ...    | 3 | full commissioning SCFC with @{PARAMS_IN_SCF} and upgrade build if needed |
    ...    | 4 | Wait BTS onair |

    ${onair_status}    Set Variable    ${False}
    Waiting_For_Site_Response
    Log To Console    ===start bts for 1st time===
    #Change by cuicui for commission/swconfig start
    ${mrbtsid}  ${PARAMS_IN_SCF_TOTAL}  ${gnb_commission_path}  ${asir_commission_path}   Get GNB ASIR And Testline Info
    ...     ${subtype}
    Get Change Swconfig Base On Release
    Log To Console  scf_change_list=${PARAMS_IN_SCF_TOTAL}
    ###########Change for DAS and CDD################
    ${asir_status}    Check RadioModule Status    'radioModules'
    Run keyword If  'CDD' in '${tl_type}'
    ...    Modify Scf And Perfom GNB ASIR Full Commission    ${mrbtsid}
    ...    ${PARAMS_IN_SCF_TOTAL}
    ...    ${gnb_commission_path}
    ...    ${asir_commission_path}
    ...    ELSE IF  '${asir_status}'=='Online'  Run Keyword  Modify Scf And Perfom GNB ASIR Full Commission    ${mrbtsid}
    ...    ${PARAMS_IN_SCF_TOTAL}
    ...    ${gnb_commission_path}
    ...    ${asir_commission_path}
    ...    ELSE  Run Keyword  Modify Scf Upgrade Build And Perfom GNB ASIR Full Commission   ${mrbtsid}  ${PARAMS_IN_SCF_TOTAL}
    ...    ${gnb_commission_path}  ${asir_commission_path}
    ###########Change for DAS and CDD################
    Log To Console With Time Prefix    wait gNB SSH connected
    Waiting_For_Site_Response
    ${onair_status}    Wait for onAir    raise_error=${false}
    Wait Until Keyword Succeeds  15 min  30s  Verify gNB Cells Setup
    Run Keyword If    ${onair_status}    Log To Console With Time Prefix    gnb is already onair
    Collect Logs For Startup  ${onair_status}   startup_1
    [Return]    ${onair_status}

Modify Scf And Perfom GNB ASIR Full Commission
    [Arguments]     ${mrbtsid}  ${para}  ${gnb_commission_path}  ${asir_commission_path}
    [Documentation]  Cuicui Wang: Modify And Perform Full Commission
    ...    | Input Parameters | Man. | Description |
    ...    | mrbtsid | Y | BTS ID |
    ...    | para | Y | List of parameter need to modify |
    ...    | gnb_commission_path | Y | gNB commission path |
    ...    | asir_commission_path | Y | asir commission path |

	Run Keyword If  'DAS' not in '${tl_type}' and 'CDD' not in '${tl_type}'
    ...  Get_TL_Configuration.Change Hub Commission Targetbtsid       ${asir_commission_path}    ${mrbtsid}
    Get_TL_Configuration.Change GNB Commission Btsid Nrbtsid     ${gnb_commission_path}    ${mrbtsid}
    ${scf_for_startup}    Modify Scf And Perform Full Commission    ${gnb_commission_path}   ${para}
    Log To Console With Time Prefix    wait gNB SSH connected
    Waiting_For_Site_Response
    Log To Console  Wait for BaseBandModulesStatus Online
    Wait Until Keyword Succeeds     15x   1min    COAM_Admin_CheckUnitsStatusNormal      'basebandModules'
    Log To Console  Wait for RadioModulesStatus Online
    Wait Until Keyword Succeeds     15x   1min    COAM_Admin_CheckUnitsStatusNormal      'radioModules'

    Run Keyword If  'DAS' not in '${tl_type}' and 'CDD' not in '${tl_type}'
    ...    Wait Until Keyword Succeeds  15x  60s    Run keywords
    ...          Log To Console With Time Prefix  \nPerform ASIR Commission
    ...          AND  Run Keyword And Continue On Failure  AsiMgr.Send Commission Fullfile   ${asir_commission_path}
    ...          AND  Sleep  30s
    [Return]    ${scf_for_startup}

Modify Scf Upgrade Build And Perfom GNB ASIR Full Commission
    [Arguments]     ${mrbtsid}  ${para}  ${gnb_commission_path}  ${asir_commission_path}
    [Documentation]  Cuicui Wang: Modify Perform Full Commission And Upgrade Build
    ...    | Input Parameters | Man. | Description |
    ...    | mrbtsid | Y | BTS ID |
    ...    | para | Y | List of parameter need to modify |
    ...    | gnb_commission_path | Y | gNB commission path |
    ...    | asir_commission_path | Y | asir commission path |

    Log To Console  \nStart Download SW Build From Load Server
    ${sw_build_path}  Download Sw Build From Loadserver   ${ENB_BUILD}
    Log To Console  \nDownload SW Build From Load Server Finished
	Run Keyword If  'DAS' not in '${tl_type}'
    ...  Get_TL_Configuration.Change Hub Commission Targetbtsid       ${asir_commission_path}    ${mrbtsid}
    Get_TL_Configuration.Change GNB Commission Btsid Nrbtsid     ${gnb_commission_path}    ${mrbtsid}
    # Modify and Perform gNB commission
    ${scf_for_startup}    Modify Scf And Perform Full Commission    ${gnb_commission_path}   ${para}
    Log To Console With Time Prefix    wait gNB SSH connected
    Waiting_For_Site_Response
    Log To Console  Wait for BaseBandModulesStatus Online
    Wait Until Keyword Succeeds     15x   1min    COAM_Admin_CheckUnitsStatusNormal      'basebandModules'
    Sleep  30s
    # Upgrade Build Via Coam
    Wait Until Keyword Succeeds     5x   2min    COAM_Admin_UpdateSW     ${sw_build_path}
    # COAM_Admin_UpdateSW     ${sw_build_path}
    Log To Console With Time Prefix    wait gNB SSH connected
    Waiting_For_Site_Response
    Log To Console  Wait for RadioModulesStatus Online
    Wait Until Keyword Succeeds     15x   1min    COAM_Admin_CheckUnitsStatusNormal      'radioModules'

    Run Keyword If  'DAS' not in '${tl_type}'
    ...    Wait Until Keyword Succeeds  6x  60s    Run keywords
    ...          Log To Console With Time Prefix  \nPerform ASIR Commission after upgrade load
    ...          AND  Run Keyword And Continue On Failure  AsiMgr.Send Commission Fullfile   ${asir_commission_path}
    ...          AND  Sleep  30s

Analyze Failure Of eNB SSH Issue
    Return From Keyword If    '${KEYWORD STATUS}'=='PASS'
    Run Keyword If    'Unable to connect to port 22 on 192.168.255.1' or 'SSHClientException' in '${KEYWORD MESSAGE}'
    ...     Log To Console    Auto Blacklisted:failed to connect 192.168.255.1    WARN
    Run Keyword If    'Unable to connect to port 22 on 192.168.255.1' or 'SSHClientException' in '${KEYWORD MESSAGE}'
    ...     Log To Console    Rerun case for single run execution,
    ...     make sure enb connection is reachable for local testline or reseved cloud testline.    WARN

Retry To Start BTS
    ${onair_status}    Set Variable    ${False}
    : FOR    ${retry}    IN RANGE    ${BTS_STARTUP_RETRY}
    \    BuiltIn.Log To Console    ===start bts for ${${retry}+2}nd time===
    \    ${onair_status}    Set Variable    ${False}
    \    RestAPI.Reset And Wait For Site
    \    ${onair_status}    Wait For onAir    raise_error=${false}
    \    Collect Logs For Startup    ${onair_status}    startup_${${retry}+2}
    \    Exit For Loop If    ${onair_status}
    Run Keyword Unless    ${onair_status}    Fail    BTS fail to startup
    Run Keyword If    ${onair_status}    Log    enb is already onair

Collect Logs For Startup
    [Arguments]    ${onair_status}      ${tag}
    ${LOG_PATH}    Set Variable If    'startup' in '${tag}'    ${SAVE LOG DIRECTORY}${tag}_logs    ${SAVE LOG DIRECTORY}
    Run Keyword if  '${onair_status}'=='${False}'   Run Keywords    Collect IM Snapshot From gNB    log_dir=${LOG_PATH}
    ...     AND     Collect IMS Log From gNB         log_dir=${LOG_PATH}
    ...     AND     Collect Snapshot From gNB        log_dir=${LOG_PATH}

Create Suite Log Directory
    ${SUITE_LOG_DIRECTORY} =    Catenate    SEPARATOR=${/}    ${OUTPUT_DIR}    ${SUITE NAME}
    ${SUITE_LOG_DIRECTORY}    Replace String    ${SUITE_LOG_DIRECTORY}/    ${SPACE}    _
    Remove Directory    ${SUITE_LOG_DIRECTORY}    True
    Create Directory    ${SUITE_LOG_DIRECTORY}
    Set Suite Variable    ${SUITE_LOG_DIRECTORY}
    Set Suite Variable    ${SAVE LOG DIRECTORY}    ${SUITE_LOG_DIRECTORY}
    Log To Console    \nLOG_DIR=${SAVE LOG DIRECTORY}

Create Test Log Directory
    ${TEST_LOG_DIR}  Catenate    SEPARATOR=${/}  ${OUTPUT_DIR}  ${SUITE NAME}  ${TEST NAME}
    ${TEST_LOG_DIR}  Replace String    ${TEST_LOG_DIR}/    ${SPACE}    _
    Remove Directory    ${TEST_LOG_DIR}    True
    Create Directory    ${TEST_LOG_DIR}
    Set Suite Variable    ${TEST_LOG_DIR}
    Log To Console    \nLOG_DIR=${TEST_LOG_DIR}

Get Testline Info
    Log To Console    ===get testline info===
    ${testline_ip}    Execute Cmd On Pc    sudo ifconfig eth0 | grep -w inet | awk '{ print $2}'
    Log    TestLineIpAddress\=${testline_ip}    console=True
    ${testline_hostname}    Execute Cmd On Pc    hostname
    Log    TestLineHostName\=${testline_hostname}    console=True
    Run Keyword And Ignore Error    Execute Cmd On Pc    pip list | grep -e ute -e kiss -e ta-a2a -e ta-ssh -e ta-xml
    ${ute_version}    Execute Cmd On Pc    ute-setup -v
    Log    UTE_VERSION\=${ute_version.split()[-1]}    console=True

Get GNB Information
    #get gnb info
    Log To Console    ===get gnb info===
    ${bts_name}    get bts name
    Log    bts_name\=${bts_name}    console=True
    ${GNB_SW_VERSION}    RestAPI.get sw version
    Log    activeBuildVersion\=${GNB_SW_VERSION}    console=True
    Set Suite Variable    ${GNB_SW_VERSION}
    ${hw_info}    RestAPI.get detected hw info
    @{list_smods}    Set variable    ${hw_info['systemModules']}
    ${count_smods}    Get length    ${list_smods}
    Log    cnt_smods\=${count_smods}    console=True
    :FOR  ${smod}  IN  @{list_smods}
    \    Log    product name\=${smod['productName']}    console=True
    @{list_bbmods}    Set variable    ${hw_info['basebandModules']}
    ${count_bbmods}    Get length    ${list_bbmods}
    Log    cnt_bbmods\=${count_bbmods}    console=True
    :FOR  ${bbmod}  IN  @{list_bbmods}
    \    Log    product name\=${bbmod['productName']}    console=True
    ${BBU_TYPE}    Set Variable    ASIK
    Log    bbu_type\=${BBU_TYPE}    console=True
    Set Suite Variable    ${BBU_TYPE}
    ${bts_port}    ${use_ssl}    Define Admin Port
    Run Keyword And Ignore Error    Execute Cmd On Pc    ps -ef | grep node
    Run Keyword And Ignore Error    Execute Cmd On Pc    netstat -ano | grep ${bts_port}
    Comment    Run Keyword And Ignore Error    Execute Cmd On Pc    nmap 192.168.255.1 -p ${bts_port}

