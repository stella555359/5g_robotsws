*** Settings ***
Documentation
...  author:  Squad 69
...  contact: I_MN_RAN_SW_ULM_ET_AP_PET_GMS
...  Description:   Test Cases for TDD 1 Cell 100 UEs Performance Test

Resource   ./resources/performance_keywords.robot
Resource   ./resources/performance_test_setup.robot


Suite Setup       performance_test_setup.Suite Setup For Performance Test
Suite Teardown    performance_test_setup.Suite Teardown For Performance Test
Test Setup        performance_test_setup.Test Case Setup For Performance Test
Test Teardown     performance_test_setup.Test Case Teardown For Performance Test


*** Test Cases ***
fdd_1Cell_100Ues_DL_ABIP
    [Documentation]
    ...    Performance Test for FDD ABIP configuration with 100 UEs attached to 1 Cell and running DL traffic simultaneously
    [Tags]    DL
    Set Test Variable   ${QC_TEST_NAME}   [1]L2PS_performance_indicator_check_fdd_1Cell_100Ues_Dl
    Set Test Variable    ${QC_PATH}       testsuite/Ulm/ET/Performance_Test/resources/qc/ABIP_performance.qc
    @{T_DEFAULT_TTI_EVENTS}=    Create List    dlLoadControlData
    Set Test Variable    ${T_DEFAULT_TTI_EVENTS}

    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=1
    ...                      num_cells_online=12
    ...                          active_cells=1
    ...                           ue_per_cell=100
    ...                           ul_datarate=0
    ...                           dl_datarate=4500
    ...                                  rate=kbps
    ...                         trf_direction=dl
    ...                             tolerance=0.176  # PMC 13905000: 10% of max achievable cell tput 412mbps
    ...                                   lua=sansa_fdd_1cell.lua
    ...                             ue_nr_cap=UE_CAP_4x4
    ...                       entry_auto_args=true
    ...                                 entry=performance_common_seq_lua_fdd  # pet_seql2_start_100UE_DL
    performance_keywords.Run Common Test    &{tc}



fdd_1Cell_100Ues_UL_ABIP
    [Documentation]
    ...    Performance Test for FDD ABIP configuration with 100 UEs attached to 1 Cell and running UL traffic simultaneously
    [Tags]    UL
    Set Test Variable   ${QC_TEST_NAME}   [1]L2PS_performance_indicator_check_fdd_1Cell_100Ues_Ul
    Set Test Variable    ${QC_PATH}       testsuite/Ulm/ET/Performance_Test/resources/qc/ABIP_performance.qc

    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=1
    ...                      num_cells_online=12
    ...                          active_cells=1
    ...                           ue_per_cell=100
    ...                           ul_datarate=2200
    ...                           dl_datarate=0
    ...                                  rate=kbps
    ...                         trf_direction=ul
    ...                             tolerance=0.141  # PMC 7087500: 10% of max achievable cell tput 210mbps
    ...                                   lua=sansa_fdd_1cell.lua
    ...                             ue_nr_cap=UE_CAP_4x4
    ...                       entry_auto_args=true
    ...                                 entry=performance_common_seq_lua_fdd  # pet_seql2_start_100UE_UL
    performance_keywords.Run Common Test    &{tc}


fdd_1Cell_100Ues_ABIP
    [Documentation]
    ...    Performance Test for FDD ABIP configuration with 100 UEs attached to 1 Cell and running DL+UL traffic simultaneously
    [Tags]    ULDL

    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=1
    ...                      num_cells_online=12
    ...                          active_cells=1
    ...                           ue_per_cell=100
    ...                           ul_datarate=2200
    ...                           dl_datarate=4500
    ...                                  rate=kbps
    ...                         trf_direction=both
    ...                             tolerance=0.18
    ...                                   lua=sansa_fdd_1cell.lua
    ...                             ue_nr_cap=UE_CAP_4x4
    ...                       entry_auto_args=true
    ...                                 entry=performance_common_seq_lua_fdd  # pet_seql2_start_100UE_UL
    performance_keywords.Run Common Test    &{tc}


fdd_12Cell_43Ues_UL_DL_ABIP_BL
    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=12
    ...                           ue_per_cell=43
    ...                           ul_datarate=2400
    ...                           dl_datarate=7000
    ...                                  rate=kbps
    ...                         trf_direction=both
    ...                             tolerance=0.1
    ...                                   lua=sansa_fdd_12cell.lua
    ...                             ue_nr_cap=UE_CAP_4x4
    ...                       entry_auto_args=true
    ...                                 entry=performance_common_seq_lua_fdd
    performance_keywords.Run Common Test    &{tc}



fdd_15Cell_half_20Ues_ramp_varUE_DL
    [Setup]    performance_test_setup.Test Case Setup For Performance Test
    ...                 SCF_SET_VAR_NRBTS_actFdmScheduling=true
    ...            SCF_SET_VAR_NRBTS_actSchedFairnessUlOlc=true
    ...     SCF_SET_VAR_NRCELL_actIncreasedFdmUsersPerSlot=true
    ...    SCF_SET_VAR_NRCELL_maxNumPdschAllocationPerSlot=12
    ...    SCF_SET_VAR_NRCELL_maxNumPuschAllocationPerSlot=10
    performance_common_tc.Run Common Test with Ramp
    ...                            start_cell=1
    ...                              end_cell=15
    ...                          active_cells=1,3,4,5,7
    ...                           ue_per_cell=20
    ...                           ul_datarate=10000
    ...                           dl_datarate=0
    ...                                  rate=kbps
    ...                         trf_direction=ul
    ...                             tolerance=.2
    ...                                   lua=sansa_fdd_15cell.lua
    ...                             ue_nr_cap=UE_CAP_2x2_15CELLS
    ...                       entry_auto_args=true
    ...                                 entry=performance_common_seq_active_cells_lua_fdd
                                    ## params for ramp ue
    ...                      ramp_ue_per_cell=200
    ...                      ramp_ul_datarate=0
    ...                      ramp_dl_datarate=3250
    ...                    ramp_trf_direction=dl
    ...                   ramp_register_delay=1
    ...                            ramp_entry=performance_common_lua_v2
    ...                        ramp_traffic_sleep=0


fdd_15Cell_half_20Ues_ramp_varUE_UL
    [Documentation]    Load 5 cells mapped to the same L2SP
    [Setup]    performance_test_setup.Test Case Setup For Performance Test
    ...                 SCF_SET_VAR_NRBTS_actFdmScheduling=true
    ...            SCF_SET_VAR_NRBTS_actSchedFairnessUlOlc=true
    ...     SCF_SET_VAR_NRCELL_actIncreasedFdmUsersPerSlot=true
    ...    SCF_SET_VAR_NRCELL_maxNumPdschAllocationPerSlot=12
    ...    SCF_SET_VAR_NRCELL_maxNumPuschAllocationPerSlot=10
    performance_common_tc.Run Common Test with Ramp
    ...                            start_cell=1
    ...                              end_cell=15
    ...                          active_cells=1,3,4,5,7
    ...                           ue_per_cell=20
    ...                           ul_datarate=0
    ...                           dl_datarate=50
    ...                                  rate=kbps
    ...                         trf_direction=dl
    ...                             tolerance=.2
    ...                                   lua=sansa_fdd_15cell.lua
    ...                             ue_nr_cap=UE_CAP_2x2_15CELLS
    ...                       entry_auto_args=true
    ...                                 entry=performance_common_seq_active_cells_lua_fdd
                                    ## params for ramp ue
    ...                      ramp_ue_per_cell=200
    ...                      ramp_ul_datarate=190
    ...                      ramp_dl_datarate=0
    ...                    ramp_trf_direction=ul
    ...                   ramp_register_delay=1
    ...                            ramp_entry=performance_common_lua_v2
    ...                    ramp_traffic_sleep=0


fdd_15Cell_half_UL_DL
    [Documentation]    Load 5 cells mapped to the same L2SP
    [Setup]    performance_test_setup.Test Case Setup For Performance Test
    ...                 SCF_SET_VAR_NRBTS_actFdmScheduling=true
    ...            SCF_SET_VAR_NRBTS_actSchedFairnessUlOlc=true
    ...     SCF_SET_VAR_NRCELL_actIncreasedFdmUsersPerSlot=true
    ...    SCF_SET_VAR_NRCELL_maxNumPdschAllocationPerSlot=12
    ...    SCF_SET_VAR_NRCELL_maxNumPuschAllocationPerSlot=10
    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=15
    ...                          active_cells=1,3,4,5,7
    ...                           ue_per_cell=20
    ...                           ul_datarate=10000
    ...                           dl_datarate=20000
    ...                                  rate=kbps
    ...                         trf_direction=both
    ...                             tolerance=.2
    ...                                   lua=sansa_fdd_15cell.lua
    ...                             ue_nr_cap=UE_CAP_2x2_15CELLS
    ...                       entry_auto_args=true
    ...                                 entry=performance_common_seq_active_cells_lua_fdd
    performance_keywords.Run Common Test    &{tc}



fdd_24Cell_full_UL_DL
    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=24
    ...                           ue_per_cell=43
    ...                           ul_datarate=2400
    ...                           dl_datarate=7000
    ...                                  rate=kbps
    ...                         trf_direction=both
    ...                             tolerance=0.1
    ...                                   lua=sansa_fdd_24cell.lua
    ...                             ue_nr_cap=UE_CAP_2x2
    ...                       entry_auto_args=true
    ...                                 entry=performance_common_seq_lua_fdd
    performance_keywords.Run Common Test    &{tc}
