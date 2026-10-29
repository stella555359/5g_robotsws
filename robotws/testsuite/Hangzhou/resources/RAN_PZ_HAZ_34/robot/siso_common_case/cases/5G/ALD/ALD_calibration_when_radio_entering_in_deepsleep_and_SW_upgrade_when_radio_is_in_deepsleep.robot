*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_csn.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/nr_feature_on.robot
*** Variables ***

*** Keywords ***
ALD_calibration_when_radio_entering_in_deepsleep_and_SW_upgrade_when_radio_is_in_deepsleep
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test is to verify if ALD SW upgrade failed when RMOD is in deep sleep
    ...    energy saving mode.ALD Calibrate and change value of angle is rejected or failed when RMOD is entering
    ...    deep sleep energy saving mode.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 14.12.2022 - - Created
    ...    - 13.03.2024 - - Update ticket:https://jiradc.ext.net.nokia.com/browse/LEOPARD-1870?filter=-1
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    [Arguments]    ${retu_index}=1    ${ALD_SW_PKG}=ALD_SW_20221209.zip
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    ${sw_full_url}    set variable     ${arti_hz_ald}${ALD_SW_PKG}
    log to console    \nMake sure ALD_package[${ALD_SW_PKG}] in URL PATH:https://10.57.169.252/build/ald/
    Download software to VM    sw_name=${ALD_SW_PKG}   sw_full_url=${sw_full_url}    package_store_path=${TS_CASE_LOG_PATH}
    Selenium Login And Disable Screen Lock    version=${stream}
    ${ald_info}    selenium_coam.get_ret_info_from_ret_management
    ${ald}    get from dictionary    ${ald_info}[0]    ALD
    sleep    10
    NR update power saving mode via webem    energySavingMode=DEEPSLEEP    actNrLBPowerSaving=true
    log to console  \n Waitting for 900s (from NORMAL to DEEPSLEEP)
    sleep    900
    Wait until keyword succeeds    20min    30s    RU Status Info Should Be Sleep
    ${ald_sw_full_url}    set variable     ${TS_CASE_LOG_PATH}${ALD_SW_PKG}
    ${load_result}    selenium_coam.load_software_package_from_local_drive    file_path=${ald_sw_full_url}
    log to console    ${load_result}
    log to console    start download without active
    selenium_coam.software_update
    sleep    30
    ${result}    selenium_coam.check_software_update_progress
    Should Be Equal As Strings   '${result}[status]'    'Download failed'
    NR Feature CB007511 OFF and Check
    NR update power saving mode via webem    energySavingMode=DEEPSLEEP    actNrLBPowerSaving=true
    log to console  \n Waitting for 8 mins 40 s
    sleep    520
    Wait until keyword succeeds    15min    10s    Cell Status Info Should Be Energy Saving State
    log to console  \n Waitting for 4 mins 20 s
    sleep    260
    selenium_coam.calibrate_ret_from_ret_management    ald=${ald}
    sleep    60
    ${info}    selenium_coam.get_ret_info_from_ret_management
    ${status}    get from dictionary    ${info}[0]    Action state and error description
    Should Contain Any   ${status}    Rejected    Fail
    [Teardown]    Run keywords
    ...    run keyword and continue on failure    CI_commssion.common commissioning
#    ...    NR update power saving mode via webem    energySavingMode=NORMAL    actNrLBPowerSaving=false
#    ...    AND   Wait until keyword succeeds    15min    60s    Verify all cells should be onair    cell_type=${cell_type}
    ...    AND   Selenium Logout And Close Browser
