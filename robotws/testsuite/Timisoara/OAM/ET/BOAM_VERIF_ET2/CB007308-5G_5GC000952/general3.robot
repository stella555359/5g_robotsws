*** Settings ***

Documentation
...    Author: Zaharia Andreea-Oana (andreea-oana.zaharia@nokia.com)
...    Maintainer: Zaharia Andreea-Oana (andreea-oana.zaharia@nokia.com)
...    Group in charge: BTS_OAM_VERIF
...    References: doors
...    Feature Description: CB007380-5G_5GC000952
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_FMRECOV/CB007308-5G_5GC000952/general.robot


Resource    ./resources/5GC000952.robot
Resource    ../resources/AirPhone/resources/ute/ute_wts_runner.robot

#Force Tags   STATE_CONFIGURED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN  master_classicalbts_all   #21A_classicalbts  #20Bb1_classicalbts
#...    CLOUD_5G_O_E_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD    CLOUD_5G_O_E_AP_LO_SANSA_FS_ECPRI_CMWV_TDD  #CLOUD_5G_O_E_AP_KL_SANSA_FS_CPRI_CMWV_FDD
#...    SBTS00   SBTS22R1   CA_RAN_BOAM_VERIF   CA_BTS_OAM_FMRECOV    #QCP_BTS_OAM    QCD_MN_BTS_OAM


Suite Setup       Suite Preconditions
Suite Teardown    Suite Postconditions
Test Setup        Run Keywords    Reach OnAir Setup for OE
...               AND             Test Preconditions
Test Teardown     Run Keywords    Reach OnAir Teardown
...               AND             Test Postconditions


*** Variables ***
${LOGGING_ENB_SYSLOG}=             True
${LOGGING_IPHY_SYSLOG}=            True
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True
${LOGGING_EMSSIM_LOG}=             True


*** Test Cases ***
 5GC000952_ASOE_Check_if_Site_recovery_reset_counter_is_cleared_and_Check_if_transient_alarm_is_reported_in_WebEM
    [Tags]   CRT
    [Documentation]
    ...
   5GC000952_ASOE_Check_if_Site_recovery_reset_counter_is_cleared_and_Check_if_transient_alarm_is_reported_in_WebEM
