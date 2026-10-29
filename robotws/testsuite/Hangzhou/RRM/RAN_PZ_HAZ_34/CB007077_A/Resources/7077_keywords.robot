*** Settings ***
Resource           ./7077_variables.robot
Resource          ./../../CB005750_FDAB/Resources/5750_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/rrm_log_check.robot
Resource          taf/rfrl/bts/robot/common/gnb_cell.robot

*** Keywords ***
7077 Suite setup
     [Arguments]     ${scf_template_path}=${SCF_TEMPLATE_FILE_PATH_7077}   ${is_need_to_require_ue}=${True}    ${is_pdl_checking_needed}=${False}
     ...    ${enb_default_scf_file}=${ENB_DEFAULT_SCF_FILE_7077}
     [Documentation]    author: Ren Biyao

     Connect to Common Unit Master
     ${SCF_PATH}     Get Substring    ${CURDIR}  0  -44
     ${TL_NAME}   set variable     ${testline_name}
     ${pattern}   Set Variable    7_5(.*)
     ${TLNAME}    Get Regexp Matches     ${TL_NAME}    ${pattern}    1
     ${testlinename}   Set Variable    7_5${TLNAME}[0]
     set suite variable     ${SCF_PATH}
     set suite variable     ${testlinename}
     COAM Create log directory    is_set_to_test_case_level=${False}
     import variables    commissionings/HGZ/${testlinename}/CB007077/Delta_SCF.py
     import variables    commissionings/HGZ/${testlinename}/__init__.py
     ${cur_program}    gnb_classical_hangzhou.Get program version based on stream version
     set suite variable    ${PROGRAM}    ${cur_program}
     import variables    ${CURDIR}/../Resources/7077_nidd_scf_modify.py
     Suite common setup preparation    cluster_start_up_timeout=${RECOVERY_TIMEOUT}    scf_template_path=${scf_template_path}
     ...    is_pdl_checking_needed=${is_pdl_checking_needed}    scf_modify_parameters=${TL_PARAMS_TO_MODIFY_SA}
     ...    enb_index=0
     ...    enb_default_scf_file=${enb_default_scf_file}
     Make SgNBAddition on specific cell     gnb_ps_cell_index=${1}
     ${UE_TYPE}    run keyword if    ${is_need_to_require_ue}    ue.translate_power_ue_type_from_testline
     run keyword if    ${is_need_to_require_ue}     set suite variable     ${UE_TYPE}
     run keyword if    ${is_need_to_require_ue}    power_ue.Prepare UE    ue_type=${UE_TYPE}
     ${UE_TYPE2}    run keyword if    ${is_need_to_require_ue}    ue.translate_power_ue_type_from_testline    ue_index=${1}
     run keyword if    ${is_need_to_require_ue}     set suite variable     ${UE_TYPE2}
     run keyword if    ${is_need_to_require_ue}    power_ue.Prepare UE    ue_type=${UE_TYPE2}    ue_index=${1}
     Run keyword if    '${tl.attenuators}'!='[None]'
     ...    Initialize attenuator values for testline    pa_values_mapping=${INIT_PA}    if_change_ENB_PA=${False}
     ...        NSA_SA=NSA

Lock or unlock AMF on gnb side
    [Arguments]    ${parameters_to_update_via_api}
    [Documentation]    author: Ren Biyao
    Connect to gnb coam via ssl
    ${update_status}    COAM Update several parameters via rest api    connection=GNB_OAM
    ...     parameters_to_update_via_api=${parameters_to_update_via_api}    timeout=6 min
    Should be true    '${update_status}'=='PASS'
    [Teardown]      run keyword and ignore error      COAM Teardown gnb connections

Drop ng link
    [Documentation]    author: Ren Biyao
    ...      X2: 36422     sctp:38412
    ${is_asib}    If ASIB card used    du_index=${0}    alias=ASIK Master    gnb_index=${0}
    run keyword if    ${is_asib}
    ...    csn.send command    command=iptables -t filter -I INPUT -p sctp --dport 38412 -j DROP     connection=ASIK Master
    ...    ELSE
    ...    Drop ng link via nftables
    sleep    2s

Drop ng link via nftables
    [Documentation]    author: Ren Biyao
    ${ori_rule}    csn.execute    command=nft list ruleset |grep 38412 |grep "ip dscp set ef"    connection=ASIK Master
    ${ori_rule}    Strip string    ${ori_rule}
    csn.send command    command=nft insert rule ip route POSTROUTING ${ori_rule} drop   connection=ASIK Master

Recover ng link via nftables
    [Documentation]    author: Ren Biyao
    ${handle_number}    csn.execute    command=nft list ruleset -a|grep 38412|grep drop|awk '{print $27,$28}'    connection=ASIK Master
    ${handle_number}    Strip string    ${handle_number}
    csn.send command    command=nft delete rule ip route POSTROUTING ${handle_number}    connection=ASIK Master

Recover ng link
    [Documentation]    author: Ren Biyao
    ${is_asib}    If ASIB card used    du_index=${0}    alias=ASIK Master    gnb_index=${0}
    ${asik_route}    catenate    nft add rule ip route PREROUTING sctp sport { 38412 } sctp dport { 38412 }
    ...    ip daddr { ${tl.gnbs[${0}].dus[${0}].f1_m_ip_addr} } counter packets 1528 bytes 138608 jump CPLANE_5G
    run keyword if    ${is_asib}
    ...    csn.send command    command=iptables -D INPUT -p sctp --dport 38412 -j DROP     connection=ASIK Master
    ...    ELSE
    ...    Recover ng link via nftables
    sleep    2s

Post case recovery
    [Documentation]    author: Ren Biyao
    [Arguments]    ${is_need_to_detach_ue}=${True}   ${is_need_to_recover_link}=${True}
    run keyword if    ${is_need_to_detach_ue}    power_ue.UE Detach    ue_type=${UE_TYPE2}    ue_index=${1}
    run keyword if    ${is_need_to_detach_ue}    power_ue.UE Detach    ue_type=${UE_TYPE}    ue_index=${0}
    run keyword if    ${is_need_to_recover_link}    Recover route
    Connect to Common Unit Master
    Lock or unlock x2 link on gnb side    parameters_to_update_via_api=${GNB_UNLOCK_VIA_API}
    Lock or unlock AMF on gnb side    parameters_to_update_via_api=${AMF1_UNLOCK_VIA_API}
    Lock or unlock AMF on gnb side    parameters_to_update_via_api=${AMF2_UNLOCK_VIA_API}
    COAM Teardown gnb connections
    Run keyword and ignore error    Tear down all SISO connections

Get cell barring status
    [Documentation]   author: Ren Biyao
    ...               Description: return cell status info DICT.
    ...                            Key are availabilityStatus,administrativeState,operationalState
    [Arguments]  ${cell_idx}=${1}   ${cell_group_idx}=${0}   ${timeout}=10   ${connection}=GNB_OAM
    Connect to gnb coam via ssl
    ${cell_idx}   Convert To Integer   ${cell_idx}
    ${cell_group_idx}  Convert To Integer    ${cell_group_idx}
    ${cell_info}    coam.get_cells_info    cell_type=nr    timeout=${timeout}    connection=${connection}
    [Return]      ${cell_info[0]}
    [Teardown]      run keyword and ignore error      COAM Teardown gnb connections

Cell should be barred
    [Documentation]   author: Ren Biyao
    ${barring_status}    Get cell barring status
    ${barring_key}    run keyword and return status    set variable   ${barring_status}    ${barring_status["barringStatus"]}
    run keyword if    ${barring_key}    Should contain   ${barring_status["barringStatus"]}    barred
    ...   ELSE     Should contain    ${barring_status["status"]["barringStatus"]}    barred


Cell should be unbarred
    [Documentation]   author: Ren Biyao
    ${barring_status}    Get cell barring status
    ${barring_key}    run keyword and return status    set variable   ${barring_status}    ${barring_status["barringStatus"]}
    run keyword if    ${barring_key}    Should contain   ${barring_status["barringStatus"]}    unbarred
    ...   ELSE     Should contain    ${barring_status["status"]["barringStatus"]}    unbarred


Cell should be deactived and unbarred
    [Documentation]   author: Ren Biyao
    ${deactive}   Get cell barring status
    Should Be Equal As Strings  ${deactive["status"]["operationalState"]}       Disabled    ignore_case=${True}
    Should Be Equal As Strings  ${deactive["status"]["administrativeState"]}    Unlocked    ignore_case=${True}
    Should Contain Any  ${deactive["status"]["availabilityStatus"]}     Offline    off line    ignore_case=${True}

BTS reset and capture cellsetup log
    [Documentation]   author: Ren Biyao
    [Arguments]    ${is_all_cells_checking_needed}=${False}    ${list_cell_index}=1
    run keyword and ignore error     csn.disconnect    connection=ASIK Master
    Connect to gnb coam via ssl
    COAM delete objects via rest api    objects_to_delete_via_api=${DELETE_AMF_OBJ}
    coam.reset_site    connection=GNB_OAM
    wait until keyword succeeds   3min    1s      Connect to gnb coam via ssl
    Wait until keyword succeeds   3min    1s      COAM Check GNB ASIK status
    Wait until keyword succeeds   3min    1s      COAM Check GNB ABIL status
    wait until keyword succeeds   3min    1s      Connect to Common Unit Master
    run keyword and ignore error    Connect to Common Unit Slave
    wait until keyword succeeds   3min    1s    Start CP-IF Log Collection
    run keyword and continue on failure     Wait until cluster is on cell on air status    timeout=10min
    ...    is_all_cells_checking_needed=${is_all_cells_checking_needed}
    ...    is_x2_check_from_enb_needed=${False}    is_enb_status_check_needed=${False}    list_cell_index=${list_cell_index}
    sleep     10s
    ${7077_cpif}    Stop tcpdump log collection    target_dir=${TS_CASE_LOG_PATH}
    Load pcap with filter    filter_expression=f1ap    command_template=${PDML_CONVERT_F1AP_TEMPLATE}
    ...    pcap_file=${7077_cpif}
    ${pdml_file}    run keyword and continue on failure    Get pdml log    tcpdump_log=${7077_cpif}

    ${cellid_relation}    coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids
    ${nrcellid1}   set variable  ${cellid_relation[1]}[nrCellIdentity]
    ${nrcellid2}   set variable  ${cellid_relation[1]}[nrCellIdentity]
    ${cell_num}    get length    ${cellid_relation}
    run keyword if    ${cell_num}==${1}   run    echo "service-state: in-service" >> ${TS_CASE_LOG_PATH}/ng_msg_7886.txt
    ...    ELSE     run keywords    run   echo "id-Served-Cells-To-Delete-Item" >> ${TS_CASE_LOG_PATH}/ng_msg_7886.txt   AND
    ...    run   echo "decimal value ${nrcellid2}" >> ${TS_CASE_LOG_PATH}/ng_msg_7886.txt
    ${check_msg_status}   run keyword and return status    check_tcpdump_msg
    ...    msg_file=${TS_CASE_LOG_PATH}/ng_msg_7886.txt   tcpdump_pdml=${pdml_file}
    run keyword and continue on failure    should be true    ${check_msg_status}    msg check fail!
    run keyword if    ${check_msg_status}    run    rm ${7077_cpif}
    run keyword if    ${check_msg_status}    run    rm ${pdml_file}

    [Teardown]    core.stop_collectors    names=cpif_tcpdump

collect Enb Snapshot Log
   [Documentation]    Author: jun.8.chen@nokia-sbell.com
   [Arguments]    ${enb_index}=${0}    ${connection}=enblte_${enb_index}    ${log_path}=${TS_CASE_LOG_PATH}    ${timeout}=${1200}
   Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}    connection=${connection}
   ${snapshot_file_path}    COAM Save snapshot via rest api    connection=${connection}    log_path=${log_path}    timeout=${timeout}
   [Return]    ${snapshot_file_path}
   [Teardown]    Run Keyword And Ignore Error    Enblte close down    connection=${connection}
