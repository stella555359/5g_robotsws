*** Settings ***
Documentation
...  author:  VERF_ULM
...  contact: I_MN_RAN_SW_ULM_ET_AP_PET_GMS
...  Description:   Test Cases ASOE BB Pooling concurrentmode enabled

Resource          ./resources/performance_keywords.robot
Resource          ./resources/performance_test_setup.robot
Resource          ./resources/performance_ttitrace.robot


Suite Setup       performance_test_setup.Suite Setup For Performance Test
Suite Teardown    performance_test_setup.Suite Teardown For Performance Test
Test Setup        performance_test_setup.Test Case Setup For Performance Test
Test Teardown     performance_test_setup.Test Case Teardown For Performance Test


*** Test Cases ***
ASOE_TDD_3Cells_32UEsPerCell_UL_CELL_1_to_3
    [Documentation]    3TDD Cells and 6 FDD cells ASOE concurrent mode
    [Tags]    UL    CLOUD_5G_O_E_AP_LOOO    ASOE    TDD
    [Setup]    performance_test_setup.Test Case Setup For Performance Test    ENABLE_TTI_TRACE_QUICK=true
    ...                                                ENABLE_ACT_BSR=auto
    ...                                                ENABLE_LTEPAT=true
    ...                                                ENABLE_MARVIN=true

    ${QC_TEST_NAME_tmp}             Catenate    SEPARATOR=    [1]CB014179-A#2_Maximum_number_of_
    ...                             PUSCH_UEs_per_slot_per_BB_pool_on_full_ASOE_with_3_FR1_TDD_
    ...                             eCPRI_cells_in_concurrent_mode
    Set Test Variable   ${QC_TEST_NAME}    ${QC_TEST_NAME_tmp}
    Set Test Variable    ${QC_PATH}    testsuite/Ulm/ET/Performance_Test/resources/qc/CB014179_A_TC01.qc

    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=9
    ...                              start_ue=1
    ...                           ue_per_cell=32    #Try this robot wil calculate end_ue
    ...                                end_ue=288
    ...                             num_cells=9
    ...                          active_cells=1,2,3
    ...                           cell_max_ue=16,16,8,0,0,0,0,0,0
    ...                             ue_nr_cap=UE_CAP_NonInact
    ...                           ul_datarate=16000
    ...                           dl_datarate=0
    ...                                  rate=kbps
    ...                         trf_direction=ul
    ...                            packetsize=1350
    ...                          trf_protocol=udp
    ...                              trf_type=internal
    ...                                pdu_id=1
    ...                                qfi_id=1
    ...                                trf_id=1
    ...                             tolerance=0.8828125
    ...                                   lua=sansa_tdd_3_cell_fdd_6_cell.lua
    ...                       entry_auto_args=true
    ...                                 entry=performance_common_seq_active_cells_lua_tdd
    ...                               timeout=2400
    ${args}       performance_keywords.Run Common Test    &{tc}
    performance_ttitrace.Check TTI Trace Total Number of Sched UEs Per L1Pool  inactive_cells=${args.inactive_cells}  count=40
    Verify CB014179-A-TC01 Counters
