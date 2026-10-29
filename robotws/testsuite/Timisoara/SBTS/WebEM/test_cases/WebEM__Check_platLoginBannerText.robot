*** Settings ***
Documentation  This suite contains WebEM__Check_platLoginBannerText TC

Resource  ../test_resources/WebEM__Check_platLoginBannerText.robot


*** Test Cases ***
WebEM__Check_platLoginBannerText
    [Setup]  TC Setup
    TC__WebEM__Check_platLoginBannerText
    [Teardown]  TC Teardown
