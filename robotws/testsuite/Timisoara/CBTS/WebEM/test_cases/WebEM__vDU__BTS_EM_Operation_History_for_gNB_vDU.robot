*** Settings ***
Documentation  This suite contains WebEM__vDU__BTS_EM_Operation_History_for_gNB_vDU TC

Resource  ../test_resources/WebEM__vDU__BTS_EM_Operation_History_for_gNB_vDU.robot


*** Test Cases ***
WebEM__vDU__BTS_EM_Operation_History_for_gNB_vDU
    [Setup]  TC Setup
    TC__WebEM__vDU__BTS_EM_Operation_History_for_gNB_vDU
    [Teardown]  TC Teardown
