*** Settings ***
Documentation
...  author:  Squad 69
...  contact: I_MN_RAN_SW_ULM_ET_AP_PET_GMS
...  Description:   Test Cases ASOE BB Pooling enabled

Resource          ./resources/performance_keywords.robot
Resource          ./resources/performance_common_tc.robot
Resource          ./resources/performance_test_setup.robot

Force Tags        CLOUD_5G_O_E_AP_LOOO

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
tdd_6cell_100Ues_trf_150UE_idle_cell_1_and_cell_3_ASOE_pooling
    [Documentation]   Test for Active UE in Cells 1 and 3
    Run Common Test With Idle UE      start_cell=1
    ...                                 end_cell=6
    ...                             active_cells=1,3
    ...                              ul_datarate=3000
    ...                              dl_datarate=32000
    ...                                     rate=kbps
    ...                            trf_direction=both
    ...                                 start_ue=1
    ...                              ue_per_cell=60
    ...                                period_ms=none
    ...                                      lua=sansa_tdd_6cell.lua
    ...                                ue_nr_cap=UE_CAP_MUMIMO
    ...                        registration_type=InitialRegistration
    ...                                tolerance=.5    # very low tput drop expected
    ...                          entry_auto_args=true
    ...                                    entry=PERFORMANCE_COMMON_TDD_SEQ_SRS_ACTIVE_CELLS
    ...                                  timeout=2400
                                      ## params for idle ue
    ...                           number_of_idle=150
    ...                          packetsize_idle=42
    ...                           period_ms_idle=5000
