*** Settings ***
Documentation
...  author:   Patryk Tatarek
...  contact:  patryk.tatarek@nokia.com

Resource  ../../../../common_resources/admin/admin.robot
Resource  ../../../../common_resources/netact/netact_operations.robot
Resource   ../../../../common_resources/swconfig/swconfig.robot

Library    OperatingSystem
Library    Collections
Library    String
Library    taf.fdsw.rc    WITH NAME    rescue
Library    SSHLibrary
Library    taf.transport.ssh  WITH NAME  ssh
Library    ./NESAS-B_resources.py
Library    taf.sbts.oam.coam.admin    WITH NAME   coam_admin

*** Variables ***
${PROXY_COMMAND}       ProxyCommand= ssh -W %h:%p
${SERV_USER}           serviceuser
${SERV_PASS}           Pl(FzaYj5~c5;q
${ATL_PATH}=           /home/ute/ATL_logs.txt

*** Keywords ***
Check all processes on BTS
    [Documentation]  Check if the given process is running for the root user
    [Arguments]    ${PROCESS}
    ${connection}=  Connect to BTS
    ${result_perm}=    ssh.execute    command=ps -aux | awk '($1=="root") && ($11~"${PROCESS}") {print $11}'
    ...                               connection=${connection}
    Should be Empty    ${result_perm}
    [Teardown]  Disconnect from BTS    ${connection}

Create SSH Keys and Add or Not Add to BTS
    [Arguments]                          ${user}  ${quantity}  ${key_type}  ${add_to_bts}=True
    ${connection}=                       Connect To ADMIN
    ${keypairs}=                         generate_keys_and_add_them_to_bts  ${add_to_bts}
    ...                                  ${quantity}
    ...                                  ${user}
    ...                                  ${key_type}
    ...                                  ${connection}
    [Teardown]                           Disconnect From ADMIN
    [Return]                             ${keypairs}

Configure SECADM FEATCADM And SECADM Objects
    [Arguments]  ${actServiceAccountSsh}=true
    ...          ${systemAcctPermEnable}=true
    ...          ${keyContinuation}=true
    Change Parameter In SECADM Object    actServiceAccountSsh  ${actServiceAccountSsh}
    Change Parameter In FEATCADM Object  systemAcctPermEnable  ${systemAcctPermEnable}
    Change Parameter In SECADM Object    keyContinuation       ${keyContinuation}

Change Parameter In FEATCADM Object
    [Arguments]                          ${parameter}  ${value}
    ${connection}=                       Connect To ADMIN
    Change Parameter On BTS              dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...                                  param_name=${parameter}
    ...                                  param_value=${value}
    ...                                  connection=${connection}
    [Teardown]                           Disconnect From ADMIN

Change Parameter In SECADM Object
    [Arguments]                          ${parameter}  ${value}
    ${connection}=                       Connect To ADMIN
    Change Parameter On BTS              dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                                  param_name=${parameter}
    ...                                  param_value=${value}
    ...                                  connection=${connection}
    [Teardown]                           Disconnect From ADMIN

Creating Test Directory with Key Files
    [Arguments]  ${filepaths}    ${dest_path}
    copy_files  ${filepaths}    ${dest_path}

Delete toor4nsn SSH Keys From BTS
    [Arguments]    ${filepaths}
    ${connection}=                       Connect to ADMIN
    delete_list_from                     MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                                  rootUserPublicKeys
    ...                                  ${connection}
    delete_files  ${filepaths}
    [Teardown]                           Disconnect from ADMIN

Delete Serviceuser SSH Keys From BTS And Locally
    [Arguments]  ${filepaths}
    ${connection}=                       Connect to ADMIN
    delete_list_from                     MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                                  serviceUserPublicKeys
    ...                                  ${connection}
    delete_files  ${filepaths}
    [Teardown]                           Disconnect from ADMIN

Check If Key For toor4nsn Is Updated
    ${all_toor4nsn_keys}=                Get All Keys For Given User  rootUserPublicKeys
    ${connection}=                       Connect To BTS
    ${key_in_toor4nsn_file}=             ssh.execute
    ...                                  command=cat /user/toor4nsn/.ssh/authorized_keys
    ...                                  connection=${connection}
    compare_keys                 ${all_toor4nsn_keys}     ${key_in_toor4nsn_file}
    [Teardown]                           Disconnect From BTS

Connect To Toor4nsn with ServiceUser
    [Arguments]    ${file_path}    ${toor4nsn_addr}    ${file_path1}    ${status}=True
    SSHLibrary.Open Connection    ${VM_IP}
    ${VM_PASS}=   Get Password
    SSHLibrary.Login    ${VM_USERNAME}   ${VM_PASS}
    Run Keyword If   '${status}'=='True'    SSHLibrary.Write    chmod 600 ${file_path}
    Run Keyword If   '${status}'=='True'    SSHLibrary.Write    chmod 600 ${file_path1}
    SSHLibrary.Write    ssh -o "${PROXY_COMMAND} -i ${file_path} ${SERV_USER}@${LMP_IP}" -i ${file_path1} ${toor4nsn_addr}
    SSHLibrary.Read Until  :~ >

Connect To Toor4nsn with Key
    [Arguments]    ${file_path}
    SSHLibrary.Open Connection    ${VM_IP}
    ${VM_PASS}=   Get Password
    SSHLibrary.Login    ${VM_USERNAME}   ${VM_PASS}
    SSHLibrary.Write    chmod 600 ${file_path}
    SSHLibrary.Write    ssh -i ${file_path} toor4nsn@${LMP_IP}
    SSHLibrary.Read Until  :~ >

Get Password
    ${VM_PASS}    Run    sudo cat /etc/ute/vncpasswd
    [Return]    ${VM_PASS}

Get All Keys For Given User
    [Arguments]              ${user_keys}
    ${scf_path}=             Download SCF
    ${all_user_keys}=        get_all_keys  ${scf_path}  ${user_keys}  ${BTS_ID}
    [Return]                 ${all_user_keys}

Connect To Toor4nsn with Toor4nsn
    [Arguments]    ${file_path}    ${toor4nsn_addr}    ${status}=True
    SSHLibrary.Open Connection    ${VM_IP}
    ${VM_PASS}=   Get Password
    SSHLibrary.Login    ${VM_USERNAME}   ${VM_PASS}
    Run Keyword If   '${status}'=='True'    SSHLibrary.Write    chmod 400 ${file_path}
    SSHLibrary.Write    ssh -i ${file_path} ${toor4nsn_addr}
    SSHLibrary.Read Until               expected=Password:
    SSHLibrary.Write                    text=${SSH_PASSWORD}
    SSHLibrary.Read Until               expected=:~ >

#Connect To Toor4nsn with ServiceUser
#    [Arguments]    ${file_path}    ${toor4nsn_addr}    ${file_path1}    ${status}=True
#    SSHLibrary.Open Connection    ${VM_IP}
#    ${VM_PASS}=   Get Password
#    SSHLibrary.Login    ${VM_USERNAME}   ${VM_PASS}
#    Run Keyword If   '${status}'=='True'    SSHLibrary.Write    chmod 400 ${file_path}
#    Run Keyword If   '${status}'=='True'    SSHLibrary.Write    chmod 400 ${file_path1}
#    SSHLibrary.Write    ssh -o "${PROXY_COMMAND} -i ${file_path} ${SERV_USER}@${LMP_IP}" -i ${file_path1} ${toor4nsn_addr}
#    SSHLibrary.Read Until  :~ >

Initated upload ATL to NetAct
    [Arguments]  ${connection}  ${path}=${ATL_path}
    get audit trail logs  ${connection}  adaptation_version=MRBTS-${tl.gnbs[0].global_bts_id}  path=${path}

Check If toor4nsn Has No Keys
   ${connection}=      Connect To BTS
   ${toor4nsn_key}=    ssh.execute  command=ls /user/toor4nsn/.ssh/  connection=cOAM_toor4nsn
   is_toot4nsn_key_empty  ${toor4nsn_key}
   [Teardown]          Disconnect From BTS

Send Logs to BTS
    [Arguments]   ${path}    ${free_space}    ${connection}
    ${free_space}=    Convert To Number    ${free_space}
    ${free_space}=    Convert To Integer    ${free_space}
    ssh.execute  command=cd ${path} && dd if=/dev/zero of=filename bs=1M count=${free_space}  connection=${connection}
