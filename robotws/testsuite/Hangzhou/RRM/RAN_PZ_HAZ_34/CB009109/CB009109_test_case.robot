*** Settings ***
Documentation    Auther:xiaoxia.hao@nokia-sbell.com
Suite Setup        8015 Suite Setup
Suite Teardown    robot_common_operations.Common Suite Teardown
Resource    Resources/CB009109_Case_Step.robot

*** Variables ***
${tdd_pcell_index}    3

*** Test Cases ***
[1]CB009109_A_09_Modify_default_assiciated_DRXDN_followed_by_SA_call_with_nonGBR_DRX_Bearer
    [Timeout]    120m
    [Setup]  Case SetUp For DSS On UTE CLoud    scf_file_name=Configuration_CB009109_${stream}
    CB009109_A_09_Modify_default_assiciated_DRXDN_followed_by_SA_call_with_nonGBR_DRX_Bearer    pcell_index=${tdd_pcell_index}
    [Teardown]   Case TearDown For CB007737

[1]CB009109_B_02_SA_non-VONR_call_setup_when_feature_deactivate_then_activate_feature_and_setup_VoNR_Bearer
    [Timeout]    120m
    [Setup]  Case SetUp For DSS On UTE CLoud    scf_file_name=Configuration_CB009109_B_${stream}
    CB009109_B_02_SA_non-VONR_call_setup_when_feature_deactivate_then_activate_feature_and_setup_VoNR_Bearer    pcell_index=${tdd_pcell_index}
    [Teardown]   8015 Case TearDown

[1]CB009109_B_05_SA_VONR_call_setup_with_VoNR_Bearer_5QI-1_with_cell_level_associated_lower_priority_DRX
    [Tags]    Classical    CRT_25R1
    [Timeout]    120m
    [Setup]  Case SetUp For DSS On UTE CLoud    scf_file_name=Configuration_CB009109_B_5_${stream}
    CB009109_B_05_SA_VONR_call_setup_with_VoNR_Bearer_5QI-1_with_cell_level_associated_lower_priority_DRX    pcell_index=${tdd_pcell_index}
    [Teardown]   8015 Case TearDown

[1]CB009109_B_10_SA_inter_frequency_ANR_HO_with_parameter_fallback
    [Tags]    Classical    CIT_24R3
    [Timeout]    120m
    [Setup]  Case SetUp For DSS On UTE CLoud    scf_file_name=Configuration_CB009109_B_10_${stream}
    ${restore_pa_value}    Set Variable If    '${stream}'=='SBTS00'    20    0
    CB009109_B_10_SA_inter_frequency_ANR_HO_with_parameter_fallback    pcell_index=${tdd_pcell_index}
    [Teardown]   Run keywords     gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    value=${restore_pa_value}   RU_id=3
    ...     AND    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    value=${restore_pa_value}   RU_id=4
    ...     AND    8015 Case TearDown



