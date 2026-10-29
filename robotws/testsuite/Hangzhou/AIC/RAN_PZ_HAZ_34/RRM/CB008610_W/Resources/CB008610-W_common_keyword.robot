*** Settings ***
Documentation
...   author: Liu Ning
...   contact: n5liu@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG

Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_vdu.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_state.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Variables     ./Configured_parameters.py
Resource     ./Variables.robot

*** Variables ***


*** Keywords ***
Ping latency verification from UE
    [Arguments]    ${ping_interval}    ${ping_timeout}    ${ping_size}    ${expected_ping_latency_avg}
    ...    ${ue_index}    ${ue_type}
    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=${ue_type}    reset_sol=reboot_ue
    power_ue.UE Attach     ue_index=${ue_index}    ue_type=${ue_type}
    ####${ue_index} is just for name connection alia, is not used for input parameter######
    Set Suite Variable     ${ue_index}
    Close ping process on android ue
    ${ping_result_file}    run keyword
    ...    Start ping testing from andriod UE    ping_interval=${ping_interval}    ping_timeout=${ping_timeout}
    ...    ping_size=${ping_size}
	Check ping latency result    expected_ping_latency_avg=${expected_ping_latency_avg}
	...    ping_result_file=${ping_result_file}
    [Teardown]    Run Keyword And Ignore Error    power_ue.UE Detach     ue_index=${ue_index}    ue_type=${ue_type}

Modify parameters of CU by delta plan_dropped
    #dropped due to KW CU Get Single Parameter Value can't support check the parameter of structure
    [Arguments]    ${parameter_dict_expected}
   &{parameter_update} 	 Create Dictionary
    log to console   \n*** Check parameters need to be added,updated or deleted ***
    FOR    ${mo_dn}    IN    @{parameter_dict_expected}
        ${parameter_dict_in_MO}    Check parameters of CU in SCF    mo_dn=${mo_dn}
        ...    parameter_dict_in_MO=${parameter_dict_expected}[${mo_dn}]
        Set To Dictionary    ${parameter_dict_in_MO}    ${mo_dn}    ${parameter_dict_in_MO}
    END

Check parameters of CU in SCF_dropped
    [Arguments]    ${parameter_dict_in_MO}    ${mo_dn}
    log to console   \n*** Check parameters need to be added,updated or deleted ***
    FOR    ${parameter}    IN    @{parameter_dict_in_MO}
        ${value_in_CU}    CU Get Single Parameter Value  distname=${mo_dn}
        ...    parameter=${parameter}
        Run keyword if   '${value_in_CU}'=='${parameter_dict_in_MO}[${parameter}]'
        ...    Remove From Dictionary    ${parameter_dict_in_MO}    ${parameter}
        log to console    parameter is ${parameter_dict_in_MO}
    END
    [Return]    ${parameter_dict_in_MO}

Modify parameters of CU by delta plan
  [Arguments]    ${parameter_dict}
  ${timeendTmp}     Get Current Date    result_format=%Y%m%d_%H%M%S%f
  &{parameter_btsname} 	 Create Dictionary    btsName    MRBTS_${timeendTmp}
  Set To Dictionary    ${parameter_dict}    ${MRBTS_dist}    ${parameter_btsname}
  CU Delta Commission update    parameters=${parameter_dict}

Update parameters by delta plan in DU
    [Arguments]    ${parameter_list}     ${Change_parameter}=${False}
    vDU Login
    ${uni_id}    ${plan_id}     Create delta plan by ADMIN REST in DU
    FOR    ${parameter}    IN    @{parameter_list}
        ${Change_parameter}    Update parameters of the same dic
        ...    parameter_dict_expected=${parameter}
        ...    plan_id=${plan_id}    Change_parameter=${Change_parameter}
    END
    Run Keyword If    ${Change_parameter} == ${True}      Validate and activate delta plan in DU
    ...    plan_id=${plan_id}    uni_id=${uni_id}    wait_vdu_up=True
    [Teardown]    Run Keyword And Ignore Error    vDU Logout

Update parameters of the same dic
    [Arguments]    ${parameter_dict_expected}     ${plan_id}    ${Change_parameter}    ${timeout}=30
    log to console   \n*** Check parameters need to be added,updated or deleted **
    FOR    ${key}    IN    @{parameter_dict_expected}
        ${out}    Update DU parameters of the same dist   mo_dn=${key}   plan_id=${plan_id}
        ...    parameter_in_the_same_dist=${parameter_dict_expected}[${key}]
        Run Keyword If    &{out} != &{Empty}     Set Suite Variable    ${Change_parameter}    ${True}
    END
    [Return]    ${Change_parameter}


Update DU parameters of the same dist
    [Arguments]    ${parameter_in_the_same_dist}    ${mo_dn}    ${plan_id}    ${timeout}=30
    &{modify_parameter_dict}    Create Dictionary
    FOR    ${para_name}    IN    @{parameter_in_the_same_dist}
        ${out}     vdu.search_parameter_of_current_plan
        ...    mo_dn=${mo_dn}   para_name=${para_name}   timeout=${timeout}
        run keyword if    "${out}"!="${parameter_in_the_same_dist}[${para_name}]"
        ...    Set to Dictionary    ${modify_parameter_dict}    ${para_name}    ${parameter_in_the_same_dist}[${para_name}]
    END
    log to console   \n*** Update Delta Plan Parameter for specific dist ***
	Run Keyword If  &{modify_parameter_dict} != &{Empty}
	...    Update Delta Plan Parameter   plan_id=${plan_id}   mo_dn=${mo_dn}
	...    updated_paras_dict=${modify_parameter_dict}   operation=replace
	[Return]     ${modify_parameter_dict}


Config DU parameters of the same dist
    [Arguments]    ${parameter_in_the_same_dist}    ${mo_dn}    ${plan_id}    ${timeout}=30
    &{modify_parameter_dict}    Create Dictionary
    &{add_parameter_dict}    Create Dictionary
    &{del_parameter_dict}    Create Dictionary
    @{parameter_config_list}    Create List
    FOR    ${para_name}    IN    @{parameter_in_the_same_dist}
        ${out}    run keyword and ignore error    vdu.search_parameter_of_current_plan
        ...    mo_dn=${mo_dn}   para_name=${para_name}   timeout=${timeout}
        run keyword if
        ...    "${out}"!="${parameter_in_the_same_dist}[${para_name}]" and "${out}"!="None"
        ...    Set to Dictionary    ${modify_parameter_dict}    ${para_name}    ${parameter_in_the_same_dist}[${para_name}]
        ...    ELSE IF   '${parameter_in_the_same_dist}[${para_name}]'=='${Empty}' and '${out}'!='None'
        ...    Set to Dictionary    ${del_parameter_dict}    ${para_name}    ${parameter_in_the_same_dist}[${para_name}]
        ...    ELSE   '${parameter_in_the_same_dist}[${para_name}]'!='${Empty}' and '${out}'=='None'
        ...    Set to Dictionary    ${add_parameter_dict}    ${para_name}    ${parameter_in_the_same_dist}[${para_name}]
    END
    log to console   \n*** Update Delta Plan Parameter for specific dist ***
	Run Keyword If  &{modify_parameter_dict} != &{Empty}    RUN KEYWORDS
	...    Update Delta Plan Parameter   plan_id=${plan_id}   mo_dn=${mo_dn}
	...    updated_paras_dict=${modify_parameter_dict}   operation=replace
	...    AND    Append to list    ${parameter_config_list}    ${modify_parameter_dict}
	Run Keyword If  &{add_parameter_dict} != &{Empty}    RUN KEYWORDS
	...    Update Delta Plan Parameter   plan_id=${plan_id}   mo_dn=${mo_dn}
	...    updated_paras_dict=${add_parameter_dict}   operation=add
	...    	...    AND    Append to list    ${parameter_config_list}    ${add_parameter_dict}
	Run Keyword If  &{del_parameter_dict} != &{Empty}     RUN KEYWORDS
	...    Update Delta Plan Parameter   plan_id=${plan_id}   mo_dn=${mo_dn}
	...    updated_paras_dict=${del_parameter_dict}   operation=delete
	...    AND    Append to list    ${parameter_config_list}    ${del_parameter_dict}

	[Return]     ${parameter_config_list}



Create delta plan by ADMIN REST in DU
    ${uni_id}   Get Unique Id
	${delta_plan_name}    get unique id    prefix=TA_delta_plan    precise=LOW
	log to console   \n*** Generate Delta Plan ***
	${plan_id}    ${action_id}    Generate Delta Plan    plan_name=${delta_plan_name}    plan_description=TA
    [Return]    ${uni_id}    ${plan_id}

Validate and activate delta plan in DU
    [Arguments]     ${plan_id}    ${uni_id}    ${wait_vdu_up}=False
    log to console   \n*** Validate Delta Plan By REST ***
    Validate Delta Plan By REST   ${plan_id}
    ${scf_path}  Get A Directory  SCF
    ${delta_filename}  Set Variable   modify_DU_parameter_${uni_id}.xml
    log to console   \n*** Save Delta Plan File ***
    ${delta_scf_fullpath}   vdu.Save Delta Plan File   local_path=${scf_path}   local_filename=${delta_filename}
    log to console   \n*** Activate Delta Plan By REST ***
    Activate Delta Plan By REST   ${plan_id}   wait_vdu_up=${wait_vdu_up}


OAM Precondition Cell Should Be Onair
    wait until keyword succeeds    600   30   vDU Verify All Cells Status Should Be Onair

Close ping process on android ue
    Connect to control pc enhanced    ue_index=${ue_index}
    ...        cpc_ip=${cpc_ip}
    ...        cpc_usrname=${cpc_username}
    ...        cpc_passwd=${cpc_password}
    run keyword and ignore error    csn.send_command
    ...    command=adb -s ${serial} shell ps -ef | grep ${progress_name} |grep -v grep
    ...    connection=cpc_${ue_index}
    sleep   3s
    ${output_for_debug}    run keyword and ignore error    csn.read_output    size=1000    connection=cpc_${ue_index}
    ${filter_command}    Catenate    ps -ef | grep ${progress_name} |grep -v grep |awk '{print $${process_index}}'
    csn.send_command
    ...    command=adb -s ${serial} shell ${filter_command} |xargs adb -s ${serial} shell kill -9
    ...    connection=cpc_${ue_index}
    sleep   3s
    FOR    ${i}    IN RANGE    ${3}
        csn.send_command    command=adb -s ${serial} shell ${filter_command}
        ...    connection=cpc_${ue_index}    timeout=60
        ${output}    csn.read_output    size=1000    connection=cpc_${ue_index}
        ${output}    replace_string    string=${output}   search_for=\n    replace_with=${SPACE}
        run keyword if    '${output}'!='${EMPTY}'    csn.send_command
        ...    command=adb -s ${serial} shell ${filter_command} |xargs adb -s ${serial} shell kill -9
        ...    connection=cpc_${ue_index}
        exit for loop if    '${output}'=='${EMPTY}'
    END
    should be empty      ${output}
    [Teardown]    Csn.disconnect      connection=cpc_${ue_index}

Start ping testing from andriod UE
    [Documentation]  This keyword connect to android control pc and start the iperf data.
    [Arguments]      ${ping_interval}    ${ping_timeout}    ${ping_size}    ${UE_folder}=/tmp
    ...    ${local_log_folder_on_ute}=${TS_CASE_LOG_PATH}
    ${timestamp}    DateTime.Get Current Date    result_format=%Y%m%d-%H%M%S
    ${ping_result}    Join path    ${UE_folder}    PING_${timestamp}.log
    ${ping_result_on_ute}    Join path    ${local_log_folder_on_ute}    PING_${timestamp}.log
    Connect to control pc enhanced    ue_index=${ue_index}
    ...        cpc_ip=${cpc_ip}
    ...        cpc_usrname=${cpc_username}
    ...        cpc_passwd=${cpc_password}
    ${ping_cmd}=      catenate    adb -s ${serial} shell
    ...     ping -s ${ping_size} -w ${ping_timeout} -i ${ping_interval} ${appserver_addr} >${ping_result} 2>&1 &
    csn.send_command    command=${ping_cmd}    connection=cpc_${ue_index}
    sleep    2s
    Check the progress exist
    sleep    ${ping_timeout}s
    csn.Download file    remote_path=${ping_result}    local_path=${ping_result_on_ute}   connection=cpc_${ue_index}
    [Teardown]    csn.disconnect    connection=cpc_${ue_index}
    [Return]    ${ping_result_on_ute}

Check the progress exist
     FOR    ${i}    IN RANGE    ${3}
         run keyword if    '${serial}'=='${EMPTY}'
         ...    csn.send_command    command=ps -ef |grep ${progress_name} |grep -v grep |awk '{print $${process_index}}'
         ...    connection=cpc_${ue_index}    timeout=120
         ...    ELSE
         ...    csn.send_command    command=adb -s ${serial} shell ps -ef | grep ${progress_name} |grep -v grep |awk '{print $${process_index}}'
         ...    connection=cpc_${ue_index}    timeout=120
        ${output}    csn.read_output    size=1000    connection=cpc_${ue_index}
        ${output}    replace_string    string=${output}   search_for=\n    replace_with=${SPACE}
        exit for loop if    '${output}'!='${EMPTY}'
    END

Check ping latency result
    [Arguments]    ${expected_ping_latency_avg}    ${ping_result_file}
    log to console    \n*** Check ping Result ***
    ${ping_rtt_output}     run    command=cat ${ping_result_file} |grep rtt
    ${ping_rtt_string}=    Run keyword and continue on failure    Remove String    ${ping_rtt_output}    \n
    log to console    ping latency is ${ping_rtt_string}
    ${ping_rtt_value}=     Fetch from right     ${ping_rtt_string}    =
    @{ping_rtt_list}=    Split String	   ${ping_rtt_value}    separator=/
    should be true     ${ping_rtt_list[1]} < ${expected_ping_latency_avg}


Test Case Setup
    ${START_TIME}=    Get time    exclude_millis=yes
    Set Suite Variable    ${START_TIME}

Test Case Teardown
     Run Keyword And Ignore Error    Stop DL UL Traffic
     Run Keyword And Ignore Error    power_ue.UE Detach     ue_index=${0}    ue_type=${ue_type}


######
Verify peak TP can reach to the target
    [Arguments]    ${ue_index}    ${ue_type}    ${in_tput}   ${tp_expected}    ${direction}    ${duration}
    ...    ${protocol}=udp
    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=${ue_type}    reset_sol=reboot_ue
    Ue attach with index    ue_index=${ue_index}
    ####${ue_index} is just for name connection alia, is not used for input parameter######
    Set Suite Variable     ${ue_index}
    power_ue.Start traffic    ue_index=${ue_index}     direction=${direction}    throughput=${in_tput}
    ...    appserver=APPserversim     protocol=${protocol}
    ...    duration=${duration}    ue_type=${ue_type}   process_num=1    iperf_type=via_command   data_amount=2M
    sleep    60s
    Check Tput Result    tp_expected=${tp_expected}     direction=${direction}    ue_type=${ue_type}
    [Teardown]    Run keywords    Run Keyword And Ignore Error    power_ue.Stop traffic
    ...    direction=${direction}    ue_index=${ue_index}    ue_type=${ue_type}    appserver=APPserversim
    ...    AND     Run Keyword And Ignore Error    power_ue.UE Detach     ue_index=${ue_index}    ue_type=${ue_type}

Check Tput Result
    [Arguments]    ${tp_expected}    ${direction}   ${ue_type}
    log to console    \n*** Check Tput Result ***
    ${handle}    vDU Begin K8s Log
    Set test variable    ${handle}
    ${container_prefix}    vDU Get Container Name Prefix
	sleep    60s
	${local_l2rt_file}    vDU End K8s Log      handle=${handle}     pod_abbr=up     container=${container_prefix}l2rt
	Set Suite Variable    ${local_l2rt_file}
	${cell_identify}=    Evaluate     16384*${tl.gnbs[0].dus[0].instance_id}+1
    ${cell_identify}   convert to string   ${cell_identify}
    @{list_of_cell}     Create List         ${cell_identify}
    ${dl_tp}    Run keyword and continue on failure    power_ue.Check Tput    ue_type=${ue_type}    direction=${direction}
    ...    log=${local_l2rt_file}    cells=@{list_of_cell}    target_throughput=${tp_expected}    target_avg_percent=0.9
