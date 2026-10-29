*** Settings ***
Documentation
...            [Author]         "Vinay Kumar S T"
...            [Maintenance]    "TRS I & V Tools Bangalore Team"

variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../../resources/common_keywords.robot


*** Keywords ***
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

Fault list after reset_1
    [Arguments]     ${pre_alarm_faultids}    ${post_alarm_faultids_1}
    ${list}=    Create List
    FOR  ${i}   IN       @{post_alarm_faultids_1}
        Run Keyword If  ${i} in ${pre_alarm_faultids}   Continue For Loop
        Append To List  ${list}  ${i}
    END
    [return]    ${list}

Start Ip traffic capture point B file mode
    [Arguments]       ${capture_device}      ${uplane_val}=True          ${alias}=default
    Traffic Capture Start     capture_device=${capture_device}   mode=file  measurement_point=Transport_Interface   uplane_capturing=${uplane_val}
    ...    timeout=120    alias=${alias}
    Sleep    10

Make 5g Call
    Call Setup    lte=device_1:data	verify_attach=${False}
    Call Start	  lte=device_1:data	profile=udp_10K_dl	iperf_section=device1
    Call Start	  lte=device_1:data	profile=udp_10K_ul	iperf_section=device1
    BuiltIn.Sleep    120
    Call Stop	  lte=device_1:data	profile=udp_10K_ul	iperf_section=device1
    Call Stop	  lte=device_1:data	profile=udp_10K_dl	iperf_section=device1
    Call Teardown    lte=device_1:data

Get Current Alarm List
	${alarms}=	Verify Alarm	alarm_type=active
	${alarm_faultids_list}=	Create List
	${alarm_faultids_list}=	Create fault id List	${alarms}
	[return]	${alarm_faultids_list}

Verify Pre Fragmentation with Traffic
	${pre_alarm_faultids}=    Get Current Alarm List
	Traffic Capture Start	capture_device=oam_device	mode=file  measurement_point=Transport_Interface    uplane_capturing=${True}   alias=pcap1
	Make 5g Call
	${pcap_path}=	Traffic Capture Stop    mode=file	alias=pcap1
	Analyse Pcap	 pcap_filename=${CURDIR}/${pcap_path}	analysis=verify_frag_messages
	Analyse Pcap	 pcap_filename=${CURDIR}/${pcap_path}	analysis=verify_isakmp
	${post_alarm_faultids}=     Get Current Alarm List
	${alarms_post_execution}=   Fault list after reset  ${pre_alarm_faultids}   ${post_alarm_faultids}
	Should Be Empty    ${alarms_post_execution}
	[Teardown]	Run Keyword and Ignore Error	Traffic Capture Stop    mode=file	alias=pcap1

Verify Pre Fragmentation with ICMP
	[Arguments]	${alias}
	${pre_alarm_faultids}=    Get Current Alarm List
	Traffic Capture Start	capture_device=oam_device	mode=file  measurement_point=Transport_Interface    uplane_capturing=${True}  alias=${alias}
	Setup Remote Access	remote_device=bts_MPlane	alias=session1
	${stdout_2}=	Execute Interactive Remote Command	command=ping -I ${src_ip} ${dest_ip} -s ${mtu_size} -c 100    alias=session1
	Sleep  30s
	${pcap_path1}=	Traffic Capture Stop    mode=file	alias=${alias}
	Analyse Pcap	 pcap_filename=${CURDIR}/${pcap_path1}	analysis=verify_frag_messages
	Analyse Pcap	 pcap_filename=${CURDIR}/${pcap_path1}	analysis=verify_isakmp
	${post_alarm_faultids}=     Get Current Alarm List
	${alarms_post_execution}=   Fault list after reset  ${pre_alarm_faultids}   ${post_alarm_faultids}
	Should Be Empty    ${alarms_post_execution}
	[Teardown]	Run Keyword and Ignore Error	Traffic Capture Stop    mode=file	alias=${alias}