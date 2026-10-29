*** Settings ***
Suite Setup          CB008962 test suite setup without configure BWF
Suite Teardown       CB008962 test suite teardown
Test Setup           SISO Coam Test Setup
#Test Teardown        SISO Coam Test Teardown
Test Timeout         6h

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

[1]CB008962-SR-F-Energy-Efficiency_01_Idle_Cell_locked_AVQE
    enable deepsleep Mode
    Selenium Login And Disable Screen Lock
    Get X2 link shutdown waiting time
    Block cells and check status    block_list=${cell_id_list}   check_alarm=${True}    gnb_type='${gNb_CuType}'
    sleep    30min
    &{dict_counter_values_lock}    CB008962 Get Counter Value
    Set Suite Variable    &{dict_counter_values_lock}
    Write lock PM counter value to excel
    [Teardown]    Run keywords    selenium logout and close browser
    ...    AND    UnBlock Cells and check status with deep sleep    block_list=${cell_id_list}   check_alarm=${True}    gnb_type='${gNb_CuType}'
    ...    AND    SISO Coam Test Teardown
[1]CB008962-SR-F-Energy-Efficiency_02_Low_Cell_Onair_AVQE
    Run Keyword And Ignore Error    enable deepsleep Mode
    Perform BTS Site Reset
    sleep    5min
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    sleep    30min
    &{dict_counter_values_onAir}    CB008962 Get Counter Value
    Set Suite Variable    &{dict_counter_values_onAir}
    selenium logout and close browser
    Write onair PM counter value to excel
    [Teardown]    Run keywords    selenium logout and close browser
    ...    AND    SISO Coam Test Teardown
[1]CB008962-SR-F-Energy-Efficiency_03_Medium_TM1-1_offset-5.1db_AVQE
    Run Keyword And Ignore Error    disable deepsleep Mode
    Enable NR Test Dedicated State
    Start NR downlink test    power_backoff=${51}    beam_id=${951}
    sleep    30min
    &{dict_counter_values_medium_load}    CB008962 Get Counter Value
    Set Suite Variable    &{dict_counter_values_medium_load}
    #Stop NR downlink test
    Write medium load PM counter value to excel
    #Run Keyword And Ignore Error    enable deepsleep Mode
    [Teardown]    Run keywords
    ...    Run Keyword And Ignore Error    disable NR Test Dedicated State
    ...    AND    selenium logout and close browser
    ...    AND    SISO Coam Test Teardown
[1]CB008962-SR-F-Energy-Efficiency_04_Busy_TM1-1_offset-2.9db_AVQE
    Run Keyword And Ignore Error    disable deepsleep Mode
    Enable NR Test Dedicated State
    Start NR downlink test    power_backoff=${29}     beam_id=${951}
    sleep    30min
    &{dict_counter_values_busy_load}    CB008962 Get Counter Value
    Set Suite Variable    &{dict_counter_values_busy_load}
    #Stop NR downlink test
    Write busy load PM counter value to excel
    [Teardown]    Run keywords
    ...    Run Keyword And Ignore Error    disable NR Test Dedicated State
    ...    AND    selenium logout and close browser
    ...    AND    SISO Coam Test Teardown
[1]CB008962-SR-F-Energy-Efficiency_05_Full_TM1-1_offset0db_AVQE
    Run Keyword And Ignore Error    disable deepsleep Mode
    Enable NR Test Dedicated State
    Start NR downlink test    power_backoff=${0}     beam_id=${951}
    sleep    30min
    &{dict_counter_values_full_load}    CB008962 Get Counter Value
    Set Suite Variable    &{dict_counter_values_full_load}
    #Stop NR downlink test
    Write full load PM counter value to excel
    #Run Keyword And Ignore Error    enable deepsleep Mode
    [Teardown]    Run keywords
    ...    Run Keyword And Ignore Error    disable NR Test Dedicated State
    ...    AND    selenium logout and close browser
    ...    AND    SISO Coam Test Teardown
