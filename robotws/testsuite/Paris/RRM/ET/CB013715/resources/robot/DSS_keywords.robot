*** Settings ***
Documentation       DSS GENERIC TEST. Author : Ch SAMSON

Library             OperatingSystem
Library             Collections
Library             DateTime
Library             taf.transport.ssh    WITH NAME    csn
Library             taf.config.scf       WITH NAME    scf
Library             taf.lteemu           WITH NAME    lteemu
Library             ute_wtssim           WITH NAME    wts

Library             ./../python/CB013715_validation.py     WITH NAME    CB013715_validation

*** Keywords ***
Update pattern "${wts_pattern}" into "${testParam}" Context
   ${testParam_dss}                 Tools.Dictionary Get              ${testParam}
   ${testParam_dss.Context.WtsWaitingPattern}      set Variable     ${wts_pattern}
   set suite variable    ${testParam_dss}
   [Return]      ${testParam_dss}

Update DSS DL pattern with
   [Arguments]                    ${testParam}     ${dl_allocated_normal_subframes}

   ${testParam_dss}                 Tools.Dictionary Get              ${testParam}
   ${testParam_dss.seq.dl_allocated_normal_subframes}      set Variable     ${dl_allocated_normal_subframes}
   set suite variable    ${testParam_dss}
   [Return]      ${testParam_dss}

Update DSS UL Allocation type with
   [Arguments]                    ${testParam}     ${allocation_type}

   ${testParam_dss}                 Tools.Dictionary Get              ${testParam}
   ${testParam_dss.seq.ul_allocation_type}      set Variable     ${allocation_type}
   set suite variable    ${testParam_dss}
   [Return]      ${testParam_dss}

Update DSS DL Allocation type with
   [Arguments]                    ${testParam}     ${allocation_type}

   ${testParam_dss}                 Tools.Dictionary Get              ${testParam}
   ${testParam_dss.seq.dl_allocation_type}      set Variable     ${allocation_type}
   set suite variable    ${testParam_dss}
   [Return]      ${testParam_dss}

Update DSS qos load meas timer with
   [Arguments]                    ${testParam}     ${dl_qos_load_meas_timer}=200    ${ul_qos_load_meas_timer}=200

   ${testParam_dss}                 Tools.Dictionary Get              ${testParam}
   ${testParam_dss.seq.dl_qos_load_meas_timer}      set Variable     ${dl_qos_load_meas_timer}
   ${testParam_dss.seq.ul_qos_load_meas_timer}      set Variable     ${ul_qos_load_meas_timer}
   set suite variable    ${testParam_dss}
   [Return]      ${testParam_dss}

#  Keyword with embedded arguments
Update DSS dl qos load meas timer "${dl_qos_load_meas_timer}" ms and ul qos load meas timer "${ul_qos_load_meas_timer}" ms into "${testParam}"
   ${testParam_dss}                 Tools.Dictionary Get              ${testParam}
   ${testParam_dss.seq.dl_qos_load_meas_timer}      set Variable     ${dl_qos_load_meas_timer}
   ${testParam_dss.seq.ul_qos_load_meas_timer}      set Variable     ${ul_qos_load_meas_timer}
   set suite variable    ${testParam_dss}
   [Return]      ${testParam_dss}

Update DSS gNBId_cellid with "${cellid}" into "${testParam}"
   ${testParam_dss}                 Tools.Dictionary Get              ${testParam}
   ${testParam_dss.Context.gNBId_cellid}      set Variable     ${cellid}
   set suite variable    ${testParam_dss}
   [Return]      ${testParam_dss}


Update Blanked PRBs into "${testParam}" for CellId "${CellId}"
    # Get SCF File (SCF.xml) done in test setup
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    # MRBTS-1/NRBTS-1/NRCELL-1
    ${actPRBBlanking}	 scf.get_value_from_scf   p_name=actPRBBlanking
    ...              dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${CellId}
    ${testParam_dss}                 Tools.Dictionary Get              ${testParam}
    ${testParam_dss.scfFile.actPRBBlanking}      set Variable     ${actPRBBlanking}
    ${testParam_dss.scfFile.nrcell.actPRBBlanking}      set Variable     ${actPRBBlanking}
    ${nbrOfBlankedPRBsHighEdgeDL}	 scf.get_value_from_scf   p_name=nbrOfBlankedPRBsHighEdgeDL
    ...              dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${CellId}
    ${testParam_dss}                 Tools.Dictionary Get              ${testParam}
    ${testParam_dss.scfFile.BlankedPRBs.nbrOfBlankedPRBsHighEdgeDL}      set Variable     ${nbrOfBlankedPRBsHighEdgeDL}
    ${nbrOfBlankedPRBsHighEdgeUL}	 scf.get_value_from_scf   p_name=nbrOfBlankedPRBsHighEdgeUL
    ...              dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${CellId}
    ${testParam_dss}                 Tools.Dictionary Get              ${testParam}
    ${testParam_dss.scfFile.BlankedPRBs.nbrOfBlankedPRBsHighEdgeUL}      set Variable     ${nbrOfBlankedPRBsHighEdgeUL}
    ${nbrOfBlankedPRBsLowEdgeDL}	 scf.get_value_from_scf   p_name=nbrOfBlankedPRBsLowEdgeDL
    ...              dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${CellId}
    ${testParam_dss}                 Tools.Dictionary Get              ${testParam}
    ${testParam_dss.scfFile.BlankedPRBs.nbrOfBlankedPRBsLowEdgeDL}      set Variable     ${nbrOfBlankedPRBsLowEdgeDL}
    ${nbrOfBlankedPRBsLowEdgeUL}	 scf.get_value_from_scf   p_name=nbrOfBlankedPRBsLowEdgeUL
    ...              dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${CellId}
    ${testParam_dss}                 Tools.Dictionary Get              ${testParam}
    ${testParam_dss.scfFile.BlankedPRBs.nbrOfBlankedPRBsLowEdgeUL}      set Variable     ${nbrOfBlankedPRBsLowEdgeUL}
    ${type0CoresetConfigurationIndex}	 scf.get_value_from_scf   p_name=type0CoresetConfigurationIndex
    ...              dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${CellId}
    ${testParam_dss}                 Tools.Dictionary Get              ${testParam}
    ${testParam.scfFile.nrcell.type0CoresetConfigurationIndex}      set Variable     ${type0CoresetConfigurationIndex}
    set suite variable    ${testParam_dss}
    [Return]      ${testParam_dss}

Update Blanked PRBs for CellId
    [Arguments]          ${testParam}         ${CellId}

    # Get SCF File (SCF.xml) done in test setup
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    # MRBTS-1/NRBTS-1/NRCELL-1
    ${actPRBBlanking}	 scf.get_value_from_scf   p_name=actPRBBlanking
    ...              dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${CellId}
    ${testParam_dss}                 Tools.Dictionary Get              ${testParam}
    ${testParam_dss.scfFile.actPRBBlanking}      set Variable     ${actPRBBlanking}
    ${testParam_dss.scfFile.nrcell.actPRBBlanking}      set Variable     ${actPRBBlanking}
    ${nbrOfBlankedPRBsHighEdgeDL}	 scf.get_value_from_scf   p_name=nbrOfBlankedPRBsHighEdgeDL
    ...              dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${CellId}
    ${testParam_dss}                 Tools.Dictionary Get              ${testParam}
    ${testParam_dss.scfFile.BlankedPRBs.nbrOfBlankedPRBsHighEdgeDL}      set Variable     ${nbrOfBlankedPRBsHighEdgeDL}
    ${nbrOfBlankedPRBsHighEdgeUL}	 scf.get_value_from_scf   p_name=nbrOfBlankedPRBsHighEdgeUL
    ...              dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${CellId}
    ${testParam_dss}                 Tools.Dictionary Get              ${testParam}
    ${testParam_dss.scfFile.BlankedPRBs.nbrOfBlankedPRBsHighEdgeUL}      set Variable     ${nbrOfBlankedPRBsHighEdgeUL}
    ${nbrOfBlankedPRBsLowEdgeDL}	 scf.get_value_from_scf   p_name=nbrOfBlankedPRBsLowEdgeDL
    ...              dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${CellId}
    ${testParam_dss}                 Tools.Dictionary Get              ${testParam}
    ${testParam_dss.scfFile.BlankedPRBs.nbrOfBlankedPRBsLowEdgeDL}      set Variable     ${nbrOfBlankedPRBsLowEdgeDL}
    ${nbrOfBlankedPRBsLowEdgeUL}	 scf.get_value_from_scf   p_name=nbrOfBlankedPRBsLowEdgeUL
    ...              dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${CellId}
    ${testParam_dss}                 Tools.Dictionary Get              ${testParam}
    ${testParam_dss.scfFile.BlankedPRBs.nbrOfBlankedPRBsLowEdgeUL}      set Variable     ${nbrOfBlankedPRBsLowEdgeUL}
    ${type0CoresetConfigurationIndex}	 scf.get_value_from_scf   p_name=type0CoresetConfigurationIndex
    ...              dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${CellId}
    ${testParam_dss}                 Tools.Dictionary Get              ${testParam}
    ${testParam.scfFile.nrcell.type0CoresetConfigurationIndex}      set Variable     ${type0CoresetConfigurationIndex}
    set suite variable    ${testParam_dss}
    [Return]      ${testParam_dss}


Update DSS ULNbrOfPrb with "${size}" into "${testParam}"
   ${testParam_dss}                 Tools.Dictionary Get              ${testParam}
   ${testParam_dss.seq.ULNbrOfPrb}      set Variable     ${size}
   set suite variable    ${testParam_dss}
   [Return]      ${testParam_dss}

Check ULl1Subpool Assignment
   [Arguments]     ${syslog}=/tmp/

    ${commandToRun}     Catenate
    ...     cat /tmp/btslog2/${syslog} | grep
    ...     'SCellMappingReq.*TCellIdentity = (\d*).*l1SubpoolId\":(\d?)'

    ${output}=        OperatingSystem.Run
    ...    command=cat /tmp/btslog2/${syslog} | grep cprt::cm:: | grep CellMappingReq:
    # ...    command=cat /tmp/btslog2/${syslog} | grep SCellMappingReq:
    should not be empty                  ${output}

    ${ull1spcells_syslog}      CB013715_validation.extract_ull1sp_from_syslog     ${output}
    ...                                                    ${ull1spcells_syslog}    ${testCaseDir}/l2ps-SCellMappingReq-syslog
    set test variable      ${ull1spcells_syslog}
    ${case1}    Run Keyword And Return Status    Should Not Be Empty     ${ull1spcells_syslog[1]}
    ${case2}    Run Keyword And Return Status    Should Not Be Empty     ${ull1spcells_syslog[3]}
    Should be true      ${case1} or ${case2}
    log to console      [ INFO ] Check ULl1Subpool Assignment : ${ull1spcells_syslog}
    # ulSubcellId
    # sp0 = [0, 1, 2]
    # ulsubpoolid => 2 dlsubpool
    dated log         ${consTraceColor}4 ulSubpoolId${defColor}
    # dated log         ${consTraceColor}ulSubcellId/ulsubpoolid : ${l1spcells}${defColor}
    dated log         [ INFO ] ${consTraceColor}Distribution of CellId and ulSubcellId in ulpool/ulSubpoolId: ${ull1spcells_syslog}${defColor}
    dated log         ${consTraceColor} sp0_poolId9 CellId in ulSubpoolId: ${ull1spcells_syslog[0]}${defColor}
    dated log         ${consTraceColor} sp1_poolId9 CellId in ulSubpoolId: ${ull1spcells_syslog[1]}${defColor}
    dated log         ${consTraceColor} sp2_poolId12 CellId in ulSubpoolId: ${ull1spcells_syslog[2]}${defColor}
    dated log         ${consTraceColor} sp3_poolId12 CellId in ulSubpoolId: ${ull1spcells_syslog[3]}${defColor}
    dated log         ${consTraceColor} sp0_poolId9 SubCellId in ulSubpoolId 0: ${ull1spcells_syslog[4]}${defColor}
    dated log         ${consTraceColor} sp1_poolId9 SubCellId in ulSubpoolId 1: ${ull1spcells_syslog[5]}${defColor}
    dated log         ${consTraceColor} sp2_poolId12 SubCellId in ulSubpoolId 2: ${ull1spcells_syslog[6]}${defColor}
    dated log         ${consTraceColor} sp3_poolId12 SubCellId in ulSubpoolId 3: ${ull1spcells_syslog[7]}${defColor}

    Set Suite Variable      ${ull1spcells_syslog}
    [Return]        ${ull1spcells_syslog}

Check Dll1Subpool Assignment
    [Arguments]     ${syslog}

    ${commandToRun}     Catenate
    ...     cat /tmp/btslog2/${syslog} | grep
    ...     'SCellMappingReq.*TCellIdentity = (\d*).*l1SubpoolId\":(\d?)'

    ${output}=        OperatingSystem.Run
    # ...    command=cat /tmp/btslog2/${syslog} | grep SCellMappingReq:
    ...    command=cat /tmp/btslog2/${syslog} | grep cprt::cm:: | grep CellMappingReq:
    should not be empty                  ${output}

    ${dll1spcells_syslog}      CB013715_validation.extract_dll1sp_from_syslog     ${output}
    ...                                                 ${dll1spcells_syslog}   ${testCaseDir}/l2ps-SCellMappingReq-syslog
    set test variable     ${dll1spcells_syslog}
    ${case1}    Run Keyword And Return Status    Should Not Be Empty     ${dll1spcells_syslog[1]}
    ${case2}    Run Keyword And Return Status    Should Not Be Empty     ${dll1spcells_syslog[3]}
    Should be true      ${case1} or ${case2}
    log to console      Check Dll1Subpool Assignment : ${dll1spcells_syslog}
    # dlSubcellId
    # sp0 = [0, 1, 2, 3, 4, 5]
    # dlsubpoolid => 2 dlsubpool
    dated log         ${consTraceColor}4 dlSubpoolId${defColor}
    dated log         ${consTraceColor}Distribution of CellId and dlSubcellId in dlpool/dlSubpoolId: ${dll1spcells_syslog}${defColor}
    dated log         ${consTraceColor} sp0_poolId9 CellId in dlSubpoolId 0: ${dll1spcells_syslog[0]}${defColor}
    dated log         ${consTraceColor} sp1_poolId9 CellId in dlSubpoolId 1: ${dll1spcells_syslog[1]}${defColor}
    dated log         ${consTraceColor} sp2_poolId12 CellId in dlSubpoolId 2: ${dll1spcells_syslog[2]}${defColor}
    dated log         ${consTraceColor} sp3_poolId12 CellId in dlSubpoolId 3: ${dll1spcells_syslog[3]}${defColor}
    dated log         ${consTraceColor} sp0_poolId9 SubCellId in dlSubpoolId 0: ${dll1spcells_syslog[4]}${defColor}
    dated log         ${consTraceColor} sp1_poolId9 SubCellId in dlSubpoolId 1: ${dll1spcells_syslog[5]}${defColor}
    dated log         ${consTraceColor} sp2_poolId12 SubCellId in dlSubpoolId 2: ${dll1spcells_syslog[6]}${defColor}
    dated log         ${consTraceColor} sp3_poolId12 SubCellId in dlSubpoolId 3: ${dll1spcells_syslog[7]}${defColor}

    Set Suite Variable      ${dll1spcells_syslog}

    [Return]        ${dll1spcells_syslog}

update bbpoolInfo Dll1Subpool and Ull1Subpool Assignment
    ${cellSetupInfos}      Create Dictionary
    ${isFileNameDLCellMappingPresent}    Run Keyword And Return Status    Should Not Be Empty   ${FileNameDLCellMapping}
    Run Keyword If    '${isFileNameDLCellMappingPresent}' == 'False'
    ...                BuiltIn.Log    DL Cell mapping file not present (from Syslog), please check the config...    level=WARN    console=yes
    ${all_equal}    ${l1poolId}=    Run Keyword If   ${isFileNameDLCellMappingPresent}    check Dl Cell mapping from Syslog ${FileNameDLCellMapping}
    ...                                   ELSE                                            ObtainVariablesKeyword
    # 2 l1pools => 2 cases    ${l1poolId}=9 or ${l1poolId}=12
    ${dll1spcells}=     Create List
    ${ull1spcells}=     Create List
    ${l1poolId_nb}=     Evaluate     list(${l1poolId})[0]
    ${l1spcells_idx}    Set Variable If     '${l1poolId_nb}' == '9'     ${4}
    ...                                                                 ${6}
    ${l1spcells_idx_1}     Evaluate     ${l1spcells_idx}+${1}
    Append To List     ${dll1spcells}    ${dll1spcells_syslog[${l1spcells_idx}]}
    Append To List     ${dll1spcells}    ${dll1spcells_syslog[${l1spcells_idx_1}]}
    Append To List     ${ull1spcells}    ${ull1spcells_syslog[${l1spcells_idx}]}
    Append To List     ${ull1spcells}    ${ull1spcells_syslog[${l1spcells_idx_1}]}
    ${l1spcells}           Create Dictionary      dlL1SpCells     ${dll1spcells}       ulL1SpCells     ${ull1spcells}
    Set To Dictionary      ${cellSetupInfos}      l1poolId      ${l1poolId_nb}
    Set To Dictionary      ${cellSetupInfos}      l1SpCells     ${l1spcells}
    # Add indentation (4 spaces) to the JSON string
    # ${formatted_json_data}        Evaluate    json.dumps(${cellSetupInfos}, indent=4)       json
    ${formatted_json_data}        Evaluate    json.dumps(${cellSetupInfos})       json
    # Save the formatted JSON to the file
    OperatingSystem.Create File    ${testCaseDir}/bbpoolInfo_cell_setup.json    ${formatted_json_data}
    [return]     ${cellSetupInfos}

Check cellmappingtocsirspoolinggroup Assignment in Syslogs
   ${commandToRun}     Catenate     cd /tmp/btslog2; find . -name "*.LOG" -type f | sort | sed -e 's/^\\.\\///g'
   ${ret}    ${syslogfiles}     Run Keyword And Ignore Error    Run   ${commandToRun}
   ${sysLog_files_list}    Split String    ${syslogfiles}    separator=\n
   FOR    ${syslog}    IN    @{sysLog_files_list}
         dated log    Computing syslog File ${consTraceColor}${syslog}${defColor}...
         ${contains_no_Syslogs}=     Run Keyword And Return Status       Should Not Contain     ${syslog}     ${EMPTY}
         # ${contains_no_Syslogs}==True   => Syslog are not present !!!
         # Run Keyword if   '${contains_no_Syslogs}' == 'True'   dated log    ${consTraceColorRed}syslog are not present !!!${defColor}
         Run Keyword if   '${contains_no_Syslogs}' == 'False'  robot_extension.Run Keyword And Warn On Failure
         ...                                                                display cellmappingtocsirspoolinggroup in SysLog    syslog=${syslog}
         ...    ELSE                                dated log    ${consTraceColorRed}syslog are not present !!!${defColor}

Check UL and DL l1Subpool Assignment in Syslogs
   ${commandToRun}     Catenate     cd /tmp/btslog2; find . -name "*.LOG" -type f | sort | sed -e 's/^\\.\\///g'
   ${ret}    ${syslogfiles}     Run Keyword And Ignore Error    Run   ${commandToRun}
   ${sysLog_files_list}    Split String    ${syslogfiles}    separator=\n
   FOR    ${syslog}    IN    @{sysLog_files_list}
         dated log    Computing syslog File ${consTraceColor}${syslog}${defColor}...
         ${contains_no_Syslogs}=     Run Keyword And Return Status       Should Not Contain     ${syslog}     ${EMPTY}
         # ${contains_no_Syslogs}==True   => Syslog are not present !!!
         # Run Keyword if   '${contains_no_Syslogs}' == 'True'   dated log    ${consTraceColorRed}syslog are not present !!!${defColor}
         Run Keyword if   '${contains_no_Syslogs}' == 'False'  robot_extension.Run Keyword And Warn On Failure
         ...                                            DSS_keywords.Check ULl1Subpool Assignment    syslog=${syslog}
         ...    ELSE                                dated log    ${consTraceColorRed}syslog are not present !!!${defColor}
         Run Keyword if   '${contains_no_Syslogs}' == 'False'  robot_extension.Run Keyword And Warn On Failure
         ...                                            DSS_keywords.Check Dll1Subpool Assignment    syslog=${syslog}
         ...    ELSE                                dated log    ${consTraceColorRed}syslog are not present !!!${defColor}
         # Run Keyword if   '${contains_no_Syslogs}' == 'False'  robot_extension.Run Keyword And Warn On Failure
         # ...                                          DSS_keywords.display totalStreamPrbs per l1PoolId in SysLog    syslog=${syslog}
         ...    ELSE                                dated log    ${consTraceColorRed}syslog are not present !!!${defColor}
   END

display totalStreamPrbs per l1PoolId in SysLog
    [Documentation]   Analyzing this kind of Syslog trace
    ...    8D-cp_rt INF/cp_rt/CsiRsPoolingGroupsTdd.cpp:58 Created 3 CsiRsPoolingGroup(s) with totalStreamPrbs:2184 in l1PoolId:10
    [Arguments]     ${syslog}=/tmp/

    ${commandToRun}     Catenate
    ...     cat /tmp/btslog2/${syslog} | grep
    ...     'CsiRsPoolingGroup.*totalStreamPrbs*\d*.*l1PoolId\:(\d?)'

    ${output}=        OperatingSystem.Run
    ...    command=cat /tmp/btslog2/${syslog} | grep CsiRsPoolingGroup
    should not be empty                  ${output}

    ${totalStreamPrbs_l1PoolId_0}  ${totalStreamPrbs_l1PoolId_10}  ${cellmappingtocsirspoolinggroup}  extract_totalStreamPrbs_from_syslog   ${output}
    Should Not Be Empty     ${totalStreamPrbs_l1PoolId_0}
    log to console      totalStreamPrbs Assignment for l1PoolId 9: ${totalStreamPrbs_l1PoolId_0}
    log to console      totalStreamPrbs Assignment for l1PoolId 12: ${totalStreamPrbs_l1PoolId_10}
    log to console      cellmappingtocsirspoolinggroup: ${cellmappingtocsirspoolinggroup}
    ${msg}=   Catenate   totalStreamPrbs Assignment for l1PoolId 9 like [l1PoolId=0, totalStreamPrbs=2184]:
    dated log         ${consTraceColor}${msg} ${totalStreamPrbs_l1PoolId_0}${defColor}
    ${msg}=   Catenate   totalStreamPrbs Assignment for l1PoolId 12 like [l1PoolId=10, totalStreamPrbs=2184]:
    dated log         ${consTraceColorYellow}${msg} ${totalStreamPrbs_l1PoolId_10}${defColor}
    Set Suite Variable      ${totalStreamPrbs_l1PoolId_10}
    Set Suite Variable      ${totalStreamPrbs_l1PoolId_0}
    # ${msg}=   Catenate   cellmappingtocsirspoolinggroup :
    # dated log         ${consTraceColor}${msg} ${cellmappingtocsirspoolinggroup}${defColor}
    # CsiRsPoolingGroupsTdd.cpp:110 added NrCellIdentity:16385 with streamPrbDemand:1092 to CsiRsPoolingGroup 0
    #    (allocatedStreamPrbs:1092) in l1PoolId:10
    # ${msg}=   Catenate   CsiRsPoolingGroupsTdd: added NrCellIdentity: ( ) with streamPrbDemand: ( ) to CsiRsPoolingGroup ( )
    # ${msg}=   Catenate   ${msg} (allocatedStreamPrbs: ( )) in l1PoolId: ( )
    # dated log         ${consTraceColor}${msg} ${cellmappingtocsirspoolinggroup[0]}${defColor}
    # dated log         ${consTraceColor}${msg} ${cellmappingtocsirspoolinggroup[1]}${defColor}
    # dated log         ${consTraceColor}${msg} ${cellmappingtocsirspoolinggroup[2]}${defColor}
    Should Not Be Empty    ${cellmappingtocsirspoolinggroup}    msg=cellmappingtocsirspoolinggroup is empty
    ${msg}=  Catenate   CsiRsPoolingGroupsTdd: added NrCellIdentity: (${cellmappingtocsirspoolinggroup[0]}[0]) with streamPrbDemand:
    ${msg}=  Catenate   ${msg} (${cellmappingtocsirspoolinggroup[0]}[1]) to CsiRsPoolingGroup (${cellmappingtocsirspoolinggroup[0]}[2])
    ${msg}=  Catenate  ${msg} (allocatedStreamPrbs: (${cellmappingtocsirspoolinggroup[0]}[3])) in l1PoolId: (${cellmappingtocsirspoolinggroup[0]}[4])
    dated log         ${consTraceColor}${msg}${defColor}
    ${msg}=  Catenate  CsiRsPoolingGroupsTdd: added NrCellIdentity: (${cellmappingtocsirspoolinggroup[1]}[0]) with streamPrbDemand:
    ${msg}=  Catenate  ${msg} (${cellmappingtocsirspoolinggroup[1]}[1]) to CsiRsPoolingGroup (${cellmappingtocsirspoolinggroup[1]}[2])
    ${msg}=  Catenate  ${msg} (allocatedStreamPrbs: (${cellmappingtocsirspoolinggroup[1]}[3])) in l1PoolId: (${cellmappingtocsirspoolinggroup[1]}[4])
    dated log         ${consTraceColor}${msg}${defColor}
    ${msg}=  Catenate  CsiRsPoolingGroupsTdd: added NrCellIdentity: (${cellmappingtocsirspoolinggroup[0]}[0]) with streamPrbDemand:
    ${msg}=  Catenate  ${msg} (${cellmappingtocsirspoolinggroup[2]}[1]) to CsiRsPoolingGroup (${cellmappingtocsirspoolinggroup[2]}[2])
    ${msg}=  Catenate  ${msg} (allocatedStreamPrbs: (${cellmappingtocsirspoolinggroup[2]}[3])) in l1PoolId: (${cellmappingtocsirspoolinggroup[2]}[4])
    dated log         ${consTraceColor}${msg}${defColor}
    Set Suite Variable      ${totalStreamPrbs_l1PoolId_10}
    [Return]        ${totalStreamPrbs_l1PoolId_10}
