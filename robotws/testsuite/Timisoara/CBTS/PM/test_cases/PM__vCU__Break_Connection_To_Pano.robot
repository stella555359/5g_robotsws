*** Settings ***
Documentation  This suite contains PM__vCU__Break_Connection_To_Pano TC

Resource  ../test_resources/PM__vCU__Break_Connection_To_Pano.robot


*** Test Cases ***
PM__vCU__Break_Connection_To_Pano
    [Setup]  TC Setup
    TC__PM__vCU__Break_Connection_To_Pano
    [Teardown]  TC Teardown
