*** Settings ***
Documentation
...  author:  Squad 69
...  contact: I_MN_RAN_SW_ULM_ET_AP_PET_GMS
...  Description:   Test Cases for TDD 1 Cell 100 UEs Performance Test

Resource   ./resources/performance_keywords.robot
Resource   ./resources/performance_test_setup.robot
Resource   ./resources/performance_verification.robot
Resource   ./resources/performance_ttitrace.robot

Force Tags    CLOUD_5G_I_MP_AP_LOOO

Suite Setup       performance_test_setup.Suite Setup For Performance Test
Suite Teardown    performance_test_setup.Suite Teardown For Performance Test
Test Setup        performance_test_setup.Test Case Setup For Performance Test
Test Teardown     performance_test_setup.Test Case Teardown For Performance Test


*** Test Cases ***
[1]CB012708_Stability_and_throughput_check_with_PGO_enabled_build_in_TDD_FR1_6cells_config
    [Documentation]
    ...    nonBF; ABIP_TDD_6Cells_72UEsPerCell_DLOnly;
    ...    Performance Test with Profile Guided Optimization for TDD ABIP configuration with 72 UEs attached to all Cells
    ...    running DL only traffic simultaneously
    [Tags]    TRAFFIC_DL
    Set Test Variable    ${QC_PATH}
    ...    testsuite/Ulm/ET/Performance_Test/resources/qc/CB012708-SR_Profile_guided_optimization_for_L2PS_Marlin.qc

    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=6
    ...                           ue_per_cell=72
    ...                           ul_datarate=0
    ...                           dl_datarate=18000
    ...                                  rate=kbps
    ...                         trf_direction=dl
    ...                             tolerance=0.35699588477366256    # Verify TP with Counters    dl   187500000    30000000
    ...                                   lua=sansa_tdd_6cell.lua
    ...                       entry_auto_args=true
    ...                                 entry=performance_common_seq_lua_tdd
    performance_keywords.Run Common Test    &{tc}

