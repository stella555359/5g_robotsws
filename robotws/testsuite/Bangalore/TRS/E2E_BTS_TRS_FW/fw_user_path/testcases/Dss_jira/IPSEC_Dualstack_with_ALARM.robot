*** Settings ***
Documentation     [Procedure] ""
...               [Date] "Date of creation "
...               [Author] "Vaishnavi"
...               [QC_Path] "QC_Path in Test Plan"
...               [QC_ID] "QC_ID in Test Lab for reporting"
...               [Feature_ID] ""
...               [Function_Hash_Tags] ""
...               [Validation_status] Validated and Passed
...               [Validated_TestLine] 2020
...               [Validation Date]


variables         ta_e2e_bts_trs_fw
Resource          ${CURDIR}/../resources/common_keywords.robot
Library           Collections


Suite Setup        Run Keywords    Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown    Run Keywords    Suite Teardown Postconditions
...     AND     Teardown Oamops

***Test Cases***
[1][1.0] EN_DS_Keep_Alive_Procedure_Time out
    Perform Commissioning   scf_file=${config_without_ipsec_withoutDSSEnable}  verify_bts_status=True  timeout=600  alias=default
    Perform Recommissioning     type=param     param_path=${ipsec_enable}:ipSecEnabled     operation=update        value=true   timeout=600
    Perform Recommissioning     type=param     param_path=${dss_enable}:actLteNrDss     operation=update        value=true
     BuiltIn.sleep   120
    ${CRM_status1}    Get Parameter   param_path=${crm_path}:crmStatus
    log     ${CRM_status1}
    Should Contain      ${CRM_status1}      running


***Keywords***
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

Get Current Alarm List
	${alarms}=	Verify Alarm	alarm_type=active
	${alarm_faultids_list}=	Create List
	${alarm_faultids_list}=	Create fault id List	${alarms}
	[return]	${alarm_faultids_list}

