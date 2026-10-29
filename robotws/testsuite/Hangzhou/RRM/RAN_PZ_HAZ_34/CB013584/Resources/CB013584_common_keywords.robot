*** Settings ***
Documentation     CB013584 common keyword

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/mcs/mcs_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot


*** Keywords ***

Online change qRxLevMin value
    [Arguments]    ${cell_id}    ${value}    ${gnb_id}=${37363}    ${gnb_index}=${0}
	TAF_ADMIN.connect to    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}    bts_port=443    use_ssl=True    name=online
    Perform online change value    MRBTS-${gnb_id}/NRBTS-${gnb_id}/NRCELL-${cell_id}   qRxLevMin    ${value}    online
    Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
    Wait '30s' for stabible
    [Teardown]    TAF_ADMIN.teardown admin    connection=online

Change all cell qRxLevMin value
    [Arguments]    ${cell1_value}=-22    ${cell2_value}=-22    ${cell3_value}=-22    ${cell4_value}=-22    ${gnb_id}=${37363}
    ${conn}    TAF_ADMIN.connect to    bts_host=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}    bts_port=443    use_ssl=True    name=online
    ${modify1}    Create Dictionary    dist_name=MRBTS-${gnb_id}/NRBTS-${gnb_id}/NRCELL-1
    ...    parameter=qRxLevMin    value=${cell1_value}
    ${modify2}    Create Dictionary    dist_name=MRBTS-${gnb_id}/NRBTS-${gnb_id}/NRCELL-2
    ...    parameter=qRxLevMin    value=${cell2_value}
    ${modify3}    Create Dictionary    dist_name=MRBTS-${gnb_id}/NRBTS-${gnb_id}/NRCELL-3
    ...    parameter=qRxLevMin    value=${cell3_value}
    ${modify4}    Create Dictionary    dist_name=MRBTS-${gnb_id}/NRBTS-${gnb_id}/NRCELL-4
    ...    parameter=qRxLevMin    value=${cell4_value}

    @{modify_param}    Create List     ${modify1}    ${modify2}    ${modify3}    ${modify4}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${modify_param}    connection=${conn}    timeout=600
    Wait '30s' for stabible

    [Teardown]    TAF_ADMIN.teardown admin    connection=online

Change all 3cell qRxLevMin value
    [Arguments]    ${cell1_value}=-56    ${cell2_value}=-56    ${cell3_value}=-56    ${gnb_id}=${37363}
    ${conn}    TAF_ADMIN.connect to    bts_host=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}    bts_port=443    use_ssl=True    name=online
    ${modify1}    Create Dictionary    dist_name=MRBTS-${gnb_id}/NRBTS-${gnb_id}/NRCELL-1
    ...    parameter=qRxLevMin    value=${cell1_value}
    ${modify2}    Create Dictionary    dist_name=MRBTS-${gnb_id}/NRBTS-${gnb_id}/NRCELL-2
    ...    parameter=qRxLevMin    value=${cell2_value}
    ${modify3}    Create Dictionary    dist_name=MRBTS-${gnb_id}/NRBTS-${gnb_id}/NRCELL-3
    ...    parameter=qRxLevMin    value=${cell3_value}

    @{modify_param}    Create List     ${modify1}    ${modify2}    ${modify3}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${modify_param}    connection=${conn}    timeout=600
    Wait '30s' for stabible

    [Teardown]    TAF_ADMIN.teardown admin    connection=online

Get cell nrCellIdentity
    Connect to gnb coam via ssl
    ${nrcell_info}     get_relation_mapping_between_cell_index_and_nrCellIdentity
    ${nrcell_id_list}    create list
    ${dic_value}    get dictionary values    ${nrcell_info}
    FOR    ${item}    IN    @{dic_value}
        ${nr_cell}    get from dictionary    ${item}    nrCellIdentity
        append to list      ${nrcell_id_list}    ${nr_cell}
    END
    [Teardown]    COAM Teardown gnb connections
    [Return]    ${nrcell_id_list}

Get DL UL tput from PM counter
    [Arguments]    ${log_dir}    ${cell}=1
    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
    ${remaining_time}     evaluate    ${remaining_time}+60
    Wait Throughput Timer    ${remaining_time}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${log_dir}${/}
    ${PM_counter_DL_value}=    get_counter_value_from_counter_file
    ...   counter_file=${PM_counter_file}
    ...   counter_id=M55309C12001
    ...   cell_id=${cell}
    ${DL_throughput}    evaluate    ${PM_counter_DL_value}*8/1024/1024
	${PM_counter_UL_value}=    get_counter_value_from_counter_file
    ...   counter_file=${PM_counter_file}
    ...   counter_id=M55309C12002
    ...   cell_id=${cell}
    ${UL_throughput}    evaluate    ${PM_counter_UL_value}*8/1024/1024
    [Return]    ${DL_throughput}    ${UL_throughput}

Online change parameter delta commission via admin
    [Arguments]    ${filename}
    setup admin    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}    bts_port=443    use_ssl=True    alias=delta_commission
    TAF_ADMIN.perform_delta_recommissioning    delta_file=${CURDIR}/${filename}    skip_parameter_relation_errors=${True}    alias=delta_commission
    teardown admin    alias=delta_commission

get KPI NR_5055b
    [Arguments]    ${PM_counter_file}    ${cell_id}
    ${PDSCH_UNSUCC_64TBL_MCS}    create list
    ${PDSCH_SUCC_ANY_64TBL_MCS}    create list
    ${PDSCH_UNSUCC_256TBL_MCS}    create list
    ${PDSCH_SUCC_ANY_256TBL_MCS}    create list
    FOR    ${num}    IN RANGE    0    32
        ${counter_2}   evaluate   2000+${num}
        ${counter_3}   evaluate   3000+${num}
        ${counter_6}   evaluate   6000+${num}
        ${counter_7}   evaluate   7000+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55300C0${counter_2}    cell_id=${cell_id}
        append to list    ${PDSCH_SUCC_ANY_64TBL_MCS}    ${result}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55300C0${counter_3}    cell_id=${cell_id}
        append to list    ${PDSCH_UNSUCC_64TBL_MCS}    ${result}

	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55300C0${counter_6}    cell_id=${cell_id}
        append to list    ${PDSCH_SUCC_ANY_256TBL_MCS}    ${result}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55300C0${counter_7}    cell_id=${cell_id}
        append to list    ${PDSCH_UNSUCC_256TBL_MCS}    ${result}
    END
#    log to console    PDSCH_SUCC_ANY_64TBL_MCS 0_to_31 is ${PDSCH_SUCC_ANY_64TBL_MCS}
#    log to console    PDSCH_UNSUCC_64TBL_MCS 0_to_31 is ${PDSCH_UNSUCC_64TBL_MCS}
#    log to console    PDSCH_SUCC_ANY_256TBL_MCS 0_to_31 is ${PDSCH_SUCC_ANY_256TBL_MCS}
#    log to console    PDSCH_UNSUCC_256TBL_MCS 0_to_31 is ${PDSCH_UNSUCC_256TBL_MCS}
    ${unsucc}    evaluate    sum(${PDSCH_UNSUCC_64TBL_MCS})+sum(${PDSCH_UNSUCC_64TBL_MCS})
    ${SUCC_ANY}    evaluate    sum(${PDSCH_SUCC_ANY_64TBL_MCS})+sum(${PDSCH_SUCC_ANY_256TBL_MCS})
    ${NR_5055b}    evaluate    ${unsucc}/(${SUCC_ANY}+${unsucc})
    log to console    cellid_${cell_id} KPI NR_5055b residual bler is ${NR_5055b}
    [Return]    ${NR_5055b}

get KPI NR_5054a
    [Arguments]    ${PM_counter_file}    ${cell_id}
    ${PDSCH_INITX_64TBL_MCS}    create list
    ${PDSCH_SUCC_INI_64TBL_MCS}    create list
    ${PDSCH_INI_256TBL_MCS}    create list
    ${PDSCH_SUCC_INI_256TBL_MCS}    create list
    FOR    ${num}    IN RANGE    0    10
        ${counter_0}   evaluate   0+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55300C0000${counter_0}    cell_id=${cell_id}
        append to list    ${PDSCH_INITX_64TBL_MCS}    ${result}
    END
    FOR    ${num}    IN RANGE    10    29
        ${counter_0}   evaluate   0+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55300C000${counter_0}    cell_id=${cell_id}
        append to list    ${PDSCH_INITX_64TBL_MCS}    ${result}
    END
    FOR    ${num}    IN RANGE    0    29
        ${counter_1}   evaluate   1000+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55300C0${counter_1}    cell_id=${cell_id}
        append to list    ${PDSCH_SUCC_INI_64TBL_MCS}    ${result}
    END
    FOR    ${num}    IN RANGE    0    28   #256qam mcs max 28
        ${counter_4}   evaluate   4000+${num}
        ${counter_5}   evaluate   5000+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55300C0${counter_4}    cell_id=${cell_id}
        append to list    ${PDSCH_INI_256TBL_MCS}    ${result}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55300C0${counter_5}    cell_id=${cell_id}
        append to list    ${PDSCH_SUCC_INI_256TBL_MCS}    ${result}
    END
#    log to console    PDSCH_INITX_64TBL_MCS 0_to_28 is ${PDSCH_INITX_64TBL_MCS}
#    log to console    PDSCH_SUCC_INI_64TBL_MCS 0_to_28 is ${PDSCH_SUCC_INI_64TBL_MCS}
#    log to console    PDSCH_INI_256TBL_MCS 0_to_27 is ${PDSCH_INI_256TBL_MCS}
#    log to console    PDSCH_SUCC_INI_256TBL_MCS 0_to_27 is ${PDSCH_SUCC_INI_256TBL_MCS}
    ${ini_tx}    evaluate    sum(${PDSCH_INITX_64TBL_MCS})+sum(${PDSCH_INI_256TBL_MCS})
    ${ini_SUCC}    evaluate    sum(${PDSCH_SUCC_INI_64TBL_MCS})+sum(${PDSCH_SUCC_INI_256TBL_MCS})
    ${NR_5054a}    evaluate    (${ini_tx}-${ini_SUCC})/${ini_tx}
    log to console    cellid_${cell_id} KPI NR_5054a ini bler is ${NR_5054a}
    [Return]    ${NR_5054a}

Get 13071 eCPRI UPlane and Fast CPlane counter
    [Arguments]    ${PM_counter_file}    ${cell_id}
    ${ECPRI_UP_MSG_RU_RCV_TOO_EARLY}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55318C00006    cell_id=${cell_id}
    should be true    ${ECPRI_UP_MSG_RU_RCV_TOO_EARLY}==0

    ${ECPRI_UP_MSG_RU_RCV_ON_TIME}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55318C00004    cell_id=${cell_id}
    ${ECPRI_UP_MSG_RAU_RCV_ALL}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55318C00002    cell_id=${cell_id}
    ${ECPRI_UP}    evaluate    ${ECPRI_UP_MSG_RAU_RCV_ALL}-${ECPRI_UP_MSG_RU_RCV_ON_TIME}
    should be true    ${ECPRI_UP}<3

    ${ECPRI_UP_MSG_RU_RCV_CORRUPT}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55318C00010    cell_id=${cell_id}
    should be true    ${ECPRI_UP_MSG_RU_RCV_CORRUPT}==0
    ${ECPRI_UP_MSG_RU_RCV_DUPLICATE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55318C00012    cell_id=${cell_id}
    should be true    ${ECPRI_UP_MSG_RU_RCV_DUPLICATE}==0


Get RT and DFT user Num by counter
    [Arguments]    ${PM_counter_file}    ${cell_id}    ${rt}    ${dft}
    ${MAX_UE_CONF_WB_BF_TAS_SRS}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55196C00011    cell_id=${cell_id}
    ${MAX_UE_CONF_SB_BF_TAS_SRS}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55196C00012    cell_id=${cell_id}
#    should be true    ${MAX_UE_CONF_WB_BF_TAS_SRS}==${dft}    #always fakeue attached
    should be true    ${MAX_UE_CONF_SB_BF_TAS_SRS}==${rt}
    log to console    MAX_UE_CONF_WB_BF_TAS_SRS${MAX_UE_CONF_WB_BF_TAS_SRS}==${dft}
    log to console    cellid_${cell_id} rt user num ${MAX_UE_CONF_SB_BF_TAS_SRS},DFT user num ${MAX_UE_CONF_WB_BF_TAS_SRS}

Block cell
    [Arguments]    ${phy_cell_id}    ${alias}
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=${alias}
    ${nrcel_list}=    TAF_ADMIN.Get Parameters For All    NRCEL    timeout=30    connection=${alias}
    FOR    ${nrcel}    IN    @{nrcel_list}
        Run Keyword If    '${nrcel.physCellId}'=='${phy_cell_id}' and '${nrcel.administrativeState}'=='Unlocked'    Run Keywords
        ...    TAF_ADMIN.block    ${nrcel.id}    timeout=60    connection=${alias}
        ...    AND    sleep    60
    END
    TAF_ADMIN.teardown    connection=${alias}
Unblock cell
    [Arguments]    ${phy_cell_id}    ${alias}
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=${alias}
    ${nrcel_list}=    TAF_ADMIN.Get Parameters For All    NRCEL    timeout=30    connection=${alias}
    FOR    ${nrcel}    IN    @{nrcel_list}
        Run Keyword If    '${nrcel.physCellId}'=='${phy_cell_id}'    Run Keywords    TAF_ADMIN.unblock    ${nrcel.id}    timeout=60
        ...    connection=${alias}
        ...    AND    sleep    60
    END
    TAF_ADMIN.teardown    connection=${alias}

download 5min PM counter file
    [Arguments]    ${log_dir}
    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
    ${remaining_time}     evaluate    ${remaining_time}+300     #5min
    log to console    sleep    ${remaining_time}s
    Wait Throughput Timer    ${remaining_time}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${log_dir}${/}
    [Return]    ${PM_counter_file}

download 2min PM counter file
    [Arguments]    ${log_dir}
    Wait Throughput Timer    150
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${log_dir}${/}
    [Return]    ${PM_counter_file}