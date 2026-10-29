*** Settings ***
Documentation
...    Author: Alexandru Tancau (alexandru.tancau@nokia.com)
...    Maintainer: Alexandru Tancau (alexandru.tancau@nokia.com)
...    Group in charge: BOAM_VERIF_ET1
...    References: Doors
...    Feature Description:
...    Sample execution: robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET1/CB007017-A/general.robot

Resource    ./resources/CB007017-A.robot
Resource    ../../BOAM_VERIF_ET2/resources/AirPhone/resources/ute/ute_wts_runner.robot

Force Tags   STATE_CONFIGURED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN      SBTS00   SBTS22R4  SBTS23R1
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    CA_RAN_BOAM_VERIF     master_classicalbts_all

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
#11_ROBUSTNESS_TEST_CASE_LTE_OPR_REQ_343_Exception_Fault_4203_after_site_reset
#    [Tags]   CRT
#    [Documentation]  Scope of this test case is to check the connectivity of the BTS with the RTPM simulator in case
#    ...              if the simulator is crashed during site reset.
#    Fault_4203_after_site_reset

3_ROBUSTNESS_LTE_OPR_REQ_343_Enabling_of_PM_counters_real-time_monitoring_5G
    [Tags]      CRT
    [Documentation]  Scope of this test case is to check that real-time monitoring of the PM counters is started for
    ...              a 5G configuration.
    Enabling_of_PM_counters_real-time_monitoring_5G

4_LTE_OPR_REQ_354_Disabling_of_PM_counters_real-time_monitoring_Case1
    [Tags]      CRT
    [Documentation]  Scope of this test case is to check that real-time monitoring of the PM counters is disabled
    ...              when rTPmCollEntity is removed from configuration.
    Disabling_of_PM_counters_real-time_monitoring_Case1

#6_LTE_OPR_REQ_397_Changing_RTPM_related_configuration
#    [Tags]      CRT
#    [Documentation]  Scope of this test case is to check how the configuration of PM counters real-time monitoring is
#    ...              changed by a user.
#    Changing_RTPM_related_configuration
