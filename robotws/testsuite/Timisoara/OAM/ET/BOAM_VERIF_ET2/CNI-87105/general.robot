*** Settings ***
Documentation
...    Author: Zaharia Andreea-Oana (andreea-oana.zaharia@nokia.com)
...    Maintainer: Zaharia Andreea-Oana (andreea-oana.zaharia@nokia.com)
...    Group in charge: BTS_OAM_VERIF_ET4
...    References: doors
...    Feature Description: CNI-87105
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/MN/UTE/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET2/CNI-87105/general.robot


Resource    ../resources/pretest_posttest.robot
Resource    ./resources/CNI87105.robot
Resource    ./../resources/AirPhone/resources/ute/ute_wts_runner.robot

Force Tags   STATE_CONFIGURED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN  master_classicalbts_all   SBTS00
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    CA_RAN_BOAM_VERIF   CA_BTS_OAM_FMRECOVCP_BTS_OAM   QCD_MN_BTS_OAM   #21A_classicalbts  #20Bb1_classicalbts    SBTS22R1  SBTS22R2


Suite Setup       Run Keywords     Reach OnAir Setup for LO_AP_LO
...               AND              Suite Preconditions
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
Fault_9102_Check_if_7th_RF_recovery_ action_is_not_executed_within_one_hour
    [Tags]   CRT
    [Documentation]
    ...
    Fault_9102_Check_if_7th_RF_recovery_ action_is_not_executed_within_one_hour

