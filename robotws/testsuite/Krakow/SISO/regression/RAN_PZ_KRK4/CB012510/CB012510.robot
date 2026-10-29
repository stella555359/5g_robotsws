*** Settings ***
Documentation
...    author: Weronika Wojcik
...    contact: weronika.wojcik@nokia.com
...    description: Test Suite CB012510

Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    taf/rfrl/bts/robot/common/gnb_alarm.robot
Resource    testsuite/Krakow/SISO/regression/RAN_PZ_KRK4/CB012510/resources/DataTransfer.robot
Library     taf.rfrl.bts.commissioning
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py



Suite Setup     Common Suite Setup With OnAir Test Line Preparation
     ...     swconfig_from_path=commissionings/${CONFIGURATION.replace('.', '/')}/swconfig.txt
Suite Teardown  Common Suite Teardown
Test Setup      Common Preconditions With Watching Alarms
Test Teardown   Common Postconditions With Watching Alarms

*** Variables ***
${GNB_ID}       ${tl.gnbs[0].global_bts_id}

*** Test Cases ***
General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing
    Run TCP Data Transfer For NR Cells  tolerance=40

Manual_SiSo_CALL_LTE_data_call
    Run TCP Data Transfer For LTE Cells   tolerance=40

