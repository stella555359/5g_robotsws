*** Settings ***
Documentation     author: shasha liu
...               Group: HGZ_SG5
...               contact: shasha.liu@nokia-sbell.com

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot

*** Variables ***
${swUpdate_Version}   null

*** Keywords ***
General_SWM_supports_SW_download_Cancellation_via_WebUI
    [Documentation]
    ...    The purpose of this test is to verify SWM supports SW version download Cancellation via WebUI
    ...    *******************
    ...    Notice: run this kw should add as '-v swUpdate_Version:0.800.xxx'
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
    ...    wait until keyword succeeds    50min    1min    check SW download progress    expStatus=ongoing    AND
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
    wait until keyword succeeds    80min    10s     check SW download progress    expStatus=completed
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

# *** step to step ***
check SW vesion after upgrade
    [Arguments]  ${active_B4}  ${passive_B4}  ${planned_B4}
    ${active}     Get gNB current software info     version_type=Active
    ${Passive}    Get gNB current software info     version_type=Passive
    ${Planned}    Get gNB current software info     version_type=Planned
    set suite variable    ${active}
    set suite variable    ${Passive}
    set suite variable    ${Planned}
    Run Keyword If    '${swUpdate_Version}'=='${active_B4}'  run keywords
    ...    should be true    '${active}'=='${swUpdate_Version}'    AND
    ...    should be true    '${Passive}'=='${passive_B4}'     AND
    ...    should be true    '${Planned}'=='' or '${Planned}'=='-'
    ...    ELSE    run keywords
    ...    should be true    '${active}'=='${swUpdate_Version}'    AND
    ...    should be true    '${Passive}'=='${active_B4}'     AND
    ...    should be true    '${Planned}'=='' or '${Planned}'=='-'

check SW vesion after SW download
    [Arguments]  ${active_B4}  ${passive_B4}  ${planned_B4}
    ${active}     Get gNB current software info     version_type=Active
    ${Passive}    Get gNB current software info     version_type=Passive
    ${Planned}    Get gNB current software info     version_type=Planned
    Run Keyword If    '${swUpdate_Version}'=='${active_B4}'     run keywords
    ...    should be true    '${active}'=='${active_B4}'    AND
    ...    should be true    '${Passive}'=='${passive_B4}'     AND
    ...    should be true    '${Planned}'=='' or '${Planned}'=='-'
    ...    ELSE    run keywords
    ...    should be true    '${active}'=='${active_B4}'    AND
    ...    should be true    '${Passive}'=='${passive_B4}'     AND
    ...    should be true    '${Planned}'=='' or '${Planned}'=='-' or '${Planned}'=='${swUpdate_Version}'

test teardown for rollback
    log to console    \ntest teardown for rollback
    Run Keyword If    '${swUpdate_Version}'=='${active_version}'
    ...    log to console    \nNote: the upgrade version is the active one,rollback will not perform
    ...    ELSE    rollback when GNB upgrade normally
    Selenium Logout And Close Browser
    Run Keyword and Ignore Error    run process    rm ${pkgDLoad_filePath}    shell=True

rollback when GNB upgrade normally
    Run Keyword If Test Passed    wait until keyword succeeds    1min    10s    selenium_coam.software_rollback
    wait until keyword succeeds    5min    5s      check ping is disabled    ip=${asik_addr}
    Run Keyword and Ignore Error    Close Start Up View    timeout=10
    Run Keyword and Ignore Error    selenium_coam.refresh_page
    log to console    \n*** check all cells' status after Rollback ***
    Wait Until Keyword Succeeds    20min     30s     verify all cells should be onair
    log to console    \n*** check Software version after Rollback ***
    Run Keyword and Ignore Error    Close Start Up View    timeout=10
    Run Keyword and Ignore Error    selenium_coam.refresh_page
    check SW version after rollback   p1=${Passive}  p2=${active}

check SW version after rollback
    [Arguments]  ${p1}  ${p2}
    ${active_rollback}     Get gNB current software info    version_type=Active
    ${Passive_rollback}    Get gNB current software info    version_type=Passive
    ${Planned_rollback}    Get gNB current software info    version_type=Planned
    should be true    '${active_rollback}'=='${p1}'
    should be true    '${Passive_rollback}'=='${p2}'
    should be true    '${Planned_rollback}'=='' or '${Planned_rollback}'=='-'

check cancel software update progress
#   selenium_coam.cancel_software_update
    ${result}    selenium_coam.check_software_update_progress
    should be equal    ${result}[status]    Software download canceled.

Download SW Build to Test PC
    [Documentation]   Description: Download SW Build from artifactory to Test PC and return file path
    ...               :param pkgDLoad<str>: SW build to be downloaded, with format 0.800.2928
    [Arguments]    ${pkgDLoad}=${swUpdate_Version}
    log to console   \n*** Download SW Build to Test PC (target build: ${swUpdate_Version}) ***
    ${cmd_pkgDownload}    set variable
    ...    wget -q --no-proxy -O %{HOME}/Downloads/AirScale-${pkgDLoad}.zip ${arti_espoo}/${pkgDLoad}/AirScale-${pkgDLoad}.zip
    ${rc}    ${Output}    Run And Return Rc And Output    ${cmd_pkgDownload}
    Should Be Equal As Integers   ${rc}    0    msg=SW build download to Test PC failed with return code ${rc}
    set test variable    ${pkgDLoad_filePath}    %{HOME}/Downloads/AirScale-${pkgDLoad}.zip
#   ${cmd_md5Download}    set variable
#   ...    wget -q --no-proxy -O %{HOME}/Downloads/AirScale-${pkgDLoad}.zip.md5 ${arti_espoo}/${pkgDLoad}/AirScale-${pkgDLoad}.zip.md5
#   ${rc}    ${Output}    Run And Return Rc And Output    ${cmd_md5Download}
#   Should Be Equal As Integers   ${rc}    0    msg=md5 file download failed with return code ${rc}
    [Return]    ${pkgDLoad_filePath}

Download SW Build to gNB
    [Documentation]   Description: Download SW Build from Test PC to gNB via WebUI
    ...               :param if_active<bool>: True or False, default is False
    [Arguments]    ${upgrade_package_path}    ${if_active}=${False}
    log to console   \n*** Download SW Build to gNB (target build: ${swUpdate_Version}) ***
    ${result}    selenium_coam.load_software_package_from_local_drive    ${upgrade_package_path}
    should be equal      ${result}    software package load success
    selenium_coam.software_update     is_activate=${if_active}
    sleep    15s

check SW download progress
    [Documentation]   check SW download progress
    ...               :param expStatus<str>: completed or ongoing
    [Arguments]    ${expStatus}=completed
    ${result}    selenium_coam.check_software_update_progress
    log to console   \nCheck software progress after Download SW Build to gNB: ${result}[percentage]
    ${status}=   Run Keyword And Return Status    check ping is disabled    ip=${asik_addr}
    ${result}=   Run Keyword And Return Status   should contain any   ${result}[percentage]    completed   100%
    Run Keyword If    '${expStatus}'=='completed'
    ...    should be true   '${status}'=='True' or '${result}'=='True'
    ...    ELSE IF    '${expStatus}'=='ongoing'
    ...    should be true    '${result}[percentage]'!='0%'
    ...    ELSE    log to console   \nNot defined SW download progress

check software update report
    ${sw_update_report}    selenium_coam.save_sw_update_report
    OperatingSystem.File Should Exist     ${sw_update_report}
    OperatingSystem.Copy File    ${sw_update_report}     ${SAVE LOG DIRECTORY}
    ${file_path}    ${file_name}    OperatingSystem.split path    ${sw_update_report}
    ${sw_update_report_content}    OperatingSystem.get file    ${SAVE LOG DIRECTORY}/${file_name}
    csn.Connect to    ${host_addr}    ${host_username}    ${host_password}    alias=TESTPC
    csn.send command    command=cat ${SAVE LOG DIRECTORY}/${file_name} |grep -n "Started Software Build Download" |tail -1 |cut -d ":" -f1
    ...    connection=TESTPC
    ${output}    csn.read output    connection=TESTPC
    ${line_number}    convert to integer   ${output}
    csn.send command    command=tail -n \+${line_number} ${SAVE LOG DIRECTORY}/${file_name}    connection=TESTPC
    ${output}    csn.read output    connection=TESTPC
    should not contain any    ${output}    error    failed
    csn.disconnect    connection=TESTPC

Get gNB current software info
    [Documentation]   Description: return current software with format 0.800.2928
    ...               :param version_type<str>: Active,Passive,Planned , default is Active
    [Arguments]    ${version_type}=${Active}
    ${sw_version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
    set test variable    ${sw_version}
    set test variable    ${version_type}
    Run Keyword If   '${sw_version}[${version_type}]'=='' or '${sw_version}[${version_type}]'=='-'
    ...    Run Keywords    log to console    \nThe ${version_type} software is EMPTY    AND
    ...    set test variable    ${version}    -
    ...    ELSE    _Get gNB current software info Tmp
    [Return]   ${version}

_Get gNB current software info Tmp
    ${result}    string.split string    string=${sw_version}[${version_type}]   separator=_
    ${length}    Get Length    ${result}
    ${length_tmp}    Evaluate    ${length} - 1
    ${length}    set variable if   '${result}[-1]'==''   ${length_tmp}    ${length}
    ${i} =    Set Variable    ${1}
    ${SW_vesion_tmp}    convert to integer     ${result}[2]
    FOR    ${i}    IN RANGE    1    ${length} - ${2}
         ${j} =    Evaluate    ${i} + ${2}
         ${build}    set variable    ${result}[${j}]
         ${build}    Run Keyword If    ${j} < 5    convert to integer    ${result}[${j}]    ELSE    set variable    ${result}[${j}]
         ${SW_vesion_tmp}    set variable    ${SW_vesion_tmp}.${build}
    END
    ${version}    set variable if    '${result}[-1]'==''    ${SW_vesion_tmp}_    ${SW_vesion_tmp}
    set test variable    ${version}
    log to console    \nThe ${version_type} software is ${version} (${sw_version}[${version_type}])

software notification
    Run Keyword and Ignore Error    selenium_coam.refresh_page
    Run Keyword and Ignore Error    Close Start Up View    timeout=10
    log to console    \n*** software notification ***
    Run Keyword If   '${swUpdate_Version}'=='null'
    ...    log to console   \nPlease assign 'swUpdate_Version' value firstly
    ${active_version}     Get gNB current software info    version_type=Active
    set test variable    ${active_version}
    Run Keyword If   '${swUpdate_Version}'=='${active_version}'
    ...    log to console   \nNote: the target build is same as Active verison: ${active_version}
    ${Passive_version}    Get gNB current software info    version_type=Passive
    set test variable    ${Passive_version}
    Run Keyword If   '${swUpdate_Version}'=='${Passive_version}'
    ...    log to console   \nNote: the target build is same as Passive verison: ${Passive_version}
    ${Planned_version}    Get gNB current software info    version_type=Planned
    set test variable    ${Planned_version}
    Run Keyword If   '${swUpdate_Version}'=='${Planned_version}'
    ...    log to console   \nNote: the target build is same as Planned verison: ${Planned_version}

check ping is disabled
    [Documentation]   check unit cannot be pingable after reset, power off/on and so on
    [Arguments]   ${ip}
    ${ping}=    run process    ping -c 3 ${ip}   timeout=60s   shell=True
    should contain    ${ping.stdout}    100% packet loss
