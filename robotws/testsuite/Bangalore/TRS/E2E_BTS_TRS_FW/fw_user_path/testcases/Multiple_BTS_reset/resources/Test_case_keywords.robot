***Settings ***
Documentation
...     [Procedure]             "The test case performs BTS software upgrade and 25 times BTS Reset"
...     [Date]                  "26-10-2022"
...     [Author]                "Punith"
...     [Feature_ID]            ""
...     [Maintenance]           "TRS I & V Tools Bangalore Team"
...     [Funtion_Hash_Tags]     "E2LINK_RIC"
...     [Validated_TestLine]    "ASIA"
...     [Precondition]          "BTS should be operational and configured state"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 "QC_ID in Test Lab for reporting"

*** Keywords ***
Create fault id List
	[Arguments]		${list}
	${length}=	Get Length	${list}
	${list1}=	Create List
	FOR	${i}	IN RANGE	${length}
		Append To List	${list1}	${list[${i}]['faultId']}
	END
	[return]	${list1}

Fault list after reset
	[Arguments]		${pre_alarm_faultids}	${post_alarm_faultids}
	${list}=	Create List
	FOR	${i}	IN		@{post_alarm_faultids}
		Run Keyword If	${i} in ${pre_alarm_faultids}	Continue For Loop
		Append To List	${list}	${i}
	END
	[return]	${list}

Delete File Addons
	SSHLibrary.Open Connection		10.45.141.111	    port=22
	SSHLibrary.Login	ute	TR5vrf@dm1nI0g1n
	Run	cd /home/ute/robotlte/testsuite/WMP/E2E_BTS_TRS_FW/fw_user_path/testcases/EDA_jira
	${prompt}=	OperatingSystem.List Directory	${CURDIR}
	FOR	${i}	IN	@{prompt}
		Run Keyword If	'disconnect' in '${i}'	Run	rm -r ${i}
	END
	#${prompt}=	Read Until Prompt	$
	#${value}=	Should Match Regexp	${prompt}	disconnect.\\*

Read Syslog
	#${file}=	OperatingSystem.Get File 	${CURDIR}//background_syslog.txt
	#@{list}=	Split to lines		${file}
	#FOR	${line}    IN    @{list}
		#Log	${line}
		#${value}=	Get Variable Value	${line}
		#Log	${value}
	#END
	${result}=	Run Process	python	onair_time.py
	log	${result.stdout}
	[return]	${result.stdout}

Suite Teardown1
	Stop Syslog
	Sleep	10s
	${onair_interval}=	Read Syslog
	Pass Execution If	${onair_interval}<380	Normal BTS reset time