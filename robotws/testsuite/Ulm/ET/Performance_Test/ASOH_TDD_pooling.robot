*** Settings ***
Documentation
...  author:  Squad 69
...  contact: I_MN_RAN_SW_ULM_ET_AP_PET_GMS
...  Description:   Test Cases for ASOH TDD Pooling

Resource   ./resources/performance_keywords.robot
Resource   ./resources/performance_ttitrace.robot
Resource   ./resources/performance_verification.robot
Resource   ./resources/performance_test_setup.robot

Force Tags    CLOUD_5G_I_O_H_AP_LOOO

Suite Setup       performance_test_setup.Suite Setup For Performance Test    SCF_ENABLE_BB_POOLING=true
Suite Teardown    performance_test_setup.Suite Teardown For Performance Test
Test Setup        performance_test_setup.Test Case Setup For Performance Test
Test Teardown     performance_test_setup.Test Case Teardown For Performance Test


*** Test Cases ***
CB013027-C_TC03_Benchmark_UEs_4Cells_Half_ASOH_equal_load
    [Documentation]    Test Case 2: CB013027-C#2 Maximum number of PDSCH UEs per slot per BB pool,
    ...                L1 subpool and L2 subpool on half ASOH with 4 FR1 TDD eCPRI cells
    [Tags]    ULDL    CLOUD_5G_O_H_AP_LOOO    ASOH    TDD
    [Setup]    performance_test_setup.Test Case Setup For Performance Test    ENABLE_TTI_TRACE_QUICK=true

    Set Test Variable    ${QC_PATH}    testsuite/Ulm/ET/Performance_Test/resources/qc/CB013027-SR_ASOH.qc
    Set Test Variable    ${QC_TEST_NAME}
    ...                  [1]CB013027_C_TC03_Benchmark_the_number_of_PDSCH_and_PUSCH_UEs_per_slot_on_half_ASOH_with_4_FR1_TDD_eCPRI_cells

    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=4
    ...                           ue_per_cell=16
    ...                           ul_datarate=21000
    ...                           dl_datarate=90000
    ...                                  rate=kbps
    ...                         trf_direction=both
    ...                             ue_nr_cap=UE_CAP
    ...                             tolerance=0.3
    ...                                   lua=sansa_tdd_4cell.lua
    ...                       entry_auto_args=true
    ...                                 entry=performance_common_seq_active_cells_lua_tdd
    performance_keywords.Run Common Test    &{tc}
    performance_ttitrace.Check TTI Trace Total Number of Sched UEs Per L1Pool  count=48
    performance_ttitrace.Check TTI Trace Total Number of Sched UEs Per L1Pool for DL  count=48


CB013027-C_TC06_Benchmark_UEs_3Cells_Half_ASOH_equal_load
    [Documentation]    Test Case 2: CB013027-C#2 Maximum number of PDSCH UEs per slot per BB pool,
    ...                L1 subpool and L2 subpool on half ASOH with 4 FR1 TDD eCPRI cells
    [Tags]    ULDL    CLOUD_5G_O_H_AP_LOOO    ASOH    TDD
    [Setup]    performance_test_setup.Test Case Setup For Performance Test    ENABLE_TTI_TRACE_QUICK=true

    Set Test Variable    ${QC_PATH}    testsuite/Ulm/ET/Performance_Test/resources/qc/CB013027-SR_ASOH.qc
    Set Test Variable    ${QC_TEST_NAME}
    ...                  [1]CB013027_C_TC06_Benchmark_the_number_of_PDSCH_and_PUSCH_UEs_per_slot_on_half_ASOH_with_3_FR1_TDD_eCPRI_cells

    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=3
    ...                           ue_per_cell=20
    ...                           ul_datarate=11000
    ...                           dl_datarate=72000
    ...                                  rate=kbps
    ...                         trf_direction=both
    ...                             ue_nr_cap=UE_CAP
    ...                             tolerance=0.3
    ...                                   lua=sansa_tdd_3cell.lua
    ...                       entry_auto_args=true
    ...                                 entry=performance_common_seq_active_cells_lua_tdd
    performance_keywords.Run Common Test    &{tc}
    performance_ttitrace.Check TTI Trace Total Number of Sched UEs Per L1Pool  count=40
    performance_ttitrace.Check TTI Trace Total Number of Sched UEs Per L1Pool for DL  count=40
