*** Settings ***
Documentation
...   author: di.yang@nokia-sbell.com
...   contact: di.yang@nokia-sbell.com
...   Description: Common Keyword

Library    ./attenuator_keywords.py
Library    taf.hw.fhgw.cli                       WITH NAME    issh
Library    taf.selenium.gnb.oam.coam.cu          WITH NAME    scu
Library    taf.gnb.oam.coam.cu.interface.cu      WITH NAME    cu
Library    taf.gnb.oam.coam.vdu.interface.Vdu    WITH NAME    vdu
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/traffic.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_vdu.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Commercial_mobile_phone_adb_common_keywords.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/gnb_classical_hangzhou.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/Cloud/Cloud_Setup_and_Teardown.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_vdu.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_throughput.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/basic/simple_ue.robot
Variables  ./att_port_mapping.py

*** Variables ***
${BTSID}      BTS-${tl.gnbs[0].cu.instance_id}
${UE_TYPE}    ${tl.ues[0].capabilities[-1]}

*** Keywords ***
Get ALL Suite Variables on VCU
    Set Suite Variable   ${LOCAL_MRBTS_ID}   ${mrbts_id}
    Set Suite Variable   ${LOCAL_NRBTS_ID}   ${nrbts_id}
    Set Suite Variable   ${LOCAL_MRBTS}   MRBTS-${LOCAL_MRBTS_ID}
    Set Suite Variable   ${LOCAL_NRBTS}   NRBTS-${LOCAL_NRBTS_ID}
    Set Suite Variable   ${LOCAL_INSID}   ${LOCAL_MRBTS}/${LOCAL_NRBTS}
    ${dn_local_nrcellidentity}    Set Variable   ${LOCAL_INSID}/NRCELL-1
    ${2ndcell_local_nrcellidentity}    Set Variable   ${LOCAL_INSID}/NRCELL-2
    Set Suite Variable   ${CU_PCELL_DN}   ${dn_local_nrcellidentity}
    Set Suite Variable   ${DU_PCELL_DN}   ${dn_local_nrcellidentity}
    Set Suite Variable   ${CU_PCELL_DN_2NDCELL}   ${2ndcell_local_nrcellidentity}
    Set Suite Variable   ${DU_2_MRBTS_ID}   ${tl.gnbs[0].dus[1].instance_id}
    Set Suite Variable   ${DU_2_MRBTS}   MRBTS-${DU_2_MRBTS_ID}
    Set Suite Variable   ${DU_2_NRBTS}   NRBTS-${nrbts_id}
    Set Suite Variable   ${DU_2_INSID}   ${DU_2_MRBTS}/${DU_2_NRBTS}
    Set Suite Variable   ${DU_2_CELL_DN}   ${DU_2_INSID}/NRCELL-2
    [Teardown]   Run Keyword And Ignore Error   CU Rest Logout

Connect to vdu via rest api
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${connection}=OAM_gnb${gnb_index}_du${du_index}
    vdu.connect_to    host=${tl.gnbs[${gnb_index}].dus[${du_index}].oam_http_connection_details.addr}
    ...    port=${EMPTY}    username=${tl.gnbs[${gnb_index}].dus[${du_index}].oam_http_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].dus[${du_index}].oam_http_connection_details.password}
    ...    secure=${True}    connection_name=${connection}
    [Return]  ${connection}

Connect to vcu via rest api
    [Arguments]  ${gnb_index}=${0}    ${connection}=OAM_CU${gnb_index}
    cu.connect to    host=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...    port=${EMPTY}
    ...    username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...    secure=${True}
    ...    alias=${connection}
    [Return]  ${connection}

_build connection with cloud cu or du
    [Documentation]    use to create oam connection with cu or du according to bts_type
    ...    bts_type  :  cloud gnb, value should be cu or du
    [Arguments]    ${bts_type}
    ...            ${gnb_index}=${0}    ${vdu_index}=${0}
    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    ${connection}=     Run keyword if   '${bts_type}'=='du'   Connect to vdu via rest api
    ...    gnb_index=${gnb_index}    du_index=${vdu_index}    connection=vdu_oam_conn_${timestamp}
    ...    ELSE       Connect to vcu via rest api
    ...    gnb_index=${gnb_index}       connection=vcu_oam_conn_${timestamp}
    [Return]    ${connection}

_Calculate Counter Total Value
    [Documentation]    hanle counter result returned through webem
    ...  Counte values in the counter dict
    ...  return result:  {'start_time': '2024-03-06T14:40:00+08:00', 'value': '1'}
    ...  Note: here start_time is the last time got from webem, match with original dictionary key.
    [Arguments]     ${dict_counter_values}
    ${temp_dic_1}    set variable   ${dict_counter_values[-1]}
    ${temp_dic_2}    set variable   ${dict_counter_values[-2]}
    ${temp_value_1}   Get From Dictionary    dictionary=${temp_dic_1}    key=value
    ${temp_value_2}   Get From Dictionary    dictionary=${temp_dic_2}    key=value
    ${counter_total_value}   evaluate     ${temp_value_1}+${temp_value_2}
    ${counter_last_timestamp}   Get From Dictionary    dictionary=${temp_dic_1}    key=start_time
    ${counter_total_value}    convert to string     ${counter_total_value}
    ${dict_counter_check_result}    create dictionary   start_time=${counter_last_timestamp}
    ...    value=${counter_total_value}
    [Return]   ${dict_counter_check_result}

Get Counter Value From Cloud gNB WebEM
    [Arguments]    ${counter_info}    ${bts_type}    ${oam_connection}
    [Documentation]    Get latest counter value from webUI via rest API.
    ...    | Input Parameters | Man. | Description |
    ...    | counter_info | Yes | ${M55118C09502}    create dictionary      counter_id=value    dimension_dn=value
    ...    | bts_type     | Yes |  cloud gnb, value should be cu or du  |
    ...    | Return Value | Description |
    ...    | ${counter_value} |  |

    ${counter_value_from_webem}=    Run keyword if   '${bts_type}'=='du'    vdu.get_counter_values
    ...     counter_id=${counter_info}[counter_id]
    ...     dimension_dn=${counter_info}[dimension_dn]
    ...     vdu_connection=${oam_connection}
    ...     ELSE         cu.get_counter
    ...     measurement_id=${None}
    ...     dimension_dist_name=${counter_info}[dimension_dist_name]
    ...     counter_id=${counter_info}[counter_id]
    ...     connection=${oam_connection}

    should not be empty    ${counter_value_from_webem}
    ${counter_values}=     Run keyword if   '${bts_type}'=='cu'
    ...       set variable    ${counter_value_from_webem["values"]}
    ...     ELSE      set variable       ${counter_value_from_webem}

    ${values_len}    Get Length    ${counter_values}
    Should Be True     ${values_len}>0

    ${dict_counter_check_result}=   _Calculate Counter Total Value  dict_counter_values=${counter_values}
    [Return]    ${dict_counter_check_result}

Compare Counters to Expect Value
    [Documentation]    list_counters : dictionary object for each counter, one example as following
    ...            ${M55184C00019}    create dictionary      counter_id=value    dimension_dist_name=value
    ...            expect_value=value
    ...    gnb_index : default value is ${0}
    ...    vdu_index : default value is ${0}
    ...    bts_type  :  cloud gnb, value should be cu or du
    [Arguments]      ${list_counters}   ${bts_type}    ${gnb_index}=${0}   ${vdu_index}=${0}   ${verify}=equal
    ${counter_num}    Get Length    ${list_counters}
    Should be True   ${counter_num}

    ${oam_connection}=    _build connection with cloud cu or du   bts_type=${bts_type}
    ...      gnb_index=${gnb_index}    vdu_index=${vdu_index}

    @{counter_list}   create list
    FOR  ${i}  IN RANGE  ${counter_num}
       ${counter_info}    set variable   ${list_counters[${i}]}
       ${counter_check_result}=   Get Counter Value From Cloud gNB WebEM
       ...     bts_type=${bts_type}
       ...     counter_info=${counter_info}
       ...     oam_connection=${oam_connection}
       Append to list  ${counter_list}     ${counter_check_result}
       ${expect_value}     convert to string     ${counter_info['expect_value']}
       ${counter_final_value}    set variable   ${counter_check_result['value']}
       ${counter_final_value}    convert to string     ${counter_final_value}
       Run Keyword And Continue On Failure    Run Keyword If   "${verify.lower()}"=="equal"    should be equal
       ...     ${counter_final_value}   ${expect_value}  ELSE    should be true  ${counter_final_value}>${expect_value}
    END
    [Return]    ${counter_list}
    [Teardown]    Run keyword if   '${bts_type}'=='du'     vdu.disconnect    vdu_connection=${oam_connection}
    ...     ELSE        cu.disconnect    connection=${oam_connection}

Get wait value minutes
    [Arguments]    ${interval}
    ${interval_seconds}    Get Interval Seconds    ${interval}
    ${origin_time}    Get Time    epoch
    ${wait_time}    evaluate    ${interval_seconds}-${origin_time}%${interval_seconds}
    [Return]    ${wait_time}

Wait for New Interval BTS counters Generate
    [Arguments]  ${interval}     ${guardtime}=30
    ${wait_time}    Get wait value minutes    ${interval}
    sleep    ${wait_time}
    sleep    ${guardtime}

New Get Commercial UE IP with first UE
    [Documentation]    get UE IP
    ...    :param  command: common which to get UE IP
    [Arguments]    ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...   ${command}=adb -s ${serial_number} shell ip -f inet addr |grep inet |grep -v ims00 | cut -d '/' -f 1 |tail -n -1 |head -1 |awk '{print $2}'
    sleep   5s
    csn.send_command    command=${command}
    ...    connection=cygwin
    ${UE_IP}=    csn.Read Output    connection=cygwin
    ${UE_IP}=    Strip String    ${UE_IP}
    Should not be empty  ${UE_IP}    msg=No UE IP after attach
    log to console    \n attached ip of ue_${ue_index}:${UE_IP}
    Set Suite Variable    ${UE_IP}    ${UE_IP}
    [Teardown]    csn.disconnect      connection=cygwin

New Get Commercial UE IP
    [Arguments]    ${ue_index}=${0}   ${capabilities}=${tl.ues[${ue_index}].capabilities[-1]}
    ...    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc via cygwin    ue_index=${ue_index}
    run keyword if
    ...    '${capabilities}'=='HUAWEI_MATE30PRO' or '${capabilities}'=='xiaomi' or '${capabilities}'=='samsungS21'
    ...    New Get Commercial UE IP with first UE    ue_index=${ue_index}
    ...    command=adb -s ${serial_number} shell ip -f inet addr |grep inet | grep -v ims00 | cut -d '/' -f 1 |tail -n -2 |head -1 |awk '{print $2}'
    ...    ELSE IF    '${capabilities}'=='samsung'
    ...    New Get Commercial UE IP with first UE    ue_index=${ue_index}
    ...    command=adb -s ${serial_number} shell ip -f inet addr |grep "scope global" | cut -d '/' -f 1 |head -n 1|awk '{print $2}'
    ...    ELSE    New Get Commercial UE IP with first UE    ue_index=${ue_index}

New Preparation and execution for andriod UE Attach
    [Documentation]    UE attach, make Commercial is on Airplane mode in default before, then Determine if UE has
    ...    attached to confirm whether the button was clicked once or twice
    ...    :param  UE_type: UE type
    ...    :param  ue_index: The list index from tl.ues[]
    [Arguments]    ${UE_type}=${brand}    ${ue_index}=${0}    ${retry}=${2}
    ...    ${hostname}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    ${home}=${home}    ${airplane}=${airplane}    ${close_task}=${close_task}
    FOR   ${index}    IN RANGE    ${retry+1}
        run keyword if    ${index}==${retry}    Commercial_mobile_phone_adb_common_keywords.Andriod UE adb reboot
        ...    ue_index=${ue_index}
        ${passed} =    Check airplane mode status on    ue_index=${ue_index}
        run keyword if    '${passed}'=='${True}'
        ...    Run Keywords    Connect to control pc via cygwin    hostname=${hostname}    ue_index=${ue_index}    AND
        ...    Commercial UE click AIRPLANE once    Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
        ...    close_task=${close_task}    AND
        ...    Log to console    INFO:click AIRPLANE once for ${UE_type} UE attach.    AND
        ...    Andriod UE adb enable data services    ue_index=${ue_index}    AND
        ...    sleep  60s    AND    Run Keyword And Ignore Error
        ...    New Get Commercial UE IP    ue_index=${ue_index}    AND
        ...    Compare UE IP if is assigned on for loop    AND
        ...    Exit For Loop If    '${compare}'=='${True}'
        ...    ELSE
        ...    Run Keywords    Connect to control pc via cygwin    hostname=${hostname}    ue_index=${ue_index}    AND
        ...    Commercial UE click AIRPLANE twice    Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
        ...    close_task=${close_task}    AND
        ...    Log to console    INFO:click AIRPLANE twice for ${UE_type} UE attach.    AND
        ...    Andriod UE adb enable data services    ue_index=${ue_index}    AND
        ...    sleep  30s    AND    Run Keyword And Ignore Error
        ...    New Get Commercial UE IP    ue_index=${ue_index}    AND
        ...    Compare UE IP if is assigned on for loop    AND
        ...    Exit For Loop If    '${compare}'=='${True}'
    END
    should be true    ${compare}    msg=UE attach failed with no IP success assigned!!!

New UE Attach
    [Arguments]    ${ue_type}    ${ue_index}    ${retry}=${2}
    [Documentation]    Attach UE for L3 call test.
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for attach
    ...  :param  retry: retry times for ue attach.
    New Preparation and execution for andriod UE Attach    ue_index=${ue_index}    retry=${retry}    UE_type=${ue_type}
    Log    click Airplane mode switch to disable its function so that make UE attach

Collect Tput and check result
    [Arguments]    ${gnb_index}=0     ${vdu_index}=0
    ${handle}    vDU Begin K8s Log    ${gnb_index}    ${vdu_index}
    Set test variable    ${handle}
    ${container_prefix}    vDU Get Container Name Prefix
	sleep    60s
	${tput_log}    vDU End K8s Log      handle=${handle}     pod_abbr=up     container=${container_prefix}l2rt
    ...    gnb_index=${gnb_index}    vdu_index=${vdu_index}
	Set Suite Variable    ${tput_log}

New Check Tput
#    [Arguments]    ${cells}    ${ue_type}=${UE_TYPE}
    Run Keyword And Continue On Failure     Collect Tput and check result

UE attach with ULDL traffic
    [Arguments]    ${ue_type}=${UE_TYPE}    ${ue_index}=${0}    ${dl_throughput}=300M
    ...            ${ul_throughput}=30M    ${duration}=600
    ...            ${ui_version}=S21UI3.1
    Run Keyword And Continue On Failure    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    ...    ui_version=${ui_version}
    power_ue.UE Detach    ue_type=${ue_type}     ue_index=${ue_index}
    sleep    10s
    New UE Attach    ue_type=${ue_type}     ue_index=${ue_index}
    sleep    5s
    Run Keyword And Continue On Failure     UE Start DL Traffic    ue_index=${ue_index}    throughput=${dl_throughput}
    ...    dl_time=${duration}    dl_port=${tl.ues[0].iperf_details.port}
    Run Keyword And Continue On Failure    power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}
    ...    direction=ul    throughput=${ul_throughput}    duration=${duration}    iperf_type=via_command
    sleep    5s
    Run Keyword And Ignore Error     New Check Tput

