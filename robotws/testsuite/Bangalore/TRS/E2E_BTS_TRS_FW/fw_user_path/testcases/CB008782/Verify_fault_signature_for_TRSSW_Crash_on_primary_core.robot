*** Settings ***
Documentation
...              [Author]      "Shankar Manurwar"
...              [Maintenance] "TRS I & V Tools Bangalore Team"



Library     taf.sbts.oam.coam.admin.interface.admin
Resource        ${CURDIR}/../resources/common_keywords.robot
     
#Suite Setup	    Run Keywords    Setup Oamops
#...    AND     Start Syslog     log_dir=${EXECDIR}/execution_logs       log_name=background_syslog.txt   file_limit=50000000
#...    alias=collect_syslog
#Suite Teardown    Run Keywords      Teardown Oamops
#...    AND     Stop Syslog       alias=collect_syslog 

#Suite Setup     Run Keywords    Pre-conditions for testsuite
#Suite Teardown     Run Keywords         Post-conditions for testteardown



***Test Cases ***
[1][1.0] Verify_fault_signature_for_TRSSW_Crash_on_primary_core

    Add routes
#    Bring up On air
#    Start the traffic and verify traffic        ${traffic_1}
    Enable CB008782
#    Sleep    900
    TRS Process 1
#    Sleep    900
    TRS Process 2
#    Sleep    1800
    TRS Process 3
#    Sleep    900
    TRS Process 4

***Keywords***

TRS Process 1

    Kill TRS Process and verify alarms and traffic        ${process_name1}
#    Start the traffic and verify traffic        ${traffic_2}
    Trigger site reset and verify alarm 4590 should not exist

TRS Process 2

    Kill TRS Process and verify alarms and traffic        ${process_name2}
#    Start the traffic and verify traffic        ${traffic_3}
    Trigger site reset and verify alarm 4590 should not exist

TRS Process 3

    Kill TRS Process and verify alarms and traffic        ${process_name3}
#    Start the traffic and verify traffic        ${traffic_4}
    Trigger site reset and verify alarm 4590 should not exist

TRS Process 4

    Kill TRS Process and verify alarms and traffic        ${process_name4}
#    Start the traffic and verify traffic        ${traffic_5}
    Trigger site reset and verify alarm 4590 should not exist

Bring up On air

    Call Setup     lte=Device_CUS:data    parallel=${False}    attach=${False}      verify_attach=${false}    timeout=120
#    Sleep	10
    Verify BTS status   should_be_onair=${True}
#    sleep	10


Start the traffic and verify traffic

    [Arguments]     ${pcap_1}
    Traffic Capture Start  capture_device=oam_device   mode=file   measurement_point=NE_Terminated   uplane_capturing=True   timeout=120
	...     alias=${pcap_1}
#    sleep	5
    Verify Alarm           faultid=61641   should_exist=${True}

    Configure UE       lte=Device_CUS:data     command=ue_attach id=1 cell=11
#    Sleep	5
    Configure UE       lte=Device_CUS:data     command=trf_data_start ue=1 dir=dl_and_ul protocol=udp kbps_dl=20000 kbps_ul=20000
#    Sleep	60

    ${filename_A}=  Traffic Capture Stop   mode=file      alias=${pcap_1}      timeout=100

    Analyse Pcap    pcap_filename=${filename_A}     filter_file_name=${traffic_filter_file_name}    analysis=UL_Traffic_check
    Analyse Pcap    pcap_filename=${filename_A}     filter_file_name=${traffic_filter_file_name}     analysis=DL_Traffic_check

Trigger site reset and verify alarm 4590 should not exist

    Reset Bts    should_be_onair=${False}
#    Sleep	120
#    Wait Until Keyword Succeeds     5mins   5sec    Verify BTS status   should_be_onair=${True}
#    Verify Alarm        faultid=4590     should_exist=${False}    alarm_type=istory     load_history=True
    Wait Until Keyword Succeeds     5mins   5sec    Verify Alarm        faultid=4590     should_exist=${False}    alarm_type=active

Add routes

    Run     cp ${rise_csv_path} ${resource_path}
    Run     sudo killall egate edaemon
    Run     sudo ipsec stop
#    sleep	10

Enable CB008782

    Perform Recommissioning     type=param  param_path=${Enable_fault_Sig}    operation=update    value=true     timeout=300
#    Verify BTS status   should_be_onair=${True}

Kill TRS Process and verify alarms and traffic
    [Arguments]     ${process_8782}
    Execute command on GNB      for pid in $(ps -eaf |grep ${process_8782} |grep -v grep |awk '{print$2}'); do kill -9 $pid; done
#    sleep	80
    Wait Until keyword Succeeds     2mins   5sec      Ping Test
#    sleep	300
#    Wait Until Keyword Succeeds     5mins   5sec    Verify BTS status   should_be_onair=${True}
    Verify FID 4590 and 6450 and 4592

Ping Test
    ${output}=        Run     ping -c 1 192.168.255.129
    Should contain     ${output}        100% packet loss


Verify FID 4590 and 6450 and 4592

    Verify Alarm        	faultid=6450    should_exist=${True}    occurrences=1   alarm_type=active
#    sleep	5
#   Wait Until Keyword Succeeds     10mins   5sec    Verify Alarm        faultid=4590     should_exist=${True}   occurrences=1   alarm_type=history
	...     load_history=True
#    sleep	5
#   Wait Until Keyword Succeeds     5mins   5sec  Verify Alarm        faultid=4592     should_exist=${True}   occurrences=1   alarm_type=history
	...     load_history=True
#    sleep	30

    Wait Until Keyword Succeeds     6mins       5sec    Verify Alarm        faultid=4592     should_exist=${True}   occurrences=1   alarm_type=active
#    sleep	5
    Wait Until Keyword Succeeds     10mins      5sec    Verify Alarm        faultid=4590     should_exist=${True}   occurrences=1   alarm_type=active
#    sleep	30
