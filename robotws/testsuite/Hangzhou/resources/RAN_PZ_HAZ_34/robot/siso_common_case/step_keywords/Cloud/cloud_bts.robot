*** Settings ***
Library           taf.gnb.oam.coam.cu    WITH NAME    cu
Library           taf.gnb.oam.coam.vdu                                    WITH NAME   vdu
Library           taf.rfrl.cbts.utilities.generic_utils
Library           taf.rfrl.cbts.connections.rest_conn_vdu.GenericVDU    WITH NAME    vdu_gen
Library           taf.rfrl.cbts.connections.rest_conn_vcu.GenericCU  WITH NAME   vcu_gen
Library           taf.rfrl.cbts.connections.ssh_connections.SSHConnExec   WITH NAME   ssh_conn
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/cloud_analysis.py
Library           taf.hw.fhgw.cli                                         WITH NAME    issh
Resource          taf/rfrl/cbts/robot/vdu/vdu_operations.robot
Resource          taf/rfrl/cbts/robot/vcu/vcu_operations.robot
Resource          taf/rfrl/cbts/robot/vdu/vdu_log.robot
Resource          taf/rfrl/cbts/robot/vcu/vcu_log.robot

Documentation     This file contains keywords for operation relevant to both vDU and vCU.

*** Keywords ***
Cloud Lock vDU And Check Result
    [Documentation]    This keyword locks the vDU and checks the result.
    ...    *Author* tingting.zhong@nokia-sbell.com
    ...    *Group* VRF_HAZ4_04
    ...    *Detail*
    ...    It logs the start of the operation, generates a unique string for the connection alias, and logs into the vCU.
    ...    It then locks the vDU and waits until the operation state is successful.
    ...    If the operation is not successful within 3 minutes, it will fail.
    ...    After the operation, it logs out of the vCU.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | du_id_list | Yes | The list of vDU IDs to lock. |
    ...    | gnb_index | No | gnb index in testline configuration file. Default is 0. |
    ...
    ...    | =Return Values= | =Description= |
    [Arguments]  ${du_id_list}    ${gnb_index}=0
    log to console    \nLock vDU from cu
    ${conn_alias}    generic_utils.get_unique_id_string
    vcu_gen.login_rest    gnb_index=${gnb_index}   alias=${conn_alias}
    ${return_info}    cu.lock_du    ${du_id_list}    connection=${conn_alias}
    Wait Until Keyword Succeeds    3min    3s    Cloud Get Lock vDU Opeartion State    operation_id=${return_info["id"]}
    ...    conn_alias=${conn_alias}
    [Teardown]    vcu_gen.logout_rest    conn_alias=${conn_alias}

Cloud Unlock vDU And Check Result
    [Documentation]    This keyword unlocks the vDU and checks the result.
    ...    *Author* tingting.zhong@nokia-sbell.com
    ...    *Group* VRF_HAZ4_04
    ...    *Detail*
    ...    It logs the start of the operation, generates a unique string for the connection alias, and logs into the vCU.
    ...    It then unlocks the vDU and waits until the operation state is successful.
    ...    If the operation is not successful within 3 minutes, it will fail.
    ...    After the operation, it logs out of the vCU.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | du_id_list | Yes | The list of vDU IDs to lock. |
    ...    | gnb_index | No | gnb index in testline configuration file. Default is 0. |
    ...
    ...    | =Return Values= | =Description= |
    [Arguments]  ${du_id_list}    ${gnb_index}=0
    log to console    \nUnlock vDU from cu
    ${conn_alias}    generic_utils.get_unique_id_string
    vcu_gen.login_rest    gnb_index=${gnb_index}   alias=${conn_alias}
    ${return_info}    cu.unlock_du    ${du_id_list}    connection=${conn_alias}
    Wait Until Keyword Succeeds    3min    3s    Cloud Get Unlock vDU Opeartion State    operation_id=${return_info["id"]}
    ...    conn_alias=${conn_alias}
    [Teardown]    vcu_gen.logout_rest    conn_alias=${conn_alias}

Cloud Get Lock vDU Opeartion State
    [Documentation]    This keyword gets the operation state of locking the vDU.
    ...    *Author* tingting.zhong@nokia-sbell.com
    ...    *Group* VRF_HAZ4_04
    ...    *Detail*
    ...    It first gets the operation state by calling the `cu.get_opeartion_state_of_locking_du` keyword with the operation ID.
    ...    It then checks if the operation state is equal to the expected result.
    ...    If the operation state is not equal to the expected result, the keyword will fail.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | operation_id | Yes | The operation ID. |
    ...    | conn_alias | Yes | The alias for the connection . |
    ...    | expect_result | No | The expected result. Defaults to "success". |
    ...
    ...    | =Return Values= | =Description= |
    [Arguments]    ${operation_id}    ${conn_alias}    ${expect_result}=success
    ${opt_info}    cu.get_opeartion_state_of_locking_du    operation_id=${operation_id}    connection=${conn_alias}
    Should Be True    "${opt_info["status"]}"=="${expect_result}"

Cloud Get Unlock vDU Opeartion State
    [Documentation]    This keyword gets the operation state of unlocking the vDU.
    ...    *Author* tingting.zhong@nokia-sbell.com
    ...    *Group* VRF_HAZ4_04
    ...    *Detail*
    ...    It first gets the operation state by calling the `cu.get_opeartion_state_of_unlocking_du` keyword with the operation ID.
    ...    It then checks if the operation state is equal to the expected result.
    ...    If the operation state is not equal to the expected result, the keyword will fail.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | operation_id | Yes | The operation ID. |
    ...    | conn_alias | Yes | The alias for the connection . |
    ...    | expect_result | No | The expected result. Defaults to "success". |
    ...
    ...    | =Return Values= | =Description= |
    [Arguments]    ${operation_id}    ${conn_alias}    ${expect_result}=success
    ${opt_info}    cu.get_opeartion_state_of_unlocking_du    operation_id=${operation_id}    connection=${conn_alias}
    Should Be True    "${opt_info["status"]}"=="${expect_result}"

Cloud Save Snapshot and Log
    [Documentation]    This keyword saves the CU and vDU snapshots and collects logs from the vDU node.
    ...    *Author* tingting.zhong@nokia-sbell.com
    ...    *Group* VRF_HAZ4_04
    ...    *Detail*
    ...    It first logs the start of the operation, then triggers and saves local snapshots for CU and vDU.
    ...    It then logs the start of log collection from the vDU node and collects the logs.
    ...    If the log collection fails, it will not cause the keyword to fail.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...
    ...    | =Return Values= | =Description= |
    log to console    Save CU Snapshot...
    Trigger And Save Local Snapshot For CU
    log to console    Save VDU Snapshot...
    Trigger And Save Local Snapshot For vDU   compressed_or_not=${True}
    log to console    Collect Log from VDU Node...
    run keyword and ignore error    Collect Log from VDU Node

Collect Log from VDU Node
    [Documentation]    This keyword collects logs from the vDU node.
    ...    *Author* tingting.zhong@nokia-sbell.com
    ...    *Group* VRF_HAZ4_04
    ...    *Detail*
    ...    It first sets the script directory and generates a unique string for the connection alias.
    ...    It then connects to the vDU cloud hosting and executes several commands to collect different logs.
    ...    The logs are then saved to the specified local log file path.
    ...    If the log collection fails, it will not cause the keyword to fail.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | local_log_file_path | No | The local log file path, defaults to the value of ${SAVE LOG DIRECTORY}. |
    ...    | conn_prompt | No | The connection prompt, defaults to empty. |
    ...
    ...    | =Return Values= | =Description= |
    [Arguments]    ${local_log_file_path}=${SAVE LOG DIRECTORY}    ${conn_prompt}=${EMPTY}
    ${script_dir}    set variable    /var/home/core/kuafu/scenarios/vdu_l3call/
    ${alias}    generic_utils.get_unique_id_string
    ${ns}    tl_config.get_vdu_namespace    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ssh_conn.connect_to_vdu_cloud_hosting    using_tenant=${True}    prompt=${conn_prompt}
    ...  vdu_index=${vdu_index}    gnb_index=${gnb_index}    alias=${alias}
    ${pod_status}    ssh_conn.execute_normal_cmd     command=oc get pod -n ${ns}    alias=${alias}
    ${startup_summary}    ssh_conn.execute_normal_cmd     command=cd ${script_dir};./30-check-vdu-apps-startup-summary.sh
    ...    check_result=${False}    alias=${alias}
    OperatingSystem.Create File    ${local_log_file_path}/30-check-vdu-apps-startup-summary.log    ${startup_summary}
    ${startup_detail}    ssh_conn.execute_normal_cmd     command=cd ${script_dir};./31-check-vdu-apps-startup-detail.sh    alias=${alias}
    OperatingSystem.Create File    ${local_log_file_path}/31-check-vdu-apps-startup-detail.log    ${startup_detail}
    ${cell_setup_process_summary}    ssh_conn.execute_normal_cmd
    ...    command=cd ${script_dir};./60-check-vdu-cell-setup-process-summary.sh    alias=${alias}
    OperatingSystem.Create File    ${local_log_file_path}/60-check-vdu-cell-setup-process-summary.log    ${cell_setup_process_summary}
    ${cell_setup_process_detail}    ssh_conn.execute_normal_cmd
    ...    command=cd ${script_dir};./61-check-vdu-cell-setup-process-detail.sh    alias=${alias}
    OperatingSystem.Create File    ${local_log_file_path}/61-check-vdu-cell-setup-process-detail.log    ${cell_setup_process_detail}
    ${startup_journal_logs}    ssh_conn.execute_normal_cmd
    ...    command=cd ${script_dir};./90-collect-vdu-logs.sh startup,journal    alias=${alias}
    OperatingSystem.Create File    ${local_log_file_path}/90-collect-vdu-logs.log    ${startup_journal_logs}
    ${remote_log_name}    Get Regexp Matches    ${startup_journal_logs}    Total logs (.*?) stored    1
    ${remote_log_dir}    Get Regexp Matches    ${startup_journal_logs}    stored in (.*?) directory    1
    ssh_conn.download_file    remote_path=${remote_log_dir[0]}/${remote_log_name[0]}
    ...  local_path=${local_log_file_path}   alias=${alias}
    ssh_conn.execute_normal_cmd    command=rm -rf ${remote_log_dir[0]}/${remote_log_name[0]}   alias=${alias}
    [Teardown]  ssh_conn.disconnect_vdu_cloud_hosting    alias=${alias}

Cloud Full Commission
    [Documentation]    This keyword performs a full commissioning of the vDU and vCU.
    ...    *Author* tingting.zhong@nokia-sbell.com
    ...    *Group* VRF_HAZ4_04
    ...    *Detail*
    ...    It first logs the start of the operation for the vCU and performs a full SCF for the vCU.
    ...    It then logs the start of the operation for the vDU and performs a full SCF for the vDU.
    ...    It then checks if all cells are on air for the vDU and vCU.
    ...    If the cells are not on air within the specified time, the keyword will fail.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | cu_scf_path | Yes | The path to the SCF file for the vCU. |
    ...    | vdu_scf_path | Yes | The path to the SCF file for the vDU. |
    ...
    ...    | =Return Values= | =Description= |
    [Arguments]    ${cu_scf_path}    ${vdu_scf_path}
    log to console    commission scf for cu...
    Cloud Perform CU Full Scf    cu_scf_path=${cu_scf_path}
    log to console    commission scf for du...
    Cloud Perform VDU Full Scf    vdu_scf_path=${vdu_scf_path}
    log to console    check cell status should be on air for du...
    wait until keyword succeeds     20min    30s    All Cells Should Be Onair For One Specific vDU
    log to console    check cell status should be on air for cu...
    wait until keyword succeeds     5min    30s    All Cells Should Be Onair For One Specific vCU

All Rmods Should Be Onair For One Specific vDU
    [Documentation]    This keyword checks if all Rmods are on air for a specific vDU.
    ...    *Author* tingting.zhong@nokia-sbell.com
    ...    *Group* VRF_HAZ4_04
    ...    *Detail*
    ...    It first gets the list of RMOD IDs by calling the `Get RMOD ID List By RESTAPI` keyword.
    ...    It then iterates over each RMOD ID and checks if the status of the RU is unlocked by calling the `RU Status Should Be Unlocked` keyword.
    ...    If any RU is not unlocked, the keyword will fail.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | gnb_index | No | gnb index in testline configuration file. Default is 0. |
    ...    | vdu_index | No | vdu index in testline configuration file. Default is 0. |
    ...
    ...    | =Return Values= | =Description= |
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0
    ${rmod_id_list}    Get RMOD ID List By RESTAPI    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    FOR    ${ru_id}    IN    @{rmod_id_list}
        RU Status Should Be Unlocked    ru_id=${ru_id}    gnb_index=${gnb_index}   vdu_index=${vdu_index}
    END

Get VDU Version
    [Documentation]    This keyword gets the software version of the vDU.
    ...    *Author* tingting.zhong@nokia-sbell.com
    ...    *Group* VRF_HAZ4_04
    ...    *Detail*
    ...    It first generates a unique string for the connection alias and logs into the vDU.
    ...    It then gets the software version of the vDU from the webem and returns it.
    ...    After the operation, it logs out of the vDU.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | gnb_index | No | gnb index in testline configuration file. Default is 0. |
    ...    | vdu_index | No | vdu index in testline configuration file. Default is 0. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | sw_version | Yes | The software version of the vDU. |
    [Arguments]     ${gnb_index}=0  ${vdu_index}=${0}
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest   vdu_index=${vdu_index}   gnb_index=${gnb_index}   alias=${conn_alias}
    ${sw_version}    vdu_ope_base.get_vdu_sw_version_from_webem    conn_alias=${conn_alias}
    [Return]    ${sw_version}
    [Teardown]    vdu_gen.logout_rest    conn_alias=${conn_alias}

Cloud Check Counter Data
    [Documentation]    *****************
    ...    This keyword is used to check counter data.
    ...    - [Keyword Details]
    ...    It iterates over each counter ID and retrieves the counter values.
    ...    It checks if the last value in the response is an integer.
    ...    If not, the keyword will fail.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | dist_name | Yes | The distribution name. |
    ...    | counter_ids | Yes | The list of counter IDs. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 11.06.2024 - - Created
    ...    *******************
    ...    * Owner: kaihui.fan@nokia-sbell.com
    ...    * Group: VRF_HAZ4_04
    ...    *******************
    [Arguments]  ${dist_name}  ${counter_ids}  ${vdu_index}=0  ${gnb_index}=0
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest   vdu_index=${vdu_index}   gnb_index=${gnb_index}   alias=${conn_alias}
    ${datetime}=    Get Time    format=%Y-%m-%d
    ${date_and_time}=    Split String    ${datetime}    ${SPACE}
    ${date}=    Set Variable    ${date_and_time[0]}
    ${start_time}=  Set Variable  ${date}T00:00:00+08:00
    ${end_time}=    Set Variable  ${date}T23:59:59+08:00
    FOR  ${counter_id}  IN  @{counter_ids}
        ${res}=  vdu.Get Counter Values  counter_id=${counter_id}  dimension_dn=${dist_name}  vdu_connection=${conn_alias}
        ...   start_time_lower_limit=${start_time}  start_time_upper_limit=${end_time}
        ${value}=  Set Variable  ${res[-1]['value']}
        ${is_int}=  Evaluate  isinstance(${value}, int)
        Should Be True  ${is_int}
    END
    [Teardown]    vdu_gen.logout_rest    conn_alias=${conn_alias}

FHGW_Reset_With_Duration_Check
    [Arguments]  ${vdu_index}=0    ${gnb_index}=0    ${fhgw_index}=0    ${user_unexpected_alarms}=@{EMPTY}
    [Documentation]    *****************
    ...    This keyword is designed to check duration and alarms after performming FHGW reset.
    ...    - [Keyword Details]
    ...    It firstly ssh to FHGW and then reboot. After that, it will check the duration and alarms.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | vdu_index | No | The vdu index. Default is 0. |
    ...    | gnb_index | No | The gnb index. Default is 0. |
    ...    | fhgw_index | No | The fhgw index. Default is 0. |
    ...    | user_unexpected_alarms | No | user defined unexpected alarms, default is empty |
    ...
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |
    ...
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 09.07.2024 - - Created
    ...    *******************
    ...    *Author* xuewen.zhang@nokia-sbell.com
    ...    *Group* VRF_HAZ4_05
    ...    *******************
    ${conn_alias}    Connect to FHGW by SSH
    ${start_time_stamp}    robot.libraries.DateTime.Get current date    result_format=%Y-%m-%d_%H-%M-%S
    Log To Console    \n FHGW-${fhgw_index} Reset in progress start at: ${start_time_stamp}
    ${out}   issh.Execute   command=sudo reboot   check_result=${False}   alias=${conn_alias}
    #FHGW reset in progress, to avoid flood prints of waiting for cell onair
    Sleep    5min
    Wait Until Keyword Succeeds  10min   5s
    ...    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${end_time_stamp}    robot.libraries.DateTime.Get current date    result_format=%Y-%m-%d_%H-%M-%S
    Run Keyword And Continue On Failure    vdu_fm.Checking No unexpected Active Alarms Raised
    ...    user_unexpected_alarms=${user_unexpected_alarms}
    Run Keyword And Continue On Failure    vcu_fm.Checking No unexpected Active Alarms Raised
    ...    user_unexpected_alarms=${user_unexpected_alarms}
    Log To Console    \n FHGW-${fhgw_index} Reset completed at: ${end_time_stamp}
    ${duration}=    Subtract Date from Date    ${end_time_stamp}    ${start_time_stamp}
    Set Test Variable    ${duration}
    Log To Console    \n FHGW-${fhgw_index} Reset duration: ${duration}s
    [Teardown]    vdu_gen.logout_rest    conn_alias=${conn_alias}

Connect to FHGW by SSH
    [Arguments]  ${vdu_index}=0    ${gnb_index}=0    ${fhgw_index}=0
    ...    ${FHGW_IP}=${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[${fhgw_index}].ip}
    ...    ${FHGW_USERNAME}=${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[${fhgw_index}].username}
    ...    ${FHGW_PASSWORD}=${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[${fhgw_index}].password}
    [Documentation]    *****************
    ...    This keyword is designed to connect to fhgw.
    ...    - [Keyword Details]
    ...    It connects to fhgw via ssh.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | vdu_index | No | The vdu index. Default is 0. |
    ...    | gnb_index | No | The gnb index. Default is 0. |
    ...    | fhgw_index | No | The fhgw index. Default is 0. |
    ...    | FHGW_IP | No | the fhgw ip to ssh. Default is got from tl config. |
    ...    | FHGW_USERNAME | No | the fhgw username to ssh. Default is got from tl config. |
    ...    | FHGW_PASSWORD | No | the fhgw password to ssh. Default is got from tl config. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | conn_alias | This connection alias used to ssh fhgw. |
    ...
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 09.07.2024 - - Created
    ...    *******************
    ...    *Author* xuewen.zhang@nokia-sbell.com
    ...    *Group* VRF_HAZ4_05
    ...    *******************
    ${conn_alias}    generic_utils.get_unique_id_string
    issh.connect_to    ip=${FHGW_IP}   port=22    username=${FHGW_USERNAME}   password=${FHGW_PASSWORD}
    ...   alias=${conn_alias}   width=200
    [Return]    ${conn_alias}

Fix OCP Syslog Format
    [Documentation]    This keyword fix OCP Syslog Format from the vDU node.
    ...    *Author* jie.2.li@nokia-sbell.com
    ...    *Group* VRF_HAZ4_04
    ...    *Detail*
    ...    OCP Syslog Format should be fixed after OCP upgrade
    ...    more imformation plese see ticket: https://jiradc.ext.net.nokia.com/browse/WESTLAKE-10335
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | conn_prompt | No | The connection prompt, defaults to empty. |
    ...    | =Return Values= | =Description= |
    ${KUBECTL_CMD}    Set Variable    kubectl get node | grep -v NAME
    ${AWK_CMD}        Set Variable    awk '{print $1}'
    ${SSH_CMD}        Set Variable    ssh -o StrictHostKeyChecking=no {}
    ${CHECK_CMD}      Set Variable    cat /etc/inputrc | grep 'set enable-bracketed-paste off'
    ${ECHO_CMD}       Set Variable    echo 'set enable-bracketed-paste off' | sudo tee -a /etc/inputrc
    ${alias}    generic_utils.get_unique_id_string
    ssh_conn.connect_to_vdu_cloud_hosting    using_tenant=${True}    alias=${alias}
    ${cmd}    Set Variable    ${KUBECTL_CMD} | ${AWK_CMD} | xargs -I {} ${SSH_CMD} \"${CHECK_CMD} || ${ECHO_CMD}\"
    ${result}    ssh_conn.execute_normal_cmd    base_command=${cmd}    alias=${alias}
    [Teardown]  ssh_conn.disconnect_vdu_cloud_hosting    alias=${alias}

Get Customized Scf From Tag
    [Documentation]    This keyword gets the customized CU and vDU SCF file path according to the case tag.
    ...    *Author* shifu.lan@nokia-sbell.com
    ...    *Group* VRF_HAZ4_04
    ...    *Detail*
    ...    It returns the customized CU and vDU SCF file path if case tag contains 'S-', otherwise returns golden CU and vDU SCF file path.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...
    ...    | =Return Values= | =Description= |
    ...    | CU_SCF_Path | The SCF file for CU commissioning. |
    ...    | vDU_SCF_Path | The SCF file for vDU commissioning. |
    ...    | Status | The result if getting customized SCF file for commissioning. |
    ${CU_SCF_Path}    set variable    ${Golden_CU_SCF_Path}
    ${vDU_SCF_Path}    set variable    ${Golden_VDU_SCF_Path}
    ${Status}    set variable    ${False}
    ${flag}    set variable    ${False}
    FOR    ${tag}    IN    @{TEST_TAGS}
        ${flag}    run keyword and return status    Should contain    ${tag}    S-
        run keyword if    ${flag}    Log to console    Case TAG:${tag}
        ${CU_SCF_Path}    run keyword if    ${flag}    Replace String    ${Golden_CU_SCF_Path}    .xml    _${tag}.xml
        ...           ELSE    set variable    ${Golden_CU_SCF_Path}
        ${vDU_SCF_Path}    run keyword if    ${flag}    Replace String    ${Golden_VDU_SCF_Path}    .xml    _${tag}.xml
        ...           ELSE    set variable     ${Golden_VDU_SCF_Path}
        ${Status}    set variable if    ${flag}==${True}    ${True}    ${False}
        exit for loop if    ${flag}
    END
    [Return]   ${CU_SCF_Path}   ${vDU_SCF_Path}    ${Status}
