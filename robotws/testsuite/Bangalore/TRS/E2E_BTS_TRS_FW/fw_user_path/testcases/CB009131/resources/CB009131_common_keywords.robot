*** Settings ***
Documentation
...     [Author]                    "Hrudya V N"
...     [Maintenance]               "TRS I&V Tools Bangalore Team"
...     [Date]                      "19:05:2021"
...     [QC_Path]                   "QC_Path in Test Plan"
...     [QC_ID]                     "QC_ID in Test Lab for reporting"
...     [Feature_ID]                "RP002688"
...     [Validated_TestLine]        "KVM53-TRSIV-TL006"
...     [Procedure]       "TRS_RPP002688_SRAN_TRS_Configure_Dual_stack_with_SA_mode_Configure_dedicated_IP_for_NG-U/C_and_Xn-U/C_interface"
...     [Precondition]              "ASIB + ASIB hardware is required"
...     [Config_Comments]           "Shared VLAN NG-U NG-C Xn-U and Xn-C IPs for 6 Operators_IPv4"
...     [Function_Hash_Tags]        "SA 6 Operator RAN Sharing, Dual Stack, verify 6 operator call with Airphone"

Variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../../resources/common_keywords.robot
Resource        ${CURDIR}/../../resources/Admin_Common_Library.robot

*** Variables ***
@{5g_nsa_nrbts_dict}

*** Keywords ***
Configure LMP IP Iterfaces
        Run     sh /home/ute/fw_user_path/testcases/CB001049/resources/interface_ip_conf.sh

Test run complete
        Run Keyword And Ignore Error    Call Teardown     5g=CB009131_6operator_dynfw_modify:data
        Run         sudo killall egate edaemon

Verify Alarms
    Download Alarm File from eNB

Download Alarm File from eNB
    ${alarms}=      Get Active Alarms
    Set Suite Variable      ${Active_alarms}        ${alarms}
    @{SEM_alarms}=      Create List
    ${Dict}=    Create Dictionary
    ${len}=     Get Length      ${Active_alarms}
    :FOR    ${i}    IN RANGE    0   ${len}
    \       Log Dictionary      @{alarms}[${i}]
    \       ${val}=     Get From Dictionary     @{alarms}[${i}]     faultId
    \       Append To List      ${SEM_alarms}       ${val}
    \       Set To Dictionary   ${Dict}     ${i}    ${val}

    Set Suite Variable      ${SEM_alarms}       ${SEM_alarms}
    Log     ${SEM_alarms}}
    Set Suite Variable      ${Dict}     ${Dict}
    Log     ${Dict}

Read parameter values
        ${lte_v4_cplane_ip}=       Get Parameter   param_path=${lte_cplane_v4_moc_path}
        Set Suite Variable       ${lte_v4_cplane_ip}
        ${lte_v6_cplane_ip}=       Get Parameter   param_path=${lte_cplane_v6_moc_path}
        Set Suite Variable       ${lte_v6_cplane_ip}
        ${lte_v4_uplane_ip}=       Get Parameter   param_path=${lte_uplane_v4_moc_path}
        Set Suite Variable       ${lte_v4_uplane_ip}
        ${lte_v6_uplane_ip}=       Get Parameter   param_path=${lte_uplane_v6_moc_path}
        Set Suite Variable       ${lte_v6_uplane_ip}
#        ${lte_v4_cplane_ip_neigh}=       Get Parameter   param_path=${lte_cplane_v4_moc_path}     alias=remote
#        Set Suite Variable       ${lte_v4_cplane_ip_neigh}
#        ${lte_v6_cplane_ip_neigh}=       Get Parameter   param_path=${lte_cplane_v6_moc_path}      alias=remote
#        Set Suite Variable       ${lte_v6_cplane_ip_neigh}
#        ${lte_v4_uplane_ip_neigh}=     Get Parameter   param_path=${lte_uplane_v4_moc_path}     alias=remote
#        Set Suite Variable       ${lte_v4_uplane_ip_neigh}
#        ${lte_v6_uplane_ip_neigh}=     Get Parameter   param_path=${lte_uplane_v6_moc_path}       alias=remote
#        Set Suite Variable       ${lte_v6_uplane_ip_neigh}
        ${x2_v4_cplane_ip}=       Get Parameter   param_path=${x2_cplane_v4_moc_path}
        Set Suite Variable       ${5g_nsa_x2_cplane_ipv4}       ${x2_v4_cplane_ip}
        ${x2_v6_cplane_ip}=       Get Parameter   param_path=${x2_cplane_v6_moc_path}
        Set Suite Variable       ${5g_nsa_x2_cplane_ipv6}        ${x2_v6_cplane_ip}
#        ${x2_v4_uplane_ip}=       Get Parameter   param_path=${x2_uplane_v4_moc_path}       alias=remote
#        Set Suite Variable       ${x2_v4_uplane_ip}
#        ${x2_v6_uplane_ip}=       Get Parameter   param_path=${x2_uplane_v6_moc_path}       alias=remote
#        Set Suite Variable       ${x2_v6_uplane_ip}
        ${lnmme_v4}=     Get Parameter   param_path=${lnmme_v4_moc_path}
        Set Suite Variable       ${lnmme_v4}
#        ${lnmme_v6}=     Get Parameter   param_path=${lnmme_v6_moc_path}
#        Set Suite Variable       ${lnmme_v6}

Add routes on VM
    Run        sudo ip a a 10.0.1.121 dev eth3
    Run        sudo ip a a 10.0.1.131 dev eth3
    Run        sudo ip a a 10.0.1.132 dev eth3
    Run        sudo ip a a 10.0.1.135 dev eth3
    Run        sudo ip a a 10.0.1.136 dev eth3
    Run        sudo ip a a 10.0.1.137 dev eth3
    Run        sudo ip a a 10.0.1.133 dev eth3
    Run        sudo ip a a 10.0.1.134 dev eth3
    Run        sudo ip a a fc00::1/120 dev eth3

Add routes on VMranssharing

      Run  sudo ip a a fc00::10/120 dev eth3
      Run   sudo ip a a fc00::11/120 dev eth3
      Run sudo ip a a fc00::12/120 dev eth3
	Run sudo ip a a fc00::13/120 dev eth3
	Run sudo ip a a fc00::14/120 dev eth3
	Run sudo ip a a fc00::15/120 dev eth3
	Run sudo ip a a fc00::16/120 dev eth3
	Run sudo ip a a fc00::17/120 dev eth3
	Run sudo ip a a fc00::18/120 dev eth3
	Run sudo ip a a fc00::19/120 dev eth3
	Run sudo ip a a fc00::20/120 dev eth3
	Run sudo ip a a fc00::21/120 dev eth3
	Run sudo ip a a fc00::22/120 dev eth3
	Run sudo ip a a fc00::23/120 dev eth3
     Run sudo ip a a 10.0.1.131/24 dev eth3
     Run sudo ip a a 10.0.1.132/24 dev eth3
     Run sudo ip a a 10.0.1.133/24 dev eth3
     Run  sudo ip a a 10.0.1.134/24 dev eth3
     Run  sudo ip a a 10.0.1.135/24 dev eth3
     Run  sudo ip a a 10.0.1.136/24 dev eth3
     Run  sudo ip a a 10.0.1.137/24 dev eth3
     Run  sudo ip a a 10.0.1.143/24 dev eth3
	Run sudo ip a a 10.0.1.144/24 dev eth3
	Run sudo ip a a 10.0.1.150/24 dev eth3
	Run sudo ip a a 10.0.1.151/24 dev eth3
	Run sudo ip a a 10.0.1.152/24 dev eth3
	Run sudo ip a a 10.0.1.153/24 dev eth3
	Run sudo ip a a 10.0.1.154/24 dev eth3
	Run sudo ip a a 10.0.1.160/24 dev eth3
	Run sudo ip a a 10.0.1.161/24 dev eth3
	Run sudo ip a a 10.0.1.162/24 dev eth3
	Run sudo ip a a 10.0.1.163/24 dev eth3
	Run sudo ip a a 10.0.1.164/24 dev eth3
	Run  sudo ip a a 10.0.1.140/24 dev eth3
	Run sudo ip a a 10.0.1.141/24 dev eth3
	Run sudo ip a a 10.0.1.142/24 dev eth3
	Run sudo ip a a 10.0.1.143/24 dev eth3
	Run sudo ip a a 10.0.1.144/24 dev eth3
Get parameter values
         Run    sudo -E pip install scapy
#         Run   cp /home/ute/MN/UTE/robotlte/testsuite/WMP/E2E_BTS_TRS_FW/fw_user_path/testcases/CB009131/1/testline_config.json
#       /home/ute/MN/UTE/robotlte/testsuite/WMP/E2E_BTS_TRS_FW/fw_user_path/config/1/
         Run   cp /home/ute/MN/UTE/robotlte/testsuite/WMP/E2E_BTS_TRS_FW/fw_user_path/testcases/resources/scapy_gtp.py /home/ute

         Setup Remote Access	remote_device=bts
	${mac_address}=		Remote Command Execute		command=ifconfig br1 | grep ether | awk '{print $2}'
        Set Suite Variable       ${mac_address}

#        ${actDynamicFirewall_param_value}=		Get Parameter		param_path=${actDynamicFirewall_param_path}
#        Should Be True		'${actDynamicFirewall_param_value}'=='False'

        @{5g_nsa_x2_cplane_ipv4_list}=  Create List
        @{5g_nsa_x2_cplane_ipv6_list}=  Create List
        ${5g_nsa_nrbts_dict}=       Query Admin Infomodel       query=get list ${nrbts_moc_path}

        ${5g_nsa_x2_cplane_ip_list}=    Get From Dictionary	dictionary=@{5g_nsa_nrbts_dict}[0]      key=${x2Cplane_param_name}
        :FOR    ${ip_dict}  IN  @{5g_nsa_x2_cplane_ip_list}
        \   ${5g_nsa_x2_cplane_ipv4_dn}=    Get From Dictionary		dictionary=${ip_dict}   key=${ipV4AddressDN1_param_name}
        \   ${ipv4}=            Get Parameter   param_path=${5g_nsa_x2_cplane_ipv4_dn}:${localIpAddr_param_name}
        \   Append To List  ${5g_nsa_x2_cplane_ipv4_list}   ${ipv4}
        \  ${ipv6}=            Get Parameter   param_path=${5g_nsa_x2_cplane_ipv6_dn}:${localIpAddr_param_name}
        \   Append To List  ${5g_nsa_x2_cplane_ipv6_list}   ${ipv6}

        ${5g_nsa_x2_cplane_ipv4}=       Set Variable    @{5g_nsa_x2_cplane_ipv4_list}[0]

        ${5g_nsa_x2_cplane_ipv6}=       Set Variable    @{5g_nsa_x2_cplane_ipv6_list}[0]

        Set Suite Variable       ${5g_nsa_x2_cplane_ipv4}
        Set Suite Variable       ${5g_nsa_x2_cplane_ipv6}

	[Teardown]	Teardown Remote Access

Get parameter valuesSA

       ${5g_sa_amf_ipv4}=		Get Parameter   param_path=${5g_sa_amf_ipv4_moc_path}
        ${5g_sa_cplane1_ipv4}=		Get Parameter   param_path=${5g_sa_cplane1_ipv4_moc_path}

            ${5g_sa_uplane1_ipv4}=		Get Parameter   param_path=${5g_sa_uplane1_ipv4_moc_path}
        ${5g_sa_amf_ipv6}=		Get Parameter   param_path=${5g_sa_amf_ipv6_moc_path}
        ${5g_sa_cplane1_ipv6}=		Get Parameter   param_path=${5g_sa_cplane1_ipv6_moc_path}
          ${5g_sa_uplane1_ipv6}=		Get Parameter   param_path=${5g_sa_uplane1_ipv6_moc_path}

            ${xnlink_cplaneip}=   Get Parameter		param_path=${5g_nsa_xnlink_cplane_ipv6_moc_path}
        Set Suite Variable       ${xnlink_cplaneipv6}

        ${xnlink_cplaneip}=   Get Parameter		param_path=${5g_nsa_xnlink_cplane_ipv4_moc_path}
        Set Suite Variable       ${xnlink_cplaneip}

        Set Suite Variable       ${5g_sa_amf_ipv4}
        Set Suite Variable       ${5g_sa_cplane1_ipv4}
          Set Suite Variable       ${5g_sa_uplane1_ipv4}
        Set Suite Variable       ${5g_sa_amf_ipv6}
        Set Suite Variable       ${5g_sa_cplane1_ipv6}
        Set Suite Variable       ${5g_sa_uplane1_ipv6}

Verify 5g Ipv4 And Ipv6 Calls
	[Arguments]		${alias_suffix}         ${profile}

          Traffic Capture Start    capture_device=oam_device     mode=file   uplane_capturing=True
          ...           measurement_point=Transport_Interface   timeout=180     alias=firstcap
          ...                  alias=capture_5g_ipv6_call_${alias_suffix}
         Call Setup     5g=${profile}:data    parallel=${False}    attach=${False}      verify_attach=${false}    timeout=900

          Sleep   120
        ${actDynamicFirewall_param_value}=		Get Parameter		param_path=${actDynamicFirewall_param_path}
        Should Be True		'${actDynamicFirewall_param_value}'=='True'
        Make 5G Call      ${profile}
         ${lmp_output_file}=  Traffic Capture Stop    mode=file
		...                timeout=180     alias=capture_5g_ipv6_call_${alias_suffix}
        Set Suite Variable       ${lmp_output_file}
        Perform Recommissioning         type=param       param_path=${x2link_ipv6_administrativeState_param_path}
          ...          		  value=Locked	timeout=300   operation=update
         Sleep   200

          Traffic Capture Start    capture_device=oam_device     mode=file   uplane_capturing=True
		...                    measurement_point=Transport_Interface   timeout=180
          ...                  alias=capture_5g_ipv4_call_${alias_suffix}
          Make 5G Call     ${profile}

        ${lmp_output_filev4}=  Traffic Capture Stop    mode=file
		...                timeout=180     alias=capture_5g_ipv4_call_${alias_suffix}
         Sleep   20
        Perform Recommissioning         type=param       param_path=${x2link_ipv6_administrativeState_param_path}
		...                        value=Unocked	    timeout=300     operation=update
         Sleep   20
Analyse Pcap NSA call verification

        Analyse Pcap    pcap_filename=${lmp_output_filev4}   analysis=verify_5g_nsa_ipv4_attach_response
        ...		filter_file_name=${traffic_filter_file_name}

#v6
         Analyse Pcap    pcap_filename=${lmp_output_file}   analysis=verify_5g_nsa_ipv6_attach_response
        ...		filter_file_name=${traffic_filter_file_name}
         Analyse Pcap        pcap_filename=${lmp_output_file}        analysis=NSA_call_ul_ipV6
        ...		 filter_file_name=${traffic_filter_file_name}
       Analyse Pcap        pcap_filename=${lmp_output_file}        analysis=NSA_call_dl_ipV6
        ...	   filter_file_name=${traffic_filter_file_name}

Verify 5g Ipv4 And Ipv6 SACalls
	[Arguments]		${alias_suffix}            ${profile}

          Traffic Capture Start    capture_device=oam_device     mode=file   uplane_capturing=True
		...         measurement_point=Transport_Interface   timeout=180

           Call Setup     5g=${profile}:data    parallel=${False}    attach=${False}      verify_attach=${false}    timeout=900
           Perform Recommissioning         type=param       param_path=${amf_ipv4_administrativeState_param_path}
        ...  		value=Locked	timeout=300   operation=update
          Sleep   120
          Make 5G SACall    ${profile}

         ${lmp_output_file}=  Traffic Capture Stop    mode=file
		...                timeout=180     alias=capture_5g_ipv6_call_${alias_suffix}
        Set Suite Variable       ${lmp_output_file}

        Perform Recommissioning         type=param       param_path=${amf_ipv4_administrativeState_param_path}
        ...  		value=UnLocked	timeout=300   operation=update

          Sleep   120
     Perform Recommissioning         type=param       param_path=${amf_ipv6_administrativeState_param_path}
        ...  		value=Locked	timeout=300   operation=update

        Traffic Capture Start    capture_device=oam_device     mode=file   uplane_capturing=True
		...         measurement_point=Transport_Interface   timeout=180
          ...                  alias=capture_5g_ipv4_call_${alias_suffix}
          Make 5G SACall    ${profile}

        ${lmp_output_filev4}=  Traffic Capture Stop    mode=file
		...                timeout=180     alias=capture_5g_ipv4_call_${alias_suffix}
           Perform Recommissioning         type=param       param_path=${amf_ipv6_administrativeState_param_path}
        ...  		value=Unlocked	timeout=300   operation=update

Analyse Pcap for SA calls verification

         Analyse Pcap    pcap_filename=${lmp_output_file}   analysis=verify_5g_sa_ipv6_attach_response
        ...		filter_file_name=${traffic_filter_file_name}
         Analyse Pcap        pcap_filename=${lmp_output_file}        analysis=SA_call_ul_ipV6
        ...		 filter_file_name=${traffic_filter_file_name}
       Analyse Pcap        pcap_filename=${lmp_output_file}        analysis=SA_call_dl_ipV6
        ...	   filter_file_name=${traffic_filter_file_name}

     Analyse Pcap    pcap_filename=${lmp_output_filev4}   analysis=verify_5g_sa_ipv4_attach_response
        ...		filter_file_name=${traffic_filter_file_name}
         Analyse Pcap        pcap_filename=${lmp_output_filev4}        analysis=SA_call_ul_ipV4
        ...		 filter_file_name=${traffic_filter_file_name}
       Analyse Pcap        pcap_filename=${lmp_output_filev4}        analysis=SA_call_dl_ipV4
        ...	   filter_file_name=${traffic_filter_file_name}

Verify X2 Link Status
    [Arguments]    ${status}    ${alias}=default
    @{lnadj_moc_list} =     Query Admin Infomodel       query=get list ${lnadjgnb_moc_path}       timeout=60    alias=${alias}
    FOR    ${lnadjgnb_moc}    IN  @{lnadj_moc_list}
       ${x2_target_cplane_ip}=     Get From Dictionary     dictionary=${lnadjgnb_moc}     key=cPlaneIpAddr
       ${x2_link_status}=     Get From Dictionary     dictionary=${lnadjgnb_moc}     key=x2ToGnbLinkStatus
       Should Be Equal      ${x2_link_status}    available
       Log to console     LTE-GNB X2 Link Is ${status}
    END

Verify NRX2LINKTRUST
      @{nrx2linktrust_moc_list} =     Query Admin Infomodel       query=get list ${nrx2trust_moc_path}
      ...       	  timeout=30
    FOR    ${nrax2link_moc}    IN  @{nrx2linktrust_moc_list}
       ${xn_target_cplane_ip}=     Get From Dictionary     dictionary=${nrx2link_moc}     key=IPv4Addr
         Set Suite Variable       ${5g_nsa_x2_Link_cplane_ip}
         ${xn_target_cplane_ip_status}=     Get From Dictionary     dictionary=${nrx2link_moc}     key=status
         Should Be Equal        ${5g_nsa_x2_Link_cplane_ip_status}       available
	END

Verify NRX2LINKTRUST with OAM
      @{nrx2linktrust_moc_list} =     Query Admin Infomodel       query=get list ${nrx2trust_moc_path}
      ...       	  timeout=30    alias=${alias}
    FOR    ${nrax2link_moc}    IN  @{nrx2linktrust_moc_list}
       ${xn_target_cplane_ip}=     Get From Dictionary     dictionary=${nrx2link_moc}     key=IPv4Addr
         Set Suite Variable       ${5g_nsa_x2_Link_cplane_ip}
         ${xn_target_cplane_ip_status}=     Get From Dictionary     dictionary=${nrx2link_moc}     key=x2LinkTrustCtrl
         Should Be Equal        ${5g_nsa_x2_Link_cplane_ip_status}       oamControlled
    END

Modify NRX2LINKTRUST

             Perform Recommissioning        type=delta      delta_file=CB009131_delta_NRX2TRUSTlink_Modify.xml
             ...			 timeout=600     skip_parameter_relation_errors=${True}
        Sleep   200

        Verify Alarm   faultid=61524     rat=5g      alarm_type=history      severity=major       should_exist=${True}

       @{nrx2linktrust_moc_list} =     Query Admin Infomodel       query=get list ${nrx2trust_moc_path}
        ...       timeout=30    alias=${alias}
    :FOR    ${nrax2link_moc}    IN  @{nrx2linktrust_moc_list}
    \   ${xn_target_cplane_ip_status}=     Get From Dictionary     dictionary=${nrx2link_moc}     key=status
    \     Should Be Equal        ${5g_nsa_x2_Link_cplane_ip_status}       oamControlled

Modify NRX2LINK TRUST for ransharing
        Perform Recommissioning        type=delta      delta_file=CB009131_delta_applicationip_Modify_ransharing.xml
         ...		timeout=600     skip_parameter_relation_errors=${True}
        Sleep   200

        Verify Alarm   faultid=61524     rat=5g      alarm_type=history      severity=major
        ....		should_exist=${False}

       @{nrx2linktrust_moc_list} =     Query Admin Infomodel       query=get list ${nrx2trust_moc_path}
        ...       timeout=30    alias=${alias}
    :FOR    ${nrax2link_moc}    IN  @{nrx2linktrust_moc_list}
    \   ${xn_target_cplane_ip_status}=     Get From Dictionary     dictionary=${nrx2link_moc}     key=status
    \     Should Be Equal        ${5g_nsa_x2_Link_cplane_ip_status}       oamControlled

Delete NRX2LINKTRUST

             Perform Recommissioning        type=delta      delta_file=CB009131_delta_NRx2TRUSTlink_delete.xml
             ....			 timeout=600     skip_parameter_relation_errors=${True}
        Sleep   200

        Verify Alarm   faultid=61524     rat=5g      alarm_type=history      severity=major
        ...   		should_exist=${False}

       @{nrx2linktrust_moc_list} =     Query Admin Infomodel       query=get list ${nrx2trust_moc_path}
       ...       timeout=30    alias=${alias}
    :FOR    ${nrax2link_moc}    IN  @{nrx2linktrust_moc_list}
    \   ${xn_target_cplane_ip_status}=     Get From Dictionary     dictionary=${nrx2link_moc}     key=status
    \     Should Be Equal        ${5g_nsa_x2_Link_cplane_ip_status}       oamControlled

Send Packet From Unknown Source
        [Arguments]     ${ip_version}   ${profile1}

        ${traffic_profile}=	Set Variable If
        ...		'${ip_version}'=='ipv4'	    ${profile1}
#        ...		'${ip_version}'=='ipv4'	    ${profile1}
        ...		'${ip_version}'=='ipv6'	    ${profile1}
#        ...		'${ip_version}'=='ipv6'	    ${profile1}

        Traffic Setup           device=device_1
        ${packet_speed}     ${time} =       Traffic Start       profile=${traffic_profile}
        Traffic Teardown
        ${packets}=     Evaluate    ${packet_speed} * ${time}
        Set Suite Variable      ${packets}      ${packets}
        Set Suite Variable      ${packet_speed}     ${packet_speed}
        Set Suite Variable      ${time}     ${time}

        [Teardown]      Run Keyword And Ignore Error        Traffic Teardown

Verify Rate Limit
	Log 	${limit_counters_list}
	${counters_list}=		Get Dictionary Values	${limit_counters_list}

	:FOR    ${counter}    IN    @{counters_list}
	\	${counter_param_dict}=		Get Dictionary Values	${counter}
	\	Final Calculations	${counter_param_dict}

	${counters_increased} = 	Evaluate	${packets} - ${rate_limit_counters_increased}
	${rate_limiting_speed} = 	Evaluate	${counters_increased} / ${time}

	${packets_tolerance}=		Evaluate		${cplane_rate_limit} * 0.1
	${packets_min}=		Evaluate		${cplane_rate_limit} - ${packets_tolerance}
	${packets_max}=		Evaluate		${cplane_rate_limit} + ${packets_tolerance}
	Should be True		${packets_min} < ${rate_limiting_speed} < ${packets_max}

Final Calculations
	[Arguments]		${counter_param_dict}
	:FOR    ${items}    IN    @{counter_param_dict}
	\	${rate_limit_counters_increased}=			Get From Dictionary  ${items}  final_counter_value
	\	Set Suite Variable		${rate_limit_counters_increased}		${rate_limit_counters_increased}

Send Packet From GTP Unknown Source
        [Arguments]		${ip_version}    ${profile1}

        ${traffic_profile}=	Set Variable If
        ...		'${ip_version}'=='ipv6gtp'    ${profile1}
        ...		'${ip_version}'=='ipv4gtp'    ${profile1}
        ...		'${ip_version}'=='ipv6gtp'    ${profile1}
         ...		'${ip_version}'=='ipv4gtp'    ${profile1}
        Traffic Setup           device=device_1
        ${packet_speed}     ${time} =       Traffic Start       profile=${traffic_profile}
        Traffic Teardown
        ${packets}=     Evaluate    ${packet_speed} * ${time}
        Set Suite Variable      ${packets}      ${packets}
        Set Suite Variable      ${packet_speed}     ${packet_speed}
        Set Suite Variable      ${time}     ${time}
        [Teardown]      Run Keyword And Ignore Error        Traffic Teardown

Make 5G Call
       [Arguments]		${profile}
        Configure UE       5g=${profile}:data  command=ue_attach   id=1    profile=1
        Sleep   5
        Configure UE       5g=${profile}:data  command=enb_x2_link_up enb=1 target=2
        Sleep   5
        Configure UE       5g=${profile}:data  command=ue_dc_enb_start ue=${operator}   target_gnb=2   target_cells=1
         ...                                                   bearer=2 type=split_scg
        Configure UE       5g=${profile}:data  command=trf_data_start  ue=1	id=2	dir=ul	trf_id=1	mbps=2
        Sleep   5
        Configure UE       5g=${profile}:data  command=trf_data_start  ue=1	id=2	dir=dl	trf_id=1	mbps=2
        Sleep    30
        Configure UE       5g=${profile}:data  command=trf_data_stop   ue=1	id=2	dir=ul	trf_id=1
        Sleep   5
        Configure UE       5g=${profile}:data  command=trf_data_stop   ue=1	id=2	dir=dl	trf_id=1
        Sleep   5
        Configure UE       5g=${profile}:data  command=ue_detach   id=1

	[Teardown]	Call Teardown     5g=${profile}:data
Make 5G SACall
           [Arguments]		${profile}

           Configure UE       5g=${profile}:data  command=ue_register       id=1
        Sleep   5
        Configure UE       5g=${profile}:data  command=set_pdu_param      ue=1     pdu=1	trf_type=internal
        Sleep   5
        Configure UE       5g=${profile}:data  command=ue_pdu_session_setup	pdu=1	gw=1	ue=1	nwslice=1
        Sleep   5
        Configure UE       5g=${profile}:data  command=trf_data_start	ue=1	pdu=1	qfi=1	dir=dl	mbps=5
        Sleep   5
        Configure UE       5g=${profile}:data  command=trf_data_start	ue=1	pdu=1	qfi=1	dir=ul	mbps=5
       Sleep    10

        Configure UE       5g=${profile}:data  command=ue_history_information_list_add_ngran      id=1    gnb_id=2
	...    cell_type=medium   nrcgi=311:489|0x01    time_ue_stayed_in_cell=100
         Sleep   5
       Configure UE       5g=${profile}:data  command=ue_history_information_list      id=1    action=commit
        Sleep   5

        Configure UE       5g=${profile}:data  command=ue_enb_param     id=1    ue_history_list=1
        Sleep    5
        Configure UE       5g=${profile}:device1_sa:data  command=ue_measurement_send_nr    id=1    meas_id=3   event=A3   srsrp_nr=11
         ...                 		srsrq_nr=11    phycell_id=50     nrsrp_nr=33   nrsrq_nr=30
	[Teardown]	Call Teardown     5g=${profile}:data

Make 5G SACall new

        Configure UE       5g=${profile}:data  command=ue_register       id=1
        Sleep   5
        Configure UE       5g=${profile}:data  command=set_pdu_param      ue=1     pdu=1	trf_type=internal
        Sleep   5
        Configure UE       5g=${profile}:data  command=ue_pdu_session_setup	pdu=1	gw=1	ue=1	nwslice=1
        Sleep   5
        Configure UE       5g=${profile}:data  command=trf_data_start	ue=1	pdu=1	qfi=1	dir=dl	mbps=5
        Sleep   5
        Configure UE       5g=${profile}:data  command=trf_data_start	ue=1	pdu=1	qfi=1	dir=ul	mbps=5
       Sleep    10
        Configure UE       5g=${profile}:data  command=ue_history_information_list_add_ngran      id=1    gnb_id=2
        ...    cell_type=medium   nrcgi=311:489|0x01    time_ue_stayed_in_cell=100
         Sleep   5
       Configure UE       5g=${profile}:data  command=ue_history_information_list      id=1    acton=commit
        Sleep   5

        Configure UE       5g=${profile}:data  command=ue_enb_param     id=1    ue_history_list=1
        Sleep    5
        Configure UE       5g=${profile}:data  command=ue_measurement_send_nr    id=1    meas_id=3   event=A3   srsrp_nr=11
        ...    srsrq_nr=11    phycell_id=50     nrsrp_nr=33   nrsrq_nr=30
	[Teardown]	Call Teardown     5g=${profile}:data

Make NSA Call and Verify for 6 Operator
	[Arguments]      ${IP_Version}      ${profile}
#	Sleep  30
        Block Cell      rat=nr
        Sleep    60
        Unblock Cell    rat=nr
        Sleep   60

    ${mnc1}=    Set Variable      ${mnc}
    @{operator}    Create List    1    8    9
#	FOR  ${operator}   IN RANGE   1   8     step=7
    FOR    ${operator}    IN    @{operator}
        ${operator_str}= 	Convert To String	${operator}
		 Set Suite Variable      ${operator}        ${operator}
	    Set Suite Variable      ${operator_str}        ${operator_str}
        Get X2C_IP Address         ${operator}
        Block Cell      rat=nr
        Sleep    60
        Unblock Cell    rat=nr
        Sleep   60

#        Get S1U_IP Address        ${operator}
#	    Run Keyword If   '${IP_Version}' == 'ipV6'    set suite variable     ${MME}    6
#	     ...     ELSE      set suite variable     ${MME}    0
#	    ${MME}=    	Evaluate       ${operator}+${MME}
#		 Traffic Capture Start    capture_device=oam_device     mode=file   uplane_capturing=True
#         ...      	measurement_point=Transport_Interface   		alias=slice_${operator_str}_${IP_Version}
        Traffic Capture Start    capture_device=vm_eth3_interface      alias=slice_${operator_str}_${IP_Version}
        ${plmn}=    Set Variable   ${mcc}:${mnc1}
        Call Setup      5g=${profile}:data   parallel=${False}    verify_attach=${False}   attach=${False}    timeout=600
	    Make 5G Call for 6operator      ${operator}     ${profile}    ${plmn}
        Run     sudo killall egate edaemon
        ${mnc1}=      Evaluate    ${mnc}+1
#    	${pcap_file}=       Traffic capture stop	mode=file    alias=slice_${operator_str}_${IP_Version}
        ${pcap_file}=       Traffic capture stop     alias=slice_${operator_str}_${IP_Version}

#	    Get X2C_IP Address         ${operator}     ${IP_Version}
#        Get S1U_IP Address        ${operator}     ${IP_Version}

#       \      ${s1Uplane_DN_List}=   Get Parameter		param_path=${S1Uplane_DN}
#        \     Set Suite Variable     ${s1uplane_IP}     ${s1Uplane_DN_List}

#	    Get S1U IP Address     ${operator}           ${IP_Version}
	    Analyse Pcap        pcap_filename=${pcap_file}        analysis=NSA_call_dl_${IP_Version}
             ...         filter_file_name=${traffic_filter_file_name}
	    Analyse Pcap        pcap_filename=${pcap_file}        analysis=NSA_call_dl_${IP_Version}
             ...          filter_file_name=${traffic_filter_file_name}
        Block Cell      rat=nr
        Sleep    60
        Unblock Cell    rat=nr
        Sleep   60
#        Analyse Pcap        pcap_filename=${pcap_file}        analysis=verify_5g_nsa_${IP_Version}_attach_response
#        ...       	filter_file_name=${traffic_filter_file_name}
#        Reset Bts   should_be_onair=False
#        Perform Commissioning       scf_file=${ransharing_scf}   verify_bts_status=False     timeout=600
#        Sleep       100
    END

Make NSA Call and Verify for 2 Operator
	[Arguments]      ${IP_Version}      ${profile}
	Sleep  100
	FOR  ${operator}   IN RANGE   1   2
#        Block Cell      rat=5g
#        Sleep    120
#        Unblock Cell    rat=5g
#        Sleep   10
        ${operator_str}= 	Convert To String	${operator}
		 Set Suite Variable      ${operator}        ${operator}
	    Set Suite Variable      ${operator_str}        ${operator_str}
	    Run Keyword If   '${IP_Version}' == 'ipV6'    set suite variable     ${MME}    6
	     ...     ELSE      set suite variable     ${MME}    0
	    ${MME}=    	Evaluate       ${operator}+${MME}
#		 Traffic Capture Start    capture_device=oam_device     mode=file   uplane_capturing=True
#         ...            	measurement_point=Transport_Interface   		alias=slice_${operator_str}_${IP_Version}
        Get X2C_IP Address        ${operator}
        Get S1U_IP Address         ${operator}
        Traffic Capture Start       capture_device=vm_eth3_interface
        Sleep   100
	    Make 5G Call for 2operator      ${operator}    ${profile}
#            Get X2C_IP Address        ${operator}    ${IP_Version}
#            Get S1U_IP Address         ${operator}    ${IP_Version}
	 	 ${pcap_file}=       Traffic capture stop
#	        ${s1Uplane_DN_List}=   Get Parameter		param_path=${S1Uplane_DN}
#             Set Suite Variable     ${s1uplane_IP}     ${s1Uplane_DN_List}
#             Analyse Pcap        pcap_filename=${pcap_file}        analysis=verify_5g_nsa_${IP_Version}_attach_response
#        ...       	filter_file_name=${traffic_filter_file_name}

#	  Analyse Pcap        pcap_filename=${pcap_file}        analysis=NSA_call_dl_${IP_Version}      filter_file_name=${traffic_filter_file_name}
#	  Analyse Pcap        pcap_filename=${pcap_file}        analysis=NSA_call_dl_${IP_Version}      filter_file_name=${traffic_filter_file_name}
    END
        [Teardown]  Call Teardown     5g=${profile}:data

Make NSA Call and Verify
    [Arguments]      ${IP_Version}      ${profile}
    Sleep  100
    FOR  ${operator}   IN RANGE   7   9
#        Block Cell      rat=5g
#        Sleep    120
#        Unblock Cell    rat=5g
#        Sleep   10
        ${operator_str}=    Convert To String   ${operator}
         Set Suite Variable      ${operator}        ${operator}
        Set Suite Variable      ${operator_str}        ${operator_str}
        Run Keyword If   '${IP_Version}' == 'ipV6'    set suite variable     ${MME}    6
         ...     ELSE      set suite variable     ${MME}    0
        ${MME}=     Evaluate       ${operator}+${MME}
        Traffic Capture Start    capture_device=oam_device     mode=file   uplane_capturing=True
         ...               measurement_point=Transport_Interface           alias=slice_${operator_str}_${IP_Version}
        Traffic Capture Start       capture_device=vm_eth3_interface
        Make 5G Call for 2operator      ${operator}    ${profile}
            Get X2C_IP Address        ${operator}
            Get S1U_IP Address         ${operator}
         ${pcap_file}=       Traffic capture stop
#           ${s1Uplane_DN_List}=   Get Parameter        param_path=${S1Uplane_DN}
#             Set Suite Variable     ${s1uplane_IP}     ${s1Uplane_DN_List}
#             Analyse Pcap        pcap_filename=${pcap_file}        analysis=verify_5g_nsa_${IP_Version}_attach_response
#        ...        filter_file_name=${traffic_filter_file_name}
#        Analyse Pcap        pcap_filename=${pcap_file}        analysis=NSA_call_dl_${IP_Version}      filter_file_name=${traffic_filter_file_name}
#        Analyse Pcap        pcap_filename=${pcap_file}        analysis=NSA_call_dl_${IP_Version}      filter_file_name=${traffic_filter_file_name}

    END
Make 5G Call for 6operator
   [Arguments]      ${opertaor}     ${profile}      ${plmn}
#        Configure UE       5g=device1_nsa_ransharing_new:data  command=enb_x2_link_up    enb=${enbid}        target=2      x2_link_addr=${x2linkip}
        Configure UE       5g=${profile}:data  command=enb_x2_link_up    enb=${opertaor}       target=2
        Sleep   5
        Configure UE       5g=${profile}:data  command=ue_change_location    id=${opertaor}    enb=${opertaor}     cell=11
        Sleep   5
        Configure UE       5g=${profile}:data  command=ue_attach   id=${operator}    profile=1    selected_plmn=${plmn}
        Sleep   5
        Configure UE       5g=${profile}:data  command=enb_ue_dc_start      ue=${operator}   target_gnb=2   target_cells=1   bearer=2
        ...    type=split_scg
        Sleep   5
        Configure UE       5g=${profile}:data  command=trf_data_start       ue=${operator}	id=2	dir=ul	trf_id=1	mbps=10
        Sleep   5
        Configure UE       5g=${profile}:data  command=trf_data_start       ue=${operator}	id=2	dir=dl	trf_id=2	mbps=10
        Sleep   60
        Configure UE       5g=${profile}:data  command=trf_data_stop        ue=${operator}	id=2	dir=ul	trf_id=1
        Sleep   5
        Configure UE       5g=${profile}:data  command=trf_data_stop        ue=${operator}	id=2	dir=dl	trf_id=2
        Sleep   5
        Configure UE       5g=${profile}:data  command=ue_detach   id=${operator}

#	[Teardown]	Call Teardown     5g=${profile}:data

Make 5G Call for 2operator
   [Arguments]      ${operator}     ${profile}
#    FOR  ${operator}   IN RANGE   1   3
        Configure UE       5g=${profile}:data  command=enb_x2_link_up   enb=1   target=2    x2_link_addr=${5g_nsa_x2_cplane_ip}
        Sleep   5
        Configure UE       5g=${profile}:data  command=ue_attach   id=${operator}    profile=1    selected_plmn=311:489
        Sleep   5
        Configure UE       5g=${profile}:data  command=enb_ue_dc_start  ue=${operator}    target_gnb=2    target_cells=1  bearer=2    type=split_scg
        Sleep   5
        Configure UE       5g=${profile}:data  command=trf_data_start   ue=${operator}	id=2	dir=ul	trf_id=1	mbps=20
        Sleep   5
        Configure UE       5g=${profile}:data  command=trf_data_start   ue=${operator}	id=2	dir=dl	trf_id=1	mbps=20
        Sleep    30
        Configure UE       5g=${profile}:data  command=trf_data_stop    ue=${operator}	id=2	dir=ul	trf_id=1
        Sleep   5
        Configure UE       5g=${profile}:data  command=trf_data_stop    ue=${operator}	id=2	dir=dl	trf_id=1
        Sleep   5
        Configure UE       5g=${profile}:data  command=ue_detach    id=${operator}
#    END

#	[Teardown]	Call Teardown     5g=${profile}:data

Get X2C_IP Address
 	[Arguments]          ${operator}

    ${index}=       Run Keyword If    '${operator}'=='1'    Set variable     0    ELSE IF    '${operator}'=='8'
    ...    Set variable     1     ELSE IF      '${operator}'=='9'     Set variable     2
	${nrbts_dict}=    Query Admin Infomodel    query=get object ${nrbts_path}
	${x2Cplane_list}=    Get From Dictionary     dictionary=${nrbts_dict}      key=x2Cplane
	${X2Cplane_add}=   Get from list       ${X2Cplane_list}        ${index}
	${X2Cplane_moc}=    Get From Dictionary     ${X2Cplane_add}       ${IP_Version}AddressDN1
	${X2Cplane_ipif}=   Query Admin Infomodel     query=get object ${X2Cplane_moc}
	${X2Cplane_ip}=    Get From Dictionary      ${X2Cplane_ipif}      localIpAddr
    Set Suite Variable     ${5g_nsa_x2_cplane_ip}      ${X2Cplane_ip}

Get S1U_IP Address
      	[Arguments]          ${operator}

	${index}=    Evaluate      ${operator}-1
	${nrbts_dict}=    Query Admin Infomodel    query=get object ${nrbts_path}
	${s1Uplane_list}=    Get From Dictionary     dictionary=${nrbts_dict}      key=s1Uplane
	${s1Uplane_add}=   Get from list       ${S1Uplane_list}        ${index}
#	${X2Cplane_moc}=    Get From Dictionary     ${S1Uplane_add}       ${IP_Version}AddressDN1
#	${X2Cplane_ipif}=   Query Admin Infomodel     query=get object ${s1Uplane_moc}
#	${X2Cplane_ip}=    Get From Dictionary      ${s1Uplane_ipif}      localIpAddr
    Set Suite Variable     ${s1Uplane_ip}      ${s1Uplane_ip}

monitor CPU/memory utilization
    Setup Enb Fsm Access
    ${cpu_usage}=   Run Keyword       Execute Command On Enb     top -b -d 1 -n 1 | grep trs-soam-d | awk '{print $9}'
    Teardown Enb Fsm Access
    Log To console  ${cpu_usage}
	Run Keyword if      '${cpu_usage}'>='${cpu_threshold_value}'         Fail       CPU utilization is more

Check duration of DU reset
       ${output}=       Run      cat /home/ute/fw_user_path/testcases/jira_implementation/master.txt | grep -i "start Reset Procedure"
       ${start_time}=       Run     cat /home/ute/fw_user_path/testcases/jira_implementation/master.txt | grep "start Reset Procedure"
       ...       	   | awk '{print $2}'
       Log to Console       ${start_time}
       ${output}=       Run      cat /home/ute/fw_user_path/testcases/jira_implementation/master.txt |
	   ...           grep -i "has been changed from Validated to OnAirDone"
       ${end_time}=       Run     cat /home/ute/fw_user_path/testcases/jira_implementation/master.txt |
        ...      	   grep "has been changed from Validated to OnAirDone" | awk '{print $2}'
       Log to Console       ${end_time}
       ${time} =   Subtract Time From Time     ${end_time}     ${start_time}

Reset with FAF enabled

       start syslog    log_dir=${OUTPUT_DIR}    log_name=master.txt

       Reset Bts
        Check duration of DU reset
        Sleep   60
         Verify NRX2LINKTRUST

        ${actDynamicFirewall_param_value}=		Get Parameter		param_path=${actDynamicFirewall_param_path}
        Should Be True		'${actDynamicFirewall_param_value}'=='True'

Scapy Validation

    PM Counters Start               analysis=verify_ingress_packet_filter_drop         counter_analysis_file=${counter_analysis_file_name}
        Send Packet From Unknown Source		ip_version=ipv6                  profile1=unknown_x2ap_src_packets_ipv6
       ${limit_counters_list}= 		Verify PM Counters		analysis=verify_ingress_packet_filter_drop
       ...     	   counter_analysis_file=${counter_analysis_file_name}
        Verify Rate Limit
      PM Counters Start               analysis=verify_ingress_packet_filter_drop         counter_analysis_file=${counter_analysis_file_name}
        Send Packet From Unknown Source		ip_version=ipv4                 profile1=unknown_x2ap_src_packets_ipv4
        ${limit_counters_list}= 		Verify PM Counters		analysis=verify_ingress_packet_filter_drop
        ...    		counter_analysis_file=${counter_analysis_file_name}
        Verify Rate Limit

     PM Counters Start               analysis=verify_ingress_packet_filter_drop         counter_analysis_file=${counter_analysis_file_name}
        Send Packet From Unknown Source		ip_version=ipv4                profile1=unknown_gtp_src_packets_ipv4
         ${limit_counters_list}= 		Verify PM Counters		analysis=verify_ingress_packet_filter_drop
         ...  		 counter_analysis_file=${counter_analysis_file_name}
        Verify Rate Limit
         PM Counters Start               analysis=verify_ingress_packet_filter_drop          counter_analysis_file=${counter_analysis_file_name}
        Send Packet From GTP Unknown Source     	ip_version=ipv6        profile1=unknown_gtp_src_packets_ipv6
        ${limit_counters_list}= 		Verify PM Counters		analysis=verify_ingress_packet_filter_drop
         ...      		counter_analysis_file=${counter_analysis_file_name}
        Verify Rate Limit

Scapy ValidationSA
    PM Counters Start               analysis=verify_ingress_packet_filter_drop         counter_analysis_file=${counter_analysis_file_name}
        Send Packet From Unknown Source		ip_version=ipv6                 profile1=unknown_xnap_src_packets_ipv6
        ${limit_counters_list}= 		Verify PM Counters		analysis=verify_ingress_packet_filter_drop
        ...      		counter_analysis_file=${counter_analysis_file_name}
        Verify Rate Limit
      PM Counters Start               analysis=verify_ingress_packet_filter_drop         counter_analysis_file=${counter_analysis_file_name}
        Send Packet From Unknown Source		ip_version=ipv4                 profile1=unknown_xnap_src_packets_ipv4
       ${limit_counters_list}= 		Verify PM Counters		analysis=verify_ingress_packet_filter_drop
        ....        	   counter_analysis_file=${counter_analysis_file_name}
        Verify Rate Limit
     PM Counters Start               analysis=verify_ingress_packet_filter_drop         counter_analysis_file=${counter_analysis_file_name}
        Send Packet From Unknown Source		ip_version=ipv4                profile1=unknown_gtp_src_packets_ipv4
       ${limit_counters_list}= 		Verify PM Counters		analysis=verify_ingress_packet_filter_drop
        ...  	     counter_analysis_file=${counter_analysis_file_name}
        Verify Rate Limit
         PM Counters Start               analysis=verify_ingress_packet_filter_drop          counter_analysis_file=${counter_analysis_file_name}
        Send Packet From GTP Unknown Source     	ip_version=ipv6         profile1=unknown_gtp_src_packets_ipv6
      ${limit_counters_list}= 		Verify PM Counters		analysis=verify_ingress_packet_filter_drop
      ...      	  counter_analysis_file=${counter_analysis_file_name}
        Verify Rate Limit
Scapy Validation for ransharing

     :FOR  ${operator}   IN RANGE   1   7
    \    ${operator_str}= 	Convert To String	${operator}
	\	 Set Suite Variable      ${operator}        ${operator}
	\    Set Suite Variable      ${operator_str}        ${operator_str}
	\    Run Keyword If   '${IP_Version}' == 'ipV6'    set suite variable     ${MME}    6
	     ...     ELSE      set suite variable     ${MME}    2
	\    ${operator}=    	Evaluate       ${operator}+${MME}
	 \    Get X2C_IP Address        ${operator}    ${IP_Version}
        \    Get S1U_IP Address         ${operator}    ${IP_Version}

       \   PM Counters Start               analysis=verify_ingress_packet_filter_drop         counter_analysis_file=${counter_analysis_file_name}
        \   Send Packet From Unknown Source		ip_version=ipV6                 profile1=unknown_x2ap_src_packets_ipv6
       \   ${limit_counters_list}= 		Verify PM Counters		analysis=verify_ingress_packet_filter_drop
            ...    	   counter_analysis_file=${counter_analysis_file_name}
        \   Verify Rate Limit

      \   PM Counters Start               analysis=verify_ingress_packet_filter_drop         counter_analysis_file=${counter_analysis_file_name}
      \   Send Packet From Unknown Source		ip_version=ipV4                 profile1=unknown_x2ap_src_packets_ipv4
       \   ${limit_counters_list}= 		Verify PM Counters		analysis=verify_ingress_packet_filter_drop
            ...     	   counter_analysis_file=${counter_analysis_file_name}
        \   Verify Rate Limit
     \   PM Counters Start               analysis=verify_ingress_packet_filter_drop         counter_analysis_file=${counter_analysis_file_name}
      \  Send Packet From Unknown Source		ip_version=ipV4                profile1=unknown_gtp_src_packets_ipv4
       \   ${limit_counters_list}= 		Verify PM Counters		analysis=verify_ingress_packet_filter_drop
            ...     	   counter_analysis_file=${counter_analysis_file_name}
        \   Verify Rate Limit
       \   PM Counters Start               analysis=verify_ingress_packet_filter_drop          counter_analysis_file=${counter_analysis_file_name}
       \   Send Packet From GTP Unknown Source     	ip_version=ipV6         profile1=unknown_gtp_src_packets_ipv6
         \   ${limit_counters_list}= 		Verify PM Counters		analysis=verify_ingress_packet_filter_drop
              ...  		 counter_analysis_file=${counter_analysis_file_name}
        \   Verify Rate Limit
Scapy Validation for ransharing 2operator
         :FOR  ${operator}   IN RANGE   1   3
    \    ${operator_str}= 	Convert To String	${operator}
	\	 Set Suite Variable      ${operator}        ${operator}
	\    Set Suite Variable      ${operator_str}        ${operator_str}
	\    Run Keyword If   '${IP_Version}' == 'ipV6'    set suite variable     ${MME}    6
	     ...     ELSE      set suite variable     ${MME}    1
	\    ${operator}=    	Evaluate       ${operator}+${MME}
          \    Get X2C_IP Address        ${operator}    ${IP_Version}
        \    Get S1U_IP Address         ${operator}    ${IP_Version}
	\   PM Counters Start               analysis=verify_ingress_packet_filter_drop         counter_analysis_file=${counter_analysis_file_name}
        \   Send Packet From Unknown Source		ip_version=ipV6                 profile1=unknown_x2ap_src_packets_ipv6
        \   ${limit_counters_list}= 		Verify PM Counters		analysis=verify_ingress_packet_filter_drop
             ...      		counter_analysis_file=${counter_analysis_file_name}
        \   Verify Rate Limit
      \   PM Counters Start               analysis=verify_ingress_packet_filter_drop         counter_analysis_file=${counter_analysis_file_name}
      \   Send Packet From Unknown Source		ip_version=ipV4                 profile1=unknown_x2ap_src_packets_ipv4
       \   ${limit_counters_list}= 		Verify PM Counters		analysis=verify_ingress_packet_filter_drop
            ...   	   counter_analysis_file=${counter_analysis_file_name}
        \   Verify Rate Limit
     \   PM Counters Start               analysis=verify_ingress_packet_filter_drop         counter_analysis_file=${counter_analysis_file_name}
      \  Send Packet From Unknown Source		ip_version=ipV4                profile1=unknown_gtp_src_packets_ipv4
      \   ${limit_counters_list}= 		Verify PM Counters		analysis=verify_ingress_packet_filter_drop
           ...      	  counter_analysis_file=${counter_analysis_file_name}
        \   Verify Rate Limit
       \   PM Counters Start               analysis=verify_ingress_packet_filter_drop          counter_analysis_file=${counter_analysis_file_name}
       \   Send Packet From GTP Unknown Source     	ip_version=ipV6         profile1=unknown_gtp_src_packets_ipv6
         \   ${limit_counters_list}= 		Verify PM Counters		analysis=verify_ingress_packet_filter_drop
             ...           		 counter_analysis_file=${counter_analysis_file_name}
        \   Verify Rate Limit
Verify Xn Link Status
    [Arguments]        ${alias}=default
    @{nradj_moc_list} =     Query Admin Infomodel       query=get list ${nradj_moc_path}       timeout=30       alias=${alias}
    :FOR    ${nradj_moc}    IN  @{nradj_moc_list}
    \   ${xn_target_cplane_ip}=     Get From Dictionary     dictionary=${nradj_moc}     key=cPlaneIpSecTrsAddr
    \   ${nradj_im_moc_name}=   Get From Dictionary     dictionary=${nradj_moc}     key=dist_name
    \   ${nradj_im_moc_name_temp}=          Replace String Using Regexp     string=${nradj_im_moc_name}
         ...         pattern=${pattern_to_replace_in_moc}        replace_with=${EMPTY}
    \   @{nradj_im_moc_path_splits}=        Split String From Right     string=${nradj_im_moc_name_temp}    separator=/
    \   ${xn_lnadj_moc_id}=     Set Variable    @{nradj_im_moc_path_splits}[-1]
    \   Check Xn Link Available

Check Xn Link Available
    ${xnlink_status_moc}=   Query Admin Infomodel       query=get object ${xn_link_moc}
    Log    ${xnlink_status_moc}
    ${xnlink_status}=   Get From Dictionary     ${xnlink_status_moc}    xnLinkStatus
    Should Be Equal    ${xnlink_status}    available
    Log to console    Xn Link Is Available

Verify Xn Link Status Removal
    [Arguments]        ${alias}=default
    @{nradj_moc_list} =     Query Admin Infomodel       query=get list ${nradj_moc_path}       timeout=30       alias=${alias}
    :FOR    ${nradj_moc}    IN  @{nradj_moc_list}
    \   ${xn_target_cplane_ip}=     Get From Dictionary     dictionary=${nradj_moc}     key=cPlaneIpSecTrsAddr
    \   ${nradj_im_moc_name}=   Get From Dictionary     dictionary=${nradj_moc}     key=dist_name
    \   ${nradj_im_moc_name_temp}=          Replace String Using Regexp     string=${nradj_im_moc_name}
         ...            pattern=${pattern_to_replace_in_moc}        replace_with=${EMPTY}
    \   @{nradj_im_moc_path_splits}=        Split String From Right     string=${nradj_im_moc_name_temp}    separator=/
    \   ${xn_lnadj_moc_id}=     Set Variable    @{nradj_im_moc_path_splits}[-1]
    \   Check Xn Link Not Available

Check Xn Link Not  Available
    ${xnlink_status_moc}=   Query Admin Infomodel       query=get object ${xn_link_moc}
    Log    ${xnlink_status_moc}
    ${xnlink_status}=   Get From Dictionary     ${xnlink_status_moc}    xnLinkStatus
    Should Be Equal    ${xnlink_status}    unavailable
    Log to console    Xn Link Is Not sAvailable