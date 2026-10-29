*** Settings ***
Documentation
...  author:  Squad 69
...  contact: I_MN_RAN_SW_ULM_ET_AP_PET_GMS
...  Description:   Test Cases for TDD 1 Cell 100 UEs Performance Test

Resource   ./resources/performance_keywords.robot
Resource   ./resources/performance_ttitrace.robot
Resource   ./resources/performance_test_setup.robot

Force Tags    CLOUD_5G_I_MP_AP_LOOO

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
tdd_1Cell_100Ues_DL_ABIP_pooling
    [Documentation]
    ...    Performance Test for TDD ABIP configuration with 100 UEs attached to 1 Cell and running DL traffic simultaneously
    [Tags]    DL
    [Setup]    performance_test_setup.Test Case Setup For Performance Test    SCF_ENABLE_BB_POOLING=true
    Set Test Variable   ${QC_TEST_NAME}   [1]L2PS_performance_indicator_check_tdd_1Cell_100Ues_Dl_pooling
    Set Test Variable    ${QC_PATH}       testsuite/Ulm/ET/Performance_Test/resources/qc/ABIP_performance.qc

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



tdd_1Cell_100Ues_UL_ABIP_pooling
    [Documentation]
    ...    Performance Test for TDD ABIP configuration with 100 UEs attached to 1 Cell and running UL traffic simultaneously
    [Tags]    UL
    [Setup]    performance_test_setup.Test Case Setup For Performance Test    SCF_ENABLE_BB_POOLING=true
    Set Test Variable   ${QC_TEST_NAME}   [1]L2PS_performance_indicator_check_tdd_1Cell_100Ues_Ul_pooling
    Set Test Variable    ${QC_PATH}       testsuite/Ulm/ET/Performance_Test/resources/qc/ABIP_performance.qc

    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=1
    ...                      num_cells_online=6
    ...                           ue_per_cell=100
    ...                           ul_datarate=3000
    ...                           dl_datarate=0
    ...                                  rate=kbps
    ...                         trf_direction=ul
    ...                             ue_nr_cap=UE_CAP
    ...                             tolerance=0.4  # Verify_TP_with_Counters_FDD_UL=6750000
    ...                                   lua=sansa_tdd_1cell.lua
    ...                       entry_auto_args=true
    ...                                 entry=PERFORMANCE_COMMON_TDD_SEQ_BF    # PET_1208FF_BF_100UE_UL
    performance_keywords.Run Common Test    &{tc}


tdd_1Cell_100Ues_ABIP_pooling
    [Documentation]
    ...    Performance Test for TDD ABIP configuration with 100 UEs attached to 1 Cell and running UL+DL traffic simultaneously
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
    ...                             tolerance=0.5945945945945946
    ...                                   lua=sansa_tdd_1cell.lua
    ...                       entry_auto_args=true
    ...                                 entry=performance_common_seq_lua_tdd
    Run Common Test    &{tc}


CB013027-A_TC01_Max_PUSCH_UEs_6Cells_Half_ABIP_equal_load
    [Documentation]    Test Case 1: CB013027-AA#1 Maximum number of PUSCH UEs per slot per BB pool,
    ...                L1 subpool and L2 subpool on half ABIP with 6 FR1 TDD eCPRI cells
    [Tags]    UL    CLOUD_5G_I_MP_AP_LOOO    ABIP    TDD
    [Setup]    performance_test_setup.Test Case Setup For Performance Test    SCF_ENABLE_BEAMFORMING=false
    ...                                                SCF_CONFIGURE_SRS=false
    ...                                                ENABLE_SRS_INFO=false
    ...                                                SCF_SET_VAR_NRCELL_actUlSrsBm=false
    ...                                                SCF_SET_VAR_NRCELL_actDlSrsBm=false
    ...                                                ENABLE_TTI_TRACE_QUICK=true

    Set Test Variable    ${QC_TEST_NAME}   [1]CB013027_A_TC01_Maximum_number_of_PUSCH_UEs_per_slot_on_half_ABIP_with_6_FR1_TDD_eCPRI_cells
    Set Test Variable    ${QC_PATH}    testsuite/Ulm/ET/Performance_Test/resources/qc/CB013027-SR_ABIP.qc

    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=6
    ...                           ue_per_cell=8
    ...                           ul_datarate=27000
    ...                           dl_datarate=0
    ...                                  rate=kbps
    ...                         trf_direction=ul
    ...                             ue_nr_cap=UE_CAP
    ...                             tolerance=0.5
    ...                                   lua=sansa_tdd_6cell.lua
    ...                       entry_auto_args=true
    ...                                 entry=performance_common_seq_active_cells_lua_tdd
    performance_keywords.Run Common Test    &{tc}
    performance_ttitrace.Check TTI Trace Total Number of Sched UEs Per L1Pool  count=48



CB013027-A_TC02_Max_PUSCH_UEs_3Cells_Half_ABIP
    [Documentation]    Test Case 2: CB013027-AA#4 Maximum number of PUSCH UEs per slot per BB pool,
    ...                L1 subpool and L2 subpool on half ABIP with 3 FR1 TDD eCPRI cells
    [Tags]    UL    CLOUD_5G_I_MP_AP_LOOO    ABIP    TDD
    [Setup]    performance_test_setup.Test Case Setup For Performance Test    ENABLE_TTI_TRACE_QUICK=true

    Set Test Variable    ${QC_TEST_NAME}   [1]CB013027_A_TC02_Maximum_number_of_PUSCH_UEs_per_slot_on_half_ABIP_with_3_FR1_TDD_eCPRI_cells
    Set Test Variable    ${QC_PATH}    testsuite/Ulm/ET/Performance_Test/resources/qc/CB013027-SR_ABIP.qc

    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=3
    ...                           ue_per_cell=16
    ...                           ul_datarate=0
    ...                           dl_datarate=0
    ...                                  rate=kbps
    ...                         trf_direction=ul
    ...                    cell_ul_throughput=13750,13750,13750
    ...                             ue_nr_cap=UE_CAP
    ...                             tolerance=0.2
    ...                                   lua=sansa_tdd_3cell.lua
    ...                       entry_auto_args=true
    ...                                 entry=PERFORMANCE_COMMON_TDD_SEQ_BF
    ...                           cell_max_ue=16,16,16
    performance_keywords.Run Common Test    &{tc}
    performance_ttitrace.Check TTI Trace Total Number of Sched UEs Per L1Pool  count=48



CB013027-A_TC05_Benchmark_UEs_6Cells_Half_ABIP
    [Documentation]    Test Case 5: CB013027-AB#3 Benchmark the number of PUSCH and PDSCH UEs per slot on half ABIP with 6 FR1 TDD eCPRI cells
    [Tags]    ULDL    CLOUD_5G_I_MP_AP_LOOO    ABIP    TDD
    [Setup]    performance_test_setup.Test Case Setup For Performance Test    SCF_ENABLE_BEAMFORMING=false
    ...                                                SCF_CONFIGURE_SRS=false
    ...                                                ENABLE_SRS_INFO=false
    ...                                                SCF_SET_VAR_NRCELL_actUlSrsBm=false
    ...                                                SCF_SET_VAR_NRCELL_actDlSrsBm=false
    ...                                                ENABLE_TTI_TRACE_QUICK=true

    Set Test Variable    ${QC_PATH}    testsuite/Ulm/ET/Performance_Test/resources/qc/CB013027-SR_ABIP.qc
    Set Test Variable    ${QC_TEST_NAME}
    ...                  [1]CB013027_A_TC05_Benchmark_the_number_of_PUSCH_and_PDSCH_UEs_per_slot_on_half_ABIP_with_6_FR1_TDD_eCPRI_cells

    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=6
    ...                           ue_per_cell=16
    ...                           ul_datarate=13000
    ...                           dl_datarate=90000
    ...                                  rate=kbps
    ...                         trf_direction=both
    ...                             ue_nr_cap=UE_CAP
    ...                             tolerance=0.5
    ...                                   lua=sansa_tdd_6cell.lua
    ...                       entry_auto_args=true
    ...                                 entry=performance_common_seq_active_cells_lua_tdd
    performance_keywords.Run Common Test    &{tc}
    performance_ttitrace.Check TTI Trace Total Number of Sched UEs Per L1Pool  count=48
    performance_ttitrace.Check TTI Trace Total Number of Sched UEs Per L1Pool for DL  count=48



CB013027-A_TC06_Benchmark_UEs_3Cells_Half_ABIP
    [Documentation]    Test Case 6: CB013027-AB#6 Benchmark the number of PUSCH and PDSCH UEs per slot on half ABIP with 3 FR1 TDD eCPRI cells
    [Tags]    ULDL    CLOUD_5G_I_MP_AP_LOOO    ABIP    TDD
    [Setup]    performance_test_setup.Test Case Setup For Performance Test    ENABLE_TTI_TRACE_QUICK=true

    Set Test Variable    ${QC_PATH}    testsuite/Ulm/ET/Performance_Test/resources/qc/CB013027-SR_ABIP.qc
    Set Test Variable    ${QC_TEST_NAME}
    ...                  [1]CB013027_A_TC06_Benchmark_the_number_of_PUSCH_and_PDSCH_UEs_per_slot_on_half_ABIP_with_3_FR1_TDD_eCPRI_cells

    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=3
    ...                           ue_per_cell=16
    ...                           ul_datarate=13750
    ...                           dl_datarate=95000
    ...                                  rate=kbps
    ...                         trf_direction=both
    ...                             ue_nr_cap=UE_CAP
    ...                             tolerance=0.5
    ...                                   lua=sansa_tdd_3cell.lua
    ...                       entry_auto_args=true
    ...                                 entry=PERFORMANCE_COMMON_TDD_SEQ_BF
    performance_keywords.Run Common Test    &{tc}
    performance_ttitrace.Check TTI Trace Total Number of Sched UEs Per L1Pool  count=48
    performance_ttitrace.Check TTI Trace Total Number of Sched UEs Per L1Pool for DL  count=40


Half_ABIP_TDD_3Cells_UL_MU_MIMO_2UEs
    [Documentation]    ABIP_8Rx_CB009363_UL_MU_MIMO_2UEs_TC
    ...                \\ul5gsn502.iv.ulm.nsn-rdnet.net\lv1\users\MuhammadZaman\ABIP_8Rx_CB009363_UL_MU_MIMO_2UEs_TC
    ...                3 TDD Cells in Half ABIP with 8Rx IRC Receiver
    [Setup]    performance_test_setup.Test Case Setup For Performance Test    ENABLE_ACT_BSR=auto
    performance_egate.Copy Specific Egate Scripts To Wts Folder    TDD_FR1_8RX_CB009363_UL_MUMIMO_2UEs

    performance_keywords.Run Common Test    start_cell=1
    ...                                       end_cell=3
    ...                               num_cells_online=3
    ...                                    ue_per_cell=2
    ...                                    ul_datarate=175
    ...                                    dl_datarate=0
    ...                                           rate=mbps
    ...                                  trf_direction=ul
    ...                                   trf_protocol=udp
    ...                                      ue_nr_cap=UE_CAP_8RX
    ...                                      tolerance=0.25
    ...                                            lua=sansa.lua
    ...                            configuration_entry=run_configuration()
    ...                                entry_auto_args=false
    ...                                custom_lua_file=commands.lua
    ...                                          entry=CB009363_UL_MU_MIMO_2UEs_TC    # seq_start rate=1 id=1,2,3
                                                                                      # max_active_ues=2
