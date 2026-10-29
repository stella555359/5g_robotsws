*** Settings ***
Resource    ../Resource/Common.robot


*** Variables ***


*** Keywords ***
Test_Case_Manual_SiSo_SM_BTS_Site_Reset_with_HWF
    Case Setup: Manual_SiSo_SM_BTS_Site_Reset_with_HWF
    Manual_SiSo_SM_BTS_Site_Reset_with_HWF
    [Teardown]   Case Teardown: Manual_SiSo_SM_BTS_Site_Reset_with_HWF


Manual_SiSo_SM_BTS_Site_Reset_with_HWF
    Log To Console   Manual_SiSo_SM_BTS_Site_Reset_with_HWF
    ${CASE_PROCESS_START}   DateTime.Get Current Date   result_format=epoch
    Log To Console   CASE_PROCESS_START: ${CASE_PROCESS_START}
    Set Test Variable   ${CASE_PROCESS_START}
    COAM Reset Site
    Wait Until Keyword Succeeds   20m   1m   COAM ADMIN Check Cell Onair

    CB010820 L3 Call Common Keyword


Case Setup: Manual_SiSo_SM_BTS_Site_Reset_with_HWF
    Set Suite Variable   ${DEFINE_TEST_NAME}   Manual_SiSo_SM_BTS_Site_Reset_with_HWF
    CB010820 Common Case Setup
    Wait Until Keyword Succeeds   10m   1m   COAM Login
    Add HWF Flag at swconfig
    COAM Reset Site
    Wait Until Keyword Succeeds   20m   1m   COAM ADMIN Check Cell Onair


Case Teardown: Manual_SiSo_SM_BTS_Site_Reset_with_HWF
    CB010820 Common Case Teardown
    Remove HWF Flag at swconfig
    COAM Reset Site
    Wait Until Keyword Succeeds   20m   1m   COAM ADMIN Check Cell Onair
    [Teardown]   Run Keyword And Ignore Error   COAM Logout
