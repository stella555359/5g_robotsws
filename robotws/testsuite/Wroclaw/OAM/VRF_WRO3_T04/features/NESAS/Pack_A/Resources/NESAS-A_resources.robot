*** Settings ***
Documentation
...  author:   Klaudyna Piechocka
...  contact:  klaudyna.piechocka@nokia.com

Resource  ../../../../common_resources/admin/admin.robot
Resource  ../../../../common_resources/netact/netact_operations.robot
Resource   ../../../../common_resources/swconfig/swconfig.robot

Library    ./NESAS-A_resources.py
Library    ./NESAS_A_VerifyPasswords.py

*** Variables ***
${crypto_agent_pub}     /etc/cryptoagent/srkpub.pem
${crypto_agent_priv}    /etc/cryptoagent/srkpriv.p8

${sericeuser_password}    Pl(FzaYj5~c5;q
${wsuser_password}        A0zY~rP#8Mx@
${dcuser_password}        nE&e3Q*ptK8
${coam_password}          zO&n1W*ktp7
${developer_password}     $developer#

${toor4nsn_hash}          $6$ZuTtnMHn$4KLAf7LqouunwIMUd97jg3hC7dv0/D2pBrdlnchj4j7VutozJy/6KHJSLRievzXNVsWneV1man3izt9tEXXTg/
${serviceuser_hash}       $6$TULJ2v8D$sFSzI/QLy31GJzVI7kyaA8uB4JFT25qDBuDOyhWQlo.b0tKfHDLcTo/t08jXoq9NA58iJYsjdl7IXDIahQhBy.
${bigtom_hash}            $6$wM23w.q0$Bfvcmea8XXd7AJMIIISVdFkcQ5ML7lfp/sWpwIaIYVh5lBZGNNEP60/0DqeP8/IzTOEojS0PVf7/cn.OTBu0X0

${new_ssh_username}       testuser
${new_ssh_password}       Alpha987

${wsuser_new_password}    B0zY~rF#6Mx@
${local_path_script}      ${CURDIR}/Netact_passwd_read_SQLLite.py
${remote_path_script}     /user/toor4nsn/Netact_passwd_read_SQLLite.py

${public_vendor_key}                 /etc/keys.d/bcerts/mcert.pem
${vendor_basic_cert_local_path}      /home/ute/logs/mcert.pem

${swconfig_cert}                     /ffs/run/pkcs7_cert.pem
${swconfig_basic_cert_local_path}    /home/ute/logs/pkcs7_cert.pem

${cmp_bts_test}                     CN=Nokia_8154_default
${ca_subject_name}                  CN=CB007672
${WSUSER_PASS}                      A0zY~rP#8Mx@
${NEW_PASSWORD}                     Qwerty1234!


*** Keywords ***
Get Fronthaul IP address
    ${conn}     Connect to ADMIN
    ${x}        admin.Get Managed Objects    class_name=RMOD_L    connection=${conn}
    ${y}        Convert to string    ${x}
    @{match}    Get Regexp Matches    ${y}    ipAddress['"]?: ['"]?([0-9.]+)
    @{fhip_list}    Create List
    FOR    ${i}     IN    @{match}
        ${status}              Run Keyword And Return Status    Should Not Contain    ${i}    0.0.0.0
        IF  ${status}
            ${match_i}         Get Regexp Matches    ${i}    [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+
            Append To List     ${fhip_list}    ${match_i}[0]
            Exit For Loop
        END
    END
    [Return]      ${fhip_list}[0]
    [Teardown]    Disconnect from ADMIN    ${conn}

Verify if each default passwords is not stored in plain text on BTS in ${file_extension} files
    Verify if ${WEBEM_PASSWORD} password is not stored in plain text on BTS in ${file_extension} files
    Verify if ${SSH_PASSWORD} password is not stored in plain text on BTS in ${file_extension} files
    Verify if ${sericeuser_password} password is not stored in plain text on BTS in ${file_extension} files
    Verify if ${wsuser_password} password is not stored in plain text on BTS in ${file_extension} files
    Verify if ${dcuser_password} password is not stored in plain text on BTS in ${file_extension} files
    Verify if ${coam_password} password is not stored in plain text on BTS in ${file_extension} files
    Verify if ${developer_password} password is not stored in plain text on BTS in ${file_extension} files
    Verify if ${toor4nsn_hash} password is not stored in plain text on BTS in ${file_extension} files
    Verify if ${serviceuser_hash} password is not stored in plain text on BTS in ${file_extension} files
    Verify if ${bigtom_hash} password is not stored in plain text on BTS in ${file_extension} files

Verify if ${password} password is not stored in plain text on BTS in ${file_extension} files
    log to console  Verify if ${password} password is not stored in plain text on BTS in ${file_extension} files
    find_illegal_files_with_stored_password  ${password}  ${file_extension}
    verify_illegal_files

Verify if each default passwords is not stored in plain text in ${directory} directory
    Verify if ${WEBEM_PASSWORD} password is not stored in plain text in ${directory} directory
    Verify if ${SSH_PASSWORD} password is not stored in plain text in ${directory} directory
    Verify if ${sericeuser_password} password is not stored in plain text in ${directory} directory
    Verify if ${wsuser_password} password is not stored in plain text in ${directory} directory
    Verify if ${dcuser_password} password is not stored in plain text in ${directory} directory
    Verify if ${coam_password} password is not stored in plain text in ${directory} directory
    Verify if ${developer_password} password is not stored in plain text in ${directory} directory
    Verify if ${toor4nsn_hash} password is not stored in plain text in ${directory} directory
    Verify if ${serviceuser_hash} password is not stored in plain text in ${directory} directory
    Verify if ${bigtom_hash} password is not stored in plain text in ${directory} directory

Verify if ${password} password is not stored in plain text in ${directory} directory
    log to console  Verify if ${password} password is not stored in plain text in ${directory} directory
    ${output}=  find_illegal_files_with_stored_password  ${password}  directory=${directory}
    verify_illegal_files

Verify if each default passwords is not stored in plain text in binary ${binary_file} file
    run keyword and continue on failure  Verify if ${WEBEM_PASSWORD} password is not stored in plain text in binary ${binary_file} file
    run keyword and continue on failure  Verify if ${SSH_PASSWORD} password is not stored in plain text in binary ${binary_file} file
    run keyword and continue on failure  Verify if ${sericeuser_password} password is not stored in plain text in binary ${binary_file} file
    run keyword and continue on failure  Verify if ${wsuser_password} password is not stored in plain text in binary ${binary_file} file
    run keyword and continue on failure  Verify if ${dcuser_password} password is not stored in plain text in binary ${binary_file} file
    run keyword and continue on failure  Verify if ${coam_password} password is not stored in plain text in binary ${binary_file} file
    run keyword and continue on failure  Verify if ${developer_password} password is not stored in plain text in binary ${binary_file} file
    run keyword and continue on failure  Verify if ${toor4nsn_hash} password is not stored in plain text in binary ${binary_file} file
    run keyword and continue on failure  Verify if ${serviceuser_hash} password is not stored in plain text in binary ${binary_file} file
    run keyword and continue on failure  Verify if ${bigtom_hash} password is not stored in plain text in binary ${binary_file} file

Verify if ${password} password is not stored in plain text in binary ${binary_file} file
    log to console  Verify if ${password} password is not stored in plain text in binary ${binary_file} file
    find_illegal_password_strings_in_binary_files  ${password}  ${binary_file}
    verify_illegal_files

Verify if each default passwords is not stored in plain text in popular system files
    Verify if each default passwords is not stored in plain text in /etc/shadow system file
    ${exist}=    Check exist /ffs/run/etc/p_shadow system file
    Run Keyword if    '${exist}' == 'True'
    ...               Verify if each default passwords is not stored in plain text in /ffs/run/etc/p_shadow system file
    Verify if each default passwords is not stored in plain text in /etc/security/opasswd system file
    ${exist}=   Check exist /ffs/run/etc/security/opasswd system file
    Run Keyword if  '${exist}' == 'True'
    ...             Verify if each default passwords is not stored in plain text in /ffs/run/etc/security/opasswd system file
    Verify if each default passwords is not stored in plain text in /etc/passwd system file

Check exist ${file} system file
    ${output}=          ssh.execute  command=ls ${file}  connection=cOAM_toor4nsn    timeout=10s
    ${statement}=       check_file_exist    ${output}
    [Return]            ${statement}

Verify if each default passwords is not stored in plain text in ${popular_system_file} system file
    Verify if ${WEBEM_PASSWORD} password is not stored in plain text in ${popular_system_file} system file
    Verify if ${SSH_PASSWORD} password is not stored in plain text in ${popular_system_file} system file
    Verify if ${sericeuser_password} password is not stored in plain text in ${popular_system_file} system file
    Verify if ${wsuser_password} password is not stored in plain text in ${popular_system_file} system file
    Verify if ${dcuser_password} password is not stored in plain text in ${popular_system_file} system file
    Verify if ${coam_password} password is not stored in plain text in ${popular_system_file} system file
    Verify if ${developer_password} password is not stored in plain text in ${popular_system_file} system file

Verify if ${password} password is not stored in plain text in ${system_file} system file
    log to console  Verify if ${password} password is not stored in plain text in ${system_file} system file
    find_illegal_password_strings_in_binary_files  ${password}  ${system_file}
    verify_illegal_files

Change Password For Wsuser
    [Arguments]      ${old_password}    ${new_password}
    ${connection}=    Connect to ADMIN
    coam_admin.modify_web_service_user      username=wsuser
    ...                                     password=${new_password}
    ...                                     old_username=wsuser
    ...                                     old_password=${old_password}
    ...                                     connection=${connection}
    [Teardown]    Disconnect from ADMIN     ${connection}
