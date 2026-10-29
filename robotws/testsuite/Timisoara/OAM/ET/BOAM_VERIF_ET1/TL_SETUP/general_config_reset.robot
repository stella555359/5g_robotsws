*** Settings ***
Documentation
...    Author: Preda Slavoliub-Denis (slavoliub-denis.preda@nokia.com)
...    Maintainer: Preda Slavoliub-Denis (slavoliub-denis.preda@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description: TL_SETUP
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log -d
...    results/ /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET1/TL_SETUP/general_config_reset.robot

Resource    ./resources/Config_reset_for_branch.robot

#Suite Setup       Run Keywords  Suite Preconditions
Suite Setup       Suite Preconditions
#Suite Teardown    Suite Postconditions
Test Setup        Test Preconditions
#Test Teardown     Test Postconditions

*** Variables ***
${LOGGING_ENB_SYSLOG}=             True
${LOGGING_IPHY_SYSLOG}=            True
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True
${LOGGING_EMSSIM_LOG}=             True

*** Test Cases ***

Config reset for branch
    [Documentation]
    ...     Config reset for SWR
    Config reset for branch



