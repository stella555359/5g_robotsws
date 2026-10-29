*** Settings ***
Documentation  This suite contains WebEM__Configuration_reset_platLoginBannerText_BTS_log_level TC

Resource  ../test_resources/WebEM__Configuration_reset_platLoginBannerText_BTS_log_level.robot


*** Test Cases ***
WebEM__Configuration_reset_platLoginBannerText_BTS_log_level
    [Setup]  TC Setup
    TC__WebEM__Configuration_reset_platLoginBannerText_BTS_log_level
    [Teardown]  TC Teardown
