*** Settings ***
Documentation  This suite contains WebEM__vDU__CW_Modify_Update_RANNIC_Update_QSFP_and_LANE_in_step_by_step_view TC

Resource  ../test_resources/WebEM__vDU__CW_Modify_Update_RANNIC_Update_QSFP_and_LANE_in_step_by_step_view.robot


*** Test Cases ***
WebEM__vDU__CW_Modify_Update_RANNIC_Update_QSFP_and_LANE_in_step_by_step_view
    [Setup]  TC Setup
    TC__WebEM__vDU__CW_Modify_Update_RANNIC_Update_QSFP_and_LANE_in_step_by_step_view
    [Teardown]  TC Teardown
