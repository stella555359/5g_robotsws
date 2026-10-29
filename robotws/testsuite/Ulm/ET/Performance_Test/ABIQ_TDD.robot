*** Settings ***
Documentation
...  author:  Squad 69
...  contact: I_MN_RAN_SW_ULM_ET_AP_PET_GMS
...  Description:   Test Cases for TDD 1 Cell 100 UEs Performance Test

Resource   ./resources/performance_keywords.robot
Resource   ./resources/performance_test_setup.robot
Resource   ./resources/performance_ttitrace.robot


Suite Setup       performance_test_setup.Suite Setup For Performance Test
Suite Teardown    performance_test_setup.Suite Teardown For Performance Test
Test Setup        performance_test_setup.Test Case Setup For Performance Test
Test Teardown     performance_test_setup.Test Case Teardown For Performance Test


*** Test Cases ***
CB013027-D_TC03_Benchmark_UEs_3Cells_Half_ABIQ_equal_load
    [Documentation]    Test Case 1: CB013027-D#3 Benchmark the number of PDSCH and PUSCH UEs per slot
    ...                on half ASOH with 4 FR1 TDD eCPRI cells
    [Tags]    CLOUD_5G_I_MP_AP_LOOO    ABIP    TDD
    [Setup]    performance_test_setup.Test Case Setup For Performance Test    SCF_ENABLE_BEAMFORMING=false
    ...                                                SCF_CONFIGURE_SRS=false
    ...                                                ENABLE_SRS_INFO=false
    ...                                                SCF_SET_VAR_NRCELL_actUlSrsBm=false
    ...                                                SCF_SET_VAR_NRCELL_actDlSrsBm=false
    ...                                                ENABLE_TTI_TRACE_QUICK=true
    ...                                                ENABLE_LTEPAT=false

    Set Test Variable    ${QC_PATH}    testsuite/Ulm/ET/Performance_Test/resources/qc/CB013027-SR_ABIQ.qc
    Set Test Variable    ${QC_TEST_NAME}
    ...                  [1]CB013027_D_TC03_Benchmark_the_number_of_PDSCH_and_PUSCH_UEs_per_slot_on_half_ABIQ_with_3_FR1_TDD_eCPRI_cells

    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=3
    ...                           ue_per_cell=16
    ...                           ul_datarate=13750
    ...                           dl_datarate=95000
    ...                                  rate=kbps
    ...                         trf_direction=both
    ...                             ue_nr_cap=UE_CAP
    ...                             tolerance=0.2
    ...                                   lua=sansa_tdd_3cell.lua
    ...                       entry_auto_args=true
    ...                                 entry=performance_common_seq_active_cells_lua_tdd
    performance_keywords.Run Common Test    &{tc}
    performance_ttitrace.Check TTI Trace Total Number of Sched UEs Per L1Pool  count=30
    performance_ttitrace.Check TTI Trace Total Number of Sched UEs Per L1Pool for DL  count=30
