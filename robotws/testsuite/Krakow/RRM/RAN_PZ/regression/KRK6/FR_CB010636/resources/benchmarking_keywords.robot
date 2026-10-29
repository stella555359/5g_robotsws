*** Settings ***
Documentation
...   author: Jakub Bak
...   contact: jakub.1.bak@nokia.com
...   maintainer: jakub.1.bak@nokia.com

Library     DateTime                                                                                WITH NAME    dt
Library     taf.rfrl.bts.devices.du.du_operations.GnbDuOperations                                   WITH NAME    duoperations
Library     taf.rfrl.bts.devices.du.pm_counters.GnbPmCounter                                        WITH NAME    gnbcounter
Library     taf.rfrl.utilities.logger.custom_logger                                                 WITH NAME    logger
Library     testsuite/Krakow/RRM/RAN_PZ/regression/KRK6/FR_CB010636/resources/suite_specific_keywords.py
Library     testsuite/Krakow/RRM/RAN_PZ/regression/KRK6/FR_CB010636/resources/kpi_benchmark.py      WITH NAME    kpi

Resource    taf/rfrl/procedures/SISO/General_SiSo_KPI_PM_Counters_benchmarking.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    testsuite/Krakow/RRM/RAN_PZ/regression/KRK6/FR_CB010636/resources/suite_specific_keywords.robot



*** Keywords ***
Trigger and Verify Scout Report
    [Arguments]               ${scout_tl_name}    ${template_id}    ${api_key}    ${reference_start_time}
    ...                       ${reference_end_time}    ${current_start_time}    ${current_end_time}
    ...                       ${ref_sw_version}        ${current_sw_version}
    ${report_id}=             kpi.trigger_report        scout_tl_name=${scout_tl_name}
    ...                                                 template_id=${template_id}
    ...                                                 first_period_description=${ref_sw_version}
    ...                                                 second_period_description=${current_sw_version}
    ...                                                 api_key=${api_key}
    ...                                                 reference_start_time=${reference_start_time}
    ...                                                 reference_end_time=${reference_end_time}
    ...                                                 current_start_time=${current_start_time}
    ...                                                 current_end_time=${current_end_time}
    Sleep                                               5min
    timer.wait_until_keyword_succeeds_timer             5min
    ...                                                 15s
    ...                                                 Validate Scout Report Is Ready
    ...                                                 report_id=${report_id}
    scout_comparator.validate_report                    report_id=${report_id}
    Robot Log Result                                    Scout report validated successfully!
    ...                                                 to_console=${True}

CB010636 KPI Scenario with PM Intervals
    [Documentation]    MFBI related scenario for KPI gathering which is executed between PM intervals. KW retruns PM
    ...                Intervals start and end time
    Wait for next PM Interval    5min
    ${start_datetime}=     kpi.Correct Time For Scout
    FOR    ${i}    IN RANGE    1    5
        Log Action to Console     \nNRDC KPI Scenario Start loop ${i}\n
        Test Scenario with CB10636
        ${end_datetime}=     kpi.Correct Time For Scout
        Wait for next PM Interval    5min
    END
    [Return]    ${start_datetime}    ${end_datetime}


Test Scenario with CB10636
    [Documentation]   CB10636 related scenario test
    Attach 5G NSA UE to Cell A
    Start Uplink and Downlink TCP Data Transmission    duration=5s
    Stop Uplink and Downlink Data Transmission
    Detach UE
    Attach 5G NSA UE to Cell B
    Start Uplink and Downlink TCP Data Transmission    duration=5s
    Stop Uplink and Downlink Data Transmission
    Detach UE
    Attach 5G NSA UE to Cell C
    Start Uplink and Downlink TCP Data Transmission    duration=5s
    Stop Uplink and Downlink Data Transmission
    Detach UE
    Attach 5G NSA UE to Cell D
    Start Uplink and Downlink TCP Data Transmission    duration=5s
    Stop Uplink and Downlink Data Transmission
    Detach UE


Wait For Next PM Interval
    [Arguments]    ${interval}=5min
    [Documentation]   KW for waiting to next PM Counters Interval
    Log Action to Console    Wait For Next PM Interval
    gnbcounter.Wait For Next Pm Period    ${interval}    delay=0
