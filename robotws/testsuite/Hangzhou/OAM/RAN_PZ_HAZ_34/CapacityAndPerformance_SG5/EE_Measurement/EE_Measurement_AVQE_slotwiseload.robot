*** Settings ***
Suite Setup          CB008962 test suite setup without configure BWF test mode
Suite Teardown       CB012662 test suite teardown
Test Setup           SISO Coam Test Setup
#Test Teardown        SISO Coam Test Teardown
Test Timeout         16h

Resource    ../../CB008962_SG05/resource/CB008962_reource.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource     ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/operate_cell_and_check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Variables   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/made_variable.py
Resource    ${BASIC_PATH_COMMON}/SBTS_Setup_And_Teardown.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/excel_chart.py
Documentation
...    Author:liu yue
...    contact:yue.2.liu@nokia-sbell.com
...    squad group:SG_05
...    Feature CB008962 in SBTS23R2 program

Force Tags   5G_RAN    5G_RAN_TDD

*** Test Cases ***
[1]CB012662_03_TM1-1_load_0_low_AVQE_slotwiseload
    #disable deepsleep Mode
    Enable NR Test Dedicated State
    Activate RD mode
    sleep    1min
    Start NR downlink test slotwiseload
    ...    type_of_load=slotWiseLoad    level_of_load_slot_wise=load_0_low
    sleep    30min
    &{dict_counter_values_load_0_low}    CB008962 Get Counter Value
    Set Suite Variable    &{dict_counter_values_load_0_low}
    Write load_0_low PM counter value to excel
    #Run Keyword And Ignore Error    enable deepsleep Mode
    [Teardown]    Run keywords
    ...    Run Keyword And Ignore Error    Disable NR Test Dedicated State
    ...    AND    selenium logout and close browser
    ...    AND    SISO Coam Test Teardown
[1]CB012662_04_TM1-1_load_10_AVQE_slotwiseload
    #disable deepsleep Mode
    Enable NR Test Dedicated State
    Activate RD mode
    sleep    1min
    Start NR downlink test slotwiseload
    ...    type_of_load=slotWiseLoad    level_of_load_slot_wise=load_10
    sleep    30min
    &{dict_counter_values_load_10}    CB008962 Get Counter Value
    Set Suite Variable    &{dict_counter_values_load_10}
    Write load_10 PM counter value to excel
    #Run Keyword And Ignore Error    enable deepsleep Mode
    [Teardown]    Run keywords
    ...    Run Keyword And Ignore Error    Disable NR Test Dedicated State
    ...    AND    selenium logout and close browser
    ...    AND    SISO Coam Test Teardown
[1]CB012662_05_TM1-1_load_30_medium_AVQE_slotwiseload
    #disable deepsleep Mode
    Enable NR Test Dedicated State
    Activate RD mode
    sleep    1min
    Start NR downlink test slotwiseload
    ...    type_of_load=slotWiseLoad    level_of_load_slot_wise=load_30_medium
    sleep    30min
    &{dict_counter_values_load_30}    CB008962 Get Counter Value
    Set Suite Variable    &{dict_counter_values_load_30}
    Write load_30_medium PM counter value to excel
    #Run Keyword And Ignore Error    enable deepsleep Mode
    [Teardown]    Run keywords
    ...    Run Keyword And Ignore Error    Disable NR Test Dedicated State
    ...    AND    selenium logout and close browser
    ...    AND    SISO Coam Test Teardown
[1]CB012662_06_TM1-1_load_50_busy_AVQE_slotwiseload
    #disable deepsleep Mode
    Enable NR Test Dedicated State
    Activate RD mode
    sleep    1min
    Start NR downlink test slotwiseload
    ...    type_of_load=slotWiseLoad    level_of_load_slot_wise=load_50_busy_hour
    sleep    30min
    &{dict_counter_values_load_50}    CB008962 Get Counter Value
    Set Suite Variable    &{dict_counter_values_load_50}
    Write load_50_busy PM counter value to excel
    #Run Keyword And Ignore Error    enable deepsleep Mode
    [Teardown]    Run keywords
    ...    Run Keyword And Ignore Error    Disable NR Test Dedicated State
    ...    AND    selenium logout and close browser
    ...    AND    SISO Coam Test Teardown
[1]CB012662_07_TM1-1_load_70_AVQE_slotwiseload
    #disable deepsleep Mode
    Enable NR Test Dedicated State
    Activate RD mode
    sleep    1min
    Start NR downlink test slotwiseload
    ...    type_of_load=slotWiseLoad    level_of_load_slot_wise=load_70
    sleep    30min
    &{dict_counter_values_load_70}    CB008962 Get Counter Value
    Set Suite Variable    &{dict_counter_values_load_70}
    Write load_70 PM counter value to excel
    #Run Keyword And Ignore Error    enable deepsleep Mode
    [Teardown]    Run keywords
    ...    Run Keyword And Ignore Error    Disable NR Test Dedicated State
    ...    AND    selenium logout and close browser
    ...    AND    SISO Coam Test Teardown
