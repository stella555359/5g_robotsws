*** Settings ***
Documentation
...    Author: George Medesan (george.medesan@nokia.com)
...    Maintainer: George Medesan (george.medesan@nokia.com)
...    Group in charge: BTS_OAM_VERIF_ET1
...    References: doors
...    Feature Description:CB005958-5G
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET1/CB007326_CB005958-5G/general.robot

Resource    ./resources/CB005958-5G.robot
Resource    ../resources/AirPhone/resources/ute/ute_wts_runner.robot

#Force Tags   STATE_CONFIGURED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN  master_classicalbts_all
#...    CLOUD_5G_O_E_AP_LO_SANSA_FS_ECPRI_CMWV_TDD   SBTS00    SBTS22R4  SBTS23R1
#...    CA_RAN_BOAM_VERIF

Suite Setup       Run Keywords    Reach OnAir Setup for OE
...               AND             Suite Preconditions

Suite Teardown    Run Keywords    Reach OnAir Teardown
...               AND             Suite Postconditions


Test Setup        Test Preconditions
Test Teardown     Test Postconditions  #With Reset Site

*** Variables ***
${LOGGING_ENB_SYSLOG}=             True
${LOGGING_IPHY_SYSLOG}=            True
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True
${LOGGING_EMSSIM_LOG}=             True

*** Test Cases ***
#Test_new version
#    [Tags]   CIT
#    [Documentation]
#    ...
#    Test_new version

M55601C01001-NR_CELL_PLAN_UNAVAIL_SAMPLES_WebEM
    [Tags]   CRT
    [Documentation]
    ...
    M55601C01001-NR_CELL_PLAN_UNAVAIL_SAMPLES_WebEM

M55601C01002-NR_CELL_PLAN_UNAVAIL_CHNG_TO_WebEM
    [Tags]   CRT
    [Documentation]
    ...
    M55601C01002-NR_CELL_PLAN_UNAVAIL_CHNG_TO_WebEM

#Robustness_testing_Check_if_value_of_NR_CELL_PLAN_UNAVAIL_CHNG_TO_is_incremented
#    [Tags]   CRT    #merged with M55601C01002-NR_CELL_PLAN_UNAVAIL_CHNG_TO_WebEM
#    [Documentation]
#    ...
#    Robustness_testing_Check_if_value_of_NR_CELL_PLAN_UNAVAIL_CHNG_TO_is_incremented

#M55601C01003-NR_CELL_UNPLAN_UNAVAIL_SAMPLES_WebEM
#    [Tags]   CRT    #merged with M55601C01001-NR_CELL_PLAN_UNAVAIL_SAMPLES_WebEM
#    [Documentation]
#    ...
#    M55601C01003-NR_CELL_UNPLAN_UNAVAIL_SAMPLES_WebEM


