*** Settings ***
Documentation    CB013709 keyword

*** Keywords ***
At Least One Greater Than Zero
    [Arguments]    @{variables}
    ${result}=    Evaluate    any(var > 0 for var in ${variables})
    Should Be True    ${result}    At least one results must be greater than 0

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


Get all cell group id list
    [Arguments]    ${connection}=GNB_OAM
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=${connection}
    ${cell_info}   TAF_ADMIN.get_subcells_status   timeout=20    connection=${connection}
    Log To Console     cell_info= ${cell_info}
    ${number_of_cell_group_info}    get length    ${cell_info}
    ${cellgrp_list}    Get Dictionary Keys    ${cell_info}
    @{cellgrp_index_list}    create list
    FOR    ${cellgrp}    IN    @{cellgrp_list}
        ${cellgrp_index}    Fetch from right    ${cellgrp}    -
        ${cellgrp_index}  convert to integer  ${cellgrp_index}
        Append to list    ${cellgrp_index_list}    ${cellgrp_index}
    END
    Sort List   ${cellgrp_index_list}
    [Return]    ${cellgrp_index_list}


Check 13709_A other cell SVRT_METRIC equal 0
     [Arguments]    ${counter_file}    ${cell_grp_id}=0
     ${M55208C00001_MIN_DL_RT_SVRT_METRIC}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
     ...    counter_id=M55208C00001    cell_grp_id=${cell_grp_id}
     ${M55208C00002_MAX_DL_RT_SVRT_METRIC}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
     ...    counter_id=M55208C00002    cell_grp_id=${cell_grp_id}
     ${M55208C00003_AVGE_DL_RT_SVRT_METRIC}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
     ...    counter_id=M55208C00003   cell_grp_id=${cell_grp_id}
     ${M55208C00004_MIN_UL_RT_SVRT_METRIC}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
     ...    counter_id=M55208C00004    cell_grp_id=${cell_grp_id}
     ${M55208C00005_MAX_UL_RT_SVRT_METRIC}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
     ...    counter_id=M55208C00005    cell_grp_id=${cell_grp_id}
     ${M55208C00006_AVGE_UL_RT_SVRT_METRIC}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
     ...    counter_id=M55208C00006    cell_grp_id=${cell_grp_id}
     ${M55208C00007_MAX_NRT_L2POOL_SVRT_METRIC}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
     ...    counter_id=M55208C00007    cell_grp_id=${cell_grp_id}
     ${M55208C00008_AVGE_NRT_L2POOL_SVRT_METRIC}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
     ...    counter_id=M55208C00008    cell_grp_id=${cell_grp_id}
     ${M55208C00009_MIN_DL_NRT_CORE_SVRT_METRIC}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
     ...    counter_id=M55208C00009    cell_grp_id=${cell_grp_id}

     ${M55208C00010_MIN_DL_NRT_CORE_SVT_METRIC}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
     ...    counter_id=M55208C00010    cell_grp_id=${cell_grp_id}
     ${M55208C00011_MAX_DL_NRT_CORE_SVT_METRIC}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
     ...    counter_id=M55208C00011    cell_grp_id=${cell_grp_id}
     ${M55208C00012_AVGE_DL_NRT_CORE_SVT_METRIC}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
     ...    counter_id=M55208C00012    cell_grp_id=${cell_grp_id}
     ${M55208C00013_MIN_UL_NRT_CORE_SVT_METRIC}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
     ...    counter_id=M55208C00013    cell_grp_id=${cell_grp_id}
     ${M55208C00014_MAX_UL_NRT_CORE_SVT_METRIC}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
     ...    counter_id=M55208C00014    cell_grp_id=${cell_grp_id}
     ${M55208C00015_AVGE_UL_NRT_CORE_SVT_METRIC}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
     ...    counter_id=M55208C00015    cell_grp_id=${cell_grp_id}

    Should Be True    ${M55208C00001_MIN_DL_RT_SVRT_METRIC}==0
    Should Be True    ${M55208C00002_MAX_DL_RT_SVRT_METRIC}==0
    Should Be True    ${M55208C00003_AVGE_DL_RT_SVRT_METRIC}==0
    Should Be True    ${M55208C00004_MIN_UL_RT_SVRT_METRIC}==0
    Should Be True    ${M55208C00005_MAX_UL_RT_SVRT_METRIC}==0
    Should Be True    ${M55208C00006_AVGE_UL_RT_SVRT_METRIC}==0
    Should Be True    ${M55208C00007_MAX_NRT_L2POOL_SVRT_METRIC}==0
    Should Be True    ${M55208C00008_AVGE_NRT_L2POOL_SVRT_METRIC}==0
    Should Be True    ${M55208C00009_MIN_DL_NRT_CORE_SVRT_METRIC}==0
    Should Be True    ${M55208C00010_MIN_DL_NRT_CORE_SVT_METRIC}==0
    Should Be True    ${M55208C00011_MAX_DL_NRT_CORE_SVT_METRIC}==0
    Should Be True    ${M55208C00012_AVGE_DL_NRT_CORE_SVT_METRIC}==0
    Should Be True    ${M55208C00013_MIN_UL_NRT_CORE_SVT_METRIC}==0
    Should Be True    ${M55208C00014_MAX_UL_NRT_CORE_SVT_METRIC}==0
    Should Be True    ${M55208C00015_AVGE_UL_NRT_CORE_SVT_METRIC}==0