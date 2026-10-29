*** Settings ***
Documentation
    ...     [Procedure]             "5GC000994_B_Multiple Twamp Sessions with different REWAIT Timers"
    ...      [SCF]                   "scfc_vlan_IPv4.xml"
    ...     [Date]                  "21-01-21"
    ...     [Author]                "Monika Parasar"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Feature_ID]            "5GC000994"
    ...     [Validation_status]     "Validated"
    ...     [Validated_TestLine]    "5G-9001"

#Force Tags    SM TRSIV Test 3        CRT


variables       ta_e2e_bts_trs_fw
#Resource        setup/framework.robot
Resource        ${CURDIR}/../resources/common_keywords.robot


#Suite Setup     Setup Oamops
#Suite Teardown  Teardown Oamops

Suite Setup     Pre-conditions for testsuite
Suite Teardown    Post-conditions for testteardown


*** Variables ***
@{source_port}		5001            5002            5003            5004            5005            5006            5007
...        5008        5009            5010
@{Vlan_id}	1810         1814         1818         1822
@{Interface_ip}		10.0.3.209      10.0.3.213          10.0.3.217          10.0.3.221
@{Broadcast_ip}         10.0.3.211      10.0.3.215          10.0.3.219          10.0.3.223


*** Test Cases ***
#[1]CB006886_994B_Multiple Twamp Sessions with different REWAIT Timers.
[1][1.0] Multiple Twamp Sessions with different REWAIT Timers.


#    Precondition
	Perform Commissioning 		scf_file=${twamp_base_scf}      verify_bts_status=false		 timeout=600     alias=default
    sleep       600
##    Call Setup      5g=asik_vlan:data    parallel=${False}    verify_attach=${False}   attach=${False}
##    Sleep   60
	Perform Recommissioning	 type=delta		 delta_file=addition_10_Twamp_reflector.xml		 timeout=600
	Read TWAMP Session IP
#	Send Twamp packets and Check for sequence Number 		eth3_1			 False
	Send Twamp packets and Check for sequence Number                eth3_1
	Sleep 	300
#	Send Twamp packets and Check for sequence Number 		eth3_2			 True
	Send Twamp packets and Check for sequence Number                eth3_2
#    Verify unexpected alarms
	[Teardown]			Run Teardown Keyword

*** Keywords ***
Precondition
    FOR    ${i}        IN RANGE        0    4
           Run		sudo ip link add link eth3 name eth3.${Vlan_id}[${i}] type vlan id ${Vlan_id}[${i}]
           Run		sudo ip addr add ${Interface_ip}[${i}]/30 brd ${Broadcast_ip}[${i}] dev eth3.${Vlan_id}[${i}]
           Run		sudo ip link set dev eth3.${Vlan_id}[${i}] up
    END
    FOR  ${i}  IN RANGE   1  9
           Run		sudo ip a a 10.0.1.13${i}/24 dev eth3
    END

Read TWAMP Session IP
	${Twamp_reflector_ip} =			Create List
	FOR   ${i}  	IN RANGE		1		6
		${reflector_ip} =		Get Parameter 		param_path=TWAMPREFLECT-${i}:twampReflectorLocalIpAddressDN:localIpAddr
		Append To List 			${Twamp_reflector_ip}		 ${reflector_ip}
	END
	${Twamp_Src_IP} = 	Run		sudo ifconfig -a eth3.2733 | grep inet | awk -F ' ' '{print $2}'| head -1
	Set Suite Variable 		${Twamp_reflector_ip}			 ${Twamp_reflector_ip}
	Set Suite Variable 		${Twamp_Src_IP}					 ${Twamp_Src_IP}

Send Twamp packets and Check for sequence Number
	[Arguments]	${alias_name}
	Traffic Capture Start 		capture_device=vm_eth3_interface		 alias=${alias_name}
	FOR 		${i}		IN RANGE	0		5

	Run	python ${Twamp_sender_command}

#	Run 	python /home/ute/MN/UTE/robotws/testsuite/Bangalore/TRS/E2E_BTS_TRS_FW/fw_user_path/testcases/resources/
#	...	twamp_reflector/twampy.py sender -i 6000 ${Twamp_reflector_ip}[${i}]:5018 ${Twamp_Src_IP}:${source_port}
#	...	[${i}] --padding 1368 --tos 252 -c 10 > twamp_port_5018.txt & echo $! > pid.txt
	END
	Sleep 	700

	Run	python ${Twamp_sender_command_1}

#	Run 	python /home/ute/MN/UTE/robotws/testsuite/Bangalore/TRS/E2E_BTS_TRS_FW/fw_user_path/testcases/resources/
#	...	twamp_reflector/twampy.py sender -i 600 ${Twamp_reflector_ip}:5018 ${Twamp_Src_IP}:${source_port}
#	...	--padding 1368 --tos 252 -c 10 > twamp_port_5018.txt & echo $! > pid.txt
	Sleep   80
	${TWAMP_session} =		Traffic Capture Stop 	alias=${alias_name}
#	Convert Tshark Log to text file 		${TWAMP_session}		 ${alias_name}.txt
	FOR 		${i}		IN RANGE	0		5
            Set Suite variable      ${Twamp_reflector_ip_1}   ${Twamp_reflector_ip}[${i}]
#		${reflector_count_set} =		Run Keyword If  '${i}'>='5'		 Set Variable		 ${reflector_count_set}
#	...	ELSE		 Set Variable		 False
#		Analyse Wireshark trace for sender and reflector    ${alias_name}.txt    ${reflector_count_set}      ${Twamp_reflector_ip}[${i}]
    Analyse Pcap    pcap_filename=${TWAMP_session}     filter_file_name=${Twamp_multi_session_reflector}    analysis=Twamp_multi_session_reflector
    END

Convert Tshark Log to text file
	[Arguments]			${log_file}			${txt_file}

	Run	chmod 755 ${log_file} && ${tshark_exe} -r ${log_file} -T fields -E separator=, -e ${twamp_seq} -e ip.src >execution_logs/${txt_file}

#	Run 	chmod 755 ${log_file} && tshark -o twamp.port:5000,5001,5002,5003,5004,5005,5006,5007,5008,5009,5010 -r
#	...	${log_file} -T fields -E separator=, -e twamp.seqnum.reflector -e ip.src >execution_logs/${txt_file}

Analyse Wireshark trace for sender and reflector
    [Arguments]         ${txt_file}     ${reflector_count_set}          ${Twamp_reflector_ip}
	${pass_count}= 		Set Variable		 0
	${reflector_sequence_count}= 		Run Keyword If 		'${reflector_count_set}'=='True'	Set Variable		 100
	...		ELSE	 Set Variable		 0
	${reflector_sequence_count} = 		Set Variable 		0
	${file} = 		OperatingSystem.Get File         execution_logs/${txt_file}		 encoding_errors=ignore
	FOR		${sequence_count} 		IN RANGE		 0		99
			${status} = 	Run Keyword And Return Status 		Should Match Regexp
			...	${file}	 	(?i)${reflector_sequence_count},${Twamp_reflector_ip}.*
			${reflector_sequence_count} = 	Evaluate 		${reflector_sequence_count}+1
			${pass_count} =     Run Keyword If      '${status}'=='True'		 Evaluate	 ${pass_count}+1
	...		ELSE 	Set Variable 		${pass_count}
	END
Run Teardown Keyword
	Run Keyword And Ignore Error 		Traffic Capture Stop		 alias=eth3_1
	Run Keyword And Ignore Error 		Traffic Capture Stop		 alias=eth3_2
    FOR    ${i}        IN RANGE        0    4
           Run     sudo ip link delete eth3.${Vlan_id}[${i}]
    END
#    Call Teardown   5g=asik_vlan:data
