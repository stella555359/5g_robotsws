*** Settings ***

Documentation
...    Author:      Natalia Grun (natalia.grun@nokia.com)
...    Maintainer:  Natalia Grun (natalia.grun@nokia.com)
...    Group in charge:   RAN_BOAM_VERIF
...    Sample execution:
...    Execution:       robot -v CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log -d results/
...       testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET2/5GC000829-A-00/5GC001638-BA-a2_5GC000952-A-a2/general.robot


Resource    ./resources/5GC001638-BA-a2_5GC000952-A-a2.robot

Force Tags   STATE_SW_UPLOADED  RAN_5G   RAN_5G_TDD    SBTS00     SBTS23R1
...    CLOUD_5G_CLASSICAL_FULLRACK_ASIKL_ABILB1B2_ASIKR_ABILB4B5_AZQG_AZQP
...    CA_BTS_OAM_VERIF   CA_RAN_BOAM_VERIF   QCP_RAN_ET   QCD_MN_RAN   master_classicalbts_all


Suite Setup       Run Keywords      5GC001638-BA-a2_5GC000952-A-a2.UTE TL Preparation
...               AND               Suite Preconditions

Suite Teardown    Suite Postconditions
Test Setup        Test Preconditions
Test Teardown     Test Postconditions

*** Variables ***
${LOGGING_ENB_SYSLOG}=             True
${LOGGING_IPHY_SYSLOG}=            False
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True
${LOGGING_EMSSIM_LOG}=             False

*** Test Cases ***
[1] 5GC001638-BA_Check_if_FSP_recovery_reset_counter_is_cleared_after_1_hour_and_after_Site_reset
    [Tags]    CRT
    5GC001638-BA_Check_if_FSP_recovery_reset_counter_is_cleared_after_1_hour_and_after_Site_reset

