*** Settings ***

Documentation
...   author: T02
...   contact: T02
...   Description: Test Suite for CB007814-F_CB008796


Library             Process
Library             Collections
Library             OperatingSystem    WITH NAME     os
Library             taf.sw.dcap.rd       WITH NAME     dcap
Library             taf.sbts.oam.coam.admin    WITH NAME     admin
Library             String
Library             taf.collectors.core   WITH NAME   core
Library             taf.collectors.btslog  WITH NAME   btslog
Library             taf.transport.ssh    WITH NAME    ssh
Library             SSHLibrary
Library             BuiltIn
Library             taf.sw.scout    WITH NAME    scout
Library             ute_fsmaccess
Library             DateTime
#Library             taf.collectors.ip_traffic_capturing    WITH NAME    ip_traffic_capturing
Library	            ./testsuite/Bangalore/ORAN/resources/python/Tshark_Validation.py
Library             taf.collectors.tshark    WITH NAME    tshark
Library             taf.collectors.simple    WITH NAME    simple
Library             taf.collectors.pmcounters    WITH NAME    PM
Library             taf.analyzer.pmcounter    WITH NAME    analyser
Library             ./testsuite/Bangalore/ORAN/resources/python/ta_ultracaller/
Library             ./testsuite/Bangalore/ORAN/SG04/resources/dcap_extract_file.py
Resource            ./testsuite/Bangalore/ORAN/SG04/resources/reportingportal_Keywords.robot
#Resource           ./testsuite/Bangalore/ORAN/resources/robot/common_log_analyzer.robot
#Resource           ./testsuite/Bangalore/ORAN/resources/python/Macro/bts/gnb.robot
#Resource           ../resources/common/common_suite_setup_teardown.robot

Force Tags          CRT    8796_SG02    TRUNK_7814    FL00    QCD_MN_RAN    QCP_RAN_VRF
Test Setup    Test setup
Test TearDown    test teardown
Suite Setup		Suite_Setup
Suite Teardown		Suite_Teardown


*** Variables ***
@{Rollback_build}=    SBTS24R2
${BTS_ADDRESS}     192.168.255.129
${bts_ip2}    10.58.239.89
${connection}    BTS_Session
${connection2}    eNB_Session
${ssh_port}                 443
${BTS_ID}                          970
${log_alias}    btslog
${bool}=    True
${str}=  SBTS00
${LOGS_PATH}=    /home/ute/logs
${wait_for_transfer}        True
${VM_HOST_IP}=  10.58.238.71
${VM_username}=  ute
${VM_Password}=  BT5l@bus3rl0g1n
${BTSLOG_Path_for_validation}               /tmp/btslog2
&{BTS_Details}                     bts_host=192.168.255.129
...                                bts_port=443
...                                username=Nemuadmin
...                                password=nemuuser
...                                use_ssl=True
...                                update_interval=5000
...                                admin_api_log_dir=${EXECDIR}
...                                name=default
...                                bundle_path=None
...                                release=SBTS242
${btsremoteip}=    10.58.239.169
#${dcaphost}=    10.41.209.115
${sw_release}=    SBTS24R3
${DCAP_host}                10.41.209.115                                             #DCAP server IP
${Windows_user}             inbabtslabuser                                            # Windows UE PC username
${Windows_pass}             BT5l@bus3rl0g1n
${dcap_log_timeout}=	800s
${NrcellId}=    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-970/NRCELL_R-2
${TestModel}=   TM1_1
@{BeamPatternId} =	0	0
${polarization}=    P_plus45_or_0
${powerBackoff}=   0
${ruMode}=   NR_Only
${PhyCellId}=    30
${pmax}=    40
${nrarfcnDl}=   432000
${nrarfcnUl}=	394000
${MIMOrank}=    1
${codebook2antports}=    0
${i11Codebook4antports}=   0
${i2codebook4antports}=    0
${i13codebook4antports}=    0
@{Required_bts_status} =   Test    OnAir
${interval}=    30s
${BTS_path}=    /home/ute/results
${ABSTRACT_LIB_CONFIG}=    /home/ute/testline_configuration_5G/Bangalore/10_2_UTE5GTLBTS970/ta_ue_config.yaml
#@{timeout}=             100
#@{deviation_dl}=        100
@{throughput_dl}=       500
@{throughput_ul}=   100
#@{udpcalltype}=         UDP
@{UE_alias}=            UE3
@{capabilities}=        Legacy_3
${SCF_Pre}=    /home/ute/robotws/testsuite/Bangalore/ORAN/SG04/CB007814/7814_SG02/SCF_Files/PreSetup_Config.xml
${SCF_TDS}=    /home/ute/robotws/testsuite/Bangalore/ORAN/SG04/CB007814/7814_SG02/SCF_Files/TDS_Mode_Config.xml
${dcapuser_name}    utfuser                                 #this need to be changed for dcap latest dcap version
${dcap_password}    utfadmin!
${PATH}    /home/ute/Documents/Automation_run_1
${PATH1}    /home/ute/Documents/Automation_run_2
${testcase_name}=    LTE5640
${testcase_name1}=    LTE5667
@{direction_dl}=  dl
@{direction_ul}=  ul
@{duration}=  700s
@{timeout}      180
@{tcpcalltype}=    TCP
@{udpcalltype}=    UDP
@{deviation_dl}=  90
@{deviation_ul}=  90
${packet_size}=  1400
${tput}=   100Mbits/sec

#############
## QC TAGS ##
#############

#&{[1]CB007814-F_Verification of site moving to TDS and then back to normal state.}
#...    QC_ID_SBTS23R4=QC_670527    QC_ID_FL00=QC_650529

&{CB008796_LTE5640_To configure eligible EN-DC bearers with flexible ARP ranges}
...    QC_ID_SBTS24R2=QC_773797    QC_ID_FL00=QC_31653

#&{CB008796_LTE5667_Extended B1 measurement report for NR}
#...    QC_ID_SBTS24R2=QC_773796    QC_ID_FL00=QC_31652


*** Test Cases ***

#CB007814-F_Verification of site moving to TDS and then back to normal state

#    	[Setup]    Test Setup
#    	Wait Until Keyword Succeeds    10min    30s    Validate_BTS_STATUS    ${Required_bts_status}[1]
#    	move_to_test_dedicated_state_Enable
#    	start_downlinkNr_test
#    	stop_downlinkNr_test
#    	move_to_test_dedicated_state_Disable
#    	[Teardown]      Test Teardown

CB008796_LTE5640_To configure eligible EN-DC bearers with flexible ARP ranges
	[Setup]    Test Setup
	Parameter_recommissioning
	Require_UE
	Detach_UE
	Start DCAP Trace
	UE_attach
	Start data throughput
	Detach_UE
	Stop DCAP Trace
	unzip the pcap trace
    	Wireshark PCAP validation
	RP Settings
    	Wait Until Keyword Succeeds    2min    10s      Link SCOUT SCF to Configuration ID for Reporting
    	Set QC_Tag
	[Teardown]      Test Teardown

#CB008796_LTE5667_Extended B1 measurement report for NR
#	[Setup]    Test Setup
#	Parameter_recommissioning_cfra
#	Require_UE
#	Detach_UE
#	Start DCAP Trace1
#	UE_attach
#	Start data_DL
#	Detach_UE
#	Stop DCAP Trace1
#	unzip the pcap trace1
#	Wireshark PCAP validation1
#	RP Settings
#   	Wait Until Keyword Succeeds    2min    10s      Link SCOUT SCF to Configuration ID for Reporting
#    	Set QC_Tag
#	[Teardown]      Test Teardown


*** Keywords ***
move_to_test_dedicated_state_Enable
    	Run Keyword And Continue On Failure    admin.reset_to_test_dedicated     detailed_output=True
	sleep     15m     To check the state of BTS after disable.
	Wait Until Keyword Succeeds    10min    30s    Validate_BTS_STATUS    ${Required_bts_status}[0]
	Log To Console    --Setup Moved to TDS--\n

Validate_BTS_STATUS
	[Arguments]    ${Required_BTS_Status}
	Log To Console    --${Required_BTS_Status}--\n
	admin.connect_to
    	${bts_status}=  admin.get_bts_statuses
	${var}  Set Variable    ${bts_status['proceduralState']}
	${str}  BuiltIn.Convert To String    ${var}

move_to_test_dedicated_state_Disable
    	admin.reset_site
	sleep     15m     To check the state of BTS after disable.
    	Wait Until Keyword Succeeds    20min    30s    Validate_BTS_STATUS    ${Required_bts_status}[1]
	Log To Console    --Setup Moved to On Air--\n

start_downlinkNr_test
	Log To Console    --Starting NR Downlink Test--\n
    	Run Keyword And Continue On Failure     admin.start_5g_downlink_test    dist_name=${NrcellId}

	...								test_model=${TestModel}
	...								beam_pattern_id=@{BeamPatternId}
	...								polarization=${polarization}
	...								power_backoff=${powerBackoff}
	...								ru_mode=${ruMode}
	...								phys_cell_id=${PhyCellId}
	...								codebook_2_antports=${codebook2antports}
	...								i11_codebook_4_antports=${i11Codebook4antports}
	...								i2_codebook_4_antports=${i2codebook4antports}
	...								i13_codebook_4_antports=${i13codebook4antports}
	...								mimo_rank=${MIMOrank}
	...								p_max=${pmax}
	...								nrarfcn_dl=${nrarfcnDl}
	...								nrarfcn_ul=${nrarfcnUl}
	sleep   1m

stop_downlinkNr_test
    	Run Keyword And Continue On Failure     admin.stop_5g_downlink_test    dist_name=${NrcellId}
	Log To Console    --NR downlink Test Completed--\n

Stops Btslogs from Local machine
    	[Documentation]    path from where to get btslog files default value: \u201c/tmp/btslog2\u201d
    	#[Arguments]    ${log_alias}
    	Run Keyword And Continue On Failure     core.stop_collectors      btslog
    	Run Keyword And Continue On Failure     core.collect_collectors      btslog
    	Run Keyword And Continue On Failure    core.teardown_collectors      btslog


Start Btslogs from Local machine
    	[Documentation]    path from where to get btslog files default value: \u201c/tmp/btslog2\u201d
    	...
    	#[Arguments]    ${log_alias}
    	btslog.create_btslog_collector    btslog
    	...    log_dir=/tmp/btslog2
    	core.setup_collectors     btslog
    	core.start_collectors     btslog
    	core.Set Suite Alias    btslog

Set QC_Tag depending on SW version

    	admin.connect_to
	${v}=    admin.get_software_info    timeout=30
	LOG    ********* Active SW Version is ${v['Active SW version']}*********
	${ActiveSW}    Set Variable    ${v['Active SW version']}
	${ActiveSWstr}  BuiltIn.Convert To String    ${ActiveSW}
	Set Suite Variable    ${OUT_ENB_ACTIVE_SW}    ${ActiveSWstr}
	${release}=    Fetch From Left    ${OUT_ENB_ACTIVE_SW}    _
	${branch_check}=    Split string    ${OUT_ENB_ACTIVE_SW}     separator=_    max_split=3
	${sw_release}=
    	...     Run Keyword If    "${branch_check[2]}"=="9999"    Set Variable    FL00
    	...     ELSE    Set Variable    ${release}
    	Set Suite Variable    ${sw_release}
    	${QC_ID}=    Set Variable    &{${TEST_NAME}}[QC_ID_${sw_release}]
    	Set Tags    ${QC_ID}


Link SCOUT SCF to Configuration ID for Reporting
    	[Documentation]
    	...    Associate the SCF to the Configuration ID in Reporting Portal using SCOUT.
    	...
    	...    Example:
    	...     |  Link SCOUT SCF to Configuration ID for Reporting    node_id=${0}    node_type=enb
    	...
    	...     |param node_id | (default=0) Id/Number of Node (eNB or gNB) |
    	...     |param node_type | (default=gnb) Node type; possible values: gnb or enb |

    	[Arguments]    ${node_id}=${0}    ${node_type}=enb    ${tl_name_only}=1_2_CLOUD970
    	${node_type_Name}        Run Keyword If  "${node_type}"=="gnb"   Set Variable  gNB
    	...     ELSE IF     "${node_type}"=="enb"                   Set Variable  eNB
    	...     ELSE        Fail    Wrong node_type '${node_type}'! allowed: enb|gnb


    	Log To Console    ${\n}SCOUT Test Line node_id: ${node_id}
    	Log To Console    ${\n}SCOUT Test Line Name: ${tl_name_only}

    	${scout_testline_name}=    Set Variable    ${tl_name_only}
    	${external_scf_id}=   Request Scout SCF   ${scout_testline_name}
    	${TC_ID}=    Set Variable    ute:id:${external_scf_id}
    	Set Tags  ${TC_ID}

Request Scout SCF
    	[Arguments]   ${scout_testline_name}
    	[Documentation]    :Author: Michele
    	...    Request Scout SCF used inside Link SCOUT SCF to Configuration ID for Reporting KW.
    	scout.setup_scout  scout_testline_name=${scout_testline_name}
    	${external_scf_id}=   scout.request_scf   use_scout_internal_id=True
    	scout.teardown_scout_api
    	[Return]   ${external_scf_id}


Get_Pre_Active_alarms
    	[Documentation]    Active Alarms
    	admin.connect_to
    	${Pre_Active_Alarm}    admin.get_active_alarms

Get_Post_Active_alarms
    	[Documentation]    Active Alarms
    	${Post_Active_Alarm}   admin.get_active_alarms


Start DCAP Trace

     	LogToConsole   \n-- Starting dcap traces --\n

	dcap.connect_to    host=${DCAP_host}    port=${ssh_port}    username=${dcapuser_name}    password=${dcap_password}
     	...              rd_version=dcapv3    secure=${True}
     	&{bts1_info}   create dictionary  host=${bts_ip2}    port=${ssh_port}    username=Nemuadmin    password=nemuuser
     	Create testcase folder
     	${output}    dcap.start_trace    bts=${bts1_info}    tag=newtrace    duration=-1
     	...    bts_trace_profile=Full tracing profile    wait_for_activation=True
     	LogToConsole    ${output}
     	${trace_id} =   Get From Dictionary   ${output}   tracer_id
     	sleep   20s
     	LogToConsole    ${trace_id}
     	set suite variable   ${trace_id}

Start DCAP Trace1

     	LogToConsole   \n-- Starting dcap traces --\n

	dcap.connect_to    host=${DCAP_host}    port=${ssh_port}    username=${dcapuser_name}    password=${dcap_password}
     	...              rd_version=dcapv3    secure=${True}
     	&{bts1_info}   create dictionary  host=${bts_ip2}    port=${ssh_port}    username=Nemuadmin    password=nemuuser
     	Create testcase folder1
     	${output}    dcap.start_trace    bts=${bts1_info}    tag=newtrace    duration=-1
     	...    bts_trace_profile=Full tracing profile    wait_for_activation=True
     	LogToConsole    ${output}
     	${trace_id} =   Get From Dictionary   ${output}   tracer_id
     	sleep   20s
     	LogToConsole    ${trace_id}
     	set suite variable   ${trace_id}

Stop DCAP Trace
      	sleep    10s
      	LogToConsole   \n-- Stopping DCAP --\n
      	dcap.stop_trace    trace_id=${trace_id}
      	${dcap_file_name}=    dcap.get_results    result_id=${trace_id}    target_dir=${PATH}/${Folder}/${testcase_name}/DCAP_Logs    timeout=1200
      	set suite variable   ${dcap_file_name}

Stop DCAP Trace1
      	sleep    10s
      	LogToConsole   \n--stopping DCAP--\n
      	dcap.stop_trace    trace_id=${trace_id}
      	${dcap_file_name}=    dcap.get_results    result_id=${trace_id}    target_dir=${PATH1}/${Folder}/${testcase_name1}/DCAP_Logs    timeout=1200
	set suite variable   ${dcap_file_name}


unzip the pcap trace

      	unzip_and_extract_file_name    ${dcap_file_name}    ${PATH}/${Folder}/${testcase_name}/DCAP_Logs/QCI_ARP      /**/*.pcap
      	set global variable    ${output_dir2}    ${PATH}/${Folder}/${testcase_name}/DCAP_Logs/QCI_ARP

unzip the pcap trace1

      	unzip_and_extract_file_name    ${dcap_file_name}    ${PATH1}/${Folder}/${testcase_name1}/DCAP_Logs/CFRA      /**/*.pcap
      	set global variable    ${output_dir1}    ${PATH1}/${Folder}/${testcase_name1}/DCAP_Logs/CFRA

Wireshark PCAP validation
    	LogToConsole   \n-- Wireshark PCAP validation --\n
    	sleep   30s
    	Wireshark validation_QCI    ${output_dir2}

Wireshark PCAP validation1
    	LogToConsole   Wireshark File Path
    	sleep   30s
    	Wireshark validation_CFRA    ${output_dir1}


Wireshark validation_QCI
    	[Arguments]    ${outputPath}
	LogToConsole   \n--${outputPath} -\n
	LogToConsole   \n--${output_dir} -\n
	${a}=    Validate_Tshark     ${output_dir2}    filter=s1ap.qCI == 6
	log      ${a}
	${a}=    Validate_Tshark     ${output_dir2}    filter=s1ap.priorityLevel == 2
	log      ${a}
	${a}=    Validate_Tshark      ${output_dir2}    filter=s1ap.qCI == 7
	log   	 ${a}
	${a}=    Validate_Tshark     ${output_dir2}    filter=s1ap.priorityLevel == 7
	log      ${a}
	${a}=    Validate_Tshark     ${output_dir2}      filter=s1ap.qCI == 8
	log      ${a}
	${a}=    Validate_Tshark     ${output_dir2}    filter=s1ap.priorityLevel == 11
	log      ${a}
	${a}=    Validate_Tshark      ${output_dir2}      filter=s1ap.e_RAB_ID == 6
	log      ${a}
	${a}=    Validate_Tshark      ${output_dir2}      filter=s1ap.e_RAB_ID == 7
	log      ${a}
	${a}=    Validate_Tshark      ${output_dir2}      filter=s1ap.e_RAB_ID == 8
	log      ${a}
	${a}=    Validate_Tshark      ${output_dir2}      filter=nas_eps.bearer_id == 6
	log      ${a}
	${a}=    Validate_Tshark      ${output_dir2}      filter=nas_eps.bearer_id == 7
	log      ${a}
	${a}=    Validate_Tshark      ${output_dir2}      filter=nas_eps.bearer_id == 8
	log      ${a}
	${a}=    Validate_Tshark     ${output_dir2}    filter=x2ap.procedureCode == 27
	log      ${a}
	${a}=    Validate_Tshark     ${output_dir2}    filter=x2ap.qCI == 6
	log      ${a}
	${a}=    Validate_Tshark     ${output_dir2}    filter=x2ap.qCI == 7
	log      ${a}
	${a}=    Validate_Tshark     ${output_dir2}    filter=x2ap.qCI == 8
	log      ${a}
	${a}=    Validate_Tshark     ${output_dir2}    filter=x2ap.e_RAB_ID == 6
	log      ${a}
	${a}=    Validate_Tshark     ${output_dir2}    filter=x2ap.e_RAB_ID == 7
	log      ${a}
	${a}=    Validate_Tshark     ${output_dir2}    filter=x2ap.e_RAB_ID == 8
	log      ${a}
	${a}=    Validate_Tshark     ${output_dir2}    filter=s1ap.E_RABToBeModifiedListBearerModInd == 4
	log      ${a}
	${a}=    Validate_Tshark     ${output_dir2}    filter=s1ap.E_RABModifyListBearerModConf == 4
	log      ${a}


Get Date
    	[Documentation]     Get date to create testcase folder
    	${date}    Get Current Date    result_format=%d_%m_%Y_%H%M%S_%f
    	${date}    Convert to String    ${date}
    	Set global variable    ${Folder}    ${date}

Get Date1
    	[Documentation]     Get date to create testcase folder1
    	${date}    Get Current Date    result_format=%d_%m_%Y_%H%M%S_%f
    	${date}    Convert to String    ${date}
    	Set global variable    ${Folder}    ${date}


Collect_Alarms
	Wait Until Keyword Succeeds    2min    30s    admin.collect_raw_alarm_history_file        target_file_name=${out}/AllAlarms.json


Collect_ImSnapshot
	Wait Until Keyword Succeeds    2min    30s    admin.collect_im_snapshot        target_file_name=${out}/ImSnapshot.ims2


Collect_SCF
	Wait Until Keyword Succeeds    2min    30s    admin.collect_scf        target_file_name=${out}/SCF.xml

Download Snapshot
	[Arguments]    ${step}
	Wait Until Keyword Succeeds    10min    120s    admin.collect_snapshot    target_file_name=${out}/${step}/Snapshot_${step}.zip


#Test Teardown
    	#Run Keyword And Ignore Error    BuiltIn.Run Keyword If Test Failed    Dcap Stop Trace
    	Run Keyword And Ignore Error    Stops Btslogs from Local machine
	Get_Post_Active_alarms
    	admin.teardown_admin   oam
	#Link SCOUT SCF to Configuration ID for Reporting
	#Collect_Alarms
	#Collect_ImSnapshot
	#Collect_SCF
	#Download Snapshot    Post
	#SCF commissioning    ${SCF_Pre}
	Log to console  --End test--\n

Create testcase folder
    	[Documentation]     Create testcase folder in testpc
    	${val}    Run Keyword And Return Status    LOG    ${PATH}/${Folder}/${testcase_name}
    	Run Keyword If    ${val} == False    Get Date
    	create directory    ${PATH}/${Folder}/${testcase_name}/DCAP_Logs

Create testcase folder1
    	[Documentation]     Create testcase folder1 in testpc
    	${val}    Run Keyword And Return Status    LOG    ${PATH1}/${Folder}/${testcase_name1}
    	Run Keyword If    ${val} == False    Get Date1
    	create directory    ${PATH1}/${Folder}/${testcase_name1}/DCAP_Logs

Suite_Setup
	Log to console  --Test Started--\n
    	${CurrentDate}=    Get Current Date    result_format=%d_%m_%Y_%H%M/
   	${CurrentDate}=    Convert to String     ${CurrentDate}
	${SUITE NAME}    Set Variable    ${SUITE NAME}
  	${SUITE NAME}    Replace String    ${SUITE NAME}    ${SPACE}    _
   	os.Create Directory    ${BTS_path}/${SUITE NAME}/${CurrentDate}
    	Set global variable    ${Date}    ${CurrentDate}
	#Update_SCF_File
	#Run Keyword And Ignore Error    Check SW Version for Start Test
	#Set_export_yml		${CONFIG_FILE_1}
	#Set_export_yml		${CONFIG_FILE_2}

Suite_Teardown
    	log    "Test END"

Check SW Version for Start Test
	#Run Keyword And Ignore Error    admin.connect_to
	${v}=    admin.get_software_info    timeout=30
	${activeSoftwareSBTS}=    Set Variable    ${v['Active SW version']}
	${OUT_ENB_ACTIVE_SW}=    Set Variable    ${v['Active SW version']}
	Set Suite variable   ${OUT_ENB_ACTIVE_SW}
	${passiveSoftwareSBTS}=    Set Variable    ${v['Passive SW version']}
	LOG    ********* Active SW Version is ${v['Active SW version']}*********
    	LOG    ********* Passive SW Version is ${v['Passive SW version']}********
	LOG    ********* TEST Started On Build ${v['Active SW version']}*********


Require_UE
	${a}=     ta_ultracaller.Require UE   ue_alias=${UE_alias}   capabilities=${capabilities}
    	log	  ${a}

Detach_UE
	ta_ultracaller.Detach UE     ${UE_alias}
	Log to console    Detach successful
    	Sleep     10s
UE_attach
	Log to console    Trying Attach
    	ta_ultracaller.Attach UE     ${UE_alias}
	Log to console    Attach successful
    	Sleep     10s

Wireshark validation_CFRA
	[Arguments]    ${output_dir1}
    ${a}=    Validate_Tshark      ${output_dir1}      filter=nr-rrc.candidateCellInfoListMN == 1
	log    ${a}
	${a}=    Validate_Tshark      ${output_dir1}      nr-rrc.measResultNeighCellListNR == 1
	log    ${a}
    ${a}=    Validate_Tshark      ${output_dir1}      filter=nr-rrc.resultsSSB_Indexes == 1
    log    ${a}
	${a}=    Validate_Tshark      ${output_dir1}      filter=nr-rrc.rach_ConfigDedicated == 0
    log    ${a}
    ${a}=    Validate_Tshark      ${output_dir1}      filter=nr-rrc.ra_PreambleIndex == 48
    log    ${a}


Start data throughput
    	Log To Console    \nStarting data transfer
    	ta_ultracaller.start_data_transfer    ${UE_alias}    ${udpcalltype}    direction=${direction_dl}
	Run Keyword If    '${wait_for_transfer}'=='True'    Run Keywords    ta_ultracaller.await_data_transfer_finish    ${UE_alias}
    	...    ${direction_dl}     ${timeout}
    	...    AND    Sleep    30
    	...    AND    Log to console    \nData transfer completed for DL
    	Run Keyword And Continue On Failure    ta_ultracaller.calculate_thrughtput    ue_alias=${UE_alias}
        ...    direction=${direction_dl}     thrughtput=${throughput_dl}    deviation=${deviation_dl}

    	ta_ultracaller.start_data_transfer  ${UE_alias}   ${udpcalltype}    direction=@{direction_ul}
    	Run Keyword If    '${wait_for_transfer}'=='True'    Run Keywords    ta_ultracaller.await_data_transfer_finish    ${UE_alias}
    	...    ${direction_ul}     ${timeout}
    	...    AND    Sleep    30
    	...    AND    Log to console    \nData transfer completed for UL
    	Run Keyword And Continue On Failure    ta_ultracaller.calculate_thrughtput    ue_alias=${UE_alias}    direction=${direction_ul}
    	...     thrughtput=${throughput_ul}    deviation=${deviation_ul}
    	Log to console    \nData transfer Finished


Test setup
    	Log To Console    \n---- Logging WebEM.....---\n

    	admin.Setup Admin    bts_host=${BTS_ADDRESS}    alias=${connection}
    	admin.Setup Admin    bts_host=${bts_ip2}    alias=${connection2}
    	${BTS_details}      admin.get_bts_info       connection=${connection2}
    	Log    ${BTS_details}
    	Set global variable    ${BTS_ID}     ${BTS_details['mrbtsID']}
    	Set global variable    ${dist_name}     MRBTS-${BTS_ID}/LNBTS-${BTS_ID}
    	Log To Console    \n----Locking Cells which are unused.....---\n
	admin.block_cell      dist_name=MRBTS-970/LNBTS-970/LNCEL-0     timeout=15    connection=${connection}
	admin.block_cell      dist_name=MRBTS-970/LNBTS-970/LNCEL-5     timeout=15    connection=${connection}
	admin.block_cell      dist_name=MRBTS-970/LNBTS-970/LNCEL-6011     timeout=15    connection=${connection}
	admin.block_cell      dist_name=MRBTS-970/NRBTS-970/NRCELL-2    timeout=15    connection=${connection}
	admin.block_cell      dist_name=MRBTS-969/LNBTS-969/LNCEL-9692    timeout=15    connection=${connection2}
	admin.block_cell      dist_name=MRBTS-969/LNBTS-969/LNCEL-9693    timeout=15    connection=${connection2}
	admin.block_cell      dist_name=MRBTS-969/LNBTS-969/LNCEL-9694    timeout=15    connection=${connection2}


test teardown


    	Log To Console    \n----Unlocking Cells which are not used.....---\n
	admin.unblock_cell      dist_name=MRBTS-970/LNBTS-970/LNCEL-0     timeout=15    connection=${connection}
	admin.unblock_cell      dist_name=MRBTS-970/LNBTS-970/LNCEL-5     timeout=15    connection=${connection}
	admin.unblock_cell      dist_name=MRBTS-970/LNBTS-970/LNCEL-6011     timeout=15    connection=${connection}
	admin.unblock_cell      dist_name=MRBTS-970/NRBTS-970/NRCELL-2    timeout=15    connection=${connection}
	admin.unblock_cell      dist_name=MRBTS-969/LNBTS-969/LNCEL-9692    timeout=15    connection=${connection2}
	admin.unblock_cell      dist_name=MRBTS-969/LNBTS-969/LNCEL-9693    timeout=15    connection=${connection2}
	admin.unblock_cell      dist_name=MRBTS-969/LNBTS-969/LNCEL-9694    timeout=15    connection=${connection2}
    	admin.Teardown Admin    ${connection}
    	admin.Teardown Admin    ${connection2}
    	Log To Console     \n--End of test--\n

Parameter_recommissioning
	admin.perform_parameter_recommissioning    dist_name=MRBTS-969/LNBTS-969
    	...    parameter=actMultiSCGSplit    value=true    operation=update
    	...    skip_parameter_relation_errors=False    timeout=300    connection=${connection2}

Parameter_recommissioning_cfra

	admin.perform_parameter_recommissioning    dist_name=MRBTS-970/NRBTS-970/NRCELL-3
    	...    parameter=cbraPreamblesPerSsb    value=n48    operation=update
    	...    skip_parameter_relation_errors=False    should_activate=True    timeout=300    connection=${connection}

Start data_DL
	Log To Console    \nStarting data transfer
    	ta_ultracaller.start_data_transfer    ${UE_alias}    ${udpcalltype}    direction=${direction_dl}
	Run Keyword If    '${wait_for_transfer}'=='True'    Run Keywords    ta_ultracaller.await_data_transfer_finish    ${UE_alias}
    	...    ${direction_dl}     ${timeout}
    	...    AND    Sleep    30
    	...    AND    Log to console    \nData transfer completed for DL
    	Run Keyword And Continue On Failure    ta_ultracaller.calculate_thrughtput    ue_alias=${UE_alias}    direction=${direction_dl}
        ...     thrughtput=${throughput_dl}    deviation=${deviation_dl}

