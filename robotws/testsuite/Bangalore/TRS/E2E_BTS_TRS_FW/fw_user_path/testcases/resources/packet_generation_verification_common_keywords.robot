***Settings ***
Documentation	This is a common keyword repository for packet generation and verification

*** Keywords ***
Send Packets to BTS
	[Documentation]		This keyword generates traffic at speed received in argument (default value=100), based on the type and code given.
	...                 Profile name is mandatory
	[Arguments]    ${profile}		${type}=0		${code}=0		${speed}=100	${alias}=default
	Set Suite Variable		${type}		${type}
	Set Suite Variable		${code}		${code}
	Set Suite Variable		${speed}	${speed}

	${packet_speed}		${time} = 		Traffic Start 		profile=${profile}		alias=${alias}
	${packets}=		Evaluate	${packet_speed} * ${time}
	Set Suite Variable		${packets}		${packets}
	Set Suite Variable		${packet_speed}		${packet_speed}
	Set Suite Variable		${time}		${time}
	Return From Keyword		${packets}	${time}

Verify Rate Limit From Admin For One Counter
	[Documentation]		This keyword verifies rate limit based on value of argument ${packets_sent},${total_time} received from Send Packet KW and
	...      ${rate_limit_to_verify} value. Verification is done for counters value received from Admin counter list ${rate_limit_counters_list}
	...      with single counter value.
	[Arguments]    ${rate_limit_counters_list}		${packets_sent}		${total_time}		${rate_limit_to_verify}

	Log 	${rate_limit_counters_list}
	${counters_list}=		Get Dictionary Values	${rate_limit_counters_list}

	FOR    ${counter}    IN    @{counters_list}
		${counter_param_dict}=		Get Dictionary Values	${counter}
		${rate_limit_counters_increased}=	Final Calculations For One Counter From Admin	${counter_param_dict}
	END

	${counters_increased} = 	Evaluate	${packets_sent} - ${rate_limit_counters_increased}
	${rate_limiting_speed} = 	Evaluate	${counters_increased} / ${total_time}

	${packets_tolerance}=		Evaluate		${rate_limit_to_verify} * 0.1
	${packets_min}=		Evaluate		${rate_limit_to_verify} - ${packets_tolerance}
	${packets_max}=		Evaluate		${rate_limit_to_verify} + ${packets_tolerance}

	Should be True		${packets_min} < ${rate_limiting_speed} < ${packets_max}
	...        msg=Rate Limiting not within 10% of expected ${rate_limit_to_verify}

Final Calculations For One Counter From Admin
	[Documentation]		This keyword is used along with KW "Verify Rate Limit From Admin For One Counter" to get final counter
	...       value from dictonary returned by Admin API.
	[Arguments]		${counter_param_dict}
	FOR    ${items}    IN    @{counter_param_dict}
		${counters_increased_in_admin}=			Get From Dictionary  ${items}  final_counter_value
	END
	Return From Keyword		${counters_increased_in_admin}

Verify Packet Filtering Value From Admin For One Counter
	[Documentation]		This keyword verifies packet filtering based on value of argument ${packets_sent},${total_time} received from
	...            Send Packet KW.
	...		Verification is done for counters value received from Admin counter list ${rate_limit_counters_list} with single counter value.
	[Arguments]    ${packet_filter_counters_list}		${packets_sent}		${total_time}

	Log  ${packet_filter_counters_list}
	${counters_list}=      Get Dictionary Values   ${packet_filter_counters_list}

	FOR    ${counter}    IN    @{counters_list}
	    ${counter_param_dict}=    Get Dictionary Values   ${counter}
	    ${packet_filter_counters_value}=	Final Calculations For One Counter From Admin    ${counter_param_dict}
	END

	${packets_tolerance}=      Evaluate    ${packets_sent} * 0.1
	${packets_min}=        Evaluate        ${packets_sent} - ${packets_tolerance}
	${packets_max}=        Evaluate        ${packets_sent} + ${packets_tolerance}

	Should be True      ${packets_min} < ${packet_filter_counters_value} < ${packets_max}          msg=Packet filtering count did not match
