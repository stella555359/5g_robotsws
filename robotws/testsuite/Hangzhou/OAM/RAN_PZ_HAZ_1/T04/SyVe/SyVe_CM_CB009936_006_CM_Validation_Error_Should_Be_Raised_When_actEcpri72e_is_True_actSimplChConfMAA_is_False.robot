*** Settings ***
Documentation       Test suite for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia-sbell.com
Test Timeout    5h
Variables     ../test_line_specific/SBTS_SYVE_1813/My_Variables.py
Variables     ../test_line_specific/Variables/NetActs.py
Resource
...   ../test_resources/SyVe/SyVe_CM_CB009936_006_CM_Validation_Error_Should_Be_Raised_When_actEcpri72e_is_True_actSimplChConfMAA_is_False.robot

*** Test Cases ***
SyVe_CM_CB009936_006_CM_Validation_Error_Should_Be_Raised_When_actEcpri72e_is_True_actSimplChConfMAA_is_False
    [Setup]    TC Setup
    [Timeout]    2h
    SyVe_CM_CB009936_006_CM_Validation_Error_Should_Be_Raised_When_actEcpri72e_is_True_actSimplChConfMAA_is_False
    [Teardown]    TC TearDown
