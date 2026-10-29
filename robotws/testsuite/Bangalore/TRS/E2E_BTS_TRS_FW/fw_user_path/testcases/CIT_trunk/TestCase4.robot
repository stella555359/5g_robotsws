*** Settings ***
Documentation
...	[Author]	"Ankita"


#Resource  setup/framework.robot
#Resource  testcases/resources/route_operations.robot
#Resource  testcases/resources/common_keywords.robot
Resource  ../resources/route_operations.robot
Resource  ../resources/common_keywords.robot
#Resource    /home/ute/MN/UTE/robotws/testsuite/Bangalore/TRS/E2E_BTS_TRS_FW/fw_user_path/testcases/resources/common_keywords.robot

Library           ute_fsmaccess
Library           String

Suite Setup             Run Keywords    Suite Setup Preconditions
...             AND             Setup Oamops
Suite Teardown     Run Keywords         Suite Teardown Postconditions
...             AND             Teardown Oamops
#Suite Setup                Setup Oamops
#Suite Teardown                Teardown Oamops

Force Tags    CA_E2ET_BTSTRSPZ        SBTS00   SBTS21B        SBTS22R1    SBTS22R2    4G_FDD     QCD_MN_RAN    QCP_RAN_VRF      CIT

*** Variables ***
${twamp_server_ip}			10.45.138.242
${twamp_dest_port_moc_path}		TWAMP-1:destPort
${twamp_dest_IP_address}		TWAMP-1:destIpAddress
${twamp_server_user}			ute
${twamp_server_password}		ute
${twamp_server_prompt}			#

*** Test Cases ***
#[1.0] SBTS_Transport_Network_Scenario_5VLAN_Ipv6_Opt_Dualbackhaul
[1.0] SBTS_Transport_Network_Scenario_5VLAN_Ipv6_Opt_Dualbackhaul

     Perform Commissioning	verify_bts_status=True     timeout=600

##Unexpected alarms
	Verify Alarm    expected_alarms=${expected_alarms}
    sleep       400
#	Traffic Capture v6
#	All RAT V6 Calls
	Stateful Refelctor For Twamp
##Snapshot
##Unexpected alarms
	Verify Alarm    expected_alarms=${expected_alarms}
	[Teardown]              Run	ps -eaf | grep "twamp" | grep -v grep | awk '{print $2}' | xargs kill

#CIT_Call
#    Make 4g Cal
*** Keywords ***
Stateful Refelctor For Twamp
	BTS As Sender
	Read IP Parameters
	Create 32 Sender Sessions
#	Verify 32 sessions successful creation

BTS As Sender
    sleep   100
	Pm Counters Start     analysis=verify_twamp_counters       counter_analysis_file=${counter_analysis_file_name}
	sleep		80
	Read TWAMP Session IP
#s	Traffic Capture Start   capture_device=oam_device    mode=file  measurement_point=NE_Terminated
#	...		uplane_capturing=True  timeout=120  alias=no_password
	Enable TWAMP Reflector
	Sleep	120
#s	[Teardown]	Check if SBTS-B received packets_server
#s	Traffic Capture Stop   mode=file  alias=no_password  timeout=120
#s	Setup Remote Access	remote_device=bts
#s	Unzip The Traffic Capture File
#s	${TWAMP_session_pointB}=	Remote Command Execute    command=cd /lte1460/; ls *.pcap
#s	${TWAMP_session}=	Get File From Remote Host      /lte1460/${TWAMP_session_pointB}      ./execution_logs/${TWAMP_session_pointB}
#s    FOR		${i}		IN RANGE		1		11
#s			${twamp_DSCP} =    Get Parameter    param_path=TWAMP-${i}:twampDscp
#s			Set Suite Variable    ${twamp_DSCP}		${twamp_DSCP}
#s			Analyse Pcap    analysis=twamp_sender_request   pcap_filename=${TWAMP_session}     filter_file_name=${filter_file_name}
#s			Analyse Pcap    analysis=twamp_sender_reply     pcap_filename=${TWAMP_session}     filter_file_name=${filter_file_name}
#s	END
#s    Teardown Remote Access
	Verify Pm Counters    analysis=verify_twamp_counters       counter_analysis_file=${counter_analysis_file_name}

Read IP Parameters
    ${twamp_reflector_ip} =    Get Parameter    param_path=${twamp_reflector_path}
    Set Suite Variable    ${twamp_reflector_ip}    ${twamp_reflector_ip}
    ${bts_ipV4_address_string}=    Run    ifconfig -a eth0 | awk '/inet addr/ {print $2}'
#    ${out}    ${lmp_ip_addr}=    Split String From Right    ${bts_ipV4_address_string}    :    max_split=1
#    Set Suite Variable    ${lmp_ip_addr}    ${lmp_ip_addr}
	${lmp_ip_addr}=    Run     ifconfig -a eth0 | awk '/inet/ {print $2}' |head -1
    Set Suite Variable    ${lmp_ip_addr}    ${lmp_ip_addr}

Create 32 Sender Sessions
	Run	  killall -9 python
	sleep 	2
    @{source_port_list}=    Create List
     FOR    ${source_port}    IN RANGE    5020    5052
        Append To List    ${source_port_list}    ${source_port}
#ankita	Run  python ${CURDIR}/../resources/twampy.py sender \ -i 30000000 ${twamp_reflector_ip}:5018 ${lmp_ip_addr}:${source_port}
#ankita	...		--padding 1368 --tos 252 > twamp_port_5018.txt & echo $! > pid.txt
        Sleep    2
     END
    Set Suite Variable    ${source_port_list}    ${source_port_list}

Verify 32 sessions successful creation
#    Wait Until Keyword Succeeds    5 minute    60 sec    Verify twamp sender destination port
    Setup Remote Access	remote_device=bts
#    Remote Command Execute    command=ps -eaf | grep -i "/opt/trs/bin/tplCliTest twamp getActiveTwampReflectorSessions" |
#    ...		awk {'print $2'} | head -n -1 | tail -n+2 | xargs kill
    ${New_Line}=    Remote Command Execute    command=/opt/trs/bin/tplCliTest twamp getActiveTwampReflectorSessions | grep -v "*"
    Comment    *
    @{list_of_dict}=    Create List
    FOR    ${item}    IN RANGE    0    223    7
        ${start_index}=    Set Variable    ${item}
        ${end_index}    Evaluate    ${item}+7
        @{lines}=    Split To Lines    ${New_Line}    ${start_index}    ${end_index}
        Twamp Reflector session verify    @{lines}
        Comment    Append To List    ${list_of_dict}    ${dict_var_temp}
    END
    [Teardown]	Teardown Remote Access

Get Twamp Sender destport Details
    Setup Remote Access	remote_device=bts
    ${dscp_values}=    Remote Command Execute    command=/opt/trs/bin/tplCliTest twamp getActiveTwampReflectorSessions |
	...		grep -v "*" | grep "Dest Port"
#    Remote Command Execute    command=ps -eaf | grep -i "/opt/trs/bin/tplCliTest twamp getActiveTwampReflectorSessions" |
#awk {'print $2'} | head -n -1 | tail -n+2 | xargs kill
    Comment    *
    Comment    ${dscp_values_}    Get Length    ${dscp_values}
    @{dscp_values_list}    Split To Lines    ${dscp_values}
    @{DestPort_ist}=    Create List
    FOR    ${item}    IN    @{dscp_values_list}
        ${out}    ${DscpVal}=    Split String From Right    ${item}    :    max_split=1
        ${DestPort}=    Convert To Integer    ${DscpVal}
        Append To List    ${DestPort_ist}    ${DestPort}
    END
    Sort List    ${DestPort_ist}
    Set Suite Variable    ${DestPort_ist}    ${DestPort_ist}
    [Teardown]	Teardown Remote Access

Verify twamp sender destination port
    Get Twamp Sender destport Details
    Should Be Equal    ${source_port_list}    ${DestPort_ist}

Twamp Reflector session verify
    [Arguments]    @{listitems}
    &{dict_var_temp}=    Create Dictionary
    : FOR    ${listvalue}    IN    @{listitems}
    \    @{list_var2} =    Split String    ${listvalue}    :    max_split=1
    \    ${str} =    Remove String    @{list_var2}[0]    ${SPACE}
    \    Set To Dictionary    ${dict_var_temp}    ${str}=@{list_var2}[1]
    log    ${dict_var_temp}
    Should Be Equal    ${dict_var_temp['SourceIp']}    ${twamp_reflector_ip}
    Should Be Equal    ${dict_var_temp['DestIp']}    ${lmp_ip_addr}
    Should Be Equal    ${dict_var_temp['SourcePort']}    5018
    Should Be Equal    ${dict_var_temp['Dscp']}    63
    Should Be True    ${dict_var_temp['SequenceNumber']} > 0
    Should Be True    ${dict_var_temp['TimeLapsedsincelastreceivedtwamppacket']} < 900

Validate Snapshot
        [Arguments]             ${snap}
        Run     unzip -o ${snap} -d Sample/
        ${ext_location}=        Run     cat Sample/snapshot_file_list.txt | grep -B 1000 Exte | grep -e "zip:" | tail -1 | awk -F ':' '{print $1}'
        Run     unzip -o Sample/${ext_location} -d Sample/
        ${ExtendedNezip}=       Run     find . -name *Extended*.txz
        Run     xz -d ${ExtendedNezip}
        ${ExtendedNeziptar}=    Run     find . -name *Extended*.tar
	${ext_content}=		Run     tar xvf ${ExtendedNeziptar} -C Sample/
        log     ${mandatoryfiles}
        :FOR    ${ELEMENT}    IN    @{mandatoryfiles}
        \       Should Match Regexp     ${ext_content}  ${ELEMENT}

All RAT V6 Calls
	Call Setup      lte=device_1:data       wcdma=device_1:voice     gsm=device_1:voice      parallel=${True}	ipv4_or_6=ipv6
	Call Start      lte=device_1:data       profile=udp_ul	iperf_device=ipv6_server
        Call Start      lte=device_1:data       profile=udp_dl	iperf_device=ipv6_server
        Call Start      wcdma=device_1:voice
        Call Start      gsm=device_1:voice
        Sleep   30
	Run Keyword And Ignore Error	Call Stop       lte=device_1:data       profile=udp_ul	iperf_device=ipv6_server
        Run Keyword And Ignore Error	Call Stop       lte=device_1:data       profile=udp_dl	iperf_device=ipv6_server
        Call Stop       wcdma=device_1:voice
        Call Stop       gsm=device_1:voice

Traffic Capture V6
#pointB
	Setup Remote Access	remote_device=bts
	Traffic Capture Start        capture_device=oam_device    mode=file 	measurement_point=NE_Terminated
	...		uplane_capturing=False  	timeout=120	  alias=pointB
	Sleep	30
	Traffic Capture Stop   mode=file  alias=pointB  timeout=120
	Unzip The Traffic Capture File
	${filename_pointB_enb}=	   Remote Command Execute    command=cd /lte1460/; ls *.pcap
	${filename_pointB}=	Get File From Remote Host      /lte1460/${filename_pointB_enb}      ./execution_logs/${filename_pointB_enb}
	Analyse Pcap 	pcap_filename=${filename_pointB}     filter_file_name=${filter_file_name}	analysis=cplane_v6
#pointA
	Traffic Capture Start        capture_device=oam_device    mode=file  measurement_point=Transport_Interface
	...		uplane_capturing=True  timeout=120  alias=pointA
	Sleep	30
	Traffic Capture Stop   mode=file  alias=pointA  timeout=120
	Unzip The Traffic Capture File
	${filename_pointA_enb}=	Remote Command Execute    command=cd /lte1460/; ls *.pcap
	${filename_pointA}=	Get File From Remote Host      /lte1460/${filename_pointA_enb}      ./execution_logs/${filename_pointA_enb}
	Analyse Pcap 	pcap_filename=${filename_pointA}     filter_file_name=${filter_file_name}	analysis=cplane_v6
	[Teardown]	Teardown Remote Access

Unzip The Traffic Capture File
        ${file} =      Run Keyword If	  '${bts_hw_version}'=='fsmr3'     Remote Command Execute    command=cd /lte1460/; ls *.zip
        ...            ELSE IF            '${bts_hw_version}'=='fsmr4'     Remote Command Execute    command=cd /lte1460/; ls *.gz

        Run Keyword And Ignore Error     Remote Command Execute    command=unzip /lte1460/${file} -d /lte1460/
        Run Keyword And Ignore Error     Remote Command Execute    command=gunzip /lte1460/${file} -d /lte1460/
Make 4g Call
       Call Setup    4g=device_1:data	verify_attach=${False}
       Call Start	  4g=device_1:data	profile=udp_10K_dl	iperf_section=device1
       BuiltIn.Sleep    120
       Call Stop	  4g=device_1:data	profile=udp_10K_dl	iperf_section=device1
       Call Teardown    4g=device_1:data

Read TWAMP Session IP
	${source_ip} = 	Get Parameter		param_path=TWAMP-1:sourceIpAddressDN:localIpAddr
	${destination_ip} = 	Get Parameter		param_path=TWAMP-1:destIpAddress
	${message_size} = 	Get Parameter		param_path=TWAMP-1:messageSize
	${message_size_added} =		Evaluate	${message_size} + 18
	Log	${message_size_added}

	Set Suite Variable	${source_ip}	${source_ip}
	Set Suite Variable	${destination_ip}	${destination_ip}
	Set Suite Variable	${message_size_added}	${message_size_added}

Enable TWAMP Reflector
	Setup Enb Fsm Access	host=${twamp_server_ip}		user=${twamp_server_user}
	...		password=${twamp_server_password}	prompt=${twamp_server_prompt} 	alias=twamp_1
	Start Command On Enb		/home/trsiv/twamp/twampserver 5018 > twamp_port_5018.txt & echo $! > pid.txt	alias=twamp_1
	${pid} = 	Execute Command on Enb		cat pid.txt		alias=twamp_1
	Set Suite Variable	${pid}	${pid}

Check if SBTS-B received packets_server
	Sleep	10
	Execute Command On Enb		kill ${pid}		alias=twamp_1
	Get Enb File	/root/twamp_port_5018.txt		./execution_logs/	alias=twamp_1
	Teardown Enb Fsm Access		alias=twamp_1

#Suite Teardown Postconditions
        Run Keyword And Ignore Error    Setup Oamops
        Collect Im Snapshot     timeout=300
        Collect Snapshot        timeout=1200
        [Teardown]        Stop Syslog       alias=collect_syslog
