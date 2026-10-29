*** Settings ***
Force Tags          CLOUD_FR4_L_3A_4xFXEB_4xFRGT_4xFXCA_4xFRHG
...                 CELL_CONFIG=[2A1A2A1A1A1A][2A1A1A1A][3A1A2A1A1A1A
...                 SCFC_ADJUSTMENTS=CNF_4d_adjustments.yml

Documentation
...   Author:       Heikki Autio
...   Contact:      I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library             Collections
Library             taf.sw.reporting_portal
Resource            testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource            testsuite/Oulu/TrunkEng/OMKPI/Robot/CIT/SingleFile/CNF_LTE_4e_lte_rat_reset.robot
Resource            testsuite/Oulu/TrunkEng/OMKPI/Robot/CIT/SingleFile/CNF_LTE_4e_power_reset.robot
Resource            testsuite/Oulu/TrunkEng/OMKPI/Robot/CIT/SingleFile/CNF_LTE_4e_site_reset.robot
Resource            testsuite/Oulu/TrunkEng/OMKPI/Robot/CIT/SingleFile/CNF_LTE_4e_ru_reset.robot


Suite Setup        Common Suite Setup
Suite Teardown     Common Suite Teardown

Test Setup         Run keywords  Common Test Setup  AND
...                Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown      Common Test Teardown

*** Variables ***
${ALLOWED_ALARMS_FILE}=  testsuite/Oulu/TrunkEng/OMKPI/allowed_alarms_4d.txt

*** Test Cases ***
Automated_OAMKPI_LTE_RAT_Reset
    [Tags]  QCD_MN_RAN  QCP_RAN_ST  QC_
    1_Automated_OAMKPI_LTE_RAT_Reset

Automated_OAMKPI_Power_Reset
    [Tags]  QCD_MN_RAN  QCP_RAN_ST  QC_
    2_Automated_OAMKPI_Power_Reset

Automated_OAMKPI_Site_Reset
    [Tags]  QCD_MN_RAN  QCP_RAN_ST  QC_
    3_Automated_OAMKPI_Site_Reset

Automated_OAMKPI_RU_Reset
    [Tags]  QCD_MN_RAN  QCP_RAN_ST  QC_
    4_Automated_OAMKPI_RU_Reset