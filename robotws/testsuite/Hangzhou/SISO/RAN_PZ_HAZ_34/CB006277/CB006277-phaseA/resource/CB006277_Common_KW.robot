*** Settings ***
Documentation     author: Liu Yue
...               Group: HGZ_SG5
...               contact: yue.2.liu@nokia-sbell.com

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/counter_check.robot
Variables    ../TestData/variables.py

Library    Collections
Library    OperatingSystem
Library    DateTime
Library    String
Library    taf.hw.rf_attenuator    WITH NAME    att

*** Variables ***
${attenuator_value}      15.0

*** Keywords ***
General_SiSo_U-plane_Fast_C-plane_counters_AQQL
    [Arguments]    ${miNrEcpriUpFCp}=5min
    Modify miNrEcpriUpFCp Parameters via API  miNrEcpriUpFCp=${miNrEcpriUpFCp}
    sleep  ${miNrEcpriUpFCp}
    selenium login and disable screen lock
    Check M55318 Counter for AQQL    change_interval=${miNrEcpriUpFCp}
    [Teardown]  run keywords  selenium logout and close browser

Check M55318 Counter for AQQL
    [Documentation]  Author: zhihao.shi@nokia-sbell.com
    [Arguments]    ${change_interval}
    connect to common unit master
    sleep  30
    #${M55318C00001_value}    Get PM Counter via Webem    counter_id=M55318C00001    interval=${change_interval}
    #${M55318C00001_value}    convert to integer     ${M55318C00001_value}
    #Should Be True    ${M55318C00001_value} >0
    ${M55318C00002_value}    Get PM Counter via Webem    counter_id=M55318C00002    interval=${change_interval}
    ${M55318C00002_value}    convert to integer     ${M55318C00002_value}
    should be true    ${M55318C00002_value} >0
    #${M55318C00003_value}    Get PM Counter via Webem    counter_id=M55318C00003    interval=${change_interval}
    #${M55318C00003_value}    convert to integer     ${M55318C00003_value}
    #Should Be True    ${M55318C00003_value} >0
    ${M55318C00004_value}    Get PM Counter via Webem    counter_id=M55318C00004    interval=${change_interval}
    ${M55318C00004_value}    convert to integer     ${M55318C00004_value}
    should be true    ${M55318C00004_value} >0
	${M55318C00006_value}    Get PM Counter via Webem    counter_id=M55318C00006    interval=${change_interval}
    ${M55318C00006_value}    convert to integer     ${M55318C00006_value}
    Should Be Equal    ${M55318C00006_value}    ${0}
	${M55318C00008_value}    Get PM Counter via Webem    counter_id=M55318C00008    interval=${change_interval}
    ${M55318C00008_value}    convert to integer     ${M55318C00008_value}
    Should Be Equal    ${M55318C00008_value}    ${0}
	${M55318C00010_value}    Get PM Counter via Webem    counter_id=M55318C00010    interval=${change_interval}
    ${M55318C00010_value}    convert to integer     ${M55318C00010_value}
    Should Be Equal    ${M55318C00010_value}    ${0}
    should be Equal    ${M55318C00002_value}    ${M55318C00004_value}
    [Teardown]  csn.Disconnect  connection=ASIK Master
General_SiSo_Auto_Automatic_RAT_SW_upgrade_Keep_Passive
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test case is to check functionality of the automatic software upgrade of RFSW
    ...    in case of incompatible RFSW.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 03.16.2020 - https://jiradc.int.net.nokia.com/browse/WESTLAKE- - Created
    ...    - 07.29.2020 - add fault 23
    ...    *******************
    ...    Notice: run this kw can add as -v target_old_version:10.1800.xxxx
    ...    *******************
    ...    Owner_aaron.deng@nokia-sbell.com
    ${Old_SW_version}    get old sw version    SW=${Active_SW_version}
    log to console    OLD_SW_PKG:${Old_SW_version}, NEW_SW_PKG:${Active_SW_version}
    ${OLD_SW_PKG}    Download SW    SW=${Old_SW_version}
    ${NEW_SW_PKG}    Download SW    SW=${Active_SW_version}
	Perform SW rollback
    log to console    start deploy to OLD_SW_PKG:${OLD_SW_PKG}
    Perform SW Update    ${SAVE LOG DIRECTORY}${OLD_SW_PKG}
    Wait Until Keyword Succeeds    10min    30s    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds    15min    180s    Check HW modules detection
    Change active partition
    Perform BTS Site Reset    download_dir=${SAVE LOG DIRECTORY}
    log to console  start check fault 23 present
    Wait For Expect Fault Present  faultId=23   timeout=1200
    log to console  start deploy to NEW_SW_PKG:${NEW_SW_PKG}
    Perform SW Update  ${SAVE LOG DIRECTORY}${NEW_SW_PKG}
    Wait Until Keyword Succeeds    10min    30s    Connect to gnb coam via ssl
    log to console  start check fault 23 disappear
    Wait For Expect Fault To Disappear  faultId=23   timeout=1200
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'
    Selenium Login And Disable Screen Lock
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
            ${radio_type}    get ru type  ru_index=${ru_index}
            ${Radio_Protocol_Type}  Get Radio Protocol
            ${active_version}     coam.get_sw_version    connection=GNB_OAM
            ${ruSW_expect}    get RFSW version from TargetBD    radio_type=${radio_type}   Radio_Protocol_Type=${Radio_Protocol_Type}
            ...    active_version=${active_version}
            ${ruSW_fromModule}    get RFSW version from radio module    ru_index=${ru_index}
            should be true    '${ruSW_fromModule}'=='${ruSW_expect}'
    END
    [Teardown]  run keywords  Selenium Logout And Close Browser    AND    Remove Downloaded Content  ${NEW_SW_PKG}  ${OLD_SW_PKG}
Perform SW rollback
    [Arguments]  ${connection}=GNB_OAM
    coam.rollback_software    connection=${connection}
    sleep    2min
    COAM Wait gnb And Cells ready    timeout=15min    gnb_type='${gNb_CuType}'
