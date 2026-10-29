*** Settings ***
Documentation
...    Author: Vlad Ichim (vlad.ichim@nokia.com)
...    Maintainer: Vlad Ichim (vlad.ichim@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description: CB008423-5G_5GC000167
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d /opt/ute/logs/ /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET2/CB008423-5G_5GC000167/general.robot

Resource    ./resources/CB008423-5G_5GC000167.robot
Resource    ../resources/AirPhone/resources/ute/ute_wts_runner.robot

#Force Tags   STATE_SW_UPLOADED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN  master_classicalbts_all
#...    CLOUD_5G_CLASSICAL_ASIBR_ABIOB4-B5_AHEGA_AZNA_CPRI
#...    CA_BTS_OAM_FMRECOV    SBTS00   SBTS22R4   SBTS23R1   #$QCP_BTS_OAM    QCD_MN_BTS_OAM

#TC to be dropped due to overlap with ST 21 Nov 2022


Suite Setup       Run Keywords      UTE TL Preparation
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
#[1]ABION_Activation_and_cancellation_of_the_fault_1937_EFaultId_FrDangerouslyOverheat
#   [Tags]   CRT    SBTS22R3 REMOVED_20_07_22_regr_opt
#   [Documentation]
#   ...
#   ABION_Activation_and_cancellation_of_the_fault_1937_EFaultId_FrDangerouslyOverheat

[1]ABION_Activation_and_cancellation_of_the_fault_4383_EFaultId_VirtualNodeNotRespondingAl
    [Tags]  CRT
    [Documentation]
    ...
    ABION_Activation_and_cancellation_of_the_fault_4383_EFaultId_VirtualNodeNotRespondingAl

#[1]ABION_Activation_and_cancellation_of_the_fault_7100_EFaultId_GnbCellActivationFailedX2Al
#    [Tags]  SBTS00    SBTS22R3  CRT
#    [Documentation]
#    ...
#    ABION_Activation_and_cancellation_of_the_fault_7100_EFaultId_GnbCellActivationFailedX2Al
#
#[1]ABION_Activation_and_cancellation_of_the_fault_7101_EFaultId_GnbCpCellUpdateFailedAl
#    [Tags]  SBTS00    SBTS22R3  CRT
#    [Documentation]
#    ...
#    ABION_Activation_and_cancellation_of_the_fault_7101_EFaultId_GnbCpCellUpdateFailedAl
