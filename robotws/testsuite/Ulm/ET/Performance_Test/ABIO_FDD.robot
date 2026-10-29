*** Settings ***
Documentation
...  author:  Squad 69
...  contact: I_MN_RAN_SW_ULM_ET_AP_PET_GMS
...  Description:   Test Cases for TDD 1 Cell 100 UEs Performance Test

Resource   ./resources/performance_keywords.robot
Resource   ./resources/performance_reporting.robot
Resource   ./resources/performance_test_setup.robot
Resource   ./resources/performance_ttitrace.robot

Force Tags    CLOUD_5G_I_LO_AP_LOOO

Suite Setup       performance_test_setup.Suite Setup For Performance Test
Suite Teardown    performance_test_setup.Suite Teardown For Performance Test
Test Setup        performance_test_setup.Test Case Setup For Performance Test
Test Teardown     performance_test_setup.Test Case Teardown For Performance Test


*** Test Cases ***
[1]CB012716-A_Adaptive_Scheduler_Budget_functionality_check_in_FDD_3CC_without_OLC_FDM_UE_Skipping
    [Documentation]
    ...    Performance Test for FDD ABIP configuration with 100 UEs attached to 1 Cell and running DL traffic simultaneously
    ...    fdd_1Cell_100Ues_DL_ABIO
    [Setup]    performance_test_setup.Test Case Setup For Performance Test    ENABLE_ONLINE_REPORTING=true
    ...                                                RDCFG_ACT_ADAPTIVE_SCHEDULER_BUDGET=true
    ...                                                ENABLE_TTI_TRACE_QUICK=true
    @{T_DEFAULT_TTI_EVENTS}=    Create List    dlLoadControlData
    Set Test Variable    ${T_DEFAULT_TTI_EVENTS}
    performance_reporting.Set QC Path          CB012716-SR_Adaptive_Scheduler_Budget_for_Improved_Message_Handling.qc

    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=1
    ...                      num_cells_online=12
    ...                           ue_per_cell=100
    ...                               ul_datarate=0
    ...                               dl_datarate=5557
    ...                                  rate=kbps
    ...                         trf_direction=dl
    ...                             tolerance=0.33297  # lowered DL threshold  ~13900000 in PM Counter
    ...                                   lua=sansa_fdd_1cell.lua
    ...                             ue_nr_cap=UE_CAP_4x4
    ...                       entry_auto_args=true
    ...                                 entry=performance_common_seq_lua_fdd
    performance_keywords.Run Common Test    &{tc}

    ## need TTI Trace (ENABLE_TTI_TRACE_QUICK)
    performance_ttitrace.Check AdativeSlotProcessingRatio Not Greater Than 90 Some Greater Than 78


fdd_1Cell_100Ues_DL_ABIO
    Set Test Variable   ${QC_TEST_NAME}   [1]L2PS_performance_indicator_check_fdd_1Cell_100Ues_Dl
    Set Test Variable    ${QC_PATH}       testsuite/Ulm/ET/Performance_Test/resources/qc/ABIO_performance.qc
    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=1
    ...                      num_cells_online=12
    ...                           ue_per_cell=100
    ...                           ul_datarate=0
    ...                           dl_datarate=5557
    ...                                  rate=kbps
    ...                         trf_direction=dl
    ...                             tolerance=0.33297  # lowered DL threshold  ~13900000 in PM Counter
    ...                                   lua=sansa_fdd_1cell.lua
    ...                             ue_nr_cap=UE_CA_n25A_n662A_n71A_n772A
    ...                                 entry=pet_seql2_start_100UE_DL
    performance_keywords.Run Common Test    &{tc}


fdd_1Cell_100Ues_UL_ABIO
    Set Test Variable   ${QC_TEST_NAME}   [1]L2PS_performance_indicator_check_fdd_1Cell_100Ues_Ul
    Set Test Variable    ${QC_PATH}       testsuite/Ulm/ET/Performance_Test/resources/qc/ABIO_performance.qc
    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=1
    ...                      num_cells_online=12
    ...                           ue_per_cell=100
    ...                           ul_datarate=2778
    ...                           dl_datarate=0
    ...                                  rate=kbps
    ...                         trf_direction=ul
    ...                             tolerance=0.35205183585313177  # Verify_TP_with_Counters_FDD_UL=6750000
    ...                                   lua=sansa_fdd_1cell.lua
    ...                             ue_nr_cap=UE_CA_n25A_n662A_n71A_n772A
    ...                                 entry=pet_seql2_start_100UE_UL
    performance_keywords.Run Common Test    &{tc}


fdd_12Cell_40Ues_ULDL_ABIO
    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=12
    ...                           ue_per_cell=40
    ...                           ul_datarate=2400
    ...                           dl_datarate=8000
    ...                                  rate=kbps
    ...                         trf_direction=both
    ...                             tolerance=0.15
    ...                                   lua=sansa_fdd_12cell.lua
    ...                             ue_nr_cap=UE_CAP_4x4
    ...                       entry_auto_args=true
    ...                                 entry=performance_common_seq_lua_fdd
    ...                          trf_protocol=tcp
    performance_keywords.Run Common Test    &{tc}


fdd_24Cell_20MHz_full_board_UL_ABIO
    [Documentation]    CB014208-A#B1-ABIO 24 FDD 20Mhz CPRI cells - 4DL4UL
    [Setup]    Test Case Setup For Performance Test    ENABLE_TTI_TRACE_QUICK=true
    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=24
    ...                           ue_per_cell=10
    ...                           ul_datarate=18
    ...                           dl_datarate=0
    ...                                  rate=mbps
    ...                         trf_direction=ul
    ...                             tolerance=1.00
    ...                                   lua=sansa_fdd_24cell.lua
    ...                             ue_nr_cap=UE_CAP_4x4
    ...                       entry_auto_args=true
    ...                                 entry=performance_common_seq_lua_fdd
    ...                          trf_protocol=udp
    performance_keywords.Run Common Test    &{tc}
    performance_ttitrace.Check TTI Trace Total Number Of Sched UEs Per L1Pool  count=76


fdd_24Cell_20MHz_full_board_DL_ABIO
    [Documentation]    CB014208-A#B2-ABIO 24 FDD 20Mhz CPRI cells - 4DL4UL
    [Setup]    Test Case Setup For Performance Test    ENABLE_TTI_TRACE_QUICK=true
    ...                                                ENABLE_ONLINE_REPORTING=true

    ${QC_TEST_NAME_tmp}             Catenate    SEPARATOR=    [1]CB014208_A_TC03_Robustness_Maximum_number_
    ...                             of_PUSCH_and_PDSCH_UEs_per_slot_per_BBP_full_ABIO_24_FDD_CPRI_cells
    Set Test Variable   ${QC_TEST_NAME}    ${QC_TEST_NAME_tmp}
    Set Test Variable    ${QC_PATH}    testsuite/Ulm/ET/Performance_Test/resources/qc/CB014208_A_TC03.qc

    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=24
    ...                           ue_per_cell=12
    ...                           ul_datarate=4
    ...                           dl_datarate=24
    ...                                  rate=mbps
    ...                         trf_direction=both
    ...                             tolerance=1.00
    ...                                   lua=sansa_fdd_24cell.lua
    ...                             ue_nr_cap=UE_CAP_4x4
    ...                       entry_auto_args=true
    ...                                 entry=performance_common_seq_lua_fdd
    ...                          trf_protocol=udp
    performance_keywords.Run Common Test    &{tc}
    performance_ttitrace.Check TTI Trace Total Number of Sched UEs Per L1Pool for DL  count=76


fdd_12Cell_40Ues_ULDL_ABIO_actFlowControlLoadBalance_false
    [Documentation]    BASED On: fdd_12Cell_40Ues_ULDL_ABIO
    ...     SCF_SET_VAR_NRBTS_actFlowControlLoadBalance=false
    ...                  CFG_EMPERF_TOLERANCE=1
    ...                     CFG_KPI_TOLERANCE=1
    ...                 ENABLE_EMPERF_default=0x1730,0x1731,0x1732,0x1733
    ...                         ENABLE_LTEPAT=true
    ...     ENABLE_SNAPSHOT_L2TRACELO_EXTRACT=true

    performance_keywords.Run Common Test                start_cell=1
    ...                              end_cell=12
    ...                           ue_per_cell=40
    ...                           ul_datarate=2400
    ...                           dl_datarate=8000
    ...                                  rate=kbps
    ...                         trf_direction=both
    ...                             tolerance=0.15
    ...                                   lua=sansa_fdd_12cell.lua
    ...                             ue_nr_cap=UE_CAP_4x4
    ...                       entry_auto_args=true
    ...                                 entry=performance_common_seq_lua_fdd
    ...                          trf_protocol=tcp


fdd_12Cell_40Ues_ULDL_ABIO_actFlowControlLoadBalance_true
    [Documentation]    BASED On: fdd_12Cell_40Ues_ULDL_ABIO
    ...                TODO: prepare QC
    [Setup]    performance_test_setup.Test Case Setup For Performance Test
    ...                     previous_tc_testname_for_db=fdd_12Cell_40Ues_ULDL_ABIO_actFlowControlLoadBalance_false
    ...     SCF_SET_VAR_NRBTS_actFlowControlLoadBalance=true
    ...                            CFG_EMPERF_TOLERANCE=0.10
    ...                               CFG_KPI_TOLERANCE=0.10
    ...                           ENABLE_EMPERF_default=0x1730,0x1731,0x1732,0x1733
    ...                                   ENABLE_LTEPAT=true
    ...                        CFG_PMCOUNTERS_TOLERANCE=0.10
    ...               ENABLE_SNAPSHOT_L2TRACELO_EXTRACT=true

    performance_keywords.Run Common Test                start_cell=1
    ...                              end_cell=12
    ...                           ue_per_cell=40
    ...                           ul_datarate=2400
    ...                           dl_datarate=8000
    ...                                  rate=kbps
    ...                         trf_direction=both
    ...                             tolerance=0.15
    ...                                   lua=sansa_fdd_12cell.lua
    ...                             ue_nr_cap=UE_CAP_4x4
    ...                       entry_auto_args=true
    ...                                 entry=performance_common_seq_lua_fdd
    ...                          trf_protocol=tcp
