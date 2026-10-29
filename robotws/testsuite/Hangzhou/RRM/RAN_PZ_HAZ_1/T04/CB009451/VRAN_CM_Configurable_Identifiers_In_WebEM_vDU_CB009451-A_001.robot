*** Settings ***
Documentation       Test suite for SyVe_CM_CB009451_A
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
Resource          ../../Resources/Cloud/AIC_Common_Resource.robot

*** Variables ***
${remote_ip}      10.106.253.50
${remote_username}    ute
${remote_password}    RAN_pz_HAZ1_SG11
${remote_fce_path}    /home/ute/fce/fce-worker.zip
${default_plan_name}    TA_CB009451-A_001

*** Keywords ***
TC__VRAN_CM_Configurable_Identifiers_In_WebEM_vDU_CB009451-A_001
    [Documentation]    *****************
    ...    Basic information
    ...    *****************
    ...    New case for TA_RAN_ST_CB009451-A_001_CM_Installing Feature Configuration Engine in the online WebEM.docx
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 11.08.2023 - New case.
    Log To Console    ${TEST_NAME} start.    console=${True}
    Step 1: Login vDU And Download Files
    Step 2: Install Invalid FCE And Verify Result
    Step 3: Install FCE And Check

Case Precondition
    Log To Console    Case Precondition
    Common Test Setup For AIC

Case Postcondition
    Log To Console    \n Case Postcondition
    ${time}    Get Time    epoch
    Run Keyword If Test Failed    Capture Page Screenshot    ${time}.png
    Run Keyword And Return Status    netact.Delete Plan    ${default_plan_name}
    Logout And Close WEBEM
    Common Test Teardown For AIC
    SSHLibrary.Close All Connections

Step ${index}: Login vDU And Download Files
    Log To Console    Step ${index}: Login vDU And Download Files
    Open WEBEM and Login    https://${du_ip}    Nemuadmin    Nokia@123
    Go To PE Page
    Create Delta Plan    ${default_plan_name}
    ${fce_worker_f_name}    ${fct_file_f_name}    Download FCE Modules For Current SW    ${Trunk_Prefix}
    Set Test Variable    ${fce_worker_f_name}

Step ${index}: Install FCE And Check
    Log To Console    Step ${index}: Install FCE And Check
    Check Button Status Before Install FCE
    ${msg}    Install FCE    ${TEST_LOG_DIRECTORY}/${fce_worker_f_name}
    Should Be Empty    ${msg}
    ${list_FCE_features}    Get FCE Feature List
    Should Not Be Empty    ${list_FCE_features}

Step ${index}: Install Invalid FCE And Verify Result
    Log To Console    Step ${index}: Install Invalid FCE And Verify Result
    Get Old FCE File From Remote
    ${msg}    Install FCE    ${TEST_LOG_DIRECTORY}/old_fce_worker.zip
    Should Contain    ${msg}    The NIDD version matching failed. The FCE installing process is terminated.

Get Old FCE File From Remote
    SSHLibrary.Open Connection    ${remote_ip}
    SSHLibrary.Login    ${remote_username}    ${remote_password}
    SSHLibrary.File Should Exist    ${remote_fce_path}
    SSHLibrary.Get File    ${remote_fce_path}    ${TEST_LOG_DIRECTORY}/old_fce_worker.zip
    OperatingSystem.File Should Exist    ${TEST_LOG_DIRECTORY}/old_fce_worker.zip

Check Button Status Before Install FCE
    ${dic_button_states}    Get Button States Of Configuration Automation
    Should Be True    ${dic_button_states['install_fce_states']}
    Should Be True    ${dic_button_states['select_plan_states']}
    Should Not Be True    ${dic_button_states['install_fct_states']}
    Should Not Be True    ${dic_button_states['select_feature_states']}
    Should Be Empty    ${dic_button_states['list_FCE_features']}