
*** Settings ***

Documentation
...  author:  VRF_ULM_T05_01_VRF_RRM
...  contact: I_MN_RAN_SW_ULM_ET_AP_PET_GMS
...  Description:   Test Cases for TDD 1 Cell 100 UEs Performance Test

Resource   ./resources/performance_keywords.robot
Resource   ./resources/performance_test_setup.robot
Resource   ../resources/SQD60/sqd60_resourceUsage.robot

Force Tags    CLOUD_5G_I_MP_AP_LOOO

Suite Setup       performance_test_setup.Suite Setup For Performance Test
Suite Teardown    performance_test_setup.Suite Teardown For Performance Test
Test Setup        performance_test_setup.Test Case Setup For Performance Test
Test Teardown     performance_test_setup.Test Case Teardown For Performance Test


*** Test Cases ***

TDD_FR2_4S_4CC_106UEs
    [Documentation]    Config Block: TDD FR2 SA,4S-4CC
    [Setup]    performance_test_setup.Test Case Setup For Performance Test
    ...                   ASSERT_ONLY_SIB_ON_ACTIVE_CELLS=true
    performance_egate.Copy Specific Egate Scripts To Wts Folder    TDD_FR2_4S_4CC_106UEs

    Set Test Variable   ${QC_TEST_NAME}   [1][1.0] L2PS_performance_indicator_check_tdd_FR2_4CC_106Ues_Ul_Dl
    Set Test Variable    ${QC_PATH}       testsuite/Ulm/ET/Performance_Test/resources/qc/ABIP_performance.qc

    performance_keywords.Run Common Test    start_cell=1
    ...                              end_cell=16
    ...                      num_cells_online=16
    ...                           ue_per_cell=106
    ...                           active_cells=1,5,9,13
    ...                           ul_datarate=2100
    ...                           dl_datarate=9962
    ...                                  rate=kbps
    ...                         trf_direction=both
    ...                          trf_protocol=udp
    ...                             ue_nr_cap=UL_CA_TDD_SA_8CC
    ...                             tolerance=0.2
    ...                                   lua=sansa.lua
    ...                   configuration_entry=run_configuration(8600)
    ...                       entry_auto_args=false
    ...                       custom_lua_file=commands.lua
    ...                                 entry=TDD_FR2_SA_4S_4CC_MUE_Max_RRC_DL_TP_START_TC1    # seq_start rate=0.5 id=17
                                                                                            # max_active_ues=424