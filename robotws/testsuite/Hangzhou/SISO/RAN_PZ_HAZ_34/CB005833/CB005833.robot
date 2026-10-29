*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup    fail_with_alarms=${True}
Test Teardown        SISO Coam Test Teardown
Test Timeout         24h

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/General_resiliency_of_M-Plane_communication_between_RU_and_DU_in_P2P_deployment_with_one_bbmod.robot
Resource    ${BASIC_PATH_5G}/General_BFD_alarms_checking_for_BFD_down_ingress_and_BFD_down_egress.robot
Resource    ${BASIC_PATH_5G}/General_Link_Supervision_with_BFD_checking_while_enabling_and_disabling_BFD_session.robot
Resource    ${BASIC_PATH_5G}/General_enable_and_disable_eCPRI_M-Plane_resilience.robot

Documentation
...    Author:cheng peng
...    contact:zhihao.shi@nokia-sbell.com
...    squad group:SG_04
...    Feature CB005833 in SBTS00 program

Force Tags            5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G    STATE_SW_UPLOADED   CLOUD_5G_CLASSICAL_SA_ASILL_ABIOB1_AZNA
...   PY310    HAZ4_T04


*** Test Cases ***
[1]CB005833_04_resiliency_of_M-Plane_communication_between_RU_and_DU_in_P2P_deployment_where_resiliency_is_only_on_one_CC_card
    [Tags]    CRT_TRUNK    CRT_22R4    1S-1CC-8D-4U_5833    RF50
    ${fault_list}    Create List    61605
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    General_resiliency_of_M-Plane_communication_between_RU_and_DU_in_P2P_deployment_with_one_bbmod
    [Teardown]    SISO Coam Test Teardown    perform_case_scf=${True}

[1]CB005833_06_BFD_alarms_checking_for_BFD_down_ingress_and_BFD_down_egress
    [Tags]    1S-2CC-8D-4U_5833
    ${fault_list}    Create List    61606
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    General_BFD_alarms_checking_for_BFD_down_ingress_and_BFD_down_egress

[1]CB005833_13_Link_Supervision_with_BFD_checking_while_enabling_and_disabling_BFD_session
    [Tags]    1S-2CC-8D-4U_5833
   ${fault_list}    Create List    61605
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    General_Link_Supervision_with_BFD_checking_while_enabling_and_disabling_BFD_session

[1]CB005833_10_enable_and_disable_eCPRI_M-Plane_resilience
    [Tags]    1S-2CC-8D-4U_5833
    General_enable_and_disable_eCPRI_M-Plane_resilience
