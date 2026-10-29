*** Settings ***
Documentation
...    Author: Radu Turcu (radu.turcu@nokia.com)
...    Maintainer: Radu Turcu (radu.turcu@nokia.com)
...    Group in charge: BTS_OAM_VERIF_ET1
...    References: doors
...    Feature Description:CB006006
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET1/CB006006_ASOE/general.robot

Resource    ./resources/CB006006.robot
Resource    ../resources/AirPhone/resources/ute/ute_wts_runner.robot
Resource    ../resources/pretest_posttest.robot

#Force Tags   STATE_SW_UPLOADED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN  master_classicalbts_all
#...   CLOUD_5G_CLASSICAL_ASOE_AEQN   SBTS00    SBTS23R1   #SBTS22R3  SBTS22R4
#...   CA_RAN_BOAM_VERIF

#Suite Setup       Suite Preconditions
#Suite Teardown    Suite Postconditions
#Suite Setup       Run Keywords  Suite Preconditions
#...               AND           ADMIN_CLI Suite Setup

Suite Setup       Run Keywords    UTE TL Preparation
...               AND             Suite Preconditions
...               AND             ADMIN_CLI Suite Setup
#
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
#[1]8.SFP_Monitoring_Transmission_mode_parameter_removed
#    [Tags]   CRT                                      # TC already covered by ST team
#    [Documentation]
#    ...
#    8.SFP_Monitoring_Transmission_mode_parameter_removed

[1]10.Activate_the_counters_for_monitoring_SFP_module_temperature
    [Tags]   CRT
    [Documentation]
    ...
    10.Activate_Deactivate_the_reporting_of_the_counters_for_monitoring_SFP_module_temperature

[1]12.Activate_the_counters_for_monitoring_Tx_power_Rx _power_and_Tx_bias_current_per_lane
    [Tags]   CRT  CDRT
    [Documentation]
    ...
    12.Act_Deact_the_reporting_of_the_counters_for_monitoring_Tx_power_Rx_power_and_Tx_bias_current_per_lane

[1]14.Get_SFP_Data_using_WebEM_CLI
    [Tags]   CRT
    [Documentation]
    ...
    14.WebEM CLI shall support command sfpData
