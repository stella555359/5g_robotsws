*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup    fail_with_alarms=${True}
Test Teardown        SISO Coam Test Teardown
Test Timeout         100 min

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Loopback_for_C_U_Plane_transport_connectivity_check_alarm_management_trigger.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Ethernet_transport_counters_on_AirScale_and_RU_with_SOAP_RP1.robot

Documentation
...    Author:zhihao shi
...    contact:zhihao.shi@nokia-sbell.com
...    squad group:SG_04
...    Feature CB008576 in trunk program

Force Tags            5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G    STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AQQY_ENB
...    PY36

*** Variables ***

*** Test Cases ***
#TL584 1S-1CC-4D-4U
[1]CB008576-B_ASIB_Loopback_for_C_U_Plane_transport_connectivity_check_alarm_management_trigger
    [Tags]    CRT_22R4    CRT_22R3    CRT_TRUNK    1S-1CC-4D-4U_8576
    ${fault_list}    Create List    61009
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    General_SiSo_Loopback_for_C_U_Plane_transport_connectivity_check_alarm_management_trigger

[1]CB008576-B_ASIB_Ethernet_transport_counters_on_AirScale_and_RU_with_SOAP_RP1
    [Tags]    CRT_22R4    CRT_22R3    CRT_TRUNK    1S-1CC-4D-4U_8576
    General_SiSo_Ethernet_transport_counters_on_AirScale_and_RU_with_SOAP_RP1

#[1]CB008576-B_ASIB_Loopback_for_C_U_Plane_transport_connectivity_check_alarm_management_clear_threshold
#    General_SiSo_Loopback_for_C_U_Plane_transport_connectivity_check_alarm_management_trigger

*** Keywords ***
