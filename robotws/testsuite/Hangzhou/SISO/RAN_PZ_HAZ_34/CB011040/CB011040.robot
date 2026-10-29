*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown
#Suite Setup           SBTS Suite Setup
#Suite Teardown        SBTS Suite Teardown
#Test Setup            SBTS Test Setup
#Test Teardown         SBTS Test Teardown

Test Timeout         24h

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_LTE.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Auto_BTS_site_reset.robot
Resource    ${BASIC_PATH_5G}/Baseband_module_lock_unlock_via_WEBUI.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Commissioning_BTS_Template_Commissioning.robot
#Resource    ${BASIC_PATH_5G}/BTS/Manual_SiSo_SM_NR_RAT_reset.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/coam_check_status.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/basic/simple_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/ue.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot.robot

Documentation
...    Author:Wu Jerry
...    contact:jerry.wu@nokia-sbell.com
...    squad group:SG02
...    Feature CB011040 in trunk program

Force Tags            5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G    STATE_SW_UPLOADED

*** Variables ***
${if_commissioning}    True

*** Test Cases ***
[1][1.0] CB011040-SR-A_4_Manual_SiSo_SM_BTS_Site_Reset 
    General_SiSo_Auto_BTS_site_reset    with_call=False    MAX_LOOP=2
	
[1][1.0] CB011040-SR-A_1_Manual_SiSo_CM_Recommissioning_half_subrack
    General_SiSo_Commissioning_BTS_Template_Commissioning
	
[1][1.0] CB011040-SR-A_5_Manual_SiSo_SM_NR RAT reset
    Manual_SiSo_SM_NR_RAT_reset_11040
	
[1][1.0] CB011040-SR-A_8_General_SiSo_Auto_BBMOD_lock_unlock_with_L3call
    Baseband_module_lock_unlock_via_WEBUI
	
	
*** Keywords ***
Manual_SiSo_SM_NR_RAT_reset_11040
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
    ...    *******************
    ...    Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${bbmod_index}=1    ${with_call}=${False}    ${with_peak}=${False}    ${duration}=${60}    ${loop_times}=${2}
    ...    ${wait_time_after_rat_reset}=100s
    ${before_active_fault_list}    Get Alarm Fault Id List   alarm_type=active
    ${before_history_fault_list}    Get Alarm Fault Id List   alarm_type=history
    Selenium Login And Disable Screen Lock
    selenium_coam.reset_nr    cancel=${True}
    selenium_coam.reset_nr    cancel=${False}
    ${is_asod_asoe_asof}    If ASOD or ASOE or ASOF or ASOG or ASOH testline
    Run keyword if    ${is_asod_asoe_asof}==${False}
    ...    wait until keyword succeeds   3min    30sec    bbmod Should Be offline    bbmod_index=${bbmod_index}
    Run keyword if    ${is_asod_asoe_asof}==${True}    sleep    ${wait_time_after_rat_reset}
    wait until keyword succeeds   10min    1min    Check status after rat reset_11040
    ...    before_active_fault_list=${before_active_fault_list}    before_history_fault_list=${before_history_fault_list}
    ...    is_asod_asoe_asof=${is_asod_asoe_asof}
    ${cell_list}    get all cell id
    run keyword if    ${with_call}    Get UE From Init File and Make call    cell_list=${cell_list}
    ...    with_peak=${with_peak}    duration=${duration}    loop_times=${loop_times}
    [Teardown]  Selenium Logout And Close Browser

Check status after rat reset_11040
    [Documentation]    Owner_tingting.zhong@nokia-sbell.com
    [Arguments]    ${before_active_fault_list}   ${before_history_fault_list}    ${gnb_type}=${gNb_CuType}    ${connection}=GNB_OAM
    ...    ${is_asod_asoe_asof}=${False}
    ${ext_active_allowd_list}    create list    ${8150}
    ${ext_history_allowd_list}    create list    ${7300}    ${7319}    ${8150}    ${7509}    ${4293}    ${4592}    ${7313}    ${16}
    ${new_activre_fault_list}    combine lists     ${before_active_fault_list}    ${ext_active_allowd_list}
    ${new_history_fault_list}    combine lists     ${before_history_fault_list}    ${ext_history_allowd_list}
    Check status after bts operation
    ...    before_active_fault_list=${new_activre_fault_list}
    ...    before_history_fault_list=${new_history_fault_list}
    ...    operation_component=bbmod
    ...    connection=${connection}
    ...    gnb_type=${gnb_type}
    ...    is_asod_asoe_asof=${is_asod_asoe_asof}
