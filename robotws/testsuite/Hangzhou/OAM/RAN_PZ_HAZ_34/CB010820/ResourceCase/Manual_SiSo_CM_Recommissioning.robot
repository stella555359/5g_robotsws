*** Settings ***
Resource    ../Resource/Common.robot


*** Variables ***


*** Keywords ***
Test_Case_Manual_SiSo_CM_Recommissioning
    Case Setup: Manual_SiSo_CM_Recommissioning
    Manual_SiSo_CM_Recommissioning
    [Teardown]   Case Teardown: Manual_SiSo_CM_Recommissioning


Manual_SiSo_CM_Recommissioning
    Log To Console   Manual_SiSo_CM_Recommissioning
    Cell Recommissioning Common Keyword   parameter_config_list=${Manual_SiSo_CM_Recommissioning}
    Cell Recommissioning Common Keyword   parameter_config_list=${SUITE_SETUP_CELL_RECOMMISSIONING}

    CB010820 L3 Call Common Keyword


Case Setup: Manual_SiSo_CM_Recommissioning
    Set Suite Variable   ${DEFINE_TEST_NAME}   Manual_SiSo_CM_Recommissioning
    CB010820 Common Case Setup
    Wait Until Keyword Succeeds   10m   1m   COAM Login
    Wait Until Keyword Succeeds   15m   1m   COAM ADMIN Check Cell Onair
    COAM Backup SCF   local_dir=${FAIL_LOG_DIR}   file_name=Manual_SiSo_CM_Recommissioning.xml
    [Teardown]   Run Keyword And Ignore Error   COAM Logout

Case Teardown: Manual_SiSo_CM_Recommissioning
    CB010820 Common Case Teardown

    Wait Until Keyword Succeeds   10m   1m   COAM Login
    COAM SCF Commission   filepath=${FAIL_LOG_DIR}/Manual_SiSo_CM_Recommissioning.xml
    Wait Until Keyword Succeeds   15m   1m   COAM ADMIN Check Cell Onair
    [Teardown]   Run Keyword And Ignore Error   COAM Logout
