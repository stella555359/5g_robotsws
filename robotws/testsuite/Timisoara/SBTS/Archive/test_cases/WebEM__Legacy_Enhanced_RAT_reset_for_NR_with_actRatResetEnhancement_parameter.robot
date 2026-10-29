*** Settings ***
Resource    ../test_resources/WebEM__Legacy_Enhanced_RAT_reset_for_NR_with_actRatResetEnhancement_parameter.robot

*** Test Cases ***
WebEM__Legacy_Enhanced_RAT_reset_for_NR_with_actRatResetEnhancement_parameter
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__WebEM__Legacy_Enhanced_RAT_reset_for_NR_with_actRatResetEnhancement_parameter