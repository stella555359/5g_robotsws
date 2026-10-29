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

${HIGH_MCS_ATTENUATION_NSA}                       14
${MIDDLE_MCS_ATTENUATION_NSA}                     45
${MIDDLE_MCS_ATTENUATION_UNDER_THRESHOLD_NSA}     45
${MIDDLE_MCS_ATTENUATION_NSA_BI}                  48
${MIDDLE_MCS_ATTENUATION_UNDER_THRESHOLD_NSA_BI}  52
${LOW_MCS_ATTENUATION_NSA}                        60
${LOW_MCS_ATTENUATION_WITH_CSI_NSA}               60
${LOW_MCS_ATTENUATION_NSA-BI}                     65
${LOW_MCS_ATTENUATION_WITH_CSI_NSA-BI}            65

*** Test Cases ***
[1]6062-B_NSA_ActivationDeactivation for PUSCH data and DRMS FDM
    [Setup]    Common CB006062 Test Setup   BB
    6062-B_NSA_ActivationDeactivation_For_PUSCH_Data_And_DRMS_FDM
    [Teardown]    Teardown

[1]6062-B_NSA_Basic support of PUSCH data and DRMS FDM for FDD FR1 - Tput UL DL check
    [Setup]   Common CB006062 Test Setup    BB
    6062-B_NSA_Basic_Support_Of_PUSCH_Data_And_DRMS_FDM_For_FDD_FR1-Tput_UL_DL_Check
    [Teardown]    Teardown

[1]6062_BI_NSA_PUSCH data and DMRS FDM co-existence with DFT-s-OFDM, PUSCH 256QAM and aperiodic CSI for FDD FR1
    [Setup]    Common CB006062 Test Setup   BI_NSA_1
    6062_BI_NSA_PUSCH_Data_And_DMRS_FDM_Co-Existence_With_DFT-s-OFDM_PUSCH_256QAM_And_Aperiodic_CSI_For_FDD_FR1
    [Teardown]    Teardown

[1]6062_BI_NSA_PUSCH data and DMRS FDM co-existence with DFT-s-OFDM, PUSCH 256QAM and aperiodic CSI for FDD FR1 - PTRS OFF
    [Setup]    Common CB006062 Test Setup   BI_NSA_2
    6062_BI_NSA_PUSCH_Data_And_DMRS_FDM_Co-Existence_With_DFT-s-OFDM_PUSCH_256QAM_And_Aperiodic_CSI_For_FDD_FR1_PTRS_OFF
    [Teardown]    Teardown

6062-BH_NSA_PUSCH data and DMRS FDM co-existence with aperiodic CSI for FDD FR1 - Tput UL DL check - short PUCCH
    [Setup]    Common CB006062 Test Setup   BH
    6062-BH_NSA_PUSCH_Data_And_DMRS_FDM_Co-Existence_With_Aperiodic_CSI_For_FDD_FR1-Tput_UL_DL_Check
    [Teardown]    Teardown
