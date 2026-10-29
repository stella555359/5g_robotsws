*** Settings ***
Documentation  This suite contains PM__vDU__Check_Parameters_Remain_Frozen TC

Resource  ../test_resources/PM__vDU__Check_Parameters_Remain_Frozen.robot


*** Test Cases ***
PM__vDU__Check_Parameters_Remain_Frozen
    [Setup]  TC Setup
    TC__PM__vDU__Check_Parameters_Remain_Frozen
    [Teardown]  TC Teardown
