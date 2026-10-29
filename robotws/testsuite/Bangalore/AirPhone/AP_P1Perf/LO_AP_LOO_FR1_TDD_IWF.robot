# Copyright (c) 2020 Nokia. All rights reserved.

*** Settings ***
Resource    resources/Keywords/p1perf_keywords.robot
Documentation    LO AP LOO IWF test cases
Suite Setup       Common Optimized Perf Suite Setup
Suite Teardown    Common Perf Suite Teardown

*** Variables ***
${IWF_TDD_FR1}    True

*** Test Cases ***
TDD FR1 SA SUE 3CC Register and Traffic DL 4800Mbps 1208FF 256QAM 8x4 BF 100Mhz
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    SA_1_UE_3CC
    Initialize_Test_Data_And_Execute    ${SA_3CC}    SA_1_UE_3CC
    [Teardown]    Perf Test Teardown Common    SA_1_UE_3CC

TDD FR1 SA 20 UE 3CC Register and Traffic DL 4800Mbps and UL 200Mbps1208FF 256QAM 8x4 BF 100Mhz
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    SA_20_UE_3CC
    Initialize_Test_Data_And_Execute    ${SA_20_UE_3CC}    SA_20_UE_3CC
    [Teardown]    Perf Test Teardown Common    SA_20_UE_3CC

TDD FR1 SA MU-MIMO 40 UE Register and Traffic DL 3200Mbps and UL 200Mbps 1208FF 256QAM 8x4 BF 100Mhz
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    SA_40_UE_MIMO
    Initialize_Test_Data_And_Execute    ${SA_40_UE_MIMO}    SA_40_UE_MIMO
    [Teardown]    Perf Test Teardown Common    SA_40_UE_MIMO

TDD FR1 SA 2000UE Register DL 74bps and UL 74bps 1208FF 256QAM 8x4 BF 100Mhz
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    SA_2000UE
    Initialize_Test_Data_And_Execute    ${SA_2000_UE_3CELL}    SA_2000UE
    [Teardown]    Run Keywords    Perf Test Teardown Common    SA_2000UE    AND
    ...    IWF Test Case teardown    SA_2000UE

TDD FR1 SA SUE Register and Traffic DL 1600Mbps and UL 200Mbps 1208FF 256QAM 2CELL 4x4 nonBF 100Mhz
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    SA_NSA_SUE_2CELL
    Environment Setup for PET IWF    SA_NSA_SUE_2CELL    ${SA_NSA_SUE_2CELL}
    Initialize_Test_Data_And_Execute    ${SA_NSA_SUE_2CELL}    SA_NSA_SUE_2CELL
    [Teardown]    Perf Test Teardown Common    SA_NSA_SUE_2CELL
