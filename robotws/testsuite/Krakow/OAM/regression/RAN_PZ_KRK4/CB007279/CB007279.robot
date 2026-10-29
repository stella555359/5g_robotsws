*** Settings ***
Documentation
...    author: Marcin Szlapa
...    contact: marcin.szlapa@nokia.com
...    Description: Test Cases CB007279

Library       ./resources/sw_keywords.py
Library       testsuite.Krakow.OAM.regression.RAN_PZ_KRK4.CB007279.resources.keywords.HubPassword
Resource      taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource      taf/rfrl/bts/robot/gnb.robot
Variables     taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables     ./resources/delta.py
Library       ../../../../resources/NJ_Resources/Resources/python/DevNJ_ASIR_Selenium.py  virtual_enable=${False}

Test Timeout  24 hours

Suite Setup         Run Keywords
...                 Common Suite Setup With Commissioning  CB007279  asir_hub=${True}
...                 AND    Wait Until Keyword Succeeds    1200 sec     60 sec    Verify Setup Of All Cells
...                 AND    gnbalarm.wait_for_alarm_deactivation    fault_id=7300    awaiting_time=1200
Suite Teardown      Common Suite Teardown
Test Setup          Common Preconditions
Test Teardown       Common Postconditions

*** Variables ***
${global_bts_id} =  ${tl.gnbs[0].global_bts_id}
${config_menu} =  Accounts
${account_type_wsuser}=  NE3S User Account
${account_type_hub}=  Hub User Accounts
${hub_user}=  hubapp
${toor4nsn_user}=  toor4nsn
${wsuser_user}=  wsuser
&{password_dict}  toor4nsn=Nokia57@ute!  hubapp=Nokia57@ute!
&{password_dict_wsuser}  wsuser=Nokia57@ute!
@{additional_allowed_alarms}  User Event Temporary Buffer Over Threshold


*** Test Cases ***
CB007279-B_6_ASiR_users_credentials_sync_check_after_password_change_(flag_is_set_to_true)
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/MNL-1/MNLENT-1/FEATCADM-1
    ...  param_name=actLoginCredPartitionSync
    ...  param_value=true
    ...  skip_parameter_relation_errors=${true}
    Change Asir Accounts Passwords
    sleep  30
    Wait Until Keyword Succeeds  3x  30
    ...  Run Keywords
    ...  DevNJ_ASIR_Selenium.Clean Browser
    ...  AND  perform_asir_recommissioning  delta=${secprm_delta}
    get_current_scf_file  local_dir_path=${OUTPUT_DIR}
    ${SECPRM_params}=  gnb_asir.get_all_params_under_class_name
    ...  scf_file_path=${OUTPUT_DIR}/REST_GNB0_ASIR_current_scf.xml  class_name=com.nokia.asi:SECPRM
    ${ASI_params}=  gnb_asir.get_all_params_under_class_name
    ...  scf_file_path=${OUTPUT_DIR}/REST_GNB0_ASIR_current_scf.xml  class_name=com.nokia.asi:ASI
    Set Suite Variable  ${SECPRM_params}
    Set Suite Variable  ${ASI_params}
    get_password_hash_for_all_users
    ${sw}=  rollback_sw
    sleep  120
    Wait Until Keyword Succeeds   25m   1m
    ...  Verify BBMOD Statuses
    ...  enabled  configured  online  unlocked
    Wait Until Keyword Succeeds   2m   15s  Verify Sw Changed  ${sw}
    verify_passwords_are_synced_to_passive_partition
    Wait Until Keyword Succeeds     3600 sec     60 sec      Verify gNB is onAir

CB007279-B_9_SEC_related_parameters_sync_check_(flag_is_set_to_true)
    get_current_scf_file  local_dir_path=${OUTPUT_DIR}
    ${SECPRM_params_after_rollback}=  gnb_asir.get_all_params_under_class_name
    ...  scf_file_path=${OUTPUT_DIR}/REST_GNB0_ASIR_current_scf.xml  class_name=com.nokia.asi:SECPRM
    ${ASI_params_after_rollback}=  gnb_asir.get_all_params_under_class_name
    ...  scf_file_path=${OUTPUT_DIR}/REST_GNB0_ASIR_current_scf.xml  class_name=com.nokia.asi:ASI
    Lists Should Be Equal  ${SECPRM_params}  ${SECPRM_params_after_rollback}
    Lists Should Be Equal  ${ASI_params}  ${ASI_params_after_rollback}
    [Teardown]  Postconditions

CB007279-B_15_Config_reset_from_ASiR_WebEM_clear_ASiController_storage_of_sHUB_passwords_is_marked
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/MNL-1/MNLENT-1/FEATCADM-1
    ...  param_name=actLoginCredPartitionSync
    ...  param_value=true
    ...  skip_parameter_relation_errors=${true}
    Change Asir Accounts Passwords
    sleep  30
    Reset Asir Configuration
    verify_asir_users_credentials_are_cleared
    Perform Full Commissioning on ASIR hub  prefix_tag=CB007279
    Wait for onAir on all DUs
    Restore default passwords


*** Keywords ***
Restore default passwords
    Run Keyword And Ignore Error  DevNJ_ASIR_Selenium.Logout  online_mode=${True}
    DevNJ_ASIR_Selenium.Clean Browser
    DevNJ_ASIR_Selenium.Asir Webem Login
    DevNJ_ASIR_Selenium.Enter Config Man  sub_menu=${config_menu}
    DevNJ_ASIR_Selenium.reset_accounts_password_to_default  account_type=${account_type_wsuser}  user=${wsuser_user}
    ...    check_required=${False}
    DevNJ_ASIR_Selenium.Enter Config Man  sub_menu=${config_menu}
    DevNJ_ASIR_Selenium.reset_accounts_password_to_default  account_type=${account_type_hub}  user=${toor4nsn_user}
    ...    check_required=${False}
    DevNJ_ASIR_Selenium.Enter Config Man  sub_menu=${config_menu}
    DevNJ_ASIR_Selenium.reset_accounts_password_to_default  account_type=${account_type_hub}  user=${hub_user}
    ...    check_required=${False}
    Sleep  5s
    Run Keyword And Ignore Error  DevNJ_ASIR_Selenium.Logout  online_mode=${True}
    DevNJ_ASIR_Selenium.Clean Browser

Postconditions
    perform_asir_recommissioning  delta=${passwdHistoryLength_delta}
    Restore default passwords
    ${sw}=  rollback_sw
    sleep  120
    Wait Until Keyword Succeeds   25m   1m
    ...  Verify BBMOD Statuses
    ...  enabled  configured  online  unlocked
    Wait Until Keyword Succeeds   2m   15s  Verify Sw Changed  ${sw}
    Wait for site to be onair
    Common Postconditions

Reset Asir Configuration
    Run Keyword And Ignore Error  DevNJ_ASIR_Selenium.Logout  online_mode=${True}
    DevNJ_ASIR_Selenium.Clean Browser
    DevNJ_ASIR_Selenium.Asir Webem Login
    DevNJ_ASIR_Selenium.Reset Configuration  clear_shub_password=${True}
    Run Keyword And Ignore Error  DevNJ_ASIR_Selenium.Logout  online_mode=${True}
    DevNJ_ASIR_Selenium.Clean Browser

Change Asir Accounts Passwords
    Run Keyword And Ignore Error  DevNJ_ASIR_Selenium.Logout  online_mode=${True}
    DevNJ_ASIR_Selenium.Clean Browser
    DevNJ_ASIR_Selenium.Asir Webem Login
    DevNJ_ASIR_Selenium.Enter Config Man  sub_menu=${config_menu}
    DevNJ_ASIR_Selenium.Change Accounts Password  account_type=${account_type_hub}  user_passwd_dict=${password_dict}
    ...    check_required=${False}
    DevNJ_ASIR_Selenium.Enter Config Man  sub_menu=${config_menu}
    DevNJ_ASIR_Selenium.Change Accounts Password  account_type=${account_type_wsuser}  user_passwd_dict=${password_dict_wsuser}
    ...    check_required=${False}
    Run Keyword And Ignore Error  DevNJ_ASIR_Selenium.Logout  online_mode=${True}
    DevNJ_ASIR_Selenium.Clean Browser

