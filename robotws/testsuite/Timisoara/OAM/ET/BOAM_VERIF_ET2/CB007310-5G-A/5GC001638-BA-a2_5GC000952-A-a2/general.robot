*** Settings ***

Documentation
...    Author:      Natalia Grun (natalia.grun@nokia.com)
...    Maintainer:  Natalia Grun (natalia.grun@nokia.com)
...    Group in charge:   RAN_BOAM_VERIF
...    Sample execution:
...    Execution:       robot -v CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log -d results/
...       testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET2/CB007310-5G-A/5GC001638-BA-a2_5GC000952-A-a2/general.robot


Resource    ./resources/5GC001638-BA-a2_5GC000952-A-a2.robot

Force Tags   STATE_SW_UPLOADED  RAN_5G   RAN_5G_TDD    SBTS00     SBTS23R1
...    CLOUD_5G_CLASSICAL_FULLRACK_ASILL_ABIOB1B3_AEQN_ECPRI_ASILR_ABIOB4B6_ENB
...    CA_BTS_OAM_VERIF   CA_RAN_BOAM_VERIF    master_classicalbts_all    #SBTS22R2   SBTS22R3


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
[1] 5GC001638-BA_Check_if_4th_Site_recovery_reset_within_1_hour_is_not_executed
    [Tags]    CRT
    5GC001638-BA_Check_if_4th_Site_recovery_reset_within_1_hour_is_not_executed




