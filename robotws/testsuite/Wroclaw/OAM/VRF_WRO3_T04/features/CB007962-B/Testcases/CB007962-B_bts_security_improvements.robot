*** Settings ***
Documentation  Continuous BTS product security improvements Part 5
...            test scenario author: Agnieszka Domagala
...            contact: agnieszka.domagala@nokia.com
...            test automation author: Adam Kufel
...            contact: adam.kufel@nokia.com

Resource   ../../../common_resources/admin/admin.robot
Resource   ../Resources/TestSpecificKeywords.robot

Library    ../Resources/test_specific_keywords.py
Library    ../Resources/audit_trail_logs.py

Library    taf.sbts.oam.coam.admin      WITH NAME   coam_admin

*** Variables ***
${SECADM_DN}=                           Set Variable    MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
${SSH_SESSION_IDLE_TIMER_DEFAULT}=      3600
${IDLE_TIME_FOR_AUTOLOGOUT}=            30
${DEFAULT_IDLE_TEST_TIME}=              60
${LMP_IP}=                              ${SSH_IP}
${ATL_PATH}=                            /home/ute/ATL_logs.txt

*** Keywords ***
CB007962-B_Check_if_sshSessionIdleTimer_is_configurable_in_prescribed_limits
    [Documentation]  Check PDL definition validation for values:
    ...              -1, 86401 => Expected definition errors presence
    ...              0, 1, 8640 => Expected these values are valid
    ...              [30.12.2022] BOAM ET transfer update - change parameters via NetAct
    ${SECADM_DN}=    Set Variable    MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ${scf}=   Download SCF   filename=initial_scf.xml
    ${netact_conn}=  netact_operations.Connect to NetAct
    ${output}=    Run keyword and ignore error
    ...     Change parameter to value via Netact    dist_name=${SECADM_DN}    parameter=sshSessionIdleTimer
    ...                                             value=-1    connection=${netact_conn}    scf=${scf}
    Log   Failed output is expected:\n${output}    console=yes
    check_definition_error_presence_in_netact_output     output=${output}  exp_status=OperationFailed
    ...                                                  exp_error_msg=Pdl validation failed
    Change parameter to value via Netact    dist_name=${SECADM_DN}    parameter=sshSessionIdleTimer
    ...                                     value=0    connection=${netact_conn}    scf=${scf}
    Change parameter to value via Netact    dist_name=${SECADM_DN}    parameter=sshSessionIdleTimer
    ...                                     value=1    connection=${netact_conn}    scf=${scf}
    Change parameter to value via Netact    dist_name=${SECADM_DN}    parameter=sshSessionIdleTimer
    ...                                     value=86400    connection=${netact_conn}    scf=${scf}
    ${output}=    Run keyword and ignore error
    ...     Change parameter to value via Netact    dist_name=${SECADM_DN}    parameter=sshSessionIdleTimer
    ...                                             value=86401    connection=${netact_conn}    scf=${scf}
    Log   Failed output is expected:\n${output}    console=yes
    check_definition_error_presence_in_netact_output     output=${output}  exp_status=OperationFailed
    ...                                                  exp_error_msg=Pdl validation failed
    [Teardown]  Run keywords            Change parameter to value via Netact    dist_name=${SECADM_DN}
    ...                                     parameter=sshSessionIdleTimer
    ...                                     value=${SSH_SESSION_IDLE_TIMER_DEFAULT}
    ...                                     connection=${netact_conn}    scf=${scf}
    ...                                 AND
    ...                                 netact_operations.Disconnect from NetAct  ${netact_conn}

CB007962-B_Check_if_SSH_user_is_automatically_logged-out_after_reach_set_period_of_inactivity
    [Documentation]     Precondition: executed ssh commands in session are logged in additionalText field
    ...                 in SSH Logout operation event related to this session.
    ...                 This precondition is covered by
    ...                 CB007962-B_Check_if_SSH_user_events_are_visible_in_RUEM_file_in_SLNBI_application
    ${SECADM_DN}=    Set Variable    MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    Turn off TLS
    ${conn}=  admin.Connect to ADMIN
    Change parameter on bts             dist_name=${SECADM_DN}
    ...                                 param_name=sshSessionIdleTimer
    ...                                 param_value=${IDLE_TIME_FOR_AUTOLOGOUT}
    ...                                 skip_parameter_relation_errors=${FALSE}
    ...                                 connection=${conn}
    ${token}=  Generate random string  8  123456789
    ${event_pwd}=  Set variable  echo autologout_tc_login_with_password_${token}
    Log to console  Perform ssh cmd: ${event_pwd}
    perform_ssh_event  hostname=${LMP_IP}         username=${SSH_USERNAME}  event=${event_pwd}
    ...                password=${SSH_PASSWORD}  auto_logout=${TRUE}        idle_time=${DEFAULT_IDLE_TEST_TIME}
    ...                log_output=${FALSE}

    ${private_key_path}=  Create ssh keys and upload on bts  connection=${conn}  dn=${SECADM_DN}
    ${token}=  Generate random string  8  123456789
    ${event_key}=  Set variable  echo autologout_tc_login_with_key_${token}
    Log to console  Perform ssh cmd: ${event_key}
    perform_ssh_event  hostname=${LMP_IP}           username=${SSH_USERNAME}  event=${event_key}
    ...                ssh_key=${private_key_path}  auto_logout=${TRUE}        idle_time=${DEFAULT_IDLE_TEST_TIME}
    ...                log_output=${FALSE}

    Sleep  ${DEFAULT_IDLE_TEST_TIME}s  reason=Wait for ATL logs collection
    ${atl_logs}=  Get cleaned ATL logs  atl_path=${ATL_PATH}       logs_age_in_s=1200
    ...                                 enable_filtering=${FALSE}  output_file=atl_logs_autologout_case.txt
    Sleep    300    reason=Wait more time to be sure that logs have been generated
    ${atl_logs}=  Get cleaned ATL logs  atl_path=${ATL_PATH}       logs_age_in_s=1200
    ...                                 enable_filtering=${FALSE}  output_file=atl_logs_autologout_case.txt
    check_atl_logs  atl_logs_file=${atl_logs}                   exp_operation=SSH Logout
    ...             exp_mrbts_id=${BTS_ID}    additional_text=${event_pwd}   log_status=Success
    check_atl_logs  atl_logs_file=${atl_logs}                   exp_operation=SSH Logout
    ...             exp_mrbts_id=${BTS_ID}    additional_text=${event_key}   log_status=Success

    [Teardown]  Run keywords            Change parameter on bts
    ...                                 dist_name=${SECADM_DN}
    ...                                 param_name=sshSessionIdleTimer
    ...                                 param_value=${SSH_SESSION_IDLE_TIMER_DEFAULT}
    ...                                 skip_parameter_relation_errors=${FALSE}
    ...                                 connection=${conn}
    ...                                 AND
    ...                                 admin.Disconnect from ADMIN  connection=${conn}
    ...                                 AND
    ...                                 Run keyword and ignore error    remove_ssh_keys  ${private_key_path}
    ...                                 AND
    ...                                 Run  rm ${ATL_PATH}

CB007962-B_Check_if_SSH_user_is_not_automatically_logged-out_when_subprocess_is_running_in_SSH_session
    [Documentation]     Precondition: executed ssh commands in session are logged in additionalText field in SSH Logout operation
    ...                 event related to this session.
    ...                 This precondition is covered by
    ...                 CB007962-B_Check_if_SSH_user_events_are_visible_in_RUEM_file_in_SLNBI_application
    ${SECADM_DN}=    Set Variable    MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ${conn}=  admin.Connect to ADMIN
    Change parameter on bts             dist_name=${SECADM_DN}
    ...                                 param_name=sshSessionIdleTimer
    ...                                 param_value=${DEFAULT_IDLE_TEST_TIME}
    ...                                 skip_parameter_relation_errors=${FALSE}
    ...                                 connection=${conn}
    ${token}=  Generate random string  8  123456789
    ${event}=  Set variable  echo subprocess_tc_${token} && vi
    Log to console  Perform ssh cmd: ${event}
    ${ssh_conn}=  perform_ssh_event  hostname=${LMP_IP}         username=${SSH_USERNAME}  event=${event}
    ...                              password=${SSH_PASSWORD}  auto_logout=${TRUE}        idle_time=45  close_conn=${FALSE}
    ...                              log_output=${FALSE}

    Sleep  ${DEFAULT_IDLE_TEST_TIME}s  reason=Wait for ATL logs collection
    ${atl_logs}=  Get cleaned ATL logs  atl_path=${ATL_PATH}       logs_age_in_s=1200
    ...                                 enable_filtering=${FALSE}  output_file=atl_logs_subprocess_case.txt
    Sleep    300    reason=Wait more time to be sure that logs have been generated
    ${atl_logs}=  Get cleaned ATL logs  atl_path=${ATL_PATH}       logs_age_in_s=1200
    ...                                 enable_filtering=${FALSE}  output_file=atl_logs_subprocess_case.txt
    check_if_operation_is_not_present_in_atl_logs  atl_logs_file=${atl_logs}                     unwanted_operation=SSH Logout
    ...                                            additional_text=echo subprocess_tc_${token}
    [Teardown]  Run Keywords            Change parameter on bts
    ...                                 dist_name=${SECADM_DN}
    ...                                 param_name=sshSessionIdleTimer
    ...                                 param_value=${SSH_SESSION_IDLE_TIMER_DEFAULT}
    ...                                 skip_parameter_relation_errors=${FALSE}
    ...                                 connection=${conn}
    ...                                 AND
    ...                                 admin.Disconnect from ADMIN  connection=${conn}
    ...                                 AND
    ...                                 close_ssh_connection  ${ssh_conn}
    ...                                 AND
    ...                                 Run  rm ${ATL_PATH}

CB007962-B_Check_if_SSH_user_events_are_visible_in_RUEM_file_in_SLNBI_application
    [Documentation]  4.01.2022  Approved changes (vs design steps):
    ...              - login with wrong password only
    ...              - check single login events with success and failure status
    ${SECADM_DN}=    Set Variable    MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    perform_login_with_wrong_password  hostname=${LMP_IP}  username=${SSH_USERNAME}  password=wrongpassword

    ${token}=  Generate random string  8  123456789
    ${event_pwd}=  Set variable  echo slnbi_tc_login_with_password_${token}
    Log to console  Perform ssh cmd: ${event_pwd}
    perform_ssh_event  hostname=${LMP_IP}  username=${SSH_USERNAME}  event=${event_pwd}  password=${SSH_PASSWORD}
    ...                log_output=${FALSE}

    ${conn}=  admin.Connect to ADMIN
    ${private_key_path}=  Create ssh keys and upload on bts  connection=${conn}  dn=${SECADM_DN}
    ${token}=  Generate random string  8  123456789
    ${event_key}=  Set variable  echo slnbi_tc_login_with_key_${token}
    Log to console  Perform ssh cmd: ${event_key}
    perform_ssh_event  hostname=${LMP_IP}  username=${SSH_USERNAME}  event=${event_key}  ssh_key=${private_key_path}
    ...                log_output=${FALSE}

    Sleep  ${DEFAULT_IDLE_TEST_TIME}s  reason=Wait for ATL logs collection
    ${atl_logs}=  Get cleaned ATL logs  atl_path=${ATL_PATH}       logs_age_in_s=1200
    ...                                 enable_filtering=${FALSE}  output_file=atl_logs_slnbi_case.txt
    Sleep    300    reason=Wait more time to be sure that logs have been generated
    ${atl_logs}=  Get cleaned ATL logs  atl_path=${ATL_PATH}       logs_age_in_s=1200
    ...                                 enable_filtering=${FALSE}  output_file=atl_logs_slnbi_case.txt
    check_atl_logs  atl_logs_file=${atl_logs}                   exp_operation=SSH Login
    ...             exp_mrbts_id=${BTS_ID}
    ...             log_status=Failure
    check_atl_logs  atl_logs_file=${atl_logs}                   exp_operation=SSH Login
    ...             exp_mrbts_id=${BTS_ID}
    ...             log_status=Success
    check_atl_logs  atl_logs_file=${atl_logs}                   exp_operation=SSH Logout
    ...             exp_mrbts_id=${BTS_ID}    additional_text=${event_pwd}
    ...             log_status=Success
    check_atl_logs  atl_logs_file=${atl_logs}                   exp_operation=SSH Logout
    ...             exp_mrbts_id=${BTS_ID}    additional_text=${event_key}
    ...             log_status=Success

    [Teardown]  Run Keywords            Change parameter on bts
    ...                                 dist_name=${SECADM_DN}
    ...                                 param_name=sshSessionIdleTimer
    ...                                 param_value=${SSH_SESSION_IDLE_TIMER_DEFAULT}
    ...                                 skip_parameter_relation_errors=${FALSE}
    ...                                 connection=${conn}
    ...                                 AND
    ...                                 admin.Disconnect from ADMIN  connection=${conn}
    ...                                 AND
    ...                                 Run keyword and ignore error    remove_ssh_keys  ${private_key_path}
    ...                                 AND
    ...                                 Run  rm ${ATL_PATH}
