*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
*** Variables ***

*** Keywords ***
General_microDTXAdvanced_when_diff_chBW
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test is to verify micro DTX Advanced when diff chBW
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 04.07.2022 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    [Arguments]  ${ru_index}=${1}
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    filter_param=Activate micro discontinued transmission    abbr=actMicroDTX    new_value=true
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    filter_param=Activate micro discontinued transmission advanced    abbr=actMicroDTXAdvanced    new_value=true
    Modify_Band_Frame_Structure    band=20    frame_structure=1208_GP1_A1
    ${power_with_20M}  Get RMOD Power Measurement    ru_index=${ru_index}
    Modify_Band_Frame_Structure    band=100    frame_structure=1208_GP1_A1
    ${power_with_100M}  Get RMOD Power Measurement    ru_index=${ru_index}
    ${p_value}    Evaluate    "%.3f" % ((${power_with_100M}-${power_with_20M})/${power_with_100M})
    ${per_value}    Evaluate    ${p_value}*100
    log to console   \n Power Saving Percent:${per_value}%
    should be true      0 < ${p_value} < 0.3
    [Teardown]  selenium logout and close browser
