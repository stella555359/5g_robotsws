*** Settings ***
Documentation     author: WangLixia
...               contact: lixia.wang@nokia-sbell.com
...               Common KWs for 5GC001575_QA and 5GC001575_QAA
Resource          ../../../None_Feature_SG1/OAM_Interface.robot


*** Variables ***
#${CFGFILE_ON_GIT}           /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/
#${DeltaPath}           ${CFGFILE_ON_GIT}/5GC001575/Delta_SCF.py
${OAM_TYPE}                 COAM
${USER_LOG_DIR}    /opt/ute/Logs
${UPDATE_FILE_PATH}    /opt/ute/tmp
#${CFGFILE_PATH}    /home/ute/TAF/cfgfile/
${WEBUI_URL}                https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_IP}                 ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${MRBTS_ID}     ${tl.gnbs[0].instance_id}
${NRBTS_ID}     ${tl.gnbs[0].global_bts_id}
${ASIK_IP}        ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${UTE_IP}         ${tl.core.default_ssh_connection_details.addr}
${UTE_USERNAME}    ${tl.core.default_ssh_connection_details.username}
${UTE_PASSWORD}    ${tl.core.default_ssh_connection_details.password}


##################define these variable for convenient############################

########################END of alias Define#######################################


*** Keywords ***

Start BTSlogs Collection
    run keyword and ignore error    run    command=cd /tmp/btslog2 ; rm -rf BTSLOG_TRACE_*.bin ; rm -rf SYSLOG_*.LOG
    run keyword and ignore error    btslog.create_btslog_collector
    ...   name=btslog
    ...   btslog_path=/opt/btslog/btslog
    ...   btslog_launcher_path=/opt/btslog/btslog_launcher
    ...   log_dir=/tmp/btslog2
    run keyword and ignore error    btslog.Set Global Alias     btslog
    run keyword and ignore error    core.setup_collectors      names=btslog
    run keyword and ignore error    core.start_collectors      names=btslog

Lock Cell
    [Arguments]   ${cell_idx}=2    ${timeout}=60
    COAM_WEBEM.LockUnlcokCell     cell_idx=${cell_idx}    action=lock
#    ${cell_info}=    selenium_coam.get_cell_info    cell_idx=${cell_idx}
#    log    ${cell_info}and ${cell_info['Status']['Administrative state']}
#    run keyword if    '${cell_info['Status']['Administrative state']}'=="Unlocked"
#    ...                selenium_coam.lock_cell    cell_idx=${cell_idx}    timeout=${timeout}
#    Wait Until Keyword Succeeds   4min   20s   verifyCellisLocked   ${cell_idx}

Unlock Cell
    [Arguments]   ${cell_idx}=2    ${timeout}=60
    COAM_WEBEM.LockUnlcokCell     cell_idx=${cell_idx}    action=unlock
#    ${cell_info}=    selenium_coam.get_cell_info    cell_idx=${cell_idx}
#    log    ${cell_info}and ${cell_info['Status']['Administrative state']}
#    run keyword if    '${cell_info['Status']['Administrative state']}'=="Locked"
#    ...                selenium_coam.unlock_cell    cell_idx=${cell_idx}   timeout=${timeout}
#    Wait Until Keyword Succeeds   4min   20s     verifyCellisUnlocked   ${cell_idx}

Get Cell Status
    [Arguments]  ${cell_idx}=${1}   ${cell_group_idx}=${0}   ${timeout}=10   ${connection}=COAM
    ${cell_idx}   Convert To Integer   ${cell_idx}
    ${cell_group_idx}  Convert To Integer    ${cell_group_idx}
    ${subcells_status}    coam.get_subcells_status   timeout=${timeout}    connection=${connection}
    ${status_dict}   Catenate   'operationalState':
    ...                         '${subcells_status["NRCELLGRP-${cell_group_idx}"]["NRCELL-${cell_idx}"]["NRCELL_R"]["operationalState"]}',
    ...                         'availabilityStatus':
    ...                         '${subcells_status["NRCELLGRP-${cell_group_idx}"]["NRCELL-${cell_idx}"]["NRCELL_R"]["availabilityStatus"]}',
    ...                         'administrativeState':
    ...                         '${subcells_status["NRCELLGRP-${cell_group_idx}"]["NRCELL-${cell_idx}"]["NRCELL_R"]["administrativeState"]}'
    ${subcell_status}    Evaluate   {${status_dict}}
    [Return]   ${subcell_status}

Cell Should Be Online
    [Arguments]  ${cell_idx}=${1}   ${cell_group_idx}=${0}   ${timeout}=10   ${connection}=COAM
    ${subcell_status}=  5GC001575_QA_Resources.Get Cell Status      cell_idx=${cell_idx}
    ...                                      cell_group_idx=${cell_group_idx}
    ...                                      timeout=${timeout}
    ...                                      connection=${connection}
    Should Be Equal As Strings  ${subcell_status["operationalState"]}   Enabled   ignore_case=${True}
#    Should Be Equal As Strings  ${subcell_status["availabilityStatus"]}  None     ignore_case=${True}
    Should Be Equal As Strings  ${subcell_status["administrativeState"]}  Unlocked   ignore_case=${True}

Cell Should Be Degraded
     [Arguments]  ${cell_idx}=${1}   ${cell_group_idx}=${0}   ${timeout}=10   ${connection}=COAM
    ${subcell_status}=  5GC001575_QA_Resources.Get Cell Status      cell_idx=${cell_idx}
    ...                                      cell_group_idx=${cell_group_idx}
    ...                                      timeout=${timeout}
    ...                                      connection=${connection}
    Should Be Equal As Strings  ${subcell_status["operationalState"]}   Enabled    ignore_case=${True}
    Should Be Equal As Strings  ${subcell_status["availabilityStatus"]}  Degraded    ignore_case=${True}
    Should Be Equal As Strings  ${subcell_status["administrativeState"]}  Unlocked     ignore_case=${True}

Cell Should Be Failed
    [Arguments]  ${cell_idx}=${1}   ${cell_group_idx}=${0}   ${timeout}=10   ${connection}=COAM
    ${subcell_status}=  5GC001575_QA_Resources.Get Cell Status      cell_idx=${cell_idx}
    ...                                      cell_group_idx=${cell_group_idx}
    ...                                      timeout=${timeout}
    ...                                      connection=${connection}
    Should Be Equal As Strings  ${subcell_status["operationalState"]}   Disabled    ignore_case=${True}
    Should Be Equal As Strings  ${subcell_status["availabilityStatus"]}  Failed     ignore_case=${True}
    Should Be Equal As Strings  ${subcell_status["administrativeState"]}  Unlocked   ignore_case=${True}

#######################    configuration operations    ################################################################
CM_WebEM.ModifyAndActiveListParameters
    [Arguments]    ${dist_name}    ${filter_param}    ${node_index}     ${new_value}
    ${string}    Convert To String    ${new_value}
    Wait Until Keyword Succeeds    2 times    30s
    ...    selenium_coam.set_parameter_value
    ...    dist_name=${dist_name}    filter_param=${filter_param}    node_index=${node_index}    new_value=${string}
    CM_WebEM.ValidateAndActiveParameters

CM_WebEM.ModifyParameter
    [Arguments]    ${dist_name}    ${filter_param}    ${new_value}
    ${string}    Convert To String    ${new_value}
    Wait Until Keyword Succeeds    2 times    30s
    ...    selenium_coam.set_parameter_value
    ...    dist_name=${dist_name}    filter_param=${filter_param}    new_value=${string}

CM_WebEM.ValidateAndActiveParameters
    [Arguments]    ${activate_plan_despite_errors}=True
    ${error}    selenium_coam.validate_plan
    log    ${error}
    Run Keyword If    '${activate_plan_despite_errors}'=='True'   selenium_coam.activate_plan    activate_plan_despite_errors=True
    ...    ELSE      selenium_coam.activate_plan

CM_WebEM.GetListParameter
    [Arguments]    ${dist_name}=MRBTS-1908/NRBTS-1050/NRCELL-1    ${filter_param}=First PDCCH monitoring occasion of paging occasion
    ...   ${node_index}=${0}
    ${value}   Wait Until Keyword Succeeds    2 times    30s
    ...    selenium_coam.get_parameter_value
    ...    dist_name=${dist_name}    filter_param=${filter_param}    node_index=${node_index}
    [Return]       ${value}

############################ alarm checking #################################################################
Alarm.Check Certain Alarm with Severity form Active Alarms
    [Arguments]     ${target_alarm_id}    ${target_fault_id}    ${target_fault_name}    ${target_severity}
    ${alarm_info}    selenium_coam.get_active_alarm_info
    Set test variable    ${alarm_info}
    ${length}    Get length     ${alarm_info}
    FOR    ${i}    IN RANGE    ${length}
        ${res}    run keyword and return status    Alarm.Check Certain Alarm  alarm_id=${alarm_info[${i}]['Alarm ID']}
    ...    fault_id=${alarm_info[${i}]['Fault ID']}    fault_name=${alarm_info[${i}]['Fault name']}   target_alarm_id=${target_alarm_id}
    ...    target_fault_id=${target_fault_id}    target_fault_name=${target_fault_name}    severity=${alarm_info[${i}]['Severity']}
    ...    target_severity=${target_severity}
        Run Keyword If    ${res}    Exit For Loop
    END
    run keyword if  not ${res}   Fail    Alarm ${target_alarm_id} not found!

Alarm.Check Certain Alarm
    [Arguments]   ${alarm_id}    ${fault_id}    ${fault_name}   ${target_alarm_id}    ${target_fault_id}    ${target_fault_name}
    ...   ${severity}   ${target_severity}
    run keyword and ignore error    should contain   container=${alarm_id}   item=${target_alarm_id}
    Run Keyword And Continue On Failure    should contain   container=${fault_id}   item=${target_fault_id}
    Run Keyword And Continue On Failure    should contain   container=${fault_name}   item=${target_fault_name}
    Run Keyword And Continue On Failure    should contain   container=${severity}   item=${target_severity}

Alarm.check alarm is not in active alarms
    [Arguments]      ${alarm_id}
    @{alarms}    selenium_coam.get_active_alarm_info    alarm_filter=${alarm_id}
    should be empty    ${alarms}
