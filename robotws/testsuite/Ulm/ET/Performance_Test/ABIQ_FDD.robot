*** Settings ***
Documentation
...  author:  VRF_ULM_5_01
...  contact: I_MN_RAN_SW_ULM_ET_AP_PET_GMS
...  Description:   Test Cases for FDD ABIQ Performance Test

Resource   ./resources/performance_keywords.robot
Resource   ./resources/performance_test_setup.robot

Force Tags    CLOUD_5G_I_MQ_AP_LOOO

Suite Setup       performance_test_setup.Suite Setup For Performance Test
Suite Teardown    performance_test_setup.Suite Teardown For Performance Test
Test Setup        performance_test_setup.Test Case Setup For Performance Test
Test Teardown     performance_test_setup.Test Case Teardown For Performance Test


*** Test Cases ***
fdd_12Cell_half_board_UL_DL
    [Setup]    Test Case Setup For Performance Test    ENABLE_TTI_TRACE_QUICK=true
    ...                                                ENABLE_LTEPAT=false

    Set Test Variable    ${QC_TEST_NAME}
    ...                  [1]CB014209_B_TC07_Robustness_Maximum_number_of_PUSCH_and_PDSCH_UEs_per_slot_per_BBP_half_ABIQ_12_FDD_CPRI_cells
    Set Test Variable    ${QC_PATH}    testsuite/Ulm/ET/Performance_Test/resources/qc/CB014209.qc

    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=12
    ...                           ue_per_cell=20
    ...                           ul_datarate=5
    ...                           dl_datarate=12
    ...                                  rate=mbps
    ...                         trf_direction=both
    ...                             tolerance=0.1
    ...                                   lua=sansa_fdd_12cell.lua
    ...                             ue_nr_cap=UE_CAP_4x4
    ...                       entry_auto_args=true
    ...                                 entry=performance_common_seq_lua_fdd
    performance_keywords.Run Common Test    &{tc}
    performance_ttitrace.Check TTI Trace Total Number Of Sched UEs Per L1Pool  count=38
    performance_ttitrace.Check TTI Trace Total Number Of Sched UEs Per L1Pool For DL  count=38

fdd_6Cell_half_board_UL_DL
    [Setup]    Test Case Setup For Performance Test    ENABLE_TTI_TRACE_QUICK=true
    ...                                                ENABLE_LTEPAT=false
    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=6
    ...                           ue_per_cell=20
    ...                           ul_datarate=10
    ...                           dl_datarate=23
    ...                                  rate=mbps
    ...                         trf_direction=both
    ...                             tolerance=0.1
    ...                                   lua=sansa_fdd_6cell.lua
    ...                             ue_nr_cap=SA_FDD_4X4_40Mhz_n3
    ...                       entry_auto_args=true
    ...                                 entry=performance_common_seq_lua_fdd
    performance_keywords.Run Common Test    &{tc}
    performance_ttitrace.Check TTI Trace Total Number Of Sched UEs Per L1Pool  count=38
    performance_ttitrace.Check TTI Trace Total Number Of Sched UEs Per L1Pool For DL  count=38

fdd_3Cell_half_board_UL_DL
    [Setup]    Test Case Setup For Performance Test    ENABLE_TTI_TRACE_QUICK=true
    ...                                                ENABLE_LTEPAT=false
    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=3
    ...                           ue_per_cell=20
    ...                           ul_datarate=20
    ...                           dl_datarate=45
    ...                                  rate=mbps
    ...                         trf_direction=both
    ...                             tolerance=0.1
    ...                                   lua=sansa_fdd_3cell.lua
    ...                             ue_nr_cap=SA_NonCA_B3_FDD
    ...                       entry_auto_args=true
    ...                                 entry=performance_common_seq_lua_fdd
    performance_keywords.Run Common Test    &{tc}
    performance_ttitrace.Check TTI Trace Total Number of Sched UEs Per L1Pool  count=30
    performance_ttitrace.Check TTI Trace Total Number of Sched UEs Per L1Pool for DL  count=36
