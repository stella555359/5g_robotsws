*** Settings ***
Documentation
...               Feature ID: CB007814

Library    OperatingSystem
Library    Process
Library    String
Library    taf.sw.dcap.rd     WITH NAME   dcap
Library    taf.sw.scout    WITH NAME    scout
Library    taf.collectors.btslog    WITH NAME    BTSLOG
Library    ute_fsmaccess
Library    taf.converters.eventdecoder    WITH NAME    eventDecConv
Library    testsuite/Bangalore/ORAN/T08/CIT/resources/dcap_extract_file.py
Library    testsuite/Bangalore/ORAN/T08/CIT/resources/validation.py
Library    testsuite/Bangalore/ORAN/T08/CIT/resources/CB007814_TTI_Log_Validation.py
Library    testsuite/Bangalore/ORAN/resources/python/ta_ultracaller/
Resource    testsuite/Bangalore/ORAN/T08/CIT/resources/alarm.robot
Resource    testsuite/Bangalore/ORAN/T08/CIT/resources/CB007814_keywords.robot
Resource    testsuite/Bangalore/ORAN/T08/CIT/resources/Common_resource.robot
Resource    testsuite/Bangalore/ORAN/resources/robot/reportingportal_Keywords.robot

*** Variables ***

@{capabilities}    Legacy_1
@{throughput_dl}=   300
@{throughput_ul}=   60
@{UE_alias}=  UE1
@{direction_dl}=  dl
@{direction_ul}=  ul
@{timeout}      100
@{deviation_dl}=  50
@{deviation_ul}=  50
@{data_protocol}       UDP
${ASP_BOARD_TYPE}     ABIO0
${DCAP_host}    10.41.209.110
${M_plane_ip}    10.63.48.5
${Retry_count}    2
${path1}    /tmp/testgetter/output_file/macro__dlStat.csv
${path2}    /tmp/testgetter/output_file/macro__dlMcPercentsStat.csv
${path3}    /tmp/testgetter/output_file/macro__ulStat.csv
${path4}    /tmp/testgetter/output_file/macro__ulMcsPercentStat.csv
${attenuator_host}    10.53.252.119        # Attenuator IP
${attenuator_port}    ${3001}               # Attenuator Port
${gNB_IP}    192.168.255.129           # gnb LMP IP
&{BTS_INFO}     host=${BTS_M_plane_ip}  port=${port}      # BTS details
@{gnb_custom_filters}    condor5gSyslog     cp_5g    L2Ps_Component     # gnb custom filters for DCAP
@{bts_custom_filter}    immediateSnapshot    scf    ipCapture       # BTS custom filters for DCAP
@{collection_timing}        Immediate       TraceEnd      # Snapshot collet option for DCAP
${Default_DCAP_duration}    10                             # DCAP log duration
${dcap_log_timeout}         1200                          # Timeout for DCAP log collection
${connection}               Active_Session                 # Alias name
${at_vendor}                TOPYOUNG                        # Attenuator Vendor
${at_model}                 TAS16T16-51-120-1N-DEJS     # Attenuator Model
${Download_path}            /home/ute/Downloads          # Software download path in test pc
${Build_download_timeout}   5m                           # Timeout to download build
${TTI_File_extension}           _tti-dec.deb           # Build extension used in download and upgrade build
${wget_link}    https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build
${confirmation}             yes
${Scout_tl_name}    10_2_LTEBTS1223


*** Keywords ***

Set_Date
    BuiltIn.log     Test Started
    ${CurrentDate}=    Get Current Date    result_format=%d_%m_%Y_%H%M
    ${CurrentDate}=    Convert to String     ${CurrentDate}
    OperatingSystem.Create Directory   ${OUTPUT_DIR}/${SUITE_NAME}/${CurrentDate}
    Set global variable    ${Date}    ${CurrentDate}
    OperatingSystem.run    chmod 777 ${OUTPUT_DIR}/${SUITE_NAME}/${Date}/${TEST_NAME}

Verify_TCP_UDP_DL_UL_tput_with_Closed_loop
	COAM.Perform Commissioning    bts_id=${BTS_ID}    scf_file=${SCF_file}    skip_parameter_relation_errors=True
	...    should_activate=True    timeout=500    connection=${connection}
	Wait Until Keyword Succeeds    15 times    20    Common_resource.Check BTS is OnAir
    Wait Until Keyword Succeeds    3 times    10     Verify_TCP_UDP_DL_UL_tput
    Initialize Counters and verify

Verify_TCP_UDP_DL_UL_tput
	COAM.lock    dist_name=MRBTS-1223/LNBTS-1223/LNCEL-0    timeout=300    connection=${connection}
	${set_atten_List}    Create List    ${1}    ${2}    ${3}    ${4}
    Set_Attenuator_Value_Startup    @{set_atten_List}
	Start DCAP log collection
	ta_ultracaller.Require UE   ue_alias=${UE_alias}   capabilities=${capabilities}
	ta_ultracaller.Detach UE     ue_alias=${UE_alias}
	ta_ultracaller.Attach UE     ue_alias=${UE_alias}
	Log to console    \nData transfer started
	ta_ultracaller.start_datatransfer   ${UE_alias}     ${data_protocol}     direction=@{direction_dl}
	sleep    30s
	Start_Attenuation    @{set_atten_List}
	Log to console    \nData transfer completed
	ta_ultracaller.Detach UE     ue_alias=${UE_alias}
	Run Keyword And Ignore error    ta_ultracaller.calculate_thrughtput    ue_alias=${UE_alias}
	...    direction=${direction_dl}    thrughtput=${throughput_dl}    deviation=${deviation_dl}
	Stop DCAP log collection
	sleep    150s
	COAM.unlock    dist_name=MRBTS-1223/LNBTS-1223/LNCEL-0    timeout=300    connection=${connection}
	Set_Attenuator_Value_Default    @{set_atten_List}
	Run keyword And Continue On Failure    Unzip and extract files    ${dcap_dirname}
	Download TTI build
	Validation of TTI traces    ${source_path}

Start DCAP log collection
    dcap.connect_to  host=${DCAP_host}   port=443   username=utfuser    password=utfadmin!
    ...              rd_version=dcapv3  secure=True
    &{bts1_info}   create dictionary  host=${M_plane_ip}    port=443    username=Nemuadmin    password=nemuuser
    @{gnb_custom_profile}=    Create List    L2Ps_Component
    ${output}    dcap.start_trace     duration=30    bts=${bts1_info}
    ...    gnb_custom_profile=@{gnb_custom_profile}
    ...    wait_for_activation=True
    ${val}        Get Dictionary Values      ${output}
	Set Suite Variable          ${trace_id}      ${val}[0]
	Log to console		Dcap started, ID: ${trace_id}

Stop DCAP log collection
    Run Keyword And Continue On Failure    dcap.stop_trace    trace_id=${trace_id}
	Log to console		Dcap stopped, ID: ${trace_id}
    ${dcap_dirname}    dcap.get_results    result_id=${trace_id}    target_dir=${OUTPUT_DIR_CIT}    timeout=2000
    ${dcap_dirname}=    Set Suite Variable    ${dcap_dirname}

Prepare environment
    Set_Date
	Set global variable    ${OUTPUT_DIR_CIT}    ${OUTPUT_DIR}/${SUITE_NAME}/${Date}/${TEST_NAME}
	COAM.setup_admin    bts_host=${gNB_IP}    alias=${connection}    admin_api_log_dir=/tmp
	${Pre_execution_scf_file}	COAM.Get Current Scf File		local_dir_path=${OUTPUT_DIR_CIT}/SCF
	...    file_name=Pre_execution_scf.xml    connection=${connection}
	Set Suite variable			${Pre_execution_scf_file}
	${Branch}		Common_resource.Get Branch
	Set Suite variable		${Branch}
	Set global variable		${SCF_file}    ${CURDIR}/resources/config/${Branch}/${TEST NAME}.xml
	Testcase setup

Testcase setup
	${BTS_details}		COAM.get_bts_info	 connection=${connection}
	Log					${BTS_details}
	Set global variable	${BTS_ID}			${BTS_details['mrbtsID']}
	${sw_version}		COAM.get_sw_version	   connection=${connection}
	Set Suite Metadata	Software version	${sw_version}
	${Active_alarm}    COAM.get_active_alarms    connection=${connection}
    LOG     ${Active_alarm}
    ${allowed_alarms}    alarm.Expected_alarm
    alarms.Watch alarms    allowed_alarms=${allowed_alarms}    connection_kwargs=${connection}       log_dir=/tmp
	CB007814_keywords.Start BTS logs

Restore environment
	alarms.check_detected_alarms
    alarms.stop_watching_alarms
	Collect snapshot from BTS
	${Default_file}		Set Variable	${OUTPUT_DIR_CIT}/SCF/Pre_execution_scf.xml
	COAM.Perform Commissioning		bts_id=${BTS_ID}    scf_file=${Default_file}    skip_parameter_relation_errors=True
    ...    should_activate=True    timeout=500    connection=${connection}
	Wait Until Keyword Succeeds	   15 times	   20	 Common_resource.Check BTS is OnAir
	${Active_alarm}    COAM.get_active_alarms    connection=${connection}
    LOG     ${Active_alarm}
	Stop BTS logs and verify
	COAM.teardown_admin    connection=${connection}
	Common_resource.Link SCOUT SCF to Configuration ID for Reporting
	Remove Directory	${outputdir}/dcap_64qam		recursive=True

Stop BTS logs and verify
    [Documentation]     Stops BTS log and check for crash
    CORE.stop_collectors    names=btslog
    CORE.collect_collectors    names=btslog     target_dir=${OUTPUT_DIR_CIT}
    CORE.teardown_collectors    names=btslog
    ${check}    CB007623.Check_bts_logs       ${OUTPUT_DIR_CIT}/btslog
	Run keyword And Continue On Failure    Should Be True    ${check}

Collect snapshot from BTS
	[Documentation]		Download BTS snapshot
	${status}    Run keyword and return status		COAM.Collect Snapshot	target_file_name=${OUTPUT_DIR_CIT}/Snapshot.zip
	...    coverage=Full
    ...    force=True
    ...    timeout=1000
    ...    connection=${connection}
	Run Keyword If    '${status}'=='False'    Log    Snapshot collection failed !!!    ERROR

Initialize Counters and verify
	Log to console 		Sleeping for 5 min for counter to update
	sleep	300s
	${counter_1}	create list		M55301C15002    M55301C15005    M55301C15008
	...    M55301C15011    M55301C15014    M55301C15017    M55301C15018
	...    M55301C15019    M55301C15021    M55301C15026    M55301C15027
	Check Counter MCS 		${counter_1}
	${counter_2}	create list		M55301C16002    M55301C16005    M55301C16008
	...    M55301C16011    M55301C16014    M55301C16017    M55301C16018
	...    M55301C16019    M55301C16021    M55301C16026    M55301C16027
	Check Counter MCS 		${counter_2}
	${counter_3}	create list		M55301C17002    M55301C17005    M55301C17008
	...    M55301C17011    M55301C17014    M55301C17017    M55301C17018
	...	   M55301C17019    M55301C17021    M55301C17026    M55301C17027
	Check Counter MCS 		${counter_3}
	${counter_4}	create list		M55301C18002    M55301C18005    M55301C18008
    ...    M55301C18011    M55301C18014    M55301C18017    M55301C18018
	...    M55301C18019    M55301C18021    M55301C18026    M55301C18027
	Check Counter MCS 		${counter_4}
	${counter_5}	create list		M55303C00002    M55303C00005    M55303C00008
    ...    M55303C00011    M55303C00014    M55303C00017    M55303C00018
	...    M55303C00019    M55303C00021    M55303C00026    M55303C00027
	Check Counter MCS 		${counter_5}
	${counter_6}	create list		M55303C01002    M55303C01005    M55303C01008
	...    M55303C01011    M55303C01014    M55303C01017    M55303C01018
	...    M55303C01019    M55303C01021    M55303C01026    M55303C01027
    Check Counter MCS 		${counter_6}

Check Counter MCS
    [Arguments]    ${counters}
    [Documentation]     Check counter value of gnb
	FOR		${counter_name}	IN	 @{counters}
		Log to console      \nChecking gnb counter ${counter_name}
		${result}		COAM.get_pm_counters
		...		counter_ids=${counter_name}    timeout=300    connection=${connection}
		log    ${result}
		${Dict_val}		get_counter_list	${result}		${counter_name}
		${values}    Get Dictionary Values    ${result${Dict_val}}
		${Total_Count}    Common_resource.Get value of Counter    ${values}
		${status}		Evaluate		${Total_Count}>=0
		Run keyword and continue on failure		Should be True		${status}
	END

Download TTI build
    [Documentation]     Download build to test pc
	${Build}    Check current software
    ${Branch}    Split string    ${Build}    _
    ${File}     Setvariable     ${Build}${TTI_File_extension}
    ${cmd}    set variable    wget -o ${OUTPUT_DIR_CIT}/wget_download_log.txt ${wget_link}/${Branch}[0]/${Build}/${File}
    Log to console    \nDownloading build ${Build} to path ${OUTPUT_DIR_CIT}, it may take some while
    Log to console    \nRunning command : ${cmd}
    ${rc}    Run And Return Rc    cd ${OUTPUT_DIR_CIT} && timeout ${Build_download_timeout} ${cmd}
    ${output}   OperatingSystem.Get File    ${OUTPUT_DIR_CIT}/wget_download_log.txt
    Log     ${output}
    Run Keyword If    ${rc} == ${0}     Log to console      \nDownload successfull
	...     ELSE        Run keywords    RUN    rm ${OUTPUT_DIR_CIT}/${Build}${TTI_File_extension}
	...     AND     Log to console      \n${output}
    ...     AND     Log to console      \n\nDownload failed
    Should be equal     ${rc}   ${0}
    ${uninstall_cmd}    set variable    sudo apt-get purge tti-dec
    Run    bash -c "echo ${confirmation} | ${uninstall_cmd}"
    ${install_cmd}    set variable    sudo gdebi ${OUTPUT_DIR_CIT}/${File}
    Run    bash -c "echo ${confirmation} | ${install_cmd}"

Check current software
    [Documentation]     Check current software in BTS
    ${current_sw}    COAM.get_sw_version    timeout=10    connection=${connection}
	@{sw_list} 		String.Split String 	${current_sw}	 _
	${status} 	Run Keyword And Return Status 		Should Be True		${sw_list[2]}==9999
	${current_trunk_sw}		Run Keyword If 		'${status}'=='True'		Replace String      ${current_sw}       ${sw_list[0]}     SBTS00
	...		ELSE	Set variable    ${current_sw}
    Log to console    \nCurrent software in BTS is ${current_sw}
    [Return]    ${current_trunk_sw}

Unzip and extract files
    [Arguments]    ${dcap_dirname}
    [Documentation]        Convert TTI logs collected from DCAP
    ${source_path}    Set Variable        ${OUTPUT_DIR_CIT}/Extracted/
    Set Global Variable    ${source_path}
    create directory         ${source_path}
    Log to console    \n--Extracting the files--
    Start Process		unzip    -q    ${dcap_dirname}    -d    ${source_path}
    sleep    30s

Validation of TTI traces
    [Arguments]    ${source_path}
    ${date}    Get Current Date    result_format=%Y%m%d
    Log to Console    Directory path being checked: ${source_path}/${date}/
    ${it}    OperatingSystem.List Directory    ${source_path}/${date}/
    Set suite Variable    ${it}
    ${output}    Create List
    FOR    ${out_index}    IN    @{it}
        ${files_list}=    OperatingSystem.List Directory    ${source_path}${date}/${out_index}
        ${output}=    _validation_tti    ${files_list}    ${source_path}    ${date}    ${out_index}
    END
    Run keyword if    ${output} != []
	...    Log to console    ${output}
    ...    ELSE    fail

_validation_tti
    [Arguments]    ${files_list}    ${source_path}    ${date}    ${out_index}
	${output}    Create List
	FOR    ${file}    IN    @{files_list}
	    ${status}    Run keyword and return status    should contain    ${file}    .pcap
        IF    '''${status}'''=='''True'''
		    Convert pcap file to json and validate
	        ...    source_path=${source_path}${date}/${out_index}    source_file=${file}
            Log to console    \n--Validating the json file--
	        ${result}=    Get TTIEvents    file_name=${source_path}${date}/${out_index}/tti.json
            Log to Console    ${result}
            Run keyword if    ${result} != {}    Append to list    ${output}    ${result}
		END
	END
	Return from keyword    ${output}

Convert pcap file to json and validate
    [Arguments]    ${source_path}    ${source_file}
	Log to console    \n--Converting pcap file to json--
    eventDecConv.create_eventdecoder_converter
    ...          name=converter_1
    ...          input_file_path=${source_path}/${source_file}
    ...          output_file_path=${source_path}/tti
    ...          output_file_format=json
    ...          tti_dec_path=/opt/tti-dec
    eventDecConv.convert  converter_1
