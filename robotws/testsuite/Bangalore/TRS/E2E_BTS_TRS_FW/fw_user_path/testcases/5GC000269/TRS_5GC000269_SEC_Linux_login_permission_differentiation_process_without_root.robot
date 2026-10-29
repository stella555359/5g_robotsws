***Settings***
Documentation	[Maintenance]        "TRS ET Bangalore Team"
...     	[Procedure]          "The test case is planned to validate Linux File Permissions"
...     	[Funtion_Hash_Tags]  "Linux_Hardening_on_RAU_and_RAC"
...     	[QC_Path]            "QC_ID in Test Lab for reporting"
...     	[QC_ID]              "QC_ID in Test Lab for reporting"
...     	[Feature_ID]         "5GC000269"
...     	[Requirement ID]     "WBTS_SEC_51946, WBTS_SEC_49140, WBTS_SEC_52641, WBTS_SEC_52642, WBTS_SEC_53359"
...     	[Validated_TestLine] "2690"
...     	[Config]             "IPv4 configuration."
...	    	[Runtime param]	     "bts_id 2690 is provided at run time."


Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
Resource        ${CURDIR}/../resources/common_keywords.robot

Suite Setup     Run Keywords    Suite Setup Preconditions
...             AND     Setup Oamops
Suite Teardown  Run Keywords    Suite Teardown Postconditions
...             AND     Teardown Oamops

***Test cases***
[2][1.0] TRS_5GC000269_SEC_Linux login permission differentiation_Encrypted file system_CryptoAgent
    Check file and process permissions
    Sleep   600
    Check encrypted file system for crypto agent

***Keywords***
Check the shadow file Permission
#/etc/shadow shall be owned by user root with group root and the file permissions shall be set to 600
    Execute command on gNB   ls -lrt /etc/shadow
    Should Match Regexp     '${stdout}'     (?im)\\-rw\\-\\-\\-\\-\\-.*shadow

Check the file Permission
#$file shall be owned by user root with group root and the file permissions shall be set to 644
    FOR    ${file}    IN    @{files_list}
        Execute command on gNB    ls -lrt ${file}
        Should Match Regexp     '${stdout}'     (?im)\\-rw\\-r\\-\\-r\\-\\-.*${file}
    END

Check the nologin permission
    FOR    ${account}    IN    @{account_list}
        Execute command on gNB    cat /etc/passwd | grep ${account}
        Should contain     '${stdout}'     /sbin/nologin
    END

Check temporary accounts to have non zero GID
    Execute command on gNB    ps -elf|egrep -v 'root|GID'|cut -d ' ' -f 3 | uniq
    Should not Be Empty     ${stdout}
    @{user_list} =    Split String      ${stdout}
    Execute command on gNB  cat /etc/passwd | uniq
	Should not Be Empty     ${stdout}
    FOR    ${user}    IN    @{user_list}
        ${username}=    Run    echo ${user} | cut -c 1-7
        Should not Contain     ${stdout}       ${username}:x:0:0:
    END

Check no dot is present in PATH
    Execute command on gNB   echo $PATH
    Should not Be Empty     ${stdout}
    Should not Contain  ${stdout}   ${dot}

Check file and process permissions
    check process    ps -elf | grep btssw | grep -v grep | cut -d ' ' -f 7

check process
    [Arguments]    ${cmd}
    Execute command on gNB    ${cmd}
    Should not Be Empty     ${stdout}
    @{process_list} =    Split String      ${stdout}
    FOR    ${process}    IN    @{process_list}
        Execute command on gNB    ls -l /proc/${process}/fd | grep -v null | grep / | cut -d ' ' -f 11
        @{files_list} =    Split To Lines      ${stdout}
        check files    @{files_list}
    END

check files
    [Arguments]    @{files_list}
    FOR    ${file}    IN    @{files_list}
        Execute command on gNB    ls -la ${file} | cut -d ' ' -f 3
        ${status}       Should Not Contain    ${stdout}      No such file or directory
        Run Keyword If    '${stdout}'=='True'    Should Be Equal    '${stdout}'   'btssw'
    END

Check process running as non root
    FOR    ${process}    IN    @{process_name_list}
        Execute command on gNB    ps -elf|egrep ${process}|egrep -v 'bash|grep'|cut -d ' ' -f 3
        Should Be Equal    '${stdout}'   'btssw'
        Execute command on gNB     id -g ${stdout}
        Should Be Equal    ${stdout}  800
        Execute command on gNB    ps -elf|egrep ${process}|egrep -v 'bash|grep'|cut -d ' ' -f 3
        Execute command on gNB     id -u ${stdout}
        Should Be Equal    ${stdout}  800
    END

Check encrypted file system for crypto agent
	check process_crypto    df -T /ffs/run/trs_data/active/keystorage/ | grep -v Filesystem |cut -d ' ' -f 1
	check process_crypto    df -T /ffs/run/trs_data/active/keystorage/cmpdb/ | grep -v Filesystem |cut -d ' ' -f 1
	check process_crypto    df -T /ffs/run/trs_data/active/keystorage/certs/ | grep -v Filesystem |cut -d ' ' -f 1

check process_crypto
    [Arguments]    ${cmd}
    Execute command on gNB    ${cmd}
    Should not Be Empty     ${stdout}
    @{user_list} =    Split String      ${stdout}
    FOR    ${user}    IN    @{user_list}
        Should Be Equal    '${user}'   'encfs'
    END
