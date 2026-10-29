*** Settings ***
Documentation  This suite contains WebEM__vDU__CW_Plan_preparation_with_step_by_step_view TC

Resource  ../test_resources/WebEM__vDU__CW_Plan_preparation_with_step_by_step_view.robot


*** Test Cases ***
WebEM__vDU__CW_Plan_preparation_with_step_by_step_view
    [Setup]  TC Setup
    TC__WebEM__vDU__CW_Plan_preparation_with_step_by_step_view
    [Teardown]  TC Teardown
