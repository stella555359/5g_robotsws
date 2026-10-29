*** Settings ***
Documentation
...    Author: Alin Necula (alin.necula@nokia.com)
...    Maintainer: Alin Necula (alin.necula@nokia.com)
...    Group in charge: RAN_BOAM_VERIF
...    References: Doors
...    Feature Description:5GC000169
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_FMRECOV/CB005752-5G-A_5GC000169/general.robot

Resource    ./resources/CB005752-5G-A_5GC000169.robot
Resource    ../resources/AirPhone/resources/ute/ute_wts_runner.robot

Force Tags   STATE_CONFIGURED   5G_RAN_TDD  5G_RAN     SBTS00      SBTS22R4    master_classicalbts_all
...    CLOUD_5G_O_E_AP_KL_NSA_L1B_ECPRI_CMWV_TDD   CLOUD_5G_O_E_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD
...    CA_RAN_BOAM_VERIF    #  SBTS22R1  SBTS22R2  SBTS22R3

Suite Setup       Run Keywords    Reach OnAir Setup for OE
...               AND             Suite Preconditions
Suite Teardown    Run Keywords    Reach OnAir Teardown
...               AND             Suite Postconditions

Test Setup        Test Preconditions
Test Teardown     Test Postconditions

*** Variables ***
${LOGGING_ENB_SYSLOG}=             True
${LOGGING_IPHY_SYSLOG}=            True
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True
${LOGGING_EMSSIM_LOG}=             True

*** Test Cases ***
ASOE_Check_Fault_ID_7100_EFaultId_GnbCellActivationFailedX2Al_Generation
    [Tags]   CRT
    [Documentation]
    ...
    ASOE_Activation_and_cancellation_of_the_fault_7100_EFaultId_GnbCellActivationFailedX2Al

#ASOE_Check_Fault_ID_7101_EFaultId_GnbCpCellUpdateFailedAl_Generation
#    [Tags]   CRT
#    [Documentation]
#    ...
#    ASOE_Activation_and_cancellation_of_the_fault_7101_EFaultId_GnbCpCellUpdateFailedAl

#ROBUSTNESS_ASOE_Check_Fault_ID_7506_EFaultId_EFaultId_GnbCpRtCellUpdateFailedAl_Generation
#    [Tags]   CRT
#    [Documentation]
#    ...
#    ASOE_Activation_and_Cancellation_of_the_Fault_7506_EFaultId_GnbCpRtCellUpdateFailedAl
