*** Settings ***
Documentation
...    Author: pawel.wroblewski@nokia.com
...    Maintainer: pawel.wroblewski@nokia.com
...    Description: Keywords for feature CB006939, based on 5GC002536
...    Team in charge: MN RAN Pz Krk 3 SG


Library    DateTime
Library    OperatingSystem
Library    taf.transport.ssh        WITH NAME   ssh
Library    testsuite.Krakow.OAM.features.CB006939.resources.CB006939_DA_keywords.CB006939_DA  WITH NAME  ck
Resource   taf/rfrl/bts/robot/gnb.robot


*** Variables ***
${MRBTS_ID}=   ${tl.gnbs[0].dus[0].instance_id}
${NRBTS_ID}=   ${tl.gnbs[0].dus[0].instance_id}
${NETACT_IP}=   ${tl.nms.nom.ssh_connections_info.addr}
${NETACT_USER}=  ${tl.nms.nom.ssh_connections_info.username}
${NETACT_PASSWORD}=   ${tl.nms.nom.ssh_connections_info.password}
${PATH_STORAGE}   /tmp/robot_tmp
${SNAPSHOT_NAME}   ${PATH_STORAGE}/snapshot_admin_robot.zip
${LOCAL_SNAPSHOT_PATH}   /tmp/test_snapshot.zip
${THRESHOLD_SIZE}    100000000
${MAX_DU_LOG_DURATION_LITTLE}   300.0
${MAX_DU_LOG_DURATION_BIG}   600.0
${MAX_DU_LOG_DURATION_LITTLE_AUTOMATIC}    300.0
${MAX_DU_LOG_DURATION_BIG_AUTOMATIC}    600.0
${TARGET_SYSLOG_START_STOP_LATENCY}   5.0
${TARGET_FREEZE_START_STOP_LATENCY}   1.0
${TARGET_REQUEST_FREEZE_LATENCY}      2.0


*** Keywords ***
Check DU snapshot collection time
    Verify snapshot collection time
    ...   runs=5
    ...   location=None
    ...   avg_snapshot_size=${THRESHOLD_SIZE}
    ...   avg_time_delta=${MAX_DU_LOG_DURATION_LITTLE}
    ...   max_time_delta=${MAX_DU_LOG_DURATION_BIG}


Remote Syslog Session Start_Stop Latency
    ck.check_syslog_start_stop_latency   mrbts_id=${MRBTS_ID}
    ...                                  start_stop_latency=${TARGET_SYSLOG_START_STOP_LATENCY}


Troubleshooting Data Freeze Duration
    ck.check_data_freeze_duration   request_freeze_latency=${TARGET_REQUEST_FREEZE_LATENCY}
    ...                             start_stop_freeze_latency=${TARGET_FREEZE_START_STOP_LATENCY}


Check Automatically Triggered Snapshot DU
    ${list_param_to_change}=    Create Dictionary
        ...     faultNumber=49
        ...     triggerType=onFaultDetection
    @{list}=    create list    ${list_param_to_change}

    Perform Configuration Parameter Recommissioning On gNB
        ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
        ...    param_name=faultSnapshotTriggers
        ...    operation=delete
        ...    param_value=${False}
        ...    skip_parameter_relation_errors=True
    Perform Configuration Parameter Recommissioning On gNB
        ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
        ...    param_name=faultSnapshotTriggers
        ...    operation=update
        ...    param_value=@{list}
        ...    skip_parameter_relation_errors=True
        ...    should_activate=True

    Block first cell

    Wait until keyword succeeds  1 min	5 sec  Verify Alarm is Active on gNB  fault_name=Cell blocked
    Log To Console    Alarm triggered

    wait until keyword succeeds   20min   20s    Check File Presence On NetAct
    Log To Console    File on Netact found
    ${snapshot_size}   Get File Size    ${LOCAL_SNAPSHOT_PATH}
    ${duration}   ck.get_snapshot_preparation_time  snapshot_dir=${LOCAL_SNAPSHOT_PATH}
    ck.compare_duration_with_threshold
    ...     duration=${duration}
    ...     size=${snapshot_size}
    ...     expected_big=${MAX_DU_LOG_DURATION_BIG_AUTOMATIC}
    ...     expected_small=${MAX_DU_LOG_DURATION_LITTLE_AUTOMATIC}
    ...     threshold=${THRESHOLD_SIZE}

    Log To Console    Reverting changes
    Unblock first cell


Check File Presence On Netact
    Log To Console    Checking File on NetAct
    Enable SSH Connection    IP=${NETACT_IP}    username=${NETACT_USER}    password=${NETACT_PASSWORD}    alias=NetAct
    Check File Presence And Remove    path=/d/oss/global/diagsnap/ne3sws    keyword=${MRBTS_ID}    alias=NetAct
    Disable SSH Connection    alias=NetAct


Enable SSH Connection
    [Arguments]   ${IP}    ${username}    ${password}    ${alias}
    Wait Until Keyword Succeeds    10min    30sec   ssh.Connect to   ${IP}   ${username}   ${password}   alias=${alias}


Disable SSH Connection
    [Arguments]    ${alias}
    ssh.disconnect    connection=${alias}


Check File Presence And Remove
    [Arguments]    ${path}    ${keyword}    ${alias}
    ${file_not_present}    set variable    NotPresent
    ${result}    ssh.execute    command=ls ${path} | grep ${keyword}    connection=${alias}
    ${filename}=   Set Variable If
    ...     ${result.count('${keyword}')}>${0}
    ...     ${result.replace('\n',' ').strip()}
    ...     ${file_not_present}
    ssh.Download File   ${path}/${filename}     ${LOCAL_SNAPSHOT_PATH}     connection=${alias}
    Run Keyword If    "${filename}"=="${file_not_present}"    Fail    File Not Present
    ssh.execute   command=cd ${path} && rm -rf ${filename}    connection=${alias}


Enable actCli parameter
    [Arguments]   ${du_web_address}
    Perform Object Recommissioning On gNB
        ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
        ...    parameter=actCli
        ...    operation=update
        ...    value=true
        ...    skip_parameter_relation_errors=True
        ...    should_activate=True


Block first cell
    ${cell_to_block}=   get_first_cell_id
    Block cell  cell_id=${cell_to_block}

Unblock first cell
    ${cell_to_block}=   get_first_cell_id
    Unblock cell  cell_id=${cell_to_block}
