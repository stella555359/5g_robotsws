*** Settings ***
Documentation
...             author:                 padmashree.b@nokia.com
...             maintainer:             padmashree.b@nokia.com
...             INTRODUCTION:      CB009422
...             TEST SET NAME:     CB009422
...             TESTING SPLIT:     See CB009422 testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB009422 CFAM

Library           OperatingSystem
Library           Process
Library           String
Library           Collections
Library			  ta5g_pm_counters
Library     SSHLibrary
Library     taf.sw.dcap.rd   WITH NAME   rd
Library     taf.transport.ssh    WITH NAME    ssh
Library     taf.sbts.oam.coam.admin   WITH NAME    coam
Library     taf.collectors.btslog    WITH NAME    btslog
Library     taf.hw.rf_attenuator  WITH NAME  at
Library     taf.collectors.tshark    WITH NAME    tshark1
Library     taf.collectors.tcpdump    WITH NAME    tcpdump1
Library     taf.collectors.core    WITH NAME    core1
Library     testsuite.Bangalore.ORAN.resources.python.ta_ultracaller    WITH NAME    ta_ultracaller
Library     taf.converters.pcaptopdml    WITH NAME    pcaptopdml
Library     taf.analyzer.pdml   WITH NAME   taf_pdml_analyser
Library		taf.ul.alarms_watchdog		WITH NAME	alarm
Library		ute_reporting_portal
Library     taf.sw.scout   												WITH NAME   scout
Library     taf.collectors.l2stream3    WITH NAME    L2STREAM3
Resource         ./CB009422_resource.robot
#Resource        ./Resources/snapshot.robot

Test setup        Run keywords	Prepare environment
... 		AND 	COAM.setup_admin    bts_host=${gNB_IP}    alias=${connection}    admin_api_log_dir=/tmp
...			AND		Verify feature enabled

Test Teardown     Run keywords		Run keyword and continue on failure			Check alarm
...         AND     Run keyword and Ignore Error            Stop ttitrace Collection    file_name=9422_data
...         AND     Run keyword and continue on failure         Stop Syslog and verify
...			AND		alarm.stop_watching_alarms
#...         AND     Report to QC
...			AND		COAM.teardown_admin    connection=${connection}

*** Variables ***
@{udpcalltype}=    UDP
@{capabilities}    Legacy_1
@{UE_alias}=  UE1
@{capabilities1}    Legacy_2
@{UE_alias1}=  UE2
@{calltype}=    TCP
${cell1}	1
${cell2}	3
${msg_col}		${5}
${con_col}		${19}
${gNB_IP} 		  192.168.255.129
${BTS_M_plane_ip}           10.68.126.112
#&{BTS_INFO}                 host=${BTS_M_plane_ip}	port=${port}
@{gnb_custom_filters}       condor5gSyslog     cp_5g
@{bts_custom_filter}        scf
${uepc_default_ip}          10.68.126.250
${emil_path}                C://Emil
${emil_profile}             ${emil_path}//profiles//5G
${uepc_Log_path}            C://Users//inbabtslabuser//Documents//Automation_logs
${Scout_tl_name}	    1_2_CLOUD1910
${connection}		oam
@{direction_dl}    dl
@{deviation_dl}    100
@{throughput_dl}    250
@{direction_ul}    ul
@{deviation_ul}    100
@{throughput_ul}    100
&{Cells_configured}			1=92
${VM_IP} 	   10.68.126.83
${VM_usn}    ute
${VM_pwd}		BT5l@bus3rl0g1n
${CB009422_ST_CRT}
#...		QC_ID_FL00=59419       QC_ID_24R3=859530
${package_web_service_SBTS}
#...   https://lterel.es-si-s3-z2.eecloud.nsn-net.net/build
...   https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build

*** Test Cases ***
[1]CB009422_ST_CRT
    Set Suite Variable      ${TEST_LOG_DIRECTORY}       ${OUTPUT_DIR}
	Wait Until Keyword Succeeds	   15 times	   20	 Check BTS is OnAir
    Get TcpdumpLogs from Remote machine
	Start alarm monitoring
	Start Syslog
	Start Ttitrace Log capture      file_name=ue_register_9422crt

	ta_ultracaller.Require UE    ue_alias=${UE_alias}   capabilities=${capabilities}
	ta_ultracaller.Detach UE     ue_alias=${UE_alias}
	ta_ultracaller.Attach UE     ue_alias=${UE_alias}
    ta_ultracaller.Require UE    ue_alias=${UE_alias1}   capabilities=${capabilities1}
    ta_ultracaller.Detach UE     ue_alias=${UE_alias1}
    ta_ultracaller.Attach UE     ue_alias=${UE_alias1}
	Sleep		3s
    Stop ttitrace Collection    file_name=ue_register_9422crt
	Log to console    \nStarting DL and UL data transfer
    Common TTI PCAP to CSV Converter ST   ${OUTPUT_DIR}/Logs/ue_register_9422crt   dir=dl
    Common TTI PCAP to CSV Converter ST    ${OUTPUT_DIR}/Logs/ue_register_9422crt   dir=ul
    Verify_RA_slots    ${OUTPUT_DIR}/Logs/ue_register_9422crt/output_ul_formated.csv   98

	ta_ultracaller.start_data_transfer  ${UE_alias}   ${udpcalltype}    direction=${direction_dl}		tputcheck=No
	ta_ultracaller.start_data_transfer  ${UE_alias}   ${udpcalltype}    direction=${direction_ul}
    ta_ultracaller.start_data_transfer  ${UE_alias1}   ${udpcalltype}    direction=${direction_dl}       tputcheck=No
    ta_ultracaller.start_data_transfer  ${UE_alias1}   ${udpcalltype}    direction=${direction_ul}
    Start Ttitrace Log capture      file_name=9422crt_data
    Sleep   3s
    Stop ttitrace Collection    file_name=9422crt_data

    Common TTI PCAP to CSV Converter ST    ${OUTPUT_DIR}/Logs/9422crt_data   dir=dl
    Common TTI PCAP to CSV Converter ST    ${OUTPUT_DIR}/Logs/9422crt_data   dir=ul

#   Verification of K2 against all DL_slots from TTI trace
    Verify_K2    ${OUTPUT_DIR}/Logs/9422crt_data/output_ul_formated.csv
#   Verification of K1 against all DL_slots from TTI trace
    Verify_K1    ${OUTPUT_DIR}/Logs/9422crt_data/output_dl_formated.csv    actEnhancedPDSCHSchSplSlot=${0}    guardPeriodLength=${6}
#   Verification of HARQ slots from TTI trace
    Verify_HARQ_slots    ${OUTPUT_DIR}/Logs/9422crt_data/output_dl_formated.csv    actEnhancedPDSCHSchSplSlot=${0}    guardPeriodLength=${6}

    Run keyword and Continue on Failure         Convert pcap file       ue_register       e1ap
    ta_ultracaller.Detach UE     ue_alias=${UE_alias}
	ta_ultracaller.Detach UE     ue_alias=${UE_alias1}

*** Keywords ***
Verify feature enabled
	Log To Console		Enable feature parameter
	${feature_param}	COAM.get_parameters    dist_name=MRBTS-30341/NRBTS-30341/NRCELL-1       pattern='tddFrameStructure.*'
    ...    connection=oam
	Should contain Match		${feature_param}	tdLteConfig0


Verify message custom
    [Arguments]    ${file_name}  ${msg_name}  ${parametr}   ${expected_sd}    ${expected_sst}  ${ic}=${-1}  ${sd2}=${-1}  ${sd3}=${-1}  ${sd4}=${-1}
    BuiltIn.Log     ${parametr}
    ${pdmlFile}=   Fetch filtered PDML file from pcap    ${file_name}    ${msg_name}
#    ${pdmlFile}     Set variable    ${file_name}
    ${sstp}    Set Variable if    ${ic}==${1}    sst     sST
    ${sdp}    Set Variable if    ${ic}==${1}    sd     sD
    ${pdml_entries}     taf_pdml_analyser.Get Pdml Entries     ${pdmlFile}
    ...          field_name=${msg_name}     attrib_name=showname     attrib_value=${sstvalue1}
    ${attrib_values}    taf_pdml_analyser.Get Attrib Value From Pdml Entries    ${pdml_entries}
    ...    field_name=${msg_name}    attrib_name=showname
    ${attrib_values}     convert to string    ${attrib_values}
    ${pdml_entries}     taf_pdml_analyser.Get Pdml Entries     ${pdmlFile}
    ...          field_name=${msg_name}     attrib_name=showname     attrib_value=${sdvalue1}
    ${attrib_values}    taf_pdml_analyser.Get Attrib Value From Pdml Entries    ${pdml_entries}
    ...    field_name=${msg_name}    attrib_name=showname
    ${attrib_values}     convert to string    ${attrib_values}
    Should Contain          ${sd}[0]    ${expected_sd}
    Should Contain          ${sst}[0]    ${expected_sst}
    Run keyword and continue on failure     Run Keyword If    ${sd2}!=${-1}     Should Contain          ${sd}[1]    f
    Run keyword and continue on failure     Run Keyword If    ${sd3}!=${-1}     Should Contain          ${sd}[2]    f
    Run keyword and continue on failure     Run Keyword If    ${sd4}!=${-1}     Should Contain          ${sd}[3]    f


Prepare environment
	COAM.setup_admin    bts_host=${gNB_IP}    alias=${connection}    admin_api_log_dir=/tmp
	${Pre_execution_scf_file}	COAM.Get Current Scf File		local_dir_path=${OUTPUT_DIR}/SCF	file_name=Pre_execution_scf.xml
	...							connection=${connection}	timeout=30
	Set Suite variable			${Pre_execution_scf_file}
	${Branch}		Get Branch
	Set Suite variable		${SCF_file}         ${CURDIR}/resources/Configuration/${Branch}/${TEST NAME}.xml
	Run keyword and Ignore Error        COAM.teardown_admin    connection=${connection}
	Download and install tti decoder


Get Branch
    ${sw_version}    COAM.get_sw_version    connection=${connection}
    ${out}    Split String From Right    ${sw_version}    _    -1
    ${Branch}    Strip String    ${out}[0]    both    SBTS
	[Return]	${Branch}

Collect snapshot from BTS
	[Documentation]		Download BTS snapshot
	Log to console		\nCollecting snapshot
	${status}			Run keyword and return status		COAM.Collect Snapshot	target_file_name=${OUTPUT_DIR}/Snapshot.zip
	...																				coverage=Full
	...																				force=True
	...																				timeout=1000
	...																				connection=${connection}
	Run Keyword If		'${status}'=='False'				Log   					Snapshot collection failed !!!			ERROR

Increase attenuation by step
	[Arguments]		${port_val_list}	${Attenuator_step_val}
	[Documentation]		Set the attenuation of specified port
	${length} 		Get Length		${port_val_list}
	FOR    ${i}    IN RANGE    10
		${status}		Attenuation loop		${port_val_list}	${Attenuator_step_val}
		Exit For Loop If 	"${status}"=="${length}"
	END

Attenuation loop
	[Arguments]		${port_val_list}	${Attenuator_step_val}
	${loop_status}		Set Variable		${0}
	FOR    ${val}    IN    @{port_val_list}
		${channel_num}		${value}	Split String	${val}	,	1
		${status}			Change value of Attenuator		${channel_num}		${value}	${Attenuator_step_val}
		${loop_status}		Run Keyword If		"${status}"=="${value}"		Evaluate		${loop_status}+${1}
		...		ELSE		Set Variable		${loop_status}
	END
	[return]	${loop_status}

Change value of Attenuator
	[Arguments]		${channel_num}		${value}	${Attenuator_step_val}
	[Documentation]		Set the attenuation of specified port
	${set_value}  at.read_attenuation  port=${${channel_num}}
	${new_val}		Run Keyword If		"${set_value}"!="${value}"		Evaluate    ${set_value} + ${Attenuator_step_val}
	...		ELSE	Set Variable		${set_value}
	Run Keyword If		"${set_value}"!="${value}"	Set Attenuator value	${channel_num}		${new_val}
	[return]		${new_val}

Block cells
	[Arguments]			${cell}
	Log to console		\nBlocking cell : ${cell}
	COAM.block_cell		dist_name=${Cell_dist}-${cell}		connection=${connection}

Unblock cells
	[Arguments]			${cell}
	Log to console		\nUnblocking cell : ${cell}
	COAM.unblock_cell	 dist_name=${Cell_dist}-${cell}		connection=${connection}
	Log to console		\nWaiting for cell to be onAir
	Wait Until Keyword Succeeds	   5 times	   20	 Check BTS is OnAir

Verify Emil
	[Arguments]    ${values}
	[Documentation]     Convert emil file and verify
	Convert Emil File To Csv
	FOR		${check}	IN	 @{values}
		${result}		Parse_Emil_Csv_File 	 path=${OUTPUT_DIR}/DCAP_Logs/Extracted/		msg=${check}
		...										msg_col=${msg_col}						con_col=${con_col}
		Run keyword And Continue On Failure		Should Be True		${result}
	END

Configure attenuator
    Setup Attenuator
    Read Ports attenuation

Setup Attenuator
    at.setup_attenuator  ip_addr=${attenuator_host}  port=${attenuator_port}  attenuation_port_numbers=${at_channel}
    ...  vendor=${at_vendor}  model=${at_model}

Read Ports attenuation
    ${port_values}    at.read_ports_attenuation  ${ports}

XnHO from source to target cell
    Log to console    \n-- Degrade source cell signal --n\
    @{values}    Set Variable    30dB    30dB    30dB    30dB
    Attenuate source cell     ${values}
    Log to console    \n-- Enhance target cell signal --n\
    @{values}    Set Variable    0dB     0dB
    Attenuate target cell     ${values}
    Sleep    20s

Attenuate source cell
    [Arguments]    ${values}
    at.set_ports_attenuation  ${source_ports}  ${values}  confirm=True  confirmation_delay=5

Attenuate target cell
    [Arguments]    ${values}
    at.set_ports_attenuation  ${target_ports}  ${values}  confirm=True  confirmation_delay=5

XnHO from target to source cell
    Log to console    \n-- Degrade target cell signal --n\
    @{values}    Set Variable    55dB     55dB
    Attenuate target cell     ${values}
    Log to console    \n-- Enhance source cell signal --n\
    @{values}    Set Variable    0dB    0dB    00dB    00dB
    Attenuate source cell     ${values}
    Sleep    20s

XnHO from source to target cell1
	${set attenuation target}	Create List		${1110_port},0
	Change attenuation	${set attenuation target}
	@{db change}	Create List		10	20	30	40	50	60	70
	FOR	${i}	IN	@{db change}
	${set attenuation}	Create List		${1105_port},${${i}}
	Change attenuation	${set attenuation}
	END

XnHO from target to source cell1
	${set attenuation target}	Create List		${1105_port},0
	Change attenuation	${set attenuation target}
	@{db change}	Create List	  10	20	 30	 40     50	60	70	80
	FOR	${i}	IN	@{db change}
	${set attenuation}	Create List		${1110_port},${${i}}
	Change attenuation	${set attenuation}
	END

Setup Attenuator Teardown
    @{values}    Set Variable    0dB    0dB    0dB    0dB
    Attenuate source cell     ${values}
    @{values}    Set Variable    70dB     70dB
    Attenuate target cell     ${values}

Check BTS is OnAir
    [Documentation]  ... checking BTS status
    [Arguments]  ${connection}=oam
    ${bts_status}=  coam.get_bts_statuses  connection=${connection}
    Should Be Equal As Strings   ${bts_status["proceduralState"]}    OnAir
    Run Keyword If  '${bts_status["proceduralState"]}'=='OnAir'
    ...    Log To Console    \nBTS procedural state is now: ${bts_status["proceduralState"]}
    ...    ELSE    fail

Change attenuation
    [Arguments]     ${port_val_list}
    [Documentation]     Set the attenuation of specified port
    FOR    ${val}    IN    @{port_val_list}
        ${channel_num}      ${value}    Split String    ${val}  ,   1
        Set Attenuator value    ${channel_num}      ${value}
    END

Login attenuator and set attenuation
    at.setup_attenuator  ip_addr=${attenuator_host}  port=${attenuator_port}    attenuation_port_numbers=@{at_channel}
     ...  vendor=${at_vendor}  model=${at_model}

Set Attenuator value
    [Arguments]     ${channel_num}      ${value}
    [Documentation]     Set the attenuation of specified port
    ${channel_num}      Convert To Integer      ${channel_num}
    ${value}        Convert To Integer      ${value}
    Log to console      \nChanging attenuator port ${channel_num} to ${value}db
    ${set_value}  at.read_attenuation  port=${${channel_num}}
    at.set_attenuation  port=${channel_num}     value=${value}      confirm=${True}
    sleep   2s      reason=Wait for change in state
    ${set_value}  at.read_attenuation  port=${${channel_num}}
    Should Be Equal As Strings  ${set_value}  ${value}

Start Tshark capture
	tshark1.create_tshark_collector
     ...    name=tshark1
     ...    options=-i eth0
     ...    sudo_password=ute
     core1.setup_collectors    names=tshark1
     core1.start_collectors    names=tshark1

Stop tshark capture
     core1.stop_collectors    names=tshark1
     core1.collect_collectors    names=tshark1
     core1.teardown_collectors    names=tshark1

Set counter values
	[Documentation]			Set counter expected values
	&{Counters_val}			Create Dictionary	M55138C03540=${3}		M55163C03007=${2}		M55163C03008=${2}
	@{Counters_list}			Create list		M55138C03540	M55163C03007	M55163C03008
	Set Suite variable		&{Counters_val}
	Set Suite variable		@{Counters_list}

Initialise counters
	${value}			Get Dictionary Keys		${Cells_configured}
	FOR		${cell}	IN	 @{value}
		Set counter as zero		${cell}		@{Counters_list}
	END

Set counter as zero
	[Documentation]	Set counetrs to zero
	[Arguments]		${cell}		@{Counters}
	FOR		${value}	IN	 @{Counters}
		Set test Variable	 ${${value}_${cell}_${0}}	 ${0}
	END

Check counters
	[Documentation]		Check counters
	[Arguments]	   		${counter}=${Counters_list}		${cell}=1
	ta5g_pm_counters.wait_for_next_full_pm_interval
	FOR		${check}	IN	 @{counter}
		${value}	Run keyword and continue on failure		Counter value	${check}	${cell}
		Run keyword and continue on failure		Set test Variable	${${check}_count}	 ${value}
        ${expected_count}    Get From Dictionary     ${Counters_val}     ${check}
        Run keyword and continue on failure     Should be true      ${${check}_count} != 0
	END

Check counters from gnb1
    [Arguments]     ${expected_3540}=0    ${expected_3008}=0    ${expected_3007}=0
	ta5g_pm_counters.wait_for_next_full_pm_interval
	${counter1}     Run keyword and continue on failure		Counter value	M55138C03540	1		${dict_M55138C03540}
    Should be True  ${counter1} > ${expected_3540}
	${counter2}     Run keyword and continue on failure		Counter value	M55163C03008	1		${dict_M55163C03008}
    Should be True  ${counter2} >= ${expected_3008}
	${counter3}     Run keyword and continue on failure		Counter value	M55163C03007	1		${dict_M55163C03007}
    Should be True  ${counter3} > ${expected_3007}
    ${counter4}     Run keyword and continue on failure     Counter value   M55143C00001    1       ${dict_M55143C00001}
    [Return]        ${counter1}     ${counter2}     ${counter3}


Check counters from gnb2
    [Arguments]     ${expected_3540}
	COAM.setup_admin    bts_host=${gNB_IP_2}    alias=${connection_2}    admin_api_log_dir=/tmp
	${counter1}     Run keyword and continue on failure		Counter value	M55138C03540	1		${dict2_M55138C03540}		${connection_2}
    Should be True  ${counter1} >= ${expected_3540}
    ${counter4}     Run keyword and continue on failure     Counter value   M55143C00001    1       ${dict2_M55143C00001}    ${connection_2}
	[Teardown]		COAM.teardown_admin    connection=${connection_2}
    [Return]        ${counter1}

Counter value
	[Documentation]			Check counter value of BTS
	[Arguments]				${counter_name}			${cell}			${Dict_val}			${connect}=${connection}
    BuiltIn.Log     ${cell}
	Log to console			\nChecking BTS counter ${counter_name}
	${result}				COAM.get_pm_counters	counter_ids=${counter_name}	timeout=1000	connection=${connect}
	BuiltIn.Log						${result}
#	${Dict_val}				Get_counter_list		${result}					${counter_name}	${cell}
	${counter_value_list}	Get Dictionary Values	${result${Dict_val}}
#	${Total_Count}		Evaluate    ${counter_value_list}[-1]+${counter_value_list}[-2]+${counter_value_list}[-3]
	${Total_Count}			Get value of Counter	${counter_value_list}
	[Return]				${Total_Count}

Get value of Counter
	[Documentation]		Get total value from list
	[Arguments]			${Counter_value}
	Set test Variable	${i}	${0}
	FOR	   ${value}	   IN	 @{Counter_value}
		${i}	Evaluate	${i} + ${value}
	END
	[Return]	${i}

Get TcpdumpLogs from Remote machine
    [Documentation]    this keyword is used to capture wireshark log in wireshark PC
    log to console    \n--Starting Wireshark Logs--
    ${executor_oam_vm}=  Create Dictionary
    ...  host=10.58.239.119
    ...  user=toor4nsn
    ...  password=oZPS0POrRieRtu
    tcpdump1.create_tcpdump_collector
    ...    name=tcpdump
    ...    options=-i any
    ...    executor=${executor_oam_vm}
    core1.setup_collectors    names=tcpdump
    core1.set_suite_alias    tcpdump
    core1.start_collectors    names=tcpdump

Convert pcap file
    [Documentation]  this keyword will stop wireshark log collection and convert pcap file to .txt format.
    [Arguments]     ${filename}     ${filter}
    #stopping tcpdump
    log to console    --Stoping Wireshark Logs--\n
    core1.stop_collectors    names=tcpdump
    core1.collect_collectors    names=tcpdump       target_dir=${TEST_LOG_DIRECTORY}
    core1.teardown_collectors    names=tcpdump
    #${log}=    Validate_tshark    ${out}    filter=e2ap
    SSH_connection    ${VM_IP}    ${VM_usn}    ${VM_pwd}
    SSHLibrary.write    cd /home/ute
    ${command}=    set variable    tshark -r ${TEST_LOG_DIRECTORY}/tcpdump/tcpdump.pcap -Y "${filter}" > ${TEST_LOG_DIRECTORY}/tcpdump/${filename}.txt
    SSHLibrary.write    ${command}
    sleep    1min
    ${filepath}    set variable    ${TEST_LOG_DIRECTORY}/tcpdump/${filename}.txt
    ${file}=    OperatingSystem.Get file    ${filepath}
    SSH_teardown
    [Return]    ${file}

SSH_connection
    [Arguments]    ${IP}    ${username}    ${pwd}
    SSHLibrary.Open Connection    ${IP}    port=22
    SSHLibrary.Login    ${username}    ${pwd}

SSH_teardown
    sshlibrary.close connection

Fetch filtered PDML file from pcap
    [Arguments]                     ${pcapFile}       ${filterExp}=None        ${filterName}=None
    [Documentation]                 Takes a PDML file as input, and returns it into a PDML file
    BuiltIn.Log     ${filterExp} ${filterName}
#    ${filterPcap}                   analyzer.filter_pcap            ${pcapFile}
#    ...                             filterName=${filterName}        filterExp=${filterExp}
#    ${pdmlFile}=                    analyzer.pcap_to_pdml           ${pcapFile}
    pcaptopdml.create_pcap_to_pdml_converter
    ...      name=converter
    ...      file_path_pattern=${pcapFile}
    ${pdmlFile}    pcaptopdml.convert    converter
    [Return]    ${pdmlFile}

Start alarm monitoring
	[Documentation]		Start monitoring alarm in BTS
	${Active_alarm}		COAM.get_active_alarms	  			connection=${connection}
	BuiltIn.LOG					${Active_alarm}
	${allowed_alarms}	Expected alarm
	alarm.Watch alarms	allowed_alarms=${allowed_alarms}	connection_kwargs=${connection}	   log_dir=${OUTPUT_DIR}

Expected alarm
	[Documentation]			Alarms which are ignored on runtime
	${allowed_alarm_1}		Create alarm	alarm_id=7220		fault_id=61524		fault_name=SSH enabled
	${allowed_alarm_2}		Create alarm	alarm_id=7220	  	fault_id=4654		fault_name=Ethernet port security is disabled
	${allowed_alarm_3}		Create alarm	alarm_id=7220	  	fault_id=61649		fault_name=LMP access via port 443
	${allowed_alarm_4}		Create alarm	alarm_id=7220	  	fault_id=4655		fault_name=Service account root access is enabled
	${allowed_alarm_5}		Create alarm	alarm_id=7220	  	fault_id=61652		fault_name=R&D Service Port enabled
	${allowed_alarm_6}		Create alarm						fault_id=4592		fault_name=BTS Reset Cause
	${allowed_alarm_7}		Create alarm					  	fault_id=49			fault_name=Cell blocked
	${allowed_alarm_8}		Create alarm	alarm_id=7652	  	fault_id=4458		fault_name=SSH Login Configuration failed			#SSD HW issue
	${allowed_alarm_9}		Create alarm					  	fault_id=6261
	...						fault_name=Failure in internal BTS connection or connection to 3rd party tool
	${allowed_alarm_10}		Create alarm					  	fault_id=4297		fault_name=NTP Server 10.43.97.179 unavailable
	${allowed_alarm_11}		Create alarm					  	fault_id=6327		fault_name=Setup of X2 connectivity to gNB failed
	${allowed_alarm_12}		Create alarm						fault_id=6203		#fault_name=Transport layer connection failure in X2 interface
    ${allowed_alarm_13}     Create alarm                        fault_id=7311       fault_name=No Xn link available
	${allowed_alarms}		Create list		${allowed_alarm_1}	${allowed_alarm_2}	${allowed_alarm_3}	${allowed_alarm_4}
	...										${allowed_alarm_5}	${allowed_alarm_6}	${allowed_alarm_7}	${allowed_alarm_8}
	...										${allowed_alarm_9}	${allowed_alarm_10}	${allowed_alarm_11}		${allowed_alarm_12}     ${allowed_alarm_13}
	[Return]				${allowed_alarms}

Check alarm
	[Documentation]		Check BTS alarm
	${Active_alarm}		COAM.get_active_alarms	  connection=${connection}
	Builtin.LOG					${Active_alarm}
	${status}			Run keyword and continue on failure		alarm.check_detected_alarms
	#Run Keyword If		'${status}'!='True'					Log		Unexpected alarm is detected !!!		ERROR

Start BTS logs
	[Documentation]					Starts BTS log in testpc
	Log to console					\nStarting BTS log
	Run								killall btslog
	btslog.create_btslog_collector	name=btslog
	core1.setup_collectors			names=btslog
	core1.set_suite_alias			btslog
	core1.start_collectors			names=btslog

Stop BTS logs and check
	[Documentation]		Stops BTS log and check for crash
	${status}			Run keyword and return status		Stop BTS log
	Run Keyword If		'${status}'=='True'					Verify BTS log
	...		ELSE		Log   Syslog collection failed!!!	ERROR

Stop BTS log
	[Documentation]				Stops BTS log
	Log to console				\nCollecting BTS log
	core1.stop_collectors		names=btslog
	core1.collect_collectors		names=btslog	target_dir=${OUTPUT_DIR}
	core1.teardown_collectors	names=btslog

Verify BTS log
	[Documentation]		Verify BTS log
#	${check}			Check_bts_logs			${OUTPUT_DIR}/btslog/
#    Run Keyword If		'${check}'!='True'		Run keywords	Log   Unexpected prints found in syslog !!!    ERROR
#	...													AND		FAIL
    Sleep   1s

Start Syslog
    [Documentation]    ... Starting Syslogs
#    ${executor_test_vm}=  Create Dictionary
#    ...  host=10.58.238.202
#    ...  user=ute
#    ...  password=BT5l@bus3rl0g1n
#    btslog.create_btslog_collector
#    ...   name=btslog
#    ...   btslog_path=/opt/btslog/btslog
#    ...   btslog_launcher_path=/opt/btslog/btslog_launcher
#    ...   executor=${executor_test_vm}
#    ...   log_dir=/tmp/btslog2
    Run                             killall btslog
    btslog.create_btslog_collector
    ...   name=btslog
    core1.setup_collectors    names=btslog
    core1.start_collectors    names=btslog
    core1.set_suite_alias    btslog
    Log To Console    \n---- Started Syslog ----\n


Stop Syslog
    sleep    20s
    core1.stop_collectors      names=btslog
    core1.collect_collectors      names=btslog          target_dir=${OUTPUT_DIR}
    core1.teardown_collectors      names=btslog
    Log To Console    \n---- Stopped Syslog ----\n

Stop Syslog and verify
    Stop Syslog
    Verify BTS log

Restart the GNB
    [Arguments]     ${connect}
    [Documentation]     Restart gnb
    Log to console      \nRebooting gNB and waiting for reconnection
    COAM.reset      reset_coverage=Site     wait_for_reconnection=True      timeout=300     connection=${connect}
    COAM.reset_admin     connection=${connect}

Link SCOUT SCF to Configuration ID for Reporting
	[Documentation]			Link Scout
    [Arguments]				${node_id}=${0}			${node_type}=gnb    ${tl_name_only}=${Hostname}
    ${node_type_Name}		Run Keyword If			"${node_type}"=="gnb"   Set Variable  gNB
    ...     ELSE IF			"${node_type}"=="enb"	Set Variable  	eNB
    ...     ELSE			Fail    				Wrong node_type '${node_type}'! allowed: enb|gnb
	Log						${node_id}
    Log To Console			\nSCOUT Test Line Name: ${tl_name_only}
    ${scout_testline_name}	Set Variable			${tl_name_only}
    ${external_scf_id}		Request Scout SCF		${scout_testline_name}
    ${TC_ID}				Set Variable			ute:id:${external_scf_id}
    Set Tags				${TC_ID}
	Set Suite variable		${external_scf_id}

Request Scout SCF
	[Documentation]			Request Scout SCF used inside Link SCOUT SCF to Configuration ID for Reporting KW
    [Arguments]				${scout_testline_name}
    scout.setup_scout		scout_testline_name=${scout_testline_name}
    ${external_scf_id}		scout.request_scf   use_scout_internal_id=True
    [Teardown]				scout.teardown_scout_api
    [Return]				${external_scf_id}

Report to QC
	Wait Until Keyword Succeeds		2min    10s      Link SCOUT SCF to Configuration ID for Reporting
	Set QC Id
	Run keyword if					"${Update_to_QC}" == "TRUE"		Update to Reporting portal

Update to Reporting portal
	[Documentation]		Report the status to QC
	Log to console		\nUpdating result to QC as ${TEST STATUS}
	${Res}		Run keyword if	"${TEST STATUS}" == "PASS"		Set variable	passed
	...			ELSE			Set variable	 failed
	${Link}		Report To Rp	name=${TEST NAME}		result=${Res}			ca=${ca}
	...																			testline=${Hostname}	build=${Active_build}	qc_domain=${qc_domain}
	...																			qc_project=${qc_project}		qc_id=${QC_ID}			label=
	...																			tool=WebEM				kpi_results=			links=
	...																			tc_execution_id=${external_scf_id}
	Log to console		\nReportal portal link : \n${Link}

Get Hostname
	[Documentation]		Get hosename of test machine
	${output}			Run			hostname
	${Hostname}			String.Replace String	 string=${output}	   search_for=-	   replace_with=_
	Set Suite variable	${Hostname}

Set QC Id
	[Documentation]		Get QC ID of testcase
	@{sw_list}			String.Split String		${Active_build}	 _
	${status}			Run Keyword And Return Status		Should Be True		${sw_list[2]}==9999
	${Tag}				Run Keyword If		'${status}'=='True'					Set Variable    FL00
    ...     			ELSE    			Set Variable   						${sw_list[0]}
	${QC_ID}    		Get from Dictionary	${${TEST_NAME}}						QC_ID_${Tag}
	Set Suite variable	${QC_ID}
	Set Tags    		${QC_ID}


Start Ttitrace Log capture
    [Arguments]    ${file_name}     ${pysical_cell_ids}=857    ${names}=l2stream3_ttitrace
	[Documentation]    This keyword is used to start ttitrace with streaming mode.
    BuiltIn.Log     ${pysical_cell_ids}
    ${executor}=  Create Dictionary
    ...  host=192.168.255.1
    ...  user=Nemuadmin
    ...  password=nemuuser
    ...  port=443
	${l2_stream_config_1}=  Create Dictionary
    ...  nr_phy_cell_ids=92
    ${l2_stream_config_2}=  Create Dictionary
    ...     nr_phy_cell_ids=92
    ...     up_sw=L2Ps
    @{l2_stream_configuration}    Create List   ${l2_stream_config_1}        ${l2_stream_config_2}
    tcpdump1.create tcpdump collector
    ...  name=tcpdump
    ...  options=-n port 5678 -W 20 -C 50
    ...  sudo_password=${VM_pwd}
    L2STREAM3.Create Sbts L2stream Collector
    ...  name=${names}
    ...  source_ip_addr=${BTS_M_plane_ip}
    ...  destination_ip_addr=${VM_IP}
    ...  collector=tcpdump
    ...  l2_stream_configuration=${l2_stream_configuration}
    ...  webservice=${executor}
    L2STREAM3.Set Suite Alias
    ...  alias=${names}
    Run keyword and ignore error    CORE1.setup_collectors
    ...  names=${names}
    Run keyword and ignore error    CORE1.start_collectors
    ...  names=${names}
    SSH_connection    ${VM_IP}    ${VM_usn}    ${VM_pwd}
#    SSHLibrary.write    cd /home/ute
    ${command}=    set variable    sudo tcpdump -n port 5678 -W 20 -C 50 -w /tmp/${file_name}.pcap > /dev/null 2>&1 &
    OperatingSystem.Run    ${command}
    SSH_teardown

Stop ttitrace Collection
    [Arguments]    ${file_name}     ${log_path}=${OUTPUT_DIR}        ${names}=l2stream3_ttitrace
    CORE1.stop_collectors
    ...  names=${names}
    CORE1.collect_collectors
    ...  names=${names}
    CORE1.teardown_collectors
    ...  names=${names}
    BuiltIn.Log     ${log_path}
    ${pcap_file}=    Set Variable    ${OUTPUT_DIR}/tcpdump_ttitrace.pcap
    SSH_connection    ${VM_IP}    ${VM_usn}    ${VM_pwd}
#    SSHLibrary.write    cd /home/ute
#    ${command}=    set variable    sudo tcpdump -n port 5678 -W 20 -C 50 -w /tmp/${file_name}.pcap -v
#    SSHLibrary.write    ${command}
#    sleep    5s
    OperatingSystem.Run    sudo pkill tcpdump
    OperatingSystem.Run    mkdir -p ${OUTPUT_DIR}/Logs/${file_name}
    ${filepath}    set variable    /tmp/${file_name}*
    OperatingSystem.Run    sudo cp /tmp/${file_name}.pcap00 ${OUTPUT_DIR}/Logs/${file_name}/tcpdump_ttitrace.pcap
    SSH_teardown
    [Return]    ${OUTPUT_DIR}

Common TTI PCAP to CSV Converter ST
    [Arguments]    ${ttitrace_path}    ${dir}=dl
    ${tti_path}      Set Variable     ${ttitrace_path}/tcpdump_ttitrace.pcap
    Builtin.Log     ${dir}
#    ${tti_file_size}    Get File Size    ${tti_path}/tcpdump_ttitrace.pcap
    Eventdecoder.Create Eventdecoder Converter    name=converter     input_file_path=${tti_path}   output_file_format=excelCsv
    Eventdecoder.Convert        name=converter
    OperatingSystem.Run      cp ${EXECDIR}/output_dl.csv ${ttitrace_path};cp ${EXECDIR}/output_ul.csv ${ttitrace_path}
    Common Format Tti In Stream Mode         ${ttitrace_path}/output_dl.csv     ${ttitrace_path}/output_dl_formated.csv
    Common Format Tti In Stream Mode         ${ttitrace_path}/output_ul.csv     ${ttitrace_path}/output_ul_formated.csv

Get Gnb Software
    COAM.setup_admin    bts_host=${gNB_IP}    alias=${connection}    admin_api_log_dir=/tmp
    ${sw_version}    COAM.get_sw_version    connection=${connection}
    COAM.teardown_admin    connection=${connection}
    [Return]    ${sw_version}

Download and install tti decoder
    ${sw_version}   Get Gnb Software
    SSH_connection    ${VM_IP}    ${VM_usn}    ${VM_pwd}
    SSHLibrary.write     wget -b ${package_web_service_SBTS}/SBTS00/${sw_version}/${sw_version}_tti-dec.deb -P ${OUTPUT_DIR}
    Sleep   60s
    SSHLibrary.write    sudo rm -rf /opt/tti-dec
    ${output}=
    ...    SSHLibrary.write    sudo dpkg -i ${OUTPUT_DIR}/${sw_version}_tti-dec.deb
    ${ttidec_failed}=    Run Keyword And Return Status    Should Not Contain    ${output}    No such file
    Run Keyword If    ${ttidec_failed}     Log to Console    Installed tti-decoder files for build version ${sw_version}!
    ...    ELSE     Log to Console    Error installing tti-decoder files for build version ${sw_version}!