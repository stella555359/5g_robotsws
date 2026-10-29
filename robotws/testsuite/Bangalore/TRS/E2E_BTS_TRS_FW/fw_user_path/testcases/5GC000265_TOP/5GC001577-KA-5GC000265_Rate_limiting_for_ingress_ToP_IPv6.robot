*** Settings ***
Documentation
	...		[Procedure]				"The test case is planned to validate firewall rate limit for Splane packet"
	...		[Date]					"10-12-21"
	...		[Author]				"Hrudya"
	...		[QC_Path]				"QC_Path in Test Plan"
	...		[QC_ID]					"QC_ID in Test Lab for reporting"
	...		[Funtion_Hash_Tags]		        "INGRESS RATE LIMITING"





Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
Library		ute_fsmaccess
Library		Collections
Library		String

Suite Setup        Setup Oamops
Suite Teardown     Teardown Oamops

*** Variables ***
${search_string}		Chain.*?policy.*?RATELIMIT_CHAIN
${splane_rate_limit}		512
${counter_analysis_file_name}	LTE4805_counters_analysis.json
${configurations}		ipv4,ipv6
${splane}       2a00:8a00:a000:11b0::3c7b
${topmaster}   2a00:8a00:a000:11b0::3c61

*** Test Cases ***

[1]5GC001577-KA-5GC000265_Rate_limiting_for_ingress_ToP_IPv6

 	PM Counters Start	analysis=verify_ingress_rate_limit_packet_drop_splane	     counter_analysis_file=${counter_analysis_file_name}
        ...	                        pm_interval=5
	Send Packets	type=splane_rate_limit_drop_ipv6
	${rate_limit_counters_list}= 		Verify PM Counters		analysis=verify_ingress_rate_limit_packet_drop_splane
        ...	     counter_analysis_file=${counter_analysis_file_name}     pm_interval=5
	Set Suite Variable		${rate_limit_counters_list}		${rate_limit_counters_list}
	Verify the Rate Limiting Speed

*** Keywords ***
Perform ipv6 configuration
    [Arguments]     ${Perform_IPV6_Configuration}
    Perform Full Commissioning     ${Perform_IPV6_Configuration}
    Sleep       300
    Run     sudo ifconfig eth3 inet6 add fc00::1/116





Send Packets
	[Arguments]		${type}
	Traffic Setup			device=device_2			alias=splane
	${packet_speed}		${time} = 		Traffic Start 		profile=${type}		 alias=splane
	Traffic Teardown	alias=splane

	${packets_sent}=		Evaluate	${packet_speed} * ${time}
	Set Suite Variable		${packets_sent}		${packets_sent}
	Set Suite Variable		${packet_speed}		${packet_speed}
	Set Suite Variable		${time}		${time}

Verify the Rate Limiting Speed
	Log 	${rate_limit_counters_list}
	${counters_list}=		Get Dictionary Values	${rate_limit_counters_list}

	FOR    ${counter}    IN    @{counters_list}
	    ${counter_param_dict}=		Get Dictionary Values	${counter}
	    Final Calculations	${counter_param_dict}
	END

	${counters_increased} = 	Evaluate	${packets_sent} - ${rate_limit_counters_increased}
	${rate_limiting_speed} = 	Evaluate	${counters_increased} / ${time}

	${packets_tolerance}=		Evaluate		${splane_rate_limit} * 0.2
	${packets_min}=		Evaluate		${splane_rate_limit} - ${packets_tolerance}
	${packets_max}=		Evaluate		${splane_rate_limit} + ${packets_tolerance}

	Should be True		${packets_min} < ${rate_limiting_speed} < ${packets_max}
        ...	      msg=Rate Limiting not within 10% of expected ${splane_rate_limit} packets/sec

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
