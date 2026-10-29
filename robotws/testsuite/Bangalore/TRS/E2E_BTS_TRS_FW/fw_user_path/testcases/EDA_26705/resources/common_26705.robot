*** Settings ***
Documentation
...            [Author]         "Sahana T C"
...            [Maintenance]    "TRS I & V Tools Bangalore Team"

Variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../../resources/common_keywords.robot

*** Variables ***
${tc_variables}     testcase_variables.json

*** Keywords ***

BBMOD Reset
    FOR    ${index}    IN RANGE    ${length}
       Reset      operation=reset_unit      dist_name=${BBMODR}      reset_type=Warm
       ...      timeout=300    verify_bts=${False}
       Sleep     200
       Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=active
       Verify Alarm    expected_alarms=${expected_alarms}     check_unexpected_alarms=True
       Collect Snapshot        timeout=900
       Verify Bts Status   should_be_onair=${True}        rat=5g
       Setup Remote Access     remote_device=ftpserver     alias=ftp
       Execute Interactive Remote Command     command=${change_permission}     alias=ftp
       Run Keyword      Make 5G Calls
       Teardown Remote Access     alias=ftp
    END

Make 5G Calls
    Start Ip traffic capture point A file mode       oam_device
    Call Setup    5g=device_3:data    verify_attach=${False}    attach=${True}
    Call Start    5g=device_3:data    profile=udp_100M_ul    iperf_section=device1
    Call Start    5g=device_3:data    profile=udp_100M_dl    iperf_section=device1
    Sleep    20
    Call Stop     5g=device_3:data    profile=udp_100M_ul
    Call Stop     5g=device_3:data    profile=udp_100M_dl
    Call Teardown    5g=device_3:data
    Stop Ip traffic capture in file mode
    Analyse Pcap    pcap_filename=${pcap_file}   analysis=nsa
    Analyse Pcap    pcap_filename=${pcap_file}   analysis=gtp_udp

Start Ip traffic capture point A file mode
    [Arguments]       ${capture_device}      ${uplane_val}=True          ${alias}=default
    Traffic Capture Start     capture_device=${capture_device}    mode=file     measurement_point=NE_Terminated
    ...   uplane_capturing=${uplane_val}    timeout=120    alias=${alias}
    Sleep    10

Stop Ip traffic capture in file mode
    [Arguments]        ${alias}=default
    ${pcap_file}=  Traffic Capture Stop   mode=file   alias=${alias}  timeout=120
    Set Suite Variable     ${pcap_file}

Roll Back
    Run Keyword And Ignore Error        Call Teardown    5g=device_3:data
    Run Keyword And Ignore Error        Stop Ip traffic capture in file mode