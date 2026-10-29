*** Settings ***
Force Tags

Documentation
...   Author:       Heikki Autio
...   Contact:      I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library             Collections
Library             taf.sw.reporting_portal
Resource            testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource            testsuite/Oulu/TrunkEng/OMKPI/Robot/NF/CNF_RFS_2/SingleFile/ru_power_reset_AHCA_5G.robot
Resource            testsuite/Oulu/TrunkEng/OMKPI/Robot/NF/CNF_RFS_2/SingleFile/ru_power_reset_AEQK_5G.robot
Resource            testsuite/Oulu/TrunkEng/OMKPI/Robot/NF/CNF_RFS_2/SingleFile/ru_power_reset_AHFIB_5G.robot
Resource            testsuite/Oulu/TrunkEng/OMKPI/Robot/NF/CNF_RFS_2/SingleFile/ru_power_reset_AHFIB_4G.robot


Suite Setup        Common Suite Setup
Suite Teardown     Common Suite Teardown

Test Setup         Run keywords  Common Test Setup  AND
...                Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown      Common Test Teardown

*** Variables ***
${ALLOWED_ALARMS_FILE}=  testsuite/Oulu/TrunkEng/OMKPI/allowed_alarms.txt
${RFS}             ${True}

*** Test Cases ***
Automated_OAMKPI_RU_Power_Reset_AHCA_5G
    [Tags]  QCD_MN_RAN  QCP_RAN_ST  QC_
    ru_power_reset_AHCA_5G

Automated_OAMKPI_RU_Power_Reset_AEQK_5G
    [Tags]  QCD_MN_RAN  QCP_RAN_ST  QC_
    ru_power_reset_AEQK_5G

Automated_OAMKPI_RU_Power_Reset_AHFIB_5G
    [Tags]  QCD_MN_RAN  QCP_RAN_ST  QC_
    ru_power_reset_AHFIB_5G

Automated_OAMKPI_RU_Power_Reset_AHFIB_4G
    [Tags]  QCD_MN_RAN  QCP_RAN_ST  QC_
    ru_power_reset_AHFIB_4G
