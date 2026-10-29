*** Settings ***
Documentation
...  author:  TBA
...  contact: I_MN_RAN_SW_ULM_ET_AP_PET_GMS
...  Description:   Common keywords for performance testing

Library    OperatingSystem
Library    Collections
Library    String
Library    taf.config.scf                                 WITH NAME    scf
Library    taf.sbts.oam.coam.admin                        WITH NAME    coam
Library    taf.ul.marvin                                  WITH NAME    marvin
Library    taf.sw.wtssim  # wts_manager, taf_sw_wtssim_wrapper dependency

Library    python/perf_keywords.py
Library    python/hasher.py
Library    python/perf_perfshot.py
Library    python/perf_resource_usage.py

Library    ../../../resources/Common/python/alarm_handling.py   WITH NAME    alarm

Resource    ../../resources/SQD60/sqd60_tools.robot
Resource    ../../resources/SQD65/sqd65_keywords.robot

Resource    ../../../resources/Common/alarm_handling.robot
Resource    ../../../resources/Common/bip_trace.robot
Resource    ../../../resources/Common/connect.robot
Resource    ../../../resources/Common/testline.robot
Resource    ../../../resources/Common/ute_workarounds.robot
Resource    ../../../resources/Common/util.robot
Resource    ../../../resources/Common/wts_ue.robot

Resource    performance_keywords.robot
Resource    performance_btslog.robot
Resource    performance_commissioning.robot
Resource    performance_common_tc.robot
Resource    performance_dcap.robot
Resource    performance_database.robot
Resource    performance_egate.robot
Resource    performance_emperf.robot
Resource    performance_info.robot
Resource    performance_log_collection.robot
Resource    performance_reporting.robot
Resource    performance_ttitrace.robot
Resource    performance_turandot.robot
Resource    performance_swconfig.robot
Resource    performance_snapshot.robot
Resource    performance_verification.robot

Variables   python/perf_variables.py

*** Variables ***
${use_internal_id}                TRUE
${PERF_RESOURCES_DIR}             ${CURDIR}

${QC_PATH}=                       testsuite/Ulm/ET/Performance_Test/resources/qc/ASOE_performance.qc
${T_TOTAL_UE_CONFIGURED}=         100
@{TS_LIST_ALL}=                   all
@{TS_LIST_NULL}=                  null

${TS_LUA_ARGS_SEPARATOR}=         %

@{TS_EXCLUDE_IN_LOGS}=            entry_final        pass_regexp    stop_log_collection    tti_trace_duration     fail_regexp    cell_and_ue_mapping
...                               expected_dl_cell_tput    expected_ul_cell_tput    subfolder

&{TCP}
## Flow Related
...                       TRAFFIC_DL=false
...                       TRAFFIC_UL=false
...                       TRAFFIC_BOTH=false
...                       previous_tc_testname_for_db=null
#ASSERTION
...                       ENABLE_EGATE_CHECK_UE_CNTX_REL_REQ=true

&{TL_DATA}                GNB_VERSION=${None}
...                       AP_VERSION=${None}
...                       GNB_CU_TYPE=${None}    # ASIL, ASIM, ASOE
...                       GNB_CAPU_TYPE=${None}  # ABIO, ABIP,

${ON_AIR_STATUS}          ${False}

${WTS_IS_RUNNING}         ${False}
${TSHARK_IS_RUNNING}      ${False}
${MARVIN_IS_RUNNING}      ${False}
${NETCAT_IS_RUNNING}      ${False}
${TRAFFIC_DIRECTION}      ${None}
${SCOUT_EXT_SCF_ID}       ${None}
${hash_testcase}          ${None}
${TC_ARGS_HASH}           ${None}
${hash_scf}               ${None}
${S_hash_gnb_swconfig}    ${None}
${S_AP_SWCONFIG_HASH}     ${None}
@{alarmslist_gnb0_setup}
#######################################################################################


*** Keywords ***
Common Log Setup
    [Documentation]
    ...   Start the logs with less resource usage first
    [Arguments]    ${args}
    ${remote_subfolder}             Set Variable    ${RL_PATH.common_log_setup}
    IF    "${args.subfolder}" != "${EMPTY}"
        ${remote_subfolder}    Set Variable    ${remote_subfolder}/${args.subfolder}
    END

    Run Keyword And Continue On Failure    performance_emperf.Start All Enabled Emperfs On Background    ${args.label}

    IF    "${TP.ENABLE_LXC_gnb_top_default}" != "null"
        Run Keyword And Warn On Failure    performance_log_collection.Start Lxc Top
        ...                                ${TP.ENABLE_LXC_gnb_top_default}   hw=gnb    subfolder=${remote_subfolder}
    END
    IF    "${TP.ENABLE_FLAME_GRAPH_gnb_default}" != "null"
        Run Keyword And Warn On Failure    performance_log_collection.Start Perf Script
        ...                                ${TP.ENABLE_FLAME_GRAPH_gnb_default}   hw=gnb
    END
    IF    "${TP.ENABLE_TSHARK}"!="false"
        sqd65_keywords.Start TCE and collect trace
        Set Test Variable    $TSHARK_IS_RUNNING    ${True}
    END
    IF    "${TP.ENABLE_LOG_TCPDUMP_ALL}"=="true" or "${TP.ENABLE_LOG_TCPDUMP_COMMON_LOG}"=="true"
        performance_log_collection.Start Tcpdump Traces    collector=common_log_sctp    options_testpc=${TP.CFG_LOG_TCPDUMP_TESTPC}
        ...                                                                             options_gnb=${TP.CFG_LOG_TCPDUMP_GNB}
    END
    IF    "${TP.ENABLE_LOG_DCAP}"=="true"
        Run Keyword And Continue On Failure    performance_dcap.Start DCAP
    END
    IF    "${TP.ENABLE_LOG_QUICK_BIP_TEST_SCRIPT}"=="true"
        Run Keyword And Continue On Failure    bip_trace.Start BIP Traces With TAF Collector    collector=common_log_bip
    END
    IF    "${TP.ENABLE_TTI_TRACE_TEST_SCRIPT}"=="true"
        Run Keyword And Continue On Failure    performance_ttitrace.Start TTI Trace Collection    tti_trace_filename=common_log_tti
    END


Common Log Teardown
    [Documentation]
    ...   Stop the logs with most resource usage first
    [Arguments]    ${snapshot_archive_prefix}=${Empty}    ${subfolder}=${Empty}    ${label}=${EMPTY}   ${tti_trace_duration}=3
    IF    "${TP.ENABLE_TTI_TRACE_TEST_SCRIPT}"=="true"
        Run Keyword And Continue On Failure    performance_ttitrace.Stop TTI Trace Collection     tti_trace_filename=common_log_tti
        ...                                    subfolder=${subfolder}
    END
    IF    "${TP.ENABLE_LOG_QUICK_BIP_TEST_SCRIPT}"=="true"
        Run Keyword And Continue On Failure    performance_log_collection.Stop BIP Traces And Save To Turandot
        ...                                    collector=common_log_bip    subfolder=${subfolder}
    END
    IF    "${TP.ENABLE_LOG_DCAP}"=="true"
        Run Keyword And Continue On Failure    performance_dcap.Stop And Collect DCAP    subfolder=${subfolder}
        ...                                                                              archive_name=common_log_emil_dcap
    END
    IF    "${TP.ENABLE_LOG_TCPDUMP_ALL}"=="true" or "${TP.ENABLE_LOG_TCPDUMP_COMMON_LOG}"=="true"
        Run Keyword And Continue On Failure    performance_log_collection.Stop Tcpdump Traces    collector=common_log_sctp    subfolder=${subfolder}
    END
    IF    "${TP.ENABLE_TSHARK}"!="false" and ${TSHARK_IS_RUNNING}
        Set Test Variable    $TSHARK_IS_RUNNING    ${False}
        perf_log_collection.Queue Logs To Turandot    ${tshark}
    END
    IF    "${TP.ENABLE_LXC_gnb_top_default}" != "null"
        Run Keyword And Warn On Failure    performance_log_collection.Stop Lxc Top And Collect Log
        ...                               ${TP.ENABLE_LXC_gnb_top_default}   hw=gnb    subfolder=${subfolder}
    END
    IF    "${TP.ENABLE_FLAME_GRAPH_gnb_default}" != "null"
        Run Keyword and Warn On Failure    performance_log_collection.Stop Perf Script
        ...                                ${TP.ENABLE_FLAME_GRAPH_gnb_default}   hw=gnb    subfolder=${subfolder}
    END
    Run Keyword And Continue On Failure    performance_emperf.Teardown All Enabled Emperfs    ${label}
    ##### Doesn't have a pair
    IF    "${TP.ENABLE_TTI_TRACE_QUICK}"=="true"
        Run Keyword And Warn On Failure    performance_ttitrace.Quick TTI Trace Collection    tti_trace_duration=${tti_trace_duration}
        ...                                                              tti_trace_filename=common_log_tti_quick    subfolder=${subfolder}
        Convert TTI Traces
    END
    IF    "${TP.ENABLE_L2PERF}"=="true"
        Run Keyword And Warn On Failure    performance_log_collection.Generate L2perf Logs With PY
    END
    IF    "${TP.ENABLE_EGATE_CHECK_UE_CNTX_REL_REQ}"=="true"
        performance_egate.UE Context Release Req should not be present
    END
    IF    "${TP.CFG_BIP_TRF_GNB_DURATION}"!="null"
        Run Keyword And Continue On Failure
        ...    performance_log_collection.Quick BIP Collection    collector=common_log_bip_quick    subfolder=${subfolder}
        ...                                                       duration=${TP.CFG_BIP_TRF_GNB_DURATION}
    END
    IF    "${TP.ENABLE_SNAPSHOT}"=="true"
        ${snapshot_path}    performance_snapshot.Collect Snapshot From Gnb And Save To Turandot
        ...                                                                    archive_prefix=${snapshot_archive_prefix}
        ...                                                                    subfolder=${subfolder}
        Post Process Snapshot    ${snapshot_path}    subfolder=${subfolder}    archive_prefix=${snapshot_archive_prefix}
    END


Get Total Expected UE Count
    [Arguments]    ${args}
    IF    ${args.expect_ue_count}!=${TS_LIST_NULL}
        ${total_ue_count}                                          Evaluate    sum([int(i) for i in ${args.expect_ue_count}])
    ELSE IF    ${args.cell_max_ue}!=${TS_LIST_NULL}
        ${total_ue_count}                                          Evaluate    sum([int(i) for i in ${args.cell_max_ue}])
    ELSE IF    ${args.ue_per_cell}!=0
        ${total_ue_count}                                          Evaluate    ${args.ue_per_cell} * ${args.total_active_cells}
    ELSE
        ${total_ue_count}                                          Set Variable    0
    END
    RETURN    ${total_ue_count}


Verify UE Count
    [Arguments]    ${args}
    ${total_ue_count}    Get Total Expected UE Count    ${args}
    performance_verification.Wait Until Active UE Reach Expected Count    ${total_ue_count}


Run Common Test
    [Arguments]    ${get_from_cli}=${True}    &{argp}
    ${args}    performance_keywords.Calculate Values for Common Run Dictionary    get_from_cli=${get_from_cli}    &{argp}
    IF    "${args.subfolder}"!="${EMPTY}"
        Create Directory    ${P_resultTestDir}/${args.subfolder}
    END
    Set Up On Air Status    ${args}
    Pass Execution If    "${TP.HALT_EXECUTION_ON_AIR}"=="true"    \n${bar_a}\nExecution Halts On Air\n${bar_a}\n

    Common Log Setup    ${args}

    ${remote_subfolder_after_attach}        Set Variable    ${RL_PATH.common_log_after_attach}
    ${remote_subfolder_traffic}             Set Variable    ${RL_PATH.traffic_logs}
    IF    "${args.subfolder}" != "${EMPTY}"
        ${remote_subfolder_after_attach}    Set Variable    ${remote_subfolder_after_attach}/${args.subfolder}
        ${remote_subfolder_traffic}         Set Variable    ${remote_subfolder_traffic}/${args.subfolder}
    END

    performance_log_collection.Wait For Next Measurement Period                           label=${args.label}_test_script

    Run Keyword And Continue On Failure    performance_egate.Run Test Script     entry=${args.entry_final}
    ...                                                        pass_regexp=${args.pass_regexp}
    ...                                                        fail_regexp=${args.fail_regexp}
    ...                                                        timeout=${args.timeout}
    ...                                                        custom_lua_file=${args.custom_lua_file}

    Verify UE Count    ${args}

    performance_log_collection.Wait For Current Measurement    label=${args.label}_test_script    subfolder=${remote_subfolder_after_attach}

    Common Log Teardown        subfolder=${remote_subfolder_after_attach}    label=${args.label}
    ...                                                                                  tti_trace_duration=${args.tti_trace_duration}

    IF    "${TP.ENABLE_LOG_TCPDUMP_ALL}"=="true" or "${TP.ENABLE_LOG_TCPDUMP_TRAFFIC}"=="true"
        performance_log_collection.Start Tcpdump Traces            collector=traffic_sctp
        ...                                                        options_testpc=${TP.CFG_LOG_TCPDUMP_TESTPC}
        ...                                                        options_gnb=${TP.CFG_LOG_TCPDUMP_GNB}
    END
    IF    "${TP.ENABLE_LOG_DCAP}"=="true"                      Run Keyword And Continue On Failure    performance_dcap.Start DCAP

    ################################################################################
    performance_log_collection.Wait For Next Measurement Period                           label=${args.label}_traffic

    IF    "${TP.ENABLE_LOG_QUICK_BIP}"=="true"                 Run Keyword And Continue On Failure
    ...                                                        bip_trace.Start BIP Traces With Taf Collector
    ...                                                            collector=traffic_bip

    IF    "${TP.ENABLE_TTI_TRACE_QUICK}"=="true"
    Run Keyword And Warn On Failure
    ...    performance_ttitrace.Quick TTI Trace Collection     tti_trace_duration=${args.tti_trace_duration}
    ...                                                        tti_trace_filename=traffic_tti_quick    subfolder=${remote_subfolder_traffic}
    END

    IF    "${TP.ENABLE_LOG_QUICK_BIP}"=="true"                 Sleep    ${TP.CFG_LOG_QUICK_BIP_DURATION}    reason=BIP collection

    IF    "${TP.ENABLE_LOG_QUICK_BIP}"=="true"                 Run Keyword And Continue On Failure
    ...                                                        performance_log_collection.Stop BIP Traces And Save To Turandot
    ...                                                            collector=traffic_bip    subfolder=${remote_subfolder_traffic}

    Log      ${SPACE} ${SPACE} ${SPACE} Sleep for traffic [${args.traffic_sleep}]   console=${True}
    Sleep    ${args.traffic_sleep}    reason=collect enough data for performance test analysis

    performance_log_collection.Wait For Current Measurement    label=${args.label}_traffic    subfolder=${remote_subfolder_traffic}

    IF    "${TP.ENABLE_SNAPSHOT}"=="true"
        ${snapshot_path}    performance_snapshot.Collect Snapshot From Gnb And Save To Turandot    subfolder=${remote_subfolder_traffic}
        performance_snapshot.Post Process Snapshot    ${snapshot_path}    subfolder=${remote_subfolder_traffic}
    END

    IF    "${TP.ENABLE_MARVIN}"=="true"                        performance_reporting.Stop Marvin    # marvin should be stopped during full traffic
    ################################################################################

    RETURN    ${args}
    [Teardown]    Run Common Test Teardown                     &{args}

Prepare WTS Manager Args
    [Arguments]    &{common_argp}
    ${argp2}    perf_keywords.Calculate Values For Common Run Dictionary Py    get_from_cli=${true}    &{common_argp}
    ${argpy}    perf_keywords.Pop Args From Common Args    ${argp2}    perf_keywords.wts_manager_non_supported_params
    &{args}     Set Variable   ${argpy}  # convert to robot style dictionary
    RETURN    ${args}


Set Up On Air Status
    [Arguments]    ${args}
    IF    "${args.setup_on_air}"!="true" and ${ON_AIR_STATUS}==${False}
        Log to console    Setup on Air is skipped!
        RETURN
    END

    IF    "${TP.ENABLE_LOG_TCPDUMP_ALL}"=="true" or "${TP.ENABLE_LOG_TCPDUMP_ON_AIR}"=="true"
        performance_log_collection.Start Tcpdump Traces            collector=onair_sctp
        ...                                                        options_testpc=${TP.CFG_LOG_TCPDUMP_TESTPC}
        ...                                                        options_gnb=${TP.CFG_LOG_TCPDUMP_GNB}
    END

    Set Test Variable         $T_TOTAL_UE_CONFIGURED    ${args.end_ue}
    Set Test Variable         $TRAFFIC_DIRECTION    ${args.trf_direction}
    Set Tags                  TRAFFIC_${args.trf_direction}    ${args.trf_direction}

    Print Parameters Arguments    ${args}    label=Run Parameters    exclude=${TS_EXCLUDE_IN_LOGS}    padding=22

    performance_egate.Run Sansa configuration script                             lua_file=${args.lua}
    ...                                                        start_cell=${args.start_cell}    end_cell=${args.end_cell}
    ...                                                        entry=${args.configuration_entry}
    ...                                                        active_cells=${args.active_cells}

    wts_ue.Check Egate Output Ensure Cells Setup Successful    total_cells=${args.num_cells_online}

    IF    "${TP.ENABLE_RESOUCE_USAGE}"=="true"
        Run Keyword And Continue On Failure
        ...    perf_resource_usage.Get Resources Usage    label=on_air     subfolder=${RL_PATH.resources_usage}    # resources_usage_on_air
    END

    IF    "${TP.ENABLE_PERFSHOT}"=="true"
        perf_perfshot.Run Perfshot    perfshot_arg=${TP.CFG_PERFSHOT_ARG}    hws=${TP.CFG_PERFSHOT_HW}
        ...    subfolder=perfshot/on_air/
    END

    IF    "${TP.ENABLE_LOG_TCPDUMP_ALL}"=="true" or "${TP.ENABLE_LOG_TCPDUMP_ON_AIR}"=="true"
        Run Keyword And Continue On Failure    performance_log_collection.Stop Tcpdump Traces    collector=onair_sctp
        ...                                                                                      subfolder=${RL_PATH.on_air}
    END

    Set Test Variable    ${ON_AIR_STATUS}    ${True}


Print Parameters Arguments
    [Arguments]    ${args}    ${label}=null    ${exclude}=@{EMPTY}    ${padding}=25
    Log To Console    \n${bar_b}\n${label}:\n
    &{args_print}    Set Variable    ${args}
    Remove From Dictionary    ${args_print}    @{exclude}
    FOR    ${key}    IN    @{args_print}
        ${value}   Collections.Get From Dictionary   ${args_print}   ${key}
        ${msg}    Format String    {: >${padding}}: {}     ${key}     ${value}
        Log To Console    ${msg}
    END
    Log To Console    ${empty}


Run Common Test Teardown
    [Arguments]    &{args}
    Log To Console    \n${bar_b}\nRun Common Test Teardown:\n

    ${remote_subfolder}        Set Variable    ${RL_PATH.common_test_teardown}
    IF    "${args.subfolder}" != "${EMPTY}"
        ${remote_subfolder}            Set Variable    ${remote_subfolder}/${args.subfolder}
    END

    IF    "${TP.ENABLE_LOG_DCAP}"=="true"           Run Keyword And Continue On Failure
    ...                                                  performance_dcap.Stop And Collect DCAP
    ...                                                      subfolder=${remote_subfolder}
    ...                                                      archive_name=traffic_emil_dcap

    IF    "${TP.ENABLE_LOG_TCPDUMP_ALL}"=="true" or "${TP.ENABLE_LOG_TCPDUMP_TRAFFIC}"=="true"
        Run Keyword And Continue On Failure    performance_log_collection.Stop Tcpdump Traces
        ...                                        collector=traffic_sctp    subfolder=${remote_subfolder}
    END

    IF    "${TP.ENABLE_TTI_TRACE_QUICK}"=="true"    Run Keyword And Warn On Failure
    ...                                                  performance_ttitrace.Quick TTI Trace Collection
    ...                                                      tti_trace_duration=${args.tti_trace_duration}
    ...                                                      tti_trace_filename=traffic_teardown_tti_quick
    ...                                                      subfolder=${remote_subfolder}

    IF    "${TP.HALT_EXECUTION_ON_AIR}"=="true"    RETURN

    IF    "${args.verify}"=="true"    Common Log Teardown Verification    ${args}    sublabel=${args.pmc_verification_sublabel}
    ...                                                                              remote_subfolder=${remote_subfolder}


Common Log Teardown Verification
    [Arguments]    ${args}    ${sublabel}=traffic    ${remote_subfolder}=${EMPTY}
    Log To Console    \n${bar_b}\nVerification:\n

    ${cell_max_ue}    Set Variable If    ${args.expect_ue_count}==${TS_LIST_NULL}    ${args.cell_max_ue}    ${args.expect_ue_count}

    performance_verification.Verify All Active UEs And Per Cell      ${args.ue_per_cell}    ${args.num_cells}    active_cells=${args.active_cells}
    ...                                                              cell_max_ue=${cell_max_ue}

    IF    "${TP.ENABLE_CELL_STATS}"=="true"    Run Keyword And Warn On Failure
    ...                                            performance_info.Print Cell Stats
    ...                                                insert_db=${args.cellstats_insert_db}
    ...                                                args=${args}

    IF    "${TP.ENABLE_PM_COUNTER}"=="true"
        Run Keyword And Continue On Failure     PM Counter Routine    ${args}    sublabel=${sublabel}    remote_subfolder=${remote_subfolder}
    ELSE
        IF    "${TP.ENABLE_LTEPAT}"=="true"    Log     IF ENABLE_LTEPAT is true, ENABLE_PM_COUNTER should be true    level=WARN
    END


PM Counter Routine
    [Arguments]    ${args}    ${sublabel}=traffic    ${pm_location}=${None}    ${remote_subfolder}=${EMPTY}
    TRY
        IF    """${pm_location}""" == "${None}"
            ${pm_location}    Set Variable    ${T_PM_FILES_LOCATION_${args.label}_${sublabel}}
        END
    EXCEPT    .*Variable .* not found.*
        Log    PM Counter Routine Failed: Variable Not Found (\${T_PM_FILES_LOCATION_${args.label}_${sublabel}})    level=ERROR
        RETURN   ${none}
    END
    IF    "${pm_location}"=="${none}"   RETURN   ${none}

    IF    "${args.subfolder}" != "${EMPTY}"
        ${remote_subfolder}    Set Variable    ${args.subfolder}/${remote_subfolder}/${args.label}_${sublabel}
    END


    Log To Console    \nPM counter routine [${args.label}_${sublabel}]
    Log               [ ${pm_location} ]    console=${P_console}

    ${total_ue}    Evaluate    sum(${args.expect_ue_count}) if ${args.expect_ue_count}!=${TS_LIST_NULL} else 'none'
    IF    "${total_ue}"!="0"
        Run Keyword And Continue On Failure
        ...    performance_verification.Verify TP With Counters Using Rate    pmfile=${pm_location}    distname=MNC-489    &{args}
    END
    Run Keyword And Continue On Failure
    ...    performance_info.Print TTI PM Counters    pmfile=${pm_location}

    Run Keyword and warn on failure
    ...    performance_info.Print PMC ULDL Throughput    pmfile=${pm_location}    rate=mbps  #rate=${args.rate}

    Run Keyword And Continue On Failure
    ...    performance_pmcounters.Save PM Counters      ${pm_location}
    ...                                                 insert_db=${args.pmc_insert_db}
    ...                                                 subfolder=${remote_subfolder}
    ...                                                 inactive_cells=${args.inactive_cells}

    IF    "${TP.ENABLE_LTEPAT}"=="true"
        Run Keyword And Continue On Failure
        ...        performance_info_kpi.Save KPI Counters    pi_dir=${pm_location}
        ...                                                  insert_db=${args.kpi_insert_db}
        ...                                                  tolerance=${args.kpi_tolerance}
        ...                                                  subfolder=${remote_subfolder}
        ...                                                  inactive_cells=${args.inactive_cells}
    END


Initialize Dictionary Parameters
    [Documentation]     Former name: Initialize Suite Parameter
    ...                 Modifies the value of dictionary if the keys are found in the suite variables
    ...                     returns a new dictionary
    ...                 Useful for -v / --variable in robot command line
    [Arguments]    ${dictionary}=${TP}    ${console}=${True}
    ${suite_variables}=  Get Variables
    FOR   ${key}   IN   @{dictionary}
        ${value}   Collections.Get From Dictionary   ${dictionary}   ${key}
        ${tmp}=    Set Variable If    "\${${key}}" not in $suite_variables    ${value}    ${${key}}
        Set To Dictionary    ${dictionary}    ${key}    ${tmp}
        ${msg}    Format String    {: >45}: {}     ${key}     ${tmp}
        IF    ${console}    Log To Console    ${msg}
    END
    IF    ${console}    Log To Console    ${EMPTY}
    RETURN    ${dictionary}


Calculate Values For Common Run Dictionary
    [Arguments]    ${get_from_cli}=${True}    ${get_hash}=${True}    &{argp}

    ${args}    perf_keywords.Calculate Values For Common Run Dictionary Py    get_from_cli=${get_from_cli}    &{argp}

    ${hash_dictionary}    Collections.Copy Dictionary  ${args}    deepcopy=${True}
    Collections.Remove From Dictionary                 ${hash_dictionary}    workspace  # romove keys that are testline specific
    ${hash}    ${json}                                 hasher.Get Rf Dictionary Sha256sum    ${hash_dictionary}
    Set To Dictionary                                  ${args}    hash=${hash}
    ${TC_ARGS_HASH_DB}
    ...    performance_database.Insert Hash            hash_run_parameters     ${hash}    ${json}
    Set Test Variable                                  ${TC_ARGS_HASH}         ${hash}
    Set Test Variable                                  ${TC_ARGS_HASH_DB}      ${TC_ARGS_HASH_DB}
    performance_database.Insert Testcase Parameter2    hash_run_parameters     ${hash}

    IF    ${get_hash}    Run Keyword And Warn On Failure    performance_database.Get Hashes

    &{args_rf}    Set Variable   ${args}  # convert to robot style dictionary
    RETURN    ${args_rf}


Expect Duplex
    [Arguments]    ${expected}    ${msg}=${empty}
    IF    "${SUITE METADATA["Duplex Mode Info"]}"!="${expected}"
    ...    Log    [caller: ${msg}] Running a ${expected} keyword on ${SUITE METADATA["Duplex Mode Info"]} testcase!
    ...           level=ERROR    console=${false}


TC Params Set To False
    [Arguments]    @{args}
    Log To Console    \============================================================
    Log To Console    Set TC Params to False
    FOR    ${arg}    IN    @{args}
        ${ORIGINAL_VALUE}    Get From Dictionary     ${TP}       ${arg}
        Set Test Variable     ${${arg}_ORIGINAL_VALUE}    ${ORIGINAL_VALUE}
        Set To Dictionary    ${TP}    ${arg}=false
        Log To Console    ${space} - ${arg}:false (orig.: ${ORIGINAL_VALUE})
    END
    Log To Console    \============================================================
    Set Suite Variable   $TP
    Set Test Variable   $TP


TC Params Revert
    [Arguments]    @{args}
    Log To Console    \============================================================
    Log To Console    TC Params revert
    FOR    ${arg}    IN    @{args}
        Set To Dictionary    ${TP}    ${arg}=${${arg}_ORIGINAL_VALUE}
        Log To Console    ${space} - ${arg}:${${arg}_ORIGINAL_VALUE}
    END
    Log To Console    \============================================================
    Set Suite Variable   $TP
    Set Test Variable   $TP


Get Directory Name From String
    [Arguments]    ${dir}
    @{paths} =  Split String    ${dir}       ${/}
    ${len}    Get Length    ${paths}
    RETURN    ${paths[${len-1}]}
