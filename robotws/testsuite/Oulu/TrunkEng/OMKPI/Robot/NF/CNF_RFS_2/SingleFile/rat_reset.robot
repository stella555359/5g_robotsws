*** Settings ***
Force Tags

Documentation
...   Author:       Heikki Autio
...   Contact:      I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library             Collections
Library             taf.sw.reporting_portal
Resource            testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource            testsuite/Oulu/TrunkEng/OMKPI/Robot/NF/CNF_RFS_2/SingleFile/rat_reset_10a_5G.robot
Resource            testsuite/Oulu/TrunkEng/OMKPI/Robot/NF/CNF_RFS_2/SingleFile/rat_reset_10b_5G.robot
Resource            testsuite/Oulu/TrunkEng/OMKPI/Robot/NF/CNF_RFS_2/SingleFile/rat_reset_7a_4G.robot
Resource            testsuite/Oulu/TrunkEng/OMKPI/Robot/NF/CNF_RFS_2/SingleFile/rat_reset_7b_4G.robot


Suite Setup        Common Suite Setup
Suite Teardown     Common Suite Teardown

Test Setup         Run keywords  Common Test Setup  AND
...                Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown      Common Test Teardown

*** Variables ***
${ALLOWED_ALARMS_FILE}=  testsuite/Oulu/TrunkEng/OMKPI/allowed_alarms.txt
${RFS}             ${True}

*** Test Cases ***
Automated_OAMKPI_rat_reset_10a_5G
    [Tags]  QCD_MN_RAN  QCP_RAN_ST  QC_
    rat_reset_10a_5G

Automated_OAMKPI_rat_reset_10b_5G
    [Tags]  QCD_MN_RAN  QCP_RAN_ST  QC_
    rat_reset_10b_5G

Automated_OAMKPI_rat_reset_7a_4G
    [Tags]  QCD_MN_RAN  QCP_RAN_ST  QC_
    rat_reset_7a_4G

Automated_OAMKPI_rat_reset_7b_4G
    [Tags]  QCD_MN_RAN  QCP_RAN_ST  QC_
    rat_reset_7b_4G

