# *** Settings ***
# Force Tags    PY36
# Suite Setup    Common setup for 710
# Suite Teardown
#
# Documentation    Suite description
# ...   author: miao.1.lu@nokia-sbell.com
# ...   contact: miao.1.lu@nokia-sbell.com
#
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/container_log_capturing.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/viavi_common_keyword.robot
# Resource          taf/rfrl/common_resources/robot/libraries_instances.robot
# Variables         ./Resources/paramter_modify.py
# Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource          ./Resources/5GC000710_common_keyword.robot
# Library    taf.analyzer.pcap    WITH NAME    check_cap
# Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/Analysis_Viavi_Log.py
# Library           Analysis_Viavi_Log.Viavi_Log_analysis     WITH NAME    Viavi_Log_analysis
# Library           taf.transport.ssh    WITH NAME    csn
# Library           taf.hw.rf_attenuator    WITH NAME    att
# Library           taf.ue  WITH NAME   ute_ue
#
# *** Variables ***
# ${CURDIR_path}             ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}
# ${CURDIR_path1}            ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/SCF_SBTS22R1_gNB1.xml
# ${CURDIR_path2}            ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/SCF_SBTS22R1_gNB2.xml
# ${CURDIR_path1_trunk}            ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/SCF_Trunk_gNB1.xml
# ${CURDIR_path2_trunk}            ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/SCF_Trunk_gNB2.xml
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
# ${LOG_PATH}                  ${OUTPUT_DIR}
# ${ul_port}                   ${tl.ues[0].iperf_details.ssh_connection_details.port}
# ${dl_port}                   ${tl.ues[0].iperf_details.port}
# ${gNB_BTS_ID}                ${tl.gnbs[0].global_bts_id}
# ${new_scf_path}              ${LOG_PATH}/scf_base_default.xml
# ${NRMTS_name}                ${MR_NR_BTS_NAME1}
# ${connection}                GNB_OAM
# ${pacp_filename}             enb_tcpdump
# ${txt_filename}              physCellId
#
# *** Test Cases ***
#
# [1]CB007403-C_5GC000710_A_001_Successful_Intra-gNB_PSCell_change_with_inter-frequency_A3_without_SRB3
#     [Documentation]    To verify successful selection of mobility profile based on PLMN and SPID matching
#     [Tags]
#     [Setup]
#     Online update paramters    parameters=${gnb1_001}
#     Online update paramters    parameters=${enb_actEndcSpidFwd}    enb=${true}
#     Check BTS Should Be Normal    index=${0}
#     Check BTS Should Be Normal    index=${1}
#     Check BTS Should Be Normal    enb=${true}
#     ${CELL1counter}       Check PM counter result    counter_id=M55157C00002    counter_object=NRMOP
#     ${CELL1counter_sum}       Get length and Check sum counter value  list_input=${CELL1counter}
#     kill IPSL process
#     log to console    Precondition for attach...
#     Precondition for attach with retry    e500_script_path=${CURDIR}/E500_scripts
#     Start tcpdump log attch UE and send UL and DL traffic
#
#     log to console    start check enb_tcpdump_1...
#     run keyword and continue on failure    Check wireshark log data equal value      command=grep physCellId |cut -d ':' -f 2|awk 'END {print}'
#     ...     pacp_filename=${pacp_filename}_1.pcap     txt_filename=${txt_filename}1.txt    filter=${filter_001}   check=${50}
#     run keyword and continue on failure    Check wireshark log data equal value      command=grep SubscriberProfileIDforRFP:|tr -cd "[0-9]"
#     ...     pacp_filename=${pacp_filename}_1.pcap     txt_filename=${txt_filename}1.txt    filter=${filter_002}   check=${12}
#     run keyword and continue on failure    Check wireshark log data equal value
#     ...    command=awk '/eventId: eventA2/{p=5}p-->0'|head -3|tail -n 1|awk '{print $2}'
#     ...     pacp_filename=${pacp_filename}_1.pcap     txt_filename=${txt_filename}1.txt    filter=${filter_001}   check=rsrp
#     run keyword and continue on failure    Check wireshark log data equal value     command=awk '/eventId: eventA2/{p=5}p-->0'|head -2|tail -n 1
#     ...     pacp_filename=${pacp_filename}_1.pcap     txt_filename=${txt_filename}1.txt    filter=${filter_001}   check=${eventA2}
#     run keyword and continue on failure    Check wireshark log data equal value
#     ...    command=awk '/measObject: measObjectNR/{p=5}p-->0'|head -3|tail -n 1|cut -d ':' -f 2
#     ...     pacp_filename=${pacp_filename}_1.pcap     txt_filename=${txt_filename}1.txt    filter=${filter_001}   check=${SSB01}
#
#     log to console    start check enb_tcpdump_2_A2...
#     ${measId1}      Get measId from wireshark log      command=grep measId |cut -d ':' -f 2|awk 'END {print}'
#     ...    pacp_filename=${pacp_filename}_2.pcap     txt_filename=measId.txt    filter=${filter_meas1}
#     run keyword and continue on failure    Check wireshark log data equal value      command=grep gapOffset:|tr -cd "[0-9]"
#     ...     pacp_filename=${pacp_filename}_2.pcap      txt_filename=${txt_filename}2.txt    filter=${filter_gapoffset}   check=${0}
#
#     log to console    start check enb_tcpdump_2_A3...
#
#     run keyword and continue on failure    Check EventA2 from wireshark log data
#     ...    pacp_filename=${pacp_filename}_2.pcap     txt_filename=EventA3.txt
#     ...    filter=${filter_gapoffset}     event=${eventA3}     MeasID=${3}
#     run keyword and continue on failure    Check EventA2 from wireshark log data
#     ...    pacp_filename=${pacp_filename}_2.pcap     txt_filename=EventA3.txt
#     ...    filter=${filter_gapoffset}     event=${eventA3}     MeasID=${4}
#
#     run keyword and continue on failure    Check wireshark log data equal value      command=grep physCellId |cut -d ':' -f 2|awk 'END {print}'
#     ...     pacp_filename=${pacp_filename}_2.pcap      txt_filename=${txt_filename}2.txt    filter=${filter_A3}   check=${51}
#     run keyword and continue on failure    Check wireshark log data equal value
#     ...    command=awk '/eventId: eventA2/{p=5}p-->0'|head -3|tail -n 1|awk '{print $2}'
#     ...     pacp_filename=${pacp_filename}_2.pcap      txt_filename=${txt_filename}2.txt    filter=${filter_A3}   check=rsrp
#     run keyword and continue on failure    Check wireshark log data equal value
#     ...    command=awk '/measObject: measObjectNR/{p=5}p-->0'|head -3|tail -n 1|cut -d ':' -f 2
#     ...     pacp_filename=${pacp_filename}_2.pcap     txt_filename=${txt_filename}1.txt    filter=${filter_ssb02}   check=${SSB02}
#     sleep    5min
#     log to console    start check counter...
#     ${CELL1counter_2}    Check PM counter result    counter_id=M55157C00002    counter_object=NRMOP
#     ${CELL1counter_sum2}      Get length and Check sum counter value  list_input=${CELL1counter_2}
#     ${dif}      Evaluate     ${CELL1counter_sum2}-${CELL1counter_sum}
#     should be true     '${dif}'=='1'
#     [Teardown]    CI_interface.Common Case Teardown
#
# [1]CB007403-C_5GC000710_A_005_Unsuccessful_configuration_of_A2_measurement_as_all_inter_frequencies_define_in_profile_not_defined_in_NRcell
#     [Documentation]
#     [Tags]
#     [Setup]
#     Online update paramters    parameters=${gnb1_005}
#     Online update paramters    parameters=${enb_actEndcSpidFwd}    enb=${true}
#     ${counter005}    Check PM counter result    counter_id=M55157C00002    counter_object=NRMOP
#     ${counter005_sum}      Get length and Check sum counter value  list_input=${counter005}
#     run keyword and continue on failure   Change ssbFrequency
#     Log To Console       Delete NRMEASCFG_IF-2...
#     run keyword and continue on failure   Delete object
#     Check BTS Should Be Normal    index=${0}
#     Check BTS Should Be Normal    index=${1}
#     Check BTS Should Be Normal    enb=${true}
#     kill IPSL process
#     log to console    Precondition for attach...
#     Precondition for attach with retry    e500_script_path=${CURDIR}/E500_scripts
#     run keyword and continue on failure     Catch tcpdump log and attch UE    filename=${pacp_filename}_005
#
#     run keyword and continue on failure    Check wireshark log data equal value      command=grep physCellId |cut -d ':' -f 2|awk 'END {print}'
#     ...     pacp_filename=${pacp_filename}_005.pcap     txt_filename=${txt_filename}005.txt    filter=${filter_005}   check=${50}
#     run keyword and continue on failure    Check wireshark log data equal value     command=awk '/eventId: eventA2/{p=5}p-->0'|head -2|tail -n 1
#     ...     pacp_filename=${pacp_filename}_005.pcap     txt_filename=NoEventA2.txt    filter=${filter_005}   check=${empty}
#
#     sleep    5min
#     log to console    start check counter...
#     ${counter005_2}    Check PM counter result    counter_id=M55157C00002    counter_object=NRMOP
#     ${counter005_sum2}      Get length and Check sum counter value  list_input=${counter005_2}
#     ${dif}      Evaluate     ${counter005_sum2}-${counter005_sum}
#     should be true       '${dif}'=='1'
#     run keyword and continue on failure   Recover ssbFrequency
#     Log To Console       Recover NRMEASCFG_IF-2...
#     run keyword and continue on failure   Recover object
#     [Teardown]    CI_interface.Common Case Teardown
#
# [1]CB007403-C_5GC000710_A_008_Successful_removal_of_inter-frequency_A3A5_and_configuration_A2_after_receipt_A1_RSRPCombine_Measurement_report
#     [Documentation]    To verify successful selection of mobility profile based on PLMN and SPID matching
#     [Tags]    CRT_22R3    CRT_TRUNK    CRT_22R2
#     [Setup]
#     Online update paramters    parameters=${gnb1_008}
#     Check BTS Should Be Normal    index=${0}
#     Check BTS Should Be Normal    index=${1}
#     Check BTS Should Be Normal    enb=${true}
#     sleep    5min
#     ${counter008}    Check PM counter result    counter_id=M55157C00002    counter_object=NRMOP
#     ${counter008_sum}      Get length and Check sum counter value  list_input=${counter008}
#     kill IPSL process
#     Log To Console       Update a1MeashoEnabled to rsrpCombined...
#     run keyword and continue on failure   Update a1MeashoEnabled
#     log to console    Precondition for attach...
#     Precondition for attach with retry    e500_script_path=${CURDIR}/E500_scripts
#     Start tcpdump log attch UE and send UL and DL traffic 008
#     log to console    start check enb_tcpdump_008...
#     run keyword and continue on failure    Check wireshark log data equal value      command=grep physCellId |cut -d ':' -f 2|awk 'END {print}'
#     ...     pacp_filename=${pacp_filename}_1.pcap     txt_filename=${txt_filename}8_1.txt    filter=${filter_001}   check=${50}
#     run keyword and continue on failure    Check wireshark log data equal value
#     ...    command=awk '/eventId: eventA2/{p=5}p-->0'|head -3|tail -n 1|awk '{print $2}'
#     ...     pacp_filename=${pacp_filename}_1.pcap    txt_filename=${txt_filename}8_1.txt    filter=${filter_001}   check=${rsrp}
#     run keyword and continue on failure    Check wireshark log data equal value     command=awk '/eventId: eventA2/{p=5}p-->0'|head -2|tail -n 1
#     ...     pacp_filename=${pacp_filename}_1.pcap     txt_filename=${txt_filename}8_1.txt    filter=${filter_001}   check=${eventA2}
#
#     log to console    start check enb_tcpdump_2_A2...
#     run keyword and continue on failure    Check wireshark log data equal value      command=grep gapOffset:|tr -cd "[0-9]"
#     ...     pacp_filename=${pacp_filename}_2.pcap      txt_filename=${txt_filename}8.txt   filter=${filter_gapoffset}   check=${0}
#
#     log to console    start check enb_tcpdump_A1_A3...
#     run keyword and continue on failure    Check EventA2 from wireshark log data
#     ...    pacp_filename=${pacp_filename}_2.pcap     txt_filename=EventA1.txt
#     ...    filter=${filter_gapoffset}     event=${eventA1}     MeasID=${2}
#     run keyword and continue on failure    Check EventA2 from wireshark log data
#     ...    pacp_filename=${pacp_filename}_2.pcap     txt_filename=EventA3.txt
#     ...    filter=${filter_gapoffset}     event=${eventA3}     MeasID=${3}
#     run keyword and continue on failure    Check EventA2 from wireshark log data
#     ...    pacp_filename=${pacp_filename}_2.pcap    txt_filename=EventA3.txt
#     ...    filter=${filter_gapoffset}     event=${eventA3}     MeasID=${4}
#
#     log to console    start check enb_tcpdump_2_rsrp...
#     run keyword and continue on failure    Check wireshark log data equal value
#     ...    command=awk '/eventId: eventA1/{p=5}p-->0'|head -3|tail -n 1|awk '{print $2}'
#     ...     pacp_filename=${pacp_filename}_2.pcap      txt_filename=${txt_filename}8.txt    filter=${filter_A3}   check=${rsrp}
#     run keyword and continue on failure    Check wireshark log data equal value
#     ...    command=awk '/eventId: eventA3/{p=5}p-->0'|head -3|tail -n 1|awk '{print $2}'
#     ...     pacp_filename=${pacp_filename}_2.pcap      txt_filename=${txt_filename}8.txt   filter=${filter_A3}   check=${rsrp}
#
#     log to console    start check gapFR2...
#     run keyword and continue on failure    Check wireshark log data equal value
#     ...    command=awk '/gapFR2: release/'
#     ...     pacp_filename=${pacp_filename}_2.pcap     txt_filename=gapFR2.txt    filter=${filter_meas5}   check=${gapFR2}
#
#     log to console    start check eventA2...
#     run keyword and continue on failure    Check EventA2 from wireshark log data
#     ...    pacp_filename=${pacp_filename}_2.pcap     txt_filename=EventA2.txt
#     ...    filter=${filter_meas5}     event=${eventA2}     MeasID=${5}
#     run keyword and continue on failure    Check wireshark log data equal value
#     ...    command=awk '/eventId: eventA2/{p=5}p-->0'|head -3|tail -n 1|awk '{print $2}'
#     ...     pacp_filename=${pacp_filename}_2.pcap      txt_filename=${txt_filename}8.txt    filter=${filter_meas5}   check=${rsrp}
#
#     log to console    start check measIdToRemoveList...
#     run keyword and continue on failure    Check wireshark log data equal value
#     ...    command=awk '/measIdToRemoveList:/{p=7}p-->0'|head -3|tail -n 1|tr -cd "[0-9]"
#     ...     pacp_filename=${pacp_filename}_2.pcap      txt_filename=${txt_filename}8.txt    filter=${filter_meas5}   check=2
#     run keyword and continue on failure    Check wireshark log data equal value
#     ...    command=awk '/measIdToRemoveList:/{p=7}p-->0'|head -5|tail -n 1|tr -cd "[0-9]"
#     ...     pacp_filename=${pacp_filename}_2.pcap      txt_filename=${txt_filename}8.txt    filter=${filter_meas5}   check=3
#     run keyword and continue on failure    Check wireshark log data equal value
#     ...    command=awk '/measIdToRemoveList:/{p=7}p-->0'|head -7|tail -n 1|tr -cd "[0-9]"
#     ...     pacp_filename=${pacp_filename}_2.pcap      txt_filename=${txt_filename}8.txt    filter=${filter_meas5}   check=4
#
#     sleep    5min
#     log to console    start check counter...
#     ${counter008_2}    Check PM counter result    counter_id=M55157C00002    counter_object=NRMOP
#     ${counter008_sum2}      Get length and Check sum counter value  list_input=${counter008_2}
#     ${dif}      Evaluate     ${counter008_sum2}-${counter008_sum}
#     should be true       '${dif}'=='1'
#     Recover a1MeashoEnabled
#     [Teardown]    CI_interface.Common Case Teardown
#
# [1]CB007403-C_5GC000710_A_011_online_deletion_of_mobility_profile_between_A2_configuration_and_A2_Report
#     [Documentation]    To verify
#     [Tags]
#     [Setup]
#     Online update paramters    parameters=${gnb1_008}
#     Check BTS Should Be Normal    index=${0}
#     Check BTS Should Be Normal    index=${1}
#     Check BTS Should Be Normal    enb=${true}
#     ${counter011}    Check PM counter result    counter_id=M55157C00002    counter_object=NRMOP
#     ${counter011_sum}      Get length and Check sum counter value  list_input=${counter011}
#     kill IPSL process
#     log to console    Precondition for attach...
#     Precondition for attach with retry    e500_script_path=${CURDIR}/E500_scripts
#     ${NRMOPRMA_NSA}     ${NRMOPR_NSA}    Start tcpdump log attch UE and send UL and DL traffic 011
#     log to console    start check enb_tcpdump_011...
#     run keyword and continue on failure    Check wireshark log data equal value      command=grep physCellId |cut -d ':' -f 2|awk 'END {print}'
#     ...     pacp_filename=${pacp_filename}_1.pcap     txt_filename=${txt_filename}11.txt    filter=${filter_001}   check=${50}
#     run keyword and continue on failure    Check wireshark log data equal value
#     ...    command=awk '/eventId: eventA2/{p=5}p-->0'|head -3|tail -n 1|awk '{print $2}'
#     ...     pacp_filename=${pacp_filename}_1.pcap     txt_filename=${txt_filename}11.txt    filter=${filter_001}   check=rsrp
#     run keyword and continue on failure    Check wireshark log data equal value     command=awk '/eventId: eventA2/{p=5}p-->0'|head -2|tail -n 1
#     ...     pacp_filename=${pacp_filename}_1.pcap     txt_filename=${txt_filename}11.txt    filter=${filter_001}   check=${eventA2}
#
#     log to console    start check A2 success...
#     ${measId1}      Get measId from wireshark log      command=grep measId |cut -d ':' -f 2|awk 'END {print}'
#     ...    pacp_filename=${pacp_filename}_2.pcap     txt_filename=measId.txt    filter=${filter_005}
#     run keyword and continue on failure    Check EventA2 from wireshark log data
#     ...    pacp_filename=${pacp_filename}_1.pcap     txt_filename=EventA2.txt
#     ...    filter=${filter_005}     event=${eventA2}     MeasID=${measId1}
#     run keyword and continue on failure    Check wireshark log data equal value      command=grep gapOffset:|tr -cd "[0-9]"
#     ...     pacp_filename=${pacp_filename}_2.pcap      txt_filename=${txt_filename}11.txt    filter=${filter_gapoffset}   check=${0}
#     run keyword and continue on failure    Check wireshark log data equal value
#     ...    command=awk '/eventId: eventA3/{p=5}p-->0'|head -3|tail -n 1|awk '{print $2}'
#     ...     pacp_filename=${pacp_filename}_2.pcap      txt_filename=${txt_filename}11.txt    filter=${filter_A3}   check=rsrp
#
#     log to console    start check new SSB...
#     run keyword and continue on failure    Check wireshark log data equal value
#     ...    command=awk '/measObject: measObjectNR/{p=5}p-->0'|head -3|tail -n 1|cut -d ':' -f 2
#     ...     pacp_filename=${pacp_filename}_2.pcap     txt_filename=${txt_filename}11.txt    filter=${filter_gapoffset}   check=${SSB02}
#     run keyword and continue on failure    Check wireshark log data not equal value
#     ...     command=awk '/measObject: measObjectNR/{p=5}p-->0'|head -3|tail -n 1|cut -d ':' -f 2
#     ...     pacp_filename=${pacp_filename}_2.pcap     txt_filename=${txt_filename}11.txt    filter=${filter_gapoffset}   check=${SSB01}
#     run keyword and continue on failure    Check wireshark log data equal value
#     ...    command=awk '/eventId: eventA3/{p=5}p-->0'|head -3|tail -n 1|awk '{print $2}'
#     ...     pacp_filename=${pacp_filename}_2.pcap      txt_filename=${txt_filename}11.txt    filter=${filter_A3}   check=rsrp
#     run keyword and continue on failure    Check wireshark log data equal value     command=awk '/eventId: eventA3/{p=7}p-->0'|head -2|tail -n 1
#     ...     pacp_filename=${pacp_filename}_2.pcap     txt_filename=${txt_filename}11.txt    filter=${filter_gapoffset}   check=${eventA3}
#     log to console    check RRC Reconfiguration Complete...
#     ${data}    Check wireshark log data common    command=awk '/SgNBModificationConfirm/'    pacp_filename=${pacp_filename}_2.pcap
#     ...    txt_filename=${txt_filename}11.txt    filter=${filter_A3_ack}
#     ${data_lits}    set variable    ${data.split('\n')}
#     ${RRC_sum}    get length    ${data_lits}
#     should be true       '${RRC_sum}'=='3'
#     sleep    5min
#     log to console    start check counter...
#     ${counter011_2}    Check PM counter result    counter_id=M55157C00002    counter_object=NRMOP
#     ${counter011_sum2}      Get length and Check sum counter value  list_input=${counter011_2}
#     ${dif}      Evaluate     ${counter011_sum2}-${counter011_sum}
#     should be true       '${dif}'=='1'
#     [Teardown]     CI_interface.Common Case Teardown
#
# [1]CB007403-C_5GC000710_A_009_Successful_inter_gNB_PSCell_change_with_inter-frequency_A3_RSRPCombine_with_SRB3
#     [Documentation]    To verify successful selection of mobility profile based on PLMN and SPID matching
#     [Tags]
#     [Setup]
#     ${new_scf_path}    Modify SCF file and create new SCF
#     Setup Commission 701SCF    CURDIR_path=${new_scf_path}    bts_host=${gNB2_ip}
#     Online update paramters    parameters=${gnb1_009}
#     sleep    3min
#     Online update paramters    parameters=${gnb2_009}    index=${1}
#     Check BTS Should Be Normal    index=${0}
#     Check BTS Should Be Normal    index=${1}
#     Check BTS Should Be Normal    enb=${true}
#     sleep    3min
#     ${counter009}    Check PM counter result    counter_id=M55157C00002    counter_object=NRMOP
#     ${counter009_sum}      Get length and Check sum counter value  list_input=${counter009}
#     ${counter009cell2}    Check PM counter result    counter_id=M55157C00002    counter_object=NRMOP    index=${1}
#     ${counter009cell2_sum}      Get length and Check sum counter value  list_input=${counter009cell2}
#     kill IPSL process
#     Log To Console       Update a3MeashoEnabled to rsrpCombined...
#     run keyword and continue on failure   Update a3MeashoEnabled
#
#     log to console    Precondition for attach...
#     Precondition for attach with retry    e500_script_path=${CURDIR}/E500_scripts2
#     run keyword and continue on failure    Start tcpdump log attch UE and send UL and DL traffic 009
#
#     log to console    start check enb_tcpdump_1...
#     run keyword and continue on failure    Check wireshark log data equal value      command=grep physCellId |cut -d ':' -f 2|awk 'END {print}'
#     ...     pacp_filename=${pacp_filename}_1.pcap     txt_filename=${txt_filename}9.txt    filter=${filter_001}   check=${50}
#     run keyword and continue on failure    Check wireshark log data equal value
#     ...    command=awk '/eventId: eventA2/{p=5}p-->0'|head -3|tail -n 1|awk '{print $2}'
#     ...     pacp_filename=${pacp_filename}_1.pcap     txt_filename=${txt_filename}9.txt    filter=${filter_001}   check=rsrp
#     run keyword and continue on failure    Check wireshark log data equal value     command=awk '/eventId: eventA2/{p=5}p-->0'|head -2|tail -n 1
#     ...     pacp_filename=${pacp_filename}_1.pcap     txt_filename=${txt_filename}9.txt    filter=${filter_001}   check=${eventA2}
#
#     log to console    start check SRBID...
#     run keyword and continue on failure    Check wireshark log data equal value      command=grep SRBID:|tr -cd "[0-9]"
#     ...     pacp_filename=gnb_tcpdump_1.pcap      txt_filename=${txt_filename}9.txt    filter=${filter_SRBID}   check=${3}
#     run keyword and continue on failure    Check wireshark log data equal value      command=grep gapOffset:|tr -cd "[0-9]"
#     ...     pacp_filename=gnb_tcpdump_1.pcap      txt_filename=${txt_filename}9.txt    filter=${filter_F1gapOffset}   check=${0}
#
#     log to console    start check gnb_tcpdump_A1_A3 by A2 report...
#     run keyword and continue on failure    Check Event and Rsrp by measID     pacp_filename=gnb_tcpdump_1.pcap     txt_filename=EventA3.txt
#     ...    filter=${filter_F1A3}     event=${eventA1}     MeasID=${2}
#     run keyword and continue on failure   Check Event and Rsrp by measID     pacp_filename=gnb_tcpdump_1.pcap     txt_filename=EventA3.txt
#     ...    filter=${filter_F1A3}     event=${eventA3}     MeasID=${3}
#     run keyword and continue on failure    Check Event and Rsrp by measID     pacp_filename=gnb_tcpdump_1.pcap     txt_filename=EventA3.txt
#     ...    filter=${filter_F1A3}     event=${eventA3}     MeasID=${4}
#
#    log to console    start check gnb_tcpdump_A1_A3 by A3 report...
#     run keyword and continue on failure    Check Event and Rsrp by measID     pacp_filename=gnb_tcpdump_1.pcap     txt_filename=EventA3.txt
#     ...    filter=${filter_F1gapOffset}     event=${eventA1}     MeasID=${2}
#     run keyword and continue on failure   Check Event and Rsrp by measID     pacp_filename=gnb_tcpdump_1.pcap     txt_filename=EventA3.txt
#     ...    filter=${filter_F1gapOffset}     event=${eventA3}     MeasID=${3}
#     run keyword and continue on failure    Check Event and Rsrp by measID     pacp_filename=gnb_tcpdump_1.pcap     txt_filename=EventA3.txt
#     ...    filter=${filter_F1gapOffset}     event=${eventA3}     MeasID=${4}
#     run keyword and continue on failure    Check wireshark log data equal value      command=grep SRBID:|tr -cd "[0-9]"
#     ...     pacp_filename=gnb_tcpdump_1.pcap      txt_filename=${txt_filename}9.txt    filter=${filter_A3report}   check=${3}
#
#     log to console    start check gnb2 change success...
#     run keyword and continue on failure    Check wireshark log data equal value      command=grep physCellId |cut -d ':' -f 2|awk 'END {print}'
#     ...     pacp_filename=gnb_tcpdump_2.pcap     txt_filename=${txt_filename}9.2.txt    filter=${filter_001}   check=${52}
#     run keyword and continue on failure    Check wireshark log data equal value
#     ...    command=awk '/eventId: eventA2/{p=5}p-->0'|head -3|tail -n 1|awk '{print $2}'
#     ...     pacp_filename=gnb_tcpdump_2.pcap     txt_filename=${txt_filename}9.2.txt    filter=${filter_001}   check=rsrp
#     run keyword and continue on failure    Check wireshark log data equal value     command=awk '/eventId: eventA2/{p=5}p-->0'|head -2|tail -n 1
#     ...     pacp_filename=gnb_tcpdump_2.pcap     txt_filename=${txt_filename}9.2.txt    filter=${filter_001}   check=${eventA2}
#     run keyword and continue on failure    Check wireshark log data equal value
#     ...    command=awk '/measObject: measObjectNR/{p=5}p-->0'|head -3|tail -n 1|cut -d ':' -f 2
#     ...     pacp_filename=gnb_tcpdump_2.pcap     txt_filename=${txt_filename}9.2.txt    filter=${filter_001}   check=${SSB02}
#     sleep    5min
#     log to console    start check counter...
#     ${counter009_2}    Check PM counter result    counter_id=M55157C00002    counter_object=NRMOP
#     ${counter009_sum2}      Get length and Check sum counter value  list_input=${counter009_2}
#     ${dif}      Evaluate     ${counter009_sum2}-${counter009_sum}
#     should be true       '${dif}'=='1'
#     ${counter009cell2_2}    Check PM counter result    counter_id=M55157C00002    counter_object=NRMOP    index=${1}
#     ${counter009cell2_sum2}      Get length and Check sum counter value  list_input=${counter009cell2_2}
#     ${dif}      Evaluate     ${counter009cell2_sum2}-${counter009cell2_sum}
#     should be true       '${dif}'=='1'
#     [Teardown]    009 Common Case Teardown