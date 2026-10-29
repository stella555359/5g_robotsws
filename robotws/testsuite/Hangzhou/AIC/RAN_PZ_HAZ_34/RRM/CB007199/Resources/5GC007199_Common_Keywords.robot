*** Settings ***
Documentation
...    author: Wang Xiaocui
...    contact: xiaocui.wang@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_cu.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_vdu.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_state.robot
Library     taf.analyzer.pcap     WITH NAME    cap
Variables   5GC001200_TestCase_Parameters.py
Resource    ./common_trans.robot
Resource     testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/RRM/Resources/AIC_BTS.robot

Library     taf.gnb.oam.commissioning    WITH NAME    commissioning


*** Variables ***
${SCF_Template_path_DU}     ${commissionings_path}/HGZ/${testline_name}/SCF_0.300_vDU.xml
${SCF_Template_path_CU_TL}  ${commissionings_path}/HGZ/${testline_name}/SCF_0.250_vCU.xml
${SUITE_LOG_PATH}    /home/ute/Downloads/
${TS_LOG_PATH_BASE}    /home/ute/Downloads/
${gnb_index}    0
${sudo}    sudo
${ue_type}    ${tl.ues[0].capabilities[1]}

*** Keywords ***


Power UE Detach with ${ue_type}
    power_ue.UE Detach    ue_index=${0}    ue_type=${ue_type}

Start traffic and check result
    [Arguments]    ${dltp_expected}=540  ${data_send_dl}=560M    ${data_send_ul}=70M
	...             ${ultp_expected}=50    ${tp_direction}=both    ${sleep_time}=1m
    Start traffic according to direction and protocol  data_send_dl=${data_send_dl}    tp_direction=${tp_direction}
    ...            data_send_ul=${data_send_ul}
    ${handle}    vDU Begin K8s Log    ${gnb_index}    ${vdu_index}
    Set test variable    ${handle}
    ${container_prefix}    vDU Get Container Name Prefix
	sleep    60s
	${local_l2rt_file}    vDU End K8s Log      handle=${handle}     pod_abbr=up     container=${container_prefix}l2rt
    ...    gnb_index=${gnb_index}    vdu_index=${vdu_index}
	Set Suite Variable    ${local_l2rt_file}
	${cell_identify}=    Evaluate     16384*${tl.gnbs[0].instance_id}+1
    ${cell_identify}   convert to string   ${cell_identify}
    @{list_of_cell}     Create List         ${cell_identify}
    Set Suite Variable     @{list_of_cell}
    ${all_tput}    Check throughput according to direction and protocol    dltp_expected=${dltp_expected}
    ...    tp_direction=${tp_direction}    ultp_expected=${ultp_expected}     cells=@{list_of_cell}
    Stop traffic according to direction and protocol   tp_direction=${tp_direction}
    [Return]     ${all_tput[0]['average']}


Check throughput for UL-direction
    [Arguments]    ${dltp_expected}    ${cells}    ${ultp_expected}=58    ${tp_direction}=both
	${all_tp}    Run keyword and continue on failure    power_ue.Check Tput
    ...    ue_type=${ue_type}    direction=UL    log=${local_l2rt_file}    cells=${cells}
    ...    target_throughput=${ultp_expected}    actCarrierAggregation=${False}
    ...    target_avg_percent=0.95    min_percent=0.75
	Set Test Variable    ${all_tp}    ${all_tp}

Check throughput for DL-direction
    [Arguments]    ${dltp_expected}    ${cells}    ${ultp_expected}=58    ${tp_direction}=both
	${all_tp}    Run keyword and continue on failure    power_ue.Check Tput
    ...    ue_type=${ue_type}    direction=DL    log=${local_l2rt_file}    cells=${cells}
    ...    target_throughput=${dltp_expected}    actCarrierAggregation=${False}
	Set Test Variable    ${all_tp}    ${all_tp}

Check throughput according to direction and protocol
    [Arguments]    ${dltp_expected}    ${cells}    ${ultp_expected}=58    ${tp_direction}=both
    log to console      Check throughput
#	${log}    Run keyword and continue on failure    power_ue.Collect Tput
#	...    ue_type=${ue_type}    duration=2m    filter=L2Lo
	Set Suite Variable     ${local_l2rt_file}
    Run keyword if    '${tp_direction}'=='dl'    Run keyword and continue on failure    Check throughput for DL-direction
    ...       dltp_expected=${dltp_expected}    tp_direction=${tp_direction}    ultp_expected=${ultp_expected}     cells=${cells}
    Run keyword if    '${tp_direction}'=='ul'    Run keyword and continue on failure    Check throughput for UL-direction
    ...       dltp_expected=${dltp_expected}    tp_direction=${tp_direction}    ultp_expected=${ultp_expected}     cells=${cells}
    [Return]     ${all_tp}

Start traffic according to direction and protocol
    [Arguments]  ${data_send_dl}    ${data_send_ul}=60M     ${tp_direction}=both
    log to console      Start traffic

    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    power_ue.Start traffic    ue_index=${0}
    ...    direction=ul    throughput=${data_send_ul}    duration=1400    ue_type=${ue_type}    iperf_type=via_command
    ...    protocol=${protocol}    data_amount=2M
    sleep    1s
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'   power_ue.Start traffic    ue_index=${0}
    ...     direction=dl    throughput=${data_send_dl}    duration=1400    ue_type=${ue_type}    seg_size=${seg_size}    protocol=${protocol}
	...    process_num=${process_num}    window=32M
    sleep    20s


Stop traffic according to direction and protocol
    [Arguments]  ${tp_direction}=both
    log to console      Stop traffic
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    power_ue.Stop traffic    direction=ul
    ...    ue_index=${0}    ue_type=${ue_type}    iperf_type=via_command    protocol=tcp
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'      power_ue.Stop traffic    direction=dl
    ...     ue_index=${0}    ue_type=${ue_type}    protocol=tcp

Start L2RT Log
    ${handle}    vDU Begin K8s Log    ${gnb_index}    ${vdu_index}
    Set test variable    ${handle}
    ${container_prefix}    vDU Get Container Name Prefix




CU SCF Modification and Commission
    [Arguments]    ${scf_file_path}    ${scf_parameters_list}
	${output_scf_file_path}    COAM Modify scf file    scf_file_path=${scf_file_path}    scf_parameters_list=${scf_parameters_list}
	CU Full Commission Fix Error    path_of_commission_file=${output_scf_file_path}

DU SCF Commission
    Cloud DU connect to gnb coam via ssl
    COAM Commission with scf file    scf_file_path=${SCF_Template_path_DU}    is_pdl_checking_needed=${False}
    [Teardown]    COAM Teardown gnb connections


Testcase teardown
     Run Keyword And Ignore Error    Stop Tcpdump from CPIF    connection=CPIF
	 Run Keyword And Ignore Error    CU Full Commission
	 ...    path_of_commission_file=${SCF_Template_path_CU_TL}     plan_name=CU_SCF    gnb_index=${gnb_index}
     Run Keyword And Ignore Error    DU SCF Commission

CU SCF Modification and Commission-vran20
    [Arguments]    ${SCF_Template_path_CU_TL}
	CU Rest Login    gnb_index=${gnb_index}
	CU Full Commission    path_of_commission_file=${SCF_Template_path_CU_TL}    plan_name=CU_SCF    gnb_index=${gnb_index}

Check vDU PM Counter Result
    [Arguments]    ${counter_id}    ${dimension_dist_name}    ${expect_counter_value}    ${vdu_index}=0
    ${counter_result}    vDU Get PM Counter Values    ${counter_id}    ${dimension_dist_name}    ${vdu_index}
    ${len}    Get Length    ${counter_result}
    @{counter_value_list}=    create list
    FOR  ${i}  IN RANGE  ${len}
        ${temp_dic}    Set Variable   ${counter_result[${i}]}
        ${temp_value}   Get From Dictionary    dictionary=${temp_dic}    key=value
        ${counter_value}    Convert To Integer    ${temp_value}
        append to list   ${counter_value_list}   ${counter_value}
    END
    Sort List   ${counter_value_list}
    ${counter_max}    Convert To Integer    ${counter_value_list[-1]}
    ${Scheduled_UE_num}    Set Variable    ${expect_counter_value}
    ${real_numUEs}    Convert To Integer    ${Scheduled_UE_num}
    Should Be True   ${counter_max}>=${real_numUEs}

vDU Get PM Counter Values
    [Arguments]   ${counter_id}   ${dimension_dist_name}  ${vdu_index}=0
    [Documentation]    Get latest counter value from webUI via rest API.
    ...    firstly, using restapi to get the counter whole info, then get the latest value
    ...    | Input Parameters | Man. | Description |
    ...    | counter_id | Yes | PM counter ID |
    ...    | dimension_dist_name | Yes | the dimension dist name that the counter belongs to, like MRBTS-2072/NRBTS-2072/NRCELL-1/NCELA |
    ...    | vdu_index | No |  vdu index to indicate which vdu will be used, 0 in default  |
    ...    *RETURN VALUE*
    ...    List of counter value
    vDU Rest Login    vdu_index=${vdu_index}
    ${counter_id} =    Replace String    ${counter_id}   ${SPACE}   ${EMPTY}
    ${counter_list}=  vdu.get_counter_values    ${counter_id}   ${dimension_dist_name}
    [return]    ${counter_list}
    [Teardown]   vDU Rest Logout   vdu_index=${vdu_index}

OAM Precondition Cell Should Be Onair
    [Documentation]    Do some common thing for every precondition of cases
    ...    any case should include it in test case setup
    ...    it will do following actions
    ...    1) check cell should be onair
    ...    2) initial global test varible
    ...
    ...    *AUTHOR* xianbiao.cheng@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   14.1.2022,chris.l.cao@nokia-sbell.com, remove 'CU Get Cells ID list' to save cell id information
    ...   22.1.2022,chris.l.cao@nokia-sbell.com, remove unused variable ${BACKUP_SCF_PATH_ON_CU} to shorten dryrun time
    ...
    log to console  \n*** OAM Precondition Cell Should Be Onair ... ***
    set_vdu_pod_container_suite_variables
    ${nf_type}  Get VCU NF Type
    Run Keyword If   "${nf_type}"=="VNF"     CU Verify All VMs Are Online

    All DUs Container Status Should Be Normal
    #CU Verify All Cells Status Are Onair
    vDU Verify All Cells Status Should Be Onair For All DUs

    ${ACTIVE_ALARM_LST_PRE_CU}=  run keyword and continue on failure  CU Get Active Alarms
    ${HISTORICAL_ALARM_LST_PRE_CU}   run keyword and ignore error   CU Get Historical Alarms
    set test variable  ${ACTIVE_ALARM_LST_PRE_CU}
    set test variable  ${HISTORICAL_ALARM_LST_PRE_CU}
    set test variable  ${ACTIVE_ALARM_LST_PRE_DU}       tbd
    set test variable  ${ACTIVE_ALARM_LST_PRE_FHGW}     tbd


Delete Delta Plan MO
    [Arguments]  ${plan_id}   ${mo_dn}    ${timeout}=60
    [Documentation]   Delete Delta Plan MO
    ...   *AUTHOR* zhaori.deng@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_id    | yes | plan_id |
    ...   | mo_dn      | yes | mo_dn   |
    ...   | timeout    | no | timeout, default is 60, unit is second   |
    ...
    ...   *RETURN VALUE*
    ...    status dictionary of operation, its content as below,
    ...    {'status': 'success', 'error_message': None, 'revision': '1594282403383843372',
    ...     'links': None, 'action_id': 'a_0b884e65-83a3-445c-a1ff-1fadc26cd767'  }
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | ${validation_id} | Delete Delta Plan MO | plan_id=<my_plan_id> | mo_dn=MRBTS-5233/TNLSVC-1/TNL-1/IPNO-1/PINGREQ-1 |
    ...
    ${timeout}   convert to integer  ${timeout}
    ${out}  vdu.delete_mo_of_delta_plan   delta_plan_id=${plan_id}  mo_dn=${mo_dn}   timeout=${timeout}
    ${action_id}  set variable  ${out["action_id"]}
    ${out}     Delete Delta Plan MO Should Be Successful   plan_id=${plan_id}   action_id=${action_id}
    [Return]  ${out}

Delete Delta Plan MO Should Be Successful
    [Arguments]  ${plan_id}   ${action_id}
    [Documentation]   Delete Delta Plan MO Should Be Successful
    ...   *AUTHOR* zhaori.deng@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | operation_id    | yes | operation_id |
    ...   | plan_id         | yes | plan_id |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Delete Delta Plan MO Should Be Successful | plan_id=<my_plan_id> | operation_id=<my_operation_id> |
    ...
    ${rtn}  wait until keyword succeeds  20   2
    ...   _Delete Delta Plan MO Should Be Expected   plan_id=${plan_id}   action_id=${action_id}   expected_status=success
    [Return]  ${rtn}

_Delete Delta Plan MO Should Be Expected
    [Arguments]   ${plan_id}   ${action_id}   ${expected_status}
    [Documentation]    _Delete Delta Plan MO Should Be Expected
    ...   *AUTHOR* zhaori.deng@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | expected_status | yes | expected_status |
    ...   | plan_id         | yes | plan_id |
    ...   | action_id    | yes | action_id |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | _Delete Delta Plan MO Should Be Expected | plan_id=<my_plan_id> | action_id=<my_action_id> | expected_status=success |
    ...
    ${out}   vdu.get_deleting_mo_action_state_of_delta_plan      delta_plan_id=${plan_id}  action_id=${action_id}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}

DU SCF Modification and Commission
    [Arguments]    ${scf_file_path}    ${scf_parameters_list}  ${gnb_index}=${0}
	${output_scf_file_path}    COAM Modify scf file    scf_file_path=${scf_file_path}    scf_parameters_list=${scf_parameters_list}
    vDU Full Commission SCF Fix Error    path_of_commission_file=${output_scf_file_path}


vDU Get last PM Counter Values
    [Arguments]    ${counter_id}    ${dimension_dist_name}      ${vdu_index}=0
    ${counter_result}    vDU Get PM Counter Values    ${counter_id}    ${dimension_dist_name}    ${vdu_index}
    ${len}    Get Length    ${counter_result}
    @{counter_value_list}=    create list
    FOR  ${i}  IN RANGE  ${len}
       ${temp_dic}    Set Variable   ${counter_result[${i}]}
       ${temp_value}   Get From Dictionary    dictionary=${temp_dic}    key=value
       ${counter_value}    Convert To Integer    ${temp_value}
       append to list   ${counter_value_list}   ${counter_value}
    END
    ${counter_value}    Convert To Integer    ${counter_value_list[-1]}
    [return]    ${counter_value}

Make UE Detach
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${UE_TYPE}
    power_ue.UE Detach    ue_index=${0}    ue_type=${ue_type}

Check throughput
    [Arguments]   ${ultarget_throughput}   ${dltarget_throughput}   ${gnb_index}=0     ${vdu_index}=0
    log to console      Check throughput
	${handle}    vDU Begin K8s Log    ${gnb_index}    ${vdu_index}
    Set test variable    ${handle}
    ${container_prefix}    vDU Get Container Name Prefix
	sleep    80s
	${log}    vDU End K8s Log      handle=${handle}     pod_abbr=up     container=${container_prefix}l2rt
    ...    gnb_index=${gnb_index}    vdu_index=${vdu_index}
	Set Suite Variable    ${log}
    ${cell_identify}=    Evaluate     16384*${tl.gnbs[0].instance_id}+1
    ${cell_identify}   convert to string   ${cell_identify}
    @{list_of_cell}     Create List         ${cell_identify}
	Set Suite Variable     @{list_of_cell}
	${all_tp}    Run keyword and continue on failure    power_ue.Check Bi Tput
	...    ue_type=${ue_type}    log=${log}     cells=@{list_of_cell}
    ...    ultarget_throughput=${ultarget_throughput}    dltarget_throughput=${dltarget_throughput}
    ...    target_avg_percent=0.95    min_percent=0.75
	Set Test Variable    ${all_tp}    ${all_tp}
    [Return]   ${all_tp[1][0]['average']}    ${all_tp[0][0]['average']}

vDU Full Commission SCF Fix Error
    [Arguments]     ${path_of_commission_file}     ${vdu_index}=0
    [Documentation]   vCU commission
    log to console   \n*** Start vDU commission ***
    vDU Rest Login
    Check Maximum Plan Number And Delete One If Reach Maximum Number
    vDU Load And Active SCF   ${path_of_commission_file}
    [Teardown]    run keyword and ignore error   vDU Logout

vDU Load And Active SCF
    [Arguments]     ${path_of_commission_file}   ${retries}=1
    [Documentation]   load SCF and active SCF
    ${upload_plan_response}=  vdu.upload_plan    ${path_of_commission_file}
    Upload Plan Status Should Be Successful  operation_id=${upload_plan_response['action_id']}
    ${fix_err_response}=   vdu.fix_vdu_staged_plan_error    ${upload_plan_response['plan_id']}
    wait until keyword succeeds  30s  10s  Fix vDU SCF Validation Errors Should Be Successful
    ...    ${upload_plan_response['plan_id']}  ${fix_err_response['action_id']}
    ${temp_validation_id}   Validate Plan By REST  plan_id=${upload_plan_response['plan_id']}   retries=${retries}
    ${out}   Activate Staged Plan By REST   plan_id=${upload_plan_response['plan_id']}

Fix vDU SCF Validation Errors Should Be Successful
    [Arguments]  ${plan_id}  ${action_id}
    ${fix_err_response}=   vdu.get_fix_vdu_staged_plan_operation_status  ${plan_id}  ${action_id}
    should be equal as strings  ${fix_err_response['status']}  success
    log to console    Fix SCF Errors Success

CU Full Commission Fix Error
    [Arguments]    ${path_of_commission_file}    ${gnb_index}=0
    [Documentation]   vCU commission
    log to console   \n*** Start vCU commission ***
    CU Login  ${gnb_index}
    vCU Load And Active SCF   ${path_of_commission_file}
    [Teardown]    run keyword and ignore error   CU Logout

vCU Load And Active SCF
    [Arguments]     ${path_of_commission_file}    ${wait_active}=${True}
    ${upload_operation_info}=   cu.upload_plan_file     ${path_of_commission_file}
    wait until keyword succeeds    60s   5s  CU Check Plan Upload Status Should Be As Expected
    ...    ${upload_operation_info["action_id"]}    success
    ${fix_err_operation}=   cu.fix_plan_validation_errors    ${upload_operation_info['plan_id']}
    ...   add_missing_objects=${True}   fix_mandatory_parameters=${True}
    sleep   60s
    ${validate_operaition_info}=  cu.plan_validation    ${upload_operation_info["plan_id"]}
    wait until keyword succeeds    60s   5s  CU Check Plan Validate Status Should Be As Expected
    ...    ${upload_operation_info["plan_id"]}   ${validate_operaition_info["action_id"]}    success
    ${activate_operaition_info}=  cu.plan_activation   ${upload_operation_info["plan_id"]}
    run keyword if    ${wait_active}==${True}    wait until keyword succeeds    600s   30s  CU Check Plan Activate Status Should Be As Expected
    ...    ${upload_operation_info["plan_id"]}  ${activate_operaition_info["id"]}    success

X2 Link Should be UnLock
    [Arguments]    ${expected_value}=unlocked
    #AIC_BTS.CU Rest Login    gnb_index=${gnb_index}
    CU Login
    wait until keyword succeeds  300s  10s    Check X2 link Operation Should Be Successful    expected_value=${expected_value}
    [Teardown]    Run keyword and ignore error    CU Logout
