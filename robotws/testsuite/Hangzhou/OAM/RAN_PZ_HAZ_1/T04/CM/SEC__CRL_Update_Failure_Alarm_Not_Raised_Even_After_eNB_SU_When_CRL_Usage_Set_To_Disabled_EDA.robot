*** Settings ***
Documentation       Test suite for SyVe_CM
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Variables         ../test_line_specific/SBTS_SYVE_1813/My_Variables.py
Resource          ../test_resources/CM/SEC__CRL_Update_Failure_Alarm_Not_Raised_Even_After_eNB_SU_When_CRL_Usage_Set_To_Disabled_EDA.robot

*** Test Cases ***
SEC__CRL_Update_Failure_Alarm_Not_Raised_Even_After_eNB_SU_When_CRL_Usage_Set_To_Disabled_EDA
    [Setup]    Common Test Setup SBTS    scf_check=${FALSE}
    SEC__CRL_Update_Failure_Alarm_Not_Raised_Even_After_eNB_SU_When_CRL_Usage_Set_To_Disabled_EDA
    [Teardown]    CaseTearDown
