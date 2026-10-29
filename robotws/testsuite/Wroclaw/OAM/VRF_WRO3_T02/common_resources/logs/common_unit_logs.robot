*** Settings ***
Documentation
...  Author: Konrad Krymowski
...  Contact: konrad.krymowski@nokia.com
...  Alternative contact: trsautowro@groups.nokia.com

Library     DateTime
Library     SSHLibrary
Library     OperatingSystem
Library     taf.transport.ssh          WITH NAME   ssh
Library     taf.collectors.core        WITH NAME   core
Library     taf.collectors.btslog      WITH NAME   btslog
Library     taf.sbts.oam.coam.admin    WITH NAME   coam_admin
Library     ./logs_functions.py

Resource    ../connections/connections.robot
Resource    ../admin/admin.robot
Resource    ../dcap/keywords.robot


*** Variables ***
${LMP_IP}=             ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${ROOT_USERNAME}=      ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${ROOT_PASSWORD}=      ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${SNAP_LOGS}=          FAIL       #Collect Snapshot. Possible settings: FAIL, ALWAYS, NONE
${OTHER_LOGS}=         ALWAYS     #Collect other logs. Possible settings: FAIL, ALWAYS, NONE

*** Keywords ***
Create Global Directory For Gathering Logs
    [Documentation]  This keyword please use one time on start your Suite Setup (or directly after James).
    ...    This keyword make the empty directory as logs container. If you use this keyword multiple
    ...    times - you will have a lot of folders with folder with logs - you should avoid this.
    ${date}=  DateTime.Get Current Date
    Set Global Variable  ${global_date}  ${date}
    Set Global Variable  ${logs_path}    ${OUTPUT DIR}/TRS_SEC_${date[0:10]}/${date[11:19]}
    IF    not '${OTHER_LOGS}'=='None'    Run Keywords
        ...  Log  \nLOGS WILL BE GATHERED TO: ${logs_path}  console=True
        ...  AND   Run  mkdir -p ${logs_path}
    END

Create Local Directory For Entity Logs In Setup
    [Documentation]  This keyword is to use on start logs gathering. This keyword make the empty directory
    ...    with name like 'Suite_Setup', 'Suite_Teardown' or 'test_name'. In this folder are unique logs
    ...    for every test execution. This will help testers with fail analysis.
    [Arguments]  ${sub_dir_name}=${TEST_NAME}
    ${sub_dir_name_without_spaces}=  Evaluate  '${sub_dir_name}'.replace(' ','_').replace('&', '_')
    Set Global Variable  ${entity_logs_path}  ${logs_path}/${sub_dir_name_without_spaces}
    Log  \nLogs from this part of execution will be gathered to: ${entity_logs_path}  console=True
    Run  mkdir -p ${entity_logs_path}

Start Gather Logs To Specified Directory
    [Arguments]    ${dir_path}=${TEST_NAME}
    IF    not '${OTHER_LOGS}'=='None'
        Run Keyword And Ignore Error  Start Gather Logs To Specified Directory Keyword Container    ${dir_path}
    END

Start Gather Logs To Specified Directory Keyword Container
    [Arguments]    ${dir_path}=${TEST_NAME}
    Create Local Directory For Entity Logs In Setup    ${dir_path}
    common_unit_logs.Collect Swconfig From BTS    init_config.txt
    common_unit_logs.Collect SCF From BTS         init_scf.xml
    common_unit_logs.BTSLOG Start Btslog On Local Machine
    common_unit_logs.Create ims2 Collection Connection

Stop Gather Logs To Specified Directory In Test Teardown
    [Documentation]  Keyword for every !!!TEST!!! teardown
    ...  Run Keyword If Test Failed     - available in Test Teardown
    ...  Run Keyword If Any Test Failed - available in Suite Teardown
    ...  So, for have a test-granularity logs (with shapshot if test failed), use this keyword in [Test Teardown].
    [Arguments]    ${dir_path}=${TEST_NAME}
    Run Keyword If   '${OTHER_LOGS}'=='FAIL'
    ...  Run Keyword If Test Failed  Stop Gather Logs To Specified Directory In Teardown    ${dir_path}
    ...  ELSE IF   '${OTHER_LOGS}'=='ALWAYS'
    ...  Stop Gather Logs To Specified Directory In Teardown    ${dir_path}
    Run Keyword If   '${SNAP_LOGS}'=='FAIL'  Run Keywords
    ...  Run Keyword If Test Failed  Run Keyword And Continue On Failure  common_unit_logs.Collect Snapshot From BTS
    ...  AND  Run Keyword If Test Failed  Run Keyword And Continue On Failure  common_unit_logs.Get SSH Logs
    ...  ELSE IF   '${SNAP_LOGS}'=='ALWAYS'  Run Keywords
    ...  Run Keyword And Continue On Failure   common_unit_logs.Collect Snapshot From BTS
    ...  AND   Run Keyword And Continue On Failure   common_unit_logs.Get SSH Logs

Stop Gather Logs To Specified Directory In Suite Teardown
    [Documentation]  Keyword dedicated for Suite Teardown
    [Arguments]    ${dir_path}
    Run Keyword If   '${OTHER_LOGS}'=='FAIL'
    ...  Run Keyword If Any Tests Failed  Stop Gather Logs To Specified Directory In Teardown    ${dir_path}
    ...  ELSE IF   '${OTHER_LOGS}'=='ALWAYS'
    ...  Stop Gather Logs To Specified Directory In Teardown    ${dir_path}
    Run Keyword If   '${SNAP_LOGS}'=='FAIL'  Run Keywords
    ...  Run Keyword If Any Tests Failed  Run Keyword And Continue On Failure  common_unit_logs.Collect Snapshot From BTS
    ...  AND   Run Keyword If Any Tests Failed  Run Keyword And Continue On Failure  common_unit_logs.Get SSH Logs
    ...  ELSE IF   '${SNAP_LOGS}'=='ALWAYS'  Run Keywords
    ...  Run Keyword And Continue On Failure  common_unit_logs.Collect Snapshot From BTS
    ...  AND   Run Keyword And Continue On Failure  common_unit_logs.Get SSH Logs

Stop Gather Logs To Specified Directory In Suite Setup Teardown
    [Documentation]  Keyword dedicated for Suite Setup
    [Arguments]    ${dir_path}
    IF    not '${OTHER_LOGS}'=='None'
        Stop Gather Logs To Specified Directory In Teardown    ${dir_path}
    END

Stop Gather Logs To Specified Directory In Teardown
    [Documentation]  Keyword for every teardown to collecting basic logs
    [Arguments]    ${dir_path}
    Run Keyword And Ignore Error   Stop Gather Logs To Specified Directory In Teardown Keyword Container    ${dir_path}

Stop Gather Logs To Specified Directory In Teardown Keyword Container
    [Documentation]  Container with keywords for every teardown section
    [Arguments]    ${dir_path}
    Run Keyword And Continue On Failure  common_unit_logs.Collect Swconfig From BTS  teardown_config.txt
    Run Keyword And Continue On Failure  common_unit_logs.Get Installed Python Packages List
    Run Keyword And Continue On Failure  common_unit_logs.BTSLOG Collect Btslog      ${dir_path}
    Run Keyword And Continue On Failure  common_unit_logs.Collect SCF From BTS       teardown_scf.xml
    Run Keyword And Continue On Failure  common_unit_logs.Get ims2 File From BTS

Create Suite Metadata
    Run Keyword And Ignore Error    Set Suite Metadata    Branch      ${ENB_BRANCH}
    Run Keyword And Ignore Error    Set Suite Metadata    Build       ${ENB_BUILD}
    Run Keyword And Ignore Error    Set Suite Metadata    Testline    ${CONFIGURATION}

#################### Basic Config-Files Section ####################
Collect Snapshot From BTS
    ${connection}=  Connect To Admin
    coam_admin.get_snapshot        target_file_name=${entity_logs_path}/snapshot.zip
    ...                       coverage=Full
    ...                       timeout=1200
    ...                       connection=${connection}
    [Teardown]  Disconnect From Admin

Collect Swconfig From BTS
    [Arguments]  ${filename}
    Connect to BTS
    ssh.Download File  remote_path=/ffs/run/swconfig.txt
    ...                local_path=${entity_logs_path}/${filename}
    ...                connection=cOAM_toor4nsn
    [Teardown]  ssh.Disconnect  connection=cOAM_toor4nsn

Collect SCF From BTS
    [Arguments]  ${filename}
    ${connection}=  Connect To Admin
    coam_admin.get_current_scf_file    local_dir_path=${entity_logs_path}
    ...                           connection=${connection}
    ...                           file_name=${filename}
    [Teardown]  Disconnect From Admin

Create ims2 Collection Connection
    Connect To Admin    alias=ims2_log

Get ims2 File From BTS
    [Documentation]  Gather ims2 logs to file. Connection must be created in Suite (Test) Setup.
    coam_admin.collect_infomodel_log_from_current_session
    ...    target_file_name=${entity_logs_path}/current_ims.ims2
    ...    timeout=300
    ...    alias=ims2_log
    [Teardown]    Disconnect From Admin    connection=ims2_log

Get Installed Python Packages List
    Run  pip freeze > ${entity_logs_path}/python_packages.txt

#################### BTSLOG Logs Section ####################
BTSLOG Start Btslog On Local Machine
    [Arguments]   ${name}=btslog
    ...           ${bts_logs_dir}=/tmp/btslog2
    common_unit_logs.Make Empty BTS Logs Dir      ${bts_logs_dir}
    btslog.create_btslog_collector
    ...    name=${name}
    ...    log_dir=${bts_logs_dir}
    core.setup_collectors        names=${name}
    core.start_collectors        names=${name}
    btslog.set_suite_alias       ${name}

BTSLOG Collect Btslog
    [Arguments]    ${dir_path}
    Run Keyword And Ignore Error    common_unit_logs.Stop And Collect Btslog On Local Machine    ${dir_path}

Stop And Collect Btslog On Local Machine
    [Arguments]    ${dir_path}    ${name}=btslog
    core.stop_collectors         names=${name}
    core.collect_collectors      names=${name}    target_dir=${dir_path}
    core.teardown_collectors     names=${name}

Make Empty BTS Logs Dir
    [Arguments]     ${bts_logs_dir}=/tmp/btslog2
    Run  if [ ! -d ${bts_logs_dir} ]; then mkdir ${bts_logs_dir}; else rm ${bts_logs_dir}/*; fi

#################### SYSLOG Logs Section ####################
Setup Syslog Collector
    [Arguments]  ${alias}=main_syslog  ${syslog_dir}=/tmp/btslog2
    Run Keyword And Ignore Error      Clear Suite Setup Syslog Alias
    Make Empty BTS Logs Dir           ${syslog_dir}
    btslog.create_btslog_collector    name=${alias}  log_dir=${syslog_dir}
    core.setup_collectors             names=${alias}
    core.start_collectors             names=${alias}
    btslog.set_test_alias             ${alias}

Stop And Collect Syslog
    [Arguments]  ${logs_dir}  ${alias}=main_syslog
    core.stop_collectors              names=${alias}
    core.collect_collectors           names=${alias}  target_dir=${logs_dir}
    core.teardown_collectors          names=${alias}

Check Syslog
    [Arguments]  ${logs_dir}  ${alias}=main_syslog
    logs_functions.check_errors_in_syslog  ${logs_dir}/${alias}

Clear Suite Setup Syslog Alias
    [Arguments]    ${dir_path}=${TEST_NAME}
    common_unit_logs.Stop And Collect Btslog On Local Machine    ${dir_path}

#################### SSH Logs Section ####################
Get SSH Logs
    Run Keyword And Ignore Error    Copy SSH Snapshot
    Run Keyword And Ignore Error    Copy Raw Errors

Copy SSH Snapshot
    Log    Copy Snapshot from BTS...    console=True
    SSHLibrary.Open Connection          host=${LMP_IP}
    SSHLibrary.Login                    username=${ROOT_USERNAME}       password=${ROOT_PASSWORD}
    Sleep  10                           reason=Time to correct login.
    SSHLibrary.Write                    text=telnet 127.0.0.1 15007
    SSHLibrary.Read Until               AaShell>
    SSHLibrary.Write                    text=log -a -z SSH_Snapshot.zip
    SSHLibrary.Read Until               AaShell>
    SSHLibrary.Close Connection
    Connect to BTS                      alias=copy_ssh_snapshot
    ssh.Download File  remote_path=/ram/SSH_Snapshot.zip
    ...                local_path=${entity_logs_path}/SSH_Snapshot.zip
    ...                connection=copy_ssh_snapshot
    [Teardown]  ssh.Disconnect  connection=copy_ssh_snapshot

Copy Raw Errors
    Log    Copy Raw Errors from BTS...    console=True
    Connect to BTS                      alias=copy_raw_errors
    ssh.Download File  remote_path=/tmp/RawAlarmHistory.txt
    ...                local_path=${entity_logs_path}/RawAlarmHistory_tmp.txt
    ...                connection=copy_raw_errors
    ssh.Download File  remote_path=/ram/RawAlarmHistory.txt
    ...                local_path=${entity_logs_path}/RawAlarmHistory_ram.txt
    ...                connection=copy_raw_errors
    [Teardown]  ssh.Disconnect  connection=copy_raw_errors

#################### DCAP Keywords Section ####################
Start Gather Logs To Specified Directory DCAP
    [Arguments]    ${dir_path}=${TEST_NAME}
    IF    not '${OTHER_LOGS}'=='None'
        Run Keyword And Ignore Error  Start Gather Logs To Specified Directory DCAP Keyword Container   ${dir_path}
    END

Start Gather Logs To Specified Directory DCAP Keyword Container
    [Arguments]    ${dir_path}=${TEST_NAME}
    Create Local Directory For Entity Logs In Setup         ${dir_path}
    Collect SCF from BTS DCAP                               path=${entity_logs_path}/init_scf
    ${snapshot_path}=   Collect Snapshot from BTS DCAP      path=${entity_logs_path}/init_snapshot
    Collect ims2 file from Snapshot DCAP                    snapshot_path=${snapshot_path}
    Start Collecting syslog from BTS DCAP                   dir_path=${dir_path}

Stop Gather Logs To Specified Directory In Teardown DCAP
    [Documentation]  Keyword for every teardown to collecting basic logs
    [Arguments]    ${dir_path}
    Run Keyword And Ignore Error   Stop Gather Logs To Specified Directory In Teardown DCAP Keyword Container
    ...                            ${dir_path}

Stop Gather Logs To Specified Directory In Teardown DCAP Keyword Container
    [Documentation]  Container with keywords for every teardown section
    [Arguments]    ${dir_path}
    Run Keyword And Continue On Failure     common_unit_logs.Get Installed Python Packages List
    Run Keyword And Continue On Failure     Stop Collecting Syslog from BTS DCAP
    ...                                     path=${entity_logs_path}/syslog   dir_path=${dir_path}
    Run Keyword And Continue On Failure     Collect SCF from BTS DCAP         path=${entity_logs_path}/teardown_scf
    ${snapshot_path}=   Run Keyword And Continue On Failure
    ...                                     Collect Snapshot from BTS DCAP    path=${entity_logs_path}/teardown_snapshot
    Run Keyword And Continue On Failure     Collect ims2 file from Snapshot DCAP
    ...                                                                       snapshot_path=${snapshot_path}

Stop Gather Logs To Specified Directory In Test Teardown DCAP
    [Documentation]  Keyword for every !!!TEST!!! teardown
    ...  Run Keyword If Test Failed     - available in Test Teardown
    ...  Run Keyword If Any Test Failed - available in Suite Teardown
    ...  So, for have a test-granularity logs (with shapshot if test failed), use this keyword in [Test Teardown].
    [Arguments]    ${dir_path}=${TEST_NAME}
    Run Keyword If   '${OTHER_LOGS}'=='FAIL'
    ...  Run Keyword If Test Failed
    ...                             Stop Gather Logs To Specified Directory In Teardown DCAP   ${dir_path}
    ...  ELSE IF   '${OTHER_LOGS}'=='ALWAYS'
    ...                             Stop Gather Logs To Specified Directory In Teardown DCAP  ${dir_path}
    Run Keyword If   '${SNAP_LOGS}'=='FAIL'  Run Keywords
    ...  Run Keyword If Test Failed  Run Keyword And Continue On Failure
    ...                             Collect Snapshot from BTS DCAP    path=${entity_logs_path}/teardown_snapshot
    ...  AND  Run Keyword If Test Failed  Run Keyword And Continue On Failure
    ...                             common_unit_logs.Get SSH Logs
    ...  ELSE IF   '${SNAP_LOGS}'=='ALWAYS'  Run Keywords
    ...  Run Keyword And Continue On Failure
    ...                             Collect Snapshot from BTS DCAP    path=${entity_logs_path}/teardown_snapshot
    ...  AND   Run Keyword And Continue On Failure
    ...                             common_unit_logs.Get SSH Logs

Stop Gather Logs To Specified Directory In Suite Teardown DCAP
    [Documentation]  Keyword dedicated for Suite Teardown
    [Arguments]    ${dir_path}
    Run Keyword If   '${OTHER_LOGS}'=='FAIL'
    ...  Run Keyword If Any Tests Failed  Stop Gather Logs To Specified Directory In Teardown DCAP    ${dir_path}
    ...  ELSE IF   '${OTHER_LOGS}'=='ALWAYS'
    ...  Stop Gather Logs To Specified Directory In Teardown DCAP    ${dir_path}
    Run Keyword If   '${SNAP_LOGS}'=='FAIL'  Run Keywords
    ...  Run Keyword If Any Tests Failed  Run Keyword And Continue On Failure
    ...                             Collect Snapshot from BTS DCAP    path=${entity_logs_path}/teardown_snapshot
    ...  AND  Run Keyword If Any Tests Failed  Run Keyword And Continue On Failure
    ...                             common_unit_logs.Get SSH Logs
    ...  ELSE IF   '${SNAP_LOGS}'=='ALWAYS'  Run Keywords
    ...  Run Keyword And Continue On Failure
    ...                             Collect Snapshot from BTS DCAP    path=${entity_logs_path}/teardown_snapshot
    ...  AND   Run Keyword And Continue On Failure
    ...                             common_unit_logs.Get SSH Logs

#################### DCAP RFRL Logs Section ####################
RFRL Start Gather Logs To Specified Directory DCAP
    [Arguments]    ${dir_path}=${TEST_NAME}    ${mplane}=${NONE}
    IF    not '${OTHER_LOGS}'=='None'
        Run Keyword And Ignore Error  RFRL Start Gather Logs To Specified Directory DCAP Keyword Container   ${dir_path}   ${mplane}
    END

RFRL Start Gather Logs To Specified Directory DCAP Keyword Container
    [Arguments]    ${dir_path}=${TEST_NAME}    ${mplane}=${NONE}
    Create Local Directory For Entity Logs In Setup            ${dir_path}
    RFRL Collect SCF from BTS DCAP                             log_dir=${entity_logs_path}   with_name=init_scf.zip   gnb_ip=${mplane}
    ${snapshot_path}=   RFRL Collect Snapshot from BTS DCAP    log_dir=${entity_logs_path}   with_name=init_snapshot.zip   gnb_ip=${mplane}
    Collect ims2 file from Snapshot DCAP                       snapshot_path=${snapshot_path}
    RFRL Start Collecting syslog from BTS DCAP                 dir_path=${dir_path}   gnb_ip=${mplane}

RFRL Stop Gather Logs To Specified Directory In Teardown DCAP
    [Documentation]  Keyword for every teardown to collecting basic logs
    [Arguments]    ${dir_path}    ${mplane}=${NONE}
    Run Keyword And Ignore Error   RFRL Stop Gather Logs To Specified Directory In Teardown DCAP Keyword Container
    ...                            ${dir_path}   ${mplane}

RFRL Stop Gather Logs To Specified Directory In Teardown DCAP Keyword Container
    [Documentation]  Container with keywords for every teardown section
    [Arguments]    ${dir_path}    ${mplane}=${NONE}
    Run Keyword And Continue On Failure    common_unit_logs.Get Installed Python Packages List
    Run Keyword And Continue On Failure    RFRL Stop Collecting Syslog from BTS DCAP
    ...                                        dir_path=${dir_path}   log_dir=${entity_logs_path}   with_name=syslog.zip
    Run Keyword And Continue On Failure    RFRL Collect SCF from BTS DCAP
    ...                                        log_dir=${entity_logs_path}      with_name=teardown_scf.zip   gnb_ip=${mplane}
    ${snapshot_path}=   Run Keyword And Continue On Failure
    ...                                    RFRL Collect Snapshot from BTS DCAP   gnb_ip=${mplane}
    ...                                        log_dir=${entity_logs_path}      with_name=teardown_snapshot.zip
    Run Keyword And Continue On Failure    Collect ims2 file from Snapshot DCAP
    ...                                        snapshot_path=${snapshot_path}

RFRL Stop Gather Logs To Specified Directory In Test Teardown DCAP
    [Documentation]  Keyword for every !!!TEST!!! teardown
    ...  Run Keyword If Test Failed     - available in Test Teardown
    ...  Run Keyword If Any Test Failed - available in Suite Teardown
    ...  So, for have a test-granularity logs (with shapshot if test failed), use this keyword in [Test Teardown].
    [Arguments]    ${dir_path}=${TEST_NAME}    ${mplane}=${NONE}
    Run Keyword If   '${OTHER_LOGS}'=='FAIL'
    ...  Run Keyword If Test Failed
    ...                             RFRL Stop Gather Logs To Specified Directory In Teardown DCAP   ${dir_path}   ${mplane}
    ...  ELSE IF   '${OTHER_LOGS}'=='ALWAYS'
    ...                             RFRL Stop Gather Logs To Specified Directory In Teardown DCAP  ${dir_path}   ${mplane}
    Run Keyword If   '${SNAP_LOGS}'=='FAIL'  Run Keywords
    ...  Run Keyword If Test Failed  Run Keyword And Continue On Failure
    ...                                  RFRL Collect Snapshot from BTS DCAP
    ...                                     log_dir=${entity_logs_path}   with_name=teardown_snapshot.zip   gnb_ip=${mplane}
    ...  AND  Run Keyword If Test Failed  Run Keyword And Continue On Failure
    ...                             common_unit_logs.Get SSH Logs
    ...  ELSE IF   '${SNAP_LOGS}'=='ALWAYS'  Run Keywords
    ...  Run Keyword And Continue On Failure
    ...                                  RFRL Collect Snapshot from BTS DCAP
    ...                                     log_dir=${entity_logs_path}   with_name=teardown_snapshot.zip   gnb_ip=${mplane}
    ...  AND   Run Keyword And Continue On Failure
    ...                             common_unit_logs.Get SSH Logs

RFRL Stop Gather Logs To Specified Directory In Suite Teardown DCAP
    [Documentation]  Keyword dedicated for Suite Teardown
    [Arguments]    ${dir_path}
    Run Keyword If   '${OTHER_LOGS}'=='FAIL'
    ...  Run Keyword If Any Tests Failed  RFRL Stop Gather Logs To Specified Directory In Teardown DCAP   ${dir_path}
    ...  ELSE IF   '${OTHER_LOGS}'=='ALWAYS'
    ...  RFRL Stop Gather Logs To Specified Directory In Teardown DCAP    ${dir_path}
    Run Keyword If   '${SNAP_LOGS}'=='FAIL'  Run Keywords
    ...  Run Keyword If Any Tests Failed  Run Keyword And Continue On Failure
    ...                                  RFRL Collect Snapshot from BTS DCAP
    ...                                     log_dir=${entity_logs_path}      with_name=teardown_snapshot.zip
    ...  AND  Run Keyword If Any Tests Failed  Run Keyword And Continue On Failure
    ...                             common_unit_logs.Get SSH Logs
    ...  ELSE IF   '${SNAP_LOGS}'=='ALWAYS'  Run Keywords
    ...  Run Keyword And Continue On Failure
    ...                                  RFRL Collect Snapshot from BTS DCAP
    ...                                     log_dir=${entity_logs_path}      with_name=teardown_snapshot.zip
    ...  AND   Run Keyword And Continue On Failure
    ...                             common_unit_logs.Get SSH Logs
#################### Blackbox Logs Section ####################
Check If Reset Counter Did Not Change
    ${reset_count}=   Get Reset Counter    source=ddal
    Should Be Equal    ${reset_count}    ${reset_suite}

Check If Reset Counter Incremented   #- commmon logs
    ${reset_count}=   Get Reset Counter    source=ddal
    ${reset_increment}=    Evaluate  ${reset_count} - ${reset_suite}
    ${passed}=             Evaluate    0 <= ${reset_increment} <= 3
    IF    not ${passed}
        Fail
    END
    Run Keyword If       ${passed}   Set Suite Variable  ${reset_suite}     ${reset_count}
    Run Keyword If       ${passed}   Log To Console    Reset counter - ${reset_count} (+${reset_increment})

Set Reset Counter Before Test   #- commmon logs
    ${reset_count}=    Get Reset Counter    source=ddal
    Set Suite Variable    ${reset_suite}    ${reset_count}
