*** Settings ***
Documentation
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Funtion_Hash_Tags]     "5G,SA,NSA,Dualstack"
    ...     [Feature_ID]            "CB006944"
    ...     [Validation_status]     "Validated and Passed"
    ...     [Validated_TestLine]    "TL-3707"
    ...     [Config_Comment]    "TL-3707"

variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot

Suite Setup     Run Keywords    Suite Setup Preconditions
...             AND             Setup Oamops
Suite Teardown    Run Keywords    Suite Teardown Postconditions
...             AND             Teardown Oamops

***Variables***
${5GC000681_SA_SCF}=      ${CURDIR}/../../config/3910/scfc_files/Alpha_gNB3910_SA_On_AIR_Callsuccess.xml
${5g_dscp}=         10

***Test cases***
[1]5GC000681-B_003_Uplink_GTP-U_Transport_support_for_NG-U_Interface_with_dual_stack
	Perform Commissioning       scf_file=${5GC000681_SA_SCF}   verify_bts_status=True     timeout=600     alias=default

	Sleep	120

#	Read IPs Parameters

	Traffic Capture Start	capture_device=oam_device	mode=file	measurement_point=Transport_Interface	uplane_capturing=${True}	timeout=120
	Run Keyword And Continue On Failure	Make All Calls For Ul
	${filemode_capture}=	Traffic Capture Stop	mode=file	timeout=120
	Run		mv ${filemode_capture} execution_logs/calls_capture.gz
	Run		gunzip execution_logs/calls_capture.gz
	Run		mv execution_logs/calls_capture execution_logs/calls_capture.pcap


	Analyse Captured Packets For Ul

#	FOR	${Reset}	IN RANGE	1	5
#		Reset Bts
#		Verify Bts Status	req_rat=all		should_be_onair=${True}		timeout=600
#		Verify Alarm	expected_alarms=${expected_alarms}
#   ENd

	[Teardown]      End Processes

[1]5GC000681-B_003_Downlink_GTP-U_Transport_support_for_NG-U_Interface_with_dual_stack
#    Perform Commissioning       scf_file=${5GC000681_SA_SCF}   verify_bts_status=True     timeout=600     alias=default
#    Sleep   120

#   Read IPs Parameters
#    Traffic Capture Start   capture_device=oam_device   mode=file   measurement_point=Transport_Interface   uplane_capturing=${True}    timeout=120
#    Run Keyword And Continue On Failure		Make All Calls For Dl
#    ${filemode_capture}=    Traffic Capture Stop    mode=file   timeout=120
#    Run     mv ${filemode_capture} execution_logs/calls_capture.gz
#    Run     gunzip execution_logs/calls_capture.gz
#    Run     mv execution_logs/calls_capture execution_logs/calls_capture_dl.pcap


    Analyse Captured Packets For Dl

#   FOR    ${Reset}    IN RANGE    1   5
#      Reset Bts
#      Verify Bts Status   req_rat=all     should_be_onair=${True}     timeout=600
#      Verify Alarm    expected_alarms=${expected_alarms}
#   END

    [Teardown]      End Processes


*** Keywords ***
Read IPs Parameters
#    ${5g_ngc_src}=              Get Parameter   rat=lte     param_path=${5g_ngc_ip}:localIpAddr
#    ${5g_amf_dest}=             Get Parameter   rat=lte     param_path=${5g_amf_ip}     alias=default

	${5g_sa_cplane1} = 		    Get Parameter	rat=lte		param_path=${5g_sa_cplane1_ipv4_moc_path}:localIpAddr
	${5g_sa_amf} = 			    Get Parameter 	rat=lte 	param_path=${5g_sa_amf_path}
	${5g_dscp} = 				Get Parameter	rat=lte		param_path=${5g_dscp_value}
#	${wcdma_cplane1} = 			Get Parameter 	rat=wcdma 	param_path=${wcdma_cplane1_ipv4_moc_path}
#	${gsm_cplane1} = 			Get Parameter 	rat=gsm 	param_path=${gsm_cplane1_ipv4_moc_path}
#	${bsc_ipv4} = 				Get Parameter	rat=gsm		param_path=${gsm_bsc_ipv4_moc_path}
#	${updated_dscp} = 			Get Parameter	rat=lte		param_path=${cplane_dscp_moc_path}

	Set Suite Variable		${5g_sa_cplane1}
	Set Suite Variable		${5g_sa_amf}
	Set Suite Variable		${5g_dscp}
#	Set Suite Variable		${wcdma_cplane1}
#	Set Suite Variable		${gsm_cplane1}
#	Set Suite Variable		${bsc_ipv4}


Make All Calls For Ul
	Run Keyword And Continue On Failure	    Make 5G Call Ul

Make All Calls For Dl
    Run Keyword And Continue On Failure     Make 5G Call Dl


Make 5G Call Ul
	${UE_ip_value}=        Call Setup	5g=device_1:data	parallel=${False}	verify_attach=${False}
    ${UE_IP}=       Get From Dictionary     ${UE_ip_value}      key=5g:device_1:data
    Log to console       UE ip is ${UE_IP}
	Set Suite Variable      ${UE_IP}
    Call Start	5g=device_1:data		profile=5g_udp_ul
	Sleep	20
	Run Keyword And Ignore Error	Call Stop	5g=device_1:data		profile=5g_udp_ul

Make 5G Call Dl
    Call Setup  5g=device_1:data    parallel=${False}   verify_attach=${False}
    Call Start  5g=device_1:data        profile=5g_udp_dl
    Sleep   20
    Run Keyword And Ignore Error    Call Stop   5g=device_1:data        profile=5g_udp_dl

Teardown Calls
	Run Keyword And Ignore Error	Call Teardown	5g=device_1:data	parallel=${False}
	Run Keyword And Ignore Error	Call Teardown	lte=device_1:data	parallel=${False}
	Run Keyword And Ignore Error	Call Teardown	wcdma=device_1:data	parallel=${False}
	Run Keyword And Ignore Error	Call Teardown	gsm=device_1:voice	parallel=${False}
	Run Keyword And Ignore Error	Call Teardown	gsm=device_1:data	parallel=${False}

Analyse Captured Packets For Ul
	Analyse Pcap    analysis=verify_5G_msg_ul      pcap_filename=execution_logs/calls_capture.pcap
    Analyse Pcap	analysis=verify_5g_sa_call_ul       pcap_filename=execution_logs/calls_capture.pcap
    Analyse Pcap    analysis=verify_5g_sa_dscp_ul       pcap_filename=execution_logs/calls_capture.pcap
    Analyse Pcap    analysis=verify_5g_sa_dscp_nrdrb       pcap_filename=execution_logs/calls_capture.pcap
    ${rc}   ${stdout}   Run And Return Rc And Output    tshark -r execution_logs/calls_capture.pcap -Y "ip.src == ${UE_IP}" -T pdml 2>/tmp/stderr.txt
    Should Match Regexp    ${stdout}   (?i)Differentiated\\sServices\\sCodepoint:\\s(.*)(${5g_dscp})
#	Analyse Pcap	analysis=verify_wcdma_call	pcap_filename=execution_logs/calls_capture.pcap
#	Analyse Pcap	analysis=verify_gsm_call	pcap_filename=execution_logs/calls_capture.pcap
#	Analyse Pcap	analysis=verify_updated_cplane		pcap_filename=execution_logs/calls_capture.pcap

Analyse Captured Packets For Dl
    Analyse Pcap    analysis=verify_5G_msg_dl       pcap_filename=execution_logs/calls_capture.pcap
    Analyse Pcap    analysis=verify_5g_sa_call_dl       pcap_filename=execution_logs/calls_capture.pcap
    Analyse Pcap    analysis=verify_5g_sa_dscp_nrdrb       pcap_filename=execution_logs/calls_capture.pcap
    ${rc}   ${stdout}   Run And Return Rc And Output    tshark -r execution_logs/calls_capture.pcap -Y "ip.src == ${UE_IP}" -T pdml 2>/tmp/stderr.txt
    Should Match Regexp    ${stdout}   (?i)Differentiated\\sServices\\sCodepoint:\\s(.*)(${5g_dscp})

End Processes
	Run Keyword And Ignore Error	Traffic Capture Stop	mode=file	timeout=120
	Run Keyword And Ignore Error	Traffic Capture Stop    capture_device=bts_lo     timeout=180     alias=capture_bts_lo
	Run Keyword And Ignore Error	Teardown Calls
#	Teardown Ems  config_device=netact1  alias=default

