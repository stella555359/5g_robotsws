*** Settings ***
Documentation
...    Author: George Medesan (george.medesan@nokia.com)
...    Maintainer: George Medesan (george.medesan@nokia.com)
...    Group in charge: BTS_OAM_VERIF
...    References: doors
...    Feature Description:CB007308_5GC000170
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET1/CB007308_5GC000170/general.robot

Resource    ./resources/CB007308_5GC000170.robot
Resource    ../resources/AirPhone/resources/ute/ute_wts_runner.robot

Force Tags   STATE_CONFIGURED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN  master_classicalbts_all
...  CLOUD_5G_O_E_AP_LO_SANSA_FS_ECPRI_CMWV_TDD  SBTS00  SBTS22R4  SBTS23R1   #CLOUD_5G_O_E_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD   SBTS22R3 
...    CA_RAN_BOAM_VERIF


Suite Setup       Run Keywords     Suite Preconditions
...               AND             Set Suite Variable  ${BTS_Side}  1

Suite Teardown    Suite Postconditions

Test Setup        Run Keywords     Test Preconditions
...               AND              Branch or Trunk
Test Teardown     Test Postconditions

#Test Setup        Run Keywords     Reach OnAir Setup for OE
#...               AND              Test Preconditions
#Test Teardown     Run Keywords     Reach OnAir Teardown
#...               AND              Test Postconditions


*** Variables ***
${LOGGING_ENB_SYSLOG}=             True
${LOGGING_IPHY_SYSLOG}=            True
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True
${LOGGING_EMSSIM_LOG}=             True

*** Test Cases ***

5GC000170_ASOE_Check_if_Site_recovery_reset_counter_is_incremented_and_if_BTS_reaches_onAir_after_Site_reset
    [Tags]   CRT
    [Documentation]
    ...
    5GC000170_ASOE_Check_if_Site_recovery_reset_counter_is_incremented_and_if_BTS_reaches_onAir_after_Site_reset
