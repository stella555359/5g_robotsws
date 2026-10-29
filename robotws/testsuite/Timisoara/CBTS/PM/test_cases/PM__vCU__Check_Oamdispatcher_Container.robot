*** Settings ***
Documentation  This suite contains PM__vCU__Check_Oamdispatcher_Container TC

Resource  ../test_resources/PM__vCU__Check_Oamdispatcher_Container.robot


*** Test Cases ***
PM__vCU__Check_Oamdispatcher_Container
    [Setup]  TC Setup
    TC__PM__vCU__Check_Oamdispatcher_Container
    [Teardown]  TC Teardown
