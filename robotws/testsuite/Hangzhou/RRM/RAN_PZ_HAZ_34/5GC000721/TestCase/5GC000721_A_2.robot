# *** Settings ***
# Resource    ../../5GC001911-CA/resource/5GC001911-CA_keywords.robot
# Resource    ../Resource/5GC000721_keyword.robot
# Resource    ../../FGCR-7660/Resources/FGCR-7660_keywords.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/modify_scf.robot
# 
# Documentation
# ...   author: Fang Ludan
# ...   contact: ludan.fang@nokia-sbell.com
# ...   squad group: MMW_SG1
# ...   feature : 5GC000721s
# 
# 
# Force Tags    5G_RRM     CIT_TRUNK    CRT_20B        
# ...    PY36
# Suite Setup     Suite preparation
# Suite Teardown  suite teardown for 721
# 
# *** Variables ***
# #${4G_IP}     ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
# ${WEBUI_USER}     ${tl.gnbs[0].cu.oam_http_connection_details.username}
# ${WEBUI_PWD}      ${tl.gnbs[0].cu.oam_http_connection_details.password}
# ${BTS_ID}                ${tl.enbs[0].instance_id}
# ${UE_TYPE}       ${tl.ues[0].capabilities[1]}
# ${CURDIR_path}          ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/
# ${gNB_ip}         ${tl.gnbs[0].dus[0].f1_m_ip_addr}
# @{5G_RU_id_list_749}        ${3}
# @{4G_RU_id_list_749}        ${1}
# ${5G_BTS_ID_749}            7502
# ${4G_BTS_ID_749}            10725
# @{RU_lock_status}           Locked    enabled    Idle    configured
# @{empty_list}
# 
# *** Test Cases ***
# [1]5GC000721_A_2_Cell2 selected as pScell in the SgNB addition when cell1 is exceed ccLoadThreshold
#     [Documentation]    author: Fang ludan
#     ...    This user scenario describes successful SgNB addition procedure with radio admission control (5GC000480) and
#     ...    PSCell load balancing(5GC000721).
#     [Tags]     CRT_20B   CIT_TRUNK     CIT_21B       CIT_21A    CRT_22R1   CRT_22R2
#     [Timeout]    1 hour
#     [Setup]    case setup for 721
#     #    UE1 Attach check
#     Start X2 log capture on gNB    log_name=X2_tcpdump
#     Retry commercial ue attach if failed    retry_time=${retry_time}    ue_type=${ue_type}    ue_index=${0}
#     Connect to Common Unit Master
#     ${X2tcpdump_log}    Stop X2 log capture from gNB    log_name=X2_tcpdump
#     Start traffic uldl    ue_index=${0}
#     Verify peak tput of each cell for 721   dl_cell=${dl_cell}    ul_cell=${ul_cell}   expected_dl_tput_max=${expected_dl_tput_max}
#     ...     expected_dl_tput_min=${expected_dl_tput_min}      expected_ul_tput=${expected_ul_tput}
#     ...     dl_num_exp=${CC_num}    ul_num_exp=${ul_num_exp}
# 
#     SISO_Pre.Close iperf progress
#     Run keyword and continue on failure    check physCellId    x2ap_log=${X2tcpdump_log}      physCellId_exp=93
#     #UE2 attach and check
#     Start X2 log capture on gNB    log_name=X2_tcpdump_UE1
#     Retry commercial ue attach if failed    retry_time=${retry_time}    ue_type=${ue_type}    ue_index=${1}
#     Connect to Common Unit Master
#     ${X2tcpdump_log}    Stop X2 log capture from gNB    log_name=X2_tcpdump_UE1
#     Start traffic uldl    ue_index=${1}
#     Verify peak tput of each cell for 721   dl_cell=${dl_cell}    ul_cell=${ul_cell}   expected_dl_tput_max=${expected_dl_tput_max}
#     ...     expected_dl_tput_min=${expected_dl_tput_min}      expected_ul_tput=${expected_ul_tput}
#     ...     dl_num_exp=${CC_num}    ul_num_exp=${ul_num_exp}
# 
#     Run keyword and continue on failure    check physCellId    x2ap_log=${X2tcpdump_log}      physCellId_exp=94
#     Verify peak tput of each cell for 721   dl_cell=${dl_cell}    ul_cell=${ul_cell}   expected_dl_tput_max=${expected_dl_tput_max}
#     ...     expected_dl_tput_min=${expected_dl_tput_min}      expected_ul_tput=${expected_ul_tput}
#     ...     dl_num_exp=${CC_num}    ul_num_exp=${ul_num_exp}
#     SISO_Pre.Close iperf progress
#     [Teardown]   run keyword and ignore error     case teardown for 721
# 
# 
# *** Keywords ***
# get correct scf path
#     [Arguments]     ${connection}=GNB_OAM
#     ${release}    Get sw build version for scf name
#     ${release_sbts}    Replace String    string=${release}    search_for=5G    replace_with=SBTS
#     ${default_scf_name}    Catenate    SCF_${release_sbts}.xml
#     ${default_scf}    set variable    ${CURDIR_path}${default_scf_name}
#     set suite variable    ${default_scf}
#     log to console   ${default_scf}
# 
# Get sw build version for scf name
#     Connect to Common Unit Master
#     ssh.force_reconnect    connection=ASIK Master
#     ${cmd_get_sw_file_name}    Set variable    ls /ffs/run |grep TargetBD.*.xml |grep -v .xml.
#     ${sw_file_name}    ssh.execute    command=${cmd_get_sw_file_name}    connection=ASIK Master
#     @{sw_version_list}    Get regexp matches    ${sw_file_name}    TargetBD_(.*?)_    1
#     Run keyword and ignore error    Remove values From List     ${sw_version_list}    BSR
#     ${sw_version_list}    Strip string    ${sw_version_list[0]}
#     ${if_SBTS}    run keyword and return status    should contain    ${sw_file_name}     9999
#     ${sw_version}    set variable if    ${if_SBTS}    SBTS00    ${sw_version_list}
#     [Return]  ${sw_version}
# 
# Suite preparation
#     [Timeout]    20 min
#     robot_common_operations.Common Suite Setup
#     Set variables for UTE cloud
#     get correct scf path
#     Modify Parameter By SCF
#     Preparation with swconfig modification and comissioning    swconfig_modify=${None}
#     ...    scf_modify=${MODIFY_721_SCF}    is_called_in_test_case_level=${False}
#     ...    is_pdl_checking_needed=${False}
#     ...    scf_template_path=${output_dir}/Modify_scf.xml    swconfig_template_path=${SWCONFIG_DEFAULT_FILE_PATH_709}
#     Wait until cluster is on cell on air status    timeout=${RECOVERY_TIMEOUT}
#     wait until keyword succeeds    5 min    10 sec    Verify all cells should be onair
#     Determine whether to lock based on RU status    lock_ru_list=${5G_RU_id_list_749}    bts_host=10.71.215.244    BTS_ID=${5G_BTS_ID_749}
#     Determine whether to lock based on RU status    lock_ru_list=${4G_RU_id_list_749}    bts_host=10.71.215.243    BTS_ID=${4G_BTS_ID_749}
# ##    ${rus_connect_success}    run keyword and return status  Connect to all rus with allocated IP
# 
# #change 4G configuration
# #    Connect to gnb coam via ssl    bts_host=${4G_IP}    username=${WEBUI_USER}    password=${WEBUI_PWD}    connection=4G_admin
# #    perform muti Parameter recommissioning
# #    ...    dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-1
# #    ...    parameter=defaultLnRelGnbCellId
# #    ...    value=1
# #    ...    operation=update
# #    ...    connection=4G_admin
# #    coam.teardown     connection=4G_admin
# 
# perform muti Parameter recommissioning
#     [Arguments]   ${dist_name}    ${parameter}   ${value}     ${operation}=create    ${connection}=cOAM_admin
#     ...    ${skip_parameter_relation_errors}=${True}     ${should_activate}=${True}
#     coam.Perform Parameter Recommissioning
#     ...    dist_name=${dist_name}
#     ...    parameter=${parameter}
#     ...    value=${value}
#     ...    operation=${operation}
#     ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}
#     ...    should_activate=${should_activate}
#     ...    connection=${connection}
# 
# case setup for 721
#     robot_common_operations.Common Case Setup
# #    change 4G configuration
#     Common case setup    is_log_required=${False}    is_btslog_required=${False}
#     ...    is_enb_status_check_needed=${False}    is_x2_check_from_enb_needed=${False}
#     coam create log directory
#     Connect to gnb coam via ssl
#     &{NR_CELL_ID_MAPPING}    coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids
#     Set test variable    ${NR_CELL_ID_MAPPING}
# 
# 
# suite teardown for 721
#     Common suite recovery    swconfig_template_path=${SWCONFIG_DEFAULT_FILE_PATH_709}
#     robot_common_operations.Common Suite Teardown
# 
# 
# case teardown for 721
#     power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#     power_ue.UE Detach    ue_type=${ue_type}     ue_index=${1}
#     Common case teardown
#     robot_common_operations.Common Case Teardown
#     CI_interface.Common Case Teardown
# 
# Generate corresponding distname list
#     [Arguments]  ${id_list}    ${p_name}
#     @{distname_list}    create list
#     @{p_name_list}    create list
#     FOR  ${id}  IN  @{id_list}
#         ${dist_name}    Catenate  SEPARATOR=-    ${NRCELL_ID}    ${id}
#         APPEND TO LIST   ${distname_list}    ${dist_name}
#         APPEND TO LIST   ${p_name_list}    ${p_name}
#     END
#     [Return]  ${distname_list}    ${p_name_list}
# 
# Modify Parameter By SCF
#     scf.load_scf       file_path=${default_scf}
#     ${distname_list3}    ${p_name_list3}    Generate corresponding distname list    id_list=${cell_id_list}    p_name=ccLoadThreshold
#     Modify Ordinary Parameter Value    dist_name_list=${distname_list3}    p_name_list=${p_name_list3}    new_value_list=${value_list2}
#     scf.save_scf        file_path=${output_dir}/Modify_scf.xml
# 
# Determine whether to lock based on RU status
#     [Arguments]    ${lock_ru_list}    ${bts_host}    ${BTS_ID}    ${ru_expect_status}=${RU_lock_status}
#     ${lock_ru_status}    Create Dictionary
#     @{tmp_ru_list}    create list
#     FOR    ${ru_id}    IN    @{lock_ru_list}
#         APPEND TO LIST    ${tmp_ru_list}    ${ru_id}
#         Set To Dictionary    ${lock_ru_status}    RMOD-${ru_id}    ${ru_expect_status}
#     END
#     ${status_list}    Check All RU or Cell Status    expect_item_status_dict=${lock_ru_status}    if_ru=${True}    bts_host=${bts_host}
#     ${length}    Get length    ${lock_ru_list}
#     FOR    ${item}   IN RANGE    ${length}
#         Run Keyword If    @{status_list}[${item}] == ${True}    Remove Values From List     ${lock_ru_list}    @{tmp_ru_list}[${item}]
#         log to console    ${tmp_ru_list}
#     END
#     Lock or Unlock RU And Check Status    lock_RU_id_list=${lock_ru_list}     lock_flag=${True}    bts_host=${bts_host}    BTS_ID=${BTS_ID}
# 
# Check All RU or Cell Status
#     [Documentation]  expect_item_status_dict eg:
#     ...              1) ${cell_status_dict}    Create Dictionary     NRCELL-1=${Cell_unblock_status}    NRCELL-2=${Cell_block_status}
#     ...              2) ${ru_status_dict}    Create Dictionary     RMOD-1=${RU_unlock_status}    RMOD-2=${RU_lock_status}
#     [Arguments]  ${expect_item_status_dict}    ${if_ru}=${True}   ${bts_host}=${gnb_ip}
#     Log To Console    Check All RU or Cell Status
#     ${item_status_dic}    Get All RU or Cell Status    if_ru=${if_ru}    bts_host=${bts_host}    connection=GNB_OAM
#     @{item_id_list}    get dictionary keys    ${expect_item_status_dict}
#     @{status_list}    create list
#     FOR  ${item_id}  IN  @{item_id_list}
#         ${expect_status_list}     get from dictionary    ${expect_item_status_dict}    ${item_id}
#         ${item_status}    set variable    ${item_status_dic['${item_id}']}
#         ${status}    run keyword and return status
#         ...    Run Keyword If    ${if_ru}    Check Single RU Status    item_status=${item_status}    expect_status_list=${expect_status_list}
#         ...    ELSE    Check Single Cell Status    item_status=${item_status}    expect_status_list=${expect_status_list}
#         append to list    ${status_list}    ${status}
#     END
#     [Return]  ${status_list}
# 
# Check Single RU Status
#     [Arguments]  ${item_status}    ${expect_status_list}
#     ${admin_status}    get from dictionary    ${item_status}    administrativeState
#     Run Keyword And Continue On Failure    should be equal as strings   ${admin_status}    ${expect_status_list[${0}]}
#     ${operate_status}    get from dictionary    ${item_status}    operationalState
#     Run Keyword And Continue On Failure    should be equal as strings    ${operate_status}    ${expect_status_list[${1}]}
#     ${usage_status}    get from dictionary    ${item_status}    usageState
#     Run Keyword And Continue On Failure    should be equal as strings    ${usage_status}    ${expect_status_list[${2}]}
#     ${procedure_status}    get from dictionary    ${item_status}    proceduralStatus
#     Run Keyword And Continue On Failure    should be equal as strings    ${procedure_status}    ${expect_status_list[${3}]}
# 
# Check Single Cell Status
#     [Arguments]  ${item_status}    ${expect_status_list}
#     Check Single RU Status    item_status=${item_status}    expect_status_list=${expect_status_list}
#     ${block_status}    get from dictionary    ${item_status}    blockingState
#     Run Keyword And Continue On Failure    should be equal as strings   ${block_status}    ${expect_status_list[${-1}]}
# 
# Get All RU or Cell Status
#     [Arguments]  ${if_ru}=${True}    ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM
#     Log to console    Get All RU or Cell Status
#     ${item_status_dic}    Create Dictionary
#     Connect to gnb coam via ssl    bts_host=${bts_host}    username=${WEBUI_USER}    password=${WEBUI_PWD}    connection=${connection}
#     ${ru_info_list}    coam.get_frm    connection=${connection}
#     ${cell_info_list}     coam.Get_Cells_Info   cell_type=nr    connection=${connection}
#     ${item_info_list}    set variable if    ${if_ru}    ${ru_info_list}    ${cell_info_list}
#     ${count_item}    Get Length    ${item_info_list}
#     FOR  ${item}  IN RANGE   ${count_item}
#         ${item_id_info}  Split String  ${item_info_list[${item}]['id']['configuration']}  separator=/
#         ${item_id}    set variable    ${item_id_info[-1]}
#         ${item_status}    set variable    ${item_info_list[${item}]['status']}
#         set to dictionary    ${item_status_dic}    ${item_id}=${item_status}
#     END
#     [Return]  ${item_status_dic}
#     [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
# 
# Lock or Unlock RU And Check Status
#     [Arguments]  ${BTS_ID}   ${lock_RU_id_list}=${empty_list}     ${unlock_RU_id_list}=${empty_list}    ${lock_flag}=${T
# ...rue}   ${bts_host}=${gnb_ip}
#     ${operate_ru_id_list}    Set Variable If    ${lock_flag}    ${lock_RU_id_list}    ${unlock_RU_id_list}
#     Lock or UnLock Multiple RU    RMOD_id_list=${operate_ru_id_list}    lock_flag=${lock_flag}    bts_host=${bts_host}    BTS_ID=${BTS_ID}
#     ${expect_item_status_dict}    create dictionary
#     FOR  ${item}  IN    @{lock_RU_id_list}
#         Set to dictionary    ${expect_item_status_dict}    RMOD-${item}=${RU_lock_status}
#     END
#     FOR  ${item1}  IN   @{unlock_RU_id_list}
#         Set to dictionary    ${expect_item_status_dict}    RMOD-${item1}=${RU_unlock_status}
#     END
#     Check All RU or Cell Status    expect_item_status_dict=${expect_item_status_dict}    if_ru=${True}    bts_host=${bts_host}
# 
# Lock or UnLock Multiple RU
#     [Arguments]    ${RMOD_id_list}   ${BTS_ID}    ${lock_flag}=${True}    ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM    ${timeout}=60
#     Connect to gnb coam via ssl    bts_host=${bts_host}    username=${WEBUI_USER}    password=${WEBUI_PWD}    connection=${connection}
#     FOR  ${RMOD_id}  IN  @{RMOD_id_list}
#         ${dist_name}    Set Variable    MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${RMOD_id}
#         Run keyword if    ${lock_flag}==${True}    Log To Console    Lock RMOD-${RMOD_id}
#         ...    ELSE    Log To Console    UnLock RMOD-${RMOD_id}
#         Run keyword if    ${lock_flag}==${True}    coam.lock    dist_name=${dist_name}    timeout=${timeout}    connection=${connection}
#         ...    ELSE    coam.unlock    dist_name=${dist_name}    timeout=${timeout}    connection=${connection}
#         sleep    8s
#     END
#     [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
# 
# Start X2 log capture on gNB
#     [Documentation]    Will start tcpdump process to capture on interface which has the external IP addr.
#     [Arguments]     ${log_name}=gnbX2    ${gnb_index}=${0}    ${du_index}=${0}    ${alias}=ASIK Master
#     ${external_ip_addr}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
#     Connect to Common Unit Master    alias=${alias}    gnb_index=${gnb_index}    du_index=${du_index}
#     ssh.send_command    command=ifconfig | grep -B1 "${external_ip_addr}" | head -n 1 | awk -F':' '{print $1}'    connection=${alias}
#     Start pcap trace capturing by tcpdump1    log_name=${log_name}    interface=any    remote_log_dir=/tmp    alias=${alias}
# 
# Start pcap trace capturing by tcpdump1
#     [Documentation]    Start tcpdump process on ${interface}, save to file ${remote_log_dir}/${log_name}.
#     [Arguments]   ${log_name}    ${interface}    ${remote_log_dir}=/tmp    ${alias}=ASIK Master
#     ${remote_log_path}    join path    ${remote_log_dir}    ${log_name}.pcap
#     csn.send command    command=nohup tcpdump sctp -i ${interface} -s 0 -w ${remote_log_path}     connection=${alias}
#     sleep    2s    reason=wait for process to start.
#     Trace capturing process should be triggered    log_prefix=${log_name}    connection_alias=${alias}