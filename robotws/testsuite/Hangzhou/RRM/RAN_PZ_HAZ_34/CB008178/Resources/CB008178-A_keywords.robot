*** Settings ***
Documentation    CB008178 NR Beam level PM Counters
Resource     CB008178-A_variables.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/Resources/case_keywords.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/common_resources.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/container_log_capturing.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/logs.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/nr_rim.robot

*** Keywords ***
Set variables for 8178
   [Documentation]    Set variables for 8178
   ...    Author: Jiang Xian
   [Arguments]   ${frame_bw}
    Connect to gnb coam via ssl   connection=${OAM_ALIAS_GNB0}    gnb_index=${0}
    Connect to gnb coam via ssl   connection=${OAM_ALIAS_GNB1}    gnb_index=${1}
    ${DICT_Cell_IDS_TECH}    get_cell_ids_based_on_cell_technology
    set suite variable    ${DICT_Cell_IDS_TECH}
    ${cur_program}    gnb_classical_hangzhou.Get program version based on stream version
    set suite variable    ${PROGRAM}    ${cur_program}
    ${CELL_MAPPING}    coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids  connection_alias=${OAM_ALIAS_GNB0}
    set suite variable    ${CELL_MAPPING}
    set suite variable    ${NRBTS_ID}                 ${tl.gnbs[0].global_bts_id}
    import variables    ${commissionings_path}/HGZ/${testline_name}/__init_8178__.py
    import variables    ${CURDIR}/../TestData/NIDD_modify_scf_common.py
    import variables    ${CURDIR}/../TestData/NIDD_Modify_data_template.py
    import variables    ${CURDIR}/../TestData/NIDD_modify_scf_${frame_bw}.py
    #import variables    ${CURDIR}/../TestData/NIDD_modify_scf_restapi.py
    [Teardown]  Run keywords    COAM Teardown gnb connections    connection=${OAM_ALIAS_GNB0}   AND
    ...    COAM Teardown gnb connections    connection=${OAM_ALIAS_GNB1}

8178 Suite preparation multiGNB
    [Documentation]    8178 Suite preparation
    ...    Author: Jiang Xian
    [Arguments]   ${frame_bw}    ${NSA_SA}=${NSA_SA}
    ...   ${gnb_num}=${1}
    Run keyword if    '${tl.attenuators}'!='[None]'
    ...    Initialize attenuator values for testline    pa_values_mapping=${INIT_PA_F_T}
    ...    NSA_SA=${NSA_SA}
    Set variables for 8178   frame_bw=${frame_bw}

    ${scf_name_suffix}
    ...    set variable if   '${frame_bw}'=='90M_1116_3ms_4GP' and '${testline_name}'=='7_5_UTE5G402T052'   _TMO   ${None}

    log to console    Start to commission GNB...
    Rim suite common setup preparation   prepare_ue=${True}
    Comissioning and Wait for Cell on air multiGNB    NSA_SA=${NSA_SA}    gnb_num=${gnb_num}    scf_name_suffix=${scf_name_suffix}
    Connect to gnb coam via ssl   connection=${OAM_ALIAS_GNB1}    gnb_index=${1}
    run keyword and ignore error    Lock cells    lock_cell_list=@{CELL_LIST_GNB1}   lock_cell_connection=${OAM_ALIAS_GNB1}

8178 case teardown
    [Documentation]    8178 case teardown
    ...    Author: Jiang Xian
    [Arguments]    ${detach_ue}=${True}    ${frame_bw}=${None}    ${connection_GNB1}=${OAM_ALIAS_GNB1}
    log to console    start to unlock victim(GNB1) cell in case teardown
    run keyword and ignore error   Unlock cells    lock_cell_list=@{CELL_LIST_GNB1}   lock_cell_connection=${connection_GNB1}
    coam_gnb_classical.COAM Teardown gnb connections    connection=${connection_GNB1}
    ${scf_name_suffix}
    ...    set variable if   '${frame_bw}'=='90M_1116_3ms_4GP' and '${testline_name}'=='7_5_UTE5G402T052'   _TMO   ${None}
    ${scf_template_path}     Set Variable if  '${scf_name_suffix}'=='${None}'
    ...   /home/ute/Projects/mmw1_config/${testline_name}/scf/SCF_MMW1_TL${NRBTS_ID}.xml
    ...   /home/ute/Projects/mmw1_config/${testline_name}/scf/SCF_MMW1_TL${NRBTS_ID}${scf_name_suffix}.xml
    run keyword and ignore error   Restore SCF in case teardown     scf_file_path_for_restore=${scf_template_path}
    run keyword and ignore error   Common case teardown    detach_ue=${detach_ue}    is_btslog_required=${False}    is_log_required=${True}


Sleep If Minute Is 5n+4
    ${current_time}    Get Current Date    result_format=%M
    log to console    current time is ${current_time}
    ${minute}    Convert To Integer    ${current_time}
    ${remainder}    Evaluate    ${minute} % 5
    Run Keyword If    ${remainder} == 4    Sleep    60s

Disable pSRS Beam feature via restAPI
    [Arguments]    ${timeout}=${TIMER_FOR_MODIFY_VIA_API}    ${cell_id}=1
    ${actDlSrsBm}    evaluate
    ...    dict(dist_name='NRBTS-${NRBTS_ID}/NRCELL-${cell_id}', parameter='actDlSrsBm', value='false')
    ${actUlSrsBm}    evaluate
    ...    dict(dist_name='NRBTS-${NRBTS_ID}/NRCELL-${cell_id}', parameter='actUlSrsBm', value='false')
    ${actPdschBeamPowerBalance}    evaluate
    ...    dict(dist_name='NRBTS-${NRBTS_ID}/NRCELL-${cell_id}', parameter='actPdschBeamPowerBalance', value='false')
    ${actCsirsBeamPowerBalance}    evaluate
    ...    dict(dist_name='NRBTS-${NRBTS_ID}/NRCELL-${cell_id}', parameter='actCsirsBeamPowerBalance', value='false')
    ${actDlRankProbing}    evaluate
    ...    dict(dist_name='NRBTS-${NRBTS_ID}/NRCELL-${cell_id}', parameter='actDlRankProbing', value='false')
    ${actDlSrsForCA}    evaluate
    ...    dict(dist_name='NRBTS-${NRBTS_ID}/NRCELL-${cell_id}', parameter='actDlSrsForCA', value='false')
    ${actDlSrsSubbandBm}    evaluate
    ...    dict(dist_name='NRBTS-${NRBTS_ID}/NRCELL-${cell_id}', parameter='actDlSrsSubbandBm', value='false')
    ${actSrsUlBeamFallbackByRetrx}    evaluate
    ...    dict(dist_name='NRBTS-${NRBTS_ID}/NRCELL-${cell_id}', parameter='actSrsUlBeamFallbackByRetrx', value='false')
    ${actSrsBeamFallbackByRetrx}    evaluate
    ...    dict(dist_name='NRBTS-${NRBTS_ID}/NRCELL-${cell_id}', parameter='actSrsBeamFallbackByRetrx', value='false')
    ${actDlMuMimoEnh}    evaluate
    ...    dict(dist_name='NRBTS-${NRBTS_ID}/NRCELL-${cell_id}', parameter='actDlMuMimoEnh', value='false')
    ${actMuAwareTdSch}    evaluate
    ...    dict(dist_name='NRBTS-${NRBTS_ID}/NRCELL-${cell_id}/NRDLMUMIMO-1', parameter='actMuAwareTdSch', value='false')
    ${actUlMuMimo}    evaluate
    ...    dict(dist_name='NRBTS-${NRBTS_ID}/NRCELL-${cell_id}', parameter='actUlMuMimo', value='false')
    ${actAdaptiveReTxResMcsEnh}    evaluate
    ...    dict(dist_name='NRBTS-${NRBTS_ID}/NRCELL-${cell_id}', parameter='actAdaptiveReTxResMcsEnh', value='false')
    ${params_to_upd}    create list    ${actDlSrsBm}  ${actUlSrsBm}  ${actPdschBeamPowerBalance}
    ...    ${actCsirsBeamPowerBalance}  ${actDlRankProbing}  ${actDlSrsForCA}  ${actDlSrsSubbandBm}  ${actSrsUlBeamFallbackByRetrx}
    ...    ${actSrsBeamFallbackByRetrx}  ${actDlMuMimoEnh}  ${actMuAwareTdSch}  ${actUlMuMimo}  ${actAdaptiveReTxResMcsEnh}

    COAM Update several parameters via rest api    parameters_to_update_via_api=${params_to_upd}    timeout=${timeout}
    Wait until cluster ready based on NSA_SA type      NSA_SA=${NSA_SA}
    Wait until cluster is on cell on air status    timeout=${TIMER_FOR_CELL_ON_AIR}
    ...    is_enb_status_check_needed=${false}
    ...    is_x2_check_from_enb_needed=${false}
    ...    is_all_cells_checking_needed=${True}

Disable 5GC002200-PMI Beam feature via restAPI
    [Arguments]    ${timeout}=${TIMER_FOR_MODIFY_VIA_API}    ${cell_id}=1
    ${dlMimoMode}    evaluate
    ...    dict(dist_name='NRBTS-${NRBTS_ID}/NRCELL-${cell_id}', parameter='dlMimoMode', value='4x4 or 4x2 Closed Loop Spatial Multiplexing')
    ${actTddCsiImRm}    evaluate
    ...    dict(dist_name='NRBTS-${NRBTS_ID}', parameter='actTddCsiImRm', value='false')
    ${params_to_upd}    create list   ${dlMimoMode}  ${actTddCsiImRm}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${params_to_upd}    timeout=${timeout}

    ${remove_periodicCsiAcquisition}    evaluate
    ...    [dict(dist_name='NRBTS-${NRBTS_ID}/NRCELL-${cell_id}', parameter='periodicCsiAcquisition')]
    COAM delete parameters via rest api    parameters_to_delete_via_api=${remove_periodicCsiAcquisition}    timeout=${TIMER_FOR_MODIFY_VIA_API}

    Wait until cluster ready based on NSA_SA type      NSA_SA=${NSA_SA}
    Wait until cluster is on cell on air status    timeout=${TIMER_FOR_CELL_ON_AIR}
    ...    is_enb_status_check_needed=${false}
    ...    is_x2_check_from_enb_needed=${false}
    ...    is_all_cells_checking_needed=${True}

Set miNrMacPduTput to 5min
    [Arguments]    ${timeout}=${TIMER_FOR_MODIFY_VIA_API}
    ${miNrMacPduTput}    evaluate
    ...    dict(dist_name='NRBTS-${NRBTS_ID}/NRPMRNL-1', parameter='miNrMacPduTput', value='5min')
    ${params_to_upd}    create list    ${miNrMacPduTput}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${params_to_upd}    timeout=${timeout}
    Wait until cluster ready based on NSA_SA type      NSA_SA=${NSA_SA}
