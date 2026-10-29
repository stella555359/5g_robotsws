*** Settings ***

Library    OperatingSystem
Library    Process
Library    String
Library    DateTime
Library    taf.transport.ssh   WITH NAME   csn
Library    Collections



*** Variables ***

${vm_ute_4G_addr}      ${tl.test_pcs[0].default_ssh_connection_details.addr}
${vm_ute_5G_addr}      ${tl.test_pcs[1].default_ssh_connection_details.addr}
${vm_username}    ute
${vm_password}    uteUTE!
${max_val_partition}    60
${tar_file}            UTE5G.tar


${command1}        cd /home/ute ; /usr/bin/rm -fr /tmp/${tar_file} 2>/dev/null ; /usr/bin/tar cvf /tmp/${tar_file} test_repo
${command2}        cd /home/ute ; /usr/bin/rm -fr test_repo test_repository 2>/dev/null
${command3}        cd /home/ute ; /usr/bin/mkdir -p /home/ute/MN/UTE/robotws ; /usr/bin/ln -s /home/ute/MN/UTE/robotws test_repository
${command4}        cd /home/ute ; /usr/bin/tar xf /tmp/${tar_file}
${command5}        cd /home/ute ; /usr/bin/mkdir test_results ; /usr/bin/rm -fr /tmp/*
${command6}        cd /home/ute ; /home/ute/.pyenv/shims/pip install -U pip ; /home/ute/.pyenv/shims/pip install ute_syslog
${command7}        cd /home/ute ; /home/ute/.pyenv/shims/pip list | grep ute_syslog


${LOG_PATH}=           ${OUTPUT_DIR}




*** Keywords ***

Check Disk space on 4G VM
    [Arguments]   ${host}=${vm_ute_4G_addr}   ${username}=${vm_username}   ${password}=${vm_password}
    csn.Connect To   ${host}   ${username}   ${password}   alias=disk_space
    ${disk_info1}   csn.Execute   ls -al /tmp   connection=disk_space
    ${disk_info2}   csn.Execute   ls -al /home/ute   connection=disk_space 
    ${space_info}   csn.Execute  df /tmp | grep /dev | awk '{ print $5} ' | cut -d % -f 1     connection=disk_space
    ${result} =     Convert To Integer    ${space_info}
    BuiltIn.Run Keyword if     ${result} > ${max_val_partition}    BuiltIn.Fail    / VM 4G /tmp partition is full . just clean it
    ${space_info}   csn.Execute  df /home | grep /dev | awk '{ print $5} ' | cut -d % -f 1     connection=disk_space
    ${result} =     Convert To Integer    ${space_info}
    BuiltIn.Run Keyword if     ${result} > ${max_val_partition}    BuiltIn.Fail    / VM 4G /home partition is full . just clean it
    csn.Disconnect   connection=disk_space


Check Disk space on 5G VM
    ${cr} =     Run  ls -al /tmp
    ${cr} =     Run  ls -al /home/ute
    ${space_info} =     Run  df /tmp | grep /dev | awk '{ print $5} ' | cut -d % -f 1
    ${result} =     Convert To Integer    ${space_info}
    BuiltIn.Run Keyword if     ${result} > ${max_val_partition}    BuiltIn.Fail    / VM 5G /tmp partition is full . just clean it
    ${space_info} =     Run  df /home | grep /dev | awk '{ print $5} ' | cut -d % -f 1
    ${result} =     Convert To Integer    ${space_info}
    BuiltIn.Run Keyword if     ${result} > ${max_val_partition}    BuiltIn.Fail    / VM 5G /home partition is full . just clean it



Copy_tar_file_to_VM_UTE_4G
    [Arguments]   ${host}=${vm_ute_4G_addr}   ${username}=${vm_username}   ${password}=${vm_password}
    csn.Connect To   ${host}   ${username}   ${password}      alias=vm_ute_4G
    ${cr} =    Execute    command=rm -fr /tmp/${tar_file} 2>/dev/null       connection=vm_ute_4G
    csn.Upload File      /tmp/${tar_file}     /tmp/${tar_file}            connection=vm_ute_4G
#    csn.Disconnect   connection=vm_ute_4G
    ${cr} =     Run  rm /tmp/${tar_file} 2>/dev/null

Tar_VM_UTE_5G
    ${cr} =    Run     ${command1}
    ${cr} =    Run     ls -alg /tmp/${tar_file}


Install_VM_UTE_4G
    [Arguments]   ${host}=${vm_ute_4G_addr}   ${username}=${vm_username}   ${password}=${vm_password}
#    csn.Connect To   ${host}   ${username}   ${password}      alias=vm_ute_4G
    ${cr} =    Execute    command=${command2}    connection=vm_ute_4G
    ${cr} =    Execute    command=${command3}    connection=vm_ute_4G
    ${cr} =    Execute    command=${command4}    connection=vm_ute_4G
    ${cr} =    Execute    command=${command5}    connection=vm_ute_4G
    ${cr} =    Execute    command=${command6}    connection=vm_ute_4G
    ${cr} =    Execute    command=${command7}    connection=vm_ute_4G
    ${cr} =    Execute    command=ls -alg /home/ute/test*    connection=vm_ute_4G
    csn.Disconnect   connection=vm_ute_4G
    
