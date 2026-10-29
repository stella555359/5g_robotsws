*** Settings ***
Documentation
...    author: Jakub Kupiec, Marcin Szlapa
...    contact: jakub.kupiec@nokia.com, marcin.szlapa@nokia.com
...    Description: Test Cases 5GC001250-GA_I&V_5GC000250_Event_logging_on_RAU&RAC

Resource   testsuite/Krakow/resources/throughput_ota_aeub_regression.robot
Resource   taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource   testsuite/Krakow/resources/RAN_PZ_KRK4/linux_hardening/connections.robot
Library    testsuite.Krakow.resources.linux_accounts.python_keywords.Keywords    WITH NAME    keywords
Library    testsuite.Krakow.resources.cu_webem.cu_webem_keywords.CuWebem    WITH NAME    cu
Resource   taf/rfrl/bts/robot/logs_collecting.robot
Variables  taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Force Tags    STATE_GNB_NOT_COMMISSIONED    CLOUD_5G_ASOD_AEUD_ENB

Suite Setup      Preconditions_1250_GA
Suite Teardown   Postconditions
Test Setup       Common Preconditions
Test Teardown    Common Postconditions

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

*** Keywords ***
Preconditions_1250_GA
    Common Suite Setup With Commissioning
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
