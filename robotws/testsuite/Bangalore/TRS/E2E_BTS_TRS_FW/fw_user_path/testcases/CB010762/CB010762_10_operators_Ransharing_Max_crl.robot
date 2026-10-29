*** Settings ***
Documentation
...		[Author]     		        	"Pranitha"
...		[Maintenance]		        	"TRS I&V Tools Bangalore Team"
...		[Date] 			            "10:05:2024"
...		[QC_Path]                   		"QC_Path in Test Plan"
...		[QC_ID]			            "QC_ID in Test Lab for reporting"
...		[Feature_ID] 		        	"CB010762"
...     		[Validated_TestLine]        		"ASIL-TL-0005"
...		[Procedure]   		        	"CB010762 A B1 10 operator Ransharing"
...     		[Precondition]              		"ASIL+ABIP hardware is required"
...     		[Function_Hash_Tags]        		"LTE 10 operator Ransharing"


Variables       	ta_e2e_bts_trs_fw
Resource    	${CURDIR}/../resources/common_keywords.robot
Resource    	${CURDIR}/resources/Common_keywords_CB010762.robot


Suite Setup		Run Keywords	Suite Setup Preconditions
...		AND		Setup Oamops
Suite Teardown	Run Keywords	Suite Teardown Postconditions
...		AND		Teardown Oamops


*** Variables ***
${profile}            LTE10762_10op_basic

*** Test Cases ***
[1]CB010762-B_B1_Feature_10_operators_MAX_CA_MAX_CRL
	Restore all Certificate
	Perform Commissioning       scf_file=${basic_6op}    verify_bts_status=False     timeout=400
  	Sleep       180
	Perform Recommissioning     type=delta      delta_file=${10op_CB010762}     timeout=300
	Sleep   120
	Get IPv4 Address
	Call Setup      lte=${profile}:data   parallel=${False}    verify_attach=${False}    attach=${False}
	Sleep    80
   	Verify S1 link status
	Verify Alarm		faultid=${gtpu_alarm}	 	occurrences=${0}		should_exist=${False}
	Verify Alarm		faultid=${s1_interface}	 	occurrences=${0}		should_exist=${False}
	Install Max CA/TA certs
	Configure and verify max crl
	configure Max values and verify S1 link status
	Sleep   60
   	[TEARDOWN]    Keyword to Run at end


*** Keywords ***
Get IPv4 Address
	Get MME IP Address     10
	Get LTE-C IP Address    ipV4    10
	Get LTE-U IP Address    ipV4    10
	Get SGW IP Address      10

Keyword to Run at end
    Call Teardown         lte=${profile}:data
    Run     sudo killall edaemon egate

Restore all Certificate
	certificate configure    operation=restore_vendor_certificate
	Sleep 		10
	certificate configure    operation=delete_cert    all_certs=${True}
	Sleep     80

Install Max CA/TA certs
	FOR 	${i}		IN RANGE 	0	68
		Certificate Configure		operation=install_certificate		cert_file=${Cert_${i}}      cert_type=AdditionalCa      cert_format=PEM
   	   	Sleep   80
   	END

Configure and verify max crl
	Perform Recommissioning		type=delta		delta_file=${max_crl}		skip_parameter_relation_errors=${True}		timeout=300
	Sleep 	400
	Certificate Configure    	operation=get_certificate_revocation_list
	Sleep 	100
	CRL Download success

CRL Download success
	Wait Until Keyword Succeeds    5 min    30 		Verify Alarm		faultid=${crl_update_failure}	 occurrences=${0}		should_exist=${False}

configure Max values and verify S1 link status
	Perform Recommissioning		type=delta		delta_file=${MAX_VLAN}		skip_parameter_relation_errors=${True}		timeout=300
	Sleep 	50
	Perform Recommissioning		type=delta		delta_file=${MAX_IPIF}		skip_parameter_relation_errors=${True}		timeout=300
	Sleep 	50
	Perform Recommissioning		type=delta		delta_file=${MAX_IPRT}		skip_parameter_relation_errors=${True}		timeout=300
	Sleep 	50
	Perform Recommissioning		type=delta		delta_file=${MAX_IPRTv6}		skip_parameter_relation_errors=${True}		timeout=300
	Sleep 	50
	Perform Recommissioning		type=delta		delta_file=${MAX_FSTSCH}		skip_parameter_relation_errors=${True}		timeout=300
	Sleep 	50
	Perform Recommissioning		type=delta		delta_file=${MAX_LNMME}		skip_parameter_relation_errors=${True}		timeout=300
	Sleep 	50
	Call Setup      lte=${profile}:data   parallel=${False}    verify_attach=${False}    attach=${False}
	Sleep    80
	Verify S1 link status
	Randomize Additional operators			1		6
	Make LTE call and verify for each operators			11
	Randomize Additional operators			7		10
   	Make LTE call and verify for each operators			12
   	[TEARDOWN]    Keyword to Run at end

Randomize Additional operators
	[Arguments]		${start}	${End}
    ${operators}=         Evaluate    random.sample(range(${start}, ${End}), 2)    random
    Set Suite Variable      ${operators}        ${operators}

Make LTE call and verify for each operators
	[Arguments]    	${cell}
	FOR  ${operator}   IN   @{operators}
		 ${index}= 		Evaluate	${operator}-1
	    ${operator_str}= 	Convert To String	${operator}
		 Traffic capture start           capture_device=vm_eth3_interface 		alias=operator_${operator_str}
	    Attach LTE UE with operator and send ul dl traffic      ${operator}      ${profile}	     ${cell}
	    Stop traffic and detach LTE UE          ${operator}      ${profile}
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
    END
	[TEARDOWN]   Run Keyword and Ignore Error     Traffic capture stop	  alias=operator_${operator_str}
