*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup    fail_with_alarms=${True}    allowed_faults_ids=7316
Test Teardown        SISO Coam Test Teardown
Test Timeout         24h

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/Cell/E2E_SiSo_Cell_block_and_unblock_gNB.robot
Resource    ${BASIC_PATH_5G}/BTS/General_SiSo_Peak_with_Given_Information.robot
Resource    ${BASIC_PATH_5G}/Manual_SiSo_CM_Recommissioning.robot

Documentation
...    Author:zhihao shi
...    contact:zhihao.shi@nokia-sbell.com
...    squad group:SG_04
...    Feature CB009163-A in trunk program

Force Tags            5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G    STATE_SW_UPLOADED   CLOUD_5G_CLASSICAL_ASIB_ABIO_AEQYx3_ENB
...    PY36


*** Test Cases ***
# TL583
#3S-(1CC+1CC)-8D-8U(SA), 100+30M, 100M peak; 1,3,5; 1*25GE per RU
[1]CB009163-A-A3-1_General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing_split_mode
    [Tags]    3S-2CC-8D-8U_Split_Mode    CRT_TRUNK    RF50
    ${cell_list}  create list  ${1}    ${4}
    Get UE From Init File and Make call  cell_list=${cell_list}  with_peak=${True}  duration=${300}  ue_num_each_call=${2}
    ...    suite_name=${SUITE NAME}    test_name=${TEST NAME}

#3S-2CC-8D-8U (SA) , 50+50M, 50M peak;1,7;3,8;5,9;2*25GE per RU.
[1]CB009163-A-A2_General_SiSo_Cell_block_and_unblock
    [Tags]    3S-2CC-8D-8U    CRT_TRUNK
    ${fault_list}    Create List    49
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    E2E_SiSo_Cell_block_and_unblock_gNB  with_peak=${false}  call_duration=${300}  ue_num_each_call=${2}

#3S-2CC-8D-8U (SA) , 50+50M, 50M peak;1,7;3,8;5,9;2*25GE per RU.
[1]CB009163-A-A2_Manual_SiSo_CM_Recommissioning
    [Tags]    3S-2CC-8D-8U    CRT_TRUNK    RF50
    Manual_SiSo_CM_Recommissioning  ue_num_each_call=${2}

