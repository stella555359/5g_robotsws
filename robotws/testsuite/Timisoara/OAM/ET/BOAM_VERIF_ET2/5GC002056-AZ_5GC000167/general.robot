*** Settings ***
Documentation
...    Author: Monika Szlovak (monika.szlovak@nokia.com)
...    Maintainer: Monika Szlovak (monika.szlovak@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description: 5GC002056-AZ_5GC000167
...    Sample execution: /opt/ute/python3/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d /opt/ute/logs/ /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET2/5GC002056-AZ_5GC000167/general.robot

Resource    ./resources/5GC002056-AZ_5GC000167.robot
Resource    ../resources/AirPhone/resources/ute/ute_wts_runner.robot

Force Tags   STATE_CONFIGURED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN   master_classicalbts_all
...    CLOUD_5G_I_BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD    #21A_classicalbts
...     CA_BTS_OAM_FMRECOV    #$QCP_BTS_OAM    QCD_MN_BTS_OAM   SBTS21B  SBTS22R1  SBTS22R2  SBTS00 Regression Optimization – part 2 – July 2022

Suite Setup       Suite Preconditions
Suite Teardown    Suite Postconditions
Test Setup        Run Keywords     Reach OnAir Setup for BO
...               AND              5GC002056-AZ_5GC000167.Test Preconditions
Test Teardown     Run Keywords    Reach OnAir Teardown
...               AND             Test Postconditions

*** Variables ***
${LOGGING_ENB_SYSLOG}=             True
${LOGGING_IPHY_SYSLOG}=            True
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True
${LOGGING_EMSSIM_LOG}=             True

*** Test Cases ***
[1]ABION_Activation_and_cancellation_of_the_fault_1937_EFaultId_FrDangerouslyOverheat
    [Tags]   CRT
    [Documentation]
    ...
    ABION_Activation_and_cancellation_of_the_fault_1937_EFaultId_FrDangerouslyOverheat

[1]ABION_Activation_and_cancellation_of_the_fault_4383_EFaultId_VirtualNodeNotRespondingAl
    [Tags]   CRT
    [Documentation]
    ...
    ABION_Activation_and_cancellation_of_the_fault_4383_EFaultId_VirtualNodeNotRespondingAl

#[1]ABION_Activation_and_cancellation_of_the_fault_7100_EFaultId_GnbCellActivationFailedX2Al
#    [Tags]   CRT
#    [Documentation]
#    ...
#    ABION_Activation_and_cancellation_of_the_fault_7100_EFaultId_GnbCellActivationFailedX2Al
#
#[1]ABION_Activation_and_cancellation_of_the_fault_7101_EFaultId_GnbCpCellUpdateFailedAl
#    [Tags]   CRT
#    [Documentation]
#    ...
#    ABION_Activation_and_cancellation_of_the_fault_7101_EFaultId_GnbCpCellUpdateFailedAl
