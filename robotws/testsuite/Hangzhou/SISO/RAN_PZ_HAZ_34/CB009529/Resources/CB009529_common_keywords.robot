*** Settings ***
Documentation
...    author: zhenzhen.guo
...    contact:zhenzhen.guo@nokia-sbell.com
...    squad group: RAN_PZ_HAZ3_SG03
...    feature : CB008392
Library     taf.sbts.oam.coam.admin   WITH NAME    coam
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/coam_resource.robot

Library    taf.selenium.sbts  WITH NAME  selenium_coam




*** Variables ***
${scf_path}                 ${commissionings_path}/HGZ/${testline_name}
${8T8R_scf_name}       SCF_8T8R_SBTS00.xml
${ue_type}    ${tl.ues[-1].capabilities[-1]}
${ute_host}    ${tl.test_pc.default_ssh_connection_details.addr}
${ute_user}    ${tl.test_pc.default_ssh_connection_details.username}
${ute_password}    ${tl.test_pc.default_ssh_connection_details.password}

*** Keywords ***
Check If there is new alarm
    Log To Console    Check If there is new alarm
    #Selenium Login And Disable Screen Lock    download_dir=/tmp    version=${version}
    @{alarm_info}=    Wait Until Keyword Succeeds    5min    10s    selenium_coam.get_active_alarm_info    timeout=100
    ${alarm_numbler}=        Get Length    ${alarm_info}
    run keyword and ignore error    should be true    ${alarm_numbler} == 4
    @{history_alarms}=    coam.get_historic_alarms    timeout=60    connection=GNB_OAM

	
Suite Teardown
    [Arguments]    ${gnb_index}=0
    log to console    \n***SISO Coam Suite Teardown***
    ${connection}    set variable if    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ...    connection=${connection}    gnb_index=${gnb_index}
	#Check If there is new alarm
	Selenium Logout And Close Browser
	run keyword and ignore error    COAM Teardown gnb connections
    Run Keyword And Ignore Error    process.Terminate All Processes    kill=True
    csn.Connect to    hostname=${ute_host}    username=${ute_user}    password=${ute_password}    alias=ute
	csn.execute    command=rm -rf /tmp/*.log    connection=ute
	csn.execute    command=rm -rf /tmp/*.html    connection=ute
	csn.execute    command=rm -rf /tmp/*    connection=ute
    csn.Disconnect     connection=ute


	
Modify parameter administrativeState
    log to console    Modify parameter administrativeState
	[Arguments]    ${cell_id}=1    ${value}=Shutting Down    
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    parameter=actGrflShdn
    ...    value=true
    ...    operation=update
    ...    skip_parameter_relation_errors=skip
    ...    connection=GNB_OAM	
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...    parameter=administrativeState
    ...    value=${value}
    ...    operation=update
    ...    skip_parameter_relation_errors=skip
    ...    connection=GNB_OAM	
	
Scf xml modify
    [Arguments]      ${scf_file_path}    ${parameters_to_update_xml}
    log to console    Scf xml modify
    ${scf_file_name}    Fetch from right    ${scf_file_path}    /
    ${scf_dir_path}    String.Replace string    ${scf_file_path}    /${scf_file_name}    ${EMPTY}
    ${file_name_without_extention}    String.Replace string    ${scf_file_name}    .xml    ${EMPTY}
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    ${scf_file_name_after_modify}    catenate  SEPARATOR=${EMPTY}    ${file_name_without_extention}
    ...    _${timestamp}_updated.xml
    ${modified_scf_file_path}    set variable    ${scf_dir_path}/${scf_file_name_after_modify}
    scf.Load Scf    ${scf_file_path}
    FOR  ${modify_para}  IN  @{parameters_to_update_xml}
      run keyword if    '${modify_para['operate']}'=='update'    scf.modify_scf_element
      ...    value=${modify_para['new_value']}    dist_name=${modify_para['dist_name']}
      ...    p_name=${modify_para['p_name']}
      run keyword if    '${modify_para['operate']}'=='delete'    scf.remove_mo_with_descendant_mos
      ...    dist_name=${modify_para['dist_name']}
      run keyword if    '${modify_para['operate']}'=='add_mo'    scf.add_object_to_scf
      ...    class_name=${modify_para['class_name']}    dist_name=${modify_para['dist_name']}
      ...    version=${modify_para['version']}
    END
    scf.save_scf    ${modified_scf_file_path}
    [Return]  ${modified_scf_file_path}

Scf commition and wair for on-air
    [Arguments]    ${scf_name}    ${is_pdl_checking_needed}=${True}    ${timeout}=600
    log to console    Scf commition and wair for on-air
    Connect to gnb coam via ssl
    COAM Commission with scf file    scf_file_path=${scf_name}    timeout=${timeout}
	...    is_pdl_checking_needed=${is_pdl_checking_needed}    connection=GNB_OAM
    Wait Until Keyword Succeeds    20min    20s    COAM Check GNB cell on air
    Run Keyword And Ignore Error    ssh.force_reconnect    connection=ASIK Master

	
Expect Fault Should Present
    [Arguments]    ${faultId}    ${source}=${None}    ${connection}=COAM    ${severity}=${None}    ${alarmId}=${None}
    log to console    \nExpect Fault ${faultId} Should Present  
    ${faultId}    Convert To Integer    ${faultId}
    @{alarms}    coam.get_active_alarms    connection=${connection}
    ${alarm_num}    Get Length    ${alarms}
    ${present_status}    Set Variable    ${False}
    FOR    ${alarm}    IN    @{alarms}
        Exit For Loop If    ${alarm_num}==${0}
        ${present_status}    Run Keyword And Return Status    Run Keywords
        ...                  Dictionary Should Contain Item    ${alarm}    faultId    ${faultId}    AND
        ...                  Run Keyword If    '${source}'!='${None}'
        ...                  Should Contain    ${alarm['notifier']}    ${source}    case_insensitive=True    AND
        ...                  Run Keyword If    '${severity}'!='${None}'
        ...                  Should Contain    ${alarm['severity']}    ${severity}    case_insensitive=True    AND
        ...                  Run Keyword If    '${alarmId}'!='${None}'
        ...                  Should Be Equal As Strings    ${alarm['alarmId']}    ${alarmId}
        Exit For Loop If    ${present_status}
    END
    Run Keyword If    ${present_status}==${False}    Fail    faultId ${faultId} reported by source ${source} is not present on gnb.

Suite Setup
    Connect to gnb coam via ssl
    ${Active_SW_version}=    coam.get_sw_version    connection=GNB_OAM
	Set Suite Variable    ${Active_SW_version}
    #Selenium Login And Disable Screen Lock
    ${stream}    get stream from version    ${Active_SW_version}
    Set Suite Variable    ${stream}
    @{SBTS_release}    string.split string    ${stream}    separator=SBTS
    ${release_id}    set variable    ${SBTS_release}[1]
    Set Suite Variable    ${release_id}
    #${8T8R_scf_name}    Run keyword if   '${stream}'=='SBTS00'     set variable   SCF_8T8R_SBTS00.xml
    #...   ELSE    set variable    SCF_8T8R_SBTS${release_id}.xml
    #Set Suite Variable    ${8T8R_scf_name}
	Connect to Common Unit Master
	
	
Check active alarms
    [Tags]      WIP
    ${active_alarms}    coam.get_active_alarms    connection=GNB_OAM    timeout=60
    ${alarm_id_list}    Create List
    ${len}    get length    ${active_alarms}
    FOR    ${i}    IN RANGE    ${len}
        ${tmp_id}    Get From Dictionary    ${active_alarms[${i}]}    faultId
        Append To List    ${alarm_id_list}    ${tmp_id}
    END
    log    ${alarm_id_list}
    [Return]     ${alarm_id_list}

Check history alarms
    [Tags]      WIP
    ${history_alarms}=    coam.get_historic_alarms    timeout=60    connection=GNB_OAM
    ${alarm_id_list}    Create List
    ${len}    get length    ${history_alarms}
    FOR    ${i}    IN RANGE    ${len}
        ${tmp_id}    Get From Dictionary    ${history_alarms[${i}]}    faultId
        Append To List    ${alarm_id_list}    ${tmp_id}
    END
    log    ${alarm_id_list}
    [Return]     ${alarm_id_list}	
	
Check if alarm exist
    [Arguments]    ${alarm_list}    ${alarm_id}
    set suite variable    ${is_alarm_visible}    False
    FOR    ${element}    IN    @{alarm_list}
        run keyword if    '${element}'=='${alarm_id}'    set suite variable   ${is_alarm_visible}     True
    END
    run keyword if     '${is_alarm_visible}'=='True'    FAIL	
	
Lock RU via WebEM
    selenium_coam.lock_ru    ru_index=1    

Check if RU is locked
    ${ru_info_full}   selenium_coam.get_ru_info    ru_index=1
    ${ru_info}         Get From Dictionary    ${ru_info_full}    Status
    should match regexp    ${ru_info}[Administrative state]    Locked
	
Unlock RU via WebEM
    selenium_coam.unlock_ru   ru_index=1
    sleep    30s


Check if RU is unlocked
    ${ru_info_full}   selenium_coam.get_ru_info    ru_index=1
    ${ru_info}         Get From Dictionary    ${ru_info_full}    Status
    ${ru_info}         Get From Dictionary    ${ru_info_full}    Status
	
Perform RU lock unlock repetition via WebEM
    [Arguments]    ${repitition_num}=1
    Log To Console    Perform RU lock unlock repetition via WebEM
    FOR    ${index}    IN RANGE    ${repitition_num}
        #${date}=    Get Current Date    result_format=%Y-%m-%d_%H:%M:%S
        Log To Console    \n ru lock Iteration ${INDEX} times
        Lock RU via WebEM
        Run keyword and continue on failure    Check if RU is locked
		Log To Console    \n ru unlock Iteration ${INDEX} 
		#times in progress at: ${date}
        Unlock RU via WebEM
        Check if RU is unlocked	
    END	

Perform RU Reset repetition via WebEM
    [Arguments]    ${repitition_num}=1
    Log To Console    Perform RU Reset repetition via WebEM
    FOR    ${index}    IN RANGE    ${repitition_num}
        #${date}=    Get Current Date    result_format=%Y-%m-%d_%H:%M:%S
        Log To Console    \n ru reset Iteration ${INDEX} times
        Perform RU Reset via WebEM
        Wait Until Keyword Succeeds    20min    10sec    RU Led Status Change to Green
    END
	
Perform RU Reset via WebEM
    [Arguments]    ${ru_index}=${1}
    ${ru_index}  Convert To Integer    ${ru_index}
    selenium_coam.reset_ru  ru_index=${ru_index}

RU Led Status Change to Green
    log to console    RU Led Status Change to Green    console=yes
    ${RU_State}      Get Led status of given unit    unit_name=RMOD-1
    should be equal    ${RU_State}    Enabled

Get Led status of given unit
    [Arguments]    ${unit_name}
    Close startup view if visible
    ${led_status}    selenium_coam.Get Led Status Of An Unit    unit=${unit_name}
    [Return]    ${led_status}
	
Close startup view if visible
    ${is_startup_window_exist}=    Run Keyword And Ignore Error    selenium_coam.start_up_view_window_exists
    Run Keyword If    '${is_startup_window_exist[0]}'=='PASS'    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window

Get and Check real time measurements for BBMOD
    [Arguments]    ${interval}
    log to console    Get and Check real time measurements
    Selenium Login And Disable Screen Lock    download_dir=/tmp
	Check real time measurements    object_names=BBMOD    interval=${interval}
	${content_origin}    selenium_coam.get_real_time_measurements    object_names=BBMOD
	${len_origin}    get length  ${content_origin}
	sleep    ${interval}
 	${content_new}    selenium_coam.get_real_time_measurements    object_names=BBMOD
	${len_new}    get length  ${content_new}
	Should be True    ${len_origin} == ${len_new}
	sleep    ${interval}
	Check real time measurements    object_names=BBMOD    interval=${interval}
    Selenium Logout And Close Browser


	
Get and Check real time measurements    
    [Arguments]    ${interval}
    log to console    Get and Check real time measurements
    Selenium Login And Disable Screen Lock    download_dir=/tmp    
	Check real time measurements    object_names=SMOD    interval=${interval}
	Check real time measurements    object_names=RMOD    interval=${interval}
	Check real time measurements    object_names=BBMOD    interval=${interval}
	${content_origin}    selenium_coam.get_real_time_measurements    object_names=BBMOD
	${len_origin}    get length  ${content_origin}
	sleep    ${interval}
 	${content_new}    selenium_coam.get_real_time_measurements    object_names=BBMOD
	${len_new}    get length  ${content_new}
	Should be True    ${len_origin} == ${len_new}
	sleep    ${interval}
	Check real time measurements    object_names=SMOD    interval=${interval}
	Check real time measurements    object_names=RMOD    interval=${interval}
	Check real time measurements    object_names=BBMOD    interval=${interval}
    Selenium Logout And Close Browser	
	
Check real time measurements
    [Arguments]    ${object_names}    ${interval}
    FOR  ${i}  IN RANGE  ${2}
	    ${Power}    ${wait_time}    Get real time measurements via Webem
        ...    object_names=${object_names}    interval=${interval}
#	    Should be True    ${Voltage} > 0
        Should be True    ${Power} > 0
	    exit for loop if   ${i} == 1
	    sleep    ${wait_time}
	    sleep    10
	END	

Get real time measurements via Webem
    [Arguments]    ${object_names}    ${interval}
    ${content}    selenium_coam.get_real_time_measurements    object_names=${object_names}
    ${value_list}    get dictionary values    ${content}
	${time_list}    get dictionary keys   ${value_list[0]}
    sort list    ${time_list}
    ${status}    ${last_time}   run keyword and ignore error    set variable    ${time_list[-1]}
	#Connect to Common Unit Master
    ${current_time}   get time from gnb
    ${end_time}    add_time_to_date    ${last_time}    ${interval}
    ${diff}    subtract_date_from_date    ${end_time}    ${current_time}
    ${diff1}    subtract_time_from_time    ${diff}    ${interval}
    should be true    ${diff1}<0
	${wait_time}=  evaluate  ${diff1} + 60
    ${power_voltage}    get_from_dictionary   ${value_list[0]}    ${last_time}
#	${Voltage}    get_from_dictionary    ${power_voltage}    Voltage
	${Power}    get_from_dictionary    ${power_voltage}    Power
    [Return]     ${Power}    ${wait_time}
	
Wait for New Interval BTS counters Generate
    [Arguments]  ${interval}
    log to console  \nWait for New Interval BTS counters Generate
    ${wait_time}    Get wait value minutes    ${interval}
    sleep    ${wait_time}min
    sleep    50
    Selenium Login And Disable Screen Lock    download_dir=/tmp 
    ${orig_len_2C}    Check and Get BTS Counter Length M40002C
	${orig_len_3C}    Check and Get BTS Counter Length M40003C
    ${orig_len_4C}    Check and Get BTS Counter Length M40004C
    selenium logout and close browser
    sleep    ${interval}
    Selenium Login And Disable Screen Lock    download_dir=/tmp 
    ${new_len_2C}    Check and Get BTS Counter Length M40002C
    Should be True    ${new_len_2C} > ${orig_len_2C}
    ${new_len_3C}    Check and Get BTS Counter Length M40003C
    Should be True    ${new_len_3C} > ${orig_len_3C}
    ${new_len_4C}    Check and Get BTS Counter Length M40004C
    Should be True    ${new_len_4C} > ${orig_len_4C}
    #selenium logout and close browser
	Selenium Logout And Close Browser

Get wait value minutes
    [Arguments]    ${interval}
    #Connect to Common Unit Master
    ssh.force_reconnect    connection=ASIK Master
    ${interval_seconds}    Get Interval Seconds    ${interval}
    ${interval_minutes}    evaluate    ${interval_seconds}/60
    ${origin_time}    Get time from GNB
    ${origin_time}    convert_date    ${origin_time}   datetime
    ${minutes}    set variable    ${origin_time.minute}
    ${wait_time}    evaluate    ${interval_minutes}-${minutes}%${interval_minutes}
    [Return]    ${wait_time}	
	
Check BTS Counter M40004C
    [Arguments]    ${interval}
    log to console   Check BTS Counter M40004C
	#Connect to Common Unit Master
    Selenium Login And Disable Screen Lock    download_dir=/tmp
	#selenium login and disable screen lock
	${value_4C0}    Get PM Counter via Webem for CB009529    counter_id=M40004C0    interval=${interval}
	Set suite Variable     ${value_4C0}
	Should be True    ${M40004C0} *1.05 >${value_4C0} > ${M40004C0} *0.95
    ${value_4C1}    Get PM Counter via Webem for CB009529    counter_id=M40004C1    interval=${interval}
    Should be True    ${M40004C1_3} *1.05 >${value_4C1} > ${M40004C1_3} *0.95
	${value_4C2}    Get PM Counter via Webem for CB009529    counter_id=M40004C2    interval=${interval}
	Should be True    ${M40004C1_3} *1.05 >${value_4C2} > ${M40004C1_3} *0.95
	${value_4C3}    Get PM Counter via Webem for CB009529    counter_id=M40004C3    interval=${interval}
	Should be True    ${M40004C1_3} *1.05 >${value_4C3} > ${M40004C1_3} *0.95
	${value_4C4}    Get PM Counter via Webem for CB009529    counter_id=M40004C4    interval=${interval}
	Should be True    ${M40004C4_5} *1.05 >${value_4C4} > ${M40004C4_5} *0.95
	${value_4C5}    Get PM Counter via Webem for CB009529    counter_id=M40004C5    interval=${interval}
	Should be True    ${M40004C4_5} *1.05 >${value_4C5} > ${M40004C4_5} *0.95
    selenium logout and close browser	
	
Check BTS Counter M40002C
    [Arguments]    ${interval}
    log to console    Check BTS Counter M40002C
	#Connect to Common Unit Master
    Selenium Login And Disable Screen Lock    download_dir=/tmp
	${value_2C0}    Get PM Counter via Webem for CB009529    counter_id=M40002C0    interval=${interval}
	Should be True    ${value_2C0} == ${value_4C0}
    ${value_2C1}    Get PM Counter via Webem for CB009529    counter_id=M40002C1    interval=${interval}
    Should be True   ${M40003C2} *1.05 >${value_2C1} > ${M40003C2} *0.95
	${value_2C2}    Get PM Counter via Webem for CB009529    counter_id=M40002C2    interval=${interval}
	Should be True    ${value_2C2} == ${value_2C0} + ${value_2C1}
    Selenium Logout And Close Browser
	
Check BTS Counter M40003C
    [Arguments]    ${interval}
    log to console    Check BTS Counter M40003C
	#Connect to Common Unit Master
    Selenium Login And Disable Screen Lock    download_dir=/tmp
	${value_3C0}    Get PM Counter via Webem for CB009529    counter_id=M40003C0    interval=${interval}
	Should be True     ${M40003C0_1} *1.05 >${value_3C0} > ${M40003C0_1} *0.95
    ${value_3C1}    Get PM Counter via Webem for CB009529    counter_id=M40003C1    interval=${interval}
    Should be True     ${M40003C0_1} *1.05 >${value_3C1} > ${M40003C0_1} *0.95
	${value_3C2}    Get PM Counter via Webem for CB009529    counter_id=M40003C2    interval=${interval}
	Set suite Variable     ${value_3C2}
	Should be True    ${M40003C2} *1.05 >${value_3C2} > ${M40003C2} *0.95
	${value_3C3}    Get PM Counter via Webem for CB009529    counter_id=M40003C3    interval=${interval}
	Should be True    ${M40003C3_5} *1.05 >${value_3C3} > ${M40003C3_5} *0.95
	${value_3C4}    Get PM Counter via Webem for CB009529    counter_id=M40003C4    interval=${interval}
	Should be True    ${M40003C3_5} *1.05 >${value_3C4} > ${M40003C3_5} *0.95
	${value_3C5}    Get PM Counter via Webem for CB009529    counter_id=M40003C5    interval=${interval}
	Should be True    ${M40003C3_5} *1.05 >${value_3C5} > ${M40003C3_5} *0.95
    Selenium Logout And Close Browser	
	
Check and Get BTS Counter Length M40002C
    ${content_2C0}    Get PM Counter content via Webem    counter_id=M40002C0
    ${len_2C0}    get length  ${content_2C0}
    ${content_2C1}    Get PM Counter content via Webem    counter_id=M40002C1
    ${len_2C1}    get length  ${content_2C1}
    run keyword and ignore error    Should be True    (${len_2C0}-1) <= ${len_2C1} <= ${len_2C0}
    ${content_2C2}    Get PM Counter content via Webem    counter_id=M40002C2
    ${len_2C2}    get length  ${content_2C2}
    run keyword and ignore error    Should be True    ${len_2C2} == ${len_2C0}
    [Return]      ${len_2C0}

Check and Get BTS Counter Length M40003C
    ${content_3C0}    Get PM Counter content via Webem    counter_id=M40003C0
    ${len_3C0}    get length  ${content_3C0}
    ${content_3C1}    Get PM Counter content via Webem    counter_id=M40003C1
    ${len_3C1}    get length  ${content_3C1}
    Should be True    ${len_3C1} == ${len_3C0}
    ${content_3C2}    Get PM Counter content via Webem    counter_id=M40003C2
    ${len_3C2}    get length  ${content_3C2}
    Should be True    ${len_3C2} == ${len_3C1}
    ${content_3C3}    Get PM Counter content via Webem    counter_id=M40003C3
    ${len_3C3}    get length  ${content_3C3}
    Should be True    ${len_3C3} == ${len_3C2}
    ${content_3C4}    Get PM Counter content via Webem    counter_id=M40003C4
    ${len_3C4}    get length  ${content_3C4}
    Should be True    ${len_3C4} == ${len_3C3}
    ${content_3C5}    Get PM Counter content via Webem    counter_id=M40003C5
    ${len_3C5}    get length  ${content_3C5}
    Should be True    ${len_3C5} == ${len_3C4}
    [Return]      ${len_3C0}

Check and Get BTS Counter Length M40004C
    ${content_4C0}    Get PM Counter content via Webem    counter_id=M40004C0
    ${len_4C0}    get length  ${content_4C0}
    ${content_4C1}    Get PM Counter content via Webem    counter_id=M40004C1
    ${len_4C1}    get length  ${content_4C1}
    Should be True    ${len_4C1} == ${len_4C0}
    ${content_4C2}    Get PM Counter content via Webem    counter_id=M40004C2
    ${len_4C2}    get length  ${content_4C2}
    Should be True    ${len_4C2} == ${len_4C1}
    ${content_4C3}    Get PM Counter content via Webem    counter_id=M40004C3
    ${len_4C3}    get length  ${content_4C3}
    Should be True    ${len_4C3} == ${len_4C2}
    ${content_4C4}    Get PM Counter content via Webem    counter_id=M40004C4
    ${len_4C4}    get length  ${content_4C4}
    Should be True    ${len_4C4} == ${len_4C3}
    ${content_4C5}    Get PM Counter content via Webem    counter_id=M40004C5
    ${len_4C5}    get length  ${content_4C5}
    Should be True    ${len_4C5} == ${len_4C4}
    [Return]      ${len_4C0}	
	
	
Get PM Counter via Webem for CB009529
    [Arguments]    ${counter_id}    ${interval}   ${dist_name}=${None}  ${counter_type}=BTS    ${full_path}=${None}
    ${content}    Get PM Counter content via Webem    counter_id=${counter_id}   dist_name=${dist_name}
    ...     counter_type=${counter_type}    full_path=${full_path}
    ${time_list}    get dictionary keys   ${content}
    sort list    ${time_list}
    ${status}    ${last_time}   run keyword and ignore error    set variable    ${time_list[-1]}
    ${current_time}   get time from gnb
    ${end_time}    robot.libraries.DateTime.add_time_to_date    ${last_time}    ${interval}
    ${diff}    robot.libraries.DateTime.subtract_date_from_date    ${current_time}     ${end_time}
    ${diff1}    robot.libraries.DateTime.subtract_time_from_time    ${diff}    ${interval}
    should be true    ${diff1}<30
    ${value}    get_from_dictionary   ${content}    ${last_time}
    [Return]    ${value}	

Collect snapshot log
    log to console     collect snapshot log
    ${local_file_path}    Catch Snapshot COAM    connection=GNB_OAM
    Set Suite Variable    ${local_file_path}
	
Get snapshot and check energy consumption counter
    ${time}=    Get Current Date    result_format=%Y%m%d-%H%M%S
    set suite variable    ${unzipped}    /home/ute/Downloads/s${time}
    set suite variable    ${unzipped_PM}    ${unzipped}/PM
    csn.connect_to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...               username=${tl.test_pc.default_ssh_connection_details.username}
    ...               password=${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=ute
    csn.execute    command=unzip -o ${local_file_path} -d ${unzipped}    connection=ute
    ${files}=    OperatingSystem.Run    ls /home/ute/Downloads/s${time}/ | grep _1011_part_
    ${PM_files_list}    Get correct file with PM    ${files}
    ${parsed_files}=    Extract and parse PM files    ${PM_files_list}    ${unzipped_PM}
    PM files should contain energy consumption counter      ${parsed_files}

Delete snapshot
    [Documentation]
   	...  Removes directory
    [Arguments]    ${local_file_path}   ${unzipped}
    run  rm -rf ${local_file_path}
    run  rm -rf ${unzipped}	
	
Get correct file with PM
    [Arguments]     ${files}
    @{files_list}=    Split String    ${files}    \n
    ${num_of_files}    Get Length    ${files_list}
    @{PM_files_list}    create list
    FOR   ${i}   IN RANGE   ${num_of_files}
        ${no}   evaluate    ${num_of_files} - ${i}
        ${PM_file}=    Get Lines Containing String    ${files}    _1011_part_${no}
        OperatingSystem.Run    unzip ${unzipped}/${PM_file} -d ${unzipped_PM}
        ${RD_files}=    OperatingSystem.Run    ls ${unzipped}/PM | grep PM.BTS.*xml.gz
        @{RD_files_split_list}=    Split String    ${RD_files}    \n
        ${PMfile}=    get length    ${RD_files_split_list}
        Run Keyword If    ${PMfile}>1    Append to List    ${PM_files_list}    @{RD_files_split_list}
        Exit for loop if    ${PM_files_list}
    END
    [Return]    ${PM_files_list}	
	
Extract and parse PM files
    [Arguments]    ${PM_files_list}    ${unzipped_PM}
    ${num_of_PM_files}    Get Length    ${PM_files_list}
    ${no_PM_file}    evaluate    ${num_of_PM_files} - 1
    Run    gzip -d ${unzipped_PM}/${PM_files_list[${no_PM_file}]}
    ${extracted_file}    Fetch From Left    ${PM_files_list[${no_PM_file}]}    .gz
    csn.SendCommand    command=cat ${unzipped_PM}/${extracted_file}    connection=ute
    ${PMfile}    csn.read output    connection=ute
    Set Variable   ${PMfile}
    [Return]    ${PMfile}	
	
PM files should contain energy consumption counter
    [Arguments]    ${parsed_files}
    ${M40002C0_matched_content}    Should Match Regexp      ${parsed_files}    M40002C0\>[1-9]\d*
    ${M40002C1_matched_content}    Should Match Regexp      ${parsed_files}    M40002C1\>[1-9]\d*
    ${M40002C2_matched_content}    Should Match Regexp      ${parsed_files}    M40002C2\>[1-9]\d*
    ${M40003C0_matched_content}    Should Match Regexp      ${parsed_files}    M40003C0\>[1-9]\d*
    ${M40003C1_matched_content}    Should Match Regexp      ${parsed_files}    M40003C1\>[1-9]\d*
    ${M40003C2_matched_content}    Should Match Regexp      ${parsed_files}    M40003C2\>[1-9]\d*
    ${M40003C3_matched_content}    Should Match Regexp      ${parsed_files}    M40003C3\>[1-9]\d*
    ${M40003C4_matched_content}    Should Match Regexp      ${parsed_files}    M40003C4\>[1-9]\d*
    ${M40003C5_matched_content}    Should Match Regexp      ${parsed_files}    M40003C5\>[1-9]\d*
    ${M40004C0_matched_content}    Should Match Regexp      ${parsed_files}    M40004C0\>[1-9]\d*
    ${M40004C1_matched_content}    Should Match Regexp      ${parsed_files}    M40004C1\>[1-9]\d*
    ${M40004C2_matched_content}    Should Match Regexp      ${parsed_files}    M40004C2\>[1-9]\d*
    ${M40004C3_matched_content}    Should Match Regexp      ${parsed_files}    M40004C3\>[1-9]\d*
    ${M40004C4_matched_content}    Should Match Regexp      ${parsed_files}    M40004C4\>[1-9]\d*
    ${M40004C5_matched_content}    Should Match Regexp      ${parsed_files}    M40004C5\>[1-9]\d*
    ${M40028C0_matched_content}    Should Match Regexp      ${parsed_files}    M40028C0\>[1-9]\d*
    ${M40028C1_matched_content}    Should Match Regexp      ${parsed_files}    M40028C1\>[1-9]\d*
    ${M40028C2_matched_content}    Should Match Regexp      ${parsed_files}    M40028C2\>[1-9]\d*
    ${M40028C3_matched_content}    Should Match Regexp      ${parsed_files}    M40028C3\>[1-9]\d*
	
Power meter Feature activation
    log to console    \nPower meter Feature activation
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    parameter=actPowerMeter
    ...    value=true
    ...    operation=update
    ...    skip_parameter_relation_errors=skip
    ...    connection=GNB_OAM

	
PM counter update enabled
    log to console    \nPM counter update enabled 
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/PMMNL-1
    ...    parameter=mtBtsEnergyMonitoring
    ...    value=15min
    ...    operation=update
    ...    skip_parameter_relation_errors=skip
    ...    connection=GNB_OAM	
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/PMMNL-1
    ...    parameter=mtSBTSBBCAPEnergyMonitoring
    ...    value=15min
    ...    operation=update
    ...    skip_parameter_relation_errors=skip
    ...    connection=GNB_OAM
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/PMMNL-1
    ...    parameter=mtSBTSRfmEnergyMonitoring
    ...    value=15min
    ...    operation=update
    ...    skip_parameter_relation_errors=skip
    ...    connection=GNB_OAM
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/PMMNL-1
    ...    parameter=mtSBTSSmEnergyMonitoring
    ...    value=15min
    ...    operation=update
    ...    skip_parameter_relation_errors=skip
    ...    connection=GNB_OAM	

Check BTS Counter M40028C
    [Arguments]    ${interval}
    log to console   Check BTS Counter M40028C
	#Connect to Common Unit Master
    Selenium Login And Disable Screen Lock    download_dir=/tmp
	#selenium login and disable screen lock
	${value_28C0}    Get PM Counter via Webem for CB009529    counter_id=M40028C0    interval=${interval}
	Set suite Variable     ${value_28C0}
    Should be True    ${value_28C0} > 0
	run keyword and ignore error    Should be True    ${M40028C0} *1.05 >${value_28C0} > ${M40028C0} *0.95
    ${value_28C2}    Get PM Counter via Webem for CB009529    counter_id=M40028C2    interval=${interval}
    Should be True    ${value_28C2} > 0
    run keyword and ignore error    Should be True    ${M40028C2_3} *1.05 >${value_28C2} > ${M40028C2_3} *0.95
    selenium logout and close browser

Check BTS Counter M40028C for BBMOD
    [Arguments]    ${interval}
    log to console   Check BTS Counter M40028C
	#Connect to Common Unit Master
    Selenium Login And Disable Screen Lock    download_dir=/tmp
	#selenium login and disable screen lock
	${value_28C0}    Get PM Counter via Webem for CB009529    counter_id=M40028C0    interval=${interval}
	Should be True    ${M40028C0} *1.02 >${value_28C0} > ${M40028C0} *0.98
	${value_28C1}    Get PM Counter via Webem for CB009529    counter_id=M40028C1    interval=${interval}
	Should be True    ${M40028C1} *1.02 >${value_28C1} > ${M40028C1} *0.98
	${value_28C2}    Get PM Counter via Webem for CB009529    counter_id=M40028C2    interval=${interval}
	Should be True    ${M40028C2} *1.02 >${value_28C2} > ${M40028C2} *0.98
    ${value_28C3}    Get PM Counter via Webem for CB009529    counter_id=M40028C3    interval=${interval}
    Should be True    ${M40028C3} *1.03 >${value_28C3} > ${M40028C3} *0.98
    selenium logout and close browser
	

Get and Check real time measurements for dual core
    [Arguments]    ${interval}
    log to console    Get and Check real time measurements for dual core
    Selenium Login And Disable Screen Lock    download_dir=/tmp    
	#Check real time measurements    object_names=SMOD    interval=${interval}
	Check real time measurements    object_names=RMOD    interval=${interval}
	Check real time measurements    object_names=BBMOD    interval=${interval}
	${content_origin}    selenium_coam.get_real_time_measurements    object_names=BBMOD
	${len_origin}    get length  ${content_origin}
	sleep    ${interval}
 	${content_new}    selenium_coam.get_real_time_measurements    object_names=BBMOD
	${len_new}    get length  ${content_new}
	Should be True    ${len_origin} == ${len_new}
	sleep    ${interval}
	#Check real time measurements    object_names=SMOD    interval=${interval}
	Check real time measurements    object_names=RMOD    interval=${interval}
	Check real time measurements    object_names=BBMOD    interval=${interval}
    Selenium Logout And Close Browser	
	
Check BTS Counter M40028C for dual core
    [Arguments]    ${interval}
    log to console   Check BTS Counter M40028C for dual core
	#Connect to Common Unit Master
    Selenium Login And Disable Screen Lock    download_dir=/tmp
	#selenium login and disable screen lock
	${value_28C0}    Get PM Counter via Webem for CB009529    counter_id=M40028C0    interval=${interval}
	...    full_path=${28C0_Primary_full_path}
	Set suite Variable     ${value_28C0}
	Should be True    ${value_28C0} > 0
	run keyword and ignore error    Should be True    ${M40028C0} *1.05 >${value_28C0} > ${M40028C0} *0.95
	${value_28C0_2}    Get PM Counter via Webem for CB009529    counter_id=M40028C0    interval=${interval}
	...    full_path=${28C0_Secondary_full_path}
	Set suite Variable     ${value_28C0_2}
    Should be True    ${value_28C0_2} > 0
	run keyword and ignore error    Should be True    ${M40028C0_2} *1.05 >${value_28C0_2} > ${M40028C0_2} *0.95	
    ${value_28C2}    Get PM Counter via Webem for CB009529    counter_id=M40028C2    interval=${interval}
    ...    full_path=${28C2_Primary_full_path}
    Should be True    ${value_28C2} > 0
    run keyword and ignore error    Should be True    ${M40028C2} *1.05 >${value_28C2} > ${M40028C2} *0.95
    ${value_28C2_2}    Get PM Counter via Webem for CB009529    counter_id=M40028C2    interval=${interval}
    ...    full_path=${28C2_Secondary_full_path}
    Should be True    ${value_28C2_2} > 0
    run keyword and ignore error    Should be True    ${M40028C2_2} *1.05 >${value_28C2_2} > ${M40028C2_2} *0.95
    selenium logout and close browser
	
	
Check real time measurements for dual core
    [Arguments]    ${object_names}    ${measured_object}    ${interval}
    FOR  ${i}  IN RANGE  ${2}
	    ${Voltage}    ${Power}    ${wait_time}    Get real time measurements via Webem
        ...    object_names=${object_names}    interval=${interval}
	    Should be True    ${Voltage} > 0
        Should be True    ${Power} > 0
	    exit for loop if   ${i} == 1
	    sleep    ${wait_time}
	    sleep    10
	END
