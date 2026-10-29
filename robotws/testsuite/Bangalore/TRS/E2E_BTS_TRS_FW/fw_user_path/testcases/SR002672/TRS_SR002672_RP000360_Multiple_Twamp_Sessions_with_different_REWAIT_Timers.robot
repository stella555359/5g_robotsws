*** Settings ***
Documentation
...   [Procedure]          "Configuration of 10 TWAMP sender session.Verification of message size for TWAMP sender and reflector messages"
...   [Date]               "Date of creation DD:MM:YY"
...   [Author]             "Monika"
...   [QC_Path]            "QC_Path in Test Plan"
...   [QC_ID]              "QC_ID in Test Lab for reporting"
...   [Feature_ID]         "RP000360"
...   [Funtion_Hash_Tags]  "TWAMP"
...   [Validation_status]  Validated and Passed
...   [Validated_TestLine] 3737
...   [Validation Date]    MM-DD-YY


Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
Resource        ${CURDIR}/../resources/common_keywords.robot

Suite Setup        Run Keywords    Suite Setup Preconditions
...        AND     Setup Oamops
Suite Teardown     Run Keywords        Suite Teardown Postconditions
...        AND     Teardown Oamops

*** Variables ***
@{source_port}          5001            5002            5003            5004            5005            5006            5007 5008 5009         5010
@{Vlan_id}                                                  200         201         202         203             204         205         206      207
@{Interface_ip}                                             10.0.3.209      10.0.3.213          10.0.3.217          10.0.3.221          10.0.3.225
...	10.0.3.229          10.0.3.233          10.0.3.237
@{Broadcast_ip}                                             10.0.3.211      10.0.3.215          10.0.3.219          10.0.3.223          10.0.3.227
...	10.0.3.231          10.03.235           10.0.3.239


*** Test Cases ***
[1][1.0] TRS_SR002672_RP000360_Multiple Twamp Sessions with different REWAIT Timers
	Perform Commissioning 		verify_bts_status=false		 timeout=1200
    sleep       900
	Perform Recommissioning	 type=delta		 delta_file=addition_10_Twamp_reflector.xml		 timeout=600
	Read TWAMP Session IP
	Send Twamp packets and Check for sequence Number
	Sleep 	300
	Send Twamp packets and Check for sequence Number
	[Teardown]			Run Teardown Keyword

*** Keywords ***


Read TWAMP Session IP
	${Twamp_reflector_ip} =			Create List
	FOR   ${i}  	IN RANGE		1		11
			${reflector_ip} =		Get Parameter 		param_path=TWAMPREFLECT-${i}:twampReflectorLocalIpAddressDN:localIpAddr
			Append To List 			${Twamp_reflector_ip}		 ${reflector_ip}
    END
	Set Suite Variable 		${Twamp_reflector_ip}			 ${Twamp_reflector_ip}
	Set Suite Variable 		${Twamp_Src_IP}					 ${Twamp_Src_IP}

Send Twamp packets and Check for sequence Number
	Traffic Capture Start 		capture_device=vm_eth3_interface		 alias=${alias_name}
	Sleep 	700
	${TWAMP_session} =		Traffic Capture Stop 	alias=${alias_name}


Analyse Wireshark trace for sender and reflector
    [Arguments]         ${txt_file}     ${reflector_count_set}          ${Twamp_reflector_ip}
	${pass_count}= 		Set Variable		 0
	${reflector_sequence_count}= 		Run Keyword If 		'${reflector_count_set}'=='True'		 Set Variable		 100
	...		ELSE	 Set Variable		 0
	${reflector_sequence_count} = 		Set Variable 		0
	${file} = 		OperatingSystem.Get File         execution_logs/${txt_file}		 encoding_errors=ignore
	FOR		${sequence_count} 		IN RANGE		 0		99
			${status} = 	Run Keyword And Return Status 		Should Match Regexp		 ${file}	 (?i)${reflector_sequence_count},
			...	${Twamp_reflector_ip}.*
	 		${reflector_sequence_count} = 	Evaluate 		${reflector_sequence_count}+1
			${pass_count} =     Run Keyword If      '${status}'=='True'		 Evaluate	 ${pass_count}+1
			...		ELSE 	Set Variable 		${pass_count}
	END
Run Teardown Keyword
	Traffic Capture Stop		 alias=eth3_1
	Traffic Capture Stop		 alias=eth3_2
