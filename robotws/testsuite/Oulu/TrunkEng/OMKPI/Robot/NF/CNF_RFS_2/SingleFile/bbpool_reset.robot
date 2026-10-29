*** Settings ***
Force Tags

Documentation
...   Author:       Heikki Autio
...   Contact:      I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library             Collections
Library             taf.sw.reporting_portal
Resource            testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource            testsuite/Oulu/TrunkEng/OMKPI/Robot/NF/CNF_RFS_2/SingleFile/bbpool_11__reset_4G.robot
Resource            testsuite/Oulu/TrunkEng/OMKPI/Robot/NF/CNF_RFS_2/SingleFile/bbpool_12__reset_4G.robot


Suite Setup        Common Suite Setup
Suite Teardown     Common Suite Teardown

Test Setup         Run keywords  Common Test Setup  AND
...                Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown      Common Test Teardown

*** Variables ***
${ALLOWED_ALARMS_FILE}=  testsuite/Oulu/TrunkEng/OMKPI/allowed_alarms.txt
${RFS}             ${True}

*** Test Cases ***
Automated_OAMKPI_BBPool_11_Reset_4G
    [Tags]  QCD_MN_RAN  QCP_RAN_ST  QC_
    bbpool_11__reset_4G

Automated_OAMKPI_BBPool_12_Reset_4G
    [Tags]  QCD_MN_RAN  QCP_RAN_ST  QC_
    bbpool_12__reset_4G

