*** Settings ***
Documentation  ssh utils
Library     taf.transport.ssh  WITH NAME  ssh
Resource    unpacking.robot

*** Variables ***
${host_ip}                      192.168.255.129
${msm_ip}                       192.168.255.1
${esm_ip}                       192.168.255.119
${user_name}                    toor4nsn
${password}                     oZPS0POrRieRtu
${tar_gz_file_name_from_ESM}    files_from_ESM.tar
${tar_gz_file_name_from_MSM}    files_from_MSM.tar
${VM_username}                  ute
${ssh_alias}                    default

*** Keywords ***
Check If Directory Exists
    [Arguments]    ${dir_path}    ${ip}=${msm_ip}
    [Documentation]
    ...  This KW connects to SM via SSH and checks if given directory exists.
    ...  if exist return True else False
    ...  default ip = 192.168.255.1
    ...  *AUTHOR*
    ...  jakub.kokoszka@nokia.com

    Log    \nLog to ${ip} and check if directory ${dir_path} exist   console=${True}
    Setup SMOD Connection    ${ip}
    ${exists}    ssh.File Exists    ${dir_path}
    ssh.Disconnect
    [Return]  ${exists}


Download Directory
    [Arguments]    ${dir_path}    ${destination_place}  ${ip}=${msm_ip}
    [Documentation]
    ...  Download directory from MSM
    ...  example of simple use:  ssh_utils.Download Directory  /ffs/run/logs  /home/ute/Downloads
    ...  default ip = 192.168.255.1

    ${if_exist}  Check If Directory Exists  ${dir_path}
    Run Keyword If    '${if_exist}'=='True'    Log  Directory will be downloaded to local disk  console=${True}
    ...    ELSE    Fail    ${dir_path} directory does not exist.
    Run    mkdir ${destination_place}/downloaded
    Setup SMOD Connection    ${ip}
    ssh.Execute        tar -zcvf ${dir_path}/${tar_gz_file_name_from_MSM} ${dir_path}
    ssh.Download File  ${dir_path}/${tar_gz_file_name_from_MSM}    ${destination_place}/downloaded/${tar_gz_file_name_from_MSM}
    ssh.Execute        rm -f ${dir_path}/${tar_gz_file_name_from_MSM}
    unpacking.Unpack Archive Content To Directory  ${destination_place}/downloaded/${tar_gz_file_name_from_MSM}  ${destination_place}/downloaded
    Run    mv ${destination_place}/downloaded/${dir_path} ${destination_place}
    Run    rm -r ${destination_place}/downloaded
    ssh.Disconnect


Download Directory From Esm Via Vm
    [Arguments]       ${ESM_VM_ip}  ${dir_path_on_ESM}    ${dir_path_on_MSM_VM}
    [Documentation]
    ...  This KW connects to ESM via second VM and copy file do directory on MSM.

    ${VM_MSM_PASSWORD}  ${VM_ESM_PASSWORD}  Get VM passwords
    Log  Connection to ESM is performed from ESM_VM  console=${True}
    Run    mkdir ${dir_path_on_MSM_VM}/downloaded
    ssh.Connect To     hostname=${ESM_VM_ip}    username=ute    password=${VM_ESM_PASSWORD}   alias=slave_vm
    ssh.Connect To     hostname=${esm_ip}    username=${user_name}    password=${password}    proxy=slave_vm
    ssh.Execute        tar -zcvf ${dir_path_on_ESM}/${tar_gz_file_name_from_ESM} ${dir_path_on_ESM}
    Log  ssh.Download File  console=${True}
    ssh.Download File  ${dir_path_on_ESM}/${tar_gz_file_name_from_ESM}    ${dir_path_on_MSM_VM}/downloaded/${tar_gz_file_name_from_ESM}
    ssh.Execute        rm -f ${dir_path_on_ESM}/${tar_gz_file_name_from_ESM}
    unpacking.Unpack Archive Content To Directory  ${dir_path_on_MSM_VM}/downloaded/${tar_gz_file_name_from_ESM}  ${dir_path_on_MSM_VM}/downloaded
    Run    mv ${dir_path_on_MSM_VM}/downloaded/${dir_path_on_ESM} ${dir_path_on_MSM_VM}
    Run    rm -r ${dir_path_on_MSM_VM}/downloaded
    ssh.Disconnect  alias=slave_vm
    ssh.Disconnect


Get VM passwords
   [Documentation]
   ...  This KW gets and return current passwords for MSM VM and ESM VM.

   ${VM_MSM_PASSWORD}=  Run  sudo cat /etc/ute/vncpasswd
   ${VM_MSM_connection}=  ssh.Connect_To  hostname=${PC_IP1}  username=${VM_username}  password=${VM_MSM_PASSWORD}
   Set Test Variable    ${VM_MSM_connection}
   ${is_it_dualcore}=  Run Keyword And Return Status  Variable Should Exist  ${SMOD2}
   Run Keyword If    ${is_it_dualcore}    Get ESM VM Password
   ...  ELSE    Set Test Variable  ${VM_ESM_PASSWORD}  ${None}
   ssh.Disconnect  ${VM_MSM_connection}
   [Return]  ${VM_MSM_PASSWORD}    ${VM_ESM_PASSWORD}


Get ESM VM Password
    [Documentation]
    ...  This KW gets and sets the current password for ESM VM.

    ${VM_ESM_connection}    ssh.Connect_To  hostname=${PC_IP2}  username=${VM_username}  proxy=${VM_MSM_connection}
    ${VM_ESM_PASSWORD}      ssh.Execute  command=sudo cat /etc/ute/vncpasswd  connection=${VM_ESM_connection}
    Set Test Variable       ${VM_ESM_PASSWORD}
    ssh.Disconnect          ${VM_ESM_connection}


Get External VM Password
    [Documentation]
    ...  This KW gets the current VM password of given ${target_ip}.
    [Arguments]    ${target_ip}

    ${VM_MSM_password}=  Run  sudo cat /etc/ute/vncpasswd
    ${VM_MSM_connection}=  ssh.Connect_To  hostname=${PC_IP1}  username=${VM_username}  password=${VM_MSM_password}
    ${External_VM_connection}  ssh.Connect_To  hostname=${target_ip}  username=${VM_username}  proxy=${VM_MSM_connection}
    ${External_VM_password}  ssh.Execute  command=sudo cat /etc/ute/vncpasswd  connection=${External_VM_connection}
    ssh.Disconnect  ${VM_MSM_connection}
    ssh.Disconnect  ${External_VM_connection}
    [Return]  ${External_VM_password}


List Remote Directory
    [Arguments]    ${dir_path}
    [Documentation]
    ...  List remote dir MSM
    ...  example of simple use:  ssh_utils.List Remote Directory  /ffs/run/logs

    Setup SMOD Connection
    ${file_list}  ssh.Execute    ls ${dir_path}
    ssh.Disconnect
    [Return]    ${file_list}


Perform Dsp Crash
    [Arguments]    ${dsp}  ${ip}=${msm_ip}
    [Documentation]
    ...  KW connects to SM via SSH and perform DSP crash using rioboot command
    ...  example of simple use:
    ...  ${dsp}    Set Variable    0x1231
    ...  ${tst_ip}    Set Variable    192.168.255.129
    ...  ${log}    ssh_utils.Perform Dsp Crash    ${dsp}    ${tst_ip}

    Setup SMOD Connection    ${ip}
    Log  Start DSP crash procedure on ${dsp}  console=${True}
    ${dsp_cmd}  Set Variable  rioboot -c read -a 0x11800000 -n 0x1000000 ${dsp}
    ssh.Execute   ${dsp_cmd}
    Log   DSP crashed  console=${True}
    ssh.Disconnect


Run Command
    [Arguments]    ${cmd}
    [Documentation]
    ...  Run command on remote
    ...  Keyword Run Command, connect via ssh and execute command.
    ...  Before Run Command keyword you have to use Set Connection Parameters keywords,
    ...  to set up ssh connection parameters.
    ...  example of simple use:
    ...  ssh_utils.Run Command    ls /ffs/run/logs/reset_info

    ${cmd_return}    ssh.Execute    ${cmd}
    ssh.Disconnect
    [Return]    ${cmd_return}


Set Connection Parameters
    [Arguments]    ${ip_address}  ${user_name}  ${password}
    [Documentation]
    ...  Set connection parameters for keyword Run Command

    ssh.Connect To    hostname=${ip_address}    username=${user_name}    password=${password}


Setup SMOD Connection
    [Arguments]    ${ip}=${msm_ip}
    [Documentation]
    ...  Setup connection with master system module, if msm_ip == 192.168.255.1

    ssh.Connect To    hostname=${ip}    username=${user_name}    password=${password}

Get VM Ip
    ${VM_ip}  Run  hostname -i
    [Return]    ${VM_ip}

SSH Connection
    ssh.Connect To    hostname=${host_ip}   username=${user_name}    password=${password}   alias=${ssh_alias}