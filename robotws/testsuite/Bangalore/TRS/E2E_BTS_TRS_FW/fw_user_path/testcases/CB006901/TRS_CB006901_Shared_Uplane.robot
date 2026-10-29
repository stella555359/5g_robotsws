****Settings ***
Documentation
     ...    [Procedure] "The test case is planned to validate Backup Ipsec Automatic switchover and switchback functionality"
     ...    [Date] "19-07-2021"
     ...    [Author] "Abhishek Gupta"
     ...    [QC_Path] "QC_Path in Test Plan"
     ...    [QC_ID] "QC_ID in Test Lab for reporting"
     ...    [Funtion_Hash_Tags] "Dualstack, UPlane"
     ...    [Feature_ID] "CB006901"
     ...    [Validation_status] "Validated and Passed"
     ...    [Validated_TestLine] ""
     ...    [Commissioning_comment] "The commissioning for this case is to enable 5GC000267 configuration on gNB 5gc000267_config.xml"
     ...    [Config]    "This script requires both IPV4 and IPV6 address with Plain configuration & contains 4 IKEP profiles , 2
     ...    IKE protection group , 2 Security policies "


variables       ta_e2e_bts_trs_fw
Library         random
Resource        ${CURDIR}/../resources/common_keywords.robot

Suite Setup     Run Keywords     Suite Setup Preconditions
...    AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions
...    AND     Teardown Oamops

*** Test Cases ***
[1][1.0] CB006901_DualStack_Shared_Uplane_IP_Addr_on_SBTS_Auto
    Perform Commissioning       scf_file=${cb006901_uplane}   verify_bts_status=False     timeout=600
    Sleep	60
    Perform Recommissioning     type=param      rat=lte     param_path=MRBTS-1/MNL-1/MNLENT-1/FEATCADM-1:actFaultSignature
    ...   operation=update     value=true      timeout=600
    ${modified_dscp_value}=	Get Random DSCP Value
    Perform Recommissioning 	type=param	 param_path=${5g_uplane_dscp_moc_path}    value=${modified_dscp_value}
    ...	  skip_parameter_relation_errors=${True}	timeout=300   operation=update
    Sleep   60
    Traffic Capture Start    capture_device=lmp_pc_all_interface     timeout=180     alias=capture_5g
    Call Setup     lte=device1_dualstack_eda:data    parallel=${False}    attach=${False}	verify_attach=${false}
    ...    ipv4_or_6=ipv6    timeout=600
    Block    operation=Cell    rat=NR
    Sleep    120
    Unblock    operation=Cell    rat=NR
    Sleep    60
    Make 5G Call
    ${output_file}=       Traffic Capture Stop    capture_device=lmp_pc_all_interface     timeout=180     alias=capture_5g
    @{5g_call_teid_list}=   Analyse Pcap    pcap_filename=${output_file}   analysis=get_5g_teid    filter_file_name=traffic_filter.json
    Should not be Empty    ${5g_call_teid_list}
    Match Eighth Bit For Teid	teid_dict_list=${5g_call_teid_list}	value_to_compare=1
    ${gtp}=   Analyse Pcap    pcap_filename=${output_file}   analysis=verify_uplink_traffic    filter_file_name=traffic_filter.json
    Should not be equal as integers    ${gtp}    0

*** Keywords ***
Configure LMP IP Iterfaces
	Run	sh /home/ute/fw_user_path/testcases/CB006901/resources/interface_ip_conf.sh

Test run complete
	Run Keyword And Ignore Error	Call Teardown     5g=device1_dualstack_eda:data
	Run Keyword And Ignore Error	Traffic Capture Stop    capture_device=lmp_pc_all_interface     timeout=180     alias=capture_5g
    Run Keyword And Ignore Error   Call Teardown     5g=device1_dualstack_eda:data

Get parameter values
	${5g_nsa_uplane_ip}=      Get Parameter      param_path=${5g_nsa_uplane1_ipv6_moc_path}
	Set Suite Variable       ${5g_nsa_uplane_ip}

Get Random DSCP Value
	${min_dscp_value}=	Convert to Integer    1
	${max_dscp_value}=	Convert to Integer    63
	${mplane_modified_dscp_value}=	random.randint    ${min_dscp_value}	${max_dscp_value}
	${mplane_modified_dscp_value_string}=	Convert to String    ${mplane_modified_dscp_value}
	${type} =    Evaluate    type($mplane_modified_dscp_value_string).__name__
	Set Suite Variable       ${mplane_modified_dscp_value_string}
	[Return]	${mplane_modified_dscp_value_string}

Make 5G Call
    Execute Cmd On Egate    lte=device1_dualstack_eda:data    cmd=ue_mme_param id=1 sgw_id=2
    Sleep   5
    Execute Cmd On Egate    lte=device1_dualstack_eda:data    cmd=ue_sgw_param id=1 s1u_preferred_ip_ver=v6
    Sleep   5
    Configure UE       lte=device1_dualstack_eda:data    command=ue_attach id=1 enb=1 cell=11 selected_plmn=234:77 scg_ul_dist_percent=100
    Sleep	5
    Configure UE       lte=device1_dualstack_eda:data    command=ue_measurement_send event=B1_NR id=1 phycell_id=50 srsrp=97 srsrq=34 nrsrp=97
    ...    nrsrq=30 nsinr=0
    Sleep   5
    Configure UE       lte=device1_dualstack_eda:data    command=trf_data_start ue=1 dir=dl_and_ul protocol=udp Mbps_ul=10 Mbps_dl=10 stats=true
    Sleep   60
    Configure UE       lte=device1_dualstack_eda:data    command=ue_detach id=1

Match Eighth Bit For Teid
	[Arguments]	${teid_dict_list}	${value_to_compare}
    FOR    ${output_dict}    IN    @{teid_dict_list}
	${teid}=	Get From Dictionary	dictionary=${output_dict}		key=gtp.teid
        ${teid_hex}=    Convert To Hex      ${teid}[0]
	${binary_teid}=		Convert To Binary	${teid_hex}		base=16
        ${binary_teid}=     Convert to List    ${binary_teid}
        ${5g_teid_eighth_bit}=  Get From List   ${binary_teid}  -9
	Should Be Equal		'${5g_teid_eighth_bit}'		'${value_to_compare}'
    END

Make 5G Call for verification
      Configure UE       5g=device1_dualstack_eda:data	command=ue_attach  id=11
	Sleep	5
	Configure UE       5g=device1_dualstack_eda:data	command=enb_ue_dc_start  ue=11  target_gnb=2  target_cells=1  bearer=3
        ...    type=split_scg
	Sleep	5
	Configure UE       5g=device1_dualstack_eda:data	command=trf_data_start  ue=11  id=3  dir=ul  trf_id=3  mbps=1
	Sleep	5
	Configure UE       5g=device1_dualstack_eda:data	command=trf_data_start  ue=11  id=3  dir=dl  trf_id=4  mbps=1
	Sleep    30
	Configure UE       5g=device1_dualstack_eda:data	command=trf_data_stop  ue=11  id=3  dir=ul  trf_id=3
	Sleep	5
	Configure UE       5g=device1_dualstack_eda:data	command=trf_data_stop  ue=11  id=3  dir=dl  trf_id=4
	Sleep	5

Analyse Wireshark for Call Setup Failure
        Analyse pcap    pcap_filename=${output_file}      analysis=verify_call_setup_failure       filter_file_name=traffic_filter.json

Verify no Diagnostic alarm
        Verify Alarm faultid=6450    should_exist=${False}

Verify wireshark for gtp traffic
     ${gtp}=   Analyse Pcap    pcap_filename=${output_file}   analysis=verify_uplink_traffic    filter_file_name=traffic_filter.json
     Should not be Equal    ${gtp}    0