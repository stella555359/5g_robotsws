*** Settings ***
Documentation
...  author:  Squad 69
...  contact: I_MN_RAN_SW_ULM_ET_AP_PET_GMS
...  Description:   Test Cases for TDD 1 Cell 100 UEs Performance Test

Resource   ./resources/performance_keywords.robot
Resource   ./resources/performance_test_setup.robot
Resource   ./resources/performance_ttitrace.robot

Force Tags    CLOUD_5G_I_LO_AP_LOOO

Suite Setup       performance_test_setup.Suite Setup For Performance Test
#...                   SCF_ENABLE_BEAMFORMING=true
#...                   SCF_CONFIGURE_SRS=true
#...                   ENABLE_SRS_INFO=true
#...                   SCF_SET_VAR_NRCELL_actUlSrsBm=true
#...                   SCF_SET_VAR_NRCELL_actDlSrsBm=true
...                   SCF_ENABLE_BB_POOLING=true
Suite Teardown    performance_test_setup.Suite Teardown For Performance Test
Test Setup        performance_test_setup.Test Case Setup For Performance Test
Test Teardown     performance_test_setup.Test Case Teardown For Performance Test


*** Test Cases ***
tdd_1Cell_100Ues_DL_ABIO_pooling
    [Documentation]
    ...    Performance Test for TDD ABIO configuration with 100 UEs attached to 1 Cell and running DL traffic simultaneously
    [Tags]    DL
    [Setup]    performance_test_setup.Test Case Setup For Performance Test    SCF_ENABLE_BB_POOLING=true
    ...                                                SCF_ENABLE_BEAMFORMING=true
    ...                                                SCF_CONFIGURE_SRS=true
    ...                                                ENABLE_SRS_INFO=true
    ...                                                SCF_SET_VAR_NRCELL_actUlSrsBm=true
    ...                                                SCF_SET_VAR_NRCELL_actDlSrsBm=true
    Set Test Variable   ${QC_TEST_NAME}   [1]L2PS_performance_indicator_check_tdd_1Cell_100Ues_Dl_pooling
    Set Test Variable    ${QC_PATH}       testsuite/Ulm/ET/Performance_Test/resources/qc/ABIO_performance.qc

    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=1
    ...                      num_cells_online=6
    ...                           ue_per_cell=100
    ...                           ul_datarate=0
    ...                           dl_datarate=22200
    ...                                  rate=kbps
    ...                         trf_direction=dl
    ...                             tolerance=0.5945945945945946  # Verify_TP_with_Counters_TDD_DL=33750000
    ...                                   lua=sansa_tdd_1cell.lua
    ...                       entry_auto_args=true
    ...                                 entry=PERFORMANCE_COMMON_TDD_SEQ_BF    # PET_1208FF_BF_100UE_DL
    performance_keywords.Run Common Test    &{tc}



tdd_1Cell_100Ues_UL_ABIO_pooling
    [Documentation]
    ...    Performance Test for TDD ABIO configuration with 100 UEs attached to 1 Cell and running UL traffic simultaneously
    [Tags]    UL
    [Setup]    performance_test_setup.Test Case Setup For Performance Test    SCF_ENABLE_BB_POOLING=true
    ...                                                SCF_ENABLE_BEAMFORMING=true
    ...                                                SCF_CONFIGURE_SRS=true
    ...                                                ENABLE_SRS_INFO=true
    ...                                                SCF_SET_VAR_NRCELL_actUlSrsBm=true
    ...                                                SCF_SET_VAR_NRCELL_actDlSrsBm=true
    Set Test Variable   ${QC_TEST_NAME}   [1]L2PS_performance_indicator_check_tdd_1Cell_100Ues_Ul_pooling
    Set Test Variable    ${QC_PATH}       testsuite/Ulm/ET/Performance_Test/resources/qc/ABIO_performance.qc

    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=1
    ...                      num_cells_online=6
    ...                           ue_per_cell=100
    ...                           ul_datarate=3000
    ...                           dl_datarate=0
    ...                                  rate=kbps
    ...                         trf_direction=ul
    ...                             tolerance=0.5945945945945946  # Verify_TP_with_Counters_TDD_DL=33750000
    ...                                   lua=sansa_tdd_1cell.lua
    ...                       entry_auto_args=true
    ...                                 entry=PERFORMANCE_COMMON_TDD_SEQ_BF    # PET_1208FF_BF_100UE_DL
    performance_keywords.Run Common Test    &{tc}


tdd_1Cell_100Ues_ABIO_pooling
    [Documentation]
    ...    Performance Test for TDD ABIO configuration with 100 UEs attached to 1 Cell and running UL+DL traffic simultaneously
    [Tags]    ULDL

    Run Common Test                start_cell=1
    ...                              end_cell=1
    ...                      num_cells_online=6
    ...                           ue_per_cell=100
    ...                           ul_datarate=3000
    ...                           dl_datarate=22200
    ...                                  rate=kbps
    ...                         trf_direction=both
    ...                             tolerance=0.4
    ...                                   lua=sansa_tdd_1cell.lua
    ...                             ue_nr_cap=UE_CAP
    ...                       entry_auto_args=true
    ...                                 entry=performance_common_seq_lua_tdd


tdd_3cells_varUEs_UL_ABIO_pooling
    [Setup]    performance_test_setup.Test Case Setup For Performance Test    SCF_ENABLE_BB_POOLING=true
    ...                                                ENABLE_TTI_TRACE_QUICK=true
    ...                                                ENABLE_LTEPAT=false
    ...                                                SCF_ENABLE_BEAMFORMING=true
    ...                                                SCF_CONFIGURE_SRS=true
    ...                                                ENABLE_SRS_INFO=true
    ...                                                SCF_SET_VAR_NRCELL_actUlSrsBm=true
    ...                                                SCF_SET_VAR_NRCELL_actDlSrsBm=true
    ...                                                SCF_SET_VENDOR_NRBTS_i40_maxNumScheUePuschL1Pool=30
    ...                                                SCF_SET_VENDOR_NRBTS_i40_maxNumScheUePuschL1Sp=30

    performance_keywords.Run Common Test                start_cell=1
    ...                              end_cell=6
    ...                           ue_per_cell=50
    ...                           ul_datarate=0
    ...                           dl_datarate=0
    ...                                  rate=kbps
    ...                         trf_direction=ul
    ...                         cell_ul_throughput=14000,150000,17000,0,0,0
    ...                             tolerance=0.2
    ...                                   lua=sansa_tdd_6cell.lua
    ...                       entry_auto_args=true
    ...                                 entry=performance_common_seq_active_cells_lua_tdd
    ...                           cell_max_ue=16,1,13,0,0,0
    ...                          active_cells=1,2,3
    performance_ttitrace.Check TTI Trace Total Number of Sched UEs Per L1Pool
    Verify CB013028-A-TC01 Counters


tdd_3cells_varUEs_UL_ABIO_CB014179_pooling
    [Setup]    performance_test_setup.Test Case Setup For Performance Test    SCF_ENABLE_BB_POOLING=true
    ...                                                ENABLE_TTI_TRACE_QUICK=true
    ...                                                ENABLE_LTEPAT=true
    ...                                                ENABLE_ONLINE_REPORTING=true
    ...                                                SCF_SET_NRBTS_actBbPoolExtensionTddFr1=true
    ...                                                SCF_ENABLE_BEAMFORMING=true
    ...                                                SCF_CONFIGURE_SRS=true
    ...                                                ENABLE_SRS_INFO=true
    ...                                                SCF_SET_VAR_NRCELL_actUlSrsBm=true
    ...                                                SCF_SET_VAR_NRCELL_actDlSrsBm=true

    ${QC_TEST_NAME_tmp}             Catenate    SEPARATOR=    [1]USCB014179-B#1_Maximum_number_of_
    ...                             PUSCH_UEs_per_slot_per_BB_pool_and_L1_subpool_on_half_ABIO_
    ...                             with_3_FR1_TDD_eCPRI_cells
    Set Test Variable   ${QC_TEST_NAME}    ${QC_TEST_NAME_tmp}
    Set Test Variable    ${QC_PATH}    testsuite/Ulm/ET/Performance_Test/resources/qc/CB014179_B_TC01.qc

    performance_keywords.Run Common Test                start_cell=1
    ...                              end_cell=6
    ...                           ue_per_cell=50
    ...                           ul_datarate=0
    ...                           dl_datarate=0
    ...                                  rate=kbps
    ...                         trf_direction=ul
    ...                         cell_ul_throughput=15000,15000,30000,0,0,0
    ...                             tolerance=0.2
    ...                                   lua=sansa_tdd_6cell.lua
    ...                       entry_auto_args=true
    ...                                 entry=performance_common_seq_active_cells_lua_tdd
    ...                           cell_max_ue=16,16,8,0,0,0
    ...                          active_cells=1,2,3
    performance_ttitrace.Check TTI Trace Total Number of Sched UEs Per L1Pool  count=40
    Verify CB014179-B-TC01 Counters


tdd_3cells_varUEs_UL_Full_ABIO_CB014179_16DL8UL_pooling
    [Setup]    performance_test_setup.Test Case Setup For Performance Test    SCF_ENABLE_BB_POOLING=true
    ...                                                ENABLE_TTI_TRACE_QUICK=true
    ...                                                ENABLE_LTEPAT=true
    ...                                                ENABLE_ACT_BSR=auto
    ...                                                ENABLE_ONLINE_REPORTING=true

    ${QC_TEST_NAME_tmp}             Catenate    SEPARATOR=    [1]USCB014179-C#1_Maximum_number_of_PUSCH_UEs_
    ...                             per_slot_per_BB_pool_on_full_ABIO_with_3_FR1_TDD_eCPRI_cells
    Set Test Variable   ${QC_TEST_NAME}    ${QC_TEST_NAME_tmp}
    Set Test Variable    ${QC_PATH}    testsuite/Ulm/ET/Performance_Test/resources/qc/CB014179_C_TC01.qc

    performance_keywords.Run Common Test                start_cell=1
    ...                              end_cell=3
    ...                           ue_per_cell=50
    ...                           ul_datarate=0
    ...                           dl_datarate=0
    ...                                  rate=kbps
    ...                         trf_direction=ul
    ...                         cell_ul_throughput=5000,5000,5000
    ...                             tolerance=0.2
    ...                                   lua=sansa_tdd_3cell.lua
    ...                       entry_auto_args=true
    ...                                 entry=performance_common_seq_active_cells_lua_tdd
    ...                           cell_max_ue=50,50,50
    ...                          active_cells=1,2,3
    performance_ttitrace.Check TTI Trace Total Number of Sched UEs Per L1Pool  count=48
    Verify CB014179-C-TC01 Counters


tdd_3cells_varUEs_DL_ABIO_pooling
    [Setup]    performance_test_setup.Test Case Setup For Performance Test    SCF_ENABLE_BB_POOLING=true
    ...                                                ENABLE_TTI_TRACE_QUICK=true
    ...                                                ENABLE_LTEPAT=false
    ...                                                SCF_ENABLE_BEAMFORMING=true
    ...                                                SCF_CONFIGURE_SRS=true
    ...                                                ENABLE_SRS_INFO=true
    ...                                                SCF_SET_VAR_NRCELL_actUlSrsBm=true
    ...                                                SCF_SET_VAR_NRCELL_actDlSrsBm=true
    ...                                                SCF_SET_VENDOR_NRBTS_i40_maxNumScheUePuschL1Pool=30
    ...                                                SCF_SET_VENDOR_NRBTS_i40_maxNumScheUePuschL1Sp=30

    performance_keywords.Run Common Test                start_cell=1
    ...                              end_cell=6
    ...                           ue_per_cell=50
    ...                           ul_datarate=0
    ...                           dl_datarate=0
    ...                                  rate=kbps
    ...                         trf_direction=dl
    ...                         cell_dl_throughput=102000,175000,175000,0,0,0
    ...                             tolerance=0.2
    ...                                   lua=sansa_tdd_6cell.lua
    ...                       entry_auto_args=true
    ...                                 entry=performance_common_seq_active_cells_lua_tdd
    ...                           cell_max_ue=16,6,8,0,0,0
    ...                          active_cells=1,2,3
    performance_ttitrace.Check TTI Trace Total Number of Sched UEs Per L1Pool for DL
    Verify CB013028-A-TC02 Counters


tdd_6cells_VTM_INTRAGNB_INTERGNB_DROP2
    [Setup]    performance_test_setup.Test Case Setup For Performance Test
    ...     SCF_CONFIGURE_SRS=false
    ...     ENABLE_SRS_INFO=false
    ...     SCF_SET_VAR_NRCELL_actUlSrsBm=false
    ...     SCF_SET_VAR_NRCELL_actDlSrsBm=false
    ...     ENABLE_LOG_DCAP=true
    ...     SCF_SET_VAR_NRCELL_actUeCsirsCoexistCellCsirs=true    #required for srs
    ...     SCF_ENABLE_BEAMFORMING=true

    performance_egate.Copy Specific Egate Scripts To Wts Folder    VTM_1208FF_6_SSB_8x4_6Cells_HO_2CC__600UEs_Mixed_HO_100UEs_Percell
    ...                       multi_ue_sa_script_new.lua
    performance_common_tc.Run Common Test With Deregister    start_cell=1
    ...                                  end_cell=6
    ...                               ue_per_cell=1
    ...                               ul_datarate=0
    ...                               dl_datarate=1
    ...                                 tolerance=1
    ...                                      rate=kbps
    ...                             trf_direction=both
    ...                                       lua=VTM_1208FF_6_SSB_8x4_6Cells_HO_2CC__600UEs_Mixed_HO_100UEs_Percell/sansa_TC4.lua
    ...                           entry_auto_args=false
    ...                           custom_lua_file=VTM_1208FF_6_SSB_8x4_6Cells_HO_2CC__600UEs_Mixed_HO_100UEs_Percell/commands.lua
    ...                                     entry=VTM_INTRAGNB_INTERGNB_DROP2(50,25)
    ...                             traffic_sleep=3600
    ...                                   timeout=3600


tdd_3cells_varUEs_UL_DL_ABIO_pooling
    [Setup]    performance_test_setup.Test Case Setup For Performance Test    SCF_ENABLE_BB_POOLING=true
    ...                                                ENABLE_TTI_TRACE_QUICK=true
    ...                                                ENABLE_ONLINE_REPORTING=true
    ...                                                ENABLE_LTEPAT=true
    ...                                                SCF_ENABLE_BEAMFORMING=true
    ...                                                SCF_CONFIGURE_SRS=true
    ...                                                ENABLE_SRS_INFO=true
    ...                                                SCF_SET_VAR_NRCELL_actUlSrsBm=true
    ...                                                SCF_SET_VAR_NRCELL_actDlSrsBm=true
    ...                                                SCF_SET_VENDOR_NRBTS_i40_maxNumScheUePuschL1Pool=30
    ...                                                SCF_SET_VENDOR_NRBTS_i40_maxNumScheUePuschL1Sp=30

    ${QC_TEST_NAME_tmp}             Catenate    SEPARATOR=    [1][1.0] CB013028_A_TC03_
    ...                             Benchmark_at_PET_the_number_of_PDSCH_and_PUSCH_UEs_per_slot_per_BB_pool_L1_subpool_
    ...                             and_L2_subpool_on_half_ABIO_with_3_FR1_TDD_eCPRI_cells
    Set Test Variable   ${QC_TEST_NAME}    ${QC_TEST_NAME_tmp}
    Set Test Variable    ${QC_PATH}    testsuite/Ulm/ET/Performance_Test/resources/qc/CB013028_A_TC03.qc

    performance_keywords.Run Common Test                start_cell=1
    ...                              end_cell=6
    ...                           ue_per_cell=50
    ...                           ul_datarate=0
    ...                           dl_datarate=0
    ...                                  rate=kbps
    ...                         trf_direction=both
    ...                         cell_ul_throughput=14000,35000,35000,0,0,0
    ...                         cell_dl_throughput=102000,175000,175000,0,0,0
    ...                             tolerance=0.2
    ...                                   lua=sansa_tdd_6cell.lua
    ...                       entry_auto_args=true
    ...                                 entry=performance_common_seq_active_cells_lua_tdd
    ...                           cell_max_ue=16,7,7,0,0,0
    ...                          active_cells=1,2,3
    performance_ttitrace.Check TTI Trace Total Number of Sched UEs Per L1Pool
    performance_ttitrace.Check TTI Trace Total Number of Sched UEs Per L1Pool for DL
    Verify CB013028-A-TC03 Counters


Mixed_HO_ping_and_traffic_then_deregister
    [Setup]    performance_test_setup.Test Case Setup For Performance Test
    ...     SCF_CONFIGURE_SRS=false
    ...     ENABLE_SRS_INFO=false
    ...     SCF_SET_VAR_NRCELL_actUlSrsBm=false
    ...     SCF_SET_VAR_NRCELL_actDlSrsBm=false
    ...     ENABLE_LOG_DCAP=true
    ...     SCF_SET_VAR_NRCELL_actUeCsirsCoexistCellCsirs=true    #required for srs
    ...     ENABLE_SOS_REPORT=false   # it causes too much cpu
    ...     ENABLE_LOG_ARCHIVE_COMPRESSION=false   # it causes too much cpu
    ...     SCF_ENABLE_BEAMFORMING=true

    performance_egate.Copy Specific Egate Scripts To Wts Folder    VTM_1208FF_6_SSB_8x4_6Cells_HO_2CC__600UEs_Mixed_HO_100UEs_Percell
    ...                                                            multi_ue_sa_script_new.lua

    performance_keywords.TC Params Set To False    ENABLE_SNAPSHOT    ENABLE_SYSLOG    ENABLE_LOG_DCAP
    ...                                            ENABLE_PM_COUNTER    # CFG_START_DCAP_CONTAINER

    ## #######################################
    ## ping
    ## entry_args is the number of ues per cell for ping traffic
    ## #######################################
    ${args}    Run Keyword And Continue On Failure    performance_keywords.Run Common Test
    ...                                   start_cell=1
    ...                                     end_cell=6
    ...                                  ue_per_cell=400
    ...                                    ue_nr_cap=UE_CAP
    ...                            registration_type=InitialRegistration
    ...                                         rate=kbps
    ...                                  ul_datarate=56       # this is hardcoded in the sequence
    ...                                  dl_datarate=56       # this is hardcoded in the sequence
    ...                                trf_direction=both     # this is hardcoded in the sequence
    ...                                      timeout=3000
    ...                                kpi_insert_db=false    # only save ramp kpi
    ...                                pmc_insert_db=false    # only save ramp pmc
    ...                                          lua=VTM_1208FF_6_SSB_8x4_6Cells_HO_2CC__600UEs_Mixed_HO_100UEs_Percell/sansa_TC4.lua
    ...                              custom_lua_file=VTM_1208FF_6_SSB_8x4_6Cells_HO_2CC__600UEs_Mixed_HO_100UEs_Percell/commands.lua
    ...                              entry_auto_args=false
    ...                                   entry_args=400      # special case, this is the number of ue per cell!
    ...                                        entry=PET_1070FF_BF_9000UE_DLUL_rate1dot5_with_ho
    ...                                  pass_regexp=PET_1070FF_BF_9000UE_DLUL_rate1dot5_with_ho script completed
    ## traffic args
    ...                         add_traffic_start_ue=6301
    ...                           add_traffic_end_ue=6900
    ...                      add_traffic_ul_datarate=200
    ...                      add_traffic_dl_datarate=200
    ## handover args
    ...                          handover_entry_args=26,12
    ...                       handover_additional_ue=300
    ...                           handover_trf_sleep=300

    ${total_ping_ue}    Evaluate    ${args.entry_args} * ${args.num_cells}
    Wait Until Active UE Reach Expected Count    ${total_ping_ue}

    ## #######################################
    ## traffic
    ## #######################################
    &{args_trf}    perf_keywords.Merge To Dictionary                   ${args}
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
    ...                                expect_ue_count=${args.entry_args}

    ${args_trf}    Run Keyword And Continue On Failure    ## robocop: off=possible-variable-overwriting
    ...    performance_keywords.Run Common Test    &{args_trf}

    # #######################################
    # handover
    # #######################################
    Run Keyword And Continue On Failure
    ...    Run Lua Script    VTM_1208FF_6_SSB_8x4_6Cells_HO_2CC__600UEs_Mixed_HO_100UEs_Percell/commands.lua
    ...               VTM_INTRAGNB_INTERGNB_DROP2(${args.handover_entry_args})
    ...               sleep=1s
    ...               pass_regexp=${None}
    #...               pass_regexp=VTM_INTRAGNB_INTERGNB_DROP2 script completed
    ...               timeout=1800    fail_regexp=${none}

    ${total_ho_ue}    Evaluate    ${total_ping_ue} + ${args.handover_additional_ue}
    Wait Until Active UE Reach Expected Count    ${total_ho_ue}

    Log To Console    Sleep ${args.handover_trf_sleep} for traffic
    Sleep    ${args.handover_trf_sleep}

    performance_keywords.TC Params Revert    ENABLE_SNAPSHOT    ENABLE_SYSLOG   ENABLE_PM_COUNTER    ENABLE_LOG_DCAP
    performance_keywords.TC Params Set To False    ENABLE_BEARER_STATS_COLLECTION
    #Run Keyword And Continue On Failure    performance_dcap.Start DCAP    # hardcoded DCAP

    #Run Keyword And Continue On Failure    Send Egate Command And Verify Output    cmd=seq_stop id=all
    Run Keyword And Continue On Failure    Send Egate Command And Verify Output    cmd=script_stop

    # #######################################
    # Deregister
    # #######################################
    ${variables}=  Get Variables
    IF    "\${ENABLE_PM_COUNTER_deregister}" not in $variables    Set Test Variable    $ENABLE_PM_COUNTER_deregister    false
    # &{args_deregister}    perf_keywords.merge_to_dictionary    ${args}
    &{args_deregister}    perf_keywords.Merge To Dictionary    ${args_trf}
    ...                                          entry=deregister_multiue_quick
    ...                                       start_ue=1       # hardcoded quickfix
    ...                                         end_ue=9000   # hardcoded quickfix
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

    Log To Console     \n${bar_b}\nStart deregister:
    Run Keyword And Continue On Failure
    ...    performance_keywords.Run Common Test    get_from_cli=${False}    &{args_deregister}

    # hardcoded DCAP
    #Run Keyword And Continue On Failure    performance_dcap.Stop and Collect DCAP    subfolder=deregister
    #...                                                                              archive_name=emil_traces_test_script
