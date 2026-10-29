*** Settings ***
Documentation
...  author:  Squad 69
...  contact: I_MN_RAN_SW_ULM_ET_AP_PET_GMS
...  Description:   Test Cases for TDD 1 Cell 100 UEs Performance Test

Resource   ./resources/performance_keywords.robot
Resource   ./resources/performance_test_setup.robot

Force Tags    CLOUD_5G_I_MP_AP_LOOO

Suite Setup       performance_test_setup.Suite Setup For Performance Test
#...                                                   SCF_ENABLE_BEAMFORMING=true
#...                                                   SCF_CONFIGURE_SRS=true
#...                                                   ENABLE_SRS_INFO=true
#...                                                   SCF_SET_VAR_NRCELL_actUlSrsBm=true
#...                                                   SCF_SET_VAR_NRCELL_actDlSrsBm=true

Suite Teardown    performance_test_setup.Suite Teardown For Performance Test
Test Setup        performance_test_setup.Test Case Setup For Performance Test
Test Teardown     performance_test_setup.Test Case Teardown For Performance Test


*** Test Cases ***
tdd_12Cell_full_40Ues_test
    [Setup]    performance_test_setup.Test Case Setup For Performance Test    ENABLE_TIMEMARKER=false

    Set Test Variable    ${QC_TEST_NAME}   [1]L2PS_performance_indicator_check_tdd_12Cell_full_40Ues_Ul_Dl
    Set Test Variable    ${QC_PATH}    testsuite/Ulm/ET/Performance_Test/resources/qc/ABIP_performance.qc
    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=12
    ...                           ue_per_cell=40
    ...                           ul_datarate=1500
    ...                           dl_datarate=14000
    ...                                  rate=kbps
    ...                         trf_direction=both
    ...                             ue_nr_cap=UE_CAP
    ...                             tolerance=0.05
    ...                                   lua=sansa_tdd_12cell.lua
    ...                       entry_auto_args=true
    ...                                 entry=performance_common_seq_lua_tdd
    performance_keywords.Run Common Test    &{tc}


tdd_6Cell_full_100Ues_test
    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=6
    ...                           ue_per_cell=100
    ...                           ul_datarate=1000
    ...                           dl_datarate=1000
    ...                                  rate=kbps
    ...                         trf_direction=both
    ...                             ue_nr_cap=UE_CAP
    ...                             tolerance=0.05
    ...                                   lua=sansa_tdd_6cell.lua
    ...                       entry_auto_args=true
    ...                                 entry=performance_common_seq_lua_tdd
    performance_keywords.Run Common Test    &{tc}


tdd_12Cell_full_20Ues_ramp_varUE_DL_CsReductionFactorOlc_0
    [Setup]    performance_test_setup.Test Case Setup For Performance Test
    ...                 SCF_SET_VAR_NRBTS_actFdmScheduling=true
    ...            SCF_SET_VAR_NRBTS_actSchedFairnessUlOlc=true
    ...     SCF_SET_VAR_NRCELL_actIncreasedFdmUsersPerSlot=true
    ...    SCF_SET_VAR_NRCELL_maxNumPdschAllocationPerSlot=16
    ...    SCF_SET_VAR_NRCELL_maxNumPuschAllocationPerSlot=16
    ...                          SCF_ENABLE_BB_POOLING=true
    performance_common_tc.Run Common Test With Ramp
    ...                            start_cell=1
    ...                              end_cell=12
    ...                           ue_per_cell=20
    ...                           ul_datarate=272
    ...                           dl_datarate=2550
    ...                                  rate=kbps
    ...                         trf_direction=both
    ...                             tolerance=.2
    ...                                   lua=sansa_tdd_12cell.lua
    ...                             ue_nr_cap=UE_CAP
    ...                       entry_auto_args=true
    ...                                 entry=PERFORMANCE_COMMON_TDD_V2
    ...                          active_cells=1,2
                                    ## params for ramp ue
    ...                      ramp_ue_per_cell=433
    ...                      ramp_ul_datarate=0
    ...                      ramp_dl_datarate=2550
    ...                    ramp_trf_direction=dl
    ...                   ramp_register_delay=1
    ...                            ramp_entry=performance_common_lua_v2
    ...                        ramp_traffic_sleep=0


tdd_12Cell_full_20Ues_ramp_varUE_DL_CsReductionFactorOlc_50
    [Setup]    performance_test_setup.Test Case Setup For Performance Test
    ...                 SCF_SET_VAR_NRBTS_actFdmScheduling=true
    ...            SCF_SET_VAR_NRBTS_actSchedFairnessUlOlc=true
    ...     SCF_SET_VAR_NRCELL_actIncreasedFdmUsersPerSlot=true
    ...    SCF_SET_VAR_NRCELL_maxNumPdschAllocationPerSlot=16
    ...    SCF_SET_VAR_NRCELL_maxNumPuschAllocationPerSlot=16
    ...                          SCF_ENABLE_BB_POOLING=true
    ...                    previous_tc_testname_for_db=tdd_12Cell_full_20Ues_ramp_varUE_DL_CsReductionFactorOlc_0
    performance_common_tc.Run Common Test With Ramp
    ...                            start_cell=1
    ...                              end_cell=12
    ...                           ue_per_cell=20
    ...                           ul_datarate=272
    ...                           dl_datarate=2550
    ...                                  rate=kbps
    ...                         trf_direction=both
    ...                             tolerance=.2
    ...                                   lua=sansa_tdd_12cell.lua
    ...                             ue_nr_cap=UE_CAP
    ...                       entry_auto_args=true
    ...                                 entry=PERFORMANCE_COMMON_TDD_V2
    ...                          active_cells=1,2
                                    ## params for ramp ue
    ...                      ramp_ue_per_cell=433
    ...                      ramp_ul_datarate=0
    ...                      ramp_dl_datarate=2550
    ...                    ramp_trf_direction=dl
    ...                   ramp_register_delay=1
    ...                            ramp_entry=performance_common_lua_v2
    ...                        ramp_traffic_sleep=0


tdd_12Cell_full_20Ues_ramp_varUE_UL_CsReductionFactorOlc_0
    [Setup]    performance_test_setup.Test Case Setup For Performance Test
    ...                 SCF_SET_VAR_NRBTS_actFdmScheduling=true
    ...            SCF_SET_VAR_NRBTS_actSchedFairnessUlOlc=true
    ...     SCF_SET_VAR_NRCELL_actIncreasedFdmUsersPerSlot=true
    ...    SCF_SET_VAR_NRCELL_maxNumPdschAllocationPerSlot=16
    ...    SCF_SET_VAR_NRCELL_maxNumPuschAllocationPerSlot=16
    ...                          SCF_ENABLE_BB_POOLING=true
    performance_common_tc.Run Common Test With Ramp
    ...                            start_cell=1
    ...                              end_cell=12
    ...                           ue_per_cell=20
    ...                           ul_datarate=272
    ...                           dl_datarate=2550
    ...                                  rate=kbps
    ...                         trf_direction=both
    ...                             tolerance=.2
    ...                                   lua=sansa_tdd_12cell.lua
    ...                             ue_nr_cap=UE_CAP
    ...                       entry_auto_args=true
    ...                                 entry=PERFORMANCE_COMMON_TDD_V2
    ...                          active_cells=1,2
                                    ## params for ramp ue
    ...                      ramp_ue_per_cell=433
    ...                      ramp_ul_datarate=272
    ...                      ramp_dl_datarate=0
    ...                    ramp_trf_direction=ul
    ...                   ramp_register_delay=1
    ...                            ramp_entry=performance_common_lua_v2
    ...                        ramp_traffic_sleep=0


tdd_12Cell_full_20Ues_ramp_varUE_UL_CsReductionFactorOlc_50
    [Setup]    performance_test_setup.Test Case Setup For Performance Test
    ...                 SCF_SET_VAR_NRBTS_actFdmScheduling=true
    ...            SCF_SET_VAR_NRBTS_actSchedFairnessUlOlc=true
    ...     SCF_SET_VAR_NRCELL_actIncreasedFdmUsersPerSlot=true
    ...    SCF_SET_VAR_NRCELL_maxNumPdschAllocationPerSlot=16
    ...    SCF_SET_VAR_NRCELL_maxNumPuschAllocationPerSlot=16
    ...                          SCF_ENABLE_BB_POOLING=true
    ...                    previous_tc_testname_for_db=tdd_12Cell_full_20Ues_ramp_varUE_UL_CsReductionFactorOlc_0
    performance_common_tc.Run Common Test With Ramp
    ...                            start_cell=1
    ...                              end_cell=12
    ...                           ue_per_cell=20
    ...                           ul_datarate=272
    ...                           dl_datarate=2550
    ...                                  rate=kbps
    ...                         trf_direction=both
    ...                             tolerance=.2
    ...                                   lua=sansa_tdd_12cell.lua
    ...                             ue_nr_cap=UE_CAP
    ...                       entry_auto_args=true
    ...                                 entry=PERFORMANCE_COMMON_TDD_V2
    ...                          active_cells=1,2
                                    ## params for ramp ue
    ...                      ramp_ue_per_cell=433
    ...                      ramp_ul_datarate=272
    ...                      ramp_dl_datarate=0
    ...                    ramp_trf_direction=ul
    ...                   ramp_register_delay=1
    ...                            ramp_entry=performance_common_lua_v2
    ...                        ramp_traffic_sleep=0
