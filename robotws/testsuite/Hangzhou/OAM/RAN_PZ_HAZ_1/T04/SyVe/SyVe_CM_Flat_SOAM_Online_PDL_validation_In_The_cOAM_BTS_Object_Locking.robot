*** Settings ***
Documentation       Test suite for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia-sbell.com
Test Timeout    75h
Variables     ../test_line_specific/SBTS_SYVE_1813/My_Variables.py
Variables     ../test_line_specific/Variables/NetActs.py
Resource      ../test_resources/SyVe/SyVe_CM_Flat_SOAM_Online_PDL_validation_In_The_cOAM_BTS_Object_Locking.robot

*** Test Cases ***
SyVe_CM_Flat_SOAM_Online_PDL_validation_In_The_cOAM_BTS_Object_Locking
    [Setup]    TC Setup
    [Timeout]    72h
    TC__SyVe_CM_Flat_SOAM_Online_PDL_validation_In_The_cOAM_BTS_Object_Locking
    [Teardown]    TC Teardown
