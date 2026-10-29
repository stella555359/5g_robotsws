*** Settings ***
Documentation
...  author:  Squad 69
...  contact: I_MN_RAN_SW_ULM_ET_AP_PET_GMS
...  Description:   Test Cases for TDD 1 Cell 100 UEs Performance Test

Resource   ../performance_keywords.robot
Resource   ../performance_test_setup.robot


Suite Setup       performance_test_setup.Suite Setup For Performance Test
...                   SCF_ENABLE_BEAMFORMING=true
...                   SCF_CONFIGURE_SRS=true
...                   ENABLE_SRS_INFO=true
...                   SCF_SET_VAR_NRCELL_actUlSrsBm=true
...                   SCF_SET_VAR_NRCELL_actDlSrsBm=true
...                   SCF_ENABLE_BB_POOLING=true
Suite Teardown    performance_test_setup.Suite Teardown For Performance Test
Test Setup        performance_test_setup.Test Case Setup For Performance Test
Test Teardown     performance_test_setup.Test Case Teardown For Performance Test

*** Variables ***
${LOOP_COUNT}    3

*** Test Cases ***
Mixed_HO_ping_and_traffic_then_deregister_CA_loop
    [Setup]    performance_test_setup.Test Case Setup For Performance Test
    ...     SCF_CONFIGURE_SRS=false
    ...     ENABLE_SRS_INFO=false
    ...     SCF_SET_VAR_NRCELL_actUlSrsBm=false
    ...     SCF_SET_VAR_NRCELL_actDlSrsBm=false
    ...     ENABLE_LOG_DCAP=true
    ...     SCF_SET_VAR_NRCELL_actUeCsirsCoexistCellCsirs=true    #required for srs
    ...     ENABLE_SOS_REPORT=false   # it causes too much cpu
    ...     ENABLE_LOG_ARCHIVE_COMPRESSION=false   # it causes too much cpu
    ...     ENABLE_EGATE_CHECK_UE_CNTX_REL_REQ=false    # deregister is part of the testcase
    performance_egate.Copy specific egate Scripts to wts folder    VTM_1208FF_6_SSB_8x4_6Cells_HO_2CC__600UEs_Mixed_HO_100UEs_Percell
    ...                                                            multi_ue_sa_script_new.lua


    # #######################################
    # On Air Only
    # #######################################
    ${argp}     Create Dictionary
    ...                         start_cell=1
    ...                           end_cell=6
    ...                        ue_per_cell=300
    ...                             end_ue=1
    ...                                lua=VTM_1208FF_6_SSB_8x4_6Cells_HO_2CC__600UEs_Mixed_HO_100UEs_Percell/sansa_TC5.lua
    ...                    custom_lua_file=VTM_1208FF_6_SSB_8x4_6Cells_HO_2CC__600UEs_Mixed_HO_100UEs_Percell/commands.lua
    ${argp}    Calculate Values for Common Run Dictionary    get_from_cli=${true}    &{argp}
    performance_keywords.Set Up On air status    ${argp}

    FOR    ${loop_ctr}    IN RANGE    1    ${LOOP_COUNT}    1
        Log to console    --------------------------------------------------------------------------------
        Log to console    Run Loop: ${loop_ctr}\n--------------------------------------------------------------------------------
        Mixed_HO_ping_and_traffic_then_deregister_CA_routine    loop_ctr=run${loop_ctr}_
    END

Mixed_HO_ping_and_traffic_then_deregister_CA
    [Setup]    performance_test_setup.Test Case Setup For Performance Test
    ...     SCF_CONFIGURE_SRS=false
    ...     ENABLE_SRS_INFO=false
    ...     SCF_SET_VAR_NRCELL_actUlSrsBm=false
    ...     SCF_SET_VAR_NRCELL_actDlSrsBm=false
    ...     ENABLE_LOG_DCAP=true
    ...     SCF_SET_VAR_NRCELL_actUeCsirsCoexistCellCsirs=true    #required for srs
    ...     ENABLE_SOS_REPORT=false   # it causes too much cpu
    ...     ENABLE_LOG_ARCHIVE_COMPRESSION=false   # it causes too much cpu
    ...     ENABLE_EGATE_CHECK_UE_CNTX_REL_REQ=false    # deregister is part of the testcase
    performance_egate.Copy specific egate Scripts to wts folder    VTM_1208FF_6_SSB_8x4_6Cells_HO_2CC__600UEs_Mixed_HO_100UEs_Percell
    ...                                                            multi_ue_sa_script_new.lua

    performance_keywords.TC Params set to False    ENABLE_SNAPSHOT    ENABLE_SYSLOG    ENABLE_LOG_DCAP
    ...                                            ENABLE_PM_COUNTER    # CFG_START_DCAP_CONTAINER

    ## #######################################
    ## ping
    ## entry_args is the number of ues per cell for ping traffic
    ## #######################################
    ${args}    Run Keyword And Continue On Failure    performance_keywords.Run Common Test
    ...                             start_cell=1
    ...                               end_cell=6
    ...                            ue_per_cell=300
    ...                              ue_nr_cap=UE_CAP
    ...                      registration_type=InitialRegistration
    ...                                   rate=kbps
    ...                            ul_datarate=56       # this is hardcoded in the sequence
    ...                            dl_datarate=56       # this is hardcoded in the sequence
    ...                          trf_direction=both     # this is hardcoded in the sequence
    ...                                timeout=3000
    ...                          kpi_insert_db=false    # only save ramp kpi
    ...                          pmc_insert_db=false    # only save ramp pmc
    ...                                    lua=VTM_1208FF_6_SSB_8x4_6Cells_HO_2CC__600UEs_Mixed_HO_100UEs_Percell/sansa_TC5.lua
    ...                        custom_lua_file=VTM_1208FF_6_SSB_8x4_6Cells_HO_2CC__600UEs_Mixed_HO_100UEs_Percell/commands.lua
    ...                        entry_auto_args=false
    ...                             entry_args=300      # special case, this is the number of ue per cell!
    ...                                  entry=PET_1070FF_BF_9000UE_DLUL_rate1dot5_with_ho
    ...                            pass_regexp=PET_1070FF_BF_9000UE_DLUL_rate1dot5_with_ho script completed

    ## ca args
    ...                              add_ca_ue=100

    ## traffic args
    ...                   add_traffic_start_ue=8401
    ...                     add_traffic_end_ue=9000
    ...                add_traffic_ul_datarate=200
    ...                add_traffic_dl_datarate=200

    ## handover args
    ...                    handover_entry_args=26,12
    ...                 handover_additional_ue=300
    ...                     handover_trf_sleep=300

    ${total_ping_ue}    Evaluate    ${args.entry_args} * ${args.num_cells}
    Wait until Active UE reach expected count    ${total_ping_ue}

    # #######################################
    # ADD CA UEs
    # #######################################
    Run Keyword And Continue On Failure
    ...    Run lua script    VTM_1208FF_6_SSB_8x4_6Cells_HO_2CC__600UEs_Mixed_HO_100UEs_Percell/commands.lua
    ...               PET_1070FF_BF_9000UE_DLUL_rate1dot5_with_ho_ca_ues(${args.add_ca_ue})
    ...               sleep=1s
    ...               pass_regexp=${None}
    #...               pass_regexp=VTM_INTRAGNB_INTERGNB_DROP2 script completed
    ...               timeout=1800    fail_regexp=${none}

    ${total_trf_ue}    Evaluate    ${total_ping_ue} + (${args.add_ca_ue} * ${args.num_cells})
    ${per_cell_trf_ue}    Evaluate    ${total_trf_ue} / ${args.num_cells}
    Wait until Active UE reach expected count    ${total_trf_ue}

    ## #######################################
    ## traffic
    ## #######################################
    &{args_trf}    perf_keywords.merge_to_dictionary                   ${args}
    ...                                     start_cell=1
    ...                                       end_cell=6
    ...                                      num_cells=6
    ...                                       start_ue=${args.add_traffic_start_ue}   # hardcoded quickfix
    ...                                         end_ue=${args.add_traffic_end_ue}     # hardcoded quickfix
    ...                                    ue_per_cell=${args.entry_args}
    ...                                           rate=kbps
    ...                                    ul_datarate=${args.add_traffic_ul_datarate}
    ...                                    dl_datarate=${args.add_traffic_dl_datarate}
    ...                                  trf_direction=both
    ...                                  kpi_tolerance=1
    ...                                entry_auto_args=true
    ...                                     entry_args=null
    ...                                          entry=performance_common_add_traffic
    ...                                  traffic_sleep=0
    ...                                    pass_regexp=${None}    # reset
    ...                                  kpi_insert_db=true    # only save ramp kpi
    ...                                  pmc_insert_db=true    # only save ramp pmc
    ...                                   setup_on_air=false
    ...                                          label=ramp_up
    ...                                      subfolder=ramp_up
    ...                                custom_lua_file=commands_common.lua
    ...                                expect_ue_count=${per_cell_trf_ue}

    ${args_trf}    Run Keyword And Continue On Failure    ## robocop: off=possible-variable-overwriting
    ...    performance_keywords.Run Common Test    &{args_trf}

    # #######################################
    # handover
    # #######################################
    Run Keyword And Continue On Failure
    ...    Run lua script    VTM_1208FF_6_SSB_8x4_6Cells_HO_2CC__600UEs_Mixed_HO_100UEs_Percell/commands.lua
    ...               VTM_INTRAGNB_INTERGNB_DROP2(${args.handover_entry_args})
    ...               sleep=1s
    ...               pass_regexp=${None}
    #...               pass_regexp=VTM_INTRAGNB_INTERGNB_DROP2 script completed
    ...               timeout=1800    fail_regexp=${none}

    ${total_ho_ue}    Evaluate    ${total_trf_ue} + ${args.handover_additional_ue}
    Wait until Active UE reach expected count    ${total_ho_ue}

    log to console    Sleep ${args.handover_trf_sleep} for traffic
    Sleep    ${args.handover_trf_sleep}


    TC Params revert    ENABLE_SNAPSHOT    ENABLE_SYSLOG   ENABLE_PM_COUNTER    ENABLE_LOG_DCAP
    performance_keywords.TC Params set to False    ENABLE_BEARER_STATS_COLLECTION
    Run Keyword And Continue On Failure    Send Egate Command And Verify Output    cmd=script_stop

    # #######################################
    # Deregister
    # #######################################
    ${variables}=  Get variables
    IF    "\${ENABLE_PM_COUNTER_deregister}" not in $variables
    ...               Set Test Variable    $ENABLE_PM_COUNTER_deregister    false
    # &{args_deregister}    perf_keywords.merge_to_dictionary    ${args}
    &{args_deregister}    perf_keywords.merge_to_dictionary    ${args_trf}
    ...                                     start_cell=1
    ...                                       end_cell=6
    ...                                      num_cells=6
    ...                                          entry=deregister_multiue_quick
    ...                                       start_ue=1       # hardcoded quickfix
    ...                                         end_ue=9000   # hardcoded quickfix
    ...                                    ue_per_cell=0
    ...                                entry_auto_args=true
    ...                                     entry_args=null
    ...                                custom_lua_file=commands_common.lua
    ...                                          label=deregister
    ...                                      subfolder=deregister
    ...                                expect_ue_count=0
    ...                                    pass_regexp=${None}    # reset
    ...                                  kpi_insert_db=false    # only save ramp kpi
    ...                                  pmc_insert_db=false    # only save ramp pmc
    ...                                  traffic_sleep=0
    ...                        deregister_range_split=10
    ...                        deregister_seq_stop_id=all
    ...                     pmc_verification_sublabel=test_script
    ...                                  setup_on_air=false

    Log to Console     \n${bar_b}\nStart deregister:
    Run Keyword And Continue On Failure    performance_keywords.Run Common Test    get_from_cli=${False}    &{args_deregister}

*** Keywords ***
Mixed_HO_ping_and_traffic_then_deregister_CA_routine
    [Arguments]    ${loop_ctr}=${empty}    ${setup_on_air}=false

    performance_keywords.TC Params set to False    ENABLE_SNAPSHOT    ENABLE_SYSLOG    ENABLE_LOG_DCAP
    ...                                            ENABLE_PM_COUNTER    # CFG_START_DCAP_CONTAINER
    ## #######################################
    ## ping
    ## entry_args is the number of ues per cell for ping traffic
    ## #######################################
    ${args}    Run Keyword And Continue On Failure    Run Common Test
    ...                                  start_cell=1
    ...                                    end_cell=6
    ...                                 ue_per_cell=300
    ...                                   ue_nr_cap=UE_CAP
    ...                           registration_type=InitialRegistration
    ...                                        rate=kbps
    ...                                 ul_datarate=56       # this is hardcoded in the sequence
    ...                                 dl_datarate=56       # this is hardcoded in the sequence
    ...                               trf_direction=both     # this is hardcoded in the sequence
    ...                                     timeout=3000
    ...                               kpi_insert_db=false    # only save ramp kpi
    ...                               pmc_insert_db=false    # only save ramp pmc
    ...                                         lua=VTM_1208FF_6_SSB_8x4_6Cells_HO_2CC__600UEs_Mixed_HO_100UEs_Percell/sansa_TC5.lua
    ...                             custom_lua_file=VTM_1208FF_6_SSB_8x4_6Cells_HO_2CC__600UEs_Mixed_HO_100UEs_Percell/commands.lua
    ...                             entry_auto_args=false
    ...                                  entry_args=300      # special case, this is the number of ue per cell!
    ...                                       entry=PET_1070FF_BF_9000UE_DLUL_rate1dot5_with_ho
    ...                                 pass_regexp=PET_1070FF_BF_9000UE_DLUL_rate1dot5_with_ho script completed
    ...                                setup_on_air=${setup_on_air}

    ## ca args
    ...                                   add_ca_ue=100

    ## traffic args
    ...                        add_traffic_start_ue=8401     # hardcoded quickfix
    ...                          add_traffic_end_ue=9000     # hardcoded quickfix
    ...                     add_traffic_ul_datarate=200
    ...                     add_traffic_dl_datarate=200

    ## handover args
    ...                         handover_entry_args=26,12
    ...                      handover_additional_ue=300
    ...                          handover_trf_sleep=300
    ...                             subfolder=${loop_ctr}ping

    ${total_ping_ue}    Evaluate    ( ${args.entry_args} * ${args.num_cells} ) - 200  # testing for some idle
    Wait until Active UE reach expected count    ${total_ping_ue}

    # #######################################
    # ADD CA UEs
    # #######################################
    Run Keyword And Continue On Failure
    ...    Run lua script    VTM_1208FF_6_SSB_8x4_6Cells_HO_2CC__600UEs_Mixed_HO_100UEs_Percell/commands.lua
    ...               PET_1070FF_BF_9000UE_DLUL_rate1dot5_with_ho_ca_ues(${args.add_ca_ue})
    ...               sleep=1s
    ...               pass_regexp=${None}
    #...               pass_regexp=VTM_INTRAGNB_INTERGNB_DROP2 script completed
    ...               timeout=1800    fail_regexp=${none}

    ${total_trf_ue}    Evaluate    ${total_ping_ue} + (${args.add_ca_ue} * ${args.num_cells})
    Wait until Active UE reach expected count    ${total_trf_ue}

    ## #######################################
    ## traffic
    ## #######################################
    &{args_trf}    perf_keywords.merge_to_dictionary                   ${args}
    ...                                     start_cell=1
    ...                                       end_cell=6
    ...                                      num_cells=6
    ...                                       start_ue=${args.add_traffic_start_ue}
    ...                                         end_ue=${args.add_traffic_end_ue}
    ...                                    ue_per_cell=${args.entry_args}
    ...                                           rate=kbps
    ...                                    ul_datarate=${args.add_traffic_ul_datarate}
    ...                                    dl_datarate=${args.add_traffic_dl_datarate}
    ...                                  trf_direction=both
    ...                                  kpi_tolerance=1
    ...                                entry_auto_args=true
    ...                                     entry_args=null
    ...                                          entry=performance_common_add_traffic
    ...                                  traffic_sleep=0
    ...                                    pass_regexp=${None}    # reset
    ...                                  kpi_insert_db=true    # only save ramp kpi
    ...                                  pmc_insert_db=true    # only save ramp pmc
    ...                                   setup_on_air=false
    ...                                          label=ramp_up
    ...                                      subfolder=${loop_ctr}ramp_up
    ...                                custom_lua_file=commands_common.lua
    ...                                expect_ue_count=none

    ${args_trf}    Run Keyword And Continue On Failure    ## robocop: off=possible-variable-overwriting
    ...    performance_keywords.Run Common Test    &{args_trf}

    # #######################################
    # handover
    # #######################################
    Run Keyword And Continue On Failure
    ...    Run lua script    VTM_1208FF_6_SSB_8x4_6Cells_HO_2CC__600UEs_Mixed_HO_100UEs_Percell/commands.lua
    ...               VTM_INTRAGNB_INTERGNB_DROP2(${args.handover_entry_args})
    ...               sleep=1s
    ...               pass_regexp=${None}
    #...               pass_regexp=VTM_INTRAGNB_INTERGNB_DROP2 script completed
    ...               timeout=1800    fail_regexp=${none}

    ${total_ho_ue}    Evaluate    ${total_trf_ue} + ${args.handover_additional_ue}
    Wait until Active UE reach expected count    ${total_ho_ue}

    log to console    Sleep ${args.handover_trf_sleep} for traffic
    Sleep    ${args.handover_trf_sleep}


    TC Params revert    ENABLE_SNAPSHOT    ENABLE_SYSLOG   ENABLE_PM_COUNTER    ENABLE_LOG_DCAP
    performance_keywords.TC Params set to False    ENABLE_BEARER_STATS_COLLECTION
    Run Keyword And Continue On Failure    Send Egate Command And Verify Output    cmd=script_stop

    # #######################################
    # Deregister
    # #######################################
    ${variables}=  Get variables
    IF    "\${ENABLE_PM_COUNTER_deregister}" not in $variables
    ...               Set Test Variable    $ENABLE_PM_COUNTER_deregister    false
    # &{args_deregister}    perf_keywords.merge_to_dictionary    ${args}
    &{args_deregister}    perf_keywords.merge_to_dictionary    ${args_trf}
    ...                                     start_cell=1
    ...                                       end_cell=6
    ...                                      num_cells=6
    ...                                          entry=deregister_multiue_quick
    ...                                       start_ue=1       # hardcoded quickfix
    ...                                         end_ue=9000   # hardcoded quickfix
    ...                                entry_auto_args=true
    ...                                     entry_args=null
    ...                                custom_lua_file=commands_common.lua
    ...                                          label=deregister
    ...                                      subfolder=${loop_ctr}deregister
    ...                                expect_ue_count=0
    ...                                    pass_regexp=${None}    # reset
    ...                                  kpi_insert_db=false    # only save ramp kpi
    ...                                  pmc_insert_db=false    # only save ramp pmc
    ...                                  traffic_sleep=0
    ...                        deregister_range_split=10
    ...                        deregister_seq_stop_id=all
    ...                     pmc_verification_sublabel=test_script
    ...                                  setup_on_air=false

    Log to Console     \n${bar_b}\nStart deregister:
    Run Keyword And Continue On Failure    performance_keywords.Run Common Test    get_from_cli=${False}    setup_on_air=false    &{args_deregister}
