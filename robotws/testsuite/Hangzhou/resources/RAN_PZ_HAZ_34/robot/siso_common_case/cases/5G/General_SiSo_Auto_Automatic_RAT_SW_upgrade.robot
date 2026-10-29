*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot

*** Variables ***

*** Keywords ***
General_SiSo_Auto_Automatic_RAT_SW_upgrade
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
    log to console  OLD_SW_PKG:${Old_SW_version}, NEW_SW_PKG:${Active_SW_version}
    ${OLD_SW_PKG}  Download SW  SW=${Old_SW_version}
    ${NEW_SW_PKG}  Download SW  SW=${Active_SW_version}
    log to console  start deploy to OLD_SW_PKG:${OLD_SW_PKG}
    Perform SW Update  ${SAVE LOG DIRECTORY}${OLD_SW_PKG}
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
