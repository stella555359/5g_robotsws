*** Settings ***
Documentation
...   author: Anagha Chenniga
...   contact: anagha.chenniga@nokia.com
...   Description: Common resource file

Library           String
Library           DateTime
Library           Collections
Library           OperatingSystem
Library           taf.transport.ssh    WITH NAME    SSH
Library           taf.collectors.core    WITH NAME    core1
Library           taf.ul.alarms_watchdog    WITH NAME    alarm
Library           taf.sbts.oam.coam.admin    WITH NAME    COAM
Library           taf.collectors.tshark    WITH NAME    tshark1
Library           taf.sw.scout    WITH NAME    scout
Resource          alarm.robot
Library           Common_script.py
Library           ../../resources/python/ta_ultracaller/
Library           ../../resources/python/memoryusage.py
Library           ../../resources/python/Tshark_Validation.py
Resource          ../../resources/robot/reportingportal_Keywords.robot
Resource          ../../resources/robot/common_setup_teardown.robot

*** Variables ***
${SCF_PATH}       		    ${CURDIR}/config    			# Default SCF path
${Default_SCF_file}         Configuration_CURRENT.xml       # Default SCF file name
${gNB_IP}         		    192.168.255.129    				# LMP IP
${egen_server_ip}    	    10.53.188.156    				# Egen server ip to collect egen logs
${NR_Mplane_IP}    		    10.53.188.247    				# To collect NR tshark logs
${LTE_Mplane_IP}    	    10.53.188.231    				# To collect LTE tshark logs
${wireshark_IP}    		    10.53.188.148    				# Ip where wireshark is collected
${UE_PC_IP}                 10.53.188.182                   # UE PC IP
@{Connected_UE}             Legacy_1    Legacy_2            # UE's available for CRT
${Legacy_1_UE}              H0B9FI1LV01C2400106             # Legacy 1 UE ID
${Legacy_2_UE}              HZQN1876BAKA2800523             # Legacy 2 UE ID
@{throughput_ul}    	    60    							# Default UL throughput
@{throughput_dl}    	    1000    						# Default DL throughput
@{throughput_dl_LTE}        40    							# Default DL throughput for LTE
@{UE_alias}       		    UE_1    						# Default UE id to run single UE call
@{direction_ul}    		    ul    							# Direction for Uplink
@{direction_dl}    		    dl    							# Direction for downlink
@{deviation_ul}    		    20    							# Expected throughput in ul is 48-72mbps
@{deviation_dl}    		    30    							# Expected throughput in DL is 800-1200mbps
${timeout}        		    300    							# Default timeout for data transfer
@{data_transfer_protocol}   UDP                             # Default data transfer type
${connection}     		    Active_connection    			# Alias for COAM connection
${LTE_cell_id}    		    153345    						# UE attached cell id
${bip_log}        		    5GBipL2L1_filtering_off.pcap	# BIP file name
${Retry_count}    		    2    							# Retry couny for testcases
${Windows_user}             inbabtslabuser                  # Windows PC default user name
${Windows_pass}             BT5l@bus3rl0g1n                 # Windows PC default password
${Proxy_path}               C:\\Nokia\\TOOLS\\ultracaller3_proxy29_win
${Scout_tl_name}            10_2_CLOUD1236

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
    alarm.Watch alarms    allowed_alarms=${allowed_alarms}    connection_kwargs=${connection}    log_dir=/tmp
    Set Suite variable      ${Default_SCF}      ${SCF_PATH}/${Branch}/${Default_SCF_file}
    Collect BTS Syslog
    #Check UE status

Create Testcase Directory
    [Documentation]    This keyword is to create a directory for storing case level logs.
    ...
    ...    ${TEST_LOG_DIRECTORY} is a test variable.
    Log To Console    Create Case Directory...
    ${test_name2}    string.Replace String    ${TEST_NAME[:50]}    ${space}    _
    Create Directory    ${SUITE_LOG_DIRECTORY}/${test_name2}
    Set Test Variable    ${TEST_LOG_DIRECTORY}    ${SUITE_LOG_DIRECTORY}/${test_name2}

Check BTS is OnAir
    [Documentation]    Check the BTS current status
    ${bts_status}    COAM.get_bts_statuses    connection=${connection}
    Should Be Equal As Strings    ${bts_status["proceduralState"]}    OnAir
    Run Keyword If    '${bts_status["proceduralState"]}'=='OnAir'    LOG    BTS procedural state is now: ${bts_status["proceduralState"]}
    ...    ELSE    fail
    Log to console    \nBTS procedural state : ${bts_status["proceduralState"]}
    Common_resource.Check cell status

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
    Common_resource.Check BTS is OnAir
    ${Active_alarm}    COAM.get_active_alarms    connection=${connection}
    LOG    ${Active_alarm}
    alarm.check_detected_alarms
    alarm.stop_watching_alarms
    post_memoryusage
    Run Keyword And Ignore Error    core1.teardown_collectors    names=tshark1
    COAM.teardown_admin    connection=${connection}
    RP Settings
    Wait Until Keyword Succeeds    2min    10s      Link SCOUT SCF to Configuration ID for Reporting
    Set QC_Tag

Attach ue and run throughput
    [Arguments]    ${UE_alias}    ${capabilities}    ${direction}    ${throughput}    ${deviation}    ${timeout}    ${start_bip}=False
	...		${Collect_eGEN}=False    ${check_tpt}=False    ${check_cell}=True    ${check_gnb_attach}=False    ${wait_for_transfer}=True
    Start NAA application
    ta_ultracaller.Require UE    ue_alias=${UE_alias}    capabilities=${capabilities}
    ta_ultracaller.Detach UE    ue_alias=${UE_alias}
    Log to console      \nExecuting testcase in UE : ${capabilities}
    Run Keyword If    '${check_gnb_attach}'=='True'    Start tshark collection
    Log to console    \nSwitching Aeroplane Mode On/OFF
    ta_ultracaller.Attach UE    ue_alias=${UE_alias}
    Run Keyword If    '${check_cell}'=='True'    ta_ultracaller.validate_ue_info		ue_alias=${UE_alias}	info=CELL_ID
    ... 	expected_value=${LTE_cell_id}
    Run Keyword If    '${check_gnb_attach}'=='True'    Run Keywords    Stop tshark collection
    ...    AND    Check for attach request in tshark logs
    Log to console    \nStarting ${direction} data transfer
    ta_ultracaller.start_datatransfer    ${UE_alias}    ${data_transfer_protocol}   direction=${direction}
    Run Keyword If    '${start_bip}'=='True'    Collect BIP logs
    Run Keyword If    '${Collect_eGEN}'=='True'    Collect eGEN Logs
    Log to console    \nWaiting for data transfer
    Run Keyword If    '${wait_for_transfer}'=='True'    Run Keywords    ta_ultracaller.await_data_transfer_finish    ${UE_alias}    ${direction}
	...		${timeout}
    ...    AND    Sleep    150
    ...    AND    Log to console    \nData transfer completed
    Run Keyword If    '${check_tpt}'=='True'    Run keyword and continue on failure    ta_ultracaller.Calculate Thrughtput    ue_alias=${UE_alias}
	...		direction=${direction}    thrughtput=${throughput}    deviation=${deviation}
    ta_ultracaller.Detach UE    ue_alias=${UE_alias}
    [Teardown]      Switch UE

Start tshark collection
    Log to console    Starting tshark logs
    ${executor_oam_vm}=    Create Dictionary    host=${wireshark_IP}    user=ute    password=BT5l@bus3rl0g1n
    tshark1.Create Tshark Collector    name=tshark1    options=-i eth1 host ${NR_Mplane_IP} && ${LTE_Mplane_IP}    executor=${executor_oam_vm}
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
    Run Keyword And Continue On Failure    Remove File    ${TEST_LOG_DIRECTORY}/tshark1/tshark1.pcap

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
        COAM.lock    dist_name=${cell}    timeout=120    connection=LTE_conn
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
    @{output_new}    Split To Lines    ${output}
    @{Devices}    Create List
    FOR    ${line}    IN    @{output_new}
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
    [Arguments]      ${node_type}=gnb    ${tl_name_only}=${Scout_tl_name}
    ${node_type_Name}        Run Keyword If  "${node_type}"=="gnb"   Set Variable  gNB
    ...     ELSE IF     "${node_type}"=="enb"                   Set Variable  eNB
    ...     ELSE        Fail    Wrong node_type '${node_type}'! allowed: enb|gnb
    Log To Console    ${\n}SCOUT Test Line Name: ${tl_name_only}
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
