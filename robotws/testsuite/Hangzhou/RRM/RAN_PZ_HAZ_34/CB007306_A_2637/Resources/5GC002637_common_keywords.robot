*** Settings ***
Documentation
...    author: Jiang Hongyu
...    contact: hongyu.jiang@nokia-sbell.com
...    squad group: MMW_SG_04
...    feature : 5GC002637-A

Library     ./samsung_sigspark.py
Library     samsung_sigspark.SigSpark    WITH NAME    samsung_spark
Library     taf.sbts.oam.coam.admin       WITH NAME    coam
Library     taf.transport.ssh            WITH NAME    csn
Library     taf.config.scf.interface.scf     WITH NAME   scf
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Commercial_mobile_phone_adb_common_keywords.robot
Resource    taf/rfrl/common_resources/robot/TTI_Trace.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot

*** Variables ***
${gnb_ip}                  ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${gNB_username}            ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gNB_password}            ${tl.gnbs[0].cu.oam_http_connection_details.password}
${TEST_PC_IP}              ${tl.test_pc.default_ssh_connection_details.addr}
${TEST_PC_USERNAME}        ${tl.test_pc.default_ssh_connection_details.username}
${TEST_PC_PASSWORD}        ${tl.test_pc.default_ssh_connection_details.password}
${control_pc}              ${tl.ues[0].ssh_connection_details.addr}
${control_pc_name}         ${tl.ues[0].ssh_connection_details.username}
${control_pc_pass}         ${tl.ues[0].ssh_connection_details.password}
${TS_CASE_LOG_PATH}        ${OUTPUT DIR}
${ul_power_port_list}      ${tl.ues[0].iperf_details.ports[0:1]}
${dl_power_port_list}      ${tl.ues[0].iperf_details.ports[1:2]}
${ul_tput_udp}             400M
${dl_tput_udp}             2000M
@{list_cell_index}         ${1}    ${2}    ${3}    ${4}    ${5}    ${6}    ${7}    ${8}
@{list_cell_group_index}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}
@{5G_RU_id_list_749}        ${3}
@{4G_RU_id_list_749}        ${1}
${5G_BTS_ID_749}            7502
${4G_BTS_ID_749}            10725
@{RU_lock_status}           Locked    enabled    Idle    configured
@{empty_list}


*** Keywords ***
########### check bts on air #################
Adapt to ute cloud commission scf
    ${TL_NAME}   set variable if      '${testline_name}' == '${EMPTY}'    ${CONFIGURATION}    ${testline_name}
    ${pattern}   Set Variable    7_5(.*)
    ${TLNAME}    Get Regexp Matches     ${TL_NAME}    ${pattern}    1
    ${TLNAME}   Set Variable    7_5${TLNAME}[0]
    Set Suite Variable    ${CURDIR_path}    ${CURDIR}/../../../../../../commissionings/HGZ/${TLNAME}/

Reset Station
    [Arguments]  ${host_ip}=${gNB_ip}    ${connection}=GNB_OAM    ${timeout}=20min
    Connect to gnb coam via ssl    bts_host=${host_ip}    username=${gNB_username}    password=${gNB_password}
    ...    connection=${connection}
    Log to console    Restart Station
    coam.reset_site   timeout=${timeout}  connection=${connection}

Check cell on air
    [Timeout]    20 min
    Wait until cluster is on cell on air status    timeout=20 min    list_cell_index=${list_cell_index}
    ...    list_cell_group_index=${list_cell_group_index}    is_enb_status_check_needed=${False}    is_x2_check_from_enb_needed=${False}
    wait until keyword succeeds    5 min    10 sec    Verify all cells should be onair
#    ${rus_connect_success}    run keyword and return status  Connect to all rus with allocated IP
#    should be equal as strings  ${rus_connect_success}    True

########## modify parameter ###################
Modify Value On DU
    [Arguments]    ${structure_modify_list}=None    ${common_modify_list}=None    ${keywords_list}=None
    ...    ${connection}=coam_admin    ${class_name}=None   ${is_structure}=${True}    ${is_common}=${True}
    ...    ${structure_index}=0
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
    ...    connection=${connection}
    run keyword if  ${is_structure}    Modify Structure parameter via Coam    class_name=${class_name}
    ...   connection=${connection}    modify_list=${structure_modify_list}    keywords_list=${keywords_list}
    ...    index=${structure_index}
    run keyword if  ${is_common}    Modify Common parameter via Coam    input_list=${common_modify_list}
    ...    connection=${connection}
#    Check cell on air
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}

Modify Structure parameter via Coam
    [Arguments]   ${class_name}   ${connection}   ${modify_list}   ${keywords_list}    ${index}=0
    ${get_managed_objects}     coam.get_managed_objects     class_name=${class_name}    connection=${connection}
    ${output_dict_list}    Return_Structure_Mofify_Value    input_list=${get_managed_objects}
    ...    modify_list=${modify_list}    keywords_list=${keywords_list}    index=${index}
    FOR    ${item}  IN  @{output_dict_list}
        ${dict_value}    Get Content From Input Dict    input_dict=${item}
        coam.Perform Parameter Recommissioning    dist_name=${dict_value}[0]   parameter=${dict_value}[1]
        ...    value=${dict_value}[2]    operation=update    skip_parameter_relation_errors=${True}
        ...    should_activate=${True}    connection=${connection}
        sleep  2min
    END

Modify Common parameter via Coam
    [Arguments]  ${input_list}    ${connection}
    FOR    ${item}  IN    @{input_list}
        ${dict_value}    Get Content From Input Dict    input_dict=${item}
        coam.Perform Parameter Recommissioning    dist_name=${dict_value}[0]   parameter=${dict_value}[1]
        ...   value=${dict_value}[2]
        ...    operation=update    skip_parameter_relation_errors=${True}    should_activate=${True}
        ...    connection=${connection}
        sleep  2min
    END

Get Content From Input Dict
    [Arguments]  ${input_dict}
    ${dist_name}    get from dictionary     ${input_dict}    dist_name
    ${parammeter}    get from dictionary    ${input_dict}    parameter
    ${new_value}     get from dictionary    ${input_dict}    value
    ${value_list}    create list    ${dist_name}    ${parammeter}    ${new_value}
    [Return]  ${value_list}

Add Object in SCF
    [Arguments]  ${default_scf}    ${object_list}    ${new_scf_name}
    scf.load_scf       file_path=${default_scf}
    FOR    ${item}    IN    @{object_list}
        ${source_dist_name}    Get From Dictionary    ${item}    source_dist_name
        ${target_dist_name}    Get From Dictionary    ${item}    target_dist_name
        scf.clone_mo_with_descendant_mos    source_mo_dist_name=${source_dist_name}
        ...    target_mo_dist_name=${target_dist_name}
    END
    ${new_scf}    set variable    ${OUTPUT DIR}/${new_scf_name}
    scf.save_scf        file_path=${new_scf}
    [Return]  ${new_scf}

Modify Parameter in SCF
    [Arguments]  ${input_scf}    ${para_list}    ${modify_scf}
    scf.load_scf       file_path=${input_scf}
    FOR     ${item}    IN    @{para_list}
        ${dist_name}    Get From Dictionary    ${item}    dist_name
        ${list_name}    Get From Dictionary    ${item}    list_name
        ${p_name}    Get From Dictionary    ${item}    p_name
        ${value}    Get From Dictionary    ${item}    value
        scf.modify_scf_element     dist_name=${dist_name}    p_name=${p_name}     value=${value}
        ...    list_name=${list_name}
    END
    ${new_scf}    set variable    ${OUTPUT DIR}/${modify_scf}
    scf.save_scf        file_path=${new_scf}
    [Return]  ${new_scf}

Add Element in SCF
    [Arguments]  ${input_scf}    ${element_list}    ${modify_scf}
    scf.load_scf       file_path=${input_scf}
    FOR    ${item}    IN    @{element_list}
        ${dist_name}    Get From Dictionary    ${item}    dist_name
        ${list_name}    Get From Dictionary    ${item}    list_name
        ${elements}    Get From Dictionary    ${item}    elements
        scf.add_elements_to_list    dist_name=${dist_name}    list_name=${list_name}     elements=${elements}
    END
    ${new_scf}    set variable    ${OUTPUT DIR}/${modify_scf}
    scf.save_scf        file_path=${new_scf}
    [Return]  ${new_scf}

################ UE attach spark ###################
UE attach by Spark
    [Arguments]  ${ue_num}=${1}    ${ue_type}=huawei_sigspark
    FOR    ${ue_index}   IN RANGE    ${ue_num}
        ${5Grach_ed}    wait until keyword succeeds    4X    2min    Prepare UE and Attach UE by spark
        ...    ue_index=${ue_index}
        power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    ue_index=${ue_index}    4G_check=False
        Log To Console    Attach UE_${ue_index} success
    END

Prepare UE and Attach UE by spark
    [Arguments]  ${ue_index}
    samsung_spark.require_ue    ue_alias=UE_${ue_index}    index=${ue_index}    reset_sol=${None}
#    samsung_spark.enable_ue_data_service    ue_alias=UE_${ue_index}
    ${5Grach_ed}    samsung_spark.attach_ue    ue_alias=UE_${ue_index}   attach_mode=5G_NSA     power_reset=False
    ...     timeout=90000
    log to console    UE_${ue_index}
    log to console    ${5Grach_ed}
    [Return]  ${5Grach_ed}

Start data traffic and Record TP Log
    [Arguments]  ${ue_num}    ${ul_throughput}   ${dl_throughput}   ${ul_duration}    ${dl_duration}    ${protocol}
    ...    ${if_ul}=${True}    ${if_dl}=${False}
    Spark Start UE Log    ue_index=0
    start multi power ue traffic ul and dl by spark attach    ue_num=${ue_num}    ul_throughput=${ul_throughput}
    ...    dl_throughput=${dl_throughput}
    ...    ul_duration=${ul_duration}    dl_duration=${dl_duration}    protocol=${protocol}    if_ul=${if_ul}
    ...    if_dl=${if_dl}

Stop data traffic and Stop Record TP Log
    [Arguments]  ${ue_num}    ${if_ul}    ${if_dl}    ${protocol}    ${spark_log_name}    ${ue_type}=samsung
    FOR    ${ue_index}    IN RANGE    ${ue_num}
        Spark Stop UE Log    ue_index=${ue_index}    log_name=${TS_CASE_LOG_PATH}/${spark_log_name}_UE${ue_index}.xml
    END
    FOR    ${ue_index}    IN RANGE    ${ue_num}
        run keyword and continue on failure    run keyword if   ${if_ul}    power_ue.Stop traffic   ue_index=${ue_index}
        ...    ue_type=${ue_type}    direction=ul   protocol=${protocol}   iperf_port=${ul_power_port_list}[${ue_index}]
        run keyword and continue on failure    run keyword if    ${if_dl}   power_ue.Stop traffic   ue_index=${ue_index}
        ...    ue_type=${ue_type}    direction=dl   protocol=${protocol}   iperf_port=${dl_power_port_list}[${ue_index}]
        Run Keyword And Ignore error    samsung_spark.detach_ue    ue_alias=UE_${ue_index}
    END

Spark Start UE Log
    [Documentation]    Author:jiang.hongyu@nokia-sbell.com
    [Arguments]    ${ue_index}
    ${ue_alias}    set variable    UE_${ue_index}
    samsung_spark.start_log    ue_alias=${ue_alias}

Spark Stop UE Log
    [Documentation]    Author:jiang.hongyu@nokia-sbell.com
    [Arguments]    ${ue_index}    ${log_name}=${TS_CASE_LOG_PATH}/uelog_sigspark_UE${ue_index}.xml
    ${ue_alias}    set variable    UE_${ue_index}
    samsung_spark.stop_log    ue_alias=${ue_alias}    logname=${log_name}   filter=CB007306

start multi power ue traffic ul and dl by spark attach
    [Arguments]    ${ue_num}    ${ul_throughput}=${None}    ${dl_throughput}=${None}    ${ul_duration}=6000
    ...    ${dl_duration}=6000    ${protocol}=udp    ${if_ul}=${True}    ${if_dl}=${True}
    log to console      Start traffic    console=yes
    run keyword and continue on failure    run keyword if    ${if_dl}    Multi UE start dl traffic    ue_num=${ue_num}
    ...    dl_throughput=${dl_throughput}    dl_duration=${dl_duration}    protocol=${protocol}
    sleep    1s
    run keyword and continue on failure    run keyword if    ${if_ul}    Multi UE start ul traffic    ue_num=${ue_num}
    ...    ul_throughput=${ul_throughput}    ul_duration=${ul_duration}    protocol=${protocol}

Multi UE start ul traffic
    [Arguments]  ${ue_num}    ${ul_throughput}    ${ul_duration}    ${protocol}
    FOR    ${item}    IN RANGE    ${ue_num}
        power_ue.Start traffic    ue_index=${item}    direction=ul    throughput=${ul_throughput}
        ...    duration=${ul_duration}    ue_type=samsung    iperf_type=via_command    protocol=${protocol}
        ...    iperf_port=${ul_power_port_list}[${item}]
    END

Multi UE start dl traffic
    [Arguments]  ${ue_num}    ${dl_throughput}    ${dl_duration}    ${protocol}
    FOR    ${item}    IN RANGE   ${ue_num}
        Start DL traffic via spark attach    ue_index=${item}    traffic=${dl_throughput}    time=${dl_duration}
        ...    iperf_port=${dl_power_port_list}[${item}]    protocol=${protocol}
    END

Start DL traffic via spark attach
    [Arguments]    ${ue_index}=${0}    ${time}=10    ${iperf_port}=${tl.ues[${ue_index}].iperf_details.port}
    ...            ${interval}=1    ${traffic}=10.00M    ${buffer_size}=1024B    ${protocol}=udp
    run keyword if    '${protocol}'=='udp'        Start DL UDP traffic via spark attach    ue_index=${ue_index}
    ...                                                       time=${time}
    ...                                                       interval=${interval}
    ...                                                       traffic=${traffic}
    ...                                                       buffer_size=${buffer_size}
    ...                                                       DL_port=${iperf_port}
    ...    ELSE    Start DL TCP traffic and check the TP on EPC with first UE    ue_index=${ue_index}
    ...                                                       time=${time}
    ...                                                       interval=${interval}
    ...                                                       traffic=${traffic}
    ...                                                       buffer_size=${buffer_size}
    ...                                                       DL_port=${iperf_port}

Start DL UDP traffic via spark attach
    [Arguments]    ${ue_index}=${0}    ${DL_port}=${tl.ues[${ue_index}].iperf_details.port}    ${time}=10
    ...            ${interval}=1    ${traffic}=10.00M    ${buffer_size}=1024B
    Get Commercial UE IP    ue_index=${ue_index}
    wait until keyword succeeds    1 min    10 sec    Connect to EPC APP    ue_index=${ue_index}
    sleep   2s
    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${DL_port}| awk '{print $2}' |xargs kill -9
    ...    connection=EPCAPP
    csn.send_command    command=iperf -c ${UE_IP} -u -t ${time} -i ${interval} -p ${DL_port} -P 1 -f m -b ${traffic} -l ${buffer_size} -T 64 &
    ...    connection=EPCAPP
    log to console    .....UE_${ue_index} udp dl iperf start....

Get Each UE TP From Spark
    [Arguments]  ${ue_num}    ${spark_log_name}    ${list_length}    ${row_list}
    @{dl_tput_info}    Create list
    @{ul_tput_info}    Create list
    @{dl_bler_info}    Create list
    @{ul_bler_info}    Create list
    @{total_result_list}    Create List
    FOR    ${ue_index}    IN RANGE  ${ue_num}
        ${result_dic}    Get_UE_TP_Bler_From_spark_log    file_path=${TS_CASE_LOG_PATH}/${spark_log_name}_UE${ue_index}.csv
        ...    list_length=${list_length}    row_list=${row_list}
        ${DL_bler}    get from dictionary  ${result_dic}    DL_bler
        ${UL_bler}    get from dictionary  ${result_dic}    UL_bler
        ${DL_tp}    get from dictionary  ${result_dic}    DL_tp
        ${UL_tp}    get from dictionary  ${result_dic}    UL_tp
        APPEND TO LIST   ${dl_tput_info}    ${DL_tp}[0]
        APPEND TO LIST   ${ul_tput_info}    ${UL_tp}[0]
        APPEND TO LIST   ${dl_bler_info}    ${DL_bler}[0]
        APPEND TO LIST   ${ul_bler_info}    ${UL_bler}[0]
        append to list   ${total_result_list}   ${result_dic}
    END
    [Return]    ${ul_tput_info}    ${dl_tput_info}   ${ul_bler_info}    ${dl_bler_info}    ${total_result_list}

Get Total UL And DL Max TP
    [Arguments]    ${spark_log}    ${row_list}    ${list_length}    ${ue_num}
    ${total_result_list}   Get Each UE TP From Spark    ue_num=${ue_num}    spark_log_name=${spark_log}
    ...    list_length=${list_length}
    ...    row_list=${row_list}
    ${total_result_dict}    set variable    ${total_result_list}[-1]
    ${total_tp_dict}    Caculate_total_tp    total_message_dict=${total_result_dict}
    ${dl_tp_list}    get from dictionary    ${total_tp_dict}    dl
    ${ul_tp_list}    get from dictionary    ${total_tp_dict}    ul
    ${dl_tp_max}    set variable    ${dl_tp_list}[1]
    ${ul_tp_max}    set variable    ${ul_tp_list}[1]
    ${dl_tp_sum}    set variable    ${dl_tp_list}[-1]
    ${ul_tp_sum}    set variable    ${ul_tp_list}[-1]
    [Return]  ${dl_tp_max}    ${ul_tp_max}    ${dl_tp_sum}    ${ul_tp_sum}


#################### Case Setup and Teardown ########################
Set Default scf name
    [Arguments]  ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
    ...    connection=${connection}
    ${version}    coam.get_sw_version    connection=${connection}
    ${version_list}    split string    ${version}    _
    ${if_common_load}     run keyword and return status    should contain    ${version_list[2]}    9999
    ${default_scf}    set variable if    ${if_common_load}    ${CURDIR_path}SCF_SBTS00.xml
    ...     ${CURDIR_path}SCF_${version_list[0]}.xml
    set suite variable    ${default_scf}
    log to console   ${default_scf}
    [Return]  ${default_scf}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}

Setup Commission SCF
    [Arguments]   ${scf_file_path}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
    ...     connection=${connection}
    COAM Commission with scf file    scf_file_path=${scf_file_path}    timeout=600
    Check cell on air
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}

Modify SCF And Commission SCF
    [Arguments]    ${para_list}    ${modify_scf}
    ${default_scf}    Set Default scf name
    ${new_scf}    Modify Parameter in SCF    input_scf=${default_scf}    para_list=${para_list}
    ...    modify_scf=${modify_scf}
    Setup Commission SCF    scf_file_path=${new_scf}
    sleep    5min

Commmon Case Teardown
    Run Keyword And Ignore Error     Clear All DU Connection From UTE    connect_ip=${gNB_ip}
    robot_common_operations.Common case Teardown
    CI_interface.Common Case Teardown


Clear All DU Connection From UTE
    [Arguments]    ${connect_ip}    ${connection}=TEST_PC
    csn.Connect to     hostname=${TEST_PC_IP}   username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}
    ...   alias=${connection}
    csn.send_command    command=ps -ef | grep ${connect_ip} | awk '{print $2}' | xargs kill -9   connection=${connection}
    [Teardown]   run keyword and ignore error  csn.Disconnect	connection=${connection}

Suite Case Teardown
    [Arguments]  ${ue_num}=${3}
    FOR    ${ue_index}    IN RANGE    ${ue_num}
        Run Keyword And Ignore error    samsung_spark.detach_ue    ue_alias=UE_${ue_index}
    END
    Run Keyword And Ignore error    Clear All Log Frome Control PC

Clear All Log Frome Control PC
    [Arguments]    ${connection}=Control_pc
    csn.Connect to     hostname=${control_pc}   username=${control_pc_name}    password=${control_pc_pass}
    ...    alias=${connection}
    csn.send_command    command=cd '/cygdrive/c/tmp/uelog/AUTO';rm -rf *    connection=${connection}
    csn.send_command    command=cd '/cygdrive/c/Program Files (x86)/Spark1.1.1998.9/Data/Tmp';rm -rf *
    ...    connection=${connection}
    csn.send_command    command=cd '/cygdrive/c/Program Files (x86)/Spark1.1.2001.110/Data/Tmp';rm -rf *
    ...    connection=${connection}
    [Teardown]   run keyword and ignore error  csn.Disconnect	connection=${connection}

All UE Detach
    [Arguments]  ${ue_num}=${3}
    FOR    ${ue_index}    IN RANGE    ${ue_num}
        Run Keyword And Ignore error    samsung_spark.detach_ue    ue_alias=UE_${ue_index}
        log to console    UE_${ue_index} Dettach!
    END

##################### Check Counter ######################
Check Release Larged Than Given
    [Arguments]    ${release}=24R1    ${gnb_index}=${0}    ${connection}=GNB_OAM
    ${Y_given_string}=    Get SubString    ${release}    0    2
    ${R_given_string}=    Get SubString    ${release}    3    4
    ${Y_given}    Evaluate    int(${Y_given_string})
    ${R_given}    Evaluate    int(${R_given_string})
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${software}    coam.get_software_info    connection=${connection}
    ${activate_version}    Set Variable    ${software}[Active SW version]
    ${Y_active_string}=    Get SubString    ${activate_version}    4    6
    ${R_active_string}=    Get SubString    ${activate_version}    7    8
    ${Y_active}    Evaluate    int(${Y_active_string})
    ${R_active}    Evaluate    int(${R_active_string})
    ${Is_large}    Set variable if    ${Y_active}>${Y_given}    ${True}
    ...    ${Y_active}==${Y_given} and ${R_active}>${R_given}    ${True}    ${False}
    [Return]    ${Is_large}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections  connection=${connection}

Get Multiple counter result
    [Arguments]    ${counter_id_dict}    ${host_ip}=${gNB_ip}    ${connection}=GNB_COM
    Connect to gnb coam via ssl    bts_host=${host_ip}    username=${gNB_username}    password=${gNB_password}
    ...    connection=${connection}
    ${counter_result_dict}   create dictionary
    ${counter_id_list}    Get Dictionary Keys    ${counter_id_dict}
    FOR    ${counter_id}    IN    @{counter_id_list}
        ${counter_list}    Get From Dictionary    ${counter_id_dict}    ${counter_id}
        ${counter_values}    coam.get pm counters   counter_ids=${counter_id}    connection=${connection}    timeout=90
        ${result_list}   Get Multiple Cell counter result    counter_list=${counter_list}    counter_id=${counter_id}
        ...    counter_values=${counter_values}
        Set To Dictionary    ${counter_result_dict}    ${counter_id}     ${result_list}
    END
    [Return]  ${counter_result_dict}
    [Teardown]    Run Keyword And Ignore Error   coam.teardown      connection=${connection}

Get Multiple Cell counter result
    [Arguments]  ${counter_list}    ${counter_id}    ${counter_values}    ${index}=${0}
    ${result_list}    create list
    FOR    ${counter}    IN    @{counter_list}
        ${BTS}    set variable    ${counter}[0]
        ${CELLS}    set variable    ${counter}[1]
        ${NRCELL}    set variable    ${counter}[2]
        ${counter_object}    set variable    ${counter}[3]
        ${MR_BTS}    set variable    MRBTS-${tl.gnbs[${index}].instance_id}
        ${NR_BTS}    set variable    NRBTS-${tl.gnbs[${index}].global_bts_id}
        ${is_large_24R1_release}    Check Release Larged Than Given    release=24R1    gnb_index=${index}
        ${result}    run keyword if    ${is_large_24R1_release}
        ...    Get Dictionary Values   ${counter_values['${BTS}']['${MR_BTS}']['${NR_BTS}']['${NRCELL}']['${counter_object}']['${counter_id}']}
        ...    ELSE    Get Dictionary Values   ${counter_values['${BTS}']['${CELLS}']['${NRCELL}']['${counter_object}']['${counter_id}']}
        Append To List    ${result_list}    ${result}
    END
    [Return]  ${result_list}

Compare Counter Result
    [Arguments]  ${old_counter_result_dict}    ${counter_id_dict}
    ${counter_id_list}    Get Dictionary Keys    ${counter_id_dict}
    ${old_counter_result}    get from dictionary    ${old_counter_result_dict}    ${counter_id_list}[0]
    ${old_counter_result_length}    Get Length   ${old_counter_result}[0]
    ${new_counter_result_dict}    Get Multiple counter result    counter_id_dict=${counter_id_dict}
    ${new_counter_result}    get from dictionary    ${new_counter_result_dict}    ${counter_id_list}[0]
    ${new_counter_result_length}    Get Length   ${new_counter_result}[0]
    ${length_diff}    Evaluate    ${new_counter_result_length}-${old_counter_result_length}
    should be equal as integers   ${length_diff}  ${2}
    [Return]  ${new_counter_result_dict}

Calculate the total value of counter
    [Arguments]  ${old_counter_result_dict}    ${counter_id_dict}
    ${counter_result_dict}   create dictionary
    ${new_counter_result_dict}    wait until keyword succeeds     12min    30s    Compare Counter Result
    ...    old_counter_result_dict=${old_counter_result_dict}    counter_id_dict=${counter_id_dict}
    ${counter_id_list}    Get Dictionary Keys    ${counter_id_dict}
    FOR    ${counter_id}    IN    @{counter_id_list}
        ${counter_value_list}    get from dictionary    ${new_counter_result_dict}    ${counter_id}
        ${counter_total_result}    List_Element_Add_To_Newlist    input_list=${counter_value_list}
        Set To Dictionary    ${counter_result_dict}    ${counter_id}     ${counter_total_result}
    END
    [Return]  ${counter_result_dict}    ${new_counter_result_dict}

###################### Capture TTI Log #########################
start tti trace
    [Arguments]  ${hw_slot}=${1}    ${connection_for_abil}=${None}
    log to console  start capture tti trace
    Create default connection    hw_slot=${hw_slot}
    Start TTI trace log capturing    hw_slot=${hw_slot}    connection_for_abil=${connection_for_abil}

Capture tti trace log
    [Arguments]  ${time}
    start tti trace
    sleep   ${time}
    Stop TTI trace log capturing
    ${UL_DL_csv_file_path_dict}    Convert TTI trace log and download combined csv logs to test pc
    ...    local_path=${TS_CASE_LOG_PATH}    is_need_to_close_connection=${False}    connection_for_abil=${None}
    ...    connection_for_asik=${None}
    [Return]    ${UL_DL_csv_file_path_dict}

################# Snopshot ###########################
Get Snapshot From BTS
    [Arguments]           ${alias}=cOAM    ${timeout}=10min
    [Documentation]       Gets sanpshot from BTS, Note time varies based on how much time BTS is up
    ...     alias:   AdminConnection object or if used, string name alias
    ...     timeout: Time to wait for positive procedure result
    ${timestamp}=         Get Current Date    result_format=%Y%m%d-%H%M%S
    ${snapshot_path}=     set variable  ${TS_CASE_LOG_PATH}/Snapshot_${timestamp}.zip
    coam.get_snapshot     target_file_name=${snapshot_path}    timeout=${timeout}    connection=${alias}
    [Return]              ${snapshot_path}

Save Snapshot
    [Arguments]    ${connection}=cOAM    ${timeout}=10min
    log to console    Save Snapshot...
    run keyword and ignore error     coam.teardown    connection=${connection}
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
    ...    connection=${connection}
    ${snapshot_path}    5GC002637_common_keywords.Get Snapshot From BTS    alias=${connection}    timeout=${timeout}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}
    [Return]    ${snapshot_path}

Analysis Snapshot
    [Arguments]  ${snapshot_path}    ${connection}
    log to console    Analysis Snapshot...
    csn.Connect to     hostname=${TEST_PC_IP}   username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}
    ...    alias=${connection}
    ${dir_path}    Get_Dir_Path    file_path=${snapshot_path}
    csn.send_command    command=sudo mkdir ${dir_path}    connection=${connection}
    csn.send_command    command=sudo unzip ${snapshot_path} -d ${dir_path}    connection=${connection}
    sleep  20s
    csn.send_command
    ...    command=sudo cat ${dir_path}/snapshot_file_list.txt |awk '{print $1}'| grep -E 'BTS153_133D_part|BTS153_1831_UPUE30_ASP-1831_runtime'
    ...    connection=${connection}
    ${output}    ssh.read output    connection=${connection}
    ${output}    Remove String    ${output}   :
    ${output_list}    split string    ${output}    \n
    FOR    ${out}   IN RANGE  len(${output_list})
        ${if_contain}     run keyword and return status    should contain    ${output_list[${out}]}
        ...    BTS153_1831_UPUE30_ASP-1831_runtime.zip
        ${runtime_number}    set variable if    ${if_contain}   ${out}
        Exit For Loop If    ${if_contain}
    END
    ${part_number}   evaluate    ${runtime_number}-${1}
    ${BTS153_133D_part_zip}    set variable     ${output_list[${part_number}]}
    ${dir_path1}    Get_Dir_Path    file_path=${dir_path}/${BTS153_133D_part_zip}
    csn.send_command    command=sudo mkdir ${dir_path1}    connection=${connection}
    csn.send_command    command=sudo unzip ${dir_path}/${BTS153_133D_part_zip} -d ${dir_path1}    connection=${connection}
    sleep  20s
    ${dir_path2}    Get_Dir_Path    file_path=${dir_path1}/BTS153_1831_UPUE30_ASP-1831_runtime.zip
    csn.send_command    command=sudo mkdir ${dir_path2}    connection=${connection}
    csn.send_command    command=sudo unzip ${dir_path1}/BTS153_1831_UPUE30_ASP-1831_runtime.zip -d ${dir_path2}
    ...    connection=${connection}
    sleep   20s
    ${log_name}    set variable     ${dir_path2}/ASP-1831_runtime.log
    [Return]  ${log_name}
    [Teardown]   run keyword and ignore error  csn.Disconnect	connection=${connection}

##################### Case Step ############################
Case1 modify para by Admin
    Modify Value On DU    structure_modify_list=${case1_structure}    common_modify_list=${case1_common}
    ...    keywords_list=${case1_keywords_list}
    ...    class_name=NRCELL_A    is_structure=${True}    is_common=${True}    structure_index=0    connection=coam_admin

Start Traffic by Spark
    [Arguments]  ${ue_num}    ${log_time}    ${spark_log}    ${ul_throughput}=${None}    ${dl_throughput}=${None}
    ...    ${protocol}=udp    ${if_ul}=${True}   ${if_dl}=${True}       ${duration}=${duration}
    UE attach by Spark    ue_num=${ue_num}
    Start data traffic and Record TP Log    ue_num=${ue_num}    ul_throughput=${ul_throughput}
    ...    dl_throughput=${dl_throughput}    ul_duration=${duration}    dl_duration=${duration}    protocol=${protocol}
    ...     if_ul=${if_ul}    if_dl=${if_dl}
    sleep   ${log_time}
    Stop data traffic and Stop Record TP Log    ue_num=${ue_num}    if_ul=${if_ul}    if_dl=${if_dl}
    ...    protocol=${protocol}    spark_log_name=${spark_log}
    [Teardown]    All UE Detach    ue_num=${ue_num}

Check List of Counter Value Diff
    [Arguments]  ${counter_result_dict}    ${counter_id}    ${expect_max}    ${expect_min}
    ${counter_value_list}    get from dictionary    ${counter_result_dict}    ${counter_id}
    ${counter_value}    Evaluate    ${counter_value_list}[-1] + ${counter_value_list}[-2]
    ${result}    Caculate_Value_Diff    actual_value=${counter_value}    expect_max=${expect_max}
    ...     expect_min=${expect_min}
    Run Keyword And Continue On Failure    Should Be Equal    ${result}    ${True}

Check Each Cell Counter Value
    [Arguments]    ${counter_value_list}    ${expect_max}    ${expect_min}
    ${couter_result_list}    create list
    FOR    ${conter_vlaue}    IN    @{counter_value_list}
        ${total_result}    Evaluate    ${conter_vlaue}[-1] + ${conter_vlaue}[-2]
        ${result}    Caculate_Value_Diff    actual_value=${total_result}    expect_max=${expect_max}
        ...    expect_min=${expect_min}
        Run Keyword And Continue On Failure    Should Be Equal    ${result}    ${True}
    END

Check List of Counter Value Proportion
    [Arguments]  ${counter_result_dict}    ${counter_id}    ${expect_value}    ${proportion}
    ${counter_value_list}    get from dictionary    ${counter_result_dict}    ${counter_id}
    ${counter_value}    Evaluate    ${counter_value_list}[-1] + ${counter_value_list}[-2]
    ${result}    Caculate_Value_Proportion    actual_value=${counter_value}    expect_value=${expect_value}
    ...    proportion=${proportion}
    Run Keyword And Continue On Failure    Should Be Equal    ${result}    ${True}

Check Each Cell Counter Value Proportion
    [Arguments]  ${counter_value_list}    ${expect_value}    ${proportion}
    ${couter_result_list}    create list
    FOR    ${conter_vlaue}    IN    @{counter_value_list}
        ${total_result}    Evaluate    ${conter_vlaue}[-1] + ${conter_vlaue}[-2]
        ${result}    Caculate_Value_Proportion    actual_value=${total_result}    expect_value=${expect_value}
        ...    proportion=${proportion}
        Run Keyword And Continue On Failure    Should Be Equal    ${result}    ${True}
    END

Case1 Check Counter
    [Arguments]  ${counter_result_dict}    ${dl_tp}    ${ul_tp}    ${new_counter_result_dict}
    ${dl_tp_max}    Evaluate    ${dl_tp}*125000
    ${ul_tp_max}    Evaluate    ${ul_tp}*125000
    ${counter_value_list1}    get from dictionary    ${new_counter_result_dict}    M55308C26001
    ${counter_value_list2}    get from dictionary    ${new_counter_result_dict}    M55308C26002
    Check Each Cell Counter Value    counter_value_list=${counter_value_list1}    expect_max=${44000}
    ...    expect_min=${38000}
    Check Each Cell Counter Value    counter_value_list=${counter_value_list2}    expect_max=${44000}
    ...    expect_min=${38000}
    Check List of Counter Value Proportion    counter_result_dict=${counter_result_dict}    counter_id=M55309C12001
    ...    expect_value=${dl_tp_max}    proportion=0.1
    Check List of Counter Value Proportion    counter_result_dict=${counter_result_dict}    counter_id=M55309C12002
    ...    expect_value=${ul_tp_max}    proportion=0.1

Case3 Check Counter
    [Arguments]  ${dl_5G_tp}    ${dl_4G_tp}    ${traffic_time}    ${new_counter_result_dict}
    ${dl_5G_tp_max}    Evaluate    ${dl_5G_tp}*1000*${traffic_time}
    ${dl_4G_tp_max}    Evaluate    ${dl_4G_tp}*8
    ${counter_id_list}    create list    M55350C03007    M55350C05007    M55350C00007
    ${expect_value_list}    create list    ${dl_5G_tp_max}    ${dl_4G_tp_max}    ${6500}
    ${proportion_list}    create list    0.1    0.015    0.3
    ${list_length}    Get Length   ${counter_id_list}
    FOR    ${i}    IN RANGE    ${list_length}
        ${couter_result_list}    Get Each Cell Counter Value    new_counter_result_dict=${new_counter_result_dict}
        ...    counter_id=${counter_id_list}[${i}]
        ${cell1_result}    Caculate_Value_Proportion    actual_value=${couter_result_list}[0]
        ...    expect_value=${expect_value_list}[${i}]    proportion=${proportion_list}[${i}]
        Run Keyword And Continue On Failure    Should Be Equal    ${cell1_result}    ${True}
        Run Keyword And Continue On Failure    should be equal as integers    ${couter_result_list}[1]    ${0}
    END
    ${counter_id_list1}    create list    M55350C01007    M55350C03007    M55350C05007
    ${couter_result_list2}    create list
    FOR    ${counter_id}    IN    @{counter_id_list1}
        ${couter_result_list1}    Get Each Cell Counter Value    new_counter_result_dict=${new_counter_result_dict}
        ...    counter_id=${counter_id}
        Append To List    ${couter_result_list2}    ${couter_result_list1}
    END
    ${counter_value_sum}    Evaluate    ${couter_result_list2[1][0]} + ${couter_result_list2[2][0]}
    ${diff_result1}    Caculate_Difference_Value    actual_value=${couter_result_list2[0][0]}
    ...    expect_value=${counter_value_sum}    expect_diff=${10}
    Run Keyword And Continue On Failure    Should Be Equal    ${diff_result1}    ${True}
    Run Keyword And Continue On Failure    should be equal as integers    ${couter_result_list2[0][1]}    ${0}

Get Counter Result From List
    [Arguments]  ${counter_result_dict}    ${counter_id_list}
    ${counter_result_list}    create list
    FOR    ${counter_id}    IN    @{counter_id_list}
        ${counter_value_list}    get from dictionary    ${counter_result_dict}    ${counter_id}
        ${counter_value}    Evaluate    ${counter_value_list}[-1] + ${counter_value_list}[-2]
        Append To List    ${counter_result_list}    ${counter_value}
    END
    [Return]  ${counter_result_list}

#Case5 Check Counter
#    [Arguments]  ${ul_5G_tp}    ${new_counter_result_dict}
#    ${ul_5G_tp_max}    Evaluate    ${ul_5G_tp}*1000
#    ${counter_id_list}    create list    M55349C02001    M55349C00007    M55349C01007
#    ${expect_value_list}    create list    ${ul_5G_tp_max}    ${5000}
#    ${proportion_list}    create list    0.1    0.1    0.1
#    ${list_length}    Get Length   ${counter_id_list}
#    ${mutil_couter_result_list}    create list
#    FOR    ${counter_id}    IN    @{counter_id_list}
#        ${couter_result_list}    Get Each Cell Counter Value    new_counter_result_dict=${new_counter_result_dict}
#        ...    counter_id=${counter_id}
#        Append To List    ${mutil_couter_result_list}    ${couter_result_list}
#    END
#    ${counter_value_sum}    Evaluate    ${mutil_couter_result_list[1][0]}/${1000}*${mutil_couter_result_list[0][0]}
#    Append To List    ${expect_value_list}    ${counter_value_sum}
#    FOR    ${i}    IN RANGE    ${list_length}
#        ${cell1_result}    Caculate_Value_Proportion    actual_value=${mutil_couter_result_list[${i}][0]}
#        ...    expect_value=${expect_value_list[${i}]}
#        ...    proportion=@{proportion_list}[${i}]
#        Run Keyword And Continue On Failure    Should Be Equal    ${cell1_result}    ${True}
#        Run Keyword And Continue On Failure    should be equal as integers   ${mutil_couter_result_list[${i}][1]}   ${0}
#    END

Case5 Check Counter
    [Arguments]  ${ul_total_5G_tp}    ${new_counter_result_dict}
    ${ul_total_5G_tp}    Evaluate    ${ul_total_5G_tp}*${1024}
    ${counter_id_list}    create list    M55349C00007    M55349C01007    M55349C02001
    ${expect_value_list}    create list    ${5000}    ${ul_total_5G_tp}
    ${proportion_list}    create list    0.1    0.15    0.1
    ${list_length}    Get Length   ${counter_id_list}
    ${mutil_couter_result_list}    create list
    FOR    ${counter_id}    IN    @{counter_id_list}
        ${couter_result_list}    Get Each Cell Counter Value    new_counter_result_dict=${new_counter_result_dict}
        ...    counter_id=${counter_id}
        Append To List    ${mutil_couter_result_list}    ${couter_result_list}
    END
    ${expect_2001_counter_value}   Evaluate    ${mutil_couter_result_list[1][0]}/${mutil_couter_result_list[0][0]}*1000
    Append to list  ${expect_value_list}    ${expect_2001_counter_value}
    FOR    ${i}    IN RANGE    ${list_length}
        ${cell1_result}    Caculate_Value_Proportion    actual_value=${mutil_couter_result_list[${i}][0]}
        ...    expect_value=${expect_value_list[${i}]}
        ...    proportion=${proportion_list}[${i}]
        Run Keyword And Continue On Failure    Should Be Equal    ${cell1_result}    ${True}
        Run Keyword And Continue On Failure    should be equal as integers   ${mutil_couter_result_list[${i}][1]}   ${0}
    END

Get Each Cell Counter Value
    [Arguments]  ${new_counter_result_dict}    ${counter_id}
    ${counter_value_list}    get from dictionary    ${new_counter_result_dict}    ${counter_id}
    ${couter_result_list}    create list
    FOR    ${conter_vlaue}    IN    @{counter_value_list}
        ${total_result}    Evaluate    ${conter_vlaue}[-1] + ${conter_vlaue}[-2]
        Append To List  ${couter_result_list}   ${total_result}
    END
    [Return]  ${couter_result_list}

Capture Snapshot and Get 4G TP
    [Arguments]
    ${snapshot_path}    Save Snapshot
    ${log_name}    Analysis Snapshot    snapshot_path=${snapshot_path}    connection=TEST_PC
    ${dl_4G_tp_max}    Caculate_Value_From_Snapshot    file_path=${log_name}
    [Return]  ${dl_4G_tp_max}

Case Suite Setup
    CI_interface.Common Suite Setup
    robot_common_operations.Common Suite Setup
    Adapt to ute cloud commission scf
    Determine whether to lock based on RU status    lock_ru_list=${5G_RU_id_list_749}    bts_host=10.71.215.244    BTS_ID=${5G_BTS_ID_749}
    Determine whether to lock based on RU status    lock_ru_list=${4G_RU_id_list_749}    bts_host=10.71.215.243    BTS_ID=${4G_BTS_ID_749}


Determine whether to lock based on RU status
    [Arguments]    ${lock_ru_list}    ${bts_host}    ${BTS_ID}    ${ru_expect_status}=${RU_lock_status}
    ${lock_ru_status}    Create Dictionary
    @{tmp_ru_list}    create list
    FOR    ${ru_id}    IN    @{lock_ru_list}
        APPEND TO LIST    ${tmp_ru_list}    ${ru_id}
        Set To Dictionary    ${lock_ru_status}    RMOD-${ru_id}    ${ru_expect_status}
    END
    ${status_list}    Check All RU or Cell Status    expect_item_status_dict=${lock_ru_status}    if_ru=${True}    bts_host=${bts_host}
    ${length}    Get length    ${lock_ru_list}
    FOR    ${item}   IN RANGE    ${length}
        Run Keyword If    ${status_list}[${item}] == ${True}    Remove Values From List     ${lock_ru_list}    ${tmp_ru_list}[${item}]
        log to console    ${tmp_ru_list}
    END
    Lock or Unlock RU And Check Status    lock_RU_id_list=${lock_ru_list}     lock_flag=${True}    bts_host=${bts_host}    BTS_ID=${BTS_ID}

Check All RU or Cell Status
    [Documentation]  expect_item_status_dict eg:
    ...              1) ${cell_status_dict}    Create Dictionary     NRCELL-1=${Cell_unblock_status}    NRCELL-2=${Cell_block_status}
    ...              2) ${ru_status_dict}    Create Dictionary     RMOD-1=${RU_unlock_status}    RMOD-2=${RU_lock_status}
    [Arguments]  ${expect_item_status_dict}    ${if_ru}=${True}   ${bts_host}=${gnb_ip}
    Log To Console    Check All RU or Cell Status
    ${item_status_dic}    Get All RU or Cell Status    if_ru=${if_ru}    bts_host=${bts_host}    connection=GNB_OAM
    @{item_id_list}    get dictionary keys    ${expect_item_status_dict}
    @{status_list}    create list
    FOR  ${item_id}  IN  @{item_id_list}
        ${expect_status_list}     get from dictionary    ${expect_item_status_dict}    ${item_id}
        ${item_status}    set variable    ${item_status_dic['${item_id}']}
        ${status}    run keyword and return status
        ...    Run Keyword If    ${if_ru}    Check Single RU Status    item_status=${item_status}    expect_status_list=${expect_status_list}
        ...    ELSE    Check Single Cell Status    item_status=${item_status}    expect_status_list=${expect_status_list}
        append to list    ${status_list}    ${status}
    END
    [Return]  ${status_list}

Get All RU or Cell Status
    [Arguments]  ${if_ru}=${True}    ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM
    Log to console    Get All RU or Cell Status
    ${item_status_dic}    Create Dictionary
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${ru_info_list}    coam.get_frm    connection=${connection}
    ${cell_info_list}     coam.Get_Cells_Info   cell_type=nr    connection=${connection}
    ${item_info_list}    set variable if    ${if_ru}    ${ru_info_list}    ${cell_info_list}
    ${count_item}    Get Length    ${item_info_list}
    FOR  ${item}  IN RANGE   ${count_item}
        ${item_id_info}  Split String  ${item_info_list[${item}]['id']['configuration']}  separator=/
        ${item_id}    set variable    ${item_id_info[-1]}
        ${item_status}    set variable    ${item_info_list[${item}]['status']}
        set to dictionary    ${item_status_dic}    ${item_id}=${item_status}
    END
    [Return]  ${item_status_dic}
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Check Single RU Status
    [Arguments]  ${item_status}    ${expect_status_list}
    ${admin_status}    get from dictionary    ${item_status}    administrativeState
    Run Keyword And Continue On Failure    should be equal as strings   ${admin_status}    ${expect_status_list[${0}]}
    ${operate_status}    get from dictionary    ${item_status}    operationalState
    Run Keyword And Continue On Failure    should be equal as strings    ${operate_status}    ${expect_status_list[${1}]}
    ${usage_status}    get from dictionary    ${item_status}    usageState
    Run Keyword And Continue On Failure    should be equal as strings    ${usage_status}    ${expect_status_list[${2}]}
    ${procedure_status}    get from dictionary    ${item_status}    proceduralStatus
    Run Keyword And Continue On Failure    should be equal as strings    ${procedure_status}    ${expect_status_list[${3}]}

Check Single Cell Status
    [Arguments]  ${item_status}    ${expect_status_list}
    Check Single RU Status    item_status=${item_status}    expect_status_list=${expect_status_list}
    ${block_status}    get from dictionary    ${item_status}    blockingState
    Run Keyword And Continue On Failure    should be equal as strings   ${block_status}    ${expect_status_list[${-1}]}

Lock or Unlock RU And Check Status
    [Arguments]  ${BTS_ID}   ${lock_RU_id_list}=${empty_list}     ${unlock_RU_id_list}=${empty_list}    ${lock_flag}=${True}   ${bts_host}=${gnb_ip}
    ${operate_ru_id_list}    Set Variable If    ${lock_flag}    ${lock_RU_id_list}    ${unlock_RU_id_list}
    Lock or UnLock Multiple RU    RMOD_id_list=${operate_ru_id_list}    lock_flag=${lock_flag}    bts_host=${bts_host}    BTS_ID=${BTS_ID}
    ${expect_item_status_dict}    create dictionary
    FOR  ${item}  IN    @{lock_RU_id_list}
        Set to dictionary    ${expect_item_status_dict}    RMOD-${item}=${RU_lock_status}
    END
    FOR  ${item1}  IN   @{unlock_RU_id_list}
        Set to dictionary    ${expect_item_status_dict}    RMOD-${item1}=${RU_unlock_status}
    END
    Check All RU or Cell Status    expect_item_status_dict=${expect_item_status_dict}    if_ru=${True}    bts_host=${bts_host}

Lock or UnLock Multiple RU
    [Arguments]    ${RMOD_id_list}   ${BTS_ID}    ${lock_flag}=${True}    ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM    ${timeout}=60
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    FOR  ${RMOD_id}  IN  @{RMOD_id_list}
        ${dist_name}    Set Variable    MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${RMOD_id}
        Run keyword if    ${lock_flag}==${True}    Log To Console    Lock RMOD-${RMOD_id}
        ...    ELSE    Log To Console    UnLock RMOD-${RMOD_id}
        Run keyword if    ${lock_flag}==${True}    coam.lock    dist_name=${dist_name}    timeout=${timeout}    connection=${connection}
        ...    ELSE    coam.unlock    dist_name=${dist_name}    timeout=${timeout}    connection=${connection}
        sleep    8s
    END
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
