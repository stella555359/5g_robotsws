# *** Settings ***
# Force Tags    PY36
# Suite Setup
# Suite Teardown    Recovery parameter
# Documentation
# ...   author: xiaofeng.1.zhu@nokia-sbell.com
# ...   contact: xiaofeng.1.zhu@nokia-sbell.com
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/container_log_capturing.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/viavi_common_keyword.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_cu.robot
# Resource          taf/rfrl/common_resources/robot/libraries_instances.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
#
# Variables         Resources/5GC001829_modify_para.py
# Library           Resources/5GC001829.py
# Library           Resources/common_keyword.py
# Resource          ../5GC001912_EB/Resources/5GC001912_EB_keywords.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/UEs/inseego.robot
# Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Library    taf.analyzer.pcap    WITH NAME   check_cap
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/pm_counter.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
#
# Library           taf.transport.ssh    WITH NAME    csn
# Library           taf.hw.rf_attenuator    WITH NAME    att
# Library           taf.ue  WITH NAME   ute_ue
# Library           taf.gnb.oam.coam.cu.interface.cu        WITH NAME      coam_cu
# *** Variables ***
# ${CURDIR_path1}            /home/ute/5GC000710_A/${testline_name}/0_200_CU_SCF.xml
# ${CURDIR_path2}            ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/0_400_DU_SCF.xml
# ${CURDIR_path3}            ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/0_400_DU2_SCF.xml
# ${CURDIR_path4}            /home/ute/5GC000710_A/${testline_name}/10_1100_CU_SCF.xml
# ${CURDIR_path5}            ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/10_1100_DU_SCF.xml
# ${CURDIR_path6}            ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/10_1100_DU2_SCF.xml
# ${CURDIR_path7}            /home/ute/5GC000710_A/${testline_name}/12_400_CU_SCF.xml
# ${CURDIR_path8}            ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/12_400_DU_SCF.xml
# ${CURDIR_path9}            ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/12_400_DU2_SCF.xml
# ${DU_OAM_IP_URL}            https://${tl.gnbs[0].dus[0].f1_m_ip_addr}
# ${DU_OAM_WEBUI_IP}         ${tl.gnbs[0].dus[0].f1_m_ip_addr}
# ${DU_OAM_WEBUI_USER}        ${tl.gnbs[0].cu.oam_http_connection_details.username}
# ${DU_OAM_WEBUI_PASSWORD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
# ${DU_OAM_IP_TL}                ${tl.gnbs[0].dus[1].f1_m_ip_addr}
# ${DU_OAM_SSH_USERNAME_TL}      ${tl.gnbs[0].dus[1].airscale.common_units[0].lmp_connection.username}
# ${DU_OAM_SSH_PASSWORD_TL}      ${tl.gnbs[0].dus[1].airscale.common_units[0].lmp_connection.password}
# ${ENB_IP}                      ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
# ${ENB_USERNAME}                ${tl.enbs[0].airscale.common_units[0].lmp_connection.username}
# ${ENB_PASSWORD}                ${tl.enbs[0].airscale.common_units[0].lmp_connection.password}
# ${ru_alias}   RU
# ${test_ute}                   ${tl.test_pc.default_ssh_connection_details.addr}
# ${ute_name}                   ${tl.test_pc.default_ssh_connection_details.username}
# ${test_password}              ${tl.test_pc.default_ssh_connection_details.password}
# ${DU_OAM_IP}                  ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
#
# ${TEST_PC_IP}                 ${tl.test_pc.default_ssh_connection_details.addr}
# ${TEST_PC_USERNAME}           ${tl.test_pc.default_ssh_connection_details.username}
# ${TEST_PC_PASSWORD}           ${tl.test_pc.default_ssh_connection_details.password}
# ${iperf_path}                ${tl.ues[0].iperf_details.iperf_path}
# ${ul_addr}                   ${tl.ues[0].iperf_details.network_interface_address}
# ${connection}                GNB_OAM
# ${max_attenuation_value}     ${127}
# ${vendor}                    HBTE
# ${luashark_path}             /opt/ute/luashark/luashark_script/generated_luashark
# ${TS_CASE_LOG_PATH}          ${output_dir}
# ${epc_log_path}              /tmp
# ${event_1}                   a3-Offset
# ${event_2}                   a5-Threshold1
# ${source}                    ${output_dir}/CPIF_log.pcap
# ${source2}                   ${output_dir}/enb_tcpdump.pcap
#
# ${target}                    ${output_dir}/attach.txt
# ${target1}                    ${output_dir}/Reconfiguration.txt
# ${target2}                   ${output_dir}/measuerment_report.txt
# ${target3}                   ${output_dir}/meas_F.txt
# ${target4}                   ${output_dir}/meas_T.txt
#
# ${target5}                   ${output_dir}/CELL_ID.txt
# ${target6}                   ${output_dir}/checkmeas.txt
# ${target7}                   ${output_dir}/bts_log.log
# ${target8}                   ${output_dir}/syslog_.log
# ${filter}                    x2ap.procedureCode == 27 && x2ap.X2AP_PDU == 1
#
# ${filter1}                   f1ap.F1AP_PDU == 0 && f1ap.procedureCode == 7 && nr-rrc.srb_Identity == 3
#
# ${filter2}                   nr-rrc.measId && f1ap.F1AP_PDU == 0 && f1ap.procedureCode == 13
# ${filter3}                   nr-rrc.measId
# ${filter4}                   x2ap.X2AP_PDU == 1 && x2ap.procedureCode == 30
# ${filter5}                   x2ap.X2AP_PDU == 0 && x2ap.procedureCode == 35
# ${filter6}                   x2ap.X2AP_PDU == 0 && x2ap.procedureCode == 30
# ${filter7}                   x2ap.X2AP_PDU == 0 && x2ap.procedureCode == 32
# ${filter8}                   x2ap.X2AP_PDU == 0 && x2ap.procedureCode == 5
# ${filter9}                   nr-rrc.newUE_Identity
# ${filter10}                  nr-rrc.measId &&f1ap.F1AP_PDU == 0 &&f1ap.procedureCode == 13&&nr-rrc.rsrq == 71
# ${filter11}                  nr-rrc.measId &&f1ap.F1AP_PDU == 0 &&f1ap.procedureCode == 13&&nr-rrc.rsrq == 56
# ${throughput}                100M
# ${cpif_log_name}            CPIF_log
# ${NSA}     {'MRBTS-${tl.gnbs[0].cu.instance_id}/NRBTS-${tl.gnbs[0].cu.global_bts_id}': {'actIntraFreqIntraGnbMobilityNSA': 'true'}}
# ${E500_SCRIPTS_BASE}    ${CURDIR}/E500_scripts
# ${TMA_APP_ALIAS}        e500
# ${Test_Case_Name}           5GC001829_BTSLOG
# ${ul_time}              1800
# ${ul_port}              ${tl.ues[0].iperf_details.ssh_connection_details.port}
# ${dl_port}              ${tl.ues[0].iperf_details.port}
# ${ul_throughput}        2M
# ${ul_length}            1024B
# ${NUM}                  1
# ${port1}                51000
# ${port2}                51001
# *** Test Cases ***
# [1]5GC001829_B_4_PSCell_change_A5_SSB_RSRP_RSRQ_Combined_enable_SRB3_cloud
#     [Documentation]    PSCell change A5 SSB RSRP RSRQ Combined enable SRB3 cloud
#     [Tags]    CRT_20B   CRT_21B    CRT_TRUNK    CRT_22R2
#     [Setup]
#     572 Case preparation
#     Set test variable    ${LOG_PATH}    ${TS_CASE_LOG_PATH}
#     CU Delta Commission update    parameters=${rsrp_combined_1}
#     Modify Common parameter via Coam    input_list=${PARAMS_TO_MODIFY_DomainNumber4}    bts_ip=${DU_OAM_IP_TL}
#     Modify Common parameter via Coam    input_list=${PARAMS_TO_MODIFY_DomainNumber5}    bts_ip=${DU_OAM_IP_TL}
#     COAM GNB Wait CU and DU cells are on air status    timeout=5min
#     log to console    Precondition for attach...
#     Precondition for attach with retry
#     Attach and trigger meas Report    report_type=A5
#     ${CELL_ID1}    Check log cell ID    target=${target}    filter=${filter}
#     ${CELL_ID2}    Check log cell ID    target=${target1}    filter=${filter1}
#     should not be equal as numbers       ${CELL_ID1}    ${CELL_ID2}
#     ${meas_ID}     Check measuerment report    target=${target2}    filter=${filter2}
#     Check meas ID measuerment report    Meas_ID=${meas_ID}    grep1=a5-Threshold1:    grep2=rsrp
#     Check A5 rsrp and rsrq
#     Check btslog meassage1
#     Check x2ap    CELL_ID=${CELL_ID1}
#     SRB3 check    CELL_ID=${CELL_ID2}
# #    Analysis capture log for Case213
#     log to console    start check counter...sleep 15min
#     Waiting time for new counter file generated period CU    reporting_interval=${15}
#     ${55120_counter_file_list}    Collect PM Counter logs from CU    counter_group=55120
#     &{counter_id_dict}    create dictionary    M55120C01002=${55120_counter_file_list}
#     Verify CU counter value match expectation    counter_id=M55120C01002    counter_id_dict=&{counter_id_dict}
#     [Teardown]
#
# [1]5GC001829_B_11_PSCell_change_A3_SSB_RSRP_and_RSRQ_enable_SRB3_CFRA_cloud
#     [Documentation]    PSCell change A3 SSB RSRP RSRQ Combined enable SRB3 cloud
#     [Tags]    CRT_20B    CRT_21B    CRT_TRUNK    CRT_22R2
#     [Setup]
#     572 Case preparation
#     Set test variable    ${LOG_PATH}    ${TS_CASE_LOG_PATH}
#     CU Delta Commission update    parameters=${a3OffsetSsbRsrp}
#     Modify Common parameter via Coam    input_list=${PARAMS_TO_MODIFY_DomainNumber2}    bts_ip=${DU_OAM_IP_TL}
#     Modify Common parameter via Coam    input_list=${PARAMS_TO_MODIFY_DomainNumber3}    bts_ip=${DU_OAM_IP_TL}
#     COAM GNB Wait CU and DU cells are on air status    timeout=5min
#     log to console    Precondition for attach...
#     Precondition for attach with retry
#     Attach and trigger meas Report    report_type=A3
#     ${CELL_ID1}    Check log cell ID    target=${target}    filter=${filter}
#     ${CELL_ID2}    Check log cell ID    target=${target1}    filter=${filter1}
#     should not be equal as numbers       ${CELL_ID1}    ${CELL_ID2}
#     ${meas_ID}     Check measuerment report    target=${target2}    filter=${filter2}
#     Check meas ID measuerment report    Meas_ID=${meas_ID}    grep1=a3-Offset:    grep2=rsrp
#     Check A3 rsrp rsrq
#     Check btslog meassage2
#     Check x2ap    CELL_ID=${CELL_ID1}
#     SRB3 check    CELL_ID=${CELL_ID2}
# #    Analysis capture log for Case213
#
#     log to console    start check counter...sleep 15min
#     Waiting time for new counter file generated period CU    reporting_interval=${15}
#     ${55120_counter_file_list}    Collect PM Counter logs from CU    counter_group=55120
#     &{counter_id_dict}    create dictionary    M55120C01002=${55120_counter_file_list}
#     Verify CU counter value match expectation    counter_id=M55120C01002    counter_id_dict=&{counter_id_dict}
#     [Teardown]
#
# *** Keywords ***
# Attach and trigger meas Report
#     [Arguments]    ${report_type}    ${cpif_log_name}=${cpif_log_name}    ${log_path}=${TS_CASE_LOG_PATH}
#      ...    ${is_need_to_download_file}=${true}    ${is_srb3}=${True}
#     run keyword if    ${is_srb3}    ENABLE SRB3 on gNB    ELSE    DISABLE SRB3 on gNB
#     sleep    10s
#     Start tcpdump log on CU    tcpdump_collector_name=${cpif_log_name}_f1    options=-i fronthaul    vm_name=cpif-0.local
#     Start tcpdump log on CU    tcpdump_collector_name=${cpif_log_name}_x2    options=-i x2    vm_name=cpif-0.local
#     Connect to gnb coam via ssl    bts_host=${DU_OAM_IP_TL}    username=${DU_OAM_WEBUI_USER}   password=${DU_OAM_WEBUI_PASSWORD}
#     log to console    start attach...
#     Cobham retry ue attach if failed
#     log to console    ue attach successful
#
# #    Iperf send UL traffic with real epc   throughput=${100}   traffic_time=${180}    ul_host_ip=10.57.178.18    port=${ul_port}
# #    Iperf send UL traffic VIAVI    throughput=${100}   traffic_time=${180}    ul_host_ip=10.57.178.18    port=${ul_port}
#     Iperf send DL traffic with real epc    throughput=${100}    traffic_time=${180}    port=${dl_port}
#     sleep    10s
#     log to console    start syslog...
#     ${list}    Create list     ${port1}    ${port2}
#     ute_syslog.Start Syslog    log_dir=${OUTPUT_DIR}    log_name=syslog_.log    host_ip=${TEST_PC_IP}    ssh_username=ute
#     ...    ssh_password=iW_K#8.ute%A10h0m0ra    ports=${list}    alias=${connection}
#
#     sleep    10s
#     run keyword if    '${report_type}'=='A3'    Trigger A3 measurement report for 572
#     run keyword if    '${report_type}'=='A5'      Trigger A5 Fail measurement report for 572
#     sleep    10s
#     run keyword if    '${report_type}'=='A5'      Trigger A5 measurement report for 572
#     sleep    20s
#     log to console    cell swtich successful
#     [Teardown]    Stop tcpdump log
#
# Stop tcpdump log
#     [Arguments]    ${cpif_log_name}=${cpif_log_name}    ${is_srb3}=${False}    ${ppb_value}=20    ${ns_value_scope}=0.5
#     log to console    End syslog
#     Stop syslog    alias=${connection}
#     Stop tcpdump on CPIF and rename downloaded file    cpif_log_name=${cpif_log_name}_f1
#     Stop tcpdump on CPIF and rename downloaded file    cpif_log_name=${cpif_log_name}_x2
#
# #    Iperf stop traffic from appserver and ue side    port=${ul_port}
# #    Iperf stop traffic from appserver and ue side    port=${dl_port}
#     Cobham UE detach
#     ${merged_log_path}    set variable    ${log_path}/${cpif_log_name}.pcap
#     run    mergecap -w ${merged_log_path} ${log_path}/Ori_${cpif_log_name}_x2.pcap ${log_path}/Ori_${cpif_log_name}_f1.pcap
#     run keyword if    ${is_srb3}    ENABLE SRB3 on gNB    ELSE    DISABLE SRB3 on gNB
#     ${CELL1}    ${CELL2}    check BTS DL throughput    CELL2=16387
# #    check BTS UL throughput    CELL1=${CELL1}    CELL2=${CELL2}
#     [Return]    ${merged_log_path}
#     [Teardown]    Run Keyword And Ignore Error    coam.teardown    connection=${connection}
#
# 572 Case preparation
# #    ${connection}    coam.connect_to    bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}     name=GNB_OAM
#     Connect to gnb coam via ssl    bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}     connection=GNB_OAM
#     ${connection}    set variable    GNB_OAM
#     ${version}    coam.get_sw_version    connection=${connection}
#     ${version_list}    split string    ${version}    _
#     run keyword if    '${version_list[2]}'=='0014'    load scf activation    path1=${CURDIR_path1}    path2=${CURDIR_path2}
#     run keyword if    '${version_list[2]}'=='0010'    load scf activation    path1=${CURDIR_path4}    path2=${CURDIR_path5}
#     run keyword if    '${version_list[2]}'=='0012'    load scf activation    path1=${CURDIR_path7}    path2=${CURDIR_path8}
#
#     COAM GNB Wait CU and DU cells are on air status    timeout=15min
#     Modify Common parameter via Coam    input_list=${PARAMS_TO_MODIFY_DomainNumber0}    bts_ip=${ENB_IP}
#     Modify Value On DU     gNB_ip=${DU_OAM_IP_TL}    structure_modify_list=${PARAMS_TO_MODIFY_DomainNumber1}
#     ...    class_name=TRBLCADM_A    keywords_list=${keywords_list1}
#     Modify Value On DU     gNB_ip=${DU_OAM_IP_TL}    structure_modify_list=${PARAMS_TO_MODIFY_DomainNumber7}
#     ...    class_name=TRBLCADM_A    keywords_list=${keywords_list1}
#     [Teardown]    Run Keyword And Ignore Error    coam.teardown    connection=${connection}
#
# load scf activation
#     [Arguments]   ${path1}    ${path2}
#     Setup Commission SCF     CURDIR_path=${path2}
#     CU Full Commission    path_of_commission_file=${path1}
#
# check BTS DL throughput
#     [Arguments]   ${flag1}=100    ${flag2}=100    ${CELL1}=16385    ${CELL2}=16386
#     log to console    Check DL throughput
#     csn.Connect to     hostname=${test_ute}   username=${ute_name}    password=${test_password}  alias=${connection}
#     FOR    ${NUM}    IN RANGE    ${1}    ${30}    1
#         csn.Send Command    command=cat ${target8}|grep DataPdu|grep ${CELL1}|cut -d ':' -f 10|cut -d '|' -f 1|head -${NUM}|tail -n 1|tr -cd "[0-9]
# "
#         ...    connection=${connection}
#         ${TP1}    csn.Read Output    connection=${connection}
#         ${TP1}    Evaluate    int(${TP1})
#         csn.Send Command    command=cat ${target8}|grep DataPdu|grep ${CELL2}|cut -d ':' -f 10|cut -d '|' -f 1|head -${NUM}|tail -n 1|tr -cd "[0-9]
# "
#         ...    connection=${connection}
#         ${TP2}    csn.Read Output    connection=${connection}
#         ${TP2}    Evaluate    int(${TP2})
#         log to console    ${CELL1}:${TP1}
#         log to console    ${CELL2}:${TP2}
#         run keyword if    ${TP2}==${0}     Set test variable    ${flag1}    ${NUM}
#         run keyword if    ${TP2}==${0}     should be true    ${TP1}>${2000}
#         run keyword if    ${TP2}>${2000}     Set test variable    ${flag2}    ${NUM}
#         should be true    ${flag2}>${flag1}
#     END
#     should not be equal as numbers    ${flag1}    100
#     should not be equal as numbers    ${flag2}    100
#     log to console    Check DL throughput successful
#     [Return]    ${CELL1}    ${CELL2}
#     [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}
#
# check BTS UL throughput
#     [Arguments]   ${CELL1}    ${CELL2}    ${flag3}=100    ${flag4}=100
#     log to console    Check UL throughput
#     csn.Connect to     hostname=${test_ute}   username=${ute_name}    password=${test_password}  alias=${connection}
#     FOR    ${NUM}    IN RANGE    ${1}    ${30}    1
#         csn.Send Command    command=cat ${target8}|grep UlCounterUp|grep ${CELL1}|awk '{print $17}'|head -${NUM}|tail -n 1|tr -cd "[0-9]"
#         ...    connection=${connection}
#         ${TP1}    csn.Read Output    connection=${connection}
#         ${TP1}    Evaluate    int(${TP1})
#
#         csn.Send Command    command=cat ${target8}|grep UlCounterUp|grep ${CELL2}|awk '{print $17}'|head -${NUM}|tail -n 1|tr -cd "[0-9]"
#         ...    connection=${connection}
#         ${TP2}    csn.Read Output    connection=${connection}
#         ${TP2}    Evaluate    int(${TP2})
#         log to console    ${CELL1}:${TP1}
#         log to console    ${CELL2}:${TP2}
#         run keyword if    ${TP2}==${0}    Set test variable    ${flag3}    ${NUM}
#         run keyword if    ${TP2}==${0}    should be true    ${TP1}>${0}
#         run keyword if    ${TP2}>${0}     Set test variable    ${flag4}    ${NUM}
#         should be true    ${flag4}>${flag3}
#     END
#     should not be equal as numbers    ${flag3}    100
#     should not be equal as numbers    ${flag4}    100
#     log to console    Check UL throughput successful
#     [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}
#
# Teardown gNB cOAM SSL Connection
#     [Arguments]    ${connection}=GNB_OAM
#     coam.teardown    connection=GNB_OAM
#
# Check btslog meassage1
#     log to console    Check btslog meassage...
#     csn.Connect to     hostname=${test_ute}   username=${ute_name}    password=${test_password}  alias=${connection}
#     csn.Send Command    command=cat ${target8}|grep 'No competition free access preamble can be used now'
#     ...    connection=${connection}
#     ${free}  csn.Read Output    connection=${connection}
#     should not be empty    ${free}
#     log to console    Check btslog meassage successful
#     [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}
#
# Check btslog meassage2
#     log to console    Check btslog meassage...
#     csn.Connect to     hostname=${test_ute}   username=${ute_name}    password=${test_password}  alias=${connection}
#     csn.Send Command    command=cat ${target8}|grep 'No competition free access preamble can be used now'
#     ...    connection=${connection}
#     ${free}  csn.Read Output    connection=${connection}
#     should be empty    ${free}
#     log to console    Check btslog meassage successful
#     [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}
#
# Verify CU counter value match expectation
#     [Arguments]    ${counter_id}    ${counter_id_dict}    ${idx}=${0}    ${expect_counter_value}=${1}
#     @{counter_id_list}    get_dictionary_keys    ${counter_id_dict}
#     &{counter_value_dict}    create dictionary
#     FOR    ${counter_id}    IN    @{counter_id_list}
#         ${counter_value}    pmcounters_parse.get_counter_value    xml_file_name=${counter_id_dict['${counter_id}'][0]}    counter_id=${counter_id}
#         run keyword and continue on failure    should be equal as integers    ${counter_value[${idx}]}    ${expect_counter_value}
#         set_to_dictionary    ${counter_value_dict}    ${counter_id}=${counter_value}
#     END
#     [Return]    ${counter_value_dict}
#
# SRB3 check
#     [Arguments]     ${CELL_ID}
#     cap.read_cap    cap_file=${source}    display_filter=f1ap
#     ${srb3_ho_rrc_reconfig} =  Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 7 and nr-rrc.srb_Identity == 3
#     ...    and nr-rrc.physCellId == ${CELL_ID}
#     ${status}    ${value} =    run keyword and ignore error    cap.Check Expression    condition_expression=${srb3_ho_rrc_reconfig}
#     log to console    ${status}
#     should be equal    '${status}'    'PASS'
#     ${CRNTI_cell} =    cap.get_element_value    element_expression=nr-rrc.newUE_Identity
#     ...    condition_expression=f1ap.F1AP_PDU == 1 and f1ap.procedureCode == 7
#     log to console    ${CRNTI_cell}
#     [Return]    ${CRNTI_cell}
#
# Check x2ap
#     [Arguments]     ${CELL_ID}
#     ${CELL_ID}    Evaluate    ${CELL_ID}*1
#     cap.read_cap    cap_file=${source}    display_filter=x2ap
#     ${SgNBAdditionRequestACK_srb3} =  Catenate    x2ap.X2AP_PDU == 1 and x2ap.procedureCode == 27
#     ...    and nr-rrc.srb_Identity == 3    and     nr-rrc.physCellId == ${CELL_ID}
#     ${status}    ${value} =    run keyword and ignore error
#     ...    cap.Check Expression    condition_expression=${SgNBAdditionRequestACK_srb3}
#     log to console    ${status}
#     should be equal    '${status}'    'PASS'
#     ${CRNTI_cell} =    cap.get_element_value    element_expression=nr-rrc.newUE_Identity
#     ...    condition_expression=x2ap.X2AP_PDU == 1 and x2ap.procedureCode == 27
#     [Return]    ${CRNTI_cell}
#
# Check A3 rsrp rsrq
#     log to console    Check A3 rsrp and rsrq...
#     csn.Connect to     hostname=${test_ute}   username=${ute_name}    password=${test_password}  alias=${connection}
#     csn.Send Command    command=cat ${target2}|grep SS-RSRP|head -1|cut -d '(' -f 2|tr -cd "[0-9]"
#     ...    connection=${connection}
#     ${RSRP_1}  csn.Read Output    connection=${connection}
#     log to console    RSRP_1:${RSRP_1}
#     csn.Send Command    command=cat ${target2}|grep SS-RSRP|tail -n 2|head -1|cut -d '(' -f 2|tr -cd "[0-9]"
#     ...    connection=${connection}
#     ${RSRP_2}  csn.Read Output    connection=${connection}
#     log to console    RSRP_2:${RSRP_2}
#     ${RSRP}    Evaluate    ${RSRP_2}-${RSRP_1}
#     log to console    RSRP:${RSRP}
#     should be true    ${RSRP}>${4}
#
# Check A5 rsrp and rsrq
#     log to console    Check A5 rsrp and rsrq...
#     csn.Connect to     hostname=${test_ute}   username=${ute_name}    password=${test_password}  alias=${connection}
#     Convert pcap to text    source=${source}    target=${target3}    connection=${connection}    filter=${filter10}
#     csn.Send Command    command=cat ${target3}|grep SS-RSRQ|head -1|cut -d '(' -f 2|tr -cd "[0-9]"
#     ...    connection=${connection}
#     ${RSRQ_F}  csn.Read Output    connection=${connection}
#     ${RSRQ_F}    Evaluate    int(${RSRQ_F})
#     should be true    ${RSRQ_F}>${60}
#
#     csn.Send Command    command=cat ${target3}|grep SS-RSRP|head -1|cut -d '(' -f 2|tr -cd "[0-9]"
#     ...    connection=${connection}
#     ${RSRP_F}  csn.Read Output    connection=${connection}
#     ${RSRP_F}    Evaluate    int(${RSRP_F})
#     should be true    ${RSRP_F}<${60}
#     log to console    measurement Report check successful,cell can't switch...
#
#     Convert pcap to text    source=${source}    target=${target4}    connection=${connection}    filter=${filter11}
#     csn.Send Command    command=cat ${target4}|grep SS-RSRQ|head -1|cut -d '(' -f 2|tr -cd "[0-9]"
#     ...    connection=${connection}
#     ${RSRQ_T}  csn.Read Output    connection=${connection}
#     ${RSRQ_T}    Evaluate    int(${RSRQ_T})
#     should be true    ${RSRQ_T}<${60}
#
#     csn.Send Command    command=cat ${target4}|grep SS-RSRP|head -1|cut -d '(' -f 2|tr -cd "[0-9]"
#     ...    connection=${connection}
#     ${RSRP_T}  csn.Read Output    connection=${connection}
#     ${RSRP_T}    Evaluate    int(${RSRP_T})
#     should be true    ${RSRP_T}<${60}
#     log to console    measurement Report check successful,cell will switch...
#     [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}
#
# Setup Commission SCF
#     [Arguments]    ${CURDIR_path}     ${bts_host}=${tl.gnbs[0].dus[1].f1_m_ip_addr}
#     ...    ${username}=${tl.gnbs[0].cu.oam_http_connection_details.username}
#     ...    ${password}=${tl.gnbs[0].cu.oam_http_connection_details.password}
# #    coam.connect_to    bts_host=${bts_host}    bts_port=${443}    username=${username}    password=${password}
# #    ...   name=${connection}
#     Connect to gnb coam via ssl    bts_host=${bts_host}     username=${username}    password=${password}
#     ...    connection=${connection}
#     log to console    connect successful
#     COAM Commission with scf file    is_pdl_checking_needed=False    scf_file_path=${CURDIR_path}
#     log to console    active DU scf successful
#     Run Keyword And Ignore Error    coam.teardown
#     [Teardown]    Run Keyword And Ignore Error    coam.teardown    connection=${connection}
#
# Trigger A3 measurement report for 572
#     [Arguments]    ${a3_meas_id}=1    ${report_interval}=0    ${serving_cell_pci}=414    ${serving_cell_rsrp}=50
#     ...    ${serving_cell_rsrq}=53    ${serving_cell_sinr}=35    ${neigh_cell_pci}=415    ${neigh_cell_rsrp}=60    ${neigh_cell_rsrq}=53
#     ...    ${neigh_cell_sinr}=44    ${tm500_alias}=e500
#     log to console  Start to trigger A3 measurement report
#     ${cmd_a3_mr}    catenate
#     ...    forw mte NrRrcAptTriggerMeasReport ${a3_meas_id} 0 0 ${report_interval} 1
#     ...    {8 [${serving_cell_pci}] [[${serving_cell_rsrp}] [${serving_cell_rsrq}] [${serving_cell_sinr}]] [] [[1{4[[50] [53] []]}] []] [] []}
#     ...    [0(1{[${neigh_cell_pci}] [[${neigh_cell_rsrp}] [${neigh_cell_rsrq}] [${neigh_cell_sinr}]] [][ [1{4[[60] [53] []]}] [] ] })]
#     ${response}    tm500_remote.send_command    command=${cmd_a3_mr}    alias=${tm500_alias}
#     ${response}    tm500_remote.send_command    command=forw mte Activate -1    alias=${tm500_alias}
#     Wait until keyword succeeds    10s    200ms    match pattern in response    response=${response}
#     ...    e500_alias=${tm500_alias}    pattern=Random Access Complete
#
# Trigger A5 Fail measurement report for 572
#     [Arguments]    ${a5_meas_id}=1    ${report_interval}=0    ${serving_cell_pci}=414    ${serving_cell_rsrp}=56
#     ...    ${serving_cell_rsrq}=71    ${serving_cell_sinr}=35    ${neigh_cell_pci}=415    ${neigh_cell_rsrp}=66    ${neigh_cell_rsrq}=57
#     ...    ${neigh_cell_sinr}=44    ${tm500_alias}=e500
#     log to console  Start to trigger A5 measurement report
#     ${cmd_a3_mr}    catenate
#     ...    forw mte NrRrcAptTriggerMeasReport ${a5_meas_id} 0 0 ${report_interval} 1
#     ...    {0 [${serving_cell_pci}] [[${serving_cell_rsrp}] [${serving_cell_rsrq}] [${serving_cell_sinr}]] [] [[1{4[[56] [71] []]}] []] [] []}
#     ...    [0(1{[${neigh_cell_pci}] [[${neigh_cell_rsrp}] [${neigh_cell_rsrq}] [${neigh_cell_sinr}]] [][ [1{4[[66] [57] []]}] [] ] })]
#     ${response}    tm500_remote.send_command    command=${cmd_a3_mr}    alias=${tm500_alias}
#     ${response}    tm500_remote.send_command    command=forw mte Activate -1    alias=${tm500_alias}
# #    Wait until keyword succeeds    10s    200ms    match pattern in response    response=${response}
# #    ...    e500_alias=${tm500_alias}    pattern=Random Access Complete
#
# Trigger A5 measurement report for 572
#     [Arguments]    ${a5_meas_id}=1    ${report_interval}=0    ${serving_cell_pci}=414    ${serving_cell_rsrp}=56
#     ...    ${serving_cell_rsrq}=56    ${serving_cell_sinr}=35    ${neigh_cell_pci}=415    ${neigh_cell_rsrp}=66    ${neigh_cell_rsrq}=66
#     ...    ${neigh_cell_sinr}=44    ${tm500_alias}=e500
#     log to console  Start to trigger A5 measurement report
#     ${cmd_a3_mr}    catenate
#     ...    forw mte NrRrcAptTriggerMeasReport ${a5_meas_id} 0 0 ${report_interval} 1
#     ...    {0 [${serving_cell_pci}] [[${serving_cell_rsrp}] [${serving_cell_rsrq}] [${serving_cell_sinr}]] [] [[1{4[[56] [56] []]}] []] [] []}
#     ...    [0(1{[${neigh_cell_pci}] [[${neigh_cell_rsrp}] [${neigh_cell_rsrq}] [${neigh_cell_sinr}]] [][ [1{4[[66] [66] []]}] [] ] })]
#     ${response}    tm500_remote.send_command    command=${cmd_a3_mr}    alias=${tm500_alias}
#     ${response}    tm500_remote.send_command    command=forw mte Activate -1    alias=${tm500_alias}
#     Wait until keyword succeeds    10s    200ms    match pattern in response    response=${response}
#     ...    e500_alias=${tm500_alias}    pattern=Random Access Complete
#
# END case
#     Run Keyword And Ignore Error    Cobham UE detach
#     run keyword and ignore error    Stop tcpdump on CPIF and rename downloaded file    cpif_log_name=${cpif_log_name}
#     run keyword and ignore error    csn.Disconnect    connection=${connection}
#
# CU parameter update
#     [Arguments]    ${parameter2}    ${parameter3}
#     log to console    start modify cu parameter
#     CU Delta Commission update    parameters=${parameter2}
#     log to console    modify parameter...
#     sleep    10s
#     CU Delta Commission update    parameters=${parameter3}
#     [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}
#
# Modify Common parameter via Coam
#     [Arguments]  ${input_list}    ${bts_ip}    ${connection}=GNB_connection
#     log to console    Modify parameter
# #    coam.connect_to    bts_host=${bts_ip}   name=${connection}
#     Connect to gnb coam via ssl    bts_host=${bts_ip}    connection=${connection}
#     FOR    ${item}    IN    @{input_list}
#         ${dict_value}    Get Content From Input Dict    input_dict=${item}
#         coam.Perform Parameter Recommissioning    dist_name=@{dict_value}[0]   parameter=@{dict_value}[1]   value=@{dict_value}[2]
#         ...    operation=update    skip_parameter_relation_errors=${True}    should_activate=${True}    connection=${connection}
#     END
#     log to console  sleep 30s
#     sleep  30s
#     [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}
#
# Get Content From Input Dict
#     [Arguments]  ${input_dict}
#     ${dist_name}    get from dictionary     ${input_dict}    dist_name
#     ${parammeter}    get from dictionary    ${input_dict}    parameter
#     ${new_value}     get from dictionary    ${input_dict}    value
#     ${value_list}    create list    ${dist_name}    ${parammeter}    ${new_value}
#     [Return]  ${value_list}
#
# Check log cell ID
#     [Arguments]    ${source}=${source}    ${target}=${target}    ${filter}=${filter}
#     ${CELL_ID}    Convert pcap file to txt    source=${source}    target=${target}   filter=${filter}
#     log to console  Check log cell ID:${CELL_ID}
#     [Return]    ${CELL_ID}
#
# Convert pcap to text
#     [Arguments]    ${source}    ${target}    ${connection}    ${filter}
#     ssh.send_command
#     ...  command=nice tshark -X lua_script:${luashark_path} -V -r ${source} -T text > ${target} -Y '${filter}'   connection=${connection}
#     ssh.await execution end  connection=${connection}  timeout=30min
#     sleep    5s
#
# Convert pcap file to txt
#     [Arguments]    ${source}   ${target}   ${filter}    ${connection}=TEST_PC
#     csn.Connect to     hostname=${test_ute}   username=${ute_name}    password=${test_password}  alias=${connection}
#     sleep    1s
#     Convert pcap to text    source=${source}    target=${target}    connection=${connection}    filter=${filter}
#     csn.Send Command  command=cat ${target} |grep physCellId |head -2 |tail -n 1 |tr -cd "[0-9]"
#     ...    connection=${connection}
#     ${CELL_ID}  csn.Read Output    connection=${connection}
#     ${CELL_ID}  strip_string    ${CELL_ID}
#     log to console  physCellId=${CELL_ID}
#     [Return]    ${CELL_ID}
#     [Teardown]    run keyword and ignore error    csn.Disconnect	connection=${connection}
#
# Check measuerment report
#     [Arguments]    ${source}=${source}    ${target}=${target2}    ${filter}=${filter2}
#     csn.Connect to     hostname=${test_ute}   username=${ute_name}    password=${test_password}  alias=${connection}
#     sleep    1s
#     Convert pcap to text    source=${source}    target=${target}    connection=${connection}    filter=${filter}
#     csn.Send Command  command=cat ${target} |grep measId|tail -n 1|tr -cd "[0-9]"
#     ...    connection=${connection}
#     ${Meas_ID}  csn.Read Output    connection=${connection}
#     ${Meas_ID}  strip_string    ${Meas_ID}
#     log to console  Meas_ID=${Meas_ID}
#     [Return]    ${Meas_ID}
#     [Teardown]    run keyword and ignore error    csn.Disconnect	connection=${connection}
#
# Check meas ID measuerment report
#     [Arguments]    ${Meas_ID}    ${grep1}    ${grep2}
#     csn.Connect to     hostname=${test_ute}   username=${ute_name}    password=${test_password}  alias=${connection}
#     sleep    1s
#     csn.Send Command  command=cat ${target} |grep measId:|head -${Meas_ID}|tail -n 1|tr -cd "[0-9]"    connection=${connection}
#     ${Meas_ID_2}    csn.Read Output    connection=${connection}
#     ${Meas_ID_2}    strip_string    ${Meas_ID_2}
#     log to console  Meas_ID=${Meas_ID_2}
#     should be equal as numbers    ${Meas_ID}    ${Meas_ID_2}
#     csn.Send Command  command=cat ${target} |grep ${grep1}|grep ${grep2}    connection=${connection}
#     ${rsrp}    csn.Read Output    connection=${connection}
#     ${rsrp}  strip_string    ${rsrp}
#     should not be empty    ${rsrp}
#     [Teardown]    run keyword and ignore error    csn.Disconnect	connection=${connection}
#
# Check A3 RSRQ measuerment report
#     [Arguments]    ${Meas_ID}
#     csn.Connect to     hostname=${test_ute}   username=${ute_name}    password=${test_password}  alias=${connection}
#     sleep    1s
#     csn.Send Command  command=cat ${target} |grep measId:|head -${Meas_ID}|tail -n 1|tr -cd "[0-9]"    connection=${connection}
#     ${Meas_ID_2}  csn.Read Output    connection=${connection}
#     ${Meas_ID_2}  strip_string    ${Meas_ID_2}
#     log to console  Meas_ID=${Meas_ID_2}
#     should be equal as numbers    ${Meas_ID}    ${Meas_ID_2}
#     csn.Send Command  command=cat ${target} |grep a3-Offset:|grep rsrq    connection=${connection}
#     ${rsrp}  csn.Read Output    connection=${connection}
#     ${rsrp}  strip_string    ${rsrp}
#     should not be empty    ${rsrp}
#     [Teardown]    run keyword and ignore error    csn.Disconnect	connection=${connection}
#
# Rename downloaded file
#     [Documentation]    Author: Cui Lingxue
#     ...    Description: rename file and move to ${TS_CASE_LOG_PATH} or ${SUITE_LOG_PATH}.
#     [Arguments]    ${log_path}    ${rename_prefix}=Ori    ${is_set_to_test_case_level}=${True}
#     ${log_name}    fetch_from_right    string=${log_path}    marker=/
#     ${new_log_dir}    set variable if    ${is_set_to_test_case_level}    ${TS_CASE_LOG_PATH}    ${SUITE_LOG_PATH}
#     ${log_path_renamed}    join path    ${new_log_dir}    ${rename_prefix}_${log_name}
#     run    mv ${log_path} ${log_path_renamed}
#     [Return]    ${log_path_renamed}
#
# Analysis capture log for Case213
#     [Arguments]    ${filter4}=${filter4}    ${filter5}=${filter5}    ${filter6}=${filter6}    ${filter7}=${filter7}
#     ...    ${filter8}=${filter8}    ${target6}=${target6}
#     csn.Connect to     hostname=${test_ute}   username=${ute_name}    password=${test_password}  alias=${connection}
#     Convert pcap to text    source=${source}    target=${target6}    connection=${connection}    filter=${filter4}
#     csn.Send Command    command=cat ${target6}    connection=${connection}
#     ${re1}  csn.Read Output    connection=${connection}
#     should be empty    ${re1}
#     Convert pcap to text    source=${source}    target=${target6}    connection=${connection}    filter=${filter5}
#     csn.Send Command    command=cat ${target6}    connection=${connection}
#     ${re2}  csn.Read Output    connection=${connection}
#     should be empty    ${re2}
#     Convert pcap to text    source=${source}    target=${target6}    connection=${connection}    filter=${filter6}
#     csn.Send Command    command=cat ${target6}    connection=${connection}
#     ${re3}  csn.Read Output    connection=${connection}
#     should be empty    ${re3}
#     Convert pcap to text    source=${source}    target=${target6}    connection=${connection}    filter=${filter7}
#     csn.Send Command    command=cat ${target6}    connection=${connection}
#     ${re4}  csn.Read Output    connection=${connection}
#     should be empty    ${re4}
#     [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}
#
# Modify Value On DU
#     [Arguments]    ${structure_modify_list}    ${gNB_ip}    ${common_modify_list}=None    ${keywords_list}=None    ${connection}=GNB_connection
#     ...    ${class_name}=None   ${is_structure}=${True}    ${is_common}=${True}    ${structure_index}=0
# #    coam.connect_to    bts_host=${gNB_ip}   name=${connection}
#     Connect to gnb coam via ssl    bts_host=${gNB_ip}    connection=${connection}
#     run keyword if  ${is_structure}    Modify Structure parameter via Coam    class_name=${class_name}   connection=${connection}
#     ...    modify_list=${structure_modify_list}    keywords_list=${keywords_list}    index=${structure_index}
#     log to console    modify successful
#     sleep    30s
#     [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}
#
# Modify Structure parameter via Coam
#     [Arguments]   ${class_name}   ${connection}   ${modify_list}   ${keywords_list}    ${index}=0
#     ${get_managed_objects}     coam.get_managed_objects     class_name=${class_name}    connection=${connection}
#     ${output_dict_list}    return_structure_value    input_list=${get_managed_objects}    modify_list=${modify_list}
#     ...    keywords_list=${keywords_list}
#     FOR    ${item}  IN  @{output_dict_list}
#          ${dict_value}    Get Content From Input Dict    input_dict=${item}
#          coam.Perform Parameter Recommissioning    dist_name=@{dict_value}[0]   parameter=@{dict_value}[1]   value=@{dict_value}[2]
#          ...    operation=update    skip_parameter_relation_errors=${True}    should_activate=${True}    connection=${connection}
#          sleep  30s
#     END
#
# Recovery parameter
#     Modify Common parameter via Coam    input_list=${PARAMS_TO_MODIFY_DomainNumber4}    bts_ip=${DU_OAM_IP_TL}
#     Modify Common parameter via Coam    input_list=${PARAMS_TO_MODIFY_DomainNumber5}    bts_ip=${DU_OAM_IP_TL}
#     Modify Value On DU     gNB_ip=${DU_OAM_IP_TL}    structure_modify_list=${PARAMS_TO_MODIFY_DomainNumber6}
#     ...    class_name=TRBLCADM_A    keywords_list=${keywords_list1}
#     COAM GNB Wait CU and DU cells are on air status    timeout=5min
#     [Teardown]    CI_interface.Common Case Teardown
#
# Iperf send UL traffic VIAVI
#     [Documentation]    Author: Ding Binmei
#     ...                Description: ul_host_ip will default to 192.168.10.70
#     ...                port=5410 is related with it used on cobham. Now dedicated to this value
#     [Arguments]    ${throughput}    ${traffic_time}    ${ul_host_ip}=192.168.10.70
#     ...    ${port}=${tl.ues[0].iperf_details.ssh_connection_details.port}    ${length}=${1024}
#     Log to console    Start UL traffic with real epc
#     wait until keyword succeeds    2 min    10 s    Connect to app server
#     ${is_iperf_process_started}    run keyword and return status  Check if iperf server process is started on app server    port=${port}
#     Run keyword if  ${is_iperf_process_started}==${False}
#     ...    Run keywords    Log to console    Iperf server is not started on app server, now started.    AND
#     ...                    Start iperf server    port=${port}    connection=APPserver    AND
#     ...                    Check if iperf server process is started on app server    port=${port}
#
#     wait until keyword succeeds    2 min    10 s    traffic_via_iperf.Connect to cobham control pc via ssh
#     ${cmd_start_iperf_client}    Catenate    ${iperf_path}/iperf -u -c ${ul_address} -b ${ul_throughput}M -t ${ul_time} -i 1 -p ${port}
#     csn.send command     command=${cmd_start_iperf_client}    connection=${TMA_SSH_ALIAS}
#     sleep    5s
#     Log to console    Start to send UL traffic with real epc on UE side, traffic time is ${traffic_time}
#     [Teardown]  Run keyword and ignore error    Run keywords    traffic_via_iperf.Disconnect from app server    AND
#     ...    traffic_via_iperf.Disconnect from cobham control pc via ssh
#
# #enable PPPoE connection
# #    [Documentation]    activates the PPPoE tunnel with E500 thanks to ssh opened connection.
# #    ...                PPPoE tunnel is required to be able to launch DL iperf in reception on the Viavi PC
# #    ...                the PPPoE configured name under the PC shall be TM500
# #    ...                the alias of the ssh connection used is ViaviSshConnection from above Viavi PC connect keyword
# #    ...                PPPoE set up action in script must be performed in background as the UE attach under TMA should
# #    ...                be launch in // of the PPPoE set up
# #    ssh.send command   rasdial TM500    connection=ViaviSshConnection
# #    ${output}          read output
# #    log     ${output}
# #    should contain     ${output}    Command completed successfully
# #
# #disable PPPoE connection
# #    ssh.send command   rasdial TM500 /disconnect
# #    ${output}          read output
# #    log     ${output}
# #    should contain     ${output}    Command completed successfully
