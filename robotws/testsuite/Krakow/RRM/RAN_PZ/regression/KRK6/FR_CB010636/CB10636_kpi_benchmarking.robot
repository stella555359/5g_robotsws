*** Settings ***
Documentation
...   Suite for testing KPI benchmarking
...   author: Jakub Bak
...   contact: jakub.1.bak@nokia.com

Library      taf.rfrl.bts.devices.du.du_operations.GnbDuOperations                                  WITH NAME    duoperations
Library      testsuite/Krakow/RRM/RAN_PZ/regression/KRK6/FR_CB010636/resources/kpi_benchmark.py     WITH NAME    kpi

Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     testsuite/Krakow/RRM/RAN_PZ/regression/KRK6/FR_CB010636/resources/suite_specific_keywords.robot
Resource     testsuite/Krakow/RRM/RAN_PZ/regression/KRK6/FR_CB010636/resources/benchmarking_keywords.robot

Suite Setup      Common Suite Setup
Suite Teardown   Common Suite Teardown

*** Variables ***

${SCOUT_TL_NAME}                            7_7_UTE5GCLOUDT8SK050
${SCOUT_TOP_KPI_25R3_ID}                    1454
${SCOUT_TEMPLATE_ID}=                       1454
${API_KEY_SCOUT}                            685b6257-e313-4c4d-abe0-acc0780fbee1
${API_KEY}                                  685b6257-e313-4c4d-abe0-acc0780fbee1
${TARGET_SW}=                               SBTS00_ENB_9999_251015_000023


*** Test Cases ***
General_SiSo_Auto_KPI_PM_Counters_benchmarking
    [Setup]    Test Setup Benchmarking
    ${ref_sw_version}=            duoperations.get bts sw version
    ${ref_start}   ${ref_end}     CB010636 KPI Scenario with PM Intervals
    Log Action To Console    SW upgrade in progress
    kpi.upgrade_bts_sw       ${TARGET_SW}
    Log Action To Console    SW upgrade done succesfully
    Sleep   5min
    ${current_sw_version}=        duoperations.get bts sw version
    ${curent_start}   ${curent_end}    CB010636 KPI Scenario with PM Intervals
    Log Action to Console    Wait for 20 min
    Sleep   20min
    Trigger and Verify Scout Report
    ...     scout_tl_name=${SCOUT_TL_NAME}
    ...     template_id=${SCOUT_TEMPLATE_ID}
    ...     api_key=${API_KEY}
    ...     ref_sw_version=${ref_sw_version}
    ...     current_sw_version=${current_sw_version}
    ...     reference_start_time=${ref_start}
    ...     reference_end_time=${ref_end}
    ...     current_start_time=${curent_start}
    ...     current_end_time=${curent_end}
    [Teardown]  UE Teardown
