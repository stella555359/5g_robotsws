*** Settings ***
Documentation     [SUITE PURPOSE]  Perform Robustness CB008661
...               Prerequisite : GNB and Airphone should be installed
...               Scope : Reach a cell setup state, and perfom basic tests :
...                       Ue Register, DL Throughput, sCellAddition
...
...
...               Test Case Scenario author   : jacob.velasco_mendez@nokia.com
...               Test Case Scenario author   : jacob.velasco_mendez@nokia.com
...               Test Case automation author : jacob.velasco_mendez@nokia.com
...               Test Case automation contact: jacob.velasco_mendez@nokia.com
...               Creation Date               : 10-December-2021
...               Modified Date               : 13-December-2021
...               Last Modified by            : jacob.velasco_mendez@nokia.com

Resource          ../../../resources/SWENG/robot/GenericTest.robot
Resource          ../../../resources/SWENG/robot/Setup.robot
Resource          resources/robot/CB008661_Keywords.robot

Variables         ../../../resources/SWENG/python/ReadConfig.py

Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD
#Force Tags        CA_5G_SW_FR-Villarceaux   QCD_MN_5G   QCP_5G     RRM
#Force Tags        CA_5G_SW_FR-Villarceaux   RRM
#...               master_classicalbts_all    SBTS00    SBTS23R1
#...               CONFIGURED    5G_RAN    RAN_5G    CRT

Suite Setup       Setup.suite setup from scratch    keepAllUeDataInCfgFile=${True}    #automaticTeardown=${True}
Suite Teardown    Setup.Suite Teardown       reset_ap=${True}


*** Variables ***
${topo}           CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD


*** Test Cases ***

CB008661
    [Documentation]        CB008661
    [Timeout]              12hours
    Init Sequence          _
    Step                   Step_TL_Restart_DSS_PRB
    Step                   Step_Cell_Setup_DSS_PRB
    Step                   Step_Est_Part_DSS
    Step                   Step_Traffic_2CC_1UE_DlHighTputBler0_UlBler0_DSS_PRB       timeout=12hours
    Step                   Step_Traffic_2CC_40UE_DlHighTputBler0_UlBler0_DSS_PRB      timeout=12hours
    Step                   Step_Postlude
    #[Teardown]             GenericTest.Display diagnosis

# Mapping For QC
#  following TC are only for result MAPPING on QC ##
[x]CB008661_TL_Restart_DSS_PRB
    [Documentation]   The aim of this test is to check that gNB startup is ok with the cpri link
    ...               and RU simulators AAHF(TDD)-AHLOA(FDD) with DSS & PRB Blanking High Edge Configuration
    Run Keyword if    '${Verdict_TL_Restart_DSS_PRB}' == 'FAILED'    FAIL    dependencies issue

[x]CB008661_Cell_Setup_DSS_PRB
    [Documentation]   The aim of this test is to check that gNB cell setup is ok with the 2255-1390
    ...               flags & parameters activated with DSS & PRB Blanking High Edge Configuration
    Run Keyword if    '${Verdict_Cell_Setup_DSS_PRB}' == 'FAILED'    FAIL    dependencies issue

[x]CB008661_Est_Part_DSS
    [Documentation]   The aim of this test is to check that gNB DSS Establish Partnership is ok
    Run Keyword if    '${Verdict_Est_Part_DSS}' == 'FAILED'    FAIL    dependencies issue

[x]CB008661_Traffic_2CC_1UE_DlHighTputBler0_UlBler0_DSS_PRB
    [Documentation]   The aim of this test is given in title
    Run Keyword if    '${Verdict_Traffic_2CC_1UE_DlHighTputBler0_UlBler0_DSS_PRB}' == 'FAILED'    FAIL    dependencies issue

[x]CB008661_Traffic_2CC_40UE_DlHighTputBler0_UlBler0_DSS_PRB
    [Documentation]   The aim of this test is given in title
    Run Keyword if    '${Verdict_Traffic_2CC_40UE_DlHighTputBler0_UlBler0_DSS_PRB}' == 'FAILED'    FAIL    dependencies issue

[x]CB008661_Postlude
    [Documentation]   The aim of this test is given in title
    Run Keyword if    '${Verdict_Postlude}' == 'FAILED'    FAIL    dependencies issue
