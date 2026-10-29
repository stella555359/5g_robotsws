*** Settings ***
Documentation
...   Test suite for regression testing of CNI-142598
...   author: Przemyslaw Herian
...   contact: przemyslaw.herian@nokia.com

Resource     ./resources/robot_keywords.robot
Variables    resources/variables.py

Suite Setup          Suite Setup
Test Setup           Test Setup
Test Teardown        Test Teardown
Suite Teardown       Suite Teardown

*** Test Cases ***
[1]CNI-142598_01_FDD_Verify_Fault_4710_Shorter_SyncE_Holdover
    Perform Delta Commissioning On gNB      ${feature_enable}
    Alarms.Wait For Alarm Activation    fault_id=4710    awaiting_time=300
    Alarms.Wait For Alarm Activation    fault_id=4712    awaiting_time=300
    Perform Delta Commissioning On gNB      ${feature_disable}
    Alarms.Wait For Alarm Deactivation    fault_id=4710    awaiting_time=300
    Alarms.Wait For Alarm Deactivation    fault_id=4712    awaiting_time=300
