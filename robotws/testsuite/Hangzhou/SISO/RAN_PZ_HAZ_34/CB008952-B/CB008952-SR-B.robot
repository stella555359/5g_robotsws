*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           #SISO Coam Test Setup
Test Teardown        #SISO Coam Test Teardown
Test Timeout         90 min

Resource             testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource             ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource             testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot

#Library             testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/get_case_variables.py
#Variables           TestData/case_variables.yml

Documentation
...    Author: Liu Yue
...    Contact: yue.2.liu@nokia-sbell.com
...    squad group:SG_05
...    Feature CB008952 in SBTS23R3 program with configuration block 23R3_N_CB008952_5 and 23R3_N_CB008952_6

Force Tags     RAN_5G     RAN_5G_TDD    STATE_SW_UPLOADED    SBTS00    PY36    master_classicalbts_all

*** Variables ***

*** Test Cases ***
[1]CB008952-B_B5_05_General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing_with_legacy_Bbcellset
    [Tags]    3S-4CC-8D4U_CB008952_5    CRT_23R3    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    log to console   to be updated
#    ${cell_list}    Create List    ${11}
#    Get UE From Init File and Make call    cell_list=${cell_list}    with_peak=${False}
    [Teardown]    SISO Coam Test Teardown

[1]CB008952-B_B6_05_General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing_with_legacy_Bbcellset
    [Tags]    3S-4CC-4D4U_CB008952_6    CRT_23R3    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    log to console   to be updated
#    ${cell_list}    Create List    ${11}
#    Get UE From Init File and Make call    cell_list=${cell_list}    with_peak=${False}
    [Teardown]    SISO Coam Test Teardown

*** Keywords ***
