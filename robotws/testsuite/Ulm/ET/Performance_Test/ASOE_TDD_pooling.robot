*** Settings ***
Documentation
...  author:  Squad 69
...  contact: I_MN_RAN_SW_ULM_ET_AP_PET_GMS
...  Description:   Test Cases ASOE BB Pooling enabled

Resource          ./resources/performance_info.robot
Resource          ./resources/performance_egate.robot
Resource          ./resources/performance_keywords.robot
Resource          ./resources/performance_log_collection.robot
Resource          ./resources/performance_verification.robot
Resource          ./resources/performance_common_tc.robot
Resource          ./resources/performance_ttitrace.robot
Resource          ./resources/performance_test_setup.robot


Suite Setup       performance_test_setup.Suite Setup For Performance Test    SCF_ENABLE_BB_POOLING=true
...                                                   SCF_ENABLE_BEAMFORMING=true
...                                                   SCF_CONFIGURE_SRS=true
...                                                   ENABLE_SRS_INFO=true
...                                                   SCF_SET_VAR_NRCELL_actUlSrsBm=true
...                                                   SCF_SET_VAR_NRCELL_actDlSrsBm=true
Suite Teardown    performance_test_setup.Suite Teardown For Performance Test
Test Setup        performance_test_setup.Test Case Setup For Performance Test
Test Teardown     performance_test_setup.Test Case Teardown For Performance Test


*** Test Cases ***
tdd_1Cell_100Ues_DL_ASOE_pooling
    [Documentation]
    ...    Performance Test for TDD ASOE configuration with 100 UEs attached to 1 Cell and running DL traffic simultaneously
    ...    BB pooling enabled
    [Tags]    DL
    [Setup]    performance_test_setup.Test Case Setup For Performance Test    ENABLE_MARVIN=true
    Set Test Variable   ${QC_TEST_NAME}   [1]L2PS_performance_indicator_check_tdd_1Cell_100Ues_Dl_pooling

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


tdd_1Cell_100Ues_UL_ASOE_pooling
    [Documentation]
    ...    Performance Test for TDD ABIO configuration with 100 UEs attached to 1 Cell and running UL traffic simultaneously
    ...    BB pooling enabled
    [Tags]    UL
    [Setup]    performance_test_setup.Test Case Setup For Performance Test    ENABLE_MARVIN=true
    Set Test Variable   ${QC_TEST_NAME}   [1]L2PS_performance_indicator_check_tdd_1Cell_100Ues_Ul_pooling

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


tdd_1Cell_100Ues_ASOE_pooling
    [Documentation]
    ...    Performance Test for TDD ASOE configuration with 100 UEs attached to 1 Cell and running UL+DL traffic simultaneously
    ...    BB pooling enabled
    [Tags]    ULDL
    [Setup]    Test case setup for Performance Test    SCF_ENABLE_BB_POOLING=true

    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=1
    ...                      num_cells_online=6
    ...                           ue_per_cell=100
    ...                           ul_datarate=3000
    ...                           dl_datarate=22200
    ...                                  rate=kbps
    ...                         trf_direction=both
    ...                             ue_nr_cap=UE_CAP
    ...                             tolerance=0.45945945945945946
    ...                                   lua=sansa_tdd_1cell.lua
    ...                       entry_auto_args=true
    ...                                 entry=performance_common_seq_lua_tdd
    performance_keywords.Run Common Test    &{tc}

tdd_2CellsPer2Cores_100UesPerCell_UL_DL_ASOE
    [Documentation]   SRS Enabled Cell 1 and Cell 3 test
    [Setup]    performance_test_setup.Test Case Setup For Performance Test    SCF_ENABLE_BB_POOLING=true
    ...                                                SCF_SET_VAR_NRBTS_actBbPoolTddFr1Enh=true
    ...                                                SCF_SET_VAR_NRSYSINFO0x5fPROFILE_systemInformationTargetRate=157
    ...                                                ENABLE_MARVIN=true

    Set Test Variable   ${QC_TEST_NAME}   [1]L2PS_performance_indicator_check_tdd_2CellsPer2Cores_100UesPerCell
    performance_keywords.Run Common Test                   start_cell=1
    ...                                 end_cell=6
    ...                             active_cells=1,3
    ...                              ul_datarate=3000
    ...                              dl_datarate=12800
    ...                                     rate=kbps
    ...                            trf_direction=both
    ...                                 start_ue=1
    ...                              ue_per_cell=100
    ...                                period_ms=none
    ...                                      lua=sansa_tdd_6cell.lua
    ...                                ue_nr_cap=UE_CAP_MUMIMO
    ...                        registration_type=InitialRegistration
    ...                                tolerance=.5    # very low tput drop expected
    ...                          entry_auto_args=true
    ...                                    entry=performance_common_seq_active_cells_lua_tdd
    ...                                  timeout=2400


tdd_6cell_1500Ues_ASOE_pooling
    [Documentation]   SRS Enabled Cell 1 and Cell 3 test

    performance_keywords.Run Common Test                   start_cell=1
    ...                                 end_cell=6
    ...                             active_cells=1,3
    ...                              ul_datarate=153
    ...                              dl_datarate=1126
    ...                                     rate=kbps
    ...                            trf_direction=both
    ...                                 start_ue=1
    ...                              ue_per_cell=1500
    ...                                period_ms=none
    ...                                      lua=sansa_tdd_6cell.lua
    ...                                ue_nr_cap=UE_CAP_MUMIMO
    ...                        registration_type=InitialRegistration
    ...                                tolerance=.5    # very low tput drop expected
    ...                          entry_auto_args=true
    ...                                    entry=performance_common_seq_active_cells_lua_tdd
    ...                                  timeout=3000


ASOE_TDD_8Cells_30UEsPerCell_UL_DL
    [Documentation]    4x4 MIMO 8 Cells Full ASOE
    [Tags]    ULDL    CLOUD_5G_O_E_AP_LOOO    ASOE    TDD
    [Setup]    performance_test_setup.Test Case Setup For Performance Test    SCF_SET_VAR_NRCELL_actUlSrsBm=false
    ...                                                SCF_SET_VAR_NRCELL_actDlSrsBm=false

    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=8
    ...                           ue_per_cell=20
    ...                           ul_datarate=3000
    ...                           dl_datarate=12800
    ...                                  rate=kbps
    ...                         trf_direction=both
    ...                             ue_nr_cap=UE_CAP
    ...                             tolerance=0.8828125
    ...                                   lua=sansa_tdd_8cell.lua
    ...                       entry_auto_args=true
    ...                                 entry=performance_common_seq_lua_tdd
    ...                               timeout=2400
    performance_keywords.Run Common Test    &{tc}



ASOE_TDD_8Cells_30UEsPerCell_UL_DL_CELL_1_to_4
    [Documentation]    4x4 MIMO 8 Cells Full ASOE
    [Tags]    ULDL    CLOUD_5G_O_E_AP_LOOO    ASOE    TDD

    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=8
    ...                           ue_per_cell=30
    ...                           ul_datarate=3000
    ...                           dl_datarate=12800
    ...                                  rate=kbps
    ...                         trf_direction=both
    ...                             ue_nr_cap=UE_CAP
    ...                             tolerance=0.8828125
    ...                                   lua=sansa_tdd_8cell.lua
    ...                       entry_auto_args=true
    ...                                 entry=performance_common_seq_active_cells_lua_tdd
    ...                               timeout=2400
    ...                          active_cells=1,2,3,4
    performance_keywords.Run Common Test    &{tc}



ASOE_TDD_8Cells_VarUEsPerCell_UL
    [Documentation]    4x4 MIMO 8 Cells Full ASOE
    [Tags]    UL    CLOUD_5G_O_E_AP_LOOO    ASOE    TDD
    [Setup]    performance_test_setup.Test Case Setup For Performance Test    ENABLE_TTI_TRACE_QUICK=true
    ...                                                SCF_SET_VAR_NRCELL_actDlSrsBm=false
    ...                                                SCF_SET_VAR_NRCELL_actUlSrsBm=false
    ...                                                SCF_SET_VENDOR_NRBTS_i40_maxNumScheUePuschL1Pool=30
    ...                                                SCF_SET_VENDOR_NRBTS_i40_maxNumScheUePuschL1Sp=30
    ...                                                SCF_SET_VAR_NRCELL_maxNumPdschAllocationPerSlot=16
    ...                                                SCF_SET_VAR_NRCELL_maxNumPuschAllocationPerSlot=16

    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=8
    ...                           ue_per_cell=16
    ...                           ul_datarate=0
    ...                           dl_datarate=0
    ...                           cell_ul_throughput=15000,30000,75000,0,0,0,75000,0
    ...                                  rate=kbps
    ...                         trf_direction=ul
    ...                             ue_nr_cap=UE_CAP
    ...                             tolerance=0.8828125
    ...                                   lua=sansa_tdd_8cell.lua
    ...                       entry_auto_args=true
    ...                                 entry=performance_common_seq_lua_tdd
    ...                               timeout=2400
    ...                          active_cells=all
    ...                         cell_max_ue=16,8,3,0,0,0,3,0
    performance_keywords.Run Common Test    &{tc}
    performance_ttitrace.Check TTI Trace Total Number of Sched UEs Per L1Pool
    Verify CB013028-C-TC01 Counters


ASOE_TDD_8Cells_VarUEsPerCell_UL_CB014179
    [Documentation]    4x4 MIMO 8 Cells Full ASOE
    [Tags]    UL    CLOUD_5G_O_E_AP_LOOO    ASOE    TDD
    [Setup]    performance_test_setup.Test Case Setup For Performance Test    ENABLE_TTI_TRACE_QUICK=true
    ...                                                ENABLE_ONLINE_REPORTING=true
    ...                                                SCF_SET_VAR_NRCELL_actDlSrsBm=false
    ...                                                ENABLE_LTEPAT=true
    ...                                                SCF_SET_VAR_NRCELL_actUlSrsBm=false
    ...                                                SCF_SET_VAR_NRCELL_maxNumPdschAllocationPerSlot=16
    ...                                                SCF_SET_VAR_NRCELL_maxNumPuschAllocationPerSlot=16
    ...                                                SCF_SET_NRBTS_actBbPoolExtensionTddFr1=true
    ...                                                ENABLE_MARVIN=true

    ${QC_TEST_NAME_tmp}             Catenate    SEPARATOR=    [1]USCB014179-B#2_Maximum_number_
    ...                             of_PUSCH_UEs_per_slot_per_BB_pool_and_L1_subpool_on_half_
    ...                             ASOE-F_with_4_FR1_TDD_eCPRI_cells
    Set Test Variable   ${QC_TEST_NAME}    ${QC_TEST_NAME_tmp}
    Set Test Variable    ${QC_PATH}    testsuite/Ulm/ET/Performance_Test/resources/qc/CB014179_B_TC02.qc

    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=8
    ...                           ue_per_cell=40
    ...                           ul_datarate=0
    ...                           dl_datarate=0
    ...                           cell_ul_throughput=15000,60000,15000,0,0,0,60000,0
    ...                                  rate=kbps
    ...                         trf_direction=ul
    ...                             ue_nr_cap=UE_CAP
    ...                             tolerance=0.8828125
    ...                                   lua=sansa_tdd_8cell.lua
    ...                       entry_auto_args=true
    ...                                 entry=performance_common_seq_lua_tdd
    ...                               timeout=2400
    ...                          active_cells=1,2,3,7
    ...                         cell_max_ue=16,4,16,0,0,0,4,0
    ${args}       performance_keywords.Run Common Test    &{tc}
    performance_ttitrace.Check TTI Trace Total Number of Sched UEs Per L1Pool  inactive_cells=${args.inactive_cells}  count=40
    Verify CB014179-B-TC02 Counters


ASOE_TDD_8Cells_VarUEsPerCell_DL
    [Documentation]    4x4 MIMO 8 Cells Full ASOE
    [Tags]    DL    CLOUD_5G_O_E_AP_LOOO    ASOE    TDD
    [Setup]    performance_test_setup.Test Case Setup For Performance Test    ENABLE_TTI_TRACE_QUICK=true
    ...                                                SCF_SET_VAR_NRCELL_actDlSrsBm=false
    ...                                                SCF_SET_VAR_NRCELL_actUlSrsBm=false
    ...                                                SCF_SET_VENDOR_NRBTS_i40_maxNumScheUePuschL1Pool=30
    ...                                                SCF_SET_VENDOR_NRBTS_i40_maxNumScheUePuschL1Sp=30
    ...                                                SCF_SET_VAR_NRCELL_maxNumPdschAllocationPerSlot=16
    ...                                                SCF_SET_VAR_NRCELL_maxNumPuschAllocationPerSlot=16

    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=8
    ...                           ue_per_cell=16
    ...                           ul_datarate=0
    ...                           dl_datarate=0
    ...                           cell_dl_throughput=110000,175000,175000,0,0,0,175000,0
    ...                                  rate=kbps
    ...                         trf_direction=dl
    ...                             ue_nr_cap=UE_CAP
    ...                             tolerance=0.8828125
    ...                                   lua=sansa_tdd_8cell.lua
    ...                       entry_auto_args=true
    ...                                 entry=performance_common_seq_lua_tdd
    ...                               timeout=2400
    ...                          active_cells=all
    ...                         cell_max_ue=16,8,3,0,0,0,3,0
    performance_keywords.Run Common Test    &{tc}
    performance_ttitrace.Check TTI Trace Total Number of Sched UEs Per L1Pool for DL
    Verify CB013028-C-TC02 Counters


ASOE_TDD_8Cells_VarUEsPerCell_UL_DL
    [Documentation]    4x4 MIMO 8 Cells Full ASOE
    [Tags]    ULDL    CLOUD_5G_O_E_AP_LOOO    ASOE    TDD
    [Setup]    performance_test_setup.Test Case Setup For Performance Test    ENABLE_TTI_TRACE_QUICK=true
    ...                                                SCF_SET_VAR_NRCELL_actDlSrsBm=false
    ...                                                SCF_SET_VAR_NRCELL_actUlSrsBm=false
    ...                                                ENABLE_ONLINE_REPORTING=true
    ...                                                ENABLE_LTEPAT=true
    ...                                                SCF_SET_VENDOR_NRBTS_i40_maxNumScheUePuschL1Pool=30
    ...                                                SCF_SET_VENDOR_NRBTS_i40_maxNumScheUePuschL1Sp=30
    ...                                                SCF_SET_VAR_NRCELL_maxNumPdschAllocationPerSlot=16
    ...                                                SCF_SET_VAR_NRCELL_maxNumPuschAllocationPerSlot=16
    ...                                                ENABLE_MARVIN=true

    ${QC_TEST_NAME_tmp}             Catenate    SEPARATOR=    [1][1.0] CB013028_C_TC03_
    ...                             Benchmark_at_PET_the_number_of_PDSCH_and_PUSCH_UEs_per_slot_per_BB_pool_L1_subpool_
    ...                             and_L2_subpool_on_half_ASOE_with_4_FR1_TDD_eCPRI_cells
    Set Test Variable   ${QC_TEST_NAME}    ${QC_TEST_NAME_tmp}
    Set Test Variable    ${QC_PATH}    testsuite/Ulm/ET/Performance_Test/resources/qc/CB013028_C_TC03.qc

    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=8
    ...                           ue_per_cell=16
    ...                           ul_datarate=0
    ...                           dl_datarate=0
    ...                           cell_ul_throughput=20000,30000,75000,0,0,0,75000,0
    ...                           cell_dl_throughput=120000,175000,175000,0,0,0,175000,0
    ...                                  rate=kbps
    ...                         trf_direction=both
    ...                             ue_nr_cap=UE_CAP
    ...                             tolerance=0.8828125
    ...                                   lua=sansa_tdd_8cell.lua
    ...                       entry_auto_args=true
    ...                                 entry=performance_common_seq_lua_tdd
    ...                               timeout=2400
    ...                          active_cells=all
    ...                         cell_max_ue=16,8,3,0,0,0,3,0
    performance_keywords.Run Common Test    &{tc}
    performance_ttitrace.Check TTI Trace Total Number of Sched UEs Per L1Pool
    performance_ttitrace.Check TTI Trace Total Number of Sched UEs Per L1Pool for DL
    Verify CB013028-C-TC03 Counters


ASOE_TDD_20UE_Ramp_varUE
    [Setup]    performance_test_setup.Test Case Setup For Performance Test
    ...                 SCF_SET_VAR_NRBTS_actFdmScheduling=true
    ...            SCF_SET_VAR_NRBTS_actSchedFairnessUlOlc=true
    ...     SCF_SET_VAR_NRCELL_actIncreasedFdmUsersPerSlot=true
    ...    SCF_SET_VAR_NRCELL_maxNumPdschAllocationPerSlot=16
    ...    SCF_SET_VAR_NRCELL_maxNumPuschAllocationPerSlot=16
    ...                              SCF_ENABLE_BB_POOLING=true
    ...                     ENABLE_BEARER_STATS_COLLECTION=true
    performance_common_tc.Run Common Test With Ramp
    ...                            start_cell=1
    ...                              end_cell=6
    ...                           ue_per_cell=20
    ...                           ul_datarate=1000
    ...                           dl_datarate=1000
    ...                                  rate=kbps
    ...                         trf_direction=both
    ...                             tolerance=.2
    ...                                   lua=sansa_tdd_6cell.lua
    ...                             ue_nr_cap=UE_CAP_MUMIMO
    ...                       entry_auto_args=true
    ...                                 entry=PERFORMANCE_COMMON_TDD_V2
                                    ## params for ramp ue
    ...                      ramp_ue_per_cell=200
    ...                      ramp_ul_datarate=1000
    ...                      ramp_dl_datarate=1000
    ...                    ramp_trf_direction=both
    ...                   ramp_register_delay=1
    ...                            ramp_entry=performance_common_lua_v2
    ...                        ramp_traffic_sleep=0
    ...                          active_cells=1,3
    ...                          trf_protocol=udp


ASOE_TDD_20UE_Ramp_varUE_DL_CsReductionFactorOlc_0
    [Setup]    performance_test_setup.Test Case Setup For Performance Test
    ...                 SCF_SET_VAR_NRBTS_actFdmScheduling=true
    ...            SCF_SET_VAR_NRBTS_actSchedFairnessUlOlc=true
    ...     SCF_SET_VAR_NRCELL_actIncreasedFdmUsersPerSlot=true
    ...    SCF_SET_VAR_NRCELL_maxNumPdschAllocationPerSlot=16
    ...    SCF_SET_VAR_NRCELL_maxNumPuschAllocationPerSlot=16
    ...                              SCF_ENABLE_BB_POOLING=true
    ...                     ENABLE_BEARER_STATS_COLLECTION=true
    performance_common_tc.Run Common Test With Ramp
    ...                            start_cell=1
    ...                              end_cell=6
    ...                           ue_per_cell=20
    ...                           ul_datarate=1600
    ...                           dl_datarate=13850
    ...                                  rate=kbps
    ...                         trf_direction=both
    ...                             tolerance=.2
    ...                                   lua=sansa_tdd_6cell.lua
    ...                             ue_nr_cap=UE_CAP_MUMIMO
    ...                       entry_auto_args=true
    ...                                 entry=PERFORMANCE_COMMON_TDD_V2
                                    ## params for ramp ue
    ...                      ramp_ue_per_cell=200
    ...                      ramp_ul_datarate=0
    ...                      ramp_dl_datarate=14850
    ...                    ramp_trf_direction=dl
    ...                   ramp_register_delay=1
    ...                            ramp_entry=performance_common_lua_v2
    ...                        ramp_traffic_sleep=0
    ...                          active_cells=1,3
    ...                          trf_protocol=udp


ASOE_TDD_20UE_Ramp_varUE_DL_CsReductionFactorOlc_50
    [Setup]    performance_test_setup.Test Case Setup For Performance Test
    ...                 SCF_SET_VAR_NRBTS_actFdmScheduling=true
    ...            SCF_SET_VAR_NRBTS_actSchedFairnessUlOlc=true
    ...     SCF_SET_VAR_NRCELL_actIncreasedFdmUsersPerSlot=true
    ...    SCF_SET_VAR_NRCELL_maxNumPdschAllocationPerSlot=16
    ...    SCF_SET_VAR_NRCELL_maxNumPuschAllocationPerSlot=16
    ...                              SCF_ENABLE_BB_POOLING=true
    ...                        previous_tc_testname_for_db=ASOE_TDD_20UE_Ramp_varUE_DL_CsReductionFactorOlc_0
    ...                     ENABLE_BEARER_STATS_COLLECTION=true
    performance_common_tc.Run Common Test With Ramp
    ...                            start_cell=1
    ...                              end_cell=6
    ...                           ue_per_cell=20
    ...                           ul_datarate=1600
    ...                           dl_datarate=13850
    ...                                  rate=kbps
    ...                         trf_direction=both
    ...                             tolerance=.2
    ...                                   lua=sansa_tdd_6cell.lua
    ...                             ue_nr_cap=UE_CAP_MUMIMO
    ...                       entry_auto_args=true
    ...                                 entry=PERFORMANCE_COMMON_TDD_V2
                                    ## params for ramp ue
    ...                      ramp_ue_per_cell=200
    ...                      ramp_ul_datarate=0
    ...                      ramp_dl_datarate=14850
    ...                    ramp_trf_direction=dl
    ...                   ramp_register_delay=1
    ...                            ramp_entry=performance_common_lua_v2
    ...                        ramp_traffic_sleep=0
    ...                          active_cells=1,3
    ...                          trf_protocol=udp


ASOE_TDD_20UE_Ramp_varUE_DL_CsReductionFactorOlc_60
    [Setup]    performance_test_setup.Test Case Setup For Performance Test
    ...                 SCF_SET_VAR_NRBTS_actFdmScheduling=true
    ...            SCF_SET_VAR_NRBTS_actSchedFairnessUlOlc=true
    ...     SCF_SET_VAR_NRCELL_actIncreasedFdmUsersPerSlot=true
    ...    SCF_SET_VAR_NRCELL_maxNumPdschAllocationPerSlot=16
    ...    SCF_SET_VAR_NRCELL_maxNumPuschAllocationPerSlot=16
    ...                              SCF_ENABLE_BB_POOLING=true
    ...          SCF_SET_VENDOR_NRBTS_csReductionFactorOlc=60       # knife: 60
    ...                        previous_tc_testname_for_db=ASOE_TDD_20UE_Ramp_varUE_DL_CsReductionFactorOlc_0
    ...                     ENABLE_BEARER_STATS_COLLECTION=true
    performance_common_tc.Run Common Test With Ramp
    ...                            start_cell=1
    ...                              end_cell=6
    ...                           ue_per_cell=20
    ...                           ul_datarate=1600
    ...                           dl_datarate=13850
    ...                                  rate=kbps
    ...                         trf_direction=both
    ...                             tolerance=.2
    ...                                   lua=sansa_tdd_6cell.lua
    ...                             ue_nr_cap=UE_CAP_MUMIMO
    ...                       entry_auto_args=true
    ...                                 entry=PERFORMANCE_COMMON_TDD_V2
                                    ## params for ramp ue
    ...                      ramp_ue_per_cell=200
    ...                      ramp_ul_datarate=0
    ...                      ramp_dl_datarate=14850
    ...                    ramp_trf_direction=dl
    ...                   ramp_register_delay=1
    ...                            ramp_entry=performance_common_lua_v2
    ...                        ramp_traffic_sleep=0
    ...                          active_cells=1,3
    ...                          trf_protocol=udp


ASOE_TDD_20UE_Ramp_varUE_UL_CsReductionFactorOlc_0
    [Setup]    performance_test_setup.Test Case Setup For Performance Test
    ...                 SCF_SET_VAR_NRBTS_actFdmScheduling=true
    ...            SCF_SET_VAR_NRBTS_actSchedFairnessUlOlc=true
    ...     SCF_SET_VAR_NRCELL_actIncreasedFdmUsersPerSlot=true
    ...    SCF_SET_VAR_NRCELL_maxNumPdschAllocationPerSlot=16
    ...    SCF_SET_VAR_NRCELL_maxNumPuschAllocationPerSlot=16
    ...                              SCF_ENABLE_BB_POOLING=true
    ...                     ENABLE_BEARER_STATS_COLLECTION=true
    performance_common_tc.Run Common Test With Ramp
    ...                            start_cell=1
    ...                              end_cell=6
    ...                           ue_per_cell=20
    ...                           ul_datarate=1600
    ...                           dl_datarate=18282
    ...                                  rate=kbps
    ...                         trf_direction=both
    ...                             tolerance=.2
    ...                                   lua=sansa_tdd_6cell.lua
    ...                             ue_nr_cap=UE_CAP_MUMIMO
    ...                       entry_auto_args=true
    ...                                 entry=PERFORMANCE_COMMON_TDD_V2
                             ## params for ramp ue
    ...                      ramp_ue_per_cell=200
    ...                      ramp_ul_datarate=1930
    ...                      ramp_dl_datarate=0
    ...                    ramp_trf_direction=ul
    ...                   ramp_register_delay=1
    ...                            ramp_entry=performance_common_lua_v2
    ...                        ramp_traffic_sleep=0
    ...                          active_cells=1,3
    ...                          trf_protocol=udp


ASOE_TDD_20UE_Ramp_varUE_UL_CsReductionFactorOlc_50
    [Setup]    performance_test_setup.Test Case Setup For Performance Test
    ...                 SCF_SET_VAR_NRBTS_actFdmScheduling=true
    ...            SCF_SET_VAR_NRBTS_actSchedFairnessUlOlc=true
    ...     SCF_SET_VAR_NRCELL_actIncreasedFdmUsersPerSlot=true
    ...    SCF_SET_VAR_NRCELL_maxNumPdschAllocationPerSlot=16
    ...    SCF_SET_VAR_NRCELL_maxNumPuschAllocationPerSlot=16
    ...                              SCF_ENABLE_BB_POOLING=true
    ...                        previous_tc_testname_for_db=ASOE_TDD_20UE_Ramp_varUE_UL_CsReductionFactorOlc_0
    ...                     ENABLE_BEARER_STATS_COLLECTION=true
    performance_common_tc.Run Common Test With Ramp
    ...                            start_cell=1
    ...                              end_cell=6
    ...                           ue_per_cell=20
    ...                           ul_datarate=1600
    ...                           dl_datarate=18282
    ...                                  rate=kbps
    ...                         trf_direction=both
    ...                             tolerance=.2
    ...                                   lua=sansa_tdd_6cell.lua
    ...                             ue_nr_cap=UE_CAP_MUMIMO
    ...                       entry_auto_args=true
    ...                                 entry=PERFORMANCE_COMMON_TDD_V2
                             ## params for ramp ue
    ...                      ramp_ue_per_cell=200
    ...                      ramp_ul_datarate=1930
    ...                      ramp_dl_datarate=0
    ...                    ramp_trf_direction=ul
    ...                   ramp_register_delay=1
    ...                            ramp_entry=performance_common_lua_v2
    ...                        ramp_traffic_sleep=0
    ...                          active_cells=1,3
    ...                          trf_protocol=udp


ASOE_TDD_20UE_Ramp_varUE_UL_CsReductionFactorOlc_60
    [Setup]    performance_test_setup.Test Case Setup For Performance Test
    ...                 SCF_SET_VAR_NRBTS_actFdmScheduling=true
    ...            SCF_SET_VAR_NRBTS_actSchedFairnessUlOlc=true
    ...     SCF_SET_VAR_NRCELL_actIncreasedFdmUsersPerSlot=true
    ...    SCF_SET_VAR_NRCELL_maxNumPdschAllocationPerSlot=16
    ...    SCF_SET_VAR_NRCELL_maxNumPuschAllocationPerSlot=16
    ...                              SCF_ENABLE_BB_POOLING=true
    ...          SCF_SET_VENDOR_NRBTS_csReductionFactorOlc=60       # knife: 60
    ...                        previous_tc_testname_for_db=ASOE_TDD_20UE_Ramp_varUE_UL_CsReductionFactorOlc_0
    ...                     ENABLE_BEARER_STATS_COLLECTION=true
    performance_common_tc.Run Common Test With Ramp
    ...                            start_cell=1
    ...                              end_cell=6
    ...                           ue_per_cell=20
    ...                           ul_datarate=1600
    ...                           dl_datarate=18282
    ...                                  rate=kbps
    ...                         trf_direction=both
    ...                             tolerance=.2
    ...                                   lua=sansa_tdd_6cell.lua
    ...                             ue_nr_cap=UE_CAP_MUMIMO
    ...                       entry_auto_args=true
    ...                                 entry=PERFORMANCE_COMMON_TDD_V2
                             ## params for ramp ue
    ...                      ramp_ue_per_cell=200
    ...                      ramp_ul_datarate=1930
    ...                      ramp_dl_datarate=0
    ...                    ramp_trf_direction=ul
    ...                   ramp_register_delay=1
    ...                            ramp_entry=performance_common_lua_v2
    ...                        ramp_traffic_sleep=0
    ...                          active_cells=1,3
    ...                          trf_protocol=udp
