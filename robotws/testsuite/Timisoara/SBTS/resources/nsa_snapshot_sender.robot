*** Settings ***
Library   DateTime
Library   String
Library   SSHLibrary
Library   OperatingSystem
Library   taf.sbts.oam.coam.admin  WITH NAME  admin

*** Variables ***
${LMP_IPv4}=  192.168.255.129

${LOG_SCR_VM_IP_CLASSICAL}=  10.42.158.55
${LOG_SCR_VM_LOGIN}=  ute
${LOG_SCR_VM_PASSWORD}=  Ut3pa5s#1be1
${SNAPSHOT_PATH}=  ${False}

*** Keywords ***
Get target snapshot name for Log Scrambling
    ${connection}=  admin.connect_to  ${LMP_IPv4}
    ${build}=  admin.get_sw_version  connection=${connection}
    ${current_time}=  Get Current Date  result_format=%d-%m-%Y_%H-%M  exclude_millis=${True}
    ${formatted_suite_name}=  Replace String  ${SUITE_NAME}  ${SPACE}  _
    ${name_of_snapshot}=  Set variable  ${build}_+${current_time}+${formatted_suite_name}
    ${path_to_snapshot}=  Set Variable  ${OUTPUT_DIR}/${name_of_snapshot}.zip
    [Return]  ${path_to_snapshot}
    [Teardown]  admin.teardown  connection=${connection}


Collect snapshot from BTS for Log Scrambling
    ${path_to_snapshot}=  Get target snapshot name for Log Scrambling
    ${connection}=  admin.connect_to  ${LMP_IPv4}
    Log  Download snapshot from bts into: ${path_to_snapshot}  console=${True}
    admin.get_snapshot          target_file_name=${path_to_snapshot}
    ...                         coverage=Full
    ...                         timeout=1200
    ...                         connection=${connection}
    Set suite variable  ${SNAPSHOT_PATH}  ${path_to_snapshot}
    [Teardown]  admin.teardown  connection=${connection}

Make snapshot copy for Log Scrambling
    ${src_snapshot}=  Set variable  ${SNAPSHOT_PATH}
    ${path_to_snapshot}=  Get target snapshot name for Log Scrambling
    Log  Copy snapshot from: ${src_snapshot} to: ${path_to_snapshot}  console=${True}
    Copy File  source=${src_snapshot}  destination=${path_to_snapshot}
    Set suite variable  ${SNAPSHOT_PATH}  ${path_to_snapshot}

Send Snapshot to VM server
    [Documentation]  Keyword to send snapshots to dedicated VM.
    [Arguments]  ${vm_host}  ${username}  ${password}  ${target_dir}  ${domain}  ${snapshot_file_path}
    Set suite variable  ${SNAPSHOT_PATH}  ${snapshot_file_path}
    Log  SNAPSHOT_PATH=${SNAPSHOT_PATH}  console=${True}
    Run Keyword Unless  '${SNAPSHOT_PATH}' == 'False'  Make snapshot copy for Log Scrambling
    Run Keyword If  '${SNAPSHOT_PATH}'=='False'  Collect snapshot from BTS for Log Scrambling
    ${command}=  Catenate  SEPARATOR=${SPACE}  sshpass -p ${password} rsync -r "${SNAPSHOT_PATH}"
    ...                                        ${username}@${vm_host}:"${target_dir}"
    Log  Send snapshot to VM with cmd=${command}  console=${True}
    Run  ${command}
    ${splitted_path}=  Split String  string=${SNAPSHOT_PATH}  separator=/
    Log  Splitted Path ${splitted_path}  console=${True}
    ${snapshot_name}=  Set Variable  ${splitted_path[-1]}
    ${snapshot_path_on_vm}=  Set Variable  ${target_dir}/${snapshot_name}
    Log  Run cmd on vm: ${snapshot_path_on_vm}  console=${True}
    SSHLibrary.Open Connection    ${vm_host}
    SSHLibrary.Login    ${username}    ${password}
    SSHLibrary.Execute Command    cd ~/proxy_script && source venv/bin/activate && python proxy_script.py ${snapshot_path_on_vm} ${domain}
    ${output}=  SSHLibrary.Read
    Log  ${output}  console=${True}
    [Teardown]    SSHLibrary.Close Connection

Check and Send Snapshot to Server
    [Arguments]  ${vm_host}  ${username}  ${password}  ${domain}  ${snapshot_path}=${False}
    ${target_dir}=  Set variable  ~/snapshots
    Send Snapshot to VM server  ${vmhost}  ${username}  ${password}  ${target_dir}  ${domain}  ${snapshot_path}

################################################ INTERFACE #############################################################
Check and Send Snapshot to Server CLASSICAL CDRT
    [Arguments]  ${snapshot_path}=${False}
    Check and Send Snapshot to Server  vm_host=${LOG_SCR_VM_IP_CLASSICAL}
    ...                                username=${LOG_SCR_VM_LOGIN}
    ...                                password=${LOG_SCR_VM_PASSWORD}
    ...                                domain=CDRT
    ...                                snapshot_path=${snapshot_path}

Check and Send Snapshot to Server CLASSICAL TRSSEC
    [Arguments]  ${snapshot_path}=${False}
    Check and Send Snapshot to Server  vm_host=${LOG_SCR_VM_IP_CLASSICAL}
    ...                                username=${LOG_SCR_VM_LOGIN}
    ...                                password=${LOG_SCR_VM_PASSWORD}
    ...                                domain=TRSSEC
    ...                                snapshot_path=${snapshot_path}

Check and Send Snapshot to Server CLASSICAL PMLOGS
    [Arguments]  ${snapshot_path}=${False}
    Check and Send Snapshot to Server  vm_host=${LOG_SCR_VM_IP_CLASSICAL}
    ...                                username=${LOG_SCR_VM_LOGIN}
    ...                                password=${LOG_SCR_VM_PASSWORD}
    ...                                domain=PMLOGS
    ...                                snapshot_path=${snapshot_path}

Check and Send Snapshot to Server CLASSICAL UUF
    [Arguments]  ${snapshot_path}=${False}
    Check and Send Snapshot to Server  vm_host=${LOG_SCR_VM_IP_CLASSICAL}
    ...                                username=${LOG_SCR_VM_LOGIN}
    ...                                password=${LOG_SCR_VM_PASSWORD}
    ...                                domain=UUF
    ...                                snapshot_path=${snapshot_path}

Check and Send Snapshot to Server CLASSICAL SISO
    [Arguments]  ${snapshot_path}=${False}
    Check and Send Snapshot to Server  vm_host=${LOG_SCR_VM_IP_CLASSICAL}
    ...                                username=${LOG_SCR_VM_LOGIN}
    ...                                password=${LOG_SCR_VM_PASSWORD}
    ...                                domain=SISO
    ...                                snapshot_path=${snapshot_path}

Check and Send Snapshot to Server CLASSICAL RRM
    [Arguments]  ${snapshot_path}=${False}
    Check and Send Snapshot to Server  vm_host=${LOG_SCR_VM_IP_CLASSICAL}
    ...                                username=${LOG_SCR_VM_LOGIN}
    ...                                password=${LOG_SCR_VM_PASSWORD}
    ...                                domain=RRM
    ...                                snapshot_path=${snapshot_path}
