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
${profile2}            LTE10762_10op_qos

*** Test Cases ***
[1]CB010762-A_B1_Feature_with_PLMNs_up_to_10_operators_with_QCI_APN_IPV4_and_SCTP_multihoming_and_QOS
	Perform Commissioning       scf_file=${basic_6op}    verify_bts_status=False     timeout=400
  	Sleep       180
	Perform Recommissioning     type=delta      delta_file=${10op_CB010762}     timeout=300
	Sleep   120
	Get IPv4 Address
	Add Interfaces on VM
	Perform Recommissioning		type=delta		delta_file=${delta_QOS}		skip_parameter_relation_errors=${True}		timeout=300
	Sleep 	50
	Call Setup      lte=${profile2}:data   parallel=${False}    verify_attach=${False}    attach=${False}
	Sleep    80
   	Verify S1 link status
	Sleep   60
	Verify wireshark for qos
	Verify SCTP link failure alarm
	Configure and verify NWslice
	Verify Counters
   	[TEARDOWN]    Keyword to Run at end

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

Verify wireshark for qos
	Verify Data Rate in wireshark		${pcap_file}		gtp && ip.addr==${uplaneIp}		1000

Verify Data Rate in wireshark
	[Arguments]         ${pcap_file}        ${filter}       ${expected_data_rate}
    Run  tshark -o esp.enable_encryption_decode:TRUE -r ${pcap_file} -Y "${filter}" -w ${EXECDIR}/ue_shaping 2>/dev/null
    ${data_rate}=  Run  capinfos ${EXECDIR}/ue_shaping -i | tail -1 | awk '{ print $4 }'
    ${data_rate}=        Remove String       ${data_rate}     ,
    Set Suite Variable     ${data_rate}
	${cal_1}=		Evaluate	${expected_data_rate}*0.1
    ${higher_limit}=        Evaluate        ${expected_data_rate}+${cal_1}
    ${lower_limit}=         Evaluate            ${expected_data_rate}-${cal_1}
    Should Be True      ${lower_limit}<${data_rate}<${higher_limit}

Keyword to Run at end
    Call Teardown         lte=${profile2}:data
    Run     sudo killall edaemon egate

Verify SCTP link failure alarm
    Delete primary LNMME link
    Sleep   150
    Verify S1 link failure alarm
    Verify S1 link status
    Restore link
    Sleep   150
    Verify S1 link alarm

Delete primary LNMME link
   	FOR    ${i}   IN RANGE    0    9
       ${mme_del_ip}=     Get from List        ${MME_IP_List}     ${i}
	    Run     sudo ip a d ${mme_del_ip}/${subnet} dev eth3
	END

Verify S1 link failure alarm
    Verify Alarm		faultid=${s1_sctp}	 	occurrences=${10}		should_exist=${True}

Verify S1 link alarm
    Verify Alarm        faultid=${s1_sctp}      occurrences=${0}       should_exist=${False}

Restore link
   FOR     ${i}   IN RANGE    0    10
      ${mme_del_ip}=     Get from List        ${MME_IP_List}     ${i}
      Run     sudo ip a a ${mme_del_ip}/${subnet} dev eth3
   END

Configure and verify NWslice
	Perform Recommissioning		type=delta		delta_file=${NWslice}		skip_parameter_relation_errors=${True}		timeout=300
	Sleep 	50
	Call Setup      lte=${profile1}:data   parallel=${False}    verify_attach=${False}    attach=${False}
	Sleep    80
	Randomize Additional operators			1		6
	Make LTE call and verify for each operators for dedicated qci			11
	Randomize Additional operators			7		10
   	Make LTE call and verify for each operators for dedicated qci			12
	Call Teardown         lte=${profile1}:data
	Run     sudo killall edaemon egate uexgate

Verify Counters
	Pm Counters Start		analysis=IPIF_counters_multiple_slice		counter_analysis_file=${counter_analysis_file_name}
	Verify Pm Counters 		analysis=IPIF_counters_multiple_slice		 counter_analysis_file=${counter_analysis_file_name}

Make LTE call and verify for each operators for dedicated qci
	[Arguments]    	${cell}
	${sgw_id}=          Set Variable            ${sgwid}
   	${QCIid}=             Set Variable            ${QCIid}
	FOR  ${operator}   IN   @{operators}
		 ${index}= 		Evaluate	${operator}-1
	    ${operator_str}= 	Convert To String	${operator}
		 Traffic capture start           capture_device=l2_wireshark 		alias=operator_${operator_str}
	    Attach LTE UE with operator and send ul dl traffic for dedicated qci     ${operator}      ${profile1}	     ${cell}
		Verify Alarm		faultid=${gtpu_alarm}	 	occurrences=${0}		should_exist=${False}
		Verify Alarm		faultid=${s1_interface}	 	occurrences=${0}		should_exist=${False}
	    Stop traffic and detach LTE UE for dedicated qci          ${operator}      ${profile1}
	    ${pcap_file}=       Traffic capture stop	  alias=operator_${operator_str}
	    ${mme_ip}=     Get from List        ${MME_IP_List}     ${index}
	    ${sgw_ip}=     Get from List        ${SGW_IP_List}     ${index}
	    ${cplaneIp}=   Get from List        ${LTE_C_IP_List}     ${index}
	    ${uplaneIp}=   Get from List        ${LTE_U_IP_List}     ${index}
	    Get IP Version      ${mme_ip}
	    Analyse Pcap      pcap_filename=${pcap_file}      analysis=s1ap_attach_request_${version}     filter_file_name=${traffic_filter_file_name}
	    Analyse Pcap      pcap_filename=${pcap_file}      analysis=s1ap_attach_accept_${version}     filter_file_name=${traffic_filter_file_name}
	    Analyse Pcap      pcap_filename=${pcap_file}      analysis=lte_call_ul_${version}      filter_file_name=${traffic_filter_file_name}
	    Analyse Pcap      pcap_filename=${pcap_file}      analysis=lte_call_dl_${version}      filter_file_name=${traffic_filter_file_name}
	    Analyse Pcap      pcap_filename=${pcap_file}      analysis=qci_${version}        filter_file_name=${traffic_filter_file_name}
	END
	[TEARDOWN]   Run Keyword and Ignore Error     Traffic capture stop	  alias=operator_${operator_str}
