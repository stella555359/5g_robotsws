*** Settings ***
Documentation
...    Author: Moldovan Dan (dan.moldovan@nokia.com)
...    Maintainer: Moldovan Dan (dan.moldovan@nokia.com)
...    Group in charge: MANO_SOAM3
...    References:
...    Feature Description: TL_SETUP
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log -d
...    results/ /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET1/TL_SETUP/general.robot

Resource    ./resources/TL_SETUP.robot
Resource    ./resources/keyword.robot

Suite Setup       Run Keywords  Branch or Trunk Jenkins
...               AND           Get last CIT promotion Build
...               AND           Precondition and DW software
#...               AND           Suite Preconditions
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

TL_SETUP
    [Documentation]
    ...     SWR and check BTS on air
    TL_SETUP

