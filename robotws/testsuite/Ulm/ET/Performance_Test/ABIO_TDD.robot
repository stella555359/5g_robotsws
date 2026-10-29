*** Settings ***
Documentation
...  author:  Squad 69
...  contact: I_MN_RAN_SW_ULM_ET_AP_PET_GMS
...  Description:   Test Cases for TDD 1 Cell 100 UEs Performance Test

Resource   ./resources/performance_keywords.robot
Resource   ./resources/performance_reporting.robot
Resource   ./resources/performance_test_setup.robot

Force Tags    CLOUD_5G_I_LO_AP_LOOO

Suite Setup       performance_test_setup.Suite Setup For Performance Test
...                                                   SCF_ENABLE_BEAMFORMING=true
...                                                   SCF_CONFIGURE_SRS=true
...                                                   ENABLE_SRS_INFO=true
...                                                   SCF_SET_VAR_NRCELL_actUlSrsBm=true
...                                                   SCF_SET_VAR_NRCELL_actDlSrsBm=true
Suite Teardown    performance_test_setup.Suite Teardown For Performance Test
Test Setup        performance_test_setup.Test Case Setup For Performance Test
Test Teardown     performance_test_setup.Test Case Teardown For Performance Test


*** Test Cases ***
tdd_1Cell_100Ues_DL_ABIO
    [Documentation]
    ...    Performance Test for TDD ABIO configuration with 100 UEs attached to 1 Cell and running DL traffic simultaneously
    performance_keywords.Run Common Test    start_cell=1
    ...                                       end_cell=1
    ...                               num_cells_online=6
    ...                                    ue_per_cell=100
    ...                                    ul_datarate=0
    ...                                    dl_datarate=22200
    ...                                           rate=kbps
    ...                                  trf_direction=dl
    ...                                      tolerance=0.5945945945945946
    ...                                            lua=sansa_tdd_1cell.lua
    ...                                entry_auto_args=false
    ...                                          entry=PET_1208FF_BF_100UE_DL

    Run Keyword And Warn On Failure    Verify Beamforming PM Counters    dl



tdd_1Cell_100Ues_UL_ABIO
    [Documentation]
    ...    Performance Test for TDD ABIO configuration with 100 UEs attached to 1 Cell and running UL traffic simultaneously
    performance_keywords.Run Common Test    start_cell=1
    ...                                       end_cell=1
    ...                               num_cells_online=6
    ...                                    ue_per_cell=100
    ...                                    ul_datarate=3000
    ...                                    dl_datarate=0
    ...                                           rate=kbps
    ...                                  trf_direction=ul
    ...                                      tolerance=0.4
    ...                                            lua=sansa_tdd_1cell.lua
    ...                                      ue_nr_cap=UE_CAP
    ...                                entry_auto_args=false
    ...                                          entry=PET_1208FF_BF_100UE_UL

    Run Keyword And Warn On Failure    Verify Beamforming PM Counters    ul


tdd_1Cell_100Ues_ABIO
    [Documentation]
    ...    Performance Test for TDD ABIO configuration with 100 UEs attached to 1 Cell and running UL+DL traffic simultaneously
    performance_keywords.Run Common Test    start_cell=1
    ...                                       end_cell=1
    ...                               num_cells_online=6
    ...                                    ue_per_cell=100
    ...                                    ul_datarate=3000
    ...                                    dl_datarate=22200
    ...                                           rate=kbps
    ...                                  trf_direction=both
    ...                                      tolerance=0.5945945945945946
    ...                                            lua=sansa_tdd_1cell.lua
    ...                                      ue_nr_cap=UE_CAP
    ...                                entry_auto_args=true
    ...                                          entry=performance_common_seq_lua_tdd

    Run Keyword And Warn On Failure    Verify Beamforming PM Counters    both


tdd_6Cells_100Ues_per_cell_ULDL_ABIO
    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=6
    ...                           ue_per_cell=100
    ...                           ul_datarate=2500
    ...                           dl_datarate=21000
    ...                                  rate=kbps
    ...                         trf_direction=both
    ...                             tolerance=0.05
    ...                                   lua=sansa_tdd_template.lua
    ...                       entry_auto_args=true
    ...                                 entry=performance_common_seq_lua_tdd
    performance_keywords.Run Common Test    &{tc}



CB012716_step1_Adaptive_Scheduler_Budget_for_Improved_Message_Handling
    [Documentation]   10 Ues each having: 10 Mbps on a Cell
    ...
    ...    To check if this automation is possible with AP TL :
    ...    With ABIO TL  below needs to be executed:
    ...    Step1:
    ...    If possible to test with below R&D parameter enabled
    ...    R&D param to be used:
    ...    rdActAdaptiveSchedulerBudget (0x58081F) = 1
    ...    first test:
    ...    10 Ues each having: 10 Mbps on a Cell
    [Setup]    performance_test_setup.Test Case Setup For Performance Test    RDCFG_ACT_ADAPTIVE_SCHEDULER_BUDGET=true

    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=1
    ...                      num_cells_online=6
    ...                           ue_per_cell=10
    ...                           ul_datarate=0
    ...                           dl_datarate=10000
    ...                                  rate=kbps
    ...                         trf_direction=dl
    ...                             tolerance=0.05
    ...                                   lua=sansa_tdd_1cell.lua
    ...                       entry_auto_args=true
    ...                                 entry=performance_common_seq_lua_tdd
    performance_keywords.Run Common Test    &{tc}



CB012716_step2_Adaptive_Scheduler_Budget_for_Improved_Message_Handling
    [Documentation]  100 UEs having full UL+DL buffer on a Cell
    ...
    ...    To check if this automation is possible with AP TL
    ...    With ABIO TL  below needs to be executed:
    ...    R&D param to be used:
    ...    rdActAdaptiveSchedulerBudget (0x58081F) = 1
    ...    2nd test:
    ...    100 UEs having full UL+DL buffer on a Cell
    [Setup]    performance_test_setup.Test Case Setup For Performance Test    RDCFG_ACT_ADAPTIVE_SCHEDULER_BUDGET=true

    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=1
    ...                      num_cells_online=6
    ...                           ue_per_cell=100
    ...                           ul_datarate=10000
    ...                           dl_datarate=10000
    ...                                  rate=kbps
    ...                         trf_direction=both
    ...                             ue_nr_cap=UE_CAP
    ...                             tolerance=0.05
    ...                                   lua=sansa_tdd_1cell.lua
    ...                       entry_auto_args=true
    ...                                 entry=performance_common_seq_lua_tdd
    performance_keywords.Run Common Test    &{tc}



ABIO_TDD_6Cells_72UEsPerCell_UL_DL
    [Documentation]    PET_UC2_1208FF_6_SSB_8*4MIMO_6CELL_SA_432UE_DL_9Gb_traffic_72UE_per_CELL
    ...                PET_1208FF_BF_432UE_UL, PET_1208FF_BF_432UE_DL
    ...                UL:3000, DL:22200
    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=6
    ...                           ue_per_cell=72
    ...                           ul_datarate=3000
    ...                           dl_datarate=22200
    ...                                  rate=kbps
    ...                         trf_direction=both
    ...                             ue_nr_cap=UE_CAP
    ...                             tolerance=0.15
    ...                                   lua=sansa_tdd_6cell.lua
    ...                       entry_auto_args=true
    ...                                 entry=PERFORMANCE_COMMON_TDD_BF_6PROFILES
    performance_keywords.Run Common Test    &{tc}



ABIO_TDD_6Cells_1500UEsPerCell_UL_DL
    [Documentation]    SRS ENABLED
    ...                PET_UC1_1070FF_6_SSB_8*4MIMO_6CELL_SA_9000UEs_DL_UL_Ping_traffic_2DRBs_PerUE_1500UEs_per_CELL
    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=6
    ...                           ue_per_cell=1500
    ...                           ul_datarate=72
    ...                           dl_datarate=72
    ...                                  rate=bps
    ...                         trf_direction=both
    ...                             ue_nr_cap=1070FF_UE_CAP
    ...                             tolerance=0.15
    ...                                   lua=sansa_tdd_6cell.lua
    ...                       entry_auto_args=false
    ...                                 entry=PET_1070FF_BF_9000UE_DLUL_rate1dot5    #PERFORMANCE_COMMON_TDD_BF_6PROFILES
    ...                               timeout=2400
    ...                     registration_type=InitialRegistration
    ...                                pdu_id=1,1
    ...                                qfi_id=1,2
    ...                                trf_id=1,1
    performance_keywords.Run Common Test    &{tc}



ABIO_TDD_6Cells_actFlowControlLoadBalance_false
    [Documentation]    Based on ABIO_TDD_6Cells_72UEsPerCell_UL_DL
    [Setup]    performance_test_setup.Test Case Setup For Performance Test
    ...      SCF_SET_VAR_NRBTS_actBbPoolExtensionTddFr1=true
    ...     SCF_SET_VAR_NRBTS_actFlowControlLoadBalance=false
    ...                            CFG_EMPERF_TOLERANCE=1
    ...                               CFG_KPI_TOLERANCE=1
    ...                           ENABLE_EMPERF_default=0x1730,0x1731,0x1732,0x1733
    ...                                   ENABLE_LTEPAT=true
    ...            ENABLE_PMCOUNTER_DICTIONARY_CREATION=true
    ...                        CFG_PMCOUNTERS_TOLERANCE=1
    ...                        ENABLE_DB_CONSOLE_OUTPUT=false  #to enable failure cause analysis in ABIO_TDD_6Cells_actFlowControlLoadBalance_true
    ...                           SCF_ENABLE_BB_POOLING=true
    ...               ENABLE_SNAPSHOT_L2TRACELO_EXTRACT=true

    performance_keywords.Run Common Test    start_cell=1
    ...                                       end_cell=6
    ...                                    ue_per_cell=72
    ...                                    ul_datarate=2000
    ...                                    dl_datarate=10000
    ...                                           rate=kbps
    ...                                  trf_direction=both
    ...                                   trf_protocol=udp
    ...                                      ue_nr_cap=UE_CAP
    ...                                      tolerance=0.5
    ...                                            lua=sansa_tdd_6cell.lua
    ...                                entry_auto_args=true
    ...                                          entry=PERFORMANCE_COMMON_TDD_BF_6PROFILES


ABIO_TDD_6Cells_actFlowControlLoadBalance_true
    [Documentation]    Based on ABIO_TDD_6Cells_72UEsPerCell_UL_DL
    ...                10 % tolerance
    ...                TODO: prepare QC
    [Setup]    performance_test_setup.Test Case Setup For Performance Test
    ...     SCF_SET_VAR_NRBTS_actBbPoolExtensionTddFr1=true
    ...                    previous_tc_testname_for_db=ABIO_TDD_6Cells_actFlowControlLoadBalance_false
    ...    SCF_SET_VAR_NRBTS_actFlowControlLoadBalance=true
    ...                           CFG_EMPERF_TOLERANCE=0.10
    ...                              CFG_KPI_TOLERANCE=0.10
    ...                          ENABLE_EMPERF_default=0x1730,0x1731,0x1732,0x1733
    ...                                  ENABLE_LTEPAT=true
    ...                       CFG_PMCOUNTERS_TOLERANCE=0.10
    ...           ENABLE_PMCOUNTER_DICTIONARY_CREATION=true
    ...                          SCF_ENABLE_BB_POOLING=true
    ...              ENABLE_SNAPSHOT_L2TRACELO_EXTRACT=true

    performance_keywords.Run Common Test
    ...                            start_cell=1
    ...                              end_cell=6
    ...                           ue_per_cell=72
    ...                           ul_datarate=2000
    ...                           dl_datarate=10000
    ...                                  rate=kbps
    ...                         trf_direction=both
    ...                          trf_protocol=udp
    ...                             ue_nr_cap=UE_CAP
    ...                             tolerance=0.5
    ...                                   lua=sansa_tdd_6cell.lua
    ...                       entry_auto_args=true
    ...                                 entry=PERFORMANCE_COMMON_TDD_BF_6PROFILES


ABIO_TDD_6Cells_Abrupt_UE_Deletion
    [Documentation]    SRS ENABLED
    ...                PET_UC1_1070FF_6_SSB_8*4MIMO_6CELL_SA_9000UEs_DL_UL_Ping_traffic_2DRBs_PerUE_1500UEs_per_CELL
    ...                Test Case #1: CNI-120470 Abrupt UE Deletion in TDD FR1 6 Cells configuration
    [Setup]    performance_test_setup.Test Case Setup For Performance Test
    #...                    previous_tc_testname_for_db=ABIO_TDD_6Cells_Abrupt_UE_Deletion_CNI_off
    ...                          SCF_ENABLE_BB_POOLING=true
    ...                                ENABLE_LOG_DCAP=false
    ...                              ENABLE_SOS_REPORT=false   # it causes too much cpu
    ...                 ENABLE_LOG_ARCHIVE_COMPRESSION=false   # it causes too much cpu
    ...             ENABLE_EGATE_CHECK_UE_CNTX_REL_REQ=false    # deregister is part of the testcase
    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=6
    ...                           ue_per_cell=1500
    ...                           ul_datarate=72
    ...                           dl_datarate=72
    ...                                  rate=bps
    ...                         trf_direction=both
    ...                             ue_nr_cap=1070FF_UE_CAP
    ...                             tolerance=0.15
    ...                                   lua=sansa_tdd_6cell.lua
    ...                       entry_auto_args=false
    ...                                 entry=PET_1070FF_BF_9000UE_DLUL_rate1dot5    #PERFORMANCE_COMMON_TDD_BF_6PROFILES
    ...                               timeout=2400
    ...                     registration_type=InitialRegistration
    ...                                pdu_id=1
    ...                                qfi_id=1
    ...                                trf_id=1
                                    ## params for deregister
    ...                deregister_range_split=10
    ...                      deregister_delay=1

    performance_common_tc.Run Common Test With Deregister    &{tc}


ABIO_TDD_6Cells_Abrupt_UE_Deletion_with_trf
    [Documentation]    SRS ENABLED
    ...                Test Case #2: CNI-120470 Abrupt UE Deletion in TDD FR1 6 Cells configuration
    [Setup]    performance_test_setup.Test Case Setup For Performance Test
    #...                    previous_tc_testname_for_db=ABIO_TDD_6Cells_Abrupt_UE_Deletion_CNI_off_with_trf
    ...                          SCF_ENABLE_BB_POOLING=true
    ...                                ENABLE_LOG_DCAP=false
    ...                              ENABLE_SOS_REPORT=false   # it causes too much cpu
    ...                 ENABLE_LOG_ARCHIVE_COMPRESSION=false   # it causes too much cpu
    ...             ENABLE_EGATE_CHECK_UE_CNTX_REL_REQ=false    # deregister is part of the testcase
    ...                        ENABLE_ONLINE_REPORTING=true
    ...                              ENABLE_TIMEMARKER=false
    ...                                  ENABLE_LTEPAT=true

    Set Test Variable   ${QC_TEST_NAME}
    ...    [1]CNI120470_Abrupt_UE_deletion_when_L2_PS_is_in_Overload_State_in_TDD_FR1_6_cells_configuration_AP_TL_simulated_RF
    performance_reporting.Set QC Path          CNI120470.qc
    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=6
    ...                           ue_per_cell=1500
    ...                           ul_datarate=72
    ...                           dl_datarate=72
    ...                            packetsize=42      # 42..9000
    ...                             period_ms=5000
    ...                                  rate=bps
    ...                         trf_direction=both
    ...                          trf_protocol=udp
    ...                             ue_nr_cap=1070FF_UE_CAP
    ...                             tolerance=0.15
    ...                                   lua=sansa_tdd_6cell.lua
    ...                       entry_auto_args=false
    ...                                 entry=PET_1070FF_BF_9000UE_DLUL_rate1dot5(1500)    #PERFORMANCE_COMMON_TDD_PET_1070FF_BF
    ...                               timeout=2400
    ...                     registration_type=InitialRegistration
    ...                                pdu_id=1
    ...                                qfi_id=1
    ...                                trf_id=1
    ...                       expect_ue_count=1500
                                    ## params for ramp ue
    ...                           ramp_end_ue=9000
    ...                      ramp_ue_per_cell=100
    ...                  ramp_expect_ue_count=1500
    ...                      ramp_ul_datarate=120
    ...                      ramp_dl_datarate=120
    ...                       ramp_packetsize=75
    ...                    ramp_trf_direction=both
    ...                   ramp_register_delay=1
    ...                  ramp_entry_auto_args=true
    ...                            ramp_entry=performance_common_add_traffic
    ...                        ramp_traffic_sleep=0
                                    ## params for deregister
    ...                deregister_range_split=5
    ...                      deregister_delay=1
    performance_common_tc.Run Common Test With Ramp And Quick Deregister    &{tc}
