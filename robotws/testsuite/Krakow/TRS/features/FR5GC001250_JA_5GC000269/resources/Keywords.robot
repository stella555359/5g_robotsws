*** Settings ***
Documentation
...  author: Wojciech Bak
...  contact: wojciech.bak@nokia.com
...
...  CC&S shall provide an API for the processes to lower privileges of user using process.

Library     taf.transport.ssh  WITH NAME     ssh
Library     testsuite/Krakow/TRS/features/FR5GC001250_JA_5GC000269/resources/remove_robot.py
Library     testsuite/Krakow/TRS/features/FR5GC001250_JA_5GC000269/resources/check_permission_to_etc_subset.py
Library     testsuite/Krakow/TRS/features/FR5GC001250_JA_5GC000269/resources/check_permissions_to_private_keys.py
Library     testsuite/Krakow/TRS/features/FR5GC001250_JA_5GC000269/resources/check_processes.py
Library     testsuite/Krakow/TRS/features/FR5GC001250_JA_5GC000269/resources/check_SUID_SGID.py
Library     testsuite/Krakow/TRS/features/FR5GC001250_JA_5GC000269/resources/world_writable.py

Resource    testsuite/Krakow/TRS/features/FR5GC001250_JA_5GC000269/resources/mzoam_common_resources/connections.robot

*** Variables ***
${644}=    -rw-r--r--
${600}=    -rw-------
${000}=    ----------
${exeptions_temporary_account}=  $1!="root" && $1!="robot" && $1!="toor4nsn" && $1!="sync" && $1!="halt" && $1!="shutdown" && $1!="operator"
${filter_DU}=  ($1=="tape" || $1=="floopy" || $1=="lp" || $1=="digital" || $1=="audio" || $1=="video" || $1=="cdrom" || $1=="game" || $1=="Lighttpd")
${filter_CU}=  ($1=="tape" || $1=="floopy" || $1=="digital" || $1=="audio" || $1=="video" || $1=="cdrom" || $1=="game" || $1=="Lighttpd")

*** Keywords ***
Find BTSSW Process on BB1
    ${process}=          ssh.execute  command=ps -aux | awk '($1=="btssw") {print}'  connection=BB1
    should contain       ${process}   start

check_path_enviroment_variable
    [Arguments]     ${connection}
    ssh.send_command
    ...  sudo su -c 'echo $PATH'
    ...  connection=${connection}
    ${result}=    ssh.read_output   connection=${connection}
    Should Not Contain    ${result}    .

check_path_enviroment_variable_BB1
    ssh.send_command
    ...  sudo su -c 'echo $PATH'
    ...  connection=BB1
    ${result}=    ssh.read_output   connection=BB1
    Should Not Contain    ${result}    .

Check terminating external interfaces on
    [Arguments]  ${VM}
    check interface and continue on failure   ntpd    ${VM}
    check interface and continue on failure    rpcbind    ${VM}
    check interface and continue on failure    mcproxy    ${VM}

Check interface and continue on failure
    [Arguments]  ${INTERFACE}   ${VM}
    ${result_perm}=    ssh.execute   command=ps -aux | awk '$1=="root" && $11~"${INTERFACE}" {print $1" "$11}'     connection=${VM}
    run keyword and continue on failure     should be empty    ${result_perm}

Find User on BB1
    ${btssw_user}=    ssh.execute  command=cat /etc/passwd | awk -F ":" '($1=="btssw") {print $1}'  connection=BB1
    should not be empty    ${btssw_user}

find_orphaned_files
    [Arguments]  ${connection}
    ssh.send_command
    ...  sudo su -c 'ls -la $(find / -xdev \\( -nouser -o -nogroup \\) -print)' | awk ('$1!~"d" || $1!~"total") && $9!\="none" {print}'
    ...  connection=${connection}
    ${result_perm}=    ssh.read_output   connection=${connection}
    ${result_perm}=    remove lines with robot  ${result_perm}
    should be empty    ${result_perm}

find_orphaned_files_BB1
    ssh.send_command
    ...  ls -la $(find / -xdev \\( -nouser -o -nogroup \\) -print)' | awk 'NR>\=4 {print} |grep -v -e robot -e none
    ...  connection=BB1
    ${result_perm}=    ssh.read_output   connection=BB1
    should be empty    ${result_perm}

Check file permissions
    [Arguments]     ${VM}
    Check perms to etc subset and continue on failure   subset=passwd   perm=${644}     connection=${VM}
    Check perms to etc subset and continue on failure   subset=group   perm=${644}     connection=${VM}
    Check perms to etc subset and continue on failure   subset=shadow   perm=${000}     connection=${VM}
    Check perms to etc subset and continue on failure   subset=fstab   perm=${644}     connection=${VM}
    Check perms to etc subset and continue on failure   subset=inittab   perm=${644}     connection=${VM}
    Check perms to etc subset and continue on failure   subset=hosts   grep_perm="other::" | cut -c 9     connection=${VM}
    Check perms to etc subset and continue on failure   subset=issue   grep_perm="other::" | cut -c 9     connection=${VM}
    Check perms to etc subset and continue on failure   subset=services   grep_perm="other::" | cut -c 9     connection=${VM}

Check file permissions BB1
    Check perms to etc subset and continue on failure   subset=passwd   perm=${644}     connection=BB1
    Check perms to etc subset and continue on failure   subset=group   perm=${644}     connection=BB1
    Check perms to etc subset and continue on failure   subset=shadow   perm=${600}     connection=BB1
    Check perms to etc subset and continue on failure   subset=fstab   perm=${644}     connection=BB1
    Check perms to etc subset and continue on failure   subset=hosts   grep_perm="other::" | cut -c 9     connection=BB1
    Check perms to etc subset and continue on failure   subset=issue   grep_perm="other::" | cut -c 9     connection=BB1
    Check perms to etc subset and continue on failure   subset=services   grep_perm="other::" | cut -c 9     connection=BB1

Check perms to etc subset and continue on failure
     [Arguments]    ${subset}   ${connection}   ${perm}=${EMPTY}   ${grep_perm}=${EMPTY}
     run keyword and continue on failure
     ...     check_permission_to_etc_subset  subset=${subset}     perm=${perm}   grep_perm=${grep_perm}     connection=${connection}

Check all processes on
    [Arguments]  ${VM}
    Check process and continue on failure  dhcpd    ${VM}
    Check process and continue on failure  ntpd    ${VM}
    Check process and continue on failure  ospfd   ${VM}
    Check process and continue on failure  zebrad  ${VM}

Check all processes on BB1
    Check process and continue on failure  ntpd     BB1
    Check process and continue on failure  ospfd    BB1
    Check process and continue on failure  zebrad   BB1

Check process and continue on failure
    [Arguments]     ${PROCESS}     ${VM}
    ${result_perm}=    ssh.execute   command=ps -aux | awk '($1=="root") && ($11~"${PROCESS}") {print $11}'   connection=${VM}
    run keyword and continue on failure    should be empty    ${result_perm}

Check files A on
    [Arguments]  ${VM}
    ${result_perm}=    ssh.execute
    ...  command=sudo su -c 'ls -la $(find / -xdev -type f -user 0 -perm /002 -print) | grep -e [-d][-r][-w][-x][-r][-w][-x][-r]w[-x]'
    ...  connection=${VM}
    run keyword and continue on failure     should be empty    ${result_perm}


Check files B on
    [Arguments]  ${VM}
    ${result_perm}=    ssh.execute
    ...  command=sudo su -c 'ls -la $(find / -xdev -type f -user 0 ! -group 0 -perm /020 -print) | grep -e [-d][-r][-w][-x][-r][-w][-x][-r]w[-x]'
    ...  connection=${VM}
    run keyword and continue on failure     should be empty    ${result_perm}

Check files A on BB1
    ${result_perm}=    ssh.execute
    ...  command=ls -la $(find / -xdev -type f -user 0 -perm /002 -print) | grep -e [-d][-r][-w][-x][-r][-w][-x][-r]w[-x]
    ...  connection=BB1
    run keyword and continue on failure     should be empty    ${result_perm}


Check files B on BB1
    ${result_perm}=    ssh.execute
    ...  command=ls -la $(find / -xdev -type f -user 0 ! -group 0 -perm /020 -print) | grep -e [-d][-r][-w][-x][-r][-w][-x][-r]w[-x]
    ...  connection=BB1
    run keyword and continue on failure     should be empty    ${result_perm}

Check Temporary accounts on
    [Arguments]  ${VM}
    ${result_perm}=    ssh.execute
    ...  command=awk 'BEGIN { FS=":" } $4==0 {print $1}' /etc/passwd | awk '${exeptions_temporary_account}'
    ...  connection=${VM}
    should be empty    ${result_perm}

Check unused on
    [Arguments]  ${VM}
    ${result_perm}=    ssh.execute  command=sudo su -c 'cat /etc/passwd' | awk 'BEGIN { FS=":" } ${filter_CU}'
    ...   connection=${VM}
    should be empty    ${result_perm}

Check unused on BB1
    ${result_perm}=    ssh.execute  command=cat /etc/passwd | awk 'BEGIN { FS=":" } ${filter_DU}'
    ...   connection=BB1
    should be empty    ${result_perm}

Check dir on
    [Arguments]  ${VM}
    ${result_perm}=  ssh.execute  command=sudo su -c 'getfacl $(find / -xdev -type d \\( -perm -0002 -a ! -perm -1000 \\)) 2> none'  connection=${VM}
    should be empty    ${result_perm}

Check dir on BB1
    ${result_perm}=  ssh.execute  command=getfacl $(find / -xdev -type d \\( -perm -0002 -a ! -perm -1000 \\)) 2> none   connection=BB1
    should be empty    ${result_perm}
