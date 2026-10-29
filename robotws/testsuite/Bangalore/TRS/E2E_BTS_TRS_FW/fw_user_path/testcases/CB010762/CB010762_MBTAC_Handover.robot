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
${profile3}	      LTE10762_10op_Handover
${profile4}	      LTE10762_10op_MBTAC

*** Test Cases ***
[1]CB010762-A_B1_Feature_with_10_operators_Handover_444_and_666_Handover_TAC_check_for_all_operators
	Perform Commissioning       scf_file=${basic_6op}    verify_bts_status=False     timeout=400
  	Sleep       180
	Perform Recommissioning     type=delta      delta_file=${10op_CB010762}     timeout=300
	Sleep   120
	Get IPv4 Address
	Get IPv6 Address
	Add IPv4 and IPv6 Interfaces on VM
	Call Setup      lte=${profile}:data   parallel=${False}    verify_attach=${False}    attach=${False}
	Sleep    80
   	Verify S1 link status
	Sleep   60
	Configure and verify MBTAC
	Verify Counters for MBTAC
	Configure and verify Handover
	Verify Counters

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

Add IPv4 and IPv6 Interfaces on VM
	Delete Interfaces
	Run		sh interfaces.sh

Randomize Additional operators
	[Arguments]		${start}	${End}
    ${operators}=         Evaluate    random.sample(range(${start}, ${End}), 1)    random
    Set Suite Variable      ${operators}        ${operators}

Keyword to Run at end
    Call Teardown         lte=${profile}:data
    Run     sudo killall edaemon egate uexgate

Configure and verify MBTAC
	Attach Multiple UEs for low TAC threshold with default qci		11		1-2		100		1000
	Attach Multiple UEs for low TAC threshold with default qci		12		7-8		100		1000
	Attach Multiple UEs for high TAC threshold with default qci		11		12		13		1-100
	UE with qci67 bearer establishment should fail		1		11		100		1		${plmn}
	Attach UE and establish dedicated qci67 bearer		${ue_id}	11	100   ${ue_id}	${plmn}
	Verify dedicated bearer QCI establishment is successful with default qci	67		2		${ue_id}	11		100

Attach Multiple UEs for low TAC threshold with default qci
	[Arguments]    	${cell}		${ue_id}	${gbr}		${kbps}
	Perform Recommissioning		type=delta	delta_file=${low_preemption} skip_parameter_relation_errors=${True}	 timeout=300
	Sleep 	50
	Configure UE    lte=${profile4}:data        command=ue_attach id=${ue_id} cell=${cell}
    Configure UE    lte=${profile4}:data        command=bearer_add ue=${ue_id} qci=2 gbr_dl=${gbr} gbr_ul=${gbr} mbr_dl=${gbr} mbr_ul=${gbr}
    Configure UE    lte=${profile4}:data        command=trf_data_start ue=${ue_id} qci=2 dir=ul kbps=${kbps} protocol=udp
    Sleep   5
    Configure UE    lte=${profile4}:data        command=bearer_add ue=${ue_id} qci=3 gbr_dl=${gbr} gbr_ul=${gbr} mbr_dl=${gbr} mbr_ul=${gbr}
    Configure UE    lte=${profile4}:data        command=trf_data_start ue=${ue_id} qci=3 dir=ul kbps=${kbps} protocol=udp
    Sleep   5
    Configure UE    lte=${profile4}:data        command=bearer_add ue=${ue_id} qci=4 gbr_dl=${gbr} gbr_ul=${gbr} mbr_dl=${gbr} mbr_ul=${gbr}
    Configure UE    lte=${profile4}:data        command=trf_data_start ue=${ue_id} qci=4 dir=ul kbps=${kbps} protocol=udp
    Sleep   5

Attach Multiple UEs for high TAC threshold with default qci
	[Arguments]    	${cell}		${cell2}		${cell3}	${ue_id}	${gbr}=10	${kbps}=50
	Perform Recommissioning		type=delta	delta_file=${high_preemption} skip_parameter_relation_errors=${True}	timeout=300
	Sleep 	50
	Configure UE    lte=${profile4}:data        command=ue_attach id=1-15 cell=${cell}
    Configure UE    lte=${profile4}:data        command=ue_attach id=16-30 cell=${cell2}
    Configure UE    lte=${profile4}:data        command=ue_attach id=31-47 cell=${cell3}
    Configure UE    lte=${profile4}:data        command=ue_attach id=48-60 cell=${cell}
    Configure UE    lte=${profile4}:data        command=ue_attach id=61-80 cell=${cell2}
    Configure UE    lte=${profile4}:data        command=ue_attach id=81-100 cell=${cell3}
    Sleep   5
    Configure UE    lte=${profile4}:data        command=bearer_add ue=${ue_id} qci=2 gbr_dl=${gbr} gbr_ul=${gbr} mbr_dl=${gbr} mbr_ul=${gbr}
    Configure UE    lte=${profile4}:data        command=trf_data_start ue=${ue_id} qci=2 dir=ul kbps=${kbps} protocol=udp
    Sleep   10
    Configure UE    lte=${profile4}:data        command=bearer_add ue=${ue_id} qci=3 gbr_dl=${gbr} gbr_ul=${gbr} mbr_dl=${gbr} mbr_ul=${gbr}
    Configure UE    lte=${profile4}:data        command=trf_data_start ue=${ue_id} qci=3 dir=ul kbps=${kbps} protocol=udp
    Sleep   10
    Configure UE    lte=${profile4}:data        command=bearer_add ue=${ue_id} qci=4 gbr_dl=${gbr} gbr_ul=${gbr} mbr_dl=${gbr} mbr_ul=${gbr}
    Configure UE    lte=${profile4}:data        command=trf_data_start ue=${ue_id} qci=4 dir=ul kbps=${kbps} protocol=udp

UE with qci67 bearer establishment should fail
	[Arguments]       ${ue_id}     ${cell_id}  ${bit_rate}   ${sgw_id}   ${plmn}
	Log     ${bit_rate}
    Traffic Capture Start   capture_device=vm_eth3_interface
    Execute cmd on egate      lte=${profile4}:data    cmd=ue_mme_param id=${ue_id} sgw_id=${sgw_id}   timeout=60
    sleep    2
    Configure UE        lte=${profile4}:data        command=ue_attach id=${ue_id} cell=${cell_id} selected_plmn=${plmn}
    [Documentation]    using run keyword and expect error since the qci67 bearer establishment has to fail with CB006274 feature flag disabled.
	Run Keyword and Expect error 		*sErrBearerAllocationReject*  Configure UE	 lte=${profile4}:data 	command=bearer_add ue=${ue_id} 	qci=67
    Sleep    5
    ${pcap_file}=       Traffic Capture Stop
    Analyse_pcap    pcap_filename=${pcap_file}  analysis=qci67_invalid_qos   filter_file_name=${CB006274_trf_filter}
    Stop traffic and detach LTE UE          ${operator}      ${profile4}

Attach UE and establish dedicated qci67 bearer
    [Arguments]       ${ue_id}     ${cell_id}   ${bit_rate}   ${sgw_id}   ${plmn}
    Execute cmd on egate      lte=${profile4}:data    cmd=ue_mme_param id=${ue_id} sgw_id=${sgw_id}   timeout=60
    sleep    2
    Configure UE        lte=${profile4}:data    command=ue_attach id=${ue_id} cell=${cell_id} selected_plmn=${plmn}
    Configure UE   lte=${profile4}:data    command=bearer_add ue=${ue_id} qci=67 gbr_ul=${bit_rate} gbr_dl=${bit_rate}  mbr_ul=${bit_rate}
    Sleep    5

Verify dedicated bearer QCI establishment is successful with default qci
    [Arguments]        ${ded_qci}    ${def_qci}    ${ue_id}     ${cell_id}   ${bit_rate}
    Log      ${def_qci}
    Traffic Capture Start   capture_device=vm_eth3_interface
    Execute cmd on egate      lte=${profile4}:data    cmd=ue_mme_param id=${ue_id} sgw_id=${sgw_id}   timeout=60
    sleep    2
    Configure UE        lte=${profile4}:data    command=ue_attach id=${ue_id} cell=${cell_id} selected_plmn=${plmn}
    Configure UE        lte=${profile4}:data    command=bearer_add ue=${ue_id} qci=${ded_qci} gbr_ul=${bit_rate} gbr_dl=${bit_rate}
    Configure UE    lte=${profile4}:data   command=trf_data_start ue=${ue_id} qci=${ded_qci} dir=dl_and_ul Mbps_dl=${dl_data} Mbps_ul=${ul_data}
    Sleep    5
    ${pcap_file}=       Traffic Capture Stop
    Set Suite Variable   ${ded_qci}
    Set Suite Variable   ${dscp}    ${qci_${ded_qci}_dscp}
    Analyse_pcap    pcap_filename=${pcap_file}  analysis=erab_setup_req   filter_file_name=${CB006274_trf_filter}
    Analyse_pcap    pcap_filename=${pcap_file}  analysis=erab_setup_resp   filter_file_name=${CB006274_trf_filter}
    Analyse_pcap    pcap_filename=${pcap_file}  analysis=ul_data_verification   filter_file_name=${CB006274_trf_filter}

Verify Counters for MBTAC
	Pm Counters Start		analysis=verify_tacSuccessfulGbrNormal		counter_analysis_file=${counter_analysis_file_name}
	Verify Pm Counters 		analysis=verify_tacSuccessfulGbrNormal		 counter_analysis_file=${counter_analysis_file_name}

Configure and verify Handover
	Perform Recommissioning		type=delta		delta_file=${HO_delta}		skip_parameter_relation_errors=${True}		timeout=300
	Sleep 	50
	Call Setup      lte=${profile3}:data   parallel=${False}    verify_attach=${False}    attach=${False}
	Sleep    80
	Verify X2 link status
	Randomize Additional operators			1		6
	Make LTE call and verify for each operators for Handover			${cell_HO}
	Randomize Additional operators			7		10
   	Make LTE call and verify for each operators for Handover			${cell_HO}
	Call Teardown         lte=${profile3}:data
	Run     sudo killall edaemon egate uexgate

Make LTE call and verify for each operators for Handover
    [Arguments]    	${cell_HO}
    Log      ${cell_HO}
	${sgw_id}=          Set Variable            ${sgwid}
   	${QCIid}=             Set Variable            ${QCIid}
	FOR  ${operator}   IN   @{operators}
		${index}= 		Evaluate	${operator}-1
	    ${operator_str}= 	Convert To String	${operator}
		Traffic capture start           capture_device=l2_wireshark 		alias=operator_${operator_str}
	    Attach LTE UE with operator and send ul dl traffic for Handover     ${operator}      ${profile3}	     ${cell}
		Verify Alarm		faultid=${gtpu_alarm}	 	occurrences=${0}		should_exist=${False}
		Verify Alarm		faultid=${s1_interface}	 	occurrences=${0}		should_exist=${False}
	    Stop traffic and detach LTE UE          ${operator}      ${profile3}
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
	    Analyse Pcap      pcap_filename=${pcap_file}      analysis=lte_call_HO_${version}        filter_file_name=${traffic_filter_file_name}
	END
	[TEARDOWN]   Run Keyword and Ignore Error     Traffic capture stop	  alias=operator_${operator_str}

Verify Counters
	Pm Counters Start		analysis=IPIF_counters_multiple_slice		counter_analysis_file=${counter_analysis_file_name}
	Verify Pm Counters 		analysis=IPIF_counters_multiple_slice		 counter_analysis_file=${counter_analysis_file_name}
