*** Settings ***
Documentation
	...		[Procedure]				"The test case is planned to validate LTE call with IPSEC configurations"
    ...     [Date]                  "15-09-25"
    ...     [Author]                "Pranitha"
	...		[QC_Path]				"QC_Path in Test Plan"
	...		[QC_ID]					"QC_ID in Test Lab for reporting"
	...  	[Validation_status]  	"Validated and Passed"
	...   	[Validated_TestLine] 	"TL-1"
    ...     [Config]    "This script verifies long duration call test with IPSEC enabled"
    ...     [RunTime Parameters]    "[bts_id used is 1]"

Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
Resource        ${CURDIR}/resources/common_keywords_PET.robot
variables       	ta_e2e_bts_trs_fw


Suite Setup     Run Keywords    Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions
...     AND     Teardown Oamops


*** Variables ***
${profile}            sim_enb


*** Test Cases ***
[1] Long_duration_call_test_with_IPSEC
	Perform Commissioning       scf_file=${base_scf_PET}   verify_bts_status=False     timeout=400     alias=default
  	Sleep  250
	Perform Recommissioning     type=delta      delta_file=${Max_ipsec}     timeout=300
	Sleep   120
	Perform Recommissioning     type=param     param_path=IPSECC-1:ipSecEnabled     operation=update     value=false    timeout=60
    Sleep   60
	Verify IPSec Status     NO_STATE
	Install cert on bts
	Install Ipsec Cerificate on Strongswan
    Sleep     60
	Perform Recommissioning     type=param     param_path=IPSECC-1:ipSecEnabled    operation=update     value=true   timeout=60
	Sleep   60
	Verify IPSec Status     ESTABLISHED
	Verify Alarm        expected_alarms=${expected_alarms}
	Make LTE longrun call and verify backhaul feature with IPSEC
	Make 5G longrun call and verify backhaul feature with IPSEC
	Verify Alarm        expected_alarms=${expected_alarms}


*** Keywords ***
Make LTE longrun call and verify backhaul feature with IPSEC
	Perform Recommissioning     type=delta      delta_file=${ransharing_config}     timeout=300
	Sleep   120
	Perform Recommissioning     type=param     param_path=FEATLADM-1:actDynamicFirewall    operation=update     value=true   timeout=60
	Sleep   60
	configure Max values
	Sleep   120
	Get IPv4 Address
	Add IPv4 Interfaces on VM
	Call Setup      lte=${profile}:data   parallel=${False}    verify_attach=${False}    attach=${False}	timeout=700
	Sleep    200
    Run     rm -rf /opt/iphy/latest/*.log*
   	Verify S1 link status
	Sleep   60
	Randomize Additional operators          1       2
   	Make LTE call and verify traffic
	Pm Counters Start     analysis=throughput     counter_analysis_file=${counter_analysis_file_name}
    Verify Pm Counters      analysis=throughput       counter_analysis_file=${counter_analysis_file_name}
	Configure dual uplane and verify LTE call
	Configure dual cplane and verify LTE call
	[TEARDOWN]    Keyword to Run at end

Make 5G longrun call and verify backhaul feature with IPSEC
	Perform Recommissioning     type=param     param_path=FEATLADM-1:actDynamicFirewall    operation=update     value=true   timeout=60
	Sleep   60
	Call Setup      5g=device4:data   parallel=${False}    verify_attach=${False}   attach=${False}
    Sleep    120
	Verify NG link Status
	Make SA Call and Verify      ipV6
	Pm Counters Start     analysis=throughput     counter_analysis_file=${counter_analysis_file_name}
    Verify Pm Counters      analysis=throughput       counter_analysis_file=${counter_analysis_file_name}
	[TEARDOWN]    Keyword to Run at end

configure Max values
	Perform Recommissioning		type=delta		delta_file=${MAX_VLAN}		skip_parameter_relation_errors=${True}		timeout=150
	Sleep 	50
	Perform Recommissioning		type=delta		delta_file=${MAX_IPIF}		skip_parameter_relation_errors=${True}		timeout=150
	Sleep 	50
	Perform Recommissioning		type=delta		delta_file=${MAX_IPRT}		skip_parameter_relation_errors=${True}		timeout=150
	Sleep 	50
	Perform Recommissioning		type=delta		delta_file=${MAX_IPRTv6}		skip_parameter_relation_errors=${True}		timeout=150
	Sleep 	50
	Perform Recommissioning		type=delta		delta_file=${MAX_FSTSCH}		skip_parameter_relation_errors=${True}		timeout=150
	Sleep 	50
	Perform Recommissioning		type=delta		delta_file=${MAX_LNMME}		skip_parameter_relation_errors=${True}		timeout=150
	Sleep 	50

Get IPv4 Address
	Get MME IP Address
	Get LTE-C IP Address    ipV4
	Get LTE-U IP Address    ipV4
	Get SGW IP Address


Add IPv4 Interfaces on VM
	Run		sh interfaces.sh

Randomize Additional operators
	[Arguments]		${start}	${End}
    	${operators}=         Evaluate    random.sample(range(${start}, ${End}), 1)    random
    	Set Suite Variable      ${operators}        ${operators}
    	${middle}=		        Evaluate    (${start}+${End}+1)/2
	Set Suite Variable		${mid_op}		${middle}
	Set Suite Variable		${start}		${start}
	Set Suite Variable		${End}			${End}

Make LTE call and verify traffic
	[Arguments]      ${operators}=1
	FOR  ${index}   IN RANGE   0   ${operators}
	    ${operator}=     Evaluate      ${index}+1
	    ${operator_str}= 	Convert To String	${operator}
		Traffic capture start           capture_device=l2_wireshark 		alias=operator_${operator_str}
	    Attach LTE UE with operator and send ul dl traffic      ${operator}      ${profile}
		Verify Alarm		faultid=${gtpu_alarm}	 	occurrences=${0}		should_exist=${False}
	    Verify Alarm		faultid=${s1_interface}	 	occurrences=${0}		should_exist=${False}
        Sleep   3600
		Verify Alarm		faultid=${gtpu_alarm}	 	occurrences=${0}		should_exist=${False}
	    Verify Alarm		faultid=${s1_interface}	 	occurrences=${0}		should_exist=${False}
		Verify IPSec Status     ESTABLISHED
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

Configure dual uplane and verify LTE call
	Perform Recommissioning     type=delta      delta_file=${dual_uplane}     timeout=300
	Sleep   120
	Call Setup      lte=${profile}:data   parallel=${False}    verify_attach=${False}    attach=${False}	timeout=700
	Sleep    200
	Run     rm -rf /opt/iphy/latest/*.log*
   	Verify S1 link status
	Randomize Additional operators          1       2
   	Make LTE call and verify traffic for dual uplane
	[TEARDOWN]    Keyword to Run at end

Make LTE call and verify traffic for dual uplane
	[Arguments]      ${operators}=1
	FOR  ${index}   IN RANGE   0   ${operators}
	    ${operator}=     Evaluate      ${index}+1
	    ${operator_str}= 	Convert To String	${operator}
		Traffic capture start           capture_device=l2_wireshark 		alias=operator_${operator_str}
	    Attach LTE UE with operator and send ul dl traffic      ${operator}      ${profile}
		Verify Alarm		faultid=${gtpu_alarm}	 	occurrences=${0}		should_exist=${False}
	    Verify Alarm		faultid=${s1_interface}	 	occurrences=${0}		should_exist=${False}
        Sleep   3600
		Verify Alarm		faultid=${gtpu_alarm}	 	occurrences=${0}		should_exist=${False}
	    Verify Alarm		faultid=${s1_interface}	 	occurrences=${0}		should_exist=${False}
	    Stop traffic and detach LTE UE          ${operator}      ${profile}
	    ${pcap_file}=       Traffic capture stop	  alias=operator_${operator_str}
	    ${mme_ip}=     Get from List        ${MME_IP_List}     ${index}
	    ${sgw_ip}=     Get from List        ${SGW_IP_List}     ${index}
	    ${cplaneIp}=   Get from List        ${LTE_C_IP_List}     ${index}
	    ${uplaneIp}=   Get from List        ${LTE_U_IP_List}     ${index}
	    Get IP Version      ${mme_ip}
	    Analyse Pcap      pcap_filename=${pcap_file}      analysis=s1ap_attach_request_${version}
		...     filter_file_name=${traffic_filter_file_name}
	    Analyse Pcap      pcap_filename=${pcap_file}      analysis=s1ap_attach_accept_${version}
		...     filter_file_name=${traffic_filter_file_name}
	    Analyse Pcap      pcap_filename=${pcap_file}      analysis=lte_call_ul_${version}      filter_file_name=${traffic_filter_file_name}
	    Analyse Pcap      pcap_filename=${pcap_file}      analysis=lte_call_dl_${version}      filter_file_name=${traffic_filter_file_name}
		Analyse Pcap      pcap_filename=${pcap_file}      analysis=dual_uplane_call_${version}     filter_file_name=${traffic_filter_file_name}
    END
	[TEARDOWN]   Run Keyword and Ignore Error     Traffic capture stop	  alias=operator_${operator_str}

Configure dual cplane and verify LTE call
	Perform Recommissioning     type=delta      delta_file=${dual_cplane}     timeout=300
	Sleep   120
	Call Setup      lte=${profile}:data   parallel=${False}    verify_attach=${False}    attach=${False}	timeout=700
	Sleep    200
	Run     rm -rf /opt/iphy/latest/*.log*
   	Verify S1 link status
	Randomize Additional operators          1       2
   	Make LTE call and verify traffic
	Verify SCTP link failure alarm
	[TEARDOWN]    Keyword to Run at end

Verify SCTP link failure alarm
    Delete primary LNMME link
    Sleep   80
    Verify S1 link failure alarm
    Verify S1 link status
    Restore link
    Sleep   80
    Verify S1 link status
    Verify S1 link alarm

Delete primary LNMME link
   	FOR    ${i}   IN RANGE    0    10
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

Keyword to Run at end
    Call Teardown         lte=${profile}:data
    Run     sudo killall edaemon egate
	Call Teardown         5g=device4:data
    Run     sudo killall edaemon egate

Install cert on bts
	Certificate Configure     operation=install_certificate     cert_file=${PET_cert}     cert_type=BtsTrustChain
	...     cert_format=P12     password=Nokia1234!
	Sleep    60

Verify IPSec Status
    [Arguments]      ${IKEP_State}
    ${ikep_list}=    Query Admin Infomodel    query=get list //IKEP_R-1   timeout=30
    ${len}=    Get Length   ${ikep_list}
    FOR   ${item}  IN  @{ikep_list}
        ${state}=    Get From Dictionary   ${item}    ikePeerState
        Should be Equal   ${state}    ${IKEP_State}
    END

Install Ipsec Cerificate on Strongswan
	SSHLibrary.Open connection    ${config.Strongswan_ip}
	SSHLibrary.Login    ${config.Strongswan_user}    ${config.Strongswan_passwd}
	Execute Command     sudo rm -rf ${cert_PrivateKey}
	Execute Command     sudo rm -rf ${cert_Btspem}
	Execute Command 	sudo ln -s ${SHA1_cert_PrivateKey} ${cert_PrivateKey}
	Execute Command 	sudo ln -s ${SHA1_cert_Btspem} ${cert_Btspem}
	[TEARDOWN] 		SSHLibrary.Close Connection

Verify NG link Status
	FOR   ${operator}   IN RANGE   0   	1
	      ${operator_str}=	   Convert To String	    ${operator}
	      ${NG_status}=       Query Admin Infomodel    query=get object ${amf_moc_path}-${operator_str}
  	      ${ng_link_status}=     Get From Dictionary     dictionary=${NG_status}      key=ngLinkStatus
          Should Be Equal		${ng_link_status}		Active
    END

Make SA Call and Verify
	[Arguments]      ${IP_Version}
	Sleep  30
	FOR  ${operator}   IN RANGE   0   1
        ${operator_str}= 	Convert To String	${operator}
		Set Suite Variable      ${operator}        ${operator}
	    Set Suite Variable      ${operator_str}        ${operator_str}
	    Run Keyword If   '${IP_Version}' == 'ipV6'    set suite variable     ${AMF}    6
        ...     ELSE      set suite variable     ${AMF}    0
	    ${served_amf}=    	Evaluate       ${operator}+${AMF}
    	Traffic Capture Start	capture_device=oam_device	mode=file	 measurement_point=NE_Terminated	  uplane_apturing=True
		...	    alias=point_A_${operator_str}_${IP_Version}
	    Attach UE with operator specific qci and send ul dl traffic for 5g     ${operator}
		Sleep	1200
	    Stop traffic and detach UE for 5g         ${operator}
     	${pcap_file}=       Traffic capture stop	  alias=slice_${operator_str}_${IP_Version}
	    Get AMF IP Address      ${served_amf}
	    Get NG-U IP Address     ${operator}           ${IP_Version}
	    ${ip_len}=      Evaluate      1000*${operator}
	    Analyse Pcap        pcap_filename=${pcap_file}        analysis=SA_call_ul_${IP_Version}      filter_file_name=${traffic_filter_file_name}
	    Analyse Pcap        pcap_filename=${pcap_file}        analysis=SA_call_dl_${IP_Version}      filter_file_name=${traffic_filter_file_name}
    END

Get AMF IP Address
	[Arguments]          ${served_amf}
	${amf_dict}=      Query Admin Infomodel    query=get object ${amf_path}-${served_amf}
    ${amf_ip}=       Get From Dictionary       ${amf_dict}    amfIPAddress
	Set Suite Variable    ${amf_ip}      ${amf_ip}

Get NG-U IP Address
 	[Arguments]          ${operator}        ${IP_Version}
	${index}=    Evaluate      ${operator}-1
	${nrbts_dict}=    Query Admin Infomodel    query=get object ${nrbts_path}
	${nguplane_list}=    Get From Dictionary     dictionary=${nrbts_dict}      key=ngUplane
	${nguplane_add}=   Get from list       ${nguplane_list}        ${index}
	${nguplane_moc}=    Get From Dictionary     ${nguplane_add}       ${IP_Version}AddressDN1
	${nguplane_ipif}=   Query Admin Infomodel     query=get object ${nguplane_moc}
	${nguplane_ip}=    Get From Dictionary      ${nguplane_ipif}      localIpAddr
    Set Suite Variable     ${nguplane_ip}      ${nguplane_ip}