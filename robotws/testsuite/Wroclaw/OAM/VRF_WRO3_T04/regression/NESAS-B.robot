*** Settings ***
Documentation    Suite for 9203 testcases from Pack B for NESAS.

Resource        ../features/NESAS/Pack_B/TestCases/NESAS-B.robot
Resource        ../common_resources/swconfig/swconfig.robot
Resource        ../common_resources/scf/scf_sender.robot
Resource        ../common_resources/connections/connections.robot
Resource        ../common_resources/scout/scout_operations.robot
Resource        ../common_resources/gathering_logs/gathering_logs.robot
Resource        ../common_resources/alarms/alarm.robot
Resource        ../common_resources/variables/variables.robot
Resource        taf/rfrl/common_resources/common_step/interface.robot
Resource        taf/rfrl/scrambling_logs_collector/Keywords.robot

Library         ../common_resources/robot_extensions/robot_extensions.py

Force Tags      CA_RAN_PZ_WRO_3
...             RESPONSIBLE_TESTER=kubacka

Suite Setup       Suite Setup
Suite Teardown    Suite Teardown

Test Setup        Test Setup
Test Teardown     Test Teardown

*** Test Cases ***
NESAS-B_Check_Group_Credentials
    [Tags]
    Check_Group_Credentials

NESAS-B_Check_Predefined_Users_for_Disabled_Access_for_Login
    [Tags]
    Check_predefined_users_for_disabled_access_and_no_login

[1]NESAS-B_SSH_Bruteforce_Attempt
    [Tags]
    SSH_Bruteforce_Attempt

[1]NESAS-B_SSH_Session_Login_Delay
    [Tags]
    SSH_Session_Login_Delay

[1]NESAS-B_Files_with_No-User_and_No-Group_Credentials
    [Tags]
    PLATFORM_Orphaned_Files

[1]NESAS-B_Process_Not_Owned_by_Root
    [Tags]
    PLATFORM_Process_user_accounts

[1]NESAS-B_Checking_Permission_and_Ownership_in_Files
    [Tags]
    PLATFORM_gNB_File_Permission_Rules

[1]NESAS-B_System_Files_Executables_SUID_SGID
    [Tags]
    PLATFORM_System_Executables_SUID_SGID

[1]NESAS-B_Permissions_to_Access_Logs_Files_by_CLI
    [Tags]
    Permissions_to_access_logs_files_by_CLI

[1]NESAS-B_Check_For_No_Extra_Users
    [Tags]
    gNB_Local_Account_Check_For_No_Extra_Users

[1]NESAS-B_Log_Activity_from_SSH_User_Logging
    [Tags]
    Log_Activity_from_SSH_User_Logging

[1]NESAS-B_Account_Creation_and_IDs_Verification
    [Tags]
    Unix_account_creation_and_UIDs_verification

[1]NESAS-B_SSH_Keys_Provisioning_While_Key_Continuation_is_Off_and_On
    [Tags]
    SSH_Keys_provisioning_via_gNB_WebUI_while_key_continuation_is_off

[1]NESAS-B_Connecting_with_SSH_Keys_While_Key_Continuation_Off_and_Toor4nsn_Accounts_SSH_Keys_Not_Uploaded_and_Uploaded
    [Tags]
    SSH_Keys_continuation_provisioning_via_gNB_WebUI_while_key_continuation_off_and_toor4nsn_accounts_ssh_keys_not_uploaded

[1]NESAS-B_Changing_parameters_with_different_admin_rights_via_WebEM
    [Tags]
    Changing_parameters_with_different_admin_rights_via_WebEM

[1]NESAS-B_System_account_permission_feature_enable_disable_provisioning_via_gNB_WebUI
    [Tags]
    System_Account_Permission_Logging_via_SSH

[1]NESAS-B_word_History_Length
    [Tags]
    Password_History_Length

[1]NESAS-B_WebEM_session_inactivity_timeout_with_local_users
    [Tags]
    WebEM_session_inactivity_timeout_with_local_users

[1]NESAS-B_Length_rules_for_users_via_WebEM
    [Tags]
    Length_rules_for_users_via_WebEM

[1]NESAS-B_Complexity_check_for_user_BTS_Security_Administrator_via_WebEM
    [Tags]
    Complexity_check_for_user_BTS_Users_via_WebEM

[1]NESAS-B_WebEM_Account_Lockout
    [Tags]
    WebEM_Account_Lockout

[1]NESAS-B_Root_Writable_Files
    [Tags]
    PLATFORM_Root_Writable_Files

[1]NESAS-B_WebEM_Bruteforce_Attempt
    [Tags]
    WebEM_Bruteforce_Attempt

[1]NESAS-B_Connecting_with_SSH_Keys_While_Key_Continuation_Off_and_Serviceuser_Accounts_SSH_Keys_Not_Uploaded_and_Uploaded
    [Tags]
    SSH_Keys_continuation_provisioning_via_gNB_WebUI_while_key_continuation_on_and_serviceuser_accounts_ssh_keys_not_uploaded

[1]NESAS-B_Handling_of_Growing_Content_Tmp
    [Tags]
    Handling_of_growing_content_via_tmp

[1]NESAS-B_Handling_of_Growing_Content_Logs
    [Tags]
    Handling_of_growing_content_via_var_log

*** Keywords ***
Suite Setup
    Common Gathering Logs for Common Suite Setup

Suite Teardown
    Common Gathering Logs for Common Suite Teardown
    Run keyword and ignore error   Collect and send logs for scrambling verification   team_name=PZ3WRO4
    ...                            input_logs_dir=${NONE}

Test Setup
    Common Gathering Logs for Test Setup

Test Teardown
    Common Gathering Logs for Test Teardown
