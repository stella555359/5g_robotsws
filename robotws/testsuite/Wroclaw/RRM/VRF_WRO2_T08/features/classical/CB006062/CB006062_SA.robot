*** Settings ***
Documentation
...   author: Rafal Kaczmarski
...   contact: rafal.kaczmarski@nokia.com

Library     taf.ue
Library     ta_messaging
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/classical/CB006062/resources/test_specific_keywords_CB006062.robot
Resource    testsuite/Wroclaw/RRM/resources/preconditions.robot

Force Tags      CA_VRF_WRO2

Suite Setup      CB006062 Suite Setup
Suite Teardown   CB006062 Suite Teardown

*** Variables ***
${ABSTRACT_LIB_CONFIG}   /home/ute/testline_configuration/7_16_UTE5GCLOUDT304/hmd_conf.yaml
${CELL_ALIAS}            GNB_1_CELL_3

${HIGH_MCS_ATTENUATION_SA}                        14
${MIDDLE_MCS_ATTENUATION_SA}                      57
${MIDDLE_MCS_ATTENUATION_UNDER_THRESHOLD_SA}      57
${LOW_MCS_ATTENUATION_SA}                         66
${LOW_MCS_ATTENUATION_WITH_CSI_SA}                66

*** Test Cases ***
[1]6062-BD_SA_PUSCH data and DMRS FDM co-existence with DFT-s-OFDM for FDD FR1 - Tput UL DL check - 1 additional DMRS - short PUCCH - PTRS OFF
    [Setup]    Common CB006062 Test Setup   BD
    6062-BD_SA_PUSCH_Data_And_DMRS_FDM_Co-Existence_With_DFT-s-OFDM_For_FDD_FR1-Tput_UL_DL_Check-1_Additional_DMRS-PTRS_OFF
    [Teardown]    Teardown

[1]6062-BF_SA_PUSCH data and DMRS FDM co-existence with PUSCH 256QAM for FDD F1 - Tput UL DL check - PTRS OFF
    [Setup]    Common CB006062 Test Setup   BF
    6062-BF_SA_PUSCH_Data_And_DMRS_FDM_Co-Existence_With_PUSCH_256QAM_For_FDD_F1-Tput_UL_DL_Check-PTRS_OFF
    [Teardown]    Teardown

[1]6062-B_SA_Basic support of PUSCH data and DRMS FDM for FDD FR1 - Tput UL DL check
    [Setup]    Common CB006062 Test Setup   BB
    6062-B_SA-Basic_Support_Of_PUSCH_Data_And_DMRS_FDM_For_FDD_FR1-Tput_UL_DL_Check
    [Teardown]    Teardown

[1]6062-B_SA_ActivationDeactivation for PUSCH data and DRMS FDM
    [Setup]    Common CB006062 Test Setup   BB
    6062-B_SA_ActivationDeactivation_For_PUSCH_Data_And_DRMS_FDM
    [Teardown]    Teardown

[1]6062_BI_SA_PUSCH data and DMRS FDM co-existence with DFT-s-OFDM, PUSCH 256QAM and aperiodic CSI for FDD FR1 - PTRS off
    [Setup]    Common CB006062 Test Setup   BI_SA
    6062_BI_SA_PUSCH_Data_And_DMRS_FDM_Co-Existence_With_DFT-s-OFDM_PUSCH_256QAM_And_Aperiodic_CSI_For_FDD_FR1-Tput_UL_DL_Check_PTRS_OFF
    [Teardown]    Run Keywords  Teardown  AND  Correct Tc Name
