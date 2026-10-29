*** Settings ***
Documentation
...		[Author]     		        "Nupur K"
...		[Maintenance]		        "TRS I&V Tools Bangalore Team"
...		[Date] 			            "19:05:2021"
...		[QC_Path]                   "QC_Path in Test Plan"
...		[QC_ID]			            "QC_ID in Test Lab for reporting"
...		[Feature_ID] 		        "CB006557"
...     [Validated_TestLine]        "KVM53-TRSIV-TL012"
...		[Procedure]   		        "SR002750_TRS_Commissioning_SgNB_with_Dual_Stack_for_all_the_RATs"
...     [Precondition]              "ASIB + ASIB hardware is required"
...     [Config_Comments]           "Shared VLAN NG-U NG-C Xn-U and Xn-C IPs for 6 Operators_IPv4"
...     [Function_Hash_Tags]        "SA 6 Operator RAN Sharing, Dual Stack, verify 6 operator call with Airphone"


variables       ta_e2e_bts_trs_fw
Resource    	${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/../resources/Admin_Common_Library.robot

Suite Setup		Run Keywords	Suite Setup Preconditions
...		AND		Setup Oamops
Suite Teardown	Run Keywords	Suite Teardown Postconditions
...		AND		Teardown Oamops



*** Variables ***
${profile}          Dual_Stack_6operator

*** Test Cases ***
[1][1.0] TRS_Commissioning SgNB with Dual Stack for all the RATs_SR002750
	Perform Commissioning       scf_file=${Configuration_scf_basic}   verify_bts_status=False     timeout=400     alias=default
    Sleep    240
    Perform Recommissioning     type=delta   delta_file=${Configuration_delta_Dual_Stack_6OP_Ransharing}      timeout=300
    Sleep   150
	Check and Verify firewall rules after enabling RAN sharing flag
	Call Setup      5g=${profile}:data   parallel=${False}    verify_attach=${False}   attach=${False}
    Sleep    120
	Verify NG link Status for Dual Stack 6 Operator
	Perform Recommissioning        type=delta             delta_file=${Block_IPv6_AMFs}          timeout=300
	Make SA Call and Verify for 6 Operator      ipV4
	Perform Recommissioning        type=delta             delta_file=${Block_IPv4_AMFs}          timeout=300
	Make SA Call and Verify for 6 Operator      ipV6
    Perform Recommissioning      type=param      param_path=NRBTS-1:actTrsSepaSARanSharing         operation=update    value=false
	Sleep    120
	Check and Verify firewall rules before enabling RAN sharing flag
    [TEARDOWN]    Keyword to Run at end

*** Keywords ***
Check and Verify firewall rules before enabling RAN sharing flag
	Execute command on ENodeB      /opt/trs/bin/./vtc l4clfr ipv4 show
	Execute command on ENodeB      cat /tmp/l3l4_classifier_table.txt | grep 5G_uplane | awk '{print $1}'
    @{5G_uplane_process_ids}=     Split String         ${stdout}
    ${no_of_uplane_process}=      Get Length      ${5G_uplane_process_ids}
    ${expected_value1}=    Convert to Integer    4
    Should Be Equal       ${no_of_uplane_process}    	${expected_value1}

	Execute command on ENodeB      cat /tmp/l3l4_classifier_table.txt | grep 38412 | awk '{print $1}'
    @{5G_ngCplane_process_ids}=     Split String         ${stdout}
    ${no_of_ngCplane_process}=      Get Length      ${5G_ngCplane_process_ids}
    ${expected_value2}=    Convert to Integer    1
    Should Be Equal       ${no_of_ngCplane_process}    	${expected_value2}

    Execute command on ENodeB      cat /tmp/l3l4_classifier_table.txt | grep 38422 | awk '{print $1}'
    @{5G_XnCplane_process_ids}=     Split String         ${stdout}
    ${no_of_XnCplane_process}=      Get Length      ${5G_XnCplane_process_ids}
    ${expected_value3}=    Convert to Integer    1
    Should Be Equal       ${no_of_XnCplane_process}      ${expected_value3}

	Execute command on ENodeB      /opt/trs/bin/./vtc l4clfr ipv6 show
	Execute command on ENodeB      cat /tmp/l3l4_classifier_table_ipv6.txt | grep 5G_uplane | awk '{print $1}'
    @{5G_uplane_process_ids}=     Split String         ${stdout}
    ${no_of_uplane_process}=      Get Length      ${5G_uplane_process_ids}
    ${expected_value1}=    Convert to Integer    1
    Should Be Equal       ${no_of_uplane_process}    	${expected_value1}

	Execute command on ENodeB      cat /tmp/l3l4_classifier_table_ipv6.txt | grep 38412 | awk '{print $1}'
    @{5G_ngCplane_process_ids}=     Split String         ${stdout}
    ${no_of_ngCplane_process}=      Get Length      ${5G_ngCplane_process_ids}
    ${expected_value2}=    Convert to Integer    1
    Should Be Equal       ${no_of_ngCplane_process}    	${expected_value2}

Check and Verify firewall rules after enabling RAN sharing flag
	Execute command on ENodeB      /opt/trs/bin/./vtc l4clfr ipv4 show
	Execute command on ENodeB      cat /tmp/l3l4_classifier_table.txt | grep 5G_uplane | awk '{print $1}'
    @{5G_uplane_process_ids}=     Split String         ${stdout}
    ${no_of_uplane_process}=      Get Length      ${5G_uplane_process_ids}
    ${expected_value1}=    Convert to Integer    9
    Should Be Equal       ${no_of_uplane_process}    	${expected_value1}

	Execute command on ENodeB      cat /tmp/l3l4_classifier_table.txt | grep 38412 | awk '{print $1}'
    @{5G_ngCplane_process_ids}=     Split String         ${stdout}
    ${no_of_ngCplane_process}=      Get Length      ${5G_ngCplane_process_ids}
    ${expected_value2}=    Convert to Integer    6
    Should Be Equal       ${no_of_ngCplane_process}    	${expected_value2}

    Execute command on ENodeB      cat /tmp/l3l4_classifier_table.txt | grep 38422 | awk '{print $1}'
    @{5G_XnCplane_process_ids}=     Split String         ${stdout}
    ${no_of_XnCplane_process}=      Get Length      ${5G_XnCplane_process_ids}
    ${expected_value3}=    Convert to Integer    1
    Should Be Equal       ${no_of_XnCplane_process}      ${expected_value3}

	Execute command on ENodeB      /opt/trs/bin/./vtc l4clfr ipv6 show
	Execute command on ENodeB      cat /tmp/l3l4_classifier_table_ipv6.txt | grep 5G_uplane | awk '{print $1}'
    @{5G_uplane_process_ids}=     Split String         ${stdout}
    ${no_of_uplane_process}=      Get Length      ${5G_uplane_process_ids}
    ${expected_value1}=    Convert to Integer    6
    Should Be Equal       ${no_of_uplane_process}    	${expected_value1}

	Execute command on ENodeB      cat /tmp/l3l4_classifier_table_ipv6.txt | grep 38412 | awk '{print $1}'
    @{5G_ngCplane_process_ids}=     Split String         ${stdout}
    ${no_of_ngCplane_process}=      Get Length      ${5G_ngCplane_process_ids}
    ${expected_value2}=    Convert to Integer    6
    Should Be Equal       ${no_of_ngCplane_process}    	${expected_value2}


Verify NG link Status for Dual Stack 6 Operator
	FOR   ${operator}   IN RANGE   1   13
	      ${operator_str}=	   Convert To String	    ${operator}
	      ${NG_status}=       Query Admin Infomodel    query=get object ${amf_moc_path}-${operator_str}
  	      ${ng_link_status}=     Get From Dictionary     dictionary=${NG_status}      key=ngLinkStatus
          Should Be Equal		${ng_link_status}		Active
    END

Make SA Call and Verify for 6 Operator
	[Arguments]      ${IP_Version}
	Sleep  30
	FOR  ${operator}   IN RANGE   1   7
        ${operator_str}= 	Convert To String	${operator}
		 Set Suite Variable      ${operator}        ${operator}
	    Set Suite Variable      ${operator_str}        ${operator_str}
	    Run Keyword If   '${IP_Version}' == 'ipV6'    set suite variable     ${AMF}    6
        ...     ELSE      set suite variable     ${AMF}    0
	    ${served_amf}=    	Evaluate       ${operator}+${AMF}
    	Traffic capture start           capture_device=l2_wireshark 		alias=slice_${operator_str}_${IP_Version}
	    Attach UE with operator specific qci and send ul dl traffic      ${operator}
	    Stop traffic and detach UE          ${operator}
	 	${pcap_file}=       Traffic capture stop	  alias=slice_${operator_str}_${IP_Version}
	    Get AMF IP Address      ${served_amf}
	    Get NG-U IP Address     ${operator}           ${IP_Version}
	    ${ip_len}=      Evaluate      1000*${operator}
	    Analyse Pcap        pcap_filename=${pcap_file}        analysis=SA_call_ul_${IP_Version}      filter_file_name=${traffic_filter_file_name}
	    Analyse Pcap        pcap_filename=${pcap_file}        analysis=SA_call_dl_${IP_Version}      filter_file_name=${traffic_filter_file_name}
        Verifying shaping for each operator	   ${pcap_file}      ${IP_Version}
        Sleep    30
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

Attach UE with operator specific qci and send ul dl traffic
    [Arguments]          ${operator}
	${size}=      Evaluate      1000*${operator}
	Configure UE       5g=${profile}:data   command=ue_register  id=${operator}  profile=${operator}
    sleep  10
	Configure UE       5g=${profile}:data   command=set_pdu_param  ue=${operator}   pdu=${operator}  trf_type=internal
    sleep  10
    Configure UE       5g=${profile}:data   command=ue_pdu_session_setup  pdu=${operator}  ue=${operator}  nwslice=${operator}  gw=${operator}
    sleep  10
    Configure UE       5g=${profile}:data   command=trf_data_start  ue=${operator}  pdu=${operator}    qfi=1   dir=ul   mbps=175
    sleep  5
    Configure UE       5g=${profile}:data   command=trf_data_start  ue=${operator}  pdu=${operator}    qfi=1   dir=dl   mbps=175
    sleep  5

Stop traffic and detach UE
    [Arguments]          ${operator}
	Configure UE       5g=${profile}:data   command=ue_pdu_session_release  ue=${operator}    pdu=${operator}
    Sleep   50
    Configure UE       5g=${profile}:data   command=ue_deregister  id=${operator}  ue_deregister_type=switch_off
    Sleep   10


Verifying shaping for each operator
	[Arguments]          ${pcap_file}        ${IP_Version}
	Run Keyword If   '${IP_Version}' == 'ipV6'
	...   Run  tshark -r ${pcap_file} -Y "ipv6.src==${nguplane_ip}&&ipv6.dst==${amf_ip}&&gtp" -w ${EXECDIR}/ue_capture_${operator_str} 2>/dev/null
	...         ELSE
	...   Run  tshark -r ${pcap_file} -Y "ip.src==${nguplane_ip} && ip.dst==${amf_ip} && gtp" -w ${EXECDIR}/ue_capture_${operator_str} 2>/dev/null
	${data_rate_ul}=     Run  capinfos ${EXECDIR}/ue_capture_${operator_str} -i | tail -1 | awk '{ print $4 }'
	${data_rate}=     Remove String        ${data_rate_ul}     kbps
    ${data_rate}=     Remove String        ${data_rate}     ,
	${date_rate}=     Convert to Integer      ${data_rate}
	Get SIR value for each operator
	${tolerance_f}=     Evaluate     ${SIR_value} * 0.1
	${tolerance}=     Convert to Integer       ${tolerance_f}
    ${min_shaping_rate}=      Evaluate      ${SIR_value} - ${tolerance}
	${max_shaping_rate}=      Evaluate      ${SIR_value} + ${tolerance}
	Should Be True      ${data_rate}>${min_shaping_rate}
	Should Be True      ${data_rate}<${max_shaping_rate}

Get SIR value for each operator
	${FSTSCH_dict}=      Query Admin Infomodel     query=get object ${FSTSCH_path}-${operator_str}
    ${SIR_value}=       Get From Dictionary        ${FSTSCH_dict}    sir
	Set Suite Variable      ${SIR_value}        ${SIR_value}

Keyword to Run at end
    Run     sudo killall edaemon egate
	Run Keyword And Ignore Error         Traffic capture stop	  alias=slice_${operator_str}
    Run Keyword And Ignore Error         Stop traffic and detach UE         ${operator}