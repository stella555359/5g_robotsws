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

Resource    ./5GC001525-SA-TA.robot
Resource    ./OAM_Common.robot
Resource    ../../resources/pretest_posttest.robot

#Force Tags   STATE_SW_UPLOADED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN
#...    CLOUD_5G_CLASSICAL_FULLRACK_ASILL_ABIOB1B3_AEQN_ECPRI_ASILR_ABIOB4B6_ENB
#...    CA_BTS_OAM_VERIF    master_classicalbts_all

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
#[1.0] 5GC001525-SA-TA-Fault_generation_1937
   # [Tags]     SBTS00   SBTS22R4   #SBTS22R3
 #    5GC001525-SA-TA-Fault_generation_1937

#[1.0] 5GC001525-SA-TA-Fault_generation_4383
#    [Tags]       REMOVED_20_07_22_regr_opt   #SBTS22R3
#     5GC001525-SA-TA-Fault_generation_4383

[1.0] 5GC001525-SA-TA-Fault_generation_28
   #  [Tags]     SBTS00   SBTS22R4   #SBTS22R3
     5GC001525-SA-TA-Fault_generation_28

#[1.0] 5GC001525-SA-TA-Fault_generation_1850
    # [Tags]     SBTS00   SBTS22R4   #SBTS22R3
#     5GC001525-SA-TA-Fault_generation_1850
