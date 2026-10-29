*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/coam_check_status.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot

*** Keywords ***
Manual_SiSo_SM_NR_RAT_reset
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] Purpose of this test case is to verify that NR RAT reset triggerred form ADMIN is performed
    ...    correctly. It is checked that after this reset all NR services are working properly. Other configured RAT’s
    ...    should not be affected
    ...    WebUI interface.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 25.10.2023 - - Created
    ...    - 24.03.2025 - - update due to CB008880: actRatResetEnhancement is true as default value
    ...    and from 25R3 release onwards this parameter is frozen and its value can only be set to 'TRUE'
    ...    *******************
    ...    Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${hard_reset}=${True}    ${bbmod_index}=1    ${with_call}=${False}    ${with_peak}=${False}    ${duration}=${60}
    ...    ${loop_times}=${2}    ${wait_time_after_rat_reset}=100s    ${check_ue}=${False}
    ...    ${is_bb_reset_expected}=${True}
    log    \ndefault value for 'is_bb_reset_expected' is ${is_bb_reset_expected}, but better to define by hard reset or not
    ${before_active_fault_list}    Get Alarm Fault Id List   alarm_type=active
    ${before_history_fault_list}    Get Alarm Fault Id List   alarm_type=history
    Selenium Login And Disable Screen Lock
    selenium_coam.reset_nr    cancel=${True}    with_hard=${hard_reset}
    selenium_coam.reset_nr    cancel=${False}    with_hard=${hard_reset}
    ${is_asod_asoe_asof}    If ASOD or ASOE or ASOF or ASOG or ASOH testline
    Run keyword if    ${is_asod_asoe_asof}==${False} and ${hard_reset}==${True} and ${is_bb_reset_expected}==${True}
    ...    wait until keyword succeeds   3min    30sec    bbmod Should Be offline    bbmod_index=${bbmod_index}
    Run keyword if    ${is_asod_asoe_asof}==${True}    sleep    ${wait_time_after_rat_reset}
    Run keyword if    ${hard_reset}==${False} or ${is_bb_reset_expected}==${False}
    ...    wait until keyword succeeds   3min    30sec    Check status of the cell onair fail
    wait until keyword succeeds   10min    1min    Check status after rat reset
    ...    before_active_fault_list=${before_active_fault_list}    before_history_fault_list=${before_history_fault_list}
    ...    is_asod_asoe_asof=${is_asod_asoe_asof}
    ${cell_list}    get all cell id
    run keyword if    ${with_call}    Get UE From Init File and Make call    cell_list=${cell_list}
    ...    with_peak=${with_peak}    duration=${duration}    loop_times=${loop_times}    check_ue=${check_ue}
    [Teardown]  Selenium Logout And Close Browser
