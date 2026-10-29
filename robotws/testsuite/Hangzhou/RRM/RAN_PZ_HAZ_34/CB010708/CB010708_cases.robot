#*** Settings ***
#Documentation    Author: xiaoxia.hao@nokia-sbell.com
#Suite Setup    10708_Suite_SetUp
#Suite Teardown    10708_Suite_Teardown
#Test Teardown    10708_Case_Teardown
#Force Tags    PY36
#Resource     Resources/CB010708_case_steps.robot
#
#
#*** Test Cases ***
#[1]CB010708-SR-A_018_Rank_switch_with_SRS-based_Beamforming
#    [Tags]    CRT_TRUNK    11160ms
#    [Setup]    10708_Case_SetUp
#    ...                            ParamterToModify=${PARAMS_TO_MODIFY_Channels_And_prachConfigurationIndex_For_2T8R_1070}
#    ...                            ListParamterToModify=${LIST_PARAMS_TO_MODIFY_For_2T8R_AND_1070}
#    ...                            ListToAdd=${LIST_TO_ADD_SYNC_SOURCE_FRAME_1070}
#    ...                            ParameterToDelete=${PARAMS_TO_DELETE_TOPP_PARAMS_AND_11026}
#    CB010708-SR-A_018_Rank_switch_with_SRS-based_Beamforming
#    [Teardown]    10708_Case_Teardown
#
#[1]CB010708-SR-C_001_16RX_IRC_reception_for_2_PUSCH_Rank2_UEs
#    [Tags]    CRT_TRUNK    11160ms
#    [Setup]    10708_Case_SetUp    swconfig_flag=rdSuSinrFlag16RX
#    CB010708-SR-C_001_16RX_IRC_reception_for_2_PUSCH_Rank2_UEs
#    [Teardown]    10708_Case_Teardown    is_recover_swconfig=${True}
#
#[1]CB010708-SR-E_004_4_RANK1_UEs_paired
#    [Tags]    CRT_TRUNK    11160ms
#    [Setup]    10708_Case_SetUp    swconfig_flag=rdSuSinrFlag16RX
#    CB010708-SR-E_004_4_RANK1_UEs_paired
#    [Teardown]    10708_Case_Teardown    is_recover_swconfig=${True}
#
