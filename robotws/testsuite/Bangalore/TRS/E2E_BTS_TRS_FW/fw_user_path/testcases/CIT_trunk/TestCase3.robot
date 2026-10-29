*** Settings ***
Documentation
...	[Author]	"Ankita"


Library         random
#Resource  setup/framework.robot
Resource  ../resources/route_operations.robot
Resource  ../resources/common_keywords.robot

Suite Setup             Run Keywords    Suite Setup Preconditions
...             AND             Setup Oamops
Suite Teardown     Run Keywords         Suite Teardown Postconditions
...             AND             Teardown Oamops

#Suite Setup       Setup Oamops
#Suite Teardown    Teardown Oamops

#Force Tags    CA_E2ET_BTSTRSPZ        SBTS00	SBTS21A        SBTS20C    4G_FDD    QCD_MN_SRAN        QCP_SRAN_SBTS        CIT
Force Tags    CA_E2ET_BTSTRSPZ        SBTS00   SBTS21B        SBTS22R1    SBTS22R2    4G_FDD     QCD_MN_RAN    QCP_RAN_VRF      CIT

*** Variables ***

${lte_cplane1_dscp_moc_path}		LNBTS-${3295}:cPlaneDscp
${lte_uplane1_dscp_moc_path}		LNBTS-${3295}:qciTab9:dscp
${traffic_filer_file_name}		sanity_traffic_filters.json
${sanity_dscp_update}			sanity_dscp_update.xml
${sanity_dscp_update_20A}                       sanity_dscp_update_20A.xml

${unauthorized_world_writable_files}		ls -l $(find / /ffs/fs{1,2} /nvrd -xdev -type f -user 0 -group 0 -perm +020|sort -u)
${Files_owned_by_root_are_not_writeable_for_other_user}		ls -l $(find / /ffs/fs{1,2} /nvrd -xdev -type f -user 0 -perm +002 | sort -u)

${Files_owned_by_root_with_GID}		ls -l $(find / /ffs/fs{1,2} /nvrd -xdev -type f -user 0 ! -group 0 -perm +020 | sort -u)
${Orphaned_files}			find / /ffs/fs{1,2} /nvrd -xdev -type f | xargs -n 1 ls -l | awk '{print $3}' | grep ^[0-9]*$ | sort -u
${system_executables}		ls -l $(find / /ffs/fs{1,2} /nvrd -xdev -type f -perm +6000 | sort -u)
${world_writable_directories}		ls -ld $(find / /ffs/fs{1,2} /nvrd -xdev -type d -perm +002 | sort -u)
${unauthorized_world_writable_files_exception}		/home/ute/fw_user_path/testcases/resources/Unauthorized_world_writeable_files.txt
${Files_owned_by_root_are_not_writeable_for_other_user_exception}
		...		/home/ute/fw_user_path/testcases/resources/files_writeable_for_other_user_or_group.txt
${system_executables_exception}		/home/ute/fw_user_path/testcases/resources/System_executables_file.txt
${world_writable_directories_exception}		/home/ute/fw_user_path/testcases/resources/world_writables.txt
${Permission_list_file}				/home/ute/fw_user_path/testcases/resources/Permissionfile_list.txt

${enb_SSE_IP}			10.253.215.221
${vm_SSE_IP}			10.253.215.222
${vm_interface}			eth1:1
${netmask}		        255.255.255.128
${Farend_IP}           		10.111.67.29
${build_number}

*** Test Cases ***
#[1]SBTS_Transport_Network_scenario_1IP_NoVlan_FTIF
[1.0] SBTS_Transport_Network_scenario_1IP_NoVlan_FTIF

    Pre Conditions
	Perform Commissioning	verify_bts_status=True     timeout=600
    Sleep   120
##Unexpected alarms
	Verify Alarm    expected_alarms=${expected_alarms}
    Perform Recommissioning     type=delta        delta_file=Wrong_GTPU_moc.xml        skip_parameter_relation_errors=${True}      timeout=300
    sleep   100
    Verify GTP Alarm
    Perform Recommissioning     type=delta        delta_file=GTPU_moc.xml        skip_parameter_relation_errors=${True}      timeout=300
    sleep   100
    Verify NO GTP Alarm
##	${Internal_mac_address}=		Run	ifconfig -a | grep eth1 | awk '/HWaddr/ {print $5}' | head -1
	${Internal_mac_address}=		Run     sudo ifconfig -a eth1 | awk '/ether/ {print $2}'
	Set Suite Variable	${Internal_mac_address}	${Internal_mac_address}
###	Modified DSCP
	Linux File Permissions
    IP Routing For SSE
#	Traffic Capture Streaming
#	Run Keyword And Continue On Failure	All Rat Calls
#Snapshot
#Unexpected alarms
    Sleep   900
#	Reset LTE
#    Reset WCDMA
#    Reset GSM
    Verify Bts Status
	Verify Alarm    expected_alarms=${expected_alarms}

#Snapshot
    ${snap}=        Collect Snapshot        timeout=900
	[Teardown]	Post Conditions
*** Keywords ***
Pre Conditions
	Configure Switch	device=l2_fsmf_eif1	command_profile=add_native_vlan
Post Conditions
	Configure Switch	device=l2_fsmf_eif1		command_profile=del_native_vlan
Modified DSCP
	${lte_cplane1} = 	Get Parameter		rat=lte			param_path=${lte_cplane1_ip_moc_path}
	${lte_uplane1} = 	Get Parameter		rat=lte			param_path=${lte_uplane1_ip_moc_path}
	${mme_ip0} = 		Get Parameter		rat=lte			param_path=${lte_mme_ip_moc_path}
#Before Change
	${lte_cplane_dscp} = 		Get Parameter		rat=lte		param_path=${lte_cplane1_dscp_moc_path}
	${lte_uplane_dscp} = 		Get Parameter		rat=lte		param_path=${lte_uplane1_dscp_moc_path}
	${icmp_dscp} = 		Get Parameter		rat=lte		param_path=${icmp_dscp_moc_path}

        Traffic Capture Start		capture_device=LMP_PC		    	alias=capture_streaming_b_default    timeout=60
        Traffic Capture Start        capture_device=oam_device    mode=streaming        measurement_point=NE_Terminated      uplane_capturing=True
        dst_mac_addr=${Internal_mac_address}        egress_port_dn=MRBTS-3281/TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-2   timeout=900	alias=pointB
    Sleep   5

	Setup Remote Access	remote_device=bts	alias=dscp_per_phb
	Remote Command Execute		command=ping -c 6 -I ${lte_cplane1} ${mme_ip0}     alias=dscp_per_phb
	...		Teardown Remote Access	alias=dscp_per_phb
	Sleep	60
#	LTE call
        Traffic Capture Stop   mode=streaming	timeout=900	alias=pointB
	${filename}=     Traffic Capture Stop		capture_device=LMP_PC		alias=capture_streaming_b_default

	Analyse Pcap 		pcap_filename=${filename}		 analysis=default_icmp_dscp
	...		filter_file_name=${traffic_filer_file_name}
	Analyse Pcap    	pcap_filename=${filename}		 analysis=default_lte_cplane_dscp
	...		filter_file_name=${traffic_filer_file_name}
	${icmp_modified_dscp_value}=	Get Random DSCP Value
	Perform Recommissioning 	type=param	 param_path=${icmp_dscp_moc_path}    value=${icmp_modified_dscp_value}
	...		skip_parameter_relation_errors=${True}	timeout=300   operation=update
	${status}=		Run Keyword and return status		Should contain		${build_number}		SBTS20A
	Run Keyword If	'${status}'=='True'	Perform Recommissioning		type=delta	delta_file=${sanity_dscp_update_20A}	timeout=300
	...		ELSE		Perform Recommissioning         type=delta      delta_file=${sanity_dscp_update}        timeout=300
	Sleep	300
#After Change
	${lte_cplane_dscp} = 		Get Parameter		rat=lte		param_path=${lte_cplane1_dscp_moc_path}
	${lte_uplane_dscp} = 		Get Parameter		rat=lte		param_path=${lte_uplane1_dscp_moc_path}
	${icmp_dscp} = 		Get Parameter		rat=lte		param_path=${icmp_dscp_moc_path}
	${lte_cplane_dscp} = 		Get Parameter		rat=lte		param_path=${lte_cplane1_dscp_moc_path}
	${lte_uplane_dscp} = 		Get Parameter		rat=lte		param_path=${lte_uplane1_dscp_moc_path}
	${icmp_dscp} = 		Get Parameter		rat=lte		param_path=${icmp_dscp_moc_path}

        Traffic Capture Start		capture_device=LMP_PC		    	alias=capture_streaming_b_modified
        Traffic Capture Start        capture_device=oam_device    mode=streaming        measurement_point=NE_Terminated
	...		uplane_capturing=True
        dst_mac_addr=${Internal_mac_address}        egress_port_dn=MRBTS-3281/TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-2
	...		timeout=900	alias=pointB_modified
    Sleep   5

	Setup Remote Access	remote_device=bts	alias=dscp_per_phb
	Remote Command Execute		command=ping -c 6 -I ${lte_cplane1} ${mme_ip0}     alias=dscp_per_phb
	Teardown Remote Access	alias=dscp_per_phb
	Sleep	60
#	LTE call
        Traffic Capture Stop   mode=streaming	timeout=900	alias=pointB_modified
	${filename}=     Traffic Capture Stop		capture_device=LMP_PC		alias=capture_streaming_b_modified

	Analyse Pcap 		pcap_filename=${filename}		 analysis=modified_icmp_dscp
	...		filter_file_name=${traffic_filer_file_name}
	Analyse Pcap            pcap_filename=${filename}		 analysis=modified_lte_cplane_dscp
	...		filter_file_name=${traffic_filer_file_name}
#	Analyse Pcap            pcap_filename=${filename}		 analysis=modified_lte_uplane_dscp
#	filter_file_name=${traffic_filer_file_name}
	[Teardown]	Run Keywords        Run Keyword And Ignore Error	 Traffic Capture Stop   mode=streaming	timeout=900 alias=pointB
	...	AND	        Run Keyword And Ignore Error	 Traffic Capture Stop
	...		capture_device=LMP_PC	alias=capture_streaming_b_default
	...	AND	        Run Keyword And Ignore Error	 Traffic Capture Stop   mode=streaming	timeout=900	alias=pointB_modified
	...	AND	        Run Keyword And Ignore Error	 Traffic Capture Stop
	...		capture_device=LMP_PC	alias=capture_streaming_b_modified

LTE call
	Call Setup      lte=device_1:data	parallel=${False}
	Call Start      lte=device_1:data       profile=udp_ul
        Call Start      lte=device_1:data       profile=udp_dl
	Sleep	10
	[Teardown]	Lte Call Stop

Linux File Permissions
	Setup Remote Access	remote_device=bts
	Get Permissioncheck File	${Permission_list_file}

#Step1
	${stdout}=	Remote Command Execute		command=${unauthorized_world_writable_files}
	Set Suite Variable    ${stdout}	${stdout}
	Log     ${stdout}
	Get Exception File      ${unauthorized_world_writable_files_exception}
	Sticky bit should be set

#Step2a
	${stdout}=	Remote Command Execute		command=${Files_owned_by_root_are_not_writeable_for_other_user}
	Set Suite Variable    ${stdout}	${stdout}
	Log     ${stdout}
	Get Exception File      ${Files_owned_by_root_are_not_writeable_for_other_user_exception}
   	Sticky bit should be set

#Step2b
	${stdout}=	Remote Command Execute		command=${Files_owned_by_root_with_GID}
	Set Suite Variable    ${stdout}	${stdout}
	Log     ${stdout}
	Get Exception File      ${Files_owned_by_root_are_not_writeable_for_other_user_exception}
   	Sticky bit should be set

#Step3
	${stdout}=	Remote Command Execute		command=${Orphaned_files}
	Set Suite Variable    ${stdout}	${stdout}
	Log     ${stdout}
	${orpfile} =       Run keyword and return status	Should Be Empty     ${stdout}
	Set Suite Variable    ${orpfile}	${orpfile}
	Log     ${orpfile}
	Run Keyword If      '${orpfile}'!='True'     Check file permission

#Step4
	${stdout}=	Remote Command Execute		command=${system_executables}
	Set Suite Variable    ${stdout}	${stdout}
	Log     ${stdout}
	Get Exception File      ${system_executables_exception}
	Sticky bit should be set

#Step5
	${stdout}=	Remote Command Execute		command=${world_writable_directories}
	Set Suite Variable    ${stdout}	${stdout}
	Log     ${stdout}
	Get Exception File      ${world_writable_directories_exception}
    	Sticky bit should be set
	[Teardown]		Teardown Remote Access

Get Exception File
    [Arguments]     ${file}
    ${Exception_file}=      OperatingSystem.Get File        ${file}     encoding_errors=ignore
    Set Suite Variable      ${Exception_file}
    Log     ${Exception_file}

Get Permissioncheck File
	[Arguments]     ${file1}
	${Permission_file}=      OperatingSystem.Get File        ${file1}     encoding_errors=ignore
    Set Suite Variable      ${Permission_file}
    Log     ${Permission_file}

Sticky bit should be set
    @{list}=    Split To Lines    ${stdout}
    ${array_length}=    Get Length      ${list}
    FOR    ${ELEMENT}    IN    @{list}
           @{output}=      Split string    ${ELEMENT}
           ${sticky_bit}=      Get From List       ${output}       0
           ${sticky_bit}=    Convert To List    ${sticky_bit}
           ${bit}=    Get From List      ${sticky_bit}     -1
           ${output_file_name}=     Get From List       ${output}     -1
           ${status}=      Run keyword and return status    Should be Equal      t      ${bit}
           ${RESULT} =       Run keyword and return status	Run Keyword If      '${status}'!='True'
           ...		Check if the exceptions are present in exceptions list    ${output_file_name}
    	   Run Keyword If      '${RESULT}'!='True'     Check if the permission is correct    ${sticky_bit}
	END

Check if the exceptions are present in exceptions list
    [Arguments]     ${output_file_name}
    Should Match Regexp      ${Exception_file}      (?i)${output_file_name}

Check if the permission is correct
	[Arguments]     ${sticky_bit}
	Should Not Match Regexp      ${Permission_file}      (?i)${sticky_bit}

Check file permission
	@{orplist}=    Split To Lines    ${stdout}
	FOR    ${Item}    IN    @{orplist}
		${files}=	Remote Command Execute		command=ls -l $(find / /ffs/fs{1,2} /nvrd -xdev -type f -user ${Item} | sort -u)
	 	Set Suite Variable    ${files}	${files}
		Log     ${files}
    	END
	File Permission
File Permission
	@{list}=    Split To Lines    ${files}
    ${array_length}=    Get Length      ${list}
    FOR    ${ELEMENT}    IN    @{list}
           @{output}=      Split string    ${ELEMENT}
           ${sticky_bit}=      Get From List       ${output}       0
           ${bit}=    Get From List      ${sticky_bit}     -1
           ${output_file_name}=     Get From List       ${output}     -1
           ${status}=      Run keyword and return status    Should be Equal      t      ${bit}
    	   Run Keyword If      '${status}'!='True'     Check if the permission is correct    ${sticky_bit}
     END
IP Routing For SSE
	Configure Switch	device=bfd1_router		command_profile=add_sse_route
	Run	sudo ifconfig ${vm_interface} ${vm_SSE_IP} netmask ${netmask} up
	Run	sudo ip route add ${Farend_IP} via ${enb_SSE_IP} dev ${vm_interface}
	${stdout}=	Run	ping -c 6 -I ${vm_SSE_IP} ${Farend_IP}
	Should contain  ${stdout}  6 packets transmitted, 6 received
	[Teardown]	Run Keywords	Run	sudo ip route del ${Farend_IP} via ${enb_SSE_IP} dev ${vm_interface}
	...	AND	Configure Switch	device=bfd1_router		command_profile=del_sse_route

Traffic Capture Streaming
#pointA
        Traffic Capture Start		capture_device=LMP_PC		    	alias=capture_streaming_a
        Traffic Capture Start        capture_device=oam_device    mode=streaming        measurement_point=Transport_Interface
	...		uplane_capturing=True        dst_mac_addr=${Internal_mac_address}        egress_port_dn=MRBTS-3281/TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-2
	...		timeout=900	alias=pointA
        Sleep   20
        Traffic Capture Stop   mode=streaming	alias=pointA  timeout=900
	...		${filename_A}=     Traffic Capture Stop		capture_device=LMP_PC		alias=capture_streaming_a
	Analyse Pcap 	pcap_filename=${filename_A}     filter_file_name=${traffic_filer_file_name}	analysis=cplane_v4
	[Teardown]	Run Keywords        Run Keyword And Ignore Error	 Traffic Capture Stop   mode=streaming	alias=pointA  timeout=900
	...		AND	        Run Keyword And Ignore Error	 Traffic Capture Stop
	...		capture_device=LMP_PC		alias=capture_streaming_a

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
        FOR    ${ELEMENT}    IN    @{mandatoryfiles}
        END       Should Match Regexp     ${ext_content}  ${ELEMENT}
All Rat Calls
#	Call Setup      lte=device_1:data       wcdma=device_1:data     gsm=device_1:voice      parallel=${True}
	Call Setup      lte=device_1:data       gsm=device_1:voice      parallel=${True}
	Call Start      lte=device_1:data       profile=udp_ul
        Call Start      lte=device_1:data       profile=udp_dl
#        Call Start      wcdma=device_1:data     profile=udp_ul_wcdma
#        Call Start      wcdma=device_1:data     profile=udp_dl_wcdma
#        Call Start      gsm=device_1:voice
        Sleep   30
	Lte Call Stop
#	Run Keyword And Ignore Error        Call Stop       wcdma=device_1:data     profile=udp_ul_wcdma
#         Run Keyword And Ignore Error	    Call Stop       wcdma=device_1:data     profile=udp_dl_wcdma
#        Call Stop       gsm=device_1:voice

Lte Call Stop
	Run Keyword And Ignore Error	Call Stop       lte=device_1:data       profile=udp_ul
        Run Keyword And Ignore Error	Call Stop       lte=device_1:data       profile=udp_dl
	[Teardown]	Call Teardown	lte=device_1:data
Get Random DSCP Value
	${min_dscp_value}=	Convert to Integer    0
	${max_dscp_value}=	Convert to Integer    63
	${mplane_modified_dscp_value}=	random.randint    ${min_dscp_value}	${max_dscp_value}
	${mplane_modified_dscp_value_string}=	Convert to String    ${mplane_modified_dscp_value}
	${type} =    Evaluate    type($mplane_modified_dscp_value_string).__name__
	[Return]	${mplane_modified_dscp_value_string}

Reset LTE
        Reset   operation=rat_reset     rat=LTE        verify_bts=True       timeout=300
        Verify Alarm    faultid=17      should_exist=${False}
        Verify Alarm    faultid=2401    should_exist=${False}

Reset WCDMA
        Reset   operation=reset_rat     rat=WCDMA       verify_bts=True     timeout=300
        Verify Alarm    faultid=6202    should_exist=${False}
        Verify Alarm    faultid=2401    should_exist=${False}

Reset GSM
        Reset   operation=reset_rat     rat=GSM         verify_bts=True     timeout=600
        Verify Alarm    faultid=6202    should_exist=${False}
        Verify Alarm    faultid=17      should_exist=${False}

#Suite Teardown Postconditions
#        Run Keyword And Ignore Error    Setup Oamops
#        Collect Im Snapshot     timeout=300
#        Collect Snapshot        timeout=1200
#        [Teardown]        Stop Syslog       alias=collect_syslog

Verify GTP Alarm
    Verify Alarm    faultid=6150        should_exist=${True}
#    ${alarm_detail}=        Verify Alarm    faultid=6150
Verify NO GTP Alarm
    Verify Alarm    faultid=6150        should_exist=${False}
