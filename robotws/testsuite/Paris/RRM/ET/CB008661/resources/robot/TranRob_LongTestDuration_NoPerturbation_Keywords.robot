*** Settings ***
Documentation   :copyright: Nokia
...             :author/s: denis.taupin@nokia.com, gerard.bonhaure@nokia.com
...             :contact/s: denis.taupin@nokia.com
...             :description: Generic resource widely used by transversal robustness test suites

Library         ../python/alarms_handler.py                 WITH NAME    alms_hdlr
Library         taf.sbts.oam.coam.admin                     WITH NAME    sbts_coam
Library         ta_emss
Library         ../python/createUeScenario.py
Library         ../python/createFullScenario.py
Library         ../python/createMasterScenario.py


*** Variables ***
${IS_SUB_SCE_RUNNING}                                       False
${Verdict_Background_Traffic_Monitoring_In_Background}      FAILED
${branchName}                                               SBTS00

*** Keywords ***
Start Pmc Monitoring robot
    [Arguments]   ${step_name}    ${granularity}
    Set Environment Variable    IS_SUB_SCE_RUNNING    ${IS_SUB_SCE_RUNNING}

    start_pmcIdTimerService_python    ${granularity}

    ${start_pmc_mon_thread}   ${stop_pmc_mon_event}    start_pmc_background_monitoring_python
    ...    ${LOG_PATH}/PM
    ...    ${CURDIR}/../../config/counter/constraint/${step_name}.csv
    ...    ${branchName}
    set suite variable   ${start_pmc_mon_thread}
    set suite variable   ${stop_pmc_mon_event}

Stop Pmc Monitoring robot
    stop_pmc_background_monitoring_python
    ...    ${stop_pmc_mon_event}
    ...    ${start_pmc_mon_thread}

    stop_pmcIdTimerService_python

Start Sce Background Robot
    [Arguments]    ${background_duration}    ${UE_Scenario}
    Set Suite Variable     ${path_scenario}         ${CURDIR}/../../config/background_scenario/
    Set Suite Variable     ${UE_Scenario}         ${path_scenario}/${UE_Scenario}
    Set Suite Variable     ${master_scenario}    master_scenario.sce
    Set Suite Variable     ${Verdict_Background_Scenario}    FAILED
    write_to_report        Start Background Scenario
    write_to_report        createUeScenario UeScenario = ${UE_Scenario} - path = ${path_scenario}
    createUeScenario       ${UE_Scenario}    ${path_scenario}
    write_to_report        createFullScenario path = ${path_scenario} - backround duration = ${background_duration}
    createFullScenario     ${path_scenario}    ${background_duration}
    write_to_report        createMasterScenario path = ${path_scenario} - master_scenario = ${master_scenario}
    createMasterScenario    ${path_scenario}    ${master_scenario}

    write_to_report        start telnet scenario path = ${path_scenario}
    ${start_sce_bkg_thread}   ${stop_sce_bkg_event}    start_sce_background_python
    ...    ${path_scenario}
    ...    ${OUTPUT_DIR}
    set suite variable   ${start_sce_bkg_thread}
    set suite variable   ${stop_sce_bkg_event}

Stop Sce Background robot
    stop_sce_background_python
    ...    ${stop_sce_bkg_event}
    ...    ${start_sce_bkg_thread}

Start Btslog Monitoring robot
    ${root_tmp_dir}               Set Variable     /tmp/btslog2
    ${sub_res_dir_prefix}         Set Variable     ${root_tmp_dir}/ERR_OCC
    ${filter_file_dir}            Set Variable     ${CURDIR}/../../config/syslog/exclusion
    create_btslog_analysis_instance
    ...    root_tmp_dir=${root_tmp_dir}
    ...    sub_res_dir_prefix=${sub_res_dir_prefix}
    ...    inc_filter_file=${filter_file_dir}/patternInclude.csv
    ...    exc_filter_file=${filter_file_dir}/patternExclude.csv
    ...    loop_inter=30
    Start Btslog Monitoring python

Stop Btslog Monitoring robot
    Stop Btslog Monitoring python

Wait For Pm Period Index
    [Arguments]    ${expected_pm_period}
    wait_for_pm_period_index_python    ${expected_pm_period}
