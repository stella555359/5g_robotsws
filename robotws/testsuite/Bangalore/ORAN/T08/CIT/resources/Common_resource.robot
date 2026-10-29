*** Settings ***
Documentation
...    Resources for CB007814
Library           String
Library           DateTime
Library           Collections
Library           OperatingSystem
Library           taf.transport.ssh    WITH NAME    SSH
Library           taf.collectors.core    WITH NAME    core1
Library           taf.ul.alarms_watchdog    WITH NAME    alarms
Library           taf.sbts.oam.coam.admin    WITH NAME    COAM
Library           taf.collectors.tshark    WITH NAME    tshark1
Library           taf.sw.scout    WITH NAME    scout
Library           taf.config.scf   WITH NAME    scf
Resource          alarm.robot
Library           Common_script.py
Library           testsuite/Bangalore/ORAN/resources/python/ta_ultracaller/
Library           testsuite/Bangalore/ORAN/resources/python/memoryusage.py
Library           testsuite/Bangalore/ORAN/resources/python/Tshark_Validation.py
Resource          testsuite/Bangalore/ORAN/resources/robot/reportingportal_Keywords.robot
Resource          testsuite/Bangalore/ORAN/resources/robot/common_setup_teardown.robot
Resource          testsuite/Bangalore/ORAN/resources/robot/common_admin.robot

*** Variables ***
${SCF_PATH}       		    ${CURDIR}/config    			# Default SCF path
${Default_SCF_file}         Configuration_CURRENT.xml       # Default SCF file name
${gNB_IP}         		    192.168.255.129    				# LMP IP
${egen_server_ip}    	    10.53.188.156    				# Egen server ip to collect egen logs
${NR_Mplane_IP}             10.53.188.227                   # To collect NR tshark logs
${LTE_Mplane_IP}            10.63.48.5                  # To collect LTE tshark logs
${wireshark_IP}             10.53.188.148                   # Ip where wireshark is collected
${UE_PC_IP}                 10.53.252.70                   # UE PC IP
@{Connected_UE}             Legacy_1    Legacy_2            # UE's available for CRT
${Legacy_1_UE}              H0B9FI1LV01C2400106             # Legacy 1 UE ID
@{throughput_ul}    	    100    							# Default UL throughput
@{throughput_dl}    	    350    						# Default DL throughput
@{throughput_ul_LTE}        70    							# Default DL throughput for LTE
@{throughput_dl_LTE}        250                              # Default DL throughput for LTE
@{UE_alias}       		    UE_1    						# Default UE id to run single UE call
@{direction_ul}    		    ul    							# Direction for Uplink
@{direction_dl}    		    dl    							# Direction for downlink
@{deviation_ul}    		    50    							# Expected throughput in ul is 48-72mbps
@{deviation_dl}    		    70    							# Expected throughput in DL is 800-1200mbps
${timeout}        		    300    							# Default timeout for data transfer
@{data_transfer_protocol}   TCP                             # Default data transfer type
${connection}     		    Active_connection    			# Alias for COAM connection
${LTE_cell_id}    		    313088    						# UE attached cell id
${NR_cell_id}               20037633                        # NR Cell id
${bip_log}        		    5GBipL2L1_filtering_off.pcap	# BIP file name
${Retry_count}    		    2    							# Retry couny for testcases
${Windows_user}             inbabtslabuser                  # Windows PC default user name
${Windows_pass}             BT5l@bus3rl0g1n                 # Windows PC default password
${Proxy_path}               C:\\Nokia\\TOOLS\\ultracaller3_proxy29_win
${Scout_tl_name}            10_2_LTEBTS1223
${Counter_path}             ['BTS']['MRBTS-1223']['RMOD-1']
${i}                        ${0}
${BTS_M_plane_ip}           10.63.48.5
${PATH}                     /home/ute/Documents/Automation_run

*** Keywords ***
Admin Setup
    [Documentation]    Create Coam connection to BTS, check BTS status, start watching alarms, create testcase folder and start BTS log
    current_memoryusage
    Run keyword and ignore error    COAM.setup_admin    bts_host=${gNB_IP}    alias=${connection}    admin_api_log_dir=/tmp
    ${BTS_details}    COAM.get_bts_info    connection=${connection}
    Log    ${BTS_details}
    ${sw_version}    COAM.get_sw_version    connection=${connection}
    Set global variable    ${BTS_ID}    ${BTS_details['mrbtsID']}
    Set global variable    ${dist_name}    MRBTS-${BTS_ID}/NRBTS-${BTS_ID}
    Get Branch
    Sleep   3m      reason=Wait to clear old alarms
    ${Active_alarm}    COAM.get_active_alarms    connection=${connection}
    LOG    ${Active_alarm}
    ${allowed_alarms}    alarm.Expected alarm
    alarms.Watch alarms    allowed_alarms=${allowed_alarms}    connection_kwargs=${connection}    log_dir=/tmp
    Set Suite variable      ${Default_SCF}      ${SCF_PATH}/${Branch}/${Default_SCF_file}
    Collect BTS Syslog

Create Testcase Directory
    [Documentation]    This keyword is to create a directory for storing case level logs.
    ...
    ...    ${TEST_LOG_DIRECTORY} is a test variable.
    Log To Console    Create Case Directory...
    ${test_name2}    string.Replace String    ${TEST_NAME}    ${space}    _
    Create Directory    ${SUITE_LOG_DIRECTORY}/${test_name2}
    Set Test Variable    ${TEST_LOG_DIRECTORY}    ${SUITE_LOG_DIRECTORY}/${test_name2}

Check BTS is OnAir
    [Documentation]    Check the BTS current status
    ${bts_status}    COAM.get_bts_statuses    connection=${connection}
    Should Be Equal As Strings    ${bts_status["proceduralState"]}    OnAir
    Run Keyword If    '${bts_status["proceduralState"]}'=='OnAir'    LOG    BTS procedural state is now: ${bts_status["proceduralState"]}
    ...    ELSE    fail
    Log to console    \nBTS procedural state : ${bts_status["proceduralState"]}
    Check cell status

Wait for BTS OnAir
    Log to console      \nWaiting for BTS to be OnAir
    FOR    ${a}    IN RANGE    1    10
        ${bts_status}=    COAM.get_bts_statuses    connection=${connection}
        Exit For Loop IF    '${bts_status["proceduralState"]}'=='OnAir'
        Sleep    1m    reason=Wait for BTS status OnAir
    END
    ${bts_status}    COAM.get_bts_statuses    connection=${connection}
    Run Keyword If    '${bts_status["proceduralState"]}'=='OnAir'    LOG    BTS procedural state is now: ${bts_status["proceduralState"]}
    ...    ELSE    fail
    Log to console    \nBTS procedural state : ${bts_status["proceduralState"]}
    Check cell status

Check cell status
    [Documentation]    Check all cell status
    ${cells}    COAM.get_ids_for_all    NRCEL    timeout=30s    connection=${connection}
    FOR    ${cell}    IN    @{cells}
        ${cell_status}    COAM.get_cell_specific_info    cell_id=${cell}    connection=${connection}
        ${administrativeState}    Set Variable    ${cell_status['status']['administrativeState']}
        Run keyword And Continue On Failure    Should Be Equal    ${administrativeState}    Unlocked
        ${operationalState}    Set Variable    ${cell_status['status']['operationalState']}
        Run keyword And Continue On Failure    Should Be Equal    ${operationalState}    enabled
        ${usageState}    Set Variable    ${cell_status['status']['usageState']}
        Run keyword And Continue On Failure    Should Be Equal    ${usageState}    Active
        ${blockingState}    Set Variable    ${cell_status['status']['blockingState']}
        Run keyword And Continue On Failure    Should Be Equal    ${blockingState}    Unblocked
        ${proceduralStatus}    Set Variable    ${cell_status['status']['proceduralStatus']}
        Run keyword And Continue On Failure    Should Be Equal    ${proceduralStatus}    configured
        ${barringStatus}    Set Variable    ${cell_status['status']['barringStatus']}
        Run keyword And Continue On Failure    Should Be Equal    ${barringStatus}    unbarred
        ${status}    Run Keyword And Return Status    Set Variable    ${cell_status['status']['availabilityStatus']}
        Run keyword And Continue On Failure    Should Not Be True    ${status}
    END

Admin Teardown
    [Documentation]    Check for alarm and delete COAM connection
    Check BTS is OnAir
    ${Active_alarm}    COAM.get_active_alarms    connection=${connection}
    LOG    ${Active_alarm}
    alarms.check_detected_alarms
    alarms.stop_watching_alarms
    post_memoryusage
    Run Keyword And Ignore Error    core1.teardown_collectors    names=tshark1
    COAM.teardown_admin    connection=${connection}
    Wait Until Keyword Succeeds    2min    10s      Link SCOUT SCF to Configuration ID for Reporting
    Set QC_Tag

Attach ue and run throughput
    [Arguments]    ${UE_alias}    ${capabilities}    ${direction}    ${throughput}    ${deviation}    ${timeout}    ${start_bip}=False
	...		${Collect_eGEN}=False    ${check_tpt}=False    ${check_cell}=False    ${check_gnb_attach}=False    ${wait_for_transfer}=True
    ta_ultracaller.Require UE   ue_alias=${UE_alias}   capabilities=${capabilities}
	ta_ultracaller.Detach UE     ue_alias=${UE_alias}
    Log to console      \nExecuting testcase in UE : ${capabilities}
    Log to console    \nSwitching Aeroplane Mode On/OFF
    ta_ultracaller.Attach UE     ue_alias=${UE_alias}
    Sleep    60
    Log to console    \n${direction} data transfer Started
    ta_ultracaller.start_datatransfer   ${UE_alias}     ${data_transfer_protocol}    direction=${direction}
    Sleep    60
    Run Keyword If    '${start_bip}'=='True'    Collect BIP logs
    Run Keyword If    '${Collect_eGEN}'=='True'    Collect eGEN Logs
    Log to console    \nWaiting for data transfer
	Log    ${check_cell}
	Run Keyword If    '${wait_for_transfer}'=='True'    Run Keywords    ta_ultracaller.await_data_transfer_finish    ${UE_alias}    ${direction}
	...		${timeout}
    ...    AND    Sleep    150
    ...    AND    Log to console    \nData transfer completed
	ta_ultracaller.Detach UE     ue_alias=${UE_alias}
    Run Keyword If    '${check_tpt}'=='True'    Run keyword and continue on failure    ta_ultracaller.Calculate Thrughtput    ue_alias=${UE_alias}
	...		direction=${direction}    thrughtput=${throughput}    deviation=${deviation}
    Run Keyword If    '${check_gnb_attach}'=='True'    Run Keywords    Stop tshark collection
    ...    AND    Check for attach request in tshark logs

Start tshark collection
    Log to console    Starting tshark logs
    ${executor_oam_vm}=    Create Dictionary    host=${wireshark_IP}    user=ute    password=BT5l@bus3rl0g1n
    tshark1.Create Tshark Collector    name=tshark1    options=-i eth1 host ${LTE_Mplane_IP}    executor=${executor_oam_vm}
    core1.setup_collectors    names=tshark1
    core1.set_suite_alias    tshark1
    core1.start_collectors    names=tshark1

Stop tshark collection
    Log to console    Stopping and collecting tshak logs
    core1.stop_collectors    names=tshark1
    core1.collect_collectors    names=tshark1    target_dir=${TEST_LOG_DIRECTORY}
    core1.teardown_collectors    names=tshark1

Check for attach request in tshark logs
    Log to console    \n--Tshark log validation--\n
    Log to console    \n--Verify X2AP sGNB Addition Request in wireshark log capture--\n
    ${Attach Request}    Validate_Tshark    ${TEST_LOG_DIRECTORY}/tshark1    filter=x2ap.procedureCode==27
    log    ${Attach Request}
    Log to console    ${Attach Request}
    Run Keyword And Continue On Failure    Should Not Be Empty    ${Attach Request}

Collect eGEN Logs
    SSH.Connect To    ${egen_server_ip}    inbabtslabuser    BT5l@bus3rl0g1n    alias=egen
    Log to console    --\n ssh DONE\n--
    ssh.Send Command    sudo su    connection=egen
    Log to console    --\n ssh DONE-2\n--
    ssh.Execute    cd /root/eGen/release    connection=egen
    Log to console    --\n ssh DONE-3\n--
    ${contents}=    ssh.Execute    /root/eGen/release/ethtool ens1f1    connection=egen
    log    ${contents}
    Log to console    --\n ru START EGEN LOGS\n--
    ${cmd}    Set variable    --cores 1-8 --port 0000:03:00.1 --port 0000:03:00.0 --capture FJTTest_2.pcap --save-n-and-quit 100000
    ssh.Execute    sudo /root/eGen/release/egen ${cmd}    connection=egen
    sleep    30
    Create Directory    ${TEST_LOG_DIRECTORY}/FJT_LOGS/
    ssh.Download File    /home/inbabtslabuser/FJTTest_2.pcap    ${TEST_LOG_DIRECTORY}/FJT_LOGS/FJTTest_2.pcap    connection=egen
    ssh.Disconnect    connection=egen

Collect BIP logs
    Start Gnb BIP Log
    BuiltIn.Sleep    60s    reason=Capturing BIP logs
    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}

Verify egen logs
    [Arguments]    @{values}
    FOR    ${port}    IN    @{values}
        ${result}    Validate_Tshark    ${TEST_LOG_DIRECTORY}/FJT_LOGS/    filter=oran_fh_cus.ru_port_id == ${port}
        log    ${result}
        Should Not Be Empty    ${result}
    END
    Log File    ${TEST_LOG_DIRECTORY}/FJT_LOGS/FJTTest_2.txt

Stop suite BTSlog
    CORE.Stop Collectors    names=btslog
    CORE.Collect Collectors    names=btslog    target_dir=${OUTPUT_DIR}/log/Pre_Execution_logs
    CORE.Teardown Collectors    names=btslog

Lock LTE cell
    Log to console    Locking LTE cell of ${LTE_cell_to_lock}
    COAM.setup_admin    bts_host=${LTE_cell_to_lock}    alias=LTE_conn    admin_api_log_dir=/tmp
    ${cells}    COAM.get_ids_for_all    LNCEL    timeout=30s    connection=LTE_conn
    FOR    ${cell}    IN    @{cells}
        COAM.lock    dist_name=${cell}    timeout=200    connection=LTE_conn
    END
    COAM.teardown_admin    connection=LTE_conn

Unlock LTE cell
    Log to console    Unlocking LTE cell of ${LTE_cell_to_lock}
    COAM.setup_admin    bts_host=${LTE_cell_to_lock}    alias=LTE_conn    admin_api_log_dir=/tmp
    ${cells}    COAM.get_ids_for_all    LNCEL    timeout=30s    connection=LTE_conn
    FOR    ${cell}    IN    @{cells}
        COAM.unlock    dist_name=${cell}    timeout=120    connection=LTE_conn
    END
    COAM.teardown_admin    connection=LTE_conn

Get BIP csv file

    Set Suite Variable    ${BIP_CSV_LOG}    ${TEST_LOG_DIRECTORY}/bip_log.csv
    Convert BIP To CSV By MCShark    ${TEST_LOG_DIRECTORY}/${bip_log}    ${BIP_CSV_LOG}    ${FILTER}    ${COLUMN_NAME}
    ${csv_content}    Get File    ${BIP_CSV_LOG}

Wait for NRCELL OnAir
    Run keyword and ignore error    COAM.setup_admin    bts_host=${gNB_IP}    alias=${connection}    admin_api_log_dir=/tmp
    Log to console      \nWaiting for NRCELL to be OnAir
    Wait Until Keyword Succeeds    10 times    30    Check cell status

Block LTE Site
    Log to console    Blocking LTE site of ${LTE_cell_to_lock}
    COAM.setup_admin    bts_host=${LTE_cell_to_lock}    alias=LTE_conn    admin_api_log_dir=/tmp
    COAM.block_rat      rat=LTE     timeout=60      connection=NoneLTE_conn
    COAM.teardown_admin    connection=LTE_conn

Unblock LTE site
    Log to console    Unblocking LTE site of ${LTE_cell_to_lock}
    COAM.setup_admin    bts_host=${LTE_cell_to_lock}    alias=LTE_conn    admin_api_log_dir=/tmp
    COAM.unblock_rat      rat=LTE     timeout=60      connection=NoneLTE_conn
    COAM.teardown_admin    connection=LTE_conn

Get Branch
    COAM.setup_admin    bts_host=${gNB_IP}    alias=Branch    admin_api_log_dir=/tmp
    ${sw_version}    COAM.get_sw_version    connection=Branch
    ${out}    Split String From Right    ${sw_version}    _    -1
    ${str}    Strip String    ${out}[0]    both    SBTS
    Set Suite variable    ${Branch}    ${str}
    LOG    ${Branch}
    COAM.teardown_admin    connection=Branch
	[Return]    ${Branch}

Start NAA application
    @{Devices}   Get active devices
    ssh.Connect_to    ${UE_PC_IP}    ${Windows_user}    ${Windows_pass}    alias=UE_PC
    FOR    ${Device}    IN    @{Devices}
        ${cmd}    set variable    adb -s ${Device} shell monkey -p com.nokia.android.application 1
        ${output}    ssh.Execute    ${cmd}    connection=UE_PC
        LOG    ${output}
    END
    Sleep       30
    start_proxy     ${UE_PC_IP}     ${Windows_user}     ${Windows_pass}     ${Proxy_path}
    ssh.Execute    cd ${Proxy_path} && START proxy.exe   connection=UE_PC
    Sleep       1m
    ssh.Disconnect    connection=UE_PC

Get active devices
    ssh.Connect_to    ${UE_PC_IP}    ${Windows_user}    ${Windows_pass}    alias=UE_PC
    ${output}    ssh.Execute    adb devices    connection=UE_PC
    @{output_dev}    Split To Lines    ${output}
    @{Devices}    Create List
    FOR    ${line}    IN    @{output_dev}
        ${b}    Split String From Right    ${line}    ${space}    -1
        Append To List    ${Devices}    ${b}[0]
    END
    ssh.Disconnect    connection=UE_PC
    [return]    @{Devices}

Switch UE
    ${Check}    Evaluate    '${Required_UE}'=='${2}' or '${Active_UE}'=='${1}'
    Run keyword if    ${Check}==False    Switch test UE
    ...    ELSE    Log to console    Cannot switch device. Required UE count : ${Required_UE}, Active UE count : ${Active_UE}

Switch test UE
    Run keyword if    "${capabilities}[0]"=="Legacy_1"    Set suite Variable     @{capabilities}    Legacy_2
    ...    ELSE    Set suite Variable     @{capabilities}    Legacy_1

Check UE status
    ${Length}    Get Length    ${UE_alias}
    Set suite variable    ${Required_UE}    ${Length}
    Check active UE
    ${status}    Evaluate    ${Active_UE}>=${Length}
    Log to console    Required UE count : ${Required_UE}, Active UE count : ${Active_UE}
    Should be true    ${status}

Check active UE
    @{Devices}   Get active devices
    @{Active_UE_list}   Create List
    FOR    ${Device}    IN    @{Devices}
        ${Value}	Run Keyword And Return Status   Should Contain    ${Device}     ${Legacy_1_UE}
        Run Keyword If      ${Value} == True    Append To List    ${Active_UE_list}    Legacy_1
        ${Value}	Run Keyword And Return Status   Should Contain    ${Device}     ${Legacy_2_UE}
        Run Keyword If      ${Value} == True    Append To List    ${Active_UE_list}    Legacy_2
    END
    LOG     ${Active_UE_list}
    ${Length}    Get Length    ${Active_UE_list}
    Set suite variable    ${Active_UE}    ${Length}
    Run keyword if    '${Required_UE}'!='${2}'    Set test UE    @{Active_UE_list}

Set test UE
    [Arguments]    @{Active_UE_list}
    Set suite Variable      @{capabilities}    ${Active_UE_list}[0]

Link SCOUT SCF to Configuration ID for Reporting
    [Arguments]    ${node_id}=${0}    ${node_type}=gnb    ${tl_name_only}=${Scout_tl_name}
	RP Settings
    ${node_type_Name}        Run Keyword If  "${node_type}"=="gnb"   Set Variable  gNB
    ...     ELSE IF     "${node_type}"=="enb"                   Set Variable  eNB
    ...     ELSE        Fail    Wrong node_type '${node_type}'! allowed: enb|gnb
    Log To Console    ${\n}SCOUT Test Line Name: ${tl_name_only}
	Log    ${node_id}
    ${scout_testline_name}=    Set Variable    ${tl_name_only}
    ${external_scf_id}=   Request Scout SCF   ${scout_testline_name}
    ${TC_ID}=    Set Variable    ute:id:${external_scf_id}
    Set Tags  ${TC_ID}

Request Scout SCF
    [Arguments]    ${scout_testline_name}
    [Documentation]    :Author: Michele
    ...    Request Scout SCF used inside Link SCOUT SCF to Configuration ID for Reporting KW.
    scout.setup_scout  scout_testline_name=${scout_testline_name}
    ${external_scf_id}=   scout.request_scf   use_scout_internal_id=True
    scout.teardown_scout_api
    [Return]   ${external_scf_id}

Counter value RURWS
    [Arguments]    ${counter_name}
    [Documentation]     Check counter value of gnb
    Log to console      \nChecking gnb counter ${counter_name}
    ${result}     COAM.get_pm_counters    counter_ids=${counter_name}    timeout=120    connection=${connection}
    log    ${result}
    FSM Access Teardown
    FSM Access Open Connection
    FSM Access Get Active And Passive Enb Sw Versions
    Get BTS SW Active Release
    log    ${sw_release}
	${values}    Get Dictionary Values    ${result['BTS']['MRBTS-1223']['EQM-1']['APEQM-1']['RMOD-1'] ['RURWS']['${counter_name}']}
    ${Total_Count}    Get value of Counter    ${values}
	[Return]    ${Total_Count}

Get value of Counter
    [Arguments]    ${Counter_value}
    [Documentation]     Get total value from list
    FOR    ${a}    IN    @{Counter_value}
        ${i}    Evaluate    ${i} + ${a}
    END
    [Return]    ${i}


Counter value TRRWS
    [Arguments]    ${counter_name}
    [Documentation]     Check counter value of gnb
    Log to console      \nChecking gnb counter ${counter_name}
    ${result}     COAM.get_pm_counters    counter_ids=${counter_name}    timeout=120    connection=${connection}
    log    ${result}
    FSM Access Teardown
    FSM Access Open Connection
    FSM Access Get Active And Passive Enb Sw Versions
    Get BTS SW Active Release
    log    ${sw_release}
	${values}    Get Dictionary Values    ${result['TRS']['MRBTS-1223']['TNLSVC-1']['TNL-2']['ETHSVC-1']['ETHLK-1'] ['TRRWS']['${counter_name}']}
    ${Total_Count}    Get value of Counter    ${values}
    [Return]    ${Total_Count}

Counter value OTRXS
    [Arguments]    ${counter_name}
    [Documentation]     Check counter value of gnb
    Log to console      \nChecking gnb counter ${counter_name}
    ${result}     COAM.get_pm_counters    counter_ids=${counter_name}    timeout=300    connection=${connection}
    log    ${result}
    FSM Access Teardown
    FSM Access Open Connection
    FSM Access Get Active And Passive Enb Sw Versions
    Get BTS SW Active Release
    log    ${sw_release}
	${values}    Get Dictionary Values    ${result['BTS']['MRBTS-1223']['EQM-1']['APEQM-1']['RMOD-1']['SFP-1']['OTRXS']['${counter_name}']}
    ${Total_Count}    Get value of Counter    ${values}
    [Return]    ${Total_Count}

Counter value OTRST
    [Arguments]    ${counter_name}
    [Documentation]     Check counter value of gnb
    Log to console      \nChecking gnb counter ${counter_name}
    ${result}     COAM.get_pm_counters    counter_ids=${counter_name}    timeout=300    connection=${connection}
    log    ${result}
    FSM Access Teardown
    FSM Access Open Connection
    FSM Access Get Active And Passive Enb Sw Versions
    Get BTS SW Active Release
    log    ${sw_release}
	${values}    Get Dictionary Values    ${result['BTS']['MRBTS-1223']['EQM-1']['APEQM-1']['RMOD-1']['SFP-1']['OTRST']['${counter_name}']}
    ${Total_Count}    Get value of Counter    ${values}
    [Return]    ${Total_Count}

Full Commission With SCF FileLTE
    [Arguments]    ${scf_file}
    [Documentation]    This keyword is to update parameters with delta file
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | scf_file | Yes | SCF file name.It usual exist in ${scf_path}/${SW_BRANCH}/SCF/${scf_file}. |
    ...    |  |  | ${SW_BRANCH} is get in keyword 'Suite Setup Update GNB', like 5G20A |
    ...
    ...    Examples:
    ...    | *** Variables *** |
    ...    | ${scf_path} | Set Variable | ${CURDIR}/config |
    ...    | Full Commission With SCF File | SCF_5GC002504.xml |    |
    ...    Example2:
    ...    | ${scf_file} | Set Variable | ${CURDIR}/scf.xml |
    ...    | Full Commission With SCF File | ${scf_file} |    |
    Log To Console    Perform full commissioning,please use the scf with full configuration saved.
    ${join_scf_path}=    OperatingSystem.Join Path    ${scf_path}    ${SW_BRANCH}    SCF    ${scf_file}
    ${is_join_path_file_exist}=    Run Keyword And Return Status    File Should Exist    ${join_scf_path}
    ${scf_path}    Set Variable If    ${is_join_path_file_exist}==True    ${join_scf_path}    ${scf_file}
    Modify File Parameter    ${scf_path}    MRBTS-[0-9]+/NRBTS-[0-9]+    ${NRBTS_DISTNAME}
    ${new_scf_path}    Migration SCF To New Release    ${scf_path}
    ${bts_id}    Get BTS IdLTE
    COAM.Setup Admin
    COAM.Perform Commissioning
    ...    bts_id=${bts_id}
    ...    scf_file=${new_scf_path}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=300
    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown


Suite Setup Update GNBLTE
    [Arguments]    ${swconfig_param}=${empty}    ${scf_file}=${empty}    ${iphy_file}=${empty}    ${swconfig_param_AP}=${empty}    ${log}=no
    ...    ${force_reboot}=no
    [Documentation]    This keyword is to update the configuration of GNB and WTS both, and wait for configured.
    ...                It also capture the logs for cell setup.
    Print Current Time    Start Robot File Time
    SSH.Reset Cache
    Clean Up Env
    Create Suite Directory
    Get All Testline Information And Set Suite VariableLTE
    ${scf_file_type}    Get File Type    ${scf_file}
    Run Keyword If    '${swconfig_param}'!='${empty}'    Add RD Parameters To GNB Swconfig File    ${swconfig_param}
    Run Keyword If    '${scf_file_type}'=='xml'    Full Commission With SCF FileLTE    ${scf_file}
    Run Keyword If    '${scf_file_type}'=='json'    Delta Commission With SCF File    ${scf_file}
    ${file_state}=    Evaluate    '${scf_file}'!='${empty}' or '${swconfig_param}'!='${empty}' or '${swconfig_param_AP}'!='${empty}'
    Run Keyword If    '${force_reboot}'=='yes'    Reboot TL And Check Configured
    ${res}    Run Keyword And Return Status    Verify Coam Site Is Ready
    Run Keyword If    '${res}'!='True'    Reboot TL And Check Configured
	LOG    ${iphy_file}
	LOG    ${log}

Get All Testline Information And Set Suite VariableLTE
    Backup Scf    ${OUTPUT_DIR}    before_suite
    Get L1Bypass Type
    Run Keyword And Ignore Error    Get Testline Type
    Get Control Board Type
    Get Testline Name


Get Default NRBTS DistNameLTE
    [Documentation]    This keyword is to get the NRBTS distname for current gNB. e.g.MRBTS-1/NRBTS-1
    COAM.Setup Admin    bts_host=${GNB_ASIK.ip}
    ${cells_info}=    COAM.Get Cell List
        ${dist_name}=    Set Variable    ${cells_info['cells']['lte'][0]['id']['configuration']}
    Log    ${dist_name}
    ${mrbts}    ${nrbts}    ${nrcell}    String.Split String    ${dist_name}    /
    Set Suite Variable    ${NRBTS_DISTNAME}    ${mrbts}/${nrbts}
    Set Suite Variable    ${MRBTS_DISTNAME}    ${mrbts}
    Log To Console    NRBTS_DISTNAME: ${NRBTS_DISTNAME}
    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown


Get BTS IdLTE
    [Documentation]    This keyword is to Get BTS IdLTE in current env
    COAM.Setup Admin
    ${cells_info}=    COAM.Get Cell List
    ${dist_name}=    Set Variable    ${cells_info['cells']['lte'][0]['id']['configuration']}
    Log    ${dist_name}
    ${mrbts}    ${nrbts}    ${nrcell}    String.Split String    ${dist_name}    /
    ${bts_id}    Fetch From Right    ${mrbts}    -
    [Return]    ${bts_id}
    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown



Common Suite TeardownLTE
    [Arguments]    ${mode}=${EMPTY}    ${collect_config_file}=${FALSE}
    ...     ${scfc_file}=/home/ute/robotws5g/testsuite/RRM/Bangalore/CRT_TESTSUITE1/resources/config/Configuration_CURRENT.xml
    [Documentation]    This keyword is to collect the logs.
	LOG    ${scfc_file}
    Run keyword If    '${FLAG_CATCH_SUITE_LOG}'=='${True}'    common_log_capture.Stop Logs    ${LOG_NAME_SUITE_SETUP}    ${SUITE_LOG_DIRECTORY}
    Run Keyword And Ignore Error    Show Relation Errors If Exist
    Run Keyword If    '${collect_config_file}'=='${TRUE}' and '${SUITE STATUS}'=='PASS'
    ...    Get Config Files And Put To Local Log Server
    Run Keyword If    '${mode}'!='debug'    Run Keyword And Ignore Error    Stop Logs    ${LOG_NAME_SUITE_TEARDOWN}    ${SUITE_LOG_DIRECTORY}
    Run Keyword If    '${mode}'!='debug'    Run Keyword And Ignore Error    Run Keyword If Any Tests Failed
    ...    Collect UTE SosReport    ${SUITE_LOG_DIRECTORY}
    common_log_capture.Teardown All Connections
    ute_wtssim.Teardown All Aliases For Wts
    Run Keyword And Ignore Error    Stop BTS Syslog
    Run Keyword And Ignore Error    Verify Syslog Anomalies
	${res}    Run Keyword And Return Status    Verify Coam Site Is Ready
    Run Keyword If    '${res}'!='True'    Reboot TL And Check Configured
    SSH.Reset Cache

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

Get Current Parameter Value
    [Arguments]    ${dist_name}    ${param_name}
    [Documentation]     Get current parameter value
    ${temp_scf_file}    COAM.Get Current Scf File    local_dir_path=/tmp    file_name=temp_scf.xml
    ...   with_auto_configured_parameters=True    connection=${connection}
    scf.Load Scf    ${temp_scf_file}
    ${param_value}    scf.get_value_from_scf    dist_name=${dist_name}    p_name=${param_name}
    [Return]    ${param_value}


DCAP_Stop_Trace_For_Teardown
    [Arguments]    ${testcase_name}
    rd.stop_trace    trace_id=${START_TRACE_ID}
    LOG     DCAP logging
	LOG    ${testcase_name}

Setup Attenuator
    at.setup_attenuator  ip_addr=${attenuator_host}  port=${attenuator_port}  attenuation_port_numbers=${at_channel}
    ...  vendor=${at_vendor}  model=${at_model}

Get Date
    [Documentation]     Get date to create testcase folder
    ${date}=    Get Current Date    result_format=%d_%m_%Y_%H%M%S_%f
    ${date}=    Convert to String    ${date}
    Set global variable    ${Folder}    ${date}


create testcase folder
    [Arguments]    ${testcase_name}
    [Documentation]     Create testcase folder in testpc
    ${val} =    Run Keyword And Return Status    LOG    ${PATH}/${Folder}/${testcase_name}
    Run Keyword If    ${val} == False    Get Date
    create directory    ${PATH}/${Folder}/${testcase_name}/DCAP_Logs
