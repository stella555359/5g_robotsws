*** Settings ***
Force Tags

Documentation
...   Author:       Heikki Autio
...   Contact:      I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library               Collections
Library               taf.sw.reporting_portal
Resource              testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource            testsuite/Oulu/TrunkEng/OMKPI/Robot/CIT/SingleFile/CNF_LTE_13_site_reset.robot
Resource            testsuite/Oulu/TrunkEng/OMKPI/Robot/CIT/SingleFile/CNF_LTE_13_power_reset.robot
Resource            testsuite/Oulu/TrunkEng/OMKPI/Robot/CIT/SingleFile/CNF_LTE_13_ru_reset.robot
Resource            testsuite/Oulu/TrunkEng/OMKPI/Robot/CIT/SingleFile/CNF_LTE_13_capacity_module_reset.robot
Resource            testsuite/Oulu/TrunkEng/OMKPI/Robot/CIT/SingleFile/CNF_LTE_13_remote_power_reset.robot
Resource            testsuite/Oulu/TrunkEng/OMKPI/Robot/CIT/SingleFile/CNF_LTE_13_capacity_module_power_reset.robot
Resource            testsuite/Oulu/TrunkEng/OMKPI/Robot/CIT/SingleFile/CNF_LTE_13_lte_rat_reset.robot

Suite Setup        Common Suite Setup
Suite Teardown     Common Suite Teardown

Test Setup         Run keywords  Common Test Setup  AND
...                Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown      Common Test Teardown

*** Variables ***
${ALLOWED_ALARMS_FILE}=  testsuite/Oulu/TrunkEng/OMKPI/allowed_alarms.txt

*** Test Cases ***

Automated_OAMKPI_Site_Reset
    [Tags]  QCD_MN_RAN  QCP_RAN_ST  QC_
    1_Site_Reset

Automated_OAMKPI_Power_Reset
    [Tags]  QCD_MN_RAN  QCP_RAN_ST  QC_
    2_Power_Reset

Automated_OAMKPI_RU_Reset
    [Tags]  QCD_MN_RAN  QCP_RAN_ST  QC_
    3_RU_Reset

Automated_OAMKPI_Capacity_Module_Reset
    [Tags]  QCD_MN_RAN  QCP_RAN_ST  QC_
    4_Capacity_Module_Reset

Automated_OAMKPI_Remote_Power_Reset
    [Tags]  QCD_MN_RAN  QCP_RAN_ST  QC_
    5_Remote_Power_Reset

Automated_OAMKPI_Capacity_Module_Power_Reset
    [Tags]  QCD_MN_RAN  QCP_RAN_ST  QC_
    6_Capacity_Module_Power_Reset

Automated_OAMKPI_LTE_RAT_Reset
    [Tags]  QCD_MN_RAN  QCP_RAN_ST  QC_
    7_LTE_RAT_Reset