*** Settings ***
Documentation  This suite contains WebEM__vDU__CW_Add_a_RANNIC_module_QSFP_and_LANE TC

Resource  ../test_resources/WebEM__vDU__CW_Add_a_RANNIC_module_QSFP_and_LANE.robot


*** Test Cases ***
WebEM__vDU__CW_Add_a_RANNIC_module_QSFP_and_LANE
    [Setup]  TC Setup
    TC__WebEM__vDU__CW_Add_a_RANNIC_module_QSFP_and_LANE
    [Teardown]  TC Teardown
