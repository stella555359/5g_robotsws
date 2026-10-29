*** Settings ***
Documentation
...    Author: Andreea-Oana Zaharia (andreea-oana.zaharia@nokia.com)
...    Maintainer: Andreea-Oana Zaharia (andreea-oana.zaharia@nokia.com)
...    Group in charge: BTS_OAM_VERIF_ET4
...    References: doors
...    Feature Description:CB006006
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET1/CB007426_CB006006/general.robot

Resource    ./resources/CB006006.robot
Resource    ../resources/AirPhone/resources/ute/ute_wts_runner.robot
Resource    ../resources/pretest_posttest.robot

Force Tags   STATE_CONFIGURED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN    master_classicalbts_all     SBTS00
...    CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    CA_BTS_OAM_FMRECOV


Suite Setup       Run Keywords    Suite Preconditions
Suite Teardown    Run Keywords    Suite Postconditions

Test Setup        Test Preconditions
Test Teardown     Test Postconditions

*** Variables ***
${LOGGING_ENB_SYSLOG}=             True
${LOGGING_IPHY_SYSLOG}=            True
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True
${LOGGING_EMSSIM_LOG}=             True

*** Test Cases ***

SFP_Monitoring_Transmission_mode_parameter_removed
    [Tags]   CRT
    [Documentation]
    ...
    SFP_Monitoring_Transmission_mode_parameter_removed

Activate_the_counters_for_monitoring_Tx_power_Rx _power_and_Tx_bias_current_per_lane
    [Tags]   CRT  CDRT
    [Documentation]
    ...
    Activate_the_counters_for_monitoring_Tx_power_Rx _power_and_Tx_bias_current_per_lane
