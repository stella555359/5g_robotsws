*** Settings ***
Documentation  This suite contains PM__vDU__Break_Connection_To_Pano TC

Resource  ../test_resources/PM__vDU__Break_Connection_To_Pano.robot


*** Test Cases ***
PM__vDU__Break_Connection_To_Pano
    [Setup]  TC Setup
    TC__PM__vDU__Break_Connection_To_Pano
    [Teardown]  TC Teardown
