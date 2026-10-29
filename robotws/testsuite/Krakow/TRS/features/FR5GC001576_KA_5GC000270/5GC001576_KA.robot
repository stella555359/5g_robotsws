*** Settings ***
Documentation
...    author: Jakub Kupiec, Marcin Szlapa
...    contact: jakub.kupiec@nokia.com, marcin.szlapa@nokia.com
...    Description: Test Cases 5GC001576-KA_I&V_5GC000270_LINUX_System_account_permissions_on_gNB

Resource   testsuite/Krakow/resources/RAN_PZ_KRK4/linux_hardening/connections.robot
Resource   taf/rfrl/bts/robot/logs_collecting.robot
Resource   taf/rfrl/bts/robot/gnb.robot
Resource   taf/rfrl/bts/robot/common/gnb_cu.robot
Resource   taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Library    testsuite.Krakow.resources.linux_accounts.python_keywords.Keywords    WITH NAME    keywords
Library    testsuite.Krakow.resources.cu_webem.cu_webem_keywords.CuWebem    WITH NAME  webem
Library    testsuite.Krakow.resources.scf.Scf    WITH NAME  scf
Variables  taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Force Tags    STATE_GNB_NOT_COMMISSIONED    CLOUD_5G_QC_ASIKR_ABILB4_AEUB
...           CRT__WITH__RAN_5G_TDD__WITH__master_pDU

Suite Setup      Setup
Suite Teardown   Teardown
Test Setup       Common Preconditions
Test Teardown    Common Postconditions

*** Variables ***
${old_path}=   /home/ute/plan.xml

*** Test Cases ***
[1][1.0] 5GC001568-KA_5GC000270_CU_1.1_User_logs_into gNB_CU_via_SSH_as_serviceuser_providing_default_password_and_logs_out
    Get actual time  gmt_timezone=True
    Cu serviceuser one step password authorization
    Cu robot one step password authorization
    Cu toor4nsn two step password authorization via robot
    Check auth log    1.1  number_of_lines=1000

[1][1.0] 5GC001568-KA_5GC000270_CU_1.2_User_logs_into gNB_CU_via_SSH_as_serviceuser_providing_SSH_key
    Get actual time  gmt_timezone=True
    ${new_path} =  scf.Add cu ssh key with passphrase  ${old_path}
    webem.Perform cu commissioning  ${new_path}
    Cu serviceuser one step authorization with ssh key and passphrase
    Check auth log    1.2

[1][1.0] 5GC001568-KA_5GC000270_CU_1.4_User_fails_to_log_into gNB_CU_via_SSH_as_serviseuser_providing_wrong_SSH_key
    Get actual time  gmt_timezone=True
    Cu serviceuser one step authorization with ssh key  should_fail=True
    Check auth log    1.4
    webem.Perform cu commissioning  ${old_path}

[1][1.0] 5GC001576-KA_5GC000270_CU_3.1_New_SSH_Keys_provisioning_for_serviceuser_via_CU_WebEM
    ${new_path} =  scf.Add cu ssh keys  ${old_path}
    webem.Perform cu commissioning  ${new_path}
    ${new_path} =  scf.Add cu ssh keys  ${old_path}  add_eleventh_key=True
    webem.Perform cu commissioning  ${new_path}  should_fail=True
    keywords.Check internalsshkeys  number_of_keys=10
#    check_auth_log    3.1

[1][1.0] 5GC001576-KA_5GC000270_CU_3.2_Changing_value_of_SSH_Key_provisioned_for_serviceuser_via_CU_WebEM
    ${new_path} =  scf.Add cu ssh keys  ${old_path}
    ${key} =  scf.Change one ssh key  ${new_path}
    webem.Perform cu commissioning  ${new_path}
    keywords.Verify internal ssh key exists  ${key}
    Cu serviceuser one step authorization with ssh key and passphrase

[1][1.0] 5GC001576-KA_5GC000270_CU_3.4_Validatiion_of_SSH_Key_with_incorrect_format_on_WebEM
    ${new_path} =  scf.Add_cu_ssh_keys  ${old_path}
    scf.Change key description to incorrect  ${new_path}
    webem.Perform cu commissioning  ${new_path}  should_fail=True
    scf.Change key value to incorrect  ${new_path}
    webem.Perform cu commissioning  ${new_path}  should_fail=True
    webem.Perform cu commissioning  ${old_path}

[1][1.0] 5GC001568-KA_5GC000270_CU_1.3_User_fails_to_log_directly_into gNB_CU_via_SSH_as_toor4nsn_providing_password
    Get actual time  gmt_timezone=True
    Cu toor4nsn one step password authorization     should_fail=True
    Cu toor4nsn two step password authorization via robot
    Check auth log     1.3

[1][1.0] 5GC001568-KA_5GC000270_CU_1.5_User_fails_to_log_into gNB_CU_via_SSH_as_serviseuser_providing_wrong_password
    Get actual time
    Cu serviceuser one step incorrect password authorization     should_fail=True
    Cu serviceuser one step password authorization
    Cu toor4nsn two step password authorization via robot
    Sleep   15s

[1][1.0] 5GC001568-KA_5GC000270_CU_1.6_User_logs_into gNB_CU_via_SSH_as_serviceuser_after_failed_authentification
    Cu serviceuser one step authorization with ssh info check

[1][1.0] 5GC001568-KA_5GC000270_CU_1.7_serviceuser_UID_differs_from_zero
    Get actual time  gmt_timezone=True
    Cu serviceuser one step password authorization
    Cu toor4nsn two step authorization via serviceuser with scli cmd
    Cu toor4nsn two step password authorization via robot
    Check auth log   1.7

[1][1.0] 5GC001568-KA_5GC000270_CU_2.1_Nokia_service_account_access_with_privileges_upgrade
    Get actual time  gmt_timezone=True
    Cu serviceuser one step password authorization
    Cu toor4nsn two step authorization via serviceuser with scli cmd
    Check auth log    2.1

[1][1.0] 5GC001568-KA_5GC000270_CU_2.2_Nokia_service_account_access_with_privileges_upgrade_attempt
    Get actual time  gmt_timezone=True
    Cu serviceuser one step password authorization
    Cu toor4nsn two step authorization via serviceuser with incorrect password
    Check auth log    2.2

[1][1.0] 5GC001568-KA_5GC000270_CU_2.3_toor4nsn_performs_system_control_actions
    Get actual time  gmt_timezone=True
    Cu serviceuser one step password authorization
    Cu toor4nsn two step authorization via serviceuser with scli cmd
    Cu run fdisk cmd as toor4nsn
    Check auth log    2.3

[1][1.0] 5GC001568-KA_5GC000270_CU_2.4_toor4nsn_UID_equal_zero
    Cu serviceuser one step password authorization
    Cu toor4nsn two step authorization via serviceuser with scli cmd
    Cu run cmd id with output check

[1][1.0] 5GC001576_KA_5GC001525_JA_DU_1_Grant_Nokia_service_account_root_access_with_two_step_authentication_(US#1.1_&_US#3)
    TC_Preconditions
    Change system account permission parameter    true
    Change key continuation parameter     false
    Change webem keys  update  serviceuser
    Change webem keys  update  toor4nsn
    Toor4nsn one step password authorization    should_fail=true
    Serviceuser one step password authorization with invalid password    should_fail=true
    Serviceuser one step password authorization
    Serviceuser one step password authorization with uid check
    Toor4nsn two step authorization with password    should_fail=true
    TC_Postconditions

[1]5GC001576_KA_5GC001525_JA_DU_2_Grant_Nokia_service_account_root_access_with_two_step_authentication_on
    TC_Preconditions
    Change system account permission parameter   true
    Change key continuation parameter    false
    Change webem keys  update  serviceuser
    Change webem keys  update  toor4nsn
    Serviceuser one step authorization with ssh key
    Toor4nsn two step authorization with different ssh keys
    Toor4nsn two step authorization with different ssh keys and privileges check
    TC_Postconditions

[1]5GC001576_KA_5GC001525_JA_DU_3_User_logs_into_gNB_via_SSH_as_Nokia_Service_User_using_password_or_public_key
    TC_Preconditions
    Change system account permission parameter    false
    Change key continuation parameter     false
    Change webem keys  update  serviceuser
    Change webem keys  update  toor4nsn
    Toor4nsn one step password authorization with privileges check
    Serviceuser one step authorization with ssh key
    Toor4nsn one step authorization with ssh key
    TC_Postconditions

[1][1.0] 5GC001576_KA_5GC001525_JA_DU_4_feature_enable_or_disable_provisioning_via_gNB_WebEM_(US#4.1)
    TC_Preconditions
    Change system account permission parameter    true
    Change key continuation parameter     false
    Change webem keys  update  serviceuser
    Change webem keys  update  toor4nsn
    Toor4nsn one step password authorization  should_fail=True
    Change system account permission parameter    false
    Toor4nsn one step password authorization
    TC_Postconditions

[1][2.0] 5GC001576_KA_5GC001525_JA_DU_8_SSH_key_continuation_is_off_and_toor4nsn_accounts_ssh_keys_uploaded_(US#5.3)
    TC_Preconditions
    Change system account permission parameter    true
    Change key continuation parameter     false
    Change webem keys  update  serviceuser
    Change webem keys  update  toor4nsn
    Toor4nsn two step authorization with password and defined ssh key
    Compare keys  should_be_different=True
    TC_Postconditions

[1]5GC001576_KA_5GC001525_JA_DU_10_SSH_Key_continuation_provisioning_via_gNB_WebEM_–_key_continuation_is_off
    TC_Preconditions
    Change system account permission parameter    true
    Change key continuation parameter     false
    Change webem keys  update  serviceuser  10
    Change webem keys  update  toor4nsn  10
    Change key continuation parameter     true   should_fail=True
    TC_Postconditions

[1]5GC001576_KA_5GC001525_JA_DU_6_SSH_Key_continuation_provisioning_via_gNB_WebEM_–_key_continuation_is_on
    TC_Preconditions
    Change system account permission parameter    true
    Change key continuation parameter     true
    Change webem keys  update  serviceuser
    Serviceuser one step authorization with ssh key
    verify_number_of_ssh_keys_via_linux_files  1  serviceuser
    Toor4nsn two step authorization with serviceuser ssh key
    Compare keys
    TC_Postconditions

[1]5GC001576_KA_5GC001525_JA_DU_7_Key_continuation_provisioning_via_gNB_WebEM_–_key_continuation_is_on
    TC_Preconditions
    Change system account permission parameter    false
    Prepare ssh and clone in unix local
    Check if authorized keys file does not exist
    Change system account permission parameter    true
    Change key continuation parameter     false
    Change key continuation parameter     true
    Check if authorized keys file does not exist
    TC_Postconditions

[1]5GC001576_KA_5GC001525_JA_DU_9_SSH_Key_continuation_provisioning_via_gNB_WebEM_–_key_continuation_is_off
    TC_Preconditions
    Change system account permission parameter    false
    Prepare ssh and clone in unix local
    Check if authorized keys file does not exist
    Change system account permission parameter    true
    Change key continuation parameter     false
    Toor4nsn two step authorization with different ssh keys     should_fail=True
    Check if authorized keys file does not exist
    TC_Postconditions

*** Keywords ***
TC_Preconditions
    Delete root user ssh keys
    Delete service user ssh keys

TC_Postconditions
    Delete delta file

Setup
    Preconditions
    gnb_cu.Get Active CU Configuration   ${old_path}
    Change system account permission parameter    false
    Change key continuation parameter     false
    Generate ssh keys  toor4nsn
    Generate ssh keys  serviceuser
    Generate ssh key with passphrase  serviceuser

Teardown
    Change system account permission parameter    false
    Change key continuation parameter     false
    Delete ssh keys  toor4nsn
    Delete ssh keys  serviceuser
    Delete ssh key with passphrase  serviceuser
    Postconditions_DU_CU
