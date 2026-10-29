*** Settings ***
Documentation       Test suite for SyVe_CM
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Variables         ../test_line_specific/SBTS_SYVE_1910/My_Variables.py
Resource          ../test_resources/CM/CM__CB012611_001_010_Configuration_Update_When_ABIO_One_Loki_Failed_At_RT_In_Basic_Or_IQF_Conf.robot

*** Test Cases ***
CM__CB012611_001_010_Configuration_Update_When_ABIO_One_Loki_Failed_At_RT_In_Basic_Or_IQF_Conf
    [Setup]    Common Test Setup SBTS    SetValidatePlanAgainstDetectedHW=${FALSE}
    CM__CB012611_001_010_Configuration_Update_When_ABIO_One_Loki_Failed_At_RT_In_Basic_Or_IQF_Conf
    [Teardown]    Common Test Teardown SBTS
