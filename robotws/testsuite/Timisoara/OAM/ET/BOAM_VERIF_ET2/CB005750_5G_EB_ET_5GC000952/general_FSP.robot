*** Settings ***
Documentation
...    Author: Natalia Grun (natalia.grun@nokia.com)
...    Maintainer: Natalia Grun (natalia.grun@nokia.com)
...    Group in charge: BTS_OAM_VERIF
...    References: doors
...    Feature Description: CB005750_5G_EB_ET_5GC000952
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET2/CB005750_5G_EB_ET_5GC000952/general_FSP.robot


Resource    ./resources/5GC000952.robot
Resource    ../resources/AirPhone/resources/ute/ute_wts_runner.robot

Force Tags  STATE_CONFIGURED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN       SBTS00    SBTS23R1
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD          #CLOUD_5G_I_LO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD  
...    CA_RAN_BOAM_VERIF  CA_BTS_OAM_VERIF   #QCP_BTS_OAM    QCD_MN_BTS_OAM
#    21A_classicalbts   master_classicalbts_all     #SBTS21B  SBTS22R1  SBTS22R2   SBTS22R3     SBTS22R4

Suite Setup       Run Keywords    Reach OnAir Setup for LO_AP_LO
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
5GC000952_ASIL_ABIO_Check_if_4th_FSP_recovery_reset_within_1_hour_is_not_executed
    [Tags]   CRT
    [Documentation]
    ...
    5GC000952_ASIL_ABIO_Check_if_4th_FSP_recovery_reset_within_1_hour_is_not_executed

#5GC000952_ASIL_ABIO_Check_if_FSP_recovery_reset_counter_is_incremented_and_Check_if_transient_alarm_is_reported_in_WebEM
#    [Documentation]
#    ...
#    5GC000952_ASIL_ABIO_Check_if_FSP_recovery_reset_counter_is_incremented_and_Check_if_transient_alarm_in_WebEM
#
#5GC000952_ASIL_ABIO_Check_if_FSP_recovery_reset_counter_is_cleared_after_1_hour_and_after_Site_reset
#    [Tags]   CRT
#    [Documentation]
#    ...
#    5GC000952_ASIL_ABIO_Check_if_FSP_recovery_reset_counter_is_cleared_after_1_hour_and_after_Site_reset
