*** Settings ***
Documentation       NF
...                 Author: Wu Amy
...                 Contact: amy.wu@nokia-sbell.com
Suite Teardown    Common Suite Teardown
Test Timeout    2h
Variables     ../test_line_specific/SBTS_SYVE_11227/My_Variables.py
Variables     ../test_line_specific/Variables/NetActs.py
Resource  ../test_resources/CM/CM__CB007518-C_007_CM_SR_Verification_Of_Pre-defined_RU_After_It_Connect_To_BTS_Multiple_Times.robot

*** Test Cases ***
[1] CM__CB007518-C_007_CM_SR_Verification_Of_Pre-defined_RU_After_It_Connect_To_BTS_Multiple_Times
    [Setup]    Test Setup
    CM__CB007518-C_007_CM_SR_Verification_Of_Pre-defined_RU_After_It_Connect_To_BTS_Multiple_Times
    [Teardown]    Test Teardown
