*** Settings ***
Documentation       NFTA
...                 Author: Wu Amy
...                 Contact: amy.wu@nokia-sbell.com
Suite Teardown    Common Suite Teardown
Test Timeout    2h
Variables     ../test_line_specific/SBTS_SYVE_11227/My_Variables.py
Variables     ../test_line_specific/Variables/NetActs.py
Resource  ../test_resources/SyVe/SRAN_SyVe_CB007518-A_008_CM_SR_Different_Order_Of_HW_Insert_And_HW_Configuration.robot

*** Test Cases ***
[1] SRAN_SyVe_CB007518-A_008_CM_SR_Different_Order_Of_HW_Insert_And_HW_Configuration
    [Setup]    Test Setup
    SRAN_SyVe_CB007518-A_008_CM_SR_Different_Order_Of_HW_Insert_And_HW_Configuration
    [Teardown]    Test Teardown
