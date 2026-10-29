*** Settings ***
Documentation    CA Feature CB007949 Automation.
...              Auther: Stella.lin@nokia-sbell.com
Suite Setup    Run Keywords    7949_Common_Suite_Setup    AND
...                            Run Keyword And Ignore Error    Clear Temp File Of ELT For MTK
Test Teardown    7949_Common_Case_Teardown
Suite Teardown    robot_common_operations.Common Suite Teardown
Force Tags    5G_RRM    SG_06

Resource    Resources/CB007949_case_steps.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB007922/Resources/CB007922_case_steps.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008290/Resources/CB008290_case_steps.robot

*** Test Cases ***
[1][1.0] CB007922_B_10_SA_Intra_frequency_Inter_gNB_mobility_support_for_UE_which_has _TDD_FR1_CA_configured
    [Tags]    SA    CB007949    CDRT_22R4    CDRT_TRUNK    CDRT_23R1
    [Setup]    7922_Common_Case_Setup    handover_gnb_type=Inter
    CB007922_B_10_SA_Intra_frequency_Inter_gNB_mobility_support_for_UE_which_has_TDD_FR1_CA_configured
    [Teardown]    Run Keywords     7949_Common_Case_Teardown    AND    Capture Snapshot For Target Gnb

[1]CB007949_B_B4_01_Scell_Change_From_T_3F_To_3
    [Documentation]    actual testing: T_2F_To_3T
    [Tags]    CB007949    SA    CIT_TRUNK    CRT_22R4    CRT_23R1
    [Setup]    7949_Common_Case_Setup_B_B4_01
    CB007949_B_B4_01_Scell_Change_From_T_3F_To_3T

[1]CB007922_A_13_NSA_Inter_frequency_Intra_gNB_mobility_support_for_UE_which_has _TDD_FR1_CA_configured
    [Tags]    CB007922    NSA    CIT_TRUNK    CIT_23R1    CRT_22R4
    [Setup]     7922_Common_Case_Setup_A13
    CB007922_A_13_NSA_Inter_frequency_Intra_gNB_mobility_support_for_UE_which_has _TDD_FR1_CA_configured

[1]CB007922_A_24_NSA_ Single_UE_Peak_Throughput_100M_60M_1116_0ms_beamset_3_1
    [Documentation]    98% peak case, and run in 821 for trunk.
    [Tags]    CB007922    NSA     CRT_TRUNK
    [Setup]    7922_Common_Case_Setup_A24
    CB007922_A_24_NSA_ Single_UE_Peak_Throughput_100M_60M_1116_0ms_beamset_3_1
    [Teardown]    7949_D_Case_Teardown

[1]CB007949_B_B3_01_A1_Scell_Addition_A2_Scell_Release_TDD_FDD_different_a1ThresholdSCellAddSsb
    [Documentation]
    [Tags]    CB007949    SA    CIT_TRUNK    CIT_22R4    CIT_23R1
    [Setup]    7949_Common_Case_Setup_B_B3_01
    CB007949_B_B3_01_A1_Scell_Addition_A2_Scell_Release_TDD_FDD_different_a1ThresholdSCellAddSsb

[1]CB007949_B_B2_01_intra_gNB_Handover_To_Pcell
    [Documentation]
    [Tags]    CB007949    SA    CIT_22R4    CRT_TRUNK    CRT_23R1
    [Setup]    7949_Common_Case_Setup_B_B2_01
    CB007949_B_B2_01_intra_gNB_Handover_To_Pcell

[1]CB008290_A_14_A6_Measurement_Report_Handling_for_SCell_swap_of_T_T
    [Documentation]
    [Tags]    CB008290    SA    CIT_TRUNK    CIT_22R4    CIT_23R1
    [Setup]    8290_Common_Case_Setup    specific_ru_pa_port_on=${0,2}
    CB008290_A_14_A6_Measurement_Report_Handling_for_SCell_swap_of_T_T

[1]CB007949_D_Extend_02_TDD_3CC_CA_Interworking_with_VoNR
    [Documentation]
    [Tags]    CB007949    SA    CRT_TRUNK    CRT_23R1
    [Setup]    7949_Common_Case_Setup_D
    CB007949_D_Extend_02_TDD_3CC_CA_Interworking_with_VoNR
    [Teardown]    Run Keyword If    '${STREAM_VERSION}'=='master'    7949_D_Case_Teardown
    ...    ELSE    7949_Common_Case_Teardown

[1]CNI_71694_A_01_T_T_CA_aware_PSCell_selection_for_FR1_cells_during_EN_DC_setup
    [Tags]    CNI71694    NSA    CRT_TRUNK    CRT_23R1    CRT_22R4    CRT_22R3
    [Setup]    7922_Common_Case_Setup    specific_testcase_id=CNI_71694    is_all_pa_port_need_to_set=${True}    mode=NSA
    CNI_71694_A_01_T_T_CA_aware_PSCell_selection_for_FR1_cells_during_EN_DC_setup

[1]CB009915-B#IWK20_PRB_blanking_interworking_with_multiple_dedicated_BWPs_inter_gNB_CA
    CB009915-B#IWK20_PRB_blanking_interworking_with_multiple_dedicated_BWPs_inter_gNB_CA
    [Teardown]    9915_Common_Case_Teardown

