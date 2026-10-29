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
Library    testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/RRM/CB008610-AD/Resources/pucch_resource_counter.py

#Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
#Resource     testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/RRM/CB007199/Resources/5GC007199_Common_Keywords.robot
#Resource     testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/RRM/Resources/AIC_BTS.robot


*** Variables ***
${MRBTS_ID}    ${tl.gnbs[0].dus[0].instance_id}
${NRBTS_ID}    ${tl.gnbs[0].dus[0].instance_id}
${dist}    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
#${cell_identify0}=    Evaluate     16384*${tl.gnbs[0].dus[0].instance_id}+1
#${cell_identify1}=    Evaluate     16384*${tl.gnbs[0].dus[0].instance_id}+2
#${cell_identify0}   convert to string   ${cell_identify0}
#${cell_identify1}   convert to string   ${cell_identify1}
#${list_of_cell_ids0}    184680449
#${list_of_cell_ids1}    184680450



*** Keywords ***
Online Modify 7922 Parameters_false
    log to console   \n*** Online Modify 7922 Parameters ***
    vDU Login
    &{modify_parameter_dict}    Create Dictionary
    &{1849_modify_parameter_dict}    Create Dictionary    actPerCsiReportBundlingTddFr1=false
    FOR    ${para_name}    IN    @{1849_modify_parameter_dict}
        ${value}=    Online Get VDU Parameter Value1    ${dist}    ${para_name}
        run keyword if    "${value}" != "${1849_modify_parameter_dict}[${para_name}]"
        ...    Set to Dictionary    ${modify_parameter_dict}    ${para_name}    ${1849_modify_parameter_dict}[${para_name}]
    END
    log to console   \n*** Modify Parameters ***
    Run Keyword If  &{modify_parameter_dict} != &{Empty}    Modify 1849 Parameters
    ...    dist=${dist}   updated_paras_dict=${modify_parameter_dict}    wait_vdu_up=True
    [Teardown]    Run Keyword And Ignore Error    vDU Logout

Online Modify 7922 Parameters_true
    log to console   \n*** Online Modify 7922 Parameters ***
    vDU Login
    &{modify_parameter_dict}    Create Dictionary
    &{1849_modify_parameter_dict}    Create Dictionary    actPerCsiReportBundlingTddFr1=true
    FOR    ${para_name}    IN    @{1849_modify_parameter_dict}
        ${value}=    Online Get VDU Parameter Value1    ${dist}    ${para_name}
        run keyword if    "${value}" != "${1849_modify_parameter_dict}[${para_name}]"
        ...    Set to Dictionary    ${modify_parameter_dict}    ${para_name}    ${1849_modify_parameter_dict}[${para_name}]
    END
    log to console   \n*** Modify Parameters ***
    Run Keyword If  &{modify_parameter_dict} != &{Empty}    Modify 1849 Parameters
    ...    dist=${dist}   updated_paras_dict=${modify_parameter_dict}    wait_vdu_up=True
    [Teardown]    Run Keyword And Ignore Error    vDU Logout

Modify 1849 Parameters
    [Arguments]    ${dist}   ${updated_paras_dict}    ${wait_vdu_up}=False
    ${uni_id}   Get Unique Id
	${delta_plan_name}    get unique id    prefix=TA_delta_plan    precise=LOW
	log to console   \n*** Generate Delta Plan ***
	${plan_id}    ${action_id}    Generate Delta Plan    plan_name=${delta_plan_name}    plan_description=TA
	log to console   \n*** Update Delta Plan Parameter ***
	Update Delta Plan Parameter   plan_id=${plan_id}   mo_dn=${dist}   updated_paras_dict=${updated_paras_dict}
	...    operation=replace
    log to console   \n*** Validate Delta Plan By REST ***
    Validate Delta Plan By REST   ${plan_id}
    ${scf_path}  Get A Directory  SCF
    ${delta_filename}  Set Variable   add_route_${uni_id}.xml
    log to console   \n*** Save Delta Plan File ***
    ${delta_scf_fullpath}   vdu.Save Delta Plan File   local_path=${scf_path}   local_filename=${delta_plan_name}
    log to console   \n*** Activate Delta Plan By REST ***
    Activate Delta Plan By REST   ${plan_id}   wait_vdu_up=${wait_vdu_up}

OAM Precondition Cell Should Be Onair
    wait until keyword succeeds    600   30   vDU Verify All Cells Status Should Be Onair

Online Get VDU Parameter Value1
    [Arguments]    ${mo_dn}    ${para_name}    ${timeout}=60
    ${timeout}   convert to integer  ${timeout}
    ${out}  vdu.search_parameter_of_current_plan   mo_dn=${mo_dn}   para_name=${para_name}   timeout=${timeout}
    [Return]  ${out}

Test Case Setup
    ${START_TIME}=    Get time    exclude_millis=yes
    Set Suite Variable    ${START_TIME}

Start DL UL Traffic
    [Arguments]    ${dl_tput}    ${ul_tput}
    #power_ue.UE Attach     ue_index=${0}    ue_type=${ue_type}
    power_ue.Start traffic    ue_index=${0}    direction=dl    throughput=${dl_tput}    duration=600
    ...    ue_type=${ue_type}   process_num=1
    power_ue.Start traffic    ue_index=${0}    direction=ul    throughput=${ul_tput}    duration=600
	...    ue_type=${ue_type}   iperf_type=via_command   data_amount=2M
	sleep    5s

Check Tput Result
    [Arguments]    ${dltarget_throughput}    ${ultarget_throughput}    ${actCarrierAggregation}=${True}
    log to console    \n*** Check Tput Result ***
    ${list_of_cell_ids0}    Create List    184680449
    ${list_of_cell_ids1}    Create List    184680450
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

Stop DL UL Traffic
    log to console      \n*** Stop traffic ***
    power_ue.Stop traffic    direction=ul    ue_index=${0}    ue_type=${ue_type}    iperf_type=via_command
    power_ue.Stop traffic    direction=dl    ue_index=${0}    ue_type=${ue_type}

check pucch_resource_num
    [Documentation]    Author: Yan Meng
    ...                Description: Verify pucch-Resource
    [Arguments]    ${pcap_file}
    ${filtered_packets}=    Load pcap with filter    pcap_file=${pcap_file}    filter_expression=${filter_expression}
    ${pucch_Resource}=    Get field value    packets=${filtered_packets}    field_name=${field_name}
    ${resource_num}=    pucch resource num    ${pucch_Resource}
    [Return]  ${resource_num}

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
    ${full_ctr_name}    Run Keyword If  '${container}'!='all'
    ...   Get Full Container Name By Container Abbreviation   ctr_abbr=${container}   gnb_index=${gnb_index}  vdu_index=${vdu_index}
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

Test Case Teardown
     Run Keyword And Ignore Error    Stop DL UL Traffic
     Run Keyword And Ignore Error    power_ue.UE Detach     ue_index=${0}    ue_type=${ue_type}
     Run Keyword And Ignore Error    Stop and download X2 Logs on eNB    x2_log_name=710_A01_ENB.pcap
     #Run Keyword And Ignore Error    CI_interface.Common Case Teardown