*** Settings ***
Documentation     [Procedure] ""
...               [Date] "25 Aug 2023"
...               [Author] "Vinay"
...               [QC_Path] "QC_Path in Test Plan"
...               [QC_ID] "QC_ID in Test Lab for reporting"
...               [Feature_ID] ""
...               [Function_Hash_Tags] ""
...               [Validation_status] Validated and Passed
...               [Validated_TestLine] 3611
...               [Validation Date]

variables         ta_e2e_bts_trs_fw
Resource      taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource          ${CURDIR}/../resources/common_keywords.robot
Resource          ${CURDIR}/../resources/Common_IPSEC_Operations.robot
Resource	  ${CURDIR}/resources/common_ipsec_setup_keywords.robot
Library           Collections

Suite Setup        Run Keywords    Suite Setup Preconditions
...        AND     Setup Oamops
Suite Teardown      Run Keywords    Suite Teardown Postconditions
...        AND     Teardown Oamops

***Test Cases***
[1][1.0] SMTRS-30670 check for different anti-reply window sizes as part of TMO profile execution accross all Hardwares along with traffic
	${window_size_list}	Create List	SIZE_1024	SIZE_512	SIZE_256	SIZE_128	SIZE_64
	FOR	${i}	IN	@{window_size_list}
		${pre_execution_alarms}=	Get Current Alarm List
		${antiReplayWindow_value}    Get Parameter   param_path=MRBTS-${bts_id}/TNLSVC-1/TNL-1/IPAPP-1/IPSECC-1/IPSECP-1:antiReplayWindowSize
		Perform Recommissioning     type=param    param_path=MRBTS-${bts_id}/TNLSVC-1/TNL-1/IPAPP-1/IPSECC-1/IPSECP-1:antiReplayWindowSize
        ...	operation=update     value=${i}     timeout=300
		BuiltIn.Sleep	600
		Verify Ipsec Tunnels Status
		Make 5g Call
		PM Counters Start       analysis=verify_vol_counters      counter_analysis_file=${vol_counter}
		Verify Pm Counters      analysis=verify_vol_counters     counter_analysis_file=${vol_counter}
		BuiltIn.Sleep	100
		${post_execution_alarms}=	Get Current Alarm List
		${alarms_post_execution}=	Fault list after reset	${pre_execution_alarms}	${post_execution_alarms}
		Should Be Empty    ${alarms_post_execution}
	END