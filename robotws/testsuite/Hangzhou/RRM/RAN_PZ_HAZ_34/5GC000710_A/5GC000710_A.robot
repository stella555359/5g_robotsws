# *** Settings ***
# Force Tags    PY36
# Suite Setup
# Suite Teardown
# Documentation
# ...   author: xiaofeng.1.zhu@nokia-sbell.com
# ...   contact: xiaofeng.1.zhu@nokia-sbell.com
# ...   report_type is the distinction of different case types(001,002,008...)
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/container_log_capturing.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/viavi_common_keyword.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_cu.robot
# Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/pm_counter.robot
#
# Variables         Resources/5GC000710_A_modify_para.py
# Library           Resources/5GC000710_A.py
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
# Library           taf.gnb.oam.coam.cu.interface.cu      WITH NAME       coam_cu
# *** Variables ***
# ${CURDIR_path1}            ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/DU_710_002.xml
# ${CURDIR_path2}            /home/ute/5GC000710_A/${testline_name}/CU_710_002.xml
# ${CURDIR_path3}            /home/ute/5GC000710_A/${testline_name}/CU_710_013.xml
# ${CURDIR_path4}            /home/ute/5GC000710_A/${testline_name}/CU_710_001.xml
# ${CURDIR_path5}            ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/DU_710_TL416.xml
# ${CURDIR_path6}            ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/DU_21B_710_002.xml
# ${CURDIR_path7}            /home/ute/5GC000710_A/${testline_name}/CU_21B_710_002.xml
# ${CURDIR_path8}            /home/ute/5GC000710_A/${testline_name}/CU_21B_710_013.xml
# ${CURDIR_path9}            /home/ute/5GC000710_A/${testline_name}/CU_21B_710_001.xml
# ${CURDIR_path10}            ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/DU_21B_710_TL416.xml
#
# ${E500_SCRIPTS_BASE1}    ${CURDIR}/E500_scripts
# ${E500_SCRIPTS_BASE2}    ${CURDIR}/E500_scripts2
# ${E500_SCRIPTS_BASE3}    ${CURDIR}/E500_scripts3
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
# ${source}                    ${output_dir}/CPIF_log.pcap
# ${source2}                   ${output_dir}/enb_tcpdump.pcap
#
# ${target}                    ${output_dir}/attach.txt
# ${target1}                    ${output_dir}/Reconfiguration.txt
# ${target2}                   ${output_dir}/measuerment_report1.txt
# ${target3}                   ${output_dir}/A3_A5.txt
# ${target5}                   ${output_dir}/CELL_ID.txt
# ${target6}                   ${output_dir}/checkmeas.txt
# ${target7}                   ${output_dir}/bts_log.log
# ${target8}                   ${output_dir}/syslog_.log
# ${target9}                   ${output_dir}/Request.txt
# ${target10}                  ${output_dir}/Setuprequest.txt
# ${target11}                   ${output_dir}/measuerment_report2.txt
# ${target12}                   ${output_dir}/SgNBMod_Reconfiguration.txt
# ${target13}                   ${output_dir}/datacheck.txt
# ${filter}                    x2ap.procedureCode == 27 && x2ap.X2AP_PDU == 1
#
# ${filter1}                   x2ap.X2AP_PDU == 0 && x2ap.procedureCode == 30
# ${filter2}                   x2ap.X2AP_PDU == 0 && x2ap.procedureCode == 35 && nr-rrc.rsrq == 53
# ${filter3}                   nr-rrc.measId
# ${filter4}                   x2ap.X2AP_PDU == 1 && x2ap.procedureCode == 30
# ${filter5}                   x2ap.X2AP_PDU == 0 && x2ap.procedureCode == 35 && nr-rrc.rsrq == 61
# ${filter6}                   x2ap.X2AP_PDU == 0 && x2ap.procedureCode == 30
# ${filter7}                   x2ap.X2AP_PDU == 0 && x2ap.procedureCode == 32
# ${filter8}                   x2ap.X2AP_PDU == 0 && x2ap.procedureCode == 5
# ${filter9}                   nr-rrc.newUE_Identity
# ${filter10}                  x2ap.procedureCode == 27 && x2ap.X2AP_PDU == 0 && x2ap.criticality == 0
# ${filter11}                  f1ap.procedureCode == 5 && f1ap.F1AP_PDU == 0
# ${filter12}                  x2ap.procedureCode == 30 && x2ap.X2AP_PDU == 0
# ${filter13}                  x2ap.X2AP_PDU == 0 && x2ap.procedureCode == 35 && nr-rrc.rsrp == 75
# ${filter14}                  nr-rrc.rsrp == 107 && x2ap.X2AP_PDU == 0 && x2ap.procedureCode == 35 && nr-rrc.rsrq == 53
# ${filter15}                  x2ap.X2AP_PDU == 0 && x2ap.procedureCode == 35 && nr-rrc.rsrq == 71
# ${filter16}                  x2ap.procedureCode == 30 && x2ap.X2AP_PDU == 0 && nr-rrc.gapOffset == 12
# ${filter17}                  x2ap.procedureCode == 30 && x2ap.X2AP_PDU == 0 && nr-rrc.gapFR2 == 0
# ${filter18}                  nr-rrc.rsrp == 75 && f1ap.procedureCode == 13 && f1ap.F1AP_PDU == 0
# ${filter19}                  nr-rrc.rsrp == 50 && f1ap.procedureCode == 13 && f1ap.F1AP_PDU == 0
# ${filter20}                  f1ap.procedureCode == 12 && f1ap.F1AP_PDU == 0 && nr-rrc.srb_Identity == 3
# ${filter21}                  nr-rrc.gapOffset == 12 && f1ap.procedureCode == 12 && f1ap.F1AP_PDU == 0
# ${filter22}                  x2ap.procedureCode == 35 && x2ap.X2AP_PDU == 0 && nr-rrc.rsrp == 75
# ${filter23}                  x2ap.procedureCode == 30 && x2ap.X2AP_PDU == 0 && nr-rrc.gapFR2 == 1
# ${filter24}                  x2ap.procedureCode == 35 && x2ap.X2AP_PDU == 0 && nr-rrc.rsrp == 55
# ${filter25}                  x2ap.procedureCode == 30 && x2ap.X2AP_PDU == 0 && nr-rrc.eventId == 1
# ${filter26}                  x2ap.procedureCode == 30 && x2ap.X2AP_PDU == 0
# ${filter27}                  x2ap.procedureCode == 30 && x2ap.X2AP_PDU == 1
# ${throughput}                100M
# ${cpif_log_name}             CPIF_log
# ${E500_SCRIPTS_BASE}         ${CURDIR}/E500_scripts
# ${TMA_APP_ALIAS}             e500
# ${Test_Case_Name}            5GC000572_BTSLOG
# ${ul_time}                   1800
# ${ul_port}                   ${tl.ues[0].iperf_details.ssh_connection_details.port}
# ${dl_port}                   ${tl.ues[0].iperf_details.port}
# ${NUM}                       1
# ${port1}                     51000
# ${port2}                     51001
# *** Test Cases ***
# [1]5GC000710_A_002_Unsuccessful_configuration_of_A2_measurement_as_all_inter_frequencies_not_supported_by_UE
#     [Documentation]    Unsuccessful configuration of A2 measurement as all inter frequencies not supported by UE
#     [Tags]    CRT_21B
#     [Setup]
#     ${version}    Case preparation    DU_CURDIR_path=${CURDIR_path1}    CU_CURDIR_path=${CURDIR_path2}
#     ...    DU_CURDIR_path_21B=${CURDIR_path6}    CU_CURDIR_path_21B=${CURDIR_path7}
#     Set test variable    ${LOG_PATH}    ${TS_CASE_LOG_PATH}
#     CU Delta Commission update    parameters=${CU_parameter_002_1}
#     Modify Common parameter via Coam    input_list=${DU_002_parameter_1}    bts_ip=${DU_OAM_IP_TL_2}
#     Modify Common parameter via Coam    input_list=${DU_002_parameter_2}    bts_ip=${DU_OAM_IP_TL_2}
#     log to console    Precondition for attach...
#     Precondition for attach with retry
#     Attach and trigger meas Report
#
#     Check wireshark log data    command=grep SubscriberProfileIDforRFP:|tail -n 1|tr -cd "[0-9]"
#     ...    target=${target9}    filter=${filter10}    check=${12}
#     Check wireshark log data    command=awk '/spCellConfigCommon/{p=5}p-->0'|head -2|tail -n 1|tr -cd "[0-9]"
#     ...    target=${target}    filter=${filter}    check=${414}
#
#     007_Check eventA2 empty
#     log to console    start check counter...sleep 5min
#     Waiting time for new counter file generated period CU    reporting_interval=${5}
#     ${55157_counter_file_list}    Collect PM Counter logs from CU    counter_group=55157
#     ${counter_value}    pmcounters_parse.get_counter_value    xml_file_name=${55157_counter_file_list[0]}    counter_id=M55157C00002
#     ${attach_time}     evaluate    ${attach_time}+1
#     should be equal as integers    ${counter_value[0]}    ${attach_time}
#     [Teardown]    CI_interface.Common Case Teardown
#
# [1]5GC000710_A_008_Successful_configuration_of_A2_measurement_using_default_mobility_profile_as_actSPID_false_when_SPID_is_configured
#     [Documentation]    Unsuccessful configuration of A2 measurement using default mobility profile as actSPID false when SPID is configured
#     [Tags]    CRT_21B
#     [Setup]
#     ${version}    Case preparation    DU_CURDIR_path=${CURDIR_path1}    CU_CURDIR_path=${CURDIR_path2}
#     ...    DU_CURDIR_path_21B=${CURDIR_path6}    CU_CURDIR_path_21B=${CURDIR_path7}
#     Set test variable    ${LOG_PATH}    ${TS_CASE_LOG_PATH}
#     CU Delta Commission update    parameters=${CU_parameter_008_1}
#     Modify Common parameter via Coam    input_list=${DU_008_parameter_1}    bts_ip=${DU_OAM_IP_TL_2}
#     Modify Common parameter via Coam    input_list=${DU_008_parameter_2}    bts_ip=${DU_OAM_IP_TL_2}
#     log to console    Precondition for attach...
#     Precondition for attach with retry
#     Attach and trigger meas Report
#
#     Check wireshark log data    command=grep SubscriberProfileIDforRFP:|tail -n 1|tr -cd "[0-9]"
#     ...    target=${target9}    filter=${filter10}    check=${12}
#     Check wireshark log data    command=awk '/spCellConfigCommon/{p=5}p-->0'|head -2|tail -n 1|tr -cd "[0-9]"
#     ...    target=${target}    filter=${filter}    check=${414}
#     Check wireshark log data    command=awk '/eventId: eventA2/{p=5}p-->0'|head -3|tail -n 1|awk '{print $2}'
#     ...    target=${target10}    filter=${filter11}    check=rsrq
#     Check wireshark log data    command=awk '/eventId: eventA2/{p=5}p-->0'|head -3|tail -n 1|awk '{print $2}'
#     ...    target=${target}    filter=${filter}    check=rsrq
#
#     log to console    start check counter...sleep 5min
#     Waiting time for new counter file generated period CU    reporting_interval=${5}
#     ${55157_counter_file_list}    Collect PM Counter logs from CU    counter_group=55157
#     ${counter_value}    pmcounters_parse.get_counter_value    xml_file_name=${55157_counter_file_list[0]}    counter_id=M55157C00001
#     should be equal as integers    ${counter_value[0]}    ${1}
#
#     [Teardown]    CI_interface.Common Case Teardown
#
# [1]5GC000710_A_013_online_modification_of_mobility_profile_between_A2_configuration_and_A2_RSRPCombine_Report_with_change_A3_to_A5
#     [Documentation]    online modification of mobility profile between A2 configuration and A2 RSRPCombine Report with change A3 to A5
#     [Tags]    CRT_21B
#     [Setup]
#     ${version}    Case preparation    DU_CURDIR_path=${CURDIR_path1}    CU_CURDIR_path=${CURDIR_path3}
#     ...    DU_CURDIR_path_21B=${CURDIR_path6}    CU_CURDIR_path_21B=${CURDIR_path8}
#     Set test variable    ${LOG_PATH}    ${TS_CASE_LOG_PATH}
#     CU Delta Commission update    parameters=${CU_parameter_013_1}
#     Modify Common parameter via Coam    input_list=${DU_013_parameter_1}    bts_ip=${DU_OAM_IP_TL_2}
#     Modify Common parameter via Coam    input_list=${DU_013_parameter_2}    bts_ip=${DU_OAM_IP_TL_2}
#     Modify Common parameter via Coam    input_list=${DU_013_parameter_3}    bts_ip=${DU_OAM_IP_TL_2}
#     log to console    Precondition for attach...
#     Precondition for attach with retry
#     Attach and trigger meas Report    report_type=013
#
#     Check wireshark log data    command=grep SubscriberProfileIDforRFP:|tail -n 1|tr -cd "[0-9]"
#     ...    target=${target9}    filter=${filter10}    check=${12}
#     Check wireshark log data    command=awk '/spCellConfigCommon/{p=5}p-->0'|head -2|tail -n 1|tr -cd "[0-9]"
#     ...    target=${target}    filter=${filter}    check=${414}
#     Check wireshark log data    command=awk '/eventId: eventA2/{p=5}p-->0'|head -3|tail -n 1|awk '{print $2}'
#     ...    target=${target10}    filter=${filter11}    check=rsrp
#     Check wireshark log data    command=awk '/eventId: eventA2/{p=5}p-->0'|head -3|tail -n 1|awk '{print $2}'
#     ...    target=${target}    filter=${filter}    check=rsrp
#
#     ${Meas1}    013_Get and Check measID    target=${target2}    filter=${filter2}
#     ${Meas2}    013_Get and Check measID    target=${target11}    filter=${filter5}
#     should be equal as numbers    ${Meas1}    ${Meas2}
#     013_Check Attach Reconfiguration event and SSBFRE    MeasID=${Meas1}
#     013_Check SgNBMOD RRC Reconfiguration
#     013_Check gapoffset    offset_data=${12}
#
#     log to console    start check counter...sleep 5min
#     Waiting time for new counter file generated period CU    reporting_interval=${5}
#     ${55157_counter_file_list}    Collect PM Counter logs from CU    counter_group=55157
#     ${counter_value}    pmcounters_parse.get_counter_value    xml_file_name=${55157_counter_file_list[0]}    counter_id=M55157C00002
#     should be equal as integers    ${counter_value[0]}    ${1}
#
#     [Teardown]    CI_interface.Common Case Teardown
#
# [1]5GC000710_A_007_Unsuccessful_configuration_of_A2_measurement_as_all_inter_frequencies_define_in_profile_not_defined_in_NRcell
#     [Documentation]    Unsuccessful configuration of A2 measurement as all inter frequencies define in profile not defined in NRcell
#     [Tags]    CRT_21B    CRT_TRUNK    CRT_22R2
#     [Setup]
#     ${version}    Case preparation    DU_CURDIR_path=${CURDIR_path1}    CU_CURDIR_path=${CURDIR_path3}
#     ...    DU_CURDIR_path_21B=${CURDIR_path6}    CU_CURDIR_path_21B=${CURDIR_path8}
#     Set test variable    ${LOG_PATH}    ${TS_CASE_LOG_PATH}
#     CU Delta Commission update    parameters=${CU_parameter_007_1}
#     Modify Common parameter via Coam    input_list=${DU_007_parameter_1}    bts_ip=${DU_OAM_IP_TL_2}
#     Modify Common parameter via Coam    input_list=${DU_013_parameter_2}    bts_ip=${DU_OAM_IP_TL_2}
#     log to console    Precondition for attach...
#     Precondition for attach with retry
#     Attach and trigger meas Report
#
#     Check wireshark log data    command=grep SubscriberProfileIDforRFP:|tail -n 1|tr -cd "[0-9]"
#     ...    target=${target9}    filter=${filter10}    check=${12}
#     Check wireshark log data    command=awk '/spCellConfigCommon/{p=5}p-->0'|head -2|tail -n 1|tr -cd "[0-9]"
#     ...    target=${target}    filter=${filter}    check=${414}
#     007_Check eventA2 empty
#
#     log to console    start check counter...sleep 5min
#     Waiting time for new counter file generated period CU    reporting_interval=${5}
#     ${55157_counter_file_list}    Collect PM Counter logs from CU    counter_group=55157
#     ${counter_value}    pmcounters_parse.get_counter_value    xml_file_name=${55157_counter_file_list[0]}    counter_id=M55157C00002
#     should be equal as integers    ${counter_value[0]}    ${1}
#
#     [Teardown]    CI_interface.Common Case Teardown
#
# [1]5GC000710_A_010_Successful_removal_of_inter-frequency_A3A5_and_configuration_A2_after_receipt_A1_RSRPCombine_Measurement_report
#     [Documentation]    Successful removal of inter-frequency A3A5 and configuration A2 after receipt A1 RSRPCombine Measurement report
#     [Tags]    CRT_21B    CRT_TRUNK    CRT_22R2
#     [Setup]
#     ${version}    Case preparation    DU_CURDIR_path=${CURDIR_path1}    CU_CURDIR_path=${CURDIR_path3}
#     ...    DU_CURDIR_path_21B=${CURDIR_path6}    CU_CURDIR_path_21B=${CURDIR_path8}
#     Set test variable    ${LOG_PATH}    ${TS_CASE_LOG_PATH}
#     CU Delta Commission update    parameters=${CU_parameter_010_1}
#     Modify Common parameter via Coam    input_list=${DU_013_parameter_1}    bts_ip=${DU_OAM_IP_TL_2}
#     Modify Common parameter via Coam    input_list=${DU_013_parameter_2}    bts_ip=${DU_OAM_IP_TL_2}
#     Modify Common parameter via Coam    input_list=${DU_013_parameter_3}    bts_ip=${DU_OAM_IP_TL_2}
#     log to console    Precondition for attach...
#     Precondition for attach with retry
#     Attach and trigger meas Report    report_type=010
#
#     Check wireshark log data    command=grep SubscriberProfileIDforRFP:|tail -n 1|tr -cd "[0-9]"
#     ...    target=${target9}    filter=${filter10}    check=${12}
#     Check wireshark log data    command=awk '/spCellConfigCommon/{p=5}p-->0'|head -2|tail -n 1|tr -cd "[0-9]"
#     ...    target=${target}    filter=${filter}    check=${414}
#     Check wireshark log data    command=awk '/eventId: eventA2/{p=5}p-->0'|head -3|tail -n 1|awk '{print $2}'
#     ...    target=${target10}    filter=${filter11}    check=rsrp
#     Check wireshark log data    command=awk '/eventId: eventA2/{p=5}p-->0'|head -3|tail -n 1|awk '{print $2}'
#     ...    target=${target}    filter=${filter}    check=rsrp
#
#     ${Meas1}    013_Get and Check measID    target=${target2}    filter=${filter13}
#     013_Check Attach Reconfiguration event and SSBFRE    MeasID=${Meas1}
#     ${Meas2}    013_Get and Check measID    target=${target2}    filter=${filter14}
#     ${Meas3}    013_Get and Check measID    target=${target11}    filter=${filter15}
#     should be equal as numbers    ${Meas2}    ${Meas3}
#     010_Check event SgNBMOD RRC Reconfiguration    MeasID=${Meas2}
#     013_Check SgNBMOD RRC Reconfiguration    filter=${filter16}    SSBFRE=2073691    event=eventA3    check=rsrp
#     013_Check SgNBMOD RRC Reconfiguration    filter=${filter16}    SSBFRE=2074267    event=eventA3    check=rsrp
#     013_Check gapoffset    offset_data=${12}
#     010_Check A1 and A3 release
#
#     log to console    start check counter...sleep 5min
#     Waiting time for new counter file generated period CU    reporting_interval=${5}
#     ${55157_counter_file_list}    Collect PM Counter logs from CU    counter_group=55157
#     ${counter_value}    pmcounters_parse.get_counter_value    xml_file_name=${55157_counter_file_list[0]}    counter_id=M55157C00002
#     should be equal as integers    ${counter_value[0]}    ${1}
#
#     [Teardown]    CI_interface.Common Case Teardown
#
# [1]5GC000710_A_001_Successful_Intra-DU_PSCell_change_with_inter-frequency_A3_with_SRB3
#     [Documentation]    Successful removal of inter-frequency A3A5 and configuration A2 after receipt A1 RSRPCombine Measurement report
#     [Tags]    CRT_21B    CRT_TRUNK    CRT_22R2
#     [Setup]
#     ${version}    Case preparation    DU_CURDIR_path=${CURDIR_path1}    CU_CURDIR_path=${CURDIR_path4}
#     ...    DU_CURDIR_path_21B=${CURDIR_path6}    CU_CURDIR_path_21B=${CURDIR_path9}    flag=001
#     Set test variable    ${LOG_PATH}    ${TS_CASE_LOG_PATH}
#     CU Delta Commission update    parameters=${CU_parameter_001_1}
#     Modify Common parameter via Coam    input_list=${DU_013_parameter_1}    bts_ip=${DU_OAM_IP_TL_2}
#     Modify Common parameter via Coam    input_list=${DU_013_parameter_2}    bts_ip=${DU_OAM_IP_TL_2}
#     Modify Common parameter via Coam    input_list=${DU_001_parameter_1}    bts_ip=${DU_OAM_IP_TL_2}
#     Modify Common parameter via Coam    input_list=${DU_001_parameter_2}    bts_ip=${DU_OAM_IP_TL_2}
#     Modify Common parameter via Coam    input_list=${DU_013_parameter_3}    bts_ip=${DU_OAM_IP_TL_2}
#     log to console    Precondition for attach...
#     Precondition for attach with retry    e500_script_path=${E500_SCRIPTS_BASE2}
#     Attach and trigger meas Report    report_type=001    E500_SCRIPTS_BASE=${E500_SCRIPTS_BASE2}    is_srb3=${True}
#
#     Check wireshark log data    command=grep SubscriberProfileIDforRFP:|tail -n 1|tr -cd "[0-9]"
#     ...    target=${target9}    filter=${filter10}    check=${12}
#     Check wireshark log data    command=awk '/spCellConfigCommon/{p=5}p-->0'|head -2|tail -n 1|tr -cd "[0-9]"
#     ...    target=${target}    filter=${filter}    check=${414}
#     Check wireshark log data    command=awk '/eventId: eventA2/{p=5}p-->0'|head -3|tail -n 1|awk '{print $2}'
#     ...    target=${target10}    filter=${filter11}    check=rsrp
#     Check wireshark log data    command=awk '/eventId: eventA2/{p=5}p-->0'|head -3|tail -n 1|awk '{print $2}'
#     ...    target=${target}    filter=${filter}    check=rsrp
#
#     ${Meas1}    013_Get and Check measID    target=${target2}    filter=${filter18}
#     013_Check Attach Reconfiguration event and SSBFRE    MeasID=${Meas1}
#     013_Check SgNBMOD RRC Reconfiguration    filter=${filter21}    SSBFRE=2073691    event=eventA3    check=rsrp
#     013_Check SgNBMOD RRC Reconfiguration    filter=${filter21}    SSBFRE=2074267    event=eventA3    check=rsrp
#     Check wireshark log data    command=grep eventA1|head -2|tail -n 1
#     ...    target=${target12}    filter=${filter21}    check=eventA1
#     013_Check gapoffset    offset_data=${12}    filter=${filter21}
#
#     ${Meas2}    013_Get and Check measID    target=${target11}    filter=${filter19}
#     010_Check event SgNBMOD RRC Reconfiguration    MeasID=${Meas2}    target=${target11}    filter=${filter21}    event=eventA3
#     ${CELL_ID1}    Check log cell ID    target=${target}    filter=${filter}
#     ${CELL_ID2}    Check log cell ID    target=${target1}    filter=${filter20}
#     should not be equal as numbers       ${CELL_ID1}    ${CELL_ID2}
#     Check wireshark log data    command=awk '/eventId: eventA2/{p=5}p-->0'|head -3|tail -n 1|awk '{print $2}'
#     ...    target=${target1}    filter=${filter20}    check=rsrp
#     Check wireshark log data    command=grep SRBID:|tr -cd "[0-9]"    target=${target1}    filter=${filter20}    check=3
#     check BTS DL throughput    CELL1=16385    CELL2=16387
#     check BTS UL throughput    CELL1=16385    CELL2=16387
#
#     log to console    start check counter...sleep 5min
#     Waiting time for new counter file generated period CU    reporting_interval=${5}
#     ${55157_counter_file_list}    Collect PM Counter logs from CU    counter_group=55157
#     ${counter_value}    pmcounters_parse.get_counter_value    xml_file_name=${55157_counter_file_list[0]}    counter_id=M55157C00002
#     should be equal as integers    ${counter_value[0]}    ${1}
#     should be equal as integers    ${counter_value[2]}    ${1}
#
#     run keyword if    '${version}'=='0000'    Check wireshark data not be empty    target=${target13}
#     ...    filter=${filter26}    check=SgNBModificationRequired
#     run keyword if    '${version}'=='0000'    Check wireshark data not be empty    target=${target13}
#     ...    filter=${filter27}    check=SgNBModificationConfirm
#
#     [Teardown]    CI_interface.Common Case Teardown
#
# [1]5GC000710_A_011_Successful_intra_gNB_Inter-DU_PSCell_change_with_inter-frequency_A5_without_SRB3
#     [Documentation]    Successful intra gNB Inter-DU PSCell change with inter-frequency A5 without SRB3
#     [Tags]    CRT_21B    CRT_TRUNK    CRT_22R2
#     [Setup]
#     ${version}    Case preparation    DU_CURDIR_path=${CURDIR_path1}    CU_CURDIR_path=${CURDIR_path4}    flag=011
#     ...    DU_CURDIR_path_21B=${CURDIR_path6}    CU_CURDIR_path_21B=${CURDIR_path9}
#     ...    PARAMS_TO_MODIFY_DomainNumber=${PARAMS_TO_MODIFY_DomainNumber10}
#     Set test variable    ${LOG_PATH}    ${TS_CASE_LOG_PATH}
#     CU Delta Commission update    parameters=${CU_parameter_011_1}
#     Modify Common parameter via Coam    input_list=${DU_011_parameter_1}    bts_ip=${DU_OAM_IP_TL}
#     Modify Common parameter via Coam    input_list=${DU_011_parameter_2}    bts_ip=${DU_OAM_IP_TL}
#     Modify Common parameter via Coam    input_list=${DU_001_parameter_1}    bts_ip=${DU_OAM_IP_TL_2}
#     Modify Common parameter via Coam    input_list=${DU_001_parameter_2}    bts_ip=${DU_OAM_IP_TL_2}
#     Modify Common parameter via Coam    input_list=${DU_011_parameter_3}    bts_ip=${DU_OAM_IP_TL}
#     log to console    Precondition for attach...
#     Precondition for attach with retry    e500_script_path=${E500_SCRIPTS_BASE3}
#     Attach and trigger meas Report    report_type=011    E500_SCRIPTS_BASE=${E500_SCRIPTS_BASE3}
#
#     Check wireshark log data    command=grep SubscriberProfileIDforRFP:|tail -n 1|tr -cd "[0-9]"
#     ...    target=${target9}    filter=${filter10}    check=${12}
#     Check wireshark log data    command=awk '/spCellConfigCommon/{p=5}p-->0'|head -2|tail -n 1|tr -cd "[0-9]"
#     ...    target=${target}    filter=${filter}    check=${416}
#     Check wireshark log data    command=awk '/eventId: eventA2/{p=5}p-->0'|head -3|tail -n 1|awk '{print $2}'
#     ...    target=${target}    filter=${filter}    check=rsrp
#     Check wireshark log data    command=awk '/spCellConfigCommon/{p=5}p-->0'|head -5|tail -n 1|tr -cd "[0-9]"
#     ...    target=${target}    filter=${filter}    check=${2073115}
#
#     ${Meas1}    013_Get and Check measID    target=${target2}    filter=${filter22}
#     013_Check Attach Reconfiguration event and SSBFRE    MeasID=${Meas1}
#     013_Check SgNBMOD RRC Reconfiguration    filter=${filter16}    SSBFRE=2073691    event=eventA5    check=rsrp
#     Check wireshark log data    command=grep eventA1|head -2|tail -n 1
#     ...    target=${target12}    filter=${filter16}    check=eventA1
#     013_Check gapoffset    offset_data=${12}    filter=${filter16}
#
#     ${Meas2}    013_Get and Check measID    target=${target11}    filter=${filter24}
#     010_Check event SgNBMOD RRC Reconfiguration    MeasID=${Meas2}    target=${target11}    filter=${filter16}    event=eventA5
#     ${CELL_ID1}    Check log cell ID    target=${target}    filter=${filter}
#     ${CELL_ID2}    Check log cell ID    target=${target1}    filter=${filter25}
#     should not be equal as numbers       ${CELL_ID1}    ${CELL_ID2}
#     Check wireshark log data    command=awk '/eventId: eventA2/{p=5}p-->0'|head -3|tail -n 1|awk '{print $2}'
#     ...    target=${target1}    filter=${filter25}    check=rsrp
#     check BTS DL throughput    CELL1=16386    CELL2=16387
#     check BTS UL throughput    CELL1=16386    CELL2=16387
#
#     log to console    start check counter...sleep 5min
#     Waiting time for new counter file generated period CU    reporting_interval=${5}
#     ${55157_counter_file_list}    Collect PM Counter logs from CU    counter_group=55157
#     ${counter_value}    pmcounters_parse.get_counter_value    xml_file_name=${55157_counter_file_list[0]}    counter_id=M55157C00002
#     should be equal as integers    ${counter_value[1]}    ${1}
#     should be equal as integers    ${counter_value[2]}    ${1}
#
#     [Teardown]    CI_interface.Common Case Teardown
#
# [1]5GC000710_A_014_online_deletion_of_mobility_profile_between_A2_configuration_and_A2_Report
#     [Documentation]     online deletion of mobility profile between A2 configuration and A2 Report
#     [Tags]    CRT_21B    CRT_TRUNK    CRT_22R2
#     [Setup]
#     ${version}    Case preparation    DU_CURDIR_path=${CURDIR_path1}    CU_CURDIR_path=${CURDIR_path3}
#     ...    DU_CURDIR_path_21B=${CURDIR_path6}    CU_CURDIR_path_21B=${CURDIR_path8}
#     Set test variable    ${LOG_PATH}    ${TS_CASE_LOG_PATH}
#     CU Delta Commission update    parameters=${CU_parameter_014_1}
#     Modify Common parameter via Coam    input_list=${DU_013_parameter_1}    bts_ip=${DU_OAM_IP_TL_2}
#     Modify Common parameter via Coam    input_list=${DU_013_parameter_2}    bts_ip=${DU_OAM_IP_TL_2}
#     Modify Common parameter via Coam    input_list=${DU_013_parameter_3}    bts_ip=${DU_OAM_IP_TL_2}
#     log to console    Precondition for attach...
#     Precondition for attach with retry
#     Attach and trigger meas Report    report_type=014
#
#     Check wireshark log data    command=grep SubscriberProfileIDforRFP:|tail -n 1|tr -cd "[0-9]"
#     ...    target=${target9}    filter=${filter10}    check=${12}
#     Check wireshark log data    command=awk '/spCellConfigCommon/{p=5}p-->0'|head -2|tail -n 1|tr -cd "[0-9]"
#     ...    target=${target}    filter=${filter}    check=${414}
#     Check wireshark log data    command=awk '/eventId: eventA2/{p=5}p-->0'|head -3|tail -n 1|awk '{print $2}'
#     ...    target=${target10}    filter=${filter11}    check=rsrp
#     Check wireshark log data    command=awk '/eventId: eventA2/{p=5}p-->0'|head -3|tail -n 1|awk '{print $2}'
#     ...    target=${target}    filter=${filter}    check=rsrp
#
#     ${Meas1}    013_Get and Check measID    target=${target2}    filter=${filter5}
#     013_Check Attach Reconfiguration event and SSBFRE    MeasID=${Meas1}
#     Check wireshark log data    command=grep measIdToAddModList:|tr -cd "[0-9]"    target=${target12}    filter=${filter16}    check=2
#     013_Check SgNBMOD RRC Reconfiguration    event=eventA3    filter=${filter16}
#     Check wireshark log data    command=awk '/eventId: eventA1/{p=5}p-->0'|head -3|tail -n 1|awk '{print $2}'
#     ...    target=${target12}    filter=${filter16}    check=rsrp
#     013_Check gapoffset    filter=${filter16}    offset_data=${12}
#
#     ${ConfigId}    Check and Return log data    command=awk '/measIdToAddModList:/{p=11}p-->0'|tail -n 1|awk '{print $2}'
#     ...    target=${target12}    filter=${filter16}
#     Check wireshark log data    command=awk '/reportConfigId: ${ConfigId}/{p=8}p-->0'|head -6|tail -n 1|awk '{print $2}'
#     ...    target=${target12}    filter=${filter16}    check=eventA3
#
#     ${measObjectId}    Check and Return log data    command=awk '/measIdToAddModList:/{p=10}p-->0'|tail -n 1|awk '{print $2}'
#     ...    target=${target12}    filter=${filter16}
#     Check wireshark log data    command=awk '/measObjectId: ${measObjectId}/{p=8}p-->0'|head -4|tail -n 1|tr -cd "[0-9]"
#     ...    target=${target12}    filter=${filter16}    check=2073691
#
#     ${ConfigId}    Check and Return log data    command=awk '/measIdToAddModList:/{p=6}p-->0'|tail -n 1|awk '{print $2}'
#     ...    target=${target12}    filter=${filter16}
#     Check wireshark log data    command=awk '/reportConfigId: ${ConfigId}/{p=8}p-->0'|head -6|tail -n 1|awk '{print $2}'
#     ...    target=${target12}    filter=${filter16}    check=eventA1
#
#     log to console    start check counter...sleep 5min
#     Waiting time for new counter file generated period CU    reporting_interval=${5}
#     ${55157_counter_file_list}    Collect PM Counter logs from CU    counter_group=55157
#     ${counter_value}    pmcounters_parse.get_counter_value    xml_file_name=${55157_counter_file_list[0]}    counter_id=M55157C00002
#     should be equal as integers    ${counter_value[0]}    ${1}
#
#     [Teardown]    CI_interface.Common Case Teardown
#
# *** Keywords ***
# Check and Return log data
#     [Arguments]    ${command}    ${source}=${source}    ${target}=${target9}    ${filter}=${filter10}    ${check}=${12}
#     csn.Connect to     hostname=${test_ute}   username=${ute_name}    password=${test_password}  alias=${connection}
#     sleep    1s
#     Convert pcap to text    source=${source}    target=${target}    connection=${connection}    filter=${filter}
#     csn.Send Command  command=cat ${target} |${command}    connection=${connection}
#     ${data}    csn.Read Output    connection=${connection}
#     ${data}    strip_string    ${data}
#     [Return]    ${data}
#     [Teardown]    csn.Disconnect	connection=${connection}
#
# Check wireshark log data
#     [Arguments]    ${command}    ${source}=${source}    ${target}=${target9}    ${filter}=${filter10}    ${check}=${12}
#     csn.Connect to     hostname=${test_ute}   username=${ute_name}    password=${test_password}  alias=${connection}
#     sleep    1s
#     Convert pcap to text    source=${source}    target=${target}    connection=${connection}    filter=${filter}
#     csn.Send Command  command=cat ${target} |${command}    connection=${connection}
#     ${data}    csn.Read Output    connection=${connection}
#     ${data}    strip_string    ${data}
#     should be equal as strings    ${data}    ${check}
#     log to console    data:${data}
#     [Teardown]    csn.Disconnect	connection=${connection}
#
# Check wireshark data not be empty
#     [Arguments]    ${check}    ${source}=${source}    ${target}=${target9}    ${filter}=${filter10}
#     csn.Connect to     hostname=${test_ute}   username=${ute_name}    password=${test_password}  alias=${connection}
#     sleep    1s
#     Convert pcap to text    source=${source}    target=${target}    connection=${connection}    filter=${filter}
#     csn.Send Command    command=cat ${target}    connection=${connection}
#     ${data}    csn.Read Output    connection=${connection}
#     ${data}    strip_string    ${data}
#     should not be empty    ${data}
#     log to console    ${check} data exist!
#     [Teardown]    csn.Disconnect	connection=${connection}
#
# 013_Get and Check measID
#     [Arguments]    ${source}=${source}    ${CELL}=${414}    ${target}=${target2}    ${filter}=${filter2}
#     csn.Connect to    hostname=${test_ute}   username=${ute_name}    password=${test_password}  alias=${connection}
#     sleep    1s
#     Convert pcap to text    source=${source}    target=${target}    connection=${connection}    filter=${filter}
#     csn.Send Command  command=cat ${target}|grep measId:|tr -cd "[0-9]"
#     ...    connection=${connection}
#     ${Meas1}    csn.Read Output    connection=${connection}
#     ${Meas1}    strip_string    ${Meas1}
#     should not be empty    ${Meas1}
#     log to console    MeasID:${Meas1}
#     [Return]    ${Meas1}
#     [Teardown]    csn.Disconnect	connection=${connection}
#
# 013_Check Attach Reconfiguration event and SSBFRE
#     [Arguments]    ${MeasID}    ${event}=eventA2    ${check}=rsrp    ${SSBFRE}=2073115    ${target}=${target}
#     csn.Connect to     hostname=${test_ute}   username=${ute_name}    password=${test_password}  alias=${connection}
#     sleep    1s
#     csn.Send Command  command=cat ${target}|awk '/measId: ${MeasID}/{p=5}p-->0'|head -3|tail -n 1|tr -cd "[0-9]"
#     ...    connection=${connection}
#     ${reportConfigId}    csn.Read Output    connection=${connection}
#     ${reportConfigId}    strip_string    ${reportConfigId}
#     csn.Send Command  command=cat ${target}|awk '/reportConfigId: ${reportConfigId}/{p=8}p-->0'|head -7|tail -n 1
#     ...    connection=${connection}
#     ${event1}    csn.Read Output    connection=${connection}
#     ${event1}    strip_string    ${event1}
#     should be equal as strings    ${event1}     ${event}
#     log to console    event:${event1}
#
#     csn.Send Command  command=cat ${target}|awk '/reportConfigId: ${reportConfigId}/{p=8}p-->0'|head -8|tail -n 1|awk '{print $2}'
#     ...    connection=${connection}
#     ${check1}    csn.Read Output    connection=${connection}
#     ${check1}    strip_string    ${check1}
#     should be equal as strings    ${check1}    ${check}
#     log to console    data:${check1}
#
#     csn.Send Command  command=cat ${target}|awk '/measId:/{p=5}p-->0'|head -2|tail -n 1|tr -cd "[0-9]"
#     ...    connection=${connection}
#     ${measObjectId}    csn.Read Output    connection=${connection}
#     ${measObjectId}    strip_string    ${measObjectId}
#     csn.Send Command  command=cat ${target}|awk '/measObjectId: ${measObjectId}/{p=8}p-->0'|head -4|tail -n 1|tr -cd "[0-9]"
#     ...    connection=${connection}
#     ${SSB}    csn.Read Output    connection=${connection}
#     ${SSB}    strip_string    ${SSB}
#     should be equal as strings    ${SSB}     ${SSBFRE}
#     log to console    SSBRF:${SSB}
#
#     [Teardown]    csn.Disconnect	connection=${connection}
#
# 013_Check SgNBMOD RRC Reconfiguration
#     [Arguments]    ${source}=${source}    ${target}=${target12}    ${filter}=${filter16}    ${check}=rsrp
#     ...    ${SSBFRE}=2073691    ${event}=eventA5    ${flag}=NULL
#     csn.Connect to     hostname=${test_ute}   username=${ute_name}    password=${test_password}  alias=${connection}
#     sleep    1s
#     Convert pcap to text    source=${source}    target=${target}    connection=${connection}    filter=${filter}
#     csn.Send Command  command=cat ${target}|grep -B5 ${SSBFRE}|tail -n 4|head -1|tr -cd "[0-9]"
#     ...    connection=${connection}
#     ${ObjectId}    csn.Read Output    connection=${connection}
#     ${ObjectId}    strip_string    ${ObjectId}
#
#     csn.Send Command  command=cat ${target}|awk '/measObjectId: ${ObjectId}/{p=2}p-->0'|tail -n 1|tr -cd "[0-9]"
#     ...    connection=${connection}
#     ${ConfigId}    csn.Read Output    connection=${connection}
#     ${ConfigId}    strip_string    ${ConfigId}
#
#     csn.Send Command  command=cat ${target}|awk '/reportConfigId: ${ConfigId}/{p=8}p-->0'|head -6|tail -n 1|awk '{print $2}'
#     ...    connection=${connection}
#     ${event1}    csn.Read Output    connection=${connection}
#     ${event1}    strip_string    ${event1}
#     should be equal as strings    ${event1}    ${event}
#     log to console    event:${event1}
#
#     csn.Send Command  command=cat ${target}|awk '/reportConfigId: ${ConfigId}/{p=8}p-->0'|head -8|tail -n 1|awk '{print $2}'
#     ...    connection=${connection}
#     ${check1}    csn.Read Output    connection=${connection}
#     ${check1}    strip_string    ${check1}
#     should be equal as strings    ${check1}    ${check}
#     log to console    A5 data:${check1}
#     [Teardown]    csn.Disconnect	connection=${connection}
#
# 013_Check gapoffset
#     [Arguments]    ${offset_data}    ${source}=${source}    ${target}=${target12}    ${filter}=${filter12}
#     csn.Connect to     hostname=${test_ute}   username=${ute_name}    password=${test_password}  alias=${connection}
#     sleep    1s
#     csn.Send Command  command=cat ${target}|grep gapOffset:|tr -cd "[0-9]"    connection=${connection}
#     ${offset}    csn.Read Output    connection=${connection}
#     ${offset}    strip_string    ${offset}
#     should be equal as Numbers    ${offset}    ${offset_data}
#     log to console    offset_data:${offset}
#     [Teardown]    csn.Disconnect	connection=${connection}
#
# 007_Check eventA2 empty
#     [Arguments]    ${source}=${source}    ${target}=${target12}    ${filter}=${filter12}
#     csn.Connect to     hostname=${test_ute}   username=${ute_name}    password=${test_password}  alias=${connection}
#     sleep    1s
#     csn.Send Command  command=cat ${target}|grep eventA2    connection=${connection}
#     ${evnet}    csn.Read Output    connection=${connection}
#     should be empty    ${evnet}
#     log to console    evnetA2 didn't exist
#     [Teardown]    csn.Disconnect	connection=${connection}
#
# 010_Check event SgNBMOD RRC Reconfiguration
#     [Arguments]    ${MeasID}    ${source}=${source}    ${target}=${target12}    ${filter}=${filter16}    ${event}=eventA1
#     csn.Connect to     hostname=${test_ute}   username=${ute_name}    password=${test_password}  alias=${connection}
#     sleep    1s
#     Convert pcap to text    source=${source}    target=${target}    connection=${connection}    filter=${filter}
#     csn.Send Command  command=cat ${target}|awk '/measId: ${MeasID}/{p=5}p-->0'|head -3|tail -n 1|tr -cd "[0-9]"
#     ...    connection=${connection}
#     ${reportConfigId}    csn.Read Output    connection=${connection}
#     ${reportConfigId}    strip_string    ${reportConfigId}
#     csn.Send Command  command=cat ${target}|awk '/reportConfigId: ${reportConfigId}/{p=8}p-->0'|head -7|tail -n 1
#     ...    connection=${connection}
#     ${event1}    csn.Read Output    connection=${connection}
#     ${event1}    strip_string    ${event1}
#     should be equal as strings    ${event1}     ${event}
#     log to console    event:${event1}
#     [Teardown]    csn.Disconnect	connection=${connection}
#
# 010_Check A1 and A3 release
#     [Arguments]    ${source}=${source}    ${target}=${target12}    ${filter}=${filter17}    ${event}=eventA1    ${check}=release
#     csn.Connect to     hostname=${test_ute}   username=${ute_name}    password=${test_password}  alias=${connection}
#     sleep    1s
#     Convert pcap to text    source=${source}    target=${target}    connection=${connection}    filter=${filter}
#     csn.Send Command  command=cat ${target}|grep eventA1    connection=${connection}
#     ${eventA1}    csn.Read Output    connection=${connection}
#     should be empty    ${eventA1}
#
#     csn.Send Command  command=cat ${target}|grep eventA3    connection=${connection}
#     ${eventA3}    csn.Read Output    connection=${connection}
#     should be empty    ${eventA3}
#
#     csn.Send Command  command=cat ${target}|grep gapFR2:|awk '{print $2}'    connection=${connection}
#     ${release}    csn.Read Output    connection=${connection}
#     ${release}    strip_string    ${release}
#     should be equal as strings    ${release}    ${check}
#     [Teardown]    csn.Disconnect	connection=${connection}
#
# 001_Check switch cellID
#     [Arguments]    ${source}=${source}    ${target}=${target5}    ${filter}=${filter17}
#     csn.Connect to     hostname=${test_ute}   username=${ute_name}    password=${test_password}  alias=${connection}
#     sleep    1s
#     Convert pcap to text    source=${source}    target=${target}    connection=${connection}    filter=${filter}
#     csn.Send Command  command=cat ${target} |grep physCellId |head -2 |tail -n 1 |tr -cd "[0-9]"
#     ...    connection=${connection}
#     ${CELL_ID}  csn.Read Output    connection=${connection}
#     ${CELL_ID}  strip_string    ${CELL_ID}
#     log to console  physCellId=${CELL_ID}
#
# Attach and trigger meas Report
#     [Arguments]    ${cpif_log_name}=${cpif_log_name}    ${log_path}=${TS_CASE_LOG_PATH}    ${report_type}=NULL
#     ...    ${E500_SCRIPTS_BASE}=${E500_SCRIPTS_BASE1}    ${is_srb3}=${False}
#     Run    rm ${output_dir}/*.pcap && rm ${output_dir}/*.txt && rm ${output_dir}/syslog_.log
#     run keyword if    ${is_srb3}    ENABLE SRB3 on gNB    ELSE    DISABLE SRB3 on gNB
#     wait counter period CU time    reporting_interval=5
#     Start tcpdump log on CU    tcpdump_collector_name=${cpif_log_name}_f1    options=-i fronthaul    vm_name=cpif-0.local
#     Start tcpdump log on CU    tcpdump_collector_name=${cpif_log_name}_x2    options=-i x2    vm_name=cpif-0.local
#
# #    Connect to gnb coam via ssl    bts_host=${DU_OAM_IP_TL}    username=${DU_OAM_WEBUI_USER}   password=${DU_OAM_WEBUI_PASSWORD}
#     log to console    start attach...
#     ${attach_time}    Cobham retry ue attach if failed    e500_script_path=${E500_SCRIPTS_BASE}
#     Set Test Variable    ${attach_time}
#     log to console    ue attach successful,sleep:2s
#     sleep    2s
#     run keyword if    '${report_type}'=='001' or '${report_type}'=='011'    Iperf send UL traffic VIAVI    throughput=${100}
#     ...    traffic_time=${120}    ul_host_ip=${tl.ues[0].iperf_details.ssh_connection_details.addr}    port=${ul_port}
#     run keyword if    '${report_type}'=='001' or '${report_type}'=='011'    Iperf send DL traffic with real epc    throughput=${100}
#     ...    traffic_time=${120}    port=${dl_port}
#     sleep    3s
#     run keyword if    '${report_type}'=='013'    CU Delta Commission update    parameters=${CU_parameter_013_2}
#     log to console    start syslog...
#     ${list}    Create list     ${port1}    ${port2}
#     run keyword if    '${report_type}'=='001' or '${report_type}'=='011'    ute_syslog.Start Syslog    log_dir=${OUTPUT_DIR}
#     ...    log_name=syslog_.log    host_ip=${TEST_PC_IP}    ssh_username=${TEST_PC_USERNAME}
#     ...    ssh_password=${TEST_PC_PASSWORD}    ports=${list}    alias=${connection}
#
#     sleep    5s
#     run keyword if    '${report_type}'=='013'    013_1_Trigger A2 measurement report
#     run keyword if    '${report_type}'=='013'    013_2_Trigger A2 measurement report
#     run keyword if    '${report_type}'=='010'    010_1_Trigger A2 measurement report
#     run keyword if    '${report_type}'=='010'    010_2_Trigger A1 measurement report
#     run keyword if    '${report_type}'=='010'    010_3_Trigger A1 measurement report
#     run keyword if    '${report_type}'=='001'    001_1_Trigger A2 measurement report
#     run keyword if    '${report_type}'=='001'    001_2_Trigger A3 measurement report
#     run keyword if    '${report_type}'=='011'    011_1_Trigger A2 measurement report
#     run keyword if    '${report_type}'=='011'    011_2_Trigger A5 measurement report
#     run keyword if    '${report_type}'=='014'    CU Delta Commission Delete MO    parameters=${CU_parameter_014_2}
#     sleep    2s
#     run keyword if    '${report_type}'=='014'    013_1_Trigger A2 measurement report
#     sleep    5s
#     [Teardown]    Stop tcpdump log    report_type=${report_type}
#
# Stop tcpdump log
#     [Arguments]    ${report_type}    ${cpif_log_name}=${cpif_log_name}    ${ppb_value}=20    ${ns_value_scope}=0.5    ${is_srb3}=${False}
#     log to console    End btslog
#     run keyword if    '${report_type}'=='001' or '${report_type}'=='011'    Stop syslog    alias=${connection}
#     Stop tcpdump on CPIF and rename downloaded file    cpif_log_name=${cpif_log_name}_f1
#     Stop tcpdump on CPIF and rename downloaded file    cpif_log_name=${cpif_log_name}_x2
#     Run Keyword And Ignore Error    Iperf stop traffic from appserver and ue side    port=${dl_port}
#     Cobham UE detach
#     ${merged_log_path}    set variable    ${log_path}/${cpif_log_name}.pcap
#     run    mergecap -w ${merged_log_path} ${log_path}/Ori_${cpif_log_name}_x2.pcap ${log_path}/Ori_${cpif_log_name}_f1.pcap
#     run keyword if    ${is_srb3}    ENABLE SRB3 on gNB    ELSE    DISABLE SRB3 on gNB
#     [Teardown]    #Run Keyword And Ignore Error    coam.teardown    connection=${connection}
#
# Case preparation
#     [Arguments]    ${DU_CURDIR_path}    ${CU_CURDIR_path}
#     ...    ${DU_CURDIR_path_21B}    ${CU_CURDIR_path_21B}
#     ...    ${DU_CURDIR_path2}=${CURDIR_path5}    ${DU_CURDIR_path2_21B}=${CURDIR_path10}    ${flag}=NULL
#     ...    ${PARAMS_TO_MODIFY_DomainNumber}=${PARAMS_TO_MODIFY_DomainNumber0}
#
# #    ${connection}    coam.connect_to    bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}     name=GNB_OAM
#     Connect to gnb coam via ssl    bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}    connection=GNB_OAM
#     ${connection}    set variable    GNB_OAM
#     ${version}    coam.get_sw_version    connection=${connection}
#     ${version_list}    split string    ${version}    _
#
#     run keyword if    '${version_list[2]}'=='0014'    load scf activation    path1=${DU_CURDIR_path}
#     ...    path2=${DU_CURDIR_path2}    path3=${CU_CURDIR_path}    flag=${flag}
#     run keyword if    '${version_list[2]}'=='0012'    load scf activation    path1=${DU_CURDIR_path_21B}
#     ...    path2=${DU_CURDIR_path2_21B}    path3=${CU_CURDIR_path_21B}    flag=${flag}
#
#     COAM GNB Wait CU and DU cells are on air status    timeout=15min
#     Modify Common parameter via Coam    input_list=${PARAMS_TO_MODIFY_DomainNumber}    bts_ip=${ENB_IP}
#     Modify Common parameter via Coam    input_list=${PARAMS_TO_MODIFY_DomainNumber9}    bts_ip=${ENB_IP}
#
#     run keyword if    '${flag}'=='011'    Modify Value On DU     gNB_ip=${DU_OAM_IP_TL}
#     ...    structure_modify_list=${PARAMS_TO_MODIFY_DomainNumber1}    class_name=TRBLCADM_A    keywords_list=${keywords_list1}
#     run keyword if    '${flag}'=='001' or '${flag}'=='011'    Modify Value On DU     gNB_ip=${DU_OAM_IP_TL_2}
#     ...    structure_modify_list=${PARAMS_TO_MODIFY_DomainNumber2}    class_name=TRBLCADM_A    keywords_list=${keywords_list1}
#     run keyword if    '${flag}'=='001' or '${flag}'=='011'    Modify Value On DU     gNB_ip=${DU_OAM_IP_TL_2}
#     ...    structure_modify_list=${PARAMS_TO_MODIFY_DomainNumber7}    class_name=TRBLCADM_A    keywords_list=${keywords_list1}
#     run keyword if    '${flag}'=='011'    Modify Value On DU     gNB_ip=${DU_OAM_IP_TL}
#     ...    structure_modify_list=${PARAMS_TO_MODIFY_DomainNumber8}    class_name=TRBLCADM_A    keywords_list=${keywords_list1}
#     [Return]    ${version_list[2]}
#     [Teardown]    Run Keyword And Ignore Error    coam.teardown    connection=${connection}
#
# load scf activation
#     [Arguments]   ${path1}    ${path2}    ${path3}    ${flag}
#     Setup Commission SCF    bts_host=${tl.gnbs[0].dus[1].f1_m_ip_addr}    CURDIR_path=${path1}
#     run keyword if    '${flag}'=='011'    Setup Commission SCF    bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}    CURDIR_path=${path2}
#     CU Full Commission    path_of_commission_file=${path3}
#     log to console    ${path1} || ${path2} || ${path3} || ${flag}
#
# check BTS DL throughput
#     [Arguments]   ${flag1}=100    ${flag2}=100    ${CELL1}=16385    ${CELL2}=16386
#     log to console    Check DL throughput
#     csn.Connect to     hostname=${test_ute}   username=${ute_name}    password=${test_password}  alias=${connection}
#     csn.Send Command    command=cat ${target8}|grep DataPdu|grep ${CELL1}|cut -d ':' -f 10|cut -d '|' -f 1
#     ...    connection=${connection}
#     ${cell_TP1}    csn.Read Output    connection=${connection}
#     log to console    ${cell_TP1}
#     csn.Send Command    command=cat ${target8}|grep DataPdu|grep ${CELL2}|cut -d ':' -f 10|cut -d '|' -f 1
#     ...    connection=${connection}
#     ${cell_TP2}    csn.Read Output    connection=${connection}
#     log to console    ${cell_TP2}
#
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
#         run keyword if    ${TP2}==${0}     should be true    ${TP1}>${4000}
#         run keyword if    ${TP2}>${4000}     Set test variable    ${flag2}    ${NUM}
#         should be true    ${flag2}>${flag1}
#     END
#     should not be equal as numbers    ${flag1}    100
#     should not be equal as numbers    ${flag2}    100
#     log to console    Check DL throughput successful
#     [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}
#
# check BTS UL throughput
#     [Arguments]   ${CELL1}    ${CELL2}    ${flag3}=100    ${flag4}=100
#     log to console    Check UL throughput
#     csn.Connect to     hostname=${test_ute}   username=${ute_name}    password=${test_password}  alias=${connection}
#     csn.Send Command    command=cat ${target8}|grep UlCounterUp|grep ${CELL1}|awk '{print $17}'
#     ...    connection=${connection}
#     ${cell1_TP}    csn.Read Output    connection=${connection}
#     log to console    cell1_TP
#     csn.Send Command    command=cat ${target8}|grep UlCounterUp|grep ${CELL2}|awk '{print $17}'
#     ...    connection=${connection}
#     ${cell2_TP}    csn.Read Output    connection=${connection}
#     log to console    cell2_TP
#
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
#         run keyword if    ${TP2}==${0}    should be true    ${TP1}>${4000}
#         run keyword if    ${TP2}>${4000}     Set test variable    ${flag4}    ${NUM}
#         should be true    ${flag4}>${flag3}
#     END
#     should not be equal as numbers    ${flag3}    100
#     should not be equal as numbers    ${flag4}    100
#     log to console    Check UL throughput successful
#     [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}
#
# 013_1_Trigger A2 measurement report
#     [Arguments]    ${a2_meas_id}=1    ${report_interval}=0    ${serving_cell_pci}=414    ${serving_cell_rsrp}=75
#     ...    ${serving_cell_rsrq}=61    ${serving_cell_sinr}=35    ${neigh_cell_pci}=416    ${neigh_cell_rsrp}=66    ${neigh_cell_rsrq}=57
#     ...    ${neigh_cell_sinr}=44    ${tm500_alias}=e500
#     log to console  Start to trigger A2 measurement report
#     ${cmd_a3_mr}    catenate
#     ...    forw mte NrRrcAptTriggerMeasReport ${a2_meas_id} 0 0 ${report_interval} 1
#     ...    {8 [${serving_cell_pci}] [[${serving_cell_rsrp}] [${serving_cell_rsrq}] [${serving_cell_sinr}]] [] [[1{0[[75] [61] []]}] []] [] []}
#     ...    [0(1{[${neigh_cell_pci}] [[${neigh_cell_rsrp}] [${neigh_cell_rsrq}] [${neigh_cell_sinr}]] [][ [1{0[[66] [] []]}] [] ] })]
#     ${response}    tm500_remote.send_command    command=${cmd_a3_mr}    alias=${tm500_alias}
#     ${response}    tm500_remote.send_command    command=forw mte Activate -1    alias=${tm500_alias}
#     sleep    5s
#
# 013_2_Trigger A2 measurement report
#     [Arguments]    ${a2_meas_id}=1    ${report_interval}=0    ${serving_cell_pci}=414    ${serving_cell_rsrp}=75
#     ...    ${serving_cell_rsrq}=53    ${serving_cell_sinr}=35    ${neigh_cell_pci}=416    ${neigh_cell_rsrp}=66    ${neigh_cell_rsrq}=57
#     ...    ${neigh_cell_sinr}=44    ${tm500_alias}=e500
#     log to console  Start to trigger A2 measurement report
#     ${cmd_a3_mr}    catenate
#     ...    forw mte NrRrcAptTriggerMeasReport ${a2_meas_id} 0 0 ${report_interval} 1
#     ...    {8 [${serving_cell_pci}] [[${serving_cell_rsrp}] [${serving_cell_rsrq}] [${serving_cell_sinr}]] [] [[1{0[[75] [53] []]}] []] [] []}
#     ...    [0(1{[${neigh_cell_pci}] [[${neigh_cell_rsrp}] [${neigh_cell_rsrq}] [${neigh_cell_sinr}]] [][ [1{0[[66] [] []]}] [] ] })]
#     ${response}    tm500_remote.send_command    command=${cmd_a3_mr}    alias=${tm500_alias}
#     ${response}    tm500_remote.send_command    command=forw mte Activate -1    alias=${tm500_alias}
#     sleep    5s
#
# 010_1_Trigger A2 measurement report
#     [Arguments]    ${a2_meas_id}=1    ${report_interval}=0    ${serving_cell_pci}=414    ${serving_cell_rsrp}=75
#     ...    ${serving_cell_rsrq}=53    ${serving_cell_sinr}=35    ${neigh_cell_pci}=416    ${neigh_cell_rsrp}=66    ${neigh_cell_rsrq}=57
#     ...    ${neigh_cell_sinr}=44    ${tm500_alias}=e500
#     log to console  Start to trigger A2 measurement report
#     ${cmd_a3_mr}    catenate
#     ...    forw mte NrRrcAptTriggerMeasReport ${a2_meas_id} 0 0 ${report_interval} 1
#     ...    {8 [${serving_cell_pci}] [[${serving_cell_rsrp}] [${serving_cell_rsrq}] [${serving_cell_sinr}]] [] [[1{0[[75] [] []]}] []] [] []}
#     ...    [0(1{[${neigh_cell_pci}] [[${neigh_cell_rsrp}] [${neigh_cell_rsrq}] [${neigh_cell_sinr}]] [][ [1{0[[66] [] []]}] [] ] })]
#     ${response}    tm500_remote.send_command    command=${cmd_a3_mr}    alias=${tm500_alias}
#     ${response}    tm500_remote.send_command    command=forw mte Activate -1    alias=${tm500_alias}
#     sleep    5s
#
# 010_2_Trigger A1 measurement report
#     [Arguments]    ${a2_meas_id}=2    ${report_interval}=0    ${serving_cell_pci}=414    ${serving_cell_rsrp}=107
#     ...    ${serving_cell_rsrq}=53    ${serving_cell_sinr}=35    ${neigh_cell_pci}=415    ${neigh_cell_rsrp}=66    ${neigh_cell_rsrq}=57
#     ...    ${neigh_cell_sinr}=44    ${tm500_alias}=e500
#     log to console  Start to trigger A2 measurement report
#     ${cmd_a3_mr}    catenate
#     ...    forw mte NrRrcAptTriggerMeasReport ${a2_meas_id} 0 0 ${report_interval} 1
#     ...    {8 [${serving_cell_pci}] [[${serving_cell_rsrp}] [${serving_cell_rsrq}] [${serving_cell_sinr}]] [] [[1{0[[107] [53] []]}] []] [] []}
#     ...    [0(1{[${neigh_cell_pci}] [[${neigh_cell_rsrp}] [${neigh_cell_rsrq}] [${neigh_cell_sinr}]] [][ [1{0[[66] [] []]}] [] ] })]
#     ${response}    tm500_remote.send_command    command=${cmd_a3_mr}    alias=${tm500_alias}
#     ${response}    tm500_remote.send_command    command=forw mte Activate -1    alias=${tm500_alias}
#     sleep    5s
#
# 010_3_Trigger A1 measurement report
#     [Arguments]    ${a2_meas_id}=2    ${report_interval}=0    ${serving_cell_pci}=414    ${serving_cell_rsrp}=107
#     ...    ${serving_cell_rsrq}=71    ${serving_cell_sinr}=35    ${neigh_cell_pci}=415    ${neigh_cell_rsrp}=66    ${neigh_cell_rsrq}=57
#     ...    ${neigh_cell_sinr}=44    ${tm500_alias}=e500
#     log to console  Start to trigger A2 measurement report
#     ${cmd_a3_mr}    catenate
#     ...    forw mte NrRrcAptTriggerMeasReport ${a2_meas_id} 0 0 ${report_interval} 1
#     ...    {8 [${serving_cell_pci}] [[${serving_cell_rsrp}] [${serving_cell_rsrq}] [${serving_cell_sinr}]] [] [[1{0[[107] [71] []]}] []] [] []}
#     ...    [0(1{[${neigh_cell_pci}] [[${neigh_cell_rsrp}] [${neigh_cell_rsrq}] [${neigh_cell_sinr}]] [][ [1{0[[66] [] []]}] [] ] })]
#     ${response}    tm500_remote.send_command    command=${cmd_a3_mr}    alias=${tm500_alias}
#     ${response}    tm500_remote.send_command    command=forw mte Activate -1    alias=${tm500_alias}
#     sleep    5s
#
# 001_1_Trigger A2 measurement report
#     [Arguments]    ${a2_meas_id}=1    ${report_interval}=0    ${serving_cell_pci}=414    ${serving_cell_rsrp}=75
#     ...    ${serving_cell_rsrq}=53    ${serving_cell_sinr}=35    ${neigh_cell_pci}=416    ${neigh_cell_rsrp}=66    ${neigh_cell_rsrq}=57
#     ...    ${neigh_cell_sinr}=44    ${tm500_alias}=e500
#     log to console  Start to trigger A2 measurement report
#     ${cmd_a3_mr}    catenate
#     ...    forw mte NrRrcAptTriggerMeasReport ${a2_meas_id} 0 0 ${report_interval} 1
#     ...    {8 [${serving_cell_pci}] [[${serving_cell_rsrp}] [${serving_cell_rsrq}] [${serving_cell_sinr}]] [] [[1{0[[75] [] []]}] []] [] []}
#     ...    [0(1{[${neigh_cell_pci}] [[${neigh_cell_rsrp}] [${neigh_cell_rsrq}] [${neigh_cell_sinr}]] [][ [1{0[[66] [] []]}] [] ] })]
#     ${response}    tm500_remote.send_command    command=${cmd_a3_mr}    alias=${tm500_alias}
#     ${response}    tm500_remote.send_command    command=forw mte Activate -1    alias=${tm500_alias}
#     sleep    5s
#
# 001_2_Trigger A3 measurement report
#     [Arguments]    ${a2_meas_id}=3    ${report_interval}=4    ${serving_cell_pci}=414    ${serving_cell_rsrp}=50
#     ...    ${serving_cell_rsrq}=53    ${serving_cell_sinr}=35    ${neigh_cell_pci}=415    ${neigh_cell_rsrp}=71    ${neigh_cell_rsrq}=57
#     ...    ${neigh_cell_sinr}=44    ${tm500_alias}=e500
#     log to console  Start to trigger A2 measurement report
#     ${cmd_a3_mr}    catenate
#     ...    forw mte NrRrcAptTriggerMeasReport ${a2_meas_id} 0 0 ${report_interval} 1
#     ...    {0 [${serving_cell_pci}] [[${serving_cell_rsrp}] [${serving_cell_rsrq}] [${serving_cell_sinr}]] [] [[1{0[[50] [] []]}] []] [] []}
#     ...    [0(1{[${neigh_cell_pci}] [[${neigh_cell_rsrp}] [${neigh_cell_rsrq}] [${neigh_cell_sinr}]] [][ [1{0[[71] [] []]}] [] ] })]
#     ${response}    tm500_remote.send_command    command=${cmd_a3_mr}    alias=${tm500_alias}
#     ${response}    tm500_remote.send_command    command=forw mte Activate -1    alias=${tm500_alias}
#     sleep    5s
#     Wait until keyword succeeds    10s    200ms    match pattern in response    response=${response}
#     ...    e500_alias=${tm500_alias}    pattern=Random Access Complete
#
# 011_1_Trigger A2 measurement report
#     [Arguments]    ${a2_meas_id}=1    ${report_interval}=0    ${serving_cell_pci}=416    ${serving_cell_rsrp}=75
#     ...    ${serving_cell_rsrq}=53    ${serving_cell_sinr}=35    ${neigh_cell_pci}=415    ${neigh_cell_rsrp}=66    ${neigh_cell_rsrq}=57
#     ...    ${neigh_cell_sinr}=44    ${tm500_alias}=e500
#     log to console  Start to trigger A2 measurement report
#     ${cmd_a3_mr}    catenate
#     ...    forw mte NrRrcAptTriggerMeasReport ${a2_meas_id} 0 0 ${report_interval} 1
#     ...    {8 [${serving_cell_pci}] [[${serving_cell_rsrp}] [${serving_cell_rsrq}] [${serving_cell_sinr}]] [] [[1{0[[75] [] []]}] []] [] []}
#     ...    [0(1{[${neigh_cell_pci}] [[${neigh_cell_rsrp}] [${neigh_cell_rsrq}] [${neigh_cell_sinr}]] [][ [1{0[[66] [] []]}] [] ] })]
#     ${response}    tm500_remote.send_command    command=${cmd_a3_mr}    alias=${tm500_alias}
#     ${response}    tm500_remote.send_command    command=forw mte Activate -1    alias=${tm500_alias}
#     sleep    5s
#
# 011_2_Trigger A5 measurement report
#     [Arguments]    ${a2_meas_id}=4    ${report_interval}=0    ${serving_cell_pci}=416    ${serving_cell_rsrp}=55
#     ...    ${serving_cell_rsrq}=53    ${serving_cell_sinr}=35    ${neigh_cell_pci}=415    ${neigh_cell_rsrp}=76    ${neigh_cell_rsrq}=57
#     ...    ${neigh_cell_sinr}=44    ${tm500_alias}=e500
#     log to console  Start to trigger A2 measurement report
#     ${cmd_a3_mr}    catenate
#     ...    forw mte NrRrcAptTriggerMeasReport ${a2_meas_id} 0 0 ${report_interval} 1
#     ...    {8 [${serving_cell_pci}] [[${serving_cell_rsrp}] [${serving_cell_rsrq}] [${serving_cell_sinr}]] [] [[1{0[[55] [] []]}] []] [] []}
#     ...    [0(1{[${neigh_cell_pci}] [[${neigh_cell_rsrp}] [${neigh_cell_rsrq}] [${neigh_cell_sinr}]] [][ [1{4[[76] [57] []]}] [] ] })]
#     ${response}    tm500_remote.send_command    command=${cmd_a3_mr}    alias=${tm500_alias}
#     ${response}    tm500_remote.send_command    command=forw mte Activate -1    alias=${tm500_alias}
#     sleep    5s
#     Wait until keyword succeeds    10s    200ms    match pattern in response    response=${response}
#     ...    e500_alias=${tm500_alias}    pattern=Random Access Complete
#
# CU parameter update
#     [Arguments]    ${parameter1}    ${parameter2}
#     log to console    start modify cu parameter
#     CU Delta Commission update    parameters=${parameter1}
#     log to console    modify parameter...sleep 30s
#     sleep    30s
#     CU Delta Commission update    parameters=${parameter2}
#     [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}
#
# Modify Value On DU
#     [Arguments]    ${structure_modify_list}    ${gNB_ip}    ${common_modify_list}=None    ${keywords_list}=None    ${connection}=GNB_connection
#     ...    ${class_name}=None   ${is_structure}=${True}    ${is_common}=${True}    ${structure_index}=0
# #    coam.connect_to    bts_host=${gNB_ip}   name=${connection}
#     Connect to gnb coam via ssl    bts_host=${gNB_ip}    connection=${connection}
#     run keyword if  ${is_structure}    Modify Structure parameter via Coam    class_name=${class_name}   connection=${connection}
#     ...    modify_list=${structure_modify_list}    keywords_list=${keywords_list}    index=${structure_index}
#     log to console    change parameter successful,sleep 30s
#     [Teardown]    coam.teardown      connection=${connection}
#
# Modify Common parameter via Coam
#     [Arguments]  ${input_list}    ${bts_ip}    ${connection}=GNB_connection
#     log to console    Modify parameter
# #    coam.connect_to    bts_host=${bts_ip}   name=${connection}
#     Connect to gnb coam via ssl    bts_host=${bts_ip}    connection=${connection}
#     FOR    ${item}  IN    @{input_list}
#         ${dict_value}    Get Content From Input Dict    input_dict=${item}
#         coam.Perform Parameter Recommissioning    dist_name=@{dict_value}[0]   parameter=@{dict_value}[1]   value=@{dict_value}[2]
#         ...    operation=update    skip_parameter_relation_errors=${True}    should_activate=${True}    connection=${connection}
#     END
#     log to console  change parameter successful,sleep 30s
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
# Convert pcap to text
#     [Arguments]    ${source}    ${target}    ${connection}    ${filter}
#     ssh.send_command
#     ...  command=nice tshark -X lua_script:${luashark_path} -V -r ${source} -T text > ${target} -Y '${filter}'   connection=${connection}
#     ssh.await execution end  connection=${connection}  timeout=30min
#     sleep    5s
#
# Check log cell ID
#     [Arguments]    ${source}=${source}    ${target}=${target}    ${filter}=${filter}    ${connection}=TEST_PC
#     csn.Connect to     hostname=${test_ute}   username=${ute_name}    password=${test_password}  alias=${connection}
#     sleep    1s
#     Convert pcap to text    source=${source}    target=${target}    connection=${connection}    filter=${filter}
#     csn.Send Command  command=cat ${target}|awk '/spCellConfigCommon/{p=5}p-->0'|head -2|tail -n 1|tr -cd "[0-9]"
#     ...    connection=${connection}
#     ${CELL_ID}    csn.Read Output    connection=${connection}
#     ${CELL_ID}    strip_string    ${CELL_ID}
#     log to console  physCellId=${CELL_ID}
#     [Return]    ${CELL_ID}
#     [Teardown]    csn.Disconnect	connection=${connection}
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
# Iperf send UL traffic VIAVI
#     [Documentation]    Author: Ding Binmei
#     ...                Description: ul_host_ip will default to 192.168.10.70
#     ...                port=5410 is related with it used on cobham. Now dedicated to this value
#     [Arguments]    ${throughput}    ${traffic_time}    ${ul_host_ip}=192.168.10.70
#     ...    ${port}=${tl.ues[0].iperf_details.ssh_connection_details.port}
#     Log to console    Start UL traffic with real epc
#     wait until keyword succeeds    2 min    10 s    Connect to app server
#     ${is_iperf_process_started}    run keyword and return status  Check if iperf server process is started on app server    port=${port}
#     Run keyword if  ${is_iperf_process_started}==${False}
#     ...    Run keywords    Log to console    Iperf server is not started on app server, now started.    AND
#     ...                    Start iperf server    port=${port}    connection=APPserver    AND
#     ...                    Check if iperf server process is started on app server    port=${port}
#
#     wait until keyword succeeds    2 min    10 s    traffic_via_iperf.Connect to cobham control pc via ssh
#     enable PPPoE connection    TMA_SSH_ALIAS=${TMA_SSH_ALIAS}
#     ${cmd_start_iperf_client}    Catenate    iperf -u -c ${ul_host_ip} -b ${throughput}M -t ${traffic_time} -i 1 -p ${port}
#     csn.send command     command=${cmd_start_iperf_client}    connection=${TMA_SSH_ALIAS}
#     sleep    5s
#     Log to console    Start to send UL traffic with real epc on UE side, traffic time is ${traffic_time}
#     [Teardown]  Run keyword and ignore error    Run keywords    traffic_via_iperf.Disconnect from app server    AND
#     ...    traffic_via_iperf.Disconnect from cobham control pc via ssh
#
# enable PPPoE connection
#     [Documentation]    activates the PPPoE tunnel with E500 thanks to ssh opened connection.
#     ...                PPPoE tunnel is required to be able to launch DL iperf in reception on the Viavi PC
#     ...                the PPPoE configured name under the PC shall be TM500
#     ...                the alias of the ssh connection used is ViaviSshConnection from above Viavi PC connect keyword
#     ...                PPPoE set up action in script must be performed in background as the UE attach under TMA should
#     ...                be launch in // of the PPPoE set up
#     [Arguments]    ${TMA_SSH_ALIAS}
#     ssh.send command   rasdial TM500    connection=${TMA_SSH_ALIAS}
#     ${output}    ssh.read output    connection=${TMA_SSH_ALIAS}
#     Log to console    ${output}
#     should contain    ${output}    Command completed successfully
#
# wait counter period CU time
#     [Arguments]    ${reporting_interval}=5
#     CU SSH To OAM    alias=CU_VM
#     &{pre_case_time_info}    counter.calculate_waiting_time_for_log_capturing_or_log_generation
#     ...    reporting_interval=${reporting_interval}    asik_alias=CU_VM
#     log to console    ${pre_case_time_info['wait_time']}minute left
#     Sleep    ${pre_case_time_info['wait_time']} min
#     [Teardown]    Teardown SSH Connections    alias=CU_VM
