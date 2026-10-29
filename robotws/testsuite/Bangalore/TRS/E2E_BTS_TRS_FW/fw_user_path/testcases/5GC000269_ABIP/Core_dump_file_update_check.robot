*** Settings ***
Documentation
...     [Maintenance]        "TRS ET Bangalore Team"
...     [Procedure]          "The test case is planned to validate Core Dump files"
...     [Funtion_Hash_Tags]  "Linux_Hardening_on_RAU_and_RAC"
...     [QC_Path]            "QC_ID in Test Lab for reporting"
...     [QC_ID]              "QC_ID in Test Lab for reporting"
...     [Feature_ID]         "5GC000269"
...     [Requirement ID]     "WBTS_SEC_51946"
...     [Validated_TestLine] "2211"
...     [Config]             "IPv4 configuration."
...	    [Runtime param]	     "bts_id 2690 is provided at run time."

Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
Resource        ${CURDIR}/../resources/common_keywords.robot

Suite Setup     Run Keywords        Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions
...     AND     Teardown Oamops

**** Test Cases ***

[1]TRS_5GC000269_SEC_Linux_login_permission_differentiation_Core_dump_file_generation_updates

	Initial configuration
	Kill the non-root process for the core dump file to be generated

*** Keywords ***

Initial configuration
	Check for the flag
	set ulimit to unlimited
	Randomly Select the process to be killed

Check for the flag
	Execute command on ENodeB    ${grep_cmd}
	Log To Console        ${stdout}
	${status}=		Run Keyword and return status		Should Be Equal       ${stdout}			${core_dump_flag}
	Log To Console		${status}
	Run Keyword If        '${status}'!='True'		Execute command on ENodeB     ${add_core_dump_flag}

set ulimit to unlimited
	Execute command on ENodeB       echo "ulimit -c unlimited" >> .bashrc
	Reset Bts       verify_bts=True      should_be_onair=False
	Sleep    180
    Execute command on ENodeB       cat .bashrc
	Should Contain        ${stdout}		ulimit -c unlimited

Randomly Select the process to be killed
	Execute command on ENodeB 			${process_cmd}
    Should not Be Empty     ${stdout}
	${ps_name}=		Create List
	@{output}=		Split to Lines       ${stdout}
	FOR    ${index}    IN    @{output}
			${value}=		Split String       ${index}
			Append To List      ${ps_name}		${value}[7]
    END
	${ps_name}=         Evaluate       random.sample(${ps_name},3)  random
	Set Suite Variable     ${ps_name}		${ps_name}

Kill the non-root process for the core dump file to be generated
	FOR    ${index}    IN RANGE	0	3
		Execute command on ENodeB			ps -eaf|grep ${ps_name}[${index}]|grep -v root
		Should Not Be Empty			${stdout}
		${id}=		Split String       ${stdout}
		${ps_id}=		Set Variable      ${id}[1]
		Execute command on ENodeB		ps -p ${ps_id}|grep -v PID
		Should Not Be Empty			${stdout}
		${output}  ${name_of_ps}=    Split String From Right      ${stdout}   max_split=1
		check any core file exists
		Kill process and check core dump file gets generated	${ps_id}
		Sleep     180
   	 END

check any core file exists
	Execute command on ENodeB 			${core_path}
    Should not Be Empty     ${stdout}
	@{output}=    Split String     ${stdout}
	${file_path}=   Get From List       ${output}     -4
	Should not Be Empty			${file_path}
	Execute command on ENodeB			ls ${file_path}
	${status}=			Run Keyword and return status      Should Be Empty			${stdout}
	Run Keyword if			'${status}'!='True'		Execute command on ENodeB		cd ${file_path};rm -rf *
	Execute command on ENodeB			ls ${file_path}
	Should Be Empty			${stdout}

Kill process and check core dump file gets generated
	[Arguments]		${ps_id}
	Execute command on ENodeB			kill -11 ${ps_id}
	Should Be Empty       ${stderr}
#Timer increased from 180 to 300 due to timeout issue
    Sleep     500
    Execute command on ENodeB         ${core_path}
    Should not Be Empty         ${stdout}
    @{output}=    Split String     ${stdout}
    ${file_path}=   Get From List       ${output}     -4
    Execute command on ENodeB           ls ${file_path}/node_0x1011/