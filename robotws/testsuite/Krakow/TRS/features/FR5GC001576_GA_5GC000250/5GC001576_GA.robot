*** Settings ***
Documentation
...    author: Jakub Kupiec, Marcin Szlapa
...    contact: jakub.kupiec@nokia.com, marcin.szlapa@nokia.com
...    Description: Test Cases 5GC001575-GA_I&V_5GC000250_Event_logging_on_RAU&RAC

Resource   testsuite/Krakow/resources/RAN_PZ_KRK4/linux_hardening/connections.robot
Resource   testsuite/Krakow/resources/throughput_ota_aeub_regression.robot
Resource   taf/rfrl/bts/robot/logs_collecting.robot
Resource   taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Library    testsuite.Krakow.resources.linux_accounts.python_keywords.Keywords    WITH NAME    keywords
Library    testsuite.Krakow.resources.cu_webem.cu_webem_keywords.CuWebem    WITH NAME    cu
Library    testsuite.Krakow.resources.linux_accounts.logging.cu_ruemlog.CuRuemlog   WITH NAME   ruem_log
Library    testsuite.Krakow.resources.scf.Scf    WITH NAME  scf
Variables  taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Force Tags    STATE_GNB_NOT_COMMISSIONED    CLOUD_5G_QC_ASIKR_ABILB4_AEUB
...           CRT__WITH__RAN_5G_TDD__WITH__master_pDU

Suite Setup      Preconditions_1576_GA
Suite Teardown   Postconditions
Test Setup       Common Preconditions
Test Teardown    Common Postconditions

*** Variables ***
${old_path}=   /home/ute/plan.xml

*** Test Cases ***
[1][1.0] 5GC001576-GA_5GC000250_023_Log_activity_from_SSH_DU_user_Logging_in
    Get actual time  gmt_timezone=True
    Toor4nsn one step authorization with ssh key
    Toor4nsn one step password authorization
    Serviceuser one step authorization with defined ssh key
    Serviceuser one step password authorization
    Check system_log events  6

[1][1.0] 5GC001576-GA_5GC000250_024_Log_activity_from_SSH_DU_user_Logging_out
    Get actual time  gmt_timezone=True
    Toor4nsn one step authorization with ssh key
    Toor4nsn one step password authorization
    Toor4nsn one step password authorization with ls cmd
    Serviceuser one step authorization with defined ssh key
    Serviceuser one step password authorization
    Serviceuser one step password authorization with ls cmd
    Check system_log events  7

[1][1.0] 5GC001576-GA_5GC000250_025_Log_activity_from_SSH_DU_unsuccessful_login_attempts
    Get actual time  gmt_timezone=True
    Toor4nsn one step authorization with invalid ssh key  should_fail=True
    Toor4nsn one step authorization with invalid password  should_fail=True
    Toor4nsn one step password authorization with incorrect user  should_fail=True
    Serviceuser one step authorization with invalid ssh key  should_fail=True
    Serviceuser one step password authorization with invalid password  should_fail=True
    Check system_log events  8

[1][1.0] 5GC001576-GA_5GC000250_026_Log_activity_from_SSH_DU_Maximum_number_of_login_attempts_is_exceeded
    Get actual time  gmt_timezone=True
    Change ssh max auth attempts parameter
    Toor4nsn one step authorization with invalid password repeatedly  should_fail=True
    Serviceuser one step authorization with invalid password repeatedly  should_fail=True
    Check system_log events  9

[1]5GC001576-GA_5GC000250_002_Log_activity_from_SSH_user_Logging_in
    ruem_log.set_time_before_event
    cu_serviceuser_one_step_password_authorization
    ruem_log.check_entry_in_ruemlog    operation=login    username=serviceuser    operationresult=success
    ...    additionaltext=Accepted keyboard-interactive/pam for serviceuser from .* port .* ssh2

[1]5GC001576-GA_5GC000250_005_Log_activity_from_SSH_unsuccessful_login_attempts
    ruem_log.set_time_before_event
    cu_serviceuser_one_step_incorrect_password_authorization    should_fail=True
    cu_robot_one_step_password_authorization_with_incorrect_username    should_fail=True
    ruem_log.check_entry_in_ruemlog    operation=login    username=serviceuser    operationresult=failure
    ...    additionaltext=Failed keyboard-interactive/pam for serviceuser from .* port .* ssh2
    ruem_log.check_entry_in_ruemlog    operation=login    username=nykaenen    operationresult=failure
    ...    additionaltext=Invalid user nykaenen from .* port .*

[1]5GC001576-GA_5GC000250_006_Log_activity_from_WebEM_unsuccessful_login_attempts
    ruem_log.set_time_before_event
    cu.login_to_cu_webem_with_incorrect_password
    cu.login_to_cu_webem_with_incorrect_username
    ruem_log.check_entry_in_ruemlog    operation=Login    username=Nemuadmin    operationresult=failure
    ...    additionaltext=Failed to authenticate the user
    ruem_log.check_entry_in_ruemlog    operation=Login    username=nykaenen    operationresult=failure
    ...    additionaltext=Authorization Failed\. Insufficient Access Rights

[1][1.0] 5GC001576-GA_5GC000250_008_Log_activity_from_SSH_Maximum_number_of_login_attempts_is_exceeded
    Update Parameter Of Delta Plan    param_name=sshMaxAuthAttempts    param_value=5
    Validate And Activate Delta Plan
    Delete Delta Plan From CU
    ruem_log.set_time_before_event
    cu_serviceuser_incorrect_password_authorization_with_limit_exceeded    should_fail=True
    ruem_log.check_entry_in_ruemlog    operation=login    username=serviceuser    operationresult=failure
    ...    additionaltext=error: maximum authentication attempts exceeded for serviceuser from .* port .* ssh2 .*

[1]5GC001576-GA_5GC000250_030_Log_activity_from_SSH_user_Logging_in_with_ssh_key
    ${new_path} =  scf.Add cu ssh keys  ${old_path}
    cu.Perform cu commissioning  ${new_path}
    ruem_log.set_time_before_event
    cu_serviceuser_one_step_authorization_with_ssh_key
    ruem_log.check_entry_in_ruemlog    operation=login    username=serviceuser    operationresult=success
    ...    additionaltext=Accepted publickey for serviceuser from .* port .* ssh2: RSA SHA256:.*

[1]5GC001576-GA_5GC000250_032_Log_activity_from_SSH_user_Logging_in_with_wrong_ssh_key
    Generate ssh keys    serviceuser
    ruem_log.set_time_before_event
    Cu serviceuser one step authorization with ssh key  should_fail=True
    ruem_log.check_entry_in_ruemlog    operation=login    username=serviceuser    operationresult=failure
    ...    additionaltext=Failed publickey for serviceuser from .* port .* ssh2:.*

[1]5GC001576-GA_5GC000250_010_Log_content_Event_time
    ruem_log.set_time_before_event
    cu.login_to_cu_webem
    ruem_log.check_entry_in_ruemlog    additionaltext=Success to generate new token    timestamp=.*

[1]5GC001576-GA_5GC000250_011_Log_content_Session_id
    ruem_log.set_time_before_event
    cu.login_to_cu_webem
    ruem_log.check_entry_in_ruemlog    additionaltext=Success to generate new token    sessionid=.*

[1]5GC001576-GA_5GC000250_012_Log_content_Client_IP
    ruem_log.set_time_before_event
    cu.login_to_cu_webem
    ruem_log.check_entry_in_ruemlog    additionaltext=Success to generate new token    clientaddress=.*

[1]5GC001576-GA_5GC000250_013_Log_content_Username
    ruem_log.set_time_before_event
    cu.login_to_cu_webem
    ruem_log.check_entry_in_ruemlog    additionaltext=Success to generate new token    username=Nemuadmin

[1]5GC001576-GA_5GC000250_014_Log_content_Operation
    ruem_log.set_time_before_event
    Download snapshot from CU
    ruem_log.check_entry_in_ruemlog    operation=trigger local snapshot start
    ruem_log.check_entry_in_ruemlog    operation=trigger local snapshot finish

[1]5GC001576-GA_5GC000250_015_Log_content_Transaction_id
    ruem_log.set_time_before_event
    Download snapshot from CU
    ruem_log.check_entry_in_ruemlog    operation=trigger local snapshot start    transaction=.*
    ruem_log.check_entry_in_ruemlog    operation=trigger local snapshot finish   transaction=.*

[1]5GC001576-GA_5GC000250_016_Log_content_Log_status
    ruem_log.set_time_before_event
    Download snapshot from CU
    ruem_log.check_entry_in_ruemlog    operation=trigger local snapshot start    operationresult=incomplete

[1]5GC001576-GA_5GC000250_020_Logs_are_not_visible_for_non-root_CU_user
    check_if_auth_log_is_visible_for_non_root_user

*** Keywords ***
Preconditions_1576_GA
    Common Suite Setup With Commissioning
    gnb_cu.Get Active CU Configuration   ${old_path}
    Delete root user ssh keys
    Delete service user ssh keys
    Change system account permission parameter    false
    Change key continuation parameter     false
    Generate ssh keys  toor4nsn
    Generate ssh keys  serviceuser
    Change webem keys  update  serviceuser
    Change webem keys  update  toor4nsn

Postconditions
    Delete ssh keys  toor4nsn
    Delete ssh keys  serviceuser
    Delete delta file
    Postconditions_DU_CU
