*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/simple_keyword.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot
*** Variables ***

*** Keywords ***
General_SiSo_CPRI_feature_activation_in_runtime_NR
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test is to verify Power Saving percentage measured in Idle Load
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 12.05.2023 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    [Arguments]  ${with_peak}=${True}    ${duration}=${60}    ${suite_name}=default    ${test_name}=default
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    ${cell_id_list}    Get All Cell Id
    ${modify_params}    Get CPRI offest modify parameters list    cell_id_list=${cell_id_list}
    Modify Parameters On Webem  modify_params=${modify_params}
    Wait Until Keyword Succeeds    10 min    30 sec    Check all cells info should be onair
    sleep    300
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    should be true  ${alarm_status}
    Get UE From Init File and Make call    cell_list=${cell_id_list}  with_peak=${with_peak}
    ...    duration=${duration}    suite_name=${suite_name}    test_name=${test_name}
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=Activate CPRI-N cell timing offset    abbr=actCellTimingOffsetCpriN    new_value=false
    sleep  20
    Wait Until Keyword Succeeds    5 min    30 sec    Check all cells info should be onair
    sleep    120
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    should be true  ${alarm_status}
    Get UE From Init File and Make call    cell_list=${cell_id_list}  with_peak=${with_peak}
    ...    duration=${duration}    suite_name=${suite_name}    test_name=${test_name}
    [Teardown]    Run keywords        Check and Modify Single Parameter on WebUI
    ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=Activate CPRI-N cell timing offset    abbr=actCellTimingOffsetCpriN    new_value=false
    ...    AND   Wait until keyword succeeds    10min    30s    Verify all cells should be onair
    ...    AND    Selenium Logout And Close Browser
