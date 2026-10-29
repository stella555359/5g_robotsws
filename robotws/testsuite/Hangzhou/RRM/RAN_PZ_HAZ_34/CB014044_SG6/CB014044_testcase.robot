*** Settings ***
Documentation
...    author:  xiaoxia.hao@nokia-sbell.com
...    contact: xiaoxia.hao@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ4_06

Suite Setup    CB014044 Common Suite Setup
Suite Teardown    CB014044 Common Suite Teardown
Force Tags  CA_5G_RRM    PY36
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB014044_SG6/Resources/CB014044_case_steps.robot


*** Test Cases ***
[1]CB014044-C_1_Validation_of_actFdAlgoEnh_for_Non-GBR Bearers_DL_FDD
    [Tags]    CDRT_TRUNK
    [Documentation]    Author:xiaoxia.hao@nokia-sbell.com
    ...               cell_1: UE Id:201_220
    ...              {'ue_indx': 201,'ul_data_transfer': '175','dl_data_transfer': '175','dl_trf_id': '3','ul_trf_id': '1'},
    ...              {'ue_indx': 202,'ul_data_transfer': '10','dl_data_transfer': '10','dl_trf_id': '1','ul_trf_id': '1'},
    ...              {'ue_indx': 203,'ul_data_transfer': '0.056','dl_data_transfer': '0.056','dl_trf_id': '1','ul_trf_id': '1'}
    [Setup]    CB014044 Common Test Setup
    CB014044-C_1_Validation_of_actFdAlgoEnh_for_Non-GBR Bearers_DL_FDD
    [Teardown]    CB014044 Common Test Teardown

[1][1.0] CB008242-D_IWK1_ Automatic UAC load triggers interactions – automatic UAC upgrade by number of RRC connections
    [Tags]    CRT_TRUNK
    [Documentation]    Author:xiaoxia.hao@nokia-sbell.com
    ...               cell_1: UE Id:201_220
    ...              {'ue_indx': 201},
    ...              {'ue_indx': 202},
    [Setup]    CB014044 Common Test Setup    scf_file_name=CB008242_${stream}
    CB008242-D_IWK1_Automatic UAC load triggers interactions_automatic UAC upgrade by number of RRC connections
    [Teardown]    CB014044 Common Test Teardown

[1][1.0] CB008242-C_#B2 Downgrade automatic UAC triggered by PUCCH load
    [Tags]    CRT_TRUNK
    [Documentation]    Author:xiaoxia.hao@nokia-sbell.com
    ...               cell_1: UE Id:201_220
    ...              {'ue_indx': 201},
    ...              {'ue_indx': 202},
    [Setup]    CB014044 Common Test Setup    scf_file_name=CB008242_${stream}
    CB008242-C_#B2 Downgrade automatic UAC triggered by PUCCH load
    [Teardown]    CB014044 Common Test Teardown

[1][1.0] CNI-125269-ST-2 RNL Normal Release is used for the SgNB Release Request message in the UE triggered EN-DC takeback scenario-NR part
    [Tags]    CRT_TRUNK
    [Documentation]    Author:xiaoxia.hao@nokia-sbell.com
    ...                NSA config
    ...                cell_1: UE Id:51
    ...               {'ue_indx': 51},

    [Setup]    CB014044 Common Test Setup    scf_file_name=Configuration_NSA_${stream}    cfg_sim_file=wts_nsa.cfg    cellDep_Type=NSA
    Normal Release is used for the SgNB Release Request message in the UE triggered EN_DC takeback scenario_NR part
    [Teardown]    CB014044 Common Test Teardown

#debug_scout_case
#    [Tags]    CIT_TRUNK
#    [Documentation]    Author:xiaoxia.hao@nokia-sbell.com
#    [Setup]    CB014044 Common Test Setup
#    ${report_timestamps_source_build}    Test Procedures For KPI Report Case On AP
#    Generate And Record KPI Report To Compass And UTE On AP
#   ...     report_timestamps=${report_timestamps_source_build}
#    [Teardown]    CB014044 Common Test Teardown

[1]CB014044-SR-I_3_Verification_UL_FilterConst_FDD
    [Setup]    CB014044 Common Test Setup
    CB014044_Verification_FilterConst_From_Compass
    [Teardown]    CB014044 Common Test Teardown

[1]CB014044-SR-I_1_Accuracy_Improved_DL_Metric_Calculation_FR1_FDD
    [Setup]    CB014044 Common Test Setup
    CB014044_Verification_FilterConst_From_Compass    scripts_file=mutiuetraffic_DL_FDD.lua    test_comments=TL083_testing_FDD_DL
    ...                                               template_name=14044_KPI_DL
    [Teardown]    CB014044 Common Test Teardown

[1]CB014044-SR-I_4_Verification_of_impact_to_the_MU-MIMO_pairing_efficiency_UL
    [Setup]    CB014044 Common Test Setup
    CB014044_Verification_FilterConst_From_Compass    scripts_file=mutiuetraffic_UL_TDD.lua    test_comments=TL083_testing_TDD_UL
    ...                                               start_ue_id=101    end_ue_id=170
    [Teardown]    CB014044 Common Test Teardown

[1]CB014044-SR-I_2_Verification_of_impact_to_the_MU-MIMO_pairing_efficiency_DL
    [Setup]    CB014044 Common Test Setup
    CB014044_Verification_FilterConst_From_Compass    scripts_file=mutiuetraffic_DL_TDD.lua    test_comments=TL083_testing_TDD_DL
    ...                                               start_ue_id=101    end_ue_id=170    template_name=14044_KPI_DL
    [Teardown]    CB014044 Common Test Teardown