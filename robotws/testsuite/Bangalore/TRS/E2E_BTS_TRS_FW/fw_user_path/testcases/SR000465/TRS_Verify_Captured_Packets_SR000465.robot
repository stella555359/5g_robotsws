*** Settings ***
Documentation
...              [Author]      "Shankar Manurwar"
...              [Maintenance] "TRS I & V Tools Bangalore Team"


Resource        ${CURDIR}/../resources/common_keywords.robot
 
variables       ta_e2e_bts_trs_fw
Suite Setup        Run Keywords    Suite Setup Preconditions
...        AND     Setup Oamops
Suite Teardown     Run Keywords        Suite Teardown Postconditions
...        AND     Teardown Oamops


***Test Cases ***
[1][2.0] TRS_Verify_Captured_Packets_SR000465

    Add routes
    Bring up On air
    Start the traffic
    Point A Traffic capture and verify      ${traffic_1}
    Point B Traffic capture and verify      ${traffic_2}

***Keywords***

Bring up On air

    Call Setup     lte=Device_CUS_465:data    parallel=${False}    attach=${False}      verify_attach=${false}    timeout=120
    Sleep   60
    Verify BTS status   should_be_onair=${True}
    sleep   10


Start the traffic

    Configure UE       lte=Device_CUS_465:data     command=ue_attach id=1 cell=12
    Sleep   5
    Configure UE       lte=Device_CUS_465:data     command=trf_data_start ue=1 dir=dl_and_ul protocol=udp Mbps_dl=10 Mbps_ul=10
    Sleep   5


Point A Traffic capture and verify

    [Arguments]     ${pcap_1}
    Traffic Capture Start   capture_device=oam_device   mode=file   measurement_point=NE_Terminated
    ...     uplane_capturing=True   timeout=12     alias=${pcap_1}
    sleep   60
    ${filename_A}=  Traffic Capture Stop   mode=file      alias=${pcap_1}      timeout=100
    Analyse Pcap    pcap_filename=${filename_A}     filter_file_name=${traffic_filter_file_name}    analysis=UL_Traffic_check1
    Analyse Pcap    pcap_filename=${filename_A}     filter_file_name=${traffic_filter_file_name}     analysis=DL_Traffic_check1

Add routes

    Run     cp /home/ute/MN/UTE/robotws/testsuite/Bangalore/TRS/E2E_BTS_TRS_FW/fw_user_path/testcases/CB008782/rise.csv ${resources}
    Run     sudo killall egate edaemon
    sleep   10

Point B Traffic capture and verify

    [Arguments]     ${pcap_1}
    Traffic Capture Start   capture_device=oam_device   mode=file   measurement_point=Transport_Interface
    ...     uplane_capturing=True   timeout=120    alias=${pcap_1}
    sleep   60
    ${filename_A}=  Traffic Capture Stop   mode=file      alias=${pcap_1}      timeout=100
    Analyse Pcap    pcap_filename=${filename_A}     filter_file_name=${traffic_filter_file_name}    analysis=UL_Traffic_check1
    Analyse Pcap    pcap_filename=${filename_A}     filter_file_name=${traffic_filter_file_name}     analysis=DL_Traffic_check1
