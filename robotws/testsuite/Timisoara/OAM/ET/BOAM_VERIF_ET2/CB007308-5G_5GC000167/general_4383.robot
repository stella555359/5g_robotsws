*** Settings ***
Documentation
...    Author: Monika Szlovak (monika.szlovak@nokia.com)
...    Maintainer: Monika Szlovak (monika.szlovak@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description: CB007308-5G_5GC000167
...    Sample execution: /opt/ute/python3/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d /opt/ute/logs/ /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET2/CB007308-5G_5GC000167/general_4383.robot

Resource    ./resources/CB007308-5G_5GC000167.robot
Resource    ../resources/AirPhone/resources/ute/ute_wts_runner.robot

Force Tags   STATE_CONFIGURED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN  master_classicalbts_all   SBTS00      SBTS23R1
...    CLOUD_5G_O_E_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    CA_BTS_OAM_FMRECOV  # SBTS22R1  SBTS22R2  SBTS22R3  SBTS22R4

Suite Setup       Suite Preconditions
Suite Teardown    Suite Postconditions
#Test Setup        Test Preconditions
#Test Teardown     Test Postconditions
Test Setup        Run Keywords     Reach OnAir Setup for OE
...               AND              CB007308-5G_5GC000167.Test Preconditions
Test Teardown     Run Keywords    Reach OnAir Teardown
...               AND             Test Postconditions

*** Variables ***
${LOGGING_ENB_SYSLOG}=             True
${LOGGING_IPHY_SYSLOG}=            True
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True
${LOGGING_EMSSIM_LOG}=             True

*** Test Cases ***
#[1]ASOE_Activation_and_cancellation_of_the_fault_1937_EFaultId_FrDangerouslyOverheat
#    [Tags]   CRT
#    [Documentation]
#    ...
#    ASOE_Activation_and_cancellation_of_the_fault_1937_EFaultId_FrDangerouslyOverheat

[1]ASOE_Activation_and_cancellation_of_the_fault_4383_EFaultId_VirtualNodeNotRespondingAl
    [Tags]   CRT
    [Documentation]
    ...
    ASOE_Activation_and_cancellation_of_the_fault_4383_EFaultId_VirtualNodeNotRespondingAl


