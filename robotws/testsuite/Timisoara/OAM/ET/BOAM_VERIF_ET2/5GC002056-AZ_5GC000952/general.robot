*** Settings ***
Documentation
...    Author: Natalia Grun (natalia.grun@nokia.com)
...    Maintainer: Natalia Grun (natalia.grun@nokia.com)
...    Group in charge: BTS_OAM_VERIF
...    References: doors
...    Feature Description:5GC002056-AZ_5GC000952
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_FMRECOV/5GC002056-AZ_5GC000952/general.robot

Resource    ./resources/5GC000952.robot
Resource    ../resources/AirPhone/resources/ute/ute_wts_runner.robot

#Force Tags   STATE_CONFIGURED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN       # SBTS00   SBTS22R1   #regression optimization
#...    CLOUD_5G_I_BO_AP_KL_NSA_L1B_ECPRI_CMWV_TDD   CLOUD_5G_BO_AP_NSA_L1B_ECPRI_CMWV_TDD
#...    CA_BTS_OAM_FMRECOV    #QCP_BTS_OAM    QCD_MN_BTS_OAM   #21A_classicalbts  master_classicalbts_all    #SBTS21B 


Suite Setup       Run Keywords    Reach OnAir Setup for BO
...               AND             Suite Preconditions
Suite Teardown    Run Keywords    Reach OnAir Teardown
...               AND             Suite Postconditions

Test Setup        Test Preconditions
Test Teardown     Test Postconditions


*** Variables ***
${LOGGING_ENB_SYSLOG}=             True
${LOGGING_IPHY_SYSLOG}=            True
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True
${LOGGING_EMSSIM_LOG}=             True


*** Test Cases ***
5GC000952_ABION_Check_if_4th_Site_recovery_reset_within_1_hour_is_not_executed
    [Tags]   CRT
    [Documentation]
    ...
    5GC000952_ABION_Check_if_4th_Site_recovery_reset_within_1_hour_is_not_executed


5GC000952_ABION_Check_if_Site_recovery_reset_counter_is_incremented_and_if_BTS_reaches_onAir_after_Site_reset
    [Tags]   CRT
    [Documentation]
    ...
    5GC000952_ABION_Check_if_Site_recovery_reset_counter_is_incremented_and_if_BTS_reaches_onAir_after_Site_reset


5GC000952_ABION_Check_if_Site_recovery_reset_counter_is_cleared_and_Check_if_transient_alarm_is_reported_in_WebEM
    [Tags]   CRT
    [Documentation]
    ...
    5GC000952_ABION_Check_if_Site_recovery_reset_counter_is_cleared_and_Check_if_transient_alarm_is_reported_in_WebEM

