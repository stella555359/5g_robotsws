*** Settings ***
Documentation    Test cases that are created as B2B Security Stream

Resource    ../../../common_resources/connections/connections.robot
Resource    ../../../common_resources/admin/admin.robot
Library             taf.sbts.oam.coam.admin    WITH NAME    coam_admin

*** Keywords ***
NESAS-SR_Private_Key_Storage_and_Certificate_Structure_Check
    Log    Step 1: Connecting to BTS and see if keys are stored    console=True
    ${ssh_conn}       Connect to BTS
    ${private}        ssh.execute    command=ls /etc/keys.d/private    connection=${ssh_conn}    timeout=10s
    ${public}         ssh.execute    command=ls /etc/keys.d/board      connection=${ssh_conn}    timeout=10s
    Should Contain    ${private}    tpmboardkeypriv.pem
    Should Contain    ${public}    pubkey.pem
    Log    Step 2: Restoring vendor certificates and check if vendor certs is proper    console=True
    ${bts_conn}       Connect to ADMIN
    coam_admin.Restore Vendor Certificate    connection=${bts_conn}
    Sleep    60s    reason=Wait until all certificates will be cleared from BTS
    ${cert}=          ssh.execute    command=openssl x509 -text -in /etc/keys.d/bcerts/mcert.pem    connection=${ssh_conn}    timeout=10s
    Should Contain    ${cert}    Issuer: O = Nokia
    Should Contain    ${cert}    CN = Factory Certification Authority
    Should Contain    ${cert}    sha256WithRSAEncryption
    Log    Step 3: Checking if on SMOD all certificates has proper format    console=True
    ${all_certs}      ssh.execute    command=find / -name *.pem | grep cert     connection=${ssh_conn}    timeout=10s
    ${lines}=         Split String    ${all_certs}    \n
    FOR    ${line}    IN    @{lines}[:-1]
        ${line}          Convert To String    ${line}
        ${line}          Replace String    ${line}    \r    ${EMPTY}
        ${line}          Replace String    ${line}    $    ${EMPTY}
        ${output}     ssh.execute    command=openssl x509 -text -in ${line}    connection=${ssh_conn}    timeout=10s
        ${status}     Run Keyword And Return Status    Should Contain    ${output}    -----BEGIN CERTIFICATE-----
        Run Keyword If    not ${status}
        ...               Should Contain Any    ${output}    Unable to load certificate    x509: Use -help for summary
    END
    [Teardown]    Run Keywords
    ...           Run Keyword And Ignore Error    Disconnect from BTS    ${ssh_conn}
    ...           AND    Run Keyword And Ignore Error    Disconnect from ADMIN    ${bts_conn}

NESAS-SR_Protecting_Data_and_Information_Storage
    Log    Step 1: Connecting to BTS as toor4nsn    console=True
    ${ssh_conn}       Connect to BTS
    ${shadow}         ssh.execute     command=cat /etc/shadow     connection=${ssh_conn}    timeout=10s
    ${shadow}         Split String    ${shadow}    \n
    Log    Step 2: Checking if all users in /etc/shadow has no visible password    console=True
    FOR    ${i}    IN    @{shadow}[:-1]
        ${password}   Split String    ${i}    :
        ${result}     Run Keyword And Return Status    Should Contain Any    ${password}    *    x    !    !*
        Run Keyword If     not ${result}    Should Not Contain    ${password}    oZPS0POrRieRtu
        Run Keyword If     not ${result}    Should Not Contain    ${password}    Pl(FzaYj5~c5;q
    END
    Log    Step 3: Checking if toor4nsn has permission to see /etc/shadow file    console=true
    ${shadow}         ssh.execute     command=ls -l /etc/shadow     connection=${ssh_conn}    timeout=10s
    Should Contain         ${shadow}    ----------
    ${ssh_service}    Connect to BTS  username=serviceuser    password=Pl(FzaYj5~c5;q
    ${shadow}         ssh.execute     command=cat /etc/shadow     connection=${ssh_service}    timeout=10s
    Log    Step 4: Checking if serviceuser has permission to see /etc/shadow file    console=true
    Should Contain         ${shadow}  Permission denied
    Disconnect from BTS    ${ssh_service}
    ${ssh_conn}       Connect to BTS
    Log    Step 5: Adding new user and check if password for new user is stored in plan text    console=True
    ssh.execute       command=useradd agent007    connection=${ssh_conn}
    ssh.execute       command=echo -e "Qwerty!@#$\nQwerty!@#$\n" | passwd agent007    connection=${ssh_conn}
    ${output}         ssh.execute     command=cat /etc/shadow    connection=${ssh_conn}
    Should Not Contain     ${output}  Permission denied
    ${output}         ssh.execute     command=cat /ffs/run/etc/p_shadow    connection=${ssh_conn}
    Should Not Contain     ${output}  Qwerty!@#$
    ${output}         ssh.execute     command=cat /etc/security/opasswd    connection=${ssh_conn}
    Should Not Contain     ${output}  Qwerty!@#$
    ${output}         ssh.execute     command=cat /etc/passwd    connection=${ssh_conn}
    Should Not Contain     ${output}  Qwerty!@#$
    Disconnect from BTS    ${ssh_conn}
    Log    Step 6: Connecting to BTS as new user and see if user has no root permission    console=True
    ${ssh_user}       Connect to BTS  username=agent007    password=Qwerty!@#$
    ${output}         ssh.execute     command=cat /etc/shadow    connection=${ssh_user}
    Should Contain         ${output}  Permission denied
    Disconnect from BTS    ${ssh_user}
    ${ssh_conn}       Connect to BTS
    Log    Step 7: Connectin to BTS as toor4nsn and deleting the created user    console=True
    ssh.execute       command=userdel agent007    connection=${ssh_conn}
    ${output}         ssh.execute     command=cat /etc/shadow    connection=${ssh_conn}
    Should Not Contain    ${output}   Permission denied
    Run Keyword And Expect Error      *ConnectFailedError:*    Connect to BTS    username=agent007    password=Qwerty!@#$
    [Teardown]     Run Keywords
    ...            Disconnect from BTS    ${ssh_conn}
    ...            AND    Disconnect from BTS    ${ssh_service}
