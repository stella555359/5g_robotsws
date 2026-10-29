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
${profile}            LTE10762_10op_basic
${profile1}	      LTE10762_10op_slicing

*** Test Cases ***
[1]CB010762-A_B1_Feature_with_10_operators_Admission_and_rejection_of_normal_GBR_connection_dual_uplane_both_IPV4_IPV6
	Perform Commissioning       scf_file=${basic_6op}    verify_bts_status=False     timeout=400
  	Sleep       180
	Perform Recommissioning     type=delta      delta_file=${10op_CB010762}     timeout=300
	Sleep   120
	Get IPv4 Address
	Get IPv6 Address
	Add Interfaces on VM
	Call Setup      lte=${profile}:data   parallel=${False}    verify_attach=${False}    attach=${False}
	Sleep    80
   	Verify S1 link status
	Sleep   60
	Configure and verify Emergency TAC
	Verify Counters
	configure and verify dual_uplane

*** Keywords ***
Get IPv4 Address
	Get MME IP Address     10
	Get LTE-C IP Address    ipV4    10
	Get LTE-U IP Address    ipV4    10
	Get SGW IP Address      10

Get IPv6 Address
	Get MME IP Address     10
	Get LTE-C IP Address    ipV6    10
	Get LTE-U IP Address    ipV6    10
	Get SGW IP Address      10

Add Interfaces on VM
	Delete Interfaces
	Run		sh interfaces.sh

Randomize Additional operators
	[Arguments]		${start}	${End}
    ${operators}=         Evaluate    random.sample(range(${start}, ${End}), 1)    random
    Set Suite Variable      ${operators}        ${operators}

Keyword to Run at end
    Call Teardown         lte=${profile}:data
    Run     sudo killall edaemon egate uexgate

Configure and verify Emergency TAC
	Perform Recommissioning     type=delta      delta_file=${delta_prereq_emer}     timeout=300
   	Sleep   120
	Randomize Additional operators			1		6
	Make LTE call for emergency TAC successful	11
	Make LTE call for emergency TAC failure		11
	Randomize Additional operators			7		10
	Make LTE call for emergency TAC successful	12
	Make LTE call for emergency TAC failure		12

Verify Counters
	Pm Counters Start		analysis=tacsuccessfulGBRemergency		counter_analysis_file=${counter_analysis_file_name}
	Verify Pm Counters 		analysis=tacsuccessfulGBRemergency		 counter_analysis_file=${counter_analysis_file_name}

Make LTE call for emergency TAC successful
	[Arguments]    	${cell}
	FOR  ${operator}   IN   @{operators}
		${index}= 		Evaluate	${operator}-1
	    ${operator_str}= 	Convert To String	${operator}
		Traffic capture start           capture_device=l2_wireshark 		alias=operator_${operator_str}
	    Attach LTE UE with operator and send ul dl traffic for Emergency TAC success   ${operator}      ${profile}	     ${cell}
	    Stop traffic and detach LTE UE        ${operator}      ${profile}
	    ${pcap_file}=       Traffic capture stop	  alias=operator_${operator_str}
		Analyse pcap  pcap_filename=${pcap_file}  analysis=emergency_ue_attach_req  filter_file_name=${traffic_filter_file_name}
		Analyse pcap   pcap_filename=${pcap_file}  analysis=emergency_ue_attach_resp_vlan	filter_file_name=${traffic_filter_file_name}
	END
	[TEARDOWN]    Run Keyword and Ignore Error     Traffic capture stop	  alias=operator_${operator_str}


Make LTE call for emergency TAC failure
	[Arguments]    	${cell}
	FOR  ${operator}   IN   @{operators}
		${index}= 		Evaluate	${operator}-1
	    ${operator_str}= 	Convert To String	${operator}
		Traffic capture start           capture_device=l2_wireshark 		alias=operator_${operator_str}
	    Attach LTE UE with operator and send ul dl traffic for Emergency TAC failure   ${operator}      ${profile}	     ${cell}
	    Stop traffic and detach LTE UE         ${operator}      ${profile}
	    ${pcap_file}=       Traffic capture stop	  alias=operator_${operator_str}
		Analyse pcap  pcap_filename=${pcap_file}  analysis=Tac_preemption_failed_vlan  filter_file_name=${traffic_filter_file_name}
	END
	[TEARDOWN]   Run Keyword and Ignore Error     Traffic capture stop	  alias=operator_${operator_str}

configure and verify dual_uplane
	Perform Recommissioning		type=delta		delta_file=${dual_uplane}		skip_parameter_relation_errors=${True}		timeout=300
	Sleep 	100
	Randomize Additional operators           1       6
    Verify dual uplane calls        11
    Randomize Additional operators          7       10
    Verify dual uplane calls        12

Verify dual uplane calls
    [Arguments]     ${cell}
    FOR  ${operator}   IN   @{operators}
        ${index}=      Evaluate    ${operator}-1
        ${operator_str}=   Convert To String   ${operator}
        Traffic capture start           capture_device=vm_eth3_interface       alias=operator_${operator_str}
        Attach LTE UE with operator and send ul dl traffic       ${operator}      ${profile}        ${cell}
        Stop traffic and detach LTE UE           ${operator}      ${profile}
        ${pcap_file}=       Traffic capture stop     alias=operator_${operator_str}
        Set Suite Variable     ${pcap_file}        ${pcap_file}
        ${secondary_uplane_ip}=    Get from List        ${LTE_U_IP_List_secondary}     ${index}
        ${mme_ip}=     Get from List        ${MME_IP_List}     ${index}
        ${sgw_ip}=     Get from List        ${SGW_IP_List}     ${index}
        ${cplaneIp}=   Get from List        ${LTE_C_IP_List}     ${index}
        ${uplaneIp}=   Get from List        ${LTE_U_IP_List}     ${index}
        Set Suite Variable      ${uplaneIp}     ${uplaneIp}
        Set Suite Variable      ${secondary_uplane_ip}     ${secondary_uplane_ip}
        Get IP Version      ${mme_ip}
        Analyse Pcap      pcap_filename=${pcap_file}      analysis=s1ap_attach_request_${version}     filter_file_name=${traffic_filter_file_name}
        Analyse Pcap      pcap_filename=${pcap_file}      analysis=s1ap_attach_accept_${version}     filter_file_name=${traffic_filter_file_name}
        Analyse Pcap      pcap_filename=${pcap_file}      analysis=lte_call_ul_${version}      filter_file_name=${traffic_filter_file_name}
        Analyse Pcap      pcap_filename=${pcap_file}      analysis=lte_call_dl_${version}      filter_file_name=${traffic_filter_file_name}
        Analyse Pcap      pcap_filename=${pcap_file}      analysis=dual_uplane_call_${version}     filter_file_name=${traffic_filter_file_name}
    END
    [TEARDOWN]   Run Keyword and Ignore Error     Traffic capture stop    alias=operator_${operator_str}
