*** Settings ***
Documentation    Suite created for tests requiring two eNB - CBRS_3 testline.

Library         taf.sw.scout    WITH NAME   scout

Resource    ./../Resources/cbrs_common_keywords.robot

Resource    ./../Tests/CB007405/CBRS_CB007405_CNI-118593_FeVe_04_Cell_Based_CBRS_Mobility_auto-configuration.robot
Resource    ./../Tests/CB007405/CBRS_CB007405_CNI-118593_FeVe_08_eNB_Based_CBRS_Mobility_auto-configuration.robot
Resource    ./../Tests/CB007405/CBRS_CB007405_LTE4679-B_FeVe_05_Mobility_Auto_Configuration_Robustness_Test.robot

Suite Setup       Run Keywords    Suite Precondition    AND
...                               Suite Precondition For Second Enb    AND
...                               scout.Setup Scout    1_16_UTE4G3766    AND
...                               Set Software Version
Suite Teardown    Run Keywords    Suite Postcondition    AND
...                               Suite Postcondition For Second Enb

Force Tags    QCP_RAN_VRF    QCD_MN_RAN    4G_TDD    CRT


*** Test Cases ***

CBRS_CB007405_CNI-118593_FeVe_04_Cell_Based_CBRS_Mobility_auto-configuration
    [Timeout]     35min
    [Setup]       Run Keywords    Test Precondition    clean_bts=false    AND
    ...                           Test Precondition For Second Enb    clean_bts=false
    [Teardown]    Run Keywords    Test Postcondition    AND
    ...                           Test Postcondition For Second Enb
    [Tags]        CB007405    SBTS00
    CBRS_CB007405_CNI-118593_FeVe_04_Cell_Based_CBRS_Mobility_auto-configuration

CBRS_CB007405_CNI-118593_FeVe_08_eNB_Based_CBRS_Mobility_auto-configuration
    [Timeout]     35min
    [Setup]       Run Keywords    Test Precondition    clean_bts=true    AND
    ...                           Test Precondition For Second Enb    clean_bts=false
    [Teardown]    Run Keywords    Test Postcondition    AND
    ...                           Test Postcondition For Second Enb
    [Tags]        CB007405    SBTS00
    CBRS_CB007405_CNI-118593_FeVe_08_eNB_Based_CBRS_Mobility_auto-configuration

CBRS_CB007405_LTE4679-B_FeVe_05_Mobility_Auto_Configuration_Robustness_Test
    [Timeout]     40min
    [Setup]       Run Keywords    Test Precondition    clean_bts=false     AND
    ...                           Test Precondition For Second Enb     clean_bts=false     #change from true 17/07/2023
    [Teardown]    Run Keywords    Test Postcondition    AND
    ...                           Test Postcondition For Second Enb
    [Tags]        CB007405    SBTS24R1    SBTS23R4    SBTS00
    CBRS_CB007405_LTE4679-B_FeVe_05_Mobility_Auto_Configuration_Robustness_Test
