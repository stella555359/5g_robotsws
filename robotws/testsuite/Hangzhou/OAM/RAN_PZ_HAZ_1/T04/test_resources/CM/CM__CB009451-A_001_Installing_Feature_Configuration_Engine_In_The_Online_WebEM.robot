*** Settings ***
Documentation       Test case for
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${remote_ip}    10.106.253.50
${remote_username}    ute
${remote_password}    RAN_pz_HAZ1_SG11
${remote_fce_path}    /home/ute/fce/fce-worker.zip

*** Keywords ***
CM__CB009451-A_001_Installing_Feature_Configuration_Engine_In_The_Online_WebEM
    [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...   New case for TA_RAN_ST_CB009451-A_001_CM_Installing Feature Configuration Engine in the online WebEM
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 09.08.2023 - New Case

    Set Tags    CM    UI    OWNER-II_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com    Author-lixin.kang@nokia-sbell.com
    LOG    ${TEST_NAME} start.    console=${True}
    Step 1: Download FCE Package For Current BTS Version
    Step 2: Open WebEM CA Page And Check Init Status
    Step 3: Install Invalid FCE And Verify Result
    Step 4: Install Valid FCE And Verify Result

Step ${index}: Download FCE Package For Current BTS Version
    Log    Step ${index}: Download FCE Package For Current BTS Version    console=True
    ${fce_worker_name}    ${fct_files_name}    Download FCE Modules For Current SW
    Set Test Variable    ${fce_worker_name}

Step ${index}: Open WebEM CA Page And Check Init Status
    Log    Step ${index}: Open WebEM CA Page And Check Init Status    console=True
    ${win_index}    SBTS WEM Logon    https://${MPLANE_IP}    skip_error=${True}
    SBTS WEM Open Configuration Manager    CA
    Check Button Status Before Install FCE

Step ${index}: Install Valid FCE And Verify Result
    Log    Step ${index}: Install Valid FCE And Verify Result   console=True
    ${error_messege}   Install FCE From WebEM CA    ${Test Results Dir}/TestFiles/${fce_worker_name}
    Should Be Empty    ${error_messege}
    Check FCE Feature List Not Empty

Step ${index}: Install Invalid FCE And Verify Result
    Log    Step ${index}: Install Invalid FCE And Verify Result   console=True
    Get Old FCE File From Remote
    ${error_messege}    Install FCE From WebEM CA    ${Test Results Dir}/TestFiles/old_fce_worker.zip
    Should Contain    ${error_messege}    NIDD version matching failed
    Should Contain    ${error_messege}    FCE installing process is terminated

Check FCE Feature List Not Empty
    ${list_FCE_features}    Get Feature List From WebEM CA
    Should Not Be Empty    ${list_FCE_features}

Get Old FCE File From Remote
    SSHLibrary.Open Connection    ${remote_ip}
    SSHLibrary.Login    ${remote_username}    ${remote_password}
    ${file_exists}    Run Keyword And Return Status    SSHLibrary.File Should Exist    ${remote_fce_path}
    Run Keyword If    ${file_exists}    SSHLibrary.Get File    ${remote_fce_path}    ${Test Results Dir}/TestFiles/old_fce_worker.zip
    OperatingSystem.File Should Exist    ${Test Results Dir}/TestFiles/old_fce_worker.zip
    [Teardown]         SSHLibrary.Close Connection

Check Button Status Before Install FCE
    ${dic_button_states}    Get Button States On CA Page
    Should Be True    ${dic_button_states['install_fce_states']}
    Should Be True    ${dic_button_states['select_plan_states']}
    Should Not Be True    ${dic_button_states['install_fct_states']}
    Should Not Be True    ${dic_button_states['select_feature_states']}
    Should Be Empty     ${dic_button_states['list_FCE_features']}

SetUp
    Common Test Setup SBTS    scf_check=${FALSE}

TearDown
    ${time}    Get Time    epoch
    Run Keyword If Test Failed    Capture Page Screenshot    ${time}.png
    Common Test Teardown SBTS
    SBTS WEM Download Chrome Console Log
    [Teardown]    Close All Browsers