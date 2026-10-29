*** Settings ***
Documentation
...		[Author]     		        	"Pranitha"
...		[Maintenance]		        	"TRS I&V Tools Bangalore Team"
...		[Date] 			            "10:05:2024"
...		[QC_Path]                   		"QC_Path in Test Plan"
...		[QC_ID]			            "QC_ID in Test Lab for reporting"
...		[Feature_ID] 		        	"CB010762"
...     [Validated_TestLine]        		"ASIL-TL-0005"
...		[Procedure]   		        	"CB010762 A B1 10 operator Ransharing"
...     [Precondition]              		"ASIL+ABIP hardware is required"
...     [Function_Hash_Tags]        		"LTE 10 operator Ransharing"


Variables       	ta_e2e_bts_trs_fw
Resource    	${CURDIR}/../resources/common_keywords.robot
Resource    	${CURDIR}/resources/Common_keywords_CB010762.robot

Suite Setup		Run Keywords	Suite Setup Preconditions
...		AND		Setup Oamops
Suite Teardown	Run Keywords	Suite Teardown Postconditions
...		AND		Teardown Oamops


*** Variables ***
${profile}            LTE10762_10op_HO_444

*** Test Cases ***
[1][1.0] LTE3065_R_a_X2_666_handover and Handover TAC check for all operators
	Perform Commissioning       scf_file=${basic_10op_HO_444}    verify_bts_status=False     timeout=400
 	Sleep       250
	Get IPv4 Address
	Add Interfaces on VM
	Call Setup      lte=${profile}:data   parallel=${False}    verify_attach=${False}    attach=${False}
	Sleep    80
	Verify S1 link status
	Sleep   60
	Verify X2 link status
	Sleep	60
	Randomize Additional operators          1       2
    	Make LTE call and verify for each operators         11      12
    	[TEARDOWN]    Keyword to Run at end

*** Keywords ***
Get IPv4 Address
	Get LNADJ IP Address	30	40
	Get MME IP Address     10
	Get LTE-C IP Address    ipV4    10
	Get LTE-U IP Address    ipV4    10
	Get SGW IP Address      10

Get IPv6 Address
	Get LNADJ IP Address	30	40
	Get MME IP Address     10
	Get LTE-C IP Address    ipV6    10
	Get LTE-U IP Address    ipV6    10
	Get SGW IP Address      10

Add Interfaces on VM
	Run		sh interfaces.sh

Randomize Additional operators
	[Arguments]		${start}	${End}
    	${operators}=         Evaluate    random.sample(range(${start}, ${End}), 1)    random
    	Set Suite Variable      ${operators}        ${operators}
    	${middle}=		        Evaluate    (${start}+${End}+1)/2
	Set Suite Variable		${mid_op}		${middle}
	Set Suite Variable		${start}		${start}
	Set Suite Variable		${End}			${End}

Make LTE call and verify for each operators
	[Arguments]    	${cell1}    ${cell2}
	FOR  ${operator}   IN   @{operators}
	    ${cell}=   Evaluate    ${cell1} if ${OPERATOR} >= ${start} and ${OPERATOR} <= ${mid_op}
		...		 else ${cell2} if ${OPERATOR} >= (${mid_op}+1) and ${OPERATOR} <= ${End} else None
    	Run Keyword If    '${cell}' == 'None'    Fail    Operator is out of the valid range (1 to 10)
    	Log    ${cell}
    	${index}=      Evaluate    ${operator}-1
    	${operator_str}=   Convert To String   ${operator}
    	Traffic capture start           capture_device=vm_eth3_interface 		alias=operator_${operator_str}
	    Attach LTE UE with operator and send ul dl traffic      ${operator}      ${profile}	     ${cell}
	    Verify Alarm		faultid=${gtpu_alarm}	 	occurrences=${0}		should_exist=${False}
	    Verify Alarm		faultid=${s1_interface}	 	occurrences=${0}		should_exist=${False}
	    Stop traffic and detach LTE UE          ${operator}      ${profile}
	    ${pcap_file}=       Traffic capture stop	  alias=operator_${operator_str}
	    ${mme_ip}=     Get from List        ${MME_IP_List}     ${index}
	    ${sgw_ip}=     Get from List        ${SGW_IP_List}     0
	    ${cplaneIp}=   Get from List        ${LTE_C_IP_List}     ${index}
	    ${uplaneIp}=   Get from List        ${LTE_U_IP_List}     ${index}
	    ${lnadjIp}=	    Get from List        ${LNADJ_IP_List}     ${index}
	    Get IP Version      ${mme_ip}
	    Analyse Pcap      pcap_filename=${pcap_file}      analysis=s1ap_attach_request_${version}
		...     filter_file_name=${traffic_filter_file_name}
	    Analyse Pcap      pcap_filename=${pcap_file}      analysis=s1ap_attach_accept_${version}
		...     filter_file_name=${traffic_filter_file_name}
	    Analyse Pcap      pcap_filename=${pcap_file}      analysis=lte_call_HO_${version}
		...      	 filter_file_name=${traffic_filter_file_name}
    END
	[TEARDOWN]   Run Keyword and Ignore Error     Traffic capture stop	  alias=operator_${operator_str}

Keyword to Run at end
    Call Teardown         lte=${profile}:data
    Run     sudo killall edaemon egate
