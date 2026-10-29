*** Settings ***
Documentation       Test suite for SyVe_CM
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
Variables         ../test_line_specific/SBTS_SYVE_37376/My_Variables.py
Variables         ../test_line_specific/Variables/NetActs.py
Resource          ../test_resources/SyVe/SyVe_CM_CB011058_CM_SR_Static_HW_Properties_Pre-validation_In_MantaRay_NM.robot

*** Test Cases ***
SyVe_CM_CB011058_CM_SR_Static_HW_Properties_Pre-validation_In_MantaRay_NM
    [Setup]    TC Setup
    SyVe_CM_CB011058_CM_SR_Static_HW_Properties_Pre-validation_In_MantaRay_NM
    [Teardown]    TC Teardown