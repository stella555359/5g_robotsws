# #*** Settings ***
# #Documentation
# #...    author: Zhang Yayun
# #...    contact: yayun.zhang@nokia-sbell.com
# #...    squal group: SG03
# #...    feature: CB008246-D
# #
# #Force Tags  CA_5G_RRM
# #...    PY36
# #Suite Setup    Run Keywords
# #...                            robot_common_operations.Common Suite Setup    AND
# #...                            Common Suite Setup for COAM    AND
# #...                            Setup for Env cell on-air for 2 gnb    is_commission_for_second_gnb=False    AND
# #...                            Common UE parameter setup
# #
# #Suite Teardown     Common Suite Teardown for COAM    gnb_list=${gnb_list}
# #
# #
# #Resource     Resources/CB008246_common_keywords.robot
# #
# #
# #*** Variables ***
# #${log_name_G_008_1}    log_name_G_008_1.pcap
# #${expected_tput_dl}    300
# #${Send_Tput_DL}        600M
# #${expected_tput_ul}    100
# #${Send_Tput_UL}        200M
# #${Send_Tput_IMS_DL}    10M
# #${test_expected_tput_dl}    150
# #
# #*** Test Cases ***
# #[1]CB008246-G_008_Scheduling_of_5G_UE_with_multiple_non-GBR_High_Reliability_DRBs_online_modify_dllaBlerTargetHR_IWK_Release_lowest_BLER_HRDRB
# #    [Documentation]    CB008246-D
# #    [Tags]    CB008246-D    CRT_TRUNK
# #    [Timeout]    1 hour
# #    [Setup]
# #    robot_common_operations.Common Case Setup
# #    Modify Parameters for Cases    gnb_index=${0}    Add_Mo_Online=${parameters_to_update_8246_G_008}
# #    Online modify parmeters     gnb_index=${0}    parameters_to_update=${PARAM_8246_gnb1_G_008}
# #    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
# #    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
# #    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
# #    Comment    UE3 attach on gnb1 cell1
# #    Start capture gNB log on master    filename=${log_name_G_008_1}
# #    Power_ue.Prepare UE    ue_type=${ue_type1}    ue_index=${0}
# #    Attach and check power UE    ue_type=${ue_type1}    ue_index=${0}    gnb_index=${0}
# #    Stop and download Logs on gNB on master    filename=${log_name_G_008_1}
# #    Check wireshark log for 8246_G008_1
# #    Start only DL traffic and check tput    ue_index=${0}    cellid=2    ue_type=${ue_type1}    gnb_index=${0}
# #    ...                                tput_dl_cell=${test_expected_tput_dl}    dl_throughput=${Send_Tput_DL}    duration=3600
# #    Start only DL IMS traffic and check tput    ue_index=${0}    traffic=${Send_Tput_IMS_DL}    logname=${log_name_G_008_1}    time=3600
# #    sleep    30s
# #    Capture Ttitrace With Admin Mode and Convert format    nr_phy_cell_ids=53
# #    Analysis tti for G008_1    names=l2stream3_ttitrace
# #    Comment    Online Modify parmeters dllaMcsMax64qamRANK1HR = 23
# #    Online modify parmeters     gnb_index=${0}    parameters_to_update=${PARAM_8246_gnb1_G_008_2}
# #    sleep    30s
# #    Capture Ttitrace With Admin Mode and Convert format    names=l2stream3_ttitrace_2    nr_phy_cell_ids=53
# #    Analysis tti for G008_2    names=l2stream3_ttitrace_2
# #    Comment     gnb1 cell2 PA to 57db to trigger HR to BR
# #    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${55}
# #    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${57}
# #    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${55}
# #    sleep    15s
# #    Comment    Increase attenuation slowly to trigger UE below MCS2,L2PS shall switch from HR to BR
# #    Comment     gnb1 cell2 PA to 60db to trigger HR to BR
# #    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${55}
# #    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${60}
# #    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${55}
# #    sleep    30s
# #    Capture Ttitrace With Admin Mode and Convert format    names=l2stream3_ttitrace_3    nr_phy_cell_ids=53
# #    Analysis tti for G008_3    names=l2stream3_ttitrace_3
# #    Comment     Continue to decrease attenuation slowly to trigger UE above MCS10,L2PS shall switch from BR to HR
# #    Comment     gnb1 cell2 PA to 55db to trigger BR to HR
# #    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
# #    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
# #    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
# #    sleep    30s
# #    Capture Ttitrace With Admin Mode and Convert format    names=l2stream3_ttitrace_4    nr_phy_cell_ids=53
# #    Analysis tti for G008_4    names=l2stream3_ttitrace_4
# #    [Teardown]    Run Keywords
# #    ...    robot_common_operations.Common Case Teardown    AND
# #    ...    Stop DL or UL traffic    ue_index=${0}    ue_type=${ue_type1}    direction=DL    AND
# #    ...    Stop DL or UL IMS traffic    ue_index=${0}    ue_type=${ue_type1}    direction=DL
# #    ...    iperf_port=${tl.ues[2].iperf_details.ssh_connection_details.port}    AND
# #    ...    UE.UE Detach    ue_type=${ue_type1}    ue_index=${0}    AND
# #    ...    Online modify parmeters     parameters_to_update=${PARAM_8246_recover_gnb1_G_008}    AND
# #    ...    Modify Parameters for Cases    gnb_index=${0}    Delete_Mo_Online=${parameters_to_delete_8246_G_008}
# #    ...    Delete_Para_Online=${PARAM_8246_recover_delete_gnb1_G_008}    AND
# #    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_G_008_1}    AND
# #    ...    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot    AND
# #    ...    Adjust HBTE gNB_eNB_RU Attenuation    AND
# #    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# #
# #*** Keywords ***
# ##Online add parmeters
# ##    [Arguments]    ${parameters_to_update}    ${gnb_index}=${0}
# ##    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
# ##    COAM add several parameters via rest api    parameters_to_add_via_api=${parameters_to_update}
# ##    sleep    5
# ##    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections
# #Check wireshark log for 8246_G008_1
# #    Check DL_UE_No_MCS_table_Capbility    logname=${log_name_G_008_1}
# #    ${UE_RNTI_ID}=    Get RNTI-ID message    logname=${log_name_G_008_1}
# #    Set Suite Variable    ${SA_UE_RNTI_ID}    ${UE_RNTI_ID}
# #
# #Check DL_UE_No_MCS_table_Capbility
# #    [Arguments]    ${logname}
# #    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
# #    ${filter_expression}=     Catenate    f1ap.procedureCode == 12 and nr-rrc.downlinkBWP_ToAddModList == 1 and nr-rrc.mcs_Table == 1
# #    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
# #    ${nr_rrc_mcs_Table}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.mcs_Table    pcap_parser=test6
# #    Should Not Contain    ${nr_rrc_mcs_Table}    1
# #
# #Get RNTI-ID message
# #    [Arguments]    ${logname}
# #    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
# #    ####InitialULRRCMessageTransfer, RRC Setup Request
# #    ${RRC_Setup_request}=     Catenate    (f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 11 and f1ap.C_RNTI)
# #    ${RRC_Setup_request_packets}=    cap.filter_packets_by_expression    filter_expression=${RRC_Setup_request}
# #    ${UE_RNTI_ID}=     cap.get_field_value_by_xpath    pdml_list=${RRC_Setup_request_packets}
# #    ...                                                xpath=.//f1ap.C_RNTI
# #    [Return]    ${UE_RNTI_ID}[0]
# #
# #Analysis tti for G008_1
# #    [Arguments]    ${names}
# #    log to console    analysis tti file from Case_Logs file...
# ##    ${col_data_new}    get_dlFdSchedData_rrmDlUsedMcs_value    csv_file=${epc_log_path}/${names}_dl.csv     filter_nam
# ...e=dlFdSchedData.rrmDlUsedMcs
# #    ${dlFdSchedData_rrmDlUsedMcs}    get_dlFdSchedData_rrmDlUsedMcs_value    csv_file=${epc_log_path}/${names}_dl.csv
# #    ...    filter_name1=rnti     filter_name2=dlFdSchedData.rrmDlUsedMcs    filter_name3=${SA_UE_RNTI_ID}
# #    FOR  ${i}    IN    @{dlFdSchedData_rrmDlUsedMcs}
# #        should be true      ${${i}}<=${${20.0}}
# #    END
# #    Should Contain    ${dlFdSchedData_rrmDlUsedMcs}    20.0
# #    ${hr_dlFdSchedData_targetBLER}    get_dlFdSchedData_targetBLER_value    csv_file=${epc_log_path}/${names}_dl.csv
# #    ...    filter_name1=rnti     filter_name2=dlFdSchedData.targetBLER    filter_name3=${SA_UE_RNTI_ID}
# #    FOR  ${i}    IN    @{hr_dlFdSchedData_targetBLER}
# #        should be equal      ${${i}}    ${${0.01}}
# #    END
# #    ${dlFdSchedData_mcsTable}    get_dlFdSchedData_mcsTable_value    csv_file=${epc_log_path}/${names}_dl.csv
# #    ...    filter_name1=rnti     filter_name2=dlFdSchedData.mcsTable    filter_name3=${SA_UE_RNTI_ID}
# #    FOR  ${i}    IN    @{dlFdSchedData_mcsTable}
# #        should be equal      ${i}    QAM64
# #    END
# #    ${dlFdSchedData_laMode}    get_dlFdSchedData_laMode_value    csv_file=${epc_log_path}/${names}_dl.csv
# #    ...    filter_name1=rnti     filter_name2=dlFdSchedData.laMode    filter_name3=${SA_UE_RNTI_ID}
# #    FOR  ${i}    IN    @{dlFdSchedData_laMode}
# #        should be equal      ${i}    HIGHRELIABILITY
# #    END
# #    ${dlFdSchedData_aggregationLevel}    get_dlFdSchedData_aggregationLevel_value    csv_file=${epc_log_path}/${names}_dl.csv
# #    ...    filter_name1=rnti     filter_name2=dlFdSchedData.aggregationLevel    filter_name3=${SA_UE_RNTI_ID}
# #    FOR  ${i}    IN    @{dlFdSchedData_aggregationLevel}
# #        should be equal      ${i}    4.0
# #    END
# #
# #Analysis tti for G008_2
# #    [Arguments]    ${names}
# #    log to console    analysis tti file from Case_Logs file...
# #    ${dlFdSchedData_rrmDlUsedMcs}    get_dlFdSchedData_rrmDlUsedMcs_value    csv_file=${epc_log_path}/${names}_dl.csv
# #    ...    filter_name1=rnti     filter_name2=dlFdSchedData.rrmDlUsedMcs    filter_name3=${SA_UE_RNTI_ID}
# #    FOR  ${i}    IN    @{dlFdSchedData_rrmDlUsedMcs}
# #        should be true      ${${i}}<=${${23.0}}
# #    END
# #    Should Contain    ${dlFdSchedData_rrmDlUsedMcs}    23.0
# #
# #Analysis tti for G008_3
# #    [Arguments]    ${names}
# #    log to console    analysis tti file from Case_Logs file...
# ##    ${col_data_targetBLER}    get_dlFdSchedData_targetBLER_value    csv_file=${epc_log_path}/${names}_dl.csv   filter_
# ...name=dlFdSchedData.targetBLER
# ##    FOR  ${i}    IN    @{col_data_targetBLER}
# ##        should be equal      ${${i}}    ${${0.1}}
# ##    END
# #    ${hr_dlFdSchedData_targetBLER}    get_dlFdSchedData_targetBLER_value    csv_file=${epc_log_path}/${names}_dl.csv
# #    ...    filter_name1=rnti     filter_name2=dlFdSchedData.targetBLER    filter_name3=${SA_UE_RNTI_ID}
# #    FOR  ${i}    IN    @{hr_dlFdSchedData_targetBLER}
# #        should be equal      ${${i}}    ${${0.1}}
# #    END
# ##    ${col_data_laMode}    get_dlFdSchedData_laMode_value    csv_file=${epc_log_path}/${names}_dl.csv     filter_name=dlFdSchedData.laMode
# #    ${dlFdSchedData_laMode}    get_dlFdSchedData_laMode_value    csv_file=${epc_log_path}/${names}_dl.csv
# #    ...    filter_name1=rnti     filter_name2=dlFdSchedData.laMode    filter_name3=${SA_UE_RNTI_ID}
# #    FOR  ${i}    IN    @{dlFdSchedData_laMode}
# #        should be equal      ${i}    BASICRELIABILITY
# #    END
# #
# #Analysis tti for G008_4
# #    [Arguments]    ${names}
# #    log to console    analysis tti file from Case_Logs file...
# ##    ${col_data_targetBLER}    get_dlFdSchedData_targetBLER_value    csv_file=${epc_log_path}/${names}_dl.csv    filter
# ..._name=dlFdSchedData.targetBLER
# ##    FOR  ${i}    IN    @{col_data_targetBLER}
# ##        should be equal      ${${i}}    ${${0.01}}
# ##    END
# #    ${hr_dlFdSchedData_targetBLER}    get_dlFdSchedData_targetBLER_value    csv_file=${epc_log_path}/${names}_dl.csv
# #    ...    filter_name1=rnti     filter_name2=dlFdSchedData.targetBLER    filter_name3=${SA_UE_RNTI_ID}
# #    FOR  ${i}    IN    @{hr_dlFdSchedData_targetBLER}
# #        should be equal      ${${i}}    ${${0.01}}
# #    END
# ##    ${col_data_laMode}    get_dlFdSchedData_laMode_value    csv_file=${epc_log_path}/${names}_dl.csv     filter_name=dlFdSchedData.laMode
# #    ${dlFdSchedData_laMode}    get_dlFdSchedData_laMode_value    csv_file=${epc_log_path}/${names}_dl.csv
# #    ...    filter_name1=rnti     filter_name2=dlFdSchedData.laMode    filter_name3=${SA_UE_RNTI_ID}
# #    FOR  ${i}    IN    @{dlFdSchedData_laMode}
# #        should be equal      ${i}    HIGHRELIABILITY
# #    END
# #
# #Start only DL IMS traffic and check tput
# #    [Documentation]
# #    ...                DL_port used UL prot for IMS DL traffic
# #    [Arguments]    ${logname}    ${ue_index}=${0}
# #    ...            ${DL_port}=${tl.ues[2].iperf_details.ssh_connection_details.port}    ${time}=600
# #    ...            ${interval}=1    ${traffic}=10.00M    ${buffer_size}=1024B
# #    ...            ${process_num}=${1}   ${cap_index}=${0}
# #    log to console    .....UE_${ue_index} udp dl IMS iperf start....
# #    ${UE_IP}    Get UE IP from wirehsark    logname=${logname}
# #    wait until keyword succeeds    1 min    10 sec    Connect to EPC APP    ue_index=${ue_index}
# #    sleep   2s
# #    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${DL_port}| awk '{print $2}' |xargs kill -9    connection=EPCAPP
# #    csn.send_command
# #    ...    command=iperf -c ${UE_IP} -u -t ${time} -i ${interval} -p ${DL_port} -P ${process_num} -f m -b ${traffic} -l ${buffer_size} -T 64&
# #    ...    connection=EPCAPP
# #    log to console    .....UE_${ue_index} udp dl iperf start....
# #
# #Get UE IP from wirehsark
# #    [Arguments]    ${logname}
# #    ...    ${message_filter}=ngap.procedureCode == 14 and nas_5gs.sm.pdu_addr_inf_ipv4
# #    ...    ${xpath}=.//nas_5gs.sm.pdu_addr_inf_ipv4
# #    Log    Get UE IP from wirehsark
# #    ${UE_IP}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
# #    [Return]    ${UE_IP}[0]
# #
# #Check wireshark log
# #    [Arguments]    ${logname}    ${message_filter}    ${xpath}    ${attribute_name}=show
# #    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    alias=test6
# #    ${filter_expression}=     Catenate    ${message_filter}
# #    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}    pcap_parser=test6
# #    ${filtered_result}=     cap.get_field_value_by_xpath    attribute_name=${attribute_name}    xpath=${xpath}    pcap_parser=test6
# #    [Return]    ${filtered_result}
# #
# #Check DL_UE_MCS_table_Capbility
# #    [Arguments]    ${logname}
# #    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
# #    ${filter_expression}=     Catenate    f1ap.procedureCode == 12 and nr-rrc.downlinkBWP_ToAddModList == 1 and nr-rrc.mcs_Table == 1
# #    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
# #    ${nr_rrc_mcs_Table}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.mcs_Table    pcap_parser=test6
# #    Should Be Equal    ${nr_rrc_mcs_Table[0]}    1
