*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup    fail_with_alarms=${True}
Test Teardown        SISO Coam Test Teardown
Test Timeout         24h

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Power_Meter_counter_update_for_energy_consumption.robot

Documentation
...    Author:zhihao shi
...    contact:zhihao.shi@nokia-sbell.com
...    squad group:SG_04
...    Feature CB007833 in SBTS22R2 program

Force Tags    5G_RAN    5G_RAN_TDD    PY310

*** Test Cases ***
#TL593
[1]CB007777-5G-L_02_01_General_SiSo_Power_Meter_counter_update_for_energy_consumption
    [Tags]    CRT_TRUNK    CIT_22R4    RF50    1S-1CC-8D-4U_CHT
    General_SiSo_Power_Meter_counter_update_for_energy_consumption
