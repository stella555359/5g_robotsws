*** Settings ***
Documentation
...               Feature ID: CB012719
Library           BuiltIn
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
Library     taf.collectors.tcpdump    WITH NAME    tcpdump
Library     taf.collectors.core    WITH NAME    core1
Library          XML
Library     testsuite.Bangalore.ORAN.resources.python.ta_ultracaller    WITH NAME    ta_ultracaller
Library          ./python/check_alarm.py
Library          ./python/utility.py
#Resource     ../../../resources/robot/common_log_collection.robot
#Resource     ../../../resources/robot/PM_Counters.robot
#Resource     ./CB012719_Resource.robot
Library     taf.converters.pcaptopdml    WITH NAME    pcaptopdml
Library     taf.analyzer.pdml   WITH NAME   taf_pdml_analyser
Library		taf.ul.alarms_watchdog		WITH NAME	alarm
Library		ute_reporting_portal
Library     taf.sw.scout	WITH NAME   scout
Library     ta5g_enb
Library     taf.collectors.l2stream3    WITH NAME    L2STREAM3
Library     taf.analyzer.pmcounter       WITH NAME    check_pm

Test setup        Run keywords	   Set counter values
...         AND     Prepare environment
...         AND     coam.connect_to     bts_host=${gNB_IP}      bts_port=443    name=admin1

#Test Teardown     Run keywords	Restore environment
#...            AND     Report to QC
#...		    	AND     Run Keyword and Ignore Error		COAM.teardown_admin    connection=${connection}

#Suite teardown		Revert feature parameter

*** Variables ***
${voice_call_TC}=    VONR_Server_Call
@{udpcalltype}=    UDP
@{capabilities}    Legacy_1
@{UE_alias}=  UE1
@{calltype}=    TCP
${cell1}	1
${cell2}	3
${msg_col}		${5}
${con_col}		${19}
${gNB_IP} 		  192.168.255.129
${BTS_M_plane_ip}           10.43.234.54
${DCAP_host}                10.41.209.109
${Default_DCAP_duration}    20
@{at_channel}               ${1}	${2}	${3}
${ports}            ${1}	${2}	${3}
${attenuator_host}          10.45.153.207
${attenuator_port}          ${3001}
#&{BTS_INFO}                 host=${BTS_M_plane_ip}	port=${port}
@{gnb_custom_filters}       condor5gSyslog     cp_5g
@{bts_custom_filter}        scf
${uepc_default_ip}          10.68.126.159
${emil_path}                C://Emil
${emil_profile}             ${emil_path}//profiles//5G
${uepc_Log_path}            C://Users//inbabtslabuser//Documents//Automation_logs
${Scout_tl_name}	    10_2_TMO95NR
${connection}		oam
@{direction_dl}    dl
@{deviation_dl}    200
@{throughput_dl}    1024
@{direction_ul}    ul
@{deviation_ul}    200
@{throughput_ul}    1024
&{Cells_configured}			301=636 	302=857 	303=829 	21=273   22=246 	23=571
${VM_IP} 	   10.43.54.70
${VM_usn}    ute
${VM_pwd}		BT5l@bus3rl0g1n
${CB012719_CVR_12719_TMO_CVR_001}
...		QC_ID_FL00=167696
${gNB_IP_2}					10.68.126.117
${connection_2}				GNB2

${dict_M55194C00285}		['BTS']['MRBTS-30365']['NRBTS-30365']['NRCELL-815']['NRIM']['M55194C00285']
${dict_M55194C00287}        ['BTS']['MRBTS-30365']['NRBTS-30365']['NRCELL-815']['NRIM']['M55194C00287']

*** Test Cases ***
[1]CB012719_CVR_12719_TMO_CVR_001
    Initialise counters
	Log to console		\nPerforming commissioning
    COAM.perform_parameter_recommissioning    dist_name=MRBTS-30365/NRBTS-30365/NRCELL-815/NRRIM_PROFILE-1
    ...    parameter=cellLoadThreshForRimMitigation    value=1    operation=update
    ...    skip_parameter_relation_errors=False    connection=admin1
    Set Suite Variable      ${TEST_LOG_DIRECTORY}       ${OUTPUT_DIR}


    Change framesync and targettotalload of Aggressor		0		0
    Sleep	900s
    ta_ultracaller.Require UE    ue_alias=${UE_alias}   capabilities=${capabilities}
    ta_ultracaller.Detach UE     ue_alias=${UE_alias}
    ta_ultracaller.Attach UE     ue_alias=${UE_alias}
    Sleep		10s
    Log to console    \nStarting DL and UL data transfer
    ta_ultracaller.start_data_transfer  ${UE_alias}   ${udpcalltype}    direction=${direction_dl}		tputcheck=No
	ta_ultracaller.start_data_transfer  ${UE_alias}   ${udpcalltype}    direction=${direction_ul}
    ta_ultracaller.await_data_transfer_finish	${UE_alias}     ${direction_ul}
    ta_ultracaller.await_data_transfer_finish   ${UE_alias}     ${direction_dl}
    Sleep   500s
    Run Keyword and Ignore Error     ta_ultracaller.Calculate Thrughtput	    ue_alias=${UE_alias}	direction=${direction_dl}
    ...		thrughtput=${throughput_dl}     deviation=${deviation_dl}
    Run Keyword and Ignore Error     ta_ultracaller.Calculate Thrughtput     ue_alias=${UE_alias}    direction=${direction_dl}
    ...       thrughtput=${throughput_ul}     deviation=${deviation_dl}

    Change framesync and targettotalload of Aggressor
    Sleep	600s
    Wait For Fault To Be Up     fault_id=7525   timeout=300
    Wait For Fault To Be Up     fault_id=7527   timeout=300
    Wait For Fault To Be Up 	fault_id=7535   timeout=300
    ${285_s2t}     ${287_s2t}     Check counters from gnb1
    Should be True    ${285_s2t} >= 0
    Should be True     ${287_s2t} == 0

    COAM.perform_parameter_recommissioning    dist_name=MRBTS-30365/NRBTS-30365/NRCELL-815/NRRIM_PROFILE-1
    ...    parameter=actRimPowerReduction    value=true    operation=update
    ...    skip_parameter_relation_errors=False    connection=admin1

    Wait For Fault To Be Down     fault_id=7535   timeout=300


	ta_ultracaller.start_data_transfer  ${UE_alias}   ${udpcalltype}    direction=${direction_dl}		tputcheck=No
	ta_ultracaller.start_data_transfer  ${UE_alias}   ${udpcalltype}    direction=${direction_ul}
    ta_ultracaller.await_data_transfer_finish	${UE_alias}     ${direction_ul}
    ta_ultracaller.await_data_transfer_finish   ${UE_alias}     ${direction_dl}
    Sleep   500s
    Run Keyword and Ignore Error     ta_ultracaller.Calculate Thrughtput	    ue_alias=${UE_alias}	direction=${direction_dl}
    ... 		thrughtput=${throughput_dl}     deviation=${deviation_dl}
    Run Keyword and Ignore Error     ta_ultracaller.Calculate Thrughtput     ue_alias=${UE_alias}    direction=${direction_dl}
    ...       thrughtput=${throughput_ul}     deviation=${deviation_dl}
	sleep	350s

#   Verify_in_cqi_and_scheduling_in_tti
    ${285_counter}     ${287_counter}       Check counters from gnb1
    Should be True     ${285_counter} > 0
    Should be True     ${287_counter} == 0


    Change framesync and targettotalload of Aggressor		0		0
    Sleep	600s
    ta_ultracaller.start_data_transfer  ${UE_alias}   ${udpcalltype}    direction=${direction_dl}		tputcheck=No
	ta_ultracaller.start_data_transfer  ${UE_alias}   ${udpcalltype}    direction=${direction_ul}
    ta_ultracaller.await_data_transfer_finish	${UE_alias}     ${direction_ul}
    ta_ultracaller.await_data_transfer_finish   ${UE_alias}     ${direction_dl}
    Sleep   500s
    Run Keyword and Ignore Error     ta_ultracaller.Calculate Thrughtput	    ue_alias=${UE_alias}	direction=${direction_dl}
    ...		thrughtput=${throughput_dl}     deviation=${deviation_dl}
    Run Keyword and Ignore Error     ta_ultracaller.Calculate Thrughtput     ue_alias=${UE_alias}    direction=${direction_dl}
    ...       thrughtput=${throughput_ul}     deviation=${deviation_dl}


*** Keywords ***
Revert feature parameter
    COAM.perform_parameter_recommissioning    dist_name=MRBTS-30365/NRBTS-30365/NRCELL-815/NRRIM_PROFILE-1
    ...    parameter=cellLoadThreshForRimMitigation    value=0    operation=update
    ...    skip_parameter_relation_errors=False    connection=admin1
    COAM.perform_parameter_recommissioning    dist_name=MRBTS-30365/NRBTS-30365/NRCELL-815/NRRIM_PROFILE-1
    ...    parameter=actRimPowerReduction    value=false    operation=update
    ...    skip_parameter_relation_errors=False    connection=admin1

Prepare environment
	COAM.setup_admin    bts_host=${gNB_IP}    alias=${connection}    admin_api_log_dir=/tmp
	${Pre_execution_scf_file}	COAM.Get Current Scf File		local_dir_path=${OUTPUT_DIR}/SCF	file_name=Pre_execution_scf.xml
	...							connection=${connection}	timeout=30
	Set Suite variable			${Pre_execution_scf_file}
	${Branch}		Get Branch
#	Set Suite variable		${SCF_file}         ${CURDIR}/resources/Configuration/${Branch}/${TEST NAME}.xml
#    Restart the GNB     ${connection}
	Run keyword and Ignore Error        COAM.teardown_admin    connection=${connection}
    Sleep   300s

Change framesync and targettotalload of Aggressor
    [Arguments]     ${frame}=607		${load}=100
    COAM.setup_admin    bts_host=${gNB_IP_2}	alias=${connection_2}
    COAM.perform_parameter_recommissioning    dist_name=MRBTS-1907/MNL-1/MNLENT-1/SYNC-1
    ...    parameter=manualFrameTimingAdjustment    value=${frame}    operation=update
    ...    skip_parameter_relation_errors=False    connection=${connection_2}
    Sleep   120s
    COAM.perform_parameter_recommissioning    dist_name=MRBTS-1907/NRBTS-1907/NRCELL-1
    ...    parameter=targetTotalLoad    value=${load}    operation=update
    ...    skip_parameter_relation_errors=False    connection=${connection_2}
    Sleep   120s

Restore environment
	COAM.setup_admin    bts_host=${gNB_IP}    alias=${connection}    admin_api_log_dir=/tmp
	Collect snapshot from BTS
#	Log to console		\nPerforming commissioning
#	COAM.Perform Commissioning		bts_id=${BTS_ID}		scf_file=${Pre_execution_scf_file}			skip_parameter_relation_errors=True
#    ...								should_activate=True	timeout=500	    connection=${connection}
	COAM.teardown_admin    connection=${connection}
    Change framesync and targettotalload of Aggressor
    COAM.teardown_admin    connection=${connection_2}

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
	Run Keyword If		'${status}'=='False'				Builtin.Log   					Snapshot collection failed !!!			ERROR

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

Get TcpdumpLogs from Remote machine
    [Documentation]    this keyword is used to capture wireshark log in wireshark PC
    log to console    \n--Starting Wireshark Logs--
    ${executor_oam_vm}=  Create Dictionary
    ...  host=10.58.239.119
    ...  user=toor4nsn
    ...  password=oZPS0POrRieRtu
    tcpdump.create_tcpdump_collector
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
    [Arguments]    ${pysical_cell_ids}=857    ${names}=l2stream3_ttitrace
    [Documentation]    This keyword is used to start ttitrace with streaming mode.
    ${executor}=  Create Dictionary
    ...  host=192.168.255.1
    ...  user=Nemuadmin
    ...  password=nemuuser
    ...  port=443
    ${nr_phy_cell_ids}=    Common Get PhysCellId Of GNB Runtime
    Log Many    ${pysical_cell_ids}       ${nr_phy_cell_ids}
#    ${l2_stream_config_1}=  Create Dictionary
#    ...  nr_phy_cell_ids=${nr_phy_cell_ids}
#    @{l2_stream_configuration}=  Create List  ${l2_stream_config_1}

#    ${l2_stream_config_1}=  Create Dictionary
#    ...  nr_phy_cell_ids=${857}
#    ${l2_stream_configuration}=     Create List   /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-55057/NRCELL_R-302

#    ${nr_cell_dns}    Create List    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-55057/NRCELL_R-302
#    ...  nr_phy_cell_ids=857
    ${l2_stream_config_1}=  Create Dictionary
    ...  nr_phy_cell_ids=857
    ${l2_stream_config_2}=  Create Dictionary
#    ...  nr_cell_dns=${nr_cell_dns}
    ...     nr_phy_cell_ids=857
    ...     up_sw=L2Ps
    ${l2_stream_configuration}    Create List   ${l2_stream_config_1}        ${l2_stream_config_2}
    tcpdump.create tcpdump collector
    ...  name=tcpdump
    ...  options=-i eth0 udp and dst 10.43.54.70 and dst port 5678
    ...  sudo_password=${VM_pwd}

    L2STREAM3.Create Sbts L2stream Collector
    ...  name=${names}
    ...  source_ip_addr=10.41.211.160
    ...  destination_ip_addr=${VM_IP}
    ...  collector=tcpdump
    ...  l2_stream_configuration=${l2_stream_configuration}
    ...  webservice=${executor}
    L2STREAM3.Set Suite Alias
    ...  alias=${names}
#    CORE1.setup_collectors
#    ...  names=${names}
#    CORE1.start_collectors
#    ...  names=${names}


Stop ttitrace Collection
    [Arguments]    ${log_path}=${OUTPUT_DIR}        ${names}=l2stream3
    CORE1.stop_collectors
    ...  names=${names}
    CORE1.collect_collectors
    ...  names=${names}
    CORE1.teardown_collectors
    ...  names=${names}
    ${pcap_file}=    Set Variable    ${log_path}/${SUITE_NAME}/${TEST_NAME}/${names}/tcpdump_ttitrace/tcpdump_ttitrace.pcap

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
	ta5g_pm_counters.wait_for_next_full_pm_interval
	${counter1}     Run keyword and continue on failure		Counter value	M55194C00285	815		${dict_M55194C00285}    admin1
	${counter2}     Run keyword and continue on failure		Counter value	M55194C00287	815		${dict_M55194C00287}    admin1
    [Return]        ${counter1}     ${counter2}

Counter value
	[Documentation]			Check counter value of BTS
	[Arguments]				${counter_name}			${cell}			${Dict_val}			${connect}=${connection}
	Log to console			\nChecking BTS counter ${counter_name}
	${result}				COAM.get_pm_counters	counter_ids=${counter_name}	timeout=1000	connection=${connect}
	Builtin.Log						${result}
    Builtin.Log                     ${cell}
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

Set counter values
	[Documentation]			Set counter expected values
	&{Counters_val}			Create Dictionary	M55194C00285=${3}		M55194C00287=${2}
	@{Counters_list}			Create list		M55194C00287	M55194C00287
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

Verify_in_cqi_and_scheduling_in_tti
    ${protected_slots}    Create List    ${2}    ${3}    ${12}    ${13}
    Start Ttitrace Log capture         ttitrace
    sleep     1s
    ${high_load}     Stop ttitrace Collection     ttitrace         test_scenario=high_load_by_config
    Decode TTI Trace    high_load_by_config
    ${high_status}   get_cqi_derived_verify   ${high_load}[ttitrace]/output_dl_formated.csv    ${protected_slots}
    ${high_status_sche}    check_scheduling    ${high_load}[ttitrace]/output_dl_formated.csv     ${protected_slots}
    Should Contain      ${high_status}   pass
    Should Contain     ${high_status_sche}    pass

