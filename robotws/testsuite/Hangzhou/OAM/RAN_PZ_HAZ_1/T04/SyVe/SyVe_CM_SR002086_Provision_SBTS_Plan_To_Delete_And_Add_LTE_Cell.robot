*** Settings ***
Documentation       Test suite for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia-sbell.comr
Test Timeout    75h
Variables       ../test_line_specific/SBTS_SYVE_1910/My_Variables.py
Variables       ../test_line_specific/Variables/NetActs.py
Resource        ../test_resources/SyVe/SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_LTE_Cell.robot

*** Test Cases ***
SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_LTE_Cell
    [Setup]    TC Setup
    [Timeout]    72h
    SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_LTE_Cell
    [Teardown]    TC Teardown
