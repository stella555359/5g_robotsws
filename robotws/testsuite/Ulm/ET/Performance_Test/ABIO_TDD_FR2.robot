
*** Settings ***

Documentation
...  author:  Squad 69
...  contact: I_MN_RAN_SW_ULM_ET_AP_PET_GMS
...  Description:   Test Cases for TDD 1 Cell 100 UEs Performance Test

Resource   ./resources/performance_keywords.robot
Resource   ./resources/performance_test_setup.robot
Resource   ../resources/SQD60/sqd60_resourceUsage.robot


Suite Setup       performance_test_setup.Suite Setup For Performance Test
Suite Teardown    performance_test_setup.Suite Teardown For Performance Test
Test Setup        performance_test_setup.Test Case Setup For Performance Test
Test Teardown     performance_test_setup.Test Case Teardown For Performance Test


*** Test Cases ***
TDD_FR2_2S_8CC_53UEsPerSector
    [Documentation]    TDD_FR2_CA_16DL8UL_3S_8CC_SA_159UE_Peak_DL_5184Mbps_traffic_MUE
    [Setup]    performance_test_setup.Test Case Setup For Performance Test
    ...                   ASSERT_ONLY_SIB_ON_ACTIVE_CELLS=true
    performance_egate.Copy Specific Egate Scripts To Wts Folder    TDD_FR2_2S_8CC_53UEsPerSector

    Set Test Variable   ${QC_TEST_NAME}   [1]L2PS_performance_indicator_check_tdd_FR2_8CC_53Ues_Ul_Dl
    Set Test Variable    ${QC_PATH}       testsuite/Ulm/ET/Performance_Test/resources/qc/ABIO_performance.qc

    performance_keywords.Run Common Test    start_cell=1
    ...                              end_cell=16
    ...                      num_cells_online=16
    ...                           ue_per_cell=53
    ...                           active_cells=1,9
    ...                           ul_datarate=10789
    ...                           dl_datarate=32603
    ...                                  rate=kbps
    ...                         trf_direction=both
    ...                          trf_protocol=udp
    ...                             ue_nr_cap=UL_CA_TDD_SA_8CC
    ...                             tolerance=0.2
    ...                                   lua=sansa.lua
    ...                   configuration_entry=run_configuration(8600)
    ...                       entry_auto_args=false
    ...                       custom_lua_file=commands.lua
    ...                                 entry=TDD_FR2_SA_3S_8CC_MUE_DL_peak_TP_START_TC1    # seq_start rate=1 id=49,57
                                                                                            # max_active_ues=53

TDD_FR2_1S_8CC_106UEsPerSector
    [Documentation]    TDD_FR2_10570_#4: DL peak Throughput per 5G cell (UL traffic to be added on top)
    ...                Config Block: TDD FR2 SA,1S-8CC, prachConfigurationIndex=121 (CA Method: Buffer Based)
    [Setup]    performance_test_setup.Test Case Setup For Performance Test
    ...                   ASSERT_ONLY_SIB_ON_ACTIVE_CELLS=true
    performance_egate.Copy Specific Egate Scripts To Wts Folder    TDD_FR2_1S_8CC_106UEsPerSector

    Set Test Variable   ${QC_TEST_NAME}   [1]L2PS_performance_indicator_check_tdd_FR2_8CC_106Ues_Ul_Dl
    Set Test Variable    ${QC_PATH}       testsuite/Ulm/ET/Performance_Test/resources/qc/ABIO_performance.qc

    performance_keywords.Run Common Test    start_cell=1
    ...                              end_cell=8
    ...                      num_cells_online=8
    ...                           ue_per_cell=106
    ...                           active_cells=1
    ...                           ul_datarate=4000
    ...                           dl_datarate=16000
    ...                                  rate=kbps
    ...                         trf_direction=both
    ...                          trf_protocol=udp
    ...                             ue_nr_cap=UL_CA_TDD_SA_8CC
    ...                             tolerance=0.2
    ...                                   lua=sansa.lua
    ...                   configuration_entry=run_configuration(8600)
    ...                       entry_auto_args=false
    ...                       custom_lua_file=commands.lua
    ...                                 entry=TDD_FR2_SA_1S_8CC_MUE_DL_peak_TP_START_TC2    # seq_start rate=0.5 id=17
                                                                                            # max_active_ues=106
