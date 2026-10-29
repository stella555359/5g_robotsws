*** Settings ***
Suite Setup          CB008962 test suite setup without configure BWF
Suite Teardown       CB008962 test suite teardown
Test Setup           SISO Coam Test Setup
#Test Teardown        SISO Coam Test Teardown
Test Timeout         6h

Resource    ../../CB008962_SG05/resource/CB008962_resource_ABIP.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource     ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ../../../../resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/operate_cell_and_check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Variables   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/made_variable.py
Resource    ${BASIC_PATH_COMMON}/SBTS_Setup_And_Teardown.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/excel_chart.py
Documentation
...    Author:Shi Jeffrey
...    contact:jeffrey.shi@nokia-sbell.com
...    squad group:SG_05
...    Feature CB013277 in SBTS25R3 program

Force Tags   5G_RAN    5G_RAN_TDD

*** Test Cases ***
[1]Energy-Efficiency_load_0_low_AQQJ_slotwiseload_NRTDD
    Run Keyword And Ignore Error    disable deepsleep Mode
    Enable NR Test Dedicated State
    Activate RD mode
    sleep    1min
    Start NR downlink test slotwiseload TDD    type_of_load=slotWiseLoad    level_of_load_slot_wise=load_0_low
    sleep    30min
    &{dict_counter_values_load_0_low}    CB008962 Get Counter Value
    &{dict_counter_value_ABIP}    Get Counter Value for ABIP_ABIQ
    Set Suite Variable    &{dict_counter_values_load_0_low}
    Write load_0_low PM counter value to excel
    #Run Keyword And Ignore Error    enable deepsleep Mode
    [Teardown]    Run keywords
    ...    Run Keyword And Ignore Error    Disable NR Test Dedicated State
    ...    AND    selenium logout and close browser
    ...    AND    SISO Coam Test Teardown
[1]Energy-Efficiency_load_10_AQQJ_slotwiseload_NRTDD
    Run Keyword And Ignore Error    disable deepsleep Mode
    Enable NR Test Dedicated State
    Activate RD mode
    sleep    1min
    Start NR downlink test slotwiseload TDD    type_of_load=slotWiseLoad    level_of_load_slot_wise=load_10
    sleep    30min
    &{dict_counter_values_load_10}    CB008962 Get Counter Value
    &{dict_counter_value_ABIP}    Get Counter Value for ABIP_ABIQ
    Set Suite Variable    &{dict_counter_values_load_10}
    Write load_10 PM counter value to excel
    #Run Keyword And Ignore Error    enable deepsleep Mode
    [Teardown]    Run keywords
    ...    Run Keyword And Ignore Error    Disable NR Test Dedicated State
    ...    AND    selenium logout and close browser
    ...    AND    SISO Coam Test Teardown
[1]Energy-Efficiency_load_30_medium_AQQJ_slotwiseload_NRTDD
    Run Keyword And Ignore Error    disable deepsleep Mode
    Enable NR Test Dedicated State
    Activate RD mode
    sleep    1min
    Start NR downlink test slotwiseload TDD    type_of_load=slotWiseLoad    level_of_load_slot_wise=load_30_medium
    sleep    30min
    &{dict_counter_values_load_30}    CB008962 Get Counter Value
    &{dict_counter_value_ABIP}    Get Counter Value for ABIP_ABIQ
    Set Suite Variable    &{dict_counter_values_load_30}
    Write load_30_medium PM counter value to excel
    #Run Keyword And Ignore Error    enable deepsleep Mode
    [Teardown]    Run keywords
    ...    Run Keyword And Ignore Error    Disable NR Test Dedicated State
    ...    AND    selenium logout and close browser
    ...    AND    SISO Coam Test Teardown
[1]Energy-Efficiency_load_50_busy_hour_AQQJ_slotwiseload_NRTDD
    Run Keyword And Ignore Error    disable deepsleep Mode
    Enable NR Test Dedicated State
    Activate RD mode
    sleep    1min
    Start NR downlink test slotwiseload TDD    type_of_load=slotWiseLoad    level_of_load_slot_wise=load_50_busy_hour
    sleep    30min
    &{dict_counter_values_load_50}    CB008962 Get Counter Value
    &{dict_counter_value_ABIP}    Get Counter Value for ABIP_ABIQ
    Set Suite Variable    &{dict_counter_values_load_50}
    Write load_50_busy PM counter value to excel
    #Run Keyword And Ignore Error    enable deepsleep Mode
    [Teardown]    Run keywords
    ...    Run Keyword And Ignore Error    Disable NR Test Dedicated State
    ...    AND    selenium logout and close browser
    ...    AND    SISO Coam Test Teardown
[1]Energy-Efficiency_load_70_AQQJ_slotwiseload_NRTDD
    Run Keyword And Ignore Error    disable deepsleep Mode
    Enable NR Test Dedicated State
    Activate RD mode
    sleep    1min
    Start NR downlink test slotwiseload TDD    type_of_load=slotWiseLoad    level_of_load_slot_wise=load_70
    sleep    30min
    &{dict_counter_values_load_70}    CB008962 Get Counter Value
    &{dict_counter_value_ABIP}    Get Counter Value for ABIP_ABIQ
    Set Suite Variable    &{dict_counter_values_load_70}
    Write load_70 PM counter value to excel
    #Run Keyword And Ignore Error    enable deepsleep Mode
    [Teardown]    Run keywords
    ...    Run Keyword And Ignore Error    Disable NR Test Dedicated State
    ...    AND    selenium logout and close browser
    ...    AND    SISO Coam Test Teardown