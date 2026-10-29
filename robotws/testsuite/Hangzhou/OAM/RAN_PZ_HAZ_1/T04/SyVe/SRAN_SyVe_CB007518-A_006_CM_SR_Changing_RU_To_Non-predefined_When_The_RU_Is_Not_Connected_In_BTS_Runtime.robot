*** Settings ***
Documentation       NFTA
...                 Author: Wu Amy
...                 Contact: amy.wu@nokia-sbell.com
Suite Teardown    Common Suite Teardown
Test Timeout    2h
Variables     ../test_line_specific/SBTS_SYVE_11227/My_Variables.py
Variables     ../test_line_specific/Variables/NetActs.py
Resource  ../test_resources/SyVe/SRAN_SyVe_CB007518-A_006_CM_SR_Changing_RU_To_Non-predefined_When_The_RU_Is_Not_Connected_In_BTS_Runtime.robot

*** Test Cases ***
[1] SRAN_SyVe_CB007518-A_006_CM_SR_Changing_RU_To_Non-predefined_When_The_RU_Is_Not_Connected_In_BTS_Runtime
    [Setup]    Test Setup
    SRAN_SyVe_CB007518-A_006_CM_SR_Changing_RU_To_Non-predefined_When_The_RU_Is_Not_Connected_In_BTS_Runtime
    [Teardown]    Test Teardown
