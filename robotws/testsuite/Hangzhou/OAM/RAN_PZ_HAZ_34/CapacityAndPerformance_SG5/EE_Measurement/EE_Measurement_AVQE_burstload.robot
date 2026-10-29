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
[1]CB008962-SR-F-Energy-Efficiency_03_Medium_TM1-1_offset-5.1db_AVQE_burstload
    disable deepsleep Mode
    Enable NR Test Dedicated State
    Activate RD mode
    sleep    1min
    Start NR downlink test    power_backoff=${51}    beam_id=${951}
    ...    test_model=NR-FR1-TM1.1.ETSI    type_of_load=burstLoad    level_of_load_burst=burst_13_5
    sleep    30min
    &{dict_counter_values_medium_load}    CB008962 Get Counter Value
    Set Suite Variable    &{dict_counter_values_medium_load}
    Write medium load PM counter value to excel
    #Run Keyword And Ignore Error    Stop NR downlink test
    [Teardown]    Run keywords
    ...    Run Keyword And Ignore Error    disable NR Test Dedicated State
    ...    AND    Run Keyword And Ignore Error    enable deepsleep Mode
    ...    AND    selenium logout and close browser
    ...    AND    SISO Coam Test Teardown
[1]CB008962-SR-F-Energy-Efficiency_04_Busy_TM1-1_offset-2.9db_AVQE_burstload
    disable deepsleep Mode
    Enable NR Test Dedicated State
    Activate RD mode
    sleep    1min
    Start NR downlink test    power_backoff=${29}     beam_id=${951}
    ...    test_model=NR-FR1-TM1.1.ETSI    type_of_load=burstLoad    level_of_load_burst=burst_13_5
    sleep    30min
    &{dict_counter_values_busy_load}    CB008962 Get Counter Value
    Set Suite Variable    &{dict_counter_values_busy_load}
    Write busy load PM counter value to excel
    #Run Keyword And Ignore Error    Stop NR downlink test
    [Teardown]    Run keywords
    ...    Run Keyword And Ignore Error    disable NR Test Dedicated State
    ...    AND    Run Keyword And Ignore Error    enable deepsleep Mode
    ...    AND    selenium logout and close browser
    ...    AND    SISO Coam Test Teardown
[1]CB008962-SR-F-Energy-Efficiency_05_Full_TM1-1_offset0db_AVQE_burstload
    disable deepsleep Mode
    Enable NR Test Dedicated State
    Activate RD mode
    sleep    1min
    Start NR downlink test    power_backoff=${0}     beam_id=${951}
    ...    test_model=NR-FR1-TM1.1.ETSI    type_of_load=burstLoad    level_of_load_burst=burst_13_5
    sleep    30min
    &{dict_counter_values_full_load}    CB008962 Get Counter Value
    Set Suite Variable    &{dict_counter_values_full_load}
    Write full load PM counter value to excel
    #Run Keyword And Ignore Error    Stop NR downlink test
    Run Keyword And Ignore Error    enable deepsleep Mode
    [Teardown]    Run keywords
    ...    Run Keyword And Ignore Error    disable NR Test Dedicated State
    ...    AND    Run Keyword And Ignore Error    enable deepsleep Mode
    ...    AND    selenium logout and close browser
    ...    AND    SISO Coam Test Teardown
