*** Settings ***
Documentation
...    Author:        yue.2.liu@nokia-sbell.com
...    Maintainer:    yue.2.liu@nokia-sbell.com

Library    taf.sw.scout    WITH NAME    scout
Library    ./scout_counter.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    taf/rfrl/procedures/SISO/General_SiSo_KPI_PM_Counters_benchmarking.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot

*** Variables ***
${api_key}    c8174890-43ba-42d8-bb5b-5e8401927045

*** Keywords ***
Generate KPI Report through scout
    [Arguments]    ${scout_tl}
    ${tl_on_scout}    run keyword and return status    scout.setup_scout    scout_testline_name=${scout_tl}    api_key=${api_key}
    return from keyword if    '${tl_on_scout}'=='False'
    scout.generate_kpi_report
    ...    report_name=TA_test
    ...    template_id=2440
    ...    start_time=2025-04-20T10:00:52.646000
    ...    end_time=2025-04-20T10:50:52.646000
    [Teardown]    run keyword if    ${tl_on_scout}    scout.teardown_scout_api
Generate KPI Compare Report through scout
    [Documentation]    parameter format example:first_start_time=2025-04-20T10:00:52.646000
    ...    first_end_time=2025-04-20T10:50:52.646000
    ...    second_start_time=2025-04-21T10:00:52.646000
    ...    second_end_time=2025-04-21T10:50:52.646000
    ...    first_period_description=SBTS25R2_ENB_0000_000280_000000
    ...    second_period_description=SBTS25R2_ENB_0000_000280_000000
    [Arguments]    ${scout_tl}    ${report_name}    ${first_start_time}    ${first_end_time}    ${second_start_time}
        ...    ${second_end_time}    ${second_period_description}    ${template_id}
    log to console    start to generate compare report on scout
    ${tl_on_scout}    run keyword and return status    scout.setup_scout    scout_testline_name=${scout_tl}    api_key=${api_key}
    return from keyword if    '${tl_on_scout}'=='False'
    ${template_id}    create list    ${template_id}
    ${report}=    scout.generate_comparator_report
    ...    report_name=${report_name}
    ...    template_ids=${template_id}
    ...    reference_start_time=${first_start_time}
    ...    reference_end_time=${first_end_time}
    ...    current_start_time=${second_start_time}
    ...    current_end_time=${second_end_time}
    ...    reference_period_description=SBTS00_ENB_9999_250603_000001
    ...    current_period_description=${second_period_description}
    ...    alpha_factor=0.005
    [Return]    ${report}
    [Teardown]    run keyword if    ${tl_on_scout}    scout.teardown_scout_api
Start L3 call and check dl ul throughput
    [Arguments]  ${ue_index}=${0}    ${ul_tput}=50M    ${dl_tput}=300M    ${cell_id}=${1}
    ${dl_tp}  ${ul_tp}  ${dl_exp}  ${ul_exp}    Calculate Send Tput And Expected Tput
    ...    peak_dl_tp=${dl_tput}    peak_ul_tp=${ul_tput}
    ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity
    ${cell_id}    Convert To String    ${cell_mapping[${cell_id}]['nrCellIdentity']}
    ${cell_id}    Create List    ${cell_id}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tput}
    ...    protocol=udp    duration=3600    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tput}
    ...    protocol=udp    duration=3600    ue_index=${ue_index}
    sleep    1min
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=300    check_source=Aasyslog
    ${output}    power_ue.Check Bi Tput   ue_type=${ue_type}    log=${tput_log}    cells=${cell_id}
    ...    ultarget_throughput=${ul_exp}    dltarget_throughput=${dl_exp}    target_avg_percent=0.1
    ...    min_percent=0.1
    log to console    ${output}
Detach and stop ul dl traffic
    [Arguments]   ${ue_index}=${0}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}
    power_ue.UE Detach   ue_type=${ue_type}    ue_index=${ue_index}


Perform SW rollback and check cells onAir
    log to console    start to Perform SW rollback and check cells onAir
    Selenium Login And Disable Screen Lock
    wait until keyword succeeds    1min    10s    selenium_coam.software_rollback
    sleep    10min
    COAM Wait for gnb ready and cell setup   gnb_type=SA
    [Teardown]    Selenium Logout And Close Browser
Export couter start and end datetime
    ${start_datetime_UTC8}=                         wait.wait_until_next_quarter
    ...                                             return_with_timezone=${False}
    #Start L3 call and check dl ul throughput
    #run keyword and ignore error    Detach and stop ul dl traffic
    ${cell_list}    create list    ${1}
    Get UE From Init File and Make call     cell_list=${cell_list}    with_peak=${False}    duration=${300}
    ${end_datetime_UTC8}=                           wait.wait_full_quarter_cycles
    ...                                             cycles=${1}
    sleep    1s
    ${start_datetime_UTC8}    Convert To String    ${start_datetime_UTC8}
    ${end_datetime_UTC8}    Convert To String    ${end_datetime_UTC8}
    ${start_datetime}    convert_to_utc    input_time_str=${start_datetime_UTC8}
    ${end_datetime}    convert_to_utc    input_time_str=${end_datetime_UTC8}
    log to console    ${start_datetime}
    log to console    ${end_datetime}
    [Return]    ${start_datetime}    ${end_datetime}