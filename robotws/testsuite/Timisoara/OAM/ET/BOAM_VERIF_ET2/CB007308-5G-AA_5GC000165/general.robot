*** Settings ***
Documentation
...    Author: Alin Necula (alin.necula@nokia.com)
...    Maintainer: Irina Tanasoiu (irina.tanasoiu@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description:5GC001542-CA
...    Sample execution: /opt/ute/python/bin/pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_FMRECOV/CB007308-5G-AA_5GC000165/general.robot

Resource    ./resources/5GC001542-CA.robot
Resource    ../resources/pretest_posttest.robot

#Force Tags   STATE_CONFIGURED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN  master_classicalbts_all   SBTS22R3
#...    CLOUD_5G_O_E_AP_LO_SANSA_FS_ECPRI_CMWV_TDD #CLOUD_5G_O_E_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD    CLOUD_5G_O_E_AP_KL_SANSA_FS_CPRI_CMWV_FDD
#...    CA_BTS_OAM_FMRECOV    # SBTS22R1  SBTS22R2

Suite Setup       Suite Preconditions
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
[1.0] Check_BTS_counter_view
    [Tags]   CRT  #Regression Optimization – part 2 – July 2022
    [Documentation]
    ...
    5GC001542-CA_Check_BTS_counter_view

[1.0] Check_BTS_transport_counters
    [Tags]   CRT  #Regression Optimization – part 2 – July 2022
    [Documentation]
    ...
    5GC001542-CA_Check_BTS_transport_counters
