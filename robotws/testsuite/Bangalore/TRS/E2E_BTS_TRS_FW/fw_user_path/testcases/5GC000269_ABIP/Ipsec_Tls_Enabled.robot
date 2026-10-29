*** Settings ***
Documentation
...     [Maintenance]        "TRS ET Bangalore Team"
...     [Procedure]          "The test case is planned to validate Unauthorised Files"
...     [Funtion_Hash_Tags]  "Linux_Hardening_on_RAU_and_RAC"
...     [QC_Path]            "QC_ID in Test Lab for reporting"
...     [QC_ID]              "QC_ID in Test Lab for reporting"
...     [Feature_ID]         "5GC000269"
...     [Requirement ID]     "WBTS_SEC_53398, WBTS_SEC_53359, WBTS_SEC_50295, WBTS_SEC_ 51175"
...     [Validated_TestLine] "2211"
...     [Config]             "IPv4 configuration."
...	    [Runtime param]	     "bts_id 2690 is provided at run time."
...     [SCF File]           "5GC000269_with_ipsec_enabled.xml"

Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
Resource        ${CURDIR}/../resources/common_keywords.robot

Suite Setup     Run Keywords        Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions
...     AND     Teardown Oamops

*** Test Cases ***

[1][1.0] TRS_5GC000269_TRS_SEC_MFPM_With_Multiple_TRS_Feature_Enabled

    Perform Commissioning       scf_file=${IPsec_enabled_commissioning}    verify_bts_status=False     timeout=400      alias=default
    Sleep     600
    Execute Commands on enb
    Perform Recommissioning     type=param   rat=5g     param_path=${ipsec_enable_moc}  operation=update    value=false     timeout=300
    ...     alias=default

[1][1.0] TRS_5GC000269_TRS_SEC_MFPM_With_Multiple_TRS_Feature_Enabled_1

    Perform Recommissioning     type=param   rat=5g    param_path=${tls_enable_moc}  operation=update    value=forced     timeout=300
    ...     alias=default
    Execute Commands on enb
    Perform Recommissioning     type=param   rat=5g    param_path=${tls_enable_moc}  operation=update    value=off     timeout=300     alias=default

*** keywords ***

Execute Commands on enb
    Execute Commands for orphan files
    Execute Command for unauthorised directories

Execute Commands for orphan files
    Setup Remote Access    remote_device=bts     alias=default
    ${stdout_0}       Remote Command Execute      command=${orphaned_files_Command}
    Sleep       60
    ${stdout_1}       Remote Command Execute      command=sort username.txt | uniq
    Should not Be Empty     ${stdout_1}
    Set Suite Variable      ${username}         ${stdout_1}
	${stdout_2}       Remote Command Execute      command=cat /etc/passwd
    Should not Be Empty     ${stdout_2}
    Set Suite Variable      ${password_file}            ${stdout_2}
    Check if username is present in file         ${password_file}       ${username}

    Execute command on ENodeB       ${orphaned_files_Command_1}
    ${stdout_3}       Remote Command Execute      command=sort group.txt | uniq
    Should not Be Empty     ${stdout_3}
    Set Suite Variable      ${group}         ${stdout_3}
    ${stdout_4}       Remote Command Execute      command=cat /etc/group
    Should not Be Empty     ${stdout_4}
    Set Suite Variable      ${group_file}           ${stdout_4}
    Check if username is present in file         ${group_file}      ${group}
    Teardown Remote Access      alias=default

Check if username is present in file
   [Arguments]         ${file}      ${user_group}
   @{list}=    Split To Lines    ${user_group}
   FOR    ${ELEMENT}    IN    @{list}
          ${is_str}=       Evaluate     isinstance($ELEMENT, str)
          Run Keyword If          '${is_str}'=='False'         Match names      ${file}        (?i)${ELEMENT}
   END

Match names
    [Arguments]         ${exp_name}      ${act_name}
    Should Match Regexp      ${exp_name}        (?i)${act_name}

Execute Command for unauthorised directories
    Setup Remote Access    remote_device=bts     alias=default
    ${stdout_5}       Remote Command Execute      command=find / /ffs/fs{1,2} /nvrd -xdev -type d -perm /002
    Should not Be Empty     ${stdout_5}
    Teardown Remote Access      alias=default
    @{list}=    Split To Lines    ${stdout_5}
    Set Suite Variable      ${stdout_5}
    ${Exception_file}=      OperatingSystem.Get File        ${unauthorised_exception_file}      encoding_errors=ignore
    Set Suite Variable      ${Exception_file}
    FOR    ${each_file}    IN    @{list}
           Check if the execeptions are present in unauthorised directories           ${each_file}
    END

Check if the execeptions are present in unauthorised directories
    [Arguments]     ${exception}
    ${result}=      Run keyword and return status       Should Contain     ${Exception_file}        ${exception}