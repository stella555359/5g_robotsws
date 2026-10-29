*** Settings ***
Documentation     [SUITE PURPOSE] Verify dynamic switching between K2={2} and K2={2,3,4} with multiple BWPs
...               (large, small, PS-BWP) and CB008367 enabled, with 'peakRate' preference. High UL PDCCH load in PS-BWP.
...               Test Case Scenario author   : yann.ah.herve@nokia.com
...               Test Case Scenario contact  : yann.ah.herve@nokia.com
...               Test Case automation author : Abderrahmane.nezrouk@nokia.com
...               Test Case automation contact: Abderrahmane.nezrouk@nokia.com
...               Creation Date               : 08-Jully-2025



Library           OperatingSystem
Resource          ./resources/robot/CB013305_common_keywords.robot
Resource          ../../../resources/SWENG/robot/Tools.robot
Resource          ../../../resources/SWENG/robot/Setup.robot

Suite Setup       Setup.Suite Setup from scratch        automaticTeardown=${True}    keepAllUeDataInCfgFile=${True}
Suite Teardown    Suite Teardown
Test Teardown     CB013305 Test Teardown

*** Test Cases ***
[1][1.0] CB013305-E1_05_Switch_k2_mode_3BWP_8367
    CB013305-E1_05_Switch_k2_mode


*** keywords ***
CB013305 Test Teardown
    [Documentation]                 Generic Test teardown:
    ...                             - Call the SCOUT services to produce data for the Reporting Portal.
    ...                             - Save the current egate_console.log file in LOG_PATH and then delete it.
    ...                             - Get SOS report and snapshot only if test is fail.
    Dated Log                       Start Test Teardown
    Produce Scout Data
    Save and Clear Egate Console Log          pattern=TestTeardown
    Run keyword if                  '${TEST_STATUS}'=='FAIL'
    ...                             Test Teardown if Fail
