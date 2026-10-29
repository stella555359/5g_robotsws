*** Settings ***
Documentation
...		[Author]     		        "Hrudya V N"
...		[Maintenance]		        "TRS I&V Tools Bangalore Team"
...		[Date] 			            "19:05:2021"
...		[QC_Path]                   "QC_Path in Test Plan"
...		[QC_ID]			            "QC_ID in Test Lab for reporting"
...		[Feature_ID] 		        "RP002688"
...     [Validated_TestLine]        "KVM53-TRSIV-TL006"
...		[Procedure]       "TRS_RPP002688_SRAN_TRS_Configure_Dual_stack_with_SA_mode_Configure_dedicated_IP_for_NG-U/C_and_Xn-U/C_interface"
...     [Precondition]              "ASIB + ASIB hardware is required"
...     [Config_Comments]           "Shared VLAN NG-U NG-C Xn-U and Xn-C IPs for 6 Operators_IPv4"
...     [Function_Hash_Tags]        "SA 6 Operator RAN Sharing, Dual Stack, verify 6 operator call with Airphone"

variables       ta_e2e_bts_trs_fw
Resource    	${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
Resource        ${CURDIR}/../resources/admin_oam_common_keywords.robot
Resource        ${CURDIR}/resources/CB009131_common_keywords.robot

Suite Setup		Run Keywords	Suite Setup Preconditions
...		AND		Setup Oamops
Suite Teardown	Run Keywords	Suite Teardown Postconditions
...		AND		Teardown Oamops

***Test Cases***
[1][1.0] TRS_CB009131_Online_Addition_Modification_Deletion_X2C_Trusted_Peers_with_NSA_RanSharing

    Run Keyword And Ignore Error  Perform Commissioning       scf_file=${ransharing_scf}   verify_bts_status=False     timeout=600
    Sleep   300
    Perform Recommissioning         type=param       param_path=${actDynamicFirewall_param_path}    value=true     timeout=300   operation=update
    Run     sudo killall egate edaemon
    Sleep    10
    Call Setup      5g=CB009131_6operator_dynfw:data   parallel=${False}    verify_attach=${False}   attach=${False}    timeout=600
    Make NSA Call and Verify for 2 Operator      ipV4       CB009131_6operator_dynfw
    Verify Alarm    expected_alarms=${expected_alarms}
#Modify x2link trust
    Sleep   60
    Perform Recommissioning        type=delta             delta_file=${modify_x2linktrust}          timeout=600
    Run     sudo killall egate edaemon
    Sleep   10
    Call Setup      5g=CB009131_6operator_dynfw_modify:data   parallel=${False}    verify_attach=${False}   attach=${False}    timeout=600
    Make NSA Call and Verify for 6 Operator      ipV4       profile=CB009131_6operator_dynfw_modify
     Perform Recommissioning         type=param       param_path=${ipfiltering}    value=5min    timeout=300   operation=update
     ${x2_v4_cplane}=       Get Parameter   param_path=${x2_cplane_v4_moc_path}
     Set Suite Variable       ${x2_v4_cplane}       ${x2_v4_cplane}
#     PM Counters Start               analysis=verify_ingress_packet_filter_drop         counter_analysis_file=${counter_analysis_file_name}
    ...    pm_interval=5
     PM Counters Start    analysis=verify_ingress_packet_filter_drop    counter_analysis_file=${counter_analysis_file_name}    pm_interval=5
     Send Packet From Unknown Source    ip_version=ipv4     profile1=unknown_x2ap_src_packets_ipv4
     Sleep   300
     Verify PM Counters      analysis=verify_ingress_packet_filter_drop    counter_analysis_file=${counter_analysis_file_name}     pm_interval=5

#Delete X2linktrust
    ${x2_v4_cplane_ip_modify}=       Get Parameter   param_path=${x2_cplane_v4_moc_path}
     Set Suite Variable       ${x2_v4_cplane_ip_modify}       ${x2_v4_cplane_ip_modify}
    Sleep   100
    Perform Recommissioning        type=delta      delta_file=${delete_x2linktrust}     timeout=600     skip_parameter_relation_errors=${True}

#verify counter for traffic from unknown source
    PM Counters Start    analysis=verify_ingress_packet_filter_drop    counter_analysis_file=${counter_analysis_file_name}     pm_interval=5
#    PM Counters Start               analysis=verify_ingress_packet_filter_drop          counter_analysis_file=${counter_analysis_file_name}
    ...    pm_interval=5
    Send Packet From Unknown Source        ip_version=ipv4     profile1=unknown_x2ap_src_packets_ipv4_modify
    Sleep   300
    Verify PM Counters              analysis=verify_ingress_packet_filter_drop          counter_analysis_file=${counter_analysis_file_name}
    ...    pm_interval=5
    Run     sudo killall egate edaemon
   [TEARDOWN]    Test run complete