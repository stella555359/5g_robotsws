*** Settings ***
Documentation
...   maintainer: Tomasz Sobania
...   contact: tomasz.sobania@nokia.com
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/classical/CB006733/resources/test_specific_keywords.robot

Force Tags      CA_VRF_WRO2

Suite Setup    CB006733 Suite Setup
Suite Teardown    CB006733 Suite Teardown

*** Variables ***
${ABSTRACT_LIB_CONFIG}      /home/ute/testline_configuration/7_16_UTE5GCLOUDT192/ue_config.yaml
${CELL_190}                 GNB_1_CELL_190
${CELL_196}                 GNB_1_CELL_196
${CELL_193}                 GNB_1_CELL_193
${CELL_197}                 GNB_1_CELL_197
${CELL_999}                 GNB_1_CELL_999
${UE_ALIAS}                 UE_1
${CHECK_COUNTER}            ${TRUE}

*** Test Cases ***
[1]CB006733_B_B4_TC21 Activate A4 measurements for FR1 CA SCell Addition after inter-RAT HO with DRX
    [Setup]    B_B4_TC21 Setup
    CB006733_B_B4_TC21 Activate A4 measurements for FR1 CA SCell Addition after inter-RAT HO with DRX
    [Teardown]    B_B4_TC21 Teardown

[1]CB006733_B_B17_TC26 Activation of A1 for SCell Change upon A2 SCell Release of A4-based SCell
    [Setup]    B_17_TC26 Setup
    CB006733_B_B17_TC26 Activation of A1 for SCell Change upon A2 SCell Release of A4-based SCell
    [Teardown]    B17_TC26 Teardown

[1]CB006733_B_B19_TC29 All SCell Candidates are A4-based in target HO cell
    [Setup]    B_19_TC29 Setup
    CB006733_B_B19_TC29 All SCell Candidates are A4-based in target HO cell
    [Teardown]    B_19_TC29 Teardown

[1]CB006733_B_B13_TC34 CB008290 interaction - prefer SCell Candidate with better radio conditions during FR1 CA SCell
    [Setup]    TC34 Setup
    CB006733_B_B13_TC34 CB008290 interaction - prefer SCell Candidate with better radio conditions during FR1 CA SCell
    [Teardown]    TC34 Teardown

CB006733_B_B32_TC30 Activate A4 measurements for FR1 CA SCell Addition after intra-gNB intra-DU HO with MFBI
    [Setup]    B_32_TC30 Setup
    CB006733_B_B32_TC30 Activate A4 measurements for FR1 CA SCell Addition after intra-gNB intra-DU HO with MFBI
    [Teardown]    B_32_TC30 Teardown

[1]CB006733_A_B6_TC32 A4-based SCell Candidate PCI not included in A4 MR
    [Setup]    A_B6_TC32 Setup
    CB006733_A_B6_TC32 A4-based SCell Candidate PCI not included in A4 MR
    [Teardown]    A_B6_TC32 Teardown

[1]CB006733_B_B1_TC11 A4 measurements for FR1 CA SCell Addition are not configured after intra-gNB HO
    [Setup]    TC11 Setup
    CB006733_B_B1_TC11 A4 measurements for FR1 CA SCell Addition are not configured after intra-gNB HO
    [Teardown]    TC11 Teardown

[1]CB006733_A_B4_TC04 Deactivation of A4 measurements for SCell Addition after A4 supervision timer expiry
    [Setup]    A_B4_TC04 Setup
    CB006733_A_B4_TC04 Deactivation of A4 measurements for SCell Addition after A4 supervision timer expiry
    [Teardown]  A_B4_TC04 Teardown
