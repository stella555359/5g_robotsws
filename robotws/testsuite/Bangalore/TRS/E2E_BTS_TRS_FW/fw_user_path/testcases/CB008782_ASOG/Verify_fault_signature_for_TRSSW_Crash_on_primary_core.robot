*** Settings ***
Documentation
...              [Author]      "Shankar Manurwar"
...              [Maintenance] "TRS I & V Tools Bangalore Team"

variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot
    
Suite Setup        Run Keywords    Suite Setup Preconditions
...        AND     Setup Oamops
Suite Teardown     Run Keywords        Suite Teardown Postconditions
...        AND     Teardown Oamops

***Test Cases ***
[1][1.0] Verify_fault_signature_for_TRSSW_Crash_on_primary_core
    Perform commissioning       scf_file=${Base_scf}   verify_bts_status=False     timeout=400     alias=default
    sleep       300
    Bring up On air
    Enable CB008782
	TRS Process 1
    TRS Process 2

*** Keywords ***
TRS Process 1
    Kill TRS Process and verify alarms and traffic        ${process_name1}
    Start the traffic and verify traffic        ${traffic_2}
    Trigger site reset and verify alarm 4590 should not exist

TRS Process 2
    Kill TRS Process and verify alarms and traffic        ${process_name2}
    Start the traffic and verify traffic        ${traffic_3}
    Trigger site reset and verify alarm 4590 should not exist
Bring up On air
    Run     sudo killall egate edaemon
    sleep   30
    Call Setup     lte=Plain_config:data    parallel=${False}    attach=${False}      verify_attach=${false}    timeout=120
    Sleep   10
    Verify BTS status   should_be_onair=${True}
    sleep   10

Start the traffic and verify traffic
    [Arguments]     ${pcap_1}
    Traffic Capture Start  capture_device=oam_device   mode=file   measurement_point=NE_Terminated   uplane_capturing=True
    ...     timeout=120     alias=${pcap_1}
    sleep  5
    Verify Alarm           faultid=61641   should_exist=${True}
    Configure UE       5g=Device_AP:data     command=enb_x2_link_up  enb=1   target=2
    Sleep   5
    Configure UE       5g=Device_AP:data     command=ue_register   id=1
    Sleep   5
    Configure UE       5g=Device_AP:data     command=set_pdu_param   ue=1    pdu=1   trf_type=internal
    Sleep   5
    Configure UE       5g=Device_AP:data    command=ue_pdu_session_setup     pdu=1   gw=1  ue=1
    Sleep   5
    Configure UE       5g=Device_AP:data    command=trf_data_start  ue=1     pdu=1    qfi=1    dir=dl  mbps=10
    Sleep   5
    Configure UE       5g=Device_AP:data    command=trf_data_start  ue=1     pdu=1    qfi=1    dir=ul  mbps=10
    Sleep   5
    Configure UE       5g=Device_AP:data    command=bearer_stats     ue=1    pdu=1   qfi=1  dir=bi
    Sleep   180

    ${filename_A}=  Traffic Capture Stop   mode=file      alias=${pcap_1}      timeout=100
    Analyse Pcap    pcap_filename=${filename_A}     filter_file_name=${traffic_filter_file_name}    analysis=UL_Traffic_check
    Analyse Pcap    pcap_filename=${filename_A}     filter_file_name=${traffic_filter_file_name}     analysis=DL_Traffic_check

Trigger site reset and verify alarm 4590 should not exist

    Reset Bts   wait_for=600    verify_bts=True     should_be_onair=True
    Wait Until Keyword Succeeds     10mins   5sec    Verify BTS status   should_be_onair=${True}
    Verify Alarm        faultid=4590     should_exist=${False}    alarm_type=history     load_history=True
    sleep   5

Add routes
    Run     sudo killall egate edaemon
    Run		sudo ip a a 10.0.1.121/24 dev eth3
    Run		sudo ip a a 10.0.1.131/24 dev eth3
    Run		sudo ip a a 10.0.1.132/24 dev eth3
    Run		sudo ip a a 10.0.1.133/24 dev eth3
    Run		sudo ip a a 10.0.1.134/24 dev eth3
    Run		sudo ip a a 10.0.1.135/24 dev eth3
    Run		sudo ip a a 10.0.1.136/24 dev eth3
    Run		sudo ip a a 10.0.1.137/24 dev eth3
    sleep   10

Enable CB008782
    Perform Recommissioning     type=param  param_path=${Enable_fault_Sig}    operation=update    value=true     timeout=300
    Verify BTS status   should_be_onair=${True}

Kill TRS Process and verify alarms and traffic
    [Arguments]     ${process_8782}
    Execute command on GNB      for pid in $(ps -eaf |grep ${process_8782} |grep -v grep |awk '{print$2}'); do kill -9 $pid; done
    Verify FID 4590 and 6450 and 4592

Ping Test
    ${output}=        Run     ping -c 5 192.168.255.129
    Should contain     ${output}        100% packet loss

Verify FID 4590 and 6450 and 4592
    Verify Alarm        	faultid=6450    should_exist=${True}    occurrences=1   alarm_type=active
    sleep   5
