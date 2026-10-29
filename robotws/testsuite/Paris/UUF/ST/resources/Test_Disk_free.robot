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
${max_val_partition}    70

*** Keywords ***
Check Disk space on 4G VM
    [Arguments]   ${host}=${vm_ute_4G_addr}   ${username}=${vm_username}   ${password}=${vm_password}
    csn.Connect To   ${host}   ${username}   ${password}   alias=disk_space
    ${disk_info1}   csn.Execute   ls -al /tmp   connection=disk_space
    ${disk_info2}   csn.Execute   ls -al /home/ute   connection=disk_space 
    ${space_info}   csn.Execute  df /tmp | grep /dev | awk '{ print $5} ' | cut -d % -f 1     connection=disk_space
    csn.Disconnect   connection=disk_space
    ${result} =     Convert To Integer    ${space_info}
    BuiltIn.Run Keyword if     ${result} > ${max_val_partition}    BuiltIn.Fail    / VM 4G partition is full . just clean it


Check Disk space on 5G VM
    ${cr} =     Run  ls -al /tmp
    ${cr} =     Run  ls -al /home/ute
    ${space_info} =     Run  df /tmp | grep /dev | awk '{ print $5} ' | cut -d % -f 1
    ${result} =     Convert To Integer    ${space_info}
    BuiltIn.Run Keyword if     ${result} > ${max_val_partition}    BuiltIn.Fail    / VM 5G partition is full . just clean it
