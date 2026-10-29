[Documentation]
    ...   author: Liu Ning
    ...   contact: ning.4.liu@nokia-sbell.com
    ...   squad group: MMW_SG3
    ...   Feature FGCR-9726 in 5G21A program
*** Settings ***

Library     ../../../../resources/RAN_PZ_HAZ_34/lines/MMW_SG1/lib/PM_Counter.py
Library     PM_Counter.PMCounter    WITH NAME    counter
Library     taf.transport.ssh    WITH NAME    ssh
Library    taf.sbts.oam.coam.admin   WITH NAME   DU

*** Variables ***
${DU_OAM_IP}            ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${WEBUI_URL}        https://${tl.gnbs[0].dus[0].f1_m_ip_addr}
${WEBUI_USER}       ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}   ${tl.gnbs[0].cu.oam_http_connection_details.password}
${bts_username}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${bts_password}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${MRBTS_ID}    ${tl.gnbs[0].instance_id}
${NRBTS_ID}    ${tl.gnbs[0].global_bts_id}
${Max_loop}    2
${drxLongCycle}   320ms
${drxOnDurationTimer}    10ms




*** Keywords ***
Connect to DU with OAM IP
    [Arguments]    ${alias}=ASIK Master
    ssh.Connect to    hostname=${DU_OAM_IP}
    ...               username=${bts_username}
    ...               password=${bts_password}
    ...               alias=${alias}

Disconnect ssh to DU
    [Arguments]    ${alias}=ASIK Master
	ssh.disconnect    connection=${alias}

Modify the parameters related with PM counter
    DU.connect_to    bts_host=${DU_OAM_IP}    bts_port=${443}    username=${WEBUI_USERNAME}    password=${WEBUI_PASSWORD}
    ...   name=GNB
    DU.perform_parameter_recommissioning       dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPMRNL-1
    ...                                            parameter=miNrCellUtilization
    ...                                            operation=update
    ...                                            value=5min
    ...                                            connection=GNB
    ...                                            skip_parameter_relation_errors=True
    set suite variable    ${reporting_interval}    5


   [Teardown]    DU.teardown      connection=GNB

Modify the parameters related with DRX
   [Arguments]    ${cell_group_list}   ${Given_cell_index}
   DU.connect_to    bts_host=${DU_OAM_IP}    bts_port=${443}    username=${WEBUI_USERNAME}    password=${WEBUI_PASSWORD}
    ...   name=GNB
   ${cell_group_length}    get length    ${cell_group_list}
   # FOR    ${index}    IN RANGE    ${cell_group_length}
   #     DU.perform_parameter_recommissioning       dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-${cell_group_list}[${index}]
   #    ...                                        parameter=actProactUlScheduling
   #    ...                                        operation=update
   #    ...                                        value=false
   #    ...                                        connection=GNB
   #    ...                                        skip_parameter_relation_errors=True
   #END


    ${DRXdict1}=    Create Dictionary   drxInactivityTimer=80ms
    ...                                  drxLongCycle=${drxLongCycle}
    ...                                  drxOnDurationTimer=${drxOnDurationTimer}
    ...                                  drxRetransTimerDl=0slot
    ...                                  drxRetransTimerUl=0slot
    @{master_list}=    create list    ${DRXdict1}
    ${dict1}=    create dictionary    parameterName=actCDrx
    ...                               operation=update
    ...                               value=true

    ${dict2}=    create dictionary    parameterName=drxProfile1
    ...                               operation=update
    ...                               value=@{master_list}
    @{parameter_list}=    create list    ${dict1}    ${dict2}

     Wait until Keyword Succeeds   60s   5s     DU.perform_object_recommissioning
     ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${Given_cell_index}
     ...    parameter=${parameter_list}    operation=update     skip_parameter_relation_errors=${True}
     ...    should_activate=${True}    connection=GNB
	${drxLongCycle0}    Fetch From Left    ${drxLongCycle}    ms
	${drxOnDurationTimer0}    Fetch From Left    ${drxOnDurationTimer}    ms
	${Expected_Multiple_Slot}     Evaluate    (${drxLongCycle0}/${drxOnDurationTimer0})-1
	set suite variable    ${Expected_Multiple_Slot}
   [Teardown]    run keyword and continue on failure    DU.teardown      connection=GNB

Get PM counter from GNB
    log to console    Get the time on ASIK, wait for the start of next reporting interval

    ${list_DRX_counter}   create list    M55308C11001   M55308C11002    M55129C00003


	set suite variable    ${list_DRX_counter}
	@{list_Timestap}   create list

    &{pre_case_time_info}    counter.calculate_waiting_time_for_log_capturing_or_log_generation    reporting_interval=${reporting_interval}
	log to console    wait time is &{pre_case_time_info}
	FOR    ${index}    IN RANGE    ${Max_loop}
         ${Multiple_minutes}     Evaluate    ${index}*${reporting_interval}
         log to console    ${Multiple_minutes}
         ${Timestap1}    robot.libraries.DateTime.Add Time To Date
	   ...    date=${pre_case_time_info['log_generator_timestamp']}    time=${Multiple_minutes} minutes    result_format=%Y-%m-%d %H:%M
         Append to List    ${list_Timestap}   ${Timestap1}
         log to console    ${list_Timestap}
	END

    ${Max_Wait_Time}    Evaluate    ${pre_case_time_info['wait_time']}+${reporting_interval}*(${Max_loop}-1)+1
	log to console    wait ${Max_Wait_Time} minutes and get PM counter files
	Sleep    ${Max_Wait_Time} min 30 seconds


	${num_counter_file}    get length    ${list_Timestap}
	set suite variable    ${DRX_SLEEP_Slot_Sum}   0
	set suite variable    ${DRX_Activate_Slot_Sum}   0
	${remote_file_path}    Wait until PM counter file is genereated in DU    timeout=1min    log_generate_timestamp=${list_Timestap}[0]
    ${local_counter_file_path}    counter.download_pm_counter_files_to_test_pc
	...    remote_file_path=${remote_file_path}    local_file_folder=${TS_CASE_LOG_PATH}
    ${Given_cell_index_list}    Create List
	Append to list    ${Given_cell_index_list}    ${Given_cell_index}

	FOR    ${index}    IN RANGE    ${num_counter_file}
	     ${cell_counters_dict0}    get_cell_counters_from_file    file_path=${local_counter_file_path}[${index}]
       ...    list_cell=${Given_cell_index_list}    list_measurement_ids=${list_DRX_counter}
	    ${key}    Get Dictionary Keys     ${cell_counters_dict0}
        ${key1}    Get From List    ${key}    0
	    ${cell_counters_dict}    Get From Dictionary    ${cell_counters_dict0}    ${key1}
        ${DRX_SLEEP_Slot}    Get From Dictionary    ${cell_counters_dict}    M55308C11002
	    ${DRX_Activate_Slot}    Get From Dictionary    ${cell_counters_dict}    M55308C11001
        ${RLF_INIT_SGNB_DLHARQ_OR_CSI}    Get From Dictionary    ${cell_counters_dict}    M55129C00003
	    ${DRX_SLEEP_Slot_Sum}     Evaluate   ${DRX_SLEEP_Slot_Sum}+${DRX_SLEEP_Slot}
	    ${DRX_Activate_Slot_Sum}     Evaluate   ${DRX_Activate_Slot_Sum}+${DRX_Activate_Slot}
        should be equal     ${RLF_INIT_SGNB_DLHARQ_OR_CSI}    0
	END
	log to console    DRX_SLEEP_Slot/DRX_Activate_Slot is ${DRX_SLEEP_Slot_Sum} and ${DRX_Activate_Slot_Sum}
	${Multiple_Slot}    Evaluate    ${DRX_SLEEP_Slot_Sum}/${DRX_Activate_Slot_Sum}
	#should be equal     ${Multiple_Slot} >= (${Expected_Multiple_Slot}-5)    And    ${Multiple_Slot}<=(${Expected_Multiple_Slot}+5)
	should be true    ${DRX_SLEEP_Slot_Sum} > 0
	should be true    ${DRX_Activate_Slot_Sum} > 0
    [Teardown]    Disconnect ssh to DU



Wait until PM counter file is genereated in DU
    [Documentation]   Description: Wait until PM counter file is generated and Return the file path for PM counter files
    ...              :para${timeout}: should be written value with unit, eg, 1min
    [Arguments]  ${log_generate_timestamp}    ${pm_counter_file_folder}=/rom/uri/PERFMON_FILES    ${file_indicator}=PM.BTS*.xml.gz
    ...    ${asik_alias}=ASIK Master    ${timeout}=1min
    ${remote_file_path}    Wait until keyword succeeds    ${timeout}    5s    Verify PM counter file is generated in DU
    ...    log_generate_timestamp=${log_generate_timestamp}    pm_counter_file_folder=${pm_counter_file_folder}    file_indicator=${file_indicator}
    ...    asik_alias=${asik_alias}
    set suite variable    ${remote_file_path}
   [Return]  ${remote_file_path}

Verify PM counter file is generated in DU
    [Documentation]  Verify PM counter file is generated
    [Arguments]  ${log_generate_timestamp}    ${pm_counter_file_folder}=/rom/uri/PERFMON_FILES    ${file_indicator}=PM.BTS*.xml.gz
    ...    ${asik_alias}=ASIK Master
	${remote_file_path}    counter.get_pm_counter_files_by_create_time    timestamp=${log_generate_timestamp}   asik_alias=${asik_alias}
    ...    pm_counter_file_folder=${pm_counter_file_folder}    file_indicator=${file_indicator}
    Should not be empty  ${remote_file_path}    msg=No PM counter files generated after timestamp ${log_generate_timestamp}
    [Return]  ${remote_file_path}




