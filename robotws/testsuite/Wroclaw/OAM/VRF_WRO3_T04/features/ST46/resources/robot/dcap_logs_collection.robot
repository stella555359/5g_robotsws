*** Settings ***
Documentation
...     description:    Keywords for DCAP log collection.

Resource    taf/rfrl/utilities/utf_lab/utf_lab.robot
Resource    ../../st46_variables.robot
Resource    ../../st46_keywords.robot
Library     DateTime
Library     ../python/st46_rfrl_common.py
Library     taf.transport.ssh    WITH NAME    ssh
Library     taf.sw.dcap.rd    WITH NAME    rd
Library     taf.sw.syslog   WITH NAME   taf_syslog

*** Keywords ***
Create Global Directory For Gathering Logs
    [Documentation]  This keyword please use one time on start your Suite Setup (or directly after James).
    ...    This keyword make the empty directory as logs container. If you use this keyword multiple
    ...    times - you will have a lot of folders with folder with logs - you should avoid this.
    ${date}=               DateTime.Get Current Date
    Set Global Variable    ${global_date}    ${date}
    Set Global Variable    ${logs_path}      ${OUTPUT DIR}/TRS_SEC_${date[0:10]}/${date[11:19]}
    Run Keyword If         '${OTHER_LOGS}'!='None'
    ...                    Run Keywords
    ...                    Log    \nLOGS WILL BE GATHERED TO: ${logs_path}    console=${TRUE}
    ...    AND             Run  mkdir -p ${logs_path}

RFRL DCAP Setup
    [Arguments]     ${gnb_ip}=${NONE}
    RFRL Start DCAP Containers
    RFRL Create DCAP Connection
    RFRL Add GNB    gnb_ip=${gnb_ip}

RFRL Start DCAP Containers
    utf_lab.Start UTF Lab on UTE VM       timeout=600
    utf_lab.Update UTF Lab on UTE VM     timeout=3200

RFRL Create DCAP Connection
    [Arguments]     ${alias}=UTE_DCAP
    utf_lab.connect    alias=${alias}

RFRL Add GNB
    [Arguments]     ${gnb_ip}=${NONE}
    utf_lab.add_gnb    gnb_ip=${gnb_ip}

RFRL Start Trace
    [Arguments]    &{args_dict}
    RFRL Create DCAP Connection
    ${trace_id}=   utf_lab.start_trace_gnb     &{args_dict}
    [Return]       ${trace_id}

RFRL Collect Suite Logs to Specified Directory DCAP
    [Arguments]    ${dir_path}=${TEST_NAME}    ${mplane}=${NONE}
    Run Keyword And Ignore Error  RFRL Collect Logs to Specified Directory DCAP Keyword   ${dir_path}   ${mplane}

RFRL Collect Logs to Specified Directory DCAP Keyword
    [Arguments]    ${dir_path}=${TEST_NAME}    ${mplane}=${NONE}
    Create Local Directory For Entity Logs In Setup            ${dir_path}
    RFRL Collect SCF from BTS DCAP                             log_dir=${entity_logs_path}   with_name=init_scf.zip   gnb_ip=${mplane}
    ${snapshot_path}=   RFRL Collect Snapshot from BTS DCAP    log_dir=${entity_logs_path}   with_name=init_snapshot.zip   gnb_ip=${mplane}
    Collect ims2 file from Snapshot DCAP                       snapshot_path=${snapshot_path}

RFRL Start Collect Test Logs to Specified Directory DCAP
    Run Keyword And Ignore Error  Setup Syslog

RFRL Stop Collect Test Logs to Specified Directory DCAP
    [Arguments]    ${dir_path}=${TEST_NAME}    ${mplane}=${NONE}
    Run Keyword And Ignore Error  RFRL Collect Logs to Specified Directory DCAP Keyword   ${dir_path}   ${mplane}
    Run Keyword And Ignore Error  Collect Syslog Files

Create Local Directory For Entity Logs In Setup
    [Documentation]  This keyword is to use on start logs gathering. This keyword make the empty directory
    ...    with name like 'Suite_Setup', 'Suite_Teardown' or 'test_name'. In this folder are unique logs
    ...    for every test execution. This will help testers with fail analysis.
    [Arguments]    ${sub_dir_name}=${TEST_NAME}
    ${sub_dir_name_without_spaces}=    Evaluate    '${sub_dir_name}'.replace(' ','_').replace('&', '_')
    Set Global Variable                ${entity_logs_path}    ${logs_path}/${sub_dir_name_without_spaces}
    Log    \nLogs from this part of execution will be gathered to: ${entity_logs_path}
    ...    console=${TRUE}
    Run    mkdir -p ${entity_logs_path}

RFRL Collect SCF From BTS DCAP
    [Arguments]     ${log_dir}    ${with_name}    ${gnb_ip}=${NONE}
    Log             Collecting SCF from BTS           console=${TRUE}
    ${path}=        utf_lab.UTF Lab Collect SCF from BTS    gnb_ip=${gnb_ip}
    ...                                                     log_dir=${log_dir}
    ...                                                     with_name=${with_name}
    [Return]        ${path}

RFRL Collect Snapshot from BTS DCAP
    [Arguments]     ${log_dir}    ${with_name}    ${gnb_ip}=${NONE}
    Log             Collecting Snapshot from BTS
    ...             console=${TRUE}
    ${path}=        utf_lab.UTF Lab Collect Snapshot from BTS    gnb_ip=${gnb_ip}
    ...                                                          log_dir=${log_dir}
    ...                                                          with_name=${with_name}
    [Return]        ${path}

Collect Ims2 File From Snapshot DCAP
    [Documentation]    Extracts ims2 file from previously collected snapshot
    [Arguments]        ${snapshot_path}
    extract_ims2       snapshot_path=${snapshot_path}

RFRL Start Collecting Syslog From BTS DCAP
    [Documentation]     Starts syslog tracing
    [Arguments]         ${dir_path}     ${gnb_ip}=${NONE}
    Log                         Start tracing syslog with DCAP   console=${TRUE}
    ${gnb_custom_profile}=      Create List         condor5gSyslog
    ${dcap_syslog_trace_id}=    RFRL Start Trace    gnb_ip=${gnb_ip}   gnb_custom_profile=${gnb_custom_profile}
    ${dcap_syslog_trace_id}=    Set Variable                           ${dcap_syslog_trace_id}[tracer_id]
    Set Suite Variable          ${${dir_path}_dcap_syslog_trace_id}    ${dcap_syslog_trace_id}

RFRL Stop Gather Logs To Specified Directory In Teardown DCAP Keyword Container
    [Documentation]    Container with keywords for every teardown section
    [Arguments]        ${dir_path}    ${mplane}=${NONE}
    Run Keyword And Continue On Failure    Get Installed Python Packages List
    Run Keyword And Continue On Failure    RFRL Stop Collecting Syslog From BTS DCAP
    ...                                    dir_path=${dir_path}
    ...                                    log_dir=${entity_logs_path}
    ...                                    with_name=syslog.zip
    Run Keyword And Continue On Failure    RFRL Collect SCF From BTS DCAP
    ...                                    log_dir=${entity_logs_path}
    ...                                    with_name=teardown_scf.zip
    ...                                    gnb_ip=${mplane}
    ${snapshot_path}=                      Run Keyword And Continue On Failure
    ...                                    RFRL Collect Snapshot From BTS DCAP
    ...                                    gnb_ip=${mplane}
    ...                                    log_dir=${entity_logs_path}
    ...                                    with_name=teardown_snapshot.zip
    Run Keyword And Continue On Failure    Collect Ims2 File From Snapshot DCAP
    ...                                    snapshot_path=${snapshot_path}

RFRL Stop Collecting Syslog From BTS DCAP
    [Documentation]     Collects syslog tracing
    [Arguments]         ${dir_path}    ${log_dir}    ${with_name}
    Log                         Collecting syslog with DCAP  console=True
    RFRL Stop Trace And Collect Results     trace_id=${${dir_path}_dcap_syslog_trace_id}
    ...                                     log_dir=${log_dir}      with_name=${with_name}
    ${filepath}=        utf_lab.extract_logfile_from_zip    path=${log_dir}/${with_name}
    ...                                                  log_name=Syslog
    [Return]            ${filepath}

RFRL Stop Trace And Collect Results
    [Arguments]    ${trace_id}    ${log_dir}    ${with_name}
    RFRL Create DCAP Connection
    utf_lab.UTF Lab Stop Tracing and Collect Results    trace_id=${trace_id}
    ...                                                 log_dir=${log_dir}
    ...                                                 with_name=${with_name}

Get Installed Python Packages List
    Run    pip freeze > ${entity_logs_path}/python_packages.txt

Get SSH Logs
    Run Keyword And Ignore Error    Copy Snapshot With SSH
    Run Keyword And Ignore Error    Copy Raw Alarms

Copy Snapshot With SSH
    Log                           Copy Snapshot from BTS
    ...                           console=${TRUE}
    SSHLibrary.Open Connection    host=${SSH_IP}
    SSHLibrary.Login              username=${SSH_USERNAME}       password=${SSH_PASSWORD}
    Sleep  10                     reason=Time to correct login.
    SSHLibrary.Write              text=telnet 127.0.0.1 15007
    SSHLibrary.Read Until         AaShell>
    SSHLibrary.Write              text=log -a -z SSH_Snapshot.zip
    SSHLibrary.Read Until         AaShell>
    SSHLibrary.Close Connection
    ${connection}=                Connect To BTS With SSH
    ssh.Download File             remote_path=/ram/SSH_Snapshot.zip
    ...                           local_path=${entity_logs_path}/SSH_Snapshot.zip
    ...                           connection=copy_ssh_snapshot
    [Teardown]                    Disconnect From BTS With SSH    ${connection}

Copy Raw Alarms
    Log                  Copy Raw Alarms from BTS
    ...                  console=${TRUE}
    ${connection}=       Connect To BTS With SSH
    ssh.Download File    remote_path=/tmp/RawAlarmHistory.txt
    ...                  local_path=${entity_logs_path}/RawAlarmHistory_tmp.txt
    ...                  connection=${connection}
    ssh.Download File    remote_path=/ram/RawAlarmHistory.txt
    ...                  local_path=${entity_logs_path}/RawAlarmHistory_ram.txt
    ...                  connection=${connection}
    [Teardown]           Disconnect From BTS With SSH    ${connection}

Create Suite Metadata
    Run Keyword And Ignore Error    Set Suite Metadata    Branch      ${ENB_BRANCH}
    Run Keyword And Ignore Error    Set Suite Metadata    Build       ${ENB_BUILD}
    Run Keyword And Ignore Error    Set Suite Metadata    Testline    ${CONFIGURATION}

Setup Syslog
    [Arguments]    ${sub_dir_name}=${TEST_NAME}
    ${sub_dir_name_without_spaces}=  Evaluate  '${sub_dir_name}'.replace(' ','_').replace('&', '_')
    Set Global Variable  ${entity_logs_path}  ${logs_path}/${sub_dir_name_without_spaces}
    Run Keyword And Ignore Error  taf_syslog.Teardown All Aliases For Syslog
    Wait Until Keyword Succeeds  5m  30s  taf_syslog.start syslog  log_dir=${entity_logs_path}  log_name=SYSLOG.log  file_limit=104857600  # 100MB
    ...  add_line_number=True  alias=taf_syslog

Collect Syslog Files
    Log  Syslog collecting  console=${true}
    taf_syslog.Collect Syslog Results  destination=${entity_logs_path}/syslog.tar.gz  unzip=False  alias=taf_syslog
    [Teardown]  taf_syslog.Teardown All Aliases For Syslog

