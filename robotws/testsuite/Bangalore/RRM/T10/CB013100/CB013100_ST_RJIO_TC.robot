*** Settings ***
Documentation
...               Feature ID: CB013100
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
#Library          ./python/check_alarm.py
#Library          ./python/utility.py
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
Library		DateTime
Library          taf.converters.eventdecoder  WITH NAME  EVENTDECODER
Library           ../../../resources/python/streaming_ttitrace_analyzer.py    WITH NAME    TTITRACEANALYZER
Library           ../../../resources/python/tti_convert.py    WITH NAME    TtiConvert
Library           ../../../resources/python/tti_stream_mode_convert.py    WITH NAME    TtiSMConvert


Test setup        Run keywords      Prepare environment
...         AND     coam.connect_to     bts_host=${gNB_IP}      bts_port=443    name=admin1

Test Teardown       Stop Syslog

#Test Teardown     Run keywords	Restore environment
#...            AND     Report to QC
#...		    	AND     Run Keyword and Ignore Error		COAM.teardown_admin    connection=${connection}

#Suite teardown		Revert feature parameter

*** Variables ***
${voice_call_TC}=    VONR_Server_Call
@{udpcalltype}=    UDP
@{capabilities_1}    Legacy_1
@{UE_alias_1}=  UE1
@{capabilities_2}    Legacy_2
@{UE_alias_2}=  UE2
@{calltype}=    TCP
${cell1}	1
${cell2}	3
${msg_col}		${5}
${con_col}		${19}
${gNB_IP} 		  192.168.255.129
${BTS_M_plane_ip}           10.68.126.120
${DCAP_host}                10.41.209.109
${Default_DCAP_duration}    20
@{at_channel}               ${1}	${2}
${ports}            ${1}	${2}
${attenuator_host}          10.43.234.54
${attenuator_port}          ${3001}
#&{BTS_INFO}                 host=${BTS_M_plane_ip}	port=${port}
@{gnb_custom_filters}       condor5gSyslog     cp_5g
@{bts_custom_filter}        scf
${uepc_default_ip}          10.68.126.229
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
&{Cells_configured}			0=376
${VM_IP} 	   10.68.126.92
${VM_usn}    ute
${VM_pwd}		BT5l@bus3rl0g1n
${CB012719_CVR_12719_TMO_CVR_001}
...		QC_ID_FL00=167696
${gNB_IP_2}					10.68.126.117
${connection_2}				GNB2

${dict_M55165C00040}		['BTS']['MRBTS-30332']['NRBTS-30332']['NRCELL-0']['NRUC']['M55165C00040']
${dict_M55308C10001}		['BTS']['MRBTS-30332']['NRBTS-30332']['NRCELL-0']['NCELA']['M55308C10001']
${dict_M55300C00061}		['BTS']['MRBTS-30332']['NRBTS-30332']['NRCELL-0']['NDLHQ']['M55300C00061']
${dict_M55300C00060}		['BTS']['MRBTS-30332']['NRBTS-30332']['NRCELL-0']['NDLHQ']['M55300C00060']
${dict_M40002C0}		['BTS']['MRBTS-30332']['SBTS_Energy_Consumption']['M40002C0']
${dict_M40002C1}		['BTS']['MRBTS-30332']['SBTS_Energy_Consumption']['M40002C1']
${dict_M40002C2}		['BTS']['MRBTS-30332']['SBTS_Energy_Consumption']['M40002C2']

*** Test Cases ***
[1]CB013100_CVR_RJIO_SA

    Initialise counters
    Log to console		\nPerforming commissioning
    COAM.perform_delta_recommissioning		delta_file=${CURDIR}/config/SBTS26R2/Delta_config_rjio.json
	...			skip_parameter_relation_errors=False    should_activate=True	 timeout=300		connection=admin1
    Set Suite Variable      ${TEST_LOG_DIRECTORY}       ${OUTPUT_DIR}
    Start Syslog
    ta_ultracaller.Require UE    ue_alias=${UE_alias_1}   capabilities=${capabilities_1}
    ta_ultracaller.Detach UE     ue_alias=${UE_alias_1}
    Run Keyword and Ignore Error    ta_ultracaller.Attach UE     ue_alias=${UE_alias_1}
    #ta_ultracaller.Require UE    ue_alias=${UE_alias_2}   capabilities=${capabilities_2}
    #ta_ultracaller.Detach UE     ue_alias=${UE_alias_2}
    #Run Keyword and Ignore Error    ta_ultracaller.Attach UE     ue_alias=${UE_alias_2}
    Sleep		10s
    Log to console    \nStarting DL and UL data transfer
    ta_ultracaller.start_data_transfer  ${UE_alias_1}   ${udpcalltype}    direction=${direction_dl}   tputcheck=No
    ta_ultracaller.start_data_transfer  ${UE_alias_1}   ${udpcalltype}    direction=${direction_ul}
     Sleep		100s

    ta5g_pm_counters.wait_for_next_full_pm_interval
    ${BFR_PRB_ALLOC_PDSCH_BFR_PO_STEP}     Counter value	M55165C00040	0	${dict_M55165C00040}    admin1
    ${BFR_PRB_USED_PDSCH}     Counter value	M55308C10001	0	${dict_M55308C10001}    admin1
    ${BFR_ENERGY_CONSUMPTION_IN_SM}     Counter value	M40002C0	30332	${dict_M40002C0}    admin1
    ${BFR_ENERGY_CONSUMPTION_IN_RF}     Counter value	M40002C1	30332	${dict_M40002C1}    admin1
    ${BFR_ENERGY_CONSUMPTION_IN_BTS}     Counter value	M40002C2	30332	${dict_M40002C2}    admin1
    ${BFR_AVG_MCS_INITX_BFR_PO_256QAM}    Counter value		 M55300C00061	0	${dict_M55300C00061}    admin1
    ${BFR_AVG_MCS_INITX_BFR_PO_64QAM}    Counter value		 M55300C00060	0	${dict_M55300C00060}    admin1


    COAM.perform_parameter_recommissioning    dist_name=MRBTS-30332/NRBTS-30332/NRCELL-0
    ...    parameter=actFdpolite    value=true    operation=update
    ...    skip_parameter_relation_errors=False    connection=admin1
    Sleep		100s


    ta5g_pm_counters.wait_for_next_full_pm_interval
    ${AFR_PRB_ALLOC_PDSCH_BFR_PO_STEP}     Counter value	M55165C00040	0	${dict_M55165C00040}    admin1
    ${AFR_PRB_USED_PDSCH}     Counter value	M55308C10001	0	${dict_M55308C10001}    admin1
    ${AFR_ENERGY_CONSUMPTION_IN_SM}     Counter value		M40002C0	30332	${dict_M40002C0}    admin1
    ${AFR_ENERGY_CONSUMPTION_IN_RF}     Counter value		M40002C1	30332	${dict_M40002C1}    admin1
    ${AFR_ENERGY_CONSUMPTION_IN_BTS}     Counter value		M40002C2	30332	${dict_M40002C2}    admin1
    ${AFR_AVG_MCS_INITX_BFR_PO_256QAM}    Counter value		 M55300C00061	0	${dict_M55300C00061}    admin1
    ${AFR_AVG_MCS_INITX_BFR_PO_64QAM}    Counter value		 M55300C00060	0	${dict_M55300C00060}    admin1


    Run Keyword and Ignore Error     Should be equal     ${BFR_PRB_ALLOC_PDSCH_BFR_PO_STEP}      ${BFR_PRB_USED_PDSCH}
#    Run Keyword and Ignore Error     Should be true     ${BFR_PRB_ALLOC_PDSCH_BFR_PO_STEP} < ${AFR_PRB_USED_PDSCH}

#   Run Keyword and Ignore Error     Should be true     ${AFR_ENERGY_CONSUMPTION_IN_SM} < ${BFR_ENERGY_CONSUMPTION_IN_SM}
#    Run Keyword and Ignore Error      Should be true     ${AFR_ENERGY_CONSUMPTION_IN_RF} < ${BFR_ENERGY_CONSUMPTION_IN_RF}
#    Run Keyword and Ignore Error      Should be true     ${AFR_ENERGY_CONSUMPTION_IN_BTS} < ${BFR_ENERGY_CONSUMPTION_IN_BTS}
#    ${result}     Run Keyword and Ignore Error     Set variable If
    ...      ${AFR_AVG_MCS_INITX_BFR_PO_256QAM} > 4 and ${AFR_AVG_MCS_INITX_BFR_PO_256QAM} < 6    PASS      FAIL
#    ta_ultracaller.Detach UE     ue_alias=${UE_alias_1}

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
#	Log to console		\nPerforming commissioning
#   OAM.Perform Commissioning		bts_id=${BTS_ID}		scf_file=13396_sa_working_scf.xml			skip_parameter_relation_errors=True
#   ...								should_activate=True	timeout=500	    connection=${connection}
#   un keyword and Ignore Error        COAM.teardown_admin    connection=${connection}
#   Sleep   300s

Restore environment
	COAM.setup_admin    bts_host=${gNB_IP}    alias=${connection}    admin_api_log_dir=/tmp
	Collect snapshot from BTS
#	Log to console		\nPerforming commissioning
	COAM.Perform Commissioning		bts_id=${BTS_ID}		scf_file=${Pre_execution_scf_file}			skip_parameter_relation_errors=True
    ...								should_activate=True	timeout=500	    connection=${connection}
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
    ${command}  set variable    tshark -r ${TEST_LOG_DIRECTORY}/tcpdump/tcpdump.pcap -Y "${filter}" > ${TEST_LOG_DIRECTORY}/tcpdump/${filename}.txt
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
	...																		testline=${Hostname}	build=${Active_build}	qc_domain=${qc_domain}
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
    [Arguments]    ${pysical_cell_ids}    ${names}=l2stream3_ttitrace
    [Documentation]    This keyword is used to start ttitrace with streaming mode.
    ${executor}=  Create Dictionary
    ...  host=192.168.255.129
    ...  user=Nemuadmin
    ...  password=nemuuser
    ...  port=443
#    ${nr_phy_cell_ids}=    Common Get PhysCellId Of GNB Runtime
#    Log Many    ${pysical_cell_ids}       ${nr_phy_cell_ids}
#    ${l2_stream_config_1}=  Create Dictionary
#    ...  nr_phy_cell_ids=${nr_phy_cell_ids}
#    @{l2_stream_configuration}=  Create List  ${l2_stream_config_1}

#    ${l2_stream_config_1}=  Create Dictionary
#    ...  nr_phy_cell_ids=${857}
#    ${l2_stream_configuration}=     Create List   /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-55057/NRCELL_R-302

#    ${nr_cell_dns}    Create List    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-55057/NRCELL_R-302
#    ...  nr_phy_cell_ids=857
    ${l2_stream_config_1}=  Create Dictionary
    ...  nr_phy_cell_ids=${pysical_cell_ids}
    ...  profile_filter_list=Default,All events
    ...  trace_type=Component
    ...  target_component=L2Ps
    @{l2_stream_configuration}=  Create List  ${l2_stream_config_1}

    tcpdump.create tcpdump collector
    ...  name=tcpdump_ttitrace
    ...  options=-i any udp and dst 10.68.126.92 and dst port 5678
    ...  sudo_password=${VM_pwd}
   Log to console               starting ttitrace
    L2STREAM3.Create Sbts L2stream Collector
    ...  name=${names}
    ...  source_ip_addr=10.68.126.120
    ...  destination_ip_addr=${VM_IP}
    ...  collector=tcpdump_ttitrace
    ...  l2_stream_configuration=${l2_stream_configuration}
    ...  webservice=${executor}
    L2STREAM3.Set Suite Alias
    ...  alias=${names}
    CORE1.setup_collectors
    ...  names=${names}
    CORE1.start_collectors
    ...  names=${names}

Stop ttitrace Collection
    [Arguments]       	 ${test_scenario}  		${log}=ttitrace    ${log_path}=${OUTPUT_DIR}          ${names}=l2stream3_ttitrace
	${common_log_path}      Create Dictionary
    ${TEST_NAME}      replace string    ${TEST_NAME}      ${SPACE}      _
    set suite variable     ${TEST_NAME}
	${log}    String.Convert To Lowercase    ${log}
    ${log_dir_gnb}           Set Variable          /home/ute/robotws/Logs/${TEST_NAME}/gNB/${log}/${test_scenario}
    CORE1.stop_collectors
    ...  names=${names}
    CORE1.collect_collectors
    ...  names=${names}
    CORE1.teardown_collectors
    ...  names=${names}
    ${pcap_file}=    Set Variable    ${log_path}/${SUITE_NAME}/${TEST_NAME}/${names}/tcpdump_ttitrace/tcpdump_ttitrace.pcap
    OperatingSystem.Run    mkdir -p ${log_dir_gnb}; cp -r "${pcap_file}" ${log_dir_gnb}
	Set To Dictionary     ${common_log_path}        ${log}       ${log_dir_gnb}
    [Return]        ${common_log_path}

Decode TTI Trace
    [Arguments]    ${ttitrace_path}=${EMPTY}
    Log to console                            converting ttitrace pcap to csv
    ${TEST_NAME}      replace string    ${TEST_NAME}      ${SPACE}      _
    set suite variable     ${TEST_NAME}
    ${tti_path}      Set Variable     /home/ute/robotws/Logs/${TEST_NAME}/gNB/ttitrace/${ttitrace_path}/
    Common Convert Ttitrace From Pcap To Excelcsv        ${tti_path}
    Common Convert Tti To Csv Mode          ${tti_path}

Common Convert Tti To Csv Mode
    [Arguments]         ${tti_path}
    Common Format Tti In Stream Mode         ${tti_path}/output_dl.csv     ${tti_path}/output_dl_formated.csv
    Common Format Tti In Stream Mode         ${tti_path}/output_ul.csv     ${tti_path}/output_ul_formated.csv

Common Convert Ttitrace From Pcap To Excelcsv
    ${TEST_NAME}      replace string    ${TEST_NAME}      ${SPACE}      _
    set suite variable     ${TEST_NAME}
    [Arguments]    ${log_path}=${OUTPUT_DIR}    ${names}=l2stream3_ttitrace    ${filename}=tcpdump_ttitrace.pcap
    Builtin.Log   ${names}
    ${file_path}=    Set Variable    ${log_path}/${filename}
    EVENTDECODER.Create Eventdecoder Converter
    ...  name=converter
    ...  input_file_path=${file_path}
    ...  output_file_format=excelCsv
    EVENTDECODER.Convert
    ...  name=converter
    OperatingSystem.Run    cp ${EXECDIR}/output_dl.csv ${log_path};cp ${EXECDIR}/output_ul.csv ${log_path}

Common Format Tti In Stream Mode
    [Arguments]    ${input_csv_name}    ${output_csv_name}    ${filters}=${EMPTY}
    [Documentation]    This keyword is to convert tti collected by stream mode.
    ...    Parameters same as keyword: Format Tti In Snapshot Mode
    Run Keyword If    '${filters}'=='${EMPTY}'    TtiSMConvert.Format Tti Stream Mode No Filters    ${input_csv_name}    ${output_csv_name}
    ...    ELSE    TtiSMConvert.Format Tti Stream Mode With Filters    ${input_csv_name}    ${output_csv_name}    ${filters}


Check counters
	[Documentation]		Check counters
	[Arguments]	   		${counter}=${Counters_list}		${cell}=1
	ta5g_pm_counters.wait_for_next_full_pm_interval
	FOR		${check}	IN	 @{counter}
		${value}	Run keyword and continue on failure		Counter value	${check}	${cell}
		Run keyword and continue on failure		Set test Variable	${${check}_count}	 ${value}
        ${expected_count}    Get From Dictionary     ${Counters_val}     ${check}
#        Run keyword and continue on failure     Should be true      ${${check}_count} != 0
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
	&{Counters_val}			Create Dictionary	M55165C00040=${3}		M55308C10001=${2}
	@{Counters_list}			Create list		M55165C00040	M55308C10001
	Set Suite variable		&{Counters_val}
	Set Suite variable		@{Counters_list}


Initialise counters
        Set counter values
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

Start Syslog
    [Documentation]    ... Starting Syslogs
    Run                             killall btslog
    btslog.create_btslog_collector
    ...   name=btslog
    ${status} 	Run Keyword And Return Status 		core1.setup_collectors    names=btslog
    ${status} 	Run Keyword And Return Status 		core1.start_collectors    names=btslog
    core1.set_suite_alias    btslog
	Run Keyword If 		'${status}'!='False'		Set test variable			${BTSlog_status}	Started

Stop Syslog
    sleep    20s
    core1.stop_collectors      names=btslog
    core1.collect_collectors      names=btslog          target_dir=${OUTPUT_DIR}
    BuiltIn.Log     ${OUTPUT_DIR}
    core1.teardown_collectors      names=btslog

Stop Syslog and verify monitor timer
	[Arguments]		 ${expected_value}
    Run Keyword If		'${BTSlog_status}'=='Started'		Stop Syslog
    ${log_file}     OperatingSystem.Run         tar -xvf ${OUTPUT_DIR}/btslog/syslog_files.tgz -C ${OUTPUT_DIR}/btslog/
    Sleep   10s
    ${timer_start}  OperatingSystem.Run		cat ${OUTPUT_DIR}/btslog/SYSLOG_* | grep -i "Start monitorTimerForCellDisable" | awk '{print $3}'
    ${timer_end}    OperatingSystem.Run     cat ${OUTPUT_DIR}/btslog/SYSLOG_* | grep -i "Timeout monitorTimerForCellDisable time" | awk '{print $3}'
    ${timer_start}       Split String    ${timer_start}      .
    ${timer_end}        Split String    ${timer_end}         .
    ${time_diff}    DateTime.Subtract Time from Time     ${timer_end}[0]        ${timer_start}[0]
#    Should Be Equal As Integers       ${time_diff}       ${expected_value}
    ${result}         Evaluate    (${expected_value} + 2.0) >= ${time_diff} >= (${expected_value} - 2.0)
#    Should Be True    ${result}



Check Only Cells Are Disabled
    [Arguments]     ${conn}   ${expected_avail_state}    ${expected_oper_state}    @{target_cells}
    ${nr_cells}=    coam.get_cells_info         connection=${conn}
    FOR    ${nr_cell}    IN    @{nr_cells}
    ${nr_cell_dn}=    Set Variable    ${nr_cell["id"]["configuration"]}
    ${is_target_cell}=    Run Keyword And Return Status    Should Contain    ${target_cells}    ${nr_cell_dn}

    IF    ${is_target_cell}
        ${status_dict}=    Get From Dictionary    ${nr_cell}    status
        ${availabilityStatus}=    Get From Dictionary    ${status_dict}    availabilityStatus
        ${operationalState}=    Get From Dictionary    ${status_dict}    operationalState
        Should Be Equal    ${availabilityStatus}    ${expected_avail_state}
        Should Be Equal    ${operationalState}    ${expected_oper_state}
    END
    END

Check Only Cells Are In Enabled State
    [Arguments]    ${conn}  ${expected_oper_state}   @{expected_cells}
    ${nr_cells}=    coam.get_cells_info             connection=${conn}
    FOR    ${nr_cell}    IN    @{nr_cells}
        ${nr_cell_dn}=    Set Variable    ${nr_cell["id"]["configuration"]}
        ${status_dict}=    Get From Dictionary    ${nr_cell}    status
        ${operationalState}=    Get From Dictionary    ${status_dict}    operationalState

        ${is_target_cell}=    Run Keyword And Return Status    Should Contain    ${expected_cells}    ${nr_cell_dn}
        IF    ${is_target_cell}
            Should Be Equal    ${operationalState}    ${expected_oper_state}
        END
    END


Check If fault 7706 Appeared and failed paths info ST
    [Documentation]    This keyword checks if an  fault ID 7706 appeared and fetches additional information.
    [Arguments]     ${conn}   ${severity}
    @{alarm_history}=    COAM.Get Active Alarms     connection=${conn}
    ${alarm_found}    Set Variable    ${False}
    FOR  ${alarm}  IN  @{alarm_history}
        ${alarm_fault_id}=    Get From Dictionary    ${alarm}    faultId
        ${alarm_severity}=      Get From Dictionary    ${alarm}    faultSeverity
        ${contains_faultid}=    Run Keyword And Return Status
        ...    Should Be Equal As Strings    ${alarm_fault_id}    7706
        Run Keyword If    '${contains_faultid}' == 'True' and '${alarm_severity}' == '${severity}'
        ...    Exit For Loop
    END
    Run Keyword If    not ${contains_faultid}
    ...    Fail    Alarm with fault ID 7706 did not appear.
    BuiltIn.Log   Alarm Found: fault-7706, alarmAttribute: ${alarm['alarmAttribute'][0]['attributeValue']}
    [RETURN]    ${alarm}
