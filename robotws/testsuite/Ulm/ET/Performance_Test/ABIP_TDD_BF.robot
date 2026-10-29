*** Settings ***
Documentation
...  author:  Squad 69
...  contact: I_MN_RAN_SW_ULM_ET_AP_PET_GMS
...  Description:   Test Cases for TDD 1 Cell 100 UEs Performance Test

Resource   ./resources/performance_keywords.robot
Resource   ./resources/performance_test_setup.robot

Force Tags    CLOUD_5G_I_MP_AP_LOOO

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
tdd_1Cell_100Ues_DL_ABIP
    [Documentation]
    ...    Beamforming; Performance Test for TDD ABIP configuration with 100 UEs attached to 1 Cell and running DL traffic simultaneously
    [Tags]    DL

    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=1
    ...                      num_cells_online=6
    ...                           ue_per_cell=100
    ...                           ul_datarate=0
    ...                           dl_datarate=22200
    ...                                  rate=kbps
    ...                         trf_direction=dl
    ...                             tolerance=0.5945945945945946    # old pmc check is 33750000
    ...                                   lua=sansa_tdd_1cell.lua
    ...                       entry_auto_args=true
    ...                                 entry=PERFORMANCE_COMMON_TDD_SEQ_BF  # PET_1208FF_BF_100UE_DL
    performance_keywords.Run Common Test    &{tc}
    Run Keyword And Warn On Failure    Verify Beamforming PM Counters    dl


tdd_1Cell_100Ues_UL_ABIP
    [Documentation]
    ...    Beamforming; Performance Test for TDD ABIP configuration with 100 UEs attached to 1 Cell and running UL traffic simultaneously
    [Tags]    UL

    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=1
    ...                      num_cells_online=6
    ...                           ue_per_cell=100
    ...                           ul_datarate=3000
    ...                           dl_datarate=0
    ...                                  rate=kbps
    ...                         trf_direction=ul
    ...                             tolerance=0.4  # Verify_TP_with_Counters_FDD_UL=6750000
    ...                                   lua=sansa_tdd_1cell.lua
    ...                       entry_auto_args=true
    ...                                 entry=PERFORMANCE_COMMON_TDD_SEQ_BF  # PET_1208FF_BF_100UE_UL
    performance_keywords.Run Common Test    &{tc}
    Run Keyword And Warn On Failure    Verify Beamforming PM Counters    ul


tdd_1Cell_100Ues_ABIP
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
    ...                             tolerance=0.5945945945945946
    ...                                   lua=sansa_tdd_1cell.lua
    ...                       entry_auto_args=true
    ...                                 entry=PERFORMANCE_COMMON_TDD_SEQ_BF

    Run Keyword And Warn On Failure    Verify Beamforming PM Counters    both


ABIP_TDD_BF_6Cells_72UEsPerCell_UL_DL
    [Documentation]
    ...    Performance Test
    [Tags]    TRAFFIC_BOTH
    ...       CLOUD_5G_I_MP_AP_LOOO    ABIP    TDD

    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=6
    ...                           ue_per_cell=72
    ...                           ul_datarate=3000
    ...                           dl_datarate=18000
    ...                                  rate=kbps
    ...                         trf_direction=both
    ...                             ue_nr_cap=UE_CAP
    ...                             tolerance=0.05
    ...                                   lua=sansa_tdd_6cell.lua
    ...                       entry_auto_args=true
    ...                                 entry=PERFORMANCE_COMMON_TDD_SEQ_BF
    performance_keywords.Run Common Test    &{tc}
