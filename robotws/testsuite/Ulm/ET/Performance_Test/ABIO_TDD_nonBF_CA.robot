*** Settings ***
Documentation
...  author:  Squad 69
...  contact: I_MN_RAN_SW_ULM_ET_AP_PET_GMS
...  Description:   Test Cases for TDD 1 Cell 100 UEs Performance Test

Resource   ./resources/performance_keywords.robot
Resource   ./resources/performance_test_setup.robot


Suite Setup       performance_test_setup.Suite Setup For Performance Test
...                                                   SCF_ENABLE_BEAMFORMING=true    # convert this to BF testcase when enabled
...                                                   SCF_CONFIGURE_SRS=true
...                                                   ENABLE_SRS_INFO=true
...                                                   SCF_SET_VAR_NRCELL_actUlSrsBm=true
...                                                   SCF_SET_VAR_NRCELL_actDlSrsBm=true
Suite Teardown    performance_test_setup.Suite Teardown For Performance Test
Test Setup        performance_test_setup.Test Case Setup For Performance Test
Test Teardown     performance_test_setup.Test Case Teardown For Performance Test


*** Test Cases ***
tdd_1Cell_ABIO_nonBF_8_4MIMO_40UE_DL_3CC
    [Documentation]    Performance Test for TDD ABIO PET_1208FF_nonBF_40UE_DL_3CC
    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=1
    ...                           ue_per_cell=40
    ...                           ul_datarate=0
    ...                           dl_datarate=120000
    ...                                  rate=kbps
    ...                         trf_direction=dl
    ...                             ue_nr_cap=UE_CAP
    ...                             tolerance=0.8125  # Verify_TP_with_Counters_TDD_DL=33750000
    ...                                   lua=sansa_tdd_1cell.lua
    ...                                 entry=PET_1208FF_nonBF_40UE_DL_3CC
    performance_keywords.Run Common Test    &{tc}
