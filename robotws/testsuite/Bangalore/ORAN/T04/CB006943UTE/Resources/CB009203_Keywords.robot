*** Settings ***
Documentation   CB009203 Keywords for NESAS-SCAS evaluation of SRAN system
...
...  author:   Patryk Tatarek
...  contact:  patryk.tatarek@nokia.com

Library    ./testsuite/Bangalore/ORAN/T04/CB006943UTE/Resources/verify_passwords.py    WITH NAME    VerifyPasswords
Library    Keywords.py
Library    PLATFORM_function.py

Library     taf.ul.oam.selenium_megazone  WITH NAME  taf_selenium

*** Variables ***
${Nemuadmin_password}     nemuuser
${toor4nsn_password}      oZPS0POrRieRtu
${sericeuser_password}    Pl(FzaYj5~c5;q
${wsuser_password}        A0zY~rP#8Mx@
${dcuser_password}        nE&e3Q*ptK8
${coam_password}          zO&n1W*ktp7
${developer_password}     $developer#

${toor4nsn_hash}          $6$ZuTtnMHn$4KLAf7LqouunwIMUd97jg3hC7dv0/D2pBrdlnchj4j7VutozJy/6KHJSLRievzXNVsWneV1man3izt9tEXXTg/
${serviceuser_hash}       $6$TULJ2v8D$sFSzI/QLy31GJzVI7kyaA8uB4JFT25qDBuDOyhWQlo.b0tKfHDLcTo/t08jXoq9NA58iJYsjdl7IXDIahQhBy.
${bigtom_hash}            $6$wM23w.q0$Bfvcmea8XXd7AJMIIISVdFkcQ5ML7lfp/sWpwIaIYVh5lBZGNNEP60/0DqeP8/IzTOEojS0PVf7/cn.OTBu0X0

${wsuser_new_password}    B0zY~rF#6Mx@
${local_path_script}      ${CURDIR}/Netact_passwd_read_SQLLite.py
${remote_path_script}     /user/toor4nsn/Netact_passwd_read_SQLLite.py

${ca_subject_name}        CN=CB007672

${LMP_IP}                 192.168.255.129
${ROOT_USERNAME}          toor4nsn
${ROOT_PASSWORD}          oZPS0POrRieRtu

${MIN_NX_BIT_ARM_ARCH_VALUE}=   6
${SERVICEUSER_PASSWORD}=        Pl(FzaYj5~c5;q
${CONFIGURATION}=    1_2_CLOUD970

*** Keywords ***
Verify if each default passwords is not stored in plain text on BTS in file_extension
    [Documentation]  Check if passwords are not stored in plain text
    [Arguments]  ${file_extension}
    Verify if password is not stored in plain text on BTS in file_extension   ${Nemuadmin_password}  ${file_extension}
    Verify if password is not stored in plain text on BTS in file_extension   ${toor4nsn_password}  ${file_extension}
    Verify if password is not stored in plain text on BTS in file_extension   ${sericeuser_password}  ${file_extension}
    Verify if password is not stored in plain text on BTS in file_extension   ${wsuser_password}  ${file_extension}
    Verify if password is not stored in plain text on BTS in file_extension   ${dcuser_password}  ${file_extension}
    Verify if password is not stored in plain text on BTS in file_extension   ${coam_password}  ${file_extension}
    Verify if password is not stored in plain text on BTS in file_extension   ${developer_password}  ${file_extension}
    Verify if password is not stored in plain text on BTS in file_extension   ${toor4nsn_hash}  ${file_extension}
    Verify if password is not stored in plain text on BTS in file_extension   ${serviceuser_hash}  ${file_extension}
    Verify if password is not stored in plain text on BTS in file_extension   ${bigtom_hash}  ${file_extension}

Verify if password is not stored in plain text on BTS in file_extension
    [Documentation]  Check if passwords are not stored in plain text
    [Arguments]  ${password}  ${file_extension}
    log  Verify if ${password} password is not stored in plain text on BTS in ${file_extension} files  console=true
    VerifyPasswords.find_illegal_files_with_stored_password   ${password}  ${file_extension}
    VerifyPasswords.Verify Illegal Files

Verify if each default passwords is not stored in plain text in directory
    [Arguments]  ${directory}
    Verify if password is not stored in plain text in directory  ${Nemuadmin_password}  ${directory}
    Verify if password is not stored in plain text in directory  ${toor4nsn_password}  ${directory}
    Verify if password is not stored in plain text in directory  ${sericeuser_password}  ${directory}
    Verify if password is not stored in plain text in directory  ${wsuser_password}  ${directory}
    Verify if password is not stored in plain text in directory  ${dcuser_password}  ${directory}
    Verify if password is not stored in plain text in directory  ${coam_password}  ${directory}
    Verify if password is not stored in plain text in directory  ${developer_password}  ${directory}
    Verify if password is not stored in plain text in directory  ${toor4nsn_hash}  ${directory}
    Verify if password is not stored in plain text in directory  ${serviceuser_hash}  ${directory}
    Verify if password is not stored in plain text in directory  ${bigtom_hash}  ${directory}

Verify if password is not stored in plain text in directory
    [Arguments]  ${password}  ${directory}
    log  Verify if ${password} password is not stored in plain text in ${directory} directory  console=true
    VerifyPasswords.find_illegal_files_with_stored_password  ${password}  directory=${directory}
    VerifyPasswords.Verify Illegal Files

Verify if each default passwords is not stored in plain text in binary file
    [Arguments]  ${binary_file}
    run keyword and continue on failure  Verify if password is not stored in plain text in binary file  ${Nemuadmin_password}  ${binary_file}
    run keyword and continue on failure  Verify if password is not stored in plain text in binary file  ${toor4nsn_password}  ${binary_file}
    run keyword and continue on failure  Verify if password is not stored in plain text in binary file  ${sericeuser_password}  ${binary_file}
    run keyword and continue on failure  Verify if password is not stored in plain text in binary file  ${wsuser_password}  ${binary_file}
    run keyword and continue on failure  Verify if password is not stored in plain text in binary file  ${dcuser_password}  ${binary_file}
    run keyword and continue on failure  Verify if password is not stored in plain text in binary file  ${coam_password}  ${binary_file}
    run keyword and continue on failure  Verify if password is not stored in plain text in binary file  ${developer_password}  ${binary_file}
    run keyword and continue on failure  Verify if password is not stored in plain text in binary file  ${toor4nsn_hash}  ${binary_file}
    run keyword and continue on failure  Verify if password is not stored in plain text in binary file  ${serviceuser_hash}  ${binary_file}
    run keyword and continue on failure  Verify if password is not stored in plain text in binary file  ${bigtom_hash}  ${binary_file}

Verify if password is not stored in plain text in binary file
    [Documentation]  Check if passwords are not stored in plain text in binary file
    [Arguments]  ${password}  ${binary_file}
    log  Verify if ${password} password is not stored in plain text in binary ${binary_file} file  console=true
    VerifyPasswords.find_illegal_password_strings_in_binary_files  ${password}  ${binary_file}
    VerifyPasswords.Verify Illegal Words

Verify if each default passwords is not stored in plain text in popular system files
    [Documentation]  Check if passwords are not stored in plain text in system file(shadow,opasswd,p_shadow)
    Verify if each default passwords is not stored in plain text in system file  /etc/shadow
    ${exist}=    Check exist system file  /ffs/run/etc/p_shadow
    Run Keyword if    '${exist}' == 'True'
    ...               Verify if each default passwords is not stored in plain text in system file  /ffs/run/etc/p_shadow
    Verify if each default passwords is not stored in plain text in system file  /etc/security/opasswd
    ${exist}=   Check exist system file  /ffs/run/etc/security/opasswd
    Run Keyword if  '${exist}' == 'True'
    ...             Verify if each default passwords is not stored in plain text in system file  /ffs/run/etc/security/opasswd
    Verify if each default passwords is not stored in plain text in system file  /etc/passwd

Check exist system file
    [Arguments]  ${file}
    ${output}=          ssh.execute  command=ls ${file}  connection=cOAM_toor4nsn    timeout=10s
    ${statement}=       check_if_file_exist    ${output}
    [Return]            ${statement}

Verify if each default passwords is not stored in plain text in system file
    [Documentation]  Verifies clear text passwords in system locations
    [Arguments]  ${popular_system_file}
    Verify if password is not stored in plain text in system file  ${Nemuadmin_password}  ${popular_system_file}
    Verify if password is not stored in plain text in system file  ${toor4nsn_password}  ${popular_system_file}
    Verify if password is not stored in plain text in system file  ${sericeuser_password}  ${popular_system_file}
    Verify if password is not stored in plain text in system file  ${wsuser_password}  ${popular_system_file}
    Verify if password is not stored in plain text in system file  ${dcuser_password}  ${popular_system_file}
    Verify if password is not stored in plain text in system file  ${coam_password}  ${popular_system_file}
    Verify if password is not stored in plain text in system file  ${developer_password}  ${popular_system_file}

Verify if password is not stored in plain text in system file
    [Arguments]  ${password}  ${system_file}
    log  Verify if ${password} password is not stored in plain text in ${system_file} system file  console=true
    VerifyPasswords.find_illegal_password_strings_in_binary_files  ${password}  ${system_file}
    VerifyPasswords.Verify Illegal Words

Check files permission rules
    [Arguments]    ${connection}
    @{files}=      Create List    passwd  group  shadow  fstab  inittab  hosts  issue  services
    FOR  ${file}  IN  @{files}
       Run Keyword and Continue on Failure    check_file_permission_rules    ${file}    ${connection}
    END

Check all processes on BTS
    [Arguments]    ${connection}
    Check process and continue on failure    httpd     ${connection}
    Check process and continue on failure    ntpd      ${connection}
    Check process and continue on failure    ospfd     ${connection}
    Check process and continue on failure    zebrad    ${connection}

Check process and continue on failure
    [Documentation]  Check if the given process is running for the root user
    [Arguments]    ${PROCESS}    ${connection}
    ${result_perm}=    ssh.execute    command=ps -aux | awk '($1=="root") && ($11~"${PROCESS}") {print $11}'
    ...                               connection=${connection}
    Run Keyword and Continue on Failure    Should be Empty    ${result_perm}

Check non executable protection
    [Arguments]    ${cpuinfo}    ${min_arm_cpu_architecture}    ${module}
    ${is_intel_processor}=    Evaluate    "Intel Atom" in """${cpuinfo}"""
    Run Keyword If    ${is_intel_processor}    Check non executable protection for intel    ${module}
    Run Keyword Unless   ${is_intel_processor}   Check non executable protection for arm   ${cpuinfo}    ${min_arm_cpu_architecture}

Check non executable protection for intel
    [Arguments]    ${module}
    ${ssh_conn}=     Connect to BTS
    ${cmd}=          Set Variable    ${module} dmesg | grep "Execute Disable"
    Log    Check Intel NX protection is active: ${cmd}   console=yes
    ${output}=       ssh.execute   ${cmd}   connection=${ssh_conn}
    Should Contain     ${output}   NX (Execute Disable) protection: active   ignore_case=True
    [Teardown]       Disconnect from BTS    ${ssh_conn}

Check non executable protection for arm
    [Arguments]    ${cpuinfo}     ${min_arm_cpu_architecture}
    ${cpus_architecture}=     Get Regexp Matches     ${cpuinfo}   CPU architecture: (.*)\r    1
    Log    Check ARM CPU architecture values: ${cpus_architecture}    console=yes
    Should Not Be Empty    ${cpus_architecture}   msg=Should not be empty, cpuinfo output: ${cpuinfo}
    FOR  ${cpu_architecture}  IN  @{cpus_architecture}
    \   ${condition}=     Evaluate    ${cpu_architecture} >= ${min_arm_cpu_architecture}
    \   Should Be True    ${condition}
