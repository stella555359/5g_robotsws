*** Settings ***
Documentation
...		[Author]				"Meghana J"
...		[Procedure]				Verify Iterative BTS reset
...		[Validated_TestLine]	10_2_T0401-ASIB07
...		[Config_Comments]		 ASIB07
...		[Funtion_Hash_Tags]		All rat on air

*** Keywords ***
Verify on air status
	Verify Bts Status    should_be_onair=${True}      timeout=100

Reset And Verify RAT
    [Arguments]    ${rat_type}
    ${pre_alarms}=        Verify Alarm    alarm_type=active
    ${pre_faultids}=      Create fault id List    ${pre_alarms}

    Reset    operation=reset_rat    should_be_onair=True    wait_for=300    rat=${rat_type}    timeout=200
    Wait Until Keyword Succeeds    ${WAIT_TOTAL}    ${WAIT_INTERVAL}    Verify Bts Status
    ...    req_rat=${rat_type}    should_be_onair=${True}    timeout=90    alias=default

    ${post_alarms}=       Verify Alarm    alarm_type=active
    ${post_faultids}=     Create fault id List    ${post_alarms}
    ${alarm_diff}=        Fault list after reset    ${pre_faultids}    ${post_faultids}

Create fault id List
	[Arguments]		${list}
	${length}=	Get Length	${list}
	${list1}=	Create List
	FOR	${i}	IN RANGE	${length}
		Append To List	${list1}	${list[${i}]['faultId']}
	END
	[return]	${list1}

Fault list after reset
	[Arguments]		${pre_alarm_faultids}	${post_alarm_faultids}
	${list}=	Create List
	FOR	${i}	IN		@{post_alarm_faultids}
		Run Keyword If	${i} in ${pre_alarm_faultids}	Continue For Loop
		Append To List	${list}	${i}
	END
	[return]	${list}

Initiate 3G Attach and verify call
    FOR    ${i}    IN RANGE    1    11
	    Backhaul link fluctuation
        ${UE_IP}=    Initiate 3G Attach And Get UE IP
        Setup Remote Access    remote_device=ftp_user    timeout=60    alias=ftp
        Verify Ping Success From FTP    ${UE_IP}
        Traffic Capture Start        capture_device=oam_device   mode=file   measurement_point=NE_Terminated  uplane_capturing=True   timeout=120
        Call Start      wcdma=device_1:data        profile=udp_10k_dl       iperf_section=device1
        Call Start      wcdma=device_1:data        profile=udp_10k_ul       iperf_section=device1
        Sleep    60
        Call Stop       wcdma=device_1:data        profile=udp_10k_dl        iperf_section=device1
        Call Teardown       wcdma=device_1:data
        ${Point_A_Capture}=   Traffic Capture Stop      mode=file       timeout=120
        ${Verify_nbap_packets}=     Analyse Pcap    pcap_filename=${Point_A_Capture}    analysis=Verify_nbap_packets
        ${UDP_UL}=		Analyse Pcap    pcap_filename=${Point_A_Capture}        analysis=UDP_UL
        ${UDP_DL}=		Analyse Pcap    pcap_filename=${Point_A_Capture}        analysis=UDP_DL
        Verify Alarm    faultid=16    should_exist=${False}
        Verify Alarm    faultid=17    should_exist=${False}
    END

Backhaul link fluctuation
    Configure Switch    link1    shutdown_te_interface
    Sleep	10
    Verify Ping Should Fail	10.41.220.62
    Setup Remote Access    remote_device=bts    timeout=20    alias=bts
    Verify Ping Fails From BTS    10.63.24.204
    Verify Bts Status    req_rat=wcdma    should_be_onair=${False}    timeout=10    alias=default
    Configure Switch    link1    noshutdown_te_interface
    Verify Ping Should Pass    10.41.220.62
    Sleep   30
    Verify Ping Success    10.63.24.204
    Verify Bts Status    req_rat=wcdma    should_be_onair=${True}    timeout=10    alias=default

Verify Ping Should Fail
    [Arguments]    ${ip}
    ${rc}    ${out}=    Run And Return Rc And Output    ping -c 5 ${ip}
    Log    ${out}
    Should Not Be Equal As Integers    ${rc}    0

Verify Ping Should Pass
    [Arguments]    ${ip}
    ${rc}    ${out}=    Run And Return Rc And Output    ping -c 10 ${ip}
    Log    ${out}
    Should Be Equal As Integers    ${rc}    0

Initiate 3G Attach And Get UE IP
    ${ue_ip_dict}=    Call Setup    wcdma=device_1:data    parallel=${False}    verify_attach=${False}
    ${ip}=    Get From Dictionary    ${ue_ip_dict}    ${3G_UE}
    Log    UE IP assigned: ${ip}
    Should Match Regexp    ${ip}    ^(10|9a00)
    [Return]    ${ip}

Verify Ping Fails From BTS
    [Arguments]    ${ip}
    ${out}=    Remote Command Execute
    ...    command=ping -c 5 ${ip}
    ...    alias=bts
    Log    ${out}
    Should Not Contain    ${out}    bytes from

Verify Ping Success
    [Arguments]    ${ip}
    ${output}=    Remote Command Execute
    ...    command=ping -c 5 ${ip}
    ...    alias=bts
    Log    ${output}
    Should Contain    ${output}    bytes from

Verify Ping Success From FTP
    [Arguments]    ${ip}
    ${out}=    Remote Command Execute
    ...    command=ping -c 100 ${ip}
    ...    alias=ftp
    Log    ${out}
    Should Contain    ${out}    bytes from