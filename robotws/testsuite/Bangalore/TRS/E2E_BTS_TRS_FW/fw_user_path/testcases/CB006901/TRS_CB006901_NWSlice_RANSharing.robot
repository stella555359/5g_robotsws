****Settings ***
Documentation
     ...    [Procedure] "The test case is planned to validate combination of 5G RAN Sharing and Network Slicing functionality"
     ...    [Date] "15-08-2021"
     ...    [Author] "Abhishek Gupta"
     ...    [QC_Path] "QC_Path in Test Plan"
     ...    [QC_ID] "QC_ID in Test Lab for reporting"
     ...    [Funtion_Hash_Tags] "Dualstack, UPlane, NW_Slice, 5G_RAN_Sharing"
     ...    [Feature_ID] "CB006901"
     ...    [Validation_status] "Validated and Passed"
     ...    [Validated_TestLine] ""
     ...    [Commissioning_comment] "This script requires DualStack configuration for LTE and NSA 5G Configuration with RAN Sharing
     ...    and Network Slice configured."
     ...    [Config]    "Second operator call is made with QCI-9 and NWSlice Traffic is sent over QCI-135 to QCI-154 with mcc:mnc as 234:76."

variables       ta_e2e_bts_trs_fw
Library         random
Resource        ${CURDIR}/../resources/common_keywords.robot

Suite Setup     Run Keywords     Suite Setup Preconditions
...    AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions
...    AND     Teardown Oamops

*** Test Cases ***
[1][1.0] CB006901_DualStack_for_NSA_Netwok_Slice_ASIL
    Perform Commissioning       scf_file=${cb006901_slice}   verify_bts_status=False     timeout=600
    Sleep   600
    Perform Recommissioning     type=param      rat=lte     param_path=MRBTS-1/MNL-1/MNLENT-1/FEATCADM-1:actFaultSignature   operation=update
    ...     value=true      timeout=600
    ${5g_ngu} =             Get Parameter   rat=common      param_path=${5g_ngu_ip_moc_path}
    Set Suite Variable  ${5g_ngu}       ${5g_ngu}
    ${5g_x2c} =             Get Parameter   rat=common      param_path=${5g_x2c_ip_moc_path}
    Set Suite Variable  ${5g_x2c}       ${5g_x2c}
    ${modified_dscp_value}=		Get Random DSCP Value
    Perform Recommissioning 	type=param	 param_path=${5g_cplane_dscp_moc_path}    value=${modified_dscp_value}
    ...	   skip_parameter_relation_errors=${True}    timeout=300   operation=update
    Traffic Capture Start    capture_device=bts_lo     timeout=180     alias=capture_bts_lo
    Call Setup     lte=device1_max_nwslice:data    parallel=${False}    attach=${False}	verify_attach=${false}    ipv4_or_6=ipv6
    ...	   timeout=600
    Make 5G Call
    ${lo_output_file}=       Traffic Capture Stop    capture_device=bts_lo     timeout=180     alias=capture_bts_lo
    Analyse Pcap    pcap_filename=${lo_output_file}   analysis=verify_5g_cplane_dscp    filter_file_name=traffic_filter.json

*** Keywords ***
Configure LMP IP Iterfaces
	Run	sh /home/ute/fw_user_path/testcases/CB006901/resources/interface_ip_conf.sh

Test run complete
	Run Keyword And Ignore Error	Call Teardown     lte=device1_max_nwslice:data
	Run Keyword And Ignore Error	Traffic Capture Stop    capture_device=lmp_pc_all_interface     timeout=180     alias=capture_5g
	Run Keyword And Ignore Error	Traffic Capture Stop    capture_device=bts_lo     timeout=180     alias=capture_bts_lo
	Run         sudo killall egate edaemon

Get parameter values
	@{5g_nsa_s1_uplane_ipv6_list}=	Create List
	@{5g_nsa_x2_cplane_ipv4_list}=	Create List

	${5g_nsa_nrbts_dict}=		Query Admin Infomodel		query=get list ${nrbts_moc_path}
	${5g_nsa_s1_uplane_ip_list}=	Get From Dictionary	dictionary=@{5g_nsa_nrbts_dict}[0]		key=${s1Uplane_param_name}

	FOR	${ip_dict}	IN	@{5g_nsa_s1_uplane_ip_list}
		${5g_nsa_s1_uplane_ipv6_dn}=	Get From Dictionary	dictionary=${ip_dict}	key=${ipV6AddressDN1_param_name}
		${ipv6}=			Get Parameter	param_path=${5g_nsa_s1_uplane_ipv6_dn}:${localIpAddr_param_name}
		Append To List	${5g_nsa_s1_uplane_ipv6_list}	${ipv6}
    END

	${second_opt_uplane}=	Set Variable	@{5g_nsa_s1_uplane_ipv6_list}[1]

	${5g_nsa_x2_cplane_ip_list}=	Get From Dictionary	dictionary=@{5g_nsa_nrbts_dict}[0]		key=${x2Cplane_param_name}
	FOR	${ip_dict}	IN	@{5g_nsa_x2_cplane_ip_list}
		${5g_nsa_x2_cplane_ipv4_dn}=	Get From Dictionary	dictionary=${ip_dict}	key=${ipV4AddressDN1_param_name}
		${ipv4}=			Get Parameter	param_path=${5g_nsa_x2_cplane_ipv4_dn}:${localIpAddr_param_name}
		Append To List	${5g_nsa_x2_cplane_ipv4_list}	${ipv4}
    END

	${5g_nsa_x2_cplane_ipv4}=		Set Variable	@{5g_nsa_x2_cplane_ipv4_list}[0]

	${qci9_nrdrb_qci_moc}=		Query Admin Infomodel		query=get object ${nrdrb_qci_moc_path} is [qciValueList[?]=9]
	${qci9_dscp}=			Get Parameter	param_path=${qci9_nrdrb_qci_moc['dist_name']}:${nrdrb_dscp_moc_path}

	Set Suite Variable       ${5g_nsa_x2_cplane_ipv4}
	Set Suite Variable       ${second_opt_uplane}
	Set Suite Variable       ${qci9_dscp}

Get Random DSCP Value
	${min_dscp_value}=	Convert to Integer    1
	${max_dscp_value}=	Convert to Integer    63
	${mplane_modified_dscp_value}=	random.randint    ${min_dscp_value}	${max_dscp_value}
	${mplane_modified_dscp_value_string}=	Convert to String    ${mplane_modified_dscp_value}
	${type} =    Evaluate    type($mplane_modified_dscp_value_string).__name__
	Set Suite Variable       ${mplane_modified_dscp_value_string}
	[Return]	${mplane_modified_dscp_value_string}

Make 5G Call
    Configure UE    lte=device1_max_nwslice:data     command=ue_attach id=1 enb=1 cell=11 selected_plmn=234:77 scg_ul_dist_percent=100
    Sleep   5
    Configure UE    lte=device1_max_nwslice:data     command=ue_measurement_send event=B1_NR id=1 phycell_id=50 srsrp=97 srsrq=34
    ...     nrsrp=97 nrsrq=30 nsinr=0
    Sleep   5
    Configure UE    lte=device1_max_nwslice:data     command=trf_data_start ue=1 dir=dl_and_ul protocol=udp Mbps_ul=10 Mbps_dl=10 stats=true
    Sleep   5
    Configure UE    lte=device1_max_nwslice:data     command=trf_data_stop ue=1
    Sleep   5
    Configure UE    lte=device1_max_nwslice:data     command=ue_detach id=1
    Sleep   10
    FOR	    ${ue_id}	IN RANGE	21	41
        Traffic Capture Start    capture_device=lmp_pc_all_interface    timeout=180    alias=capture_5g_${ue_id}
        Execute Cmd On Egate       lte=device1_max_nwslice:data        cmd=ue_mme_param id=${ue_id} sgw_id=2
        Sleep   5
        Execute Cmd On Egate       lte=device1_max_nwslice:data        cmd=ue_sgw_param id=${ue_id} s1u_preferred_ip_ver=v6
        Sleep    5
	Configure UE    lte=device1_max_nwslice:data     command=ue_attach id=${ue_id} enb=1 cell=11 selected_plmn=234:76 scg_ul_dist_percent=100
	Sleep	5
	Configure UE    lte=device1_max_nwslice:data     command=bearer_add ue=${ue_id} qci=${qci_id}
	Sleep	5
	Configure UE    lte=device1_max_nwslice:data     command=ue_measurement_send event=B1_NR id=${ue_id} phycell_id=50 srsrp=97 srsrq=34
        ...     nrsrp=97 nrsrq=30 nsinr=0
        Sleep	5
	Configure UE    lte=device1_max_nwslice:data     command=trf_data_start ue=${ue_id} dir=dl_and_ul protocol=udp Mbps_ul=10 Mbps_dl=10
        ...     stats=true qci=${qci_id}
	Sleep	10
        Configure UE    lte=device1_max_nwslice:data     command=trf_data_stop ue=${ue_id}
        Sleep   3
        Configure UE    lte=device1_max_nwslice:data     command=ue_detach id=${ue_id}
        Sleep   3
        ${lmp_output_file}=       Traffic Capture Stop    capture_device=lmp_pc_all_interface     timeout=180     alias=capture_5g_${ue_id}
        ${qci_nwslice_moc}=     Query Admin Infomodel       query=get object ${qci_nsa_nwslice_moc} is [operatorSpecificQCIList[?]=${qci_id}]
        ${qci_nwslice_uplane1}=     Get Parameter   param_path=${qci_nwslice_moc['dist_name']}:${qci_nsa_nwslice_uplane1_ipv6_moc_path}
        Set Suite Variable       ${qci_nwslice_uplane1}
        Analyse Pcap    pcap_filename=${lmp_output_file}   analysis=verify_5g_multiple_nwslice_uplane_dscp    filter_file_name=traffic_filter.json
        Convert To Integer  ${qci_id}
        ${qci_id}=  Evaluate    int(${qci_id}) + int(1)
        Set Variable    ${qci_id}
    END

Verify Multiple NwSlice Dscp
        ${qci_value}    138
        ${qci_nrdrb_qci_moc}=   Query Admin Infomodel       query=get object ${nrdrb_qci_moc_path} is [qciValueList[?]=${qci_value}]
        ${qci_dscp}=        Get Parameter   param_path=${qci_nrdrb_qci_moc['dist_name']}:${nrdrb_dscp_moc_path}
        ${qci_nwslice_moc}=     Query Admin Infomodel       query=get object ${qci_nsa_nwslice_moc} is [operatorSpecificQCIList[?]=${qci_value}]
        ${qci_nwslice_uplane1}=     Get Parameter   param_path=${qci_nwslice_moc['dist_name']}:${qci_nsa_nwslice_uplane1_ipv6_moc_path}
        Set Suite Variable       ${qci_dscp}
        Set Suite Variable       ${qci_nwslice_uplane1}
        Analyse Pcap    pcap_filename=${lmp_output_file}   analysis=verify_5g_multiple_nwslice_uplane_dscp    filter_file_name=traffic_filter.json

Verify Multiple NwSlice Dscp backup
	FOR	${qci_value}	IN RANGE	135	154
		${qci_nrdrb_qci_moc}= 	Query Admin Infomodel		query=get object ${nrdrb_qci_moc_path} is [qciValueList[?]=${qci_value}]
		${qci_dscp}=		Get Parameter	param_path=${qci_nrdrb_qci_moc['dist_name']}:${nrdrb_dscp_moc_path}
		${qci_nwslice_moc}= 	Query Admin Infomodel		query=get object ${qci_nsa_nwslice_moc} is
                ...    [operatorSpecificQCIList[?]=${qci_value}]
		${qci_nwslice_uplane1}=		Get Parameter
                ...    param_path=${qci_nwslice_moc['dist_name']}:${qci_nsa_nwslice_uplane1_ipv6_moc_path}
		Set Suite Variable       ${qci_dscp}
		Set Suite Variable       ${qci_nwslice_uplane1}
        Analyse Pcap    pcap_filename=${lmp_output_file}   analysis=verify_5g_multiple_nwslice_uplane_dscp    filter_file_name=traffic_filter.json
    END