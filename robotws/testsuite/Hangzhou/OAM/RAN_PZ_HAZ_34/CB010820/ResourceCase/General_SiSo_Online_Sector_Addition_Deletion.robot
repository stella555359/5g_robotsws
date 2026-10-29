*** Settings ***
Resource    ../Resource/Common.robot


*** Variables ***


*** Keywords ***
Test_Case_General_SiSo_Online_Sector_Addition_Deletion
    Case Setup: General_SiSo_Online_Sector_Addition_Deletion
    General_SiSo_Online_Sector_Addition_Deletion
    [Teardown]   Case Teardown: General_SiSo_Online_Sector_Addition_Deletion


General_SiSo_Online_Sector_Addition_Deletion
    Log To Console   General_SiSo_Online_Sector_Addition_Deletion
    # Cell Addition Deletion Common Keyword   cell_id=2
    Cell List Addition Deletion Common Keyword   cell_id_list=${General_SiSo_Online_Sector_Addition_Deletion}   scf_local_dir=${FAIL_LOG_DIR}

    CB010820 L3 Call Common Keyword


Case Setup: General_SiSo_Online_Sector_Addition_Deletion
    Set Suite Variable   ${DEFINE_TEST_NAME}   General_SiSo_Online_Sector_Addition_Deletion
    CB010820 Common Case Setup
    Wait Until Keyword Succeeds   10m   1m   COAM Login
    Wait Until Keyword Succeeds   15m   1m   COAM ADMIN Check Cell Onair
    COAM Backup SCF   local_dir=${FAIL_LOG_DIR}   file_name=General_SiSo_Online_Sector_Addition_Deletion.xml
    [Teardown]   Run Keyword And Ignore Error   COAM Logout


Case Teardown: General_SiSo_Online_Sector_Addition_Deletion
    CB010820 Common Case Teardown

    Wait Until Keyword Succeeds   10m   1m   COAM Login
    COAM SCF Commission   filepath=${FAIL_LOG_DIR}/General_SiSo_Online_Sector_Addition_Deletion.xml
    Wait Until Keyword Succeeds   15m   1m   COAM ADMIN Check Cell Onair
    [Teardown]   Run Keyword And Ignore Error   COAM Logout
