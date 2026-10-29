*** Settings ***
Documentation
...    Author: Dan Moldovan (dan.moldovan@nokia.com) ; Geroge Medesan (george.Medesan@nokia.com)
...    Maintainer: Dan Moldovan (dan.moldovan@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description: CNI77091
...    Sample execution: /opt/ute/python3/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log -d
...    results/ /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET1/CNI-77091/general.robot

Resource    ./resources/CNI-77091.robot

#Force Tags   STATE_SW_UPLOADED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN  master_classicalbts_all
#...    CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_TDD    SBTS00    SBTS22R4  SBTS23R1
#...    CLOUD_5G_CLASSICAL_MULTIGNB_ASIB_ABIL_ABIO_4xAEUD
#...    CA_BTS_OAM_VERIF     #CA_RAN_BOAM_VERIF

Suite Setup       Run Keywords      log to console  UTE TL PreparationTBD
...               AND               Suite Preconditions
Suite Teardown    Suite Postconditions
Test Setup        Test Preconditions
Test Teardown     Test Postconditions


*** Variables ***
${LOGGING_ENB_SYSLOG}=             True
${LOGGING_IPHY_SYSLOG}=            True
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True
${LOGGING_EMSSIM_LOG}=             True

*** Test Cases ***

Test1_Check_Fault_8102
    [Tags]   CRT
    [Documentation]
    ...  Generate Fault 8102
    Check_Fault_8102

Test2_Check_Fault_8103
    [Tags]   CRT
    [Documentation]
    ...  Generate Fault 8103
    Check_Fault_8103

Test3_Check_Fault_8104
    [Tags]   CRT
    [Documentation]
    ...  Generate Fault 8104
    Check_Fault_8104

Test4_Check_Fault_8105
    [Tags]   CRT
    [Documentation]
    ...  Generate Fault 8105
    Check_Fault_8105
