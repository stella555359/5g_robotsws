*** Settings ***
Documentation
...    Author: Zaharia Andreea-Oana
...    Maintainer: Zaharia Andreea-Oana
...    Test Description:
...    AC/REQ:

#Library    SSHLibrary
#Library    OperatingSystem
#Library    ute_fault
#Library    string
#Library    ute_async
#Library    collections
#Library    Selenium2Library
#Library    XML  lxml=True
##Library    Process

Resource    ../../resources/pretest_posttest.robot
Resource    ./resource/5GC001546-AA.robot

Force Tags   STATE_SW_UPLOADED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN
...    CRT    SBTS00    SBTS23R1
...    CLOUD_5G_CLASSICAL_FULLRACK_ASILL_ABIOB1B3_AEQN_ECPRI_ASILR_ABIOB4B6_ENB
...    CA_BTS_OAM_VERIF    master_classicalbts_all

Suite Setup       Run Keywords       UTE TL Preparation
...                                 AND    Suite Preconditions
#Suite Teardown    Suite Postconditions
Test Setup        Test Preconditions
Test Teardown     Test Postconditions

*** Variables ***
${LOGGING_ENB_SYSLOG}=             True
${LOGGING_IPHY_SYSLOG}=            False
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True
${LOGGING_EMSSIM_LOG}=             False


*** Test Cases ***
[1.0] Verify if raw PM files are available for each measurement type after the selected measurement interval has passed.
   # [Tags]     SBTS00   SBTS23R1
     Verify if raw PM files are available for each measurement type

#
