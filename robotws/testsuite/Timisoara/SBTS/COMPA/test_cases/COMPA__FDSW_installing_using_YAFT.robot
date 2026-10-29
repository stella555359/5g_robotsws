*** Settings ***
Documentation  This suite contains COMPA__FDSW_installing_using_YAFT TC

Resource  ../test_resources/COMPA__FDSW_installing_using_YAFT.robot


*** Test Cases ***
COMPA__FDSW_installing_using_YAFT
    [Setup]  TC Setup
    TC__COMPA__FDSW_installing_using_YAFT
    [Teardown]  TC Teardown
