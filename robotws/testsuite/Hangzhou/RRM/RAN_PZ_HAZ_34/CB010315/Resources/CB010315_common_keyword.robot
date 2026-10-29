*** Settings ***
Documentation
...    Author:Quanqingjun
...    Contact:qingjun.quan@nokia-sbell.com
...    Group: HGZ_SG6
...    Feature: CB010315

Library       taf.selenium.sbts    WITH NAME    selenium_coam
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    taf.ue    WITH NAME    taf_ue
Library    ../lib/CB010315.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/operate_cell_and_check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BW_common_case/lib/BW_step_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/cell_addition_deletion_online.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG08_keywords_SISO_operation.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Variables    ../TestData/variables_CB010315.py

*** Variables ***
${CB010315_json_path}    ${CURDIR}/json
${update_actRimCmFmReport_parameters}    ${CB010315_json_path}/actRimCmFmReport_parameter.json

*** Keywords ***
Commissioning SCF And Check BTS On Air
    [Arguments]    ${scf_name}    ${connection}=GNB_OAM
#    Connect to gnb coam via ssl   connection=${connection}    gnb_index=${gnb_index}
    log to console    import scf of ${scf_name}
    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    _${scf_name}.xml
    COAM Commission with scf file    scf_file_path=${SCF_upload}    connection=${connection}    timeout=${600}
    Wait until keyword succeeds    15min    180s    Check all cells info should be onair    connection=${connection}
    #[Teardown]    run keyword    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

CB006991_framework0_check
    [Arguments]    ${check_victim_NRRIM_cellid}=${1}    ${check_frame_cellid}=${1}
    ${NRRIM_parameters}    Get MO all parameters by distname
    ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${check_victim_NRRIM_cellid}/NRRIM_PROFILE-1
    ${rs1_rep_num}=    run keyword if    '${NRRIM_parameters[0]["parameters"]["repetitionRsType1"]}'=='r4'    Set Variable    ${4}
    ...    ELSE IF   '${NRRIM_parameters[0]["parameters"]["repetitionRsType1"]}'=='r2'    Set Variable    ${2}
    ...    ELSE    Set Variable    ${1}
    ${frame_structure_type}    Get frame structure type    check_frame_cellid=${check_frame_cellid}
    ${dl_muting_slots_index}    ${muting_slot_number}    get_dl_muting_slots_index    ${frame_structure_type}
    ...    ${NRRIM_parameters[0]["parameters"]["rimDlMutingMaxRange"]}    ${ri_effect_distance_value}
    Wait Until Keyword Succeeds    5min    10s    Expect Fault Should Present    faultId=7525
    sleep    30s
    ${RI_check_content}=    Run
    ...    command=cat /tmp/btslog2//SYSLOG_*.LOG | grep "/L2-PS/src/ul/sch/rim/RimLogger" |grep C:${check_rim_cellid} |grep 'RI status:'|tail -n 1
    Should Contain    ${RI_check_content}    ${ri_detected_state}
    Should Contain    ${RI_check_content}    ${ri_effect_distance}
    Wait Until Keyword Succeeds    5min    10s    Expect Fault Should Present    faultId=7527
    ${RI_received_check_content}=    Run
    ...    command=cat /tmp/btslog2//SYSLOG_*.LOG | grep "/L2-PS/src/ul/sch/rim/RimLogger" |grep C:${check_rim_cellid} |grep 'RI status:'|tail -n 1
    Should Contain    ${RI_received_check_content}    ${ri_detected_state}
    sleep    30s
    ${check_rs_common_command}=    Set Variable    cat /tmp/btslog2/SYSLOG_*.LOG | grep "/RimRsSendReq"
    ${Rs_send_check_content}=    Run
    ...    command=${check_rs_common_command} |grep NRCELL:${check_rim_cellid} |tail -n ${rs1_rep_num} |head -n 1
    ${key_value}    get_rimRsScramblingSequenceInit    ${Rs_send_check_content}
    ${Rs_send_check_bySequence}=    Run
    ...    command=${check_rs_common_command} | grep NRCELL:${check_rim_cellid}| grep '${key_value}'
    ${rs_send_check_bySequence_split}    Split String    ${Rs_send_check_bySequence}    \n
    ${rs_send_number}    Get Length    ${rs_send_check_bySequence_split}
    should be equal as integers    ${rs_send_number}    ${rs1_rep_num}
    FOR    ${i}    IN RANGE    ${rs_send_number}
           ${slot_content}    get_rs_send_slots    ${rs_send_check_bySequence_split[${i}]}
           Should Contain    ${Nearfar["${NRRIM_parameters[0]["parameters"]["rsNearFarConfig"]}"]["${frame_structure_type}"]}   ${slot_content}
    END
    Wait Until Keyword Succeeds    5min    10s    Expect Fault Should Present    faultId=7535
    ${DL_muting_slots_content}=    Run
    ...    command=cat /tmp/btslog2/SYSLOG_*.LOG | grep "/CellDbUpdater" | grep '"nrCellIdentity":${check_rim_cellid}' |tail -n 1
    ${syslog_dl_muting_slots_index}    get_dl_muting_slots_index_from_syslog    ${DL_muting_slots_content}
    Should Be Equal    ${dl_muting_slots_index}    ${syslog_dl_muting_slots_index}

CB009823_framework1_check
    [Arguments]    ${check_victim_NRRIM_cellid}=${1}    ${check_frame_cellid}=${1}
    ${NRRIM_parameters}    Get MO all parameters by distname
    ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${check_victim_NRRIM_cellid}/NRRIM_PROFILE-1
    ${rs1_rep_num}=    run keyword if    '${NRRIM_parameters[0]["parameters"]["repetitionRsType1"]}'=='r4'    Set Variable    ${4}
    ...    ELSE IF   '${NRRIM_parameters[0]["parameters"]["repetitionRsType1"]}'=='r2'    Set Variable    ${2}
    ...    ELSE    Set Variable    ${1}
    ${rs2_rep_num}=    run keyword if    '${NRRIM_parameters[0]["parameters"]["repetitionRsType2"]}'=='r4'    Set Variable    ${4}
    ...    ELSE IF   '${NRRIM_parameters[0]["parameters"]["repetitionRsType2"]}'=='r2'    Set Variable    ${2}
    ...    ELSE    Set Variable    ${1}
    @{rsType1NScId}=    Create list    ${NRRIM_parameters[0]["parameters"]["rsType1NScId"]}
    ${rsType1NScId_len}    Get Length    @{rsType1NScId}
    ${rsType1NScId_len_half}=    Evaluate    ${rsType1NScId_len}/2
    @{rsType1NScId_half}=    Get Slice From List    @{rsType1NScId}    end=${rsType1NScId_len_half}
    ${frame_structure_type}    Get frame structure type    check_frame_cellid=${check_frame_cellid}
    ${dl_muting_slots_index}    ${muting_slot_number}    get_dl_muting_slots_index    ${frame_structure_type}
    ...    ${NRRIM_parameters[0]["parameters"]["rimDlMutingMaxRange"]}    ${ri_effect_distance_value}
    Wait Until Keyword Succeeds    3min    30s    Expect Fault Should Present    faultId=7525
    sleep    30s
    ${RI_check_content}=    Run
    ...    command=cat /tmp/btslog2//SYSLOG_*.LOG | grep "/L2-PS/src/ul/sch/rim/RimLogger" |grep C:${check_rim_cellid} |grep 'RI status:'|tail -n 1
    Should Contain    ${RI_check_content}    ${ri_detected_state}
    Should Contain    ${RI_check_content}    ${ri_effect_distance}
    Wait Until Keyword Succeeds    10min    30s    Expect Fault Should Present    faultId=7527    supplementary=Both RIM RS1 and RS2 are detected*
    ${RI_received_check_content}=    Run
    ...    command=cat /tmp/btslog2//SYSLOG_*.LOG | grep "/L2-PS/src/ul/sch/rim/RimLogger" |grep C:${check_rim_cellid} |grep 'RI status:'|tail -n 1
    Should Contain    ${RI_received_check_content}    ${rs1_rs2_detected_state}
    sleep    5min
    ${check_rs_common_command}=    Set Variable    cat /tmp/btslog2/SYSLOG_*.LOG | grep "/RimRsSendReq"
    ${Rs1_send_check_content}=    Run
    ...    command=${check_rs_common_command} |grep RimRs:TYPE1 |grep NRCELL:${check_rim_cellid} |tail -n ${rs1_rep_num} |head -n 1
    ${key_value}    get_rimRsScramblingSequenceInit    ${Rs1_send_check_content}
    ${nscID}    get_nscID_from_syslog    ${Rs1_send_check_content}
    List Should Contain Value    ${rsType1NScId_half}    ${nscID}
    ${Rs1_send_check_bySequence}=    Run
    ...    command=${check_rs_common_command}| grep RimRs:TYPE1 |grep NRCELL:${check_rim_cellid} | grep '${key_value}'
    ${rs1_send_check_bySequence_split}    Split String    ${Rs1_send_check_bySequence}    \n
    ${rs1_send_number}    Get Length    ${rs1_send_check_bySequence_split}
    should be equal as integers    ${rs1_send_number}    ${rs1_rep_num}
    FOR    ${i}    IN RANGE    ${rs1_send_number}
           ${slot_content}    get_rs_send_slots    ${rs1_send_check_bySequence_split[${i}]}
           Should Contain    ${Nearfar["${NRRIM_parameters[0]["parameters"]["rsNearFarConfig"]}"]["${frame_structure_type}"]}   ${slot_content}
    END
    ${Rs2_send_check_content}=    Run
    ...    command=${check_rs_common_command} | grep RimRs:TYPE2| grep NRCELL:${check_rim_cellid} |tail -n ${rs2_rep_num} |head -n 1
    ${key_value}    get_rimRsScramblingSequenceInit    ${Rs2_send_check_content}
    ${Rs2_send_check_bySequence}=    Run
    ...    command=${check_rs_common_command}| grep RimRs:TYPE2 | grep NRCELL:${check_rim_cellid} | grep '${key_value}'
    ${rs2_send_check_bySequence_split}    Split String    ${Rs2_send_check_bySequence}    \n
    ${rs2_send_number}    Get Length    ${rs2_send_check_bySequence_split}
    should be equal as integers    ${rs2_send_number}    ${rs2_rep_num}
    FOR    ${i}    IN RANGE    ${rs2_send_number}
           ${slot_content}    get_rs_send_slots    ${rs2_send_check_bySequence_split[${i}]}
           Should Contain    ${Nearfar["${NRRIM_parameters[0]["parameters"]["rsNearFarConfig"]}"]["${frame_structure_type}"]}   ${slot_content}
    END
    Wait Until Keyword Succeeds    5min    10s    Expect Fault Should Present    faultId=7535
    ${DL_muting_slots_content}=    Run
    ...    command=cat /tmp/btslog2/SYSLOG_*.LOG | grep "/CellDbUpdater" | grep '"nrCellIdentity":${check_rim_cellid}' |tail -n 1
    ${syslog_dl_muting_slots_index}    get_dl_muting_slots_index_from_syslog    ${DL_muting_slots_content}
    Should Be Equal    ${dl_muting_slots_index}    ${syslog_dl_muting_slots_index}
    Wait Until Keyword Succeeds    10min    30s    Expect Fault Should Present    faultId=7532
    ${rimAsymmetric_status_content}=    Run
    ...    command=cat /tmp/btslog2/SYSLOG_*.LOG | grep "/RemoteInterferenceIndSender" |tail -n 2
    ${rimAsymmetric_status}    get_rimAsymmetricStatus    ${rimAsymmetric_status_content}
    Should Be Equal    ${rimAsymmetric_status}    ASYMMETRIC

CB014133_framework1_check
    [Arguments]    ${check_victim_NRRIM_cellid}=${1}    ${check_aggressor_NRRIM_cellid}=${1}    ${check_frame_cellid}=${1}
    ${NRRIM_parameters}    Get MO all parameters by distname
    ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${check_victim_NRRIM_cellid}/NRRIM_PROFILE-1
    ${rs1_rep_num}=    run keyword if    '${NRRIM_parameters[0]["parameters"]["repetitionRsType1"]}'=='r4'    Set Variable    ${4}
    ...    ELSE IF   '${NRRIM_parameters[0]["parameters"]["repetitionRsType1"]}'=='r2'    Set Variable    ${2}
    ...    ELSE    Set Variable    ${1}
    ${rs2_rep_num}=    run keyword if    '${NRRIM_parameters[0]["parameters"]["repetitionRsType2"]}'=='r4'    Set Variable    ${4}
    ...    ELSE IF   '${NRRIM_parameters[0]["parameters"]["repetitionRsType2"]}'=='r2'    Set Variable    ${2}
    ...    ELSE    Set Variable    ${1}
    ${frame_structure_type}    Get frame structure type    check_frame_cellid=${check_frame_cellid}
    ${dl_muting_slots_index}    ${muting_slot_number}    get_dl_muting_slots_index    ${frame_structure_type}
    ...    ${NRRIM_parameters[0]["parameters"]["rimDlMutingMaxRange"]}    ${ri_effect_distance_value}
    Wait Until Keyword Succeeds    3min    30s    Expect Fault Should Present    faultId=7525
    sleep    30s
    ${RI_check_content}=    Run
    ...    command=cat /tmp/btslog2//SYSLOG_*.LOG | grep "/L2-PS/src/ul/sch/rim/RimLogger" |grep C:${check_rim_cellid} |grep 'RI status:'|tail -n 1
    Should Contain    ${RI_check_content}    ${ri_detected_state}
    Should Contain    ${RI_check_content}    ${ri_effect_distance}
    Wait Until Keyword Succeeds    10min    30s    Expect Fault Should Present    faultId=7527    supplementary=Both RIM RS1 and RS2 are detected*
    ${RI_received_check_content}=    Run
    ...    command=cat /tmp/btslog2//SYSLOG_*.LOG | grep "/L2-PS/src/ul/sch/rim/RimLogger" |grep C:${check_rim_cellid} |grep 'RI status:'|tail -n 1
    Should Contain    ${RI_received_check_content}    ${rs1_rs2_detected_state}
    sleep    30s
    ${check_rs_common_command}=    Set Variable    cat /tmp/btslog2/SYSLOG_*.LOG | grep "/RimRsSendReq"
    ${Rs1_send_check_content}=    Run
    ...    command=${check_rs_common_command} |grep RimRs:TYPE1 |grep NRCELL:${check_rim_cellid} |tail -n ${rs1_rep_num} |head -n 1
    ${key_value}    get_rimRsScramblingSequenceInit    ${Rs1_send_check_content}
    ${Rs1_send_check_bySequence}=    Run
    ...    command=${check_rs_common_command} | grep RimRs:TYPE1 |grep NRCELL:${check_rim_cellid} | grep '${key_value}'
    ${rs1_send_check_bySequence_split}    Split String    ${Rs1_send_check_bySequence}    \n
    ${rs1_send_number}    Get Length    ${rs1_send_check_bySequence_split}
    should be equal as integers    ${rs1_send_number}    ${rs1_rep_num}
    FOR    ${i}    IN RANGE    ${rs1_send_number}
           ${slot_content}    get_rs_send_slots    ${rs1_send_check_bySequence_split[${i}]}
           Should Contain    ${Nearfar["${NRRIM_parameters[0]["parameters"]["rsNearFarConfig"]}"]["${frame_structure_type}"]}   ${slot_content}
    END
    ${Rs2_send_check_content}=    Run
    ...    command=${check_rs_common_command} | grep RimRs:TYPE2| grep NRCELL:${check_rim_cellid} |tail -n ${rs2_rep_num} |head -n 1
    ${key_value}    get_rimRsScramblingSequenceInit    ${Rs2_send_check_content}
    ${Rs2_send_check_bySequence}=    Run
    ...    command=${check_rs_common_command} | grep RimRs:TYPE2 | grep NRCELL:${check_rim_cellid} | grep '${key_value}'
    ${rs2_send_check_bySequence_split}    Split String    ${Rs2_send_check_bySequence}    \n
    ${rs2_send_number}    Get Length    ${rs2_send_check_bySequence_split}
    should be equal as integers    ${rs2_send_number}    ${rs2_rep_num}
    FOR    ${i}    IN RANGE    ${rs2_send_number}
           ${slot_content}    get_rs_send_slots    ${rs2_send_check_bySequence_split[${i}]}
           Should Contain    ${Nearfar["${NRRIM_parameters[0]["parameters"]["rsNearFarConfig"]}"]["${frame_structure_type}"]}   ${slot_content}
    END
    Wait Until Keyword Succeeds    5min    10s    Expect Fault Should Present    faultId=7535
    ${DL_muting_slots_content}=    Run
    ...    command=cat /tmp/btslog2/SYSLOG_*.LOG | grep "/CellDbUpdater" | grep '"nrCellIdentity":${check_rim_cellid}' |tail -n 1
    ${syslog_dl_muting_slots_index}    get_dl_muting_slots_index_from_syslog    ${DL_muting_slots_content}
    Should Be Equal    ${dl_muting_slots_index}    ${syslog_dl_muting_slots_index}
    Wait Until Keyword Succeeds    5min    10s    Expect Fault Should Present    faultId=7532
    ${rimAsymmetric_status_content}=    Run
    ...    command=cat /tmp/btslog2/SYSLOG_*.LOG | grep "/RemoteInterferenceIndSender" |tail -n 2
    ${rimAsymmetric_status}    get_rimAsymmetricStatus    ${rimAsymmetric_status_content}
    Should Be Equal    ${rimAsymmetric_status}    ASYMMETRIC
    Modify parameters by delta commissioning    delta_file=${update_actRimCmFmReport_parameters}
    Expect Fault Should Absent    faultId=7525
    Expect Fault Should Absent    faultId=7527
    Expect Fault Should Absent    faultId=7532
    Expect Fault Should Absent    faultId=7535
    ${NRRIMINFO_parameters}    Get MO all parameters by distname
    ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${check_victim_NRRIM_cellid}/NRRIMINFO-1
    ${NRRIM_aggressor_parameters}    Get MO all parameters by distname
    ...    dist_name=MRBTS-${mrbtsID_aggressor}/NRBTS-${nrbtsID_aggressor}/NRCELL-${check_aggressor_NRRIM_cellid}/NRRIM_PROFILE-1
    ...    connection=${connection_aggressor}
    ${aggressor_setid}    Set Variable    ${NRRIM_aggressor_parameters[0]["parameters"]["rsSetId"]}
    ${cm_muting_status}=    run keyword if    ${muting_slot_number}==${1}    set variable    special slot muting
    ...    ELSE IF    ${muting_slot_number}==${2}    set variable    1DL+special slot muting
    ...    ELSE IF    ${muting_slot_number}==${3}    set variable    2DL+special slot muting
    ...    ELSE IF    ${muting_slot_number}==${4}    set variable    3DL+special slot muting
    Should Be Equal    ${NRRIMINFO_parameters[0]["parameters"]["asymmetricState"]}    asymmetric state detected
    Should Be Equal    ${NRRIMINFO_parameters[0]["parameters"]["dlMutingState"][0]["pdschMutingStatus"]}    ${cm_muting_status}
    Should Be Equal    ${NRRIMINFO_parameters[0]["parameters"]["riState"]}    RI detected
    Should Contain    ${NRRIMINFO_parameters[0]["parameters"]["rimRsSetIdType1"]}    ${aggressor_setid}
    Should Contain    ${NRRIMINFO_parameters[0]["parameters"]["rimRsSetIdType2"]}    ${aggressor_setid}

Get MO all parameters by distname
    [Arguments]    ${dist_name}    ${connection}=GNB_OAM
    ${NRRIM_parameters}    coam.get_parameter_by_distname
    ...    dist_name=${dist_name}
    ...    connection=${connection}
    [Return]    ${NRRIM_parameters}

Get frame structure type
    [Arguments]    ${check_frame_cellid}=${1}    ${connection}=GNB_OAM
    @{frame_structure_parameters}    create list    tddFrameStructure
    ${frame_structure_parameters_value}    coam.get_parameter_by_distname
    ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${check_frame_cellid}
    ...    parameter_list=@{frame_structure_parameters}
    ...    connection=${connection}
    ${parameters}    Set Variable    ${frame_structure_parameters_value[0]["parameters"]["tddFrameStructure"][0]}
    ${frame_structure_type}=    run keyword if
    ...    '${parameters["frameStructureType"]}'=='tdLte' and '${parameters["lteToNrFrameShift"]}'=='3ms'
    ...    Set Variable    1116_3
    ...    ELSE IF
    ...    '${parameters["frameStructureType"]}'=='semiStatic' and '${parameters["lteToNrFrameShift"]}'=='1/4'
    ...    Set Variable    1208
    ...    ELSE IF
    ...    '${parameters["frameStructureType"]}'=='semiStatic' and '${parameters["lteToNrFrameShift"]}'=='3/7'
    ...    Set Variable    1070
    ...    ELSE IF
    ...    '${parameters["frameStructureType"]}'=='tdLte' and '${parameters["lteToNrFrameShift"]}'=='0ms'
    ...    Set Variable    1116_0
    [Return]    ${frame_structure_type}

Setup aggressor connection
    [Arguments]    ${gnb_index}=${1}
    Set Suite Variable    ${connection_aggressor}    GNB_OAM_aggressor
    run keyword and ignore error    COAM Teardown gnb connections    connection=${connection_aggressor}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ...    connection=${connection_aggressor}    gnb_index=${gnb_index}
    ${scf_path_aggressor}    Download SCF Download Via Rest Api    scf_dir_path=${SAVE LOG DIRECTORY}/aggressor
    ...    connection=${connection_aggressor}
    set suite variable    ${scf_path_aggressor}
    ${mrbtsID_aggressor}    ${nrbtsID_aggressor}   Get mrbtsID and nrbtsID via SCF for gNB    scf_path=${scf_path_aggressor}
    log to console  MRBTS_ID:${mrbtsID_aggressor}, NRBTS_ID:${nrbtsID_aggressor}
    set suite variable  ${mrbtsID_aggressor}
    set suite variable  ${nrbtsID_aggressor}

Modify parameters by delta commissioning
    [Arguments]    ${delta_file}    ${connection}=GNB_OAM    ${wait_for_completion}=True
    coam.perform_delta_recommissioning   delta_file=${delta_file}    connection=${connection}    timeout=${600}
    IF    '${wait_for_completion}'=='True'
        Wait until keyword succeeds    15min    180s    Check all cells info should be onair    connection=${connection}
    END

Lock aggressor cell via COAM
    [Arguments]    ${cell_index}=${1}    ${connection}=GNB_OAM_aggressor
     coam.lock    dist_name=MRBTS-${mrbtsID_aggressor}/NRBTS-${nrbtsID_aggressor}/NRCELL-${cell_index}
     ...    timeout=${120}    connection=${connection}