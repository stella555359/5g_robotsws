*** Settings ***
Documentation
...    Author: Ana-Maria Rodean (ana-maria.rodean@nokia.com)
...    Maintainer: Ana-Maria Rodean (ana-maria.rodean@nokia.com)
...    Group in charge: BOAM_VERIF_ET1
...    References: Doors
...    Feature Description:5GC000169
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET1/CB007326-5G-Z_5GC000169/general.robot

Resource    ./resources/CB007326-5G-Z_5GC000169.robot
Resource    ../resources/AirPhone/resources/ute/ute_wts_runner.robot

#Force Tags   STATE_CONFIGURED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN  master_classicalbts_all
#...    CLOUD_5G_O_E_AP_LO_SANSA_FS_ECPRI_CMWV_TDD   SBTS00    SBTS22R4  SBTS23R1
#...    CA_RAN_BOAM_VERIF

Suite Setup       Run Keywords     Reach OnAir Setup for OE
...               AND              Suite Preconditions
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
Check_fault_7506_generation
    [Tags]   CRT
    [Documentation]
    ...
    ASOE_Activation_and_Cancellation_of_the_Fault_7506_EFaultId_GnbCpRtCellUpdateFailedAl
