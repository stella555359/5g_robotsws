*** Settings ***

Documentation
     ...    [Procedure] "TRS_CB009901_NG-C_Setup_With_AMF_Address_Configured_As_FQDN_With_TTL_Timer"
     ...    [Date] "02-01-2025"
     ...    [Author] "Meghana J"
     ...    [QC_Path] "QC_Path in Test Plan"
     ...    [QC_ID] "QC_ID in Test Lab for reporting"
     ...    [Funtion_Hash_Tags] "AMF FQDN"
     ...    [Feature_ID] "CB009901"
     ...    [Validation_status] "Validated"
     ...    [Validated_TestLine] "ASIM"
     ...    [Commissioning_comment] "This script requires 5G and AMF FQDN Configuration"

Resource        ${CURDIR}/../resources/common_keywords.robot

Suite Setup                     Pre-conditions for testsuite
Suite Teardown                   Post-conditions for testteardown

*** Test Cases ***
[1]TRS_CB009901_NG-C_Setup_With_AMF_Address_Configured_As_FQDN_With_TTL_Timer

	Perform AMF FQDN Commissioning
	Verify AMF FQDN IP Address Resolved for IPv4 and IPv6
	Traffic Capture for Default TTL timer
	Process Tshark Output
	Update TTL Timer value
	Traffic Capture for Different TTL timer
	Process Tshark Output

*** Keywords ***
Perform AMF FQDN Commissioning
	Perform Commissioning		scf_file=${AMF_FQDN_TTL}	verify_bts_status=False     timeout=1200
	Sleep	150
	Call Setup		nr=airphone_sa:data      parallel=${False}    verify_attach=${False}   attach=${False}    ipv4_or_6=ipv6       timeout=300
	Verify Bts Status       req_rat=nr      should_be_onair=${True}        timeout=90        alias=default

Verify AMF FQDN IP Address Resolved for IPv4 and IPv6
	${amfIPAddressResolved}=     Get Parameter     param_path=SERVEDAMF-1:amfIPAddressResolved
	Should Be Equal     ${amfIPAddressResolved}       ${amfIPAddress_ipv4}
	${amfIPAddressResolved}=     Get Parameter     param_path=SERVEDAMF-2:amfIPAddressResolved
	Should Be Equal     ${amfIPAddressResolved}       ${amfIPAddress_ipv6}


Traffic Capture for Default TTL timer
	Traffic Capture Start        capture_device=oam_device    mode=file		measurement_point=NE_Terminated		uplane_capturing=True	timeout=1200
	Sleep	450
	Traffic Capture Stop		mode=file		timeout=120


Update TTL Timer value
	Perform Recommissioning		type=param	param_path=SERVEDAMF-1:amfIPAddressTTL	operation=update	value=5
	Perform Recommissioning		type=param	param_path=SERVEDAMF-2:amfIPAddressTTL	operation=update	value=7
	Call Setup		nr=airphone_sa:data      parallel=${False}    verify_attach=${False}   attach=${False}    ipv4_or_6=ipv6       timeout=300


Traffic Capture for Different TTL timer
	Traffic Capture Start        capture_device=oam_device    mode=file		measurement_point=NE_Terminated		uplane_capturing=True	timeout=1200
	Sleep	1000
	Traffic Capture Stop		mode=file		timeout=120


Process Tshark Output
    [Documentation]    Extract IPv4 and IPv6 DNS responses from the pcap file.
    ${file_path}=    Set Variable    ${CURDIR}/execution_logs/default_1.zip
    ${ipv4_responses}    ${ipv6_responses}=    Capture Tshark Responses    ${file_path}
    Check Consistent Time Difference in DNS Responses    ${ipv4_responses}    ${ipv6_responses}


Capture Tshark Responses
    [Arguments]    ${file_path}
    [Documentation]    Extract IPv4 and IPv6 DNS responses separately from the .pcap file.
    ${ipv4_output}=    Run    tshark -r ${file_path} -T fields -e frame.time -e dns.qry.name -e dns.a -Y "dns.a"
    ${ipv4_list}=    Split String    ${ipv4_output}    \n
    ${ipv6_output}=    Run    tshark -r ${file_path} -T fields -e frame.time -e dns.qry.name -e dns.aaaa -Y "dns.aaaa"
    ${ipv6_list}=    Split String    ${ipv6_output}    \n
    [Return]    ${ipv4_list}    ${ipv6_list}


Check Consistent Time Difference in DNS Responses
    [Arguments]    ${ipv4_list}    ${ipv6_list}
    Check Time Difference    ${ipv4_list}    IPv4
    Check Time Difference    ${ipv6_list}    IPv6


Check Time Difference
    [Arguments]    ${response_list}    ${protocol}
    ${timestamps} =    Create List

    FOR    ${entry}    IN    @{response_list}
        ${time_str}    ${dns_name}    ${ip} =    Split String    ${entry}    \t
        ${time_str} =    Fetch From Left    ${time_str}    .
        ${time_str} =    Replace String    ${time_str}    UTC    ${EMPTY}
        ${timestamp} =    Convert Date    ${time_str}    date_format=%b %d, %Y %H:%M:%S    result_format=%Y-%m-%d %H:%M
        Append To List    ${timestamps}    ${timestamp}
    END

    ${unique_intervals} =    Create List
    ${previous_time} =    Get From List    ${timestamps}    0

	FOR    ${current_time}    IN    @{timestamps}[1:]
		${time_diff_seconds} =    Subtract Date From Date    ${current_time}    ${previous_time}
		${time_diff_minutes} =    Evaluate    int(float(${time_diff_seconds}) // 60)
		Append To List    ${unique_intervals}    ${time_diff_minutes}
		${previous_time} =    Set Variable    ${current_time}
	END

    ${unique_intervals} =    Evaluate    list(set(${unique_intervals}))
    ${interval_count} =    Get Length    ${unique_intervals}
    Should Be Equal As Integers    ${interval_count}    1    Time difference is inconsistent for ${protocol}! Found: ${unique_intervals}