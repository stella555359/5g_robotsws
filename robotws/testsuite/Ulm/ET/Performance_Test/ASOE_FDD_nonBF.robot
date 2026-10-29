*** Settings ***
Documentation
...  author:  Squad 69
...  contact: I_MN_RAN_SW_ULM_ET_AP_PET_GMS
...  Description:   Test Cases for TDD 1 Cell 100 UEs Performance Test

Resource   ./resources/performance_keywords.robot
Resource   ./resources/performance_test_setup.robot
Resource   ./resources/performance_egate.robot
Resource   ./resources/performance_info.robot
Resource   ./resources/performance_log_collection.robot

Force Tags    CLOUD_5G_O_E_AP_LO

Suite Setup       performance_test_setup.Suite Setup For Performance Test
Suite Teardown    performance_test_setup.Suite Teardown For Performance Test
Test Setup        performance_test_setup.Test Case Setup For Performance Test
Test Teardown     performance_test_setup.Test Case Teardown For Performance Test


*** Test Cases ***
fdd_1Cell_100Ues_DL_ASOE
    [Documentation]
    ...    Performance Test for FDD ASOE configuration with 100 UEs attached to 1 Cell and running DL traffic simultaneously
    [Tags]    DL
    [Setup]    performance_test_setup.Test Case Setup For Performance Test    ENABLE_MARVIN=true
    Set Test Variable    ${QC_TEST_NAME}      [1]L2PS_performance_indicator_check_fdd_1Cell_100Ues_Dl

    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=1
    ...                      num_cells_online=6
    ...                           ue_per_cell=100
    ...                           ul_datarate=0
    ...                           dl_datarate=5557
    ...                                  rate=kbps
    ...                         trf_direction=dl
    ...                             tolerance=0.33297  # lowered DL threshold  ~13900000 in PM Counter
    ...                                   lua=sansa_fdd_asoe_1cell.lua
    ...                             ue_nr_cap=UE_CA_n25A_n662A_n71A_n772A
    ...                                 entry=pet_seql2_start_100UE_DL
    performance_keywords.Run Common Test    &{tc}


fdd_1Cell_100Ues_UL_ASOE
    [Documentation]
    ...    Performance Test for FDD ASOE configuration with 100 UEs attached to 1 Cell and running UL traffic simultaneously
    [Tags]    UL
    [Setup]    performance_test_setup.Test Case Setup For Performance Test    ENABLE_MARVIN=true
    Set Test Variable    ${QC_TEST_NAME}      [1]L2PS_performance_indicator_check_fdd_1Cell_100Ues_Ul

    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=1
    ...                      num_cells_online=6
    ...                           ue_per_cell=100
    ...                           ul_datarate=2778
    ...                           dl_datarate=0
    ...                                  rate=kbps
    ...                         trf_direction=ul
    ...                             tolerance=0.35205183585313177  # Verify_TP_with_Counters_FDD_UL=6750000
    ...                                   lua=sansa_fdd_asoe_1cell.lua
    ...                             ue_nr_cap=UE_CA_n25A_n662A_n71A_n772A
    ...                                 entry=pet_seql2_start_100UE_UL
    performance_keywords.Run Common Test    &{tc}



fdd_16Cell_20MHz_full_board_UL_ASOE
    [Documentation]    CB014208-B#B1-ASOE 16 FDD 20Mhz CPRI cells - 4DL4UL
    [Setup]    Test Case Setup For Performance Test    ENABLE_TTI_TRACE_QUICK=true
    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=16
    ...                           ue_per_cell=10
    ...                           ul_datarate=20
    ...                           dl_datarate=0
    ...                                  rate=mbps
    ...                         trf_direction=ul
    ...                             tolerance=0.50
    ...                                   lua=sansa_fdd_asoe_16cell_6amf.lua
    ...                             ue_nr_cap=UE_CAP_4x4
    ...                       entry_auto_args=true
    ...                                 entry=performance_common_seq_lua_fdd
    performance_keywords.Run Common Test    &{tc}
    performance_ttitrace.Check TTI Trace Total Number Of Sched UEs Per L1Pool  count=76

fdd_16Cell_20MHz_full_board_DL_ASOE
    [Documentation]    CB014208-B#B2-ASOE 16 FDD 20Mhz CPRI cells - 4DL4UL
    [Setup]    Test Case Setup For Performance Test    ENABLE_TTI_TRACE_QUICK=true
    ...                                                ENABLE_LOG_DCAP=true
    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=16
    ...                           ue_per_cell=12
    ...                           ul_datarate=0
    ...                           dl_datarate=60
    ...                                  rate=mbps
    ...                         trf_direction=dl
    ...                             tolerance=0.50
    ...                                   lua=sansa_fdd_asoe_16cell_6amf.lua
    ...                             ue_nr_cap=UE_CAP_4x4
    ...                       entry_auto_args=true
    ...                                 entry=performance_common_seq_lua_fdd
    performance_keywords.Run Common Test    &{tc}
    performance_ttitrace.Check TTI Trace Total Number Of Sched UEs Per L1Pool for DL  count=72
