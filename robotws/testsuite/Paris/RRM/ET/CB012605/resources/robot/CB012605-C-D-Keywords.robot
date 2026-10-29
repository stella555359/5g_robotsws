*** Settings ***
Documentation     [SUITE PURPOSE] CB012605 Test suite for Subfeature C and D
...                               Cell deletion/addition and counters checks in DL and UL
...
...               Test Case Scenario author   : blandine.garnier@nokia.com
...               Test Case automation author : blandine.garnier@nokia.com / laurent.puchelle@nokia.com
...               Creation Date               : 2024-07-01
...               Modified Date               : 2024-10-15
...               Last Modified by            : laurent.puchelle@nokia.com
...               Modification:
...                       2024-07-01          | Creation
...                       2024-10-15          | refactoring, implementation of KPI and TTI checks
...                       2025-02-19          | Modification to register all Ues after add


Resource          ./CB012605-Common-Keywords.robot


*** Variables ***

# Vendor file parameters
#-----------------------
# ${actBbPoolingTddFr1Ecpri72e_val}     true
${actDPAOverloadControl_val}          false
${actEcpri72e_val}                    Ecpri72eULDL
# Fronthaul interface resolution for PUSCH IQ data in eCPRI 7-2e UL split
${xEc_val}                            14
# Fronthaul interface resolution for PUSCH Normalization Factor in eCPRI 7-2e UL split
${betaEc_val}                         13
# maximum number of layer PRB by L1 subpool for DL
${MAX_NUM_LAYER_PRB_L1_SUBPOOL_DL}    800
${MAX_NUM_LAYER_PRB_L1_POOL_DL}       1600
# maximum number of stream PRB by L1 subpool for UL
${MAX_NUM_LAYER_PRB_L1_SUBPOOL_UL}    200
${MAX_NUM_LAYER_PRB_L1_POOL_UL}       400

# vendor's setting
#-----------------
@{custom_actEcpri72e}
# ...    NRBTS.actBbPoolingTddFr1Ecpri72e=${actBbPoolingTddFr1Ecpri72e_val}
...    NRBTS.actDPAOverloadControl=${actDPAOverloadControl_val}
# ...    NRBTS.actEcpri72e=${actEcpri72e_val}
...    NRBTS.xEc=${xEc_val}
...    NRBTS.betaEc=${betaEc_val}
...    NRBTS.bbL1SpPrbInitCapacity___ABIP___4811___DL___NR_L1Pool_Thor_TDD_FR1_eCPRI_7_2e.maxNumLayerPrbL1Sp=${MAX_NUM_LAYER_PRB_L1_SUBPOOL_DL}
...    NRBTS.bbL1SpPrbInitCapacity___ABIP___4811___UL___NR_L1Pool_Thor_TDD_FR1_eCPRI_7_2e.maxNumLayerPrbL1Sp=${MAX_NUM_LAYER_PRB_L1_SUBPOOL_UL}


# gNB RAD param setting
#----------------------
@{rdParam_actEcpri72e}
#...    ${rdBbPoolTddFr1Ecpri72e}=15
...    ${rdFakeUeSchedulingEnable}=0
...    ${rdHARQDisableIncrRedundancyDl}=1
...    ${enabledNewCeFrameworkFlagInDu}=0
# Don't set RAD parameters concerning specific traces
#...    ${rdAaSysLogInputLevel}=1
#...    ${rdFEAT_DBG_BTSOM_BBC}=1
#...    ${rdFEAT_DBG_Rpmag}=2
#...    ${rdFEAT_DBG_BTSOM_APW}=2

${custom_SCF}    ${CURDIR}/../../config/customCFG/Scf_pooling_ecpri72e_lte3ms.xml
${custom_CFG}    ${CURDIR}/../../config/customCFG/basic_setup_ecpri72e.cfg
${custom_IPHY}   ${CURDIR}/../../config/customCFG/iphy_ecpri72e.xml

# csv constraints files for counters checks
${constraints_onAir}     ${CURDIR}/../../config/countersKPI/CB012605_C_cellDeletionAddition_onAir.csv
${constraints_6cells}    ${CURDIR}/../../config/countersKPI/CB012605_C_cellDeletionAddition_cellAdded_6UEs.csv


# expected min/max numAllocCellLayerPrb
#--------------------------------------
${DLminNbLayerPrb_onAir}     533
${DLmaxNbLayerPrb_onAir}     534
${DLminNbLayerPrb_5cells}    450
${DLmaxNbLayerPrb_5cells}    900
${DLminNbLayerPrb_6cells}    450
${DLmaxNbLayerPrb_6cells}    700

${ULminNbLayerPrb_onAir}     133
${ULmaxNbLayerPrb_onAir}     134
${ULminNbLayerPrb_5cells}    50
${ULmaxNbLayerPrb_5cells}    320
${ULminNbLayerPrb_6cells}    50
${ULmaxNbLayerPrb_6cells}    250

${DLthroughput}    100
${ULthroughput}    50

${robLoop}         5


*** Keywords ***
TC_CB012605_C_D_Cell_Deletion_Addition_Counters
    TC_CB012605_C_D_Cell_Deletion_Addition_Counters_Loop    loopNb=${robLoop}


# ----- CCB012605_C_D keywords ----------------------------------------------------------------------
TC_CB012605_C_D_Cell_Deletion_Addition_Counters_Loop
    [Arguments]              ${loopNb}=1

    # Configuration and cell setup
    ${syslogCellSetup}       CB012605_Custom_Setup    SCF=${custom_SCF}      CFG=${custom_CFG}    rdParam=@{rdParam_actEcpri72e}
    ...                                               IPHY=${custom_IPHY}    vendorParam=@{custom_actEcpri72e}

    # TTI capture configuration
    ${TTIdir}                Get TTI Trace Path    dir_suffix=cell_del_add

    # Capture TTI and get counters in "on air" state (no UE attached)
    ${TTI_onAir}    ${PM_onAir}
    ...                      CB012605_Wait_End_ZOI    PMdir=${LOG_PATH}/PM    TTIdir=${TTIdir}    suffix=_onAir

    # Attach UEs with traffic
    ${UElist}                CB012605_C_D_Build_UEs_list
    FOR    ${UEsetting}    IN    @{UElist}
        Dated Log New Line    ====> Attach UE ${UEsetting.ue}
        UE Register           ue=${UEsetting.ue}
        Launch PDU Session    ue=${UEsetting.ue}    pdu=${UEsetting.pdu}    gw=${UEsetting.ue}

        Traffic UE DL         ueSetting=${UEsetting}    throughput=${DLthroughput}
        ...                   shouldBeStop=False        shouldBeCheck=False
        ...                   duration=0

        Traffic UE UL         ueSetting=${UEsetting}    throughput=${ULthroughput}
        ...                   shouldBeStop=False        shouldBeCheck=False
        ...                   duration=0
    END

    # Create json files to delete and add cell 1
    ${jsonCellDeletion}      ${jsonCellAddition}
    ...                      CB012605_C_D_Prepare_Cell_Deletion_And_Addition_Delta_Files    cellID=1

    ${gnb_alias}             Set Variable        gNB
    sbts_coam.connect_to     name=${gnb_alias}

    @{TTI_5cells_List}       Create List
    @{TTI_6cells_List}       Create List
    @{PM_6cells_List}        Create List
    @{SyslogDelCell_List}    Create List
    @{SyslogAddCell_List}    Create List

    ${loopIdMax}             Evaluate    ${loopNb}+1
    FOR    ${Loop}    IN RANGE    1   ${loopIdMax}
        Dated Log New Line       ====================================
        Dated Log New Line       =========== LOOP ${Loop} / ${loopNb}
        Dated Log New Line       ====================================

        Dated Log New Line       ====> Detach UE1 (cell 1)
        Traffic Stop             ueSetting=${UElist[0]}    dir=dl
        Traffic Stop             ueSetting=${UElist[0]}    dir=ul
        UE Deregister            id=${UElist[0].ue}

        Dated Log New Line       ====> perform cell deletion
        ${syslog}                SYSLOG Start    host=${GNB_DU.sys[0].M}    name=cellDel_${Loop}
        coam_parameter.perform_scf_delta_commission
        ...                      delta_file=${jsonCellDeletion}
        ...                      connection=${gnb_alias}
        Sleep                    10    msg=SYSLOG capture
        ${syslogDelCell}         SYSLOG Stop     syslog=${syslog}
        Append To List           ${SyslogDelCell_List}    ${syslogDelCell}

        Dated Log New Line       ====> Start TTI trace capture
        Start TTI Traces in Streaming mode    src_ip=10.0.1.2
        Traced Sleep             5    msg=capture TTI trace
        ${TTI_5cells}            Stop TTI Traces in Streaming mode    tti_trace_path=${TTIdir}    tti_trace_filename=TTItrace_5cells_${Loop}
        Append To List           ${TTI_5cells_List}    ${TTI_5cells}

        Dated Log New Line       ====> perform cell re-addition
        ${syslog}                SYSLOG Start    host=${GNB_DU.sys[0].M}    name=cellAdd_${Loop}
        coam_parameter.perform_scf_delta_commission
        ...                      delta_file=${jsonCellAddition}
        ...                      connection=${gnb_alias}
        Sleep                    15    msg=SYSLOG capture
        ${syslogAddCell}         SYSLOG Stop     syslog=${syslog}
        Append To List           ${SyslogAddCell_List}    ${syslogAddCell}

		Sleep                    180

        # Re-attach UE1 on cell 1  with DL and UL traffic
	    UE Register           ue=${UElist[0].ue}
        Launch PDU Session    ue=${UElist[0].ue}    pdu=${UElist[0].pdu}    gw=${UElist[0].ue}

        Traffic UE DL         ueSetting=${UElist[0]}    throughput=${DLthroughput}
        ...                   shouldBeStop=False        shouldBeCheck=False
        ...                   duration=0

        Traffic UE UL         ueSetting=${UElist[0]}    throughput=${ULthroughput}
        ...                   shouldBeStop=False        shouldBeCheck=False
        ...                   duration=0

        # Capture TTI and get counters (one UE attached on the 6 cells)
        ${TTI_6cells}    ${PM_6cells}
        ...                      CB012605_Wait_End_ZOI    PMdir=${LOG_PATH}/PM    TTIdir=${TTIdir}    suffix=_6cells_${Loop}
        Append To List           ${TTI_6cells_List}    ${TTI_6cells}
        Append To List           ${PM_6cells_List}     ${PM_6cells}
    END

    # Detach all UEs
    FOR    ${UEsetting}    IN    @{UElist}
        Dated Log New Line    ====> Detach UE ${UEsetting.ue}
        Traffic Stop          ueSetting=${UEsetting}    dir=dl
        Traffic Stop          ueSetting=${UEsetting}    dir=ul
        UE Deregister         id=${UEsetting.ue}
    END

    # Convert TTI traces in json and csv
    ${TTIjson_onAir}             Convert TTItrace from pcap to others    input_file_path=${TTI_onAir}
    ${TTIcsv_onAir}              decode_tti_traces_json_using_TtitraceReaderEvtDec    jsonPathName=${TTIjson_onAir}    num_of_events=100000

    ${TTIjson_5cells}            Convert TTItrace from pcap to others    input_file_path=${TTI_5cells}
    ${TTIcsv_5cells}             decode_tti_traces_json_using_TtitraceReaderEvtDec    jsonPathName=${TTIjson_5cells}    num_of_events=100000

    ${TTIjson_6cells}            Convert TTItrace from pcap to others    input_file_path=${TTI_6cells}
    ${TTIcsv_6cells}             decode_tti_traces_json_using_TtitraceReaderEvtDec    jsonPathName=${TTIjson_6cells}    num_of_events=100000

    # Get list of cells per L1pool for DL and UL at cell setup
    ${DlCellsPerL1pool}    ${UlCellsPerL1pool}
    ...                          getCellPerL1pool_from_syslog        ${syslogCellSetup}

    # Update list of cells per L1pool for DL and UL after cell addition
    ${DlCellsPerL1poolUpd}    ${UlCellsPerL1poolUpd}
    ...                          updateCellPerL1pool_from_syslog     ${syslogAddCell}    ${DlCellsPerL1pool}    ${UlCellsPerL1pool}

    # Check TTI "on air"
    Dated Log New Line                ====> Check TTI ON AIR
    ${statusOnAirSubPoolId}           check_SubpoolId_consistency                      jsonPathName=${TTIjson_onAir}
    ${status_OnAir_LayerPrbCapDL}     check_DLl1SubPoolLayerPrbCapacity_consistency    jsonPathName=${TTIjson_onAir}
    ...                                                                                poolMaxNumLayerPrb=${MAX_NUM_LAYER_PRB_L1_POOL_DL}
    ${status_OnAir_LayerPrbCapUL}     check_ULl1SubPoolLayerPrbCapacity_consistency    jsonPathName=${TTIjson_onAir}
    ...                                                                                poolMaxNumLayerPrb=${MAX_NUM_LAYER_PRB_L1_POOL_UL}
    ${status_OnAir_MaxAllocDL}        check_maxAllocLayerPrbPerL1poolDl                jsonPathName=${TTIjson_onAir}
    ...                                                                                cellsPerL1pool=${DlCellsPerL1pool}
    ...                                                                                maxNbLayerPrb=${MAX_NUM_LAYER_PRB_L1_POOL_DL}
    ${status_OnAir_MaxAllocUL}        check_maxAllocLayerPrbPerL1poolUl                jsonPathName=${TTIjson_onAir}
    ...                                                                                cellsPerL1pool=${UlCellsPerL1pool}
    ...                                                                                maxNbLayerPrb=${MAX_NUM_LAYER_PRB_L1_POOL_UL}

    # Check TTI "cell deleted"
    Dated Log New Line                ====> Check TTI with cell1 removed
    ${status_5cells_LayerPrbCapDL}    check_DLl1SubPoolLayerPrbCapacity_consistency    jsonPathName=${TTIjson_5cells}
    ...                                                                                poolMaxNumLayerPrb=${MAX_NUM_LAYER_PRB_L1_POOL_DL}
    ${status_5cells_LayerPrbCapUL}    check_ULl1SubPoolLayerPrbCapacity_consistency    jsonPathName=${TTIjson_5cells}
    ...                                                                                poolMaxNumLayerPrb=${MAX_NUM_LAYER_PRB_L1_POOL_UL}
    ${status_5cells_MaxAllocDL}       check_maxAllocLayerPrbPerL1poolDl                jsonPathName=${TTIjson_5cells}
    ...                                                                                cellsPerL1pool=${DlCellsPerL1pool}
    ...                                                                                maxNbLayerPrb=${MAX_NUM_LAYER_PRB_L1_POOL_DL}
    ${status_5cells_MaxAllocUL}       check_maxAllocLayerPrbPerL1poolUl                jsonPathName=${TTIjson_5cells}
    ...                                                                                cellsPerL1pool=${UlCellsPerL1pool}
    ...                                                                                maxNbLayerPrb=${MAX_NUM_LAYER_PRB_L1_POOL_UL}

    # Check TTI "cell re-added"
    Dated Log New Line                ====> Check TTI with cell1 re-added
    ${status_6cells_LayerPrbCapDL}    check_DLl1SubPoolLayerPrbCapacity_consistency    jsonPathName=${TTIjson_6cells}
    ...                                                                                poolMaxNumLayerPrb=${MAX_NUM_LAYER_PRB_L1_POOL_DL}
    ${status_6cells_LayerPrbCapUL}    check_ULl1SubPoolLayerPrbCapacity_consistency    jsonPathName=${TTIjson_6cells}
    ...                                                                                poolMaxNumLayerPrb=${MAX_NUM_LAYER_PRB_L1_POOL_UL}
    ${status_6cells_MaxAllocDL}       check_maxAllocLayerPrbPerL1poolDl                jsonPathName=${TTIjson_6cells}
    ...                                                                                cellsPerL1pool=${DlCellsPerL1poolUpd}
    ...                                                                                maxNbLayerPrb=${MAX_NUM_LAYER_PRB_L1_POOL_DL}
    ${status_6cells_MaxAllocUL}       check_maxAllocLayerPrbPerL1poolUl                jsonPathName=${TTIjson_6cells}
    ...                                                                                cellsPerL1pool=${UlCellsPerL1poolUpd}
    ...                                                                                maxNbLayerPrb=${MAX_NUM_LAYER_PRB_L1_POOL_UL}

    ${status_cellDistrib}             CB012605_Check_cells_distribution    syslog=${syslogCellSetup}

    # Evaluate counters value in state "on air"
    ${statusKPI_onAir}           KPI Evaluate    pmFile=${PM_onAir}    constraintsFile=${constraints_onAir}    failOnError=${False}

    # Evaluate counters value with one UE attached on the 6 cells
    ${statusKPI_6cells}          Set Variable    ${true}
    FOR    ${PMfile}    IN    @{PM_6cells_List}
        ${statusKPI}                 KPI Evaluate    pmFile=${PM_6cells}    constraintsFile=${constraints_6cells}    failOnError=${False}
        ${statusKPI_6cells}          Evaluate    ${statusKPI} and ${statusKPI_6cells}
    END

    Should be true               ${statusOnAirSubPoolId} and ${status_OnAir_LayerPrbCapDL} and ${status_OnAir_MaxAllocDL}
    Should be true               ${status_OnAir_LayerPrbCapUL} and ${status_OnAir_MaxAllocUL}
    Should be true               ${status_5cells_LayerPrbCapDL} and ${status_5cells_MaxAllocDL}
    Should be true               ${status_5cells_LayerPrbCapUL} and ${status_5cells_MaxAllocUL}
    Should be true               ${status_6cells_LayerPrbCapDL} and ${status_6cells_MaxAllocDL}
    Should be true               ${status_6cells_LayerPrbCapUL} and ${status_6cells_MaxAllocUL}
    Should be true               ${status_cellDistrib} and ${statusKPI_onAir} and ${statusKPI_6cells}


CB012605_C_D_Build_UEs_list
    [Documentation]
    ...     Actions:         Builds UEs list according to the UEs defined in customized basic CFG for TC cell deletion/addition
    ...     Parameters:      None
    ...     Return:          List of UEs

    @{listOfUes}             Create List
    FOR    ${UEid}    IN RANGE    1    7
        ${current_ueSetting}    Copy Dictionary         ${BASIC_UE_SA}
        Set To Dictionary       ${current_ueSetting}    ue    ${UEid}
        Append To List          ${listOfUes}            ${current_ueSetting}
    END
    RETURN                      ${listOfUes}


CB012605_C_D_Create_Cmd_To_Update_RefNrCellGroup
    [Documentation]
    ...     Actions:         Create a command to update RefNrCellGroup without cell group ID given
    ...     Parameters:      cellGrpId: cell group ID associated to the cell to delete
    ...                      nrduId: ID of the NRDU object including RefNrCellGroup to update
    ...     Return:          Command to update RefNrCellGroup
    [Arguments]              ${cellGrpId}    ${nrduId}=1

    ${refNrCellGroupList}    scf.get_all_values_from_scf
    ...                      dist_name=MRBTS-${TMRBTS_ID[0]}/NRBTS-${TNRBTS_ID[0]}/NRDU-${nrduId}
    ...                      list_name=refNrCellGroup

    ${updateCmd}            Set Variable     modify:NRDU-${nrduId}:refNrCellGroup=
    FOR    ${grpID}    IN    @{refNrCellGroupList}
        ${updateCmd}         Run Keyword If    ${grpID} != ${cellGrpId}
        ...                      Set Variable    ${updateCmd}${grpID},
        ...                  ELSE
        ...                      Set Variable    ${updateCmd}
    END
    ${updateCmd}             Replace String Using Regexp    string=${updateCmd}    pattern=,$    replace_with=${EMPTY}

    @{cmdList}               Create List         ${updateCmd}
    Dated Log                Command to update RefNrCellGroup: ${cmdList}
    RETURN                   ${cmdList}


CB012605_C_D_Prepare_Cell_Deletion_And_Addition_Delta_Files
    [Documentation]
    ...     Actions:         Builds the delta json files to delete and re-add a cell
    ...     Parameters:      cellID: cell ID of the cell
    ...     Return:          json for cell deletion and json for cell re-addition
    [Arguments]              ${cellID}

    ${originalScfFile}       OAM Get SCF File    file=SCF_TC_original.xml
    scf.load_scf	         ${originalScfFile}

    ${dist_name_nrcell}      Set Variable              MRBTS-${TMRBTS_ID[0]}/NRBTS-${TNRBTS_ID[0]}/NRCELL-${cellID}
    ${LCELNRid}              scf.get_value_from_scf    dist_name=${dist_name_nrcell}    p_name=lcrId
    ${dist_name_lcelnr}      Set Variable              MRBTS-${TMRBTS_ID[0]}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${LCELNRid}
    ${dist_name_nrcellgrp}   OAM Get NR Cell GROUP     NRCellId=${cellID}

    Dated Log New Line       === Build json for cell deletion and addition
    Dated Log                dist_name_lcelnr ------ ${dist_name_lcelnr}
    Dated Log                dist_name_nrcell ------ ${dist_name_nrcell}
    Dated Log                dist_name_nrcellgrp --- ${dist_name_nrcellgrp}

    scf.remove_mo_with_descendant_mos    dist_name=${dist_name_nrcell}
    scf.remove_mo_with_descendant_mos    dist_name=${dist_name_lcelnr}
    scf.remove_mo_with_descendant_mos    dist_name=${dist_name_nrcellgrp}

    ${NRCELLGRPid}           Replace String Using Regexp    string=${dist_name_nrcellgrp}    pattern=.*NRCELLGRP-    replace_with=${EMPTY}
    ${RefNrCellGroup_update_cmd}    CB012605_C_D_Create_Cmd_To_Update_RefNrCellGroup    cellGrpId=${NRCELLGRPid}
    scf.perform_scf_modification    ${RefNrCellGroup_update_cmd}

    ${SCF_5cells}       Set Variable    ${LOG_PATH}/SCF_TC_5cells.xml
    scf.save_scf             file_path=${SCF_5cells}

    ${jsonCellDeletion}      Set Variable    ${LOG_PATH}/Cell_deletion.json
    ${jsonCellAddition}      Set Variable    ${LOG_PATH}/Cell_addition.json

    scf.calculate_delta_scf  target_scf_path=${SCF_5cells}    actual_scf_path=${originalScfFile}    delta_scf_path=${jsonCellDeletion}
    scf.calculate_delta_scf  target_scf_path=${originalScfFile}    actual_scf_path=${SCF_5cells}    delta_scf_path=${jsonCellAddition}
    RETURN                   ${jsonCellDeletion}    ${jsonCellAddition}
