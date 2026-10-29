*** Settings ***
Documentation   :copyright: Nokia
...             :author/s: denis.taupin@nokia.com, gerard.bonhaure@nokia.com
...             :contact/s: denis.taupin@nokia.com
...             :description: Generic resource widely used by transversal robustness test suites

Library         OperatingSystem
Library         ../python/alarms_handler.py                 WITH NAME    alms_hdlr
Library         taf.sbts.oam.coam.admin                     WITH NAME    sbts_coam
Library         ta_emss
Library         ../python/createUeScenario.py
Library         ../python/createFullScenario.py
Library         ../python/createMasterScenario.py
Library         ../python/TranRob_LongTestDuration_NoPerturbation_util.py
Library         ../python/merge_scout_histo_nr_files.py

*** Variables ***
${IS_SUB_SCE_RUNNING}                                       False
${Verdict_Background_Traffic_Monitoring_In_Background}      FAILED
${branchName}                                               SBTS00

# Telnet optimization parameters
${TELNET_VERBOSE_MODE}                                      ${False}
${TELNET_CMDS_PER_CONNECTION}                               10

# variables for Scout
&{scout_templates_dict}                                     2238=5G TOP KPI 25R3                   1271=5G TOP KPI 25R3
...                                                         3217=5G TOP KPI 26R2 AND ROB LEGACY    1809=5G TOP KPI 26R2 AND ROB LEGACY

&{SCOUT_RD_RECORDS}
${SCOUT_TEMPLATE_PATTERN}                                           26R2

# BSR custom beamset packages git repository
${BSR_git_path}         gitlabe1.ext.net.nokia.com/nps_vrf_8_and_9/bsr.git


*** Keywords ***
Do TranRob TMO LTD Prelude
    [Arguments]       ${FEATURE_ROOT_DIR}=${CURDIR}/../..    @{delta_commissioning_files}

    ${commissioning_result}    Set Variable    NA

    ${background_scenario_name}
    ...               Fetch From Left                                        ${background_sce}      .
                      Set Suite Variable                                     ${background_scenario_name}
                      Set Environment Variable                               SCOUT_PM_PERIOD_START_DATE    None
                      Set Environment Variable                               SCOUT_PM_PERIOD_STOP_DATE     None

    ${nb_of_pm_period_for_zoi}
    ...               Get Number Of Pm Period Account From Jenkins
                      Run keyword if                                         ${nb_of_pm_period_for_zoi} != "dummy_account"
    ...               Overwrite Number Loop Before And Backgroud Duration    ${nb_of_pm_period_for_zoi}

                      Scout.Enable Full Kpi Pm Collection

    Init Sequence     _
                      write_to_report    INF: Do TranRob TMO LTD Prelude: FEATURE_ROOT_DIR = ${FEATURE_ROOT_DIR}
                      write_to_report    INF: Do TranRob TMO LTD Prelude: Number of commissioning files = ${delta_commissioning_files.__len__()}
                      FOR    ${file}    IN    @{delta_commissioning_files}
                          write_to_report    INF: Do TranRob TMO LTD Prelude: DELTA_COMMISSIONING_JSON = ${file}
                      END
    Step              Archive And Compare Topology Configs
    Step              Step_TL_Init    ${FEATURE_ROOT_DIR}    TranRobTmo    tranrobtmo    FR1_TMO    activate_sherpa    no_tti    fifo_debug=0
                      write_to_report                                        INF: Step TL Restart
    Step              Step_TL_Restart
                      write_to_report                                        INF: Sleep 30s
                      Sleep                                                  30s

    step              Load BSR file                             ${TMO_AEHC_6_H6_ALN60_ARP60_P00_Dic}

                      # Apply all commissioning files if provided
                      FOR    ${comm_file}    IN    @{delta_commissioning_files}
                          write_to_report   INF: Applying commissioning file: ${comm_file}
                          ${commissioning_result}=    Run Keyword and Ignore Error
    ...                   Json Recommissioning             delta_file=${comm_file}
                          write_to_report   INF: Do TranRob TMO LTD Prelude: commissioning_result = ${commissioning_result}
                      END

    Step              alms_hdlr.allowed_alarms_before_precondition
    Step              alms_hdlr.start_watchdog_alarms
    Step              alms_hdlr.check_detected_alarms

                      write_to_report                                        :::::::::: startWTS ::::::::::
    Step              startWTS

    Step              alms_hdlr.check_detected_alarms

                      write_to_report                                        INF: pmIntervalMin = ${pm_interval_min} minutes
                      write_to_report                                        INF: pmIntervalSec = ${pm_interval_sec} seconds
                      write_to_report                                        INF: backgroundDurationSec = ${background_duration} seconds
    Step              Update_Kpi_Dict                                        ${KPI_DICTIONARY}            ${pm_interval_sec}

    Step              Start Sce Background robot                             ${background_duration}       ${background_sce}
                      write_to_report                                        INF: wait 600 seconds for scenario to start
                      Sleep                                                  600s

    Step              alms_hdlr.disallow_alarms_after_precondition
    Step              alms_hdlr.check_detected_alarms
                      alms_hdlr.stop_watchdog_alarms
                      alms_hdlr.allowed_alarms_after_precondition
                      alms_hdlr.start_watchdog_alarms

                      write_to_report                                        :::::::::: start PmcId Timer Service ::::::::::
    Step              Start PmcId Timer Service Robot                        ${pm_interval_min}

                      write_to_report                                        :::::::::: WAIT FOR BEGIN OF 1st PM PERIOD ::::::::::
    Step              Wait For Pm Period Index                               expected_pm_period=1

                      write_to_report                                        :::::::::: PM_PERIOD_INDEX = %{PM_PERIOD_INDEX} ::::::::::
                      write_to_report                                        :::::::::: PM_PERIOD_START_DATE = %{PM_PERIOD_START_DATE} ::::::::::

Do TranRob RJIO LTD Prelude
    [Arguments]           ${FEATURE_ROOT_DIR}=${CURDIR}/../..    @{delta_commissioning_files}

    ${commissioning_result}    Set Variable    NA

    ${background_scenario_name}
    ...               Fetch From Left                                        ${background_sce}      .
                      Set Suite Variable                                     ${background_scenario_name}
                      Set Environment Variable                               SCOUT_PM_PERIOD_START_DATE    None
                      Set Environment Variable                               SCOUT_PM_PERIOD_STOP_DATE     None

    ${nb_of_pm_period_for_zoi}
    ...               Get Number Of Pm Period Account From Jenkins
                      Run keyword if                                         ${nb_of_pm_period_for_zoi} != "dummy_account"
    ...               Overwrite Number Loop Before And Backgroud Duration    ${nb_of_pm_period_for_zoi}

                      Scout.Enable Full Kpi Pm Collection
    Init Sequence     _
                      write_to_report    INF: Do TranRob RJIO LTD Prelude: FEATURE_ROOT_DIR = ${FEATURE_ROOT_DIR}
                      write_to_report    INF: Do TranRob RJIO LTD Prelude: Number of commissioning files = ${delta_commissioning_files.__len__()}
                      FOR    ${file}    IN    @{delta_commissioning_files}
                          write_to_report    INF: Do TranRob RJIO LTD Prelude: DELTA_COMMISSIONING_JSON = ${file}
                      END
    Step              Step_TL_Init    ${FEATURE_ROOT_DIR}    TranRobRjio    tranrobrjio    FR1_RJIO_5_2    activate_sherpa    no_tti    fifo_debug=0
    Step              Step_TL_Restart
                      Sleep                                                  30s

    step              Load BSR file                                          ${RJIO_AQQJ_6_H6_ALN45_ARP45_P00_Dic}

                      # Apply all commissioning files if provided
                      FOR    ${comm_file}    IN    @{delta_commissioning_files}
                          write_to_report   INF: Applying commissioning file: ${comm_file}
                          ${commissioning_result}=    Run Keyword and Ignore Error
    ...                   Json Recommissioning             delta_file=${comm_file}
                          write_to_report   INF: Do TranRob RJIO LTD Prelude: commissioning_result = ${commissioning_result}
                      END

    Step              alms_hdlr.allowed_alarms_before_precondition
    Step              alms_hdlr.start_watchdog_alarms
    Step              alms_hdlr.check_detected_alarms

    Step              startWTS

    Step              alms_hdlr.check_detected_alarms

    Step              Update_Kpi_Dict                                        ${KPI_DICTIONARY}            ${pm_interval_sec}
    Step              Start Sce Background robot                             ${background_duration}       ${background_sce}      ${isX2LinkUp}
                      Sleep                                                  600s

    Step              alms_hdlr.disallow_alarms_after_precondition
    Step              alms_hdlr.check_detected_alarms

    Step              Start PmcId Timer Service Robot                        ${pm_interval_min}
    Step              Wait For Pm Period Index                               expected_pm_period=1
                      write_to_report                                        :::::::::: PM_PERIOD_INDEX = %{PM_PERIOD_INDEX} ::::::::::
                      write_to_report                                        :::::::::: PM_PERIOD_START_DATE = %{PM_PERIOD_START_DATE} ::::::::::

Do TranRob TMO LTD Postlude
    Step              Stop PmcId Timer Service Robot
    Step              alms_hdlr.check_detected_alarms
                    # Log_Allowed_and_Detected_Alarms
    ${alm_summary}    get_alarms_check_failed_summary      ${ListStep}
                      write_to_report                      ${alm_summary}
    Step              alms_hdlr.stop_watchdog_alarms
    Step              Stop Sce Background robot
    Step              Step_Postlude
                      Scout.Disable Full Kpi Pm Collection
    ${date}           Get Current Date    result_format=%Y%m%d_%H%M%S
    ${output_name}    Set Variable    NR_HISTO_SUMMARY_${date}.xlsx
    ${excel_file}     Merge Scout Histo NR Files    ${SCOUT_LOG_DIR}   ${output_name}
                      write_to_report    :::::::::: NR_HISTO_SUMMARY = ${excel_file} ::::::::::

Do TranRob LTD Postlude
    Step              Stop PmcId Timer Service Robot
    Step              alms_hdlr.check_detected_alarms
    ${alm_summary}    get_alarms_check_failed_summary      ${ListStep}
                      write_to_report                      ${alm_summary}
    Step              alms_hdlr.stop_watchdog_alarms
    Step              Stop Sce Background robot
    Step              Step_Postlude
                      Scout.Disable Full Kpi Pm Collection
    ${date}           Get Current Date    result_format=%Y%m%d_%H%M%S
    ${output_name}    Set Variable    NR_HISTO_SUMMARY_${date}.xlsx
    ${excel_file}     Merge Scout Histo NR Files    ${SCOUT_LOG_DIR}   ${output_name}
                      write_to_report    :::::::::: NR_HISTO_SUMMARY = ${excel_file} ::::::::::

Start PmcId Timer Service Robot
    [Arguments]   ${granularity}
    start_pmcIdTimerService_python    ${granularity}
    Sleep       15

Stop PmcId Timer Service Robot
    stop_pmcIdTimerService_python

Start Background Monitoring robot
    [Arguments]   ${step_name}    ${granularity}
    Set Environment Variable    IS_SUB_SCE_RUNNING    ${IS_SUB_SCE_RUNNING}

    ${start_pmc_mon_thread}   ${stop_pmc_mon_event}    start_pmc_background_monitoring_python
    ...    ${LOG_PATH}/PM
    ...    ${CURDIR}/../../config/counter/constraint/${step_name}_${granularity}min.csv
    ...    ${branchName}
    set suite variable   ${start_pmc_mon_thread}
    set suite variable   ${stop_pmc_mon_event}

Stop Background Monitoring robot
    stop_pmc_background_monitoring_python
    ...    ${stop_pmc_mon_event}
    ...    ${start_pmc_mon_thread}

Start Sce Background Robot
    [Arguments]    ${background_duration}    ${UE_Scenario}    ${isX2LinkUp}=${True}
    ...    ${verbose}=${TELNET_VERBOSE_MODE}
    ...    ${cmds_per_connection}=${TELNET_CMDS_PER_CONNECTION}
    Set Suite Variable     ${path_scenario}         ${CURDIR}/../../config/background_scenario/
    Set Suite Variable     ${UE_Scenario}         ${path_scenario}/${UE_Scenario}
    Set Suite Variable     ${master_scenario}    master_scenario.txt
    Set Suite Variable     ${Verdict_Background_Scenario}    FAILED
    write_to_report        Start Background Scenario
    write_to_report        createUeScenario UeScenario = ${UE_Scenario} - path = ${path_scenario}
    write_to_report    :::::::::: DTN250715: Start Sce Background Robot - isX2LinkUp = ${isX2LinkUp} ::::::::::
    write_to_report    :::::::::: DTN251203: Start Sce Background Robot - verbose = ${verbose} ::::::::::
    write_to_report    :::::::::: DTN251203: Start Sce Background Robot - cmds_per_connection = ${cmds_per_connection} ::::::::::
    write_to_report    :::::::::: DTN250715: Start Sce Background Robot - path_scenario = ${path_scenario} ::::::::::
    write_to_report    :::::::::: DTN250715: Start Sce Background Robot - UE_Scenario = ${UE_Scenario} ::::::::::
    write_to_report    :::::::::: DTN250715: Start Sce Background Robot - master_scenario = ${master_scenario} ::::::::::
    write_to_report    :::::::::: DTN250715: Start Sce Background Robot - OUTPUT_DIR = ${OUTPUT_DIR} ::::::::::
    createUeScenario       ${UE_Scenario}    ${path_scenario}
    write_to_report        createFullScenario path = ${path_scenario} - background duration = ${background_duration}
    createFullScenario     ${path_scenario}    ${background_duration}
    write_to_report        createMasterScenario path = ${path_scenario} - master_scenario = ${master_scenario}
    createMasterScenario    ${path_scenario}    ${master_scenario}
    OperatingSystem.Copy Directory    ${path_scenario}/UeScenario    ${OUTPUT_DIR}/UeScenario
    OperatingSystem.Copy File         ${UE_Scenario}                 ${OUTPUT_DIR}/UeScenario/
    write_to_report        UeScenario directory and scenario file copied to ${OUTPUT_DIR}/UeScenario
    write_to_report        start telnet scenario path = ${path_scenario}
    ${start_sce_bkg_thread}   ${stop_sce_bkg_event}   ${thread_log_file}=    start_sce_background_python
    ...    ${path_scenario}
    ...    ${OUTPUT_DIR}
    ...    ${isX2LinkUp}
    ...    ${verbose}
    ...    ${cmds_per_connection}
    set suite variable   ${start_sce_bkg_thread}
    set suite variable   ${stop_sce_bkg_event}
    set suite variable   ${thread_log_file}
    write_to_report    :::::::::: DTN250715: Start Sce Background Robot - start_sce_bkg_thread = ${start_sce_bkg_thread} ::::::::::
    write_to_report    :::::::::: DTN250715: Start Sce Background Robot - stop_sce_bkg_event = ${stop_sce_bkg_event} ::::::::::
    write_to_report    :::::::::: DTN250715: Start Sce Background Robot - thread_log_file = ${thread_log_file} ::::::::::
    Afficher Thread Log Sce    ${thread_log_file}

Stop Sce Background robot
    write_to_report    :::::::::: DTN250715: Stop Sce Background robot - start_sce_bkg_thread = ${start_sce_bkg_thread} ::::::::::
    write_to_report    :::::::::: DTN250715: Stop Sce Background robot - stop_sce_bkg_event = ${stop_sce_bkg_event} ::::::::::
    stop_sce_background_python
    ...    ${stop_sce_bkg_event}
    ...    ${start_sce_bkg_thread}
    ...    ${thread_log_file}
    write_to_report    :::::::::: DTN250715: Stop Sce Background robot - thread_log_file = ${thread_log_file} ::::::::::
    Afficher Thread Log Sce    ${thread_log_file}

Afficher Thread Log Sce
    [Arguments]    ${thread_log_file}
    ${content}=    OperatingSystem.Get File    ${thread_log_file}
    write_to_report    ${content}

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


TranRob_Background
    [Arguments]        ${perturbation_sce}    ${step_name_suffix}    ${start_pm_index}    ${nb_loop}
    Set Suite Variable     ${Step_Background_Is_Run_Checks_Pass}    ${False}
    write_to_report    :::::::::: DTN250715: SCOUT_PM_PERIOD_START_DATE ini = %{SCOUT_PM_PERIOD_START_DATE} ::::::::::
    write_to_report    :::::::::: DTN250715: SCOUT_PM_PERIOD_STOP_DATE ini = %{SCOUT_PM_PERIOD_STOP_DATE} ::::::::::
    ${stop_pm_index}   Evaluate    ${start_pm_index} + ${nb_loop} - 1
    write_to_report    :::::::::: DTN250715: start_pm_index = ${start_pm_index} ::::::::::
    write_to_report    :::::::::: DTN250715: stop_pm_index = ${stop_pm_index} ::::::::::
    Set Scout Range Date If Current Pm Period Index    pm_period_index=${start_pm_index}   env_var_name=SCOUT_PM_PERIOD_START_DATE
    write_to_report    :::::::::: DTN250715: SCOUT_PM_PERIOD_START_DATE = %{SCOUT_PM_PERIOD_START_DATE} ::::::::::
    Set Scout Range Date If Current Pm Period Index    pm_period_index=${stop_pm_index}    env_var_name=SCOUT_PM_PERIOD_STOP_DATE
    write_to_report    :::::::::: DTN250715: SCOUT_PM_PERIOD_STOP_DATE = %{SCOUT_PM_PERIOD_STOP_DATE} ::::::::::
    write_to_report        INF: TranRob_Background before Step_Background - Step_Background_Is_Run_Checks_Pass=${Step_Background_Is_Run_Checks_Pass}
    Step               Step_Background
    ...                timeout=12hours   perturbation_sce=${perturbation_sce}   reportingIntervalPm=${pm_interval_min}min
    ...                step_name_suffix=${step_name_suffix}     KPI_DICTIONARY=${KPI_DICTIONARY}
    write_to_report        INF: TranRob_Background after Step_Background - Step_Background_Is_Run_Checks_Pass=${Step_Background_Is_Run_Checks_Pass}
    # BHR begin 30/10/2025 : rework alrm history managment
    Step               alms_hdlr.check_detected_alarms
    ${last_step_status}    Get Last Step Status
                           Run Keyword If                     '${last_step_status}' == 'PASS'
    ...                    write_to_report                    INF: run_checks - detected alarm PASS
    ...                    ELSE
    ...                    write_to_report                    ERR: run_checks - detected alarm FAIL
                           alms_hdlr.stop_watchdog_alarms
                           alms_hdlr.allowed_alarms_after_precondition
                           alms_hdlr.start_watchdog_alarms
    # BHR end
    ${is_detected_alarm_pass}=    Evaluate    '${last_step_status}' == 'PASS'
    write_to_report    ::::::::::::::::::::::::::::::::::::::::::::::::::::
    ${runCheck_and_alarms}=      Evaluate    ${Step_Background_Is_Run_Checks_Pass} and ${is_detected_alarm_pass}
    write_to_report        INF: TranRob_Background - runCheck_and_alarms=${runCheck_and_alarms}
    Run Keyword If         not ${runCheck_and_alarms}     FAIL    failure during run_checks and/or alarms

Set Scout Range Date If Current Pm Period Index
    [Arguments]                   ${pm_period_index}       ${env_var_name}
    ${result}                     get_pm_period_date_if_current_pm_period_index_python         ${pm_period_index}
    Run Keyword If                "${result}" == "None"     Return From Keyword                ${result}
    Set Environment Variable      ${env_var_name}                                              ${result}

Update Scout Range Date Dictionary Records
    [Arguments]                                                       ${step_name_suffix}   ${test_name_prefix}=${TEST NAME}
    ${record}                     Create Dictionary                   name=${test_name_prefix}_${step_name_suffix}
    ...                                                               start=%{SCOUT_PM_PERIOD_START_DATE}
    ...                                                               stop=%{SCOUT_PM_PERIOD_STOP_DATE}
    ...                                                               short_name=${step_name_suffix}
    write_to_report    :::::::::: DTN250715: UpdateScoutDict - record = ${record} ::::::::::
    ${index}                      Get Length                          ${SCOUT_RD_RECORDS}
    write_to_report    :::::::::: DTN250715: UpdateScoutDict - index = ${index} ::::::::::
    ${key}                        Convert To String                   ${index}
    write_to_report    :::::::::: DTN250715: UpdateScoutDict - key = ${key} ::::::::::
    Set To Dictionary             ${SCOUT_RD_RECORDS}             ${key}=${record}
    write_to_report    :::::::::: DTN250715: UpdateScoutDict - SCOUT_RD_RECORDS = ${SCOUT_RD_RECORDS} ::::::::::

Extract Kpi Code From Test Case Name
    ${tc_name}                    Set Variable                        ${TEST NAME}
  # Handles all KPI naming variants:
  #   1. NR_1234a          (standard)
  #   2. SCOUT_NR_1234a    (with SCOUT_ prefix, any number of digits)
  #   3. SCOUT_NR_1234a_Else  (with SCOUT_ prefix and _Else suffix)
  # The SCOUT_ prefix and _Else suffix are stripped; only the canonical KPI code is returned.
    ${pattern}=                   Set Variable    (?:SCOUT_)?((?:NR|MRBTS)_[0-9]+[a-z]?)(?:_Else)?
    ${result}=    Evaluate    re.search(r'''${pattern}''', '''${tc_name}''').group(0) if re.search(r'''${pattern}''', '''${tc_name}''') else None
    [Return]      ${result}

Extract Pm Id From Test Case Name
    ${tc_name}=                   Set Variable                        ${TEST NAME}
    ${pattern}=                   Set Variable                        M55[0-9]+C[0-9]+
    ${result}=    Evaluate    re.search(r'''${pattern}''', '''${tc_name}''').group(0) if re.search(r'''${pattern}''', '''${tc_name}''') else None
    [Return]      ${result}

Initialize Scout Api Token
    ${my_token}                   Scout.Get Api Token
                                  Set Suite Variable                  ${PERSONAL_SCOUT_TOKEN}         ${my_token}
    write_to_report    \n:::::::::: DTN250715: scout api token is initialized with : ${PERSONAL_SCOUT_TOKEN} ::::::::::

Get Template Ids For Pattern
    [Arguments]                   ${pattern}=${SCOUT_TEMPLATE_PATTERN}
    # Returns template IDs whose value contains ${pattern}, in insertion order (not sorted).
    # Example: pattern=25R3 → [2238, 1271]  |  pattern=26R2 → [2825, 1640]
    ${ids}=                       Evaluate
    ...                           [k for k, v in $scout_templates_dict.items() if '${pattern}' in v]
    [Return]                      ${ids}

Loop On Range Date Records To Post Process Scout Kpi History
    [Timeout]    60 seconds
    Initialize Scout Api Token
    ${kpi_code}                   Extract Kpi Code From Test Case Name
    ${pm_id}                      Extract Pm Id From Test Case Name
    # Determine mode: PM counter (M55xxx) takes precedence over KPI (NR_xxx / MRBTS_xxx)
    ${is_pm_mode}=                Evaluate                            '${pm_id}' != 'None' and '${kpi_code}' == 'None'
    ${active_id}=                 Set Variable If                     ${is_pm_mode}    ${pm_id}    ${kpi_code}

                                  Run Keyword If                      '${active_id}' != 'None'
        ...                       Log to console                      Extracted Id: ${active_id} (pm_mode=${is_pm_mode})
                                  Run Keyword If                      '${active_id}' == 'None'
        ...                       Log to console                      No match found!

    write_to_report    \n:::::::::: loopRangeDatePostProcessScoutKpiHistory - active_id = ${active_id} - is_pm_mode = ${is_pm_mode} ::::::::::
    write_to_report    :::::::::: DTN250715: loopRangeDatePostProcessScoutKpiHistory - SCOUT_RD_RECORDS = ${SCOUT_RD_RECORDS} ::::::::::

    # Initialize failure tracking
    ${failed_iterations}          Set Variable                        0
    @{failed_keys}                Create List

    FOR    ${key}    IN    @{SCOUT_RD_RECORDS.keys()}
        ${record}=                Get From Dictionary                 ${SCOUT_RD_RECORDS}             ${key}
        ${step_name_suffix}       Get From Dictionary                 ${record}                       name
        ${start_date}             Get From Dictionary                 ${record}                       start
        ${stop_date}              Get From Dictionary                 ${record}                       stop
        ${short_step_name_suff}   Get From Dictionary                 ${record}                       short_name

        ${filenames_suffix_tmp}   Catenate                            SEPARATOR=_
        ...                                                           ${start_date}                   ${stop_date}
        ${filenames_suffix}       Replace String                      ${filenames_suffix_tmp}         ${SPACE}                _

        ${filename_kpi_history}   Catenate                            SEPARATOR=_
        ...                                                           ${step_name_suffix}             ${filenames_suffix}
        ${pmi}                    Catenate                            SEPARATOR=                      ${pm_interval_min}      min
        write_to_report    :::::::::: DTN250715: loopRangeDatePostProcessScoutKpiHistory - key = ${key} ::::::::::
        write_to_report    :::::::::: DTN250715: loopRangeDatePostProcessScoutKpiHistory - record = ${record} ::::::::::
        write_to_report    :::::::::: DTN250715: loopRangeDatePostProcessScoutKpiHistory - step_name_suffix = ${step_name_suffix} ::::::::::
        write_to_report    :::::::::: DTN250715: loopRangeDatePostProcessScoutKpiHistory - start_date = ${start_date} ::::::::::
        write_to_report    :::::::::: DTN250715: loopRangeDatePostProcessScoutKpiHistory - stop_date = ${stop_date} ::::::::::
        write_to_report    :::::::::: DTN250715: loopRangeDatePostProcessScoutKpiHistory - filename_kpi_history = ${filename_kpi_history} ::::::::::
        write_to_report    :::::::::: BHR251124: loopRangeDatePostProcessScoutKpisReport - short_name = ${short_step_name_suff} ::::::::::

        # --- Branch: PM counter (M55xxx) vs KPI (NR_xxx / MRBTS_xxx) ---
        IF    ${is_pm_mode}
            ${history_res}        Run Keyword and Ignore Error
            ...                   Scout.Get Pm History               pm_id=${pm_id}                  start_date=${start_date}
            ...                                                      stop_date=${stop_date}          interval=${pm_interval_min}
            write_to_report    :::::::::: loopRangeDatePostProcessScoutKpiHistory - PM history_res = ${history_res} ::::::::::
            ${status}             Set Variable                        ${history_res[0]}
            ${histo_csv_res}      Run Conditional Keyword And Capture Result                          '${status}' == 'PASS'
            ...                   Scout.Convert Pm History To Csv File
            ...                                                       ${pm_id}                        ${history_res}
            ...                                                       ${SCOUT_LOG_DIR}                ${filename_kpi_history}.csv
        ELSE
            ${history_res}        Run Keyword and Ignore Error
            ...                   Scout.Get Kpi History               kpi_code=${kpi_code}            start_date=${start_date}
            ...                                                                                       stop_date=${stop_date}
            write_to_report    :::::::::: DTN250715: loopRangeDatePostProcessScoutKpiHistory - kpi_history_res = ${history_res} ::::::::::
            ${status}             Set Variable                        ${history_res[0]}
            ${histo_csv_res}      Run Conditional Keyword And Capture Result                          '${status}' == 'PASS'
            ...                   Scout.Convert Kpi History To Csv File
            ...                                                       ${kpi_code}                     ${history_res}
            ...                                                       ${SCOUT_LOG_DIR}                ${filename_kpi_history}.csv
        END
        write_to_report    :::::::::: DTN250715: loopRangeDatePostProcessScoutKpiHistory - histo_csv_res = ${histo_csv_res} ::::::::::

        # --- Common post-processing ---
        ${status}                 Set variable                        ${histo_csv_res[0]}
        ${kpis_histo_csv_res1}    Set variable                        ${histo_csv_res[1]}
        write_to_report    :::::::::: DTN250715: loopRangeDatePostProcessScoutKpiHistory - kpis_histo_csv_res1 = ${kpis_histo_csv_res1} ::::::::::
        write_to_report    :::::::::: DTN250715: loopRangeDatePostProcessScoutKpiHistory - active_id = ${active_id} ::::::::::
        ${constraint_files_dir}   Set variable                        ${CURDIR}/../../config/counter/constraint/
        ${constraint_files_pref}  Set variable                        ${short_step_name_suff}_${pmi}
        ${scout_kpi_histo_eval_res}           Run Keyword and Ignore Error        Scout.Analyze Scout Kpi History
        ...                                                           ${active_id}
        ...                                                           ${kpis_histo_csv_res1}
        ...                                                           ${constraint_files_dir}
        ...                                                           ${constraint_files_pref}
        IF  '${scout_kpi_histo_eval_res[1]}' == 'True'
            Log               Execution test case passed successfully for key ${key}
            write_to_report    :::::::::: PASS: Iteration ${key} succeeded ::::::::::
        ELSE
            Log               WARNING: Execution test case FAILED for key ${key} in Scout.py::scout_kpi_history_analyzer    level=WARN
            write_to_report    :::::::::: FAIL: Iteration ${key} failed - continuing with next iteration ::::::::::
            ${failed_iterations}    Evaluate    ${failed_iterations} + 1
            Append To List    ${failed_keys}    ${key}
        END
        write_to_report    :::::::: DTN250715: loopRangeDatePostProcessScoutKpiHistory - Hist evaluation res: = ${scout_kpi_histo_eval_res[1]} :::::
    END

    # Check if any iterations failed and report
    write_to_report    \n:::::::::: Loop completed - Total iterations: ${SCOUT_RD_RECORDS.__len__()} ::::::::::
    write_to_report    :::::::::: Failed iterations: ${failed_iterations} ::::::::::
    IF    ${failed_iterations} > 0
        write_to_report    :::::::::: Failed keys: ${failed_keys} ::::::::::
        Fail    ${failed_iterations} iteration(s) failed: ${failed_keys}
    END

Loop On Range Date Records To Post Process Scout Kpis Report
    Initialize Scout Api Token

    # Global verdict: set to FAIL as soon as one iteration fails
    ${loop_verdict}               Set Variable                        PASS

    FOR    ${key}    IN    @{SCOUT_RD_RECORDS.keys()}
        ${record}=                Get From Dictionary                 ${SCOUT_RD_RECORDS}             ${key}
        ${step_name_suffix}       Get From Dictionary                 ${record}                       name
        ${start_date}             Get From Dictionary                 ${record}                       start
        ${stop_date}              Get From Dictionary                 ${record}                       stop
        ${short_step_name_suff}   Get From Dictionary                 ${record}                       short_name
        write_to_report    \n:::::::::: DTN250715: loopRangeDatePostProcessScoutKpisReport - key = ${key} ::::::::::
        write_to_report    :::::::::: DTN250715: loopRangeDatePostProcessScoutKpisReport - SCOUT_RD_RECORDS = ${SCOUT_RD_RECORDS} ::::::::::
        write_to_report    :::::::::: DTN250715: loopRangeDatePostProcessScoutKpisReport - record = ${record} ::::::::::
        write_to_report    :::::::::: DTN250715: loopRangeDatePostProcessScoutKpisReport - step_name_suffix = ${step_name_suffix} ::::::::::
        write_to_report    :::::::::: DTN250715: loopRangeDatePostProcessScoutKpisReport - start_date = ${start_date} ::::::::::
        write_to_report    :::::::::: DTN250715: loopRangeDatePostProcessScoutKpisReport - stop_date = ${stop_date} ::::::::::
        write_to_report    :::::::::: BHR251124: loopRangeDatePostProcessScoutKpisReport - short_name = ${short_step_name_suff} ::::::::::

        # 1. Post Process Scout kpis Report
        ${pp_status}    ${pp_msg}    Run Keyword And Ignore Error
        ...                       Post Process Scout kpis Report     ${step_name_suffix}   ${start_date}    ${stop_date}   ${short_step_name_suff}
        IF    '${pp_status}' == 'FAIL'
            write_to_report    :::::::::: FAIL: key=${key} - Post Process Scout kpis Report: ${pp_msg} ::::::::::
            ${loop_verdict}    Set Variable    FAIL
            Continue For Loop
        END

        # 2. Update Scout Journal For The Latest Evaluation
        ${jnl_status}    ${jnl_msg}    Run Keyword And Ignore Error
        ...                       Update Scout Journal For The Latest Evaluation       ${step_name_suffix}   ${start_date}    ${stop_date}
        IF    '${jnl_status}' == 'FAIL'
            write_to_report    :::::::::: FAIL: key=${key} - Update Scout Journal: ${jnl_msg} ::::::::::
            ${loop_verdict}    Set Variable    FAIL
            Continue For Loop
        END

        # 3. Compare Scout Last Report With Previous One
        ${cmp_status}    ${cmp_msg}    Run Keyword And Ignore Error
        ...                       Compare Scout Last Report With Previous One
        IF    '${cmp_status}' == 'FAIL'
            write_to_report    :::::::::: FAIL: key=${key} - Compare Scout Last Report: ${cmp_msg} ::::::::::
            ${loop_verdict}    Set Variable    FAIL
            Continue For Loop
        END

        write_to_report    :::::::::: PASS: Iteration ${key} succeeded ::::::::::
    END

    # Final keyword verdict
    write_to_report    \n:::::::::: Loop completed - Total iterations: ${SCOUT_RD_RECORDS.__len__()} ::::::::::
    write_to_report    :::::::::: loop_verdict = ${loop_verdict} ::::::::::
    Run Keyword If    '${loop_verdict}' == 'FAIL'    Fail    One or more iterations failed - see report above

Post Process Scout kpis Report
    [Arguments]                         ${step_name_suffix}             ${start_date}        ${stop_date}     ${short_step_name_suff}
    Set Suite Variable                  ${scout_kpi_eval_res}           ${EMPTY}

    ${filenames_suffix_tmp}       Catenate                            SEPARATOR=_
    ...                                                               ${start_date}                   ${stop_date}
    ${filenames_suffix}           Replace String                      ${filenames_suffix_tmp}         ${SPACE}                _

    ${filename_kpis_report}       Catenate                            SEPARATOR=_
    ...                                                               ${step_name_suffix}             ${filenames_suffix}
    write_to_report    :::::::::: DTN250715: postProcessScoutKpisReport - filename_kpis_report = ${filename_kpis_report} ::::::::::

    ${pmi}                        Catenate                            SEPARATOR=                      ${pm_interval_min}      min
    write_to_report    :::::::::: DTN250715: postProcessScoutKpisReport - pm_interval_min = ${pm_interval_min} ::::::::::
    write_to_report    :::::::::: DTN250715: postProcessScoutKpisReport - pmi = ${pmi} ::::::::::

    ${template_id_list}           Get Template Ids For Pattern
    ${template_id}                Get From List                       ${template_id_list}             0
    write_to_report    :::::::::: DTN250715: postProcessScoutKpisReport - scout_templates_dict = ${scout_templates_dict} ::::::::::
    write_to_report    :::::::::: DTN250715: postProcessScoutKpisReport - template_id_list = ${template_id_list} ::::::::::
    write_to_report    :::::::::: DTN250715: postProcessScoutKpisReport - template_id = ${template_id} ::::::::::

    ${kpis_report_res}            Run Keyword and Ignore Error
    ...                           Scout.Get Kpis Report               report_name=${filename_kpis_report}
    ...                                                               template_id=${template_id}      start_date=${start_date}
    ...                                                                                               stop_date=${stop_date}
    write_to_report    :::::::::: DTN250715: postProcessScoutKpiReport - kpis_report_res ::::::::::

    ${status}                     Set Variable                        ${kpis_report_res[0]}
    write_to_report    :::::::::: DTN250715: postProcessScoutKpisReport - status = ${status} ::::::::::
    ${kpis_report_csv_res}        Run Conditional Keyword And Capture Result                          '${status}' == 'PASS'
    ...                           Scout.Convert Kpis Report To Csv File
    ...                                                               ${kpis_report_res}              ${SCOUT_LOG_DIR}
    ...                                                               ${filename_kpis_report}.csv
    write_to_report    :::::::::: DTN250715: postProcessScoutKpisReport - kpis_report_csv_res = ${kpis_report_csv_res} ::::::::::

    ${status}                     Run Keyword If    ${kpis_report_csv_res} != ${None}    Set variable    ${kpis_report_csv_res[0]}
    ...                           ELSE    Set variable    FAIL
    write_to_report    :::::::::: DTN250715: postProcessScoutKpisReport - status = ${status} ::::::::::

    ${kpis_report_csv_res_part1}  Run Keyword If    ${kpis_report_csv_res} != ${None}    Set variable    ${kpis_report_csv_res[1]}
    ...                           ELSE    Set variable    ${EMPTY}

    ${constraint_files_dir}   Set variable                            ${CURDIR}/../../config/counter/constraint/
    ${constraint_files_pref}  Set variable                            ${short_step_name_suff}_${pmi}

    write_to_report    :::::::::: DTN250715: postProcessScoutKpisReport - kpis_report_csv_res_part1 = ${kpis_report_csv_res_part1} ::::::::::

    ${scout_kpi_eval_res}         Run Conditional Keyword And Capture Result                          '${status}' == 'PASS'
    ...                           Scout.Evaluate Constraints Multiple Files
    ...                                                               ${constraint_files_dir}
    ...                                                               ${constraint_files_pref}
    ...                                                               ${kpis_report_csv_res_part1}

    write_to_report  ::::: DTN250715: postProcessScoutKpisReport - constraint file: ${constraint_files_dir}${constraint_files_pref}.csv :::::
    write_to_report    :::::::::: DTN250715: postProcessScoutKpisReport - scout_kpi_eval_res = ${scout_kpi_eval_res} ::::::::::
                                  Set Suite Variable                  ${scout_kpi_eval_res}

Run Conditional Keyword And Capture Result
    [Arguments]    ${condition}    ${keyword}    @{args}
    ${result}=    Run Keyword If    ${condition}    Run Keyword and Ignore Error    ${keyword}    @{args}
    [Return]    ${result}

Update Scout Journal For The Latest Evaluation
    [Arguments]    ${step_name_suffix}   ${start}     ${stop}
    # 1. Need variables to be set
    ${eval_status}                Run Keyword If    ${scout_kpi_eval_res} != ${None}    Set Variable    ${scout_kpi_eval_res[0]}
    ...                           ELSE    Set Variable    FAIL
    ${scout_jnl_file_name}        Set Variable                        journal.csv
    ${scout_jnl_local_path}       Set Variable                        /tmp/${scout_jnl_file_name}
    # ${scout_jnl_remote_path}      Set Variable          /mnt/titan/ET/feature/${long_feature_name}/Scout/${branchName}/${scout_jnl_file_name}
    ${scout_jnl_remote_path}      Set Variable          /ceph/VRF/COMMON/TranRob/${long_feature_name}/Scout/${branchName}/${scout_jnl_file_name}
    ${template_id_list}           Get Template Ids For Pattern
    ${template_id}                Get From List                       ${template_id_list}             0
    ${template_name}              Get From Dictionary                 ${scout_templates_dict}    ${template_id}

    # 2. Needed Variable to update scout journal line entry
    # 1.current_date       2.step_name_suffix          3.start_date         4.stop_date          5.testline_name
    # 2025-05-13 19:17:37  Background_13UEs_TMO_15min  2025-05-13 17:00:00  2025-05-13 17:15:00  7_20_UTE5GCLASSTL059

    # 6.software_load                7.evaluation_status
    # SBTS00_ENB_9999_250511_000003  PASS

    ${current_date}               Get Current Date                    result_format=%Y-%m-%d %H:%M:%S              # Colomn 1
    ${step_name_suffix}           Set Variable                        ${step_name_suffix}_${pm_interval_min}min    # Colomn 2
    ${start_date}                 Set Variable                        ${start}                                     # Colomn 3
    ${stop_date}                  Set Variable                        ${stop}                                      # Colomn 4
    ${tl_name}                    sco_uti.get_testline_name                                                        # Colomn 5
    ${software_load}              Set Variable                        ${TGNB_DU[0].GNB_VERSION}                    # Colomn 6
    ${eval_status}                Run Keyword If    ${scout_kpi_eval_res} != ${None}    Set Variable    ${scout_kpi_eval_res[0]}
    ...                           ELSE    Set Variable    FAIL                                                     # Colomn 7
    ${template_id}                Set Variable                        ${template_name}                             # Colomn 8

                                  write_to_report                     :::::::::: Varaible Definition for Journaling ::::::::::
                                  write_to_report                     ------------------------------------------------------------
                                  write_to_report                     :::::::::: current_date = ${current_date} ::::::::::
                                  write_to_report                     :::::::::: step_name_suffix = ${step_name_suffix} ::::::::::
                                  write_to_report                     :::::::::: start_date = ${start_date} ::::::::::
                                  write_to_report                     :::::::::: stop_date = ${stop_date} ::::::::::
                                  write_to_report                     :::::::::: tl_name = ${tl_name} ::::::::::
                                  write_to_report                     :::::::::: software_load = ${software_load} ::::::::::
                                  write_to_report                     :::::::::: eval_status = ${eval_status} ::::::::::
                                  Write To Report                     :::::::::: template_id = ${template_id} ::::::::::

    ${line}                       Create Dictionary
    ...                                                               current_date          ${current_date}
    ...                                                               step_name_suffix      ${step_name_suffix}
    ...                                                               start_date            ${start_date}
    ...                                                               stop_date             ${stop_date}
    ...                                                               testline_name         ${tl_name}
    ...                                                               software_load         ${software_load}
    ...                                                               evaluation_status     ${eval_status}
    ...                                                               template_id           ${template_id}
    ${status}                     Scout.Update Scout Journal                ${line}   ${scout_jnl_local_path}   ${scout_jnl_remote_path}

Compare Scout Last Report With Previous One
    ${scout_jnl_file_name}        Set Variable                        journal.csv
    ${scout_jnl_local_path}       Set Variable                        /tmp/${scout_jnl_file_name}
    # ${remote_path}                Set Variable   /mnt/titan/ET/feature/${long_feature_name}/Scout/${branchName}/${scout_jnl_file_name}
    ${remote_path}                Set Variable     /ceph/VRF/COMMON/TranRob/${long_feature_name}/Scout/${branchName}/${scout_jnl_file_name}
    ${template_id_list}           Get Template Ids For Pattern
    ${template_id}                Get From List                       ${template_id_list}             1
    ${result}                     Scout.Compare Two Scout Reports           ${template_id}    ${scout_jnl_local_path}    ${remote_path}

    ${first_report}               Get From List                       ${result}                       0
    ${meta}                       Get From Dictionary                 ${first_report}                 meta
    ${report_display}             Get From Dictionary                 ${meta}                         report_display
    ${template_id_str}            Convert To String                   ${template_id}
    ${template_report}            Get From Dictionary                 ${report_display}               ${template_id_str}
    ${comparator_report_pk}       Get From Dictionary                 ${template_report}              comparator_report_pk
    ${comparator_report_pk}       Convert To String                   ${comparator_report_pk}
    write_to_report               INF: comparator_report_pk extracted from path meta/report_display/${template_id_str}
    write_to_report               INF: comparator_report_pk = ${comparator_report_pk}

    ${output_filename_fullpath}   Set Variable                        ${SCOUT_LOG_DIR}/BENCHMARK_REPORT_ID_${comparator_report_pk}.xlsx
    write_to_report               INF: comparator_report output_filename_fullpath = ${output_filename_fullpath}

    Sleep    300s
    IF    $comparator_report_pk is not None and $comparator_report_pk != ''
        Scout.Fetch Scout Comparator Report To Excel    ${comparator_report_pk}    ${output_filename_fullpath}
    ELSE
        write_to_report    INF: Skip fetch comparator report to Excel because comparator_report_pk is empty or None
    END

Merge Scout Histo NR Files
    [Documentation]    Merge multiple NR_*.csv files into a single Excel pivot file
    ...                Uses the Python library merge_scout_histo_nr_files.py
    ...                Automatically searches for KPI descriptions in constraint files
    ...
    ...                Arguments:
    ...                - source_directory: Path to the directory containing NR_*.csv files
    ...                - output_file: (Optional) Output Excel file name. Default: NR_Summary.xlsx
    ...
    ...                Returns:
    ...                - Path to the created Excel file
    ...
    ...                Example:
    ...                | ${result}= | Merge Scout Histo NR Files | ${SCOUT_LOG_DIR} |
    ...                | ${result}= | Merge Scout Histo NR Files | ${SCOUT_LOG_DIR} | custom_output.xlsx |
    [Arguments]    ${source_directory}    ${output_file}=${NONE}

    write_to_report    :::::::::: Merge Scout Histo NR Files ::::::::::
    write_to_report    :::::::::: source_directory = ${source_directory} ::::::::::
    write_to_report    :::::::::: output_file = ${output_file} ::::::::::

    ${result_path}=    Run Keyword If    $output_file is $NONE
    ...    merge_nr_files    ${source_directory}
    ...    ELSE
    ...    merge_nr_files    ${source_directory}    ${output_file}

    write_to_report    :::::::::: Merged file created: ${result_path} ::::::::::

    [Return]    ${result_path}


Load BSR file
    [Documentation]         Load BSR file to enable the use of Spatial Managed UE position
    [Arguments]             ${BSR_Dic}

    Dated Log New Line     ===> Download BSR file ${BSR_Dic.BSR_file_name}
    Download Package Using Git Update OAM
    ...                                 git_path=${BSR_git_path}
    ...                                 git_folder=${BSR_Dic.BSR_folder}
    ...                                 git_file_name=${BSR_Dic.BSR_file_name}
    ...                                 target_dir=${LOG_PATH}/BSR


Get Number Of Pm Period Account From Jenkins
    [Documentation]
    ...       Retrieve from Jenkins the NB_OF_PM_PERIOD_FOR_ZOI to evaluate dynamically
	...       several TC needed periods.
    ...
    ...                *Definitions:*
    ...                - PM Period Account: Unassign Interger casted as string that will used for
	...                  TC case durations calculation. It must be set in the environment variable
    ...                  %{NB_OF_PM_PERIOD_ACCOUNT_FOR_ZOI_DURATION}.
    ...                - Dummy account: If the environment variable is not set, a dummy_account
	...                  is returned.
    ...
    ...                *Arguments:*
    ...                - None.
    ...
    ...                *Returned value:*
    ...                - ${NB_OF_PM_PERIOD_FOR_ZOI}
    IF    '%{NB_OF_PM_PERIOD_FOR_ZOI}' == ''
        Dated Log    WARNING: %{NB_OF_PM_PERIOD_ACCOUNT_FOR_ZOI_DURATION} is not set. Using dummy account.
        ${NB_OF_PM_PERIOD_FOR_ZOI}    Set Variable    dummy_account
    ELSE
        ${NB_OF_PM_PERIOD_FOR_ZOI}    Set Variable    %{NB_OF_PM_PERIOD_FOR_ZOI}
        Dated log   INF : NB_OF_PM_PERIOD_FOR_ZOI = ${NB_OF_PM_PERIOD_FOR_ZOI}
    END
    [Return]    ${NB_OF_PM_PERIOD_FOR_ZOI}

Overwrite Number Loop Before And Backgroud Duration
    [Arguments]    ${nb_of_pm_period_for_zoi}
    set suite variable    ${Nb_loop_before}    ${nb_of_pm_period_for_zoi}
    ${my_duration_in_second}   Evaluate    ${Nb_loop_before} * ${pm_interval_sec} + 3600
    set suite variable    ${background_duration}    ${my_duration_in_second}

Scout Data Teardown
    [Documentation]    Teardown personnalisé pour produire les données Scout après chaque test
    Dated Log    Executing Scout data teardown for test: ${TEST NAME}
    Run Keyword And Ignore Error    Produce Scout Data
    Dated Log    Scout data production completed for test: ${TEST NAME}

Archive And Compare Topology Configs
    [Documentation]    Archive topology_configs directory and compare scfc.xml files
    ...                Creates a tar archive and generates a diff report

    write_to_report    :::::::::: Archive And Compare Topology Configs - START ::::::::::

    # Find the correct execution directory (1, 2, or 3)
    ${exec_num}    Set Variable    ${NONE}
    FOR    ${num}    IN RANGE    1    4
        ${exec_path}    Set Variable    /home/ute/.ute-ca/executions/${num}/configs/topology_configs
        ${path_exists}    Run Keyword And Return Status    Directory Should Exist    ${exec_path}
        Run Keyword If    ${path_exists}    Set Suite Variable    ${exec_num}    ${num}
        Exit For Loop If    ${path_exists}
    END

    Run Keyword If    '${exec_num}' == '${NONE}'    Fail    No valid execution directory found (1, 2, or 3)

    ${base_path}    Set Variable    /home/ute/.ute-ca/executions/${exec_num}/configs
    ${topology_path}    Set Variable    ${base_path}/topology_configs
    write_to_report    INF: Using execution directory: ${exec_num}
    write_to_report    INF: Topology configs path: ${topology_path}

    # Create Installation directory in OUTPUT_DIR
    ${installation_dir}    Set Variable    ${OUTPUT_DIR}/Installation
    Create Directory    ${installation_dir}
    write_to_report    INF: Installation directory created: ${installation_dir}

    # Create tar archive of topology_configs
    ${date}    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${tar_file}    Set Variable    ${installation_dir}/topology_configs_${date}.tar.gz
    ${tar_result}    Run Process    tar    -czf    ${tar_file}    -C    ${base_path}    topology_configs
    Run Keyword If    ${tar_result.rc} != 0    Fail    Failed to create tar archive: ${tar_result.stderr}
    write_to_report    INF: Tar archive created: ${tar_file}

    # Read chosen variant
    ${chosen_variant_file}    Set Variable    ${topology_path}/node_1/chosen_variant
    ${variant_exists}    Run Keyword And Return Status    File Should Exist    ${chosen_variant_file}

    Run Keyword If    not ${variant_exists}    write_to_report    WARNING: chosen_variant file not found: ${chosen_variant_file}
    Return From Keyword If    not ${variant_exists}

    ${chosen_variant}    OperatingSystem.Get File    ${chosen_variant_file}
    ${chosen_variant}    Strip String    ${chosen_variant}
    write_to_report    INF: Chosen variant: ${chosen_variant}

    # Define paths for diff
    ${backup_file}    Set Variable    ${topology_path}/node_1/backup/scfc.xml.bk
    ${variant_file}    Set Variable    ${topology_path}/node_1/${chosen_variant}/scfc.xml

    ${backup_exists}    Run Keyword And Return Status    File Should Exist    ${backup_file}
    ${variant_exists}    Run Keyword And Return Status    File Should Exist    ${variant_file}

    Run Keyword If    not ${backup_exists}    write_to_report    WARNING: Backup file not found: ${backup_file}
    Run Keyword If    not ${variant_exists}    write_to_report    WARNING: Variant file not found: ${variant_file}
    Return From Keyword If    not ${backup_exists} or not ${variant_exists}

    # Perform diff comparison
    ${diff_file}    Set Variable    ${installation_dir}/scfc_diff_${date}.txt
    ${diff_result}    Run Process    diff    -u    ${backup_file}    ${variant_file}    stdout=${diff_file}    stderr=STDOUT

    write_to_report    INF: Diff file created: ${diff_file}
    write_to_report    INF: Diff comparison between backup and variant files
    write_to_report    INF: Backup file: ${backup_file}
    write_to_report    INF: Variant file: ${variant_file}

    # Read and filter diff content to show only changes
    ${diff_content}    OperatingSystem.Get File    ${diff_file}
    ${filtered_diff}    Filter Diff Content    ${diff_content}

    write_to_report    ========== SCFC.XML DIFF COMPARISON - START ==========
    write_to_report    ${filtered_diff}
    write_to_report    ========== SCFC.XML DIFF COMPARISON - END ==========

    write_to_report    :::::::::: Archive And Compare Topology Configs - END ::::::::::

Filter Diff Content
    [Documentation]    Filter diff output to show only changed lines (- and +)
    [Arguments]    ${diff_content}

    @{lines}    Split To Lines    ${diff_content}
    @{filtered_lines}    Create List

    FOR    ${line}    IN    @{lines}
        # Skip empty lines
        ${line_length}    Get Length    ${line}
        Continue For Loop If    ${line_length} == 0

        # Get first character
        ${first_char}    Get Substring    ${line}    0    1

        # Get first three characters for header detection
        ${first_three}    Run Keyword If    ${line_length} >= 3
        ...    Get Substring    ${line}    0    3
        ...    ELSE    Set Variable    ${line}

        # Check if it's a header (---, +++, or @@)
        ${is_header}    Evaluate    '''${first_three}''' in ['---', '+++'] or '''${first_char}''' == '@'

        # Add if starts with - or + but is not a header
        ${is_change}    Evaluate    '''${first_char}''' in ['-', '+'] and not ${is_header}
        Run Keyword If    ${is_change}    Append To List    ${filtered_lines}    ${line}
    END

    ${filtered_text}    Run Keyword If    ${filtered_lines.__len__()} > 0
    ...    Catenate    SEPARATOR=\n    @{filtered_lines}
    ...    ELSE    Set Variable    No changes detected

    ${summary}    Set Variable    Total changes: ${filtered_lines.__len__()} lines
    ${result}    Catenate    SEPARATOR=\n    ${summary}    ${EMPTY}    ${filtered_text}

    [Return]    ${result}


Run Test Segment
    [Documentation]    Execute one background or perturbation segment.
    ...                ${segment_type}     : 'background' or 'perturbation'
    ...                ${oam_action}       : optional 'activate'/'deactivate' (background only)
    ...                ${test_name_prefix} : optional prefix forwarded to Update Scout Range Date Dictionary Records
    [Arguments]    ${segment_type}    ${oam_action}=${None}    ${test_name_prefix}=${None}
    IF    '${segment_type}' == 'background'
        ${start_pm_index}    Get Start PM Index For Background    ${bkg_segment_id}
        ${Nb_loop}           Get Nb Loop For Background           ${bkg_segment_id}
        IF    '${oam_action}' != '${None}'
            Online Oam Activate Deactivate Feature robot    ${oam_action}
        END
        ${step_name_suffix}    Set Variable    ${background_scenario_name}
        FOR    ${i}    IN RANGE    ${Nb_loop}
            Run Keyword And Continue On Failure    TranRob_Background    wait    ${step_name_suffix}    ${start_pm_index}    ${Nb_loop}
        END
        IF    '${test_name_prefix}' != '${None}'
            Update Scout Range Date Dictionary Records    ${step_name_suffix}    test_name_prefix=${test_name_prefix}
        ELSE
            Update Scout Range Date Dictionary Records    ${step_name_suffix}
        END
        Set Suite Variable    ${bkg_segment_id}    ${${bkg_segment_id} + 1}
    ELSE IF    '${segment_type}' == 'perturbation'
        ${start_pm_index}        Get Start PM Index For Perturbation    ${pert_segment_id}
        ${Nb_loop}               Get Nb Loop For Perturbation           ${pert_segment_id}
        ${perturbation_sce}      Get Perturbation Sce File              ${pert_segment_id}
        ${perturbation_name}     Fetch From Left    ${perturbation_sce}    .
        ${step_name_suffix}      Set Variable    ${background_scenario_name}_${perturbation_name}
        FOR    ${i}    IN RANGE    ${Nb_loop}
            Run Keyword And Continue On Failure    TranRob_Background    ${perturbation_sce}    ${step_name_suffix}
            ...                                                          ${start_pm_index}    ${Nb_loop}
        END
        IF    '${test_name_prefix}' != '${None}'
            Update Scout Range Date Dictionary Records    ${step_name_suffix}    test_name_prefix=${test_name_prefix}
        ELSE
            Update Scout Range Date Dictionary Records    ${step_name_suffix}
        END
        Set Suite Variable    ${pert_segment_id}    ${${pert_segment_id} + 1}
    ELSE
        Fail    Unknown segment_type '${segment_type}' — expected 'background' or 'perturbation'
    END
