*** Settings ***
Resource    ../Resource/Common.robot


*** Variables ***


*** Keywords ***
Test_Case_Manual_SiSo_SM_BTS_Site_Reset
    Case Setup: Manual_SiSo_SM_BTS_Site_Reset
    Manual_SiSo_SM_BTS_Site_Reset
    [Teardown]   Case Teardown: Manual_SiSo_SM_BTS_Site_Reset


Manual_SiSo_SM_BTS_Site_Reset
    Log To Console   Manual_SiSo_SM_BTS_Site_Reset
    COAM Reset Site
    Wait Until Keyword Succeeds   20m   1m   COAM ADMIN Check Cell Onair

    CB010820 L3 Call Common Keyword


Case Setup: Manual_SiSo_SM_BTS_Site_Reset
    Set Suite Variable   ${DEFINE_TEST_NAME}   Manual_SiSo_SM_BTS_Site_Reset
    CB010820 Common Case Setup
    Wait Until Keyword Succeeds   10m   1m   COAM Login
    Wait Until Keyword Succeeds   20m   1m   COAM ADMIN Check Cell Onair


Case Teardown: Manual_SiSo_SM_BTS_Site_Reset
    CB010820 Common Case Teardown

    Wait Until Keyword Succeeds   10m   1m   COAM Login
    Wait Until Keyword Succeeds   20m   1m   COAM ADMIN Check Cell Onair
    [Teardown]   Run Keyword And Ignore Error   COAM Logout
