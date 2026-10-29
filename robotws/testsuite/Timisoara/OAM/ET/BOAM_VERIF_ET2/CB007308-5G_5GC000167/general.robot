*** Settings ***
Documentation
...    Author: Monika Szlovak (monika.szlovak@nokia.com)
...    Maintainer: Monika Szlovak (monika.szlovak@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description: CB007308-5G_5GC000167
...    Sample execution: /opt/ute/python3/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d /opt/ute/logs/ /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET2/CB007308-5G_5GC000167/general.robot

Resource    ./resources/CB007308-5G_5GC000167.robot
Resource    ../resources/AirPhone/resources/ute/ute_wts_runner.robot

Force Tags   STATE_SW_UPLOADED   RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN  master_classicalbts_all   SBTS00      SBTS23R1
...   CLOUD_5G_CLASSICAL_ASOE_AEQN     #CLOUD_5G_CLASSICAL_SA_ASOE_2xAZHL_eCPRI
...    CA_BTS_OAM_FMRECOV  #SBTS22R1  SBTS22R2  SBTS22R3  SBTS22R4

#Suite Setup       Suite Preconditions
Suite Setup       Run Keywords  CB007308-5G_5GC000167.UTE TL Preparation   #2_11_UTESRAN201 TL Preparation
...               AND           Suite Preconditions
Suite Teardown    Suite Postconditions
Test Setup        pretest_posttest.Test Preconditions
Test Teardown     Test Postconditions

*** Variables ***
${LOGGING_ENB_SYSLOG}=             True
${LOGGING_IPHY_SYSLOG}=            True
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True
${LOGGING_EMSSIM_LOG}=             True

*** Test Cases ***
[1]ASOE_Activation_and_cancellation_of_the_fault_1937_EFaultId_FrDangerouslyOverheat
    [Tags]   CRT
    [Documentation]
    ...
    ASOE_Activation_and_cancellation_of_the_fault_1937_EFaultId_FrDangerouslyOverheat

#[1]ASOE_Activation_and_cancellation_of_the_fault_4383_EFaultId_VirtualNodeNotRespondingAl
#    [Tags]   CRT
#    [Documentation]
#    ...
#    ASOE_Activation_and_cancellation_of_the_fault_4383_EFaultId_VirtualNodeNotRespondingAl


