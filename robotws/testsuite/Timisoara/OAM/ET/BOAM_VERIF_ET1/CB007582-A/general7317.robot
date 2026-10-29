*** Settings ***
Documentation
...    Author: Ioana Raluca Radulescu (raluca.radulescu@nokia.com)
...    Maintainer: Ioana Raluca Radulescu (raluca.radulescu@nokia.com)
...    Group in charge: BOAM_VERIF_ET4
...    References: Doors
...    Feature Description:CB007582
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET1/CB007582-A/general7317.robot

Resource    ./resources/CB007582-A.robot
Resource    ../resources/AirPhone/resources/ute/ute_wts_runner.robot

Force Tags   STATE_CONFIGURED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN  master_classicalbts_all
...    CLOUD_5G_O_E_AP_LO_SANSA_FS_ECPRI_CMWV_TDD   SBTS00
...    CA_RAN_BOAM_VERIF

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
3_Fault_7317_EFaultId_NgSetupStopRetryAl
    [Tags]   CRT
    [Documentation]
    ...
    ASOE_Activation_and_cancellation_of_the_fault_7317_EFaultId_NgSetupStopRetryAl
