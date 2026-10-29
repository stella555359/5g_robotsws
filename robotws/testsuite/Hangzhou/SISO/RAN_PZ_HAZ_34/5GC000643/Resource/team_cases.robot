*** Settings ***
Documentation     author: shasha liu
...               Group: HGZ_SG5
...               contact: shasha.liu@nokia-sbell.com
...               Note: This file is for team internal usage, not make full compatibility

Resource     team_steps.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Auto_Automatic_RAT_SW_upgrade.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot

*** Variables ***

*** Keywords ***
### case pool for siso ###

General_SWM_supports_SW_download_Cancellation_via_WebUI
    [Documentation]
    ...    The purpose of this test is to verify SWM supports SW version download Cancellation via WebUI
    ...    *******************
    ...    Notice: run this kw should add param such as '-v swUpdate_Version:0.800.xxx'
    ...    *******************
    ...    Owner_shasha.liu@nokia-sbell.com

    Selenium Login And Disable Screen Lock
    software notification
    Download SW Build to Test PC    pkgDLoad=${swUpdate_Version}
    Download SW Build to gNB    if_active=${False}    upgrade_package_path=${pkgDLoad_filePath}
    log to console   \n*** cancel SW download ***
    Run Keyword If
    ...  '${swUpdate_Version}'!='${active_version}' and '${swUpdate_Version}'!='${Passive_version}' and '${swUpdate_Version}'!='${Planned_version}'
    ...    Run Keywords
    ...    wait until keyword succeeds    20min    30s    check SW download progress    expStatus=ongoing    AND
    ...    selenium_coam.cancel_software_update    AND
    ...    wait until keyword succeeds    10min    30s   check cancel software update progress
    log to console   \n*** check current software after cancel SW Download ***
    check SW vesion after SW download    active_B4=${active_version}  passive_B4=${Passive_version}  planned_B4=${Planned_version}
    Run Keyword and Ignore Error    selenium_coam.refresh_page
    Run Keyword and Ignore Error    Close Start Up View    timeout=10

General_SWM_supports_SW_download_via_WebUI
    [Documentation]
    ...    The purpose of this test is to verify SWM supports SW version download to BTS via WebUI and SW version update
    ...    *******************
    ...    Notice: run this kw should add as '-v swUpdate_Version:0.800.xxx'
    ...    *******************
    ...    Owner_shasha.liu@nokia-sbell.com

    Selenium Login And Disable Screen Lock
    software notification
    Download SW Build to Test PC    pkgDLoad=${swUpdate_Version}
    Download SW Build to gNB    if_active=${False}   upgrade_package_path=${pkgDLoad_filePath}
    wait until keyword succeeds    50min    10s     check SW download progress    expStatus=completed
    log to console   \n*** check current software after Download SW Build to gNB ***
    check SW vesion after SW download    active_B4=${active_version}  passive_B4=${Passive_version}  planned_B4=${Planned_version}
    Run Keyword and Ignore Error    Close Start Up View    timeout=10
    Run Keyword and Ignore Error    selenium_coam.refresh_page


General_SWM_supports_SW_provision_via_WebUI
    [Documentation]
    ...    The purpose of this test is to verify SWM supports SW provision via WebUI
    ...    *******************
    ...    Notice: run this kw should add as '-v swUpdate_Version:0.800.xxx'
    ...    *******************
    ...    Owner_shasha.liu@nokia-sbell.com

    Selenium Login And Disable Screen Lock
    software notification
    Download SW Build to Test PC    pkgDLoad=${swUpdate_Version}
    Download SW Build to gNB    if_active=${True}   upgrade_package_path=${pkgDLoad_filePath}
    wait until keyword succeeds    50min    10s     check SW download progress    expStatus=completed
    Run Keyword If    '${swUpdate_Version}'!='${active_version}'   run keywords
    ...    wait until keyword succeeds    5min    5s     check ping is disabled    ip=${asik_addr}    AND
    ...    Run Keyword and Ignore Error    Close Start Up View    timeout=10    AND
    ...    Run Keyword and Ignore Error    selenium_coam.refresh_page
    log to console    \n*** check all cells' status after Upgrade ***
    Wait Until Keyword Succeeds    20min    30s     verify all cells should be onair
    Run Keyword and Ignore Error    Close Start Up View    timeout=10
    Run Keyword and Ignore Error    selenium_coam.refresh_page
    log to console    \n*** check Software version after Upgrade ***
    check SW vesion after upgrade    active_B4=${active_version}    passive_B4=${Passive_version}  planned_B4=${Planned_version}
    Run Keyword and Ignore Error    check software update report
