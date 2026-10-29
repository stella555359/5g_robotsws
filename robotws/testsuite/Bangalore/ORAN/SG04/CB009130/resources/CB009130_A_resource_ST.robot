*** Settings ***
Documentation
...   author: karthik.j@nokia.com
...   contact: MN RAN RD VRF BLR1 4
...   Description: CB009130-A Test cases to configure multiple bands and carriers with O-RAN compliant LTE Radio

Library           String
Library           DateTime
Library           OperatingSystem
Library           Collections
Library           taf.collectors.core    WITH NAME    core
Library           taf.sbts.oam.coam.admin    WITH NAME    COAM
Library    		    taf.sw.scout    WITH NAME    scout
Library           taf.sw.dcap.rd     WITH NAME   dcap
Library    taf.analyzer.netconf
Library    taf.collectors.simple
Library     taf.collectors.core
Library           ../../../resources/python/ta_ultracaller/
Resource		      ../../../resources/robot/common_admin.robot
Resource		      ../../../resources/robot/expected_alarm.robot
Resource          ./testsuite/Bangalore/ORAN/SG04/resources/reportingportal_Keywords.robot
Library           ./testsuite/Bangalore/ORAN/SG04/resources/Common_script.py

*** Variables ***
${bts_id}                    969								# BTS ID
${M_plane_ip}                10.58.239.89				# Mplane IP
${bts_port}                  443								# bts login port
${bts_uname}                 Nemuadmin					# bts login username
${bts_pwd}                   nemuuser						# bts login password
${bts_uname_SSH}             toor4nsn					  # bts SSH login username
${bts_pwd_SSH}               oZPS0POrRieRtu			# bts SSH login password
${connection}                None
${UE_PC_IP}                  10.45.150.167      # UE PC IP
${dcap_host}                 10.41.209.115      # DCAP IP
${dcap_port}                 443
${dcap_version}              dcapv3
${dcap_uname}                utfuser
${dcap_pwd}                  utfadmin!
${dcap_log_status}           2.0                # 2.0-Failure & collect DCAP, 1.0-Pass & Abort DCAP trace
@{UE_alias}       		       UE2    						# Default UE id to run single UE call
@{capabilities}    	    	   Legacy_2						# Default UE profile
@{throughput_ul}    	       70    							# Default UL throughput
@{throughput_dl}    	       200    							# Default DL throughput (120)
@{direction_ul}    		       ul    							# Direction for Uplink
@{direction_dl}    		       dl    							# Direction for downlink
@{deviation_ul}    		       30    							# Expected throughput in ul is 40-80mbps
@{deviation_dl}    		       70    							# Expected throughput in DL is 100-120mbps (50)
${timeout}        		       180    						# Default timeout for data transfer
@{data_transfer_protocol}    UDP                # Default data transfer type
${LTE_cell_id1}    		       248064    					# UE attached cell id1
${LTE_cell_id2}    		       248065    					# UE attached cell id2
${LTE_cell_id3}    		       248066    					# UE attached cell id3
${LTE_cell_id4}    		       248067    					# UE attached cell id4
${Windows_user}              inbabtslabuser     # Windows PC default user name
${Windows_pass}              BT5l@bus3rl0g1n    # Windows PC default password
${Proxy_path}                C:\\Nokia\\TOOLS\\ultracaller3_proxy29_win
${cell1}                     MRBTS-969/LNBTS-969/LNCEL-9691
${cell2}                     MRBTS-969/LNBTS-969/LNCEL-9692
${cell3}                     MRBTS-969/LNBTS-969/LNCEL-9693
${cell4}                     MRBTS-969/LNBTS-969/LNCEL-9694
${radio}                     MRBTS-969/EQM-1/APEQM-1/RMOD-1
${pmax_new}                  400                                # pMax value new (dBm)
${pmax_exist}                330                                # pMax value exist (dBm)
${CONFIGURATION}		         10_2_SG4MRBTS969                   # eNB 969 Scout ID
@{enb_customfilter}    condor4gSyslog    condor4gTti
${OUTPUT_DIR1}				/home/ute/results
${eNB2_IP}    10.58.239.169                # enb LMP IP
${connection1}    Active_Session          # Alias name
${Log_Folder_Name}	 TC01_CB009130_A


&{[1][1.0]TC01_CB009130_A_To_configure_multiple_Band_with_one_Sectors_per_Band_for_ORAN_4G_radio}
...    QC_ID_FL00=QC_31657

&{[1][1.0]TC05_CB009130_A_To_configure_multiple_Band_and_multi_Sectors_for_ORAN_4G_radio}
...    QC_ID_FL00=QC_31656

&{[1][1.0]TC08_CB009130_A_To_configure_multiple_Band_with_one_Sectors_2T2R_for_ORAN_4G_radio}
...    QC_ID_FL00=QC_31654

&{[1][1.0]TC09_CB009130_A_To_configure_multiple_Band_with_one_Sectors_2T4R_for_ORAN_4G_radio}
...    QC_ID_FL00=QC_31655

*** Keywords ***
CB009130_A_To_configure_multiple_Band_with_one_Sectors_per_Band_for_ORAN_4G_radio
    Log    \n Configure B1 & B3 with one cell per band 4T/4R        console=yes
    Run keyword and ignore error    COAM.setup_admin    bts_host=${M_plane_ip}   admin_api_log_dir=/tmp
    ${BTS_details}    COAM.get_bts_info
    Perform_parameter_recommissioning_new    ${cell1}
#    --Netconf logs clear
    COAM.Unlock    dist_name=${cell1}    timeout=120
    COAM.lock    dist_name=${cell2}    timeout=120
    COAM.lock    dist_name=${cell3}    timeout=120
    COAM.lock    dist_name=${cell4}    timeout=120
    Connect Ultracaller
    Start DCAP Trace
    Downlink and uplink data transfer
    Netconf File Collection
    Netconf Message validation
    Log    \n+ TC01 completed    console=yes
    [Teardown]    Run Keywords    COAM.lock    dist_name=${cell3}    timeout=120
	  ...    AND    COAM.lock    dist_name=${cell4}    timeout=120
	  ...    AND    COAM.Unlock    dist_name=${cell2}    timeout=120
   ...    AND    Perform_parameter_recommissioning_exist    ${cell1}


CB009130_A_To_configure_multiple_Band_and_multi_Sectors_for_ORAN_4G_radio
    Log    \n Configure B1, B3 & B3 with one cell per band 4T/4R        console=yes
    Run keyword and ignore error    COAM.setup_admin    bts_host=${M_plane_ip}   admin_api_log_dir=/tmp
    ${BTS_details}    COAM.get_bts_info
    Perform_parameter_recommissioning_new    ${cell2}
    COAM.Unlock    dist_name=${cell2}    timeout=120
	  COAM.lock    dist_name=${cell1}    timeout=120
	  COAM.lock    dist_name=${cell3}    timeout=120
    COAM.lock    dist_name=${cell4}    timeout=120
    Connect Ultracaller
    Start DCAP Trace
    Downlink and uplink data transfer
    Log    \n+ TC05 completed    console=yes
    [Teardown]    Run Keywords    COAM.lock    dist_name=${cell3}    timeout=120
	  ...    AND    COAM.lock    dist_name=${cell4}    timeout=120
	  ...    AND    COAM.Unlock    dist_name=${cell1}    timeout=120
    ...    AND    Perform_parameter_recommissioning_exist    ${cell2}


CB009130_A_To_configure_multiple_Band_with_one_Sectors_2T2R_for_ORAN_4G_radio
    Log    \n Configure B1, B3 with one cell per band 2T/2R        console=yes
    Run keyword and ignore error    COAM.setup_admin    bts_host=${M_plane_ip}   admin_api_log_dir=/tmp
    ${BTS_details}    COAM.get_bts_info
    Perform_parameter_recommissioning_new    ${cell3}
	  COAM.Unlock    dist_name=${cell3}    timeout=120
	  COAM.lock    dist_name=${cell1}    timeout=120
	  COAM.lock    dist_name=${cell2}    timeout=120
    COAM.lock    dist_name=${cell4}    timeout=120
    Connect Ultracaller
    Start DCAP Trace
    Downlink and uplink data transfer
    Log    \n+ TC08 completed    console=yes
    [Teardown]    Run Keywords    COAM.lock    dist_name=${cell3}    timeout=120
	  ...    AND    COAM.lock    dist_name=${cell4}    timeout=120
	  ...    AND    COAM.Unlock    dist_name=${cell1}    timeout=120
	  ...    AND    COAM.Unlock    dist_name=${cell2}    timeout=120
	  ...    AND    Perform_parameter_recommissioning_exist    ${cell3}


CB009130_A_To_configure_multiple_Band_with_one_Sectors_2T4R_for_ORAN_4G_radio
    Log    \n Configure B1, B3 with one cell per band 2T/4R        console=yes
    Run keyword and ignore error    COAM.setup_admin    bts_host=${M_plane_ip}   admin_api_log_dir=/tmp
    ${BTS_details}    COAM.get_bts_info
    Perform_parameter_recommissioning_new    ${cell4}
	  COAM.Unlock    dist_name=${cell4}    timeout=120
	  COAM.lock    dist_name=${cell1}    timeout=120
	  COAM.lock    dist_name=${cell2}    timeout=120
    COAM.lock    dist_name=${cell3}    timeout=120
    Connect Ultracaller
    Start DCAP Trace
    Downlink and uplink data transfer
    Log    \n+ TC09 completed    console=yes
    [Teardown]    Run Keywords    COAM.lock    dist_name=${cell3}    timeout=120
    ...    AND    COAM.lock    dist_name=${cell4}    timeout=120
	  ...    AND    COAM.Unlock    dist_name=${cell1}    timeout=120
	  ...    AND    COAM.Unlock    dist_name=${cell2}    timeout=120
    ...    AND    Perform_parameter_recommissioning_exist    ${cell4}



Downlink and uplink data transfer
    Log to console    \nStarting ${direction_dl} data transfer
    ta_ultracaller.start_data_transfer    ${UE_alias}    ${data_transfer_protocol}    direction=@{direction_dl}
    Log to console    \nStarting ${direction_ul} data transfer
    ta_ultracaller.start_data_transfer    ${UE_alias}    ${data_transfer_protocol}    direction=${direction_ul}
    sleep    180
    ta_ultracaller.await_data_transfer_finish    ${UE_alias}    ${direction_dl}    ${timeout}
    ta_ultracaller.await_data_transfer_finish    ${UE_alias}    ${direction_ul}    ${timeout}
    ta_ultracaller.Detach UE    ue_alias=${UE_alias}
    ta_ultracaller.calculate_thrughtput    ue_alias=${UE_alias}    direction=${direction_dl}
    ...     thrughtput=${throughput_dl}    deviation=${deviation_dl}     #Throughput check
    ta_ultracaller.calculate_thrughtput    ue_alias=${UE_alias}    direction=${direction_ul}
    ...     thrughtput=${throughput_ul}    deviation=${deviation_ul}      #Throughput check
    Log to console   --\n DL & UL data transfer completed \n--
    ${dcap_log_status}=    Set Variable    1.0
    Set suite variable    ${dcap_log_status}
    Log to console	DCAP_LOG_STATUS: ${dcap_log_status}
    [Teardown]    Run Keywords    ta_ultracaller.Detach UE    ue_alias=${UE_alias}
    ...    AND    Run Keyword If		"${dcap_log_status}" == "1.0"   Abort DCAP Trace    ELSE    DCAP Stop with log Transfer

Perform_parameter_recommissioning_new
    [Arguments]    ${cell_id}
    Log to console    \nStarting pMax recommissioning to new value
    COAM.perform_parameter_recommissioning    dist_name=${cell_id}    parameter=pMax    operation=update
    ...    value=${pmax_new}    skip_parameter_relation_errors=${False}    should_activate=${True}    timeout=120
    Wait for BTS OnAir
    Sleep    30
    #Check cell status
    COAM.get_active_alarms
    ${allowed_alarms}=    Expected_alarm

Perform_parameter_recommissioning_exist
    [Arguments]    ${cell_id}
    COAM.perform_parameter_recommissioning    dist_name=${cell_id}    parameter=pMax    operation=update
    ...    value=${pmax_exist}    skip_parameter_relation_errors=${False}    should_activate=${True}    timeout=120
    Wait for BTS OnAir
    COAM.get_active_alarms
    ${allowed_alarms}=    Expected_alarm

Wait for BTS OnAir
    Log to console      \nWaiting for BTS to be OnAir
    FOR    ${a}    IN RANGE    1    10
        ${bts_status}=    COAM.get_bts_statuses
        Exit For Loop IF    '${bts_status["proceduralState"]}'=='OnAir'
        Sleep    1m    reason=Wait for BTS status OnAir
    END
    ${bts_status}    COAM.get_bts_statuses
    Run Keyword If    '${bts_status["proceduralState"]}'=='OnAir'    LOG    BTS procedural state is now: ${bts_status["proceduralState"]}
    ...    ELSE    fail
    Log to console    \nBTS procedural state : ${bts_status["proceduralState"]}

Check cell status
    [Documentation]    Check all cell status
    ${cells}    COAM.get_ids_for_all    LNCEL    timeout=30s
    FOR    ${cell}    IN    @{cells}
        ${cell_status}    COAM.get_cell_specific_info    cell_id=${cell}
        ${administrativeState}    Set Variable    ${cell_status['status']['administrativeState']}
        Run keyword And Continue On Failure    Should Be Equal    ${administrativeState}    unlocked
        ${operationalState}    Set Variable    ${cell_status['status']['operationalState']}
        Run keyword And Continue On Failure    Should Be Equal    ${operationalState}    enabled
        #${usageState}    Set Variable    ${cell_status['status']['usageState']}
        #Run keyword And Continue On Failure    Should Be Equal    ${usageState}    Idle
        ${blockingState}    Set Variable    ${cell_status['status']['blockingState']}
        Run keyword And Continue On Failure    Should Be Equal    ${blockingState}    Unblocked
        ${status}    Run Keyword And Return Status    Set Variable    ${cell_status['status']['availabilityStatus']}
        Run keyword And Continue On Failure    Should Not Be True    ${status}
    END

Connect Ultracaller
    Log to console    \nStarting Ultracaller
    Start NAA application
    ta_ultracaller.Require UE    ue_alias=${UE_alias}    capabilities=${capabilities}
    ta_ultracaller.Detach UE    ue_alias=${UE_alias}
    Log to console      \nExecuting testcase in UE : ${capabilities}
    Log to console    \nSwitching Aeroplane Mode On/OFF
    ta_ultracaller.Attach UE    ue_alias=${UE_alias}

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
    @{output}    Split To Lines    ${output}
    @{Devices}    Create List
    FOR    ${line}    IN    @{output}
        ${b}    Split String From Right    ${line}    ${space}    -1
        Append To List    ${Devices}    ${b}[0]
    END
    ssh.Disconnect    connection=UE_PC
    [return]    @{Devices}

Start DCAP Trace
    dcap.connect_to  host=${dcap_host}   port=${dcap_port}    username=${dcap_uname}   password=${dcap_pwd}
    ...              rd_version=dcapv3  secure=True
    ${bts_info}   create dictionary  host=${M_plane_ip}    port=${bts_port}    username=${bts_uname}   password=${bts_pwd}
    @{enb_custom_profile}=    Create List    condor4gSyslog    condor4gTti
    ${output}=    dcap.start_trace    tag=start_trace      duration=-1     force=${True}    bts=${bts_info}    tag=newtrace
    ...    wait_for_activation=True    enb_custom_profile=@{enb_customfilter}    bts_trace_profile=dcap-lite-default    timeout=300
    Log to console    \n-- DCAP trace started on MRBTS-${bts_id} --\n
    ${trace_d}=    Get Dictionary Values   ${output}
	  ${trace_id}=    Set Variable    ${trace_d}[0]
    Log to console    \n DCAP Trace ID: ${trace_id} \n
    Set suite variable    ${trace_id}
    sleep    60

Abort DCAP Trace
    LogToConsole   \n--Hence Aborting DCAP trace--\n
    dcap.abort_trace    trace_id=${trace_id}
    sleep    10

DCAP Stop with log Transfer
    dcap.stop_trace      trace_id=${trace_id}
    Log to console    \n-- Stopped DCAP Traces & Moving files to Logs Repo --\n
    #${TIMESTAMP}=    Get Current Date    result_format=%Y%m%d-%H%M
    dcap.get_results    result_id=${trace_id}       target_dir=/home/ute/results/${Log_Folder_Name}    timeout=300
    Run    sudo mv '/home/ute/results/${Log_Folder_Name}' /sharedvolume/Execution_CRT_Logs/

Netconf File Collection
    Log to console   \n Netconf log collection Started
    ${executor}    Create Dictionary    host=${M_plane_ip}
	...     user=${bts_uname_SSH}    password=${bts_pwd_SSH}
    taf.collectors.simple.create_simple_collector
    ...    name=coredump
    ...    dir_path=/tmp/node_FHNET00/tmp
    ...    file_pattern=.*
    ...    executor=${executor}
    ...    target_file_name=coredump1.log
    taf.collectors.core.setup_collectors    names=coredump
    sleep    30s
    taf.collectors.core.collect_collectors    names=coredump    target_dir=${OUTPUT_DIR1}/${Log_Folder_Name}/
    taf.collectors.core.teardown_collectors    names=coredump
    Run    tar -zxvf ${OUTPUT_DIR1}/${Log_Folder_Name}/coredump/coredump1.log.tgz -C ${OUTPUT_DIR1}/${Log_Folder_Name}/coredump
# Run	command=cat ${OUTPUT_DIR1}/${Log_Folder_Name}/coredump/RMOD_L*.log >> ${OUTPUT_DIR1}/${Log_Folder_Name}/RMOD_L-1_NetconfRpcMessageTrace.log
    Move File    ${OUTPUT_DIR1}/${Log_Folder_Name}/coredump/RMOD_L-*_NetconfRpcMessageTrace_0.log
                    ...    ${OUTPUT_DIR1}/${Log_Folder_Name}/RMOD_L-1_NetconfRpcMessageTrace.log
    Log to console   \n Netconf log collection completed

Netconf logs clear


Admin Setup
    [Documentation]    Admin Setup
    Lock LTE Site

Admin Teardown
    [Documentation]    Check for alarm and delete COAM connection
    UnLock LTE Site
    ${Active_alarm}    COAM.get_active_alarms
    LOG    ${Active_alarm}
    COAM.teardown_admin
    RP Settings
    Wait Until Keyword Succeeds    2min    10s      Link SCOUT SCF to Configuration ID for Reporting
    Set QC_Tag

Lock LTE Site
    Log to console    \n-- locking LTE RAT for eNODEB --\n
    COAM.setup_admin    bts_host=${eNB2_IP}    alias=${connection1}    admin_api_log_dir=/tmp
	Wait until keyword succeeds   1min   2s    COAM.block_rat    rat=LTE    connection=${connection1}
    COAM.teardown_admin    connection=${connection1}

UnLock LTE Site
    Log to console    \n-- Unlocking LTE RAT for eNODEB --\n
    COAM.setup_admin    bts_host=${eNB2_IP}    alias=${connection1}    admin_api_log_dir=/tmp
	Wait until keyword succeeds   1min   2s    COAM.unblock_rat    rat=LTE    connection=${connection1}
    COAM.teardown_admin    connection=${connection1}

Link SCOUT SCF to Configuration ID for Reporting
    [Documentation]
    ...    Associate the SCF to the Configuration ID in Reporting Portal using SCOUT.
    ...
    ...    Example:
    ...     |  Link SCOUT SCF to Configuration ID for Reporting    node_id=${0}    node_type=enb
    ...
    ...     |param node_id | (default=0) Id/Number of Node (eNB or gNB) |
    ...     |param node_type | (default=gnb) Node type; possible values: gnb or enb |
    [Arguments]    ${node_id}=${0}    ${node_type}=enb    ${tl_name_only}=${CONFIGURATION}
    log    ${node_id}
    ${node_type_Name}        Run Keyword If  "${node_type}"=="gnb"   Set Variable  gNB
    ...     ELSE IF     "${node_type}"=="enb"                   Set Variable  eNB
    ...     ELSE        Fail    Wrong node_type '${node_type}'! allowed: enb|gnb

    Log To Console    ${\n}SCOUT Test Line Name: ${tl_name_only}
    ${scout_testline_name}=    Set Variable    ${tl_name_only}
    ${external_scf_id}=   Wait Until Keyword Succeeds    2min    10s    Request Scout SCF   ${scout_testline_name}
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

Netconf Message validation
    Log to console   --\n Netconf log verification started\n--
    @{entries}=    Get NETCONF Log Entries	file_path=${OUTPUT_DIR1}/${Log_Folder_Name}/RMOD_L-1_NetconfRpcMessageTrace.log
    Log    ${entries}
    @{min-supported-frequency-dl}=    create List
    @{min-supported-frequency-ul}=    create List
	@{max-supported-frequency-dl}=    create List
    @{max-supported-frequency-ul}=    create List
	@{max-num-component-carriers}=    create List
	@{min-carrier-bandwidth-dl}=    create List
    @{min-carrier-bandwidth-ul}=    create List
  	@{max-carrier-bandwidth-dl}=    create List
    @{max-carrier-bandwidth-ul}=    create List
	@{min-power-per-pa-antenna}=    create List
    @{max-power-per-pa-antenna}=    create List
	@{max-gain}=    create List
    FOR    ${entry}    IN    @{entries}
		#Log    ${entry.message.xml.findtext(".//min-supported-frequency-dl[last()-1]")}
        Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findall(".//min-supported-frequency-dl")}' != '[]'
		...    Append To List    ${min-supported-frequency-dl}    ${entry.message.xml.findall(".//min-supported-frequency-dl")}
        Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findall(".//min-supported-frequency-ul")}' != '[]'
		...    Append To List    ${min-supported-frequency-ul}    ${entry.message.xml.findall(".//min-supported-frequency-ul")}
		    Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findall(".//max-supported-frequency-dl")}' != '[]'
		...    Append To List    ${max-supported-frequency-dl}    ${entry.message.xml.findall(".//max-supported-frequency-dl")}
        Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findall(".//min-supported-frequency-ul")}' != '[]'
		...    Append To List    ${max-supported-frequency-ul}    ${entry.message.xml.findall(".//max-supported-frequency-ul")}
		Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findall(".//max-num-component-carriers")}' != '[]'
		...    Append To List    ${max-num-component-carriers}    ${entry.message.xml.findall(".//max-num-component-carriers")}
		Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findall(".//min-carrier-bandwidth-dl")}' != '[]'
		...    Append To List    ${min-carrier-bandwidth-dl}    ${entry.message.xml.findall(".//min-carrier-bandwidth-dl")}
        Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findall(".//min-carrier-bandwidth-ul")}' != '[]'
		...    Append To List    ${min-carrier-bandwidth-ul}    ${entry.message.xml.findall(".//min-carrier-bandwidth-ul")}
		Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findall(".//max-carrier-bandwidth-dl")}' != '[]'
		...    Append To List    ${max-carrier-bandwidth-dl}    ${entry.message.xml.findall(".//max-carrier-bandwidth-dl")}
        Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findall(".//max-carrier-bandwidth-ul")}' != '[]'
		...    Append To List    ${max-carrier-bandwidth-ul}    ${entry.message.xml.findall(".//max-carrier-bandwidth-ul")}
		        Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findall(".//min-power-per-pa-antenna")}' != '[]'
		...    Append To List    ${min-power-per-pa-antenna}    ${entry.message.xml.findall(".//min-power-per-pa-antenna")}
        Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findall(".//max-power-per-pa-antenna")}' != '[]'
		...    Append To List    ${max-power-per-pa-antenna}    ${entry.message.xml.findall(".//max-power-per-pa-antenna")}
		Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findall(".//max-gain")}' != '[]'
		...    Append To List    ${max-gain}    ${entry.message.xml.findall(".//max-gain")}

    END
	Parameter Check    ${min-supported-frequency-dl}    2110000000
 	Parameter Check    ${min-supported-frequency-ul}    1920000000
 	Parameter Check    ${min-supported-frequency-dl}    1805000000
	Parameter Check    ${min-supported-frequency-ul}    1710000000
	Parameter Check    ${max-supported-frequency-dl}    2170000000
 	Parameter Check    ${max-supported-frequency-ul}    1980000000
 	Parameter Check    ${max-supported-frequency-dl}    1880000000
	Parameter Check    ${max-supported-frequency-ul}    1785000000
	Parameter Check    ${max-num-component-carriers}    2
	Parameter Check    ${min-carrier-bandwidth-dl}    10000000
 	Parameter Check    ${min-carrier-bandwidth-ul}    10000000
 	Parameter Check    ${min-carrier-bandwidth-dl}    10000000
	Parameter Check    ${min-carrier-bandwidth-ul}    10000000
	Parameter Check    ${max-carrier-bandwidth-dl}    20000000
 	Parameter Check    ${max-carrier-bandwidth-ul}    20000000
 	Parameter Check    ${max-carrier-bandwidth-dl}    20000000
	Parameter Check    ${max-carrier-bandwidth-ul}    20000000
	Parameter Check    ${min-power-per-pa-antenna}    30.9
 	Parameter Check    ${max-power-per-pa-antenna}    49.0
	Parameter Check    ${max-gain}    43.0
 	Parameter Check    ${max-gain}    44.7
    Log to console   --\n Netconf log verification completed\n--

Nested Looping
    [Arguments]    ${I}    ${value}
	@{parameter-check}=    create list
	FOR    ${line}    IN    @{I}
        Run Keyword If     '${line.text}'=='${value}'    Append To List    ${parameter-check}    ${line.text}
	END
	[RETURN]    ${parameter-check}

Parameter Check
	[Arguments]    ${parameter-check}    ${val}
	${final_band}=    create list
    FOR    ${I}    IN    @{parameter-check}
	    Log    ${I}
        ${aa}=    Nested Looping    ${I}	${val}
		${final_band}=    combine lists    ${aa}    ${final_band}
    END
	${len}=    get length    ${final_band}
