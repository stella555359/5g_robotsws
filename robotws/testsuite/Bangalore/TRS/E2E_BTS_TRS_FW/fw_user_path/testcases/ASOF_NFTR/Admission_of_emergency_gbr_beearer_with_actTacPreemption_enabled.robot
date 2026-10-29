*** Settings ***
Documentation
...     [Author]        "Asha P"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"


#Resource		${CURDIR}/../resources/Admin_Common_Library.robot
Resource		${CURDIR}/../resources/common_keywords.robot

Suite Setup       Pre-conditions for testsuite
Suite Teardown    Post-conditions for testteardown

#Suite Setup      setup oamops
#Suite Teardown    Teardown oamops

*** Test Cases ***
[1][1.0] Admission of emergency gbr beearer with actTacPreemption enabled
##Configuration:

	Precondition for ipV4 Dual uplane configuration
    Perform Recommissioning     type=delta      delta_file=${delta_772_prereq_emer}     timeout=600
    Sleep   180s
    Perform Recommissioning     type=param      param_path=${Preemption_enable}   skip_parameter_relation_errors=${False}
    ...     operation=update    value=true       timeout=120
    Perform Recommissioning     type=param      rat=lte     param_path=${TAC_limit_GBR_normal}   skip_parameter_relation_errors=${False}
    ...     operation=update    value=8000       timeout=400
    Perform Recommissioning     type=param      rat=lte     param_path=${TAC_limit_GBR_handover}   skip_parameter_relation_errors=${False}
    ...    operation=update    value=8000     timeout=400
    Perform Recommissioning     type=param      rat=lte     param_path=${TAC_limit_GBR_emergency}   skip_parameter_relation_errors=${False}
    ...     operation=update    value=9500       timeout=400
	Pm Counters Start     analysis=tac_emergency_counters     counter_analysis_file=${772_counter_analysis}
    Run     sudo ifconfig eth3:1 10.0.1.104 netmask 255.255.255.0 up
    Traffic Capture Start   capture_device=vm_eth3_interface   capture_filter=sctp   alias=eth3_pcap
    Run    cd /opt/iphy/latest;sudo ./edaemon --port 50001

    Call Setup  lte=772_emergency:data   parallel=${False}      attach=         verify_attach=${False}       timeout=120
    Run Keyword And Ignore Error    Configure UE        lte=772_emergency:data     command=ue_detach id=1
    Wait Until Keyword Succeeds  5 min     30 sec    Verify Bts Status   should_be_onair=${True}
	Sleep	120s

##Check x2link status
	${x2link_status}=      Get Parameter      param_path=LNADJ-30:x2LinkStatus
    Should Be True     '${x2link_status}'=='available'

##Testcase
    Attach UE1,2,3
#@	Attach UE4 on enb2
#@	Triggering HO from enb2 to enb1
#@	${pcap_capture_1}=       Traffic Capture Stop        alias=eth3_pcap
#@    Analyse pcap            pcap_filename=${pcap_capture_1}        analysis=Successful_HO     filter_file_name=${772_traffic_filter}
	Traffic Capture Start   capture_device=vm_eth3_interface     alias=eth3_pcap_1
    sleep    10
	Attach UE5 with emergency bearer

##Attach another dedicated emergency bearer to UE5
	Traffic Capture Start   capture_device=vm_eth3_interface   capture_filter=sctp   alias=eth3_pcap_2
    Configure UE     lte=772_emergency:data      command=ue_attach id=6 emergency=on pdn_request_type=emergency cell=12 establishment_cause=emergency
    Configure UE     lte=772_emergency:data       command=trf_data_start ue=6 dir=ul kbps=1000 protocol=udp
#    Configure UE     lte=772_emergency:data       command=trf_data_start ue=6 dir=dl kbps=1000 protocol=udp
    Configure UE     lte=772_emergency:data       command=trf_data_start ue=6 qci=1 dir=ul kbps=1000 protocol=udp
#    Configure UE     lte=772_emergency:data       command=trf_data_start ue=6 qci=1 dir=dl kbps=1000 protocol=udp

	${pcap_capture_3}=       Traffic Capture Stop        alias=eth3_pcap_2
    Analyse pcap            pcap_filename=${pcap_capture_3}   analysis=Tac_preemption     filter_file_name=${772_traffic_filter}
	Analyse pcap            pcap_filename=${pcap_capture_3}   analysis=emergency_ue_attach_resp_vlan   filter_file_name=${772_traffic_filter}
    Sleep    10
    Attach UE6 with emergency bearer
#@	Configure UE     lte=772_emergency:data       command=ue_detach id=401
    Detach all UE's
	check the counter increment

#Configuring Drb and UE
#@	Perform Recommissioning     type=param      rat=lte     param_path=${Max_number_DRB}   skip_parameter_relation_errors=${False}
#@	...     operation=update    value=11       timeout=300
#@	Perform Recommissioning     type=param      rat=lte     param_path=${Max_number_UE}   skip_parameter_relation_errors=${False}
#@	...     operation=update    value=11	timeout=300
    Perform Recommissioning     type=delta      delta_file=Less_no_DRB_UE_772.xml     timeout=600
    Sleep	30

#Check x2link status
	${x2link_status}=      Get Parameter      param_path=LNADJ-30:x2LinkStatus
    Should Be True     '${x2link_status}'=='available'


#Repeat the steps after chnaging the Drb and UE
	Attach UE1,2,3
#@	Traffic Capture Start   capture_device=vm_eth3_interface   capture_filter=sctp   alias=eth3_pcap_3
#@    Attach UE4 on enb2
#@	Triggering HO from enb2 to enb1
#@	${pcap_capture_4}=       Traffic Capture Stop        alias=eth3_pcap_3
#@    Sleep   5
#@    Analyse pcap            pcap_filename=${pcap_capture_4}        analysis=Successful_HO   filter_file_name=${772_traffic_filter}
    Traffic Capture Start   capture_device=vm_eth3_interface    alias=eth3_pcap_1
    Sleep   5
	Attach UE5 with emergency bearer

#Attach another dedicated emergency bearer to UE5
	Traffic Capture Start   capture_device=vm_eth3_interface    capture_filter=sctp   alias=eth3_pcap_4
    Configure UE     lte=772_emergency:data      command=ue_attach id=6 emergency=on pdn_request_type=emergency cell=12 establishment_cause=emergency
    Configure UE     lte=772_emergency:data       command=trf_data_start ue=6 dir=ul kbps=1000 protocol=udp
#    Configure UE     lte=772_emergency:data       command=trf_data_start ue=6 dir=dl kbps=1000 protocol=udp
    Configure UE     lte=772_emergency:data       command=trf_data_start ue=6 qci=1 dir=ul kbps=1000 protocol=udp
#    Configure UE     lte=772_emergency:data       command=trf_data_start ue=6 qci=1 dir=dl kbps=1000 protocol=udp

	${pcap_capture_5}=       Traffic Capture Stop        alias=eth3_pcap_4
    Analyse pcap            pcap_filename=${pcap_capture_5}   analysis=RAC_TAC_preemption     filter_file_name=${772_traffic_filter}
	Analyse pcap            pcap_filename=${pcap_capture_5}   analysis=emergency_ue_attach_resp_vlan  filter_file_name=${772_traffic_filter}
	Attach UE6 with emergency bearer
    check the counter increment
    Detach all UE's
    Sleep   30
    [Documentation]  Verification of jira SMTRS-25342
    Perform Recommissioning     type=delta      delta_file=${delta_emer_config}     timeout=300
    Fetch the counters
    Set Suite Variable    ${emer_gbr_before}    ${emer_gbr}
    Set Suite Variable    ${normal_gbr_before}    ${normal_gbr}
	Configure UE     lte=772_emergency:data       command=ue_attach id=9 cell=12
	Configure UE     lte=772_emergency:data       command=trf_data_start ue=9 dir=ul Mbps=1 protocol=udp
    Configure UE     lte=772_emergency:data       command=trf_data_start ue=9 dir=dl Mbps=1 protocol=udp
    Fetch the counters
    Set Suite Variable    ${emer_gbr_after}    ${emer_gbr}
    Set Suite Variable    ${normal_gbr_after}    ${normal_gbr}
    Should Be equal    ${emer_gbr_before}     ${emer_gbr_after}
    Should Be True    ${normal_gbr_after}==${normal_gbr_before}+1
#@    [Teardown]  Keywords to run at end


***Keywords***
Keywords to run at end
    Call Teardown  lte=772_emergency:data
    Sleep   30
    Run    sudo killall egate edaemon
    Run Keyword and ignore error    Traffic Capture Stop        alias=eth3_pcap
    Run Keyword and ignore error    Traffic Capture Stop        alias=eth3_pcap_1
    Run Keyword and ignore error    Traffic Capture Stop        alias=eth3_pcap_2
    Run Keyword and ignore error    Traffic Capture Stop        alias=eth3_pcap_3
    Run Keyword and ignore error    Traffic Capture Stop        alias=eth3_pcap_4
    Run Keyword and ignore error    Traffic Capture Stop        alias=eth3_pcap_6
    Run     sudo ip link delete eth3.${vlan_ids}[1]
    Run     sudo ip link delete eth3.${vlan_ids}[2]
    Run     sudo ip link delete eth3.${vlan_ids}[3]
    Run     sudo ip link delete eth3.${vlan_ids}[4]

Fetch the counters
	Setup remote access        remote_device=bts
	${emer_gbr}    Remote Command Execute  command=/opt/trs/bin/objcli getTacCounters 0|grep "tacSuccessfulGbrEmergency"|head -1 | awk '{print $3}'
    Set Suite Variable          ${emer_gbr}
	${normal_gbr}  Remote Command Execute  command=/opt/trs/bin/objcli getTacCounters 0 | grep "tacSuccessfulGbrNormal" | head -1 | awk '{print $4}'
    Set Suite Variable          ${normal_gbr}
    [Teardown]      Teardown remote Access


Precondition for ipV4 Dual uplane configuration
	Bring 4 VLAN interface on VM
    Copy File    ${delta_dir}/${delta_ipv4_dual_uplane}   ${EXECDIR}/${delta_ipv4_dual_uplane}
    FOR   ${i}    IN RANGE   1   5
           ${j}=     Evaluate    ${i}+1
           Run     sudo sed -i "s/{{vlan_id_${j}}}/${vlan_ids}[${i}]/g" ${delta_dir}/${delta_ipv4_dual_uplane}
    END
	Perform Recommissioning      type=delta     delta_file=${delta_ipv4_dual_uplane}     timeout=500
    Sleep   180
    [Teardown]   Copy File    ${EXECDIR}/${delta_ipv4_dual_uplane}   ${delta_dir}/${delta_ipv4_dual_uplane}

Attach UE1,2,3
    FOR    ${i}    IN RANGE   1    5
#a        ${qci}=     Evaluate    ${i}+1
        ${qci}=     IF     '${i}'<='3'     Evaluate    ${i}+1      ELSE     Evaluate    ${i}+0
        Configure UE     lte=772_emergency:data       command=ue_attach id=${i} cell=12
        Configure UE     lte=772_emergency:data       command=trf_data_start ue=${i} dir=ul Mbps=1 protocol=udp
        Configure UE     lte=772_emergency:data       command=trf_data_start ue=${i} dir=dl Mbps=1 protocol=udp
        Configure UE     lte=772_emergency:data       command=bearer_add ue=${i} qci=${qci} gbr_ul=1000 gbr_dl=1000 mbr_ul=1000 mbr_dl=1000
        Configure UE     lte=772_emergency:data       command=trf_data_start ue=${i} qci=${qci} dir=ul kbps=1000 protocol=udp
        Configure UE     lte=772_emergency:data       command=trf_data_start ue=${i} qci=${qci} dir=dl kbps=1000 protocol=udp
        Sleep    5
    END

Attach UE4 on enb2
	Configure UE     lte=772_emergency:data       command=ue_attach id=401 cell=33
    Configure UE     lte=772_emergency:data       command=trf_data_start ue=401 dir=ul Mbps=1 protocol=udp
    Configure UE     lte=772_emergency:data       command=trf_data_start ue=401 dir=dl Mbps=1 protocol=udp
	Configure UE     lte=772_emergency:data       command= bearer_add ue=401 qci=2 gbr_ul=5=1000 gbr_dl=1000 mbr_ul=1000 mbr_dl=1000
    Configure UE     lte=772_emergency:data       command=trf_data_start ue=401 qci=2 dir=ul kbps=1000 protocol=udp

Triggering HO from enb2 to enb1
	Configure UE        lte=772_emergency:data  command=ue_ho id=401 cell=12 enb=1

Attach UE5 with emergency bearer
	Configure UE     lte=772_emergency:data      command=ue_attach id=5 emergency=on pdn_request_type=emergency cell=12 establishment_cause=emergency
	Configure UE     lte=772_emergency:data       command=trf_data_start ue=5 dir=ul kbps=1000 protocol=udp
#    Configure UE     lte=772_emergency:data       command=trf_data_start ue=5 dir=dl kbps=1000 protocol=udp
    Configure UE     lte=772_emergency:data       command=trf_data_start ue=5 qci=1 dir=ul kbps=1000 protocol=udp
#    Configure UE     lte=772_emergency:data       command=trf_data_start ue=5 qci=1 dir=dl kbps=1000 protocol=udp
    Sleep   10
	${pcap_capture_2}=       Traffic Capture Stop        alias=eth3_pcap_1
    Analyse pcap            pcap_filename=${pcap_capture_2}        analysis=emergency_ue_attach_req     filter_file_name=${772_traffic_filter}
	Analyse pcap            pcap_filename=${pcap_capture_2}        analysis=emergency_ue_attach_resp_vlan
	...     filter_file_name=${772_traffic_filter}

Attach UE6 with emergency bearer
	Traffic Capture Start   capture_device=vm_eth3_interface   capture_filter=sctp    alias=eth3_pcap_6
    [Documentation]  ignore error is used since the UE attach is expected to fail since it is low priority bearer than
    ...   admitted bearer when the TAC threshold is reached
	Run Keyword and ignore error   Configure UE     lte=772_emergency:data   command=ue_attach id=7 emergency=on pdn_request_type=emergency
    ...     cell=12 establishment_cause=emergency
    Sleep   5
	${pcap_capture_6}=       Traffic Capture Stop        alias=eth3_pcap_6
    Analyse pcap            pcap_filename=${pcap_capture_6}        analysis=Tac_preemption_failed_vlan
    ...     filter_file_name=${772_traffic_filter}

Perfomring HO from enb2 to enb1
	Configure UE        lte=772_emergency:data  command=ue_ho id=4 cell=12 enb=1
	${pcap_capture_1}=       Traffic Capture Stop        alias=eth3_pcap
    Analyse pcap            pcap_filename=${pcap_capture_1}        analysis=HO_threshold     filter_file_name=${772_traffic_filter}

check the counter increment
    Verify Pm Counters      analysis=tac_emergency_counters       counter_analysis_file=${772_counter_analysis}

Detach all UE's
	FOR  ${i}   IN RANGE       1     5
			Configure UE		lte=772_emergency:data       command=ue_detach id=${i}
    END
	Configure UE		lte=772_emergency:data       command=ue_detach id=5
	Configure UE		lte=772_emergency:data       command=ue_detach id=6


Bring 4 VLAN interface on VM
	Run		sudo ip link add link eth3 name eth3.${vlan_ids}[1] type vlan id ${vlan_ids}[1]
	Run		sudo ip addr add 10.0.3.209/30 brd 10.0.3.211 dev eth3.${vlan_ids}[1]
	Run		sudo ip link set dev eth3.${vlan_ids}[1] up

	Run		sudo ip link add link eth3 name eth3.${vlan_ids}[2] type vlan id ${vlan_ids}[2]
	Run		sudo ip addr add 10.0.3.213/30 brd 10.0.3.215 dev eth3.${vlan_ids}[2]
	Run		sudo ip link set dev eth3.${vlan_ids}[2] up

	Run		sudo ip link add link eth3 name eth3.${vlan_ids}[3] type vlan id ${vlan_ids}[3]
	Run		sudo ip addr add 10.0.3.217/30 brd 10.0.3.219 dev eth3.${vlan_ids}[3]
	Run		sudo ip link set dev eth3.${vlan_ids}[3] up

	Run		sudo ip link add link eth3 name eth3.${vlan_ids}[4] type vlan id ${vlan_ids}[4]
	Run		sudo ip addr add 10.0.3.221/30 brd 10.0.3.223 dev eth3.${vlan_ids}[4]
	Run		sudo ip link set dev eth3.${vlan_ids}[4] up