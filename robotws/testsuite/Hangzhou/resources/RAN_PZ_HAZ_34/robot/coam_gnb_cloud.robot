*** Settings ***
Documentation    This is for COAM classical GNB, it's focus on rest api
...              Notes: This file is mainly for the first GNB defined in testline configure file.
...              Please do not modify the file without notification to author
...              Author: Ding Binmei
...              Squard: MMW_HZ_SG1
Resource    ./coam_gnb_classical.robot
Library     ../python/coam_gnb_cloud.py
Library     taf.gnb.oam.coam.cu.interface.cu      WITH NAME    cu

*** Keywords ***
Cloud wait for gnb ready on both CU and DU
    [Documentation]  Author: Ding Binmei
    ...              Description: Wait all DU status ready and also verify status on CU
    ...              CU alias will be released automatically. For DU alias, need to release by tester in cases.
    ...              Example alias: GNB_OAM, GNB_OAM_du1, GNB_OAM_du2
    ...    ${is_all_dus_checking_needed}: if ${True}, then will check all DUs defined in test line config file; Default to check for all DUs
    ...                                   if ${False}, then ${list_du_index} must be entered. Supported data types are string and list
    [Timeout]  30 min
    [Arguments]  ${gnb_index}=0    ${connection}=OAM_CU${gnb_index}    ${timeout}=10 min    ${retry_interval}=5 sec
    ...    ${is_all_dus_checking_needed}=${True}    ${list_du_index}=0
    @{tl_all_du_index}    _Generate DU index based on testline config file
    ${input_du_index}    Convert data type to a list    input_data=${list_du_index}
    @{list_du_index}    Set variable if    ${is_all_dus_checking_needed}    ${tl_all_du_index}    ${input_du_index}
    FOR    ${du_index}    IN    @{list_du_index}
           Log to console    Start to check bts status for DU ${du_index}
           Run keyword and continue on failure    coam_gnb_classical.Wait until cluster is on cell on air status    timeout=${timeout}
           ...    is_all_cells_checking_needed=${True}    retry_interval=${retry_interval}    du_index=${du_index}
           ...    is_x2_check_from_enb_needed=${False}    is_enb_status_check_needed=${False}
    END
    Run keyword and continue on failure    Wait for all ENB status are on air based on testline config file    timeout=${timeout}
    Wait until GNB status ready on CU    gnb_index=${gnb_index}    connection=${connection}    timeout=${timeout}    retry_interval=${retry_interval}

Wait until GNB status ready on CU
    [Documentation]  Author: Ding Binmei
    ...              Description: Check cloud status on CU
    [Timeout]  20 min
    [Arguments]  ${gnb_index}=0    ${connection}=OAM_CU${gnb_index}    ${timeout}=10 min    ${retry_interval}=5 sec
    Log to console    Start to check GNB status on CU
    Wait until keyword succeeds    ${timeout}    ${retry_interval}    Connect to cu via ssl   gnb_index=${gnb_index}    connection=${connection}
    Wait until keyword succeeds    ${timeout}    ${retry_interval}    Verify VM status are as expected on CU    gnb_index=${gnb_index}
    ...    connection=${connection}    exp_availability_status=on line    exp_operational_state=enabled
    Wait until keyword succeeds    ${timeout}    ${retry_interval}    Verify DU status are available on CU    gnb_index=${gnb_index}
    ...    connection=${connection}
    Wait until keyword succeeds    ${timeout}    ${retry_interval}    Verify X2 link status are available on CU   gnb_index=${gnb_index}
    ...    connection=${connection}
    Wait until keyword succeeds    ${timeout}    ${retry_interval}    Verify cells status are on air on CU   gnb_index=${gnb_index}
    ...    connection=${connection}
    [Teardown]    Teardown cu connection via ssl    gnb_index=${gnb_index}    connection=${connection}

_Generate DU index based on testline config file
    [Documentation]  Author: Ding Binmei  [Private]
    ${dus}    testline_info.get_du_list    tl=${tl}
    ${count_dus}    Get length    ${dus}
    @{du_index}    Evaluate    list(range(0,${count_dus}))
    [Return]  ${du_index}

Connect to cu via ssl
    [Documentation]  Author: Ding Binmei
    [Arguments]  ${gnb_index}=0    ${connection}=OAM_CU${gnb_index}
    cu.connect to    host=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...    port=${EMPTY}
    ...    username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...    cu_version=cuoam_19b
    ...    secure=${True}
    ...    alias=${connection}

Teardown cu connection via ssl
    [Documentation]  Author: Ding Binmei
    [Arguments]  ${gnb_index}=0    ${connection}=OAM_CU${gnb_index}
    cu.disconnect    connection=${connection}

Verify VM status are as expected on CU
    [Documentation]  Author: Ding Binmei
    ...              Description: Verify all VM status are as expected.
    [Arguments]  ${gnb_index}=0    ${connection}=OAM_CU${gnb_index}    ${exp_availability_status}=on line    ${exp_operational_state}=enabled
    &{dict_vms_info}    coam_gnb_cloud.get_all_vms_info    connection=${connection}
    @{vm_names}    Get Dictionary Keys    ${dict_vms_info}
    ${count_vm_numbers}    Get length    ${vm_names}
    Should be true    ${count_vm_numbers}>=7    msg= VM number ${count_vm_numbers} is incorrect
    FOR  ${vm_name}  IN  @{vm_names}
         Run keyword and continue on failure    should be equal as strings    ${dict_vms_info['${vm_name}']['availability_status']}
         ...    ${exp_availability_status}    ignore_case=${True}
         Run keyword and continue on failure    should be equal as strings    ${dict_vms_info['${vm_name}']['operational_state']}
        ...    ${exp_operational_state}    ignore_case=${True}
    END

Verify DU status are available on CU
    [Documentation]  Author: Ding Binmei
    ...              Description: Verify DU status and administrative state are ok on CU.
    [Arguments]  ${gnb_index}=0    ${connection}=OAM_CU${gnb_index}
    &{dict_dus_info}    cu.get_dus_diff    connection=${connection}
    ${count_dus_num}    Get length    ${dict_dus_info['created']}
    Should be true    ${count_dus_num}>=1    msg= DU number ${count_dus_num} is incorrect
    FOR    ${du_info}    IN    @{dict_dus_info['created']}
           Run keyword and continue on failure    should be equal as strings    ${du_info['f1_link_status']}    available
           ...    msg=F1 link status for DU ${du_info['name']} is not as expected    ignore_case=${True}
           Run keyword and continue on failure    should be equal as strings    ${du_info['administrative_state']}    Unlocked
           ...    msg=Administrative state link status for DU ${du_info['name']} is not as expected    ignore_case=${True}
    END

Verify X2 link status are available on CU
    [Documentation]  Author: Ding Binmei
    ...              Description: Verify X2 link status are as expected on CU.
    [Arguments]  ${gnb_index}=0    ${connection}=OAM_CU${gnb_index}
    &{x2_links_info}    cu.get_x2_links_info    connection=${connection}
    ${list_x2_links_info}    Set variable    ${x2_links_info['created']}
    ${count_x2_links_num}    Get length    ${list_x2_links_info}
    Should be true    ${count_x2_links_num}>=1    msg= X2 links number ${count_x2_links_num} is incorrect
    FOR    ${x2_link_info}    IN    @{list_x2_links_info}
           ${x2_link_info}    Evaluate    dict(${x2_link_info})
           Run keyword and continue on failure    should be equal as strings    ${x2_link_info['x2_link_status']}    available
           ...    msg=X2 link status for ${x2_link_info['dist_names']['config']} is not as expected    ignore_case=${True}
           Run keyword and continue on failure    should be equal as strings    ${x2_link_info['x2_link_lock']}    unlocked
           ...    msg=X2 link status for ${x2_link_info['dist_names']['config']} is not as expected    ignore_case=${True}
    END

Verify cells status are on air on CU
    [Documentation]  Author: Ding Binmei
    ...              Description: Verify cell status are on air on CU.
    [Arguments]  ${gnb_index}=0    ${connection}=OAM_CU${gnb_index}
    @{cells}    cu.get_cells_statuses    connection=${connection}
    ${count_cells_num}    Get length    ${cells}
    Should be true    ${count_cells_num}>=1    msg= Cell number ${count_cells_num} is incorrect
    FOR    ${cell_status}    IN    @{cells}
         Run keyword and continue on failure    should be equal as strings    ${cell_status['administrative_state']}    Unlocked
         ...    msg=Cell status for cell ${cell_status['id']} is not as expected    ignore_case=${True}
         Run keyword and continue on failure    should be equal as strings    ${cell_status['operational_state']}    enabled
         ...    msg=Cell status for cell ${cell_status['id']} is not as expected    ignore_case=${True}
    END

Veriy if alarms exist on CU
    [Documentation]    Author: Cui Lingxue  MMW_SG1
    ...                Description: Collect active alarms and write the alarms to file
    [Arguments]  ${gnb_index}=0    ${connection}=OAM_CU${gnb_index}    ${timeout}=60s    ${log_path_alarm}=${TS_CASE_LOG_PATH}
    Connect to cu via ssl    gnb_index=${gnb_index}    connection=${connection}
    ${check_alarm_output}    cu.get_active_alarms    timeout=${timeout}    connection=${connection}
    ${alarm_num}    set variable    ${check_alarm_output['total']}
    @{active_alarms}    set variable    ${check_alarm_output['alarms']}
    Run keyword and continue on failure    Should be true    ${alarm_num} == ${0}
    ...    msg=${alarm_num} alarm exist, please check manually
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    Run    command=echo "Active alarm number:${alarm_num}">${log_path_alarm}/cu_active_alarm_${timestamp}.txt
    FOR  ${alarm}  IN  @{active_alarms}
         run    command=echo "${alarm}">>${log_path_alarm}/cu_active_alarm_${timestamp}.txt
    END
    [Teardown]    Teardown cu connection via ssl
