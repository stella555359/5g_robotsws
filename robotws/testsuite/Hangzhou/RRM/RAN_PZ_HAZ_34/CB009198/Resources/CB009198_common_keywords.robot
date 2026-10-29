*** Settings ***
Documentation    CA Feature CB009198 Automation cases common steps
...              Author: jun.8.chen@nokia-sbell.com

Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/Resources.robot




*** Keywords ***
#---9198 Setup And TearDown---#
9198_Suite_Setup
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    run keyword and ignore error    Check And Power on RUs
    robot_common_operations.Common Suite Setup
    CI_interface.Common Suite Setup
    Upload Swconfig File
    @{ue_num}    Set Variable    ${tl.ues}
    ${ue_length}    Get Length    ${ue_num}
    Set Suite Variable    ${ue_length}
    ${ute_env}    Run Keyword And Return Status    Run Keywords
    ...    Variable Should Exist    ${CONFIGURATION}    AND    Variable Should Exist    ${ENB_BUILD}
    ${testline}   Run Keyword If    ${ute_env}    String.Fetch From Right    string=${CONFIGURATION}    marker=.
    ...           ELSE    Set Variable     ${testline_name}
    Set Suite Variable    ${testline_name}    ${testline}
    Common_setup_and_teardown.Suite Common SetUp    is_commission=${False}
    Kill Adb App
    Adb Reboot UE And Verify
    Initial PA Value Setting For All Attenuators

9198_Case_Setup
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_index}=0
    robot_common_operations.Common Case Setup    fail_with_alarms=${False}
    ${gnb_allowed_fault_Before_Commission}   Create List    4203    1838    4741    4681   7311   7331
    ...                                                     4293    4297    4420    4775   1932   1934    1933
    Set Test Variable    ${gnb_allowed_fault_Before_Commission}
    AlarmWatchdog.add_allow_alarms    fault_id=${gnb_allowed_fault_Before_Commission}
    ${basic_scf_path_for_ute}    Get Basic SCF File Path
    CaseSetup.Common Initialization    ue_index=${ue_index}
    ...                                extract_case_info_from_data_file=${True}
    ...                                specific_scf_file_path=${basic_scf_path_for_ute}
    ...                                TESTCASE_INFO_MAPPING_TABLE=${TESTCASE_INFO_MAPPING_TABLE_9198}
#    Run Keyword If    '${ue_type}'=='qct_dx50'    Change Network Mode For QXDM    ue_type=${ue_type}
#    ...                                                                           ue_index=${ue_index}
#    ...                                                                           prefer_5g_nr_mode=${mode}
    ${summary_alarm_info}    Get Active Alarms And Save Summary Infomation
    Set Test Variable    ${summary_alarm_info}
    [Teardown]    Teardown Multi gNb Connections

9198_Case_Teardown
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    Run Keyword And Continue On Failure    robot_common_operations.Common Case Teardown
    Run Keyword And Ignore Error    Initial PA Value Setting For All Attenuators
    Run Keyword And Ignore Error    Stop Traffic With Power UE
    Run Keyword And Ignore Error    Close the iperf process on android ue    ue_index=${0}    iperf_port=${UL_PORT}
    Run Keyword And Ignore Error    Close the iperf process on APPserver    port=${DL_PORT}
    Run Keyword And Ignore Error    Stop Aasyslog And Download To TestPC    log_prefix=aasyslog
    Run Keyword And Ignore Error    Common Case Teardown    is_save_snapshot=False
    Run Keyword And Ignore Error    Make To Capture Snapshot
    Check Whether New Alarm Happened During Running Case    alarm_info_before=${summary_alarm_info}

Check And Power on RUs
    [Arguments]    ${gnb_index}=${0}    ${du_index}=${0}
    ${ru_numbers}    get length    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus}
    log to console    ru_numbers: ${ru_numbers}
    FOR    ${index}    IN RANGE    0    ${ru_numbers}
        ${model}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${index}].pdu_port.pdu.__class__.__name__}
        ${address}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${index}].pdu_port.pdu.addr}
        ${port}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${index}].pdu_port.port_no}
        ${ru_index}    evaluate    ${index}+1
        log to console    for ru ${ru_index}, model is ${model}, pb ip is ${address}, pb port is ${port}
        pdu.Setup Pdu    model=${model}   host=${address}    alias=pdu_ru_${ru_index}
        ${port_status}    pdu.Get Port Status    port=${port}    pdu_device=pdu_ru_${ru_index}
        log to console    port status of ru ${ru_index} is ${port_status}
        run keyword if    '${port_status}'=='off'    pdu.power on    port=${port}    pdu_device=pdu_ru_${ru_index}
        sleep    5s
    END

Make To Capture Snapshot
    Connect to gnb coam via ssl    connection=GNB_OAM0  gnb_index=0
    run keyword and ignore error    COAM Save snapshot via rest api    connection=GNB_OAM0    timeout=30min
    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=GNB_OAM0

Change Network Mode For QXDM
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_type}    ${ue_index}=${0}    ${is_prepare_ue_needed}=${True}    ${prefer_5g_nr_mode}=SA
    ...    ${network_mode_switch_method}=${tl.ues[${ue_index}].network_mode_switch_method}
    ...    ${mobile_network_text}=${tl.ues[${ue_index}].mobile_network_text}
    ...    ${setting_network_mode_text}=${tl.ues[${ue_index}].setting_network_mode_text}
    Run Keyword If   ${is_prepare_ue_needed}    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    Run Keyword And Ignore Error    android_common_keyword.Ue attach with index    ue_index=${ue_index}
    ${network_mode}    Set Variable If    '${prefer_5g_nr_mode}'=='SA'    NR only
    ...                                   '${prefer_5g_nr_mode}'=='NSA'    NR/LTE
    ...                                   '${prefer_5g_nr_mode}'=='NSA+SA'    NR/LTE
    ...                                   '${prefer_5g_nr_mode}'=='LTE'    LTE
    ...                                   Un_supported
    ${validate_net_mode_text}    Set Variable If    '${network_mode}'=='NR/LTE'    Preferred network mode: NR / LTE
    ...                                             '${network_mode}'=='NR only'    Preferred network mode: NR only
    ...                                             '${network_mode}'=='LTE'    LTE
    ...                                             Un_supported
    ${is_network_mode_as_expected}    Is network mode as expected    exp_net_mode=${validate_net_mode_text}    ue_index=${ue_index}
    ...    network_mode_switch_method=${network_mode_switch_method}    mobile_network_text=${mobile_network_text}
    ...    setting_network_mode_text=${setting_network_mode_text}
    Run Keyword If   ${is_network_mode_as_expected}
    ...    Log To Console    cur network mode is ${network_mode} which is as expected. No need to switch.
    ${swicth_mode_status}    Run Keyword If    ${is_network_mode_as_expected}==${FALSE}    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    2X    2s    android_common_keyword.Change network mode on UE    net_mode=${network_mode}
    ...        validate_net_mode_text=${validate_net_mode_text}    ue_index=${ue_index}
    Run Keyword If    ${is_network_mode_as_expected}==${FALSE}    Should Be True    ${swicth_mode_status}
    [Teardown]    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

Upload Swconfig File
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${swconfig_path}=${CURDIR}/swconfig.txt    ${connection}=GNB_OAM
    ...            ${gnb_index}=${0}    ${du_index}=${0}    ${alias}=swconfig
    Log    ${connection}
    Connect to Common Unit Master    gnb_index=${gnb_index}    du_index=${du_index}    alias=${alias}
    ssh.Force Reconnect    connection=${alias}
    Log To Console    Start update Swconfig file.
    swconf.Upload swConfig file to asik and crasign    localFilePath=${swconfig_path}    asik_alias=${alias}
    csn.disconnect    connection=${alias}

Get Basic SCF File Path
    [Documentation]   Author: jun.8.chen@nokia-sbell.com
    ${SCF_Path}    ${result}    Split String From Right    ${CURDIR}    testsuite     1
    ${ute_env}    Run Keyword And Return Status    Run Keywords
    ...    Variable Should Exist    ${CONFIGURATION}    AND    Variable Should Exist    ${ENB_BUILD}
    ${tmp_testline}   Run Keyword If    ${ute_env}    String.Fetch From Right    string=${CONFIGURATION}    marker=.
    ...           ELSE    Set Variable     ${testline_name}
    ${stream}    ${build}     Run Keyword If    ${ute_env}    CI_commssion._Get Stream From Variable    ${ENB_BUILD}
    ...    ELSE   CI_commssion._Get Stream From Variable    ${AF_PATH}
    ${basic_scf_path}    Set Variable    ${SCF_PATH}commissionings/HGZ/${tmp_testline}/SCF_${stream}.xml
    [Return]    ${basic_scf_path}

Procedures.Stop Traffic And Detach
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}
    Run Keyword And Ignore Error    Close the iperf process on android ue    ue_index=${ue_index}    iperf_port=${UL_PORT}
    Run Keyword And Ignore Error    Close the iperf process on APPserver    port=${DL_PORT}
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

CaseSetup.Common Initialization
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_index}=0
    ...            ${running_gnb}=0
    ...            ${specific_scf_file_path}=${None}
    ...            ${extract_case_info_from_data_file}=${False}
    ...            ${specific_update_params_dict}=&{EMPTY}
    ...            ${TESTCASE_INFO_MAPPING_TABLE}=${None}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Test Variable    ${ue_type}
    Log To Console    ue index is ${ue_index} , ue type is ${ue_type}
    ${tl_prefix}    Set Variable    ${testline_name.split('_')[-1][-4:]}
    Set Test Variable    ${TL_NAME}    ${tl_prefix}
    Log To Console    testline is ${TL_NAME}
    ${test_case_id}    Evaluate    '_'.join(${TEST NAME.split('_')[1:3]})
    Set Test Variable    ${TESTCASE_ID}    ${test_case_id}
    ${running_gnb}    Set Variable If    ${extract_case_info_from_data_file}
    ...    ${TESTCASE_INFO_MAPPING_TABLE['${TESTCASE_ID}']['${TL_NAME}']['running_gnb']}
    ...    ${running_gnb}
    Set Test Variable    ${RUNNING_GNB_ID}    ${running_gnb}
    Log To Console    running gnb is: gnb${RUNNING_GNB_ID}
    ${scf_file_path}    Set Variable If    '${specific_scf_file_path}'=='${None}'
    ...                                    /home/ute/SCF/GNB${RUNNING_GNB_ID}_BASIC_GOLDEN_SCF_${STREAM_VERSION}.xml
    ...                                    ${specific_scf_file_path}
    Log To Console    commission scf file path is : ${scf_file_path}
    ${case_update_params_dict}   Set Variable If    ${extract_case_info_from_data_file}
    ...    ${TESTCASE_INFO_MAPPING_TABLE['${TESTCASE_ID}']['${TL_NAME}']}
    ...    ${specific_update_params_dict}
    Log To Console    update params:${case_update_params_dict}
#    COAM Create log directory
    Common_setup_and_teardown.Case Common SetUp   gnb_index=${RUNNING_GNB_ID}
    ...                                           update_param_name=${case_update_params_dict}
    ...                                           scf_file_path=${scf_file_path}
    Initial PA Value Setting For Required RU    gnb_id=${RUNNING_GNB_ID}    all_ru_need_to_modify=${False}
    [Teardown]    Teardown Multi gNb Connections

Procedures.Basic Attach L3 Call Test
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${mode}=SA    ${ue_index}=${0}    ${gnb_index}=0    ${enb_index}=0    ${coam_connection}=GNB_OAM
    ...            ${du_index}=0    ${tput_collect_duration}=120    ${data_transfer_duration}=900
    ...            ${expect_addition_scell_indexs}=${None}    ${expect_tp_percent}=1
    ...            ${check_pcell_tput_type}=peak   ${check_ul_pcell_tput_type}=peak    ${check_scell_tput_type}=peak
    ...            ${target_DL_avg_percent}=0.9    ${target_UL_avg_percent}=0.9
    ...            ${min_DL_percent}=0.2    ${min_UL_percent}=0.2    ${min_scell_percent}=0.2
    ...            ${dl_data_transfer}=1800M    ${ul_data_transfer}=200M
    ...            ${is_vonr_call_needed}=${False}    ${is_vonr_ip_exist}=${False}
    ...            ${is_do_require_ue}=${True}
    ...            ${check_scell_tput}=${False}    ${scell_mapping}=${None}
    ...            ${inactivate_scell_index_list}=@{EMPTY}
    ...            ${auto_required_dl_tput_layers}=${True}
    ...            ${wireshark_check_point}=${True}    ${mappingtype}=typeB
    ...            ${whether_check_ptrs}=${False}    ${ptrs}=ptrs
    ...            ${input_attach_cell_index}=1
    Log To Console    \n****** start to attach and verify L3 call ******\n
    Log Many    ${du_index}    ${expect_addition_scell_indexs}    ${expect_tp_percent}
    Comment    \n****** step0:some additional operations before attach ******\n
    Run Keyword If    '${mode}'=='NSA'    Modify PA Value Of ENB
    Run Keyword If    '${mode}'=='NSA'    Change cellBarred Parameter Value On Gnb    pcell_index=all    exp_status=barred
    Comment    \n****** step1:start to attach with specific UE type ******\n
#    Run Keyword And Ignore Error    Do ADB Reboot    ue_index=${ue_index}
    Run keyword if    ${is_do_require_ue}    Procedures.UE Prepare    ue_index=${ue_index}    ue_type=${ue_type}
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}
    ${attach_info}    Procedures.UE Attach    wireshark_log_prefix=ca_attach
    ...                                       ue_mode=${mode}
    ...                                       ue_type=${ue_type}
    ...                                       coam_connection=${coam_connection}
    ...                                       ue_index=${ue_index}
    ...                                       gnb_index=${gnb_index}
    ...                                       enb_wireshark_log_prefix=enb_wireshark_log
    ...                                       enb_index=${enb_index}
    ...                                       sleep_interval=5 sec
    ...                                       4G_check=${False}
    ...                                       input_attach_cell_index=${input_attach_cell_index}
    Log To Console    ${attach_info}
    Comment    \n****** step2:generate pcell mapping result: ${PCELL_MAPPING} ******\n
#    Generate Pcell Mapping Info    pcell_index=${attach_info['attach_cell_index']}    source_gnb_id=${gnb_index}
    Comment    \n****** step3(Optional):check scell activatation success if activation method is blind ******\n
    ${status}    ${attach_aasyslog_list}    Run Keyword And Ignore Error    Stop Aasyslog And Download To TestPC    log_prefix=5Grach
    Comment    \n****** step4:get pcell belonged ru index  ******\n
    ${pcell_ru_index}    Set Variable    ${PCELL_MAPPING['ru_index_mapping']}
    Comment    \n****** step5 start ul/dl data transfer   ******\n
    ${need_get_ue_ip}    Set Variable If    '${ue_type}'=='qct_dx50' or ${is_vonr_ip_exist}    ${True}    ${False}
    ${cpif_log_path}    Set Variable If    '${mode}'=='NSA'    ${attach_info['enb_wireshark_log_path']}
    ...                                                        ${attach_info['cpif_log_path']}
    ${dl_layers_dict}    Run Keyword If    ${auto_required_dl_tput_layers}    Get DL Tput Layers For Pcell From Wireshark
    ...                                                                       cpif_log_path=${cpif_log_path}
    ...                                                                       mode=${mode}
    ...                                                                       alias=parser
    Start L3 Call Data Transfer For 9198    ul_data_transfer=${ul_data_transfer}
    ...                                     dl_data_transfer=${dl_data_transfer}
    ...                                     duration=${data_transfer_duration}
    ...                                     need_get_ue_ip=${need_get_ue_ip}
    ...                                     cpif_log_path=${cpif_log_path}
    ...                                     mode=${mode}
    ...                                     ue_index=${ue_index}
    Comment    \n****** step6(Optional):start vonr call if vonr case  ******\n
    Run Keyword If    ${is_vonr_call_needed}    Procedures.Vonr Call Setup Test     gnb_index=${gnb_index}    ue_index=${ue_index}
    Comment    \n****** step7:check ul/dl tput  ******\n
    ${cpif_checkpoint_log}    Run Keyword If    ${wireshark_check_point}    Trigger Transprecoding And Capture CPIF Log
    ...    ru_index=${pcell_ru_index}
    Run Keyword And Continue On Failure        Check Tput For CA Group
    ...                                    ue_type=${ue_type}
    ...                                    gnb_index=${gnb_index}
    ...                                    duration=${tput_collect_duration}
    ...                                    check_pcell_tput_type=${check_pcell_tput_type}
    ...                                    check_scell_tput_type=${check_scell_tput_type}
    ...                                    target_DL_avg_percent=${target_DL_avg_percent}
    ...                                    target_UL_avg_percent=${target_UL_avg_percent}
    ...                                    min_DL_percent=${min_DL_percent}
    ...                                    min_UL_percent=${min_UL_percent}
    ...                                    min_scell_percent=${min_scell_percent}
    ...                                    check_ul_pcell_tput_type=${check_ul_pcell_tput_type}
    ...                                    check_scell_tput=${check_scell_tput}
    ...                                    scell_mapping=${scell_mapping}
    ...                                    inactivate_scell_index_list=${inactivate_scell_index_list}
    ...                                    auto_required_dl_tput_layers=${auto_required_dl_tput_layers}
    Comment    \n****** step8(Optional):start vonr call if vonr case  ******\n
    Run Keyword If    ${is_vonr_call_needed}    Run Keyword And Continue On Failure
    ...    Procedures.Vonr Call Release Test     gnb_index=${gnb_index}    ue_index=${ue_index}
    Run Keyword If    ${wireshark_check_point}    Run Keyword And Continue On Failure
    ...    Verify Checkpoint Via Wireshark    log_path=${cpif_checkpoint_log}
    ...                                                                              mappingtype=${mappingtype}
    ...                                                                              mode=${mode}
    Run Keyword If    ${whether_check_ptrs}    Run Keyword And Continue On Failure
    ...    Verify Whether Ptrs Is Exist    log_path=${attach_info['cpif_log_path']}    ptrs=${ptrs}
    Comment    \n****** step9:return detailed pcell and scell related info dict during attach ******\n
    ${attach_ca_cell_info_dict}    Create Dictionary    pcell_index=${attach_info['attach_cell_index']}
    ...                                                 source_gnb_id=${gnb_index}
    ...                                                 pcell_ru_index=${pcell_ru_index}
    ...                                                 attach_cpif_log=${attach_info['cpif_log_path']}
    ...                                                 cpif_checkpoint_log=${cpif_checkpoint_log}
    [Return]    ${attach_ca_cell_info_dict}
    [Teardown]    Run Keyword If    ${is_vonr_call_needed}    Run keyword and ignore error     Hang Up Vonr Call    ue_index=${ue_index}

Start L3 Call Data Transfer For 9198
    [Documentation]    Author:stella.lin@nokia-sbell.com
    ...                 this keyword start ul&dl traffic
    [Arguments]     ${ul_data_transfer}=20M
    ...             ${dl_data_transfer}=180M
    ...             ${duration}=600
    ...             ${ue_index}=${0}
    ...             ${cap_index}=${0}
    ...             ${buffer_size}=${DATA_LENGTH}
    ...             ${cap_index}=${0}
    ...             ${apn_address}=wap1nokiacom
    ...             ${need_get_ue_ip}=${False}
    ...             ${cpif_log_path}=${None}
    ...             ${is_multi_pdu}=${False}
    ...             ${ue_iperf_path}=iperf
    ...             ${mode}=SA
    ...             ${ue_ip_type}=data
    ...             ${dl_process_num}=2
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${iperf_type}    Set Variable If    '${ue_type}' == 'samsung'     via_command    via_app
    ${start_traffic_duration}    set variable if    'lg' in '${ue_type}'    ${duration}s    ${duration}
    ${DL_PORT}=    Get Variable Value    ${DL_PORT}    default
    ${UL_PORT}=    Get Variable Value    ${UL_PORT}    default
    ${need_get_ue_ip}    Set Variable If    ${is_multi_pdu}    ${True}    ${need_get_ue_ip}
    ${dl_data_value}    get regexp matches    ${dl_data_transfer}    \\d+.*\\d+
    ${dl_data_unit}    get regexp matches    ${dl_data_transfer}    [^\\d+]+
    ${target_dl_data_value}    Evaluate    int(${dl_data_value}[0]/${dl_process_num})
    ${dl_data_transfer_1}     Set Variable     ${target_dl_data_value}${dl_data_unit}[0]
    Run Keyword If    ${need_get_ue_ip}    Start Data Transfer With UE IP Required For 9198
    ...                                    cpif_log_path=${cpif_log_path}
    ...                                    dl_port=${DL_PORT}
    ...                                    ul_port=${UL_PORT}
    ...                                    ue_index=${ue_index}
    ...                                    dl_data_transfer=${dl_data_transfer}
    ...                                    ul_data_transfer=${ul_data_transfer}
    ...                                    duration=${start_traffic_duration}
    ...                                    is_multi_pdu=${is_multi_pdu}
    ...                                    ue_iperf_path=${ue_iperf_path}
    ...                                    mode=${mode}
    ...                                    ue_ip_type=${ue_ip_type}
    ...                                    dl_process_num=${dl_process_num}
    ...    ELSE    Run Keywords    power_ue.Start traffic
    ...                            ue_type=${ue_type}
    ...                            direction=dl
    ...                            throughput=${dl_data_transfer_1}
    ...                            duration=${start_traffic_duration}
    ...                            iperf_port=${DL_PORT}
    ...                            ue_index=${ue_index}
    ...                            cap_index=${cap_index}
    ...                            buffer_size=${buffer_size}
    ...                            dt_name=dt_dl
    ...                            apn_address=${apn_address}
    ...                            process_num=${dl_process_num}                   AND    power_ue.Start traffic    ue_type=${ue_type}
    ...                                                                                           direction=ul
    ...                                                                                           throughput=${ul_data_transfer}
    ...                                                                                           duration=${start_traffic_duration}
    ...                                                                                           iperf_port=${UL_PORT}
    ...                                                                                           ue_index=${ue_index}
    ...                                                                                           cap_index=${cap_index}
    ...                                                                                           buffer_size=${buffer_size}
    ...                                                                                           dt_name=dt_ul
    ...                                                                                           iperf_type=${iperf_type}
    ...                                                                                           apn_address=${apn_address}

Start Data Transfer With UE IP Required For 9198
    [Documentation]    Author:stella.lin@nokia-sbell.com
    ...                For senario : 1. without attach  2. multi-PDU
    [Arguments]    ${cpif_log_path}    ${dl_port}    ${ul_port}    ${ue_index}
    ...            ${dl_data_transfer}=180M    ${ul_data_transfer}=50M    ${duration}=600
    ...            ${is_multi_pdu}=${False}    ${ue_iperf_path}=iperf    ${mode}=SA    ${ue_ip_type}=data
    ...            ${dl_process_num}=2
    ${dl_data_value}    get regexp matches    ${dl_data_transfer}    \\d+.*\\d+
    ${dl_data_unit}    get regexp matches    ${dl_data_transfer}    [^\\d+]+
    ${target_dl_data_value}    Evaluate    int(${dl_data_value}[0]/${dl_process_num})
    ${dl_data_transfer}     Set Variable     ${target_dl_data_value}${dl_data_unit}[0]
    Run Keyword And Continue On Failure    Start UL traffic via iperf from andriod UE    ue_index=${ue_index}
    ...                                                                                  ul_time=${DATA_TIME}
    ...                                                                                  ul_port=${ul_port}
    ...                                                                                  ul_throughput=${ul_data_transfer}
    ...                                                                                  ul_length=${DATA_LENGTH}
    ...                                                                                  iperf_path=${ue_iperf_path}
    ${ue_ip_dict}    Wait Until Keyword Succeeds    3X    10sec
    ...    Get ALL PDU IP Address From Wireshark For 9198    cpif_log_path=${cpif_log_path}    is_multi_pdu=${is_multi_pdu}    mode=${mode}
    ${ue_ip}    Set Variable    ${ue_ip_dict['${ue_ip_type}']}
    wait until keyword succeeds    1 min    10 sec    Connect to APPserver
    ${dl_command}    Set Variable
    ...    iperf -c ${ue_ip} -u -t ${duration} -i 1 -p ${dl_port} -P ${dl_process_num} -f m -b ${dl_data_transfer} -l ${DATA_LENGTH} -T 64 &
    Run Keyword And Continue On Failure    csn.send command
    ...    command=${dl_command}
    ...    connection=APPserver
    [Teardown]    Run keyword and ignore error    csn.disconnect    connection=APPserver

Get ALL PDU IP Address From Wireshark For 9198
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    ...               get pdu ip addr in message <InitialContextSetupRequest,DL NAS transport,pdu session establishment accept>
    ...               message filter: ngap.procedureCode == 14 && nas_5gs.sm.pdu_addr_inf_ipv4
    ...               If MultiPdu is configured, second pdu ip addr can be get from message <PDUSessionResourceSetupRequest>
    ...               message filter: ngap.procedureCode == 29 &&  nas_5gs.sm.pdu_addr_inf_ipv4
    ...               return dict：{ims:xx,data:xx}
    [Arguments]    ${cpif_log_path}    ${is_multi_pdu}=${False}    ${alias}=parser    ${mode}=SA
    Log    ${is_multi_pdu}
    ${first_pdu_ip_message_filter}    Set Variable If     '${mode}'=='SA'    ngap.procedureCode == 14 && nas-5gs.sm.pdu_addr_inf_ipv4
    ...                                                                      s1ap.procedureCode == 9 && nas-eps.esm.pdn_ipv4
    ${second_pdu_ip_message_filter}    Set Variable If     '${mode}'=='SA'    ngap.procedureCode == 29 && nas-5gs.sm.pdu_addr_inf_ipv4
    ...                                                                       s1ap.procedureCode == 19 && nas-eps.esm.pdn_ipv4
    ${pdu_ip_xpath}    Set Variable If     '${mode}'=='SA'    .//nas-5gs.sm.pdu_addr_inf_ipv4    .//nas-eps.esm.pdn_ipv4
    ${dnn_xpath}    Set Variable If     '${mode}'=='SA'    .//nas-5gs.cmn.dnn    .//nas-eps.esm.qci
    ${cmd}    Set Variable    /usr/bin/tshark -r {pcap_file} -o nas-5gs.null_decipher:TRUE -Y \"${first_pdu_ip_message_filter}\" -T pdml
    pcap.load_pcap_file    pcap_file=${cpif_log_path}    command_template=${cmd}    alias=${alias}
    ${first_pdu_ip}     pcap.get_field_value_by_xpath    xpath=${pdu_ip_xpath}     pcap_parser=${alias}
    ${first_dnn_value}    pcap.get_field_value_by_xpath    xpath=${dnn_xpath}     pcap_parser=${alias}
    ${first_pdu_ip_dnn_pair}    Evaluate    list(zip(${first_pdu_ip},${first_dnn_value}))
    ${pdu_ip_dnn_dict}    Create Dictionary
    FOR  ${item}  IN  @{first_pdu_ip_dnn_pair}
      ${ip_type}    Set Variable If    '${item[-1]}'=='ims' or '${item[-1]}'=='5'    ims    data
      Set To Dictionary    ${pdu_ip_dnn_dict}     ${ip_type}    ${item[0]}
    END
    ${cmd2}    Set Variable    /usr/bin/tshark -r {pcap_file} -o nas-5gs.null_decipher:TRUE -Y \"${second_pdu_ip_message_filter}\" -T pdml
    pcap.load_pcap_file    pcap_file=${cpif_log_path}    command_template=${cmd2}    alias=${alias}
    ${second_pdu_ip}     pcap.get_field_value_by_xpath    xpath=${pdu_ip_xpath}     pcap_parser=${alias}
    ${second_dnn_value}    pcap.get_field_value_by_xpath    xpath=${dnn_xpath}     pcap_parser=${alias}
    ${second_pdu_ip_dnn_pair}    Evaluate    list(zip(${second_pdu_ip},${second_dnn_value}))
    FOR  ${item}  IN  @{second_pdu_ip_dnn_pair}
      ${ip_type}    Set Variable If    '${item[-1]}'=='ims' or '${item[-1]}'=='5'    ims    data
      Set To Dictionary    ${pdu_ip_dnn_dict}     ${ip_type}    ${item[0]}
    END
    Log to console    All pdu ip address are : ${pdu_ip_dnn_dict}
    run keyword if  not ${pdu_ip_dnn_dict}    Fail    msg=fail to get ue ip from wireshark。
    [Return]    ${pdu_ip_dnn_dict}

Get DL Tput Layers For Pcell From Wireshark
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                only valid for 2200 cable connection and tdd cell.
    [Arguments]    ${cpif_log_path}    ${mode}=SA    ${alias}=parser
    ${dl_tput_layers}    Create Dictionary
    ${pcell_filter_expression}    Set Variable    ${${mode}_RRC_RECONFIGURE_FILTER_ATTACH}
    Convert CPIF Pcap To Pdml    file_path=${cpif_log_path}    filter=${pcell_filter_expression}    alias=${alias}
    ${pcell_csirs_ports}    pcap.get_field_value_by_xpath    xpath=.//nr-rrc.nzp_CSI_RS_ResourceToAddModList//nr-rrc.nrofPorts
    ...    pcap_parser=${alias}
    ${pcell_p8_port_number}    Get Match Count    ${pcell_csirs_ports}    3
    ${pcell_layer}    Set Variable If    ${pcell_p8_port_number} >= ${2}    4    2
    set to dictionary     ${dl_tput_layers}    pcell=${pcell_layer}
    Set Test Variable    ${dl_pcell_layer}    ${dl_tput_layers['pcell']}
    [Return]    ${dl_tput_layers}

Modify PA Value Of ENB
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ${attenuator_index}    Set Variable    ${0}
    ${value}    Set Variable    ${20}
    @{channels}    Create List    16
    attenuator.setup_attenuator    attenuator=${tl.attenuators[${attenuator_index}]}
    @{ports}    Create List
    ${value}    Evaluate    float(${value})
    @{values}    Create List
    FOR    ${channel}    IN    @{channels}
        ${channel}    Convert To Integer    ${channel}
        Append To List    ${ports}    ${channel}
        Append To List    ${values}    ${value}
    END
    Wait Until Keyword Succeeds   5min   5sec   attenuator.set_ports_attenuation   ports=${ports}   values=${values}   confirm=True
    @{new_values}    attenuator.read_ports_attenuation     ports=${ports}
    Lists Should Be Equal    ${new_values}    ${values}    msg=Attenuation set failed.
    Log To Console    \n change attenuation to ${value}

Trigger Transprecoding And Capture CPIF Log
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${ru_index}    ${wireshark_log_checkpoint}=cpif_checkpoint    ${range}=10    ${gnb_index}=0
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log     tcpdump_collector_name=${wireshark_log_checkpoint}
    ...                                                                              gnb_index=${gnb_index}
    Modify PA Value By Steps For Special RU     ru_index=${ru_index}    gnb_id=${gnb_index}    step=5    range=${range}    sleep_duration=2
    Sleep    20sec
    Modify PA Value By Steps For Special RU     ru_index=${ru_index}    gnb_id=${gnb_index}    step=-5    range=${range}
    ...                                         sleep_duration=2    use_origin_vlaue=56
    Sleep    10sec
    ${cpif_checkpoint_log_on_testPC}    Run Keyword And Continue On Failure
    ...    Stop Container Wireshark Log Collection    tcpdump_collector_name=${wireshark_log_checkpoint}
    [Return]    ${cpif_checkpoint_log_on_testPC}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    core.stop_collectors    names=${wireshark_log_checkpoint}    AND
    ...                           Run Keyword And Ignore Error    core.teardown_collectors    names=${wireshark_log_checkpoint}

Verify Checkpoint Via Wireshark
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${log_path}    ${mode}=SA    ${filter}=e1ap||f1ap||ngap||nr-rrc||xnap    ${alias}=parser    ${mappingtype}=typeB
    ${filter}    Set Variable If    '${mode}'=='SA'    f1ap.procedureCode == 12    x2ap.procedureCode == 30
    Convert CPIF Pcap To Pdml    file_path=${log_path}    filter=${filter}    alias=${alias}
    Log To Console    \n***Check transformprecoder=0 enabled without qam256***\n
    ${value1}    Get Field Value From Pdml    filter_expression=${filter} && nr-rrc.transformPrecoder == 0
    ...                                       xpath=.//nr-rrc.mcs_Table
    ...                                       attribute_name=show
    ${empty_list}    Create List
    Lists Should Be Equal    ${value1}    ${empty_list}
    Log To Console    \n***Check transformprecoder=1 disabled with qam256***\n
    ${value2}    Get Field Value From Pdml    filter_expression=${filter} && nr-rrc.transformPrecoder == 1
    ...                                       xpath=.//nr-rrc.mcs_Table
    ...                                       attribute_name=showname
    Should Contain    ${value2}[0]    qam256
    ${type_value}    Set Variable If    '${mappingtype}'=='typeB'    1    0
    Log To Console    \n***Check mappingtype is ${mappingtype}, when transformprecoder=0 enabled without qam256***\n
    # Check mappingtype is ${mappingtype}, when transformprecoder=0 enabled without qam256
    ${type1}    Get Field Value From Pdml    filter_expression=${filter} && nr-rrc.transformPrecoder == 0
    ...                                      xpath=.//nr-rrc.mappingType
    ...                                      attribute_name=show
    ${type1}    Remove Duplicates    ${type1}
    ${type1_length}    Get Length    ${type1}
    run keyword if  not '${type1_length}'=='1'    Fail    msg=mappingtype abnormal!!!
    ${type_value1}    Convert To String    ${type1}[0]
    Should Be Equal    ${type_value1}    ${type_value}    msg=mappingtype is not correct!!!!
    Log To Console    \n***Check mappingtype is ${mappingtype}, when transformprecoder=1 disabled with qam256***\n
    ${type2}    Get Field Value From Pdml    filter_expression=${filter} && nr-rrc.transformPrecoder == 1
    ...                                       xpath=.//nr-rrc.mappingType
    ...                                       attribute_name=show
    ${type2}    Remove Duplicates    ${type2}
    ${type2_length}    Get Length    ${type2}
    run keyword if  not '${type2_length}'=='1'    Fail    msg=mappingtype abnormal!!!
    ${type_value2}    Convert To String    ${type2}[0]
    Should Be Equal    ${type_value2}    ${type_value}    msg=mappingtype is not correct!!!!

Verify Whether Ptrs Is Exist
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                param: ${ptrs}----ptrs or no_ptrs
    [Arguments]    ${log_path}    ${alias}=parser    ${ptrs}=ptrs
    ${value}    Set Variable If    '${ptrs}'=='ptrs'    ${True}
    ...                            '${ptrs}'=='no_ptrs'    ${False}
    Convert CPIF Pcap To Pdml    file_path=${log_path}    alias=${alias}    command_template={tshark_path} -r {pcap_file} -T pdml
    Log To Console    \n***Check that whether ptrs is exist***\n
    ${result}    Run Keyword And Return Status    pcap.get_packets    filter=nr-rrc.ptrs_Power == 0    pcap_parser=${alias}
    Should Be Equal    ${result}    ${value}

Modify PA Value For Special RU With Interval
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${ru_index}    ${gnb_id}=0    ${interval}=10    ${use_origin_vlaue}=${None}
    ${ru_index_type}    Evaluate    type(${ru_index}).__name__
    ${convert_ru_index_to_list}    Create List    ${ru_index}
    ${modify_ru_id_list}    Set Variable If    'list' in '${ru_index_type}'    ${ru_index}    ${convert_ru_index_to_list}
    FOR    ${ru_index}    IN    @{modify_ru_id_list}
        ${base_value}    Set Variable    ${${TL_NAME}_PA_BASE_VALUE_MAPPING_TABLE['${gnb_id}']['${ru_index}']}
        ${base_down_value}    Set Variable    ${use_origin_vlaue}
        ${base_value}    Set Variable If    ${use_origin_vlaue}==${None}    ${base_value}    ${use_origin_vlaue}
        ${base_value_type}    Evaluate    type(${base_value}).__name__
        ${modify_value}    Run Keyword If    'list' in '${base_value_type}'    Evaluate    [int(x)+int(${interval}) for x in ${base_value}]
        ...                            ELSE   Evaluate    ${base_value}+${interval}
        gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU   value=${modify_value}   RU_id=${ru_index}   gnb_id=${gnb_id}
    END

Modify PA Value By Steps For Special RU
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${ru_index}    ${gnb_id}=0   ${step}=2    ${range}=15     ${sleep_duration}=1    ${use_origin_vlaue}=${None}
    FOR    ${round}    IN RANGE    0    ${range}
        ${interval}    Evaluate    ${round}*${step}
        sleep    ${sleep_duration}sec
        Modify PA Value For Special RU With Interval    ru_index=${ru_index}    gnb_id=${gnb_id}
        ...                                             interval=${interval}    use_origin_vlaue=${use_origin_vlaue}
    END

Adb Reboot UE And Verify
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Run Keyword If    '${ue_type}'=='qct_dx50'    Run Keywords
    ...    Connect to control pc enhanced    ${ue_index}    AND
    ...    csn.execute    command=adb -s ${serial_number} reboot   connection=cpc_${ue_index}    AND
    ...    Sleep    10s    AND
    ...    Wait Until Keyword Succeeds    3 min    10s    Connect ADB devices    alias=cpc_${ue_index}    serial_number=${serial_number}
    [Teardown]    Run Keyword If    '${ue_type}'=='qct_dx50'    Run Keyword And Ignore Error    csn.disconnect   connection=cpc_${ue_index}

Procedures.Update actUlDftSOfdm And puschMappingType
    [Documentation]   Auther:jun.8.chen@nokia-sbell.com
    [Arguments]    ${pcell_index}=1    ${gnb_id}=0    ${actUlDftSOfdm_value}=true    ${type_value}=TypeB
    Log To Console    \n***start to update actUlDftSOfdm--${actUlDftSOfdm_value} and puschMappingType--${type_value}***\n
    @{param_list}    Create List
    ${NRBTS_ID}    Set Variable    ${tl.gnbs[${gnb_id}].global_bts_id}
    ${update_actUlDftSOfdm}    Create Dictionary    dist_name=NRBTS-${NRBTS_ID}/NRCELL-${pcell_index}
    ...                                             parameter=actUlDftSOfdm
    ...                                             value=${actUlDftSOfdm_value}
    ${update_puschMappingType}    Create Dictionary    dist_name=NRBTS-${NRBTS_ID}/NRCELL-${pcell_index}
    ...                                                parameter=puschMappingType
    ...                                                value=${type_value}
    Append To List    ${param_list}    ${update_actUlDftSOfdm}    ${update_puschMappingType}
    Common_keywords.Update Params Via RestApi    params_need_to_modify=${param_list}    gnb_index=${gnb_id}
