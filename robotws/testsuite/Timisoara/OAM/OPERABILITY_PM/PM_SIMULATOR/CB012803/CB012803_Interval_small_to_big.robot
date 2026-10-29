*** Settings ***
Documentation
...    Author: Denisa-Maria Coras (denisa.coras@nokia.com)
...    Maintainer: Denisa-Maria Coras (denisa.coras@nokia.com)
...    Group in charge: I_MN_RAN_BOAM_OPERABILITY_PM_GMS
...    References: doors
...    Feature Description: CB012803
...    Sample execution: robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log -d results/
...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/OAM/OPERABILITY_PM/PM_SIMULATOR/CB012803/CB012803_Interval_small_to_big.robot

Resource    ./resources/CB012803.robot
Resource    ../../../ET/BOAM_VERIF_ET2/resources/pretest_posttest.robot
Resource    ../../../ET/BOAM_VERIF_ET2/resources/system.robot
Resource    ../../../ET/BOAM_VERIF_ET2/resources/AirPhone/resources/ute/ute_wts_runner.robot

#Force Tags   STATE_CONFIGURED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN   SBTS00  SBTS24R2   master_classicalbts_all
#...    CLOUD_5G_I_LO_AP_LO
#...    CA_BTS_OAM_FMRECOV

Suite Setup       Suite Preconditions
Suite Teardown    Suite Postconditions
Test Setup        Test Preconditions
Test Teardown     Test Postconditions

*** Variables ***
${LOGGING_ENB_SYSLOG}=             True
${LOGGING_IPHY_SYSLOG}=            True
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True
${LOGGING_EMSSIM_LOG}=             True

*** Test Cases ***
CB012803_Interval_small_to_big
    CB012803_Interval_small_to_big
