*** Settings ***
Documentation
...   Test suite for regression testing of feature CB012611
...   author: Przemyslaw Herian
...   contact: przemyslaw.herian@nokia.com

Resource     ./resources/CB012611_keywords.robot

Suite Setup          Suite Setup
...                  prefix_tag_GNB=${prefix_tag_GNB}
...                  prefix_tag_ASIR=${prefix_tag_ASIR}
Test Setup           Test Setup
Test Teardown        Test Teardown
Suite Teardown       Suite Teardown

*** Test Cases ***
[1]CB012611-SR-A_TC01_Single_Loki_permanent_failure_basic_configuration
    Trigger Loki failure
    Wait Until Keyword Succeeds     120 sec     10 sec     Verify ABIO status is degraded
    Verify cells on Loki are failed
    Verify fault ID 252 is raised with critical severity
    Trigger Loki recovery
    Reset gNB
    Wait Until Keyword Succeeds    3x    60s    Wait For Site To Be Onair
    gnbalarm.Wait For Alarm Deactivation    fault_id=1868    awaiting_time=10
