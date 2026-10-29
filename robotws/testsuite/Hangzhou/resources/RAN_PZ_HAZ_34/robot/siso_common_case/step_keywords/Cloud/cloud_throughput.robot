*** Settings ***
Library           DateTime
Library           json
Library           taf.gnb.oam.coam.vdu.vdu    WITH NAME    vdu
Library           taf.ul.stream.aasyslog.aasyslog    WITH NAME    steam_aasyslog
Library           taf.rfrl.cbts.utilities.tl_config   WITH NAME  tl_config
Library           taf.rfrl.cbts.utilities.generic_utils   WITH NAME    generic_utils
Library           taf.rfrl.cbts.connections.ssh_connections.SSHConnExec   WITH NAME   ssh_conn
Library           taf.rfrl.cbts.connections.rest_conn_vdu.GenericVDU   WITH NAME   vdu_gen
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/throughput/nrdim_throughput/interface.py    WITH NAME    throughput_computation
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/obtain_information.py
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/get_case_variables.py
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/frame_structure_and_throughput.py
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/basic/simple_ue.robot

*** Keywords ***
Cloud Generate Peak Information
    [Documentation]    This keyword is designed to generate and return a dictionary containing peak information.
    ...    *Author* tingting.zhong@nokia-sbell.com
    ...    *Group* VRF_HAZ4_04
    ...    *Detail*
    ...    The keyword logs a message to the console and generates a unique string to be used as a connection alias to use to login in vdu
    ...    it retrieves the L3 average rate and minimum rate, and gets the current plan file from the vDU
    ...    The keyword then creates an empty dictionary to store the cell and peak information.
    ...    For each cell ID in the input list, it generates the real peak information by nrdim
    ...    Finally, it logs the dictionary to the console and returns it as the result of the keyword.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | cell_list | Yes | The list of cell index. |
    ...    | ue_dl_layer | No | ue support dl layer, it depend on the ue capability. Default is 4. |
    ...    | ue_ul_layer | No | ue support ul layer, it depend on the ue capability. Default is 1. |
    ...    | duration | No | check tput duration. Default is 60. |
    ...    | l3_avg_rate | No | get l3call average rate. Default is None, it means get from yml, if not None, it will get the set value |
    ...    | l3_min_rate | No | get l3call min rate. Default is None, it means get from yml, if not None, it will get the set value |
    ...    | suite_name | No | get_l3_avg_rate internal parameter. Default is None, when it is None, it is the robot name |
    ...    | test_name | No | get_l3_avg_rate internal parameter. Default is None, when it set None, it is the case name |
    ...    | release | No | get_l3_avg_rate internal parameter. Default is master, it means get l3call_avg_rate by release from yml |
    ...    | local_output_dir | No | the case log path. Default is SAVE LOG DIRECTORY, which is a suite test variable |
    ...    | vdu_index | No | the vdu index. Default is 0. |
    ...    | gnb_index | No | the gnb index. Default is 0. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | cell_and_peak_info | The dictionary containing peak information. |
    [Arguments]  ${cell_list}    ${ue_dl_layer}=${4}    ${ue_ul_layer}=${1}    ${duration}=${60}
    ...    ${l3_avg_rate}=${None}    ${l3_min_rate}=${None}    ${suite_name}=default    ${test_name}=default
    ...    ${release}=master    ${local_output_dir}=${SAVE LOG DIRECTORY}  ${vdu_index}=0    ${gnb_index}=0
    log to console   \nget theoretical throughput from nrdim with scf on site!
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest   vdu_index=${vdu_index}   gnb_index=${gnb_index}   alias=${conn_alias}
    ${avg_expect_rate}    get_l3_avg_rate    suite_name=${suite_name}    test_name=${test_name}    release=${release}
    ...    l3_avg_rate=${l3_avg_rate}
    ${min_expect_rate}    get_l3_min_rate    suite_name=${suite_name}    test_name=${test_name}    release=${release}
    ...    l3_min_rate=${l3_min_rate}
    ${scf_path}   vdu.Get_Current_Plan_File    local_dir_path=${local_output_dir}  filename=scf.xml  include_runtime_data=${False}
    ...   vdu_connection=${conn_alias}
    ${cell_and_peak_info}    create dictionary
    FOR    ${cell_id}    IN    @{cell_list}
        ${peak_info}    generate_real_peak_info    cell_id=${cell_id}    scf_path=${scf_path}    ue_dl_layer=${ue_dl_layer}
        ...    ue_ul_layer=${ue_ul_layer}    avg_expect_rate=${avg_expect_rate}    min_expect_rate=${min_expect_rate}
        ...    duration=${duration}
        ${cell_id}    convert to string    ${cell_id}
        set to dictionary    ${cell_and_peak_info}    ${cell_id}    ${peak_info}
    END
    log to console    ${cell_and_peak_info}
    [Return]    ${cell_and_peak_info}
    [Teardown]  vdu_gen.logout_rest    conn_alias=${conn_alias}

Cloud Generate Peak Information with Given Params
    [Documentation]    This keyword is designed to generate and return a dictionary containing peak information for a given cell.
    ...    *Author* tingting.zhong@nokia-sbell.com
    ...    *Group* VRF_HAZ4_04
    ...    *Detail*
    ...    It converts the cell ID to a string and creates a dictionary with the given parameters.
    ...    The dictionary is then added to the cell and peak information dictionary with the cell ID as the key.
    ...    The keyword returns the updated cell and peak information dictionary.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | cell_id | No | The cell ID. Default is 1. |
    ...    | dl_tp | No | The downlink throughput. Default is 300. |
    ...    | ul_tp | No | The uplink throughput. Default is 30. |
    ...    | duration | No | The duration. Default is 60. |
    ...    | target_avg_percent | No | The target average percent. Default is 0.5. |
    ...    | min_percent | No | The minimum percent. Default is 0.3. |
    ...    | cell_and_peak_info | No | The dictionary to store the cell and peak information. Default is an empty dictionary. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | cell_and_peak_info | The updated dictionary containing peak information. |
    [Arguments]  ${cell_id}=1    ${dl_tp}=300  ${ul_tp}=30    ${duration}=${60}
    ...    ${target_avg_percent}=0.5    ${min_percent}=0.3    ${cell_and_peak_info}=&{EMPTY}
    ${cell_id}    convert to string    ${cell_id}
    ${peak_info}    create dictionary    dl_tp=${dl_tp}    ul_tp=${ul_tp}    peak_dl_tp=${dl_tp}    peak_ul_tp=${ul_tp}
    ...    avg_expect_rate=${target_avg_percent}    min_expect_rate=${min_percent}    duration=${duration}
    set to dictionary    ${cell_and_peak_info}    ${cell_id}=${peak_info}
    [Return]  ${cell_and_peak_info}

Cloud UE L3 Call Preparation
    [Arguments]  ${cell_list}    ${ue_dl_layer}=${4}    ${ue_ul_layer}=${1}    ${duration}=${60}
    ...    ${l3_avg_rate}=${None}    ${l3_min_rate}=${None}    ${suite_name}=default    ${test_name}=default
    ...    ${scf_path}=${Golden_VDU_SCF_Path}    ${allowed_no_ue}=${False}    ${mobile_network_system}=NR
    [Documentation]    This keyword is designed to verify the peak throughput for a given UE.
    ...    - [Keyword Details]
    ...    It obtains a list of UE indices and cell IDs for the given cell list.
    ...    The keyword then checks if there are any UEs in the list.
    ...    If no UEs are allowed, it logs a message to the console and returns from the keyword.
    ...    If UEs are allowed and there are no UEs in the list, it logs a message to the console and returns from the keyword.
    ...    The keyword then generates the peak information for each cell in the list.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | cell_list | Yes | The list of cell index. |
    ...    | ue_dl_layer | No | ue support dl layer, it depend on the ue capability. Default is 4. |
    ...    | ue_ul_layer | No | ue support ul layer, it depend on the ue capability. Default is 1. |
    ...    | duration | No | check tput duration. Default is 60. |
    ...    | l3_avg_rate | No | get l3call average rate. Default is None, it means get from yml, if not None, it will get the set value |
    ...    | l3_min_rate | No | get l3call min rate. Default is None, it means get from yml, if not None, it will get the set value |
    ...    | suite_name | No | get_l3_avg_rate internal parameter. Default is None, when it is None, it is the robot name |
    ...    | test_name | No | get_l3_avg_rate internal parameter. Default is None, when it set None, it is the case name |
    ...    | scf_path | No | The SCF path. Default is Golden_VDU_SCF_Path. |
    ...    | allowed_no_ue | No | Whether no UE is allowed. Default is False. |
    ...    | mobile_network_system | No | The mobile network system. Default is NR. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | ue_index_list | The ue index list for the given cell list. |
    ...    | cell_and_peak_info | The dictionary containing peak information. |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 21.06.2024 - - Created
    ...    *******************
    ...    * Owner: shifu.lan@nokia-sbell.com
    ...    * Group: VRF_HAZ4_04
    ...    *******************
    ${ue_index_list}    ${cell_id_list}    Obtain UE List for Given Cell List    cell_list=${cell_list}
    ...    scf_path=${scf_path}    mobile_network_system=${mobile_network_system}
    ${ue_num}    get length    ${ue_index_list}
    run keyword if    not ${allowed_no_ue}    should not be empty    ${ue_index_list}
    ...    msg=Please add ue mapping in __init__.py under robotws/commissionings/HGZ/{testline_name}}, refer to 7_5_UTE5G402T319
    ...    ELSE IF    ${allowed_no_ue} and ${ue_num}==0    run keywords    log to console    no ue on cell ${cell_list}!!!    AND
    ...    return from keyword
    ${cell_and_peak_info}    Cloud Generate Peak Information     cell_list=${cell_list}
    ...    ue_dl_layer=${ue_dl_layer}    ue_ul_layer=${ue_ul_layer}    duration=${duration}
    ...    l3_avg_rate=${l3_avg_rate}    l3_min_rate=${l3_min_rate}    suite_name=${suite_name}    test_name=${test_name}
    [Return]  ${ue_index_list}    ${cell_and_peak_info}

Cloud UE L3 Call And Throughput
    [Documentation]    This keyword is designed to verify the peak throughput for a given UE.
    ...    *Author* tingting.zhong@nokia-sbell.com
    ...    *Group* VRF_HAZ4_04
    ...    *Detail*
    ...    It obtains a list of UE indices and cell IDs for the given cell list.
    ...    The keyword then checks if there are any UEs in the list.
    ...    If no UEs are allowed, it logs a message to the console and returns from the keyword.
    ...    If UEs are allowed and there are no UEs in the list, it logs a message to the console and returns from the keyword.
    ...    The keyword then generates the peak information for each cell in the list.
    ...    It then verifies the peak throughput for each UE in the list by comparing the actual throughput with the theoretical throughput.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | cell_list | Yes | The list of cell index. |
    ...    | ue_dl_layer | No | ue support dl layer, it depend on the ue capability. Default is 4. |
    ...    | ue_ul_layer | No | ue support ul layer, it depend on the ue capability. Default is 1. |
    ...    | duration | No | check tput duration. Default is 60. |
    ...    | l3_avg_rate | No | get l3call average rate. Default is None, it means get from yml, if not None, it will get the set value |
    ...    | l3_min_rate | No | get l3call min rate. Default is None, it means get from yml, if not None, it will get the set value |
    ...    | suite_name | No | get_l3_avg_rate internal parameter. Default is None, when it is None, it is the robot name |
    ...    | test_name | No | get_l3_avg_rate internal parameter. Default is None, when it set None, it is the case name |
    ...    | ue_num_for_call_per_cell | No | The number of UEs for call per cell. Default is 1. |
    ...    | check_wait_time | No | The check wait time. Default is 60. |
    ...    | scf_path | No | The SCF path. Default is Golden_VDU_SCF_Path. |
    ...    | allowed_no_ue | No | Whether no UE is allowed. Default is False. |
    ...    | mobile_network_system | No | The mobile network system. Default is NR. |
    ...    | loop_times | No | The loop times. Default is 1. |
    [Arguments]  ${cell_list}    ${ue_dl_layer}=${4}    ${ue_ul_layer}=${1}    ${duration}=${60}
    ...    ${l3_avg_rate}=${None}    ${l3_min_rate}=${None}    ${suite_name}=default    ${test_name}=default
    ...    ${ue_num_for_call_per_cell}=1    ${check_wait_time}=60
    ...    ${scf_path}=${Golden_VDU_SCF_Path}    ${allowed_no_ue}=${False}    ${mobile_network_system}=NR    ${loop_times}=${1}
    ${ue_index_list}    ${cell_and_peak_info}    Cloud UE L3 Call Preparation    cell_list=${cell_list}    ue_dl_layer=${ue_dl_layer}
    ...    ue_ul_layer=${ue_ul_layer}    duration=${duration}    l3_avg_rate=${l3_avg_rate}    l3_min_rate=${l3_min_rate}
    ...    suite_name=${suite_name}    test_name=${test_name}    allowed_no_ue=${allowed_no_ue}
    ...    scf_path=${scf_path}    mobile_network_system=${mobile_network_system}
    wait until keyword succeeds    ${loop_times}x    30sec     Cloud UE L3 CAll Procedure    ue_index_list=${ue_index_list}
    ...    cell_and_peak_info=${cell_and_peak_info}    scf_path=${scf_path}    duration=${duration}
    ...    check_wait_time=${check_wait_time}    mobile_network_system=${mobile_network_system}

Cloud UE L3 CAll Procedure
    [Documentation]    This keyword is designed to perform a L3 call procedure for given UE index list and verify the peak throughput.
    ...    *Author* tingting.zhong@nokia-sbell.com
    ...    *Group* VRF_HAZ4_04
    ...    *Detail*
    ...    It prepares the UE for the L3 call procedure.
    ...    It then attaches the UE to the cell and starts the traffic.
    ...    It then collects the throughput from the VDU  and stop the traffic.
    ...    Finally, it verifies the peak throughput for each UE in the list.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | ue_index_list | Yes | The list of UE index. |
    ...    | cell_and_peak_info | Yes | A dictionary containing peak information for each cell. |
    ...    | scf_path | No | The SCF file path. Default is Golden_VDU_SCF_Path,which is a suite variable defined in test suite setup. |
    ...    | check_wait_time | No | The check wait time. Default is 60. |
    ...    | duration | No | The duration. Default is 60. |
    ...    | mobile_network_system | No | The mobile network system. Default is NR. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |
    [Arguments]    ${ue_index_list}    ${cell_and_peak_info}    ${scf_path}=${Golden_VDU_SCF_Path}    ${check_wait_time}=${60}
    ...    ${duration}=${60}    ${mobile_network_system}=NR
    Simple Ue Prepare    ue_index_list=${ue_index_list}    scf_path=${scf_path}    mobile_network_system=${mobile_network_system}
    ${ue_and_cell}    Simple Ue Attach and Start Traffic    ue_index_list=${ue_index_list}    cell_and_peak_info=${cell_and_peak_info}
    ...    mobile_network_system=${mobile_network_system}    scf_path=${scf_path}    duration=${duration}
    sleep    ${check_wait_time}
    ${tput_log}    Cloud Collect Tput from VDU    duration=${duration}
    Simple Ue Stop DL UL Traffic    ue_index_list=${ue_index_list}
    Cloud UE Verify Peak Throughput    ue_index_list=${ue_index_list}    ue_and_cell=${ue_and_cell}
    ...    cell_and_peak_info=${cell_and_peak_info}    log=${tput_log}
    ...    mobile_network_system=${mobile_network_system}
    [Teardown]  Simple Ue Detach    ue_index_list=${ue_index_list}

Cloud Collect Tput from VDU
    [Documentation]    This keyword is designed to collect throughput from VDU.
    ...    *Author* tingting.zhong@nokia-sbell.com
    ...    *Group* VRF_HAZ4_04
    ...    *Detail*
    ...    It generates a unique string and uses it to connect to the VDU.
    ...    It creates a list of filter texts and joins them into a single string.
    ...    It gets the namespace of the VDU and the full names of the pod and container.
    ...    It then constructs a command to execute on the VDU to collect the throughput.
    ...    After waiting for a specified duration, it downloads the log file containing the throughput information.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | gnb_index | No | The gNB index. Default is 0. |
    ...    | vdu_index | No | The vDU index. Default is 0. |
    ...    | duration | No | The duration. Default is 60. |
    ...    | log_path | No | The path to the log file. Default is SAVE LOG DIRECTORY, which is a suite test variable. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | log_path | The path to the downloaded tput log file. |
    [Arguments]    ${gnb_index}=0     ${vdu_index}=0    ${duration}=${60}    ${log_path}=${SAVE LOG DIRECTORY}
    log to console    \nCollect Tput from VDU
    ${alias}    generic_utils.get_unique_id_string
    ${alias}    ssh_conn.connect_to_vdu_cloud_hosting    using_tenant=${True}
    ...  vdu_index=${vdu_index}    gnb_index=${gnb_index}    alias=${alias}
    ${filter_text_list}    create list    UlCounterUpdate    DataPdu    L2_PS_DL_UP_.*ue.rnti    handlePrachPreamble
    ...    Pdcch Resources updated for Ue rnti    informDlOfSuccessfulMsg3Ue    Store UE    dl_awaitMsg4WithoutHiMsgTimerExpiry
    ${filter_text}    Evaluate    r"\\|".join($filter_text_list)
    ${namespace}   tl_config.get_vdu_namespace    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${pod_full_name}    ${container_full_name}    ssh_conn.get_full_pod_and_container_name    pod_abbr=logservice
    ...    container_abbr=logstorageserver    namespace=${namespace}    alias=${alias}
    ${base_command}    set variable    nohup kubectl exec -it ${pod_full_name} -c ${container_full_name} -n ${namespace} --
    Cloud Split Duration and Collect Tput    base_command=${base_command}    duration=${duration}    filter_text=${filter_text}
    ...    log_path=${log_path}    alias=${alias}
    [Return]    ${log_path}/${alias}_tput.log
    [Teardown]    run keyword and ignore error    ssh_conn.disconnect_all_vdu_cloud_hosting

Cloud Split Duration and Collect Tput
    [Documentation]    This keyword is designed to split the duration and collect throughput.
    ...    *Author* tingting.zhong@nokia-sbell.com
    ...    *Group* VRF_HAZ4_04
    ...    *Detail*
    ...    It calculates the number of command times and sets the timeout.
    ...    It enters a loop where it constructs a command to execute on the VDU to collect the throughput.
    ...    After waiting for a specified timeout, it downloads the log file containing the throughput information.
    ...    Finally, it appends the content of the downloaded file to the main log file.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | base_command | Yes | The base command to execute on the VDU. |
    ...    | duration | Yes | The duration to split. |
    ...    | filter_text | Yes | The filter text to use when collecting throughput. |
    ...    | log_path | Yes | The path to the log file. |
    ...    | alias | Yes | The alias to use when connecting to the VDU. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |
    [Arguments]  ${base_command}    ${duration}    ${filter_text}   ${log_path}    ${alias}
    ${cmd_times}    evaluate    math.ceil(${duration}/600)   math
    ${duration}    convert to number    ${duration}
    ${timeout}    set variable if    ${cmd_times}<=1    ${duration}    ${600}
    ${interval}    evaluate    math.ceil(${timeout}/10)   math
    FOR    ${i}    IN RANGE    1    ${cmd_times+1}
        ${tput_file}    set variable    ${alias}_tput_${i}.log
        ${cmd}    set variable
        ...    ${base_command} timeout ${timeout} tail -f /var/log/localvolume/syslog | grep -a "${filter_text}" > /tmp/${tput_file} &
        ${output}    ssh_conn.execute_normal_cmd    base_command=${cmd}    alias=${alias}
        sleep    ${timeout}
        ssh_conn.download_file    remote_path=/tmp/${tput_file}    local_path=${log_path}/${tput_file}
        ...    alias=${alias}
        ssh_conn.execute_normal_cmd    base_command=rm -rf /tmp/${tput_file}   alias=${alias}
        ${content}    get file    ${log_path}/${tput_file}
        append to file    ${log_path}/${alias}_tput.log    ${content}
    END

Cloud UE Verify Peak Throughput
    [Documentation]    This keyword is designed to verify the peak throughput for a given UE.
    ...    *Author* tingting.zhong@nokia-sbell.com
    ...    *Group* VRF_HAZ4_04
    ...    *Detail*
    ...    It enters a loop where it processes each UE in the ue_index_list
    ...    It translates the power UE type from the testline and converts the UE index to string.
    ...    It retrieves the cell identity ID and creates a list containing this ID
    ...    It retrieves the downlink details and calculates the duration percent.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | ue_index_list | Yes | The list of UE index. |
    ...    | ue_and_cell | Yes | A dictionary mapping UEs to cells. |
    ...    | cell_and_peak_info | Yes | A dictionary containing peak information for each cell. |
    ...    | log | Yes | The path to the log file. |
    ...    | check_source | No | The source to check. Default is 'Aasyslog'. |
    ...    | mobile_network_system | No | The mobile network system. Default is 'NR'. |
    ...    | local_output_dir | No | The local output directory. Default is 'SAVE LOG DIRECTORY'. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |
    [Arguments]  ${ue_index_list}    ${ue_and_cell}    ${cell_and_peak_info}
    ...    ${log}    ${check_source}=Aasyslog    ${mobile_network_system}=NR    ${local_output_dir}=${SAVE LOG DIRECTORY}
    log to console    \nUE Verify Peak Throughput
    FOR  ${ue_index}  IN  @{ue_index_list}
        ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
        ${ue_index}    convert to string    ${ue_index}
        ${cell_id}    get from dictionary    ${ue_and_cell}    ${ue_index}
        ${cell_id}    convert to string    ${cell_id}
        ${peak_info}    get from dictionary    ${cell_and_peak_info}    ${cell_id}
        ${identity_id}    Get Cell Identity Id   cell_id=${cell_id}
        ${cells}    Create List    ${identity_id}
        ${all_dl_details}    run keyword and continue on failure    steam_aasyslog.check_aasyslog_throughput
        ...    direction=dl    log_path=${log}    local_output_dir=${local_output_dir}
        ...    cells=${cells}    theoretical_throughput=${peak_info['peak_dl_tp']}
        ...    average_tolerance=${peak_info['avg_expect_rate']}    minimum_tolerance=${peak_info['min_expect_rate']}
        ${all_ul_details}    run keyword and continue on failure    steam_aasyslog.check_aasyslog_throughput
        ...    direction=ul    log_path=${log}    local_output_dir=${local_output_dir}
        ...    cells=${cells}    theoretical_throughput=${peak_info['peak_ul_tp']}
        ...    average_tolerance=${peak_info['avg_expect_rate']}    minimum_tolerance=${peak_info['min_expect_rate']}
        ${dl_detail}    Get DL details    all_dl_details=${all_dl_details}    identity_id=${identity_id}
        ${duration}    get from dictionary    ${cell_and_peak_info['${cell_id}']}    duration
        ${duration_percent}    evaluate
        ...    ${dl_detail['count']}*${dl_detail['min_time_interval']}/${duration}
        ${duration_percent}    evaluate    round(${duration_percent}, 2)
        should be true    ${duration_percent}>=0.8    msg=get DL throughput duration is less than 80%
    END

Get DL details
    [Documentation]    This keyword is designed to get the downlink details for a given cell identity.
    ...    *Author* tingting.zhong@nokia-sbell.com
    ...    *Group* VRF_HAZ4_04
    ...    *Detail*
    ...    This keyword accepts a list of all downlink details and a cell identity.
    ...    It then iterates over the list of downlink details and returns the details for the given cell identity.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | all_dl_details | Yes | The list of all downlink details. |
    ...    | identity_id | Yes | The cell identity. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | dl_detail | The downlink details for the given cell identity. |
    [Arguments]  ${all_dl_details}    ${identity_id}
     FOR  ${dl_detail}  IN  @{all_dl_details}
         return from keyword if    '${identity_id}'=='${dl_detail['cellid']}'    ${dl_detail}
     END

Get Cell Identity Id
    [Documentation]    This keyword is designed to get the cell identity for a given cell ID.
    ...    *Author* tingting.zhong@nokia-sbell.com
    ...    *Group* VRF_HAZ4_04
    ...    *Detail*
    ...    This keyword accepts the vDU index, gNB index, and cell ID as arguments.
    ...    It then generates a unique string and uses it to connect to the vDU.
    ...    It retrieves the status of the cells in the vDU and iterates over the list of cells.
    ...    If the cell ID matches the given cell ID, it returns the cell identity.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | vdu_index | No | The vDU index. Default is 0. |
    ...    | gnb_index | No | The gNB index. Default is 0. |
    ...    | cell_id | No | The cell ID. Default is 1. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | cell_identity | The cell identity for the given cell ID. If no match is found, it returns None. |
    [Arguments]    ${vdu_index}=0  ${gnb_index}=0  ${cell_id}=1
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest   vdu_index=${vdu_index}   gnb_index=${gnb_index}   alias=${conn_alias}
    ${cells_status}    vdu.get_vdu_cells_status    vdu_connection=${conn_alias}
    FOR  ${cell}  IN  @{cells_status}
        return from keyword if    '${cell_id}'=='${cell['id']}'     ${cell['nr_cell_identity']}
    END
    [Return]    ${None}
    [Teardown]  vdu_gen.logout_rest    conn_alias=${conn_alias}
