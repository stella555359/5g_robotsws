*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/Resources/case_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot

Documentation
...   This is for CA feature CB007873 keywords.
...   author: Cui Lingxue
...   contact: lingxue.cui@nokia-sbell.com
...   squad group: MMW_SG1

*** Variables ***

*** Keywords ***
7873 Suite preparation
    [Arguments]    ${NSA_SA}=SA    ${enb_default_scf_file}=${None}    ${import_nidd_needed}=${True}  ${swconfig_modify}=${None}
    run keyword if    '${import_nidd_needed}'=='True'    Import NIDD variables
    set suite variable    ${PARAMS_TO_MODIFY}    ${MODIFY_SCF_DEFAULT_ALIGNBWP}
    set suite variable    ${PARAMS_TO_DELETE}    ${DELETE_NRREL}

    CA Suite preparation    prepare_ue=${True}    NSA_SA=${NSA_SA}    enb_default_scf_file=${enb_default_scf_file}
    ...   swconfig_modify=${swconfig_modify}


Mobility suite preparation
#    ${CA_GROUP_INDEX_INTRA_FREQ}    set variable if    '${testline_name}'=='7_5_UTE5G402T049'    2    0
#    ${CA_GROUP_INDEX_INTRA_FREQ}    set variable     0
#    set suite variable    ${CA_GROUP_INDEX_INTRA_FREQ}
    Import NIDD variables
    import variables        testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/TestData/mobility_nidd_modify_scf.py
    COAM Create log directory    is_set_to_test_case_level=${False}

    log to console    Start to commission adjacent gNB...
    ${adj_gnb_scf_template_processed}    scfpro.SCFProcess    scf_template_path=${ADJ_SCF_DEFAULT_FILE_PATH}    scf_process_folder=${SUITE_LOG_PATH}
    ...    list_para_to_delete=${SCF_ADJ_GNB_DELETE_BEFORE_CASE}
    ...    list_para_to_modify=${SCF_ADJ_GNB_MODIFY_DEFAULT_MOBILITY}
    ...    list_para_to_add=${SCF_ADJ_GNB_ADD_MO_DEFAULT_MOBILITY}
    Preparation with swconfig modification and comissioning
    ...    swconfig_modify=${None}    swconfig_template_path=${ADJ_SWCONFIG_DEFAULT_FILE_PATH}
    ...    scf_modify=${PARAMS_TO_MODIFY_SCF}    scf_template_path=${adj_gnb_scf_template_processed}
    ...    gnb_index=${1}    connection=${ADJ_GNB_OAM_ALIAS}    alias=${ADJ_GNB_ASIK_ALIAS}

    Connect to gnb coam via ssl    gnb_index=${1}    connection=${ADJ_GNB_OAM_ALIAS}
    &{ADJ_GNB_NR_CELL_ID_MAPPING}  coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids  connection_alias=${ADJ_GNB_OAM_ALIAS}
    Set suite variable    ${ADJ_GNB_NR_CELL_ID_MAPPING}
    Wait until cluster is on cell on air status    is_all_cells_checking_needed=${True}
    ...    is_need_to_setup_gnb_connection=${False}    connection=${ADJ_GNB_OAM_ALIAS}
    ...    is_enb_status_check_needed=${False}    is_x2_check_from_enb_needed=${False}
    Change status for parameter cellBarred on GNB    exp_status=notBarred   list_cell_ids=1    gnb_index=${1}
    ...    connection=${ADJ_GNB_OAM_ALIAS}    timeout=${TIMER_FOR_MODIFY_VIA_API}

    Enable cplane debug log on gNB
    set suite variable    ${PARAMS_TO_ADD}       ${SCF_ADD_MO_DEFAULT_MOBILITY}
    set suite variable    ${PARAMS_TO_MODIFY}    ${SCF_MODIFY_DEFAULT_MOBILITY}
    ${SCF_NIDD_DELETE}    combine lists    ${SCF_DELETE_BEFORE_CASE}    ${DELETE_NRREL}
    set suite variable    ${PARAMS_TO_DELETE}    ${SCF_NIDD_DELETE}

    CA Suite preparation
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections    connection=${ADJ_GNB_OAM_ALIAS}

Case restoration and teardown
    [Arguments]    ${wa_flag}=${False}    ${detach_ue}=${True}    ${restapi_restore_nidd}=${None}    ${is_log_required}=${IS_LOG_CAPTURED_CASE_LEVEL}
    ...    ${is_need_to_clear_tcpdump}=${False}
    run keyword if    ${wa_flag}    WA force UE attach to FDD cell
    Common case teardown    detach_ue=${detach_ue}    restapi_restore_nidd=${restapi_restore_nidd}    is_log_required=${is_log_required}
    run keyword if    ${is_need_to_clear_tcpdump}    Kill tcpdump on asik slave or asib master

Mobility case setup
    [Arguments]    ${nidd_modify_via_api}=${None}    ${nidd_modify_on_target_gnb}=${None}    ${NSA_SA}=SA    ${intra_freq}=${False}
    _refactor PCELL_ID if match condition    intra_freq=${intra_freq}
    Common case setup    nidd_modify_via_api=${nidd_modify_via_api}    timeout_restapi=${TIMER_FOR_MODIFY_VIA_API}
    ...    is_log_required=${True}    NSA_SA=${NSA_SA}
    run keyword if    '${NSA_SA}'=='SA'
    ...    Change status for parameter cellBarred on GNB    exp_status=notBarred   list_cell_ids=${PCELL_ID}    timeout=${TIMER_FOR_MODIFY_VIA_API}
    Block adjacent gNB RUs
    Initialize PA ports of PCell RU
    Block PA ports of non-used RUs

    Connect to gnb coam via ssl    gnb_index=${1}    connection=${ADJ_GNB_OAM_ALIAS}
    run keyword if    ${nidd_modify_on_target_gnb}!=${None}
    ...    Modify NIDD by rest api and wait onair    parameters=${nidd_modify_on_target_gnb}    NSA_SA=SA    connection=${ADJ_GNB_OAM_ALIAS}
    Connect to Common Unit Master    alias=${ADJ_GNB_ASIK_ALIAS}    gnb_index=${1}
    run keyword and ignore error    Download SCF file to log path    connection=${ADJ_GNB_OAM_ALIAS}

Mobility case teardown
    [Arguments]    ${wa_flag}=${False}    ${restapi_restore_nidd}=${None}
    Initialize attenuator values for testline    pa_values_mapping=${INIT_PA_F_T}
    Collect logs in teardown    gnb_index=${1}   connection=${ADJ_GNB_ASIK_ALIAS}    is_btslog_required=${False}
    Case restoration and teardown    wa_flag=${wa_flag}    detach_ue=${True}    restapi_restore_nidd=${restapi_restore_nidd}
    ...    is_need_to_clear_tcpdump=${True}    is_log_required=${True}

    Kill tcpdump on asik slave or asib master    gnb_index=${1}    asik_alias=${ADJ_GNB_ASIK_ALIAS}    asik_slave_alias=${ADJ_GNB_ASIK_ALIAS}_SLAVE
    COAM Teardown gnb connections    connection=${ADJ_GNB_OAM_ALIAS}
    ssh.disconnect    connection=${ADJ_GNB_ASIK_ALIAS}
    ssh.reset_cache

########## throughput verification

Data transmission only on FDD Cell
    [Documentation]    Author: Cui Lingxue
    ...    Check throughput on all cells, the expectation is:
    ...        - DL: data transfer only on FDD Cell, tput on TDD Cell is 0.
    ...        - UL: data transfer only on FDD Cell, tput on TDD Cell is 0.
    [Arguments]    ${dl_cell_id}=${PCELL_ID},${SCELL_ID}    ${ul_cell_id}=${PCELL_ID},${SCELL_ID}
    Check Tput info for each cell    dl_cell_id=${dl_cell_id}    exp_dl=${PCELL_EXP_DL},0    ul_cell_id=${ul_cell_id}    exp_ul=${PCELL_EXP_UL},0

Set 5GC001390 active without 5GC002255 and check PDL error
    [Documentation]   author: Wang Yixiang
    ...    Activate feature 5GC001390 by setting carrierAggregationSupportList enumeration parameter to 2 (ca_Fdd_Fr1Tdd)
    ...    PDL rule triggers error message indicating that activation of "FDD  FR1-TDD CA" feature 5GC001390 is not possible
    ...    and activation requires that "Enabler for Inter Band CA between CCs with different numerologies" feature 5GC002255 is activated.
    log to console    /*** Activate feature 5GC001390 without 5GC002255 and check PDL error ***/
    ${validation_error}    Modify NIDD via webUI and get PDL error    parameters=${ACTIVE_5GC001390_VIA_WEBUI_PDL_ERROR}
    should contain    container=${validation_error}    item=actInterNumerologyCa (value: false) equal to true
    ...    msg=Activate feature 5GC001390 without 5GC002255 should raise PDL error
    log to console    Validation error:${validation_error}
    [Teardown]     run keyword and ignore error     COAM selenium logout

Activate feature 5GC001390 and 5GC002255 by rest api
    [Documentation]   author: Wang Yixiang
    ...    Activate feature 5GC001390 by setting carrierAggregationSupportList=ca_Fdd_Fr1Tdd
    ...    Active feature 5GC002255 by setting actInterNumerologyCa=true
    [Arguments]     ${parameters}=${ACTIVE_5GC002255_5GC001390_RESTAPI}    ${timeout}=${TIMER_FOR_MODIFY_VIA_API}
    Modify NIDD by rest api and wait onair    parameters=${parameters}    timeout=${timeout}

Deactivate feature 5GC001390 and 5GC002255 by rest api
    [Documentation]   author: Wang Yixiang
    ...    Deactivate feature 5GC001390 by setting carrierAggregationSupportList=none
    ...    Deactive feature 5GC002255 by setting actInterNumerologyCa=false
    [Arguments]     ${parameters}=${DEACTIVE_5GC002255_5GC001390_RESTAPI}    ${timeout}=${TIMER_FOR_MODIFY_VIA_API}
    Modify NIDD by rest api and wait onair    parameters=${parameters}    timeout=${timeout}

Deactivate feature 5GC001390 by carrierAggregationSupportList to none
    [Documentation]   author: Wang Yixiang
    ...    Deactivate feature 5GC001390 by setting carrierAggregationSupportList=none via rest api
    [Arguments]     ${parameters}=${DEACTIVE_5GC001390_RESTAPI}    ${timeout}=${TIMER_FOR_MODIFY_VIA_API}
    Modify NIDD by rest api and wait onair    parameters=${parameters}    timeout=${timeout}

Set PCell primaryPathMaxQueueingDelay=10 and SCell secondaryPathMaxQueueingDelay=0
    [Arguments]    ${NSA_SA}=SA
    ${pcell_priPathDelay}    evaluate
    ...    [dict(dist_name='${DN_PCELL_LIST[0]}', parameter='primaryPathMaxQueueingDelay', value='10')]
    ${scell_secPathDelay}    evaluate
    ...    [dict(dist_name='${DN_SCELL_LIST[0]}', parameter='secondaryPathMaxQueueingDelay', value='0')]
    ${parameters_list}    combine lists    ${pcell_priPathDelay}    ${scell_secPathDelay}
    log to console  Set PCell primaryPathMaxQueueingDelay=10 and SCell secondaryPathMaxQueueingDelay=0
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters_list}
    ${is_enb_status_check_needed}     set variable if    '${NSA_SA}'=='SA'    ${False}    ${True}
    ${is_x2_check_from_enb_needed}    set variable if    '${NSA_SA}'=='SA'    ${False}    ${True}
    Wait until cluster is on cell on air status    timeout=${TIMER_FOR_MODIFY_VIA_API}
    ...    is_enb_status_check_needed=${is_enb_status_check_needed}
    ...    is_x2_check_from_enb_needed=${is_x2_check_from_enb_needed}
    ...    is_all_cells_checking_needed=${True}

Set PCell primaryPathMaxQueueingDelay=0 and SCell secondaryPathMaxQueueingDelay=10
    [Arguments]    ${NSA_SA}=SA
    ${pcell_priPathDelay}    evaluate
    ...    [dict(dist_name='${DN_PCELL_LIST[0]}', parameter='primaryPathMaxQueueingDelay', value='0')]
    ${scell_secPathDelay}    evaluate
    ...    [dict(dist_name='${DN_SCELL_LIST[0]}', parameter='secondaryPathMaxQueueingDelay', value='10')]
    log to console  Set PCell primaryPathMaxQueueingDelay=0 and SCell secondaryPathMaxQueueingDelay=10
    ${parameters_list}    combine lists    ${pcell_priPathDelay}    ${scell_secPathDelay}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters_list}
    ${is_enb_status_check_needed}     set variable if    '${NSA_SA}'=='SA'    ${False}    ${True}
    ${is_x2_check_from_enb_needed}    set variable if    '${NSA_SA}'=='SA'    ${False}    ${True}
    Wait until cluster is on cell on air status    timeout=${TIMER_FOR_MODIFY_VIA_API}
    ...    is_enb_status_check_needed=${is_enb_status_check_needed}
    ...    is_x2_check_from_enb_needed=${is_x2_check_from_enb_needed}
    ...    is_all_cells_checking_needed=${True}

Restore PathMaxQueueingDelay
    [Arguments]    ${NSA_SA}=SA
    ${pcell_priPathDelay}    evaluate
    ...    [dict(dist_name='${DN_PCELL_LIST[0]}', parameter='primaryPathMaxQueueingDelay', value='10')]
    ${scell_secPathDelay}    evaluate
    ...    [dict(dist_name='${DN_SCELL_LIST[0]}', parameter='secondaryPathMaxQueueingDelay', value='10')]
    ${parameters_list}    combine lists    ${pcell_priPathDelay}    ${scell_secPathDelay}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters_list}
    ${is_enb_status_check_needed}     set variable if    '${NSA_SA}'=='SA'    ${False}    ${True}
    ${is_x2_check_from_enb_needed}    set variable if    '${NSA_SA}'=='SA'    ${False}    ${True}
    Wait until cluster is on cell on air status    timeout=${TIMER_FOR_MODIFY_VIA_API}
    ...    is_enb_status_check_needed=${is_enb_status_check_needed}
    ...    is_x2_check_from_enb_needed=${is_x2_check_from_enb_needed}
    ...    is_all_cells_checking_needed=${True}

Remove NIDD sCellAdditionMethod via restapi
    [Documentation]   author: Cui Lingxue
    ...    Removing nidd parameter sCellAdditionMethod via restapi. Verify cell is on-air after modification.
    [Arguments]   ${FDD_ID}=${PCELL_ID}    ${NSA_SA}=SA
    ${remove_sCellAdditionMethod}    evaluate
    ...    [dict(dist_name='MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${FDD_ID}/NRREL-1', parameter='sCellAdditionMethod')]
    COAM delete parameters via rest api    parameters_to_delete_via_api=${remove_sCellAdditionMethod}    timeout=${TIMER_FOR_MODIFY_VIA_API}
    ${is_enb_status_check_needed}     set variable if    '${NSA_SA}'=='SA'    ${False}    ${True}
    ${is_x2_check_from_enb_needed}    set variable if    '${NSA_SA}'=='SA'    ${False}    ${True}
    Wait until cluster is on cell on air status    timeout=${TIMER_FOR_CELL_ON_AIR}
    ...    is_enb_status_check_needed=${is_enb_status_check_needed}
    ...    is_x2_check_from_enb_needed=${is_x2_check_from_enb_needed}
    ...    is_all_cells_checking_needed=${True}

Remove NIDD sCellAdditionMethod via restapi and verify performance
    [Documentation]   author: Wang Yixiang
    ...    21A:  Remove sCellAdditionMethod and data continue transmission on both pcell and scell
    ...    21B and Trunk: Remove sCellAdditionMethod, pcell will lock and unlock, and there is have a msg:PDUSessionResourceReleaseCommand
    [Arguments]   ${NSA_SA}=SA
    run keyword if    '${PROGRAM}'!='21A'    Run keywords    Change status for parameter cellBarred on GNB    exp_status=notBarred    AND
    ...    Start capture F1AP log    tcpdump_collector_name=lock_unlock
    Remove NIDD sCellAdditionMethod via restapi
    ${tcpdump_log}    run keyword if    '${PROGRAM}'!='21A'    Stop tcpdump log collection    tcpdump_collector_name=lock_unlock
    run keyword if    '${PROGRAM}'=='21A'    run keyword and continue on failure  Data transimission on both Pcell and Scell
    ...  ELSE IF   '${NSA_SA}'=='SA'    Change status for parameter cellBarred on GNB    exp_status=notBarred   list_cell_ids=${PCELL_ID}
    [Teardown]    run keyword if    '${PROGRAM}'!='21A'    run keyword and ignore error
    ...    Stop Tcpdump via collector    tcpdump_collector_name=lock_unlock

Add NIDD sCellAdditionMethod via restapi
    [Documentation]   author: Cui Lingxue
    ...    Add nidd parameter sCellAdditionMethod=blind via restapi. Verify cell is on-air after modification.
    [Arguments]   ${FDD_ID}=${PCELL_ID}    ${NSA_SA}=SA
    ${add_sCellAdditionMethod}    evaluate
    ...    [dict(dist_name='MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${FDD_ID}/NRREL-1', parameter='sCellAdditionMethod', value='blind')]
    COAM Update several parameters via rest api    parameters_to_update_via_api=${add_sCellAdditionMethod}    timeout=${TIMER_FOR_MODIFY_VIA_API}
    ${is_enb_status_check_needed}     set variable if    '${NSA_SA}'=='SA'    ${False}    ${True}
    ${is_x2_check_from_enb_needed}    set variable if    '${NSA_SA}'=='SA'    ${False}    ${True}
    Wait until cluster is on cell on air status    timeout=${TIMER_FOR_CELL_ON_AIR}
    ...    is_enb_status_check_needed=${is_enb_status_check_needed}
    ...    is_x2_check_from_enb_needed=${is_x2_check_from_enb_needed}
    ...    is_all_cells_checking_needed=${True}

Activate feature 5GC001390 by setting carrierAggregationSupportList to ca_Fdd_Fr1Tdd
    [Documentation]   author: Cui Lingxue
    ...    Add nidd parameter carrierAggregationSupportList=ca_Fdd_Fr1Tdd via restapi. Verify cell is on-air after modification.
    [Arguments]   ${NSA_SA}=SA
    ${dist_name}    set variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
    ${update_carrierAggregationSupportList}    evaluate
    ...    [dict(dist_name='${dist_name}', parameter='carrierAggregationSupportList', value=${carrierAggregationSupportList})]
    COAM Update several parameters via rest api    parameters_to_update_via_api=${update_carrierAggregationSupportList}
    ...    timeout=${TIMER_FOR_MODIFY_VIA_API}
    ${is_enb_status_check_needed}     set variable if    '${NSA_SA}'=='SA'    ${False}    ${True}
    ${is_x2_check_from_enb_needed}    set variable if    '${NSA_SA}'=='SA'    ${False}    ${True}
    Wait until cluster is on cell on air status    timeout=${TIMER_FOR_CELL_ON_AIR}
    ...    is_enb_status_check_needed=${is_enb_status_check_needed}
    ...    is_x2_check_from_enb_needed=${is_x2_check_from_enb_needed}
    ...    is_all_cells_checking_needed=${True}

Lock FDD cell via rest api
    [Arguments]    ${graceful_shutdown}=${False}   ${cell_group_idx}=${PCELLNRCELLGRPID}  ${cell_idx}=${PCELL_ID}
    ...    ${timeout}=${TIMER_FOR_CELL_ON_AIR}
    run keyword if    ${graceful_shutdown}    Lock cell with graceful cell shutdown    cell_idx=${cell_idx}
    ...    ELSE    Perform cell lock via rest api    cell_idx=${cell_idx}
    Wait Until Keyword Succeeds    ${timeout}    3 sec    Cell Should Be Locked    cell_idx=${cell_idx}    cell_group_idx=${cell_group_idx}

Unlock FDD cell via rest api
    [Arguments]   ${cell_group_idx}=${PCELLNRCELLGRPID}  ${cell_idx}=${PCELL_ID}
    Perform cell unlock via rest api    cell_idx=${cell_idx}
    Wait Until Keyword Succeeds    90 sec    3 sec    Cell Should Be Unlocked    cell_idx=${cell_idx}    cell_group_idx=${cell_group_idx}

Lock TDD cell via rest api
    [Arguments]    ${graceful_shutdown}=${False}   ${cell_group_idx}=${SCELLNRCELLGRPID}  ${cell_idx}=${SCELL_ID}
    run keyword if    ${graceful_shutdown}    Lock cell with graceful cell shutdown    cell_idx=${cell_idx}
    ...    ELSE    Perform cell lock via rest api    cell_idx=${cell_idx}
    Wait Until Keyword Succeeds    90 sec    3 sec    Cell Should Be Locked    cell_idx=${cell_idx}    cell_group_idx=${cell_group_idx}

Unlock TDD cell via rest api
    [Arguments]   ${cell_group_idx}=${SCELLNRCELLGRPID}    ${cell_idx}=${SCELL_ID}
    Perform cell unlock via rest api    cell_idx=${cell_idx}
    Wait Until Keyword Succeeds    90 sec    3 sec    Cell Should Be Unlocked    cell_idx=${cell_idx}    cell_group_idx=${cell_group_idx}

Enable graceful shutdown function
    [Arguments]    ${NSA_SA}=SA
    Modify NIDD by rest api and wait onair    parameters=${RESTAPI_EABLE_GRACEFUL_SHUTDOWN}    NSA_SA=${NSA_SA}

Trigger BBMOD reset via webui
    [Documentation]   author: Ren Biyao
    [Arguments]     ${abil_index}
    COAM Navigate to login page via webUI
    Start capture F1AP log    tcpdump_collector_name=abil_reset_debug
    selenium_coam.reset_abil    abil_index=${abil_index}
#    wait until keyword succeeds    2min    1s    Check BBMOD disabled    abil_index=${abil_index}
    wait until keyword succeeds    2min    1s    bbmod Should Be offline    bbmod_index=${abil_index}
    sleep    50s
    ${abil_reset_debug}    Stop tcpdump log collection    tcpdump_collector_name=abil_reset_debug
    [Teardown]     run keyword and ignore error    run keywords    COAM selenium logout
    ...    AND    core.stop_collectors    names=abil_reset_debug
    [Return]    ${abil_reset_debug}

Check BBMOD disabled
    [Documentation]   author: Ren Biyao
    [Arguments]     ${abil_index}
    ${ABIL_info}    selenium_coam.get_abil_info     abil_index=${abil_index}
    should be equal   ${ABIL_info['Status']['Availability status']}    Offline
    should be equal   ${ABIL_info['Status']['Operational state']}    Disabled

Initialize PA ports of PCell RU
    [Documentation]    Author: Cui Lingxue
    Initialize attenuator for specified RU    exp_pa_value=${INIT_PA_VALUE_${MRBTS_ID}}    ru_index=${PCELL_RU_INDEX}

Initialize PA ports of adjacent gNB RUs
    [Documentation]    Author: Cui Lingxue
    ...    Initilize PA ports of adjacent gNB FDD and TDD RUs, to let UE access in.
    Initialize attenuator for specified RU    ru_index=${0}    gnb_index=${1}    exp_pa_value=${INIT_PA_VALUE_${ADJ_MRBTS_ID}_RU_0}
    Initialize attenuator for specified RU    ru_index=${1}    gnb_index=${1}    exp_pa_value=${INIT_PA_VALUE_${ADJ_MRBTS_ID}_RU_1}

Block adjacent gNB RUs
    [Documentation]    Author: Cui Lingxue
    ...    Block PA ports of adjacent gNB FDD and TDD RUs, to avoid UE access in.
    ${number_of_gnbs}    get_length    ${tl.gnbs}
    return from keyword if    ${number_of_gnbs}<2
    ${number_of_rus}     get_length    ${tl.gnbs[${1}].dus[0].rus}
    FOR    ${ru_index}    IN RANGE    ${number_of_rus}
        Block attenuator for specified RU    ru_index=${ru_index}    gnb_index=${1}
    END

Block PA ports of non-used RUs
    [Documentation]    Author: Cui Lingxue
    ...    Block signal of unused RUs by setting PA value to max. This is to avoid unexpected interference.
    [Arguments]    ${gnb_index}=${0}    ${unblock_ru_index}=${PCELL_RU_INDEX},${SCELL_RU_INDEX}
    ${unblock_ru_index}    string2list    ${unblock_ru_index}
    ${number_of_rus}     get_length    ${tl.gnbs[${gnb_index}].dus[0].rus}
    FOR    ${ru_index}    IN RANGE    ${number_of_rus}
        ${ru_index}    evaluate    str(${ru_index})
        ${status}    run keyword and return status    list_should_contain_value    ${unblock_ru_index}    ${ru_index}
        continue for loop if    ${status}
        Block attenuator for specified RU    ru_index=${ru_index}    gnb_index=${gnb_index}
    END

Modify NRREL's lcrid and check UE released
    [Documentation]    Author: Wang Yixiang
    ...    Modify NRREL's lcrid will trigger cell lock unlock, UE will released
    Change status for parameter cellBarred on GNB    exp_status=notBarred
    Modify NRREL's lcrid via restapi    lcrid=${PCELL_LIST[2]['lcrId']}
    Basic_L3_call_No_CA    exp_dl=50,0
    Start capture F1AP log    tcpdump_collector_name=lock_unlock_lcrid
    Modify NRREL's lcrid via restapi    lcrid=${SCELL_LIST[0]['lcrId']}
    ${tcpdump_log}    Stop tcpdump log collection    tcpdump_collector_name=lock_unlock_lcrid
    Verify PDUSessionResourceReleaseCommand in tcpdump    tcpdump_log=${tcpdump_log}
    Change status for parameter cellBarred on GNB    exp_status=notBarred   list_cell_ids=${PCELL_ID}
    [Teardown]    run keyword and ignore error    Stop Tcpdump via collector    tcpdump_collector_name=lock_unlock_lcrid

_refactor PCELL_ID if match condition
    [Documentation]    Author: Cui Lingxue
    ...    For intra-freq case on TL49, use NRCELL-4 as PCell, for other situation, PCELL is same for intra-freq and inter-freq case.
    [Arguments]    ${intra_freq}=${False}
    return from keyword if    '${intra_freq}'=='${False}' or '${CA_GROUP_INDEX}'=='${CA_GROUP_INDEX_INTRA_FREQ}'
    set test variable   ${CA_GROUP_INDEX}    ${CA_GROUP_INDEX_INTRA_FREQ}
    set test variable   ${PCELL_ID}    ${PCELL_LIST[${CA_GROUP_INDEX}]['nrCellId']}
    set test variable   ${SCELL_ID}    ${SCELL_LIST[${CA_GROUP_INDEX}]['nrCellId']}
    set test variable   ${PCELL_RU_INDEX}    ${PCELL_LIST[${CA_GROUP_INDEX}]['ru_index_in_testline_file']}
    set test variable   ${SCELL_RU_INDEX}    ${SCELL_LIST[${CA_GROUP_INDEX}]['ru_index_in_testline_file']}

# # to be obsolete
