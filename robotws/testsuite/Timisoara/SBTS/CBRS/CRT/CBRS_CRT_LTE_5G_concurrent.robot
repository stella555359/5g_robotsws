*** Settings ***
Documentation
...    Suite created for tests requiring double BTS (LTE-NR) setup with RF sharing. Suite recomended to be run on CBRS_9 testline.

Resource    ./../Resources/cbrs_common_keywords.robot
Resource    ./../Tests/CB007659/RF_Sharing_suite_setup.robot
Resource    ./../Tests/CB007659/CBRS_CB007659-A_FeVe_02_NR-LTE_carrier_chBw_reconfiguration_in_NR-LTE_RF_sharing_with_AZQC.robot
Resource    ./../Tests/CB007659/CBRS_CB007659-A_FeVe_07_Configuration_change_involving_supportedSpectrumV2_in_NR-LTE_RF_Sharing_site.robot
Resource    ./../Tests/CB007659/CBRS_CB007659-A_FeVe_09_Startup_Spectrum_selection_for_PAL_and_wINNFTSV_less_than_2_in_NR-LTE_RF_Sharing_site.robot
Resource    ./../Tests/CB007659/CBRS_CB007659-A_FeVe_11_Runtime_Spectrum_selection_for_GAA_and_wINNFTSV_less_than_2_in_NR-LTE_RF_Sharing_site.robot
Resource    ./../Tests/CB007659/CBRS_CB007659-A_FeVe_14_Background_Query_CBRS_spectrum_for_GAA_and_wINNFTSV_less_than_2_while_gNB_onAir.robot
Resource    ./../Tests/CB007659/CBRS_CB007659-A_FeVe_15_Cell_reassignment_after_query_CBRS_when_desiredChBw_missmatch_in_NR-LTE_RF_Sharing.robot
Resource    ./../Tests/CB007659/CBRS_CB007659-A_FeVe_16_Preparation_before_activating_cells_on_AZQC_upon_radio_discovery.robot

Suite Setup       Run Keywords
...                               Suite Precondition    AND
...                               Suite Precondition For Second Enb    AND
...                               Set Software Version
Suite Teardown    Run Keywords
...                              Suite Postcondition    AND
...                              Suite Postcondition For Second Enb

Force Tags    QCP_RAN_VRF    QCD_MN_RAN    4G_TDD    CRT


*** Test Cases ***

CBRS_CB007659-A_FeVe_02_NR-LTE_carrier_earfcn_chBw_pmax_reconfiguration_in_NR-LTE_RF_sharing_with_AZQC
    [Timeout]     15min
    [Setup]       Run Keywords    Test Precondition    clean_bts=false    AND
    ...                           Test Precondition For Second Enb    clean_bts=false
    [Teardown]    Run Keywords    Test Postcondition    AND
    ...                           Test Postcondition For Second Enb
    [Tags]        CB007659    SBTS00
    CBRS_CB007659-A_FeVe_02_NR-LTE_carrier_chBw_reconfiguration_in_NR-LTE_RF_sharing_with_AZQC


CBRS_CB007659-A_FeVe_07_Configuration_change_involving_supportedSpectrumV2_in_NR-LTE_RF_Sharing_site
    [Timeout]     15min
    [Setup]       Run Keywords    Test Precondition    clean_bts=false    AND
    ...                           Test Precondition For Second Enb    clean_bts=false
    [Teardown]    Run Keywords    Test Postcondition    AND
    ...                           Test Postcondition For Second Enb
    [Tags]        CB007659    SBTS00
    CBRS_CB007659-A_FeVe_07_Configuration_change_involving_supportedSpectrumV2_in_NR-LTE_RF_Sharing_site


CBRS_CB007659-A_FeVe_09_Startup_Spectrum_selection_for_PAL_and_wINNFTSV_less_than_2_in_NR-LTE_RF_Sharing_site
    [Timeout]     15min
    [Setup]       Run Keywords    Test Precondition    clean_bts=false    AND
    ...                           Test Precondition For Second Enb    clean_bts=false
    [Teardown]    Run Keywords    Test Postcondition    AND
    ...                           Test Postcondition For Second Enb
    [Tags]        CB007659    SBTS00
    CBRS_CB007659-A_FeVe_09_Startup_Spectrum_selection_for_PAL_and_wINNFTSV_less_than_2_in_NR-LTE_RF_Sharing_site


CBRS_CB007659-A_FeVe_11_Runtime_Spectrum_selection_for_GAA_and_wINNFTSV_less_than_2_in_NR-LTE_RF_Sharing_site
    [Timeout]     30min
    [Setup]       Run Keywords    Test Precondition    clean_bts=false    AND
    ...                           Test Precondition For Second Enb    clean_bts=false
    [Teardown]    Run Keywords    Test Postcondition    AND
    ...                           Test Postcondition For Second Enb
    [Tags]        CB007659    SBTS00
    CBRS_CB007659-A_FeVe_11_Runtime_Spectrum_selection_for_GAA_and_wINNFTSV_less_than_2_in_NR-LTE_RF_Sharing_site


CBRS_CB007659-A_FeVe_14_Background_Query_CBRS_spectrum_for_GAA_and_wINNFTSV_less_than_2_in_NR-LTE_RF_Sharing_site
    [Timeout]     30min
    [Setup]       Run Keywords    Test Precondition    clean_bts=false    AND
    ...                           Test Precondition For Second Enb    clean_bts=false
    [Teardown]    Run Keywords    Test Postcondition    AND
    ...                           Test Postcondition For Second Enb
    [Tags]        CB007659    SBTS00
    CBRS_CB007659-A_FeVe_14_Background_Query_CBRS_spectrum_for_GAA_and_wINNFTSV_less_than_2_while_gNB_onAir


CBRS_CB007659-A_FeVe_15_Cell_reassignment_after_query_CBRS_when_desiredChBw_missmatch_in_NR-LTE_RF_Sharing
    [Timeout]     25min
    [Setup]       Run Keywords    Test Precondition    clean_bts=false    AND
    ...                           Test Precondition For Second Enb    clean_bts=false
    [Teardown]    Run Keywords    Test Postcondition    AND
    ...                           Test Postcondition For Second Enb
    [Tags]        CB007659    SBTS00
    CBRS_CB007659-A_FeVe_15_Cell_reassignment_after_query_CBRS_when_desiredChBw_missmatch_in_NR-LTE_RF_Sharing


CBRS_CB007659-A_FeVe_16_Preparation_before_activating_cells_on_AZQC_upon_radio_discovery
    [Timeout]     15min
    [Setup]       Run Keywords    Test Precondition    clean_bts=false    AND
    ...                           Test Precondition For Second Enb    clean_bts=false
    [Teardown]    Run Keywords    Test Postcondition    AND
    ...                           Test Postcondition For Second Enb
    [Tags]        CB007659    SBTS00
    CBRS_CB007659-A_FeVe_16_Preparation_before_activating_cells_on_AZQC_upon_radio_discovery
