*** Settings ***
Documentation
...  author:  VRF_ULM_5_01
...  contact: I_MN_RAN_SW_ULM_ET_AP_PET_GMS
...  Description:   Test Cases for FDD ABIP Performance Test

Resource   ./resources/performance_keywords.robot
Resource   ./resources/performance_test_setup.robot

Suite Setup       performance_test_setup.Suite Setup For Performance Test
Suite Teardown    performance_test_setup.Suite Teardown For Performance Test
Test Setup        performance_test_setup.Test Case Setup For Performance Test
Test Teardown     performance_test_setup.Test Case Teardown For Performance Test


*** Test Cases ***

fdd_15Cell_20MHz_half_board_UL_DL
    [Documentation]    CB014209 Half-ABIP 15 FDD CPRI cells - 4DL4UL up to 20Mhz
    [Tags]    CLOUD_5G_I_MP_AP_LOOO
    [Setup]    Test Case Setup For Performance Test    ENABLE_TTI_TRACE_QUICK=true

    Set Test Variable    ${QC_TEST_NAME}
    ...                  [1]CB014209_A_TC08_Robustness_Maximum_number_of_PUSCH_and_PDSCH_UEs_per_slot_per_BBP_half_ABIP_15_FDD_CPRI_cells
    Set Test Variable    ${QC_PATH}    testsuite/Ulm/ET/Performance_Test/resources/qc/CB014209.qc

    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=15
    ...                           ue_per_cell=16
    ...                           ul_datarate=6
    ...                           dl_datarate=12
    ...                                  rate=mbps
    ...                         trf_direction=both
    ...                             tolerance=0.1
    ...                                   lua=sansa_fdd_15cell.lua
    ...                             ue_nr_cap=UE_CAP_4x4_15CELLS
    ...                       entry_auto_args=true
    ...                                 entry=performance_common_seq_lua_fdd
    performance_keywords.Run Common Test    &{tc}
    performance_ttitrace.Check TTI Trace Total Number Of Sched UEs Per L1Pool  count=46
    performance_ttitrace.Check TTI Trace Total Number Of Sched UEs Per L1Pool For DL  count=50


fdd_4Cell_50MHz_half_board_UL_DL
    [Documentation]    Half-ABIP 4 FDD CPRI cells - 4DL4UL up to 50Mhz
    [Tags]    CLOUD_5G_I_MP_AP_LOOO
    [Setup]    Test Case Setup For Performance Test    ENABLE_TTI_TRACE_QUICK=true
    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=4
    ...                           ue_per_cell=20
    ...                           ul_datarate=20
    ...                           dl_datarate=35
    ...                                  rate=mbps
    ...                         trf_direction=both
    ...                             tolerance=0.1
    ...                                   lua=sansa_fdd_4cell.lua
    ...                             ue_nr_cap=SA_NonCA_B3_FDD
    ...                       entry_auto_args=true
    ...                                 entry=performance_common_seq_lua_fdd
    performance_keywords.Run Common Test    &{tc}
    performance_ttitrace.Check TTI Trace Total Number Of Sched UEs Per L1Pool  count=40
    performance_ttitrace.Check TTI Trace Total Number Of Sched UEs Per L1Pool For DL  count=48
