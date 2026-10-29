*** Settings ***
Documentation
...  authors:      Kacper Witek, kacper.witek@nokia.com
...                Krystian Krakowski, krystian.krakowski@nokia.com
...  maintainers:  Kacper Witek, kacper.witek@nokia.com
...                Krystian Krakowski, krystian.krakowski@nokia.com
...                Mateusz Zachwieja, mateusz.zachwieja@nokia.com

Library    OperatingSystem
Library    Process
Library    String
Library    ./SSHExtension.py  WITH NAME  ssh
Library    taf.gnb.oam.coam.vdu.interface.vdu  WITH NAME  vdu
Library    taf.gnb.oam.coam.cu.interface.cu  WITH NAME  vcu
Library    Collections
Library    DateTime
Library    syslog_utils.py


Variables   variables.py


*** Keywords ***
Wait until all pods are ready
    [Arguments]  ${unit}  ${timeout}=1min
    Wait until keyword succeeds  ${timeout}  10s  Verify that all ${unit} pods are ready
    Log to console  ${\n}${unit}: All pods ready

Verify that all CU pods are ready
    [Tags]    robot:no-dry-run    # Fixes argument validation fails
    [Arguments]  ${count}=37  ${master_cu}=${MASTER_CU}  ${namespace_cu}=${NAMESPACE_CU}
    ${cu_master}=  ssh.Connect to  &{master_cu}
    Verify that all pods are ready  ${count}  ${master_cu}[alias]  ${namespace_cu}
    [Teardown]  ssh.Disconnect  connection=${master_cu}[alias]

Connect to one of master nodes
    [Documentation]  DEPRECATED
    [Arguments]  ${master_nodes}
    ${node}=  Wait until keyword succeeds  5x  1min  Try master node connection  ${master_nodes}
    [Return]  ${node}

Try master node connection
    [Documentation]  DEPRECATED
    [Arguments]  ${master_nodes}
    FOR  ${node}  IN  @{master_nodes}
        ${status}=    Run keyword and return status
        ...  ssh.Connect to  &{node}
        Return from keyword if  ${status}  ${node}
    END

Verify that all DU pods are ready
    [Documentation]  DEPRECATED
    [Arguments]  ${count}=20  ${master_du}=${MASTER_DU}  ${namespace_du}=${NAMESPACE_DU}
    ${master}=  Set variable  ${master_du}
    ssh.Connect to  &{master}
    Verify that all pods are ready  ${count}  ${master_du}[alias]  ${namespace_du}
    [Teardown]  ssh.Disconnect  connection=${master_du}[alias]

Verify that all pods are ready
    [Tags]    robot:no-dry-run    # Fixes argument validation fails
    [Arguments]  ${count}  ${alias}  ${namespace}=${NAMESPACE}  ${pod_list_readiness}=${POD_LIST_READINESS}
    [Documentation]  Verify that all pods from given namespace are Ready.
    ...  About pod conditions: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#pod-conditions
    ...
    ...  Examples:
    ...  | Verify that all pods are ready | cran1 |
    ${output}=  ssh.Execute  oc get pods -n ${namespace} -o jsonpath\=${pod_list_readiness}  connection=${alias}
    Should not start with  ${output}  error  msg=${output}  ignore_case=True
    ${line_count}=  Get line count  ${output}
    Run keyword if  ${line_count} != ${count}
    ...  Fail  Not all pods are created, expected: ${count}, got: ${line_count}.
    ${matches}=  Get regexp matches  ${output}  (.+),(False|Unknown)  1
    Run keyword unless  ${matches} == []
    ...  Log  Pods Ready status False or Unknown: ${matches}  console=True  repr=True

Verify that pod is ready
    [Tags]    robot:no-dry-run    # Fixes argument validation fails
    [Arguments]    ${pod_name}  ${namespace}
    [Documentation]  DEPRECATED
    ...  Verify that given pod is Ready.
    ...  About pod conditions: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#pod-conditions
    ...
    ...  Examples:
    ...  | Verify that pod is ready | po-cran1-cpif-0 | cran1 |
    ${readiness}=  Get pod readiness  ${pod_name}  ${namespace}
    ${status}=  Set variable  ${readiness}[status]
    Run keyword if  "${status}" != "True"
    ...  Fail  Pod ${pod_name} is not Ready:${\n}${readiness}
    [Return]  ${readiness}

Get pod readiness
    [Tags]    robot:no-dry-run    # Fixes argument validation fails
    [Arguments]    ${pod_name}  ${namespace}  ${pod_readiness}=${POD_READINESS}
    [Documentation]  DEPRECATED
    ...  Get Ready status from PodConditions of given pod.
    ...  About pod conditions: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#pod-conditions
    ...
    ...  Examples:
    ...  | Get pod readiness | po-cran1-cpif-0 | cran1 |
    ${output}=  ssh.Execute  oc get pod ${pod_name} -n ${namespace} -o jsonpath\=${pod_readiness}  connection=master
    ${output_json}=  Evaluate  json.loads(r"""${output}""")  json
    [Return]  ${output_json}

Wait for CU pod role change
    [Arguments]  ${pod_name}  ${role}  ${timeout}  ${retry}
    Wait until keyword succeeds  ${timeout}  ${retry}  CU pod/${pod_name} role should be ${role}

CU pod/${pod_name} role should be ${expected_role}
    ${role}=  Get CU pod/${pod_name} role
    Should be equal  ${role}  ${expected_role}  ignore_case=True
    Log to console  ${pod_name} is ${expected_role}

Get CU VNFCs
    [Tags]    robot:no-dry-run    # Fixes argument validation fails
    [Arguments]  ${oam_cu}=${OAM_CU}
    vcu.Connect to  &{oam_cu}
    ${states}=  vcu.Get VNFCs states  connection=${oam_cu}[alias]
    [Return]  ${states}
    [Teardown]  vcu.Disconnect  ${oam_cu}[alias]

Get CU pod/${pod_name} role
    ${VNFCs}=  Get CU VNFCs
    FOR  ${vnfc}  IN  @{VNFCs}
        Return from keyword if  '${vnfc}[name]' == '${pod_name}'  ${vnfc}[role]
    END

Get ${expected_role} CU ${component} pod name
    ${pods}=  Get component pod names  ${component}  ${MASTER_CU}  ${NAMESPACE_CU}
    FOR  ${pod}  IN  @{pods}
        ${role}=  Get CU pod/${pod} role
        Return from keyword if  '${role}' == '${expected_role}'  ${pod}
    END

Get component pod names
    [Tags]    robot:no-dry-run    # Fixes argument validation fails
    [Arguments]  ${component}  ${master}  ${namespace}
    ssh.Connect to  &{master}
    ${output}=  SSH.Execute
    ...  oc get pods -n ${namespace} -l vnfctype\=${component} -o jsonpath\='{.items[*].metadata.name}'  connection=${master}[alias]
    @{pod_names}=  Split string  ${output}
    [Return]  ${pod_names}
    [Teardown]  SSH.Disconnect  ${master}[alias]

Execute remote command in container with crictl
    [Tags]    robot:no-dry-run    # Fixes argument validation fails
    [Arguments]  ${master}  ${namespace}  ${pod}  ${container}  ${command}  ${check_exit_code}=${True}
    ${worker_name}=  Get pod worker  ${pod}  ${master}  ${namespace}
    ${worker_alias}=  Set variable  worker

    ssh.Connect to  &{master}
    ${worker}=  SSH.Connect to  hostname=${worker_name}  username=core  proxy=${master}[alias]  alias=${worker_alias}

    ${get_container_id_command}=  Set variable
    ...  sudo crictl ps --label "io.kubernetes.pod.name=${pod}" --label "io.kubernetes.container.name=${container}" --quiet
    ${container_id}=  SSH.Execute  ${get_container_id_command}  connection=${worker_alias}
    Run keyword if  ${check_exit_code}  SSH.Assert exit status  0  connection=${worker_alias}

    ${output}=  SSH.Execute  sudo crictl exec -it ${container_id} ${command}  connection=${worker_alias}
    Run keyword if  ${check_exit_code}  SSH.Assert exit status  0  connection=${worker_alias}

    [Return]  ${output}
    [Teardown]  Run keywords  SSH.Disconnect  ${worker_alias}
    ...         AND           SSH.Disconnect  ${master}[alias]

Get pod worker
    [Tags]    robot:no-dry-run    # Fixes argument validation fails
    [Arguments]  ${pod_name}  ${master}  ${namespace}
    ssh.Connect to  &{master}
    ${worker}=  SSH.Execute
    ...  oc get pod -n ${namespace} ${pod_name} -o jsonpath\='{.spec.nodeName}'  connection=${master}[alias]
    [Return]  ${worker}
    [Teardown]  SSH.Disconnect  ${master}[alias]

Send signal to remote processes in container
    [Arguments]  ${signal}  ${pattern}  ${master}  ${namespace}  ${pod}  ${container}
    ${output}=  Execute remote command in container  ${master}  ${namespace}  ${pod}  ${container}  pkill -${signal} -f "${pattern}" --oldest
    [Return]  ${output}

Execute remote command in container
    [Tags]    robot:no-dry-run    # Fixes argument validation fails
    [Arguments]  ${master}  ${namespace}  ${pod}  ${container}  ${command}
    ssh.Connect to  &{master}
    ${output}=  SSH.Execute  oc rsh -c ${container} -n ${namespace} ${pod} ${command}  connection=${master}[alias]
    [Return]  ${output}
    [Teardown]  SSH.Disconnect  ${master}[alias]

Get time from container
    [Arguments]  ${master}  ${namespace}  ${pod}  ${container}  ${args}=-Iseconds
    ${timestamp}=  Execute remote command in container  ${master}  ${namespace}  ${pod}  ${container}  date ${args}
    [Return]  ${timestamp}

Read container logs until re
    [Tags]    robot:no-dry-run    # Fixes argument validation fails
    [Arguments]  ${master}  ${namespace}  ${pod}  ${container}  ${regexp}  ${args}=${EMPTY}  ${path}=${None}  ${timeout}=10m
    ssh.Connect to  &{master}
    ${output}=  SSH.Execute  (oc logs -n ${namespace} ${pod} -c ${container} ${args} --follow &) | grep -m1 -B 10 -P '${regexp}'
    ...  connection=${master}[alias]  timeout=${timeout}
    ${line_index}=    Get Line Count    ${output}

    FOR    ${index}    IN RANGE    ${line_index}
        ${line}=    Get Line    ${output}    -${index + 1}
        ${line}=    Strip String    ${line}
        Run Keyword If    '${line}' == ''    Continue For Loop
        ${line}=    Run Keyword If    '${line}' != ''    Set Variable    ${line}
        Exit For Loop If    '${line}' != ''
    END

    Should match regexp  ${line}  ${regexp}

    Run keyword unless  ${path} == None  Write content to file  ${path}  ${output}
    [Return]  ${output}
    [Teardown]  SSH.Disconnect  ${master}[alias]

Wait for messages in container logs
    [Arguments]  ${master}  ${namespace}  ${pod}  ${container}  ${msg_list}  ${since_time}
    FOR  ${line}  IN  @{msg_list}
        ${msg}  ${timeout}  ${args} =  Split string  ${line}  separator=::  max_split=2
        Read container logs until re  ${master}  ${namespace}  ${pod}  ${container}  ${msg}  args=--since-time\=${since_time}  timeout=${timeout}
    END

Get container liveness using command
    [Tags]    robot:no-dry-run    # Fixes argument validation fails
    [Arguments]  ${master}  ${namespace}  ${pod}  ${container}
    ssh.Connect to  &{master}
    SSH.Execute  oc rsh -n ${namespace} -c ${container} ${pod} /usr/bin/genapik8s --is-alive > /dev/null 2>\&1  connection=${master}[alias]
    ${exit_code}=  SSH.Get exit status  connection=${master}[alias]
    [Return]  ${exit_code}
    [Teardown]  SSH.Disconnect  ${master}[alias]

Verify container liveness check exit code
    [Arguments]  ${master_node}  ${namespace}  ${pod}  ${container}  ${expected_exit_code}
    ${exit_code}=  Get container liveness using command
    ...  ${master_node}  ${namespace}  ${pod}  ${container}
    Should be equal as strings  ${exit_code}  ${expected_exit_code}

Wait until container liveness check returns exit code
    [Arguments]  ${master_node}  ${namespace}  ${pod}  ${container}  ${expected_exit_code}  ${timeout}=10s  ${retry}=1s
    Wait until keyword succeeds  ${timeout}  ${retry}  Verify container liveness check exit code
    ...  ${master_node}  ${namespace}  ${pod}  ${container}  ${expected_exit_code}

Wait until container restarts
    [Arguments]  ${master_node}  ${namespace}  ${pod}  ${container}  ${timeout_down}=30s  ${retry_down}=1s  ${timeout_up}=10s  ${retry_up}=1s
    Wait until container liveness check returns exit code
    ...  ${master_node}  ${namespace}  ${pod}  ${container}  1  ${timeout_down}  ${retry_down}
    Wait until container liveness check returns exit code
    ...  ${master_node}  ${namespace}  ${pod}  ${container}  0  ${timeout_up}  ${retry_up}
    Log to console  Container ${container} restarted

Get all snapshots
    [Tags]    robot:no-dry-run    # Fixes argument validation fails
    [Arguments]  ${vdu_connection}  ${vcu_connection}  ${timestamp}=${TIMESTAMP}  ${snapshot_path}=${OUTPUT DIR}/${TEST NAME}/${timestamp}
    ${du_master}=  vdu.Connect to  &{vdu_connection}
    ${cu_master}=  vcu.Connect to  &{vcu_connection}

    vdu.Get local snapshot  ${snapshot_path}  vdu_connection=${vdu_connection}[connection_name]  compressed_or_not=${True}
    ${snapshot_names}=  List files in directory  ${snapshot_path}  pattern=Snapshot_*zip
    Move file  ${snapshot_path}/${snapshot_names}[0]  ${snapshot_path}/vDU_snapshot.zip

    vcu.Get local snapshot  ${snapshot_path}  connection=${vcu_connection}[alias]
    ${snapshot_names}=  List files in directory  ${snapshot_path}  pattern=Snapshot_*zip
    Move file  ${snapshot_path}/${snapshot_names}[0]  ${snapshot_path}/vCU_snapshot.zip

    [Teardown]  Run keywords  vdu.Disconnect  vdu_connection=${vdu_connection}[connection_name]
    ...         AND           vcu.Disconnect  connection=${vcu_connection}[alias]

Collect logs from pods
    [Arguments]  ${master}  ${namespace}  ${args}=${EMPTY}  ${timestamp}=${TIMESTAMP}  ${log_dir}=${TEST_log_dir}/Pods
    ...  ${zipped}=${True}
    ${pod_names}=  Get all pods for namespace  ${master}  ${namespace}
    FOR  ${pod}  IN  @{pod_names}
        Get logs from pod  ${master}  ${namespace}  ${pod}  ${args}  ${timestamp}  ${log_dir}
    END
    ${sys_wrn_err_dir}    Set Variable    ${log_dir}/syslog_warns_and_errors
    ${sys_wrn_err_filepath}    Set Variable    ${sys_wrn_err_dir}/all_syslog_warns_and_errors.txt
    Create File    ${sys_wrn_err_filepath}
    @{lines_to_display}    Create List
    @{syslog_warn_files}    Find Files    ${sys_wrn_err_dir}    -iname    '*.LOG'
    FOR    ${syslog_warn_file}    IN    @{syslog_warn_files}
        ${warn_file_content}    Get File    ${syslog_warn_file}
        Run Keyword If    '''${warn_file_content}''' != ''    Append To File
        ...    ${sys_wrn_err_filepath}    ${warn_file_content}
        ${lines}    Get Lines Matching Regexp    ${warn_file_content}    .*ERR/cp_.*
        @{lines_list}    Split To Lines    ${lines}
        ${lines_to_display}    Combine Lists    ${lines_to_display}    ${lines_list}
        Remove File    ${syslog_warn_file}
    END
    Sort Syslogs In File    ${sys_wrn_err_filepath}
    Run keyword if  ${zipped}  Run keywords  Run process  zip  -jrm  ${log_dir}.zip  ${log_dir}
    ...                        AND           Remove directory  ${sys_wrn_err_dir}
    ...                        AND           Remove directory  ${log_dir}
    [Return]    ${lines_to_display}

Display Listed Logs As Robot Warnings
    [Arguments]    ${lines}
    ${list_length}    Get Length    ${lines}
    Return From Keyword If    ${list_length} == 0
    @{lines}    Sort Syslogs List    ${lines}
    FOR    ${line}    IN    @{lines}
      Log    ${TEST NAME} Syslog: ${line}    level=WARN
    END

Get all pods for namespace
    [Tags]    robot:no-dry-run    # Fixes argument validation fails
    [Arguments]  ${master}  ${namespace}
    ssh.Connect to  &{master}
    ${output}=  SSH.Execute  oc get pods -n ${namespace} -o jsonpath\='{.items[*].metadata.name}'  connection=${master}[alias]
    @{pod_names}=  Split string  ${output}
    [Return]  ${pod_names}
    [Teardown]  SSH.Disconnect  ${master}[alias]

Get logs from pod
    [Arguments]  ${master}  ${namespace}  ${pod}  ${args}=${EMPTY}  ${timestamp}=${TIMESTAMP}  ${log_dir}=${TEST_log_dir}/Pods
    ...  ${include_previous}=${False}
    ${container_names}=  Get all pod containers  ${master}  ${namespace}  ${pod}
    FOR  ${container}  IN  @{container_names}
        Get logs from container  ${master}  ${namespace}  ${pod}  ${container}  ${args}  ${timestamp}  ${log_dir}  ${include_previous}
    END

Get all pod containers
    [Tags]    robot:no-dry-run    # Fixes argument validation fails
    [Arguments]  ${master}  ${namespace}  ${pod}
    ssh.Connect to  &{master}
    ${output}=  SSH.Execute  oc get pods ${pod} -n ${namespace} -o jsonpath\='{.spec.containers[*].name}'  connection=${master}[alias]
    @{container_names}=  Split string  ${output}
    [Return]  ${container_names}
    [Teardown]  SSH.Disconnect  ${master}[alias]

Get logs from container
    [Tags]    robot:no-dry-run    # Fixes argument validation fails
    [Arguments]  ${master}  ${namespace}  ${pod}  ${container}  ${args}=${EMPTY}  ${timestamp}=${TIMESTAMP}
    ...  ${log_dir}=${TEST_log_dir}/Pods  ${include_previous}=${False}  ${timeout}=1m
    ssh.Connect to  &{master}
    ${remote_path}=  Set variable  /tmp/logs/${namespace}
    ${file_name}=  Set variable  ${master}[alias]_${pod}_${container}.log

    Create directory  ${log_dir}
    Create directory  ${log_dir}/syslog_warns_and_errors
    SSH.Execute  mkdir -p ${remote_path}  connection=${master}[alias]  timeout=${timeout}
    SSH.Assert exit status  0  connection=${master}[alias]

    Run keyword if  ${include_previous}
    ...  SSH.Execute  oc logs -p -n ${namespace} ${pod} -c ${container} ${args} >> ${remote_path}/${file_name}
    ...  connection=${master}[alias]  timeout=${timeout}
    SSH.Execute  oc logs -n ${namespace} ${pod} -c ${container} ${args} >> ${remote_path}/${file_name}
    ...  connection=${master}[alias]  timeout=${timeout}
    SSH.Download file  ${remote_path}/${file_name}  ${log_dir}/${file_name}  connection=${master}[alias]  timeout=${timeout}

    ${errors_filepath}    Replace String    ${log_dir}/syslog_warns_and_errors/${file_name}    .log    _syslog_err_and_warn.log
    ${result}    Run Process    grep    'ERR/\\|WRN/'    ${log_dir}/${file_name}    stdout=${errors_filepath}    shell=${True}
    File Should Exist    ${errors_filepath}

    [Teardown]  Run keywords  SSH.Execute  rm -f ${remote_path}/${file_name}  connection=${master}[alias]  timeout=${timeout}
    ...         AND           SSH.Disconnect  ${master}[alias]

Change interface status on a container
    [Arguments]  ${master}  ${namespace}  ${pod}  ${container}  ${interface}  ${status}
    ${command}=  Set variable  ip l set dev ${interface} ${status}
    Execute remote command in container with crictl  ${master}  ${namespace}  ${pod}  ${container}  ${command}

    ${regexp}=  Set variable  link down in kernel
    Read container logs until re  ${master}  ${namespace}  ${pod}  ${container}  ${regexp}
