*** Settings ***
Documentation     Keywords and variables for CB007814.robot file


Library           String
Library     Process
Library           DateTime
Library    taf.file.pack
Library           Collections
Library           OperatingSystem
Library           taf.sw.dcap.rd   WITH NAME   rd
Library           taf.hw.rf_attenuator  WITH NAME  at
Library           ./testsuite/Bangalore/ORAN/resources/python/ta_ultracaller/
Resource          ./testsuite/Bangalore/ORAN/resources/robot/common_log_analyzer.robot
Library           ./testsuite/Bangalore/ORAN/resources/python/Tshark_Validation.py


*** Variables ***
${bts_ip}                   192.168.255.129
${UE_PC_IP}                 10.45.150.167                                               			# Windows UE PC IP
${BTS_M_plane_ip}           10.58.239.169                                               			# BTS M PLane IP
${DCAP_host}                10.41.209.115                                               			# DCAP server IP
${Windows_user}             inbabtslabuser                                              			# Windows UE PC username
${Windows_pass}             BT5l@bus3rl0g1n                                             			# Windows UE PC password
${emil_path}                C://Emil                                                                # Emil path in UE PC machine
@{at_channel}               1    2    3    4                                             				# Attenuation port used
${attenuator_host}          10.45.153.205                                               			# Attenuator IP
${attenuator_port}          ${3001}                                                     			# Attenuator Port
${gNB_IP}                   192.168.255.129                                             			# gnb LMP IP
${eNB_IP}=    10.58.239.89
&{BTS_INFO}                 host=${BTS_M_plane_ip}	port=${port}                        			# BTS details
${connection_enb}=    eNB_Session
@{gnb_custom_filters}       condor5gSyslog    bip_interface_mirroring    cp_5g   
@{bts_custom_filter}        immediateSnapshot    scf                       			# BTS custom filters for DCAP
${collection_timing}        Immediate,TraceEnd                                    			# Snapshot collet option for DCAP
${Default_DCAP_duration}    30                                                           			# DCAP log duration
${dcap_log_timeout}         1600                                                         			# Timeout for DCAP log collection
${connection}               Active_Session                                              			# Alias name
${emil_profile}             ${emil_path}//profiles//5G                                  			# Emil profile path in UE PC machine
${uepc_Log_path}            C://Users//inbabtslabuser//Documents//Automation_logs       			# Path for Emil logs are copied in UE PC
${dcapuser_name}    utfuser                                 #this need to be changed for dcap latest dcap version
${dcap_password}    utfadmin!                             #this need to be changed for dcap latest dcap version
${at_vendor}                TOPYOUNG                                                    			# Attenuator Vendor
${at_model}                 TAS_16T16_0_2G6_90_1S_DEJS                                  			# Attenuator Model
${UE_file}					ta_ue_config.yaml														# UE Configuration file name
${direction}			 	dl																		# Direction for data
@{UE_alias}					UE_1																	# UE ID in configuration file
@{capabilities}				Legacy_1																# UE capability
${i}                        ${0}                                                        			# Initial counter value
${port}                     443                                                         			# Port value for DCAP connection
${secure}                   True                                                        			# Secure value for DCAP connection
${rd_version}               dcapv3                                                      			# DCAP version
@{data_transfer_protocol}   UDP                                                                     # Default data transfer type 
${Path}                     /home/ute/results                                      # DCAP logs saving path
${Proxy_path}               C:\Users\inbabtslabuser\Desktop\Tools\Ultracaller\ultracaller3_proxy29_win          # Proxy path in UE PC  
${ssh_port}                 443
${bip_log}        5GBipL2L1_filtering_off.pcap
${FILTER}         dldata_pdschsendreq
@{COLUMN_NAME}     DlData_PdschGrant.mcs    DlData_PdschGrant.numOfDmrsCdmGroupWithoutData
${TEST_LOG_DIRECTORY}                     /home/ute/Dcap
@{ports_FJT_LTE}=    9    10    11    12
@{ports}=    1    2    3    4
@{values1}=    0dB     0dB    0dB    0dB
@{values2}=    10dB     10dB    10dB    10dB
@{values3}=    20dB    20dB    20dB    20dB
@{values4}=    30dB    30dB    30dB    30dB
@{values5}=    35dB    35dB    35dB    35dB
@{values6}=    45dB    45dB    45dB    45dB
@{values7}=    50dB    50dB    50dB    50dB
@{values8}=    60dB    60dB    60dB    60dB
@{NR_cell}      2
@{LTE_cell}    9693    9692    9694
@{LTE_cells}    9691 
@{enb_cells}    0    5    6011
${filter1}    DlData_PdschGrant.mcs>=15&&DlData_PdschGrant.mcs<=27&&DlData_PdschGrant.numOfDmrsCdmGroupWithoutData==1&&
...    DlData_PdschGrant.numOfLayers<=2
${filter2}  DlData_PdschGrant.mcs>=15&&DlData_PdschGrant.mcs<=27&&DlData_PdschGrant.numOfDmrsCdmGroupWithoutData==1&&
...    DlData_PdschGrant.numOfLayers>2  



*** Keywords ***
Admin Setup
    [Documentation]     Create Coam connection to BTS, check BTS status, start watching alarms, create testcase folder and start BTS log
    COAM.setup_admin    bts_host=${gNB_IP}    alias=${connection}    admin_api_log_dir=/tmp
    ${BTS_details}      COAM.get_bts_info       connection=${connection}
    Log    ${BTS_details}  
    ${current_sw}    COAM.get_sw_version    connection=${connection}
    Log to console      \nCurrent Active build in gnb : ${current_sw}
    ${SW}=    Split String    ${current_sw}    _
    Log    ${SW}[2]
    Set global variable    ${SPLIT_SW}    ${SW}[2]
    ${SW_VERSION_TOTAL}    runkeyword if    "9999" in "${SW}[2]"     replace string    ${current_sw}    ${SW}[0]    SBTS00 
    runkeyword if    "0000" in "${SW}[2]"    Set global variable    ${SW_VERSION_TOTAL}    ${current_sw}   
    Log    ${SW_VERSION_TOTAL}
    Set global variable    ${SW_VERSION_TOTAL}
	Set global variable    ${BTS_ID}     ${BTS_details['mrbtsID']}
    Set global variable    ${dist_name}     MRBTS-${BTS_ID}/NRBTS-${BTS_ID}
	Set global variable    ${Cell3_dist}     MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRCELL-3
    Set global variable    ${connection}
    ${cell_details}      COAM.get_cells_info       connection=${connection}
    ${cell_count}       Get Length      ${cell_details}	
	@{FDD_cells}		Create List
	Set suite variable		@{FDD_cells}
	Set suite variable		${cell_count}
    Create dcap session
	Create testcase folder
    
    
Admin Setup2
    COAM.setup_admin    bts_host=${eNB_IP}    alias=${connection_enb}    admin_api_log_dir=/tmp
    ${BTS_details_eNB}      COAM.get_bts_info       connection=${connection_enb}
    Set global variable    ${BTS_ID2}     ${BTS_details_eNB['mrbtsID']}
    
    Log    ${BTS_details_eNB} 

Create dcap session
    [Documentation]    Establish DCAP session 
    rd.connect_to     host=${DCAP_host}     port=${port}    rd_version=${rd_version}
    ...    username=${dcapuser_name}    password=${dcap_password}        secure=${secure}

Dcap Start Trace SA
    [Documentation]     Start DCAP logs with custom filter
    Log to console      \nStarting DCAP trace
    ${bts_profiles}    rd.get_bts_profiles
    ${lte_profiles}    rd.get_lte_profiles
    &{bts_info}=  Create Dictionary    host=${BTS_M_plane_ip}    port=${ssh_port}    username=Nemuadmin    password=nemuuser
    
    
	${output}       rd.start_trace  duration=-1     bts=${BTS_INFO}    
    ...    gnb_custom_profile=@{gnb_custom_filters}
    ...     collection_timing=${collection_timing}
    ...     bip_mirroring_time=300    wait_for_activation=True
    ${val}        Get Dictionary Values      ${output} 

    Set Suite Variable          ${START_TRACE_ID}      ${val}[0]
    Set Suite Variable  ${START_TRACE_ID}
    LOG      DCAP log collection has been started in the gNB

Dcap Stop Trace and Get results SA
    [Documentation]     Stops DCAP and collect logs
    Log to console      \nStopping DCAP trace ID ${START_TRACE_ID} and collecting logs
    rd.stop_trace    trace_id=${START_TRACE_ID}    timeout=600
    LOG     DCAP logging stopped
    ${dcap_dirname}    rd.get_results    result_id=${START_TRACE_ID}        
    ...    target_dir=${Path}/${Folder}/${testcase_name}/DCAP_Logs    timeout=${dcap_log_timeout}
    LogToConsole    ${dcap_dirname}
    ${dcap_dirname}=    Set Suite Variable    ${dcap_dirname} 
    
Dcap Stop Trace teardown

    [Documentation]     Stops DCAP and collect logs
    Log to console      \nStopping DCAP trace ID ${START_TRACE_ID} and collecting logs
    rd.stop_trace    trace_id=${START_TRACE_ID}    timeout=400
    LOG     DCAP logging stopped
    ${dcap_dirname}    rd.get_results    result_id=${START_TRACE_ID}    
    ...    target_dir=${Path}/${Folder}/${testcase_name}/DCAP_Logs    timeout=300
    LogToConsole    ${dcap_dirname}


Unpack log files

    ${path1}=     Set Variable        ${Path}/${Folder}/${testcase_name}/DCAP_Logs
    Set global variable    ${path1}
    extract
    ...  path=${dcap_dirname}
    ...  output_dir=${path1}/Extracted
    ...  .=*/*/5g/bip/*.zip
    ...  **/bip/*.zip=BTS*_*011_*.zip
    ...  **/bip/*.zip/*.zip=*.pcap.xz
    ...  **/bip/*.zip/*.zip/*.pcap.xz=*
    Set global variable    ${Extracted_path}    ${path1}/Extracted
    ${result}=    Run Process
    ...    find ${Extracted_path} -type f \\\( -name "*.pcap" \\\) -exec cp '{}' ${Extracted_path} \\\;
    ...    shell=True

   
BIP analysis
    Run Process     command=mergecap ${Extracted_path}/*mirroring* -w ${Extracted_path}/5GBipL2L1_filtering_off.pcap    
    ...    shell=True
    Copy Files    ${Extracted_path}/5GBipL2L1_filtering_off.pcap  ${TEST_LOG_DIRECTORY}
  
    Get BIP csv file
    ${result}=    Run keyword And Continue On Failure    Validate_Tshark    ${TEST_LOG_DIRECTORY}    
    ...    filter=${filter1}
    Run keyword And Continue On Failure    Should Not Be Empty    ${result}
    
    ${result1}    Validate_Tshark    ${TEST_LOG_DIRECTORY}    
    ...    filter=${filter2}

    log    ${result1}

    Run keyword And Continue On Failure    Should Be Empty    ${result1}
    ${result3}    Validate_Tshark    ${TEST_LOG_DIRECTORY}    
    ...    filter=DlData_PdschGrant.mcs<15&&DlData_PdschGrant.numOfDmrsCdmGroupWithoutData==1

    log    ${result3}

    Run keyword And Continue On Failure    Should Be Empty    ${result3}
   

Admin Teardown
    [Documentation]     Check for alarm and delete COAM connection
    Check BTS is OnAir
    COAM.teardown_admin    connection=${connection}


Get Date
    [Documentation]     Get date to create testcase folder
    ${date}    Get Current Date    result_format=%d_%m_%Y_%H%M%S_%f
    ${date}    Convert to String    ${date}
    Set global variable    ${Folder}    ${date}

Create testcase folder
    [Documentation]     Create testcase folder in testpc
    ${val}    Run Keyword And Return Status    LOG    ${PATH}/${Folder}/${TEST NAME}
    Run Keyword If    ${val} == False    Get Date
    create directory    ${Path}/${Folder}/${testcase_name}/DCAP_Logs

Parameter value change
    [Arguments]    ${dist_name}     ${parameter}    ${value}
    [Documentation]     Change parameter valur=e in SCF and commision it
    Log to console      \nChanging gnb parameter ${parameter} to ${value}
    ${current_value}    Get Current Parameter Value    ${dist_name}    ${parameter}
    LOG    ${current_value}
    Run Keyword If    '${current_value.upper()}'!='${value.upper()}'    COAM.Perform Parameter Recommissioning    dist_name=${dist_name}
    ...     parameter=${parameter}      operation=update    value=${value}    skip_parameter_relation_errors=True    connection=${connection}
    ${current_value}    Get Current Parameter Value    ${dist_name}    ${parameter}
    LOG    ${current_value}
    Run keyword And Continue On Failure    Should Be Equal As Strings    ${current_value.upper()}    ${value.upper()}

 
Parameter update
    [Arguments]    ${dist_name}     ${parameter}    ${value}
    [Documentation]     Change parameter valur=e in SCF and commision it
    Log to console      \nChanging gnb parameter ${parameter} to ${value}
    ${current_value}    Get Current Parameter Value    ${dist_name}    ${parameter}
    LOG    ${current_value}
    ${delta_update}=    Get delta    bts_name_update
    Run Keyword If    '${current_value.upper()}'!='${value.upper()}'    COAM.Perform delta recommissioning    ${delta_update}    
    ...    skip_parameter_relation_errors=True       
    connection=${connection}
    ${current_value}    Get Current Parameter Value    ${dist_name}    ${parameter}
    LOG    ${current_value}
    Run keyword And Continue On Failure    Should Be Equal As Strings    ${current_value.upper()}    ${value.upper()}

Get BIP csv file
    Set Suite Variable    ${BIP_CSV_LOG}    ${TEST_LOG_DIRECTORY}/bip_log.csv
    OperatingSystem.Run   sudo rm -rf /usr/lib/x86_64-linux-gnu/wireshark/plugins/4.0/epan/mcshark-*buster.so
    Convert BIP To CSV By MCShark    ${TEST_LOG_DIRECTORY}/${bip_log}    ${BIP_CSV_LOG}    ${FILTER}    ${COLUMN_NAME}
    ${csv_content}    Get File    ${BIP_CSV_LOG}
	
Get Current Parameter Value
    [Arguments]    ${dist_name}    ${param_name}
    [Documentation]     Get current parameter value
    ${temp_scf_file}    COAM.Get Current Scf File    local_dir_path=/tmp    file_name=temp_scf.xml    connection=${connection}
    scf.Load Scf    ${temp_scf_file}
    ${param_value}    scf.get_value_from_scf    dist_name=${dist_name}    p_name=${param_name}
    [Return]    ${param_value}

Counter value  
    [Arguments]    ${counter_name}
    [Documentation]     Check counter value of gnb
    Log to console      \nChecking gnb counter ${counter_name}
    ${result}     COAM.get_pm_counters    couter_ids=${counter_name}    timeout=60    connection=${connection}
    log    ${result}
    ${values}    Get Dictionary Values    ${result['BTS']['CELLS']['NRCELL-1']['NCELA']['${counter_name}']}
    ${Total_Count}    Get value of Counter    ${values}
    [Return]    ${Total_Count} 


Check BTS is OnAir
    [Documentation]     Check the BTS current status
    ${bts_status}      COAM.get_bts_statuses       connection=${connection}
    Should Be Equal As Strings      ${bts_status["proceduralState"]}    OnAir
    Run Keyword If      '${bts_status["proceduralState"]}'=='OnAir'     LOG     BTS procedural state is now: ${bts_status["proceduralState"]}
    ...     ELSE    fail
    Log to console      \nBTS procedural state : ${bts_status["proceduralState"]}
    Check cell status

Wait for BTS OnAir
    Log to console      \nWaiting for BTS to be OnAir
    FOR    ${a}    IN RANGE    1    20
        ${bts_status}=    COAM.get_bts_statuses       connection=${connection}    
        Exit For Loop IF    '${bts_status["proceduralState"]}'=='OnAir'
        Sleep    1m    reason=Wait for BTS status OnAir
    END
    ${bts_status}    COAM.get_bts_statuses       connection=${connection}    
    Run Keyword If    '${bts_status["proceduralState"]}'=='OnAir'    LOG    BTS procedural state is now: ${bts_status["proceduralState"]}
    ...    ELSE    fail
    Log to console    \nBTS procedural state : ${bts_status["proceduralState"]}

Get Current Parameter Value from selenium
    [Arguments]    ${dist_name}    ${param_name}
    [Documentation]     Get parameter value
    Log to console      \nChecking gnb parameter ${param_name} value
    seleLib.login    url=https://192.168.255.129    username=Nemuadmin    password=nemuuser    browser=Chrome    alias=connection
    ${view}     seleLib.start_up_view_window_exists         sbts=connection   
    Run Keyword If       '${view}'== 'True'     seleLib.close_start_up_view_window      sbts=connection  
    ${curr_value}    seleLib.get_parameter_value    dist_name=${dist_name}    filter_param=${param_name}    sbts=connection
    seleLib.close_browser       sbts=connection
    [Return]    ${curr_value}

Check BTS status on runtime and collect dcap logs
    [Arguments]    ${dist_name}
	[Documentation]     Check for parameter change and start DCAP
    Log to console      \nWaiting for state change
    FOR    ${a}    IN RANGE    1   5
         ${Value}        Get Current Parameter Value from selenium       ${dist_name} 	state
         ${bts_status}      COAM.get_bts_statuses       connection=${connection}
         Run Keyword If       '${Value}'== 'NotAdded'       Dcap Start Trace SA
         Exit For Loop IF       '${Value}'== 'NotAdded' 
    END
    Log to console      \nSleeping for 2m
    sleep       2m      reason=Wait for change in state
    FOR    ${a}    IN RANGE    1    5
         ${Value}        Get Current Parameter Value from selenium       ${dist_name} 	state
         ${bts_status}      COAM.get_bts_statuses       connection=${connection}
         Exit For Loop IF       '${Value}'== 'Added'
    END
    Dcap Stop Trace and Get results SA
    Should Be Equal As Strings      ${Value}    Added
    ${bts_status}      COAM.get_bts_statuses       connection=${connection}
    Should Be Equal As Strings      ${bts_status["proceduralState"]}    OnAir

Verify Emil logs
	[Arguments]    @{values}
	[Documentation]     Convert emil file and verify
	Convert Emil File To Csv
	FOR		${check}	IN	 @{values}
		${result}		Parse_Emil_Csv_File_For_Message 	 ${path1}/Extracted/		${check}
		Run keyword And Continue On Failure		Should Be True		${result}
	END

Convert Emil File To Csv
    [Documentation]        Convert Emil logs collected from DCAP
    Log to console      \nConverting Emil logs and verifying
    ${path1}=     Set Variable        ${PATH}/${Folder}/${TEST NAME}/DCAP_Logs
    Set Global variable     ${path1}
    ${source_paths}    Set Variable        ${path1}/Extracted/      
    create directory         ${source_paths}
    ${files}    List Files In Directory    ${path1}	
    FOR    ${zip}    IN    @{files}
        Extract_zip        ${path1}/${zip}        ${source_paths}
    END
    ${check}    List Directory    ${source_paths}
    FOR    ${value}    IN    @{check}
        ${date}		Set Variable		${value}
    	Exit For Loop
    END
    ${it}=    List Directory    ${source_paths}/${date}
    ssh.Connect_to    ${UE_PC_IP}    ${Windows_user}    ${Windows_pass}    alias=mcg_vm
    FOR    ${out_index}    IN    @{it}
        Run keyword And Ignore Error    Start Emil To Convert Emil File To Csv    source_path=${source_paths}/${date}
        ...     source_file=${out_index}/5g/controlPlane       
    END
    ${output}		ssh.Execute     command=rm -v -f ${uepc_Log_path}//*       connection=mcg_vm		timeout=30s
    LOG		${output}
	ssh.Disconnect		connection=mcg_vm

Start Emil To Convert Emil File To Csv
    [Arguments]    ${source_path}     ${source_file}
    [Documentation]         Upload Emil logs to MCG PC and convert emil to csv file
    ${source_emil_file}    List Directory    ${source_path}/${source_file}
    ssh.Execute    command=mkdir ${uepc_Log_path}     connection=mcg_vm
    sleep    10s
    ssh.upload_file    local_path=${source_path}/${source_file}/${source_emil_file}[0]    remote_path=${uepc_Log_path}//${source_emil_file}[0]
    ...     connection=mcg_vm
    sleep    30s
    Run keyword and ignore error	ssh.Execute    command=ps -W | awk '/Emil.exe/,NF=1' | xargs kill -f      connection=mcg_vm		timeout=30s
    ${src_file}     Set Variable        ${uepc_Log_path}//${source_emil_file}[0]
	${cmd}	Set Variable	cd ${emil_path} && ./Emil.exe ${src_file} -tocsv -autoclose -destination ${uepc_Log_path} -ProfilePath ${emil_profile}
    sleep    2m
	LOG	${cmd}
	${output}		ssh.Execute    command=${cmd}      connection=mcg_vm		timeout=5m
	LOG		${output}
	${csvfile}    String.Replace String    string=${source_emil_file}[0]    search_for=.5gm    replace_with=.csv
	ssh.download_file    remote_path=${uepc_Log_path}//${csvfile}		local_path=${source_path}/${source_file}/${csvfile}      connection=mcg_vm


Check cell status
	[Documentation]		Check all cell status
    ${cells}    COAM.get_ids_for_all    NRCEL    timeout=30s    connection=${connection}
    FOR    ${cell}    IN    @{cells}
		${cell_status}	COAM.get_cell_specific_info		cell_id=${cell}	connection=${connection}
		${administrativeState}		Set Variable		${cell_status['status']['administrativeState']}
		Run keyword And Continue On Failure		Should Be Equal		${administrativeState}		Unlocked
		${operationalState}	Set Variable	${cell_status['status']['operationalState']}
		Run keyword And Continue On Failure		Should Be Equal		${operationalState}		enabled
		${usageState}		Set Variable	${cell_status['status']['usageState']}
		Run keyword And Continue On Failure		Should Be Equal		${usageState}		Active
		${blockingState}		Set Variable	${cell_status['status']['blockingState']}
		Run keyword And Continue On Failure		Should Be Equal		${blockingState}		Unblocked
		${proceduralStatus}		Set Variable	${cell_status['status']['proceduralStatus']}
		Run keyword And Continue On Failure		Should Be Equal		${proceduralStatus}		configured
		${barringStatus}		Set Variable	${cell_status['status']['barringStatus']}
		Run keyword And Continue On Failure		Should Be Equal		${barringStatus}		unbarred
		${status}		Run Keyword And Return Status 		Set Variable	${cell_status['status']['availabilityStatus']}
		Run keyword And Continue On Failure		Should Not Be True		${status}
		${technology}		Set Variable	${cell_status['technology']}
		Run Keyword If		"${technology}"=="FDD"		Append To List		${FDD_cells}	${cell}
	END

Change attenuation
	[Arguments]		${port_val_list}
	[Documentation]		Set the attenuation of specified port
	FOR    ${val}    IN    @{port_val_list}
		${channel_num}		${value}	Split String	${val}	,	1
		Set Attenuator value	${channel_num}		${value}
	END

Set Attenuator value
	[Arguments]		${channel_num}		${value}
	[Documentation]		Set the attenuation of specified port
	${channel_num}		Convert To Integer		${channel_num}
	${value}		Convert To Integer		${value}
    Log to console      \nChanging attenuator port ${channel_num} to ${value}db
	at.setup_attenuator  ip_addr=${attenuator_host}  port=${attenuator_port}    attenuation_port_numbers=@{at_channel}
	...  vendor=${at_vendor}  model=${at_model}
	${set_value}  at.read_attenuation  port=${${channel_num}}
	at.set_attenuation  port=${channel_num} 	value=${value}		confirm=${True}
	sleep	2s		reason=Wait for change in state
	${set_value}  at.read_attenuation  port=${${channel_num}}
	Should Be Equal As Strings  ${set_value}  ${value}

Change attenuation by step
	[Arguments]		${port_val_list}	${Attenuator_step_val}
	[Documentation]		Set the attenuation of specified port
	${length} 		Get Length		${port_val_list}
	FOR    ${i}    IN RANGE    10
		${status}		Loop for attenuation		${port_val_list}	${Attenuator_step_val}
		Exit For Loop If 	"${status}"=="${length}"
	END

Loop for attenuation
	[Arguments]		${port_val_list}	${Attenuator_step_val}
	${loop_status}		Set Variable		${0}
	FOR    ${val}    IN    @{port_val_list} 
		${channel_num}		${value}	Split String	${val}	,	1
		${status}		Change Attenuator value		${channel_num}		${value}	${Attenuator_step_val}
		${loop_status}		Run Keyword If		"${status}"=="${value}"		Evaluate		${loop_status}+${1}
		...		ELSE		Set Variable		${loop_status}
	END
	sleep	30s		reason=Wait for change in state
	[return]	${loop_status}	

Change Attenuator value
	[Arguments]		${channel_num}		${value}	${Attenuator_step_val}
	[Documentation]		Set the attenuation of specified port
	${set_value}  at.read_attenuation  port=${${channel_num}}
	${new_val}		Run Keyword If		"${set_value}"!="${value}"		Evaluate    ${set_value} - ${Attenuator_step_val}
	...		ELSE	Set Variable		${set_value}
	Run Keyword If		"${set_value}"!="${value}"	Set Attenuator value	${channel_num}		${new_val}
	[return]		${new_val}
	
Lock cells
    [Documentation]     Lock the specified cell
    [Arguments]         ${cell_list}
    FOR    ${cell}    IN    @{cell_list}
        Log to console      \nLocking cell : ${cell}
        COAM.lock           dist_name=MRBTS-${BTS_ID2}/LNBTS-${BTS_ID2}/LNCEL-${cell}      timeout=90     connection=${connection_enb}
    END
    
Unlock cells
    [Documentation]     Lock the specified cell
    [Arguments]         ${cell_list}
    FOR    ${cell}    IN    @{cell_list}
        Log to console      \nUnlocking cell : ${cell}
        COAM.unlock           dist_name=MRBTS-${BTS_ID2}/LNBTS-${BTS_ID2}/LNCEL-${cell}      timeout=180     connection=${connection_enb}
    END

Block LTERAT
	COAM.setup_admin    bts_host=${gNB_IP}    alias=${connection}    admin_api_log_dir=/tmp
	COAM.block_rat    rat="LTE"    timeout=100    connection=${connection}
     
    
Lock NR cells
    [Documentation]     Lock the specified cell
    [Arguments]         ${nrcell_list}
    FOR    ${cell}    IN    @{nrcell_list}
        Log to console      \nLocking cell : ${cell}
        COAM.lock           dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRCELL-${cell}      timeout=180     connection=${connection}
    END
    
Unlock NR cells
    [Documentation]     Lock the specified cell
    [Arguments]         ${nrcell_list}
    FOR    ${cell}    IN    @{nrcell_list}
        Log to console      \Unlocking cell : ${cell}
        COAM.unlock           dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRCELL-${cell}      timeout=180     connection=${connection}
    END

Unblock LTERAT
    Wait until keyword succeeds   1min   2s    COAM.unblock_rat    rat=LTE    connection=${connection}
