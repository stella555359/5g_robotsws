*** Settings ***
Force Tags    PY39    RF50

Documentation
...        author: Emilia Sadowska
...        contact: emilia.sadowska@nokia.com
...        description: Automated triggerring on demand run testsuite with AirPhone.

Resource    ${CURDIR}/../../../../Bangalore/AirPhone/QT/resources/Keywords/common_keywords.robot
Resource    ${CURDIR}/../../../../Bangalore/AirPhone/QT/resources/Keywords/allowed_alarms.robot
Resource    ${CURDIR}/../../resources/robot/airphone.robot
Library     ${CURDIR}/../../resources/python/airphone.py

Suite Setup       Run Keywords    Run Keyword And Ignore Error    Checkout To Robotws Branch
...               AND             Set Global Variable    ${component_carrier}    2
...               AND             Set Global Variable    ${WTS_CONFIG}           ${True}
...               AND             Set Global Variable    ${TEST STATUS}          Fail    #Gather logs independently from test results
...               AND             Set Global Variable    ${QT_CONFIG}            True
...               AND             Common Optimized Suite Setup
...               AND             Get Baseline
...               AND             Run Keyword And Ignore Error    Setup And Connect IM
Suite Teardown    Run Keywords    Common Suite Teardown
...               AND             Copy logs to test_results

*** Test Cases ***
Quick_Test_as_a_Service_AirPhone_fullscope
    [Documentation]
    ...    This test case is designed to run a fullscope test for AirPhone on QT's testsuite for Quick Test as a Service
    Installation of gNB package
    Verify Ng Link Status
    X2 Connection
    Verify Cell Setup for AP
    Commissioning
    Verify Ng Link Status After Commissioning
    X2 Connection After Commissioning
    Verify Cell Setup for AP After Commissioning
    UE Attach
    UE Data Transfer
    UE Detach
    Install gNB package T1
    Verify Ng Link Status T1
    X2 Connection T1
    Verify Cell Setup for AP T1
    Check Active And Historical Alarms

Quick_Test_as_a_Service_AirPhone_install_package_T0_T1
    Installation of gNB package
    Verify Ng Link Status
    X2 Connection
    Verify Cell Setup for AP
    Install gNB package T1
    Verify Ng Link Status T1
    X2 Connection T1
    Verify Cell Setup for AP T1
    Check Active And Historical Alarms

Quick_Test_as_a_Service_AirPhone_install_package_T0_and_commissioning
    Installation of gNB package
    Verify Ng Link Status
    X2 Connection
    Verify Cell Setup for AP
    Commissioning
    Verify Ng Link Status After Commissioning
    X2 Connection After Commissioning
    Verify Cell Setup for AP After Commissioning

Quick_Test_as_a_Service_AirPhone_test_call
    X2 Connection
    Verify Cell Setup for AP
    UE Attach
    UE Data Transfer
    UE Detach

*** Keywords ***
Installation of gNB package
    Stop Edaemon Egate
    Install gNB package    sw_version=${sw_version}
    Check SW version
    Wait until Keyword Succeeds    3x    10s    Run WTS

Verify Ng Link Status
    [Documentation]    -SA- Check if "NG link is UP" message can be found in egate console and egate_console.log
    ...                -SANSA- Check if "Address Distribution is complete" message can be found in APL3.log
    ...                -SA- Check if "SystemInformationBlockType1" message can be found in egate console and egate_console.log
    NG Link Should be UP
    Run Keyword    Log to console    \nNG link after T0 package installation is OK
    Address Distribution should be Successful
    UE SIB Decoding should be Successful
    BuiltIn.Sleep    5s

X2 Connection
    [Documentation]    -NSA- check if "X2AP Link with GNB" msg found in egate console
    X2AP Link Should be UP
    Run Keyword    Log to console    \nx2 link after T0 package installation is OK
    BuiltIn.Sleep    5s

Verify Cell Setup for AP
    [Documentation]    -SANSA- Check if "Cell Setup completed" message can be found in APL3.log
    AP Cell Setup should be Successful
    Run Keyword    Log to console    \nCell setup after T0 package installation is OK
    Test Teardown for Cell Setup

Commissioning
    Perform commissioning
    Wait until Keyword Succeeds    3x    10s    Run WTS

Verify Ng Link Status After Commissioning
    [Documentation]    -SA- Check if "NG link is UP" message can be found in egate console and egate_console.log
    ...                -SANSA- Check if "Address Distribution is complete" message can be found in APL3.log
    ...                -SA- Check if "SystemInformationBlockType1" message can be found in egate console and egate_console.log
    NG Link Should be UP
    Run Keyword    Log to console    \nNG link after Commissioning is OK
    Address Distribution should be Successful
    UE SIB Decoding should be Successful
    BuiltIn.Sleep    5s

X2 Connection After Commissioning
    [Documentation]    -NSA- check if "X2AP Link with GNB" msg found in egate console
    X2AP Link Should be UP
    Run Keyword    Log to console    \nx2 link after Commissioning is OK
    BuiltIn.Sleep    5s

Verify Cell Setup for AP After Commissioning
    [Documentation]    -SANSA- Check if "Cell Setup completed" message can be found in APL3.log
    AP Cell Setup should be Successful
    Run Keyword    Log to console    \nCell setup after Commissioning is OK

UE Attach
    [Documentation]    -SA- Check if UE registers
    ...                -SA- Check if UE deregisters
    ...                -SA- Check if UE reregisters
    ...                -NSA- Check if UE attaches to NR
    UE Register should be Successful for SANSA
    UE Deregister should be Successful
    UE Reregister should be Successful for SANSA
    LTE Attach should be Successful
    UE Attach should be Successful
    Run Keyword    Log to console    \nUE Attach is OK
    Run Keyword    Pre_Check

UE Data Transfer
    [Documentation]    -SA- -NSA- Traffic
    Start and Validate Traffic For Mixed Mode
    Run Keywords
    ...    Stop Attach and Data Traffic TCPDUMP    AND
    ...    Delete Pcaps from Traffic

UE Detach
    [Documentation]    -NSA- Check if UE detaches to NR
    ...                -NSA- Check if UE detaches to LTE
    ...                -NSA- Check if UE attaches to NR
    UE 5GDetach should be Successful
    UE Detach should be Successful
    Run Keyword    Log to console    \nUE Deach is OK
    Run Keyword    Collect gNB Snapshot via adminAPI

Install gNB package T1
    Install gNB package    sw_version=${sw_version}    component=T1
    BuiltIn.Sleep    300s
    Check SW version       component=T1
    Wait until Keyword Succeeds    3x    10s    Run WTS

Verify Ng Link Status T1
    [Documentation]    -SA- Check if "NG link is UP" message can be found in egate console and egate_console.log
    ...                -SANSA- Check if "Address Distribution is complete" message can be found in APL3.log
    ...                -SA- Check if "SystemInformationBlockType1" message can be found in egate console and egate_console.log
    NG Link Should be UP
    Run Keyword    Log to console    \nNG link after T1 package installation is OK
    Address Distribution should be Successful
    UE SIB Decoding should be Successful
    BuiltIn.Sleep    5s

X2 Connection T1
    [Documentation]    -NSA- check if "X2AP Link with GNB" msg found in egate console
    X2AP Link Should be UP
    Run Keyword    Log to console    \nx2 link after T1 package installation is OK
    BuiltIn.Sleep    5s

Verify Cell Setup for AP T1
    [Documentation]    -SANSA- Check if "Cell Setup completed" message can be found in APL3.log
    AP Cell Setup should be Successful
    Run Keyword    Log to console    \nCell setup after T1 package installation is OK

Check Active And Historical Alarms
    Append To List    ${AP_ALLOWED_ALARMS}    7308
    Check Alarms In Ims File    name=_all_test_    allowed_alarms=${AP_ALLOWED_ALARMS}
    Run Keyword    Log to console    \nAlarms chcecked in Ims File, no not allowed alarms were found