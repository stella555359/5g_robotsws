# *** Settings ***
# Force Tags    PY36
# Suite Setup    572 Case preparation
# Suite Teardown    Recovery parameter
# Documentation
# ...   author: xiaofeng.1.zhu@nokia-sbell.com
# ...   contact: xiaofeng.1.zhu@nokia-sbell.com
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/container_log_capturing.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/viavi_common_keyword.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_cu.robot
# Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
#
# Variables         Resources/5GC000572_modify_para.py
# Library           Resources/5GC000572.py
# Resource          ../5GC001912_EB/Resources/5GC001912_EB_keywords.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/UEs/inseego.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
# Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
# Library           Resources/common_keyword.py
# Library    taf.analyzer.pcap    WITH NAME    check_cap
# Library           taf.transport.ssh    WITH NAME    csn
# Library           taf.hw.rf_attenuator    WITH NAME    att
# Library           taf.ue  WITH NAME   ute_ue
# Library           taf.gnb.oam.coam.cu.interface.cu     WITH NAME     coam_cu
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
#
# ${DU_OAM_IP_URL}            https://${tl.gnbs[0].dus[0].f1_m_ip_addr}
# ${DU_OAM_WEBUI_IP}         ${tl.gnbs[0].dus[0].f1_m_ip_addr}
# ${DU_OAM_WEBUI_USER}        ${tl.gnbs[0].cu.oam_http_connection_details.username}
# ${DU_OAM_WEBUI_PASSWORD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
# ${DU_OAM_IP_TL_2}              ${tl.gnbs[0].dus[1].f1_m_ip_addr}
# ${DU_OAM_IP_TL}                ${tl.gnbs[0].dus[0].f1_m_ip_addr}
# ${DU_OAM_SSH_USERNAME_TL}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
# ${DU_OAM_SSH_PASSWORD_TL}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
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
#
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
# ${target3}                   ${output_dir}/A3_A5.txt
# ${target5}                   ${output_dir}/CELL_ID.txt
# ${target6}                   ${output_dir}/checkmeas.txt
# ${target7}                   ${output_dir}/bts_log.log
# ${target8}                   ${output_dir}/syslog_.log
# ${filter}                    x2ap.procedureCode == 27 && x2ap.X2AP_PDU == 1
#
# ${filter1}                   x2ap.X2AP_PDU == 0 && x2ap.procedureCode == 30
# ${filter2}                   x2ap.X2AP_PDU == 0 && x2ap.procedureCode == 35
#
# ${filter3}                   nr-rrc.measId
# ${filter4}                   x2ap.X2AP_PDU == 1 && x2ap.procedureCode == 30
# ${filter5}                   x2ap.X2AP_PDU == 0 && x2ap.procedureCode == 35
# ${filter6}                   x2ap.X2AP_PDU == 0 && x2ap.procedureCode == 30
# ${filter7}                   x2ap.X2AP_PDU == 0 && x2ap.procedureCode == 32
# ${filter8}                   x2ap.X2AP_PDU == 0 && x2ap.procedureCode == 5
# ${filter9}                   nr-rrc.newUE_Identity
# ${throughput}                100M
# ${cpif_log_name}            CPIF_log
# ${NSA}     {'MRBTS-${tl.gnbs[0].cu.instance_id}/NRBTS-${tl.gnbs[0].cu.global_bts_id}': {'actIntraFreqIntraGnbMobilityNSA': 'true'}}
# ${E500_SCRIPTS_BASE}    ${CURDIR}/E500_scripts
# ${TMA_APP_ALIAS}        e500
# ${Test_Case_Name}           5GC000572_BTSLOG
# ${ul_time}              1800
# ${ul_port}              ${tl.ues[0].iperf_details.ssh_connection_details.port}
# ${dl_port}              ${tl.ues[0].iperf_details.port}
# ${ul_throughput}        2M
# ${ul_length}            1024B
# ${NUM}                  1
# ${port1}                51000
# ${port2}                51001
# *** Test Cases ***
# [1]5GC000572_C_51_mobility_execution_passed_call_a3_measurement_configuration_ssb_rsrp_enabled
#     [Documentation]    mobility execution passed call a3 measurement configuration ssb rsrp enabled
#     [Tags]    CRT_20B    CRT_21B    CRT_TRUNK    CRT_22R2
#     [Setup]
#     Set test variable    ${LOG_PATH}    ${TS_CASE_LOG_PATH}
#     CU Delta Commission update    parameters=${CELL_1_A3_RSRP}
#     Precondition for attach with retry
#     Attach and trigger meas Report
#     ${CELL_ID1}    Check log cell ID    target=${target}    filter=${filter}
#     ${CELL_ID2}    Check log cell ID    target=${target1}    filter=${filter1}
#     should not be equal as numbers       ${CELL_ID1}    ${CELL_ID2}
#     ${meas_ID}     Check measuerment report    target=${target2}    filter=${filter2}
#     Check meas ID measuerment report    Meas_ID=${meas_ID}    grep1=a3-Offset:    grep2=rsrp
#     Analysis capture log for Case213
#     ${CELL1}    ${CELL2}    check BTS DL throughput
#     #check BTS UL throughput    CELL1=${CELL1}    CELL2=${CELL2}
#     [Teardown]
#
# [1]5GC000572_E_53_mobility_execution_passed_call_a3_measurement_configuration_ssb_rsrp_and_rsrq_enabled
#     [Documentation]    mobility execution passed call a3 measurement configuration ssb rsrp and rsrq enabled
#     [Tags]    CRT_20B    CRT_21B    CRT_TRUNK    CRT_22R2
#     [Setup]
#     Set test variable    ${LOG_PATH}    ${TS_CASE_LOG_PATH}
#     CU Delta Commission update    parameters=${CELL_1_A3_RSRP_RSRQ}
#     Precondition for attach with retry
#     Attach and trigger meas Report    report_type=RSRQ
#     ${CELL_ID1}    Check log cell ID    target=${target}    filter=${filter}
#     ${CELL_ID2}    Check log cell ID    target=${target1}    filter=${filter1}
#     should not be equal as numbers       ${CELL_ID1}    ${CELL_ID2}
#     ${meas_ID}     Check measuerment report    target=${target2}    filter=${filter2}
#     Check meas ID measuerment report    Meas_ID=${meas_ID}    grep1=a3-Offset:    grep2=rsrq
#     Analysis capture log for Case213
#     ${CELL1}    ${CELL2}    check BTS DL throughput
#     #check BTS UL throughput    CELL1=${CELL1}    CELL2=${CELL2}
#     [Teardown]
#
# [1]5GC000572_E_65_mobility_execution_passed_call_a5_measurement_configuration_ssb_rsrp_and_rsrq_enabled
#     [Documentation]    mobility execution passed call a5 measurement configuration ssb rsrp and rsrq enabled
#     [Tags]    CRT_20B    CRT_21B    CRT_TRUNK    CRT_22R2
#     [Setup]
#     Set test variable    ${LOG_PATH}    ${TS_CASE_LOG_PATH}
#     CU Delta Commission update    parameters=${CELL_1_A5_RSRP_RSRQ}
#     Precondition for attach with retry
#     Attach and trigger meas Report    report_type=A5
#     ${CELL_ID1}    Check log cell ID    target=${target}    filter=${filter}
#     ${CELL_ID2}    Check log cell ID    target=${target1}    filter=${filter1}
#     should not be equal as numbers       ${CELL_ID1}    ${CELL_ID2}
#     ${meas_ID}     Check measuerment report    target=${target2}    filter=${filter2}
#     Check meas ID measuerment report    Meas_ID=${meas_ID}    grep1=a5-Threshold1:    grep2=rsrp
#     Analysis capture log for Case213
#     ${CELL1}    ${CELL2}    check BTS DL throughput
#     #check BTS UL throughput    CELL1=${CELL1}    CELL2=${CELL2}
#     [Teardown]
#
# *** Keywords ***
# Attach and trigger meas Report
#     [Arguments]    ${cpif_log_name}=${cpif_log_name}    ${log_path}=${TS_CASE_LOG_PATH}    ${report_type}=RSRP
#     Start tcpdump log on CU    tcpdump_collector_name=${cpif_log_name}_f1    options=-i fronthaul    vm_name=cpif-0.local
#     Start tcpdump log on CU    tcpdump_collector_name=${cpif_log_name}_x2    options=-i x2    vm_name=cpif-0.local
#
#     Connect to gnb coam via ssl    bts_host=${DU_OAM_IP_TL}    username=${DU_OAM_WEBUI_USER}   password=${DU_OAM_WEBUI_PASSWORD}
#     log to console    start attach...
#
#     Cobham retry ue attach if failed
#     log to console    ue attach successful,sleep:10s
# #    Iperf send UL traffic with real epc   throughput=${100}   traffic_time=${180}    ul_host_ip=10.57.178.18    port=${ul_port}
#     Iperf send DL traffic with real epc    throughput=${100}    traffic_time=${180}    port=${dl_port}
#     sleep    10s
#     log to console    start syslog...
#     ${list}    Create list     ${port1}    ${port2}
#     ute_syslog.Start Syslog    log_dir=${OUTPUT_DIR}    log_name=syslog_.log    host_ip=${TEST_PC_IP}    ssh_username=ute
#     ...    ssh_password=iW_K#8.ute%A10h0m0ra    ports=${list}    alias=${connection}
#
#     sleep    10s
#     run keyword if    '${report_type}'=='RSRP'    Trigger A3 measurement report for 572
#     run keyword if    '${report_type}'=='RSRQ'    Trigger A3 RSRQ measurement report for 572
#     run keyword if    '${report_type}'=='A5'      Trigger A5 measurement report for 572
#     log to console    cell swtich successful
#     sleep    20s
#     [Teardown]    Stop tcpdump log
#
# Stop tcpdump log
#     [Arguments]    ${cpif_log_name}=${cpif_log_name}    ${ppb_value}=20    ${ns_value_scope}=0.5
#     log to console    End btslog
#     Stop syslog    alias=${connection}
#     Stop tcpdump on CPIF and rename downloaded file    cpif_log_name=${cpif_log_name}_f1
#     Stop tcpdump on CPIF and rename downloaded file    cpif_log_name=${cpif_log_name}_x2
#
# #    Iperf stop traffic from appserver and ue side    port=${ul_port}
# #    Iperf stop traffic from appserver and ue side    port=${dl_port}
#     Cobham UE detach
#     ${merged_log_path}    set variable    ${log_path}/${cpif_log_name}.pcap
#     run    mergecap -w ${merged_log_path} ${log_path}/Ori_${cpif_log_name}_x2.pcap ${log_path}/Ori_${cpif_log_name}_f1.pcap
#     [Teardown]    Run Keyword And Ignore Error    coam.teardown    connection=${connection}
#
# 572 Case preparation
#     [Arguments]    ${is_srb3}=${False}
# #    ${connection}    coam.connect_to    bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}     name=GNB_OAM
#     Connect to gnb coam via ssl    bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}    connection=GNB_OAM
#     ${connection}    set variable    GNB_OAM
#     ${version}    coam.get_sw_version    connection=${connection}
#     ${version_list}    split string    ${version}    _
#     run keyword if    '${version_list[2]}'=='0014'    load scf activation    path1=${CURDIR_path1}    path2=${CURDIR_path2}    path3=${CURDIR_path3
# }
#     run keyword if    '${version_list[2]}'=='0010'    load scf activation    path1=${CURDIR_path4}    path2=${CURDIR_path5}    path3=${CURDIR_path6
# }
#     run keyword if    '${version_list[2]}'=='0012'    load scf activation    path1=${CURDIR_path7}    path2=${CURDIR_path8}    path3=${CURDIR_path9
# }
#
#     COAM GNB Wait CU and DU cells are on air status    timeout=15min
#     Modify Common parameter via Coam    input_list=${PARAMS_TO_MODIFY_DomainNumber0}    bts_ip=${ENB_IP}
#     Modify Value On DU     gNB_ip=${DU_OAM_IP_TL}    structure_modify_list=${PARAMS_TO_MODIFY_DomainNumber1}
#     ...    class_name=TRBLCADM_A    keywords_list=${keywords_list1}
#     Modify Value On DU     gNB_ip=${DU_OAM_IP_TL_2}    structure_modify_list=${PARAMS_TO_MODIFY_DomainNumber2}
#     ...    class_name=TRBLCADM_A    keywords_list=${keywords_list1}
#     Modify Value On DU     gNB_ip=${DU_OAM_IP_TL_2}    structure_modify_list=${PARAMS_TO_MODIFY_DomainNumber7}
#     ...    class_name=TRBLCADM_A    keywords_list=${keywords_list1}
#     Modify Value On DU     gNB_ip=${DU_OAM_IP_TL}    structure_modify_list=${PARAMS_TO_MODIFY_DomainNumber8}
#     ...    class_name=TRBLCADM_A    keywords_list=${keywords_list1}
#     run keyword if    ${is_srb3}    ENABLE SRB3 on gNB    ELSE    DISABLE SRB3 on gNB
#     log to console    Precondition for attach...
#     [Teardown]    Run Keyword And Ignore Error    coam.teardown    connection=${connection}
#
# load scf activation
#     [Arguments]   ${path1}    ${path2}    ${path3}
#     Setup Commission SCF    bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}    CURDIR_path=${path3}
#     Setup Commission SCF    bts_host=${tl.gnbs[0].dus[1].f1_m_ip_addr}    CURDIR_path=${path2}
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
# Trigger A3 measurement report for 572
#     [Arguments]    ${a3_meas_id}=1    ${report_interval}=0    ${serving_cell_pci}=414    ${serving_cell_rsrp}=50
#     ...    ${serving_cell_rsrq}=53    ${serving_cell_sinr}=35    ${neigh_cell_pci}=416    ${neigh_cell_rsrp}=71    ${neigh_cell_rsrq}=57
#     ...    ${neigh_cell_sinr}=44    ${tm500_alias}=e500
#     log to console  Start to trigger A3 measurement report
#     ${cmd_a3_mr}    catenate
#     ...    forw mte NrRrcAptTriggerMeasReport ${a3_meas_id} 0 0 ${report_interval} 1
#     ...    {8 [${serving_cell_pci}] [[${serving_cell_rsrp}] [${serving_cell_rsrq}] [${serving_cell_sinr}]] [] [[1{0[[50] [] []]}] []] [] []}
#     ...    [0(1{[${neigh_cell_pci}] [[${neigh_cell_rsrp}] [${neigh_cell_rsrq}] [${neigh_cell_sinr}]] [][ [1{0[[71] [] []]}] [] ] })]
#     ${response}    tm500_remote.send_command    command=${cmd_a3_mr}    alias=${tm500_alias}
#     ${response}    tm500_remote.send_command    command=forw mte Activate -1    alias=${tm500_alias}
#     Wait until keyword succeeds    10s    200ms    match pattern in response    response=${response}
#     ...    e500_alias=${tm500_alias}    pattern=Random Access Complete
#
# Trigger A3 RSRQ measurement report for 572
#     [Arguments]    ${a3_meas_id}=2    ${report_interval}=0    ${serving_cell_pci}=414    ${serving_cell_rsrp}=60
#     ...    ${serving_cell_rsrq}=53    ${serving_cell_sinr}=35    ${neigh_cell_pci}=416    ${neigh_cell_rsrp}=60    ${neigh_cell_rsrq}=57
#     ...    ${neigh_cell_sinr}=44    ${tm500_alias}=e500
#     log to console  Start to trigger A3 RSRQ measurement report
#     ${cmd_a3_mr}    catenate
#     ...    forw mte NrRrcAptTriggerMeasReport ${a3_meas_id} 0 0 ${report_interval} 1
#     ...    {8 [${serving_cell_pci}] [[${serving_cell_rsrp}] [${serving_cell_rsrq}] [${serving_cell_sinr}]] [] [[1{0[[60] [53] []]}] []] [] []}
#     ...    [0(1{[${neigh_cell_pci}] [[${neigh_cell_rsrp}] [${neigh_cell_rsrq}] [${neigh_cell_sinr}]] [][ [1{0[[60] [57] []]}] [] ] })]
#     ${response}    tm500_remote.send_command    command=${cmd_a3_mr}    alias=${tm500_alias}
#     ${response}    tm500_remote.send_command    command=forw mte Activate -1    alias=${tm500_alias}
#     Wait until keyword succeeds    10s    200ms    match pattern in response    response=${response}
#     ...    e500_alias=${tm500_alias}    pattern=Random Access Complete
#
# Trigger A5 measurement report for 572
#     [Arguments]    ${a5_meas_id}=1    ${report_interval}=0    ${serving_cell_pci}=414    ${serving_cell_rsrp}=56
#     ...    ${serving_cell_rsrq}=71    ${serving_cell_sinr}=35    ${neigh_cell_pci}=416    ${neigh_cell_rsrp}=66    ${neigh_cell_rsrq}=57
#     ...    ${neigh_cell_sinr}=44    ${tm500_alias}=e500
#     log to console  Start to trigger A5 measurement report
#     ${cmd_a3_mr}    catenate
#     ...    forw mte NrRrcAptTriggerMeasReport ${a5_meas_id} 0 0 ${report_interval} 1
#     ...    {0 [${serving_cell_pci}] [[${serving_cell_rsrp}] [${serving_cell_rsrq}] [${serving_cell_sinr}]] [] [[1{0[[56] [71] []]}] []] [] []}
#     ...    [0(1{[${neigh_cell_pci}] [[${neigh_cell_rsrp}] [${neigh_cell_rsrq}] [${neigh_cell_sinr}]] [][ [1{0[[66] [57] []]}] [] ] })]
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
# Modify Common parameter via Coam
#     [Arguments]  ${input_list}    ${bts_ip}    ${connection}=GNB_connection
#     log to console    Modify parameter
# #    coam.connect_to    bts_host=${bts_ip}   name=${connection}
#     Connect to gnb coam via ssl    bts_host=${bts_ip}    connection=${connection}
#     :FOR    ${item}  IN    @{input_list}
#     \    ${dict_value}    Get Content From Input Dict    input_dict=${item}
#     \    coam.Perform Parameter Recommissioning    dist_name=@{dict_value}[0]   parameter=@{dict_value}[1]   value=@{dict_value}[2]
#         ...    operation=update    skip_parameter_relation_errors=${True}    should_activate=${True}    connection=${connection}
#     log to console  sleep 30s
#     sleep  30s
#     [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}
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
#     ${CELL_ID}    csn.Read Output    connection=${connection}
#     ${CELL_ID}    strip_string    ${CELL_ID}
#     log to console  physCellId=${CELL_ID}
#     [Return]    ${CELL_ID}
#     [Teardown]    run keyword and ignore error    csn.Disconnect	connection=${connection}
#
# Check measuerment report
#     [Arguments]    ${source}=${source}    ${target}=${target2}    ${filter}=${filter2}
#     csn.Connect to     hostname=${test_ute}   username=${ute_name}    password=${test_password}  alias=${connection}
#     sleep    1s
#     Convert pcap to text    source=${source}    target=${target}    connection=${connection}    filter=${filter}
#     csn.Send Command  command=cat ${target} |grep measId |tr -cd "[0-9]"
#     ...    connection=${connection}
#     ${Meas_ID}    csn.Read Output    connection=${connection}
#     ${Meas_ID}    strip_string    ${Meas_ID}
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
#     ${Meas_ID_2}    csn.Read Output    connection=${connection}
#     ${Meas_ID_2}    strip_string    ${Meas_ID_2}
#     log to console  Meas_ID=${Meas_ID_2}
#     should be equal as numbers    ${Meas_ID}    ${Meas_ID_2}
#     csn.Send Command  command=cat ${target} |grep a3-Offset:|grep rsrq    connection=${connection}
#     ${rsrp}    csn.Read Output    connection=${connection}
#     ${rsrp}    strip_string    ${rsrp}
#     should not be empty    ${rsrp}
#     [Teardown]    run keyword and ignore error    csn.Disconnect	connection=${connection}
#
# Check A5 measuerment report
#     [Arguments]    ${Meas_ID}
#     csn.Connect to     hostname=${test_ute}   username=${ute_name}    password=${test_password}  alias=${connection}
#     sleep    1s
#     csn.Send Command  command=cat ${target} |grep measId:|head -${Meas_ID}|tail -n 1|tr -cd "[0-9]"    connection=${connection}
#     ${Meas_ID_2}    csn.Read Output    connection=${connection}
#     ${Meas_ID_2}    strip_string    ${Meas_ID_2}
#     log to console  Meas_ID=${Meas_ID_2}
#     should be equal as numbers    ${Meas_ID}    ${Meas_ID_2}
#     csn.Send Command  command=cat ${target} |grep a5-Threshold1:|grep rsrp    connection=${connection}
#     ${rsrp}    csn.Read Output    connection=${connection}
#     ${rsrp}    strip_string    ${rsrp}
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
#     Convert pcap to text    source=${source}    target=${target6}    connection=${connection}    filter=${filter7}
#     csn.Send Command    command=cat ${target6}    connection=${connection}
#     ${re4}    csn.Read Output    connection=${connection}
#     should be empty    ${re4}
#     [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}
#
# Recovery parameter
#     Modify Value On DU     gNB_ip=${DU_OAM_IP_TL_2}    structure_modify_list=${PARAMS_TO_MODIFY_DomainNumber3}
#     ...    class_name=TRBLCADM_A    keywords_list=${keywords_list1}
#     Modify Value On DU     gNB_ip=${DU_OAM_IP_TL}    structure_modify_list=${PARAMS_TO_MODIFY_DomainNumber6}
#     ...    class_name=TRBLCADM_A    keywords_list=${keywords_list1}
#     COAM GNB Wait CU and DU cells are on air status    timeout=5min
#     [Teardown]    CI_interface.Common Case Teardown
#
# Setup Commission SCF
#     [Arguments]    ${CURDIR_path}     ${bts_host}=${tl.gnbs[0].dus[0].f1_m_ip_addr}
#     ...    ${username}=${tl.gnbs[0].cu.oam_http_connection_details.username}
#     ...    ${password}=${tl.gnbs[0].cu.oam_http_connection_details.password}
# #    coam.connect_to    bts_host=${bts_host}    bts_port=${443}    username=${username}    password=${password}
# #    ...   name=${connection}
#     Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
#     ...    connection=${connection}
#     log to console    connect successful
#     COAM Commission with scf file    is_pdl_checking_needed=False    scf_file_path=${CURDIR_path}
#     log to console    active DU scf successful
#     Run Keyword And Ignore Error    coam.teardown
#     [Teardown]    Run Keyword And Ignore Error    coam.teardown    connection=${connection}
