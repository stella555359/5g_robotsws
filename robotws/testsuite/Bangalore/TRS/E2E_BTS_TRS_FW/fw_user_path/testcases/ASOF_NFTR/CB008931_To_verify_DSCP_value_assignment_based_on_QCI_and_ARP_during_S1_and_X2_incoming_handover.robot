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
[1][1.0] CB008931_To_verify_DSCP_value_assignment_based_on_QCI_and_ARP_during_S1_and_X2_incoming_handover
##Configuration:
	Precondition for ipV4 Dual uplane configuration
    Perform Recommissioning     type=delta      delta_file=${delta_772_prereq_emer}     timeout=600
    Sleep   180s
    Perform Recommissioning     type=param      param_path=${Preemption_enable}   skip_parameter_relation_errors=${False}
    ...     operation=update    value=true       timeout=120
    Perform Recommissioning     type=param      rat=lte     param_path=${TAC_limit_GBR_normal}   skip_parameter_relation_errors=${False}
    ...     operation=update    value=7000       timeout=400
    Perform Recommissioning     type=param      rat=lte     param_path=${TAC_limit_GBR_handover}   skip_parameter_relation_errors=${False}
    ...    operation=update    value=8000     timeout=400
    Perform Recommissioning     type=param      rat=lte     param_path=${TAC_limit_GBR_emergency}   skip_parameter_relation_errors=${False}
    ...     operation=update    value=9500       timeout=400
    Run     sudo ifconfig eth3:1 10.0.1.104 netmask 255.255.255.0 up
    Run    cd /opt/iphy/latest;sudo ./edaemon --port 50001

    Call Setup  lte=HO_verification:data   parallel=${False}      attach=    verify_attach=${False}       timeout=120
    Run Keyword And Ignore Error    Configure UE        lte=HO_verification:data     command=ue_detach id=1
    Wait Until Keyword Succeeds  10 min     1 min    Verify Bts Status   should_be_onair=${True}
	Sleep	120s

##Check x2link status
	${x2link_status}=      Get Parameter      param_path=LNADJ-30:x2LinkStatus
    Should Be True     '${x2link_status}'=='available'

##Testcase
	Traffic Capture Start   capture_device=vm_eth3_interface     alias=eth3_pcap_x2
	Attach UE4 on enb2
	Triggering HO from enb2 to enb1
	${pcap_capture_1}=       Traffic Capture Stop        alias=eth3_pcap_x2
    Analyse pcap            pcap_filename=${pcap_capture_1}        analysis=Successful_X2_HO     filter_file_name=${772_traffic_filter}
    sleep    10
    Configure UE     lte=HO_verification:data       command=ue_detach id=401

    Execute cmd on egate      lte=HO_verification:data    cmd=enb_param id=30 ho_source=s1   timeout=60
    Traffic Capture Start   capture_device=vm_eth3_interface     alias=eth3_pcap_s1
    Attach UE4 on enb2
    Triggering HO from enb2 to enb1
    ${pcap_capture_1}=       Traffic Capture Stop        alias=eth3_pcap_s1
    Analyse pcap            pcap_filename=${pcap_capture_1}        analysis=Successful_S1_HO     filter_file_name=${772_traffic_filter}
    sleep    10
    Configure UE     lte=HO_verification:data       command=ue_detach id=401

    [Teardown]  Keywords to run at end


***Keywords***
Keywords to run at end
    Call Teardown  lte=:data
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

Attach UE4 on enb2
	Configure UE     lte=HO_verification:data       command=ue_attach id=401 cell=33
    Configure UE     lte=HO_verification:data       command=trf_data_start ue=401 dir=ul Mbps=1 protocol=udp
    Configure UE     lte=HO_verification:data       command=trf_data_start ue=401 dir=dl Mbps=1 protocol=udp
	Configure UE     lte=HO_verification:data       command=bearer_add ue=401 qci=2 gbr_ul=1000 gbr_dl=1000 mbr_ul=1000 mbr_dl=1000
    Configure UE     lte=HO_verification:data       command=trf_data_start ue=401 qci=2 dir=ul kbps=1000 protocol=udp

Triggering HO from enb2 to enb1
	Configure UE        lte=HO_verification:data  command=ue_ho id=401 cell=12 enb=1

Perfomring HO from enb2 to enb1
	Configure UE        lte=HO_verification:data  command=ue_ho id=4 cell=12 enb=1
	${pcap_capture_1}=       Traffic Capture Stop        alias=eth3_pcap
    Analyse pcap            pcap_filename=${pcap_capture_1}        analysis=HO_threshold     filter_file_name=${772_traffic_filter}


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


