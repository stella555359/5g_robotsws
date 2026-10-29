*** Settings ***
Documentation
...   This is for 1726 TA common keywords
...   squad group: MMW_SG1
Resource    ./1726_variables.robot
#Variables      ./../TestData/1726_NIDD_modify.py
#Variables    ../TestData/1726_SCF_modify.py
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/common_resources.robot
Resource          taf/rfrl/common_resources/robot/TTI_Trace.robot
Resource    ./5GC001726_keywords.robot
#Library    taf.analyzer.pcap     WITH NAME    cap
#Library    taf.analyzer.pcap    WITH NAME    cap
Library     ./core_deploy.py
Library     ./event_trace_log_analysis.py
Resource     ./5GC001726_keywords_cobham.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/rrm_log_check.robot
Resource      ./../../5GC001937_Classical/Resources/5GC001937_classical_keywords.robot
Variables    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/lib/NIDD_modify_merge_scf.py


*** Keywords ***
Verify L2Hi and TRSW deployment logs
    [Documentation]  Author: Wang Yixiang
    ...    Verify L2Hi and TRSW deployment logs
    ...    reference document:
    ...    https://confluence.int.net.nokia.com/display/5GRANHZ/How+to+check+new+deployment%28L2-HI-DU+and+TRSW+%29+in+1726-H
    ...    asik slave:
    ...    /tmp/node_0xe00a/tmp/FCT-E00A_startup.log filter string like following to get core list
    ...    ccs_em_rt_dispatcher_affinity_set: ccs_em_rt_dispatcher_affinity_set for EM RT dispatcher 6 to physical core 7
    ...    expected cores:2,3,4,5,6,7
    ...    asik master:
    ...    /tmp/startup_TRSW.log filter string like "lcores 0@(7),4,5,6,7" to get core list
    ...    expected cores:4,5,6,7
    ${actual_l2hi_core_list}    get_l2hi_delopment_core_list    log_path=${LOCAL_L2HI_LOG_PATH}
    ${actual_trsw_core_list}    get_trsw_delopment_core_list    log_path=${LOCAL_TRSW_LOG_PATH}

    ${expect_l2hi_core_list}    create list    2   3   4   5   6   7
    ${expect_trsw_core_list}    create list    4   5   6   7

    Lists Should Be Equal    ${actual_l2hi_core_list}    ${expect_l2hi_core_list}
    Lists Should Be Equal    ${actual_trsw_core_list}    ${expect_trsw_core_list}

Collect logs in teardown
    [Documentation]  Author: Ding Binmei
    ...              Description: Collect common logs in teardown phase for trouble shooting
    ...                           This keyword can be called in both suite teardown and case teardown with ${is_called_in_test_case_level}
    [Arguments]    ${is_called_in_test_case_level}=${True}
    ${status}    Set variable if    ${is_called_in_test_case_level}    ${TEST STATUS}    ${SUITE STATUS}
    ${log_path}    Set variable if    ${is_called_in_test_case_level}    ${TS_CASE_LOG_PATH}    ${SUITE_LOG_PATH}
    Connect to gnb coam via ssl
    Run keyword if    '${status}' == 'FAIL'    COAM Save snapshot via webUI    download_dir=${log_path}
    [Teardown]  COAM Teardown gnb connections

Verify bler is as expected based on event trace log
    [Documentation]    Author: Ding Binmei
    ...                Description: Verify bler is within the expected value
    ...                dict_event_trace_log should be a dict, {'UL':/XXX/XXX/XXX.csv, 'DL':/XXX/XXX/XXX.csv}
    ...                data_transfer_direction: supported values are both, ul, dl
    [Arguments]    ${dict_event_trace_log}    ${data_transfer_direction}=both    ${exp_ue_number}=1
    Run keyword if    '${data_transfer_direction}'=='both'
    ...    Run keywords    run keyword and continue on failure    event_trace_analysis.verify_bler_is_as_expected
    ...                    file_path=${dict_event_trace_log['UL']}    exp_bler=${EXPECTED_BLER}    direction=ul    exp_ue_number=${exp_ue_number}
    ...    AND    run keyword and continue on failure    event_trace_analysis.verify_bler_is_as_expected
    ...               file_path=${dict_event_trace_log['DL']}    exp_bler=${EXPECTED_BLER}    direction=dl    exp_ue_number=${exp_ue_number}
    ...    ELSE IF    '${data_transfer_direction}'=='ul'
    ...        event_trace_analysis.verify_bler_is_as_expected    file_path=${dict_event_trace_log['UL']}    exp_bler=${EXPECTED_BLER}
    ...            direction=ul    exp_ue_number=${exp_ue_number}
    ...    ELSE IF    '${data_transfer_direction}'=='dl'
    ...        event_trace_analysis.verify_bler_is_as_expected    file_path=${dict_event_trace_log['DL']}    exp_bler=${EXPECTED_BLER}
    ...            direction=dl    exp_ue_number=${exp_ue_number}
    ...    ELSE    Should be true    ${False}    msg=Invalid input for data_transfer_direction, supported values are: both, ul, dl

Common Suite Teardown
    [Timeout]    10 min
    [Documentation]    Author: Ren Biyao
    ...    This keyword is used in suite teardown part.
    [Arguments]        ${local_log_path}=${SUITE_LOG_PATH}
    5GC001726_keywords.Collect logs in teardown    is_called_in_test_case_level=${False}
    run keyword and ignore error    Close all connection

Test Case Teardown
    [Documentation]    Author: Ren Biyao
    ...               :default value ${IS_POWER_UE_SUPPORTED} is set in suite preparation
    ...               :default value ${UE_TYPE} is set in suite preparation
    [Timeout]    20 min
    [Arguments]     ${e500_script_path}=${E500_SCRIPTS_BASE}    ${log_path}=${TS_CASE_LOG_PATH}
    ...    ${is_need_to_clear_unused_logs}=${True}    ${protocol}=udp    ${is_log_required}=${True}
    ...    ${ue_type}=${UE_TYPE}
    run keyword if    ${is_log_required}    Collect logs in teardown classical and cloud
    ...    is_called_in_test_case_level=${True}    name=btslog    is_btslog_required=${True}
    Connect to gnb coam via ssl
    COAM Update several parameters via rest api    parameters_to_update_via_api=${MODIFY_VIA_API_FOR_DEFAULT_8CC_BTS_PARAMETERS}
#    5GC001937_classical_keywords.Case Teardown     is_need_to_send_rp=${False}
    COAM Teardown gnb connections
    power_ue.UE Detach    ue_type=${UE_TYPE}
    Stop data transfer based on direction    data_transfer_direction=both   protocol=${protocol}
    run keyword and ignore error    run keyword if    ${is_need_to_clear_unused_logs}
    ...    Clear unuseful log in teardown    log_path=${TS_CASE_LOG_PATH}   is_called_in_test_case_level=${True}
    CI_interface.Common Case Teardown
    run keyword and ignore error    Close all connection

Switch pcell for attach based on cell index
    [Documentation]    Author: Ren Biyao
    ...                Description: if prerequisite 'actDynTrigLteNrDualConnectivity = false' satisfied, defaultLnRelGnbCellId can be used
    ...                             in eNB scf to force the SgNBAddition on specific cell
    ...                ${cell_index_for_attach} is given as the gnb cell index which is chosen for ue attach, eg, 1, 2 ...
    [Arguments]  ${cell_index_for_attach}
    Make SgNBAddition on specific cell    gnb_ps_cell_index=${cell_index_for_attach}

Close iperf progress
    [Documentation]    Author: Wang Yixiang
    [Arguments]    ${dl_port}=${DL_PORT}    ${ul_port}=${UL_PORT}    ${ue_index}=0
    Run Keyword If    '${dl_port}'!='${None}'    Close the iperf process on APPserver    port=${dl_port}
    Run Keyword If    '${ul_port}'!='${None}'    Close the iperf process on APPserver    port=${ul_port}
    Close the iperf process on Qualcomm    ue_index=${ue_index}

Android Common Test Teardown
    [Documentation]  Author: Wang Yixiang
    ...              Description: Case teardown
    power_ue.UE Detach    ue_type=${UE_TYPE}
    android_common_keyword.Download uepc log on ue control pc
    android_common_keyword.Clear uepc log on ue control pc
    Stop data transfer based on direction    data_transfer_direction=both
    5GC001726_keywords.Collect logs in teardown
    Teardown all connections

Teardown all connections
    [Documentation]  Author: Wang Yixiang
    ...              Description: Release all connections
    coam_gnb_classical.COAM Teardown gnb connections
    enb_lte.Enblte close down    connection=enblte
    @{ssh_alias}    Create list   ASIK Master    ASIK Slave    GNB_OAM
    Disconnect ssh connections    list_alias=${ssh_alias}

Get PM counters by cell
    [Documentation]  Author: Wang Yixiang
    ...              get pm counter values by cell
    ...              ${cell} can be sigle value 1 or multiple value 1,2,3
    ...              ${measurement_id} can be sigle value M55324C00101 or multiple value M55324C00000,M55324C00101
    ...              Example output:
    ...                   {'1': {'M55324C00000': '0', 'M55324C00101': '0'},
    ...                    '2': {'M55324C00000': '0', 'M55324C00101': '0'},
    ...                    '3': {'M55324C00000': '0', 'M55324C00101': '0'},
    ...                    '4': {'M55324C00000': '0', 'M55324C00101': '0'}}
    ...              usage:
    ...              ${cell_counter}    Get PM counters by cell   file_path=${counter_path}   cell=1   measurement_id=M55324C00000,M55324C00101
    ...              or
    ...              ${cell_counter}    Get PM counters by cell   file_path=${counter_path}   cell=1,2   measurement_id=M55324C00000,M55324C00101

    [Arguments]    ${file_path}    ${cell}    ${measurement_id}
    @{list_cell}               string2list    ${cell}
    @{list_measurement_ids}    string2list    ${measurement_id}
    counter.get_cell_counters_from_file
    ...    file_path=${file_path}   list_cell=${list_cell}    list_measurement_ids=${list_measurement_ids}


Power ue attach
    [Documentation]    Author: Ren Biyao
    ...                :default value ${UE_TYPE} is from keyword translate_power_ue_type_from_testline, and set as suite variable
    ...                :para${is_need_to_keep_ue_attach} and para ${duration_of_ue_attach} are used to decide whether or not to keep ue attached
    ...                 for a given period.
    [Arguments]    ${ue_type}=${UE_TYPE}    ${is_need_to_keep_ue_attach}=${False}    ${duration_of_ue_attach}=${None}    ${ue_index}=${0}
    ...    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ${is_ue_exists}    run keyword and return status    Check UE device exist    ue_index=${ue_index}
    should be true    ${is_ue_exists}
    Retry commercial ue attach if failed    prepare_ue_needed=${False}
    ...    ue_type=${ue_type}    ue_index=${ue_index}    retry_time=${2}    4G_check=${False}    detach_request=${False}
    run keyword if    ${is_need_to_keep_ue_attach}    sleep    ${duration_of_ue_attach}

Capture log and verify CSI-ReportsAllCC and DL HARQ feedback success anb bler
    [Documentation]    Author: Wang Yixiang
    ...    capture event trace log and check that CSI reports are scheduled for all the allocated component carriers for the UE
    ...    Check that all DL HARQ feedbacks are received successfully (via PUCCH on PSCell)
    ...    Data transfer in UL and DL is maintained and the bler did not exceed the target
    ...    cell id can be follwing:
    ...    cell_id=1
    ...    cell_id=1-5  means 1,2,3,4,5
    ...    cell_id=1,3,5
    [Arguments]    ${cell_id}    ${multi_ue}=${False}   ${hw_slot}=${1}
    Start TTI trace log capturing   hw_slot=${hw_slot}
    Sleep    1s
    Stop TTI trace log capturing
    &{dict_csv_file_path}    Convert TTI trace log and download combined csv logs to test pc
    @{expected_physicalCellId_list}    create list
    @{cell_id_list}    string2list    ${cell_id}
    FOR    ${cell_id}    IN     @{cell_id_list}
        append to list    ${expected_physicalCellId_list}    ${NR_CELL_ID_MAPPING[${cell_id}]['physicalCellId']}
    END
    Run keyword and continue on failure    event_trace_analysis.check_csi_reports_scheduled_for_all_CCs_for_ue
    ...    file_path=${dict_csv_file_path['DL']}    expected_physCellId_list=${expected_physicalCellId_list}
    Run keyword and continue on failure    Verify bler is as expected based on event trace log    dict_event_trace_log=${dict_csv_file_path}
    ...    data_transfer_direction=both

Qcom attach UE and start traffic
     [Documentation]    Author: Ren Biyao
     ...    :para${call_duration} should be seconds, 600 stands for 600s.
     [Arguments]    ${call_duration}=600    ${cell_index_for_attach}=1    ${dl_tput_size}=50    ${ul_tput_size}=20
     ...    ${buffer_size}=1400B    ${traffic_send_method}=UDP    ${tcp_throughput}=1M    ${tcp_process}=${10}
     ...    ${tcp_mtu}=${1280}    ${data_transfer_direction}=both    ${iperf_type_ul}=via_command
     Switch pcell for attach based on cell index    cell_index_for_attach=${cell_index_for_attach}
     ${attach_status}    Wait until keyword succeeds    2X    10 s    Power ue attach
     ${traffic_time}    Evaluate    ${call_duration}*10

    Run keyword if    '${traffic_send_method}'=='UDP'
    ...    Start data transfer based on direction    dl_tput=${dl_tput_size}   ul_tput=${ul_tput_size}   duration=${traffic_time}
    ...    buffer_size=${buffer_size}    protocol=udp    data_transfer_direction=${data_transfer_direction}
    ...    iperf_type_ul=${iperf_type_ul}
    ...    ELSE IF  '${traffic_send_method}'=='TCP'
    ...    Start data transfer based on direction    dl_tput=${dl_tput_size}   ul_tput=${ul_tput_size}   duration=${traffic_time}
    ...    buffer_size=${buffer_size}    protocol=tcp    data_transfer_direction=${data_transfer_direction}
    ...    iperf_type_ul=${iperf_type_ul}
    ...    ELSE    Should be true    ${False}    msg=Invalid input for traffic_send_method!
    [Return]    ${attach_status}

Suite Preparation
    [Documentation]    Author: Ren Biyao
    ...    This keyword will modify swconfig file(default is not to modify swconfig) and commission gnb and verify
    ...    gnb cell on air status.
    ...    ${1726_scf_parameter} is the parameters list which is related to 1726 function.
    [Timeout]    20 min
    [Arguments]    ${1726_scf_parameter}=${MODIFY_SCF_COMMON}    ${swconfig_modify}=${None}
    ...       ${is_pdl_checking_needed}=${False}
    ...       ${is_need_to_perform_commision}=${True}
    # stream decides
    5GC001937_classical_keywords.Pre Condition    scf_modify=${1726_scf_parameter}
    ${cur_program}    gnb_classical_hangzhou.Get program version based on stream version
    set suite variable    ${PROGRAM}    ${cur_program}
    import library      event_trace_log_analysis.Event_trace_log_analysis_1726    program=${PROGRAM}     WITH NAME    event_trace_analysis
    Connect to Capacity Unit Master
    ${IS_POWER_UE_SUPPORTED}    run keyword and return status      ue_type.translate_power_ue_type_from_testline
    set suite variable    ${IS_POWER_UE_SUPPORTED}
    ${is_attenuation_exists}    Check if testline configured with attenuation
    run keyword if    ${is_attenuation_exists}     Adjust the Attenuation
    Set suite variable    ${IS_ATTENUATION_EXISTS}     ${is_attenuation_exists}
    &{NR_CELL_ID_MAPPING}    coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids
    Set suite variable    ${NR_CELL_ID_MAPPING}
    Run keyword and ignore error    Verify SIM card state and reboot UE if SIM not loaded
    Switch pcell for attach based on cell index    cell_index_for_attach=${1}

Counter suite preparation
    [Documentation]    Author: Ren Biyao
    [Arguments]    ${is_need_to_perform_commision}=${True}    ${is_pdl_checking_needed}=${False}
    5GC001726_keywords.Suite Preparation    is_need_to_perform_commision=${is_need_to_perform_commision}
    ...    is_pdl_checking_needed=${is_pdl_checking_needed}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${MODIFY_VIA_API_COUNTER}
    Set suite counter list

Update parameters which will cause bts restart via api
    [Documentation]    Author: Ren Biyao
    ...     This keyword is to modify parameters which will cause the reset of bts and to check that bts will be onair after reset.
    ...     :para${timeout_api_restart} is the timeout for getting the response from rest api method
    ...     :para${timeout_bts_ready} is timeout for waiting bts ready, eg, Wait ENB cell on air, GNB cell on air, X2 link status available.
    [Arguments]    ${parameters_to_update_via_api}    ${timeout_api_restart}=${TIMEOUT_REST_API_RESTART}    ${timeout_bts_ready}=${TIMEOUT_CLUSTER}
    Connect to gnb coam via ssl
    run keyword and ignore error     ssh.disconnect    connection=ASIK Master
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters_to_update_via_api}
    ...    timeout=${timeout_api_restart}
    Wait until cluster is on cell on air status    timeout=${timeout_bts_ready}    is_all_cells_checking_needed=${True}
    Connect to Capacity Unit Master

Set suite counter list
    [Documentation]    Author: Ren Biyao
    ...   RRC_RECONF_x_SCELL_UL/DL_ATT:Number of SgNB RRC Reconfiguration configuring x SCells in UL/DL
    ...   RRC_RECONF_x_SCELL_UL_SUCC:Number of successful SgNB RRC Reconfiguration configuring x SCells in UL/DL
    ...   M55118C02001    RRC_RECONF_1_SCELL_UL_ATT;  M55118C03001    RRC_RECONF_1_SCELL_UL_SUCC
    ...   M55118C02006    RRC_RECONF_4_SCELL_DL_ATT;  M55118C03006    RRC_RECONF_4_SCELL_DL_SUCC
    ...   M55118C02008    RRC_RECONF_5_SCELL_DL_ATT;  M55118C03008    RRC_RECONF_5_SCELL_DL_SUCC
    ...   M55118C02010    RRC_RECONF_6_SCELL_DL_ATT;  M55118C03010    RRC_RECONF_6_SCELL_DL_SUCC
    ...   M55118C02012    RRC_RECONF_7_SCELL_DL_ATT;  M55118C03012    RRC_RECONF_7_SCELL_DL_SUCC
    ...   UE_PSCELL_x_CONF_SCELL_UL/DL:Number of CA UEs in the current cell configured as a PSCell, which have x configured SCells in UL/DL
    ...                   interval  is 1s, it is for counting how many ues are attaching, if pm file generates every 5 min,
    ...                   and 1 ue is attach, this value should be 300.
    ...   UE_SCELL_x_CONF_SCELL_UL/DL:Number of successful SgNB RRC Reconfiguration configuring x SCell in UL/DL
    ...   M55118C04001    UE_PSCELL_1_CONF_SCELL_UL;  M55118C05001    UE_SCELL_1_CONF_SCELL_UL
    ...   M55118C04006    UE_PSCELL_4_CONF_SCELL_DL;  M55118C05006    UE_SCELL_4_CONF_SCELL_DL
    ...   M55118C04008    UE_PSCELL_5_CONF_SCELL_DL;  M55118C05008    UE_SCELL_5_CONF_SCELL_DL
    ...   M55118C04010    UE_PSCELL_6_CONF_SCELL_DL;  M55118C05010    UE_SCELL_6_CONF_SCELL_DL
    ...   M55118C04012    UE_PSCELL_7_CONF_SCELL_DL;  M55118C05012    UE_SCELL_7_CONF_SCELL_DL
    ...   SCELL_DL_ATT is to check msg: RRC Reconfiguration; SCELL_DL_SUCC is to check msg: RRC reconfiguration complete
    # GA counter to check
    @{list_RRC_RECONF_X_SCELL_ATT_counter}    create list   M55118C02001    M55118C02006    M55118C02008    M55118C02010    M55118C02012
    @{list_RRC_RECONF_X_SCELL_SUCC_counter}    create list   M55118C03001    M55118C03006    M55118C03008    M55118C03010    M55118C03012
    @{list_UE_PSCELL_X_CONF_SCELL_counter}   create list   M55118C04001    M55118C04006    M55118C04008    M55118C04010    M55118C04012
    @{list_UE_SCELL_X_CONF_SCELL_counter}   create list   M55118C05001    M55118C05006    M55118C05008    M55118C05010    M55118C05012
    set suite variable    ${LIST_RRC_RECONF_X_SCELL_ATT_COUNTER}    ${list_RRC_RECONF_X_SCELL_ATT_counter}
    set suite variable    ${LIST_RRC_RECONF_X_SCELL_SUCC_COUNTER}   ${list_RRC_RECONF_X_SCELL_SUCC_counter}
    set suite variable    ${LIST_UE_PSCELL_X_CONF_SCELL_COUNTER}   ${list_UE_PSCELL_X_CONF_SCELL_counter}
    set suite variable    ${LIST_UE_SCELL_X_CONF_SCELL_COUNTER}   ${list_UE_SCELL_X_CONF_SCELL_counter}
    #GF counter to check
    @{LIST_PSCELL_UE_X_ACT_SCELL_DL}    create list    M55316C05000    M55316C05001    M55316C05002    M55316C05003   M55316C05004
    ...    M55316C05005    M55316C05006    M55316C05007
    @{LIST_INTEREST_COUNTER_ID}    create list
    ...    M55316C05000    M55316C05001    M55316C05002    M55316C05003    M55316C05004    M55316C05005   M55316C05006    M55316C05007
    ...    M55316C03000    M55316C03001    M55316C03002    M55316C03003    M55316C03004   M55316C03005    M55316C03006    M55316C03007
    ...    M55316C01003
    @{LIST_MAX_PSCELL_UE_X_ACT_SCELL_DL}   create list    M55316C03000    M55316C03001    M55316C03002    M55316C03003    M55316C03004
    ...    M55316C03005    M55316C03006    M55316C03007
    set suite variable    ${LIST_PSCELL_UE_X_ACT_SCELL_DL}
    set suite variable    ${LIST_MAX_PSCELL_UE_X_ACT_SCELL_DL}
    set suite variable    ${LIST_INTEREST_COUNTER_ID}

Qcom attach UE and start traffic and check counter
     [Documentation]    Author: Ren Biyao
     ...    :para${call_duration} should be seconds, 600 stands for 600s.
     [Arguments]    ${call_duration}=600    ${cell_index_for_attach}=1    ${dl_tput_size}=2500    ${ul_tput_size}=100
     Switch pcell for attach based on cell index    cell_index_for_attach=${cell_index_for_attach}
     &{pre_case_time_info}    counter.calculate_waiting_time_for_log_capturing_or_log_generation    reporting_interval=5
     Sleep    ${pre_case_time_info['wait_time']} min
     Wait until PM counter file is genereated    timeout=2min
     ...    log_generate_timestamp=${pre_case_time_info['log_generator_timestamp']}
     &{case_start_time_info}    counter.calculate_waiting_time_for_log_capturing_or_log_generation    reporting_interval=5
     Wait until keyword succeeds    2X    10 s    Power ue attach
     ${traffic_time}    Evaluate    ${call_duration}*10
     Start data transfer based on direction    dl_tput=${dl_tput_size}   ul_tput=${ul_tput_size}   duration=${traffic_time}
     ...    data_transfer_direction=both
     Sleep    ${call_duration}s
     Connect to Capacity Unit Master
     &{case_stop_time_info}    counter.calculate_waiting_time_for_log_capturing_or_log_generation    reporting_interval=5
     sleep    ${case_stop_time_info['wait_time']} min
     ${remote_last_counter_file}    Wait until PM counter file is genereated    timeout=2min
     ...    log_generate_timestamp=${case_stop_time_info['log_generator_timestamp']}
     @{local_last_counter_file}   counter.download_pm_counter_files_to_test_pc    remote_file_path=${remote_last_counter_file}
     ...    local_file_folder=${TS_CASE_LOG_PATH}
     @{local_file_path}     Wait until PM counter file is genereated    timeout=2min
     ...    log_generate_timestamp=${case_start_time_info['log_generator_timestamp']}
     @{local_counter_file_path}    counter.download_pm_counter_files_to_test_pc    remote_file_path=${local_file_path}
    ...    local_file_folder=${TS_CASE_LOG_PATH}

     set test variable    ${COUNTER_FILE_PATH}    ${local_file_path}
     set_test_variable    ${LAST_COUNTER_FILE}    ${local_last_counter_file[0]}

Attach to pcells and do verification for configured IE
    [Documentation]    Author: Ren Biyao
    ...                Description:    ${cell_index_for_attach} is given as the cell which is chosen for ue attach, eg, 1, 2 ...
    ...                :para ${verification_type}  can be ca_enable, ca_disable, scell_number, scell_number&&drx_config, default type is scell_number
    ...                :default value ${UE_TYPE} is from keyword translate_power_ue_type_from_testline, and set as suite variable
    ...                :default value ${DRX_CONFIG} is set from 1726_NIDD_modify.py and it is dict type
    [Arguments]    ${cell_index_for_attach}    ${log_prefix}    ${log_dir_on_ute}=${TS_CASE_LOG_PATH}    ${verification_type}=scell_number
    ...    ${expected_dl_scell_number}=${7}    ${expected_ul_scell_number}=${1}     ${ue_type}=${UE_TYPE}    ${is_need_to_detach_ue}=${True}
    ...    ${drx_config}=&{DRX_CONFIG}
    Switch pcell for attach based on cell index    cell_index_for_attach=${cell_index_for_attach}
    log to console    Start X2 log capture from enb...
    ${log_full_path_enb}    Wait until keyword succeeds    3X    3 s    Start x2 trace capturing from enb    log_prefix=${log_prefix}
    log to console    Perform ue attach...
    Wait until keyword succeeds    2X    10 s    Power ue attach
    sleep    1s
    Stop Trace Capturing    log_prefix=${log_prefix}    connection_alias=ENB
    ${log_full_path_ute}    Download trace log    log_full_path=${log_full_path_enb}    log_dir_ute=${log_dir_on_ute}    connection_alias=ENB

    log to console    Perform ue detach...
    run keyword if    ${is_need_to_detach_ue}    power_ue.UE Detach    ue_type=${ue_type}
    run keyword if    '${verification_type}' == 'ca_disable'    run keyword and continue on failure
    ...    Verify CA is disabled in x2 log    file_path=${log_full_path_ute}
    ...    ELSE IF    '${verification_type}' == 'ca_enable'    run keyword and continue on failure
    ...    Verify CA is enabled in x2 log     file_path=${log_full_path_ute}
    ...    ELSE IF    '${verification_type}' == 'scell_number'    run keyword and continue on failure
    ...    Verify ul and dl scell number    file_path=${log_full_path_ute}
    ...    expected_ul_scell_number=${expected_ul_scell_number}    expected_dl_scell_number=${expected_dl_scell_number}
    ...    ELSE IF    '${verification_type}' == 'scell_number&&drx_config'    run keyword and continue on failure
    ...    run keywords    Verify ul and dl scell number    file_path=${log_full_path_ute}
    ...    expected_ul_scell_number=${expected_ul_scell_number}    expected_dl_scell_number=${expected_dl_scell_number}    AND
    ...    Verify drx config in x2 log    file_path=${log_full_path_ute}    drx_config=&{drx_config}
    ...    ELSE IF   '${verification_type}' == 'drx_config'    run keyword and continue on failure
    ...    Verify drx config in x2 log    file_path=${log_full_path_ute}    drx_config=&{drx_config}
    ...    ELSE    Fail    msg=Unsupported verification type!
   [Teardown]      run keyword and ignore error     run keywords    Stop Trace Capturing    log_prefix=${log_prefix}    connection_alias=ENB
   ...    AND    csn.execute         command=rm ${log_full_path_enb}    connection=ENB

Count element in pdml file
    [Arguments]     ${element_filter}    ${filter_expression}    ${element_attribute}=showname
    ...   ${pdml_format_file}=${None}    ${pcap_parser}=pcap_ue_id
    [Documentation]    Author: Ren Biyao
    ...                This keyword is used to verify the value in pcap file match the value set in bts.
    ...                ${pdml_format_file} is converted from pcap file.
    ...                ${filter_expression} is legal expression which can be applied in origial pcap file, eg, x2ap ...
    ...                ${element_filter} is the expression of the information element, eg .//nr-rrc.sCellToAddModList
    ...                ${element_attribute} is attribute of packet field, value can be "show", "value", or "showname",
    ${filtered_packets}    cap.filter_packets_by_expression
    ...    filter_expression=${filter_expression}    pcap_parser=pcap_ue_id
    ${content}    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=${element_filter}    attribute_name=${element_attribute}    pcap_parser=${pcap_parser}
    ${content_number}    get length    ${content}
    [Return]    ${content_number}

Verify CA is disabled in x2 log
    [Arguments]    ${file_path}
    [Documentation]    Author: Ren Biyao
    ${SgNB_add_req_ack_packets}    ${list_ue_id}    Get ue id list    file_path=${file_path}
    FOR    ${cur_ue_x2ap_id}   IN    @{list_ue_id}
           ${content_number}    Count element in pdml file    pdml_format_file=${SgNB_add_req_ack_packets}
           ...    element_filter=.//nr-rrc.sCellToAddModList    filter_expression=nr-rrc.newUE_Identity == ${cur_ue_x2ap_id}
           should be equal as integers    ${content_number}     ${0}
    END

Verify ul and dl scell number
    [Arguments]    ${file_path}   ${expected_ul_scell_number}    ${expected_dl_scell_number}
    [Documentation]    Author: Ren Biyao
    ${SgNB_add_req_ack_packets}    ${list_ue_id}    Get ue id list    file_path=${file_path}
    log to console    ${list_ue_id}
    FOR    ${cur_ue_x2ap_id}   IN    @{list_ue_id}
         ${actual_ul_number}    Count element in pdml file    pdml_format_file=${SgNB_add_req_ack_packets}
         ...    element_filter=.//nr-rrc.sCellConfigCommon_element/nr-rrc.uplinkConfigCommon_element
         ...    filter_expression=nr-rrc.newUE_Identity == ${cur_ue_x2ap_id}
         run keyword and continue on failure    should be equal as integers   ${actual_ul_number}    ${expected_ul_scell_number}
         ...    The ul scell number in pcap file is ${actual_ul_number}, while expect value is ${expected_ul_scell_number}.
         ${actual_dl_number}    Count element in pdml file    pdml_format_file=${SgNB_add_req_ack_packets}
         ...    element_filter=.//nr-rrc.sCellConfigCommon_element/nr-rrc.downlinkConfigCommon_element
         ...    filter_expression=nr-rrc.newUE_Identity == ${cur_ue_x2ap_id}
         run keyword and continue on failure    should be equal as integers   ${actual_dl_number}    ${expected_dl_scell_number}
         ...    The dl scell number in pcap file is ${actual_dl_number}, while expect value is ${expected_dl_scell_number}.
    END

Verify CA is enabled in x2 log
    [Arguments]    ${file_path}
    [Documentation]    Author: Ren Biyao
    ${SgNB_add_req_ack_packets}    ${list_ue_id}    Get ue id list    file_path=${file_path}
    FOR    ${cur_ue_x2ap_id}   IN    @{list_ue_id}
          ${content_number}    Count element in pdml file    pdml_format_file=${SgNB_add_req_ack_packets}
          ...    element_filter=.//nr-rrc.sCellToAddModList    filter_expression=nr-rrc.newUE_Identity == ${cur_ue_x2ap_id}
          should not be equal as integers    ${content_number}     ${0}
    END

Start x2 trace capturing from enb
    [Documentation]    Author: Ren Biyao
    [Arguments]     ${log_prefix}    ${retry_time}=2    ${interface}=br1     ${log_dir}=/tmp
    wait until keyword succeeds    10 min    10 sec    Connect to eNB
    ${trace_timestamp}    Get Current Date    result_format=%H%M%S
    ${log_name}    Set variable    ${log_prefix}_${trace_timestamp}.pcap
    ${log_full_path_enb}    join path    ${log_dir}    ${log_name}
    csn.send command    command=nohup tcpdump -i ${interface} -s 0 -w ${log_full_path_enb}     connection=ENB
    sleep    2s
    Trace capturing process should be triggered    log_prefix=${log_prefix}    connection_alias=ENB
   [Return]      ${log_full_path_enb}

WA of creating special test case directory
    [Documentation]   Author: Ren Biyao
    ...    COAM Create log directory will not be used because if the name contains [1] the convert of pdml will have some issue.
    ${test_case_name} =    replace string    string=${TEST NAME}    search_for=${SPACE}    replace_with=_
    ${test_case_name} =     remove string    ${test_case_name}    [1]
    ${case_log_path}    Join path    ${SUITE_LOG_PATH}    ${test_case_name}
    Set test variable    ${TS_CASE_LOG_PATH}    ${case_log_path}
    Create directory    ${TS_CASE_LOG_PATH}

Get ue id list
    [Documentation]   Author: Ren Biyao
    ...               This keyword is to get all ue ids from x2 log.
   [Arguments]    ${file_path}
    cap.load_pcap_file    pcap_file=${file_path}    tshark_path=${TSHARK_PATH}
    ...    command_template=${PDML_CONVERT_X2AP_TEMPLATE}    alias=pcap_ue_id
    ${SgNB_add_req_ack_packets}    cap.filter_packets_by_expression
    ...    filter_expression=x2ap.SgNBAdditionRequestAcknowledge_element    pcap_parser=pcap_ue_id
    ${list_ue_id}    cap.get_field_value_by_xpath    pdml_list=${SgNB_add_req_ack_packets}
    ...    xpath=.//nr-rrc.newUE_Identity    pcap_parser=pcap_ue_id
    [Return]    ${SgNB_add_req_ack_packets}    ${list_ue_id}

Verify drx config in x2 log
    [Arguments]    ${file_path}    ${drx_config}=&{DRX_CONFIG}
    [Documentation]    Author: Ren Biyao
    ...    This keyword has an assumption that all scells have the same configuration drx and &{DRX_CONFIG} is set from 1726_NIDD_modify.py.

    cap.load_pcap_file    pcap_file=${file_path}    tshark_path=${TSHARK_PATH}
    ...    command_template=${PDML_CONVERT_X2AP_TEMPLATE}    alias=pcap_drx_config
    ${SgNB_add_req_ack_packets}    ${list_ue_id}    Get ue id list    file_path=${file_path}
    log to console    ${list_ue_id}
    FOR    ${cur_ue_x2ap_id}   IN    @{list_ue_id}
         ${drx_Config_msg}     cap.get_field_value_by_xpath    pcap_parser=pcap_drx_config
         ...    xpath=.//nr-rrc.drx_Config    attribute_name=showname
         should not be empty     ${drx_Config_msg}    msg=nr-rrc.drx_Config does not exist, no need to check detailed configuration!
         ${drx_onDurationTimer}    cap.get_field_value_by_xpath    pcap_parser=pcap_drx_config
         ...    attribute_name=showname    xpath=.//nr-rrc.drx_onDurationTimer/nr-rrc.milliSeconds
         ${drx_onDurationTimer_value}    strip string    ${drx_config}[drxOnDurationTimer]    characters=mslot
         run keyword and continue on failure    should contain    ${drx_onDurationTimer[0]}     milliSeconds: ms${drx_onDurationTimer_value}
         ${drx_InactivityTimer}    cap.get_field_value_by_xpath    pcap_parser=pcap_drx_config
         ...    attribute_name=showname    xpath=.//nr-rrc.drx_InactivityTimer
         ${drx_InactivityTimer_value}    strip string    ${drx_config}[drxInactivityTimer]    characters=mslot
         run keyword and continue on failure    should contain     ${drx_InactivityTimer[0]}    drx-InactivityTimer: ms${drx_InactivityTimer_value}
         ${drx_LongCycle}    cap.get_field_value_by_xpath    pcap_parser=pcap_drx_config
         ...    attribute_name=showname    xpath=.//nr-rrc.drx_LongCycleStartOffset
         ${drx_LongCycle_value}    strip string    ${drx_config}[drxLongCycle]    characters=mslot
         run keyword and continue on failure    should contain     ${drx_LongCycle[0]}    drx-LongCycleStartOffset: ms${drx_LongCycle_value}
         ${drx_RetransTimerDl}    cap.get_field_value_by_xpath    pcap_parser=pcap_drx_config
         ...    attribute_name=showname    xpath=.//nr-rrc.drx_RetransmissionTimerDL
         ${drx_RetransTimerDl_value}    strip string    ${drx_config}[drxRetransTimerDl]    characters=mslot
         run keyword and continue on failure   should contain   ${drx_RetransTimerDl[0]}   drx-RetransmissionTimerDL: sl${drx_RetransTimerDl_value}
         ${drx_RetransTimerUl}    cap.get_field_value_by_xpath    pcap_parser=pcap_drx_config
         ...    attribute_name=showname    xpath=.//nr-rrc.drx_RetransmissionTimerUL
         ${drx_RetransTimerUl_value}    strip string    ${drx_config}[drxRetransTimerUl]    characters=mslot
         run keyword and continue on failure   should contain    ${drx_RetransTimerUl[0]}   drx-RetransmissionTimerUL: sl${drx_RetransTimerUl_value}
    END

Test case preparation
    [Documentation]   Author: Ren Biyao
    WA of creating special test case directory
    Connect to gnb coam via ssl
    Connect to Capacity Unit Master case

Attach to pcells and collect counter logs
    [Documentation]    Author: Ren Biyao
    ...             :default value${IS_POWER_UE_SUPPORTED} is set as suite variable
    [Arguments]    ${e500_script_path}=${None}    ${is_para_modifiation_cause_reset}=${False}
    ...    ${is_need_to_keep_ue_attach}=${False}    ${duration_of_ue_attach}=${None}    ${ue_index}=${0}
    log to console    Get the time on ASIK, wait for the start of next reporting interval
    &{pre_case_time_info}    counter.calculate_waiting_time_for_log_capturing_or_log_generation    reporting_interval=5
    Sleep    ${pre_case_time_info['wait_time']} min
    Wait until PM counter file is genereated    timeout=2min
    ...    log_generate_timestamp=${pre_case_time_info['log_generator_timestamp']}
    &{case_start_time_info}    counter.calculate_waiting_time_for_log_capturing_or_log_generation    reporting_interval=5

    ${log_full_path_enb}    Wait until keyword succeeds    3X    3 s    Start x2 trace capturing from enb    log_prefix=x2log_for_debug
    Power ue attach    is_need_to_keep_ue_attach=${is_need_to_keep_ue_attach}    duration_of_ue_attach=${duration_of_ue_attach}
    log to console    Collect pm files
    Stop Trace Capturing    log_prefix=x2log_for_debug    connection_alias=ENB
    ${x2log_for_debug}    Download trace log    log_full_path=${log_full_path_enb}    log_dir_ute=${TS_CASE_LOG_PATH}
    ...    connection_alias=ENB
    Connect to Capacity Unit Master
    &{case_stop_time_info}    counter.calculate_waiting_time_for_log_capturing_or_log_generation    reporting_interval=5
    sleep    ${case_stop_time_info['wait_time']} min
    @{remote_file_path}    Wait until PM counter file is genereated    timeout=2min
    ...    log_generate_timestamp=${case_start_time_info['log_generator_timestamp']}
    @{local_counter_file_path}    counter.download_pm_counter_files_to_test_pc    remote_file_path=${remote_file_path}
    ...    local_file_folder=${TS_CASE_LOG_PATH}
    Get Commercial UE IP    ue_index=${ue_index}
    log to console    UE IP captured after counter logs generate is ${UE_IP}
    cap.load_pcap_file    pcap_file=${x2log_for_debug}    tshark_path=${TSHARK_PATH}
    ...    command_template=${PDML_CONVERT_X2AP_TEMPLATE}    alias=pcap_ue_id

    ${scell_att_number}    Count element in pdml file    pcap_parser=pcap_ue_id
    ...    element_filter=x2ap//..//x2ap.SgNBAdditionRequestAcknowledge_element
    ...    filter_expression=x2ap

    ${scell_succ_number}    Count element in pdml file    pcap_parser=pcap_ue_id
    ...    element_filter=x2ap//..//x2ap.SgNBReconfigurationComplete_element
    ...    filter_expression=x2ap
    set test variable      ${SCELL_ATT_NUMBER}      ${scell_att_number}
    set test variable      ${SCELL_SUCC_NUMBER}     ${scell_succ_number}

    [Return]    @{local_counter_file_path}
    [Teardown]    run keyword and ignore error     run keywords
    ...    Connect to Capacity Unit Master     AND
    ...    Stop trace capturing    log_prefix=x2log_for_debug    connection_alias=ASIK Master

Expect one counter works while other counters remain idle
    [Documentation]    Author: Ren Biyao
    ...    This keyword is to check ${expect_work_counter_value} with ${expect_work_counter_id}, while value other counters remain 0.
    ...    ${list_all_interested_counter_ids}  refers to all the counter ids their values that the feature are
    ...             interested in checking,  list type: ['M55110C00009', 'M55110C000092]
    ...    ${attached_cell} is the cell which ue attached, and for 1726-GA counter cases, one cell will  be attached.
    ...    ${local_counter_log_path}: xml path
    [Arguments]     ${local_counter_log_path}   ${list_all_interested_counter_ids}    ${expect_work_counter_value}
    ...    ${expect_work_counter_id}       ${cell_id}     ${num_cells_with_expected_counter_work}

    ${cell_id}     string2list    ${cell_id}
    ${expect_work_counter_value}    string2list    ${expect_work_counter_value}
    ${cell_counters_dict}    get_cell_counters_from_file    file_path=${local_counter_log_path}
    ...    list_cell=${cell_id}    list_measurement_ids=${list_all_interested_counter_ids}

    check_one_expected_counter_works_for_each_cell    expect_counter_id=${expect_work_counter_id}
    ...    expect_counter_value=${expect_work_counter_value}    cell_id=${cell_id}
    ...    cell_counters_dict=${cell_counters_dict}
    ...    num_cells_with_expected_counter_work=${num_cells_with_expected_counter_work}

    check_several_counters_remian_idle_for_each_cell    list_all_interested_counter_ids=${list_all_interested_counter_ids}
    ...    expect_work_counter_id=${expect_work_counter_id}    cell_id=${cell_id}
    ...    cell_counters_dict=${cell_counters_dict}

Import NIDD variables
    [Documentation]  Author: Wang Yixiang
    ...              This keyword is to set several variables by program.
    [Arguments]    ${if_vonr_conf_needed}=${False}
    ${cur_program}    gnb_classical_hangzhou.Get program version based on stream version
    set suite variable    ${PROGRAM}    ${cur_program}
    import variables   ${CURDIR}/../TestData/1726_NIDD_modify.py
    import variables    ${CURDIR}/../TestData/1726_SCF_modify.py

Start data transfer with high or low throughput and verify behaviours
    [Documentation]    Author: Ding Binmei
    ...                Description: Verify behaviours changes when data transfer change from high througput to low throughput
    ...                             or from low througput to high throughput
    ...                             Will do log capturing and verify for ${REPEAT_TIME_FOR_VERIFICATION} times
    ...                :para${traffic_time}, in seconds unit, eg, 600 stands for 600 seconds
    [Arguments]      ${dl_tput_iperf}    ${ul_tput_iperf}=20M    ${ue_type}=${UE_TYPE}
    ...    ${expected_ul_tput}=${UL_TPUT_EXPECT}   ${expected_dl_tput}=${20}    ${nr_cell_id_mapping}=${NR_CELL_ID_MAPPING}

    Start data transfer based on direction     dl_tput=${dl_tput_iperf}    ul_tput=${ul_tput_iperf}    duration=3000s
    ${tput_log}    power_ue.Collect Tput     ue_type=${ue_type}    duration=5m   ignore_time=30s    filter=L2Lo
    run keyword and ignore error     Connect to Appserver and check iperf process
    ${info}   get dictionary values    ${nr_cell_id_mapping}
    ${list_of_cell_ids}    create list
    FOR    ${cur_info}    IN    @{info}
           ${cur_nridentiity}    set variable   ${cur_info}[nrCellIdentity]
           ${cur_nridentiity}   convert to string    ${cur_nridentiity}
           append to list    ${list_of_cell_ids}   ${cur_nridentiity}
    END
    power_ue.Check Bi Tput
    ...    ue_type=${ue_type}   log=${tput_log}    cells=${list_of_cell_ids}    min_percent=0.8
    ...    ultarget_throughput=${expected_ul_tput}   dltarget_throughput=${expected_dl_tput}    actCarrierAggregation=${True}
    [Teardown]  Run keyword and ignore error    wait until keyword succeeds    3x    5s
    ...    Stop data transfer based on direction    data_transfer_direction=both

Verify behaviours when start traffic with high or low throughput
    [Documentation]    Author: Ding Binmei
    ...                Description: Capturing logs and do verifications as bellow:
    ...                             1. throughput is maintained
    ...                             2. Bler is as expected
    ...                             3. numbers of cells changes when traffic is low or high
    ...                             4. Check_DL_HARQ_feedbacks_are_received_successfully
    ...                             5. max data rate as indicated by UE capability is not exceeded in any slot
    ...                ${exp_cells_num_ul}: can only be num
    ...                ${exp_cells_num_dl}: can be a num or a string with format like 3,4:
    ...                                     it means 3 or 4 number of cells are used for dl transmission
    [Arguments]      ${expect_scheduled_scell_num}
    ...    ${expected_ul_tput}     ${expected_dl_tput}    ${nr_cell_id_mapping}
    ...    ${exp_cells_num_ul}=1-8    ${exp_cells_num_dl}=1-8
    ...    ${max_retry_time}=5    ${gnb_index}=0
    ...    ${asik_alias}=ASIK Master    ${duration}=3s    ${local_log_folder}=${TS_CASE_LOG_PATH}
    ...    ${deviation}=0.2
    ${time_stamp_start}    DateTime.get current date    result_format=epoch    exclude_millis=True
    ${tput_check}    join path   ${local_log_folder}   Tput_check_${time_stamp_start}
    create directory     ${tput_check}
    @{list_tput_info}    Create list
     AAsys log captrue    stop_aasys_flag=${True}   timeout=20s    log_name=Tput_ul_dl.txt
     Wait until keyword succeeds    1 min    10 sec    Connect to Common Unit Master
     @{tput_file_list}    Split tput log to ul and dl files
     &{dict_local_tput_file_path}    Download tput file to test pc    ul_dl_tput_file_paths_gnb=${tput_file_list}
     ...    local_log_folder=${tput_check}

    run keyword and ignore error     Stop data transfer based on direction
     ${list_dl_cell}    string2list    ${exp_cells_num_dl}
     ${list_ul_cell}    string2list    ${exp_cells_num_ul}

     ${ul_tput_avg}   ${ul_tput_max}   ${ul_tput_min}   ${ul_detail_peak_tput_info}
    ...    verify_tput.get_details_of_peak_tput_all_cells   tput_file=${dict_local_tput_file_path['UL_L2LO']}
    ...    list_cell=${list_ul_cell}    nr_cell_id_mapping=${NR_CELL_ID_MAPPING}
     ${dl_tput_avg}   ${dl_tput_max}   ${dl_tput_min}   ${dl_detail_peak_tput_info}
     ...    verify_tput.get_details_of_peak_tput_all_cells   tput_file=${dict_local_tput_file_path['DL_L2LO']}
     ...    list_cell=${list_dl_cell}    nr_cell_id_mapping=${NR_CELL_ID_MAPPING}
     &{dict_tput_info}    Create dictionary
     Set to dictionary    ${dict_tput_info}    timestamp=${time_stamp_start}
     Set to dictionary    ${dict_tput_info}    ul_tput_peak_all_cells_avg=${ul_tput_avg}
     Set to dictionary    ${dict_tput_info}    ul_tput_peak_all_cells_max=${ul_tput_max}
     Set to dictionary    ${dict_tput_info}    ul_tput_peak_all_cells_min=${ul_tput_min}
     Set to dictionary    ${dict_tput_info}    dl_tput_peak_all_cells_avg=${dl_tput_avg}
     Set to dictionary    ${dict_tput_info}    dl_tput_peak_all_cells_max=${dl_tput_max}
     Set to dictionary    ${dict_tput_info}    dl_tput_peak_all_cells_min=${dl_tput_min}
     set to dictionary    ${dict_tput_info}    ul_tput_peak_all_cells_details=${ul_detail_peak_tput_info}
     set to dictionary    ${dict_tput_info}    dl_tput_peak_all_cells_details=${dl_detail_peak_tput_info}
     Log to console    tput info: ${dict_tput_info}
     Append to list    ${list_tput_info}    ${dict_tput_info}
    ${csv_log_file_path}    Join path    ${tput_check}    tput_records_${time_stamp_start}.csv
    export_to_csv.write_data_to_csv    input_data=${list_tput_info}    csv_file_path=${csv_log_file_path}
    ${min_expect_ul_tput}    evaluate    ${expected_ul_tput}-${expected_ul_tput}*${deviation}
    Run keyword and continue on failure    Should be true    ${ul_tput_avg}>=${expected_ul_tput}
    Run keyword and continue on failure    Should be true    ${ul_tput_min}>=${min_expect_ul_tput}
    Run keyword and continue on failure    Should be true    ${dl_tput_avg}>=${expected_dl_tput}
    [Teardown]  Run keyword and ignore error    Run keywords
    ...    Stop data transfer based on direction     AND
    ...    check_average_throughput.stop_tput_aasyslog_capturing    asik_alais=${asik_alias}
