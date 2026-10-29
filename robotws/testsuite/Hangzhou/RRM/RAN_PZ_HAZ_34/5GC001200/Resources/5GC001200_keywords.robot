*** Settings ***
Documentation
...   This is for 1200 TA common keywords with Viavi UE
...   squad group: SG_04
Resource    ./5GC001200_variables_common.robot
Variables   ../TestData/1200_A_swconf_modify.py
Variables   ../TestData/1200_cplane_msg_checkpoints.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    taf/rfrl/common_resources/robot/coam_selenium.robot
Resource    taf/rfrl/common_resources/robot/TTI_Trace.robot
Resource    taf/rfrl/common_resources/robot/stream_manager.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/container_log_capturing.robot
Library     taf.rfrl.common_resources.python.SWConfig     WITH NAME    swconf
Library     taf.rfrl.common_resources.python.gNB_l2_lo_throughput
Library     taf.rfrl.common_resources.python.ssh_common_commands
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/lib/string_list.py
Library    taf.analyzer.pcap    WITH NAME    pcap
Resource    ./log_capture_analysis.robot
Resource    ./throughput_verification.robot
Variables   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/lib/defult_testline_scf.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/viavi_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/common_other.robot


*** Keywords ***
Set suite variables by program
    [Documentation]  Author: Ren Biyao
    ...              This keyword is to set several variables by program.
    ...              Variables diff from different programs are:
    ...                - ABIL slot position ${HW_SLOW};
    ...                - PA ports and their init values;
    ...                - Cobham board's IP ${E500_HLS_IP};
    ...                - Cobham script;
    ${cur_program}    gnb_classical_hangzhou.Get program version based on stream version
    set suite variable    ${PROGRAM}    ${cur_program}
    import variables   ${CURDIR}/../TestData/1200_suggested_para_value.py
    ${HW_SLOT}    set variable if    '${tl.gnbs[0].instance_id}'=='250'    ${5}    ${1}    # only TL250 gnb locate at right side of AMIA
    set suite variable    ${HW_SLOT}
    run keyword if    '${PROGRAM}' == 'master' or '${PROGRAM}' == '21B' or '${PROGRAM}' == '21A'
    ...    import resource    ${CURDIR}/5GC001200_variables_trunk.robot
    ...    ELSE    import resource    ${CURDIR}/5GC001200_variables_20A_20B.robot

Common Suite Preparation
    [Documentation]    Author: Cui Lingxue
    ...    This keyword will modify swconfig file and commission gnb and verify gnb cell on air status.
    ...    ${scf_parameter_to_modify} could be the parameters in __init__.py
    ...    ${1200_scf_parameter} is the parameters list which is related to 1200 function.
    [Timeout]          20 min
    [Arguments]    ${swconfig_modify}=${None}     ${testline_scf_parameter}=${PARAMS_TO_MODIFY_SCF}
    ...    ${1200_scf_parameter}=${MODIFY_SCF_1200_BASE}    ${is_pdl_checking_needed}=${True}
    Run keyword and ignore error    wait until keyword succeeds    3x    10 s    Reset Viavi via ASC
    ...    tma_asc_alias=${TMA_ASC_ALIAS}
    coam_gnb_classical.COAM Create log directory    is_set_to_test_case_level=${False}
    Modify LTE cPlaneIpAddr via rest api
    ${scf_modify}    combine lists    ${1200_scf_parameter}    ${testline_scf_parameter}
    ${PDL_VALIDATION_RESULT}    Preparation with swconfig modification and comissioning    swconfig_modify=${swconfig_modify}
    ...    is_called_in_test_case_level=${False}    is_pdl_checking_needed=${is_pdl_checking_needed}    scf_modify=${scf_modify}
    Wait until cluster is on cell on air status
    ${parameter_values_in_scf}    Convert parameter value in SCF    1200_scf_parameter=${1200_scf_parameter}
    set suite variable    ${PARAMETER_VALUES_IN_SCF}    ${parameter_values_in_scf}
    Set suite variable    ${PDL_VALIDATION_RESULT}

Modify LTE cPlaneIpAddr via rest api
    [Documentation]    Author: Wang Yixiang
    enb_lte.Connect to eNB via ssl    connection=enblte
    &{kargs}    Create Dictionary
    ...    value=${tl.gnbs[0].dus[0].f1_m_ip_addr}
    ...    dist_name=MRBTS-${tl.enbs[0].global_bts_id}/LNBTS-${tl.enbs[0].instance_id}/LNADJGNB-1
    ...    parameter=cPlaneIpAddr
    ${IP_MODIFY_API}     create list    ${kargs}
    coam_gnb_classical.COAM Update several parameters via rest api
    ...    parameters_to_update_via_api=${IP_MODIFY_API}     connection=enblte
    [Teardown]  enb_lte.Enblte close down    connection=enblte


Common test preparation
    [Documentation]    Author: Cui Lingxue
    [Arguments]    ${parameters_to_update_via_api}    ${is_need_to_check_validation_errors}=${False}
    ...    ${iperf_ul_port_list}=${IPERF_UL_PORT_LIST}
    ...    ${e500_script_path}=${E500_SCRIPTS_BASE}    ${e500_attach_script_path}=${E500_SCRIPTS_BASE}
    ...    ${is_need_to_check_mul_drb_established}=${False}    ${mul_drb_code_stream_of_attach}=${DRB_WITH_NR}    ${number_of_ue}=${1}
    ...    ${is_need_to_check_ul_data_on_lte}=${False}    ${is_need_to_check_ul_data_on_NR}=${True}
    coam_gnb_classical.COAM Create log directory    is_set_to_test_case_level=${True}
    Online modify nidd parameters via rest api
    ...    1200_other_nidd_modify_via_api=${parameters_to_update_via_api}
    Get UE ready for rlo    iperf_ul_port_list=${iperf_ul_port_list}    e500_script_path=${e500_script_path}
    ...    e500_attach_script_path=${e500_attach_script_path}
    ...    is_need_to_check_mul_drb_established=${is_need_to_check_mul_drb_established}
    ...    mul_drb_code_stream_of_attach=${mul_drb_code_stream_of_attach}
    ...    number_of_ue=${number_of_ue}
    ...    is_need_to_check_ul_data_on_lte=${is_need_to_check_ul_data_on_lte}
    ...    is_need_to_check_ul_data_on_NR=${is_need_to_check_ul_data_on_NR}

Test preparation for multi-UE
    [Arguments]    ${parameters_to_update_via_api}
    Common test preparation    parameters_to_update_via_api=${parameters_to_update_via_api}
    ...    iperf_ul_port_list=${IPERF_UL_PORT_LIST_MUL_UE}
    ...    e500_script_path=${E500_SCRIPTS_MULTI_UE}
    ...    e500_attach_script_path=${E500_SCRIPTS_MULTI_UE}
    ...    number_of_ue=${NUMBER_OF_UE}

Common Suite Teardown
    [Documentation]    Author: Cui Lingxue
    ...    This keyword is used in suite teardown phase
    [Timeout]    10 min
    [Arguments]        ${local_log_path}=${SUITE_LOG_PATH}
    connection_alias_store.Connect to Common Unit Master    alias=${ASIK_ALIAS}
    run keyword and continue on failure    swconf.Restore swConfig file on asik and crasign    asik_alias=${ASIK_ALIAS}
    Run keyword and ignore error    coam_gnb_classical.COAM Teardown gnb connections
    Run keyword and ignore error    enb_lte.Enblte close down    connection=${ENB_ALIAS}
    Run keyword and ignore error    Disconnect from cobham ASC via ssh    tma_asc_alias=${TMA_ASC_ALIAS}
    @{ssh_alias}    Create list    ASIK Master    ABIL Master    ASIK Slave    ABIL Slave
    Run keyword and ignore error    coam_siso_common.Disconnect ssh connections    list_alias=${ssh_alias}

Common Test Teardown
    [Timeout]    20 min
    [Arguments]    ${dl_port}=${IPERF_DL_PORT}    ${e500_attach_script_path}=${E500_SCRIPTS_BASE}    ${number_of_ue}=${1}
    Iperf stop traffic from appserver and ue side    port=${dl_port}
    Cobham UE detach    e500_script_path=${e500_attach_script_path}
    Run keyword and ignore error    Kill tma process
    Collect tma logs to test pc
    Run keyword and ignore error    coam_gnb_classical.COAM Verify if alarm exists
    Run keyword if    '${TEST STATUS}' == 'FAIL'
    ...    COAM Save snapshot via webUI
    Run keyword and ignore error    coam_gnb_classical.COAM Teardown gnb connections
    Run keyword and ignore error    enb_lte.Enblte close down    connection=${ENB_ALIAS}
    @{ssh_alias}    Create list    ASIK Master    ABIL Master    ASIK Slave    ABIL Slave    tma_ssh    tma
    Run keyword and ignore error    coam_siso_common.Disconnect ssh connections    list_alias=${ssh_alias}
    Initiate programmable attenuation for attach

Get UE ready for rlo
    [Documentation]    Author: Cui Lingxue
    ...    This keyword is to get the environment ready for triggering rlo, including initilize PA, connect cobham, UE attach,
    ...    start UL and DL data transfer.
    ...    2020-12-29: adapt for multi-drb and multi-ue.
    [Arguments]    ${iperf_ul_port_list}=${IPERF_UL_PORT_LIST}    ${log_path}=${TS_CASE_LOG_PATH}
    ...    ${e500_script_path}=${E500_SCRIPTS_BASE}    ${e500_attach_script_path}=${E500_SCRIPTS_BASE}
    ...    ${is_need_to_check_mul_drb_established}=${False}    ${mul_drb_code_stream_of_attach}=${DRB_WITH_NR}    ${number_of_ue}=${1}
    ...    ${is_need_to_check_ul_data_on_lte}=${False}    ${is_need_to_check_ul_data_on_NR}=${True}

    Initiate programmable attenuation for attach
    Connect to Common Unit Master     alias=${ASIK_ALIAS}

    Precondition for attach with retry    e500_script_path=${e500_script_path}    repeat_times=${3}
    ${ue_ip_list}    run keyword if    ${number_of_ue}==${1}
    ...            Cobham Retry ue attach if failed    e500_script_path=${e500_attach_script_path}
    ...            is_need_to_check_mul_drb_established=${is_need_to_check_mul_drb_established}
    ...            mul_drb_code_stream=${mul_drb_code_stream_of_attach}
    ...    ELSE    Cobham multiple UEs attach    number_of_ue=${number_of_ue}    e500_script_path_multi_ue=${e500_attach_script_path}
    ...            is_need_to_check_mul_drb_established=${is_need_to_check_mul_drb_established}
    ...            mul_drb_code_stream=${mul_drb_code_stream_of_attach}
    set suite variable    ${UE_IP_LIST}    ${ue_ip_list}

    FOR    ${i}    IN RANGE    ${number_of_ue}
        Iperf send UL traffic with real epc    throughput=${UL_THROUGHPUT}    traffic_time=${TRAFFIC_TIME}    ul_host_ip=${E500_HLS_IP}
        ...    port=${iperf_ul_port_list[${i}]}
    END
    run keyword if    ${number_of_ue}>${1}
    ...      Iperf send DL traffic with real epc for multiple UEs   number_of_ue=${number_of_ue}   throughput=${DL_THROUGHPUT}
    ...      dl_port=${IPERF_DL_PORT}    dl_host_ip_list=${UE_IP_LIST}   traffic_time=${TRAFFIC_TIME}
    ...    ELSE IF    ${is_need_to_check_mul_drb_established}    run keywords
    ...      Iperf send DL traffic with real epc    throughput=${DL_THROUGHPUT}    traffic_time=${TRAFFIC_TIME}    port=${IPERF_DL_DEDIC_PORT}    AND
    ...      Iperf send DL traffic with real epc    throughput=${DL_THROUGHPUT}    traffic_time=${TRAFFIC_TIME}    port=${IPERF_DL_PORT}
    ...    ELSE    Iperf send DL traffic with real epc    throughput=${DL_THROUGHPUT}    traffic_time=${TRAFFIC_TIME}    port=${IPERF_DL_PORT}

    Sleep   3s

    @{RB_LIST}    run keyword if    ${is_need_to_check_mul_drb_established}    create list    6    7    ELSE    create list    6
    run keyword and ignore error    run keyword if    ${number_of_ue}>${1}    There should exist traffic for each UE
    ...    number_of_ue=${number_of_ue}    log_path=${log_path}
    ...    ELSE    There should exist traffic on each DRB    rb_list=${RB_LIST}   log_path=${log_path}
    run keyword and ignore error    run keyword if    ${is_need_to_check_ul_data_on_lte}
    ...   run keyword and continue on failure    Evaluate throughput for LTE data transfer    direction=ul    log_path=${log_path}
    wait until keyword succeeds    2 min    10 s    Connect to cobham control pc via ssh    tma_ssh_alias=${TMA_SSH_ALIAS}

Online modify nidd parameters via rest api
    [Documentation]    Author: Cui Lingxue
    ...    Use this keyword to update nidd paramter related to 1200 via rest api and verify alarms.
    [Arguments]    ${1200_other_nidd_modify_via_api}    ${log_path}=${TS_CASE_LOG_PATH}
    coam_gnb_classical.Connect to gnb coam via ssl
    coam_gnb_classical.COAM Update several parameters via rest api
    ...    parameters_to_update_via_api=${1200_other_nidd_modify_via_api}

    # WA for 20A issue, NIDD not able to be online modified
    run keyword if    '${PROGRAM}' == '20A'    run keywords
    ...    Perform BTS Site Reset    download_dir=${log_path}    AND
    ...    Wait until cluster is on cell on air status

    ${timestamp}    Get Current Date    result_format=%Y%m%d-%H%M%S
    ${scf_file_path}    coam.get_current_scf_file    local_dir_path=${log_path}
    ...    file_name=SCF_after_nidd_modification_${timestamp}    connection=GNB_OAM
    Log to console    Downloading current scf from gNB. SCF file path is ${scf_file_path}
    [Teardown]    coam_gnb_classical.COAM Teardown gnb connections

Online modify nidd parameters via webUI
    [Arguments]    ${parameters_to_update_via_webui}    ${is_need_to_check_validation_errors}=${True}
    ...    ${log_path}=${TS_CASE_LOG_PATH}
    coam_selenium.COAM Update Several Parameters Via WebUI
    ...    parameters_to_update_via_webui=${parameters_to_update_via_webui}
    ...    download_dir=${log_path}
    ...    is_need_to_check_validation_errors=${is_need_to_check_validation_errors}

    # WA for 20A issue, NIDD not able to be online modified
    run keyword if    '${PROGRAM}' == '20A'    run keywords
    ...    Perform BTS Site Reset    download_dir=${log_path}    AND
    ...    Wait until cluster is on cell on air status

    coam_gnb_classical.Connect to gnb coam via ssl
    ${timestamp}    Get Current Date    result_format=%Y%m%d-%H%M%S
    ${scf_file_path}    coam.get_current_scf_file    local_dir_path=${log_path}
    ...    file_name=SCF_after_nidd_modification_${timestamp}.xml    connection=GNB_OAM
    Log to console    Downloading current scf from gNB. SCF file path is ${scf_file_path}
    [Teardown]    coam_gnb_classical.COAM Teardown gnb connections

Convert parameter value in SCF
    [Documentation]    Author: Cui Lingxue
    ...    Description: parameters are organized into list type when used to modify scf file. This keyword is to convert them to
    ...    a dict type variable without DIST_NAME, so it is convenient to use as criteria for event trace analysis.
    ...    Input data example: [dict(value='true', dist_name=NR_CELL_NAME, p_name='actDynUlDataSplitMode'),
    ...        dict(value='30', dist_name=NR_CELL_NAME, p_name='pucchDataDtxNumOfSamples'), ...]
    ...    Return example:  {b'actDynUlDataSplitMode': b'true', b'pucchDataDtxNumOfSamples': b'30', b'puschDataDtxNumOfSamples': b'30', ...}
    [Arguments]    ${1200_scf_parameter}    ${key_name}=p_name
    ${dict_parameters}    create dictionary
    ${num_of_parameters}    get length    ${1200_scf_parameter}
    FOR    ${i}    IN RANGE    ${num_of_parameters}
        ${para_key}      get_from_dictionary    dictionary=${1200_scf_parameter[${i}]}    key=${key_name}
        ${para_value}    get_from_dictionary    dictionary=${1200_scf_parameter[${i}]}    key=value
        ${para_value}    run keyword if    '${para_key}'=='rloSinrThreshold'    evaluate    float(${para_value}/10.0)
        ...    ELSE IF    '${para_key}'=='rlResumeSinrThreshold'    evaluate    float(${para_value}/10.0)
        ...    ELSE    set variable    ${para_value}
        set_to_dictionary    ${dict_parameters}    ${para_key}    ${para_value}
    END
    [Return]    ${dict_parameters}

Initiate programmable attenuation for attach
    [Documentation]    Author: Cui Lingxue
    ...    This keyword is to initiate PA to be ready for attach. Ports and initial values are set in variable file.
    Adjust programmable attenuation
    ...            port_of_layer0_ul=${LAYER0_UL_PORT}
    ...            port_of_layer0_dl=${LAYER0_DL_PORT}
    ...            port_of_layer1_ul=${LAYER1_UL_PORT}
    ...            port_of_layer1_dl=${LAYER1_DL_PORT}
    ...            attenuation_of_layer0_ul=${INITIAL_LAYER0_UL_ATTEN}
    ...            attenuation_of_layer0_dl=${INITIAL_LAYER0_DL_ATTEN}
    ...            attenuation_of_layer1_ul=${INITIAL_LAYER1_UL_ATTEN}
    ...            attenuation_of_layer1_dl=${INITIAL_LAYER1_DL_ATTEN}


# kw about RLO and RL_RESUME trigger
_detailed start log process
    [Documentation]    Author: Ren Biyao
    ...    This keyword contains the procedure of capturing UPUE and EventTrace logs.
    [Arguments]    ${UPUE_log_prefix}    ${interface}=any    ${is_tti_required}=${True}
    ${UPUE_log_full_path_asik}    Wait until keyword succeeds    3min    3 s    Start tcpdump trace capturing    log_prefix=${UPUE_log_prefix}
    ...    connection_alias=ASIK Master
    run keyword if    ${is_tti_required}    TTI_Trace.Start TTI trace log capturing    hw_slot=${HW_SLOT}
    [Return]    ${UPUE_log_full_path_asik}

_detailed stop log process
    [Documentation]    Author: Ren Biyao
    ...    This keyword is to stop UPUE and EventTrace logs and download them to local. ${EVENT_trace['DL']} will be removed
    ...   because 1200 does not use dl trace for checking.
    [Arguments]    ${UPUE_log_full_path_asik}    ${UPUE_log_prefix}    ${log_path}=${TS_CASE_LOG_PATH}    ${connection}=ASIK Master
    ...    ${is_tti_required}=${True}
    run keyword if    ${is_tti_required}    TTI_Trace.Stop TTI trace log capturing
    stop trace capturing    log_prefix=${UPUE_log_prefix}    connection_alias=${connection}
    ${UPUE_trace}    Download trace log    log_full_path=${UPUE_log_full_path_asik}    log_dir_ute=${log_path}
    ...    connection_alias=${connection}
    ${EVENT_trace}    run keyword if    ${is_tti_required}    run keyword and ignore error
    ...    TTI_Trace.Convert TTI trace log and download combined csv logs to test pc    local_path=${log_path}
    connection_alias_store.Connect to Common Unit Master     alias=${ASIK_ALIAS}
    [Return]    ${UPUE_trace}    ${EVENT_trace}

Trigger RLO or Resume by online modify nidd parameter and log capture
    [Documentation]    Author: Wang Yixiang
    ...                Trigger RLO and Resume by online modify nidd parameter and capture log,
    ...                verify RLO and Resume by code stream
    [Arguments]    ${UPUE_log_prefix}=UPUE_log
    ...            ${code_stream}=${SIG_DRB_RLO}
    ...            ${codestream_timeout}=10 s
    ...            ${trigger_time}=${None}
    ...            ${log_path}=${TS_CASE_LOG_PATH}
    ...            ${connection}=${TMA_APP_ALIAS}
    ...            ${is_need_to_capture_log}=${True}
    ...            ${is_tti_required}=${False}
    ...            ${ue_idx}=0
    ...            ${return_status}=${False}
    @{ue_idx_list}    string_list.string2list    input_str=${ue_idx}
    @{RLO_RLM_trigger_status}     create list
    ${UPUE_log_full_path_asik}    run keyword if    ${is_need_to_capture_log}    _detailed start log process
    ...    UPUE_log_prefix=${UPUE_log_prefix}    is_tti_required=${is_tti_required}
    Online modify nidd parameters via rest api    1200_other_nidd_modify_via_api=${MODIFY_SCF_TRIGGER_RLO_RLM_API}

    FOR    ${idx}    IN     @{ue_idx_list}
        ${Is_RLO_RLM_triggered}    Run keyword and return status    Wait until code stream is triggered    code_stream=${code_stream}
        ...    timeout=${codestream_timeout}    trigger_time=${trigger_time}    ue_idx=${idx}
        Append To List    ${RLO_RLM_trigger_status}    ${Is_RLO_RLM_triggered}
    END

    stop trace capturing    log_prefix=${UPUE_log_prefix}    connection_alias=ASIK Master
    ${UPUE_trace}    ${EVENT_trace}    run keyword if    ${is_need_to_capture_log}     _detailed stop log process
    ...    UPUE_log_full_path_asik=${UPUE_log_full_path_asik}    UPUE_log_prefix=${UPUE_log_prefix}   log_path=${log_path}
    ...    is_tti_required=${is_tti_required}

    Return From Keyword If    '${return_status}' == '${True}'    ${Is_RLO_RLM_triggered}
    FOR    ${trigger_status}    IN     @{RLO_RLM_trigger_status}
        should be true    condition=${trigger_status}    msg=Trigger RLO or Resume, verify by code stream:${code_stream} failed.
    END
    [Return]    ${Is_RLO_RLM_triggered}

# move from Cobham_Pre.robot

Cobham multiple UEs attach
    [Documentation]    Author: Cui Lingxue
    ...    This keyword is to perform tm500 attach for multiple UEs and return with their IP addresses.
    ...    ${number_of_ue} specify the number of UEs.
    ...    Each UE attach will attempt for ${retry_time}, if one of them fail to attach after retry times, this keyword will fail.
    ...    ${UE_IP_LIST} contains all UEs' IP addresses, and will be set as TEST varilble after all UEs attach successfully.
    ...    2020-2-29 Ding Binmei: Added ${is_cell_config_update_needed}: if ${True} then cell config script need to be executed for each UE;
    ...        If ${False}, then it means for all ues they can use the same cell config file.
    [Arguments]    ${number_of_ue}    ${e500_script_path_multi_ue}=${E500_SCRIPTS_MULTI_UE}    ${retry_time}=${10}
    ...    ${e500_alias}=${TMA_APP_ALIAS}    ${is_cell_config_update_needed}=${False}
    ...    ${is_need_to_check_mul_drb_established}=${False}    ${mul_drb_code_stream}=142D28DFAFC7370CD311FAFC7370CC28
    ${ue_ip_list}    create list
    FOR    ${i}    IN RANGE    ${number_of_ue}
        Run keyword if    ${is_cell_config_update_needed}    tm500_hangzhou.Perform cell search
        ...    cell_search_script_path=${e500_script_path_multi_ue}/script_ue${i}/NSA_5G_Cell_Config.txt    tm500_alias=${e500_alias}
        Cobham retry ue attach if failed    e500_script_path=${e500_script_path_multi_ue}/script_ue${i}    retry_time=${retry_time}
        ...    e500_alias=${e500_alias}    is_need_to_check_mul_drb_established=${is_need_to_check_mul_drb_established}
        ...    mul_drb_code_stream=${mul_drb_code_stream}
        append to list    ${ue_ip_list}    ${UE_IP}
    END
    [Return]    ${ue_ip_list}

Cobham multiple UEs detach
    [Documentation]    Author: Cui Lingxue
    ...    This keyword is to detach multiple UEs.
    ...    ${number_of_ue} specify the number of UEs.
    [Arguments]    ${number_of_ue}    ${e500_script_path_multi_ue}=${E500_SCRIPTS_MULTI_UE}
    FOR    ${i}    IN RANGE    ${number_of_ue}
        tm500_hangzhou.TM500 detach    tm500_alias=${TMA_APP_ALIAS}
        ...    detach_script_path=${e500_script_path_multi_ue}/script_ue${i}/NSA_5G_UEdetach.txt
    END
    [Teardown]    tm500_hangzhou.Disconnect    tm500_alias=${TMA_APP_ALIAS}

Iperf send DL traffic with real epc for multiple UEs
    [Documentation]    Author: Cui Lingxue
    ...    This keyword is to send DL traffic for multiple UEs on app server.
    ...    ${number_of_ue} specify the number of UEs.
    ...    ${UE_IP_LIST} is returned from multiple UE attach
    ...    Need to configure iperf path to cygwin
    ...    DL port value range: 54000~55000
    [Arguments]    ${number_of_ue}    ${throughput}    ${traffic_time}    ${dl_port}    ${dl_host_ip_list}=${UE_IP_LIST}
    Log to console    Start DL traffic with real epc
    ${number_of_ue_ip}    get length    ${dl_host_ip_list}
     FOR    ${i}    IN RANGE    ${number_of_ue}
         Iperf send DL traffic with real epc    port=${dl_port}    dl_host_ip=${dl_host_ip_list[${i}]}
         ...    throughput=${throughput}    traffic_time=${traffic_time}
     END
