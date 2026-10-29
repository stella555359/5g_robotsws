# Copyright (c) 2020 Nokia. All rights reserved.

*** Settings ***
Resource    resources/Keywords/p1perf_keywords.robot
Documentation    L3 Call Suite for MMWV IWF
Suite Setup       Common Optimized Perf Suite Setup
Suite Teardown    Common Perf Suite Teardown

*** Variables ***
${AP_P1Perf_mmwv}    True

*** Test Cases ***
X2 Connection
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    NON_IWF    IWF    SUE    FR2_NSA_MUE
    [Documentation]    -NSA- check if "X2AP Link with GNB" msg found in egate console
    X2AP Link Should be UP
    sleep    5s

Verify Cell Setup for AP
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    NON_IWF    IWF    SUE    FR2_NSA_MUE
    [Documentation]    -SANSA- Check if "Cell Setup completed" message can be found in APL3.log
    Run Keyword If    '${IWF_ENABLED}' == 'True'    Cell Setup Validation from egate Console
    ...    ELSE    AP Cell Setup should be Successful

TDD FR2 NSA SUE Attach and Traffic 8CC CA DL 4300Mbps 1127FF 64QAM 2X2 BF 100 Mhz
    [Tags]    FULL_RUN    Attach    FR2_8CC    [flow]L3 Call    MUE    IWF    IWF_INTERNAL
    [Documentation]    -NSA- Check if the NSA UE attach, start NSA traffic and validate
    [Setup]    Requires Tc    Verify Cell Setup for AP
    Run Keyword If    '${IWF_ENABLED}' == 'True'
    ...    NSA SUE Attach DL Traffic for 1127FF NonBF 8CC CA
    [Teardown]    Run Keywords
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    IWF Status Check    FR2_8CC    AND
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    gNB Snapshot Collection via adminAPI

TDD FR2 NSA SUE Detach 8CC CA DL 4300Mbps 1127FF 64QAM 2X2 BF 100 Mhz
    [Tags]    FULL_RUN    Detach    FR2_8CC    [flow]L3 Call    MUE    IWF    IWF_INTERNAL
    [Documentation]    -NSA- Check if the NSA UE Detach
    Run Keyword If    '${IWF_ENABLED}' == 'True'
    ...    Detach NSA MMWV Single UE
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    gNB Snapshot Collection via adminAPI

TDD FR2 NSA SUE Attach and Traffic DL 550Mbps UL 110Mbps 1127FF 64QAM 1CELL 2x2 BF 100Mhz
    [Tags]    FULL_RUN    Attach    FR2_NSA_SUE    [flow]L3 Call    SUE    IWF    NON_IWF    IWF_INTERNAL
    [Documentation]    -NSA- Check if the NSA UE attach, start NSA traffic and validate
    [Setup]    Requires Tc    Verify Cell Setup for AP
    NSA Attach for Mmwv Single UE Single Cell
    [Teardown]    Run Keywords
    ...    Run Keyword If    '${IWF_ENABLED}' == 'True' and '${TEST STATUS}' == 'FAIL'    IWF Status Check    FR2_NSA_SUE
    ...    AND    Run Keyword If    '${TEST STATUS}' == 'FAIL'    gNB Snapshot Collection via adminAPI

TDD FR2 NSA SUE Detach DL 550Mbps UL 110Mbps 1127FF 64QAM 1CELL 2x2 BF 100Mhz
    [Tags]    FULL_RUN    Detach    FR2_NSA_SUE    [flow]L3 Call    SUE    IWF    NON_IWF    IWF_INTERNAL
    [Documentation]    -NSA- Check if the NSA UE Detach
    Detach NSA MMWV Single UE
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    gNB Snapshot Collection via adminAPI

TDD FR2 NSA SUE Attach and Traffic 4CC CA DL 2200Mbps 1127FF 64QAM 2X2 BF 100 Mhz
    [Tags]    FULL_RUN    Attach    FR2_4CC    [flow]L3 Call    MUE    IWF    IWF_INTERNAL
    [Documentation]    -NSA- Check if the NSA UE attach, start NSA traffic and validate
    [Setup]    Requires Tc    Verify Cell Setup for AP
    Run Keyword If    '${IWF_ENABLED}' == 'True'
    ...    NSA SUE Attach and DL Traffic for 1127FF NonBF 4CC CA
    [Teardown]    Run Keywords
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    IWF Status Check    FR2_4CC    AND
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    gNB Snapshot Collection via adminAPI

TDD FR2 NSA SUE Detach 4CC CA DL 2200Mbps 1127FF 64QAM 2X2 BF 100 Mhz
    [Tags]    FULL_RUN    Detach    FR2_4CC    [flow]L3 Call    MUE    IWF    IWF_INTERNAL
    [Documentation]    -NSA- Check if the NSA UE Detach
    Run Keyword If    '${IWF_ENABLED}' == 'True'
    ...    Detach NSA MMWV Single UE
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    gNB Snapshot Collection via adminAPI

TDD FR2 NSA Attach and Traffic 20UEs DL 550Mbps UL 110Mbps 1127FF 64QAM 2CELLS 2x2 BF 100Mhz
    [Tags]    FULL_RUN    Attach    NSA_MUE_SCELL    [flow]L3 Call    FR2_NSA_MUE_2CELL    IWF_INTERNAL    IWF
    [Documentation]    -NSA- Check if the NSA UE attach, start NSA traffic and validate
    [Setup]    Requires Tc    Verify Cell Setup for AP
    Attach Multi UE for Multi Cell NSA
    [Teardown]    Run Keywords
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    IWF Status Check    FR2_NSA_MUE_2CELL    AND
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    gNB Snapshot Collection via adminAPI

TDD FR2 NSA Detach 20UEs DL 550Mbps UL 110Mbps 1127FF 64QAM 2CELLS 2x2 BF 100Mhz
    [Tags]    FULL_RUN    Detach    NSA_MUE_SCELL    [flow]L3 Call    FR2_NSA_MUE_2CELL    IWF_INTERNAL    IWF
    [Documentation]    -NSA- Check if the NSA UE Detach
    Detach NSA MMWV MUE
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    gNB Snapshot Collection via adminAPI
