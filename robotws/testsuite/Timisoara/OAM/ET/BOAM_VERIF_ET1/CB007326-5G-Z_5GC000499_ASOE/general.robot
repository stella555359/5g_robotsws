*** Settings ***
Documentation
...    Author: Radu Turcu (radu.turcu@nokia.com)
...    Maintainer: Radu Turcu (radu.turcu@nokia.com)
...    Group in charge: BTS_OAM_VERIF_ET1
...    References: doors
...    Feature Description:CB007326-5G-Z_5GC000499
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET1/CB007326-5G-Z_5GC000499_ASOE/general.robot

Resource    ./resources/5GC002056-AZ_5GC000499.robot
Resource    ../resources/AirPhone/resources/ute/ute_wts_runner.robot

#Force Tags   STATE_CONFIGURED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN  master_classicalbts_all
#...    CLOUD_5G_O_E_AP_LO_SANSA_FS_ECPRI_CMWV_TDD   SBTS00    SBTS22R4  SBTS23R1   #CLOUD_5G_O_E_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD  SBTS22R3
#...    CA_RAN_BOAM_VERIF

Suite Setup       Suite Preconditions
Suite Teardown    Suite Postconditions


Test Setup        Test Preconditions
Test Teardown     Test Postconditions  #With Reset Site

*** Variables ***
${LOGGING_ENB_SYSLOG}=             True
${LOGGING_IPHY_SYSLOG}=            True
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True
${LOGGING_EMSSIM_LOG}=             True

*** Test Cases ***
#Check_if_PM_result_file_is_generated_every_5m
#    [Tags]   CRT
#    [Documentation]
#    ...
#    Check_if_PM_result_file_is_generated_every_5m

Verify_if_raw_PM_files_are_available_for_each_measurement_type
    [Tags]   CRT     #merged with Check_if_PM_result_file_is_generated_every_5m
    [Documentation]
    ...
    Verify_if_raw_PM_files_are_available_for_each_measurement_type
