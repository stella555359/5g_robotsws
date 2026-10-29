*** Settings ***
Documentation  This suite contains WebEM__ALD_SW_package_in_online_and_offline_mode TC

Resource  ../test_resources/WebEM__ALD_SW_package_in_online_and_offline_mode.robot


*** Test Cases ***
WebEM__ALD_SW_package_in_online_and_offline_mode
    [Setup]  TC Setup
    TC__WebEM__ALD_SW_package_in_online_and_offline_mode
    [Teardown]  TC Teardown
