*** Settings ***
Documentation
...    author: yan meng
...    contact: meng.yan@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG2

Resource          ../../../../../resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_cu.robot
#Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_vdu.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_state.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/container_log_capturing.robot
Resource       ../../../../../RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/L3Call.robot
Resource       taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Library    Collections



*** Variables ***
${MRBTS_ID}    ${tl.gnbs[0].dus[0].instance_id}
${NRBTS_ID}    ${tl.gnbs[0].dus[0].instance_id}
${dist}    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1


*** Keywords ***
Test Setup for 8610
    robot_common_operations.Common Case Setup
    ${START_TIME}=    Get time    exclude_millis=yes
    Set Suite Variable    ${START_TIME}

Test Teardown for 8610
     Run Keyword And Ignore Error    Stop DL UL Traffic
     Run Keyword And Ignore Error    power_ue.UE Detach     ue_index=${0}    ue_type=${ue_type}
     robot_common_operations.Common Case Teardown
    # Run Keyword And Continue On Failure    Stop and download X2 Logs on eNB    x2_log_name=710_A01_ENB.pcap

OAM Precondition Cell Should Be Onair
    wait until keyword succeeds    600   30   vDU Verify All Cells Status Should Be Onair

Online Get VDU Parameter Value1
    [Arguments]    ${mo_dn}    ${para_name}    ${timeout}=60
    ${timeout}   convert to integer  ${timeout}
    ${out}  vdu.search_parameter_of_current_plan   mo_dn=${mo_dn}   para_name=${para_name}   timeout=${timeout}
    [Return]  ${out}

Start DL UL Traffic
    [Arguments]    ${dl_tput}    ${ul_tput}
    #power_ue.UE Attach     ue_index=${0}    ue_type=${ue_type}
    power_ue.Start traffic    ue_index=${0}    direction=dl    throughput=${dl_tput}    duration=600
    ...    ue_type=${ue_type}   process_num=1
    power_ue.Start traffic    ue_index=${0}    direction=ul    throughput=${ul_tput}    duration=600
	...    ue_type=${ue_type}   iperf_type=via_command   data_amount=2M
	sleep    5s

Start DL Traffic
    [Arguments]    ${dl_tput}
    power_ue.Start traffic    ue_index=${0}    direction=dl    throughput=${dl_tput}    duration=600
    ...    ue_type=${ue_type}   process_num=1
	sleep    5s

Start UL Traffic
    [Arguments]    ${ul_tput}
    power_ue.Start traffic    ue_index=${0}    direction=ul    throughput=${ul_tput}    duration=600
	...    ue_type=${ue_type}   iperf_type=via_command   data_amount=2M
	sleep    5s

Check Tput Result
    [Arguments]    ${dltarget_throughput}    ${ultarget_throughput}    ${actCarrierAggregation}=${True}
    log to console    \n*** Check Tput Result ***
    ${list_of_cell_ids0}    Create List    184680451
    ${list_of_cell_ids1}    Create List    184680452
    ${handle}    vDU Begin K8s Log
    Set test variable    ${handle}
    ${container_prefix}    vDU Get Container Name Prefix
	sleep    80s
	${local_l2rt_file0}    vDU End K8s Log with pod_name      handle=${handle}     pod_abbr=up
	...    container=${container_prefix}l2rt    full_pod_name=po-tl175-up-0
	#Set Suite Variable    ${local_l2rt_file0}
	#${local_l2rt_file1}    vDU End K8s Log with pod_name      handle=${handle}     pod_abbr=up
	#...    container=${container_prefix}l2rt    full_pod_name=po-tl175-up-1
	#Set Suite Variable    ${local_l2rt_file1}

	${all_tp0}    Run keyword and continue on failure    power_ue.Check Bi Tput
	...    ue_type=${ue_type}    log=${local_l2rt_file0}     cells=${list_of_cell_ids0}
    ...    ultarget_throughput=0   dltarget_throughput=0
    ...    target_avg_percent=1
    ${all_tp1}    Run keyword and continue on failure    power_ue.Check Bi Tput
	...    ue_type=${ue_type}    log=${local_l2rt_file0}     cells=${list_of_cell_ids1}
    ...    ultarget_throughput=0    dltarget_throughput=0
    ...    target_avg_percent=1
	Set Test Variable    ${all_tp0}    ${all_tp0}
	Set Test Variable    ${all_tp1}    ${all_tp1}
	${dl_average_real}=    Evaluate    ${all_tp0[1][0]['average']}+${all_tp1[1][0]['average']}
	${ul_average_real}=    Evaluate    ${all_tp0[0][0]['average']}+${all_tp1[0][0]['average']}
    Run keyword and continue on failure    should be true    ${dl_average_real}>=${dltarget_throughput}
	Run keyword and continue on failure    should be true    ${ul_average_real}>=${ultarget_throughput}

Check DL Tput Result
    [Arguments]    ${dltarget_throughput}    ${actCarrierAggregation}=${True}
    log to console    \n*** Check Tput Result ***
    ${list_of_cell_ids0}    Create List    184680451
    ${list_of_cell_ids1}    Create List    184680452
    ${handle}    vDU Begin K8s Log
    Set test variable    ${handle}
    Set test variable    ${container_prefix}    ctr-tl175-
    #${container_prefix}    vDU Get Container Name Prefix
	sleep    80s
	${local_l2rt_file0}    vDU End K8s Log with pod_name      handle=${handle}     pod_abbr=up
	...    container=${container_prefix}l2rt    full_pod_name=po-tl175-up-0
	#Set Suite Variable    ${local_l2rt_file0}
	#${local_l2rt_file1}    vDU End K8s Log with pod_name      handle=${handle}     pod_abbr=up
	#...    container=${container_prefix}l2rt    full_pod_name=po-tl175-up-1
	#Set Suite Variable    ${local_l2rt_file1}

	${all_tp0}    Run keyword and continue on failure    power_ue.Check Bi Tput
	...    ue_type=${ue_type}    log=${local_l2rt_file0}     cells=${list_of_cell_ids0}
    ...    ultarget_throughput=0   dltarget_throughput=0
    ...    target_avg_percent=1
    ${all_tp1}    Run keyword and continue on failure    power_ue.Check Bi Tput
	...    ue_type=${ue_type}    log=${local_l2rt_file0}     cells=${list_of_cell_ids1}
    ...    ultarget_throughput=0    dltarget_throughput=0
    ...    target_avg_percent=1
	Set Test Variable    ${all_tp0}    ${all_tp0}
	Set Test Variable    ${all_tp1}    ${all_tp1}
	${dl_average_real}=    Evaluate    ${all_tp0[1][0]['average']}+${all_tp1[1][0]['average']}
	${dltarget_throughput}    Evaluate    ${dltarget_throughput}*0.95
    Run keyword and continue on failure    should be true    ${dl_average_real}>=${dltarget_throughput}

Check UL Tput Result
    [Arguments]    ${ultarget_throughput}    ${actCarrierAggregation}=${True}
    log to console    \n*** Check Tput Result ***
    ${list_of_cell_ids0}    Create List    184680451
    ${list_of_cell_ids1}    Create List    184680452
    ${handle}    vDU Begin K8s Log
    Set test variable    ${handle}
    Set test variable    ${container_prefix}    ctr-tl175-
    #${container_prefix}    vDU Get Container Name Prefix
	sleep    80s
	${local_l2rt_file0}    vDU End K8s Log with pod_name      handle=${handle}     pod_abbr=up
	...    container=${container_prefix}l2rt    full_pod_name=po-tl175-up-0
	#Set Suite Variable    ${local_l2rt_file0}
	#${local_l2rt_file1}    vDU End K8s Log with pod_name      handle=${handle}     pod_abbr=up
	#...    container=${container_prefix}l2rt    full_pod_name=po-tl175-up-1
	#Set Suite Variable    ${local_l2rt_file1}

	${all_tp0}    Run keyword and continue on failure    power_ue.Check Bi Tput
	...    ue_type=${ue_type}    log=${local_l2rt_file0}     cells=${list_of_cell_ids0}
    ...    ultarget_throughput=0   dltarget_throughput=0
    ...    target_avg_percent=1
    ${all_tp1}    Run keyword and continue on failure    power_ue.Check Bi Tput
	...    ue_type=${ue_type}    log=${local_l2rt_file0}     cells=${list_of_cell_ids1}
    ...    ultarget_throughput=0    dltarget_throughput=0
    ...    target_avg_percent=1
	Set Test Variable    ${all_tp0}    ${all_tp0}
	Set Test Variable    ${all_tp1}    ${all_tp1}
	${ul_average_real}=    Evaluate    ${all_tp0[0][0]['average']}+${all_tp1[0][0]['average']}
	${ultarget_throughput}    Evaluate    ${ultarget_throughput}*0.95
	Run keyword and continue on failure    should be true    ${ul_average_real}>=${ultarget_throughput}

Stop DL UL Traffic
    log to console      \n*** Stop traffic ***
    power_ue.Stop traffic    direction=ul    ue_index=${0}    ue_type=${ue_type}    iperf_type=via_command
    power_ue.Stop traffic    direction=dl    ue_index=${0}    ue_type=${ue_type}

Stop DL Traffic
    log to console      \n*** Stop traffic ***
    power_ue.Stop traffic    direction=dl    ue_index=${0}    ue_type=${ue_type}

Stop UL Traffic
    log to console      \n*** Stop traffic ***
    power_ue.Stop traffic    direction=ul    ue_index=${0}    ue_type=${ue_type}    iperf_type=via_command

vDU End K8s Log with pod_name
    [Arguments]   ${handle}  ${pod_abbr}  ${container}    ${full_pod_name}   ${gnb_index}=0  ${vdu_index}=0
    [Teardown]  run keyword and ignore error    vDU Disconnect Interactive Connection    alias=${alias}
    [Documentation]    End K8s Log
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change, <date>,<who>,<what and how>
    ...    13.09.2021, chris.l.cao@nokia-sbell.com, change login account from tenant to admin to better support in OCP
    ...    |  Input Parameters | Man. | Description |
    ...    | since_time |  Yes | it's returned from 'Begin K8s Log' |
    ...    | pod_abbr   |  Yes | pod abbreviation name, eg, oamcp, uprt |
    ...    | container  | Yes | container name, e.g. oam, oamfh, nwmgmt, cprt, rcpsdl, l2rt, l2hi, l1hi |
    ...	   | gnb_index  | no | gnb_index, default is 0 |
    ...	   | vdu_index  | no | vdu_index, default is 0 |
    ...    *RETURN VALUE*
    ...    Handle of 'Begin K8s Log', it will be used in 'End K8s Log'
    ...    Example
    ...    Capture in one POD and one container
    ...    | ${handle} | Begin K8s Log |
    ...    | sleep  | 30 |
    ...    | ${log_file} | End K8s Log | handle=${handle}  |  pod_name=up | container_name=l2rt |
    ...    Capture in two POD and two containers
    ...    | ${handle} | Begin K8s Log |
    ...    | sleep  | 30 |
    ...    | ${log_file} | End K8s Log | handle=${handle}  |  pod_name=up | container_name=l2rt |
    ...    | ${log_file2} | End K8s Log | handle=${handle}  |  pod_name=oamcp | container_name=cprt |
    ${alias}   get unique id
    vDU Connect To K8s Master Interactively    vdu_index=${vdu_index}   alias=${alias}   gnb_index=${gnb_index}
   # ${full_pod_name}   Get Full Pod Name By Pod Abbreviation Interactively    pod_abbr=${pod_abbr}   alias=${alias}
   #     ...  gnb_index=${gnb_index}   vdu_index=${vdu_index}
   # ${full_pod_name}    set variable    po-tl175-up-0
    #${full_ctr_name}    Run Keyword If  '${container}'!='all'
    #...   Get Full Container Name By Container Abbreviation   ctr_abbr=${container}   gnb_index=${gnb_index}  vdu_index=${vdu_index}
    Set test variable    ${full_ctr_name}    ctr-tl175-l2rt
    ${remote_file}   get a remote file  ${pod_abbr}_${container}.log     alias=${alias}
    ${unique_id}     get unique id   precise=LOW
    ${local_ute_file}   get a file  ${pod_abbr}_${container}_${unique_id}.log
    ${ns}   Get vDU Namespace From TestLine   gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${function_cmd}=   Run Keyword If  '${container}'=='all'
    ...  set variable  kubectl logs ${full_pod_name} --all-containers=true --since-time=${handle} -n ${ns}
    ...  ELSE  set variable  kubectl logs ${full_pod_name} -c ${full_ctr_name} --since-time=${handle} -n ${ns}
    ${old_timeout}    issh.set_timeout  600   alias=${alias}
    ${cmd}  set variable   ${function_cmd} > ${remote_file}
    ${out}  issh.Execute  command=${cmd}   alias=${alias}
    issh.set_timeout  ${old_timeout}   alias=${alias}
    ${out}  issh.Execute  command=sync  alias=${alias}
    ${out}  issh.downloadfile   remote_path=${remote_file}   local_path=${local_ute_file}   alias=${alias}
    [Return]  ${local_ute_file}

