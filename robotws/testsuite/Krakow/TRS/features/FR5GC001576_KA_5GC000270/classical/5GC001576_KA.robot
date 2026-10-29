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


Force Tags    STATE_SW_UPLOADED    RAN_5G
...  SBTS00__WITH__CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AEUB__WITH__CRT


Suite Setup      Setup
Suite Teardown   Teardown
Test Setup       Common Preconditions
Test Teardown    Common Postconditions

*** Test Cases ***
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
