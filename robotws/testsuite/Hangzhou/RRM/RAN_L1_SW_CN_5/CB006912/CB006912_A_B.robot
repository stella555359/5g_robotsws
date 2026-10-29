*** Settings ***
Documentation
...    Author:  Sun, Ya
...    Contact: ya.1.sun@nokia-sbell.com
...    Feature: CB005973
...    Release: 23R1
Suite Setup       common_resource_suite.Common Suite Setup
Suite Teardown    common_resource_suite.Common Suite Teardown
Test Setup        common_resource_suite.Common Test Setup
Test Teardown     common_resource_suite.Common Test Teardown
Resource          ../resources/common_resources.robot
Force Tags    5G_RAN_FDD    CRT    SBTS00    QCD_MN_RAN    QCP_RAN_RF

*** Variables ***
@{ALLOWED_FAULT}    49    Cell blocked

${scfc_file_1}    CB006912_scf_OBSAI_12_plus_CPRI_12_cells.xml
${scfc_file_2}    CB006912_scf_OBSAI_12_plus_CPRI_9_cells.xml

${NR_Cell_ID_5}    180125701     #20M 2D2U Peak DL Tput 155.8 Mbps~152.986,UL 177.5 Mbps~82.295,80.204
${NR_Cell_ID_22}    180125718
${NR_Cell_ID_12}    180125708
${NR_Cell_ID_1}    180125697     #15M 4D2U           DL 220 Mbps~215,UL 126.8,66 Mbps~55M


*** Test Cases ***
CB006912_A_TC14_NR_FR1_FDD_CPRI_ABIN_support_for_up_to_12_CPRI_cells_with_20MHz_2T2R_L3call
    [Tags]    LOKI    CB006912    CB006912_A_US14    Trunk
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}CB006912${/}${scfc_file_1}
    log to console    [INFO]Multi cells lock ongoing
    Perform NR Cell block 1,11,12,13,3,31,32,33,4,41,42,43,51,52,53 via AdminCLI
    log to console    [INFO]Attch UE to AHLOA_1_RMOD_3_cell_5
    SMAwave L3 call    ${NR_Cell_ID_5}    70M    80M    10%    5G    71

CB006912_A_TC30_NR_FR1_FDD_OBSAI_ABIN_support_for_up_to_12_cells_with_10MHz_4T4R_L3call
    [Tags]    LOKI    CB006912    CB006912_US30    Trunk    QL3
    log to console    [INFO]Cell unlock and lock operation ongoing
    Perform NR Cell unblock 12 via AdminCLI
    Perform NR Cell block 5 via AdminCLI
    log to console    [INFO]Attch UE to FRHG_2_RMOD_2_cell_22
    SMAwave L3 call    ${NR_Cell_ID_12}    65M    35M    10%    5G    7

CB006912_B_TC14_NR_FR1_FDD_CPRI_ABIN_support_for_up_to_9_CPRI_cells_with_15MHz_4T4R_L3call
    [Tags]    LOKI    CB006912    CB006912_B_US14    Trunk    QL3
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}CB006912${/}${scfc_file_2}
    log to console    [INFO]Multi cells lock ongoing
    Perform NR Cell block 11,4,41,42,3,31,32,5,51,52 via AdminCLI
    log to console    [INFO]Attch UE to FRHG_1_RMOD_1_cell_1
    SMAwave L3 call    ${NR_Cell_ID_1}    105M    55M    10%    5G    7
