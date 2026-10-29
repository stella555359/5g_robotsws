# #*** Settings ***
# #Force Tags    PY36
# #Documentation    author：Hongyu Jiang
# #...              contact: hongyu.jiang@nokia-sbell.com
# #...              squad group: mmw_SG_04
# #
# #Resource          ./Resources/common_keyword.robot
# #Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# #
# #*** Variables ***
# #${gNB_ip}                 ${tl.gnbs[0].dus[0].f1_m_ip_addr}
# #${gNB_username}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
# #${gNB_password}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
# #${LOG_PATH}               ${output_dir}
# #${TEST_PC_IP}             ${tl.test_pc.default_ssh_connection_details.addr}
# #${TEST_PC_USERNAME}       ${tl.test_pc.default_ssh_connection_details.username}
# #${TEST_PC_PASSWORD}       ${tl.test_pc.default_ssh_connection_details.password}
# #${CU_ip}                  ${tl.gnbs[0].cu.oam_http_connection_details.addr}
# #${luashark_path}          /opt/ute/luashark/luashark_script/generated_luashark
# #${oam_ip}                 ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
# #${oam_username}           ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
# #${oam_password}           ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
# #${log_dir}                /home/robot
# #${tl_name}                ${tl.gnbs[0].instance_id}
# #${eNB_ip}                 ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
# #${eNB_name}               ${tl.enbs[0].airscale.common_units[0].lmp_connection.username}
# #${eNB_password}           ${tl.enbs[0].airscale.common_units[0].lmp_connection.password}
# #${plan_name}              Modify_DSCP
# #
# #
# #
# #*** Test Cases ***
# #[1]5GC000577_001_Check_OAM_QoS_Layer3_setting_for_F1-U&X2-C&X2-U&S1-U_Interface
# #     [Documentation]    Check OAM QoS Layer3 setting for F1-U&X2-C&X2-U&S1-U Interfac
# #     [Tags]     CRT_21B   CRT_22R2
# #     [Setup]
# #     ${dscp_webui_value}    Get DSCP Value From CU GNB ENB
# #     UE Attach And Get Wireshark Log    filename_list=${filename_list1}    port_list=${listen_port_list}  if_ul=${True}
# #     ...    connection1=oam_1    connection2=eNB_1
# #     ${txt_path_list}    Batch Convert pcap to text     pcap_file_list=${filename_list1}
# #     ${dscp_value_list}    Get DSCP Value From text   txt_path_list=${txt_path_list}    src_dst_iplist=${src_dst_iplist}
# #     run keyword and continue on failure     Check Dscp Value    get_dscp_value=${dscp_value_list}    except_dscp_value=${dscp_webui_value}
# #     run keyword and ignore error    Remove Files From Ute    filename_list=${filename_list1}
# #     Modify DSCP Value On CU GNB ENB   time=5min    GNB_MODIFY_PARAMS=${Modify_DU_DSCP_value}
# #     ${dscp_webui_value}    Get DSCP Value From CU GNB ENB
# #     Check Modify Value Equal To Webui    dscp_webui_value=${dscp_webui_value}   gnb_value=${Modify_DU_DSCP_value}
# #     ...    cu_value=${Modify_CU_DSCP_value_web}    enb_value=${Modify_eNB_DSCP_value}
# #     UE Attach And Get Wireshark Log    filename_list=${filename_list2}    port_list=${listen_port_list}   if_ul=${True}
# #     ...    connection1=oam_2    connection2=eNB_2
# #     ${txt_path_list2}    Batch Convert pcap to text     pcap_file_list=${filename_list2}
# #     ${dscp_value_list2}    Get DSCP Value From text   txt_path_list=${txt_path_list2}    src_dst_iplist=${src_dst_iplist}
# #     Check Dscp Value    get_dscp_value=${dscp_value_list2}    except_dscp_value=${dscp_webui_value}
# #     [Teardown]   Case Teardown
# #
# #[1]5GC000577_003_Check_5G_gNB_splits_Downlink_data_transfer_from_S1-U_to_F1-U_over_IPv4
# #    [Documentation]    Check 5G gNB splits Downlink data transfer from S1-U to F1-U overIPv4
# #    [Tags]    5GC002236_577    CRT_20B
# #    [Setup]
# #    Modify parameters online and Active Plan On CU    flag=dlDataSplitMode    dlDataSplitMode_value=dlOverF1U
# #    Reset gNB
# #    UE Attach And Get AAsys Log   filename_list=${filename_list1}    port_list=${listen_port_list}   if_ul=${False}
# #    ...    connection1=oam_upe    connection2=eNB
# #    ${txt_path_list}    Batch Convert pcap to text     pcap_file_list=${filename_list1}
# #    Check F1U And X2U Ip In Text    txt_path_list=${txt_path_list}   src_dst_iplist=${src_dst_iplist1}
# #    Download Asslog And Check DLRate    min_value=9    max_value=10
# #    [Teardown]    Case Teardown
# #
# #
# #
# #
# #*** Keywords ***
# #Setup Commission SCF
# #     Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
# #     COAM Commission with scf file    scf_file_path=${718_L_default_scf}
# #     Sleep   15min
# #
# #Get DSCP Value From text
# #    [Arguments]  ${txt_path_list}    ${src_dst_iplist}
# #    ${txt_list_len}    get length  ${txt_path_list}
# #    ${dscp_value_list}    create list
# #    ${value_list1}     create list
# #    ${value_list2}     create list
# #    ${tmp_iplist1}    set variable    @{src_dst_iplist}[0]
# #    ${dscp_value1}    Get_F1_DscpValue    file_path=@{txt_path_list}[0]     src_ip=@{tmp_iplist1}[0]    dst_ip=@{tmp_iplist1}[1]
# #    Append to list    ${value_list1}   ${dscp_value1}
# #    FOR  ${i}    IN RANGE    1    ${txt_list_len}
# #         ${tmp_iplist}    set variable    @{src_dst_iplist}[${i}]
# #         ${dscp_value1}    Get_DscpValue_By_Ip    file_path=@{txt_path_list}[${i}]     src_ip=@{tmp_iplist}[0]
# #         ...    dst_ip=@{tmp_iplist}[1]
# #         Append to list    ${value_list1}    ${dscp_value1}
# #    END
# #    FOR  ${i}    IN RANGE    ${txt_list_len}
# #         ${tmp_iplist}    set variable    @{src_dst_iplist}[${i}]
# #         ${dscp_value2}    Get_DscpValue_By_Ip    file_path=@{txt_path_list}[${i}]     src_ip=@{tmp_iplist}[1]
# #         ...    dst_ip=@{tmp_iplist}[0]
# #         Append to list    ${value_list2}    ${dscp_value2}
# #    END
# #    Append to list    ${dscp_value_list}    ${value_list1}
# #    Append to list    ${dscp_value_list}    ${value_list2}
# #    [Return]    ${dscp_value_list}
# #
# #Check Ip Value From text
# #    [Arguments]  ${txt_list}   ${src_dst_ip_list}
# #    ${txt_path_list}    create list   @{txt_list}[0]    @{txt_list}[1]
# #    ${src_dst_ip_list_len}    get length  ${src_dst_ip_list}
# #    FOR    ${i}    IN RANGE    ${src_dst_ip_list_len}
# #         ${tmp_list}    set variable   @{src_dst_ip_list_len}[${i}]
# #         ${return_value}    Get_IpAddress_In_Text    file_path=@{txt_path_list}[${i}]  src_ip=@{tmp_list}[0]    dst_ip=@{tmp_list}[1]
# #         should be equal as strings  ${return_value}    ${True}
# #    END
# #
# #Check Dscp Value
# #    [Arguments]    ${get_dscp_value}    ${except_dscp_value}
# #    ${get_dscp_value1}    set variable  @{get_dscp_value}[0]
# #    ${except_dscp_value1}    set variable  @{except_dscp_value}[0]
# #    ${get_dscp_value2}    set variable  @{get_dscp_value}[1]
# #    ${except_dscp_value2}    set variable  @{except_dscp_value}[1]
# #    ${get_dscp_value_len}    get length   ${get_dscp_value1}
# #    FOR  ${i}    IN RANGE    ${get_dscp_value_len}
# #         should be equal as strings    @{get_dscp_value1}[${i}]     @{except_dscp_value1}[${i}]
# #    END
# #    should be equal as strings    @{get_dscp_value2}[0]    @{except_dscp_value2}[0]
# #    should be equal as strings    @{get_dscp_value2}[2]    @{except_dscp_value2}[2]
# #
# #Get DSCP Value From CU GNB ENB
# #    [Arguments]    ${CU_value}=${CU_DSCP_value_web}    ${DU_value}=${DU_DSCP_value_web}
# #    ${cu_dscp}    Get DSCP On CU    CU_parameter_web=${CU_value}
# #    ${gnb_dscp}    Get DSCP On BaseStation    bts_addr=${gNB_ip}    bts_parameter_web=${DU_value}
# #    ${enb_dscp}    Get DSCP Value On eNB    parameter1=qciTab7    parameter2=cPlaneDscp   abbr=dscp
# #    ${tmp_list1}    create list    @{gnb_dscp}[0]   @{enb_dscp}[0]   @{enb_dscp}[1]    @{enb_dscp}[1]
# #    ${tmp_list2}    create list    @{cu_dscp}[0]    @{cu_dscp}[0]    @{cu_dscp}[1]    None
# #    ${dscp_webui_value}    create list    ${tmp_list1}    ${tmp_list2}
# #    log to console  ${dscp_webui_value}
# #    [Return]    ${dscp_webui_value}
# #
# #Modify DSCP Value On CU GNB ENB
# #    [Arguments]   ${time}    ${GNB_MODIFY_PARAMS}    ${ENB_MODIFY_PARAMS}=${Modify_eNB_DSCP_value}
# #     ...    ${CU_MODIFY_PARAMS}=${Modify_CU_DSCP_value_web}
# #    Modify parameters online and Active Plan On CU    dscp_value=@{CU_MODIFY_PARAMS}[0]    cplane_value=@{CU_MODIFY_PARAMS}[1]    flag=dscp
# #    log to console   Modify CU Success
# #    Modify Common parameter via Coam    input_list=${GNB_MODIFY_PARAMS}
# #    log to console   Modify DU Success
# #    Modify DSCP Value On eNB     new_value=@{ENB_MODIFY_PARAMS}[0]    cPlaneDscp=@{ENB_MODIFY_PARAMS}[1]
# #    log to console   Modify ENB Success
# #    Sleep  ${time}
# #
# #UE Attach And Get Wireshark Log
# #    [Arguments]  ${filename_list}    ${port_list}   ${if_ul}    ${connection1}    ${connection2}
# #    ${connection_list}    Start to Capture wireshark Log    port_list=${port_list}   filename_list=${filename_list}
# #    ...    connection1=${connection1}    connection2=${connection2}
# #    attach multi power ue    ue_num=${1}
# #    start multi power ue traffic ul and dl  ue_num=${1}    ul_throughput=10M    dl_throughput=10M    if_ul=${if_ul}
# #    Stop Upue log and Download Log    filename_list=${filename_list}    connection1=@{connection_list}[0]    connection2=@{connection_list}[1]
# #    stop multi power ue traffic ul and dl    ue_num=${1}    if_ul=${if_ul}
# #    [Teardown]   detach multi power ue
# #
# #Check Modify Value Equal To Webui
# #    [Arguments]  ${dscp_webui_value}  ${gnb_value}   ${cu_value}   ${enb_value}
# #    ${tmp_list1}    set variable  @{dscp_webui_value}[0]
# #    ${tmp_list2}     set variable  @{dscp_webui_value}[1]
# #    ${gnb_dscp_value}     get from dictionary     @{gnb_value}[0]    value
# #    should be equal as strings   @{tmp_list1}[0]   ${gnb_dscp_value}
# #    should be equal as strings   @{tmp_list1}[1]   @{enb_value}[0]
# #    should be equal as strings   @{tmp_list1}[2]   @{enb_value}[1]
# #    should be equal as strings   @{tmp_list2}[0]   @{cu_value}[0]
# #    should be equal as strings   @{tmp_list2}[2]   @{cu_value}[1]
# #
# #
# #UE Attach And Get AAsys Log
# #    [Arguments]  ${filename_list}    ${port_list}   ${if_ul}    ${connection1}    ${connection2}
# #    ${connection_list}    Start to Capture wireshark Log    port_list=${port_list}   filename_list=${filename_list}
# #    ...    connection1=${connection1}    connection2=${connection2}
# #    attach multi power ue    ue_num=${1}
# #    start multi power ue traffic ul and dl  ue_num=${1}    ul_throughput=10M    dl_throughput=10M    if_ul=${if_ul}
# #    AAsys log captrue    gnb_index=0    du_index=0    filter=DL-RLC
# #    Sleep    5s
# #    Stop Upue log and Download Log    filename_list=${filename_list}    connection1=@{connection_list}[0]    connection2=@{connection_list}[1]
# #    stop multi power ue traffic ul and dl    ue_num=${1}    if_ul=${if_ul}
# #    detach multi power ue
# #
# #Case Teardown
# #    run keyword and ignore error    Remove Files From Ute    filename_list=${filename_list1}
# #    CI_interface.Common Case Teardown