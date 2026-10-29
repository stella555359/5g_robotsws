*** Settings ***
Documentation
...  author:  Squad 69
...  contact: I_MN_RAN_SW_ULM_ET_AP_PET_GMS
...  Description:

Library     python/bearer_stats_fast.py
Library     python/scripts.py

Resource    performance_egate.robot
Resource    performance_keywords.robot

*** Variables ***
${ENABLE_PM_COUNTER_default_traffic}=        true
${ENABLE_PM_COUNTER_default_test_script}=    false

${ENABLE_PM_COUNTER_ramp_up_traffic}=        true

${ENABLE_PM_COUNTER_deregister_traffic}=        false
${ENABLE_PM_COUNTER_deregister_test_script}=    true

*** Keywords ***
Run Common Test with Idle UE
    [Arguments]    &{argp}
    Set Test Variable     $ENABLE_PM_COUNTER_default_traffic    false
    &{default_args}    Create Dictionary    start_cell=1
    ...                                       end_cell=1
    ...                                   active_cells=all
    ...                                    ul_datarate=0
    ...                                    dl_datarate=0
    ...                                           rate=kbps
    ...                                  trf_direction=both
    ...                                       start_ue=1
    ...                                    ue_per_cell=0
    ...                                     packetsize=1350
    ...                                      period_ms=none
    ...                                            lua=none
    ...                                      ue_nr_cap=UE_CAP
    ...                              registration_type=InitialRegistration
    ...                                      tolerance=0.05
    ...                            stop_log_collection=false
    ...                                  traffic_sleep=${TP.SET_TRAFFIC_SLEEP}
    ...                                entry_auto_args=true
    ...                                          entry=none
    ...                                        timeout=1200
    ## params for idle ue
    ...                                 number_of_idle=0       # <-- EDIT THIS!!
    ...                                packetsize_idle=42      # 42..9000
    ...                                 period_ms_idle=5000
    &{args1}=              Evaluate    ${default_args} | ${argp}
    ${args}    performance_keywords.Run Common Test    &{args1}

    # Idle UE Calculations
    ${end_ue_id_idle}          Evaluate                    ${args.end_ue} + ( ${args.num_cells}*${args['number_of_idle']} )
    ${ue_per_cell_plus_idle}   Evaluate                    ${args['number_of_idle']} + ${args.ue_per_cell}
    ${start_ue_idle}           Evaluate                    ${args.end_ue} + 1
    &{args_idle}               Create Dictionary      start_ue=${start_ue_idle}
    ...                                                 end_ue=${end_ue_id_idle}
    ...                                            ul_datarate=0
    ...                                            dl_datarate=0
    ...                                                   rate=bps
    ...                                             packetsize=${args['packetsize_idle']}
    ...                                              period_ms=${args['period_ms_idle']}
    &{args_idle}=              Evaluate     ${args} | ${args_idle}
    ${args_str_idle}           Convert Dictionary to Lua Parameter String    &{args_idle}
    ${idle_entry}              Set Variable    ${args.entry}(${args_str_idle})

    Log to Console    Start Idle UE Registration
    performance_egate.Run Test Script            ${idle_entry}    timeout=${args.timeout}
    ...                                         fail_regexp=${args.fail_regexp}

    # Log Collections with IDLE UE
    Wait For Next Measurement Period        label=TRF_IDLE_UE

    Log      ${SPACE} ${SPACE} ${SPACE} Sleep for traffic [${args.traffic_sleep}]   console=${True}
    Sleep    ${args.traffic_sleep}    reason=collect enough data for performance test analysis

    ${pmfile_idle_traffic}    Wait for Current Measurement            label=TRF_IDLE_UE

    ${total_ue_trf}           Evaluate      ${args.ue_per_cell} * ${args.total_active_cells}
    Verify TP with Counters using rate      pmfile=${pmfile_idle_traffic}      &{args}

    Verify All Active UEs and per cell      ${ue_per_cell_plus_idle}    ${args.num_cells}    active_cells=${args.active_cells}
    ...                                     cell_max_ue=${args.cell_max_ue}

    Run Keyword and warn on failure         performance_info.Print PMC ULDL Throughput    pmfile=${pmfile_idle_traffic}
    ...                                                                                   rate=mbps  #rate=${args.rate}


Run Common Test with Ramp
    [Arguments]    &{argp}
    # #######################################
    # BASE UE
    # #######################################
    ${args}    perf_keywords.merge_to_dictionary    ${argp}    reversed=${True}
    ...                                            lua=none
    ...                                      ue_nr_cap=UE_CAP_MUMIMO
    ...                              registration_type=InitialRegistration
    ...                                entry_auto_args=true
    ...                                        timeout=3000
    ...                                  kpi_insert_db=false    # only save ramp kpi
    ...                                  pmc_insert_db=false    # only save ramp pmc
    ## params for ramp
    ...                               ramp_ue_per_cell=0
    ...                               ramp_ul_datarate=10
    ...                               ramp_dl_datarate=10
    ...                        ramp_cell_ul_throughput=null
    ...                        ramp_cell_dl_throughput=null
    ...                              ramp_cell_trf_dir=null
    ...                             ramp_trf_direction=both
    ...                            ramp_register_delay=1
    ...                                     ramp_entry=performance_common_lua_v2
    ...                                 ramp_traffic_sleep=0
    ...                            ramp_down_traffic_sleep=0
    ...                               ramp_cell_max_ue=null
    ...                                deregister_type=switch_off
    ...                                  deregister_by=ue
    ${args}    performance_keywords.Run Common Test    &{args}

    # #######################################
    # RAMP UP
    # #######################################
    ${start_ue_ramp}           Evaluate    ${args.end_ue} + 1
    ${ue_count_in_cell}        perf_keywords.calculate_ue_count_in_cell    ${args}
    &{args_ramp_p}    perf_keywords.merge_to_dictionary                   ${args}
    ...                                       start_ue=${start_ue_ramp}
    ...                                         end_ue=auto
    ...                                    ue_per_cell=${args.ramp_ue_per_cell}
    ...                                    ul_datarate=${args.ramp_ul_datarate}
    ...                                    dl_datarate=${args.ramp_dl_datarate}
    ...                                  trf_direction=${args.ramp_trf_direction}
    ...                             cell_ul_throughput=${args.ramp_cell_ul_throughput}
    ...                             cell_dl_throughput=${args.ramp_cell_dl_throughput}
    ...                                   cell_trf_dir=${args.ramp_cell_trf_dir}
    ...                                 register_delay=${args.ramp_register_delay}
    ...                                  kpi_tolerance=1
    ...                                    cell_max_ue=${args.ramp_cell_max_ue}
    ...                               ue_count_in_cell=${ue_count_in_cell}
    ...                                          entry=${args.ramp_entry}
    ...                                      traffic_sleep=${args.ramp_traffic_sleep}
    ...                                    pass_regexp=${None}    # reset
    ...                                  kpi_insert_db=true    # only save ramp kpi
    ...                                  pmc_insert_db=true    # only save ramp pmc
    ...                                          label=ramp_up
    ...                                      subfolder=ramp_up
    ...                                custom_lua_file=commands_common.lua
    ...                                    setup_on_air=false

    Log to Console    \n${bar_b}\nStart Ramp up:\n${SPACE} ${SPACE} ${args_ramp_p.ramp_ue_per_cell} Total UE, 1ue/${args_ramp_p.ramp_register_delay}s
    ${args_ramp}    performance_keywords.Run Common Test    get_from_cli=${False}    &{args_ramp_p}     ## robocop: off=possible-variable-overwriting

    performance_keywords.TC Params set to False    ENABLE_BEARER_STATS_COLLECTION
    # #######################################
    # RAMP DOWN
    # #######################################
    &{args_ramp_down}    perf_keywords.merge_to_dictionary    ${args_ramp}
    ...                                          entry=deregister_multiue_parallel
    ...                                custom_lua_file=commands_common.lua
    ...                                    ue_per_cell=${args.ue_per_cell}
    ...                                    cell_max_ue=${args.cell_max_ue}
    ...                                          label=ramp_down
    ...                                      subfolder=ramp_down
    ...                                    pass_regexp=${None}    # reset
    ...                                  kpi_insert_db=false    # only save ramp kpi
    ...                                  pmc_insert_db=false    # only save ramp pmc
    ...                                   setup_on_air=false

    Log to Console     \n${bar_b}\nStart Ramp down:\n${SPACE} ${SPACE} ${args_ramp.ramp_ue_per_cell} Total UE, 1ue/${args_ramp.ramp_register_delay}s
    performance_keywords.Run Common Test    get_from_cli=${False}    &{args_ramp_down}


Run Common Test with Deregister
    [Arguments]    &{argp}
    performance_keywords.TC Params set to False    ENABLE_SNAPSHOT    ENABLE_LOG_DCAP    #ENABLE_SYSLOG

    ${args}    Run Keyword And Continue On Failure    performance_keywords.Run Common Test    &{argp}

    TC Params revert    ENABLE_SNAPSHOT    ENABLE_LOG_DCAP    #ENABLE_SYSLOG
    performance_keywords.TC Params set to False    ENABLE_BEARER_STATS_COLLECTION

    # #######################################
    # Deregister
    # #######################################
    &{args_deregister}    perf_keywords.merge_to_dictionary    ${args}
    ...                                          entry=deregister_multiue_quick
    ...                                entry_auto_args=true
    ...                                custom_lua_file=commands_common.lua
    ...                                          label=deregister
    ...                                      subfolder=deregister
    ...                                expect_ue_count=0
    ...                                    pass_regexp=${None}    # reset
    ...                                  kpi_insert_db=false    # only save ramp kpi
    ...                                  pmc_insert_db=false    # only save ramp pmc
    ...                                       start_ue=1
    ...                     pmc_verification_sublabel=test_script
    ...                                  setup_on_air=false

    Log to Console     \n${bar_b}\nStart deregister:
    performance_keywords.Run Common Test    get_from_cli=${False}    &{args_deregister}


Run Common Test with Ramp and Quick Deregister
    [Arguments]    &{argp}


    performance_keywords.TC Params set to False    ENABLE_SNAPSHOT    ENABLE_SYSLOG    ENABLE_LOG_DCAP

    ${args}    perf_keywords.merge_to_dictionary    ${argp}    reversed=${True}
    ...                                            lua=none
    ...                                      ue_nr_cap=UE_CAP
    ...                              registration_type=InitialRegistration
    ...                                entry_auto_args=true
    ...                                        timeout=3000
    ...                                  kpi_insert_db=false    # only save ramp kpi
    ...                                  pmc_insert_db=false    # only save ramp pmc
    ...                                     packetsize=42      # 42..9000
    ...                                      period_ms=5000
    # #######################################
    # params for ramp
    # #######################################
    ...                               ramp_ue_per_cell=0
    ...                               ramp_ul_datarate=10
    ...                               ramp_dl_datarate=10
    ...                        ramp_cell_ul_throughput=null
    ...                        ramp_cell_dl_throughput=null
    ...                              ramp_cell_trf_dir=null
    ...                             ramp_trf_direction=both
    ...                            ramp_register_delay=2
    ...                                     ramp_entry=performance_common_add_traffic    # performance_common_lua_v2
    ...                                 ramp_traffic_sleep=0
    ...                            ramp_down_traffic_sleep=0
    ...                               ramp_cell_max_ue=null
    ...                                deregister_type=switch_off
    ...                                  deregister_by=ue
    ...                                ramp_packetsize=1350
    ...                                 ramp_period_ms=none
    ...                           ramp_expect_ue_count=1500
    ...                                    ramp_end_ue=8501

    ${args}    Run Keyword And Continue On Failure    performance_keywords.Run Common Test    &{args}

    # #######################################
    # RAMP UP
    # #######################################
    ${start_ue_ramp}           Evaluate    ${args.end_ue} + 1
    ${ue_count_in_cell}        perf_keywords.calculate_ue_count_in_cell    ${args}
    &{args_ramp_p}    perf_keywords.merge_to_dictionary                   ${args}
    ...                                       start_ue=${start_ue_ramp}
    ...                                         end_ue=${args.ramp_end_ue}
    ...                                    ue_per_cell=${args.ramp_ue_per_cell}
    ...                                    ul_datarate=${args.ramp_ul_datarate}
    ...                                    dl_datarate=${args.ramp_dl_datarate}
    ...                                  trf_direction=${args.ramp_trf_direction}
    ...                             cell_ul_throughput=${args.ramp_cell_ul_throughput}
    ...                             cell_dl_throughput=${args.ramp_cell_dl_throughput}
    ...                                   cell_trf_dir=${args.ramp_cell_trf_dir}
    ...                                 register_delay=${args.ramp_register_delay}
    ...                                  kpi_tolerance=1
    ...                                    cell_max_ue=${args.ramp_cell_max_ue}
    ...                               ue_count_in_cell=${ue_count_in_cell}
    ...                                entry_auto_args=${args.ramp_entry_auto_args}
    ...                                          entry=${args.ramp_entry}
    ...                                      traffic_sleep=${args.ramp_traffic_sleep}
    ...                                    pass_regexp=${None}    # reset
    ...                                  kpi_insert_db=true    # only save ramp kpi
    ...                                  pmc_insert_db=true    # only save ramp pmc
    ...                                          label=ramp_up
    ...                                      subfolder=ramp_up
    ...                                custom_lua_file=commands_common.lua
    ...                                     packetsize=${args.ramp_packetsize}
    ...                                      period_ms=${args.ramp_period_ms}
    ...                                expect_ue_count=${args.ramp_expect_ue_count}
    ...                                   setup_on_air=false

    FOR    ${key}    IN    ramp_end_ue    ramp_ue_per_cell    ramp_ul_datarate    ramp_dl_datarate    ramp_trf_direction
    ...                    ramp_cell_ul_throughput    ramp_cell_dl_throughput    ramp_cell_trf_dir    ramp_register_delay    ramp_cell_max_ue
        Pop From Dictionary    ${args_ramp_p}   ${key}
    END

    Log to Console    \n${bar_b}\nStart Ramp up:
    ${args_ramp}    performance_keywords.Run Common Test    get_from_cli=${False}    &{args_ramp_p}

    Log to Console    \============================================================
    Log to Console    Enable Logging
    Log to Console    \============================================================
    Set to dictionary    ${TP}    ENABLE_SNAPSHOT=${ENABLE_SNAPSHOT_ORIGINAL_VALUE}
    Set to dictionary    ${TP}    ENABLE_SYSLOG=${ENABLE_SYSLOG_ORIGINAL_VALUE}
    Set to dictionary    ${TP}    ENABLE_LOG_DCAP=${ENABLE_LOG_DCAP_ORIGINAL_VALUE}
    Set Test Variable   $TP

    performance_keywords.TC Params set to False    ENABLE_BEARER_STATS_COLLECTION
    # #######################################
    # Deregister
    # #######################################
    ${variables}=  Get variables
    IF    "\${ENABLE_PM_COUNTER_deregister}" not in $variables    Set Test Variable    $ENABLE_PM_COUNTER_deregister    false
    # &{args_deregister}    perf_keywords.merge_to_dictionary    ${args}
    &{args_deregister}    perf_keywords.merge_to_dictionary    ${args_ramp}
    ...                                          entry=deregister_multiue_quick
    ...                                entry_auto_args=true
    ...                                custom_lua_file=commands_common.lua
    ...                                          label=deregister
    ...                                      subfolder=deregister
    ...                                expect_ue_count=0
    ...                                    pass_regexp=${None}    # reset
    ...                                  kpi_insert_db=false    # only save ramp kpi
    ...                                  pmc_insert_db=false    # only save ramp pmc
    ...                                  traffic_sleep=0
    ...                                       start_ue=1
    ...                                         end_ue=9000   # hardcoded quickfix
    ...                     pmc_verification_sublabel=test_script
    ...                                  setup_on_air=false

    Log to Console     \n${bar_b}\nStart deregister:
    performance_keywords.Run Common Test    get_from_cli=${False}    &{args_deregister}
