*** Settings ***
Documentation
...    Author: Sergiu Crisan (sergiu.crisan@nokia.com)
...    Maintainer: Sergiu Crisan (sergiu.crisan@nokia.com)
...    Group in charge: BOAM_VERIF_ET1
...    References: doors
...    Feature Description:CB008480-5G-B
...    Sample execution: /opt/ute/python3/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET1/CB008480-5G-B/general.robot

Resource    ./resources/CB008480-5G-B.robot

Force Tags   STATE_SW_UPLOADED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN  master_classicalbts_all
...    CLOUD_5G_CLASSICAL_ASIL_ABIO_2xO-RU    SBTS00  SBTS22R4  SBTS23R1
...    CA_RAN_BOAM_VERIF

Suite Setup       Run Keywords  UTE TL Preparation O-RU
...               AND           Suite O-RU_Preconditions
...               AND           Get Software Release
Suite Teardown    Run Keywords  Update Software ORU1 pack
...               AND           Suite Postconditions
Test Setup        Test Preconditions
Test Teardown     Test Postconditions

*** Variables ***
${LOGGING_ENB_SYSLOG}=             True
${LOGGING_IPHY_SYSLOG}=            True
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True
${LOGGING_EMSSIM_LOG}=             True

*** Test Cases ***

Test7_Local_SWR_with_automatic_reset_enabled_using_CLI_command
    [Tags]   CRT
    [Documentation]  Purpose of the test is to check that WebEM shall support ORU SWR with
    ...   optional reset radio ENABLED

    Local SWR with automatic reset enabled

Test6_Local_SWR_with_automatic_reset_disabled_using_CLI_command
    [Tags]   CRT
    [Documentation]  Purpose of the test is to check that WebEM shall support ORU SWR with
    ...   optional reset radio DISABLED

    Local SWR with automatic reset disabled
