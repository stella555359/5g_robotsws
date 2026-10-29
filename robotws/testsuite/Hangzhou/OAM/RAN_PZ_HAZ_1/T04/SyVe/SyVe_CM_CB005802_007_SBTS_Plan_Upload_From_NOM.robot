*** Settings ***
Documentation       Test suite for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia-sbell.com
Test Timeout    75h
Variables     ../test_line_specific/SBTS_SYVE_1813/My_Variables.py
Variables     ../test_line_specific/Variables/NetActs.py
Resource      ../test_resources/SyVe/SyVe_CM_CB005802_007_SBTS_Plan_Upload_From_NOM.robot

*** Test Cases ***
SyVe_CM_CB005802_007_SBTS_Plan_Upload_From_NOM
    [Setup]    TC Setup
    [Timeout]    72h
    SyVe_CM_CB005802_007_SBTS_Plan_Upload_From_NOM
    [Teardown]    TC Teardown
