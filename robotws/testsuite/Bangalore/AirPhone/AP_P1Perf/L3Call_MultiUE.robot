# Copyright (c) 2020 Nokia. All rights reserved.

*** Settings ***
Resource    resources/Keywords/p1perf_keywords.robot
Documentation    Perf TC cases FR1
Suite Setup       Common Optimized Perf Suite Setup
Suite Teardown    Common Perf Suite Teardown

*** Variables ***
${AP_P1Perf}    True

*** Test Cases ***
Verify Ng Link Status
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup
    ...    SA_NSA_PAR_TC1    20UEDL    NON_IWF    SA304UE    SA_NSA_PAR_TC2    SA_MUE    SA500UE
    ...    SA_20_UE_2CC    NSA_MUE    SANSA_72_UE    IWF
    [Documentation]    -SA- Check if "NG link is UP" message can be found in egate console and egate_console.log
    NG Link Should be UP

Verify Address Distribution
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup
    ...    SA_NSA_PAR_TC1    20UEDL    NON_IWF    SA304UE    SA_NSA_PAR_TC2    SA_MUE    SA500UE
    ...    SA_20_UE_2CC    NSA_MUE    SANSA_72_UE    IWF
    [Documentation]    -SANSA- Check if "Address Distribution is complete" message can be found in APL3.log
    Address Distribution should be Successful

UE SIB Decoding
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup
    ...    SA_NSA_PAR_TC1    20UEDL    NON_IWF    SA304UE    SA_NSA_PAR_TC2    SA_MUE    SA500UE
    ...    SA_20_UE_2CC    NSA_MUE    SANSA_72_UE    IWF
    [Documentation]    -SA- Check if "SystemInformationBlockType1" message can be found in egate console and egate_console.log
    UE SIB Decoding should be Successful
   sleep    5s

X2 Connection
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup
    ...    SA_NSA_PAR_TC1    20UEDL    NON_IWF    SA304UE    SA_NSA_PAR_TC2    SA_MUE    SA500UE
    ...    SA_20_UE_2CC    NSA_MUE    SANSA_72_UE    IWF
    [Documentation]    -NSA- check if "X2AP Link with GNB" msg found in egate console
    X2AP Link Should be UP
    sleep    5s

Verify Cell Setup for AP
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup
    ...    SA_NSA_PAR_TC1    20UEDL    NON_IWF    SA304UE    SA_NSA_PAR_TC2    SA_MUE    SA500UE
    ...    SA_20_UE_2CC    NSA_MUE    SANSA_72_UE    IWF
    [Documentation]    -SANSA- Check if "Cell Setup completed" message can be found in APL3.log
    Run Keyword If    '${IWF_ENABLED}' != 'True'    AP Cell Setup should be Successful
    ...    ELSE    AP Cell Setup should be Successful for MIMO

TDD FR1 SA SUE Register and Traffic DL 1600Mbps & UL 200Mbps 1208FF 256QAM 1CELL 4*4 100Mhz
    [Documentation]    -SA- Check if the SA UE Registers, start SA traffic and validate
    ...    Depreacated Perf Test Scenario
    [Setup]    Requires Tc    Verify Cell Setup for AP
    Register Single UE for Single Cell
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    gNB Snapshot Collection via adminAPI

TDD FR1 SA SUE DL 1600Mbps & UL 200Mbps 1208FF 256QAM 1CELL 4*4 100Mhz Deregister
    [Setup]    Requires Tc    TDD FR1 SA SUE DL 1600Mbps & UL 200Mbps 1208FF 256QAM 1CELL 4*4 100Mhz
    [Documentation]    -SA- Check if the Single SA UE Deregisters
    ...    Depreacated Perf Test Scenario
    Deregister Single UE Single Cell
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    gNB Snapshot Collection via adminAPI

TDD FR1 NSA SUE Attach and Traffic DL 1600Mbps & UL 200Mbps 1208FF 256QAM 1CELL 4*4 100Mhz
    [Documentation]    -NSA- Check if the NSA UE attach, start NSA traffic and validate
    ...    Depreacated Perf Test Scenario
    [Setup]    Requires Tc    Verify Cell Setup for AP
    NSA Attach for Single UE Single Cell
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    gNB Snapshot Collection via adminAPI

TDD FR1 NSA SUE DL 1600Mbps & UL 200Mbps 1208FF 256QAM 1CELL 4*4 100Mhz Detach
    [Documentation]    -NSA- Check if the NSA UE Detach
    ...    Depreacated Perf Test Scenario
    [Setup]    Requires Tc    TDD FR1 NSA SUE DL 1600Mbps & UL 200Mbps 1208FF 256QAM 1CELL 4*4 100Mhz Detach
    Detach NSA Single UE
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    gNB Snapshot Collection via adminAPI

TDD FR1 SA SUE Register and Traffic DL 1600Mbps & UL 200Mbps 1208FF 256QAM 2CELL 4*4 nonBF 100Mhz
    [Tags]    FULL_RUN    Register    SA    [flow]L3 Call    SA_MUE    IWF_INTERNAL    NON_IWF    IWF
    [Documentation]    -SA- Check if the SA UE Registers, start SA traffic and validate
    [Setup]    Requires Tc    Verify Cell Setup for AP
    Run Keyword If    '${IWF_ENABLED}' != 'True'    Register Multi UE for Multi Cell
    ...    ELSE    SA MUE Register for 2 cell 2 UEs
    Run Keyword If    '${IWF_ENABLED}' == 'True'    Deregister UEs
    [Teardown]    Run Keywords
    ...    Run Keyword If    '${IWF_ENABLED}' == 'True' and '${TEST STATUS}' == 'FAIL'    IWF Status Check    SA_MUE
    ...    AND    Run Keyword If    '${TEST STATUS}' == 'FAIL'    gNB Snapshot Collection via adminAPI

TDD FR1 SA SUE DL 1600Mbps & UL 200Mbps 1208FF 256QAM 2CELL 4*4 100Mhz nonBF Deregister
    [Tags]    FULL_RUN    Deregister    SA    [flow]L3 Call    SA_MUE    NON_IWF
    [Documentation]    -SA- Check if the Single SA UE Deregisters
    Run Keyword If    '${IWF_ENABLED}' != 'True'    Deregister for Multi UE for Multi Cell
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    gNB Snapshot Collection via adminAPI

TDD FR1 NSA SUE Attach and Traffic DL 1600Mbps & UL 200Mbps 1208FF 256QAM 2CELL 4*4 nonBF 100Mhz
    [Tags]    FULL_RUN    Attach    NSA    [flow]L3 Call    NSA_MUE    IWF_INTERNAL    NON_IWF    IWF
    [Documentation]    -SA- Check if the NSA UE attaches, start NSA traffic and validate
    [Setup]    Requires Tc    Verify Cell Setup for AP
    Run Keyword If    '${IWF_ENABLED}' != 'True'    Attach Multi UE for Multi Cell
    ...    ELSE    Attach 2 UE for 2 Cell
    [Teardown]    Run Keywords
    ...    Run Keyword If    '${IWF_ENABLED}' == 'True' and '${TEST STATUS}' == 'FAIL'    IWF Status Check    NSA_MUE
    ...    AND    Run Keyword If    '${TEST STATUS}' == 'FAIL'    gNB Snapshot Collection via adminAPI

TDD FR1 NSA SUE DL 1600Mbps & UL 200Mbps 1208FF 256QAM 2CELL 4*4 nonBF 100Mhz Detach
    [Tags]    FULL_RUN    Detach    NSA    [flow]L3 Call    NSA_MUE    IWF_INTERNAL    NON_IWF    IWF
    [Documentation]    -SA- Check if the Single NSA UE Detaches
    Run Keyword If    '${IWF_ENABLED}' != 'True'    Detach for Multi UE for Multi Cell
    ...    ELSE    Detach NSA MUE Multicell
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    gNB Snapshot Collection via adminAPI

TDD FR1 10 SA & 10 NSA Register Attach and Traffic DL 600Mbps & UL 100Mbps 1208FF 256QAM 2CELL 4*4 nonBF 100Mhz
    [Tags]    FULL_RUN     Register    [flow]L3 Call    SA_NSA_PAR_TC1    NON_IWF
    [Documentation]    -SA- Check if the SA UE registers, start Traffic along with validation
    [Setup]    Requires Tc    Verify Cell Setup for AP
    SA NSA Register Attach and Traffic Validation
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    gNB Snapshot Collection via adminAPI

TDD FR1 10 SA & 10 NSA DL 600Mbps & UL 100Mbps 1208FF 256QAM 2CELL 4*4 nonBF 100Mhz Deregister and Detach
    [Tags]    FULL_RUN     Register    [flow]L3 Call    SA_NSA_PAR_TC1    NON_IWF
    [Documentation]    -SA- Check if the SA UE registers, start Traffic along with validation
    SA Deregister and NSA UE Detach
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    gNB Snapshot Collection via adminAPI

TDD FR1 5 SA & 5 NSA Register Attach and Traffic DL 600Mbps & UL 100Mbps 1208FF 256QAM 2CELL 4*4 nonBF 100Mhz
    [Tags]    FULL_RUN     Register    [flow]L3 Call    SA_NSA_PAR_TC2    NON_IWF
    [Documentation]    -SA- Check if the SA UE registers, start Traffic along with validation
    [Setup]    Run Keyword If    '${IWF_ENABLED}' != 'True'    Requires Tc    Verify Cell Setup for AP
    SA NSA MUE Register Attach and Traffic
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    gNB Snapshot Collection via adminAPI

TDD FR1 5 SA & 5 NSA DL 600Mbps & UL 100Mbps 1208FF 256QAM 2CELL 4*4 nonBF 100Mhz Deregister & Detach
    [Tags]    FULL_RUN     Register    [flow]L3 Call    SA_NSA_PAR_TC2    NON_IWF
    [Documentation]    -SA- Check if the SA UE registers, start Traffic along with validation
    SA Deregister and NSA MUE Detach MultiCell
    [Teardown]    Run Keywords
    ...    Run Keyword If    '${IWF_ENABLED}' == 'True'    IWF Test Case teardown    SA_NSA_PAR_TC2    AND
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    gNB Snapshot Collection via adminAPI

TDD FR1 SA 304UE Register DL 152Mbps & UL 152Mbps 1208FF 256QAM 2CELL 4*4 nonBF 100Mhz
    [Tags]    FULL_RUN     Register    [flow]L3 Call    SA304UE    NON_IWF
    [Documentation]    -SA- Check if the SA UE registers, start Traffic along with validation
    [Setup]    Run Keyword If    '${IWF_ENABLED}' != 'True'    Requires Tc    Verify Cell Setup for AP
    SA MUE Register for 304UEs
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    gNB Snapshot Collection via adminAPI

TDD FR1 SA 304UE DL 152Mbps & UL 152Mbps 1208FF 256QAM 2CELL 4*4 nonBF 100Mhz Deregister
    [Tags]    FULL_RUN     Register    [flow]L3 Call    SA304UE    NON_IWF
    [Documentation]    -SA- Check if the SA UE registers, start Traffic along with validation
    SA Deregister MUE 304UEs
    [Teardown]    Run Keywords
    ...    Run Keyword If    '${IWF_ENABLED}' == 'True'    IWF Test Case teardown    SA304UE
    ...    ELSE    Test Case teardown    AND
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    gNB Snapshot Collection via adminAPI

TDD FR1 SA 20UE Register and Traffic DL 120Mbps 1208FF nonBF 4*4 100Mhz
    [Tags]    FULL_RUN     SA    [flow]L3 Call    20UEDL    NON_IWF
    [Documentation]    -SA- Check if UEs Register completes
    SA Register and Traffic for 1208FF Non BF 4x4 CA Intra Loki 20UEs
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    gNB Snapshot Collection via adminAPI

TDD FR1 SA 20UE DL 120Mbps 1208FF NonBF 4*4 nonBF 100Mhz Deregister
    [Tags]    FULL_RUN     SA    [flow]L3 Call    20UEDL    NON_IWF
    [Documentation]    -SA- Check if UE deregisters
    UE Deregister should be Successful for 1208FF NonBF 4x4 MIMO CA Intra Loki 20UEs
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    gNB Snapshot Collection via adminAPI

TDD FR1 72 SA & 72 NSA Register Attach and Traffic DL 1600Mbps & UL 200Mbps 1208FF 256QAM 2CELL 4*4 nonBF 100Mhz
    [Tags]    FULL_RUN     Register    [flow]L3 Call    SANSA_72_UE    IWF_INTERNAL    IWF
    [Documentation]    -SA- Check if the SA UE registers, start Traffic along with validation
    SA NSA MUE Register Attach 72Ues
    [Teardown]    Run Keywords
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    IWF Status Check    SANSA_72_UE    AND
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    gNB Snapshot Collection via adminAPI

TDD FR1 72 SA & 72 NSA DL 1600Mbps & UL 200Mbps 1208FF 256QAM 2CELL 4*4 nonBF 100Mhz Deregister & Detach
    [Tags]    FULL_RUN     Register    [flow]L3 Call    SANSA_72_UE    IWF_INTERNAL    IWF
    [Documentation]    -SA- Check if the SA UE registers, start Traffic along with validation
    NSA MUE Deregister detach 72Ues
    [Teardown]    Run Keywords
    ...    Run Keyword    IWF Test Case teardown    SANSA_72_UE    AND
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    gNB Snapshot Collection via adminAPI

TDD FR1 SA 500UE Register DL 76bps & UL 76bps 1208FF 256QAM 2CELL 4*4 nonBF 100Mhz
    [Tags]    FULL_RUN     Register    [flow]L3 Call    SA500UE    IWF_INTERNAL    IWF
    [Documentation]    -SA- Check if the SA UE registers, start Traffic along with validation
    SA MUE Register for 500UEs
    [Teardown]    Run Keywords
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    IWF Status Check    SA500UE    AND
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    gNB Snapshot Collection via adminAPI

TDD FR1 SA SUE 3CC Register and Traffic DL 4800Mbps 1208FF 256QAM 4*4 BF 100Mhz
    [Tags]    FULL_RUN     Register    [flow]L3 Call    SA_1_UE_3CC    IWF_INTERNAL    IWF
    SA Register 3CC SUE
    Deregister UEs
    [Teardown]    Run Keywords
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    IWF Status Check    SA_1_UE_3CC    AND
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    gNB Snapshot Collection via adminAPI
