*** Settings ***
Documentation
...  All Keywords About Reporting

Library    taf.transport.ssh                            WITH NAME   ssh
Library    taf.ul.marvin                                WITH NAME    marvin

Resource    ../../../resources/Common/reporting.robot

Resource    performance_log_collection.robot
Resource    performance_kpi_data_manager.robot


*** Variables ***
${GRAFANA_SCRIPTS_DIR}    /home/ute/DEVELOPMENT/performance/scripts
${MARVIN_IS_RUNNING}      ${False}

*** Keywords ***
Report Tests
    [Arguments]    ${database}    ${grafana_snapshot_dir}=${P_resultTestDir}
    Run Keyword And Warn On Failure
    ...    Generate KPIData Json File And Send To Dashboard    ${grafana_snapshot_dir}    ${database}
    IF    "${TP.ENABLE_ONLINE_REPORTING}"=="true"    Run Keyword And Warn On Failure
    ...                                              Start Online Reporting


Set QC Path
    [Arguments]    ${qc_filename}
    Set Test Variable    ${QC_PATH}
    ...    testsuite/Ulm/ET/Performance_Test/resources/qc/${qc_filename}


Create UUID For Marvin
    ${core_alias}    connect.Connect to Core
    ${MARVIN_REF_RUN_ID}    ssh.Execute    command=cat /proc/sys/kernel/random/uuid    connection=${core_alias}
    Set Suite Variable    $MARVIN_REF_RUN_ID    ${MARVIN_REF_RUN_ID}


Start Marvin
    Log To Console    Start Marvin...
    ${marvin_status}    Run Keyword And Return Status    marvin.Prepare And Start Marvin
    ...                                                      ${TEST_NAME}
    ...                                                      adapter_list=${TP.CFG_MARVIN_ADAPTER_LIST}
    ...                                                      marvin_folder=${TP.CFG_MARVIN_FOLDER}
    ...                                                      common_templates=${TP.CFG_MARVIN_CT}
    ...                                                      organization=${TP.CFG_MARVIN_ORGANIZATION}
    ...                                                      marvin_side=${TP.CFG_MARVIN_SIDE}
    ...                                                      print_marvin_link=${True}
    IF    ${marvin_status}
        Set Test Variable    $MARVIN_IS_RUNNING    ${True}
    ELSE
        Set Test Variable    $MARVIN_IS_RUNNING    ${False}
        Log    Marvin Startup Failed: General Failure    level=ERROR
    END


Stop Marvin
    IF    ${MARVIN_IS_RUNNING}
        ${marvin_status}    Run Keyword And Return Status    marvin.Stop Marvin
        ...                                                      fetch_snapshot=${${TP.CFG_MARVIN_FETCH_SNAPSHOT}}
        ...                                                      only_test_run=${${TP.CFG_MARVIN_ONLY_TEST_RUN}}
        ...                                                      wait_after_run=${${TP.CFG_MARVIN_WAIT_AFTER_RUN}}
        IF    ${marvin_status}
            Log To Console    Marvin Stopped Successfully
        ELSE
            Log    Stop Marvin Failed: General Failure    level=ERROR
        END
        Set Test Variable    $MARVIN_IS_RUNNING    ${False}
    ELSE
        Log    Marvin is Not Started!    level=DEBUG
    END


Generate KPIData Json File and Send to Dashboard
    [Arguments]    ${snapshot_dir}    ${database}
    ${core_alias}    connect.Connect to Core

    ${TP.REPORT_TO_GRAFANA}    Set Variable If    '${TEST_STATUS}'=='FAIL'    false    ${TP.REPORT_TO_GRAFANA}
    ${deployment}  ${board}  Get Deployment

    ${processor_command}    Catenate    ${CURDIR}/bash/grafana.sh ${GRAFANA_SCRIPTS_DIR}
    ...                                 ${snapshot_dir}
    ...                                 ${TEST_STATUS}
    ...                                 ${deployment}
    ...                                 ${board}
    ...                                 ${TEST_NAME}
    ...                                 ${WORKSPACE}
    ...                                 ${TL_DATA['GNB_VERSION']}
    ...                                 ${TL_DATA['AP_VERSION']}
    ...                                 ${database}
    ...                                 ${TP.JOB_NAME}
    ...                                 ${TP.JOB_URL}
    ...                                 ${TP.BUILD_ID}
    ...                                 | tee ${P_resultTestDir}/grafana.log

    Log to Console    REPORT_TO_GRAFANA: ${TP.REPORT_TO_GRAFANA}
    ${return_str}    ssh.Execute    ${processor_command}    connection=${core_alias}

    FOR    ${error_string}    IN    IndexError: list index out of range    FileNotFoundError
        IF    "${error_string}" in """${return_str}"""
            Log    Grafana Script Failed: ${error_string}     level=ERROR
            RETURN    ${NONE}
        END
    END

    ${json_output}    Set Variable    ${WORKSPACE}/KpiData/data_${TEST_NAME}.json
    ${json_original}    Set Variable    ${WORKSPACE}/KpiData/data_${TEST_NAME}_orig.json
    Copy File    ${json_output}    ${json_original}
    perf_log_collection.Queue Logs To Turandot    ${json_original}    compress=false    subfolder=${RL_PATH.grafana}
    Modify Json File    ${json_output}
    perf_log_collection.Queue Logs To Turandot    ${json_output}    compress=false    subfolder=${RL_PATH.grafana}

    IF    "${TP.REPORT_TO_GRAFANA}"=="true" and "${TEST_STATUS}"=="PASS"    Send To Grafana


##################################################
#                   PRIVATE
##################################################


Start Online Reporting
    IF          '${TEST STATUS}'!='PASS'   RETURN
    Set Tags                        SKIP_REPORT
    ${variables}  Get Variables
    ${QC_TEST_NAME}    Set Variable If    "\${QC_TEST_NAME}" not in $variables    ${TEST_NAME}    ${QC_TEST_NAME}
    reporting.Online Reporting To ReP    tcName=${QC_TEST_NAME}
    ...                                  qcFilePath=${QC_PATH}    isForDebugging=${TP.ONLINE_REPORTING_DEBUGGING}
    Log To Console    \nReported to QC: ${QC_TEST_NAME} -> ${QC_PATH}


Modify Json File
    [Arguments]    ${source_json}    ${target}=${None}
    IF    "${target}"=="${None}"
        ${target}     Set Variable    ${source_json}
    END

    @{kpi_list}    Create List    NR_5192e    NR_5193b
    ${kpi_dictionary}    performance_kpi_data_manager.Get KPI Dictionary    kpi_list=${kpi_list}

    ${L1Pool_DL_Avg_UEPerTTI}    Get Variable Value    ${kpi_dictionary['NR_5192e']['distnames']['sum']}    ${None}
    ${L1Pool_UL_Avg_UEPerTTI}    Get Variable Value    ${kpi_dictionary['NR_5193b']['distnames']['sum']}    ${None}

    ${source_json_str}    Get File    ${source_json}
    TRY
        ${json_obj}    Evaluate      json.loads('''${source_json_str}''')    modules=json
    EXCEPT    JSONDecodeError
        Log    Grafana: Failed to Modify JSON    level=ERROR
        RETURN    ${source_json}
    END

    TRY
        Set To Dictionary    ${json_obj['data'][-1]['fields']}
        ...    L1Pool_DL_Avg_UEPerTTI=${L1Pool_DL_Avg_UEPerTTI}
        ...    L1Pool_UL_Avg_UEPerTTI=${L1Pool_UL_Avg_UEPerTTI}
        ${json_fmt}    Evaluate    json.dumps($json_obj, indent=4)    modules=json
    EXCEPT    TypeError
        Log    Grafana: Unexpected Json Format    level=ERROR
        RETURN    ${source_json}
    END

    Create File    ${target}      ${json_fmt}
    RETURN    ${target}


Send To Grafana
    ${core_alias}    connect.Connect to Core
    ${send_to_grafana_cmd}    Catenate    source /home/ute/DEVELOPMENT/env_activate;
    ...                                   python3
    ...                                   ${GRAFANA_SCRIPTS_DIR}/step5_scripts/perfdata_processor.py
    ...                                   by_json
    ...                                   ${WORKSPACE}/KpiData/data_${TEST_NAME}.json
    ssh.execute    ${send_to_grafana_cmd}    connection=${core_alias}


Get Deployment
    [Arguments]    ${gnb_id}=${0}   ${du_id}=${0}   ${common_unit_id}=${0}   ${capu_id}=${0}
    ${gnb_capu_unit_num}=    Get Length    ${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${common_unit_id}].capacity_units}
    ${gnb_capu_unit_1}=      testline.Get Capacity Unit Type    gnb_id=${gnb_id}   du_id=${du_id}
    ...                                                         common_unit_id=${common_unit_id}   capu_id=${capu_id}
    ${board}                 Set Variable If    "${gnb_capu_unit_num}"!="0"    ${gnb_capu_unit_1}    ${TL_DATA['GNB_CU_TYPE']}
    ${deployment}            Catenate    ${TL_DATA['GNB_CU_TYPE']}_${gnb_capu_unit_1}
    ${deployment}            Set Variable If    "${gnb_capu_unit_num}"!="0"    ${deployment}    ${TL_DATA['GNB_CU_TYPE']}
    RETURN    ${deployment}    ${board}
