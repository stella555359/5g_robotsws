*** Settings ***
Documentation    author：Hongyu Jiang
...              contact: hongyu.jiang@nokia-sbell.com
...              squad group: mmw_SG_04



Library     Process
Library     taf.collectors.tcpdump    WITH NAME    tcpdump
Library     taf.collectors.l2stream3    WITH NAME    l2stream3
Library     taf.collectors.core    WITH NAME    core
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/mmw4_coam_cloud_gnb.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/SISO_common_operation.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/TTI_stream_Analysis_MMW4.py
Library     TTI_stream_Analysis_MMW4.TTI_Stream_analysis    WITH NAME    TTI_Stream
Library     ./CB013440_common_keyword.py


*** Variables ***
${CU_IP}              ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${CU_username}        ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${CU_password}        ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${DU_IP}              ${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
${DU_username}        ${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
${DU_password}        ${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
${DU_OAM_IP}          ${tl.gnbs[0].dus[0].oam_http_connection_details.addr}
${DU_OAM_username}    ${tl.gnbs[0].dus[0].oam_http_connection_details.username}
${DU_OAM_password}    ${tl.gnbs[0].dus[0].oam_http_connection_details.password}
${TEST_PC_IP}         ${tl.test_pc.default_ssh_connection_details.addr}
${TEST_PC_USERNAME}   ${tl.test_pc.default_ssh_connection_details.username}
${TEST_PC_PASSWORD}   ${tl.test_pc.default_ssh_connection_details.password}
@{cell_list}          ${GNB_CELL_NAME}2    ${GNB_CELL_NAME}5    ${GNB_CELL_NAME}6
${CURDIR_path}        ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}
@{dl_cell_list}       613433346    613433349    613433350
${eNB_ip}             ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${ul_port_list}       ${tl.ues[0].data_transfer[0].app_server.ports[0:2]}
${dl_port_list}       ${tl.ues[0].data_transfer[0].app_server.ports[2:4]}
@{all_PA_port_list}          ${0}    ${1}    ${2}    ${3}    ${4}    ${5}    ${6}    ${7}    ${8}    ${10}    ${11}    ${12}
@{default_PA_value_list}     ${0}    ${0}    ${0}    ${0}    ${127}    ${127}    ${127}    ${127}   ${127}   ${127}   ${127}   ${127}
@{case10_PA_value_list1}     ${0}    ${127}    ${0}    ${127}    ${127}    ${127}    ${127}    ${127}   ${127}   ${127}   ${127}   ${127}
@{case10_PA_value_list2}     ${127}    ${127}    ${127}    ${127}    ${127}    ${127}    ${127}    ${127}   ${0}   ${127}   ${127}   ${0}
@{case7_PA_value_list}       ${127}    ${127}    ${127}    ${127}   ${127}   ${127}   ${127}   ${127}   ${0}   ${0}   ${0}   ${0}
@{case8_PA_value_list}       ${127}    ${127}    ${127}    ${127}   ${0}   ${0}   ${0}   ${0}   ${127}   ${127}   ${127}   ${127}
@{caseB7_PA_value_list1}     ${127}    ${127}    ${127}    ${127}   ${35}   ${35}   ${35}   ${35}   ${127}   ${127}   ${127}   ${127}
@{caseB7_PA_value_list2}     ${127}    ${127}    ${127}    ${127}   ${50}   ${50}   ${50}   ${50}   ${127}   ${127}   ${127}   ${127}
@{caseB3_PA_value_list1}     ${127}    ${127}    ${127}    ${127}   ${127}   ${127}   ${127}   ${127}   ${15}   ${15}   ${15}   ${15}
@{caseB3_PA_value_list2}     ${127}    ${127}    ${127}    ${127}   ${127}   ${127}   ${127}   ${127}   ${35}   ${35}   ${35}   ${35}







*** Keywords ***
CB013440 Suite Setup
    mmw4_coam_cloud_gnb.Set Default Scf
    CU Full Commssion By Rest    path_of_commission_file=${CURDIR_path}/gnb0/cu/${default_cu_scf}
    vDU Full Commssion By Rest    scf_path=${CURDIR_path}/gnb0/dus_0/${default_du_scf}
    Wait Until Keyword Succeeds    20 min   30s    Check vDU And CU On Air
    ${tti_dec_path}    Download TTI Decoder Tool
    Run    pip3 install pandas --proxy=http://10.144.1.10:8080

Case Setup
    Create Directory    ${OUTPUT_DIR}/${TEST NAME}

Case Teardown
    [Arguments]    ${du_para}=None    ${cu_para}=None    ${enb_para}=None    ${PA_value_list}=${default_PA_value_list}
    Run Keyword If    "${TEST_STATUS}"=="FAIL"    Collect vdu snapshot
    Modify Parameter And Adjust PA    du_para=${du_para}    cu_para=${cu_para}    enb_para=${enb_para}    PA_value_list=${PA_value_list}

Capture Syslog And Check TP
    [Arguments]    ${ul_list}    ${dl_list}    ${exp_ul_tp}    ${exp_dl_tp}    ${syslog_filename}=L2RT_SYSLOG    ${time}=30s
    ...    ${if_ul}=${True}    ${if_dl}=${True}
    sleep   20s
    Start Capture SYSLOG on Cloud DU    syslog_filename=${syslog_filename}
    sleep   ${time}
    Stop Capture SYSLOG on Cloud DU
    ${log_path}    Download syslog from Cloud DU    syslog_filename=${syslog_filename}
    ${ul_avg}    ${dl_avg}    Check TP From Aasyslog   ul_list=${ul_list}    dl_list=${dl_list}    exp_ul_tp=${exp_ul_tp}
    ...    exp_dl_tp=${exp_dl_tp}    log_path=${log_path}    if_ul=${if_ul}    if_dl=${if_dl}
    [Return]    ${ul_avg}    ${dl_avg}

Check TP From Aasyslog
    [Arguments]    ${ul_list}    ${dl_list}    ${exp_ul_tp}    ${exp_dl_tp}    ${log_path}    ${if_ul}=${True}    ${if_dl}=${True}
    ${ul_output}    run keyword and continue on failure    run keyword if    ${if_ul}==${True}    power_ue.Check Tput    ue_type=samsung
    ...    direction=UL    log=${log_path}    cells=${ul_list}    target_throughput=${exp_ul_tp}    target_avg_percent=1
    ...    actCarrierAggregation=${True}    min_percent=0
    ${dl_output}    run keyword and continue on failure    run keyword if    ${if_dl}==${True}    power_ue.Check Tput    ue_type=samsung
    ...    direction=DL    log=${log_path}    cells=${dl_list}    target_throughput=${exp_dl_tp}    target_avg_percent=1
    ...    actCarrierAggregation=${True}    min_percent=0
    ${ul_avg_tp}    Get From Dictionary    ${ul_output[${0}]}    average
    ${dl_avg_tp}    Get From Dictionary    ${dl_output[${0}]}    average
    Log To Console    DL avg tp is ${dl_avg_tp}
    Log To Console    UL avg tp is ${ul_avg_tp}
    [Return]    ${ul_avg_tp}    ${dl_avg_tp}

Check Bler From Ttilog
    [Arguments]    ${tti_path}    ${except_dl_bler}    ${except_ul_bler}    ${tti_name}=tcpdump_ttitrace    ${check_ul_bler}=${True}
    ...    ${check_dl_bler}=${True}
    ${dl_tti_file}    Get From Dictionary    ${tti_path}    ${tti_name}_dl
    ${ul_tti_file}    Get From Dictionary    ${tti_path}    ${tti_name}_ul
    ${dl_bler}    Run Keyword If    ${check_dl_bler}    TTI_Stream.get_HarqRxDataArray_ackNack_number    file_path=${dl_tti_file}    direction=dl
    ...    ELSE    Set Variable    ${0}
    ${ul_bler}    Run Keyword If    ${check_ul_bler}    TTI_Stream.get_ulFdSchedData_txNumber_data    file_path=${ul_tti_file}
    ...    ELSE    Set Variable    ${0}
    Run Keyword And Continue On Failure    Should Be True    ${dl_bler}<=${except_dl_bler}
    Run Keyword And Continue On Failure    Should Be True    ${ul_bler}<=${except_ul_bler}
    Log To Console    DL bler is ${dl_bler}
    Log To Console    UL bler is ${ul_bler}
    [Return]    ${ul_bler}    ${dl_bler}

Capture Bip Log
    [Arguments]    ${bip_log_name}
    Stop L1L2bip log for Cloud DU
    Start L1L2bip log for Cloud DU
    sleep    2s
    Stop L1L2bip log for Cloud DU
    ${log_full_path_ute}    Download L1L2bip log for Cloud DU    log_name=${bip_log_name}
    ${log_path}    Replace String    ${log_full_path_ute}    ${bip_log_name}.pcap    ${bip_log_name}
    Log To Console    ${log_path}
    [Return]    ${log_path}

Check Bip Log
    [Arguments]    ${log_path}    ${filter}    ${field_name}    ${pdml_name}=${EMPTY}
    Covert Pcap To Pdml    pcap_file=${log_path}.pcap   output_file=${log_path}${pdml_name}.pdml   filter='${filter}'
    ${field_value_list}    Get_packet_info   file_path=${log_path}${pdml_name}.pdml    field_name=${field_name}
    [Return]    ${field_value_list}

Get Multi field Value
    [Arguments]    ${field_name_list}    ${log_path}    ${get_all_value}=${False}
    ${field_value_dict}    Create Dictionary
    FOR   ${field_name}  IN   @{field_name_list}
        ${field_value_list}    Get_packet_info   file_path=${log_path}    field_name=${field_name}
        ${field_name}    Split String    ${field_name}    separator=.
        ${field_name}    Set Variable    ${field_name[${-1}]}
        Run Keyword If    ${get_all_value}    Set To Dictionary    ${field_value_dict}   ${field_name}    ${field_value_list}
        ...    ELSE    Set To Dictionary    ${field_value_dict}   ${field_name}    ${field_value_list[${0}]}
    END
    [Return]    ${field_value_dict}

Check Multi Message From Bip
    [Arguments]    ${log_path}    ${filter}    ${cell_list}    ${field_name_list}    ${pdml_name}    ${check_value_list}
    ...   ${normal_field}=${True}    ${abnormal_field}=${False}    ${get_all_value}=${False}
    ${abnormal_value_dict}    Create Dictionary
    ${normal_value_dict}    Create Dictionary
    ${len}    Get Length    ${cell_list}
    FOR   ${i}  IN RANGE  ${len}
        ${covert_filter}    Run Keyword If    ${len}==${1}    Set Variable    ${filter}
        ...    ELSE    Catenate    ${filter}    ${cell_list[${i}]})
        ${pdml_file_path}    Set Variable    ${log_path}_${pdml_name}_${i}.pdml
        Covert Pcap To Pdml    pcap_file=${log_path}.pcap   output_file=${pdml_file_path}   filter='${covert_filter}'
        ${abnormal_value_dict}    Run Keyword If    ${abnormal_field}    Extract_Pdlm_Message    filename=${pdml_file_path}
        ...    get_all_value=${get_all_value}
        ${normal_value_dict}    Run Keyword If    ${normal_field}    Get Multi field Value    field_name_list=${field_name_list}
        ...    log_path=${pdml_file_path}    get_all_value=${get_all_value}
        ${all_field_value_dict}   Merge_Two_Dictionaries    Dictionary1=${normal_value_dict}   Dictionary2=${abnormal_value_dict}
        ${compare_result_dict}    ${compare_result_value}    Check_Dictionary_Value_As_expect    actual_dict=${all_field_value_dict}
        ...    expect_dict=${check_value_list[${i}]}
        Run Keyword And Continue On Failure    List Should Not Contain Value    ${compare_result_value}    ${False}
        Log To Console    ${all_field_value_dict}
    END

Check Multi Times By Diff Filter
    [Arguments]    ${log_path}    ${filter_list}    ${check_cell_list}    ${check_field_list}    ${pdml_name_list}
    ...    ${expect_value_list}    ${normal_field_list}    ${abnormal_field_list}    ${get_all_value}=${False}
    ${len}   Get Length    ${filter_list}
    FOR  ${i}  IN RANGE   ${len}
        Log To Console    ${filter_list[${i}]}
        Check Multi Message From Bip    log_path=${log_path}    filter=${filter_list[${i}]}    cell_list=${check_cell_list[${i}]}
        ...    field_name_list=${check_field_list[${i}]}    pdml_name=${pdml_name_list[${i}]}    check_value_list=${expect_value_list[${i}]}
        ...    normal_field=${normal_field_list[${i}]}    abnormal_field=${abnormal_field_list[${i}]}    get_all_value=${get_all_value}
    END

Modify Parameter And Adjust PA
    [Arguments]    ${du_para}=None    ${cu_para}=None    ${enb_para}=None    ${PA_value_list}=None    ${PA_port_list}=${all_PA_port_list}
    Run Keyword If    ${du_para} != None    VDU Online Change Parameters Activate    updated_paras_list=${du_para}
    Run Keyword If    ${cu_para} != None    CU Online Change Parameters Activate    updated_paras_list=${cu_para}
    Run Keyword If    ${enb_para} != None    Modify Parameters with json    input_list=${enb_para}    bts_host=${eNB_ip}    password=nemuuser
    Wait Until Keyword Succeeds    20 min   30s    Check vDU And CU On Air
    Run Keyword If    ${PA_value_list} != None    Adjust the HBTE attenuation values    value_list=${PA_value_list}    port_list=${PA_port_list}

UE attach Mutile Time And Capture Tcpdump
    [Arguments]    ${ue_index}    ${ue_type}=samsung_ue     ${attach_time}=${2}    ${pcap_filename}=tcpdump_cplane_cu    ${filter}=x2ap
    Start Capture tcpdump on Cloud CU    pcap_filename=${pcap_filename}
    FOR  ${i}   IN RANGE    ${attach_time}
        Single UE Attach    ue_index=${ue_index}    ue_type=${ue_type}
        sleep   2s
        Single UE detach    ue_index=${ue_index}    ue_type=${ue_type}
        sleep   2s
    END
    Stop Capture tcpdump on Cloud CU
    ${pcap_full_path}    Download tcpdump from Cloud CU    pcap_filename=${pcap_filename}
    ${txt_full_path}    Convert pcap to text    pcap_filename=${pcap_filename}    filter=${filter}
    [Return]    ${txt_full_path}

UE Start Traffic
    [Arguments]    ${ue_index}    ${ue_type}=samsung_ue    ${ul_throughput}=${None}    ${dl_throughput}=${None}
    ...    ${ul_duration}=6000    ${dl_duration}=6000    ${protocol}=udp    ${if_ul}=${True}    ${if_dl}=${True}
    Run Keyword And Ignore Error    run keyword if     ${if_ul}    power_ue.Start traffic    direction=ul    duration=${ul_duration}
    ...    protocol=${protocol}    ue_index=${ue_index}    iperf_port=${ul_port_list[${ue_index}]}    throughput=${ul_throughput}
    ...    ue_type=${ue_type}    apn_address=dxdata1    iperf_type=via_command
    run keyword and continue on failure    run keyword if     ${if_dl}    power_ue.Start traffic    direction=dl    duration=${dl_duration}
    ...    protocol=${protocol}    ue_index=${ue_index}    iperf_port=${dl_port_list[${ue_index}]}    throughput=${dl_throughput}
    ...    ue_type=${ue_type}

UE Stop Traffic
    [Arguments]    ${ue_index}    ${ue_type}=samsung_ue    ${protocol}=udp    ${if_ul}=${True}    ${if_dl}=${True}
    Run Keyword And Ignore Error    run keyword if    ${if_ul}    power_ue.Stop traffic    direction=ul    ue_index=${ue_index}
    ...    ue_type=${ue_type}    protocol=${protocol}    iperf_port=${ul_port_list[${ue_index}]}    iperf_type=via_command
    run keyword and continue on failure    run keyword if    ${if_dl}    power_ue.Stop traffic    direction=dl    ue_index=${ue_index}
    ...    ue_type=${ue_type}    protocol=${protocol}    iperf_port=${dl_port_list[${ue_index}]}

Start Capture SYSLOG And Download
    [Arguments]    ${file_name}=L2RT_SYSLOG    ${syslog_time}=1min
    sleep  20s
    Start Capture SYSLOG on Cloud DU    syslog_filename=${file_name}
    sleep  ${syslog_time}
    Stop Capture SYSLOG on Cloud DU
    ${ute_log_path}    Download syslog from Cloud DU    syslog_filename=${file_name}    remote_path=/tmp
    [Return]    ${ute_log_path}

Capture TTi Log
    [Arguments]    ${cell_dn_list}    ${time}=3s    ${output_name}=tcpdump_ttitrace
    Get L2stream logs using cOAM cli from Cloud DU    cell_dn_list=${cell_dn_list}
    sleep  ${time}
    ${tti_path}    Stop Capture L2TTI Trace for Cloud DU
    ${decoded_csv_files}    Decode TTI Traces from PCAP or BIN for Cloud DU
    ...    input_filepath=${OUTPUT_DIR}/${TEST NAME}/l2stream/tcpdump/tcpdump.pcap
    ...    output_path=${OUTPUT_DIR}/${TEST NAME}    output_name=${output_name}
    ...    format=excelCsv    excel_csv_options=-w
    [Return]    ${decoded_csv_files}

Adjust the HBTE attenuation values
    [Arguments]      ${value_list}    ${port_list}
    att.setup_attenuator    ip_addr=${tl.attenuator.ip_addr}    port=${tl.attenuator.port}    model=${tl.attenuator.model}    vendor=HBTE
    ...    attenuation_port_numbers=${tl.gnbs[0].dus[0].rannics[0].rus[0].attenuation_ports[0].port_no}    max_attenuation=${127}
    ${port_num}    Get Length   ${port_list}
    @{port_list1}    Create List
    FOR    ${port}    IN    @{port_list}
        ${tmp}    Evaluate    ${port}+1
        Append to list  ${port_list1}  ${tmp}
    END
    FOR    ${i}    IN RANGE    ${port_num}
        att.set_attenuation     port=${tl.gnbs[0].dus[0].rannics[0].rus[0].attenuation_ports[${port_list[${i}]}].port_no}
        ...    value=${value_list}[${i}]
        ${value_port}    att.read_attenuation    port=${port_list1}[${i}]
        should be equal    ${value_port}    ${value_list}[${i}]
    END
    sleep  10s

########### about UE #################
Single UE Attach
    [Arguments]  ${ue_index}=${1}    ${ue_type}=samsung_ue
    log to console       Prepare UE
    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=${ue_type}
    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${ue_type}     log_type=None
    power_ue.Verify attach    ue_type=${ue_type}    ue_index=${ue_index}

Single UE detach
    [Arguments]  ${ue_index}=${1}    ${ue_type}=samsung_ue
    Power_ue.UE Detach    ue_index=${ue_index}    ue_type=${ue_type}

Get all UE pointer variable
    [Documentation]    Pixel range of X80 mobile phones
    ...                MTK：（1110~1280）：1200
    Set Suite Variable    ${home}    3
    Set Suite Variable    ${Home_button}    3
    Set Suite Variable    ${swipe}    500 2050 500 800
    Set Suite Variable    ${iperf_button}    720 312
    Set Suite Variable    ${brand}    mtk

MTK UE Click on airplane mode
    [Documentation]   click AIRPLANE
    ...    :param  ue_mode: Attach  or  Dettach
    [Arguments]   ${ue_mode}    ${ue_index}
    Get all UE pointer variable
    Connect to control pc via cygwin    ue_index=${ue_index}
    Run Keyword If    '${ue_mode}'=='Dettach'    Dettach UE By Adb Command    ue_index=${ue_index}
    Run Keyword If    '${ue_mode}'=='Attach'    Run Keywords    Dettach UE By Adb Command    ue_index=${ue_index}    AND
    ...    Attach UE By Adb Command    ue_index=${ue_index}
    [Teardown]    Run Keyword And Ignore Error    csn.disconnect      connection=cygwin

Dettach UE By Adb Command
    [Arguments]    ${ue_index}=${0}
    ${serial_number}    Set Variable    ${tl.ues[${ue_index}].serial_number}
    Run Keyword and Ignore Error   csn.send_command    command=adb -s ${serial_number} root    connection=cygwin
    sleep   4s
    Run Keyword and Ignore Error   csn.send_command    command=adb -s ${serial_number} shell settings put global airplane_mode_on 1
    ...    connection=cygwin
    sleep   4s
    Run Keyword and Ignore Error   csn.send_command
    ...    command=adb -s ${serial_number} shell am broadcast -a android.intent.action.AIRPLANE_MODE --ez state true    connection=cygwin
    sleep   4s

Attach UE By Adb Command
    [Arguments]    ${ue_index}=${0}
    ${serial_number}    Set Variable    ${tl.ues[${ue_index}].serial_number}
    Run Keyword and Ignore Error   csn.send_command    command=adb -s ${serial_number} root    connection=cygwin
    sleep   4s
    Run Keyword and Ignore Error   csn.send_command    command=adb -s ${serial_number} shell settings put global airplane_mode_on 0
    ...    connection=cygwin
    sleep   4s
    Run Keyword and Ignore Error   csn.send_command
    ...    command=adb -s ${serial_number} shell am broadcast -a android.intent.action.AIRPLANE_MODE --ez state false    connection=cygwin
    sleep   4s

Case15 Step
    [Arguments]    ${du_para}    ${cu_para}    ${bip_log}    ${filter_list}    ${check_cell_list}    ${check_field_list}
    ...    ${pdml_name_list}    ${expect_value_list}    ${normal_field_list}    ${abnormal_field_list}
    VDU Online Change Parameters Activate    updated_paras_list=${du_para}
    CU Online Change Parameters Activate    updated_paras_list=${cu_para}
    Check vDU And CU On Air
    ${log_path}    Capture Bip Log    bip_log_name=${bip_log}
    Check Multi Times By Diff Filter    log_path=${log_path}    filter_list=${filter_list}    check_cell_list=${check_cell_list}
    ...    check_field_list=${check_field_list}    pdml_name_list=${pdml_name_list}    expect_value_list=${expect_value_list}
    ...    normal_field_list=${normal_field_list}    abnormal_field_list=${abnormal_field_list}

Case10 Step
    [Arguments]    ${du_para}    ${cu_para}    ${enb_para}    ${PA_value_list}    ${counter_id_dict}    ${pcap_filename}
    Modify Parameter And Adjust PA    du_para=${du_para}    cu_para=${cu_para}    enb_para=${enb_para}    PA_value_list=${PA_value_list}
    ${befor_counter_value}    Cu Get PM Counters    counter_id_dict=${counter_id_dict}
    ${txt_path}    UE attach Mutile Time And Capture Tcpdump    ue_index=${0}    ue_type=samsung_ue     attach_time=${2}
    ...    pcap_filename=${pcap_filename}    filter=x2ap
    Case10 Check Point    txt_path=${txt_path}    check_field=SgNBReleaseRequired    counter_id_dict=${counter_id_dict}
    ...    befor_counter_value=${befor_counter_value}

Case10 Check Point
    [Arguments]    ${txt_path}    ${check_field}    ${counter_id_dict}    ${befor_counter_value}
    ${tcpdump_result}    Check_Tcpdump_Contain_field    field_value=${check_field}    file_path=${txt_path}
    Log To Console    Start to Wait Counter...
    sleep   6min
    ${after_counter_value}    Cu Get PM Counters    counter_id_dict=${counter_id_dict}
    ${actual_counter_dict}    Compara_Counter_Dict    befor_counter_dict=${befor_counter_value}    after_counter_dict=${after_counter_value}
    ${result_dict}    Check_counter_value_should_greater_than_zero    counter_value_dict=${actual_counter_dict}
    ${counter_value_tmp}    Get From Dictionary    ${result_dict}    M55112C00007
    Run Keyword And Continue On Failure    List Should Contain Value    ${counter_value_tmp}    ${True}
    Run Keyword And Continue On Failure    Should Be Equal As Strings    ${tcpdump_result}    True

Case4_B_Step
    [Arguments]    ${du_para}    ${cu_para}    ${bip_log}    ${except_bler}    ${filter_list}    ${check_cell_list}    ${check_field_list}
    ...    ${pdml_name_list}    ${expect_value_list}    ${normal_field_list}    ${abnormal_field_list}    ${exp_ul_tp}=170    ${exp_dl_tp}=1100
    ...    ${tti_name}=tcpdump_ttitrace    ${sys_log}=L2RT_SYSLOG    ${PA_value_list}=${case8_PA_value_list}
    Modify Parameter And Adjust PA    du_para=${du_para}    cu_para=${cu_para}    PA_value_list=${PA_value_list}
    MTK UE Click on airplane mode    ue_mode=Attach    ue_index=${1}
    UE Start Traffic    ue_index=${1}    ue_type=samsung    ul_throughput=200M    dl_throughput=1500M
    ${tti_path}    ${bip_log_path}    ${asyslog_path}    Capture Bip TTI Aasys Log    bip_log_name=${bip_log}    sys_log=${sys_log}
    ...    tti_name=${tti_name}    syslog_time=1min
    UE Stop Traffic    ue_index=${1}    ue_type=samsung
    Case4_B_Check_Point    asyslog_path=${asyslog_path}    tti_path=${tti_path}    bip_log_path=${bip_log_path}    except_bler=${except_bler}
    ...    exp_ul_tp=${exp_ul_tp}    exp_dl_tp=${exp_dl_tp}    filter_list=${filter_list}    check_cell_list=${check_cell_list}
    ...    check_field_list=${check_field_list}    pdml_name_list=${pdml_name_list}    expect_value_list=${expect_value_list}
    ...    normal_field_list=${normal_field_list}    abnormal_field_list=${abnormal_field_list}    tti_name=${tti_name}
    [Teardown]    MTK UE Click on airplane mode    ue_mode=Dettach    ue_index=${1}

Case4_B_Check_Point
    [Arguments]    ${asyslog_path}    ${tti_path}    ${bip_log_path}    ${except_bler}   ${exp_ul_tp}    ${exp_dl_tp}    ${abnormal_field_list}
    ...    ${filter_list}    ${check_cell_list}    ${check_field_list}    ${pdml_name_list}    ${expect_value_list}    ${normal_field_list}
    ...    ${tti_name}
    ${ul_bler}    ${dl_bler}    Run Keyword And Continue On Failure    Check Bler From Ttilog    tti_path=${tti_path}
    ...    except_dl_bler=${except_bler}    except_ul_bler=${except_bler}    tti_name=${tti_name}
    ${ul_avg_tp}    ${dl_avg_tp}    Run Keyword And Continue On Failure    Check TP From Aasyslog    ul_list=${dl_cell_list}
    ...    dl_list=${dl_cell_list}    exp_ul_tp=${exp_ul_tp}    exp_dl_tp=${exp_dl_tp}    log_path=${asyslog_path}
    Run Keyword And Continue On Failure    Check Multi Times By Diff Filter    log_path=${bip_log_path}    filter_list=${filter_list}
    ...    check_cell_list=${check_cell_list}    check_field_list=${check_field_list}   pdml_name_list=${pdml_name_list}
    ...    expect_value_list=${expect_value_list}    normal_field_list=${normal_field_list}    abnormal_field_list=${abnormal_field_list}
    ...    get_all_value=${True}

Capture Bip TTI Aasys Log
    [Arguments]    ${bip_log_name}    ${sys_log}    ${tti_name}    ${syslog_time}=30s    ${PA_value_list}=None
    Run Keyword If    ${PA_value_list} != None    Adjust the HBTE attenuation values    value_list=${PA_value_list}    port_list=${all_PA_port_list}
    sleep  2s
    ${tti_path}    Capture TTi Log    cell_dn_list=${cell_list}    time=2s    output_name=${tti_name}
    ${bip_log_path}    Capture Bip Log    bip_log_name=${bip_log_name}
    ${asyslog_path}    Start Capture SYSLOG And Download    file_name=${sys_log}    syslog_time=${syslog_time}
    [Return]    ${tti_path}    ${bip_log_path}    ${asyslog_path}


Capture Log And Check TP
    [Arguments]    ${bip_log_name}    ${sys_log}    ${tti_name}    ${exp_ul_tp}    ${exp_dl_tp}    ${syslog_time}=30s    ${PA_value_list}=None
    ${tti_path}    ${bip_log_path}    ${asyslog_path}    Capture Bip TTI Aasys Log    bip_log_name=${bip_log_name}
    ...    sys_log=${sys_log}    tti_name=${tti_name}    syslog_time=${syslog_time}    PA_value_list=${PA_value_list}
    ${ul_avg_tp1}    ${dl_avg_tp1}    Run Keyword And Continue On Failure    Check TP From Aasyslog    ul_list=${dl_cell_list}
    ...    dl_list=${dl_cell_list}    exp_ul_tp=${exp_ul_tp}    exp_dl_tp=${exp_dl_tp}    log_path=${asyslog_path}
    [Return]    ${tti_path}    ${bip_log_path}    ${asyslog_path}


