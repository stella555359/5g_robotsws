*** Settings ***
Documentation  This suite contains WebEM__Check_appLoginBannerText TC

Resource  ../test_resources/WebEM__Check_appLoginBannerText.robot


*** Test Cases ***
WebEM__Check_appLoginBannerText
    [Setup]  TC Setup
    TC__WebEM__Check_appLoginBannerText
    [Teardown]  TC Teardown
