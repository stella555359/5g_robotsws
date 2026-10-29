*** Settings ***
Documentation
...    Author: Andreea-Oana Zaharia
...    Maintainer: Andreea-Oana Zaharia
...    Test Description: The purpose of this test case is to check if technical logs are automatically triggered after an
...                         unexpected loss of comunication between the baseband module and the RF module.
...    Execution: pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log -d results/ /home/ute/
...    Sample execution: /opt/ute/python3/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d /opt/ute/logs/ /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET2/5GC001196-M-a_5GC000371/general.robot
...    NA in OSSEMS TRUNK

Resource    ./resources/5GC001196-M-a_5GC000371.robot

#Force Tags   STATE_SW_UPLOADED   RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN
#...   CLOUD_5G_CLASSICAL_ASILL_ABILB1_AZQG_ECPRI_ENB    SBTS22R4
#...   CA_BTS_OAM_FMRECOV   #SBTS22R1  SBTS22R2   SBTS22R3

#Suite Setup       Suite Preconditions
Suite Setup       Run Keywords  UTE TL Preparation
...               AND           Suite Preconditions
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
[1.0] 2. Snapshot collection is triggered by radio recovery after unexpected loss of comunication
    [Tags]    CRT
    [Documentation]
    ...
    [1.0] 2. Snapshot collection is triggered by radio recovery after unexpected loss of comunication
