*** Settings ***
Documentation    CB010774 TA cases common steps
...              Author: jun.8.chen@nokia-sbell.com

Resource    CB010774_common.robot


*** Variables ***
${MRBTS_ID}    ${tl.gnbs[0].instance_id}
${NRBTS_ID}    ${tl.gnbs[0].global_bts_id}
&{framestructure_1208}    1=1208    2=1208
&{framestructure_1070}    1=1070    2=1070
&{framestructure_11160ms}    1=11160ms    2=11160ms
&{framestructure_11163ms}    1=11163ms    2=11163ms
&{framestructure_8406}    1=8406    2=8406


*** Keywords ***
CB010774_B_B7_paging_broadcast_for_Idle_state_Ues_for_cell_with_5GC001116_0ms
#    Update R&D Debug Parameter
    10774 Update Related Parameters For Paging
    Wait Gnb Ready And Cell On Air
    # Start to do case steps
    ${slot_in_fact_list}    Create List    6    7    8
    Set Test Variable    ${slot_in_fact_list}
    Start To Do Case Steps And Check The Related Logs    slot_in_fact_list=${slot_in_fact_list}
    Start To Check L1L2 Error Info From Syslog

CB010774_B_B6_paging_broadcast_for_Idle_state_Ues_for_cell_with_CB012269_CB008406
    ${slot_in_fact_list}    Create List    1
    Set Test Variable    ${slot_in_fact_list}
    Start To Do Case Steps And Check The Related Logs    slot_in_fact_list=${slot_in_fact_list}
    Start To Check L1L2 Error Info From Syslog

CB010774_B_B5_paging_broadcast_for_Idle_state_Ues_for_cell_with_CB012269_5GC001070_BBPooling_Enabled
    ${slot_in_fact_list}    Create List    5    5    5
    Set Test Variable    ${slot_in_fact_list}
    Start To Do Case Steps And Check The Related Logs    slot_in_fact_list=${slot_in_fact_list}
    ...                                                  frame_len=${3}
    ...                                                  whether_check_DCI_for_pci300=${True}
    Start To Check L1L2 Error Info From Syslog

CB010774_B_B4_paging_broadcast_for_Idle_state_Ues_for_cell_with_CB012269_5GC001208
    ${slot_in_fact_list}    Create List    5    6    15
    Set Test Variable    ${slot_in_fact_list}
    Start To Do Case Steps And Check The Related Logs    slot_in_fact_list=${slot_in_fact_list}
    Start To Check L1L2 Error Info From Syslog

10774_Suite_SetUp
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}    ${gnb_index}=${0}
    run keyword and ignore error    Check And Power on RUs
    ${swconfig_path}    Set Variable    ${CURDIR}/swconfig.txt
    Common_setup_and_teardown.Upload Swconfig File Via LMP    swconfig_path=${swconfig_path}
    ${gnb_status}    Run Keyword And Return Status    CI_interface.Common Suite Setup    gnb_index=${gnb_index}
    run keyword if    not ${gnb_status}    run keywords
    ...    run keyword and ignore error    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl    AND
    ...    Run Keyword And Ignore Error    COAM Save snapshot via rest api    log_path=${OUTPUT DIR}/Case_Logs    timeout=${600}
    robot_common_operations.Common Suite Setup
    Run Keyword And Ignore Error    clear vm pid before run case
    ${ue_type}    translate_power_ue_type_from_testline
    Set Suite Variable    ${ue_type}
    ${stream_version}    Get Active SW Version Based On Stream Version
    Set Suite Variable    ${STREAM_VERSION}    ${stream_version}
    ${SCF_Path}    ${result}    Split String From Right    ${CURDIR}    testsuite     1
    ${ute_env}    Run Keyword And Return Status    Run Keywords
    ...    Variable Should Exist    ${CONFIGURATION}    AND    Variable Should Exist    ${ENB_BUILD}
    ${tmp_testline}   Run Keyword If    ${ute_env}    String.Fetch From Right    string=${CONFIGURATION}    marker=.
    ...           ELSE    Set Variable     ${testline_name}
    ${stream}    ${build}     Run Keyword If    ${ute_env}    CI_commssion._Get Stream From Variable    ${ENB_BUILD}
    ...    ELSE   CI_commssion._Get Stream From Variable    ${AF_PATH}
    Set Suite Variable    ${tmp_testline}
    ${tl_prefix}    Set Variable    ${tmp_testline.split('_')[-1][-4:]}
    Set Suite Variable    ${TL_NAME}    ${tl_prefix}
    Set Suite Variable    ${stream}
    Set Suite Variable    ${SCF_PATH}
    ${Golden_SCF_Path}    Set Variable    ${SCF_PATH}commissionings/HGZ/${tmp_testline}/SCF_${stream}.xml
    Set Suite Variable    ${Golden_SCF_Path}
    run keyword and ignore error    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl
    run keyword if  not ${gnb_status}   run keywords    Power Reset All RF    AND
    ...                                                               Upgrade RF Version For Gnb
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    Suite Log Path Create
    Procedures.UE Prepare    ue_type=${ue_type}
    Run Keyword And Ignore Error    MTK_common_keywords.Do UE Detach    ue_index=${ue_index}
    Sleep    5sec

10774_Case_SetUp
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${framestructure}=${None}    ${update_params}=${None}    ${chbw}=${None}
    Log To Console    \n***start to case setup***
    ${frame_str}    Set Variable If    '${framestructure}'=='${None}'    ${None}    ${framestructure_${framestructure}}
#    ${allowed_faults_ids}    Create List     4681
#    robot_common_operations.Common Case Setup    fail_with_alarms=${True}    allowed_faults_ids=${allowed_faults_ids}
    robot_common_operations.Common Case Setup    fail_with_alarms=${False}
    ${gnb_allowed_fault_Before_Commission}   Create List    4203    1838    4741    4681   7311   7331
    ...                                                     4293    4297    4420    4775   1932   1934    1933
    Set Test Variable    ${gnb_allowed_fault_Before_Commission}
    AlarmWatchdog.add_allow_alarms    fault_id=${gnb_allowed_fault_Before_Commission}
    Create Case Log Path
    ${scf_path}    Set Variable    ${Golden_SCF_Path}
    ${scf_with_framestructure}    update_framestructure_chbw_pdcch_params    framestructure=${frame_str}
    ...    basic_scf_path=${scf_path}    update_scf_path=${TS_CASE_LOG_PATH}/SCF_${stream}_framestructure_update.xml
    ...    modify_param=${STREAM_VERSION}    whether_do_pdcch_modify=False    modify_cell_chbw_dict=${chbw}
    ${scf_with_update_params}    perform_update_scf_params
    ...                          update_params=${update_params}
    ...                          basic_scf_path=${scf_with_framestructure}
    ...                          update_scf_path=${TS_CASE_LOG_PATH}/SCF_${stream}_final_update.xml
    Perform Commission    scf_file_path=${scf_with_update_params}
    ...                   gnb_index=${0}
    ...                   timeout_for_commission=900
    ...                   wait_gnb_up_timeout=20 min
    ...                   is_pdl_checking_needed=${True}
    ${summary_alarm_info}    Get Active Alarms And Save Summary Infomation
    Set Test Variable    ${summary_alarm_info}
    ${allowed_faults_list}    Combine Current Active Alarm With White List Alarm List
    Set Test Variable    ${ALLOWED_FAULTS_LIST}    ${allowed_faults_list}

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

Power Reset All RF
    ${rus}   Set Variable   ${tl.gnbs[0].dus[0].rus}
    ${ru_count}   Get Length   ${rus}
    FOR   ${index}    IN RANGE    ${ru_count}
        ${pb_host}   Set Variable   ${rus[${index}].pdu_port.pdu.addr}
        ${pb_port}   Set Variable   ${rus[${index}].pdu_port.port_no}
        ${pb_model}   Set Variable   ${rus[${index}].pdu_port.pdu.__class__.__name__}
        pdu.setup_pdu    model=${pb_model}   host=${pb_host}   alias=ru_${index}
        pdu.power_off    port=${pb_port}    pdu_device=ru_${index}
        Sleep    5sec
        pdu.power_on    port=${pb_port}    pdu_device=ru_${index}
    END

Upgrade RF Version For Gnb
    run keyword and ignore error    COAM Teardown gnb connections
    run keyword and ignore error    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl
    ${bts_stream}    ${bts_version}    Split String From Right    ${Active_SW_version}    ENB     1
    ${testline_name}  Get Variable Value    ${testline_name}
    WAIT UNTIL KEYWORD SUCCEEDS    15min    30s    CI_commssion.All Hw Should Be Detected    testline=${testline_name}
    ...                                                                  build=${stream}_ENB${bts_version}    stream=${stream}    ute_env=${True}

10774_Case_SetUp_8406
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    ${update_params}    Set Variable If    '${stream}'=='SBTS25R3'    ${UPDATE_PARAMETERS_FOR_8406}    ${UPDATE_PARAMETERS_FOR_8406_TRUNK}
    10774_Case_SetUp    update_params=${update_params}

10774_Case_SetUp_1070
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    ${update_params}    Set Variable If    '${stream}'=='SBTS25R3'    ${UPDATE_PARAMETERS_FOR_1070}    ${UPDATE_PARAMETERS_FOR_1070_TRUNK}
    10774_Case_SetUp    update_params=${update_params}

10774_Case_SetUp_1208
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    ${update_params}    Set Variable If    '${stream}'=='SBTS25R3'    ${UPDATE_PARAMETERS_FOR_1208}    ${UPDATE_PARAMETERS_FOR_1208_TRUNK}
    10774_Case_SetUp    update_params=${update_params}

10774_Case_Teardown
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}
    Run Keyword And Continue On Failure    robot_common_operations.Common Case Teardown
    Run Keyword And Ignore Error    run    command=ps -ef | grep firefox |awk '{print $2}' | xargs kill -9
    Run Keyword And Ignore Error    COAM Teardown gnb connections
    Run Keyword And Ignore Error    Close the iperf process on android ue    ue_index=${ue_index}    iperf_port=${UL_PORT}
    Run Keyword And Ignore Error    Close the iperf process on APPserver    port=${DL_PORT}
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}
    Run Keyword And Ignore Error    Common Case Teardown    is_save_snapshot=False
    Run Keyword And Ignore Error    Capture Snapshot If Case Failed
    Check Whether New Alarm Happened During Running Case    alarm_info_before=${summary_alarm_info}

10774_Suite_Teardown
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=GNB_OAM
    robot_common_operations.Common Suite Teardown

Start To Do Case Steps And Check The Related Logs
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${slot_in_fact_list}    ${frame_len}=${1}    ${pci}=299    ${whether_check_DCI_for_pci300}=${False}
    Log Many    ${slot_in_fact_list}    ${frame_len}    ${pci}    ${whether_check_DCI_for_pci300}
    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
#    Change status for parameter cellBarred on GNB    exp_status=notBarred    list_cell_ids=1    connection=GNB_OAM    timeout=300
    Log To Console    ${\n}INFO:--- start to attach ---
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log    tcpdump_collector_name=cpif_attach
    ...                                                                             cprt_collector_name=cprt_attach
    ...                                                                             asik_connection_alias=ASIK Master
    ...                                                                             gnb_index=${0}
    ${status}    Run Keyword And Return Status    CB010774 UE Attach For Paging
    Sleep    10sec
    Run Keyword If    '${status}'=='False'    Run Keywords    Log To Console    --- start attach for second time ---
    ...                                                       AND    CB010774 UE Attach For Paging
    Sleep    30sec
    ${attach_log_on_testPC}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection
    ...                                                                        tcpdump_collector_name=cpif_attach
    ...                                                                        cprt_collector_name=cprt_attach
    ...                                                                        gnb_index=${0}
    ...                                                                        asik_connection_alias=ASIK Master
    ${ue_ip}    M60_Redcap.Get UE IP    attach_cpif_log=${attach_log_on_testPC}
    Check UE Enter Into RRC Idle State For WA    wireshark_log=${attach_log_on_testPC}
    Log To Console    ${\n}INFO:--- start to paging ---
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    Set Test Variable    ${wireshark_log_name}    cpif_paging_${timestamp}
    Set Test Variable    ${cprt_log_name}    cprt_paging_${timestamp}
    Recover Collect Syslog For Gnb
    Run Keyword And Continue On Failure    Start Btslog With Path Check
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log    tcpdump_collector_name=${wireshark_log_name}
    ...                                                                             cprt_collector_name=${cprt_log_name}
    ...                                                                             asik_connection_alias=ASIK Master
    ...                                                                             gnb_index=${0}
    ${expect_pci}    Create List    299    300
    Run Keyword And Continue On Failure    Collect Interface Mirroring Bip Collector    nr_phy_cell_ids=${expect_pci}
    ...                                                                                 target_file_name=bip_log_paging
    ${timestamp_for_paging_start}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${counter_generatd_time}    robot.libraries.DateTime.Convert Date 	  ${timestamp_for_paging_start}    epoch
    Run Keyword And Continue On Failure    M60_RedCap.Start DL traffic    ue_addr=${ue_ip}    dl_throughput=1MKbits/sec
    Sleep    5sec
    ${bip_log_normal}    Run Keyword And Continue On Failure    Get Bip Log Via Interface Mirroring Collector
    ...                                                                     target_file_name=bip_log_paging
    ${paging_log_on_testPC}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection
    ...                                                                        tcpdump_collector_name=${wireshark_log_name}
    ...                                                                        cprt_collector_name=${cprt_log_name}
    ...                                                                        gnb_index=${0}
    ...                                                                        asik_connection_alias=ASIK Master
    Run Keyword And Continue On Failure    Stop Btslog With Path Check    target_dir=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    Sleep    5sec
    Run Keyword And Continue On Failure    M60_RedCap.Stop Traffic    ul_traffic=${False}
    Log To Console    ${\n}INFO:--- start to check the case logs ---
    Run Keyword And Continue On Failure    Check Paging Send On F1AP After Inactive    wireshark_log=${paging_log_on_testPC}
    Run Keyword And Continue On Failure    Check RRC Resume After Paging    wireshark_log=${paging_log_on_testPC}
    Run Keyword And Continue On Failure    Check Paging Send To L1 Via BIP    bip_log=${bip_log_normal[0]}
#    Run Keyword And Continue On Failure    Check DCI Item Via BIP    bip_log=${bip_log_normal[0]}
#    ...                                                              pci=${pci}
#    ...                                                              frame_len=${frame_len}
#    ...                                                              slot_in_fact_list=${slot_in_fact_list}
#    Run Keyword If    ${whether_check_DCI_for_pci300}    Run Keyword And Continue On Failure
#    ...                                                      Check DCI Item Via BIP    bip_log=${bip_log_normal[0]}
#    ...                                                                                pci=300
#    ...                                                                                frame_len=${frame_len}
#    ...                                                                                slot_in_fact_list=${slot_in_fact_list}
    Run Keyword And Continue On Failure    Verify The Paging Information In Syslog    syslog_file_path=btslog_${timestamp}/btslog
    Run Keyword And Continue On Failure    Check L1L2 Error Info From Syslog    btslog_path=${TS_CASE_LOG_PATH}/btslog_${timestamp}
#    Sleep    6min
#    ${counter_info_dict_list}    BTS Counters List For Inactive
#    ${counter_id_mapping_values}    Get PM Counter Values Information    counter_generatd_time=${counter_generatd_time}
#    ...                                                                  counter_info_dict_list=${counter_info_dict_list}
#    Verify PM Counter Values For Inactive    count_of_CNPagingCNT=${count_of_CNPagingCNT}
#    ...                                      counter_id_mapping_values=${counter_id_mapping_values}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    core.stop_collectors    names=${wireshark_log_name}    AND
    ...                           Run Keyword And Ignore Error    core.teardown_collectors    names=${wireshark_log_name}    AND
    ...                           Run Keyword And Ignore Error    core.stop_collectors    names=${cprt_log_name}    AND
    ...                           Run Keyword And Ignore Error    core.teardown_collectors    names=${cprt_log_name}    AND
    ...                           Run Keyword And Ignore Error    core.stop_collectors    names=bip_log_paging    AND
    ...                           Run Keyword And Ignore Error    core.teardown_collectors    names=bip_log_paging
