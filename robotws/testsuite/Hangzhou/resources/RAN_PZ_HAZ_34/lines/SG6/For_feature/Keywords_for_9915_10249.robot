*** Settings ***
Documentation    Author: Stella
...              Contact: Stella.lin@nokia-sbell.com


*** Keywords ***
Activate PRB Blank For 9915
    [Arguments]    ${cell_index}=303
    ...            ${bwpDN_index_common}=17
    ...            ${bwpDN_index_dedicate}=177
    ...            ${bwpDN_index_powersaving}=10077
    ...            ${actPRBBlanking}=true
    ...            ${nbrOfBlankedPRBsHighEdgeDL}=3
    ...            ${nbrOfBlankedPRBsHighEdgeUL}=3
    ...            ${nbrOfBlankedPRBsLowEdgeDL}=3
    ...            ${nbrOfBlankedPRBsLowEdgeUL}=3
    ...            ${skip_parameter_relation_errors}=False
    ...            ${update_powersaving_bwpDN_index_powersaving}=${True}
    Log To Console    \n***start to Activate PRB Blanking for ${cell_index} ***
    ${update_bwpDN}    catenate   {'dist_name': 'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}',
    ...    'parameter':'cellBwpList',
    ...    'value':[{'bwpDN':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-${bwpDN_index_common}','cellBwpId':'0'},
    ...    {'bwpDN':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-${bwpDN_index_dedicate}','cellBwpId':'1'}]}
    ${update_bwpDN_SBTS00}    catenate   {'dist_name': 'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}',
    ...    'parameter':'cellBwpList',
    ...    'value':[{'bwpDN':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-${bwpDN_index_common}','cellBwpId':'0'},
    ...    {'bwpDN':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-${bwpDN_index_dedicate}','cellBwpId':'1'},
    ...    {'bwpDN':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-${bwpDN_index_powersaving}','cellBwpId':'2'}]}
    ${update_actprbblank}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}',
    ...    'parameter':'actPRBBlanking','value':'${actPRBBlanking}'}
    ${update_nbrOfBlankedPRBsHighEdgeDL}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}',
    ...    'parameter':'nbrOfBlankedPRBsHighEdgeDL','value':'${nbrOfBlankedPRBsHighEdgeDL}'}
    ${update_nbrOfBlankedPRBsHighEdgeUL}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}',
    ...    'parameter':'nbrOfBlankedPRBsHighEdgeUL','value':'${nbrOfBlankedPRBsHighEdgeUL}'}
    ${update_nbrOfBlankedPRBsLowEdgeDL}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}',
    ...    'parameter':'nbrOfBlankedPRBsLowEdgeDL','value':'${nbrOfBlankedPRBsLowEdgeDL}'}
    ${update_nbrOfBlankedPRBsLowEdgeUL}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}',
    ...    'parameter':'nbrOfBlankedPRBsLowEdgeUL','value':'${nbrOfBlankedPRBsLowEdgeUL}'}
    ${all_update_params}    catenate    ${update_bwpDN},${update_actprbblank},${update_nbrOfBlankedPRBsHighEdgeDL},
    ...    ${update_nbrOfBlankedPRBsHighEdgeUL},${update_nbrOfBlankedPRBsLowEdgeDL},${update_nbrOfBlankedPRBsLowEdgeUL},
    ${all_update_params_SBTS00}    catenate    ${update_bwpDN_SBTS00},${update_actprbblank},${update_nbrOfBlankedPRBsHighEdgeDL},
    ...    ${update_nbrOfBlankedPRBsHighEdgeUL},${update_nbrOfBlankedPRBsLowEdgeDL},${update_nbrOfBlankedPRBsLowEdgeUL},
    ${update_param_branch}     evaluate    [${all_update_params}]
    ${update_param_SBTS00}     evaluate    [${all_update_params_SBTS00}]
    ${update_param}    Set Variable IF
    ...    ('${stream_version}'=='master' or '${stream_version}'=='26R2') and ${update_powersaving_bwpDN_index_powersaving}
    ...    ${update_param_SBTS00}    ${update_param_branch}
    Common_keywords.Update Params Via RestApi    params_need_to_modify=${update_param}    gnb_index=0
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}

Activate PRB Blank For 9915_E006
    [Arguments]    ${cell_index}=1
    ...            ${bwpDN_index_common}=1008
    ...            ${bwpDN_index_dedicate}=187
    ...            ${bwpDN_index_powersaving}=10187
    ...            ${actPRBBlanking}=true
    ...            ${nbrOfBlankedPRBsHighEdgeDL}=9
    ...            ${nbrOfBlankedPRBsHighEdgeUL}=9
    ...            ${nbrOfBlankedPRBsLowEdgeDL}=9
    ...            ${nbrOfBlankedPRBsLowEdgeUL}=9
    ...            ${startRB}=8
    ...            ${skip_parameter_relation_errors}=False
    ...            ${cSRS}=56
    Log To Console    \n***start to Activate PRB Blanking for ${cell_index} ***
    ${update_bwpDN}    catenate   {'dist_name': 'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}',
    ...    'parameter':'cellBwpList',
    ...    'value':[{'bwpDN':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-${bwpDN_index_common}','cellBwpId':'0'},
    ...    {'bwpDN':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-${bwpDN_index_dedicate}','cellBwpId':'1'}]}
    ${update_bwpDN_SBTS00}    catenate   {'dist_name': 'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}',
    ...    'parameter':'cellBwpList',
    ...    'value':[{'bwpDN':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-${bwpDN_index_common}','cellBwpId':'0'},
    ...    {'bwpDN':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-${bwpDN_index_dedicate}','cellBwpId':'1'},
    ...    {'bwpDN':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-${bwpDN_index_powersaving}','cellBwpId':'2'}]}
    ${update_actprbblank}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}',
    ...    'parameter':'actPRBBlanking','value':'${actPRBBlanking}'}
    ${update_nbrOfBlankedPRBsHighEdgeDL}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}',
    ...    'parameter':'nbrOfBlankedPRBsHighEdgeDL','value':'${nbrOfBlankedPRBsHighEdgeDL}'}
    ${update_nbrOfBlankedPRBsHighEdgeUL}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}',
    ...    'parameter':'nbrOfBlankedPRBsHighEdgeUL','value':'${nbrOfBlankedPRBsHighEdgeUL}'}
    ${update_nbrOfBlankedPRBsLowEdgeDL}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}',
    ...    'parameter':'nbrOfBlankedPRBsLowEdgeDL','value':'${nbrOfBlankedPRBsLowEdgeDL}'}
    ${update_nbrOfBlankedPRBsLowEdgeUL}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}',
    ...    'parameter':'nbrOfBlankedPRBsLowEdgeUL','value':'${nbrOfBlankedPRBsLowEdgeUL}'}
    ${update_csrs}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}',
    ...    'parameter':'srsForBeamMgmt','value':[{'cSRS':'${cSRS}'}]}
    ${update_startRB}    catenate    {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}',
    ...                                'parameter':'csirsForTracking','value':[{'startRB':'${startRB}'}]}
    ${all_update_params}    catenate    ${update_bwpDN},${update_actprbblank},${update_nbrOfBlankedPRBsHighEdgeDL},
    ...    ${update_nbrOfBlankedPRBsHighEdgeUL},${update_nbrOfBlankedPRBsLowEdgeDL},${update_nbrOfBlankedPRBsLowEdgeUL},
    ...    ${update_csrs}
    ${all_update_params_SBTS00}    catenate    ${update_bwpDN_SBTS00},${update_actprbblank},${update_nbrOfBlankedPRBsHighEdgeDL},
    ...    ${update_nbrOfBlankedPRBsHighEdgeUL},${update_nbrOfBlankedPRBsLowEdgeDL},${update_nbrOfBlankedPRBsLowEdgeUL},
    ...    ${update_csrs},${update_startRB}
    ${update_param_branch}     evaluate    [${all_update_params}]
    ${update_param_SBTS00}     evaluate    [${all_update_params_SBTS00}]
    ${update_param}    Set Variable IF    '${stream}'=='SBTS00' or '${stream_version}'=='26R2'    ${update_param_SBTS00}    ${update_param_branch}
    Common_keywords.Update Params Via RestApi    params_need_to_modify=${update_param}    gnb_index=0
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}


Activate PRB Blank For 9915_B10
    [Arguments]    ${pcell_index}=303    ${scell_index}=401    ${update_powersaving_bwpDN_index_powersaving}=${True}
    Activate PRB Blank For 9915    cell_index=${pcell_index}
    ...                            update_powersaving_bwpDN_index_powersaving=${update_powersaving_bwpDN_index_powersaving}
    Activate PRB Blank For 9915    cell_index=${scell_index}
    ...                            bwpDN_index_common=17
    ...                            bwpDN_index_dedicate=172
    ...                            actPRBBlanking=true
    ...                            nbrOfBlankedPRBsHighEdgeDL=9
    ...                            nbrOfBlankedPRBsHighEdgeUL=9
    ...                            nbrOfBlankedPRBsLowEdgeDL=9
    ...                            nbrOfBlankedPRBsLowEdgeUL=9
    ...                            update_powersaving_bwpDN_index_powersaving=${update_powersaving_bwpDN_index_powersaving}

Activate PRB Blank For 9915_B_B4
    [Arguments]    ${cell_index}=402    ${update_powersaving_bwpDN_index_powersaving}=${True}
    Activate PRB Blank For 9915    cell_index=${cell_index}
    ...                            bwpDN_index_common=17
    ...                            bwpDN_index_dedicate=712
    ...                            actPRBBlanking=true
    ...                            nbrOfBlankedPRBsHighEdgeDL=1
    ...                            nbrOfBlankedPRBsHighEdgeUL=1
    ...                            nbrOfBlankedPRBsLowEdgeDL=1
    ...                            nbrOfBlankedPRBsLowEdgeUL=1
    ...                            update_powersaving_bwpDN_index_powersaving=${update_powersaving_bwpDN_index_powersaving}
    ${update_slimRfFilterDL}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}',
    ...    'parameter':'slimRfFilterDL','value':'49.5MHz'}
    ${update_slimRfFilterUL}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}',
    ...    'parameter':'slimRfFilterUL','value':'49.5MHz'}
    ${update_param}     evaluate    [${update_slimRfFilterDL},${update_slimRfFilterUL}]
    Common_keywords.Update Params Via RestApi    params_need_to_modify=${update_param}    gnb_index=0

Activate PRB Blank For 10249_B_B4
    [Arguments]    ${cell_index}=4
    Activate PRB Blank For 9915    cell_index=${cell_index}
    ...                            bwpDN_index_common=17
    ...                            bwpDN_index_dedicate=712
    ...                            actPRBBlanking=true
    ...                            nbrOfBlankedPRBsHighEdgeDL=3
    ...                            nbrOfBlankedPRBsHighEdgeUL=3
    ...                            nbrOfBlankedPRBsLowEdgeDL=3
    ...                            nbrOfBlankedPRBsLowEdgeUL=3
    ${update_slimRfFilterDL}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}',
    ...    'parameter':'slimRfFilterDL','value':'38.5MHz'}
    ${update_slimRfFilterUL}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}',
    ...    'parameter':'slimRfFilterUL','value':'38.5MHz'}
    ${update_param}     evaluate    [${update_slimRfFilterDL},${update_slimRfFilterUL}]
    Common_keywords.Update Params Via RestApi    params_need_to_modify=${update_param}    gnb_index=0

Activate PRB Blank For 9915_B_B2
    [Arguments]    ${cell_index}=402
    Activate PRB Blank For 9915    cell_index=${cell_index}
    ...                            bwpDN_index_common=17
    ...                            bwpDN_index_dedicate=714
    ...                            actPRBBlanking=true
    ...                            nbrOfBlankedPRBsHighEdgeDL=9
    ...                            nbrOfBlankedPRBsHighEdgeUL=9
    ...                            nbrOfBlankedPRBsLowEdgeDL=9
    ...                            nbrOfBlankedPRBsLowEdgeUL=9
    ${update_slimRfFilterDL}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}',
    ...    'parameter':'slimRfFilterDL','value':'34MHz'}
    ${update_slimRfFilterUL}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}',
    ...    'parameter':'slimRfFilterUL','value':'34MHz'}
    ${update_param}     evaluate    [${update_slimRfFilterDL},${update_slimRfFilterUL}]
    Common_keywords.Update Params Via RestApi    params_need_to_modify=${update_param}    gnb_index=0

Activate PRB Blank For 9915_A13
    [Arguments]    ${pcell_index}=301    ${scell_index}=401    ${bwp_dn_index}=172    ${update_powersaving_bwpDN_index_powersaving}=${True}
    Activate PRB Blank For 9915    cell_index=${pcell_index}
    ...                            update_powersaving_bwpDN_index_powersaving=${update_powersaving_bwpDN_index_powersaving}
    Activate PRB Blank For 9915    cell_index=${scell_index}
    ...                            bwpDN_index_common=17
    ...                            bwpDN_index_dedicate=${bwp_dn_index}
    ...                            actPRBBlanking=true
    ...                            nbrOfBlankedPRBsHighEdgeDL=9
    ...                            nbrOfBlankedPRBsHighEdgeUL=9
    ...                            nbrOfBlankedPRBsLowEdgeDL=9
    ...                            nbrOfBlankedPRBsLowEdgeUL=9
    ...                            update_powersaving_bwpDN_index_powersaving=${update_powersaving_bwpDN_index_powersaving}

Get Required BIP File
    [Arguments]    ${bip_list}    ${filter}
#    ${bip_file_filter}    Evaluate    [x for x in ${bip_list} if '${filter}' in x and x.endswith('.pcap0')]
    ${bip_file_filter}    Evaluate    [x for x in ${bip_list} if '${filter}' in x]
    Sort List    ${bip_file_filter}
    [Return]    ${bip_file_filter[-1]}

Check StartPrb And NumOfPrb On UlData_PuschReceiveReq
    [Arguments]    ${file_path}    ${pci}=333    ${expect_startprb}=8    ${expect_numofprb}=257
    ${filter_with_pci}    Set Variable    3gpp.dmrsScramblingSequenceInt==${pci}
    Setup Pcap File   file_path=${file_path}    filter=uldata_puschreceivereq
    ${start_prb_list}    Get Field Value From PCAP    field_name=UlData_puschReceiveReqGrant_t.startPrb
    ...                                               filter_expression=${filter_with_pci}
    ${start_prb_length}    Get Length    ${start_prb_list}
    Should Be True    ${start_prb_length}>${1}    msg=no valid data on UlData_PuschReceiveReq filter out.please check the bip log.
    ${start_prb_list_new}    Evaluate   [int(x[0]) for x in ${start_prb_list}]
    ${start_prb_actual}    Evaluate   min(${start_prb_list_new})
    Run Keyword And Continue On Failure    Should Be True    ${start_prb_actual}==int(${expect_startprb})
    ...    msg=ul start prb is not ${expect_startprb} on UlData_PuschReceiveReq, actual is ${start_prb_actual}.
    ${number_prb_list}    Get Field Value From PCAP    field_name=UlData_puschReceiveReqGrant_t.numOfPrb
    ...                                               filter_expression=${filter_with_pci}
    ${number_prb_list_new}    Evaluate   [int(x[0]) for x in ${number_prb_list}]
    ${number_prb_actual}    Evaluate   max(${number_prb_list_new})
    Run Keyword And Continue On Failure    Should Be True    ${number_prb_actual}==int(${expect_numofprb})
    ...    msg=ul number of prb is not ${expect_numofprb} on UlData_PuschReceiveReq,actual is ${number_prb_actual}.

Check StartPrb And NumOfPrb On DlData_PdschSendreq
    [Arguments]    ${file_path}    ${pci}=333    ${expect_startprb}=16   ${expect_numofprb}=240
    ...            ${dldata_pdschsendreq}=dldata_pdschsendreq    ${DlData_PdschGrant}=DlData_PdschGrant
    ${filter_with_pci}    Set Variable    3gpp.dmrsScramblingSequenceInt==${pci}
    Setup Pcap File   file_path=${file_path}    filter=${dldata_pdschsendreq}
    ${start_prb_list}    Get Field Value From PCAP    field_name=${DlData_PdschGrant}.startPrb
    ...                                               filter_expression=${filter_with_pci}
    ${start_prb_length}    Get Length    ${start_prb_list}
    Should Be True    ${start_prb_length}>${1}    msg=no valid data on dldata_pdschsendreq filter out.please check the bip log.
    ${start_prb_list_new}    Evaluate   [int(x[0]) for x in ${start_prb_list}]
    ${start_prb_actual}    Evaluate   min(${start_prb_list_new})
    Run Keyword And Continue On Failure    Should Be True    ${start_prb_actual}==int(${expect_startprb})
    ...    msg=ul start prb is not ${expect_startprb} on UlData_PuschReceiveReq, actual is ${start_prb_actual}.
    ${number_prb_list}    Get Field Value From PCAP    field_name=${DlData_PdschGrant}.numOfPrb
    ...                                               filter_expression=${filter_with_pci}
    ${number_prb_list_new}    Evaluate   [int(x[0]) for x in ${number_prb_list}]
    ${number_prb_actual}    Evaluate   max(${number_prb_list_new})
    Run Keyword And Continue On Failure    Should Be True    ${number_prb_actual}==int(${expect_numofprb})
    ...    msg=dl number of prb is not ${expect_numofprb} on UlData_PuschReceiveReq, actual is ${number_prb_actual}.

Check StartPrb And NumOfPrb On DlData_PdschSendreq For B_B2
    [Arguments]    ${file_path}    ${pci}=422    ${expect_startprb}=16    ${expect_numofprb}=80
    ...            ${dldata_pdschsendreq}=dldata_pdschsendreq    ${DlData_PdschGrant}=DlData_PdschGrant
    ${filter_with_pci}    Set Variable    3gpp.dmrsScramblingSequenceInt==${pci}
    Setup Pcap File   file_path=${file_path}    filter=${dldata_pdschsendreq}
    ${number_prb_list}    Get Field Value From PCAP    field_name=${DlData_PdschGrant}.numOfPrb
    ...                                               filter_expression=${filter_with_pci}
    ${number_prb_list_new}    Evaluate   [int(x[0]) for x in ${number_prb_list}]
    ${number_prb_actual}    Evaluate   max(${number_prb_list_new})
    Run Keyword And Continue On Failure    Should Be True    ${number_prb_actual}==int(${expect_numofprb})
    ...    msg=dl number of prb is not ${expect_numofprb} on UlData_PuschReceiveReq, actual is ${number_prb_actual}.
    ${start_prb_list}    Get Field Value From PCAP    field_name=${DlData_PdschGrant}.startPrb
    ...                                               filter_expression=${filter_with_pci} && ${DlData_PdschGrant}.numOfPrb==${expect_numofprb}
    ${start_prb_length}    Get Length    ${start_prb_list}
    Should Be True    ${start_prb_length}>${1}    msg=no valid data on UlData_PuschReceiveReq filter out.please check the bip log.
    ${start_prb_list_new}    Evaluate   [int(x[0]) for x in ${start_prb_list}]
    ${start_prb_actual}    Evaluate   min(${start_prb_list_new})
    Run Keyword And Continue On Failure    Should Be True    ${start_prb_actual}==int(${expect_startprb})
    ...    msg=ul start prb is not ${expect_startprb} on UlData_PuschReceiveReq, actual is ${start_prb_actual}.

Check_Point_For_10249_Via_Snapshot
    [Arguments]    ${timeout}=${1800}    ${ru_index}=${2}    ${check_point_value}=NR49_5   ${file_name}=a011_gandalf    ${prefix_name}=BTS
    ${snapshot_file_path}    Common_keywords.Collect Snapshot Log    timeout=${timeout}
    ${ru_index}    Set Variable    ${ru_index}
    ${check_point}    Set Variable    ${check_point_value}
    ${Serial_number}    Set Variable    ${tl.gnbs[0].dus[0].rus[${ru_index}-1].serial_number}
    Run    mkdir ${TS_CASE_LOG_PATH}/Snapshot/
    ${snapshot}     Set Variable    ${TS_CASE_LOG_PATH}/Snapshot
    Run    unzip ${snapshot_file_path} -d ${TS_CASE_LOG_PATH}/Snapshot/
    Sleep    60sec
    Run    cat ${snapshot}/snapshot_file_list.txt | grep -i "part\\|${prefix_name}_${Serial_number}.*${file_name}" > ${snapshot}/part.txt
    Run    cat ${snapshot}/part.txt | grep -B1 -i "${prefix_name}_${Serial_number}.*${file_name}" > ${snapshot}/logpath.txt
    ${log_path2}    Run    cat ${snapshot}/logpath.txt | grep part
    ${log_path3}    Fetch From Left    ${log_path2}    :
    Run    unzip ${snapshot}/${log_path3} -d ${snapshot}/Logs
    ${zip_file}    Run    ls ${snapshot}/Logs | grep -i ${prefix_name}_${Serial_number}.*${file_name}
    Run    cd ${snapshot}/Logs && tar -xf ${zip_file}
    Sleep    60sec
    ${rf_logs_file}    Run    ls -l ${snapshot}/Logs/gandalf_logs/misc_rf/rf_configured_logs |awk '{print $9}' |tail -n 1
    ${rf_logs_file}    Fetch From Left    ${rf_logs_file}    ${\n}
    ${retrun_log}    Run    cat ${snapshot}/Logs/gandalf_logs/misc_rf/rf_configured_logs/${rf_logs_file} | grep ${check_point}
    Should Contain    ${retrun_log}    ${check_point}

Checkpoint For 9915_Trunk_B_B4
    [Arguments]    ${bip_log}    ${dldata_pdschsendreq}=dldata_pdschsendreql1sw    ${DlData_PdschGrant}=DlData_PdschGrantL1sw
    Run Keyword And Continue On Failure    Check StartPrb And NumOfPrb On DlData_PdschSendreq
    ...    file_path=${bip_log}    pci=422   expect_startprb=8    expect_numofprb=120
    ...    dldata_pdschsendreq=${dldata_pdschsendreq}    DlData_PdschGrant=${DlData_PdschGrant}

Checkpoint For 9915_24R2_B_B4
    [Arguments]    ${bip_log}
    Run Keyword And Continue On Failure    Check StartPrb And NumOfPrb On DlData_PdschSendreq
    ...    file_path=${bip_log}    pci=834   expect_startprb=8    expect_numofprb=88

Checkpoint For 9915_Trunk_B_B2
    [Arguments]    ${bip_log}    ${dldata_pdschsendreq}=dldata_pdschsendreql1sw    ${DlData_PdschGrant}=DlData_PdschGrantL1sw
    Run Keyword And Continue On Failure    Check StartPrb And NumOfPrb On UlData_PuschReceiveReq
    ...    file_path=${bip_log}    pci=422   expect_startprb=14    expect_numofprb=78
    Run Keyword And Continue On Failure    Check StartPrb And NumOfPrb On DlData_PdschSendreq For B_B2
    ...    file_path=${bip_log}    pci=422   expect_startprb=16    expect_numofprb=80
    ...    dldata_pdschsendreq=${dldata_pdschsendreq}    DlData_PdschGrant=${DlData_PdschGrant}

Checkpoint For 9915_24R2_B_B2
    [Arguments]    ${bip_log}    ${dldata_pdschsendreq}=dldata_pdschsendreql1sw    ${DlData_PdschGrant}=DlData_PdschGrantL1sw
    Run Keyword And Continue On Failure    Check StartPrb And NumOfPrb On UlData_PuschReceiveReq
    ...    file_path=${bip_log}    pci=832   expect_startprb=14    expect_numofprb=78
    Run Keyword And Continue On Failure    Check StartPrb And NumOfPrb On DlData_PdschSendreq For B_B2
    ...    file_path=${bip_log}    pci=832   expect_startprb=16    expect_numofprb=80
    ...    dldata_pdschsendreq=${dldata_pdschsendreq}    DlData_PdschGrant=${DlData_PdschGrant}

Checkpoint For 9915_24R2_A13
    [Arguments]    ${bip_log}    ${dldata_pdschsendreq}=dldata_pdschsendreql1sw    ${DlData_PdschGrant}=DlData_PdschGrantL1sw
    Run Keyword And Continue On Failure    Check StartPrb And NumOfPrb On UlData_PuschReceiveReq
    ...    file_path=${bip_log}    pci=831   expect_startprb=13    expect_numofprb=247
    Run Keyword And Continue On Failure    Check StartPrb And NumOfPrb On DlData_PdschSendreq
    ...    file_path=${bip_log}    pci=831   expect_startprb=16    expect_numofprb=240
    ...    dldata_pdschsendreq=${dldata_pdschsendreq}    DlData_PdschGrant=${DlData_PdschGrant}
    Run Keyword And Continue On Failure    Check StartPrb And NumOfPrb On DlData_PdschSendreq
    ...    file_path=${bip_log}    pci=832   expect_startprb=16    expect_numofprb=80
    ...    dldata_pdschsendreq=${dldata_pdschsendreq}    DlData_PdschGrant=${DlData_PdschGrant}

Checkpoint For 9915_24R3_A13
    [Arguments]    ${bip_log}
    Run Keyword And Continue On Failure    Check StartPrb And NumOfPrb On UlData_PuschReceiveReq
    ...    file_path=${bip_log}    pci=791   expect_startprb=13    expect_numofprb=247
    Run Keyword And Continue On Failure    Check StartPrb And NumOfPrb On DlData_PdschSendreq
    ...    file_path=${bip_log}    pci=791   expect_startprb=16    expect_numofprb=240
    Run Keyword And Continue On Failure    Check StartPrb And NumOfPrb On DlData_PdschSendreq
    ...    file_path=${bip_log}    pci=792   expect_startprb=16    expect_numofprb=80

Checkpoint For 9915_Trunk_A13
    [Arguments]    ${bip_log}
    ...            ${dldata_pdschsendreq}=dldata_pdschsendreql1sw
    ...            ${DlData_PdschGrant}=DlData_PdschGrantL1sw
    ...            ${pcell_startprb}=16
    ...            ${scell_startprb}=16
    ...            ${pcell_numofprb}=240
    ...            ${scell_numofprb}=104
    Run Keyword And Continue On Failure    Check StartPrb And NumOfPrb On UlData_PuschReceiveReq
    ...    file_path=${bip_log}    pci=311   expect_startprb=8    expect_numofprb=257
    Run Keyword And Continue On Failure    Check StartPrb And NumOfPrb On DlData_PdschSendreq
    ...    file_path=${bip_log}    pci=311   expect_startprb=${pcell_startprb}    expect_numofprb=${pcell_numofprb}
    ...    dldata_pdschsendreq=${dldata_pdschsendreq}    DlData_PdschGrant=${DlData_PdschGrant}
    Run Keyword And Continue On Failure    Check StartPrb And NumOfPrb On DlData_PdschSendreq
    ...    file_path=${bip_log}    pci=411   expect_startprb=${scell_startprb}    expect_numofprb=${scell_numofprb}
    ...    dldata_pdschsendreq=${dldata_pdschsendreq}    DlData_PdschGrant=${DlData_PdschGrant}

Checkpoint For 9915_Trunk_B10
    [Arguments]    ${bip_log}
    ...            ${dldata_pdschsendreq}=dldata_pdschsendreql1sw
    ...            ${DlData_PdschGrant}=DlData_PdschGrantL1sw
    ...            ${pcell_startprb}=16
    ...            ${scell_startprb}=16
    ...            ${pcell_numofprb}=240
    ...            ${scell_numofprb}=104
    Run Keyword And Continue On Failure    Check StartPrb And NumOfPrb On UlData_PuschReceiveReq
    ...    file_path=${bip_log}    pci=333   expect_startprb=8    expect_numofprb=257
    Run Keyword And Continue On Failure    Check StartPrb And NumOfPrb On DlData_PdschSendreq
    ...    file_path=${bip_log}    pci=333   expect_startprb=${pcell_startprb}    expect_numofprb=${pcell_numofprb}
    ...    dldata_pdschsendreq=${dldata_pdschsendreq}    DlData_PdschGrant=${DlData_PdschGrant}
    Run Keyword And Continue On Failure    Check StartPrb And NumOfPrb On DlData_PdschSendreq
    ...    file_path=${bip_log}    pci=411   expect_startprb=${scell_startprb}    expect_numofprb=${scell_numofprb}
    ...    dldata_pdschsendreq=${dldata_pdschsendreq}    DlData_PdschGrant=${DlData_PdschGrant}

Checkpoint For 9915_Trunk_9568_A51
    [Arguments]    ${bip_log}    ${pci}=311    ${dldata_pdschsendreq}=dldata_pdschsendreql1sw    ${DlData_PdschGrant}=DlData_PdschGrantL1sw
    Run Keyword And Continue On Failure    Check StartPrb And NumOfPrb On UlData_PuschReceiveReq
    ...    file_path=${bip_log}    pci=${pci}   expect_startprb=13    expect_numofprb=41
    Run Keyword And Continue On Failure    Check StartPrb And NumOfPrb On DlData_PdschSendreq
    ...    file_path=${bip_log}    pci=${pci}   expect_startprb=3    expect_numofprb=51
    ...    dldata_pdschsendreq=${dldata_pdschsendreq}    DlData_PdschGrant=${DlData_PdschGrant}

Checkpoint For 9915_24R2_B10
    [Arguments]    ${bip_log}
    Run Keyword And Continue On Failure    Check StartPrb And NumOfPrb On UlData_PuschReceiveReq
    ...    file_path=${bip_log}    pci=835   expect_startprb=14    expect_numofprb=189
    Run Keyword And Continue On Failure    Check StartPrb And NumOfPrb On DlData_PdschSendreq
    ...    file_path=${bip_log}    pci=835   expect_startprb=16    expect_numofprb=192
    Run Keyword And Continue On Failure    Check StartPrb And NumOfPrb On DlData_PdschSendreq
    ...    file_path=${bip_log}    pci=833   expect_startprb=16    expect_numofprb=192

Checkpoint For 9915_24R3_B10
    [Arguments]    ${bip_log}    ${dldata_pdschsendreq}=dldata_pdschsendreql1sw    ${DlData_PdschGrant}=DlData_PdschGrantL1sw
    Run Keyword And Continue On Failure    Check StartPrb And NumOfPrb On UlData_PuschReceiveReq
    ...    file_path=${bip_log}    pci=795   expect_startprb=14    expect_numofprb=189
    Run Keyword And Continue On Failure    Check StartPrb And NumOfPrb On DlData_PdschSendreq
    ...    file_path=${bip_log}    pci=795   expect_startprb=16    expect_numofprb=192
    ...    dldata_pdschsendreq=${dldata_pdschsendreq}    DlData_PdschGrant=${DlData_PdschGrant}
    Run Keyword And Continue On Failure    Check StartPrb And NumOfPrb On DlData_PdschSendreq
    ...    file_path=${bip_log}    pci=793   expect_startprb=16    expect_numofprb=192
    ...    dldata_pdschsendreq=${dldata_pdschsendreq}    DlData_PdschGrant=${DlData_PdschGrant}

Check dl number of layers from bip
    [Arguments]    ${file_path}    ${pci}=311     ${expect_layers}=4
    ...            ${dldata_pdschsendreq}=dldata_pdschsendreq    ${DlData_PdschGrant}=DlData_PdschGrant
    ${filter_with_pci}    Set Variable    3gpp.dmrsScramblingSequenceInt==${pci}
    Setup Pcap File   file_path=${file_path}    filter=(${dldata_pdschsendreq}) && (!3gpp.rnti == 65535)
    ${dl_rank_list}    Get Field Value From PCAP    field_name=${DlData_PdschGrant}.numOfLayers
    ...                                             filter_expression=${filter_with_pci}
    ${dl_rank_length}    Get Length    ${dl_rank_list}
    Should Be True    ${dl_rank_length}>${1}    msg=no valid data filter out.please check the bip log.
    FOR    ${dl_rank}   IN    @{dl_rank_list}
        ${error_rank}    Evaluate    [x for x in ${dl_rank} if int(x)!=int(${expect_layers})]
        ${length}    Get Length    ${error_rank}
        Run Keyword And Continue On Failure    Should Be True    ${length}==${0}
        ...    msg=dl layers is not ${expect_layers} on dlData_PuschReceiveReq, actual is ${dl_rank}.
    END

9915 Check A1 Addition Success
    [Arguments]    ${cpif_log_path}    ${pcell_pci}=311    ${scell_pci}=201
    Setup Pcap File   file_path=${cpif_log_path}   filter= nr-rrc.physCellId == ${pcell_pci} && f1ap.procedureCode == 13
    ${test_value}    Get Field Value From PCAP    field_name=nr-rrc.measQuantityResults.rsrp
    ...    filter_expression=nr-rrc.measQuantityResults.rsrp
    Run Keyword And Continue On Failure    Should Not Be Empty    ${test_value}
    ...    msg=msg=A1 is not triggered.
    Setup Pcap File   file_path=${cpif_log_path}   filter= nr-rrc.sCellToAddModList == 1 && f1ap.procedureCode == 12
    ${scell_pci_list}    Get Field Value From PCAP    field_name=nr-rrc.physCellId
    ...    filter_expression=nr-rrc.physCellId
    Run Keyword And Continue On Failure     Should Be Equal As Integers    ${scell_pci}    ${scell_pci_list[0][0]}
    ...   msg=scell addition failed. expect scell pci is ${scell_pci},actual is ${scell_pci_list[0][0]}.
