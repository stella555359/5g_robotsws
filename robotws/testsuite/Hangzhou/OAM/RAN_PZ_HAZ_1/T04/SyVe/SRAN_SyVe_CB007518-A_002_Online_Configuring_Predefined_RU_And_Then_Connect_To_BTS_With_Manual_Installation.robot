*** Settings ***
Documentation       NFTA
...                 Author: Wu Amy
...                 Contact: amy.wu@nokia-sbell.com
Suite Teardown    Common Suite Teardown
Test Timeout    2h
Variables     ../test_line_specific/SBTS_SYVE_11227/My_Variables.py
Variables     ../test_line_specific/Variables/NetActs.py
Resource  ../test_resources/SyVe/SRAN_SyVe_CB007518-A_002_Online_Configuring_Predefined_RU_And_Then_Connect_To_BTS_With_Manual_Installation.robot

*** Test Cases ***
[1] SRAN_SyVe_CB007518-A_002_CM_SR_Online_Configuring_Pre-defined_RU_And_Then_Connect_To_BTS_With_Manual_Installation
    [Setup]    Test Setup
    SRAN_SyVe_CB007518-A_002_CM_SR_Online_Configuring_Pre-defined_RU_And_Then_Connect_To_BTS_With_Manual_Installation
    [Teardown]    Test Teardown
