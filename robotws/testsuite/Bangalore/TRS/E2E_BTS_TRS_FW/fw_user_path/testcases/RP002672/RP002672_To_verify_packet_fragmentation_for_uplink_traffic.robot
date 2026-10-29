*** Settings ***
Documentation
    ...     [Procedure]             "The test case is to validate 5G call functionality along with DSCP values for cplane and
    ...    GTPU error indication messages"
    ...     [Date]                  "27-04-20"
    ...     [Author]                "Pavithra C"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Funtion_Hash_Tags]     ""
    ...     [Feature_ID]            "5GC000577"
    ...     [Validation_status]     "Not yet tested"
    ...     [Validated_TestLine]    "5G-9010"

variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot

Suite Setup     Run Keywords    Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown  Run Keywords    Suite Teardown Postconditions
...     AND     Teardown Oamops

***Test Cases***
[2][1.0] TRS_SR002672_To_Verify_packet_Fragmentation_for_uplink_traffic
#    [Documentation]     The test case is to validate 5G call functionality along with DSCP values for cplane and GTPU error indication messages
    Perform Commissioning       scf_file=${basic_asib}   verify_bts_status=False     timeout=600
    Sleep    300
    Read 5G NSA IPv4 IPv6 Parameters
    Verify packet Fragmentation for 5g
##jira
    Add And Delete IP In Loop
    Sleep   20
    Verify 4g call
    Add And Delete IP In Loop for 4g call

***Keywords***
Read BTS Parameters
    [Documentation]     This keyword reads the configured value for cplane IPs based on the rat environment.

    Run Keyword If      '5g' in ${rat_env} or 'SRAN_5G' in ${rat_env} and 'NSA' in ${bts_hw_version}    Read 5G NSA IPv4 IPv6 Parameters
    Run Keyword If      'LTE' in ${rat_env} or 'SRAN_5G' in ${rat_env}      Read LTE IPv4 IPv6 Parameters
    Run Keyword If      'SRAN' in ${rat_env} or 'SRAN_5G' in ${rat_env}     Read WCDMA IPv4 IPv6 Parameters
    Run Keyword If      'SRAN' in ${rat_env} or 'SRAN_5G' in ${rat_env}     Read GSM IPv4 IPv6 Parameters
    ${cplane_rats}=     Set Variable If
    ...     'sran_5g' in ${rat_env}     5g,lte,wcdma,gsm
    ...     '5g' in ${rat_env}          5g
    ...     'sran' in ${rat_env}        lte,wcdma,gsm
    ...     'lte' in ${rat_env}         lte
    Set Suite Variable      ${cplane_rats}       ${cplane_rats}
Read 5G NSA IPv4 IPv6 Parameters
    ${5g_x2u} = 			Get Parameter 	rat=common 		param_path=${5g_x2u_ip_moc_path}
	${5g_x2c} = 			Get Parameter 	rat=common 		param_path=${5g_x2c_ip_moc_path}
	${5g_s1u} = 			Get Parameter 	rat=common 		param_path=${5g_s1u_ip_moc_path}
	Set Suite Variable 	${5g_x2u} 		${5g_x2u}
	Set Suite Variable 	${5g_x2c} 		${5g_x2c}
	Set Suite Variable 	${5g_s1u} 		${5g_s1u}

Perform 5G call for uplink traffic
    [Arguments]      ${mtu_value}
	Traffic capture start           capture_device=vm_eth3_interface
    Call Setup      lte=sim_enb_lte:data  parallel=${False}  verify_attach=${False}  ipv4_or_6=ipv4  attach=${False}   timeout=600
    Sleep   5
    Configure UE       lte=sim_enb_lte:data    command=ue_attach id=1 enb=1 cell=11 selected_plmn=234:77 scg_ul_dist_percent=100
    Sleep   5
    Configure UE       lte=sim_enb_lte:data    command=ue_measurement_send event=B1_NR id=1 phycell_id=50 srsrp=97 srsrq=34 nrsrp=97 nrsrq=30 nsinr=0
    Sleep   5
    Configure UE       lte=sim_enb_lte:data    command=trf_data_start ue=1 dir=ul protocol=udp bearer=5 kbps=2000 size=${mtu_value} stats=true
    Sleep   20
    Configure UE       lte=sim_enb_lte:data    command=trf_data_stop ue=1
    Sleep   5
    Configure UE      lte=sim_enb_lte:data    command=ue_detach id=1
    Sleep   20

    ${pcap_file}=	Traffic Capture Stop
    Set Suite Variable     ${pcap_file}     ${pcap_file}
     Sleep   20
    [Teardown]      Call Teardown   5g=sim_enb_lte:data
Perform 5G call for downlink taraffic
    [Arguments]      ${udp_dl_profile}
    Traffic capture start           capture_device=vm_eth3_interface
    Setup Remote Access    remote_device=bts
    Call Setup      5g=device1:data  parallel=${False}  verify_attach=${False}  ipv4_or_6=ipv4  attach=${False}
    Configure UE       5g=device1:data    command=ue_attach  id=1  profile=1
    Configure UE       5g=device1:data    command=enb_ue_dc_start  ue=1  target_gnb=2  target_cells=1  bearer=2  type=split_scg
    Configure UE      5g=device1:data    command=trf_data_start  ue=1  id=2  dir=ul  trf_id=1  size=${higher_mtu_value}
    Sleep   15
    Run Keyword And Ignore Error    Call Stop  5g=device1:data  profile=${udp_dl_profile}
    Call Teardown   5g=device1:data
    Teardown remote Access
   ${pcap_file}=       Traffic capture stop
    Set Suite Variable     ${pcap_file}
Teardown 5g call
    Run Keyword And Ignore Error    Call Stop  5g=airphone:data  profile=udp_ul
    Run Keyword And Ignore Error    Call Stop  5g=airphone:data  profile=udp_dl
    Call Teardown   5g=airphone:data
    Run Keyword And Ignore Error    Traffic capture stop
    Run    sudo killall egate edaemon

Verify wireshark for uplink traffic
    Analyse pcap    pcap_filename=${pcap_file}      analysis=verify_uplink_traffic       filter_file_name=${RP002672_traffic_filter}

Verify wireshark for downlink traffic
    Analyse pcap    pcap_filename=${pcap_file}      analysis=verify_downlink_traffic       filter_file_name=${RP002672_traffic_filter}

Verify fragmentation for lesser MTU value for uplink
	Analyse pcap    pcap_filename=${pcap_file}      analysis=verify_fragmentation_lesser_mtu_uplink
        ...    filter_file_name=${RP002672_traffic_filter}

Verify fragmentation for higher MTU value for uplink
	Analyse pcap    pcap_filename=${pcap_file}      analysis=verify_fragmentation_higher_mtu_uplink
        ...    filter_file_name=${RP002672_traffic_filter}

Verify fragmentation for lesser MTU value for downlink
    Analyse pcap    pcap_filename=${pcap_file}      analysis=verify_fragmentation_lesser_mtu_downlink
    ...    filter_file_name=${RP002672_traffic_filter}

Verify fragmentation for higher MTU value for downlink
     Analyse pcap    pcap_filename=${pcap_file}      analysis=verify_fragmentation_higher_mtu_downlink
     ...    filter_file_name=${RP002672_traffic_filter}

Send packets from UE that is lesser than MTU of gNB
	 FOR   ${i}   IN RANGE   10
	     ${lesser_mtu_value}=         Evaluate    random.choice(range(200, ${initial_mtu_value}))  random
	     Set Suite Variable      ${lesser_mtu_value}      ${lesser_mtu_value}
	     Exit For Loop if     ${lesser_mtu_value} != ${initial_mtu_value}
     END
	 Perform 5G call for uplink traffic    mtu_value=${lesser_mtu_value}
      Verify fragmentation for lesser MTU value for uplink
Send packets from UE that is greater than MTU of gNB
	 FOR   ${i}   IN RANGE   10
	     ${higher_mtu_value}=         Evaluate    random.choice(range(${initial_mtu_value}, 8188))  random
	     Set Suite Variable      ${higher_mtu_value}      ${higher_mtu_value}
	     Exit For Loop if     ${higher_mtu_value} != ${initial_mtu_value}
     END
#	 Perform 5G call for uplink traffic for higher mtu    mtu_value=${higher_mtu_value}
    Perform 5G call for uplink traffic    mtu_value=${higher_mtu_value}
    Verify wireshark for uplink traffic
    Verify fragmentation for higher MTU value for uplink

Send packets from core such that SGW sends non-fragmented GTPU packets to gNB
    Perform 5G call for downlink taraffic    udp_dl_lesser_mtu

Send packets from core such that SGW sends fragmented GTPU packets to gNB
    Perform 5G call for downlink taraffic    udp_dl_higher_mtu

Verify packet Fragmentation for 5g
    ${dict} =     Query Admin Infomodel    query=get object //IPIF_A-*
    ${initial_mtu_value}=        Get From Dictionary    dictionary=${dict}        key=ipMtu
    LOG To Console    ${initial_mtu_value}
	Set Suite Variable      ${initial_mtu_value}    ${initial_mtu_value}
    Send packets from UE that is lesser than MTU of gNB
    Send packets from UE that is greater than MTU of gNB

Perform 5G call for uplink traffic for higher mtu
     [Arguments]      ${mtu_value}
    Traffic capture start           capture_device=vm_eth3_interface
    Call Setup      5g=sim_enb:data  parallel=${False}  verify_attach=${False}  ipv4_or_6=ipv4  attach=${False}   timeout=600
    Sleep   5
    Configure UE       5g=sim_enb:data    command=ue_attach id=1 enb=1 cell=11 selected_plmn=234:77 scg_ul_dist_percent=100
    Sleep   5
    Configure UE       5g=sim_enb:data    command=ue_measurement_send event=B1_NR id=1 phycell_id=50 srsrp=97 srsrq=34 nrsrp=97 nrsrq=30 nsinr=0
    Sleep   5
    Configure UE      5g=sim_enb:data    command=trf_data_start ue=1 dir=ul protocol=udp bearer=5 kbps=2000 size=${mtu_value} stats=true
    Sleep   10
    Configure UE       5g=sim_enb:data    command=ue_detach id=1

    Call Teardown   5g=sim_enb:data
    ${pcap_file}=   Traffic Capture Stop
    Set Suite Variable     ${pcap_file}     ${pcap_file}
Verify S1 link status unavailable
    @{lnmme_moc_list} =     Query Admin Infomodel       query=get list ${s1_link_status_moc_path}
    FOR     ${lnmme_moc}    IN  @{lnmme_moc_list}
    ${s1_primary_ip}=   Get From Dictionary     dictionary=${lnmme_moc}     key=ipAddrPrim
    ${s1_secondary_ip}=     Get From Dictionary     dictionary=${lnmme_moc}     key=ipAddrSec
    ${s1_link_status}=  Get From Dictionary     dictionary=${lnmme_moc}     key=s1LinkStatus
    Should Be Equal     ${s1_link_status}   unavailable
    END

Verify S1 link status available
    @{lnmme_moc_list} =     Query Admin Infomodel       query=get list ${s1_link_status_moc_path}
    FOR     ${lnmme_moc}    IN  @{lnmme_moc_list}
    ${s1_primary_ip}=   Get From Dictionary     dictionary=${lnmme_moc}     key=ipAddrPrim:wq!
    ${s1_secondary_ip}=     Get From Dictionary     dictionary=${lnmme_moc}     key=ipAddrSec
    ${s1_link_status}=  Get From Dictionary     dictionary=${lnmme_moc}     key=s1LinkStatus
    Should Be Equal     ${s1_link_status}   available
    END

Add And Delete IP In Loop
    FOR    ${i}    IN RANGE    11
        Sleep    30
        Log    Iteration ${i}
        Run    sudo ip a d 10.0.1.131/24 dev eth3.550
        Sleep    300
        Verify S1 link status unavailable
        Run    sudo ip a a 10.0.1.131/24 dev eth3.550
        Sleep    300
        Verify S1 link status available
        Sleep    60
        Verify packet Fragmentation for 5g
    END
Verify 4g call
    Traffic capture start           capture_device=vm_eth3_interface
    Call Setup      lte=sim_enb_lte:data  parallel=${False}  verify_attach=${False}  ipv4_or_6=ipv4  attach=${False}   timeout=600
    Sleep   5
    Configure UE       lte=sim_enb_lte:data    command=ue_attach id=2 enb=1 cell=11
    Sleep   5
    Configure UE       lte=sim_enb_lte:data    command=trf_data_start ue=2 dir=dl_and_ul protocol=udp kbps_dl=2000 kbps_ul=2000
    Sleep   20
    Configure UE      lte=sim_enb_lte:data    command=ue_detach id=2
    Sleep   5
    [Teardown]      Call Teardown   5g=sim_enb_lte:data
    ${pcap_file}=   Traffic Capture Stop
    Set Suite Variable     ${pcap_file}     ${pcap_file}
    Sleep    10
    Verify wireshark for uplink and downlink traffic
Add And Delete IP In Loop for 4g call
    FOR    ${i}    IN RANGE    11
        Sleep    30
        Log    Iteration ${i}
        Run    sudo ip a d 10.0.1.131/24 dev eth3.550
        Sleep    300
        Verify S1 link status unavailable
        Run    sudo ip a a 10.0.1.131/24 dev eth3.550
        Sleep    300
        Verify S1 link status available
        Sleep    60
        Verify 4g call
    END
Verify wireshark for uplink and downlink traffic
      Analyse pcap    pcap_filename=${pcap_file}      analysis=verify_4g_uplink_traffic       filter_file_name=${RP002672_traffic_filter}
      Analyse pcap    pcap_filename=${pcap_file}      analysis=verify_4g_downlink_traffic       filter_file_name=${RP002672_traffic_filter}