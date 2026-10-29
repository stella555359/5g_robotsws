# Copyright (c) 2020 Nokia. All rights reserved.

*** Settings ***
Resource    resources/Keywords/p1perf_keywords.robot
Documentation    IWF Test cases
Suite Setup       Common Optimized Perf Suite Setup
Suite Teardown    Common Perf Suite Teardown

*** Variables ***
${IWF_TDD_FR2}    True
${PREV_TEST_NAME}    None

*** Test Cases ***
TDD FR2 NSA SUE Attach and Traffic 8CC CA DL 4300Mbps 4CC UL 560Mbps 1127FF 64QAM 2X2 BF 100 Mhz
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    NSA    NSA_8CC_SUE
    [Documentation]    -NSA- Check if the NSA UE attach
    Initialize_Test_Data_And_Execute    ${NSA_8CC_SUE}   NSA_8CC_SUE
    [Teardown]    Perf Test Teardown Common    NSA_8CC_SUE

TDD FR2 NSA 106 UE RRC Connected 1127FF 64QAM 1CELL 2x2 BF 100Mhz
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    NSA_BCK    NSA_106_UE
    [Documentation]    -NSA- Check if the NSA UE attach
    Attach Multi UE for Multi Cell NSA 106 UE
    [Teardown]    Run Keywords
    ...    Deregister NSA MultiUE IWF    ${FR2_IWF_NSA_MUE_106UE_ULDL}    AND
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    IWF Status Check    NSA_106_UE    AND
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    gNB Snapshot Collection via adminAPI

TDD FR2 NSA 10 UE Attach and Traffic 8CC CA DL 4300Mbps 4CC UL 560Mbps 1127FF 64QAM 2X2 BF 100 Mhz
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    NSA    NSA_10_UE
    [Documentation]    -NSA- Check if the NSA UE attach, start NSA traffic and validate
    Initialize_Test_Data_And_Execute    ${NSA_10_UE}   NSA_10_UE
    [Teardown]    Run Keywords    Perf Test Teardown Common    NSA_10_UE
    ...    AND    IWF Test Case teardown    NSA_10_UE

TDD FR2 NSA SUE Attach and Traffic DL 550Mbps UL 110Mbps 1127FF 64QAM 1CELL 2x2 BF 100Mhz
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    NSA_BCK    NSA_SUE
    [Documentation]    -NSA- Check if the NSA UE attach
    Attach NSA SUE Attach and Traffic DL 550Mbps UL 110Mbps
    [Teardown]    Run Keywords
    ...    Deregister FR2 NSA SUE    AND
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    IWF Status Check    NSA_SUE    AND
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    gNB Snapshot Collection via adminAPI

TDD FR2 NSA SUE Attach and Traffic 4CC CA DL 2200Mbps 1127FF 64QAM 2X2 BF 100 Mhz
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    NSA_BCK    NSA_4CC_SUE
    [Documentation]    -NSA- Check if the NSA UE attach
    Attach NSA SUE Attach and Traffic 4CC CA DL 2200Mbps
    [Teardown]    Run Keywords
    ...    Deregister FR2 NSA SUE    AND
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    IWF Status Check    NSA_4CC_SUE    AND
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    gNB Snapshot Collection via adminAPI

TDD FR2 NSA Attach and Traffic 10UEs DL 550Mbps UL 110Mbps 1127FF 64QAM 4CELLS 2x2 nonBF 100Mhz
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    NSA    NSA_10UEs
    [Documentation]    -NSA- Check if the NSA UE attach
    Environment Setup for PET IWF    NSA_10UEs
    Initialize_Test_Data_And_Execute    ${NSA_10UEs}    NSA_10UEs
    [Teardown]    Perf Test Teardown Common    NSA_10UEs

TDD FR2 SA Attach and Traffic 106UEs 8CC CA DL 1060Mbps100Mhz nonIWF
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    NSA    nIWF_SA_106UEs    TC1_106SA_DL
    [Documentation]    -SA- Check if the SA MUEs attach and traffic work with Non IWF condition
    Environment Setup for PET IWF    TC1_106SA_DL    ${TC1_106SA_DL}
    Initialize_Test_Data_And_Execute    ${TC1_106SA_DL}     TC1_106SA_DL
    [Teardown]    Run Keywords    Deregister_Perf_IWF    AND
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    gNB Snapshot Collection via adminAPI

FDD DSS 40UE SA Peak DLUL nonCA 4CELL 20MHz 4x4 2cellperloki
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    SANSA    SANSA_40_UE    DSS_nCA_IWF    DSS_IWF_PERF
    [Documentation]    -SANSA- Check if the SANSA UE attach
    Attach Multi UE for Multi Cell SA 40 UE
    [Teardown]    Run Keywords
    ...    Deregister PET    AND
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    IWF Status Check    SANSA_40_UE    AND
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    gNB Snapshot Collection via adminAPI

FDD DSS 152UE SA RRC connected nonCA 4CELL 20MHz 4x4 2cellperloki
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    SANSA    SANSA_152_UE    DSS_nCA_IWF    DSS_IWF_PERF
    [Documentation]    -SANSA- Check if the SANSA UE attach
    Attach Multi UE for Multi Cell SA 152 UE
    [Teardown]    Run Keywords
    ...    Deregister PET    AND
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    IWF Status Check    SANSA_152_UE    AND
    ...    IWF Test Case teardown    NonCA_DSS_Logs    AND
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    gNB Snapshot Collection via adminAPI

836FF 4x4 MIMO 8CELL SA 1216UE RRC connected
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    SANSA_BCK    SA_1216UE_BCK    Non_DSS_IWF_BCK
    [Documentation]    -SA- Check if the SA UE attach
    Attach SA_SUE for 8CELL 1216UE
    [Teardown]    Run Keywords
    ...    Deregister PET    AND
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    IWF Status Check    SA_1216UE    AND
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    gNB Snapshot Collection via adminAPI

836FF 4x4 MIMO 8CELL SA SUE DL 3248Mbps and UL 1680Mbps 4cell per LOKI
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    SANSA    SA_SUE    Non_DSS_IWF
    [Documentation]    -SA- Check if the SA UE attach
    Initialize_Test_Data_And_Execute    ${SA_SUE_NON_DSS}   SA_SUE
    [Teardown]    Perf Test Teardown Common    SA_SUE

836FF 4x4 MIMO 8CELL 10SA and 10NSA DL 3248Mbps and UL 1680Mbps 4cell per LOKI
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    SANSA    SA_NSA_10UE    Non_DSS_IWF
    [Documentation]    -SA- Check if the SA UE attach
    Initialize_Test_Data_And_Execute    ${SANSA_10UE_NON_DSS}   SA_NSA_10UE
    [Teardown]    Run Keywords    Perf Test Teardown Common    SA_NSA_10UE    AND
    ...    IWF Test Case teardown    SA_NSA_10UE

836FF 4x4 MIMO 8CELL SA 20UE DL 3248Mbps and UL 1680Mbps
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    SANSA_BCK    SA_20UE_BCK    Non_DSS_IWF_BCK
    [Documentation]    -SA- Check if the SA UE attach
    Attach SA_20UE for 8CELL
    [Teardown]    Run Keywords
    ...    Deregister PET    AND
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    IWF Status Check    SA_20UE    AND
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    gNB Snapshot Collection via adminAPI

FDD Non DSS 4CC DL 1624Mbps CA SA 20UE Peak Throughput 4X4 Pcell
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    SANSA    SA_CA_20UE    Non_DSS_IWF
    [Documentation]    -SA- Check if the SA UE attach
    Environment Setup for PET IWF    SA_CA_20UE    ${20UE_CA_SA}
    Initialize_Test_Data_And_Execute    ${20UE_CA_SA}   SA_CA_20UE
    [Teardown]    Run Keywords
    ...    Perf Test Teardown Common    SA_CA_20UE    AND
    ...    IWF Test Case teardown    SA_CA_20UE

FDD Non DSS nonCA Mix Band SA 80UE Peak Throughput
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    SANSA    SA_CA_80UE    Non_DSS_IWF
    [Documentation]    -SA- Check if the SA UE attach
    Environment Setup for PET IWF    SA_CA_80UE   ${SA_CA_80UE_NON_DSS}
    Initialize_Test_Data_And_Execute    ${SA_CA_80UE_NON_DSS}     SA_CA_80UE
    [Teardown]    Run Keywords    Perf Test Teardown Common    SA_CA_80UE    AND
    ...    IWF Test Case teardown    SA_CA_80UE

FDD DSS 4CC DL CA SA 20UEs Peak Throughput 4X4 MIMO
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    SA    SA_2F_20UE    DSS_CA_IWF    DSS_IWF_PERF
    [Documentation]    -SANSA- Check if the SANSA UE attach
    Environment Setup for PET IWF    SA_2F_20UE
    Attach Multi_UE for IWF DL    ${SA_2F_20UE}    SA_2F_20UE
    Set Suite Variable    ${PREV_TEST_NAME}    ${TEST NAME}
    [Teardown]    Run Keywords
    ...    Deregister PET    AND
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    IWF Status Check    SA_2F_20UE    AND
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    gNB Snapshot Collection via adminAPI

FDD DSS 3CC DL CA SA 20UE Peak Throughput 4X4 MIMO
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    SA    SA_3F_20UE    DSS_CA_IWF    DSS_IWF_PERF
    [Documentation]    This test case depends on the previous test case for its configuration files.
    Run Keyword If    "${PREV_TEST_NAME}" == "None" or "${PREV_TEST_NAME}" != "FDD DSS 4CC DL CA SA 20UEs Peak Throughput 4X4 MIMO"
    ...    Environment Setup for PET IWF    SA_3F_20UE
    Attach Multi_UE for IWF DL    ${SA_3F_20UE}    SA_3F_20UE
    [Teardown]    Run Keywords
    ...    Deregister PET    AND
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    IWF Status Check    SA_3F_20UE    AND
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    gNB Snapshot Collection via adminAPI

####################ECPRI72E_IWF_Stream1_Cases###############

ECPRI7dot2E_8DL4UL_100MHz_SUE_SA_NSA_DL1600M_UL220M_TWO_CELL
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    SUE_SANSA_ECPRI72E    IWF_ECPRI72E    MP_AP_LO_Stream1
    [Documentation]    MP_AP_LO_Stream1_TC1 8DL4UL 100MHz TDD Tput 1 UE Per Cell SA Cell1 NSA Cell2 1600 DL 220Mbps Per Cell
    Initialize_Test_Data_And_Execute    ${SUE_SANSA_ECPRI72E}    SUE_SANSA_ECPRI72E
    [Teardown]    Run Keywords
    ...    Deregister_Perf_IWF    AND
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    IWF Status Check    SUE_SANSA_ECPRI72E    AND
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    gNB Snapshot Collection via adminAPI

ECPRI7dot2E_8DL4UL_100MHz_MUMIMO_40UE_SA_DL3200M_UL220M_Single_Cell
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    40UE_SA_ECPRI72E    IWF_ECPRI72E    MP_AP_LO_Stream1
    [Documentation]    MP_AP_LO_Stream1_TC2
    Initialize_Test_Data_And_Execute    ${40UE_SA_ECPRI72E}    40UE_SA_ECPRI72E
    [Teardown]    Run Keywords
    ...    Deregister_Perf_IWF    AND
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    IWF Status Check    40UE_SA_ECPRI72E    AND
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    gNB Snapshot Collection via adminAPI

ECPRI7dot2E_8DL4UL_100MHz_SA_NSA_RRC_CONNECTED_1000UE_TWO_CELL
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    2000UE_SANSA_ECPRI72E    IWF_ECPRI72E    MP_AP_LO_Stream1
    [Documentation]    MP_AP_LO_Stream1_TC3
    Initialize_Test_Data_And_Execute    ${2000UE_SANSA_ECPRI72E}    2000UE_SANSA_ECPRI72E
    [Teardown]    Run Keywords
    ...    Deregister_Perf_IWF    AND    IWF Test Case teardown    2000UE_SANSA_ECPRI72E    AND
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    IWF Status Check    2000UE_SANSA_ECPRI72E    AND
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    gNB Snapshot Collection via adminAPI

ECPRI7dot2E_4DL2UL_50MHz_SUE_SA_NSA_DL800M_FOUR_CELL
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    SUE_PER_CELL_SANSA_ECPRI72E    IWF_ECPRI72E    MP_AP_LO_Stream1
    [Documentation]    MP_AP_LO_Stream1_TC4
    Initialize_Test_Data_And_Execute    ${SUE_PER_CELL_SANSA_ECPRI72E}    SUE_PER_CELL_SANSA_ECPRI72E
    [Teardown]    Run Keywords
    ...    Deregister_Perf_IWF    AND
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    IWF Status Check    SUE_PER_CELL_SANSA_ECPRI72E
    ...    AND    Run Keyword If    '${TEST STATUS}' == 'FAIL'    gNB Snapshot Collection via adminAPI

####################ECPRI72E_IWF_Stream1_Cases_End###############

####################ECPRI72E_IWF_Stream2_Cases###############
ECPRI7dot2E_16DL4UL_100MHz_SUE_SA_DL_6000M
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    SUE_SA_ECPRI72E_DL    IWF_ECPRI72E_STREAM2    MPP_AP_LOO_Stream2
    [Documentation]    MPP_AP_LOO_Stream2_TC1 16DL4UL 100MHz TDD Tput 1 UE Per Cell SA Cell 6000Mbps DL
    Initialize_Test_Data_And_Execute    ${SUE_SA_ECPRI72E_DL}    SUE_SA_ECPRI72E_DL
    [Teardown]    Run Keywords
    ...    Deregister_Perf_IWF    AND
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    IWF Status Check    SUE_SA_ECPRI72E_DL    AND
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    gNB Snapshot Collection via adminAPI

ECPRI7dot2E_16DL4UL_100MHz_SUE_SA_UL_220M
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    SUE_SA_ECPRI72E_UL    IWF_ECPRI72E_STREAM2    MPP_AP_LOO_Stream2
    [Documentation]    MPP_AP_LOO_Stream2_TC2 16DL4UL 100MHz TDD Tput 1 UE Per Cell SA Cell 220Mbps UL
    Initialize_Test_Data_And_Execute    ${SUE_SA_ECPRI72E_UL}    SUE_SA_ECPRI72E_UL
    [Teardown]    Run Keywords
    ...    Deregister_Perf_IWF    AND
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    IWF Status Check    SUE_SA_ECPRI72E_UL    AND
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    gNB Snapshot Collection via adminAPI

ECPRI7dot2E_16DL4UL_100MHz_40UEs_SA_UL_2CC_440M
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    S2TC3_SA_MUE_UL_440Mbps    IWF_ECPRI72E_STREAM2    MPP_AP_LOO_Stream2
    [Documentation]    MPP_AP_LOO_Stream2_TC3 16DL4UL 100MHz TDD Tput 40 UEs With SA CA Cells 440Mbps UL
    Initialize_Test_Data_And_Execute    ${S2TC3_SA_MUE_UL_440Mbps}    S2TC3_SA_MUE_UL_440Mbps
    [Teardown]    Run Keywords
    ...    Deregister_Perf_IWF    AND
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    IWF Status Check    S2TC3_SA_MUE_UL_440Mbps    AND
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    gNB Snapshot Collection via adminAPI

ECPRI7dot2E_16DL4UL_100MHz_40UEs_SA_DL_6300M_6CC_CA
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    S2TC4_SA_MUE_DL_6300M    IWF_ECPRI72E_STREAM2    MPP_AP_LOO_Stream2
    [Documentation]    MPP_AP_LOO_Stream2_TC4 16DL4UL 100MHz TDD Tput 40 UEs With SA CA Cells 6300Mbps DL
    Initialize_Test_Data_And_Execute    ${S2TC4_SA_MUE_DL_6300M}    S2TC4_SA_MUE_DL_6300M
    [Teardown]    Run Keywords
    ...    Deregister_Perf_IWF    AND
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    IWF Status Check    S2TC4_SA_MUE_DL_6300M    AND
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    gNB Snapshot Collection via adminAPI
####################ECPRI72E_IWF_Stream1_Cases_End###############
