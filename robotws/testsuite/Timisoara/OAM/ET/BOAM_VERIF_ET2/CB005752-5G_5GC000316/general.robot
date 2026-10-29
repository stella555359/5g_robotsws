*** Settings ***
Documentation
...    Author: Monika Szlovak (monika.szlovak@nokia.com)
...    Maintainer: Monika Szlovak (monika.szlovak@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description:5GC000316
...    Sample execution: /opt/ute/python3/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d /home/ute/logs/ /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET2/CB005752-5G_5GC000316/general.robot

Resource    ./resources/5GC000316.robot

Force Tags   STATE_CONFIGURED  RAN_5G  RAN_5G_TDD  5G_RAN_TDD  5G_RAN   SBTS00      master_classicalbts_all
...    CLOUD_5G_O_E_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    CA_BTS_OAM_FMRECOV   #SBTS22R1  SBTS22R2  SBTS22R3  SBTS22R4

Suite Setup       Suite Preconditions
Suite Teardown    Suite Teardown
Test Setup        Test Preconditions
Test Teardown     Test Postconditions

*** Variables ***
${LOGGING_ENB_SYSLOG}=             True
${LOGGING_IPHY_SYSLOG}=            True
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True
${LOGGING_EMSSIM_LOG}=             True

*** Test Cases ***
CB005752-5G_5GC000316_Clock_control_value_is_shown_in_graph_view
    [Tags]   CRT
    [Documentation]
    ...
    5GC000316_Clock_control_value_is_shown_in_graph_View

CB005752-5G_5GC000316_Satellite_signal_level_of_GNSS_receiver_in_graph_view
    [Tags]   CRT
    [Documentation]
    ...
    5GC000316_Satellite_signal_level_of_GNSS_receiver_in_graph_view

