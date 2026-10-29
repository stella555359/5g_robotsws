*** Settings ***

Documentation
...            [Author]         "Vinay"
...            [Maintenance]    "TRS I & V Tools Bangalore Team"

variables         ta_e2e_bts_trs_fw
Resource          taf/rfrl/trs_e2e_fw/setup/framework.robot
Library           Collections
Library		  SSHLibrary
Library		  OperatingSystem
Library		  String
Resource          ${CURDIR}/../resources/common_keywords.robot
Resource      taf/rfrl/trs_e2e_fw/setup/framework.robot
#Resource	/home/ute/robotlte/testsuite/WMP/E2E_BTS_TRS_FW/fw_path/setup/framework.robot


Suite Setup      Run Keywords    Suite Setup Preconditions
...             AND             Setup Oamops

Suite Teardown     Run Keywords         Suite Teardown Postconditions
...             AND             Teardown Oamops


*** Test Cases ***
[1]ASIB_Multiple site reset iteration & startup time monitoring
	FOR	${j}	IN RANGE	${reset_try}
		${pre_execution_alarms}	   Get Current Alarm List
		Reset	  operation=reset_bts	 should_be_onair=True
		BuiltIn.sleep	500
		Verify Bts Status
		${post_execution_alarms}=	Get Current Alarm List
		${alarms_post_execution}=	Fault list after reset	   ${pre_execution_alarms}	${post_execution_alarms}
		Should Be Empty     ${alarms_post_execution}
	END



*** Keywords ***
Create fault id List
	[Arguments]		${list}
	${length}=	Get Length	${list}
	${list1}=	Create List
	FOR	${i}	IN RANGE	${length}
		${fault_id}	Convert to String	${list[${i}]['faultId']}
		Append To List	   ${list1}	${fault_id}
	END
	[return]	${list1}

Fault list after reset
	[Arguments]		${pre_alarm_faultids}	${post_alarm_faultids}
	${list}=	Create List
	FOR	${i}	IN		@{post_alarm_faultids}
		${status}     Run Keyword And Return Status    List Should Contain Value	${pre_alarm_faultids}	   ${i}
		Run Keyword If	   ${status}	Continue For Loop
		Append To List	${list}	${i}
	END
	[return]	${list}


Get Current Alarm List
	${alarms}=	Verify Alarm	alarm_type=active
	${alarm_faultids_list}=	Create List
	${alarm_faultids_list}=	Create fault id List	${alarms}
	[return]	${alarm_faultids_list}



