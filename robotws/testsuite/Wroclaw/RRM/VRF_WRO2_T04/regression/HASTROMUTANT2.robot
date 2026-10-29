*** Settings ***
Documentation
...   author: Pawel Zabawczuk
...   contact: pawel.k.zabawczuk@nokia.com
...   Test cases execute on T-Mobile US #133 setup


Resource        ./regression_keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB011081/CB011081_C.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB009854/CB009854_X_05.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB005934/CB005934_B.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB006733/CB006733_C.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB009103/CB009103_Inter_gNB_DL_CA.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB009010/CB009010_ANR_UE_based_for_RAN_sharing_configuration.robot
Library         testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils    WITH NAME    AdminUtils
Variables       testsuite/Wroclaw/RRM/VRF_WRO2_T04/regression/global_variables.py


Suite Setup    Run Keywords
...                 Initialise Attenuator
...                 Set Sector for Testing


Test Setup      Run Keywords
...                 Start Collecting Syslog
...                 AdminUtils.wait_for_all_cells_on_air_state

Test Teardown   Run Keywords
...                 Clear Cache
...                 Collect and Verify Syslog
...                 Make Snapshot In Case Of Error
...                 Add Scout Data Info To Testcase

Test Timeout    120 minutes


*** Test Cases ***
CB011081_C_IWK4_FDD+TDD_FR1_DL_6CC_CA_and_F+F_UL_2CC_CA
    [Tags]    CB011081
    CB011081_C_IWK4_FDD_TDD_FR1_DL_6CC_CA_and_F_F_UL_2CC_CA


CB009854-X_05_Measurement_gaps_and_inter_freq_HO_for_5CC_UE
    [Tags]    CB009854
    CB009854_X_05_Measurement_gaps_and_inter_freq_HO_for_5CC_UE


CB005934_B_004_SCell_swap_4FDD_limit_on_SCell_swap_targets
    [Tags]    CB005934
    CB005934_B_004_SCell_swap_4FDD_limit_on_SCell_swap_targets


TC12_CB006733_9059intActA4measCASCellAdditionDuringICS
    [Tags]    CB006733
    TC12_CB006733_9059intActA4measCASCellAdditionDuringICS


CB009103_Mixed_A1_and_A4_Based_SCell_addition_across_2_gNBs
    [Tags]    CB009103   CB009103_ABC
    CB009103_Mixed_A1_and_A4_Based_SCell_addition_across_2_gNBs


CB009103_Successful_transition_from_RRC_CONNECTED_to_RRC_INACTIVE_state
    [Tags]    CB009103   CB009103_DG
    CB009103_Successful_transition_from_RRC_CONNECTED_to_RRC_INACTIVE_state


CB009103_Succesful_A2_based_PCell_switch_to_intra_SCell_when_also_ext_cells_are_present
    [Tags]    CB009103   CB009103_H
    CB009103_Succesful_A2_based_PCell_switch_to_intra_SCell_when_also_ext_cells_are_present


CB009010_A_Handover_restriction_on_the_Target_for_UEs_using_PLMN_that_is_reserved_on_the_Target_cell_NRPLMNSET_SA
    [Tags]    CB009010
    CB009010_A__Handover_restriction_on_the_Target_for_UEs_using_PLMN_that_is_reserved_on_the_Target_cell_NRPLMNSET_SA
