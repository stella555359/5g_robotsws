# Copyright (c) 2020 Nokia. All rights reserved.

*** Settings ***
Resource    resources/Keywords/p1perf_keywords.robot
Documentation    LOO AP LOOO IWF
Suite Setup       Common Optimized Perf Suite Setup
Suite Teardown    Common Perf Suite Teardown

*** Variables ***
${IWF_FR1_LOO_LOOO}    True
${PREV_TEST_NAME}    None

*** Test Cases ***
TDD FR1 SA 40 UE 5CC 3T and 2F DL 5000 Mbps UL 248 Mbps 1208FF 256QAM TDD 3x100 MHz and FDD 2x40 MHz
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    SA_40_UE_5CC    SA_5CC_COMMON    IWF_FR1
    SA 40UE 5CC Register and Traffic DL 5000Mbps UL 248Mbps 1208FF
    [Teardown]    Run Keywords
    ...    Deregister PET    AND
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    IWF Status Check    SA_40_UE_5CC    AND
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    gNB Snapshot Collection via adminAPI

TDD FR1 SA SUE 5CC 3T and 2F DL 4500 Mbps UL 250 Mbps 1208FF 256QAM TDD 3x100 MHz and FDD 2x40 MHz
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    SA_SUE_5CC    SA_5CC_COMMON    IWF_FR1
    SA SUE 5CC Register and Traffic DL 4500Mbps UL 250Mbps 1208FF
    [Teardown]    Run Keywords
    ...    Deregister PET    AND
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    IWF Status Check    SA_SUE_5CC    AND
    ...    IWF Test Case teardown    SA_SUE_5CC    AND
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    gNB Snapshot Collection via adminAPI

TDD FR1 SA SUE 6CC 4F and 2T DL 4300 Mbps UL 399 Mbps 1208FF 256QAM FDD 3x50 MHz and 1x30 MHz and TDD 2x100 MHz
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    SA_SUE_6CC    SA_SUE_6CC_IWF    IWF_FR1
    Environment Setup for PET IWF    SA_SUE_6CC    ${SA_SUE_6CC}
    Common Register Traffic and Validation    ${SA_SUE_6CC}    SA_SUE_6CC
    Set Suite Variable    ${PREV_TEST_NAME}    ${TEST NAME}
    [Teardown]    Run Keywords
    ...    Deregister PET    AND
    ...    IWF Test Case teardown    SA_SUE_6CC    AND
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    IWF Status Check    SA_SUE_6CC    AND
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    gNB Snapshot Collection via adminAPI

TDD FR1 SA SUE 6CC 2T and 4F DL 4300 Mbps UL 295 Mbps 1208FF 256QAM TDD 2x100 MHz and FDD 3x50 MHz and 1x30 MHz
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    SA_UE_6CC    SA_SUE_6CC_IWF    IWF_FR1
    [Documentation]    This test case depends on the previous test case for its configuration files.
    ${6CC_TC}=    Catenate    "${PREV_TEST_NAME}" == "None" or
    ...    "${PREV_TEST_NAME}" != "TDD FR1 SA SUE 6CC 4F and 2T DL 4300 Mbps UL 399 Mbps 1208FF 256QAM FDD 3x50 MHz and 1x30 MHz and TDD 2x100 MHz"
    Run Keyword If    ${6CC_TC}    Environment Setup for PET IWF    SA_UE_6CC
    Perform Delta SCF Commissioning    SA_UE_6CC
    Common Register Traffic and Validation    ${SA_UE_6CC}    SA_UE_6CC
    [Teardown]    Run Keywords
    ...    Deregister PET    AND
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    IWF Status Check    SA_UE_6CC    AND
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    gNB Snapshot Collection via adminAPI
