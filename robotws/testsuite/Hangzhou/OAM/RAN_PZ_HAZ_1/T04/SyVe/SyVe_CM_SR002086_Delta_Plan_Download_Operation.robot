*** Settings ***
Documentation       Test suite for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia-sbell.com
Test Timeout    75h
Variables     ../test_line_specific/SBTS_SYVE_1813/My_Variables.py
Variables     ../test_line_specific/Variables/NetActs.py
Resource    ../test_resources/SyVe/SyVe_CM_SR002086_Delta_Plan_Download_Operation.robot

*** Test Cases ***
SyVe_CM_SR002086_Delta_Plan_Download_Operation
    [Setup]    TC Setup
    [Timeout]    72h
    [Teardown]    TC Teardown
    SyVe_CM_SR002086_Delta_Plan_Download_Operation

