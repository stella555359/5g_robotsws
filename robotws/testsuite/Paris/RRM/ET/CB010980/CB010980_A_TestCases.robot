*** Settings ***
Documentation     [SUITE PURPOSE] Entry points for CB010980-A (CP SCTP PM counters) automated test cases
...               Test Case Scenario author   : yann.ah.herve@nokia.com
...               Test Case Scenario contact  : yann.ah.herve@nokia.com
...               Test Case automation author : yann.ah.herve@nokia.com
...               Test Case automation contact: yann.ah.herve@nokia.com
...               Creation Date               : 18-September-2025
...               Last Modified by            :
...               Modification:
...                       18-September-2025   | Creation
...

Library           OperatingSystem
Resource          ./resources/robot/CB010980_A_keywords.robot
Resource          ../../../resources/SWENG/robot/Tools.robot
Resource          ../../../resources/SWENG/robot/Setup.robot

Suite Setup       Suite Setup from scratch            listBackupFiles=${FD_ALL}
...               keepAllUeDataInCfgFile=${True}
Suite Teardown    Suite Teardown
Test Teardown     CB010980 Test Teardown

*** Test Cases ***
[1][1.0] USCB010980-A-PMO_1_007_NG-C_Resent_PM
    CB010980_A_PMO_1_TC_NG-C_Resent_PM
