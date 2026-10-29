*** Settings ***

Documentation
...    Author: Moldovan Dan (dan.moldovan@nokia.com)
...    Maintainer: Moldovan Dan (dan.moldovan@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description: CB006615-5G-B
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log -d
...    results/ /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET1/CB006615-5G-B/general_SC.robot

Resource    ./resources/CB006615-5G-B.robot
Resource    ./resources/keyword.robot

# Suite Setup       Run Keywords  Suite Preconditions
# #...               AND           Branch or Trunk
# ##...               AND           Download SW
# Suite Teardown    Suite Postconditions
Test Setup        Test Preconditions
Test Teardown     Test Postconditions

*** Variables ***
${LOGGING_ENB_SYSLOG}=             True
${LOGGING_IPHY_SYSLOG}=            True
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True
${LOGGING_EMSSIM_LOG}=             True

*** Test Cases ***
T1_Secondary_Commisionning
    Secondary_Commisionning
