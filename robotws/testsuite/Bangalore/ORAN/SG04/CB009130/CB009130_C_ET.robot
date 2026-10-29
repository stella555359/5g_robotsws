*** Settings ***
Documentation
...    Author: rafal.zajac@nokia.com; pawel.kuzminski@nokia.com; jaroslaw.stolarczyk@nokia.com
...    Maintainer:
...    Test Description: Feature extends CB009098 by adding multi-band, multi-carrier and LTE support to the new
...    triple-band RU.
...    Confluence link: link
...    Group in charge:
...    References: https://gates.nsn-net.net/view/0002659b#o=0
...    QualityCenter:
...    Sample execution: python3 --variable CONFIGURATION:Wroclaw.XXX -b debug.log -d /home/ute/results/ /home/ute/
...    Review: -
...    AC/REQ:
Library     ute_fsmaccess
Resource    	  ./testsuite/Bangalore/ORAN/SG04/CB009130/resources/CB009130_ET_keywords.robot

Suite Setup       Run keywords		Suite Preconditions		AND		Copy files to Docker	AND
...				  Check RAT
Test Setup        ORAN Preconditions
Test Teardown     Run keywords		Test Postconditions Without WTSSIM S1
Suite Teardown    Suite Postconditions
Force Tags        CRT  SBTS23R2    SBTS23R1  FL00    QCD_MN_RAN   QCP_RAN_VRF

*** Variables ***
${LOGGING_ENB_SYSLOG}=             True
${LOGGING_IPHY_SYSLOG}=            False
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True
${LOGGING_EMSSIM_LOG}=             False
${RAT}      nr

*** Test Cases ***

#[2.0] TC_02 O-DU shall process the alarm information from the retrieved O-RU active alarm list and from the received O-RU alarm notification message
#        [2]O-DU shall process the alarm information from the retrieved O-RU active alarm list and from the received O-RU alarm notification message

#[2.0] TC_06 O-DU shall support O-RAN common fault ID with antenna line fault source received from O-RU
#        [6]O-DU shall support O-RAN common fault ID with antenna line fault source received from O-RU

[2.0] TC_03 O-DU shall map the received fault with O-RAN common fault ID to a Nokia fault ID when disableORUHWValidation is set to true
       [3]O-DU shall map the received fault with O-RAN common fault ID to a Nokia fault ID when disableORUHWValidation is set to true

#[2.0] TC_07 O-DU shall calculate the fault severity of TX RX path out of order fault
#        [7]O-DU shall calculate the fault severity of TX RX path out of order fault

#[2.0] TC_04 O-DU shall map the received fault with O-RAN common fault ID to a Nokia fault ID when disableORUHWValidation is set to false
#        [4]O-DU shall map the received fault with O-RAN common fault ID to a Nokia fault ID when disableORUHWValidation is set to false
