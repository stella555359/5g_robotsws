*** Settings ***
Documentation
	...		[Procedure]             "The test case is to verify functionality of source based routing"
    ...     [Date]                  "09-05-2025"
    ...     [Author]                "Mansi"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Funtion_Hash_Tags]     "Source Based Routing"
    ...     [Feature_ID]            "5GC000894"
    ...     [Validation_status]     "Tested"
    ...     [Validated_TestLine]    "5G-9002"


variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../../resources/common_keywords.robot
Library    taf.sw.scout    WITH NAME    scout



***Keywords***
Verify if IPV4 address is configured in gui
        ${LOCAL_IPV4_ADDR}=      Get Parameter      param_path=IPIF-1/IPADDRESSV4-1:localIpAddr
		Should Not Be Empty 		${LOCAL_IPV4_ADDR}

Verify if IPV6 address is configured in gui
        ${LOCAL_IPV6_ADDR}=      Get Parameter      param_path=IPIF-1/IPADDRESSV6-1:localIpAddr
		Should Not Be Empty 		${LOCAL_IPV6_ADDR}

Verify wireshark for source based routing
    Analyse pcap    pcap_filename=${pcap_file}      analysis=verify_vlan_for_first_ip         filter_file_name=${5GC000894_traffic_filter}
    Analyse pcap    pcap_filename=${pcap_file}      analysis=verify_vlan_for_second_ip         filter_file_name=${5GC000894_traffic_filter}
    Analyse pcap    pcap_filename=${pcap_file}      analysis=verify_vlan_for_third_ip         filter_file_name=${5GC000894_traffic_filter}
	Analyse pcap    pcap_filename=${pcap_file}      analysis=verify_vlan_for_fourth_ip        filter_file_name=${5GC000894_traffic_filter}

Command to execute on board
        [Arguments]      ${command}
        Remote Command Execute      command=${command}

Keywords To Run At End
    Call Teardown  5g=SBR_cfg:data
    Run     cd /opt/iphy/latest/ ; sudo killall egate edaemon

Perform software upgrade
    ${Active_SW_version}    ${passive_SW_version}=  Get Sw Version
     Setup Remote Access     remote_device=bts
     ${build_version}=       Remote Command Execute
     ...        command=cd /ffs/run/; ls -ltr | grep -i TargetBD | head -1 | awk '{print $9}' | cut -c -39 | cut -d_ -f 2-6
     Set Suite Variable      ${build_version}
    [Teardown]      Teardown remote Access
    @{active_release}=      Split String From Right     ${Active_SW_version}            _       max_split=2
     Run Keyword If  '${active_release[0]}' == 'SBTS23R2_ENB_9999'        PerformSoftware Download And Update    wft_profile=sbtstrunk_00
     ...        timeout=1600                ELSE    Perform Software Download And Update    wft_profile=branch_SBTS23R1  timeout=1600
     Sleep  300


verify calls for SA
    Start SA Calls
    Stop SA calls

Start SA Calls
    Configure UE    5g=SBR_cfg:data        command=ue_register        id=1        profile=1
    Sleep   3
    Configure UE    5g=SBR_cfg:data        command=set_pdu_param        ue=1        pdu=1        trf_type=internal
    Sleep   3
    Configure UE    5g=SBR_cfg:data        command=ue_pdu_session_setup        pdu=1        gw=1         ue=1
    Sleep   3
    Configure UE    5g=SBR_cfg:data        command=trf_data_start         ue=1         pdu=1        qfi=1        dir=dl        mbps=20
    Sleep   3
    Configure UE    5g=SBR_cfg:data        command=trf_data_start        ue=1        pdu=1        qfi=1         dir=ul         mbps=20



Stop SA calls
    Configure UE    5g=SBR_cfg:data        command=ue_pdu_session_release         ue=1        pdu=1
    Sleep   3
    Configure UE    5g=SBR_cfg:data        command=trf_data_stop        ue=1        dir=dl
    Sleep   3
    Configure UE    5g=SBR_cfg:data        command=trf_data_stop        ue=1        dir=ul
    Sleep   3
    Configure UE    5g=SBR_cfg:data        command=ue_deregister        id=1        ue_deregister_type=switch_off

verify calls and frame length and Traffic Length
    ${DL_GTP_Packet_Count}=     Analyse Pcap        pcap_filename=${PointA_File_Mode}         filter_file_name=${5GC000894_traffic_filter}
    ...        analysis=gtp_success_SA_DL
    ${UL_GTP_Packet_Count}=     Analyse Pcap        pcap_filename=${PointA_File_Mode}         filter_file_name=${5GC000894_traffic_filter}
    ...         analysis=gtp_success_SA_UL
    ${DL_Packet_Count}=     Analyse Pcap        pcap_filename=${PointA_File_Mode}         filter_file_name=${5GC000894_traffic_filter}
    ...         analysis=Verify_GTP_frame_len_DL
    ${UL_Packet_Count}=     Analyse Pcap        pcap_filename=${PointA_File_Mode}           filter_file_name=${5GC000894_traffic_filter}
    ...         analysis=Verify_GTP_frame_len_UL

verify TCP calls and frame length for SA with Iperf
    Traffic Capture Start   capture_device=oam_device   mode=file   measurement_point=Transport_Interface   uplane_capturing=True
    ...         timeout=120     alias=Iperf_TCP_PointA_File_Mode
    Configure UE    5g=SBR_cfg:data        command=set_pdu_param        ue=1        pdu=1        trf_type=external
    Configure UE    5g=SBR_cfg:data        command=ue_register        id=1        profile=1
    Sleep   2
    Configure UE    5g=SBR_cfg:data        command=ue_pdu_session_setup        pdu=1        gw=1         ue=1
    Sleep   2
	Process.Start Process		iperf -s -p 7070 -i 1 -B 10.0.2.1 > iperf_server.log &    shell=True
	Process.Start Process		iperf -c 72.23.0.1 -p 7070 -l 1500 -b 20M -i 2 -t 10 -B 10.0.2.1 > iperf_client.log &    shell=True
    Sleep   5
    Comment     TCP Frame Length: IP (20) + UDP (8) + GTP (16) + IP (20) + TCP with iperf (32) = 96 Bytes
    Set Suite Variable      ${frame_len}    96
    Stop SA calls
    ${PointA_File_Mode}=    Traffic Capture Stop    mode=file   alias=Iperf_TCP_PointA_File_Mode
	Set Suite Variable		${PointA_File_Mode}		${PointA_File_Mode}
    verify calls and frame length for SA

verify '${protocol}' calls and frame length for SA
    ${Traffic_Length}=   Evaluate    random.randint(2000,9000)     random
    Set Suite Variable      ${Traffic_Length}    ${Traffic_Length}
    Comment     UDP Frame Length: IP (20) + outer UDP (8) + GTP (16) + IP (20) + Inner UDP (8) = 72 Bytes
    Comment     TCP Frame Length: IP (20) + UDP (8) + GTP (16) + IP (20) + TCP (20) = 84 Bytes
    ${frame_len}=       Set Variable If     '${protocol}'=='tcp'      84    72
    Set Suite Variable      ${frame_len}  ${frame_len}

    Comment     Triggering SA call
    Traffic Capture Start   capture_device=oam_device   mode=file   measurement_point=Transport_Interface   uplane_capturing=True
    ...         timeout=120     alias=${protocol}_SA_PointA_File_Mode
    Configure UE    5g=SBR_cfg:data        command=set_pdu_param        ue=1        pdu=1        trf_type=internal
    Configure UE    5g=SBR_cfg:data        command=ue_register        id=1        profile=1
    Sleep   2
    Configure UE    5g=SBR_cfg:data        command=ue_pdu_session_setup        pdu=1        gw=1         ue=1
    Sleep   2
    Configure UE    5g=SBR_cfg:data        command=trf_data_start       ue=1       pdu=1      qfi=1      dir=dl      mbps=2
    ...         protocol=${protocol}      size=${Traffic_Length}
	Configure UE    5g=SBR_cfg:data        command=trf_data_start       ue=1       pdu=1      qfi=1      dir=ul      mbps=2
    ...         protocol=${protocol}      size=${Traffic_Length}
    Sleep   5
    ${PointA_File_Mode}=    Traffic Capture Stop    mode=file   alias=${protocol}_SA_PointA_File_Mode
    Set Suite Variable      ${PointA_File_Mode}     ${PointA_File_Mode}
    verify calls and frame length and Traffic Length

    Comment     Triggering NSA call
    Traffic Capture Start   capture_device=oam_device   mode=file   measurement_point=Transport_Interface   uplane_capturing=True
    ...         timeout=120     alias=${protocol}_NSA_PointA_File_Mode
    Configure UE    5g=SBR_cfg:data        command=ue_attach    id=11    profile=1
    Configure UE    5g=SBR_cfg:data        command=enb_ue_dc_start      target_gnb=2    target_cells=1      ue=11       bearer=2    type=split_scg
    Sleep   2
    Configure UE    5g=SBR_cfg:data        command=trf_data_start       ue=11   id=2    dir=ul   trf_id=2      mbps=2
    ...         protocol=${protocol}      size=${Traffic_Length}
    Configure UE    5g=SBR_cfg:data        command=trf_data_start       ue=11   id=2    dir=dl   trf_id=2      mbps=2
    ...         protocol=${protocol}      size=${Traffic_Length}
    Sleep   5
    ${PointA_File_Mode}=    Traffic Capture Stop    mode=file   alias=${protocol}_NSA_PointA_File_Mode
	Set Suite Variable		${PointA_File_Mode}		${PointA_File_Mode}

    Stop calls
    verify calls and frame length and Traffic Length

Stop calls
	Run		sudo killall iperf
    Configure UE    5g=SBR_cfg:data        command=ue_pdu_session_release         ue=1        pdu=1
    Sleep   1
    Configure UE    5g=SBR_cfg:data        command=ue_deregister        id=1        ue_deregister_type=switch_off
    Configure UE    5g=SBR_cfg:data        command=ue_detach    id=11

Check unexpected alarms if any
	Collect Initial Alarms
	Check for No Abnormal Alarms

Collect Initial Alarms
    @{Enb1_Initial_Alarm}=      Create List
    ${Enb1_Alarm}=      Verify Alarm
    Log     ${Enb1_Alarm}
    :FOR    ${i}    IN      @{Enb1_Alarm}
    \       ${value}=       Get From Dictionary     ${i}    alarmDetail
    \       Append To List      ${Enb1_Initial_Alarm}       ${value}
    Set Suite Variable      ${Enb1_Initial_Alarm}

Check for No Abnormal Alarms
    @{Enb1_current_Alarm}=      Create List
    ${Enb1_Alarm}=      Verify Alarm
    Log     ${Enb1_Alarm}
    :FOR    ${i}    IN      @{Enb1_Alarm}
    \       ${value}=       Get From Dictionary     ${i}    alarmDetail
    \       Append To List      ${Enb1_current_Alarm}       ${value}
    Set Suite Variable      ${Enb1_current_Alarm}
    Sort List       ${Enb1_current_Alarm}
    Sort List       ${Enb1_Initial_Alarm}
    Lists Should Be Equal       ${Enb1_Initial_Alarm}       ${Enb1_current_Alarm}

Check 138 IPV6 RTPOL are configured in board
        ${IPRT6_COUNT}=    Remote Command Execute    command=ip -6 ru sh | sed -n '/^0/,/^996/p' | wc -l
        Should Be Equal     ${IPRT6_COUNT}    285

Check 138 IPV4 RTPOL are configured in board
        ${IPRT4_COUNT}=    Remote Command Execute    command=ip ru sh | sed -n '/^0/,/^504/p' | wc -l
        Should Be Equal     ${IPRT4_COUNT}    276


verify calls and frame length for SA
    ${DL_GTP_Packet_Count}=     Analyse Pcap        pcap_filename=${PointA_File_Mode}         analysis=gtp_success_SA_DL
    ${UL_GTP_Packet_Count}=     Analyse Pcap        pcap_filename=${PointA_File_Mode}         analysis=gtp_success_SA_UL
    ${DL_Packet_Count}=     Analyse Pcap        pcap_filename=${PointA_File_Mode}         analysis=Verify_GTP_frame_len_DL
    ${UL_Packet_Count}=     Analyse Pcap        pcap_filename=${PointA_File_Mode}           analysis=Verify_GTP_frame_len_UL