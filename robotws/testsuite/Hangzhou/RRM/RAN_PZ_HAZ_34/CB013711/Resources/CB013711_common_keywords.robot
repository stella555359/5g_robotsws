*** Settings ***
Documentation     CB013711 common keyword

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/mcs/mcs_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot


*** Keywords ***

Online change qRxLevMin value
    [Arguments]    ${cell_id}    ${value}    ${gnb_id}=${10754}    ${gnb_index}=${0}
	TAF_ADMIN.connect to    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}    bts_port=443    use_ssl=True    name=online
    Perform online change value    MRBTS-${gnb_id}/NRBTS-${gnb_id}/NRCELL-${cell_id}   qRxLevMin    ${value}    online
    Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
    Wait '30s' for stabible
    [Teardown]    TAF_ADMIN.teardown admin    connection=online

Change all cell qRxLevMin value
    [Arguments]    ${cell1_value}=-22    ${cell2_value}=-22    ${cell3_value}=-22    ${cell4_value}=-22    ${gnb_id}=${10754}
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

Change 2 cells qRxLevMin value
    [Arguments]    ${cell700_qrx}=-22    ${cell701_qrx}=-22    ${gnb_id}=37577
    ${conn}    TAF_ADMIN.connect to    bts_host=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}    bts_port=443    use_ssl=True    name=online
    ${modify1}    Create Dictionary    dist_name=MRBTS-${gnb_id}/NRBTS-${gnb_id}/NRCELL-700
    ...    parameter=qRxLevMin    value=${cell700_qrx}
    ${modify2}    Create Dictionary    dist_name=MRBTS-${gnb_id}/NRBTS-${gnb_id}/NRCELL-701
    ...    parameter=qRxLevMin    value=${cell701_qrx}
    @{modify_param}    Create List     ${modify1}    ${modify2}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${modify_param}    connection=${conn}    timeout=600
    Wait '15s' for stabible
    [Teardown]    TAF_ADMIN.teardown admin    connection=online

Change all 3cell qRxLevMin value
    [Arguments]    ${cell1_value}=-56    ${cell2_value}=-56    ${cell3_value}=-56    ${gnb_id}=${10754}
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

Get 13711 eCPRI UPlane and Fast CPlane counter
    [Arguments]    ${PM_counter_file}    ${cell_id}
    ${ECPRI_UP_MSG_RU_RCV_TOO_EARLY}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55318C00006    cell_id=${cell_id}
    should be true    ${ECPRI_UP_MSG_RU_RCV_TOO_EARLY}==0

    ${ECPRI_UP_MSG_RU_RCV_ON_TIME}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55318C00004    cell_id=${cell_id}

    ${ECPRI_UP_MSG_RU_RCV_CORRUPT}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55318C00010    cell_id=${cell_id}
    should be true    ${ECPRI_UP_MSG_RU_RCV_CORRUPT}==0


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
    Wait Throughput Timer    130
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${log_dir}${/}
    [Return]    ${PM_counter_file}

download PM counter file when attach on ongoing
    [Arguments]    ${log_dir}
    Wait Throughput Timer    120
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${log_dir}${/}
    [Return]    ${PM_counter_file}

Download PM counter file after attach pass
    [Arguments]    ${log_dir}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${log_dir}${/}
    [Return]    ${PM_counter_file}

Get gNB history alarms and fault
    [Arguments]  ${gnb_index}=${0}    ${enb_index}=${0}    ${connection}=Trunk_roll_check
    ${has_enb}    testline_info.has_enb    ${tl}
    ${enb_oam_ip}    run keyword if    ${has_enb}    set variable if    ${tl.enbs[${enb_index}].airscale}
    ...    ${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.addr}    ${tl.enbs[${enb_index}].oam_ip.v4}
    run keyword if    ${tl.gnbs}    Connect to gnb coam via ssl    connection=${connection}
    ...    ELSE    Connect to gnb coam via ssl
    ...    bts_host=${enb_oam_ip}    connection=${connection}    username=Nemuadmin    password=nemuuser
    @{truck_roll_fault}    Create List    ${10}    ${1806}    ${4341}    ${4352}    ${4383}    ${6450}
    ${active_alarms}    coam.get_alarm_history    connection=${connection}    timeout=${100}
    FOR   ${active_alarm}    IN   @{active_alarms}
        ${roll}    run keyword and return status    Collections.List Should not Contain Value    ${truck_roll_fault}    ${active_alarm['faultId']}
        run keyword if    not ${roll}
        ...    fail
    END
    log to console    history fault @{truck_roll_fault} in gnb_${gnb_index}
    [Return]    ${active_alarms}
    [Teardown]  coam.teardown    connection=${connection}

Get an check gNB active alarms and fault
    [Arguments]  ${gnb_index}=${0}    ${enb_index}=${0}    ${connection}=Trunk_roll_check
    ${has_enb}    testline_info.has_enb    ${tl}
    ${enb_oam_ip}    run keyword if    ${has_enb}    set variable if    ${tl.enbs[${enb_index}].airscale}
    ...    ${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.addr}    ${tl.enbs[${enb_index}].oam_ip.v4}
    run keyword if    ${tl.gnbs}    Connect to gnb coam via ssl    connection=${connection}
    ...    ELSE    Connect to gnb coam via ssl
    ...    bts_host=${enb_oam_ip}    connection=${connection}    username=Nemuadmin    password=nemuuser
    @{truck_roll_fault}    Create List    ${10}    ${1806}    ${4341}    ${4352}    ${4383}
    ${active_alarms}    coam.get_active_alarms    connection=${connection}    timeout=${100}
#    log to console    active_alarms are ${active_alarms}
    FOR   ${active_alarm}    IN   @{active_alarms}
        log to console    \nactive_alarms are ${active_alarm['faultId']}
        ${roll}    run keyword and return status    Collections.List Should not Contain Value    ${truck_roll_fault}    ${active_alarm['faultId']}
        run keyword if    not ${roll}
        ...    fail
    END
    log to console    truck_roll_fault @{truck_roll_fault} in gnb_${gnb_index}
#    log to console    active_alarms are ${active_alarms}
    [Return]    ${active_alarms}
    [Teardown]  coam.teardown    connection=${connection}

KPI print
	log to console    NR_5100c	5G Average MAC layer user throughput in downlink
	...    \nNR_5101b    5G Average MAC layer user throughput in uplink
	...    \nNR_5114b 	5G PRB utilization for PDSCH
	...    \nNR_5115a 	5G PRB utilization for PUSCH
	...    \nNR_5244e 	5G Scheduled user throughput in downlink considering PRB utilization
	...    \nNR_5245d 	5G 0-Scheduled user throughput in uplink considering PRB utilization
	...    \nNR_5415a 	5G Average number of active UEs with data in the buffer for DRBs in DL (excluding DRX)
	...    \nNR_5192e 	5G Average number of scheduled (FDM and MU-MIMO) UEs on PDSCH
	...    \nNR_5193b 	5G Average number of scheduled (FDM and MU-MIMO) UEs on PUSCH

get KPI NR_5088d
    [Arguments]    ${PM_counter_file}    ${cell_id}
    log to console    get KPI NR_5088d for cellid_${cell_id}
    ...   5G MAC PDU Cell throughput on active PDSCH data slots on initial HARQ transmissions
    ${PDSCH_INI_VOL_64TBL_MCS_list}    create list
    ${PDSCH_INI_VOL_256TBL_MCS_list}    create list
    ${PDSCH_INI_VOL_LOWSE_MCS_list}    create list
    FOR    ${num}    IN RANGE    0    29
        ${counter_2}   evaluate   1000+${num}
        ${counter_3}   evaluate   5000+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55304C0${counter_2}    cell_id=${cell_id}
        append to list    ${PDSCH_INI_VOL_64TBL_MCS_list}    ${result}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55366C0${counter_3}    cell_id=${cell_id}
        append to list    ${PDSCH_INI_VOL_LOWSE_MCS_list}    ${result}
    END
    FOR    ${num}    IN RANGE    0    28
        ${counter_3}   evaluate   5000+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55304C0${counter_3}    cell_id=${cell_id}
        append to list    ${PDSCH_INI_VOL_256TBL_MCS_list}    ${result}
    END

    ${DATA_SLOT_PDSCH_TIME}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00008    cell_id=${cell_id}
    ${SSB_SLOT_PDSCH_TIME}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00016    cell_id=${cell_id}
    ${TRS_SLOT_PDSCH_TIME}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00018    cell_id=${cell_id}

    ${PDSCH_INI_VOL_64TBL_MCS_sum}    evaluate    sum(${PDSCH_INI_VOL_64TBL_MCS_list})
    ${PDSCH_INI_VOL_256TBL_MCS_sum}    evaluate    sum(${PDSCH_INI_VOL_256TBL_MCS_list})
    ${PDSCH_INI_VOL_LOWSE_MCS_sum}    evaluate    sum(${PDSCH_INI_VOL_LOWSE_MCS_list})
    ${NR_5088d_fenzi1}    evaluate    8*(${PDSCH_INI_VOL_64TBL_MCS_sum}+${PDSCH_INI_VOL_256TBL_MCS_sum}+${PDSCH_INI_VOL_LOWSE_MCS_sum})
    ${NR_5088d_fenmu}     evaluate    ${DATA_SLOT_PDSCH_TIME}+${SSB_SLOT_PDSCH_TIME}+${TRS_SLOT_PDSCH_TIME}
    ${NR_5088d}    evaluate    ${NR_5088d_fenzi1}/${NR_5088d_fenmu}
    log to console    cellid_${cell_id} KPI NR_5088d_5G MAC PDU Cell throughput on active PDSCH data slots on initial HARQ transmissions ${NR_5088d}
    [Return]    ${NR_5088d}

get KPI NR_5089e
    [Arguments]    ${PM_counter_file}    ${cell_id}
    log to console    get KPI NR_5089e for cellid_${cell_id}
    ...   5G MAC PDU Cell throughput on active PUSCH data slots on initial HARQ transmissions
    ${PUSCH_CP_INI_VOL_64TBL_MCS_list}    create list
    ${PUSCH_DFT_INI_VOL_64TBL_MCS_list}    create list
    ${PUSCH_CP_INI_VOL_256TBL_MCS_list}    create list
    ${PUSCH_CP_INI_VOL_LOWSE_MCS_list}    create list
    FOR    ${num}    IN RANGE    0    29
        ${counter_2}   evaluate   3000+${num}
        ${counter_3}   evaluate   5000+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55304C0${counter_2}    cell_id=${cell_id}
        append to list    ${PUSCH_CP_INI_VOL_64TBL_MCS_list}    ${result}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55367C0${counter_3}    cell_id=${cell_id}
        append to list    ${PUSCH_CP_INI_VOL_LOWSE_MCS_list}    ${result}
    END
    FOR    ${num}    IN RANGE    0    28
        ${counter_2}   evaluate   7000+${num}
        ${counter_3}   evaluate   9000+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55304C0${counter_2}    cell_id=${cell_id}
        append to list    ${PUSCH_DFT_INI_VOL_64TBL_MCS_list}    ${result}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55304C0${counter_3}    cell_id=${cell_id}
        append to list    ${PUSCH_CP_INI_VOL_256TBL_MCS_list}    ${result}
    END

    ${PUSCH_DFT_INI_VOL_64TBL_SAG_R2}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55370C00011    cell_id=${cell_id}
    ${PUSCH_DFT_INI_VOL_64TBL_SAG_R4}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55370C00017    cell_id=${cell_id}

    ${DATA_SLOT_PUSCH_TIME}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00009    cell_id=${cell_id}
    ${PRACH_SLOTS_PUSCH_TIME}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00011    cell_id=${cell_id}

    ${sum1}    evaluate    sum(${PUSCH_CP_INI_VOL_64TBL_MCS_list})
    ${sum2}    evaluate    sum(${PUSCH_DFT_INI_VOL_64TBL_MCS_list})
    ${sum3}    evaluate    sum(${PUSCH_CP_INI_VOL_256TBL_MCS_list})
    ${sum4}    evaluate    sum(${PUSCH_CP_INI_VOL_LOWSE_MCS_list})
    ${fenzi1}    evaluate    8*(${sum1}+${sum2}+${sum3}+${sum4}+${PUSCH_DFT_INI_VOL_64TBL_SAG_R2}+${PUSCH_DFT_INI_VOL_64TBL_SAG_R4})
    ${fenmu}     evaluate    ${DATA_SLOT_PUSCH_TIME}+${PRACH_SLOTS_PUSCH_TIME}
    ${NR_5089e}    evaluate    ${fenzi1}/${fenmu}
    log to console    cellid_${cell_id} KPI NR_5089e_5G MAC PDU Cell throughput on active PUSCH data slots on initial HARQ transmissions ${NR_5089e}
    [Return]    ${NR_5089e}

get KPI NR_5244e
    [Arguments]    ${PM_counter_file}    ${cell_id}
    log to console    get KPI NR_5244e for cellid_${cell_id}
    ...   5G Scheduled user throughput in downlink considering PRB utilization
    ${PDSCH_INI_VOL_64TBL_MCS_list}    create list
    ${PDSCH_INI_VOL_256TBL_MCS_list}    create list
    ${PDSCH_INI_VOL_LOWSE_MCS_list}    create list
    FOR    ${num}    IN RANGE    0    29
        ${counter_2}   evaluate   1000+${num}
        ${counter_3}   evaluate   5000+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55304C0${counter_2}    cell_id=${cell_id}
        append to list    ${PDSCH_INI_VOL_64TBL_MCS_list}    ${result}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55366C0${counter_3}    cell_id=${cell_id}
        append to list    ${PDSCH_INI_VOL_LOWSE_MCS_list}    ${result}
    END
    FOR    ${num}    IN RANGE    0    28
        ${counter_3}   evaluate   5000+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55304C0${counter_3}    cell_id=${cell_id}
        append to list    ${PDSCH_INI_VOL_256TBL_MCS_list}    ${result}
    END

    ${MEAS_PERIOD_NR_MAC_PDU_TPUT}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55304C00001    cell_id=${cell_id}
    ${PRB_USED_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C10001    cell_id=${cell_id}
    ${PRB_AVAIL_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C10003    cell_id=${cell_id}

    ${ACC_SCHED_UE_PDSCH_NOPAGING}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C10010    cell_id=${cell_id}
    ${DATA_SLOT_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00005    cell_id=${cell_id}
    ${SSB_SLOT_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00015    cell_id=${cell_id}
    ${TRS_SLOT_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00017    cell_id=${cell_id}

    ${PDSCH_INI_VOL_64TBL_MCS_sum}    evaluate    sum(${PDSCH_INI_VOL_64TBL_MCS_list})
    ${PDSCH_INI_VOL_256TBL_MCS_sum}    evaluate    sum(${PDSCH_INI_VOL_256TBL_MCS_list})
    ${PDSCH_INI_VOL_LOWSE_MCS_sum}    evaluate    sum(${PDSCH_INI_VOL_LOWSE_MCS_list})
    ${fenzi1}     evaluate    8*(${PDSCH_INI_VOL_64TBL_MCS_sum}+${PDSCH_INI_VOL_256TBL_MCS_sum}+${PDSCH_INI_VOL_LOWSE_MCS_sum})
    ${fenmu1}     evaluate    ${MEAS_PERIOD_NR_MAC_PDU_TPUT}+0
    ${fenmu2}     evaluate    ${PRB_USED_PDSCH}/${PRB_AVAIL_PDSCH}
    ${fenmu3}     evaluate    ${ACC_SCHED_UE_PDSCH_NOPAGING}/(${DATA_SLOT_PDSCH}+${SSB_SLOT_PDSCH}+${TRS_SLOT_PDSCH})
    ${NR_5244e}    evaluate   ${fenzi1}/${fenmu1}/${fenmu2}/${fenmu3}
    log to console    cellid_${cell_id} KPI NR_5244e_5G 5G Scheduled user throughput in downlink considering PRB utilization ${NR_5244e}
    [Return]    ${NR_5244e}

get KPI NR_5245d
    [Arguments]    ${PM_counter_file}    ${cell_id}
    log to console    get KPI NR_5089e for cellid_${cell_id}
    ...   5G MAC PDU Cell throughput on active PUSCH data slots on initial HARQ transmissions
    ${PUSCH_CP_INI_VOL_64TBL_MCS_list}    create list
    ${PUSCH_DFT_INI_VOL_64TBL_MCS_list}    create list
    ${PUSCH_CP_INI_VOL_256TBL_MCS_list}    create list
    ${PUSCH_CP_INI_VOL_LOWSE_MCS_list}    create list
    FOR    ${num}    IN RANGE    0    29
        ${counter_2}   evaluate   3000+${num}
        ${counter_3}   evaluate   5000+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55304C0${counter_2}    cell_id=${cell_id}
        append to list    ${PUSCH_CP_INI_VOL_64TBL_MCS_list}    ${result}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55367C0${counter_3}    cell_id=${cell_id}
        append to list    ${PUSCH_CP_INI_VOL_LOWSE_MCS_list}    ${result}
    END
    FOR    ${num}    IN RANGE    0    28
        ${counter_2}   evaluate   7000+${num}
        ${counter_3}   evaluate   9000+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55304C0${counter_2}    cell_id=${cell_id}
        append to list    ${PUSCH_DFT_INI_VOL_64TBL_MCS_list}    ${result}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55304C0${counter_3}    cell_id=${cell_id}
        append to list    ${PUSCH_CP_INI_VOL_256TBL_MCS_list}    ${result}
    END

    ${PUSCH_DFT_INI_VOL_64TBL_SAG_R2}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55370C00011    cell_id=${cell_id}
    ${PUSCH_DFT_INI_VOL_64TBL_SAG_R4}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55370C00017    cell_id=${cell_id}

    ${MEAS_PERIOD_NR_MAC_PDU_TPUT}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55304C00001    cell_id=${cell_id}
    ${PRB_USED_PUSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C10002    cell_id=${cell_id}
    ${PRB_AVAIL_PUSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C10004    cell_id=${cell_id}

    ${ACC_SCHED_UE_PUSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C18001    cell_id=${cell_id}
    ${DATA_SLOT_PUSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00006    cell_id=${cell_id}
    ${PRACH_SLOTS_PUSCH_TIME}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00010    cell_id=${cell_id}

    ${sum1}    evaluate    sum(${PUSCH_CP_INI_VOL_64TBL_MCS_list})
    ${sum2}    evaluate    sum(${PUSCH_DFT_INI_VOL_64TBL_MCS_list})
    ${sum3}    evaluate    sum(${PUSCH_CP_INI_VOL_256TBL_MCS_list})
    ${sum4}    evaluate    sum(${PUSCH_CP_INI_VOL_LOWSE_MCS_list})
    ${fenzi1}    evaluate    8*(${sum1}+${sum2}+${sum3}+${sum4}+${PUSCH_DFT_INI_VOL_64TBL_SAG_R2}+${PUSCH_DFT_INI_VOL_64TBL_SAG_R4})
    ${fenmu1}     evaluate    ${MEAS_PERIOD_NR_MAC_PDU_TPUT}+0
    ${fenmu2}     evaluate    ${PRB_USED_PUSCH}/${PRB_AVAIL_PUSCH}
    ${fenmu3}     evaluate    ${ACC_SCHED_UE_PUSCH}/${DATA_SLOT_PUSCH}/${PRACH_SLOTS_PUSCH_TIME}
    ${NR_5245d}    evaluate    ${fenzi1}/${fenmu1}/${fenmu2}/${fenmu3}
    log to console    cellid_${cell_id} KPI NR_5245d_5G Scheduled user throughput in uplink considering PRB utilization ${NR_5245d}
    [Return]    ${NR_5245d}

get KPI NR_5100c
    [Arguments]    ${PM_counter_file}    ${cell_id}
    log to console    get KPI NR_5100c for cellid_${cell_id}
    ...   5G Average MAC layer user throughput in downlink

    ${DL_MAC_SDU_VOL_DTCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55309C01001    cell_id=${cell_id}
    ${ACC_UE_DL_DRB_DATA}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C02000    cell_id=${cell_id}
    ${ACC_UE_DL_SLEEP_DATA}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C27001    cell_id=${cell_id}
    ${DATA_SLOT_PDSCH_TIME}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00008    cell_id=${cell_id}
    ${DATA_SLOT_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00005    cell_id=${cell_id}

    ${fenzi1}    evaluate    8*${DL_MAC_SDU_VOL_DTCH}
    ${fenmu1}     evaluate    (${${DL_MAC_SDU_VOL_DTCH}}-${ACC_UE_DL_SLEEP_DATA})*${DATA_SLOT_PDSCH_TIME}/${DATA_SLOT_PDSCH}
    ${NR_5100c}    evaluate    ${fenzi1}/${fenmu1}
    log to console    cellid_${cell_id} KPI NR_5100c 5G Average MAC layer user throughput in downlink ${NR_5100c}
    [Return]    ${NR_5100c}

get KPI NR_5101b
    [Arguments]    ${PM_counter_file}    ${cell_id}
    log to console    get KPI NR_5101b for cellid_${cell_id}
    ...   5G Average MAC layer user throughput in uplink

    ${UL_MAC_SDU_VOL_DTCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55309C02001    cell_id=${cell_id}
    ${ACC_UE_UL_DRB_DATA}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C02002    cell_id=${cell_id}
    ${DATA_SLOT_PUSCH_TIME}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00009    cell_id=${cell_id}
    ${DATA_SLOT_PUSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00006    cell_id=${cell_id}

    ${fenzi1}    evaluate    8*${UL_MAC_SDU_VOL_DTCH}
    ${fenmu1}     evaluate    ${ACC_UE_UL_DRB_DATA}*${DATA_SLOT_PUSCH_TIME}/${DATA_SLOT_PUSCH}
    ${NR_5101b}    evaluate    ${fenzi1}/${fenmu1}
    log to console    cellid_${cell_id} KPI NR_5101b 5G Average MAC layer user throughput in uplink ${NR_5101b}
    [Return]    ${NR_5101b}

get KPI NR_5114b
    [Arguments]    ${PM_counter_file}    ${cell_id}
    log to console    get KPI NR_5114b for cellid_${cell_id}
    ...   5G PRB utilization for PDSCH

    ${PRB_USED_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C10001    cell_id=${cell_id}
    ${PRB_USED_SIB}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C10015    cell_id=${cell_id}
    ${PRB_USED_PAGING}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C10011    cell_id=${cell_id}
    ${PRB_AVAIL_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C10003    cell_id=${cell_id}

    ${fenzi1}    evaluate    100*(${PRB_USED_PDSCH}+${PRB_USED_SIB}+${PRB_USED_PAGING})
    ${fenmu1}     evaluate    ${PRB_AVAIL_PDSCH}+0
    ${NR_5114b}    evaluate    ${fenzi1}/${fenmu1}
    log to console    cellid_${cell_id} KPI NR_5114b 5G PRB utilization for PDSCH ${NR_5114b}
    [Return]    ${NR_5114b}

get KPI NR_5115a
    [Arguments]    ${PM_counter_file}    ${cell_id}
    log to console    get KPI NR_5115a for cellid_${cell_id}
    ...   5G PRB utilization for PUSCH

    ${PRB_USED_PUSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C10002    cell_id=${cell_id}
    ${PRB_AVAIL_PUSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C10004    cell_id=${cell_id}

    ${NR_5115a}    evaluate    100*${PRB_USED_PUSCH}/${PRB_AVAIL_PUSCH}
    log to console    cellid_${cell_id} KPI NR_5115a 5G PRB utilization for PUSCH ${NR_5115a}
    [Return]    ${NR_5115a}

get KPI NR_5415a
    [Arguments]    ${PM_counter_file}    ${cell_id}
    log to console    get KPI NR_5415a for cellid_${cell_id}
    ...   5G Average number of active UEs with data in the buffer for DRBs in DL (excluding DRX)

    ${ACC_UE_DL_DRB_DATA}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C02000    cell_id=${cell_id}
    ${ACC_UE_DL_SLEEP_DATA}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C27001    cell_id=${cell_id}
    ${SAMPLE_CNT_NR_CELL_UTIL_DL}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C01000    cell_id=${cell_id}

    ${fenzi1}    evaluate    ${ACC_UE_DL_DRB_DATA}-${ACC_UE_DL_SLEEP_DATA}
    ${fenmu1}     evaluate    ${SAMPLE_CNT_NR_CELL_UTIL_DL}+0
    ${NR_5415a}    evaluate    ${fenzi1}/${fenmu1}

    log to console    cellid_${cell_id} KPI NR_5415a 5G Average number of active UEs with data for DRBs in DL (excluding DRX) ${NR_5415a}
    [Return]    ${NR_5415a}

get KPI NR_5192e
    [Arguments]    ${PM_counter_file}    ${cell_id}
    log to console    get KPI NR_5192e for cellid_${cell_id}
    ...   5G Average number of scheduled (FDM and MU-MIMO) UEs on PDSCH

    ${ACC_SCHED_UE_PDSCH_NOPAGING}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C02000    cell_id=${cell_id}
    ${DATA_SLOT_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00005    cell_id=${cell_id}
    ${SSB_SLOT_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00015    cell_id=${cell_id}
    ${SSB_SLOT_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00017    cell_id=${cell_id}

    ${fenzi1}    evaluate    ${ACC_SCHED_UE_PDSCH_NOPAGING}+0
    ${fenmu1}     evaluate    ${DATA_SLOT_PDSCH}+${SSB_SLOT_PDSCH}+${SSB_SLOT_PDSCH}
    ${NR_5192e}    evaluate    ${fenzi1}/${fenmu1}

    log to console    cellid_${cell_id} KPI NR_5192e 5G Average number of scheduled (FDM and MU-MIMO) UEs on PDSCH ${NR_5192e}
    [Return]    ${NR_5192e}

get KPI NR_5193b
    [Arguments]    ${PM_counter_file}    ${cell_id}
    log to console    get KPI NR_5193b for cellid_${cell_id}
    ...   5G Average number of scheduled (FDM and MU-MIMO) UEs on PUSCH

    ${ACC_SCHED_UE_PUSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C18001    cell_id=${cell_id}
    ${DATA_SLOT_PUSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00006    cell_id=${cell_id}
    ${PRACH_SLOTS_PUSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00010    cell_id=${cell_id}

    ${fenzi1}    evaluate    ${ACC_SCHED_UE_PUSCH}+0
    ${fenmu1}     evaluate    ${DATA_SLOT_PUSCH}+${PRACH_SLOTS_PUSCH}
    ${NR_5193b}    evaluate    ${fenzi1}/${fenmu1}

    log to console    cellid_${cell_id} KPI NR_5193b 5G Average number of scheduled (FDM and MU-MIMO) UEs on PUSCH ${NR_5193b}
    [Return]    ${NR_5193b}

get KPI NR_5258a
    [Arguments]    ${PM_counter_file}    ${cell_id}
    log to console    get KPI NR_5258a for cellid_${cell_id}
    ...   5G Maximum MAC SDU Cell Throughput in DL on DTCH

    ${MAC_DTCH_CELL_THP_DL_MAX}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55309C12001    cell_id=${cell_id}
    ${NR_5258a}    evaluate    8*${MAC_DTCH_CELL_THP_DL_MAX}/1000000

    log to console    cellid_${cell_id} KPI NR_5258a 5G Maximum MAC SDU Cell Throughput in DL on DTCH ${NR_5258a}
    [Return]    ${NR_5258a}

get KPI NR_5259a
    [Arguments]    ${PM_counter_file}    ${cell_id}
    log to console    get KPI NR_5259a for cellid_${cell_id}
    ...   5G Maximum MAC SDU Cell Throughput in UL on DTCH

    ${MAX UL DTCH throughput in MAC layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55309C12002    cell_id=${cell_id}
    ${NR_5259a}    evaluate    8*${MAX UL DTCH throughput in MAC layer}/1000000

    log to console    cellid_${cell_id} KPI NR_5259a 5G Maximum MAC SDU Cell Throughput in UL on DTCH ${NR_5259a}
    [Return]    ${NR_5259a}

check cell status
    [Arguments]    ${alias}=default
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=${alias}
    ${nrcel_list}=    TAF_ADMIN.Get Parameters For All    NRCEL    timeout=30    connection=${alias}
    FOR    ${nrcel}    IN    @{nrcel_list}
        log to console    ${nrcel.cellName}'s operationalState is ${nrcel.operationalState}
        should be true    '${nrcel.operationalState}'=='enabled'
    END
    TAF_ADMIN.teardown    connection=${alias}

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