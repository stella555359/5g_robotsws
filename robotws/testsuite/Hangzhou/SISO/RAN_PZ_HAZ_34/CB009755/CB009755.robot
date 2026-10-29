*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup    fail_with_alarms=${True}
Test Teardown        SISO Coam Test Teardown
Test Timeout         12h

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/Cell/General_SiSo_Online_Cell_addition_deletion.robot
Resource    ${BASIC_PATH_5G}/Cell/E2E_SiSo_Cell_block_and_unblock_gNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/selenium.robot

Documentation
...    Author:Zhong Tingting
...    contact:tingting.zhong@nokia-sbell.com
...    squad group:SG_04
...    Feature Owner: Xu Mingming
...    Feature CB009755 in trunk program

Force Tags            5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G    STATE_SW_UPLOADED
...   PY36

*** Variables ***
${if_commissioning}   False

*** Test Cases ***
# TL593
[1]CB009755_SR_ST_SiSo_04_General_SiSo_Online_Cell_Addition_Deletion
    [Tags]  1S-3CC-8D-8U
    ${cell_list}    Get All Cell Id
    run keyword and continue on failure
    ...    Get UE From Init File and Make call    cell_list=${cell_list}    with_peak=${True}
    ...    duration=${300}    ue_num_each_call=${2}    suite_name=${SUITE NAME}    test_name=${TEST NAME}
    Selenium Login And Disable Screen Lock
    Prepare for delete NRPGRP
    Online delete NRPGRP
    General_SiSo_Online_Cell_addition_deletion    check_cell=1    suite_name=${SUITE NAME}    test_name=${TEST NAME}
    General_SiSo_Online_Cell_addition_deletion    check_cell=2    suite_name=${SUITE NAME}    test_name=${TEST NAME}
    [Teardown]  run keywords    SISO Coam Test Teardown    perform_case_scf=${True}    AND
    ...    Selenium Logout And Close Browser

# TL585
[1]CB009755_SR_ST_SiSo_01_General_SiSo_Cell_block_and_unblock
    [Tags]  1S-2CC-16D-8U
    ${fault_list}    Create List    49
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    ${cell_list}    Get All Cell Id
    run keyword and continue on failure
    ...    Get UE From Init File and Make call    cell_list=${cell_list}    with_peak=${True}
    ...    duration=${300}    ue_num_each_call=${2}    suite_name=${SUITE NAME}    test_name=${TEST NAME}
    E2E_SiSo_Cell_block_and_unblock_gNB    with_call=${True}    with_peak=${True}    call_duration=${300}    upload_duration=${False}
    ...    suite_name=${SUITE NAME}    test_name=${TEST NAME}

*** Keywords ***

