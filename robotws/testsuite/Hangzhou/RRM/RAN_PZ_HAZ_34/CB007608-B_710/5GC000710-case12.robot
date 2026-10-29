# *** Settings ***
# Force Tags    PY36
# Suite Setup    Common setup for 710
# Suite Teardown
# Documentation    Suite description
# ...   author: miao.1.lu@nokia-sbell.com
# ...   contact: miao.1.lu@nokia-sbell.com
#
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/container_log_capturing.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/viavi_common_keyword.robot
# Variables         ./Resources/paramter_modify.py
# Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource          ./Resources/5GC000710_common_keyword.robot
# Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/Analysis_Viavi_Log.py
# Library           Analysis_Viavi_Log.Viavi_Log_analysis     WITH NAME    Viavi_Log_analysis
# Library           taf.transport.ssh    WITH NAME    csn
# Library           taf.hw.rf_attenuator    WITH NAME    att
# Library           taf.ue  WITH NAME   ute_ue
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
#
#
# *** Variables ***
# ${CURDIR_path1_trunk}      ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/SCF_Trunk_gNB1.xml
# ${CURDIR_path2_trunk}      ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/SCF_Trunk_gNB2.xml
# ${CURDIR_path}             ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}
# ${CURDIR_path1}            ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/SCF_SBTS22R1_gNB1.xml
# ${CURDIR_path2}            ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/SCF_SBTS22R1_gNB2.xml
# ${E500_SCRIPTS_BASE}         ${CURDIR}/E500_scripts
# ${E500_SCRIPTS_BASE2}    ${CURDIR}/E500_scripts2
# ${DU_OAM_IP_URL}            https://${tl.gnbs[0].dus[0].f1_m_ip_addr}
# ${gNB_ip}                 ${tl.gnbs[0].dus[0].f1_m_ip_addr}
# ${gNB2_ip}                ${tl.gnbs[1].dus[0].f1_m_ip_addr}
# ${enb_ip}                 ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
# ${eNB_username}           ${tl.enbs[0].airscale.common_units[0].lmp_connection.username}
# ${eNB_password}           ${tl.enbs[0].airscale.common_units[0].lmp_connection.password}
# ${DU_OAM_WEBUI_USER}        ${tl.gnbs[0].cu.oam_http_connection_details.username}
# ${DU_OAM_WEBUI_PASSWORD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
# ${TEST_PC_IP}             ${tl.test_pc.default_ssh_connection_details.addr}
# ${TEST_PC_USERNAME}       ${tl.test_pc.default_ssh_connection_details.username}
# ${TEST_PC_PASSWORD}       ${tl.test_pc.default_ssh_connection_details.password}
# ${connection}                GNB_OAM
# ${luashark_path}             /opt/ute/luashark/luashark_script/generated_luashark
# ${LOG_PATH}                  ${OUTPUT_DIR}
# ${epc_log_path}              /tmp
# ${filter_001}                x2ap.procedureCode == 27 && x2ap.X2AP_PDU == 1
# ${filter_002}                x2ap.procedureCode == 27 && x2ap.X2AP_PDU == 0
# ${filter_005}                x2ap.procedureCode == 27 && x2ap.X2AP_PDU == 1 && nr-rrc.physCellId == 50
# ${filter_meas1}              nr-rrc.rsrp == 75 && x2ap.procedureCode == 35 && x2ap.X2AP_PDU == 0
# ${filter_meas3}              nr-rrc.rsrp == 54 && x2ap.procedureCode == 35 && x2ap.X2AP_PDU == 0
# ${filter_A3}                 x2ap.procedureCode == 30 && x2ap.X2AP_PDU == 0
# ${filter_A3_ack}             x2ap.procedureCode == 30 && x2ap.X2AP_PDU == 1
# ${filter_gapoffset}          x2ap.procedureCode == 30 && x2ap.X2AP_PDU == 0 && nr-rrc.gapOffset == 0
# ${filter_ssb02}              x2ap.procedureCode == 30 && x2ap.X2AP_PDU == 0 && nr-rrc.physCellId == 51
# ${throughput}                100M
# ${TMA_APP_ALIAS}             e500
# ${Test_Case_Name}            5GC000710_BTSLOG
# ${ul_time}                   1800
# ${ul_port}                   ${tl.ues[0].iperf_details.ssh_connection_details.port}
# ${dl_port}                   ${tl.ues[0].iperf_details.port}
# ${NRMTS_name}                ${MR_NR_BTS_NAME1}
# ${NUM}                       1
# ${port1}                     51000
# ${port2}                     51001
# ${eventA2}                   eventA2
# ${eventA3}                   eventA3
# ${SSB01}                     2073115
# ${SSB02}                     2073691
# ${pacp_filename}             enb_tcpdump
# ${txt_filename}              physCellId
#
#
# *** Test Cases ***
# [1]CB007608-B_5GC000710_A_012_online_modification_of_mobility_profile_between_A2_config_and_A2_Report_with_inter-frequencies_not_supported_by_UE
#     [Documentation]    To verify successful selection of mobility profile based on PLMN and SPID matching
#     [Tags]      CRT_TRUNK    CRT_22R2
#     [Setup]
#     Online update paramters    parameters=${gnb1_008}
#     Check BTS Should Be Normal    index=${0}
#     Check BTS Should Be Normal    index=${1}
#     Check BTS Should Be Normal    enb=${true}
#     ${counter012}    Check PM counter result    counter_id=M55157C00002    counter_object=NRMOP
#     ${counter012_sum}      Get length and Check sum counter value  list_input=${counter012}
#     kill IPSL process
#     log to console    Precondition for attach...
#     Precondition for attach with retry    e500_script_path=${CURDIR}/E500_scripts
#     Start tcpdump log attch UE 012
#     log to console    start check enb_tcpdump_012...
#     run keyword and continue on failure    Check wireshark log data equal value      command=grep physCellId |cut -d ':' -f 2|awk 'END {print}'
#     ...     pacp_filename=${pacp_filename}_1.pcap     txt_filename=${txt_filename}12.txt    filter=${filter_001}   check=${50}
#     run keyword and continue on failure    Check wireshark log data equal value
#     ...    command=awk '/eventId: eventA2/{p=5}p-->0'|head -3|tail -n 1|awk '{print $2}'
#     ...     pacp_filename=${pacp_filename}_1.pcap     txt_filename=${txt_filename}12.txt    filter=${filter_001}   check=rsrp
#     run keyword and continue on failure    Check wireshark log data equal value     command=awk '/eventId: eventA2/{p=5}p-->0'|head -2|tail -n 1
#     ...     pacp_filename=${pacp_filename}_1.pcap     txt_filename=${txt_filename}12.txt    filter=${filter_001}   check=${eventA2}
#     log to console    start check A2 success...
#     ${measId1}      Get measId from wireshark log      command=grep measId |cut -d ':' -f 2|awk 'END {print}'
#     ...    pacp_filename=${pacp_filename}_2.pcap     txt_filename=measId.txt    filter=${filter_005}
#     run keyword and continue on failure    Check EventA2 from wireshark log data     pacp_filename=${pacp_filename}_1.pcap
#     ...    txt_filename=EventA1.txt    filter=${filter_005}     event=${eventA2}     MeasID=${measId1}
# #    run keyword and continue on failure    Check wireshark log data equal value
# #    ...     command=grep measObjectToRemoveList |cut -d ':' -f 2|awk 'END {print}'    pacp_filename=${pacp_filename}_2.pcap
# #    ...     txt_filename=${txt_filename}12.txt    filter=${filter_A3}   check=1 item
#     run keyword and continue on failure    Check wireshark log data equal value
#     ...     command=grep reportConfigToRemoveList |cut -d ':' -f 2|awk 'END {print}'    pacp_filename=${pacp_filename}_2.pcap
#     ...     txt_filename=${txt_filename}12.txt    filter=${filter_A3}   check=1 item
#     run keyword and continue on failure    Check wireshark log data equal value
#     ...     command=grep measIdToRemoveList |cut -d ':' -f 2|awk 'END {print}'    pacp_filename=${pacp_filename}_2.pcap
#     ...     txt_filename=${txt_filename}1234.txt    filter=${filter_A3}   check=1 item
#     run keyword and continue on failure    Check wireshark log data empty
#     ...    command=awk '/eventId: eventA3/{p=5}p-->0'|head -3|tail -n 1|awk '{print $2}'
#     ...     pacp_filename=${pacp_filename}_2.pcap      txt_filename=${txt_filename}12.txt    filter=${filter_A3}
#     run keyword and continue on failure    Check wireshark log data equal value
#     ...     command=grep MeNBtoSgNBContainer |cut -d ':' -f 2|awk 'END {print}'    pacp_filename=${pacp_filename}_1.pcap
#     ...     txt_filename=${txt_filename}12.txt    filter=${filter_A3_ack}   check=40
#     sleep    5min
#     log to console    start check counter...
#     ${counter012_2}    Check PM counter result    counter_id=M55157C00002    counter_object=NRMOP
#     ${counter012_sum2}      Get length and Check sum counter value  list_input=${counter012_2}
#     ${dif}      Evaluate     ${counter012_sum2}-${counter012_sum}
#     should be true       '${dif}'=='1'
#     [Teardown]    Case12 Teardown
#
# *** Keywords ***
# Start tcpdump log attch UE 012
#     [Arguments]   ${E500_SCRIPTS_BASE}=${E500_SCRIPTS_BASE}
#     Start wireshark capture from gNB or Enb      filename=${pacp_filename}_1   alias=enb1
#     log to console    start attach...
#     Cobham retry ue attach if failed    e500_script_path=${E500_SCRIPTS_BASE}     rrc_count=${2}
#     log to console    ue attach successful,sleep:5s
#     sleep    5s
#     ${log_wireshark_path1}      Stop wireshark capture from gNB or Enb        filename=${pacp_filename}_1   alias=enb1
#     Start wireshark capture from gNB or Enb     filename=${pacp_filename}_2    alias=enb2
#     sleep     5s
#     Modify ssbFrequency Parameters Online
#     run keyword and continue on failure     A2 measurement trigger
#     sleep     10s
#     Stop wireshark capture from gNB or Enb     filename=${pacp_filename}_2     alias=enb2
#     [Teardown]     Cobham UE detach
#
# Modify ssbFrequency Parameters Online
#     Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}    connection=cOAM_admi
# n
#     coam.perform_parameter_recommissioning     dist_name=${MR_NR_BTS_NAME1}/NRMEASCFG_IF-2
#     ...                                        parameter=ssbFrequency
#     ...                                        operation=update
#     ...                                        value=2253979
#     ...                                        skip_parameter_relation_errors=${True}
#     ...                                        should_activate=${True}
#     ...                                        connection=cOAM_admin
#     coam.perform_parameter_recommissioning     dist_name=${MR_NR_BTS_NAME1}/NRMEASCFG_IF-3
#     ...                                        parameter=ssbFrequency
#     ...                                        operation=update
#     ...                                        value=2256859
#     ...                                        skip_parameter_relation_errors=${True}
#     ...                                        should_activate=${True}
#     ...                                        connection=cOAM_admin
#     coam.perform_parameter_recommissioning     dist_name=${MR_NR_BTS_NAME1}/NRCELL-1/NRHOIF-1
#     ...                                        parameter=ssbFrequency
#     ...                                        operation=update
#     ...                                        value=2253979
#     ...                                        skip_parameter_relation_errors=${True}
#     ...                                        should_activate=${True}
#     ...                                        connection=cOAM_admin
#     coam.perform_parameter_recommissioning     dist_name=${MR_NR_BTS_NAME1}/NRCELL-1/NRHOIF-2
#     ...                                        parameter=ssbFrequency
#     ...                                        operation=update
#     ...                                        value=2256859
#     ...                                        skip_parameter_relation_errors=${True}
#     ...                                        should_activate=${True}
#     ...                                        connection=cOAM_admin
#     [Teardown]   Disconnect from DU
#
# Reduct ssbFrequency Parameters Online
#     Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}    connection=cOAM_admi
# n
#     coam.perform_parameter_recommissioning     dist_name=${MR_NR_BTS_NAME1}/NRMEASCFG_IF-2
#     ...                                        parameter=ssbFrequency
#     ...                                        operation=update
#     ...                                        value=2073691
#     ...                                        skip_parameter_relation_errors=${True}
#     ...                                        should_activate=${True}
#     ...                                        connection=cOAM_admin
#     coam.perform_parameter_recommissioning     dist_name=${MR_NR_BTS_NAME1}/NRMEASCFG_IF-3
#     ...                                        parameter=ssbFrequency
#     ...                                        operation=update
#     ...                                        value=2074267
#     ...                                        skip_parameter_relation_errors=${True}
#     ...                                        should_activate=${True}
#     ...                                        connection=cOAM_admin
#     coam.perform_parameter_recommissioning     dist_name=${MR_NR_BTS_NAME1}/NRCELL-1/NRHOIF-1
#     ...                                        parameter=ssbFrequency
#     ...                                        operation=update
#     ...                                        value=2073691
#     ...                                        skip_parameter_relation_errors=${True}
#     ...                                        should_activate=${True}
#     ...                                        connection=cOAM_admin
#     coam.perform_parameter_recommissioning     dist_name=${MR_NR_BTS_NAME1}/NRCELL-1/NRHOIF-2
#     ...                                        parameter=ssbFrequency
#     ...                                        operation=update
#     ...                                        value=2074267
#     ...                                        skip_parameter_relation_errors=${True}
#     ...                                        should_activate=${True}
#     ...                                        connection=cOAM_admin
#     [Teardown]   Disconnect from DU
#
# Case12 Teardown
#     Reduct ssbFrequency Parameters Online
#     CI_interface.Common Case Teardown
#
# Check wireshark log data empty
#     [Arguments]    ${command}    ${pacp_filename}   ${txt_filename}    ${filter}   ${connection}=ute
#     ${data}    Check wireshark log data common    command=${command}    pacp_filename=${pacp_filename}    connection=${connection}
#     ...   txt_filename=${txt_filename}      filter=${filter}
#     should be empty    ${data}
