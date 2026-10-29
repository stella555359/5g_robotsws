*** Settings ***
Resource    ../Resource/Common.robot


*** Variables ***


*** Keywords ***
Test_Case_General_SiSo_Commissioning_BTS_Template_Commissioning
    Case Setup: General_SiSo_Commissioning_BTS_Template_Commissioning
    General_SiSo_Commissioning_BTS_Template_Commissioning
    [Teardown]   Case Teardown: General_SiSo_Commissioning_BTS_Template_Commissioning


General_SiSo_Commissioning_BTS_Template_Commissioning
    Log To Console   General_SiSo_Commissioning_BTS_Template_Commissioning
    COAM Login
    COAM Backup SCF   local_dir=${FAIL_LOG_DIR}   file_name=General_SiSo_Commissioning_BTS_Template_Commissioning.xml
    COAM SCF Commission   filepath=${FAIL_LOG_DIR}/General_SiSo_Commissioning_BTS_Template_Commissioning.xml

    Wait Until Keyword Succeeds   15m   1m   COAM ADMIN Check Cell Onair

    CB010820 L3 Call Common Keyword

    [Teardown]   Run Keyword And Ignore Error   COAM Logout


Case Setup: General_SiSo_Commissioning_BTS_Template_Commissioning
    Set Suite Variable   ${DEFINE_TEST_NAME}   General_SiSo_Commissioning_BTS_Template_Commissioning
    CB010820 Common Case Setup
    Wait Until Keyword Succeeds   10m   1m   COAM Login
    Wait Until Keyword Succeeds   15m   1m   COAM ADMIN Check Cell Onair
    [Teardown]   Run Keyword And Ignore Error   COAM Logout


Case Teardown: General_SiSo_Commissioning_BTS_Template_Commissioning
    CB010820 Common Case Teardown
