*** Settings ***
Documentation
	...		[Procedure]				"The test case is planned to validate firewall rate limit for Splane packet"
	...		[Date]					"10-07-19"
	...		[Author]				"Swetha S"
	...		[QC_Path]				"QC_Path in Test Plan"
	...		[QC_ID]					"QC_ID in Test Lab for reporting"
	...		[Funtion_Hash_Tags]		"FIREWALL"


variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
Resource        ${CURDIR}/../resources/admin_oam_common_keywords.robot

Suite Setup     Run Keywords    Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown  Run Keywords    Suite Teardown Postconditions
...     AND     Teardown Oamops

*** Variables ***
${search_string}		chain*.*RATELIMIT_CHAIN
${splane_rate_limit}		512
${counter_analysis_file_name}	LTE4805_counters_analysis.json
${configurations}		ipv4

*** Test Cases ***
[1][1.0] TRS_LTE4805_Verification_of_IP Filtering PM counter for Splane traffic type of Ingress Rate Limiter
    Install Scapy
    Run Keyword And Ignore Error  Perform Commissioning       scf_file=${asoe_scf}   verify_bts_status=False
	...     timeout=600
	PM Counters Start		analysis=verify_ingress_rate_limit_packet_drop_splane
	...		counter_analysis_file=${counter_analysis_file_name}
	Send Packets	type=splane_rate_limit_drop
	${rate_limit_counters_list}= 		Verify PM Counters		analysis=verify_ingress_rate_limit_packet_drop_splane
	...		counter_analysis_file=${counter_analysis_file_name}
	Set Suite Variable		${rate_limit_counters_list}		${rate_limit_counters_list}
	Verify the Rate Limiting Speed
*** Keywords ***
Perform ipv6 configuration
    [Arguments]     ${Perform_IPV6_Configuration}
    Perform Full Commissioning     ${Perform_IPV6_Configuration}
    Sleep       300
    Run     sudo ifconfig eth3 inet6 add fc00::1/116
Read IP Parameters
	${splane} = 	Get Parameter		param_path=TOP-1:sPlaneIpAddressDN:localIpAddr
	Set Suite Variable		${splane}		${splane}
	${topmaster}=	Get Parameter		param_path=TOPF-1:topMasterList:masterIpAddr
	Set Suite Variable		${topmaster}		${topmaster}
Install Scapy
    Run     pip install scapy
Send Packets
    [Arguments]     ${type}
    Traffic Setup           device=device_1         alias=splane
    ${packet_speed}     ${time} =       Traffic Start       profile=${type}      alias=splane
    Traffic Teardown    alias=splane
    ${packets_sent}=        Evaluate    ${packet_speed} * ${time}
    Set Suite Variable      ${packets_sent}     ${packets_sent}
    Set Suite Variable      ${packet_speed}     ${packet_speed}
    Set Suite Variable      ${time}     ${time}
Verify the Rate Limiting Speed
	Log 	${rate_limit_counters_list}<F12>
	${counters_list}=		Get Dictionary Values	${rate_limit_counters_list}
	FOR    ${counter}    IN    @{counters_list}
		${counter_param_dict}=		Get Dictionary Values	${counter}
		Final Calculations	${counter_param_dict}
    END
	${counters_increased} = 	Evaluate	${packets_sent} - ${rate_limit_counters_increased}
	${rate_limiting_speed} = 	Evaluate	${counters_increased} / ${time}
    ${packets_tolerance}=		Evaluate		${splane_rate_limit} * 0.1
	${packets_min}=		Evaluate		${splane_rate_limit} - ${packets_tolerance}
	${packets_max}=		Evaluate		${splane_rate_limit} + ${packets_tolerance}
Final Calculations
	[Arguments]		${counter_param_dict}
	@{counter_check}=    Create List
	FOR    ${items}    IN    @{counter_param_dict}
		${rate_limit_counters_increased}=	Get From Dictionary  ${items}  final_counter_value
		Set Suite Variable	${rate_limit_counters_increased} 	${rate_limit_counters_increased}
		Append To List      ${counter_check}    ${rate_limit_counters_increased}
    END
Check Counters match
	[Arguments]		${counter_check}
	${val1}=        Get From List       ${counter_check}        0
	${val2}=        Get From List       ${counter_check}        1
	Should Be Equal As Integers		${val1}		${val2}
Final Calculations for no drop
	[Arguments]		${counter_param_dict}
	FOR    ${items}    IN    @{counter_param_dict}
		${rate_limit_counters_increased}=			Get From Dictionary  ${items}  final_counter_value
		Set Suite Variable		${rate_limit_counters_increased}		${rate_limit_counters_increased}
		Append To List      ${counter_check}    ${rate_limit_counters_increased}
    END
Verify Rate Limit for no drop
	Log     ${rate_limit_counters_list}
    ${counters_list}=       Get Dictionary Values   ${rate_limit_counters_list}
    FOR    ${counter}    IN    @{counters_list}
       ${counter_param_dict}=      Get Dictionary Values   ${counter}
       Final Calculations for no drop ${counter_param_dict}
    END

Check Counters match for drop
	[Arguments]		${counter_check}
	${val_counter_1}=        Get From List       ${counter_check}        0
	${val_counter_2}=        Get From List       ${counter_check}        1
	${packets_tolerance}=       Evaluate        ${val_counter_1} * 0.1
    ${packets_min}=     Evaluate        ${val_counter_1} - ${packets_tolerance}
    ${packets_max}=     Evaluate        ${val_counter_1} + ${packets_tolerance}
	Should be True      ${packets_min} < ${val_counter_2} < ${packets_max}