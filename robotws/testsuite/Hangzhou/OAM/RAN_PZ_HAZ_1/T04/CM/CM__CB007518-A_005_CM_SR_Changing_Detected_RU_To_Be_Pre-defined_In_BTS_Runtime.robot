*** Settings ***
Documentation       Test suite for CB007518
...                 Author: Wu Amy
...                 Contact: amy.wu@nokia-sbell.com
Suite Teardown    Common Suite Teardown
Test Timeout    2h
Variables     ../test_line_specific/SBTS_SYVE_11227/My_Variables.py
Variables     ../test_line_specific/Variables/NetActs.py
Resource  ../test_resources/CM/CM__CB007518-A_005_CM_SR_Changing_Detected_RU_To_Be_Pre-defined_In_BTS_Runtime.robot

*** Test Cases ***
[1] CM__CB007518-A_005_CM_SR_Changing_Detected_RU_To_Be_Pre-defined_In_BTS_Runtime
    [Setup]    Test Setup
    CM__CB007518-A_005_CM_SR_Changing_Detected_RU_To_Be_Pre-defined_In_BTS_Runtime
    [Teardown]    Test Teardown
