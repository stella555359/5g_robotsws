*** Settings ***
Documentation       Test suite for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia-sbell.com
Test Timeout    75h
Variables     ../test_line_specific/SBTS_SYVE_1813/My_Variables.py
Variables     ../test_line_specific/Variables/NetActs.py
Resource      ../test_resources/SyVe/SRAN_SyVe_CM_CB007490_Modify_NRREL_Parameters_For_NR_CELL_Reset.robot

*** Test Cases ***
SRAN_SyVe_CM_Modify_NRREL_Parameters_For_NR_CELL_Reset_CB007490
    [Setup]    TC Setup
    [Timeout]    72h
    SRAN_SyVe_CM_CB007490_Modify_NRREL_Parameters_For_NR_CELL_Reset
    [Teardown]    TC Teardown
