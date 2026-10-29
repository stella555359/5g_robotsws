*** Settings ***
Documentation
...    Author: Ichim Vlad (vlad.ichim@nokia.com)
...    Maintainer: Alexandra Istrate (alexandra.istrate@nokia.com)
...    Group in charge: RAN_BOAM_VERIF_ET2
...    References: doors
...    Feature Description: CB008436

Resource    ./resources/Fault_ID_243_EthLinkUnstableAl.robot
Resource    ./resources/Start_backplane_Ethernet_link_monitoring.robot

Force Tags   STATE_CONFIGURED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN   SBTS00   SBTS22R3   SBTS22R4   SBTS23R1
...    CRT
...    CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_TDD
...    CA_BTS_OAM_VERIF

Suite Setup     Run Keywords     Reach OnAir Setup for BL
...             AND              Suite Preconditions
Suite Teardown    Run Keywords    Reach OnAir Teardown
...             AND              Suite Postconditions
Test Setup        Test Preconditions
Test Teardown     Test Postconditions

*** Variables ***
${LOGGING_ENB_SYSLOG}=             True
${LOGGING_IPHY_SYSLOG}=            True
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True
${LOGGING_EMSSIM_LOG}=             True
${alias}=                       admin_1


*** Test Cases ***
#Fault_ID_243_EthLinkUnstableAl
#     [Tags]
#     [Documentation]  BBMOD Recovery Action after FaultID 243 is raised
#
#     ADMIN INFOMODEL Check If BTS Is OnAir
#     ADMIN Check If Alarm Is Not Active  fault_id=243
#     Generate FaultID 243
#     Wait Until Keyword Succeeds   30   1  ADMIN Check If Alarm Is Active  fault_id=243
#     Wait Until Keyword Succeeds   60   3  ADMIN Check If Alarm Is In Historical Alarms  fault_id=243
#     Check Eth Link monitoring is off
#     Wait Until Keyword Succeeds   600    60    ADMIN INFOMODEL Check If BTS Is OnAir
#     ADMIN Check If Alarm Is Not Active  fault_id=243
#    # Check Eth Link monitoring is on

Start_backplane_Ethernet_link_monitoring
     [Tags]
     [Documentation]  Monitoring starts after BBMOD reset

     ADMIN INFOMODEL Check If BTS Is OnAir
     Reset BBMOD
     Wait Until Keyword Succeeds   600    60    ADMIN INFOMODEL Check If BTS Is OnAir
     Check Eth Link monitoring is on
