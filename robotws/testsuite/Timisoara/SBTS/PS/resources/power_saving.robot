*** Settings ***
Library  DateTime
Library  ute_syslog
Library  taf.sbts.oam.coam.admin  WITH NAME  admin

Documentation
...  AUTHORS:
...  MAINTAINER:    RAN_VRF_TSR1_T05
...  *****************
...  Basic information
...  *****************
...  Internal WRO1 resource library repetitive keywords in multiple tests.
...  ******************
...  History of changes
...  ******************
...  06.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-293 - New kw created "Overlapping Preiods For Same Cells"
...  07.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-302 - New kw's created "Check Power Saving NR", "Select Two Random NR Cells",
...                                                                 "Create And Activate NRPGRP For CB008745", "Shift Time For PSGRP",
...                                                                 "Create And Activate PSGRP For CB008745", "Shift Time For NRPGRP"
...  15.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-326 - New KW Cell Barred/NotBarred
...  16.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-212 - New kw's created "Suspend/notSuspend PowerSaving NR",
...                                                                 "Create And Activate NRPGRP for 5GC000431", "Select All NR Cells"
...  12.04.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-350 - Create And Activate NRPGRP KWs modified for SBTS00 - updated on 26.04.2023
...  14.04.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-353 - Create And Activate PSGRP KWs modified
...  26.04.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-350 - Test case adaption for CB010683 - mandatory parameter lbpsUseExtConfig added
...  26.04.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-350 - KW Get Parameter Value Under NRBTS added
...  02.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-369 - KW's "Create And Activate PSGRP FOR LTE1103/1203/CB00880/LTE3330/CB008745"
...                                                                 have been changed.
...  15.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-377 - New KW - Wait for date
...  05.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-376 - New KW - "Create And Activate SWRESETREQ", "Check For Specofic Time"
...                                                                 "Delete Old SWRESETREQ Object", "Remove SWRESETREQ Object If Exists"
...  07.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-380 - fix test automation shutdown method for FSMF
...  27.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-390 - New KW - Create And Activate NRPGRP For CB010683; Get NR Cells For CB10683
...  23.08.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-419 - Added SBTS24R1 to all Create and activate PSGRP KWs
...  12.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-413 - Create And Activate NRPGRP For CB010683 modified to work on tests 39 and 41
...                                                                 Get NR Cells For CB010683 modified to create standalone keyword:
...                                                                 Get NR MIMO/NotMIMO cells and RMODS lists
...  18.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-426 - Change logic in release verification in Create and Activate PSGRP KWs
...  19.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-375 - New KW - Check cell_m operational state
...                                                                 New KW - Check syslog for Graceful cell shutdown message
...  27.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-405 - TC for CB010683 adaptation for non mMIMO BTS
...  06.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-469 - New KW - Set Default LoadSettings For LNCELs
...  21.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-428 - New KWs due to TC PS.46 creation
...  04.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-477 - New KWs due to KW Select Two Random NR Cells NSA creation
...  20.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-478 - New KW Get one cell for each technology
...  06.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-495 - New KW - "Remove RMOD dcPortWinList", "Reconfigure DCPort Time Schedule"
...                                                                 "Prepare To Power Off Via FPFH DC Port", "Get All Radios And Their Cells",
...                                                                 "Choose Matching Nrcell IDs From RMOD", "Get Selected RU Info",
...                                                                 "Return Proper Distname For RU", "Check DCPort Power State And Maintenance Mode",
...                                                                 "Check Radio State DC Port PWROFF", "Create deepSleepTimeSchedule"
...  12.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-550 - Correct date in PS_CB008800_Backward_compatibility_with_LTE1103
...  xx.xx.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-xxx - xxx
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Variables ***
${SKIP_PARAMETER_RELATION_ERRORS}  True


*** Keywords ***
Check Syslog For Graceful Cell Shutdown Messages
    [Arguments]  ${technology}
    [Documentation]  checks if graceful massages were sent for 1 choosen technology

    ${sw_splited}  Split String  ${active_sw_version}  _
	${sw_prefix}  Get From List  ${sw_splited}  0
	Set Test Variable  ${sw_prefix}
	${cell_shutdown}  Set variable  None
	FOR  ${i}  IN RANGE  0  1
        #${cell_shutdown}  IF  "${technology}"=="lte"  Set variable  Sent msg: CellShutDownReq
		IF  "${technology}"=="lte" and '${sw_prefix}'=='SBTS25R1'
		    ${cell_shutdown}  Set variable  Sent msg: CellShutDownReq
        ELSE IF  "${technology}"=="lte" and '${sw_prefix}'!='SBTS25R1'
            ${cell_shutdown}  Set variable  Sent msg: RROM_CellShutDownReq
        END
        Exit For Loop If  "${cell_shutdown}"!="None"
        ${cell_shutdown}  IF  "${technology}"=="gsm"  Set variable  Ev_TrxImBlockReq
        Exit For Loop If  "${cell_shutdown}"!="None"
        ${cell_shutdown}  IF  "${technology}"=="nr"  Set variable  Received cprt::cm::ShutdownResp
        Exit For Loop If  "${cell_shutdown}"!="None"
        ${cell_shutdown}  IF  "${technology}"=="wcdma"  Set variable  Performing graceful cell shutdown
        Exit For Loop If  "${cell_shutdown}"!="None"
    END
    ute_syslog.wait for message in syslog file  regexp=${cell_shutdown}  timeout=15min  alias=ute_syslog
    Log  Message ${cell_shutdown} in syslog found  console=${true}


Check cell_m operational state
    [Arguments]  ${selected_cell}  ${expected_cell_state}
    [Documentation]  Fails when cell state != expected cell state. Example ${selected_cell} = MRBTS-101047/WNBTS-1/WNCEL-10703. Used in PS.44.

    ${cells_M}  admin.Get Managed Objects  CELL_M
    ${split_cell_dn}  Split String  ${selected_cell}  /
    ${technology}  ${cell_id}  Split String  ${split_cell_dn}[-1]  -
    FOR  ${i}  IN RANGE  0  1
        ${value}  IF  "${technology}"=="LNCEL"  Set variable  /MRBTS-1/RAT-1/MCTRL-1/BBTOP_M-1/MRBTS_M-1/LNBTS_M-1/CELL_M-${cell_id}
        IF  "${value}"!="None"  BREAK
        ${value}  IF  "${technology}"=="GNCEL"  Set variable  /MRBTS-1/RAT-1/MCTRL-1/BBTOP_M-1/MRBTS_M-1/GNBTS_M-1/CELL_M-${cell_id}001
        IF  "${value}"!="None"  BREAK
        ${value}  IF  "${technology}"=="NRCELL"  Set variable  /MRBTS-1/RAT-1/MCTRL-1/BBTOP_M-1/MRBTS_M-1/NRBTS_M-1/CELL_M-${cell_id}
        IF  "${value}"!="None"  BREAK
        ${value}  IF  "${technology}"=="WNCEL"  Set variable  /MRBTS-1/RAT-1/MCTRL-1/BBTOP_M-1/MRBTS_M-1/WNBTS_M-1/CELL_M-${cell_id[-1]}
        IF  "${value}"!="None"  BREAK
    END
    FOR  ${index}  ${item}  IN ENUMERATE  @{cells_M}
        ${correct_cell}  Run Keyword And Return Status  Dictionary Should Contain Value  ${item}  ${value}
        IF  ${correct_cell}  Should Be Equal  ${item['parameters']['stateInfo']['operationalState']}  ${expected_cell_state}
        IF  ${correct_cell}  BREAK
    END


Get NR MIMO/NotMIMO Cells And RMODS Lists
    [Documentation]  This kw sets test variables of lists of MIMO and NotMIMO cells and radios

    ${cells_list}  admin.Get Cell List
    ${nr_cells_length}  Get Length  ${cells_list['cells']['nr']}
    Set test Variable  ${nr_cells_length}
    ${MIMO_CELLS}  Create List
    ${NOT_MIMO_CELLS}  Create List
    ${MIMO_RMODS}  Create List
    ${NOT_MIMO_RMODS}  Create List
    ${zero}  Convert To Integer  0
    FOR  ${i}  IN RANGE  0  ${nr_cells_length}
        ${check_mimo}  Set Variable  ${cells_list['cells']['nr'][${i}]['carrierList'][${zero}]['antennaLineId']['configuration']}
        ${global_id}  Set Variable  ${cells_list['cells']['nr'][${i}]['globalCellId']}
        ${splited_info}  Split String  ${check_mimo}  /
        ${cell_dedicated_rmod}  Get From List  ${splited_info}  -2
        ${status}  Run keyword and return status  Should Contain  ${check_mimo}  PHYANT
        IF  ${status}
            Append to List  ${MIMO_CELLS}  ${global_id}
        ELSE
            Append to List  ${NOT_MIMO_CELLS}  ${global_id}
        END
        IF  ${status}
            Append to List  ${MIMO_RMODS}  ${cell_dedicated_rmod}
        ELSE
            Append to List  ${NOT_MIMO_RMODS}  ${cell_dedicated_rmod}
        END
    END
    ${MIMO_RMODS}  Evaluate  list(set(${MIMO_RMODS}))
    ${NOT_MIMO_RMODS}  Evaluate  list(set(${NOT_MIMO_RMODS}))
    Set Test Variable  ${MIMO_CELLS}
    Set Test Variable  ${NOT_MIMO_CELLS}
    Set Test Variable  ${MIMO_RMODS}
    Set Test Variable  ${NOT_MIMO_RMODS}


Get NR Cells For CB010683
    [Documentation]  this kw returns a list of 3 cells where 1st is MIMO cell and others are standard NR Cells

    Get NR MIMO/NotMIMO Cells And RMODS Lists
	${NRcell_list_not_mMIMO}=  Get NRCEL List Without 2TX And mMIMO
    ${selected_cells}  Create List
    IF  ${MIMO_CELLS}!=[]
        Append to List  ${selected_cells}  ${MIMO_cells[0]}
    ELSE
        Append to List  ${selected_cells}  ${NRcell_list_not_mMIMO[2]}
    END
    Append to List  ${selected_cells}  ${NRcell_list_not_mMIMO[0]}
    Append to List  ${selected_cells}  ${NRcell_list_not_mMIMO[1]}
    Set Test Variable  ${selected_cells}


Assign Chosen Cells to PSGRP
    ${selected_cells_DNs}  Create List
    IF  ${1st_LNCEL_ID} != 48181  append to list  ${selected_cells_DNs}  ${1st_LNCEL_DN}
    IF  ${2nd_LNCEL_ID} != 48181  append to list  ${selected_cells_DNs}  ${2nd_LNCEL_DN}
    IF  ${3rd_LNCEL_ID} != 48181  append to list  ${selected_cells_DNs}  ${3rd_LNCEL_DN}
    Set Test Variable  ${selected_cells_DNs}
    ${cell_for_call_ID}  Create List
    IF  ${1st_LNCEL_ID} != 48181  append to list  ${cell_for_call_ID}  ${1st_LNCEL_ID}
    IF  ${2nd_LNCEL_ID} != 48181  append to list  ${cell_for_call_ID}  ${2nd_LNCEL_ID}
    IF  ${3rd_LNCEL_ID} != 48181  append to list  ${cell_for_call_ID}  ${3rd_LNCEL_ID}
    Set Test Variable  ${cell_for_call_ID}
    ${cells_for_PSGRP_ID}  Create List
    IF  ${1st_LNCEL_ID} != 48181  append to list  ${cells_for_PSGRP_ID}  ${1st_LNCEL_ID}
    IF  ${2nd_LNCEL_ID} != 48181  append to list  ${cells_for_PSGRP_ID}  ${2nd_LNCEL_ID}
    IF  ${3rd_LNCEL_ID} != 48181  append to list  ${cells_for_PSGRP_ID}  ${3rd_LNCEL_ID}
    Set Test Variable  ${cells_for_PSGRP_ID}
    ${cell_list_to_PSGRP}  Combine Lists  ${cells_for_PSGRP_ID}  ${cell_for_call_ID}
    Set Test Variable  ${cell_list_to_PSGRP}
    ${1st_LNCELL_CB010397}  Set Variable  ${cell_list_to_PSGRP}[0]
    Set Test Variable  ${1st_LNCELL_CB010397}
    ${2nd_LNCELL_CB010397}  Set Variable  ${cell_list_to_PSGRP}[1]
    Set Test Variable  ${2nd_LNCELL_CB010397}
    ${3rd_LNCELL_CB010397}  Set Variable  ${cell_list_to_PSGRP}[2]
    Set Test Variable  ${3rd_LNCELL_CB010397}


Create And Activate PSGRP For CB010397
    [Documentation]
    ...  **Example of simple usage:**
    ...  Create And Activate PSGRP For CB010397
    [Arguments]  ${PSGRP-ID}  ${lbpsDuration}

    ${selected_cells_IDs}  Create List  ${1st_LNCELL_CB010397}  ${2nd_LNCELL_CB010397}  ${3rd_LNCELL_CB010397}
    ${delta_create_psgrp}  Set Variable  psgrp_create
    ${PSGRP_DN}  Set Variable  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}
    admin.create delta  ${delta_create_psgrp}
    admin.append managed object to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  create  ${delta_create_psgrp}
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  lbpsCSONCtlEnabled  false  ${delta_create_psgrp}
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  lbpsLastCellMinLoad  2  ${delta_create_psgrp}
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  lbpsLastCellRTXMinLoad  10  ${delta_create_psgrp}
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  lbpsLastCellSOEnabled  false  ${delta_create_psgrp}
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  lbpsMaxLoad  2  ${delta_create_psgrp}
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  lbpsMinLoad  1  ${delta_create_psgrp}
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  lbpsPdcchLoadOffset  0  ${delta_create_psgrp}
    admin.append parameter update to delta  ${PSGRP_DN}  lbpsRTXMaxLoad  80  ${delta_create_psgrp}
    admin.append parameter update to delta  ${PSGRP_DN}  lbpsRTXMinLoad  70  ${delta_create_psgrp}
    ${sw_splited}  Split String  ${active_sw_version}  _
    ${sw_prefix}  Get From List  ${sw_splited}  0
    Set Test Variable  ${sw_prefix}
    IF  '${if_actCo4g5g}'=='PASS' and '${sw_prefix}'!='SBTS23R2'
        admin.append parameter update to delta  ${PSGRP_DN}  lbpsGuardTimerNrAct  20  ${delta_create_psgrp}
        admin.append parameter update to delta  ${PSGRP_DN}  lbpsMaxLoadNrAct  40  ${delta_create_psgrp}
        admin.append parameter update to delta  ${PSGRP_DN}  lbpsMinNumEndcCapUeNrAct  0  ${delta_create_psgrp}
        admin.append parameter update to delta  ${PSGRP_DN}  lbpsMonWinNrAct  5  ${delta_create_psgrp}
        admin.append parameter update to delta  ${PSGRP_DN}  lbpsRetryTimerNrAct  5  ${delta_create_psgrp}
    END
    ${actMixedSOMethod_state}  Check parameter availability under LNBTS  actMixedSOMethod
    IF  '${actMixedSOMethod_state}'=='PASS'  admin.append parameter update to delta  ${PSGRP_DN}  lbpsSOMethod
    ...  Mixed Switch Off  ${delta_create_psgrp}
    ${lbpsCellList}  Create Dictionary
    ${item}  Create List  20  30  100
    FOR  ${i}  ${cell}  IN ZIP  ${item}  ${selected_cells_IDs}
        IF  '${if_actExtCellSOMethod}'=='PASS'  Set To Dictionary  ${lbpsCellList}  lbpsUseExtConfig  false
        Set To Dictionary  ${lbpsCellList}  lbpsCellSOOrder=${i}
        Set To Dictionary  ${lbpsCellList}  lnCelId=${cell}
        admin.append complex item to delta  ${PSGRP_DN}  list_name=lbpsCellList  &{lbpsCellList}  delta_id=${delta_create_psgrp}
    END
    Get Time And Date With Minute Offset  3minutes
    ${lbpsPeriodList}  Create Dictionary
    Set To Dictionary  ${lbpsPeriodList}  lbpsDayOfWeek=${day}
    ${lbpsDuration}  Get Regexp Matches  ${lbpsDuration}  \\d+
    Set To Dictionary  ${lbpsPeriodList}  lbpsDuration=${lbpsDuration[0]}
    Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeHour=${start_hour}
    Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeMinute=${start_minutes}
    Set To Dictionary  ${lbpsPeriodList}  lbpsSuspended=notSuspended
    admin.append complex item to delta  ${PSGRP_DN}  list_name=lbpsPeriodList  &{lbpsPeriodList}  delta_id=${delta_create_psgrp}
    admin.get delta  ${delta_create_psgrp}
    admin.save delta  ${RESULTS}/delta_create_psgrp_${PSGRP-ID}_LTE1203.json  ${delta_create_psgrp}
    Log  Activate Power Saving Group under MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  console=${true}
    admin.perform delta recommissioning  ${RESULTS}/delta_create_psgrp_${PSGRP-ID}_LTE1203.json  ${delta_create_psgrp}
    ${end_time}  Add Time To Date  ${time_with_offset}  ${lbpsDuration[0]} minutes
    ${end_hour}  Convert Date  ${end_time}  result_format=%H
    ${end_minutes}  Convert Date  ${end_time}  result_format=%M
    Log  Power Saving Group time frame: ${start_hour}:${start_minutes}-${end_hour}:${end_minutes} (+${lbpsDuration[0]} minutes)  console=${true}
    Log  Affected cells in ${PSGRP-ID}:  console=${true}
    Log  - Power Saving Saving: LNCEL_R-${1st_LNCELid} and LNCEL_R-${2nd_LNCELid}  console=${true}


Create And Activate PSGRPs For CB010869
    [Documentation]
    ...  Creates and activates two Power Saving Groups (PSGRPs) for feature CB010869 (load-based energy saving).
    ...  First PSGRP uses cells 1–3 with **TX switch off** and SlidingAverageMethod; second uses cells 4–6 with
    ...  **Cell Switch Off** and MinValueMethod. Each PSGRP gets its own LBPS period, cell list, and load
    ...  threshold windows. Start time is current time + 5 minutes. Expects pre-selected cell IDs
    ...  (e.g. \${1st_LNCELL_ID} … \${6th_LNCELL_ID}).
    ...
    ...  **Arguments:**
    ...  - \${FIRST_PSGRP_ID}   ID of the first PSGRP (e.g. PSGRP-1).
    ...  - \${SECOND_PSGRP_ID}  ID of the second PSGRP (e.g. PSGRP-2).
    ...  - \${lbpsDuration} LBPS duration in minutes for the first PSGRP (e.g. 65); second uses 70 min.
    ...
    ...  **Example:**
    ...  | Create And Activate PSGRPs For CB010869 | PSGRP-1 | PSGRP-2 | 65 |
    [Arguments]  ${FIRST_PSGRP_ID}  ${SECOND_PSGRP_ID}  ${lbpsDuration}

    ${cells_1}  Create List  ${1st_LNCEL_ID}  ${2nd_LNCEL_ID}  ${3rd_LNCEL_ID}
    ${cells_2}  Create List  ${4th_LNCEL_ID}  ${5th_LNCEL_ID}  ${6th_LNCEL_ID}
    ${order_1}  Create List  10  20  30
    ${order_2}  Create List  10  20  100
    ${lbpsDuration_parsed}  Get Regexp Matches  ${lbpsDuration}  \\d+

    ${cfg1}  Create Dictionary
    ...  psgrp_id=${FIRST_PSGRP_ID}  delta_id=psgrp_create_1  cells=${cells_1}  cell_order=${order_1}
    ...  so_method=TX Switch Off  son_tr_rule=SlidingAverageMethod
    ...  mon_win_soff_param=lbpsMonWinForRtxSOff  mon_win_son_param=lbpsMonWinForRtxSOn
    ...  last_cell_so=true  duration=${lbpsDuration_parsed[0]}
    ...  thres1_max=75  thres1_min=35  thres2_max=70  thres2_min=30

    ${cfg2}  Create Dictionary
    ...  psgrp_id=${SECOND_PSGRP_ID}  delta_id=psgrp_create_2  cells=${cells_2}  cell_order=${order_2}
    ...  so_method=Cell Switch Off  son_tr_rule=MinValueMethod
    ...  mon_win_soff_param=lbpsMonWinForCellSOff  mon_win_son_param=lbpsMonWinForCellSOn
    ...  last_cell_so=false  duration=70
    ...  thres1_max=15  thres1_min=5  thres2_max=35  thres2_min=15

    ${configs}  Create List  ${cfg1}  ${cfg2}
    Get Time And Date With Minute Offset  5minutes
    ${t2_normalized}  Normalize Hour And Minutes  ${start_hour}  ${start_minutes}  20
    ${t2_start_hour}  Set Variable  ${t2_normalized[0]}
    ${t2_start_minutes}  Set Variable  ${t2_normalized[1]}
    Set Test Variable  ${T2_TIME}  ${t2_start_hour}:${t2_start_minutes}
    ${t3_normalized}  Normalize Hour And Minutes  ${start_hour}  ${start_minutes}  30
    ${t3_start_hour}  Set Variable  ${t3_normalized[0]}
    ${t3_start_minutes}  Set Variable  ${t3_normalized[1]}
    Set Test Variable  ${T3_TIME}  ${t3_start_hour}:${t3_start_minutes}

    FOR  ${cfg}  IN  @{configs}
        ${PSGRP_DN}  Set Variable  ${LNBTS_DISTNAME}/${cfg}[psgrp_id]
        admin.Create Delta  ${cfg}[delta_id]
        admin.Append Managed Object To Delta  ${PSGRP_DN}  create  ${cfg}[delta_id]
        admin.Append Parameter Update To Delta  ${PSGRP_DN}  lbpsSOffTrRule  MaxValueMethod  ${cfg}[delta_id]
        admin.Append Parameter Update To Delta  ${PSGRP_DN}  lbpsLoadCalcMethod  Max(G, W, P)  ${cfg}[delta_id]
        admin.Append Parameter Update To Delta  ${PSGRP_DN}  lbpsRTXMaxLoad  75  ${cfg}[delta_id]
        admin.Append Parameter Update To Delta  ${PSGRP_DN}  lbpsRTXMinLoad  35  ${cfg}[delta_id]
        admin.Append Parameter Update To Delta  ${PSGRP_DN}  lbpsRTXCellCapOffset  50  ${cfg}[delta_id]
        admin.Append Parameter Update To Delta  ${PSGRP_DN}  lbpsCSONCtlEnabled  false  ${cfg}[delta_id]
        admin.Append Parameter Update To Delta  ${PSGRP_DN}  lbpsSOMethod  ${cfg}[so_method]  ${cfg}[delta_id]
        admin.Append Parameter Update To Delta  ${PSGRP_DN}  lbpsSOnTrRule  ${cfg}[son_tr_rule]  ${cfg}[delta_id]
        admin.Append Parameter Update To Delta  ${PSGRP_DN}  ${cfg}[mon_win_soff_param]  60  ${cfg}[delta_id]
        admin.Append Parameter Update To Delta  ${PSGRP_DN}  ${cfg}[mon_win_son_param]  120  ${cfg}[delta_id]
        admin.Append Parameter Update To Delta  ${PSGRP_DN}  lbpsLastCellSOEnabled  ${cfg}[last_cell_so]  ${cfg}[delta_id]
        ${lbpsCellList}  Create Dictionary
        FOR  ${order}  ${cell}  IN ZIP  ${cfg}[cell_order]  ${cfg}[cells]
            Set To Dictionary  ${lbpsCellList}  lbpsUseExtConfig  false
            Set To Dictionary  ${lbpsCellList}  lbpsCellSOOrder=${order}
            Set To Dictionary  ${lbpsCellList}  lnCelId=${cell}
            admin.Append Complex Item To Delta  ${PSGRP_DN}  list_name=lbpsCellList  &{lbpsCellList}  delta_id=${cfg}[delta_id]
        END
        ${lbpsPeriodList}  Create Dictionary
        ...  lbpsDayOfWeek=${day}  lbpsDuration=${cfg}[duration]
        ...  lbpsStartTimeHour=${start_hour}  lbpsStartTimeMinute=${start_minutes}
        admin.Append Complex Item To Delta  ${PSGRP_DN}  list_name=lbpsPeriodList  &{lbpsPeriodList}  delta_id=${cfg}[delta_id]
        ${lbpsCsoLoadThresList1}  Create Dictionary
        ...  lbpsCsoThresDayOfWeek=${day}  lbpsCsoThresDuration=10
        ...  lbpsCsoThresStartTimeHour=${t2_start_hour}  lbpsCsoThresStartTimeMinute=${t2_start_minutes}
        ...  lbpsMaxLoad=${cfg}[thres1_max]  lbpsMinLoad=${cfg}[thres1_min]
        admin.Append Complex Item To Delta  ${PSGRP_DN}  list_name=lbpsCsoLoadThresList  &{lbpsCsoLoadThresList1}  delta_id=${cfg}[delta_id]
        ${lbpsCsoLoadThresList2}  Create Dictionary
        ...  lbpsCsoThresDayOfWeek=${day}  lbpsCsoThresDuration=35
        ...  lbpsCsoThresStartTimeHour=${t3_start_hour}  lbpsCsoThresStartTimeMinute=${t3_start_minutes}
        ...  lbpsMaxLoad=${cfg}[thres2_max]  lbpsMinLoad=${cfg}[thres2_min]
        admin.Append Complex Item To Delta  ${PSGRP_DN}  list_name=lbpsCsoLoadThresList  &{lbpsCsoLoadThresList2}  delta_id=${cfg}[delta_id]
        admin.Get Delta  ${cfg}[delta_id]
        admin.Save Delta  ${RESULTS}/delta_create_psgrp_${cfg}[psgrp_id].json  ${cfg}[delta_id]
        Log  Activate Power Saving Group under MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${cfg}[psgrp_id]  console=${true}
        admin.Perform Delta Recommissioning  ${RESULTS}/delta_create_psgrp_${cfg}[psgrp_id].json  ${cfg}[delta_id]
        Log  Power Saving Group ${cfg}[psgrp_id] time frame: ${start_hour}:${start_minutes} (+${cfg}[duration] minutes)  console=${true}
    END


Change Parameters Under PSGRP for CB010869
    [Documentation]
    ...  Updates LBPS parameters under two existing PSGRPs for feature CB010869 via a single delta.
    ...  Both PSGRPs get: lbpsSOMethod=Mixed Switch Off, lbpsSOffTrRule/lbpsSOnTrRule=SlidingAverageMethod,
    ...  lbpsLoadCalcMethod=Max(G_N_combined, P). The second PSGRP additionally gets lbpsLastCellSOEnabled=true.
    ...  Expects \${LNBTS_DISTNAME} to be set (e.g. MRBTS-1/LNBTS-1). Saves and applies one recommissioning.
    ...
    ...  **Arguments:**
    ...  - \${first_id}   Numeric ID of the first PSGRP (e.g. 1 for PSGRP-1).
    ...  - \${second_id}  Numeric ID of the second PSGRP (e.g. 2 for PSGRP-2).
    ...
    ...  **Example:**
    ...  | Change Parameters Under PSGRP for CB010869 | 1 | 2 |
    [Arguments]  ${first_id}  ${second_id}

    ${parameter_delta}  Set Variable  delta_change_parameters
    ${common_params}  Create Dictionary  lbpsSOMethod=Mixed Switch Off  lbpsSOffTrRule=SlidingAverageMethod  lbpsSOnTrRule=SlidingAverageMethod
    ...  lbpsLoadCalcMethod=Max(G_N_combined, P)
    admin.Create Delta  ${parameter_delta}
    FOR  ${param}  ${value}  IN  &{common_params}
        admin.Append Parameter Update To Delta  ${LNBTS_DISTNAME}/PSGRP-${first_id}  ${param}  ${value}  ${parameter_delta}
    END
    admin.Append Parameter Update To Delta  ${LNBTS_DISTNAME}/PSGRP-${second_id}  lbpsLastCellSOEnabled  true  ${parameter_delta}
    FOR  ${param}  ${value}  IN  &{common_params}
        admin.Append Parameter Update To Delta  ${LNBTS_DISTNAME}/PSGRP-${second_id}  ${param}  ${value}  ${parameter_delta}
    END
    admin.Get Delta  ${parameter_delta}
    admin.Save Delta  ${RESULTS}/psgrp_parameters_changed.json  ${parameter_delta}
    admin.Perform Delta Recommissioning  ${RESULTS}/psgrp_parameters_changed.json  ${parameter_delta}


Create And Activate One PSGRP For CB010869
    [Documentation]
    ...  Kw creates PSGRP with 2 LTE ${cell_ids} provided for CB010869 feature - LTE cell TX switch off/on depending on
    ...  RTX load duration set on PSGRP object.
    [Arguments]  ${psgrp_id}  ${lnbts_distname}  ${cell_ids}  ${period_duration}  ${rtx_load_thres_duration}  ${psgrp_period_starting_time}
    ...  ${rtx_load_starting_time}

    Log  Create and activate PSGRP-${psgrp_id} for LTE cell ids: ${cell_ids}\n  console=true
    ${psgrp_dn}  Set Variable  ${lnbts_distname}/PSGRP-${psgrp_id}
    ${delta_id}  Set Variable  psgrp_CB010869
    admin.Create Delta  ${delta_id}
    admin.Append Managed Object To Delta  ${psgrp_dn}  create  ${delta_id}
    ${psgrp_params}  Create Dictionary  lbpsCSONCtlEnabled=false  lbpsLastCellSOEnabled=false  lbpsSOffTrRule=MaxValueMethod
    ...  lbpsSOnTrRule=MinValueMethod  lbpsSOMethod=TX Switch Off  lbpsLoadCalcMethod=Max(G, W, P)  lbpsMonWinForRtxSOff=60
    ...  lbpsMonWinForRtxSOn=120  lbpsRTXMaxLoad=80  lbpsRTXMinLoad=70  lbpsRTXCellCapOffset=50
    FOR  ${param}  IN  @{psgrp_params}
        admin.Append Parameter Update To Delta  ${psgrp_dn}  ${param}  ${psgrp_params}[${param}]  ${delta_id}
    END

    ${cell_list_1}  Create Dictionary  lbpsCellSOOrder=10  lbpsUseExtConfig=false  lnCelId=${cell_ids}[0]
    admin.Append Complex Item To Delta  ${psgrp_dn}  list_name=lbpsCellList  &{cell_list_1}  delta_id=${delta_id}
    ${cell_list_2}  Create Dictionary  lbpsCellSOOrder=100  lbpsUseExtConfig=false  lnCelId=${cell_ids}[1]
    admin.Append Complex Item To Delta  ${psgrp_dn}  list_name=lbpsCellList  &{cell_list_2}  delta_id=${delta_id}

    ${psgrp_period_day}  Convert Date  ${psgrp_period_starting_time}  result_format=%a
    ${psgrp_period_hour}  Convert Date  ${psgrp_period_starting_time}  result_format=%H
    ${psgrp_period_minute}  Convert Date  ${psgrp_period_starting_time}  result_format=%M
    ${lbpsPeriodList}  Create Dictionary  lbpsDayOfWeek=${psgrp_period_day}  lbpsDuration=${period_duration}
    ...  lbpsStartTimeHour=${psgrp_period_hour}  lbpsStartTimeMinute=${psgrp_period_minute}
     admin.Append Complex Item To Delta  ${psgrp_dn}  list_name=lbpsPeriodList  &{lbpsPeriodList}  delta_id=${delta_id}

    ${rtx_load_day}  Convert Date  ${rtx_load_starting_time}  result_format=%a
    ${rtx_load_hour}  Convert Date  ${rtx_load_starting_time}  result_format=%H
    ${rtx_load_minute}  Convert Date  ${rtx_load_starting_time}  result_format=%M
    ${lbpsRTXLoadThresList}  Create Dictionary  lbpsRTXThresDayOfWeek=${rtx_load_day}  lbpsRTXThresDuration=${rtx_load_thres_duration}
    ...  lbpsRTXThresStartTimeHour=${rtx_load_hour}  lbpsRTXThresStartTimeMinute=${rtx_load_minute}  lbpsRTXMaxLoad=15  lbpsRTXMinLoad=10
    admin.Append Complex Item To Delta  ${psgrp_dn}  list_name=lbpsRTXLoadThresList  &{lbpsRTXLoadThresList}  delta_id=${delta_id}
    admin.Get Delta  ${delta_id}
    admin.Save Delta  ${RESULTS}/delta_create_${psgrp_id}.json  ${delta_id}
    admin.Perform Delta Recommissioning  ${RESULTS}/delta_create_${psgrp_id}.json  ${delta_id}
    Log  Power Saving Group PSGRP-${psgrp_id} time frame: ${psgrp_period_hour}:${psgrp_period_minute} (+${period_duration} minutes)\n  console=true


Create And Activate NRPGRP With 2 Cells For CB010869
    [Documentation]
    ...  Kw creates NRPGRP with 2 NR cell ids ${cell_ids} provided for CB010869 feature - NR cell TX switch off/on depending on
    ...  RTX load duration set on NRPGRP object.
    [Arguments]  ${nrpgrp_id}  ${nrbts_distname}  ${cell_ids}  ${period_duration}  ${rtx_load_thres_duration}  ${nrpgrp_period_starting_time}
    ...  ${rtx_load_starting_time}

    Log  Create and activate NRPGRP-${nrpgrp_id} for NR cell ids: ${cell_ids}\n  console=true
    ${nrpgrp_dn}  Set Variable  ${nrbts_distname}/NRPGRP-${nrpgrp_id}
    ${delta_id}  Set Variable  nrpgrp_CB010869
    admin.Create Delta  ${delta_id}
    admin.Append Managed Object To Delta  ${nrpgrp_dn}  create  ${delta_id}
    ${nrpgrp_params}  Create Dictionary  lbpsCSONCtlEnabled=false  lbpsLastCellSOEnabled=true  lbpsSOffTrRule=SlidingAverageMethod
    ...  lbpsSOnTrRule=MinValueMethod  lbpsSOMethod=TX switch off  lbpsLoadCalcMethod=Max(G_N_combined, P)  lbpsRTXSOffTime=60
    ...  lbpsRTXSOnTime=120  lbpsRTXMaxLoad=80  lbpsRTXMinLoad=70  lbpsRTXCellCapOffset=25
    FOR  ${param}  IN  @{nrpgrp_params}
        admin.Append Parameter Update To Delta  ${nrpgrp_dn}  ${param}  ${nrpgrp_params}[${param}]  ${delta_id}
    END

    ${cell_list_1}  Create Dictionary  lbpsCellSOOrder=10  lbpsUseExtConfig=false  nrCellId=${cell_ids}[0]
    admin.Append Complex Item To Delta  ${nrpgrp_dn}  list_name=lbpsCellList  &{cell_list_1}  delta_id=${delta_id}
    ${cell_list_2}  Create Dictionary  lbpsCellSOOrder=100  lbpsUseExtConfig=false  nrCellId=${cell_ids}[1]
    admin.Append Complex Item To Delta  ${nrpgrp_dn}  list_name=lbpsCellList  &{cell_list_2}  delta_id=${delta_id}

    ${nrpgrp_period_day}  Convert Date  ${nrpgrp_period_starting_time}  result_format=%a
    ${nrpgrp_period_hour}  Convert Date  ${nrpgrp_period_starting_time}  result_format=%H
    ${nrpgrp_period_minute}  Convert Date  ${nrpgrp_period_starting_time}  result_format=%M
    ${lbpsPeriodList}  Create Dictionary  lbpsDayOfWeek=${nrpgrp_period_day}  lbpsDuration=${period_duration}
    ...  lbpsStartTimeHour=${nrpgrp_period_hour}  lbpsStartTimeMinute=${nrpgrp_period_minute}
     admin.Append Complex Item To Delta  ${nrpgrp_dn}  list_name=lbpsPeriodList  &{lbpsPeriodList}  delta_id=${delta_id}

    ${rtx_load_day}  Convert Date  ${rtx_load_starting_time}  result_format=%a
    ${rtx_load_hour}  Convert Date  ${rtx_load_starting_time}  result_format=%H
    ${rtx_load_minute}  Convert Date  ${rtx_load_starting_time}  result_format=%M
    ${lbpsRTXLoadThresList}  Create Dictionary  lbpsRTXThresDayOfWeek=${rtx_load_day}  lbpsRTXThresDuration=${rtx_load_thres_duration}
    ...  lbpsRTXThresStartTimeHour=${rtx_load_hour}  lbpsRTXThresStartTimeMinute=${rtx_load_minute}  lbpsRTXMaxLoad=15  lbpsRTXMinLoad=10
    admin.Append Complex Item To Delta  ${nrpgrp_dn}  list_name=lbpsRTXLoadThresList  &{lbpsRTXLoadThresList}  delta_id=${delta_id}
    admin.Get Delta  ${delta_id}
    admin.Save Delta  ${RESULTS}/delta_create_${nrpgrp_id}.json  ${delta_id}
    admin.Perform Delta Recommissioning  ${RESULTS}/delta_create_${nrpgrp_id}.json  ${delta_id}
    Log  Power Saving Group NRPGRP-${nrpgrp_id} time frame: ${nrpgrp_period_hour}:${nrpgrp_period_minute} (+${period_duration} minutes)\n
    ...  console=true


Create And Activate NRPGRP With 3 Cells For CB010869
    [Documentation]
    ...  Kw creates NRPGRP with 3 NR cell ids ${cell_ids} provided for CB010869 feature - NR cell switch off/on depending on
    ...  CSO load duration set on NRPGRP object.
    [Arguments]  ${nrpgrp_id}  ${nrbts_distname}  ${cell_ids}  ${period_duration}  ${cso_load_thres_duration}  ${nrpgrp_period_starting_time}
    ...  ${cso_load_starting_time}

    Log  Create and activate NRPGRP-${nrpgrp_id} for NR cell ids: ${cell_ids}\n  console=true
    ${nrpgrp_dn}  Set Variable  ${nrbts_distname}/NRPGRP-${nrpgrp_id}
    ${delta_id}  Set Variable  nrpgrp_CB010869
    admin.Create Delta  ${delta_id}
    admin.Append Managed Object To Delta  ${nrpgrp_dn}  create  ${delta_id}
    ${nrpgrp_params}  Create Dictionary  lbpsCSONCtlEnabled=false  lbpsLastCellSOEnabled=false  lbpsSOffTrRule=SlidingAverageMethod
    ...  lbpsSOnTrRule=MinValueMethod  lbpsSOMethod=cell switch off  lbpsLoadCalcMethod=Max(G_N_combined, P)
    ...  lbpsMonWinForCellSOff=60  lbpsMonWinForCellSOn=120  lbpsMaxLoad=80  lbpsMinLoad=70
    FOR  ${param}  IN  @{nrpgrp_params}
        admin.Append Parameter Update To Delta  ${nrpgrp_dn}  ${param}  ${nrpgrp_params}[${param}]  ${delta_id}
    END

    ${cell_list_1}  Create Dictionary  lbpsCellSOOrder=10  lbpsUseExtConfig=false  nrCellId=${cell_ids}[0]
    admin.Append Complex Item To Delta  ${nrpgrp_dn}  list_name=lbpsCellList  &{cell_list_1}  delta_id=${delta_id}
    ${cell_list_2}  Create Dictionary  lbpsCellSOOrder=20  lbpsUseExtConfig=false  nrCellId=${cell_ids}[1]
    admin.Append Complex Item To Delta  ${nrpgrp_dn}  list_name=lbpsCellList  &{cell_list_2}  delta_id=${delta_id}
    ${cell_list_3}  Create Dictionary  lbpsCellSOOrder=100  lbpsUseExtConfig=false  nrCellId=${cell_ids}[2]
    admin.Append Complex Item To Delta  ${nrpgrp_dn}  list_name=lbpsCellList  &{cell_list_3}  delta_id=${delta_id}

    ${nrpgrp_period_day}  Convert Date  ${nrpgrp_period_starting_time}  result_format=%a
    ${nrpgrp_period_hour}  Convert Date  ${nrpgrp_period_starting_time}  result_format=%H
    ${nrpgrp_period_minute}  Convert Date  ${nrpgrp_period_starting_time}  result_format=%M
    ${lbpsPeriodList}  Create Dictionary  lbpsDayOfWeek=${nrpgrp_period_day}  lbpsDuration=${period_duration}
    ...  lbpsStartTimeHour=${nrpgrp_period_hour}  lbpsStartTimeMinute=${nrpgrp_period_minute}
     admin.Append Complex Item To Delta  ${nrpgrp_dn}  list_name=lbpsPeriodList  &{lbpsPeriodList}  delta_id=${delta_id}

    ${cso_load_day}  Convert Date  ${cso_load_starting_time}  result_format=%a
    ${cso_load_hour}  Convert Date  ${cso_load_starting_time}  result_format=%H
    ${cso_load_minute}  Convert Date  ${cso_load_starting_time}  result_format=%M
    ${lbpsCsoLoadThresList}  Create Dictionary  lbpsCsoThresDayOfWeek=${cso_load_day}  lbpsCsoThresDuration=${cso_load_thres_duration}
    ...  lbpsCsoThresStartTimeHour=${cso_load_hour}  lbpsCsoThresStartTimeMinute=${cso_load_minute}  lbpsMaxLoad=15  lbpsMinLoad=10
    admin.Append Complex Item To Delta  ${nrpgrp_dn}  list_name=lbpsCsoLoadThresList  &{lbpsCsoLoadThresList}  delta_id=${delta_id}
    admin.Get Delta  ${delta_id}
    admin.Save Delta  ${RESULTS}/delta_create_${nrpgrp_id}.json  ${delta_id}
    admin.Perform Delta Recommissioning  ${RESULTS}/delta_create_${nrpgrp_id}.json  ${delta_id}
    Log  Power Saving Group NRPGRP-${nrpgrp_id} time frame: ${nrpgrp_period_hour}:${nrpgrp_period_minute} (+${period_duration} minutes)\n
    ...  console=true


Create And Activate NRPGRP With 3 Cells For 5GC000431
    [Documentation]
    ...  Kw creates NRPGRP with 3 NR cell ids ${cell_ids} provided for 5GC000431 feature
    [Arguments]  ${nrpgrp_id}  ${nrbts_distname}  ${cell_ids}  ${period_duration}

    Log  Create and activate NRPGRP-${nrpgrp_id} for NR cell ids: ${cell_ids}\n  console=true
    ${nrpgrp_dn}  Set Variable  ${nrbts_distname}/NRPGRP-${nrpgrp_id}
    ${delta_id}  Set Variable  nrpgrp_5GC000431
    admin.Create Delta  ${delta_id}
    admin.Append Managed Object To Delta  ${nrpgrp_dn}  create  ${delta_id}
    ${nrpgrp_params}  Create Dictionary  lbpsLastCellSOEnabled=true  lbpsLastCellMinLoad=20  lbpsLoadCalcMethod=Max(G_N_combined, P)
    ...  lbpsMaxLoad=60  lbpsMinLoad=20  lbpsMonWinForCellSOff=120  lbpsMonWinForCellSOn=120
    ...  lbpsPdcchLoadOffset=4  lbpsSOffTrRule=SlidingAverageMethod  lbpsSOnTrRule=SlidingAverageMethod  lbpsSOMethod=cell switch off
    FOR  ${param}  IN  @{nrpgrp_params}
        admin.Append Parameter Update To Delta  ${nrpgrp_dn}  ${param}  ${nrpgrp_params}[${param}]  ${delta_id}
    END
    ${nrcell_params}  Create Dictionary  actDlDynSwitchAlloc=true  actRat1Alloc=true
    FOR  ${cell}  IN  @{cell_ids}
        FOR  ${key}  ${value}  IN  &{nrcell_params}
            admin.Append Parameter Update To Delta  ${nrbts_distname}/NRCELL-${cell}  ${key}  ${value}  ${delta_id}
        END
    END
    ${cell_list_1}  Create Dictionary  lbpsCellSOOrder=100  lbpsUseExtConfig=false  nrCellId=${cell_ids}[0]
    admin.Append Complex Item To Delta  ${nrpgrp_dn}  list_name=lbpsCellList  &{cell_list_1}  delta_id=${delta_id}
    ${cell_list_2}  Create Dictionary  lbpsCellSOOrder=100  lbpsUseExtConfig=false  nrCellId=${cell_ids}[1]
    admin.Append Complex Item To Delta  ${nrpgrp_dn}  list_name=lbpsCellList  &{cell_list_2}  delta_id=${delta_id}
    ${cell_list_3}  Create Dictionary  lbpsCellSOOrder=100  lbpsUseExtConfig=false  nrCellId=${cell_ids}[2]
    admin.Append Complex Item To Delta  ${nrpgrp_dn}  list_name=lbpsCellList  &{cell_list_3}  delta_id=${delta_id}

    ${current_date}  Get Current Date  result_format=datetime
    ${nrpgrp_period_starting_time}  Add Time To Date  ${current_date}  5 minutes
    ${nrpgrp_period_day}  Convert Date  ${nrpgrp_period_starting_time}  result_format=%a
    ${nrpgrp_period_hour}  Convert Date  ${nrpgrp_period_starting_time}  result_format=%H
    ${nrpgrp_period_minute}  Convert Date  ${nrpgrp_period_starting_time}  result_format=%M
    ${lbpsPeriodList}  Create Dictionary  lbpsDayOfWeek=${nrpgrp_period_day}  lbpsDuration=${period_duration}
    ...  lbpsStartTimeHour=${nrpgrp_period_hour}  lbpsStartTimeMinute=${nrpgrp_period_minute}
    admin.Append Complex Item To Delta  ${nrpgrp_dn}  list_name=lbpsPeriodList  &{lbpsPeriodList}  delta_id=${delta_id}

    admin.Get Delta  ${delta_id}
    admin.Save Delta  ${RESULTS}/delta_create_${nrpgrp_id}.json  ${delta_id}
    admin.Perform Delta Recommissioning  ${RESULTS}/delta_create_${nrpgrp_id}.json  ${delta_id}
    Log  Power Saving Group NRPGRP-${nrpgrp_id} time frame: ${nrpgrp_period_hour}:${nrpgrp_period_minute} (+${period_duration} minutes)\n
    ...  console=true


Create And Activate PSGRPs And NRPGRPs For LTE1203 And CB008392
    [Documentation]
    ...  Kw creates PSGRPs and NRPGRPs with 1 cell for following LTE and NR cell ids provided for LTE1203 and CB008392
    ...  features - Tx switch off switch on.
    [Arguments]  ${lnbts_distname}  ${nrbts_distname}  ${lte_cell_ids_list}  ${nr_cell_ids_list}  ${lte_period_duration}  ${nr_period_duration}
    ...  ${period_starting_time}

    ${delta_id}  Set Variable  psg_LTE1203_CB008392
    admin.Create Delta  ${delta_id}
    ${period_day}  Convert Date  ${period_starting_time}  result_format=%a
    ${period_hour}  Convert Date  ${period_starting_time}  result_format=%H
    ${period_minute}  Convert Date  ${period_starting_time}  result_format=%M

    ${lte_cells_length}  Get Length  ${lte_cell_ids_list}
    Log  \nCreate and activate PSGRP-[0-${lte_cells_length}] for LTE cells: ${lte_cell_ids_list}\n  console=true
    FOR  ${index}  IN RANGE  0  ${lte_cells_length}
        ${ln_cell_id}  Set Variable  ${lte_cell_ids_list}[${index}]
        ${psgrp_dn}  Set Variable  ${lnbts_distname}/PSGRP-${index}
        admin.Append Managed Object To Delta  ${psgrp_dn}  create  ${delta_id}

        ${psgrp_params}  Create Dictionary  lbpsLastCellRTXMinLoad=40  lbpsLastCellSOEnabled=true  lbpsPdcchLoadOffset=4
        ...  lbpsRTXCellCapOffset=80  lbpsRTXMaxLoad=60  lbpsRTXMinLoad=30  lbpsSOMethod=Legacy Mixed Switch Off
        FOR  ${param}  IN  @{psgrp_params}
            admin.Append Parameter Update To Delta  ${psgrp_dn}  ${param}  ${psgrp_params}[${param}]  ${delta_id}
        END
        ${lbpsCellList}  Create Dictionary  lbpsCellSOOrder=10  lbpsUseExtConfig=false  lnCelId=${ln_cell_id}
        admin.Append Complex Item To Delta  ${psgrp_dn}  list_name=lbpsCellList  &{lbpsCellList}  delta_id=${delta_id}

        ${lbpsPeriodList}  Create Dictionary  lbpsDayOfWeek=${period_day}  lbpsDuration=${lte_period_duration}
        ...  lbpsStartTimeHour=${period_hour}  lbpsStartTimeMinute=${period_minute}  lbpsSuspended=notSuspended
        admin.Append Complex Item To Delta  ${psgrp_dn}  list_name=lbpsPeriodList  &{lbpsPeriodList}  delta_id=${delta_id}
    END

    ${nr_cells_length}  Get Length  ${nr_cell_ids_list}
    Log  Create and activate NRPGRP-[0-${nr_cells_length}] for NR cells: ${nr_cell_ids_list}\n  console=true
    FOR  ${index}  IN RANGE  0  ${nr_cells_length}
        ${nr_cell_id}  Set Variable  ${nr_cell_ids_list}[${index}]
        ${nrpgrp_dn}  Set Variable  ${nrbts_distname}/NRPGRP-${index}
        admin.Append Managed Object To Delta  ${nrpgrp_dn}  create  ${delta_id}

        ${nrpgrp_params}  Create Dictionary  lbpsLastCellRTXMinLoad=40  lbpsLastCellSOEnabled=true  lbpsPdcchLoadOffset=4
        ...  lbpsRTXCellCapOffset=80  lbpsRTXMaxLoad=60  lbpsRTXMinLoad=30  lbpsRTXSOffTime=300
        ...  lbpsRTXSOnTime=120  lbpsSOMethod=TX switch off
        FOR  ${param}  IN  @{nrpgrp_params}
            admin.Append Parameter Update To Delta  ${nrpgrp_dn}  ${param}  ${nrpgrp_params}[${param}]  ${delta_id}
        END
        ${lbpsCellList}  Create Dictionary  lbpsCellSOOrder=10  lbpsUseExtConfig=false  nrCellId=${nr_cell_id}
        admin.Append Complex Item To Delta  ${nrpgrp_dn}  list_name=lbpsCellList  &{lbpsCellList}  delta_id=${delta_id}

        ${lbpsPeriodList}  Create Dictionary  lbpsDayOfWeek=${period_day}  lbpsDuration=${nr_period_duration}
        ...  lbpsStartTimeHour=${period_hour}  lbpsStartTimeMinute=${period_minute}  lbpsSuspended=notSuspended
        admin.Append Complex Item To Delta  ${nrpgrp_dn}  list_name=lbpsPeriodList  &{lbpsPeriodList}  delta_id=${delta_id}
    END

    admin.Get Delta  ${delta_id}
    admin.Save Delta  ${RESULTS}/delta_create_${delta_id}.json  ${delta_id}
    admin.Perform Delta Recommissioning  ${RESULTS}/delta_create_${delta_id}.json  ${delta_id}
    Remove Delta  ${delta_id}

    Log  PSGRPs time frame: ${period_hour}:${period_minute} (+${lte_period_duration} minutes)\n  console=true
    Log  NRPGRPs time frame: ${period_hour}:${period_minute} (+${nr_period_duration} minutes)\n  console=true


Create And Activate NRPGRP For CB010683
    [Documentation]
    ...  Creates and activates NRGRP.
    ...  Demands ${cell_order}  ${selected_cells}
    [Arguments]  ${lbpsDuration}=25  ${NRPGRP-ID}=13  ${test_id}=43

    ${delta_create_nrpgrp}  Set Variable  nrpgrp_create
    ${NRPGRP_DN}  Set Variable  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-${NRPGRP-ID}
    admin.create delta  ${delta_create_nrpgrp}
    admin.append managed object to delta  ${NRPGRP_DN}  create  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsCSONCtlEnabled  false  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsLastCellMinLoad  20  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsLastCellRTXMinLoad  10  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsRTXMaxLoad  50  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsRTXMinLoad  40  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsRTXSOffTime  300  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsRTXSOnTime  120  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsRTXCellCapOffset  80  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsLastCellSOEnabled  true  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsMaxLoad  60  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsMinLoad  30  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsPdcchLoadOffset  4  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsSOMethod  mixed switch off  ${delta_create_nrpgrp}
    ${lbpsCellList}  Create Dictionary
    FOR  ${i}  ${cell}  IN ZIP  ${cell_order}  ${selected_cells}
      Set To Dictionary  ${lbpsCellList}  lbpsCellSOOrder=${i}
      Set To Dictionary  ${lbpsCellList}  nrCellId=${cell}
      IF  '${i}'=='100'
          ${lbpsUseExtConfig_state}  Set Variable  false
      ELSE
          ${lbpsUseExtConfig_state}  Set Variable  true
      END
      IF  '${if_actNrExtCellSOMethod}'=='PASS'  Set To Dictionary  ${lbpsCellList}  lbpsUseExtConfig  ${lbpsUseExtConfig_state}
      admin.append complex item to delta  ${NRPGRP_DN}  list_name=lbpsCellList  &{lbpsCellList}  delta_id=${delta_create_nrpgrp}
    END
    Log to console  Selected Cells: ${selected_cells}
    Get Time And Date With Minute Offset  9minutes  5minutes
    ${lbpsPeriodList}  Create Dictionary
    Set To Dictionary  ${lbpsPeriodList}  lbpsDayOfWeek=${day}
    ${lbpsDuration}  Get Regexp Matches  ${lbpsDuration}  \\d+
    Set To Dictionary  ${lbpsPeriodList}  lbpsDuration=${lbpsDuration[0]}
    Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeHour=${start_hour}
    Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeMinute=${start_minutes}
    Set To Dictionary  ${lbpsPeriodList}  lbpsSuspended=notSuspended
    admin.append complex item to delta  ${NRPGRP_DN}  list_name=lbpsPeriodList  &{lbpsPeriodList}  delta_id=${delta_create_nrpgrp}
    Log  Power Saving For NRPGRP start: ${start_hour}:${start_minutes}, duration: ${lbpsDuration[0]} minutes  console=${true}
    ${lbpsCellPeriodList}  Create Dictionary
    Set To Dictionary  ${lbpsCellPeriodList}  lbpsCellDayOfWeek=${day}
    Set To Dictionary  ${lbpsCellPeriodList}  nrCellId=${selected_cells[0]}
    Set To Dictionary  ${lbpsCellPeriodList}  lbpsCellSOMethod  mixed switch off
    IF  ${test_id}==43  Set To Dictionary  ${lbpsCellPeriodList}  lbpsCellDuration=${lbpsDuration[0]}
    IF  ${test_id}==39  Set To Dictionary  ${lbpsCellPeriodList}  lbpsCellDuration=25
    IF  ${test_id}==41  Set To Dictionary  ${lbpsCellPeriodList}  lbpsCellDuration=40
    Set To Dictionary  ${lbpsCellPeriodList}  lbpsCellStartTimeHour=${start_hour}
    Set To Dictionary  ${lbpsCellPeriodList}  lbpsCellStartTimeMinute=${start_minutes}
    admin.append complex item to delta  ${NRPGRP_DN}  list_name=lbpsCellPeriodList  &{lbpsCellPeriodList}  delta_id=${delta_create_nrpgrp}
#PS.39 only part
    ${lbpsCellPeriodList}  Create Dictionary
    Set To Dictionary  ${lbpsCellPeriodList}  lbpsCellDayOfWeek=${day}
    IF  ${test_id}==39  Set To Dictionary  ${lbpsCellPeriodList}  nrCellId=${selected_cells[1]}
    Set To Dictionary  ${lbpsCellPeriodList}  lbpsCellSOMethod  mixed switch off
    IF  ${test_id}==39  Set To Dictionary  ${lbpsCellPeriodList}  lbpsCellDuration=25
    Set To Dictionary  ${lbpsCellPeriodList}  lbpsCellStartTimeHour=${start_hour}
    Set To Dictionary  ${lbpsCellPeriodList}  lbpsCellStartTimeMinute=${start_minutes}
    IF  ${test_id}==39  admin.append complex item to delta  ${NRPGRP_DN}  list_name=lbpsCellPeriodList
    ...  &{lbpsCellPeriodList}  delta_id=${delta_create_nrpgrp}
#PS.39 only part end
    IF  ${test_id}==39  Get Time And Date With Minute Offset  39minutes  5minutes
    ${lbpsCellPeriodList}  Create Dictionary
    Set To Dictionary  ${lbpsCellPeriodList}  lbpsCellDayOfWeek=${day}
    IF  ${test_id}==43  Set To Dictionary  ${lbpsCellPeriodList}  nrCellId=${selected_cells[1]}
    IF  ${test_id}==39  Set To Dictionary  ${lbpsCellPeriodList}  nrCellId=${selected_cells[0]}
    IF  ${test_id}==41  Set To Dictionary  ${lbpsCellPeriodList}  nrCellId=${selected_cells[1]}
    Set To Dictionary  ${lbpsCellPeriodList}  lbpsCellSOMethod  TX switch off
    IF  ${test_id}==43  Set To Dictionary  ${lbpsCellPeriodList}  lbpsCellDuration=${lbpsDuration[0]}
    IF  ${test_id}==39  Set To Dictionary  ${lbpsCellPeriodList}  lbpsCellDuration=20
    IF  ${test_id}==41  Set To Dictionary  ${lbpsCellPeriodList}  lbpsCellDuration=40
    Set To Dictionary  ${lbpsCellPeriodList}  lbpsCellStartTimeHour=${start_hour}
    Set To Dictionary  ${lbpsCellPeriodList}  lbpsCellStartTimeMinute=${start_minutes}
    admin.append complex item to delta  ${NRPGRP_DN}  list_name=lbpsCellPeriodList  &{lbpsCellPeriodList}  delta_id=${delta_create_nrpgrp}
#PS.39 only part
    IF  ${test_id}==39  Get Time And Date With Minute Offset  39minutes  5minutes
    ${lbpsCellPeriodList}  Create Dictionary
    Set To Dictionary  ${lbpsCellPeriodList}  lbpsCellDayOfWeek=${day}
    IF  ${test_id}==39  Set To Dictionary  ${lbpsCellPeriodList}  nrCellId=${selected_cells[1]}
    Set To Dictionary  ${lbpsCellPeriodList}  lbpsCellSOMethod  TX switch off
    IF  ${test_id}==39  Set To Dictionary  ${lbpsCellPeriodList}  lbpsCellDuration=20
    Set To Dictionary  ${lbpsCellPeriodList}  lbpsCellStartTimeHour=${start_hour}
    Set To Dictionary  ${lbpsCellPeriodList}  lbpsCellStartTimeMinute=${start_minutes}
    IF  ${test_id}==39  admin.append complex item to delta  ${NRPGRP_DN}
    ...  list_name=lbpsCellPeriodList  &{lbpsCellPeriodList}  delta_id=${delta_create_nrpgrp}
#PS.39 only part end
    admin.save delta  ${RESULTS}/delta_create_nrpgrp_CB010683.json  ${delta_create_nrpgrp}
    Log  Activate Power Saving Group under ${NRPGRP_DN}  console=${true}
    admin.perform delta recommissioning  ${RESULTS}/delta_create_nrpgrp_CB010683.json  ${delta_create_nrpgrp}


Create And Activate PSGRP For CB010397_CB008800
    [Documentation]
    ...  **Example of simple usage:**
    ...  Create And Activate PSGRP For CB010397_CB008800  PSGRP-12  45min
    ...
    [Arguments]  ${PSGRP-ID}  ${lbpsDuration}
    ${selected_cells_IDs}=    Create List    ${1st_LNCELL_CB010397}    ${2nd_LNCELL_CB010397}    ${3rd_LNCELL_CB010397}
    ${delta_create_psgrp}=  Set Variable  psgrp_create
    ${PSGRP_DN}=  Set Variable  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}
    admin.create delta  ${delta_create_psgrp}
    admin.append managed object to delta  ${PSGRP_DN}  create  ${delta_create_psgrp}
    admin.append parameter update to delta  ${PSGRP_DN}  lbpsCSONCtlEnabled  false  ${delta_create_psgrp}
    admin.append parameter update to delta  ${PSGRP_DN}  lbpsLastCellMinLoad  1  ${delta_create_psgrp}
    admin.append parameter update to delta  ${PSGRP_DN}  lbpsLastCellRTXMinLoad  1  ${delta_create_psgrp}
    admin.append parameter update to delta  ${PSGRP_DN}  lbpsLastCellSOEnabled  true  ${delta_create_psgrp}
    admin.append parameter update to delta  ${PSGRP_DN}  lbpsMaxLoad  2  ${delta_create_psgrp}
    admin.append parameter update to delta  ${PSGRP_DN}  lbpsMinLoad  1  ${delta_create_psgrp}
    admin.append parameter update to delta  ${PSGRP_DN}  lbpsPdcchLoadOffset  1  ${delta_create_psgrp}
    admin.append parameter update to delta  ${PSGRP_DN}  lbpsRTXCellCapOffset  80  ${delta_create_psgrp}
    admin.append parameter update to delta  ${PSGRP_DN}  lbpsRTXMaxLoad  2  ${delta_create_psgrp}
    admin.append parameter update to delta  ${PSGRP_DN}  lbpsRTXMinLoad  1  ${delta_create_psgrp}
    ${sw_splited}  Split String  ${active_sw_version}  _
    ${sw_prefix} = 	Get From List  ${sw_splited}  0
    Set Test Variable  ${sw_prefix}
    Run Keyword If  '${if_actCo4g5g}'=='PASS' and '${sw_prefix}'!='SBTS23R2'
    ...  Run Keywords  admin.append parameter update to delta  ${PSGRP_DN}  lbpsGuardTimerNrAct  20  ${delta_create_psgrp}
    ...  AND  admin.append parameter update to delta  ${PSGRP_DN}  lbpsMaxLoadNrAct  40  ${delta_create_psgrp}
    ...  AND  admin.append parameter update to delta  ${PSGRP_DN}  lbpsMinNumEndcCapUeNrAct  0  ${delta_create_psgrp}
    ...  AND  admin.append parameter update to delta  ${PSGRP_DN}  lbpsMonWinNrAct  5  ${delta_create_psgrp}
    ...  AND  admin.append parameter update to delta  ${PSGRP_DN}  lbpsRetryTimerNrAct  5  ${delta_create_psgrp}
    ${actMixedSOMethod_state} =  Check parameter availability under LNBTS    actMixedSOMethod
    Run Keyword If  '${actMixedSOMethod_state}'=='PASS'
    ...  admin.append parameter update to delta  ${PSGRP_DN}  lbpsSOMethod  Mixed Switch Off  ${delta_create_psgrp}
    ${lbpsCellList}=  Create Dictionary
    ${item}=  Create List  20  100  100
    FOR  ${i}  ${cell}  IN ZIP  ${item}  ${selected_cells_IDs}
        Set To Dictionary  ${lbpsCellList}  lbpsUseExtConfig  true
        Set To Dictionary  ${lbpsCellList}  lbpsCellSOOrder=${i}
        Set To Dictionary  ${lbpsCellList}  lnCelId=${cell}
        admin.append complex item to delta  ${PSGRP_DN}  list_name=lbpsCellList  &{lbpsCellList}  delta_id=${delta_create_psgrp}
    END
    ${lbpsCelPeriodList}=  Create Dictionary
    ${switch_off_methods}=  Create List  Cell Switch Off  Tx Paths Switch Off  Tx Paths Switch Off
    Get Time And Date With Minute Offset  3minutes
    FOR  ${switch_off_method}  ${cell_ID}  IN ZIP  ${switch_off_methods}  ${selected_cells_IDs}
        Set To Dictionary  ${lbpsCelPeriodList}  lbpsCellDayOfWeek=${day}
        Set To Dictionary  ${lbpsCelPeriodList}  lbpsCellDuration=20
        Set To Dictionary  ${lbpsCelPeriodList}  lbpsCellSOMethod=${switch_off_method}
        Run Keyword If  '${switch_off_method}' == 'Cell Switch Off'
        ...  Run Keywords  Get Time And Date With Minute Offset  5 minutes  20 minutes
        ...  AND  Set To Dictionary  ${lbpsCelPeriodList}  lbpsCellStartTimeHour=${start_hour}
        ...  AND  Set To Dictionary  ${lbpsCelPeriodList}  lbpsCellStartTimeMinute=${start_minutes}
        ...  AND  Log  Power Saving for LNCEL_R-${cell_ID} time frame: ${start_hour}:${start_minutes}-${end_hour}:${end_minutes}.  console=${true}
        ...  AND  Log  Switching Off Method: ${switch_off_method}  console=${true}  console=${true}
        ...  ELSE IF  '${switch_off_method}' == 'Tx Paths Switch Off'
        ...  Run Keywords  Get Time And Date With Minute Offset  7 minutes  20 minutes
        ...  AND  Set To Dictionary  ${lbpsCelPeriodList}  lbpsCellStartTimeHour=${start_hour}
        ...  AND  Set To Dictionary  ${lbpsCelPeriodList}  lbpsCellStartTimeMinute=${start_minutes}
        ...  AND  Log  Power Saving for LNCEL_R-${cell_ID} time frame: ${start_hour}:${start_minutes}-${end_hour}:${end_minutes}.  console=${true}
        ...  AND  Log  Switching Off Method: ${switch_off_method}  console=${true}
        Set To Dictionary  ${lbpsCelPeriodList}  lnCelId=${cell_ID}
        admin.append complex item to delta  ${PSGRP_DN}  list_name=lbpsCelPeriodList  &{lbpsCelPeriodList}  delta_id=${delta_create_psgrp}
    END
    Get Time And Date With Minute Offset  3minutes
    ${lbpsPeriodList}=  Create Dictionary
    Set To Dictionary  ${lbpsPeriodList}  lbpsDayOfWeek=${day}
    ${lbpsDuration}=  Get Regexp Matches  ${lbpsDuration}  \\d+
    Set To Dictionary  ${lbpsPeriodList}  lbpsDuration=${lbpsDuration[0]}
    Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeHour=${start_hour}
    Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeMinute=${start_minutes}
    Set To Dictionary  ${lbpsPeriodList}  lbpsSuspended=notSuspended
    admin.append complex item to delta  ${PSGRP_DN}  list_name=lbpsPeriodList  &{lbpsPeriodList}  delta_id=${delta_create_psgrp}
    admin.get delta  ${delta_create_psgrp}
    admin.save delta  ${RESULTS}/delta_create_psgrp_${PSGRP-ID}_CB010397.json  ${delta_create_psgrp}
    Log  Activate Power Saving Group under MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  console=${true}
    admin.perform delta recommissioning  ${RESULTS}/delta_create_psgrp_${PSGRP-ID}_CB010397.json  ${delta_create_psgrp}
    ${end_time}=  Add Time To Date  ${time_with_offset}  ${lbpsDuration[0]} minutes
    ${end_hour}=  Convert Date  ${end_time}  result_format=%H
    ${end_minutes}=  Convert Date  ${end_time}  result_format=%M
    Log  Power Saving Group time frame: ${start_hour}:${start_minutes}-${end_hour}:${end_minutes} (+${lbpsDuration[0]} minutes)  console=${true}
    Log  Affected cells in ${PSGRP-ID}:  console=${true}
    Log  - Reduced Energy Saving: LNCEL_R-${3rd_LNCELid}  console=${true}
    Log  - Reduced Energy Saving: LNCEL_R-${2nd_LNCELid}  console=${true}
    Log  - Energy Saving: LNCEL_R-${1st_LNCELid}  console=${true}


Remove SWRESETREQ Object If Exists
    ${gpoup_obj_all}  admin.get managed objects  SWRESETREQ_A
    IF  ${gpoup_obj_all}!=[]
        Log  SWRESETREQ object exist and will be deleted  console=${true}
        Delete Old SWRESETREQ Object  ${gpoup_obj_all}
    ELSE
        Log  There is no SWRESETREQ object on testline
    END


Delete Old SWRESETREQ Object
    [Documentation]  Remove old SWRESETREQ object from BTS.
    [Arguments]  ${gpoup_obj_all}

    ${gpoup_path_list}  Create List
    FOR  ${i}  IN  @{gpoup_obj_all}
        ${gpoup_distName}  Set Variable  ${i['distName']}
        ${ignore}  ${gpoup_path}  Split String From Right  ${gpoup_distName}  separator=SCF-1/
        ${gpoup}  Replace String  ${gpoup_path}  search_for=_A  replace_with=
        Append To List  ${gpoup_path_list}  ${gpoup}
    END
    ${delta_gpoup_obj}  Set Variable  gpoup_del
    admin.create delta  ${delta_gpoup_obj}
    FOR  ${i}  IN  @{gpoup_path_list}
        admin.append managed object to delta  ${i}  delete  delta_id=${delta_gpoup_obj}
    END
    admin.get delta  ${delta_gpoup_obj}
    admin.save delta  ${RESULTS}/delete_gpoup_obj.json  delta_id=${delta_gpoup_obj}
    admin.perform delta recommissioning  ${RESULTS}/delete_gpoup_obj.json  ${SKIP_PARAMETER_RELATION_ERRORS}


Create And Activate SWRESETREQ
    [Documentation]
    ...  Keyword creating SWRESETREQ to perform site reset with grace cell shutdown for CB006830
    ...  Create And Activate SWRESETREQ  ${SWRESETREQ-ID}
    [Arguments]  ${SWRESETREQ-ID}

    ${delta_create_SWRESETREQ}  Set Variable  SWRESETREQ_create
    ${SWRESETREQ_DN}  Set Variable  MRBTS-${MRBTS_ID}/MNL-$1/CMD-1/${SWRESETREQ-ID}
    admin.create delta  ${delta_create_SWRESETREQ}
    admin.append managed object to delta  MRBTS-${MRBTS_ID}/MNL-1/CMD-1/${SWRESETREQ-ID}  create  ${delta_create_SWRESETREQ}
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/MNL-1/CMD-1/${SWRESETREQ-ID}  swResetLevel  btsReset   ${delta_create_SWRESETREQ}
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/MNL-1/CMD-1/${SWRESETREQ-ID}  gracefulCellShutdown  true  ${delta_create_SWRESETREQ}
    admin.get delta  ${delta_create_SWRESETREQ}
    admin.save delta  ${RESULTS}/delta_create_SWRESETREQ_${SWRESETREQ-ID}.json  ${delta_create_SWRESETREQ}
    Log  Activate SWRESETREQ under MRBTS-${MRBTS_ID}/MNL-$1/CMD-1/${SWRESETREQ-ID}  console=${true}
    admin.perform delta recommissioning  ${RESULTS}/delta_create_SWRESETREQ_${SWRESETREQ-ID}.json  ${delta_create_SWRESETREQ}


Check For Specofic Time
    [Arguments]  ${technology}  ${state_value}  ${specific_time}

    FOR  ${i}  IN RANGE  ${specific_time}
        Check If Cells Are Disabled  ${technology}  ${state_value}
        Sleep  1s
    END


Suspend/notSuspend PowerSaving NR
    [Documentation]  Suspends/Unsuspends PS choosen PS GRP time period
    [Arguments]  ${nrpgrp_id}=1  ${suspended}=suspended  ${period}=1

    ${NRPGRP_DN}  Set Variable  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-${nrpgrp_id}
    ${nrpgrpParameters}  admin.get managed objects  NRPGRP_A
    ${lbpsPeriodListToSuspend}  Create Dictionary
    ${delta_nrpgrpSuspend}  Set Variable  nrpgrpSuspend
    ${PLANS_DIR}  Set Variable  ${RESULTS}/plans
    admin.create delta  ${delta_nrpgrpSuspend}
    FOR  ${nrpgrpParameter}  IN  @{nrpgrpParameters}
      ${lbpsPeriodList}  Get From Dictionary  ${nrpgrpParameter['parameters']}  lbpsPeriodList
      Set Test Variable  ${lbpsPeriodList}
    END
    ${counter}  Set Variable  ${1}
    FOR  ${parameter}  IN  @{lbpsPeriodList}
      ${lbpsDayOfWeek}  Get From Dictionary  ${parameter}  lbpsDayOfWeek
      ${lbpsDuration}  Get From Dictionary  ${parameter}  lbpsDuration
      ${lbpsStartTimeHour}  Get From Dictionary  ${parameter}  lbpsStartTimeHour
      ${lbpsStartTimeMinute}  Get From Dictionary  ${parameter}  lbpsStartTimeMinute
      ${lbpsCurrentSuspend}  Get From Dictionary  ${parameter}  lbpsSuspended
      Set To Dictionary  ${lbpsPeriodListToSuspend}  lbpsDayOfWeek=${lbpsDayOfWeek}
      Set To Dictionary  ${lbpsPeriodListToSuspend}  lbpsDuration=${lbpsDuration}
      Set To Dictionary  ${lbpsPeriodListToSuspend}  lbpsStartTimeHour=${lbpsStartTimeHour}
      Set To Dictionary  ${lbpsPeriodListToSuspend}  lbpsStartTimeMinute=${lbpsStartTimeMinute}
      IF  ${counter} == ${period}  Set To Dictionary  ${lbpsPeriodListToSuspend}  lbpsSuspended=${suspended}
      IF  ${counter} != ${period}  Set To Dictionary  ${lbpsPeriodListToSuspend}  lbpsSuspended=${lbpsCurrentSuspend}
      admin.append complex item to delta  ${NRPGRP_DN}  list_name=lbpsPeriodList  &{lbpsPeriodListToSuspend}  delta_id=${delta_nrpgrpSuspend}
      ${counter}  Evaluate  ${counter} + 1
    END
    admin.get delta  ${delta_nrpgrpSuspend}
    admin.save delta  ${PLANS_DIR}/delta_nrpgrpSuspend.json  ${delta_nrpgrpSuspend}
    admin.perform delta recommissioning  ${PLANS_DIR}/delta_nrpgrpSuspend.json  ${delta_nrpgrpSuspend}


Create And Activate NRPGRP for 5GC000431_Cell_Outage
    [Documentation]
    ...  Creates and activates NRGRP.
    ...  Demands ${cell_order}  ${selected_cells}
    [Arguments]  ${NRPGRP-ID}  ${lbpsDuration}

    ${delta_create_nrpgrp}  Set Variable  nrpgrp_create
    ${NRPGRP_DN}  Set Variable  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-${NRPGRP-ID}
    admin.create delta  ${delta_create_nrpgrp}
    admin.append managed object to delta  ${NRPGRP_DN}  create  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsCSONCtlEnabled  false  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsLastCellMinLoad  10  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsLastCellSOEnabled  false  ${delta_create_nrpgrp}
#    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsLoadCalcMethod  Max(G, C, P)  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsLoadCalcMethod  Max(G_N_combined, P)  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsMaxLoad  16  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsMinLoad  8  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsMonWinForCellSOff  360  ${delta_create_nrpgrp}
	#admin.append parameter update to delta  ${NRPGRP_DN}  lbpsMonWinForCellSOff  180  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsMonWinForCellSOn  120  ${delta_create_nrpgrp}
#    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsSOffTrRule  MaxValueMethod  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsSOffTrRule  SlidingAverageMethod  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsPdcchLoadOffset  4  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsSOMethod  cell switch off  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsSOnTrRule  SlidingAverageMethod  ${delta_create_nrpgrp}
#    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsSOnTrRule  MinValueMethod  ${delta_create_nrpgrp}
    ${lbpsCellList}  Create Dictionary
    ${item}  Create List  1  2  3  4
    FOR  ${i}  ${cell}  IN ZIP  ${item}  ${selected_cells_IDs}
        Set To Dictionary  ${lbpsCellList}  lbpsCellSOOrder=${i}
        Set To Dictionary  ${lbpsCellList}  nrCellId=${cell}
        IF  '${if_actNrExtCellSOMethod}'=='PASS'
        ...  Set To Dictionary  ${lbpsCellList}  lbpsUseExtConfig  false
        admin.append complex item to delta  ${NRPGRP_DN}  list_name=lbpsCellList  &{lbpsCellList}  delta_id=${delta_create_nrpgrp}
    END
    Get Time And Date With Minute Offset  4minutes  5minutes
    ${lbpsPeriodList}  Create Dictionary
    Set To Dictionary  ${lbpsPeriodList}  lbpsDayOfWeek=${day}
    ${lbpsDuration}  Get Regexp Matches  ${lbpsDuration}  \\d+
    Set To Dictionary  ${lbpsPeriodList}  lbpsDuration=${lbpsDuration[0]}
    Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeHour=${start_hour}
    Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeMinute=${start_minutes}
    Set To Dictionary  ${lbpsPeriodList}  lbpsSuspended=notSuspended
    admin.append complex item to delta  ${NRPGRP_DN}  list_name=lbpsPeriodList  &{lbpsPeriodList}  delta_id=${delta_create_nrpgrp}
    Log  Power Saving For NRPGRP time frame: ${start_hour}:${start_minutes}-${end_hour}:${end_minutes}  console=${true}
    admin.append complex item to delta  ${NRPGRP_DN}  list_name=lbpsPeriodList  &{lbpsPeriodList}  delta_id=${delta_create_nrpgrp}
    admin.get delta  ${delta_create_nrpgrp}
    admin.save delta  ${RESULTS}/delta_create_nrpgrp_CB008745.json  ${delta_create_nrpgrp}
    Log  Activate Power Saving Group under ${NRPGRP_DN}  console=${true}
    admin.perform delta recommissioning  ${RESULTS}/delta_create_nrpgrp_CB008745.json  ${delta_create_nrpgrp}


Create And Activate NRPGRP for 5GC000431
    [Documentation]
    ...  Creates and activates NRGRP with 3 PS time periods.
    ...  Demands ${cell_order}  ${selected_cells}
    [Arguments]  ${nrpgrp_id}=1  ${suspended_1}=notSuspended  ${suspended_2}=notSuspended  ${suspended_3}=suspended
    ...  ${duration}=20  ${duration_2}=20  ${duration_3}=25

    ${delta_create_nrpgrp}  Set Variable  nrpgrp_create
    ${PLANS_DIR}  Set Variable  ${RESULTS}/plans
    ${NRPGRP_DN}  Set Variable  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-${nrpgrp_id}
    admin.create delta  ${delta_create_nrpgrp}
    admin.append managed object to delta  ${NRPGRP_DN}  create  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsCSONCtlEnabled  false  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsLastCellMinLoad  2  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsLastCellSOEnabled  false  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsMaxLoad  30  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsMinLoad  20  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsPdcchLoadOffset  15  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsSOMethod  cell switch off  ${delta_create_nrpgrp}
    ${lbpsCellList}  Create Dictionary
    FOR  ${i}  ${cell}  IN ZIP  ${cell_order}  ${selected_cells}
      Set To Dictionary  ${lbpsCellList}  lbpsCellSOOrder=${i}
      Set To Dictionary  ${lbpsCellList}  nrCellId=${cell}
      IF  '${if_actNrExtCellSOMethod}'=='PASS'  Set To Dictionary  ${lbpsCellList}  lbpsUseExtConfig  false
      admin.append complex item to delta  ${NRPGRP_DN}  list_name=lbpsCellList  &{lbpsCellList}  delta_id=${delta_create_nrpgrp}
    END
    Get Time And Date With Minute Offset  3minutes  ${duration} minutes
    ${lbpsPeriodList}  Create Dictionary
    Set To Dictionary  ${lbpsPeriodList}  lbpsDayOfWeek=${day}
    Set To Dictionary  ${lbpsPeriodList}  lbpsDuration=${duration}
    Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeHour=${start_hour}
    Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeMinute=${start_minutes}
    Set To Dictionary  ${lbpsPeriodList}  lbpsSuspended=${suspended_1}
    admin.append complex item to delta  ${NRPGRP_DN}  list_name=lbpsPeriodList  &{lbpsPeriodList}  delta_id=${delta_create_nrpgrp}
    Log  Power Saving Group time frame: ${start_hour}:${start_minutes}-${end_hour}:${end_minutes}  console=${true}
    Get Time And Date With Minute Offset  25minutes  ${duration_2} minutes
    ${lbpsPeriodList}  Create Dictionary
    Set To Dictionary  ${lbpsPeriodList}  lbpsDayOfWeek=${day}
    Set To Dictionary  ${lbpsPeriodList}  lbpsDuration=${duration_2}
    Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeHour=${start_hour}
    Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeMinute=${start_minutes}
    Set To Dictionary  ${lbpsPeriodList}  lbpsSuspended=${suspended_2}
    admin.append complex item to delta  ${NRPGRP_DN}  list_name=lbpsPeriodList  &{lbpsPeriodList}  delta_id=${delta_create_nrpgrp}
    Log  Power Saving Group time frame: ${start_hour}:${start_minutes}-${end_hour}:${end_minutes}  console=${true}
    Get Time And Date With Minute Offset  46minutes  ${duration_3} minutes
    ${lbpsPeriodList}  Create Dictionary
    Set To Dictionary  ${lbpsPeriodList}  lbpsDayOfWeek=${day}
    Set To Dictionary  ${lbpsPeriodList}  lbpsDuration=${duration_3}
    Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeHour=${start_hour}
    Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeMinute=${start_minutes}
    Set To Dictionary  ${lbpsPeriodList}  lbpsSuspended=${suspended_3}
    admin.append complex item to delta  ${NRPGRP_DN}  list_name=lbpsPeriodList  &{lbpsPeriodList}  delta_id=${delta_create_nrpgrp}
    Log  Power Saving Group time frame: ${start_hour}:${start_minutes}-${end_hour}:${end_minutes}  console=${true}
    admin.get delta  ${delta_create_nrpgrp}
    admin.save delta  ${PLANS_DIR}/delta_create_nrpgrp_5GC000431.json  ${delta_create_nrpgrp}
    Log  Activate Power Saving Group under ${NRPGRP_DN}  console=${true}
    admin.perform delta recommissioning  ${PLANS_DIR}/delta_create_nrpgrp_5GC000431.json  ${delta_create_nrpgrp}


Wait for date
    [Documentation]  This keyword checks if the provoided date/time is met
    ...    In basic form its 30 loops times 30 secounds = 900 s = 15 min
    [Arguments]  ${given_date}  ${number_of_loops}=30  ${loop_duration}=30

    Log To Console  Wait until ${given_date}
    FOR  ${i}  IN RANGE  0  ${number_of_loops}
        ${current_date}  Get Current Date
        ${result}  Subtract Date From Date  ${given_date}  ${current_date}
        Exit For Loop If  ${result} <= 0
        Sleep  ${loop_duration} s
    END


Wait Until Time Plus Minutes
    [Documentation]  Reads current hour and minute, computes how many minutes are left until
    ...    \${time_hh_mm} + \${minutes_to_add}, then sleeps that long. Use e.g. with \${T2_TIME} or \${T3_TIME}.
    [Arguments]  ${time_hh_mm}  ${minutes_to_add}=1

    ${curr_h}  Get Current Date  result_format=%H
    ${curr_m}  Get Current Date  result_format=%M
    ${parts}  Split String  ${time_hh_mm}  :
    ${target_m}  Evaluate  (int("${parts[1]}") + int(${minutes_to_add})) % 60
    ${carry}  Evaluate  (int("${parts[1]}") + int(${minutes_to_add})) // 60
    ${target_h}  Evaluate  (int("${parts[0]}") + int(${carry})) % 24
    ${target_min}  Evaluate  int(${target_h}) * 60 + int(${target_m})
    ${current_min}  Evaluate  int("${curr_h}") * 60 + int("${curr_m}")
    ${minutes_left}  Evaluate  int(${target_min}) - int(${current_min})
    ${minutes_left}  Set Variable If  ${minutes_left} < 0  0  ${minutes_left}
    IF  ${minutes_left} > 0
        Log  Waiting ${minutes_left} min until ${time_hh_mm}+${minutes_to_add}min  console=True
        Sleep  ${minutes_left} min
    END


Select All NR Cells
    [Documentation]    This keyword collects ID's and Path's of every NR Cells
    ...    assigning it to list's: selected_cells, selected_cells_paths
    ...    Also creates test variable nr_cells_length

    ${NR_cells}  admin.get parameters for all  NRCEL
    ${nr_cells_length}  Get Length  ${nr_cells}
    Set Test Variable  ${nr_cells_length}
    @{selected_cells}  create List
    @{selected_cells_paths}  create List
    Set Test Variable  @{selected_cells}
    Set Test Variable  @{selected_cells_paths}
    FOR  ${cell}  IN RANGE  ${nr_cells_length}
      ${cell_id}  ${cell_path}  Get Id Of Selected Cell  ${nr_cells}[${cell}]
      Append To List  ${selected_cells}  ${cell_id}
      Append To List  ${selected_cells_paths}  ${cell_path}
    END


Select Three Random LTE Cells
    ${LTE_cells}  admin.get parameters for all  LNCEL
    @{cell}  Evaluate  random.sample(${LTE_cells}, 3)  random
    ${1st_LNCEL_ID}  ${1st_LNCEL_DN}  Get Id Of Selected Cell  ${cell}[0]
    ${2nd_LNCEL_ID}  ${2nd_LNCEL_DN}  Get Id Of Selected Cell  ${cell}[1]
    ${3rd_LNCEL_ID}  ${3rd_LNCEL_DN}  Get Id Of Selected Cell  ${cell}[2]
    Set Test Variable  ${1st_LNCEL_ID}
    Set Test Variable  ${2nd_LNCEL_ID}
    Set Test Variable  ${3rd_LNCEL_ID}
    Set Test Variable  ${1st_LNCEL_DN}
    Set Test Variable  ${2nd_LNCEL_DN}
    Set Test Variable  ${3rd_LNCEL_DN}


Remove PSGRP/NRPGRP Objects If Exist
    [Documentation]  This keyword remove PSGRP/NRPGRP objects if exist on BTS.
    [Arguments]  ${group}

    IF  '${group}'=='PSGRP'
        Remove PSGRP Objects If Exist
    ELSE IF  '${group}'=='NRPGRP'
        Remove NRPGRP Objects If Exist
    ELSE IF  '${group}'== 'PSGRP/NRPGRP'
        Remove PSGRP Objects If Exist
        Remove NRPGRP Objects If Exist
    END


Remove PSGRP Objects If Exist
    ${gpoup_obj_all}  admin.get managed objects  PSGRP_A
    IF  ${gpoup_obj_all}!=[]
        Log  PSGRP object exist and will be deleted  console=true
        Delete Old PSGRP/NRPGRP Objects  ${gpoup_obj_all}
    ELSE
        Log  There is no PSGRP objects on testline  console=true
    END


Remove NRPGRP Objects If Exist
    ${gpoup_obj_all}  admin.get managed objects  NRPGRP_A
    IF  ${gpoup_obj_all}!=[]
        Log  NRPGRP object exist and will be deleted  console=true
        Delete Old PSGRP/NRPGRP Objects  ${gpoup_obj_all}
    ELSE
        Log  There is no NRPGRP objects on testline  console=true
    END


Delete Old PSGRP/NRPGRP Objects
    [Documentation]  Remove old PSGRP/NRPGRP objects from BTS.
    [Arguments]  ${gpoup_obj_all}

    ${gpoup_path_list}  Create List
    FOR  ${i}  IN  @{gpoup_obj_all}
        ${gpoup_distName}  Set Variable  ${i['distName']}
        ${ignore}  ${gpoup_path}  Split String From Right  ${gpoup_distName}  separator=SCF-1/
        ${gpoup}  Replace String  ${gpoup_path}  search_for=_A  replace_with=
        Append To List  ${gpoup_path_list}  ${gpoup}
    END
    ${delta_gpoup_obj}  Set Variable  gpoup_del
    admin.create delta  ${delta_gpoup_obj}
    FOR  ${i}  IN  @{gpoup_path_list}
        admin.append managed object to delta  ${i}  delete  delta_id=${delta_gpoup_obj}
    END
    admin.get delta  ${delta_gpoup_obj}
    admin.save delta  ${RESULTS}/delete_gpoup_obj.json  delta_id=${delta_gpoup_obj}
    Sleep  30s
    admin.perform delta recommissioning  ${RESULTS}/delete_gpoup_obj.json  ${SKIP_PARAMETER_RELATION_ERRORS}


Remove Old NRFSOPGRPs Objects If Existing
    [Documentation]  Description: Remove old NRFSOPGRP objects from BTS using delta recommissioning.

    ${group_obj_list}  admin.Get Managed Objects  NRFSOPGRP_A
    IF  ${group_obj_list}!=[]
        Log  NRFSOPGRP objects exist and will be deleted  console=true
    ELSE
        Log  There are no NRFSOPGRP objects on testline  console=true
        Return From Keyword
    END
    ${group_path_list}  Create List
    FOR  ${obj}  IN  @{group_obj_list}
        ${group_distName}  Set Variable  ${obj['distName']}
        ${ignore}  ${group_path}  Split String From Right  ${group_distName}  separator=SCF-1/
        ${group}  Replace String  ${group_path}  search_for=_A  replace_with=
        Append To List  ${group_path_list}  ${group}
    END
    ${delta_group_obj}  Set Variable  group_del
    admin.Create Delta  ${delta_group_obj}
    FOR  ${path}  IN  @{group_path_list}
        admin.Append Managed Object To Delta  ${path}  delete  delta_id=${delta_group_obj}
    END
    admin.Get Delta  ${delta_group_obj}
    admin.Save Delta  ${RESULTS}/delete_group_obj.json  delta_id=${delta_group_obj}
    Sleep  30s
    admin.Perform Delta Recommissioning  ${RESULTS}/delete_group_obj.json  true


Remove Old ${psgrp_type} Objects If Present
    [Documentation]  Description: Remove old PSGRP objects from BTS using delta recommissioning.

    ${group_obj_list}  admin.Get Managed Objects  ${psgrp_type}_A
    IF  ${group_obj_list}!=[]
        Log  ${psgrp_type} objects exist and will be deleted  console=true
    ELSE
        Log  There are no ${psgrp_type} objects on testline  console=true
        Return From Keyword
    END
    ${group_path_list}  Create List
    FOR  ${obj}  IN  @{group_obj_list}
        ${group_distName}  Set Variable  ${obj['distName']}
        ${ignore}  ${group_path}  Split String From Right  ${group_distName}  separator=SCF-1/
        ${group}  Replace String  ${group_path}  search_for=_A  replace_with=
        Append To List  ${group_path_list}  ${group}
    END
    ${delta_group_obj}  Set Variable  group_del
    admin.Create Delta  ${delta_group_obj}
    FOR  ${path}  IN  @{group_path_list}
        admin.Append Managed Object To Delta  ${path}  delete  delta_id=${delta_group_obj}
    END
    admin.Get Delta  ${delta_group_obj}
    admin.Save Delta  ${RESULTS}/delete_group_obj.json  delta_id=${delta_group_obj}
    Sleep  30s
    admin.Perform Delta Recommissioning  ${RESULTS}/delete_group_obj.json  true


Change Parameter Under LNCEL
    [Documentation]  This KW changes parameter under LNCEL object without using Netact.
	...  Example of usage:
    ...  Change Parameter Under LNCEL  administrativeState  shutting down  ${1st_CELL_ID}
    [Arguments]  ${parameter}  ${value}  ${ID}

    ${parameter_delta}  Set Variable  lncel_${parameter}_${value}
    admin.create delta  ${parameter_delta}
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-${ID}  ${parameter}  ${value}  ${parameter_delta}
    admin.get delta  ${parameter_delta}
    admin.save delta  ${RESULTS}/lncel_delta_change_admstate_${parameter}_${value}.json  ${parameter_delta}
    admin.perform delta recommissioning  ${RESULTS}/lncel_delta_change_admstate_${parameter}_${value}.json  ${parameter_delta}


Change Parameter Under NRCELL
    [Documentation]  This KW changes parameter under NRCELL object without using Netact.
	...  Example of usage:
    ...  Change Parameter Under NRCELL  administrativeState  shutting down  ${1st_CELL_ID}
    [Arguments]  ${parameter}  ${value}  ${ID}

    ${parameter_delta}  Set Variable  nrcell_${parameter}_${value}
    admin.create delta  ${parameter_delta}
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${ID}  ${parameter}  ${value}  ${parameter_delta}
    admin.get delta  ${parameter_delta}
    admin.save delta  ${RESULTS}/nrcell_delta_change_admstate_${parameter}_${value}.json  ${parameter_delta}
    admin.perform delta recommissioning  ${RESULTS}/nrcell_delta_change_admstate_${parameter}_${value}.json  ${parameter_delta}


Create List Of FDD Cells
    ${lncel_param}  admin.get parameters for all  LNCEL
    ${lncel_fdd}  Create List
    ${lncel_fdd_ids}  Create List
    FOR  ${ITEM}  IN  @{lncel_param}
        IF  '${item['technology']}'=='FDD'  Append To List  ${lncel_fdd}  ${item['id']}
    END
    FOR  ${cell}  IN  @{lncel_fdd_ids}
        ${id}  Evaluate  re.search(r'LNCEL_R-(\\d+)','''${item}''').group(1)  re
        Append To List  ${lncel_fdd_ids}  ${id}
    END

    RETURN  ${lncel_fdd_ids}


Check Syslog For Gracefull Shutdown Messages
    [Documentation]  Grep syslog.
    ...  **Author:** tomasz.marchewka@nokia.com
    ...  **Example of simple usage:**
    ...   Check Syslog For Gracefull Shutdown Messages  LTE
    ...   Check Syslog For Gracefull Shutdown Messages  LTE/NR
    ...
    [Arguments]  ${rat}

    ${start_shutdown_lte}  Set Variable If  '${rat}'=='LTE' or '${rat}'=='LTE/NR'  RromGracefulCellShutdownFsm.*Start Cell ShutDown procedure.*
    ${already_shutdown}  Set Variable If  '${rat}'=='LTE' or '${rat}'=='LTE/NR'  RromGracefulCellShutdownFsm.*is already shutdown.*
    ${resetting_shutdown}  Set Variable If  '${rat}'=='LTE' or '${rat}'=='LTE/NR'  RromGracefulCellShutdownFsm.*Resetting shutdown service.*
    ${pscell_shutdown}  Set Variable If  '${rat}'=='NR' or '${rat}'=='LTE/NR'  PsCell.*QueueStateDefault.*PSCELL_DL_CELL_SHUTDOWN_REQ_MSG
    ${start_shutdown_nr}  Set Variable If  '${rat}'=='NR' or '${rat}'=='LTE/NR'  .*slotType\/PowerReduction.*Starting cell shutdown.*
    ${cell_shutdown}  Set Variable If  '${rat}'=='NR' or '${rat}'=='LTE/NR'  .*slotType\/PowerReduction.*Cell shutdown config.*
    IF  '${rat}'=='LTE' or '${rat}'=='LTE/NR'
        ute_syslog.wait for message in syslog file  regexp=${start_shutdown_lte}  timeout=15min  alias=ute_syslog
        Log  Message ${start_shutdown_lte} in syslog found  console=${true}
    END
    IF  '${rat}'=='LTE' or '${rat}'=='LTE/NR'
        ute_syslog.wait for message in syslog file  regexp=${already_shutdown}  timeout=15min  alias=ute_syslog
        Log  Message ${already_shutdown} in syslog found  console=${true}
    END
    IF  '${rat}'=='LTE' or '${rat}'=='LTE/NR'
        ute_syslog.wait for message in syslog file  regexp=${resetting_shutdown}  timeout=15min  alias=ute_syslog
        Log  Message ${resetting_shutdown} in syslog found  console=${true}
    END
    IF  '${rat}'=='NR' or '${rat}'=='LTE/NR'
        ute_syslog.wait for message in syslog file  regexp=${pscell_shutdown}  timeout=15min  alias=ute_syslog
        Log  Message ${pscell_shutdown} in syslog found  console=${true}
    END
    IF  '${rat}'=='NR' or '${rat}'=='LTE/NR'
        ute_syslog.wait for message in syslog file  regexp=${start_shutdown_nr}  timeout=15min  alias=ute_syslog
        Log  Message ${start_shutdown_nr} in syslog found  console=${true}
    END
    IF  '${rat}'=='NR' or '${rat}'=='LTE/NR'
        ute_syslog.wait for message in syslog file  regexp=${cell_shutdown}  timeout=15min  alias=ute_syslog
        Log  Message ${cell_shutdown} in syslog found  console=${true}
    END


Set Parameters For LTE Graceful Cell Shutdown
    [Arguments]  ${enableGrflShdn}  ${shutdownStepAmount}  ${shutdownWindow}

    ${pre_action_reset_number}  Get Reset Counter From Blackbox
    Set Feature Under Given Object  ${LNBTS_DistName}  enableGrflShdn  ${enableGrflShdn}
    Set Feature Under Given Object  ${LNBTS_DistName}  shutdownStepAmount  ${shutdownStepAmount}
    ${shutdownWindow}  Get Regexp Matches  ${shutdownWindow}  \\d+
    Set Feature Under Given Object  ${LNBTS_DistName}  shutdownWindow  ${shutdownWindow[0]}
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    ${post_action_reset_number}  Get Reset Counter From Blackbox
    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
    IF  ${counter_diff}==${0}
        Log  Reset Counter not incremented
    ELSE IF  ${counter_diff}>${1}
        Fail  msg=Reset Counter incremented (more than 1 unexpected reset)
    ELSE IF  ${counter_diff}==${1}
        Fail  msg=Reset Counter incremented +1
    END


Set Parameters For NR Graceful Cell Shutdown
    [Arguments]  ${actGrflShdn}  ${shutdownStepAmount}  ${shutdownWindow}

    ${pre_action_reset_number}  Get Reset Counter From Blackbox
    Set Feature Under Given Object  ${NRBTS_DistName}  actGrflShdn  ${actGrflShdn}
    Set Feature Under Given Object  ${NRBTS_DistName}  shutdownStepAmount  ${shutdownStepAmount}
    ${shutdownWindow}  Get Regexp Matches  ${shutdownWindow}  \\d+
    Set Feature Under Given Object  ${NRBTS_DistName}  shutdownWindow  ${shutdownWindow[0]}
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    ${post_action_reset_number}  Get Reset Counter From Blackbox
    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
    IF  ${counter_diff}==${0}
        Log  Reset Counter not incremented
    ELSE IF  ${counter_diff}>${1}
        Fail  msg=Reset Counter incremented (more than 1 unexpected reset)
    ELSE IF  ${counter_diff}==${1}
        Fail  msg=Reset Counter incremented +1
    END


Check which technology have to be chosen
    IF  '${IF_GSM_EXIST}'=='EXIST' and '${IF_WCDMA_EXIST}'=='EXIST' and '${IF_LTE_EXIST}'=='EXIST' and '${IF_NR_EXIST}'=='EXIST'
        Log to console    \n======= Actual Test Line RATs: NR || LTE || WCDMA || GSM =======
    ELSE IF  '${IF_GSM_EXIST}'=='NO' and '${IF_WCDMA_EXIST}'=='EXIST' and '${IF_LTE_EXIST}'=='EXIST' and '${IF_NR_EXIST}'=='EXIST'
        Log to console  \n======= Actual Test Line RATs: NR || LTE || WCDMA =======
    ELSE IF  '${IF_GSM_EXIST}'=='NO' and '${IF_WCDMA_EXIST}'=='NO' and '${IF_LTE_EXIST}'=='EXIST' and '${IF_NR_EXIST}'=='EXIST'
        Log to console  \n======= Actual Test Line RATs: NR || LTE  =======
    ELSE IF  '${IF_GSM_EXIST}'=='NO' and '${IF_WCDMA_EXIST}'=='NO' and '${IF_LTE_EXIST}'=='NO' and '${IF_NR_EXIST}'=='EXIST'
        Log to console  \n======= Actual Test Line RATs: NR =======
    ELSE IF  '${IF_GSM_EXIST}'=='NO' and '${IF_WCDMA_EXIST}'=='NO' and '${IF_LTE_EXIST}'=='EXIST' and '${IF_NR_EXIST}'=='NO'
        Log to console  \n======= Actual Test Line RATs: LTE =======
    ELSE IF  '${IF_GSM_EXIST}'=='EXIST' and '${IF_WCDMA_EXIST}'=="NO' and '${IF_LTE_EXIST}'=='EXIST' and '${IF_NR_EXIST}'=='NO'
        Log to console  \n======= Actual Test Line RATs: LTE || GSM =======
    ELSE IF  '${IF_GSM_EXIST}'=='EXIST' and '${IF_WCDMA_EXIST}'=='NO' and '${IF_LTE_EXIST}'=='NO' and '${IF_NR_EXIST}'=='EXIST'
        Log to console  \n======= Actual Test Line RATs: NR || GSM =======
    ELSE IF  '${IF_GSM_EXIST}'=='NO' and '${IF_WCDMA_EXIST}'=='EXIST' and '${IF_LTE_EXIST}'=='NO' and '${IF_NR_EXIST}'=='EXIST'
        Log to console  \n======= Actual Test Line RATs: NR || WCDMA =======
    ELSE IF  '${IF_GSM_EXIST}'=='NO' and '${IF_WCDMA_EXIST}'=='EXIST' and '${IF_LTE_EXIST}'=='EXIST' and '${IF_NR_EXIST}'=='NO'
        Log to console  \n======= Actual Test Line RATs: LTE || WCDMA =======
    END


Check which RAT are on given TestLine
    ${GSM_DEPLOYED}  admin.get ids for all  GNCEL
    ${WCDMA_DEPLOYED}  admin.get ids for all  WNCEL
    ${LTE_DEPLOYED}  admin.get ids for all  LNCEL
    ${NR_DEPLOYED}  admin.get ids for all  NRCEL
    ${IF_GSM_EXIST}  Set Variable If  ${GSM_DEPLOYED}!=[]  EXIST  NO
    ${IF_WCDMA_EXIST}  Set Variable If  ${WCDMA_DEPLOYED}!=[]  EXIST  NO
    ${IF_LTE_EXIST}  Set Variable If  ${LTE_DEPLOYED}!=[]  EXIST  NO
    ${IF_NR_EXIST}  Set Variable If  ${NR_DEPLOYED}!=[]  EXIST  NO
    Set Suite Variable  ${IF_GSM_EXIST}
    Set Suite Variable  ${IF_WCDMA_EXIST}
    Set Suite Variable  ${IF_LTE_EXIST}
    Set Suite Variable  ${IF_NR_EXIST}


Select Two Random LTE Cells
    ${LTE_cells}  admin.get parameters for all  LNCEL
    @{cell}  Evaluate  random.sample(${LTE_cells}, 2)  random
    ${1st_LNCEL_ID}  ${1st_LNCEL_DN}  Get Id Of Selected Cell  ${cell}[0]
    ${2nd_LNCEL_ID}  ${2nd_LNCEL_DN}  Get Id Of Selected Cell  ${cell}[1]
    Set Test Variable  ${1st_LNCEL_ID}  #1st_cell_id
    Set Test Variable  ${2nd_LNCEL_ID}  #2nd_cell_id
    Set Test Variable  ${1st_LNCEL_DN}  #1st_cell_path
    Set Test Variable  ${2nd_LNCEL_DN}  #2nd_cell_path


Select Six Random LTE Cells
    [Documentation]
    ...  Picks six random LTE cells (LNCEL) from the current admin context and exposes their IDs and DNs as
    ...  test variables. Requires at least 6 LNCELs to exist. Uses random.sample; no arguments.
    ...
    ...  **Sets test variables:**
    ...  - \${1st_LNCEL_ID} … \${6th_LNCEL_ID}  Cell IDs of the six selected LNCELs.
    ...  - \${1st_LNCEL_DN} … \${6th_LNCEL_DN}  Distinguished names of the six selected LNCELs.

    ${LTE_cells}  admin.Get Parameters For All  LNCEL
    @{cell}  Evaluate  random.sample(${LTE_cells}, 6)  random
    ${1st_LNCEL_ID}  ${1st_LNCEL_DN}  Get Id Of Selected Cell  ${cell}[0]
    ${2nd_LNCEL_ID}  ${2nd_LNCEL_DN}  Get Id Of Selected Cell  ${cell}[1]
    ${3rd_LNCEL_ID}  ${3rd_LNCEL_DN}  Get Id Of Selected Cell  ${cell}[2]
    ${4th_LNCEL_ID}  ${4th_LNCEL_DN}  Get Id Of Selected Cell  ${cell}[3]
    ${5th_LNCEL_ID}  ${5th_LNCEL_DN}  Get Id Of Selected Cell  ${cell}[4]
    ${6th_LNCEL_ID}  ${6th_LNCEL_DN}  Get Id Of Selected Cell  ${cell}[5]
    Set Test Variable  ${1st_LNCEL_ID}
    Set Test Variable  ${2nd_LNCEL_ID}
    Set Test Variable  ${3rd_LNCEL_ID}
    Set Test Variable  ${4th_LNCEL_ID}
    Set Test Variable  ${5th_LNCEL_ID}
    Set Test Variable  ${6th_LNCEL_ID}
    Set Test Variable  ${1st_LNCEL_DN}
    Set Test Variable  ${2nd_LNCEL_DN}
    Set Test Variable  ${3rd_LNCEL_DN}
    Set Test Variable  ${4th_LNCEL_DN}
    Set Test Variable  ${5th_LNCEL_DN}
    Set Test Variable  ${6th_LNCEL_DN}


Select Two Random LTE Cells for 10817
    ${LTE_cells}  admin.get parameters for all  LNCEL
    @{cell}  Evaluate  random.sample(${LTE_cells}, 2)  random
    ${1st_LNCEL_ID}  ${1st_LNCEL_DN}  Get Id Of Selected Cell  ${cell}[0]
    ${2nd_LNCEL_ID}  ${2nd_LNCEL_DN}  Get Id Of Selected Cell  ${cell}[1]
    Set Test Variable  ${1st_LNCEL_ID}  202
    Set Test Variable  ${2nd_LNCEL_ID}  107
    Set Test Variable  ${1st_LNCEL_DN}  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-10817/LNCEL_R-202
    Set Test Variable  ${2nd_LNCEL_DN}  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-10817/LNCEL_R-107

Select Two LTE Cells for 10818
    # selection restricted by UE frequency band capablities
    Set Test Variable  ${1st_LNCEL_ID}  48180
    Set Test Variable  ${2nd_LNCEL_ID}  48140
    Set Test Variable  ${1st_LNCEL_DN}  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-10818/LNCEL_R-48180
    Set Test Variable  ${2nd_LNCEL_DN}  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-10818/LNCEL_R-48140

Select Two Random LTE TX Cells for 10817
    ${LTE_cells}  admin.get parameters for all  LNCEL
    @{cell}  Evaluate  random.sample(${LTE_cells}, 2)  random
    ${1st_LNCEL_ID}  ${1st_LNCEL_DN}  Get Id Of Selected Cell  ${cell}[0]
    ${2nd_LNCEL_ID}  ${2nd_LNCEL_DN}  Get Id Of Selected Cell  ${cell}[1]
    Set Test Variable  ${1st_LNCEL_ID}  203
    Set Test Variable  ${2nd_LNCEL_ID}  107
    Set Test Variable  ${1st_LNCEL_DN}  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-10817/LNCEL_R-203
    Set Test Variable  ${2nd_LNCEL_DN}  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-10817/LNCEL_R-107


Select Two Random NR Cells
    ${NR_cells}  admin.get parameters for all  NRCEL
    @{cell}  Evaluate  random.sample(${NR_cells}, 2)  random
    ${1st_NRCELL_ID}  ${1st_NRCELL_DN}  Get Id Of Selected Cell  ${cell}[0]
    ${2nd_NRCELL_ID}  ${2nd_NRCELL_DN}  Get Id Of Selected Cell  ${cell}[1]
    Set Test Variable  ${1st_NRCELL_ID}  #1st_cell_id
    Set Test Variable  ${2nd_NRCELL_ID}  #2nd_cell_id
    Set Test Variable  ${1st_NRCELL_DN}  #1st_cell_path
    Set Test Variable  ${2nd_NRCELL_DN}  #2nd_cell_pathl


Select Three Random NR Cells
    ${NR_cells}  admin.get parameters for all  NRCEL
    @{cell}  Evaluate  random.sample(${NR_cells}, 3)  random
    ${1st_NRCELL_ID}  ${1st_NRCELL_DN}  Get Id Of Selected Cell  ${cell}[0]
    ${2nd_NRCELL_ID}  ${2nd_NRCELL_DN}  Get Id Of Selected Cell  ${cell}[1]
    ${3rd_NRCELL_ID}  ${3rd_NRCELL_DN}  Get Id Of Selected Cell  ${cell}[2]
    Set Test Variable  ${1st_NRCELL_ID}  #1st_cell_id
    Set Test Variable  ${2nd_NRCELL_ID}  #2nd_cell_id
    Set Test Variable  ${1st_NRCELL_DN}  #1st_cell_path
    Set Test Variable  ${2nd_NRCELL_DN}  #2nd_cell_path
    Set Test Variable  ${3rd_NRCELL_ID}  #${3rd_NRCELL_ID}
    Set Test Variable  ${3rd_NRCELL_DN}  #${3rd_NRCELL_DN}


Select Three Random NR Cells NSA
    Set Test Variable  ${1st_NRCELL_ID}  4
    Set Test Variable  ${1st_NRCELL_DN}  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-10817/NRCELL_R-4
    Set Test Variable  ${2nd_NRCELL_ID}  2
    Set Test Variable  ${2nd_NRCELL_DN}  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-10817/NRCELL_R-2
    Set Test Variable  ${3rd_NRCELL_ID}  56
    Set Test Variable  ${3rd_NRCELL_DN}  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-10817/NRCELL_R-56
    ${selected_cells_IDs}  Create List  ${1st_NRCELL_ID}  ${2nd_NRCELL_ID}    ${3rd_NRCELL_ID}
    Set Test Variable  ${selected_cells_IDs}
    ${selected_cells_DNs}  Create List  ${1st_NRCELL_DN}  ${2nd_NRCELL_DN}  ${3rd_NRCELL_DN}
    Set Test Variable  ${selected_cells_DNs}
#    [Documentation]  KW is used to select random cells from different RMODs if barring does not work for NSA NRCells
#    ${NRCELLS_R}  admin.get managed objects  NRCELL_R
#    Set Test Variable  ${NRCELLS_R}
#    ${other_cell_ids}  Create List
#    Set Test variable  ${other_cell_ids}
#    ${NR_cells}  admin.get parameters for all  NRCEL
#    @{cell}  Evaluate  random.sample(${NR_cells}, 1)  random
#    ${1st_NRCELL_ID}  ${1st_NRCELL_DN}  Get Id Of Selected Cell  ${cell}[0]
#    Set Test Variable  ${1st_NRCELL_ID}  #1st_cell_id
#    Set Test Variable  ${1st_NRCELL_DN}  #1st_cell_path
#    Get RMOD of 1st cell
#    Set Test Variable  ${1st_cell_RMOD}
#    Find NRCELLs on the same RMOD as 1st cell
#    FOR  ${NR_cell}  IN  @{NR_cells}
#        ${NR_cell_id}  Set variable  ${NR_cell['id']}
#        ${cell_id2}  Get matches   ${other_cell_ids}  ${NR_cell_id}
#        IF  ${cell_id2}!=[]  Remove Values From List  ${NR_cells}  ${NR_cell}
#        Set Test Variable  ${NR_cells}
#    END
#    Log to console  ${NR_cells}
#    @{cell}  Evaluate  random.sample(${NR_cells}, 1)  random
#    ${2nd_NRCELL_ID}  ${2nd_NRCELL_DN}  Get Id Of Selected Cell  ${cell}[0]
#    Set Test Variable  ${2nd_NRCELL_ID}  #2nd_cell_id
#    Set Test Variable  ${2nd_NRCELL_DN}  #2nd_cell_pathl


Select 2 Cells First NbIotInband
    [Documentation]  Selects one LTE cell hosting an NB-IoT inband deployment and one
    ...              random LTE cell that is not. Fails if this combination is not possible.

    Log to console    \n========================================
    Log  Selecting one NB-IoT Inband cell and one non-inband LTE cell.  console=${True}
    Log to console    ========================================

    # Step 1: Get all LTE cell data in a single operation
    ${all_lte_cells}=  admin.get parameters for all  LNCEL
    @{inband_cells}=      Create List
    @{non_inband_cells}=  Create List

    # Step 2: Iterate through the locally stored cell data to sort them
    FOR    ${cell}    IN    @{all_lte_cells}
        IF    '${cell.nbIoTMode}' == 'inband'
            Append To List  ${inband_cells}  ${cell}
        ELSE
            Append To List  ${non_inband_cells}  ${cell}
        END
    END

    # Step 3: Explicitly validate that both required cell types are available
    ${inband_count}=  Get Length  ${inband_cells}
    Run Keyword If  ${inband_count} == 0  Fail  msg=TEST SETUP ERROR: No LTE cells with nbIoTMode='inband' were found. Cannot select the first cell.

    ${non_inband_count}=  Get Length  ${non_inband_cells}
    Run Keyword If  ${non_inband_count} == 0  Fail  msg=TEST SETUP ERROR: No non-inband LTE cells were found. Cannot select a unique second cell.

    # Step 4: Select one cell from each list, guaranteeing uniqueness and the desired configuration
    ${1st_cell_object}=  Evaluate  random.choice(${inband_cells})      random
    ${2nd_cell_object}=  Evaluate  random.choice(${non_inband_cells})  random

    # Step 5: Extract IDs and DNs and set them as test variables
    ${1st_LNCEL_ID}  ${1st_LNCEL_DN}  Get Id Of Selected Cell  ${1st_cell_object}
    ${2nd_LNCEL_ID}  ${2nd_LNCEL_DN}  Get Id Of Selected Cell  ${2nd_cell_object}

    Set Test Variable  ${1st_LNCEL_ID}
    Set Test Variable  ${2nd_LNCEL_ID}
    Set Test Variable  ${1st_LNCEL_DN}
    Set Test Variable  ${2nd_LNCEL_DN}

    Log  Selected NB-IoT Inband Host Cell: ID=${1st_LNCEL_ID}, DN=${1st_LNCEL_DN}  console=${True}
    Log  Selected Non-Inband Cell: ID=${2nd_LNCEL_ID}, DN=${2nd_LNCEL_DN}  console=${True}


Get RMOD of 1st cell
    FOR  ${NRCELL_R}  IN  @{NRCELLS_R}
        ${Cell_R_name}  Get From Dictionary  ${NRCELL_R}  distName
        ${Cell_R_ID}  string.Split String  ${Cell_R_name}  NRCELL_R-
        ${1st_cell_RMOD}  IF  "${Cell_R_ID[1]}"=="${1st_NRCELL_ID}"  Get From Dictionary  ${NRCELL_R['parameters']}  frRefList
        IF  "${Cell_R_ID[1]}"=="${1st_NRCELL_ID}"
            Log to console  NRCELL-${1st_NRCELL_ID} is deployed on ${1st_cell_RMOD}
            Set Test Variable  ${1st_cell_RMOD}
        END
    END


Find NRCELLs on the same RMOD as 1st cell
    FOR  ${NRCELL_R}  IN  @{NRCELLS_R}
        ${RMOD_from_NRCELL_R}  Get From Dictionary  ${NRCELL_R['parameters']}  frRefList
        ${other_cell_id}  IF  "${RMOD_from_NRCELL_R}"=="${1st_cell_RMOD}"  Get From Dictionary  ${NRCELL_R}  distName
        Append to list  ${other_cell_ids}  ${other_cell_id}
    END


Select Random LTE Cell
    ${LTE_cells}  admin.get parameters for all  LNCEL
    @{cell}  Evaluate  random.sample(${LTE_cells}, 2)  random
    ${1st_LNCEL_ID}  ${1st_LNCEL_DN}  Get Id Of Selected Cell  ${cell}[0]
    Set Test Variable  ${1st_LNCEL_ID}  #1st_cell_id
    Set Test Variable  ${1st_LNCEL_DN}  #1st_cell_path


Select 19 LTE Cells For ReducedEnergySaving
    [Arguments]  ${LTE_cells}

    @{cells}  Evaluate  random.sample(${LTE_cells}, 19)  random
    @{RES_LTE_IDS}  Create List
    ${nr_of_cells}  Get Length  ${cells}
    FOR  ${index}  IN RANGE  ${nr_of_cells}
		${LNCEL_id}  Fetch From Right  ${cells}[${index}]  -
        Append To List  ${RES_LTE_IDS}  ${LNCEL_id}
    END

    RETURN  ${RES_LTE_IDS}


Select Random NR Cell
    ${1st_NRCELL_ID}  ${1st_NRCELL_DN}  Get Random Cell Id And Path  nr
    Set Test Variable  ${1st_NRCELL_DN}  #cell_path
    Set Test Variable  ${1st_NRCELL_ID}  #cell_id
#    RETURN  ${1st_NRCELL_ID}  ${1st_NRCELL_DN}


Select Random WCDMA Cell
    ${1st_WNCEL_ID}  ${1st_WNCEL_DN}  Get Random Cell Id And Path  wcdma
    Set Test Variable  ${1st_WNCEL_DN}
    Set Test Variable  ${1st_WNCEL_ID}


Select Random GSM Cell
    ${1st_GNCEL_ID}  ${1st_GNCEL_DN}  Get Random Cell Id And Path  gsm
    Set Test Variable  ${1st_GNCEL_DN}
    Set Test Variable  ${1st_GNCEL_ID}


Get Specified Duplex NRCEL List
    [Documentation]  Description: This keyword returns a list of all NRCELLs with the given ${duplex}
    [Arguments]  ${duplex}

    ${nrcels_param}  admin.Get Parameters For All  class_name=NRCEL
    ${nrcels}  Create List
    FOR  ${cell}  IN  @{nrcels_param}
        IF  '${cell['technology']}'=='${duplex}'  Append To List  ${nrcels}  ${cell['id']}
    END

    RETURN  ${nrcels}


Get NRCEL List Of Specified Duplex Under RMOD
    [Documentation]  This KW checks how many NRCELs of the specified duplex ${duplex} are found under a specific RMOD,
    ...  given via ${rmod_serial_number}, and returns a list comprised of the NRCELS found under that RMOD that satisfy the
    ...  ${duplex} condition.
    [Arguments]  ${rmod_sn}  ${duplex}

    ${TDD_RU_NRCELS}  Create List
    ${found_rmod_flag}  Set Variable  ${False}
    ${rmod_list}  admin.Get Frm
    FOR  ${rmod}  IN  @{rmod_list}
        ${rmod_serial_number}  Set Variable  ${rmod['serialNumber']}
        ${rmod_internal_id}  Set Variable  ${rmod['id']['internal']}
        ${found_rmod_flag}  Set Variable If  '${rmod_serial_number}'=='${rmod_sn}'  ${True}  ${False}
        IF  ${found_rmod_flag}
            ${TDD_RU_NRCELS}  Get Cell List Under RMOD  ${rmod_internal_id}
            BREAK
        END
    END
    IF  ${found_rmod_flag}==${False}  Fail  No RMOD with the serial number ${rmod_serial_number} was found. Test cannot continue\n
    ${nrcel_list}  admin.Get Parameters For All  class_name=NRCEL
    ${nrcels}  Create List
    FOR  ${cell}  IN  @{nrcel_list}
        ${nrcell_id}  Set Variable  ${cell['configurationId']}
        ${is_cell_in_list}  Run Keyword And Return Status
        ...  List Should Contain Value  ${TDD_RU_NRCELS}  ${nrcell_id}
        IF  '${cell['technology']}'=='${duplex}' and ${is_cell_in_list}
            Append To List  ${nrcels}  ${nrcell_id}
        END
    END

    RETURN  ${nrcels}


Check If LNCEL IoT Cells Exist Under RMOD
    [Documentation]  This KW checks if there is any IoT cell under the RMOD specified via RMOD internal id ${rmod_id}
    ...  and returns true if any IoT cell is found, false otherwise
    [Arguments]  ${rmod_id}

    ${rmod_cells}  Create List
    ${rmod_list}  admin.Get Frm
    FOR  ${rmod}  IN  @{rmod_list}
        ${rmod_internal_id}  Set Variable  ${rmod['id']['internal']}
        ${found_rmod_flag}  Set Variable If  '${rmod_internal_id}' == '${rmod_id}'  ${TRUE}  ${FALSE}
        IF  ${found_rmod_flag}
            ${rmod_cells}  Get Cell List Under RMOD  ${rmod_internal_id}
            BREAK
        END
    END
    IF  ${found_rmod_flag}==${FALSE}  Fail  No RMOD with the internal id ${rmod_internal_id} was found. Test cannot continue\n
    ${lncell_list}  admin.Get Parameters For All  class_name=LNCEL
    IF  not ${lncell_list}  Return from keyword  ${FALSE}
    ${lncells}  Create List
    FOR  ${lncell}  IN  @{lncell_list}
        ${cell_id}  Set Variable  ${lncell['id']}
        ${nb_iot_cell}  Set Variable  ${lncell['nbIoTCell']}
        ${is_iot_cell}  Set Variable If  ${nb_iot_cell} != None  ${TRUE}  ${FALSE}
        ${id}  Fetch From Right  ${cell_id}  -
        FOR  ${cell}  IN  @{rmod_cells}
            ${is_cell_in_list}  Set Variable If  '${cell}'=='${id}'  ${TRUE}  ${FALSE}
            IF  ${is_cell_in_list}  BREAK
        END
        IF  ${is_iot_cell} and ${is_cell_in_list}
            ${status}  Set Variable  ${TRUE}
            BREAK
        ELSE
            ${status}  Set Variable  ${FALSE}
        END
    END

    RETURN  ${status}


Set Voltage For RU Based On Serial Number
    [Documentation]  This KW uses multiple shell scripts of the form "up_volt_PS_<RU_SN>" and "low_volt_PS_<RU_SN>", found at
    ...  ${shell_file_path}, in order to either lower or raise the voltage that is going through the RU, given by ${ru_serial_number}.
    ...  Can take the values of either "LOWER", "RAISE", "SET_LOW_46" or "BASE" depending on the action required. The voltage values are established
    ...  in the shell scripts.
    [Arguments]  ${shell_file_path}  ${ru_serial_number}  ${operation}

    Log  Run shell script to ${operation} the voltage on RU ${ru_serial_number}\n  console=true
    IF  '${operation}'=='LOWER'
        ${file_path}  Catenate  SEPARATOR=  ${shell_file_path}  low_volt_PS_  ${ru_serial_number}  .sh
    ELSE IF  '${operation}'=='RAISE'
        ${file_path}  Catenate  SEPARATOR=  ${shell_file_path}  up_volt_PS_  ${ru_serial_number}  .sh
    ELSE IF  '${operation}'=='SET_LOW_46'
	    ${file_path}  Catenate  SEPARATOR=  ${shell_file_path}  low_volt_PS_  ${ru_serial_number}_  46V  .sh
    END
    ${result}  Run Process  bash  ${file_path}  shell=yes


Check Voltage For RU Based On RMOD Internal Name
    [Documentation]  This KW checks if the voltage value on an RU, based on its internal name ${ru_internal_name}, is
    ...  satisfying the ${comparison} with the ${expected_voltage_value}, which should be given as a real number (e.g. 50.0)
    [Arguments]  ${ru_internal_name}  ${comparison}  ${expected_voltage_value}

    ${rmod_measurements}  admin.Get Measurements  realTime
    FOR  ${rmod}  IN  @{rmod_measurements}
        ${keys}  Get Dictionary Keys  ${rmod}
        ${values}  Get Dictionary Values  ${rmod}
        ${voltage_checked}  Set Variable  ${False}
        ${status}  Run Keyword And Return Status  Should Contain  ${keys}[0]  ${ru_internal_name}
        ...  msg=The desired RU internal name could not be found.
        IF  ${status}
            ${ru_voltage}  Set Variable  ${values[0]['voltage']}
            IF  '${comparison}'=='LOWER_THAN'
                IF  ${ru_voltage}<${expected_voltage_value}
                    Log  The voltage on RU ${ru_internal_name} is as expected, ${comparison} ${expected_voltage_value}\n  console=true
                    ${voltage_checked}  Set Variable  ${True}
                    BREAK
                END
            ELSE IF  '${comparison}'=='GREATER_THAN'
                IF  ${ru_voltage}>${expected_voltage_value}
                    Log  The voltage on RU ${ru_internal_name} is as expected, ${comparison} ${expected_voltage_value}\n  console=true
                    ${voltage_checked}  Set Variable  ${True}
                    BREAK
                END
            END
            BREAK
        END
    END
    IF  not ${voltage_checked}
        Fail  Could not check the voltage value on RU ${ru_internal_name}. Please check manually!
    END


Change FEATCADM Parameter
    [Documentation]  KW to change any FEATCADM parameter
    [Arguments]  ${parameter}  ${value}  ${skip_parameter_relation_errors}=${TRUE}  ${timeout}=300

    Log  FEATCADM Parameter ${parameter} will be changed to ${value}.  console=true
    ${featcadm_object}  Query Infomodel  get object //FEATCADM_CONF_M-*
    ${actual_value}  Convert To String  ${featcadm_object}[${parameter}]
    ${actual_value}  Convert To Lowercase  ${actual_value}
    IF  '${actual_value}'=='${value}'
        Log  Parameter already has the requested value. Parameter change will be skipped.  console=true
        RETURN
    END
    Log  Current parameter value ${actual_value}.  console=true
    admin.Perform Parameter Recommissioning  dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1  parameter=${parameter}
    ...  operation=update  value=${value}  skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...  timeout=${timeout}


Get ${tdd_qty} TDD And ${fdd_qty} FDD Cells At Random
    [Documentation]  Description: This keyword returns a list comprised of a TDD and one FDD cell chosen randomly
    ...  Return: ${cell_list}

    ${tdd_nrcels}  Get Specified Duplex NRCEL List  duplex=TDD
    ${fdd_nrcels}  Get Specified Duplex NRCEL List  duplex=FDD
    ${tdd_nr}  Get Length  ${tdd_nrcels}
    ${fdd_nr}  Get Length  ${fdd_nrcels}
    IF  ${tdd_nr}<${tdd_qty}  Log  Requested TDD type NRCEL number is higher than existing TDD NRCEL cells in environment. Using max available\n
    ...  console=true
    ${tdd_qty}  Set Variable If  ${tdd_nr}<${tdd_qty}  ${tdd_nr}  ${tdd_qty}
    IF  ${fdd_nr}<${fdd_qty}  Log  Requested FDD type NRCEL number is higher than existing FDD NRCEL cells in environment. Using max available\n
    ...  console=true
    ${fdd_qty}  Set Variable If  ${fdd_nr}<${fdd_qty}  ${fdd_nr}  ${fdd_qty}
    ${tdd_random}  Evaluate  random.sample(${tdd_nrcels}, ${tdd_qty})  random
    ${fdd_random}  Evaluate  random.sample(${fdd_nrcels}, ${fdd_qty})  random
    ${cell_list}  Create List
    FOR  ${index}  IN RANGE  ${tdd_qty}
        Append To List  ${cell_list}  ${tdd_random}[${index}]
    END
    FOR  ${index}  IN RANGE  ${fdd_qty}
        Append To List  ${cell_list}  ${fdd_random}[${index}]
    END

    RETURN  ${cell_list}


Get ${tdd_qty} TDD And ${fdd_qty} FDD ${tehnology} Cells At Random
    [Documentation]  Description: This keyword returns a list comprised of a TDD and one FDD cell chosen randomly of the
    ...  selected tehnology.
    ...  Return: ${cell_list}

    ${tdd_cells}  Get Specified Duplex List  ${tehnology}  duplex=TDD
    ${fdd_cells}  Get Specified Duplex List  ${tehnology}  duplex=FDD
    ${tdd_nr}  Get Length  ${tdd_cells}
    ${fdd_nr}  Get Length  ${fdd_cells}
    IF  ${tdd_nr}<${tdd_qty}
        Log  Requested TDD type NRCEL number is higher than existing TDD NRCEL cells in environment. Using max available\n  console=true
    END
    ${tdd_qty}  Set Variable If  ${tdd_nr}<${tdd_qty}  ${tdd_nr}  ${tdd_qty}
    IF  ${fdd_nr}<${fdd_qty}
        Log  Requested FDD type NRCEL number is higher than existing FDD NRCEL cells in environment. Using max available\n  console=true
    END
    ${fdd_qty}  Set Variable If  ${fdd_nr}<${fdd_qty}  ${fdd_nr}  ${fdd_qty}
    ${tdd_random}  Evaluate  random.sample(${tdd_cells}, ${tdd_qty})  random
    ${fdd_random}  Evaluate  random.sample(${fdd_cells}, ${fdd_qty})  random
    ${cell_list}  Create List
    FOR  ${index}  IN RANGE  ${tdd_qty}
        Append To List  ${cell_list}  ${tdd_random}[${index}]
    END
    FOR  ${index}  IN RANGE  ${fdd_qty}
        Append To List  ${cell_list}  ${fdd_random}[${index}]
    END

    [Return]  ${cell_list}


Get Id Of Selected Cell
    [Documentation]  Return cell id (number) and its path.
    [Arguments]  ${cell}

    ${cellId}  Split String  ${cell['id']}  -

    RETURN  ${cellId[-1]}  ${cell['id']}


Get LNCEL List Without SingleTX And mMIMO
    ${LTE_cells}  admin.get parameters for all  LNCEL
	${cells}  Create List
	Log  Removing SingleTX cells  console=true
    FOR  ${LNCEL}  IN  @{LTE_cells}
        ${dlMimoMode}  Get From Dictionary  ${LNCEL}  dlMimoMode
        IF  '${dlMimoMode}'=='SingleTX'  Remove Values From List  ${LTE_cells}  ${LNCEL}
    END
	Log  Removing mMIMO cells  console=true
	FOR  ${LNCEL}  IN  @{LTE_cells}
        ${dlMimoMode}  Get From Dictionary  ${LNCEL}  dlMimoMode
        #IF  '${dlMimoMode}'=='Closed Loop MIMO (8x4)'  Remove Values From List  ${LTE_cells}  ${LNCEL}
		IF  '${dlMimoMode}'=='Dual Stream Beamforming'  Remove Values From List  ${LTE_cells}  ${LNCEL}
    END
    FOR  ${cell}  IN  @{LTE_cells}
        ${id}  Get From Dictionary  ${cell}  id
        Append To List  ${cells}  ${id}
    END
    Remove Values From List  ${cells}  ${1st_LNCEL_DN}

    RETURN  ${cells}


Get NRCEL List Without 2TX And mMIMO
    ${NR_cells}  admin.get parameters for all  NRCEL
	${cells}  Create List
	${cells_DN}  Create List
	Log  Removing SingleTX and 2TX cells  console=true
    FOR  ${NRCEL}  IN  @{NR_cells}
        ${dlMimoMode}  Get From Dictionary  ${NRCEL}  dlMimoMode

        ${string} =    Convert To String      ${dlMimoMode}
        ${dlMimoMode} =    Get Substring      ${string}    0    1

        IF  '${dlMimoMode}'!='4' and '${dlMimoMode}'!='8'   Remove Values From List  ${NR_cells}  ${NRCEL}
    END
	Log  Removing mMIMO cells  console=true
	FOR  ${NRCEL}  IN  @{NR_cells}
        ${dlMimoMode}  Get From Dictionary  ${NRCEL}  dlMimoMode
        IF  '${dlMimoMode}'=='Closed Loop MIMO (8x4)'  Remove Values From List  ${NR_cells}  ${NRCEL}
    END
    FOR  ${cell}  IN  @{NR_cells}
        ${id}  Get From Dictionary  ${cell}  id
        Append To List  ${cells_DN}  ${id}
    END
    ${nr_of_cells}  Get Length  ${cells_DN}
    FOR  ${i}  IN RANGE  ${nr_of_cells}
        ${split_for_id}=  Split String From Right  ${cells_DN[${i}]}  separator=/NRCELL_R-  max_split=1
        ${nrcell_R_Id}=  Get From List  ${split_for_id}  1
        Append To List  ${cells}  ${nrcell_R_Id}
    END
    #Remove Values From List  ${cells}  ${1st_NRCEL_DN}
    RETURN  ${cells}


Select Two Random LNCEL For ReducedEnergySanving
    [Arguments]  ${LTE_cells}

    @{REScell}  Evaluate  random.sample(${LTE_cells}, 2)  random
    ${1st_RES_LNCEL_ID}  Evaluate  re.search(r'LNCEL_R-(\\d+)','''${REScell}[0]''').group(1)  re
    ${2nd_RES_LNCEL_ID}  Evaluate  re.search(r'LNCEL_R-(\\d+)','''${REScell}[1]''').group(1)  re
    ${1st_RES_LNCEL_DN}  Set Variable  ${REScell}[0]
    ${2nd_RES_LNCEL_DN}  Set Variable  ${REScell}[1]

    RETURN  ${1st_RES_LNCEL_ID}  ${1st_RES_LNCEL_DN}  ${2nd_RES_LNCEL_ID}  ${2nd_RES_LNCEL_DN}


Select One Random LNCEL For ReducedEnergySanving
    [Arguments]  ${LTE_cells}

    @{REScell}  Evaluate  random.sample(${LTE_cells}, 1)  random
    ${1st_RES_LNCEL_ID}  Evaluate  re.search(r'LNCEL_R-(\\d+)','''${REScell}[0]''').group(1)  re
    ${1st_RES_LNCEL_DN}  Set Variable  ${REScell}[0]

    RETURN  ${1st_RES_LNCEL_ID}  ${1st_RES_LNCEL_DN}


Get Random Cell Id And Path
    [Arguments]  ${cell_technology}

    ${cells_list}  Get Cell List
    ${cells_list['cells']['lte']}  Ignore PowerSaving IoT Cells
    Set Suite Variable  ${cells_list}
    ${chosen}  Evaluate  random.choice(${cells_list['cells']['${cell_technology}']})  random
    ${cell_id}  Fetch From Right  ${chosen['id']['internal']}    -
    ${technology}  Evaluate  "${cell_technology}".upper()
#    Log   For ${technology} Cell ID:${cell_id} selected.   INFO   console=True

    RETURN  ${cell_id}  ${chosen['id']['internal']}


Ignore PowerSaving IoT Cells
    ${cells_list}  Get cell list
    FOR  ${cell}  IN  @{cells_list['cells']['lte']}
        ${technology}  Get from dictionary  ${cell}  technology
        IF  '${technology}'=='NB-IoT-FDD'  Remove Values From List  ${cells_list['cells']['lte']}  ${cell}
    END

    RETURN  ${cells_list['cells']['lte']}


Set Feature Under NRPGRP/PSGRP Object
    [Documentation]  Keyword sets indicated values for chosen parameters under NRPGRP object
    ...  Example of usage:
    ...  Set Feature Under NRPGRP Object  lbpsLoadCalcMethod  Max(G_N_combined, P)  NRPGRP
    [Arguments]  ${feature_flag}  ${value}  ${object_name}  ${group_dn}

    ${feature_flag_delta}  Set Variable  ${feature_flag}_${value}
    admin.create delta  ${feature_flag_delta}
    IF  '${object_name}'=='NRPGRP'
        Log  Set ${feature_flag} on ${value}  console=${true}
        admin.append parameter update to delta  ${group_dn}  ${feature_flag}  ${value}  ${feature_flag_delta}
    ELSE IF  '${object_name}'=='PSGRP'
        Log  Set ${feature_flag} on ${value}  console=${true}
         admin.append parameter update to delta  ${group_dn}  ${feature_flag}  ${value}  ${feature_flag_delta}
    END
    admin.get delta  ${feature_flag_delta}
    admin.save delta  ${RESULTS}/delta_${feature_flag}_${value}.json  ${feature_flag_delta}
    admin.perform delta recommissioning  ${RESULTS}/delta_${feature_flag}_${value}.json


Shift Time For PSGRP
    [Arguments]  ${duration}  ${PSGRP_DN}

    Get Time And Date With Minute Offset  5minutes  10minutes
    ${delta_create_psgrp}  Set Variable  psgrp_create
    admin.create delta  ${delta_create_psgrp}
    ${lbpsPeriodList}  Create Dictionary
    Set To Dictionary  ${lbpsPeriodList}  lbpsDayOfWeek=${day}
    Set To Dictionary  ${lbpsPeriodList}  lbpsDuration=${duration}
    Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeHour=${start_hour}
    Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeMinute=${start_minutes}
    Set To Dictionary  ${lbpsPeriodList}  lbpsSuspended=notSuspended
    admin.append complex item to delta  ${PSGRP_DN}  list_name=lbpsPeriodList  &{lbpsPeriodList}  delta_id=${delta_create_psgrp}
    Log  POWER SAVING PERIOD FOR PSGRP SHIFTED: ${start_hour}:${start_minutes}-${end_hour}:${end_minutes}  console=${true}
    admin.get delta  ${delta_create_psgrp}
    admin.save delta  ${RESULTS}/delta_psgrp_create.json  ${delta_create_psgrp}
    admin.perform delta recommissioning  ${RESULTS}/delta_psgrp_create.json  ${delta_create_psgrp}


Shift Time For NRPGRP
    [Arguments]  ${duration}  ${NRPGRP_DN}

    Get Time And Date With Minute Offset  5minutes
    ${delta_create_nrpgrp}  Set Variable  nrpgrp_create
    admin.create delta  ${delta_create_nrpgrp}
    ${lbpsPeriodList}  Create Dictionary
    Set To Dictionary  ${lbpsPeriodList}  lbpsDayOfWeek=${day}
    Set To Dictionary  ${lbpsPeriodList}  lbpsDuration=${duration}
    Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeHour=${start_hour}
    Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeMinute=${start_minutes}
    Set To Dictionary  ${lbpsPeriodList}  lbpsSuspended=notSuspended
    admin.append complex item to delta  ${NRPGRP_DN}  list_name=lbpsPeriodList  &{lbpsPeriodList}  delta_id=${delta_create_nrpgrp}
    admin.get delta  ${delta_create_nrpgrp}
    admin.save delta  ${RESULTS}/delta_nrpgrp_create.json  ${delta_create_nrpgrp}
    admin.perform delta recommissioning  ${RESULTS}/delta_nrpgrp_create.json  ${delta_create_nrpgrp}


Create And Activate PSGRP For CB008745
    [Documentation]
    ...  **Example of simple usage:**
    ...  Create And Activate PSGRP For CB008745  ${1st_LNCEL_DN}  ${2nd_LNCEL_DN}  PSGRP-11  25min
    ...
    [Arguments]  ${1st_LNCELdistName}  ${2nd_LNCELdistName}  ${PSGRP-ID}  ${lbpsDuration}

    ${1st_LNCELid}  Evaluate  re.search(r'LNCEL_R-(\\d+)','''${1st_LNCELdistName}''').group(1)  re
    ${2nd_LNCELid}  Evaluate  re.search(r'LNCEL_R-(\\d+)','''${2nd_LNCELdistName}''').group(1)  re
    ${selected_cells_IDs}  Create List  ${1st_LNCELid}  ${2nd_LNCELid}
    ${delta_create_psgrp}  Set Variable  psgrp_create
    ${PSGRP_DN}  Set Variable  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}
    ${sw_splited}  Split String  ${active_sw_version}  _
    ${sw_prefix}  Get From List  ${sw_splited}  0
    Set Test Variable  ${sw_prefix}
    admin.create delta  ${delta_create_psgrp}
    admin.append managed object to delta  ${PSGRP_DN}  create  ${delta_create_psgrp}
    admin.append parameter update to delta  ${PSGRP_DN}  lbpsCSONCtlEnabled  false  ${delta_create_psgrp}
    admin.append parameter update to delta  ${PSGRP_DN}  lbpsLastCellMinLoad  4  ${delta_create_psgrp}		#old value:10
    admin.append parameter update to delta  ${PSGRP_DN}  lbpsLastCellRTXMinLoad  2  ${delta_create_psgrp}		#old value:20
    admin.append parameter update to delta  ${PSGRP_DN}  lbpsLastCellSOEnabled  false  ${delta_create_psgrp}
    admin.append parameter update to delta  ${PSGRP_DN}  lbpsLoadCalcMethod  Max(G, W, P)  ${delta_create_psgrp}
    admin.append parameter update to delta  ${PSGRP_DN}  lbpsMaxLoad  6  ${delta_create_psgrp}		#old value:20
    admin.append parameter update to delta  ${PSGRP_DN}  lbpsMinLoad  6  ${delta_create_psgrp}		#old value:15
    admin.append parameter update to delta  ${PSGRP_DN}  lbpsMonWinForCellSOff  60  ${delta_create_psgrp}
    IF  '${sw_prefix}'=='SBTS24R3'
        admin.append parameter update to delta  ${PSGRP_DN}  lbpsMonWinForCellSOn  30  ${delta_create_psgrp}
    ELSE
        admin.append parameter update to delta  ${PSGRP_DN}  lbpsMonWinForCellSOn  60  ${delta_create_psgrp}
    END
    admin.append parameter update to delta  ${PSGRP_DN}  lbpsMonWinForRtxSOff  120  ${delta_create_psgrp}		#old value:60
    admin.append parameter update to delta  ${PSGRP_DN}  lbpsMonWinForRtxSOn  60  ${delta_create_psgrp}
    admin.append parameter update to delta  ${PSGRP_DN}  lbpsSOffTrRule  MaxValueMethod  ${delta_create_psgrp}
    admin.append parameter update to delta  ${PSGRP_DN}  lbpsPdcchLoadOffset  1  ${delta_create_psgrp}		#old value:1
    admin.append parameter update to delta  ${PSGRP_DN}  lbpsSOnTrRule  SlidingAverageMethod  ${delta_create_psgrp}
    admin.append parameter update to delta  ${PSGRP_DN}  lbpsRTXCellCapOffset  50  ${delta_create_psgrp}		#old value:80
    admin.append parameter update to delta  ${PSGRP_DN}  lbpsRTXMaxLoad  8  ${delta_create_psgrp}		#nomNumPrbNonGbr=10
    admin.append parameter update to delta  ${PSGRP_DN}  lbpsRTXMinLoad  6  ${delta_create_psgrp}		#old value:20
    ${sw_splited}  Split String  ${active_sw_version}  _
    ${sw_prefix}  Get From List  ${sw_splited}  0
    Set Test Variable  ${sw_prefix}
    IF  '${if_actCo4g5g}'=='PASS' and '${sw_prefix}'!='SBTS23R2'
        admin.append parameter update to delta  ${PSGRP_DN}  lbpsGuardTimerNrAct  20  ${delta_create_psgrp}
        admin.append parameter update to delta  ${PSGRP_DN}  lbpsMaxLoadNrAct  40  ${delta_create_psgrp}
        admin.append parameter update to delta  ${PSGRP_DN}  lbpsMinNumEndcCapUeNrAct  0  ${delta_create_psgrp}
        admin.append parameter update to delta  ${PSGRP_DN}  lbpsMonWinNrAct  5  ${delta_create_psgrp}
        admin.append parameter update to delta  ${PSGRP_DN}  lbpsRetryTimerNrAct  5  ${delta_create_psgrp}
    END
    ${actMixedSOMethod_state}  Check parameter availability under LNBTS    actMixedSOMethod
    IF  '${actMixedSOMethod_state}'=='PASS'  admin.append parameter update to delta  ${PSGRP_DN}  lbpsSOMethod
    ...  Legacy Mixed Switch Off  ${delta_create_psgrp}
    ${lbpsCellList}  Create Dictionary
    ${item}  Create List  1  2
    FOR  ${i}  ${cell}  IN ZIP  ${item}  ${selected_cells_IDs}
        Set To Dictionary  ${lbpsCellList}  lbpsUseExtConfig  false
        Set To Dictionary  ${lbpsCellList}  lbpsCellSOOrder=${i}
        Set To Dictionary  ${lbpsCellList}  lnCelId=${cell}
        admin.append complex item to delta  ${PSGRP_DN}  list_name=lbpsCellList  &{lbpsCellList}  delta_id=${delta_create_psgrp}
    END
    Get Time And Date With Minute Offset  4minutes
    ${lbpsPeriodList}  Create Dictionary
    Set To Dictionary  ${lbpsPeriodList}  lbpsDayOfWeek=${day}
    ${lbpsDuration}  Get Regexp Matches  ${lbpsDuration}  \\d+
    Set To Dictionary  ${lbpsPeriodList}  lbpsDuration=${lbpsDuration[0]}
    Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeHour=${start_hour}
    Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeMinute=${start_minutes}
    Set To Dictionary  ${lbpsPeriodList}  lbpsSuspended=notSuspended
    admin.append complex item to delta  ${PSGRP_DN}  list_name=lbpsPeriodList  &{lbpsPeriodList}  delta_id=${delta_create_psgrp}
    admin.get delta  ${delta_create_psgrp}
    admin.save delta  ${RESULTS}/delta_create_psgrp_${PSGRP-ID}_LTE1103.json  ${delta_create_psgrp}
    Log  Activate Power Saving Group under MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  console=${true}
    admin.perform delta recommissioning  ${RESULTS}/delta_create_psgrp_${PSGRP-ID}_LTE1103.json  ${delta_create_psgrp}
    ${end_time}  Add Time To Date  ${time_with_offset}  ${lbpsDuration[0]} minutes
    ${end_hour}  Convert Date  ${end_time}  result_format=%H
    ${end_minutes}  Convert Date  ${end_time}  result_format=%M
    Log  Power Saving Group time frame: ${start_hour}:${start_minutes}-${end_hour}:${end_minutes} (+${lbpsDuration[0]} minutes)  console=${true}
    Log  Affected cells in ${PSGRP-ID}: LNCEL_R-${1stLNCELid} and LNCEL_R-${2ndLNCELid}  console=${true}


Create And Activate NRPGRP For CB008745
    [Documentation]
    ...  Creates and activates NRGRP.
    ...  Demands ${cell_order}  ${selected_cells}
    [Arguments]  ${NRPGRP-ID}  ${lbpsDuration}  ${lastCellPs}=false  ${feature}='CB008745'

    ${delta_create_nrpgrp}  Set Variable  nrpgrp_create
    ${NRPGRP_DN}  Set Variable  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-${NRPGRP-ID}
    ${sw_splited}  Split String  ${active_sw_version}  _
    ${sw_prefix}  Get From List  ${sw_splited}  0
    Set Test Variable  ${sw_prefix}
    admin.create delta  ${delta_create_nrpgrp}
    admin.append managed object to delta  ${NRPGRP_DN}  create  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsCSONCtlEnabled  false  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsLastCellMinLoad  2  ${delta_create_nrpgrp}
    IF  '${lastCellPs}'=='true'
        admin.append parameter update to delta  ${NRPGRP_DN}  lbpsLastCellSOEnabled  true  ${delta_create_nrpgrp}
    ELSE
        admin.append parameter update to delta  ${NRPGRP_DN}  lbpsLastCellSOEnabled  false  ${delta_create_nrpgrp}
    END
#    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsLoadCalcMethod  Max(G, C, P)  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsLoadCalcMethod  Max(G_N_combined, P)  ${delta_create_nrpgrp}
#    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsMaxLoad  30  ${delta_create_nrpgrp}
#    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsMinLoad  20  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsMaxLoad  10  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsMinLoad  8  ${delta_create_nrpgrp}
#    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsMonWinForCellSOff  60  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsMonWinForCellSOff  120  ${delta_create_nrpgrp}
    IF  '${sw_prefix}'=='SBTS24R3'
        admin.append parameter update to delta  ${NRPGRP_DN}  lbpsMonWinForCellSOn  60  ${delta_create_nrpgrp}
#    ELSE  admin.append parameter update to delta  ${NRPGRP_DN}  lbpsMonWinForCellSOn  60  ${delta_create_nrpgrp}
    ELSE
        admin.append parameter update to delta  ${NRPGRP_DN}  lbpsMonWinForCellSOn  120  ${delta_create_nrpgrp}
    END
#    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsSOffTrRule  MaxValueMethod  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsSOffTrRule  SlidingAverageMethod  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsPdcchLoadOffset  4  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsSOMethod  cell switch off  ${delta_create_nrpgrp}
#    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsSOnTrRule  SlidingAverageMethod  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsSOnTrRule  MinValueMethod  ${delta_create_nrpgrp}
    ${lbpsCellList}  Create Dictionary
    IF  "${feature}" == "CB009176"
        ${item}  Create List  1
    ELSE
        ${item}  Create List  1  2  3
    END
    FOR  ${i}  ${cell}  IN ZIP  ${item}  ${selected_cells_IDs}
        Set To Dictionary  ${lbpsCellList}  lbpsCellSOOrder=${i}
        Set To Dictionary  ${lbpsCellList}  nrCellId=${cell}
        IF  '${if_actNrExtCellSOMethod}'=='PASS'  Set To Dictionary  ${lbpsCellList}  lbpsUseExtConfig  false
        admin.append complex item to delta  ${NRPGRP_DN}  list_name=lbpsCellList  &{lbpsCellList}  delta_id=${delta_create_nrpgrp}
    END
    Get Time And Date With Minute Offset  4minutes  5minutes
    ${lbpsPeriodList}  Create Dictionary
    Set To Dictionary  ${lbpsPeriodList}  lbpsDayOfWeek=${day}
    ${lbpsDuration}  Get Regexp Matches  ${lbpsDuration}  \\d+
    Set To Dictionary  ${lbpsPeriodList}  lbpsDuration=${lbpsDuration[0]}
    Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeHour=${start_hour}
    Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeMinute=${start_minutes}
    Set To Dictionary  ${lbpsPeriodList}  lbpsSuspended=notSuspended
    admin.append complex item to delta  ${NRPGRP_DN}  list_name=lbpsPeriodList  &{lbpsPeriodList}  delta_id=${delta_create_nrpgrp}
    ${end_time}  Add Time To Date  ${time_with_offset}  ${lbpsDuration[0]} minutes
    ${end_hour}  Convert Date  ${end_time}  result_format=%H
    ${end_minutes}  Convert Date  ${end_time}  result_format=%M
    Log  Power Saving Group time frame: ${start_hour}:${start_minutes}-${end_hour}:${end_minutes} (+${lbpsDuration[0]} minutes)  console=${true}
    admin.append complex item to delta  ${NRPGRP_DN}  list_name=lbpsPeriodList  &{lbpsPeriodList}  delta_id=${delta_create_nrpgrp}
    admin.get delta  ${delta_create_nrpgrp}
    admin.save delta  ${RESULTS}/delta_create_nrpgrp_CB008745.json  ${delta_create_nrpgrp}
    Log  Activate Power Saving Group under ${NRPGRP_DN}  console=${true}
    admin.perform delta recommissioning  ${RESULTS}/delta_create_nrpgrp_CB008745.json  ${delta_create_nrpgrp}


Create And Activate PSGRP For LTE1103
    [Documentation]
    ...  **Example of simple usage:**
    ...  Create And Activate PSGRP For LTE1103  ${1st_LNCEL_DN}  ${2nd_LNCEL_DN}  PSGRP-11  25min
    ...
    [Arguments]  ${1st_LNCELdistName}  ${2nd_LNCELdistName}  ${PSGRP-ID}  ${lbpsDuration}

    ${1st_LNCELid}  Evaluate  re.search(r'LNCEL_R-(\\d+)','''${1st_LNCELdistName}''').group(1)  re
    ${2nd_LNCELid}  Evaluate  re.search(r'LNCEL_R-(\\d+)','''${2nd_LNCELdistName}''').group(1)  re
    ${selected_cells_IDs}  Create List  ${1st_LNCELid}  ${2nd_LNCELid}
    ${delta_create_psgrp}  Set Variable  psgrp_create
    ${PSGRP_DN}  Set Variable  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}
    admin.create delta  ${delta_create_psgrp}
    admin.append managed object to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  create  ${delta_create_psgrp}
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  lbpsCSONCtlEnabled  false  ${delta_create_psgrp}
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  lbpsLastCellMinLoad  0  ${delta_create_psgrp}
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  lbpsLastCellRTXMinLoad  0  ${delta_create_psgrp}
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  lbpsLastCellSOEnabled  true  ${delta_create_psgrp}
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  lbpsMaxLoad  100  ${delta_create_psgrp}
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  lbpsMinLoad  0  ${delta_create_psgrp}
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  lbpsPdcchLoadOffset  4  ${delta_create_psgrp}
    ${sw_splited}  Split String  ${active_sw_version}  _
    ${sw_prefix}  Get From List  ${sw_splited}  0
    Set Test Variable  ${sw_prefix}
    IF  '${sw_prefix}'!='SBTS23R2'
        admin.append parameter update to delta  ${PSGRP_DN}  lbpsGuardTimerNrAct  20  ${delta_create_psgrp}
        admin.append parameter update to delta  ${PSGRP_DN}  lbpsMaxLoadNrAct  40  ${delta_create_psgrp}
        admin.append parameter update to delta  ${PSGRP_DN}  lbpsMinNumEndcCapUeNrAct  0  ${delta_create_psgrp}
        admin.append parameter update to delta  ${PSGRP_DN}  lbpsMonWinNrAct  5  ${delta_create_psgrp}
        admin.append parameter update to delta  ${PSGRP_DN}  lbpsRetryTimerNrAct  5  ${delta_create_psgrp}
    END
    ${actMixedSOMethod_state}  Check parameter availability under LNBTS  actMixedSOMethod
    admin.append parameter update to delta  ${PSGRP_DN}  lbpsSOMethod
    ...  Legacy Mixed Switch Off  ${delta_create_psgrp}
    ${lbpsCellList}  Create Dictionary
    ${item}  Create List  1  2
    FOR  ${i}  ${cell}  IN ZIP  ${item}  ${selected_cells_IDs}
        IF  '${if_actExtCellSOMethod}'=='PASS'  Set To Dictionary  ${lbpsCellList}  lbpsUseExtConfig  false
        Set To Dictionary  ${lbpsCellList}  lbpsCellSOOrder=${i}
        Set To Dictionary  ${lbpsCellList}  lnCelId=${cell}
		Set To Dictionary  ${lbpsCellList}  lbpsUseExtConfig=false
        admin.append complex item to delta  ${PSGRP_DN}  list_name=lbpsCellList  &{lbpsCellList}  delta_id=${delta_create_psgrp}
    END
    Get Time And Date With Minute Offset  3minutes
    ${lbpsPeriodList}  Create Dictionary
    Set To Dictionary  ${lbpsPeriodList}  lbpsDayOfWeek=${day}
    ${lbpsDuration}  Get Regexp Matches  ${lbpsDuration}  \\d+
    Set To Dictionary  ${lbpsPeriodList}  lbpsDuration=${lbpsDuration[0]}
    Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeHour=${start_hour}
    Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeMinute=${start_minutes}
    Set To Dictionary  ${lbpsPeriodList}  lbpsSuspended=notSuspended
    admin.append complex item to delta  ${PSGRP_DN}  list_name=lbpsPeriodList  &{lbpsPeriodList}  delta_id=${delta_create_psgrp}
    admin.get delta  ${delta_create_psgrp}
    admin.save delta  ${RESULTS}/delta_create_psgrp_${PSGRP-ID}_LTE1103.json  ${delta_create_psgrp}
    Log  Activate Power Saving Group under MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  console=${true}
    admin.perform delta recommissioning  ${RESULTS}/delta_create_psgrp_${PSGRP-ID}_LTE1103.json  ${delta_create_psgrp}
    ${end_time}  Add Time To Date  ${time_with_offset}  ${lbpsDuration[0]} minutes
    ${end_hour}  Convert Date  ${end_time}  result_format=%H
    ${end_minutes}  Convert Date  ${end_time}  result_format=%M
    Log  Power Saving Group time frame: ${start_hour}:${start_minutes}-${end_hour}:${end_minutes} (+${lbpsDuration[0]} minutes)  console=${true}
    Log  Affected cells in ${PSGRP-ID}: LNCEL_R-${1stLNCELid} and LNCEL_R-${2ndLNCELid}  console=${true}


Create And Activate PSGRPs
    [Documentation]  This keyword creates and activates ${psgrp_nr} PSGRPs containing one cell each, for ReducedEnergySaving
    ...  setting the reduced energy saving time window to ${lbps_duration} minutes. ${psgrp_nr} should be equal with Get Length  ${cell_ids}
    ...  Usage example: Create And Activate PSGRPs  ${psgrp_nr}  ${cell_ids}  ${lbps_duration}
    [Arguments]  ${psgrp_nr}  ${cell_ids}  ${lbps_duration}

    ${nr_of_ids}  Get Length  ${cell_ids}
    Should Be Equal As Integers  ${nr_of_ids}  ${psgrp_nr}  The number of PSGRPs is not equal to the number of cell IDs
    Get Time And Date With Minute Offset  5minutes
    FOR  ${i}  IN RANGE  1  ${psgrp_nr} + 1
        ${delta_create_psgrp}  Set Variable  psgrp_create
        ${PSGRP_DN}  Set Variable  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/PSGRP-${i}
        admin.create delta  ${delta_create_psgrp}
        admin.append managed object to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/PSGRP-${i}  create  ${delta_create_psgrp}
        admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/PSGRP-${i}  lbpsCSONCtlEnabled  false  ${delta_create_psgrp}
        admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/PSGRP-${i}  lbpsLastCellMinLoad  0  ${delta_create_psgrp}
        admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/PSGRP-${i}  lbpsLastCellRTXMinLoad  0  ${delta_create_psgrp}
        admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/PSGRP-${i}  lbpsLastCellSOEnabled  true  ${delta_create_psgrp}
        admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/PSGRP-${i}  lbpsMaxLoad  100  ${delta_create_psgrp}
        admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/PSGRP-${i}  lbpsMinLoad  0  ${delta_create_psgrp}
        admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/PSGRP-${i}  lbpsRTXMaxLoad  45  ${delta_create_psgrp}
        admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/PSGRP-${i}  lbpsRTXMinLoad  20  ${delta_create_psgrp}
        admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/PSGRP-${i}  lbpsPdcchLoadOffset  4  ${delta_create_psgrp}
        ${sw_splited}  Split String  ${active_sw_version}  _
        ${sw_prefix}  Get From List  ${sw_splited}  0
        IF  '${IF_ACTCO4G5G}'=='PASS' and '${sw_prefix}'!='SBTS23R2'
            admin.append parameter update to delta  ${PSGRP_DN}  lbpsGuardTimerNrAct  20  ${delta_create_psgrp}
            admin.append parameter update to delta  ${PSGRP_DN}  lbpsMaxLoadNrAct  40  ${delta_create_psgrp}
            admin.append parameter update to delta  ${PSGRP_DN}  lbpsMinNumEndcCapUeNrAct  0  ${delta_create_psgrp}
            admin.append parameter update to delta  ${PSGRP_DN}  lbpsMonWinNrAct  5  ${delta_create_psgrp}
            admin.append parameter update to delta  ${PSGRP_DN}  lbpsRetryTimerNrAct  5  ${delta_create_psgrp}
        END
        ${actMixedSOMethod_state}  Check parameter availability under LNBTS  actMixedSOMethod
        IF  '${actMixedSOMethod_state}'=='PASS'  admin.append parameter update to delta  ${PSGRP_DN}  lbpsSOMethod
        ...  Legacy Mixed Switch Off  ${delta_create_psgrp}
        ${lbpsCellList}  Create Dictionary
        IF  '${IF_ACTEXTCELLSOMETHOD}'=='PASS'  Set To Dictionary  ${lbpsCellList}  lbpsUseExtConfig  false
        Set To Dictionary  ${lbpsCellList}  lbpsCellSOOrder=100
        ${index}  Evaluate  ${i}-1
        Set To Dictionary  ${lbpsCellList}  lnCelId=${cell_ids}[${index}]
        admin.append complex item to delta  ${PSGRP_DN}  list_name=lbpsCellList  &{lbpsCellList}  delta_id=${delta_create_psgrp}
        ${lbpsPeriodList}  Create Dictionary
        Set To Dictionary  ${lbpsPeriodList}  lbpsDayOfWeek=${day}
        Set To Dictionary  ${lbpsPeriodList}  lbpsDuration=${lbps_duration}
        Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeHour=${start_hour}
        Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeMinute=${start_minutes}
        Set To Dictionary  ${lbpsPeriodList}  lbpsSuspended=notSuspended
        admin.append complex item to delta  ${PSGRP_DN}  list_name=lbpsPeriodList  &{lbpsPeriodList}  delta_id=${delta_create_psgrp}
        admin.get delta  ${delta_create_psgrp}
        admin.save delta  ${RESULTS}/delta_create_psgrp_${i}_LTE1203.json  ${delta_create_psgrp}
        Log  Activate Power Saving Group under MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/PSGRP-${i}  console=true
        admin.perform delta recommissioning  ${RESULTS}/delta_create_psgrp_${i}_LTE1203.json  ${delta_create_psgrp}
        ${end_time}  Add Time To Date  ${time_with_offset}  ${lbps_duration} minutes
        ${end_hour}  Convert Date  ${end_time}  result_format=%H
        ${end_minutes}  Convert Date  ${end_time}  result_format=%M
        ${index}  Evaluate  ${i}-1
        Log  Power Saving Group time frame: ${start_hour}:${start_minutes}-${end_hour}:${end_minutes} (+${lbps_duration} minutes)  console=true
        Log  Affected cells in PSGRP${i}:  console=true
        Log  - Reduced Energy Saving: LNCEL_R-${cell_ids}[${index}]  console=true
    END


Create And Activate PSGRP
    [Documentation]  This KW creates a PSGRP based on the parameters provided. This KW takes a variable number of parameters.
    ...  The first parameter is the PSGRP ID ${psgrp_id} and after that comes a series of dictionaries containing the configuring
    ...  parameters for the PSGRP. Each dictionary should have a key-value pair consisting of the name of the list of parameters
    ...  they are configuring, or, if it contains the standalone parameters, the name of that dictionary should be 'standalone'.
    [Arguments]  ${psgrp_id}  @{parameters}

    ${delta_create_psgrp}  Set Variable  psgrp_create
    ${psgrp_dn}  Set Variable  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/PSGRP-${psgrp_id}
    admin.Create Delta  ${delta_create_psgrp}
    admin.Append Managed Object To Delta  ${psgrp_dn}  create  ${delta_create_psgrp}
    Append Items And Parameters To Delta  ${psgrp_dn}  ${delta_create_psgrp}  @{parameters}
    admin.Get Delta  ${delta_create_psgrp}
    admin.Save Delta  ${RESULTS}/delta_create_psgrp_${psgrp_id}.json  ${delta_create_psgrp}
    Log  Activate Power Saving Group under ${psgrp_dn}  console=true
    admin.Perform Delta Recommissioning  ${RESULTS}/delta_create_psgrp_${psgrp_id}.json  ${delta_create_psgrp}
    ${end_time}  Add Time To Date  ${time_with_offset}  ${switch_off_duration} minutes
    ${end_hour}  Convert Date  ${end_time}  result_format=%H
    ${end_minutes}  Convert Date  ${end_time}  result_format=%M
    Set Test Variable  ${TIME_WITH_OFFSET_PSGRP}  ${time_with_offset}
    Set Test Variable  ${END_TIME_PSGRP}  ${end_time}


Reconfigure Energy Saving Group
    [Arguments]  ${group_type}  ${group_id}  @{parameters}

    IF  '${group_type}'=='PSGRP'
        ${grp_dn}  Set Variable  MRBTS-${MRBTS_ID}/LNBTS-${LNBTS_ID}/${group_type}-${group_id}
    ELSE IF  '${group_type}'=='NRPGRP'
        ${grp_dn}  Set Variable  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/${group_type}-${group_id}
    ELSE
        Fail  Unknown group type given! Reconfiguration not possible!\n
    END
    ${delta_reconfig_grp}  Set Variable  delta_reconfig_${group_type}
    admin.Create Delta  ${delta_reconfig_grp}
    Append Items And Parameters To Delta  ${grp_dn}  ${delta_reconfig_grp}  @{parameters}
    admin.Get Delta  ${delta_reconfig_grp}
    admin.Save Delta  ${RESULTS}/delta_reconfig_${group_type}-${group_id}.json  ${delta_reconfig_grp}
    Log  Reconfiguring Power Saving Group under ${grp_dn}  console=true
    admin.Perform Delta Recommissioning  ${RESULTS}/delta_reconfig_${group_type}-${group_id}.json  ${delta_reconfig_grp}


Append Items And Parameters To Delta
    [Documentation]  This KW takes a list of items consisting of dictionaries and lists of dictionaries that represent parameters
    ...  that can/should be configured when creating or updating an energy saving group (PSGRP/NRPGRP) and updates the delta plan.
    ...  It also take the DistName of the group and also the delta id for the operation in cause (creating/reconfiguring PSGRP/NRPGRP)
    [Arguments]  ${group_dn}  ${delta_id}  @{parameters}

    FOR  ${param}  IN  @{parameters}
        ${param_type}  Get Variable Type  ${param}
        IF  '${param_type}'=='list'
            FOR  ${dict}  IN  @{param}
                ${status}  Run Keyword And Return Status  Dictionary Should Contain Key  ${dict}  name
                IF  ${status}
                    ${dict_name}  Get From Dictionary  ${dict}  name
                    Remove From Dictionary  ${dict}  name
                    admin.Append Complex Item To Delta  ${group_dn}  list_name=${dict_name}  &{dict}  delta_id=${delta_id}
                END
            END
        ELSE IF  '${param_type}'=='dict'
            ${status}  Run Keyword And Return Status  Dictionary Should Contain Key  ${param}  name
            IF  ${status}
                ${dict_name}  Get From Dictionary  ${param}  name
                Remove From Dictionary  ${param}  name
                IF  '${dict_name}'=='standalone'
                    FOR  ${key}  IN  @{param.keys()}
                        admin.Append Parameter Update To Delta  ${group_dn}  ${key}  ${param["${key}"]}  ${delta_id}
                    END
                ELSE
                    admin.Append Complex Item To Delta  ${group_dn}  list_name=${dict_name}  &{param}  delta_id=${delta_id}
                END
            END
        END
    END



Create And Activate NRPGRP
    [Documentation]  This KW creates a NRPGRP based on the parameters provided. This KW takes a variable number of parameters.
    ...  The first parameter is the NRPGRP ID ${nrpgrp_id} and after that comes a series of dictionaries containing the configuring
    ...  parameters for the NRPGRP. Each dictionary should have a key-value pair consisting of the name of the list of parameters
    ...  they are configuring, or, if it contains the standalone parameters, the name of that dictionary should be 'standalone'.
    [Arguments]  ${nrpgrp_id}  @{parameters}

    ${nrpgrp_dn}  Set Variable  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-${nrpgrp_id}
    ${delta_create_nrpgrp}  Set Variable  nrpgrp_create
    admin.Create Delta  ${delta_create_nrpgrp}
    admin.Append Managed Object To Delta  ${nrpgrp_dn}  create  ${delta_create_nrpgrp}
    Append Items And Parameters To Delta  ${nrpgrp_dn}  ${delta_create_nrpgrp}  @{parameters}
    admin.Get Delta  ${delta_create_nrpgrp}
    admin.Save Delta  ${RESULTS}/delta_create_nrpgrp_${nrpgrp_id}.json  ${delta_create_nrpgrp}
    Log  Activate NRPGRP under ${nrpgrp_dn}  console=true
    admin.Perform Delta Recommissioning  ${RESULTS}/delta_create_nrpgrp_${nrpgrp_id}.json  ${delta_create_nrpgrp}
    ${end_time}  Add Time To Date  ${time_with_offset}  ${switch_off_duration} minutes
    ${end_hour}  Convert Date  ${end_time}  result_format=%H
    ${end_minutes}  Convert Date  ${end_time}  result_format=%M
    Set Test Variable  ${TIME_WITH_OFFSET_NRPGRP}  ${time_with_offset}
    Set Test Variable  ${END_TIME_NRPGRP}  ${end_time}


Create And Activate FSOPSGRP
    [Documentation]  This KW creates a FSOPSGRP based on the parameters provided. This KW takes a variable number of parameters.
    ...  The first parameter is the list of LNCELS ${cell_list}, then FSOPSGRP ID ${fsopsgrp_id} and after that comes a series of
    ...  dictionaries containing the configuring parameters for the FSOPSGRP. Each dictionary should have a key-value pair
    ...  consisting of the name of the list of parameters they are configuring, or, if it contains the standalone parameters,
    ...  the name of that dictionary should be 'standalone'.
    [Arguments]  ${cell_list}  ${fsopsgrp_id}  @{parameters}

    ${delta_create_fsopsgrp}  Set Variable  fsopsgrp_create
    ${fsopsgrp_dn}  Set Variable  MRBTS-${MRBTS_ID}/LNBTS-${LNBTS_ID}/FSOPSGRP-${fsopsgrp_id}
    admin.Create Delta  ${delta_create_fsopsgrp}
    admin.Append Managed Object To Delta  ${fsopsgrp_dn}  create  ${delta_create_fsopsgrp}
    FOR  ${dict}  IN  @{parameters}
        ${status}  Run Keyword And Return Status  Dictionary Should Contain Key  ${dict}  name
        IF  ${status}
            ${dict_name}  Get From Dictionary  ${dict}  name
            Remove From Dictionary  ${dict}  name
        END
        IF  '${dict_name}'=='standalone'
            FOR  ${key}  IN  @{dict.keys()}
                admin.Append Parameter Update To Delta  ${fsopsgrp_dn}  ${key}  ${dict["${key}"]}  ${delta_create_fsopsgrp}
            END
        ELSE
            admin.Append Complex Item To Delta  ${fsopsgrp_dn}  list_name=${dict_name}  &{dict}  delta_id=${delta_create_fsopsgrp}
        END
    END
    admin.Append List Items To Delta  ${fsopsgrp_dn}  lnCelIdList  @{cell_list}  delta_id=${delta_create_fsopsgrp}
    admin.Get Delta  ${delta_create_fsopsgrp}
    admin.Save Delta  ${RESULTS}/delta_create_fsopsgrp_${fsopsgrp_id}.json  ${delta_create_fsopsgrp}
    Log  Activate FSOPSGRP under ${fsopsgrp_dn}  console=true
    admin.Perform Delta Recommissioning  ${RESULTS}/delta_create_fsopsgrp_${fsopsgrp_id}.json  ${delta_create_fsopsgrp}
    Log  Affected cells in FSOPSGRP-_${fsopsgrp_id}:  console=true
    Log  - Energy Saving: LNCELs: ${cell_list}  console=true


Create And Activate NRPGRP With 5GC000431
    [Documentation]  Creates and activates NRPGRP as per 5GC000431 requirements.
    [Arguments]  ${nrcell}  ${start_time_offset}  ${switch_off_duration}

    ${NRPGRP_DN}  Set Variable  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-1
    ${delta_create_nrpgrp}  Set Variable  nrpgrp_create
    admin.Create Delta  ${delta_create_nrpgrp}
    admin.Append Managed Object To Delta  ${NRPGRP_DN}  create  ${delta_create_nrpgrp}
    admin.Append Parameter Update To Delta  ${NRPGRP_DN}  lbpsCSONCtlEnabled  true  ${delta_create_nrpgrp}
    admin.Append Parameter Update To Delta  ${NRPGRP_DN}  lbpsLastCellMinLoad  2  ${delta_create_nrpgrp}
    admin.Append Parameter Update To Delta  ${NRPGRP_DN}  lbpsLastCellRTXMinLoad  0  ${delta_create_nrpgrp}
    admin.Append Parameter Update To Delta  ${NRPGRP_DN}  lbpsLastCellSOEnabled  true  ${delta_create_nrpgrp}
    admin.Append Parameter Update To Delta  ${NRPGRP_DN}  lbpsLoadCalcMethod  Max(G_N_combined, P)  ${delta_create_nrpgrp}
    admin.Append Parameter Update To Delta  ${NRPGRP_DN}  lbpsMaxLoad  4  ${delta_create_nrpgrp}
    admin.Append Parameter Update To Delta  ${NRPGRP_DN}  lbpsMinLoad  2  ${delta_create_nrpgrp}
    admin.Append Parameter Update To Delta  ${NRPGRP_DN}  lbpsMonWinForCellSOff  300  ${delta_create_nrpgrp}
    admin.Append Parameter Update To Delta  ${NRPGRP_DN}  lbpsMonWinForCellSOn  120  ${delta_create_nrpgrp}
    admin.Append Parameter Update To Delta  ${NRPGRP_DN}  lbpsPdcchLoadOffset  4  ${delta_create_nrpgrp}
    admin.Append Parameter Update To Delta  ${NRPGRP_DN}  lbpsRTXCellCapOffset  80  ${delta_create_nrpgrp}
    admin.Append Parameter Update To Delta  ${NRPGRP_DN}  lbpsRTXMaxLoad  60  ${delta_create_nrpgrp}
    admin.Append Parameter Update To Delta  ${NRPGRP_DN}  lbpsRTXMinLoad  20  ${delta_create_nrpgrp}
    admin.Append Parameter Update To Delta  ${NRPGRP_DN}  lbpsRTXSOffTime  300  ${delta_create_nrpgrp}
    admin.Append Parameter Update To Delta  ${NRPGRP_DN}  lbpsRTXSOnTime  120  ${delta_create_nrpgrp}
    admin.Append Parameter Update To Delta  ${NRPGRP_DN}  lbpsSOMethod  cell switch off  ${delta_create_nrpgrp}
    ${lbpsCellList}  Create Dictionary
    Set To Dictionary  ${lbpsCellList}  lbpsUseExtConfig  false
    Set To Dictionary  ${lbpsCellList}  lbpsCellSOOrder=1
    Set To Dictionary  ${lbpsCellList}  nrCellId=${nrcell}[0]
    admin.Append Complex Item To Delta  ${NRPGRP_DN}  list_name=lbpsCellList  &{lbpsCellList}  delta_id=${delta_create_nrpgrp}
    Get Time And Date With Minute Offset  ${start_time_offset}
    ${lbpsPeriodList}  Create Dictionary
    Set To Dictionary  ${lbpsPeriodList}  lbpsDayOfWeek=${DAY}
    Set To Dictionary  ${lbpsPeriodList}  lbpsDuration=${switch_off_duration}
    Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeHour=${START_HOUR}
    Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeMinute=${START_MINUTES}
    Set To Dictionary  ${lbpsPeriodList}  lbpsSuspended=notSuspended
    admin.Append Complex Item To Delta  ${NRPGRP_DN}  list_name=lbpsPeriodList  &{lbpsPeriodList}  delta_id=${delta_create_nrpgrp}
    admin.Get Delta  ${delta_create_nrpgrp}
    admin.Save Delta  ${RESULTS}/delta_create_nrpgrp_5GC000431.json  ${delta_create_nrpgrp}
    Log  Activate Power Saving Group under ${NRPGRP_DN}  console=${true}
    admin.Perform Delta Recommissioning  ${RESULTS}/delta_create_nrpgrp_5GC000431.json  ${delta_create_nrpgrp}
    ${end_time}  Add Time To Date  ${time_with_offset}  ${switch_off_duration} minutes
    ${end_hour}  Convert Date  ${end_time}  result_format=%H
    ${end_minutes}  Convert Date  ${end_time}  result_format=%M
    Set Test Variable  ${TIME_WITH_OFFSET_NRPGRP}  ${time_with_offset}
    Set Test Variable  ${END_TIME_NRPGRP}  ${end_time}
    Log  NRPGRP time frame: ${start_hour}:${start_minutes}-${end_hour}:${end_minutes} (+${switch_off_duration} minutes)  console=true
    Log  Affected cells in NRPGRP-1:  console=true
    Log  - Energy Saving: ${nrcell}  console=true


Create And Activate NRPGRP With 1 mMIMO And 1 Non mMIMO
    [Documentation]  Creates and activates NRPGRP with one random mMIMO cell and one random non-mMIMO cell selected
    [Arguments]  ${selected_mmimo_cell}  ${selected_nmmimo_cell}  ${start_time_offset}  ${switch_off_duration}

    ${selected_nrcells}  Create List  ${selected_mmimo_cell}  ${selected_nmmimo_cell}
    ${nrpgrp_dn}  Set Variable  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-1
    ${delta_create_nrpgrp}  Set Variable  nrpgrp_create
    admin.Create Delta  ${delta_create_nrpgrp}
    admin.Append Managed Object To Delta  ${nrpgrp_dn}  create  ${delta_create_nrpgrp}
    admin.Append Parameter Update To Delta  ${NRBTS_DistName}  actNrExtCellSOMethod  true  ${delta_create_nrpgrp}
    admin.Append Parameter Update To Delta  ${NRBTS_DistName}  actNrLBPowerSaving  true  ${delta_create_nrpgrp}
    admin.Append Parameter Update To Delta  ${NRBTS_DistName}  actNrLBmMimoRTXPowerSaving  true  ${delta_create_nrpgrp}
    admin.Append Parameter Update To Delta  ${NRBTS_DistName}  actNrLBRTXPowerSaving  false  ${delta_create_nrpgrp}
    admin.Append Parameter Update To Delta  ${NRBTS_DistName}  actNrMixedSOMethod  false  ${delta_create_nrpgrp}
    admin.Append Parameter Update To Delta  ${NRBTS_DistName}  shutdownWindow  60  ${delta_create_nrpgrp}
    admin.Append Parameter Update To Delta  ${nrpgrp_dn}  lbpsCSONCtlEnabled  true  ${delta_create_nrpgrp}
    admin.Append Parameter Update To Delta  ${nrpgrp_dn}  lbpsLastCellMinLoad  0  ${delta_create_nrpgrp}
    admin.Append Parameter Update To Delta  ${nrpgrp_dn}  lbpsLastCellRTXMinLoad  0  ${delta_create_nrpgrp}
    admin.Append Parameter Update To Delta  ${nrpgrp_dn}  lbpsLastCellSOEnabled  true  ${delta_create_nrpgrp}
    admin.Append Parameter Update To Delta  ${nrpgrp_dn}  lbpsMaxLoad  60  ${delta_create_nrpgrp}
    admin.Append Parameter Update To Delta  ${nrpgrp_dn}  lbpsMinLoad  20  ${delta_create_nrpgrp}
    admin.Append Parameter Update To Delta  ${nrpgrp_dn}  lbpsPdcchLoadOffset  4  ${delta_create_nrpgrp}
    admin.Append Parameter Update To Delta  ${nrpgrp_dn}  lbpsRTXCellCapOffset  80  ${delta_create_nrpgrp}
    admin.Append Parameter Update To Delta  ${nrpgrp_dn}  lbpsRTXMaxLoad  60  ${delta_create_nrpgrp}
    admin.Append Parameter Update To Delta  ${nrpgrp_dn}  lbpsRTXMinLoad  20  ${delta_create_nrpgrp}
    admin.Append Parameter Update To Delta  ${nrpgrp_dn}  lbpsRTXSOffTime  300  ${delta_create_nrpgrp}
    admin.Append Parameter Update To Delta  ${nrpgrp_dn}  lbpsRTXSOnTime  120  ${delta_create_nrpgrp}
    admin.Append Parameter Update To Delta  ${nrpgrp_dn}  lbpsSOMethod  TX switch off  ${delta_create_nrpgrp}
    ${cell_so_order}  Create List  1  100
    ${cell_so_method}  Create List  TX switch off  cell switch off
    ${lbpsCellList}  Create Dictionary
    ${lbpsCellPeriodList}  Create Dictionary
    Get Time And Date With Minute Offset  ${start_time_offset}
    FOR  ${current_item_order}  ${cell}  ${method}  IN ZIP  ${cell_so_order}  ${selected_nrcells}  ${cell_so_method}
        Set To Dictionary  ${lbpsCellList}  lbpsCellSOOrder=${current_item_order}
        Set To Dictionary  ${lbpsCellList}  lbpsUseExtConfig  true
        Set To Dictionary  ${lbpsCellList}  nrCellId=${cell}
        Set To Dictionary  ${lbpsCellPeriodList}  lbpsCellDayOfWeek=${DAY}
        Set To Dictionary  ${lbpsCellPeriodList}  lbpsCellDuration=${switch_off_duration}
        Set To Dictionary  ${lbpsCellPeriodList}  lbpsCellSOMethod=${method}
        Set To Dictionary  ${lbpsCellPeriodList}  lbpsCellStartTimeHour=${START_HOUR}
        Set To Dictionary  ${lbpsCellPeriodList}  lbpsCellStartTimeMinute=${START_MINUTES}
        Set To Dictionary  ${lbpsCellPeriodList}  nrCellId=${cell}
        admin.Append Complex Item To Delta  ${nrpgrp_dn}  list_name=lbpsCellList  &{lbpsCellList}  delta_id=${delta_create_nrpgrp}
        admin.Append Complex Item To Delta  ${nrpgrp_dn}  list_name=lbpsCellPeriodList  &{lbpsCellPeriodList}  delta_id=${delta_create_nrpgrp}
    END
    ${lbpsPeriodList}  Create Dictionary
    Set To Dictionary  ${lbpsPeriodList}  lbpsDayOfWeek=${DAY}
    Set To Dictionary  ${lbpsPeriodList}  lbpsDuration=${switch_off_duration}
    Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeHour=${START_HOUR}
    Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeMinute=${START_MINUTES}
    admin.Append Complex Item To Delta  ${nrpgrp_dn}  list_name=lbpsPeriodList  &{lbpsPeriodList}  delta_id=${delta_create_nrpgrp}
    admin.Get Delta  ${delta_create_nrpgrp}
    admin.Save Delta  ${RESULTS}/delta_create_nrpgrp.json  ${delta_create_nrpgrp}
    Log  Activate Power Saving Group under ${nrpgrp_dn}  console=true
    admin.Perform Delta Recommissioning  ${RESULTS}/delta_create_nrpgrp.json  ${delta_create_nrpgrp}
    ${end_time}  Add Time To Date  ${time_with_offset}  ${switch_off_duration} minutes
    ${end_hour}  Convert Date  ${end_time}  result_format=%H
    ${end_minutes}  Convert Date  ${end_time}  result_format=%M
    Set Test Variable  ${TIME_WITH_OFFSET_NRPGRP}  ${time_with_offset}
    Set Test Variable  ${END_TIME_NRPGRP}  ${end_time}
    Log  NRPGRP time frame: ${start_hour}:${start_minutes}-${end_hour}:${end_minutes} (+${switch_off_duration} minutes)  console=true
    Log  Affected cells in NRPGRP-1:  console=true
    Log  ${selected_nrcells}  console=true


Get Specific Parameter From Existing NRPGRP
    [Documentation]  This keyword returns the selected ${parameter} values from an existing NRPGRP.
    ...  Use only when only targeted NRPGRP exists on BTS
	[Arguments]  ${parameter}

    ${nrpgrp_parameter_list}  admin.Get Managed Objects  NRPGRP_A
    ${cells_in_nrpgrp}  Create List
    ${cell_so_order_in_nrpgrp}  Create List
    FOR  ${nrpgrp_parameter}  IN  @{nrpgrp_parameter_list}
        ${parameter_values}  Get From Dictionary  ${nrpgrp_parameter['parameters']}  ${parameter}
    END

    RETURN  ${parameter_values}


Get Specific Parameter From Existing Group
    [Documentation]  This keyword returns the selected ${parameter} values from an existing energy saving group ${group}.
    [Arguments]  ${group}  ${group_id}  ${parameter}

    ${grp_parameter_list}  admin.Get Managed Objects  ${group}_A
    FOR  ${grp_parameter}  IN  @{grp_parameter_list}
        ${dist_name}  Get From Dictionary  ${grp_parameter}  distName
        ${grp_id}  Fetch From Right  ${dist_name}  -
        IF  '${grp_id}'=='${group_id}'
            ${parameter_values}  Get From Dictionary  ${grp_parameter['parameters']}  ${parameter}
        END
    END

    RETURN  ${parameter_values}


Modify Cell Composition Of Group
    [Arguments]  ${group}  ${cell_list}  ${group_id}  ${action_required}  ${so_order_list}=@{EMPTY}

    ${existing_lbps_cell_list}  Get Specific Parameter From Existing Group  ${group}  ${group_id}  lbpsCellList
    IF  '${group}'=='PSGRP'
        ${grp_dn}  Set Variable  MRBTS-${MRBTS_ID}/LNBTS-${LNBTS_ID}/${group}-${group_id}
    ELSE IF  '${group}'=='NRPGRP'
        ${grp_dn}  Set Variable  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/${group}-${group_id}
    END
    ${delta_reconfig_grp}  Set Variable  delta_reconfig_${group}
    admin.Create Delta  ${delta_reconfig_grp}
    ${action_required}  Evaluate  "${action_required}".upper()
    IF  '${action_required}'=='REMOVE'
        FOR  ${lbps_cell}  IN  @{existing_lbps_cell_list}
            IF  '${group}'=='PSGRP'
                ${cell_in_dict}  Get From Dictionary  ${lbps_cell}  lnCelId
            ELSE IF  '${group}'=='NRPGRP'
                ${cell_in_dict}  Get From Dictionary  ${lbps_cell}  nrCellId
            END
            ${contains_cell}  Set Variable If  '${cell_list[0]}'=='${cell_in_dict}'  ${TRUE}  ${FALSE}
            IF  ${contains_cell}  Remove Values From List  ${existing_lbps_cell_list}  ${lbps_cell}
        END
    ELSE IF  '${action_required}'=='ADD'
        ${lbps_cell_list}  Create Dictionary
        ${param_name}  Set Variable If  '${group}'=='PSGRP'  lnCelId  nrCellId
        FOR  ${cell}  ${so_order}  IN ZIP  ${cell_list}  ${so_order_list}
            Set To Dictionary  ${lbps_cell_list}  lbpsCellSOOrder=${so_order}
            Set To Dictionary  ${lbps_cell_list}  lbpsUseExtConfig  false
            Set To Dictionary  ${lbps_cell_list}  ${param_name}=${cell}
            Append To List  ${existing_lbps_cell_list}  ${lbps_cell_list}
        END
    ELSE
        Fail  Unknown action intended for the KW! Use only ADD/REMOVE\n
    END
    FOR  ${lbps_list}  IN  @{existing_lbps_cell_list}
        admin.Append Complex Item To Delta  ${grp_dn}  list_name=lbpsCellList  &{lbps_list}  delta_id=${delta_reconfig_grp}
    END
    admin.Get Delta  ${delta_reconfig_grp}
    admin.Save Delta  ${RESULTS}/delta_reconfig_${group}.json  ${delta_reconfig_grp}
    admin.Perform Delta Recommissioning  ${RESULTS}/delta_reconfig_${group}.json  ${delta_reconfig_grp}


Add NRCELLS To Existing NRPGRP
    [Arguments]  ${nrcells_to_add}  ${cell_so_order_to_add}  ${method_to_add}  ${switch_off_duration}

    ${existing_lbps_cell_list}  Get Specific Parameter From Existing NRPGRP  lbpsCellList
    ${existing_lbps_cell_period_list}  Get Specific Parameter From Existing NRPGRP  lbpsCellPeriodList
    ${delta_reconfig_nrpgrp}  Set Variable  delta_reconfig_nrpgrp
    admin.Create Delta  ${delta_reconfig_nrpgrp}
    ${lbps_cell_list}  Create Dictionary
    ${lbpsCellPeriodList}  Create Dictionary
    ${nrpgrp_dn}  Set Variable  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-1
    FOR  ${order}  ${cell}  ${method}  IN ZIP  ${cell_so_order_to_add}  ${nrcells_to_add}  ${method_to_add}
        Set To Dictionary  ${lbps_cell_list}  lbpsCellSOOrder=${order}
        Set To Dictionary  ${lbps_cell_list}  lbpsUseExtConfig  true
        Set To Dictionary  ${lbps_cell_list}  nrCellId=${cell}
        Set To Dictionary  ${lbpsCellPeriodList}  lbpsCellDayOfWeek=${DAY}
        Set To Dictionary  ${lbpsCellPeriodList}  lbpsCellDuration=${switch_off_duration}
        Set To Dictionary  ${lbpsCellPeriodList}  lbpsCellSOMethod=${method}
        Set To Dictionary  ${lbpsCellPeriodList}  lbpsCellStartTimeHour=${START_HOUR}
        Set To Dictionary  ${lbpsCellPeriodList}  lbpsCellStartTimeMinute=${START_MINUTES}
        Set To Dictionary  ${lbpsCellPeriodList}  nrCellId=${cell}
        Append To List  ${existing_lbps_cell_list}  ${lbps_cell_list}
        Append To List  ${existing_lbps_cell_period_list}  ${lbpsCellPeriodList}
    END
    FOR  ${lbps_list}  ${lbps_period_list}  IN ZIP  ${existing_lbps_cell_list}  ${existing_lbps_cell_period_list}
        admin.Append Complex Item To Delta  ${nrpgrp_dn}  list_name=lbpsCellList  &{lbps_list}  delta_id=${delta_reconfig_nrpgrp}
        admin.Append Complex Item To Delta  ${nrpgrp_dn}  list_name=lbpsCellPeriodList  &{lbps_period_list}  delta_id=${delta_reconfig_nrpgrp}
    END
    admin.Get Delta  ${delta_reconfig_nrpgrp}
    admin.Save Delta  ${RESULTS}/delta_reconfig_nrpgrp.json  ${delta_reconfig_nrpgrp}
    admin.Perform Delta Recommissioning  ${RESULTS}/delta_reconfig_nrpgrp.json  ${delta_reconfig_nrpgrp}


Create And Activate NRFSOPGRP Based On Time Windows
    [Documentation]  Description: This keyword creates a NRFSOPGRP for time window cell switch off and
    ...  activates it at current VM time + ${start_time_offset}, sets the duration of the cell switch off to
    ...  ${switch_off_duration}, and uses the cells provided in ${cell_list}
    ...  ${cell_list}           #list of NRCELLs to use for NRFSOPGRP
    ...  ${start_time_offset}   #time offset for when the cell switch off should begin, based on VM time
    ...  ${switch_off_duration} #amount of time that cell switch off should be active
    ...  Return: none${\n}
    ...  Output: {}${\n}
    ...  Author: victor.banicioiu@nokia.com${\n}
    [Arguments]  ${cell_list}  ${start_time_offset}  ${switch_off_duration}

    Get Time And Date With Minute Offset  ${start_time_offset}
    ${delta_create_nrfsopgrp}  Set Variable  nrfsopgrp_create
    ${NRFSOPGRP_DN}  Set Variable  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRFSOPGRP-1
    admin.Create Delta  ${delta_create_nrfsopgrp}
    admin.Append Managed Object To Delta  ${NRFSOPGRP_DN}  create  ${delta_create_nrfsopgrp}
    admin.Append Parameter Update To Delta  ${NRFSOPGRP_DN}  cellSwitchOffType  TimeWindow  ${delta_create_nrfsopgrp}
    admin.Append List Items To Delta  ${NRFSOPGRP_DN}  nrCellIdList  @{cell_list}  delta_id=${delta_create_nrfsopgrp}
    ${fso_period_list}  Create Dictionary
    Set To Dictionary  ${fso_period_list}  fsoDayOfWeek=${DAY}
    Set To Dictionary  ${fso_period_list}  fsoDuration=${switch_off_duration}
    Set To Dictionary  ${fso_period_list}  fsoStartHour=${START_HOUR}
    Set To Dictionary  ${fso_period_list}  fsoStartMinute=${START_MINUTES}
    admin.Append Complex Item To Delta  ${NRFSOPGRP_DN}  list_name=timeWindowCellSwitchOffList  &{fso_period_list}
    ...  delta_id=${delta_create_nrfsopgrp}
    admin.Get Delta  ${delta_create_nrfsopgrp}
    admin.Save Delta  ${RESULTS}/delta_create_nrfsopgrp_1_CB012087.json  ${delta_create_nrfsopgrp}
    Log  Activate NRFSOPGRP under ${NRFSOPGRP_DN}  console=true
    admin.Perform Delta Recommissioning  ${RESULTS}/delta_create_nrfsopgrp_1_CB012087.json  ${delta_create_nrfsopgrp}
    ${end_time}  Add Time To Date  ${time_with_offset}  ${switch_off_duration} minutes
    ${end_hour}  Convert Date  ${end_time}  result_format=%H
    ${end_minutes}  Convert Date  ${end_time}  result_format=%M
    Set Test Variable  ${TIME_WITH_OFFSET}
    Set Test Variable  ${END_TIME}
    Log  NRFSOPGRP time frame: ${start_hour}:${start_minutes}-${end_hour}:${end_minutes} (+${switch_off_duration} minutes)  console=true
    Log  Affected cells in NRFSOPGRP-1:  console=true
    Log  - Energy Saving: ${cell_list}  console=true


Create And Activate FSOPSGRP Based On Time Windows
    [Documentation]  Description: This keyword creates a FSOPSGRP for time window cell switch off and
    ...  activates it at current VM time + ${start_time_offset}, sets the duration of the cell switch off to
    ...  ${switch_off_duration}, and uses the cells provided in ${cell_list}
    ...  ${cell_list}           #list of NRCELLs to use for NRFSOPGRP
    ...  ${start_time_offset}   #time offset for when the cell switch off should begin, based on VM time
    ...  ${switch_off_duration} #amount of time that cell switch off should be active
    ...  Return: none${\n}
    ...  Output: {}${\n}
    ...  Author: victor.banicioiu@nokia.com${\n}
    [Arguments]  ${cell_list}  ${start_time_offset}  ${switch_off_duration}

    Get Time And Date With Minute Offset  ${start_time_offset}
    ${delta_create_fsopsgrp}  Set Variable  fsopsgrp_create
    ${fsopsgrp_dn}  Set Variable  MRBTS-${MRBTS_ID}/LNBTS-${LNBTS_ID}/FSOPSGRP-1
    admin.Create Delta  ${delta_create_fsopsgrp}
    admin.Append Managed Object To Delta  ${fsopsgrp_dn}  create  ${delta_create_fsopsgrp}
    admin.Append Parameter Update To Delta  ${fsopsgrp_dn}  cellSwitchOffType  TimeWindow  ${delta_create_fsopsgrp}
    admin.Append List Items To Delta  ${fsopsgrp_dn}  lnCelIdList  @{cell_list}  delta_id=${delta_create_fsopsgrp}
    ${fso_period_list}  Create Dictionary
    Set To Dictionary  ${fso_period_list}  fsoDayOfWeek=${DAY}
    Set To Dictionary  ${fso_period_list}  fsoDuration=${switch_off_duration}
    Set To Dictionary  ${fso_period_list}  fsoStartHour=${START_HOUR}
    Set To Dictionary  ${fso_period_list}  fsoStartMinute=${START_MINUTES}
    admin.Append Complex Item To Delta  ${fsopsgrp_dn}  list_name=timeWindowCellSwitchOffList  &{fso_period_list}
    ...  delta_id=${delta_create_fsopsgrp}
    admin.Get Delta  ${delta_create_fsopsgrp}
    admin.Save Delta  ${RESULTS}/delta_create_fsopsgrp_1_CB012087.json  ${delta_create_fsopsgrp}
    Log  Activate FSOPSGRP under ${fsopsgrp_dn}  console=true
    admin.Perform Delta Recommissioning  ${RESULTS}/delta_create_fsopsgrp_1_CB012087.json  ${delta_create_fsopsgrp}
    ${end_time}  Add Time To Date  ${time_with_offset}  ${switch_off_duration} minutes
    ${end_hour}  Convert Date  ${end_time}  result_format=%H
    ${end_minutes}  Convert Date  ${end_time}  result_format=%M
    Set Test Variable  ${TIME_WITH_OFFSET}
    Set Test Variable  ${END_TIME}
    Log  FSOPSGRP time frame: ${start_hour}:${start_minutes}-${end_hour}:${end_minutes} (+${switch_off_duration} minutes)  console=true
    Log  Affected cells in FSOPSGRP-1:  console=true
    Log  - Energy Saving: ${cell_list}  console=true


Modify Fso Duration For Existing FSOPSGRP
    [Arguments]  ${fsopsgrp_id}  ${new_fso_duration}

    ${delta_reconfig_fsopsgrp}  Set Variable  delta_reconfig_fsopsgrp
    ${fsopsgrp_dn}  Set Variable  MRBTS-${MRBTS_ID}/LNBTS-${LNBTS_ID}/${fsopsgrp_id}
    admin.Create Delta  ${delta_reconfig_fsopsgrp}
    ${fso_period_list}  Create Dictionary
    Set To Dictionary  ${fso_period_list}  fsoDayOfWeek=${DAY}
    Set To Dictionary  ${fso_period_list}  fsoDuration=${new_fso_duration}
    Set To Dictionary  ${fso_period_list}  fsoStartHour=${START_HOUR}
    Set To Dictionary  ${fso_period_list}  fsoStartMinute=${START_MINUTES}
    admin.Append Complex Item To Delta  ${fsopsgrp_dn}  list_name=timeWindowCellSwitchOffList  &{fso_period_list}
    ...  delta_id=${delta_reconfig_fsopsgrp}
    admin.Get Delta  ${delta_reconfig_fsopsgrp}
    admin.Save Delta  ${RESULTS}/delta_reconfig_fsopsgrp_1_CB012087.json  ${delta_reconfig_fsopsgrp}
    Log  Activate FSOPSGRP under ${fsopsgrp_dn}  console=true
    admin.Perform Delta Recommissioning  ${RESULTS}/delta_reconfig_fsopsgrp_1_CB012087.json  ${delta_reconfig_fsopsgrp}
    ${modified_end_time}  Add Time To Date  ${time_with_offset}  ${new_fso_duration} minutes
    ${end_hour}  Convert Date  ${modified_end_time}  result_format=%H
    ${end_minutes}  Convert Date  ${modified_end_time}  result_format=%M
    Set Test Variable  ${TIME_WITH_OFFSET}
    Set Test Variable  ${MODIFIED_END_TIME}
    Log  FSOPSGRP modified time frame: ${start_hour}:${start_minutes}-${end_hour}:${end_minutes} (+${new_fso_duration} minutes)  console=true


Create And Activate NRFSOPGRP Based On Voltage Threshold
    [Documentation]  Description: This keyword creates a NRFSOPGRP for voltage threshold cell switch off and
    ...  activates it so that the cells turn off at ${turn_off_voltage} value and turn on at ${turn_on_voltage}, and
    ...  uses the cells provided in ${cell_list}
    ...  ${cell_list}           #list of NRCELLs to use for NRFSOPGRP
    ...  ${turn_off_voltage}    #voltage threshold for cell switch off
    ...  ${turn_on_voltage}     #voltage threshold for cell switch on
    ...  Return: none${\n}
    ...  Output: {}${\n}
    ...  Author: victor.banicioiu@nokia.com${\n}
    [Arguments]  ${cell_list}  ${turn_off_voltage}  ${turn_on_voltage}

    ${delta_create_nrfsopgrp}  Set Variable  nrfsopgrp_create
    ${NRFSOPGRP_DN}  Set Variable  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRFSOPGRP-2
    admin.Create Delta  ${delta_create_nrfsopgrp}
    admin.Append Managed Object To Delta  ${NRFSOPGRP_DN}  create  ${delta_create_nrfsopgrp}
    admin.Append Parameter Update To Delta  ${NRFSOPGRP_DN}  cellSwitchOffType  LowVoltage  ${delta_create_nrfsopgrp}
    ${voltage_cell_switchoff}  Create Dictionary
    Set To Dictionary  ${voltage_cell_switchoff}  lowVoltageCellSwitchOffThr=${turn_off_voltage}
    Set To Dictionary  ${voltage_cell_switchoff}  lowVoltageCellSwitchOnThr=${turn_on_voltage}
    admin.Append Complex Item To Delta  ${NRFSOPGRP_DN}  list_name=lowVoltageCellSwitchOff  &{voltage_cell_switchoff}
    ...  delta_id=${delta_create_nrfsopgrp}
    admin.Append List Items To Delta  ${NRFSOPGRP_DN}  nrCellIdList  @{cell_list}  delta_id=${delta_create_nrfsopgrp}
    admin.Get Delta  ${delta_create_nrfsopgrp}
    admin.Save Delta  ${RESULTS}/delta_create_nrfsopgrp_2_CB012087.json  ${delta_create_nrfsopgrp}
    Log  Activate NRFSOPGRP under ${NRFSOPGRP_DN}  console=true
    admin.Perform Delta Recommissioning  ${RESULTS}/delta_create_nrfsopgrp_2_CB012087.json  ${delta_create_nrfsopgrp}
    Log  NRFSOPGRP voltage threshold frame: ${turn_off_voltage}:cell switch off -> ${turn_on_voltage}:cell switch on\n  console=true
    Log  Affected cells in NRFSOPGRP-2:  console=true
    Log  - Energy Saving: NRCEL_R-${cell_list}[0], NRCEL_R-${cell_list}[1]  console=true


Create And Activate FSOPSGRP Based On Voltage
    [Documentation]  Description: This keyword creates a FSOPSGRP for voltage threshold cell switch off and
    ...  activates it so that the cells turn off at ${turn_off_voltage} value and turn on at ${turn_on_voltage}, and
    ...  uses the cells provided in ${cell_list}
    ...  ${cell_list}           #list of LNCELLs to use for FSOPSGRP
    ...  ${turn_off_voltage}    #voltage threshold for cell switch off
    ...  ${turn_on_voltage}     #voltage threshold for cell switch on
    ...  Return: none${\n}
    ...  Output: {}${\n}
    ...  Author: victor.banicioiu@nokia.com${\n}
    [Arguments]  ${cell_list}  ${turn_off_voltage}  ${turn_on_voltage}

    ${delta_create_fsopsgrp}  Set Variable  fsopsgrp_create
    ${FSOPSGRP_DN}  Set Variable  MRBTS-${MRBTS_ID}/LNBTS-${LNBTS_ID}/FSOPSGRP-2
    admin.Create Delta  ${delta_create_fsopsgrp}
    admin.Append Managed Object To Delta  ${FSOPSGRP_DN}  create  ${delta_create_fsopsgrp}
    admin.Append Parameter Update To Delta  ${FSOPSGRP_DN}  cellSwitchOffType  LowVoltage  ${delta_create_fsopsgrp}
    ${voltage_cell_switchoff}  Create Dictionary
    Set To Dictionary  ${voltage_cell_switchoff}  lowVoltageCellSwitchOffThr=${turn_off_voltage}
    Set To Dictionary  ${voltage_cell_switchoff}  lowVoltageCellSwitchOnThr=${turn_on_voltage}
    admin.Append Complex Item To Delta  ${FSOPSGRP_DN}  list_name=lowVoltageCellSwitchOff  &{voltage_cell_switchoff}
    ...  delta_id=${delta_create_fsopsgrp}
    admin.Append List Items To Delta  ${FSOPSGRP_DN}  lnCelIdList  @{cell_list}  delta_id=${delta_create_fsopsgrp}
    admin.Get Delta  ${delta_create_fsopsgrp}
    admin.Save Delta  ${RESULTS}/delta_create_fsopsgrp_2_CB012087.json  ${delta_create_fsopsgrp}
    Log  Activate FSOPSGRP under ${FSOPSGRP_DN}  console=true
    admin.Perform Delta Recommissioning  ${RESULTS}/delta_create_fsopsgrp_2_CB012087.json  ${delta_create_fsopsgrp}
    Log  FSOPSGRP voltage threshold frame: ${turn_off_voltage}:cell switch off -> ${turn_on_voltage}:cell switch on\n  console=true
    Log  Affected cells in FSOPSGRP-2:  console=true
    Log  - Energy Saving: LNCEL-${cell_list}[0]  console=true


Modify Voltage Threshold For Existing FSOPSGRP
    [Arguments]  ${fsopsgrp_id}  ${new_off_voltage_value}  ${new_on_voltage_value}

    ${delta_reconfig_fsopsgrp}  Set Variable  delta_reconfig_fsopsgrp
    ${fsopsgrp_dn}  Set Variable  MRBTS-${MRBTS_ID}/LNBTS-${LNBTS_ID}/${fsopsgrp_id}
    admin.Create Delta  ${delta_reconfig_fsopsgrp}
    ${voltage_cell_switchoff}  Create Dictionary
    Set To Dictionary  ${voltage_cell_switchoff}  lowVoltageCellSwitchOffThr=${new_off_voltage_value}
    Set To Dictionary  ${voltage_cell_switchoff}  lowVoltageCellSwitchOnThr=${new_on_voltage_value}
    admin.Append Complex Item To Delta  ${FSOPSGRP_DN}  list_name=lowVoltageCellSwitchOff  &{voltage_cell_switchoff}
    ...  delta_id=${delta_reconfig_fsopsgrp}
    admin.Get Delta  ${delta_reconfig_fsopsgrp}
    admin.Save Delta  ${RESULTS}/delta_reconfig_fsopsgrp_2_CB012087.json  ${delta_reconfig_fsopsgrp}
    Log  Activate FSOPSGRP under ${fsopsgrp_dn}  console=true
    admin.Perform Delta Recommissioning  ${RESULTS}/delta_reconfig_fsopsgrp_2_CB012087.json  ${delta_reconfig_fsopsgrp}
    Log  FSOPSGRP voltage threshold frame: ${new_off_voltage_value}:cell switch off -> ${new_on_voltage_value}:cell switch on\n  console=true


Get RMOD DistName And Internal Name Based On Serial Number
    [Documentation]  This keyword gets and returns the distName and internal name of the RMOD that has the serial number equal to ${rmod_sn}
    [Arguments]  ${rmod_sn}

    Log  Getting the distName and internal name for RU ${rmod_sn}\n  console=true
    ${rmod_list}  admin.Get Frm
    FOR  ${rmod}  IN  @{rmod_list}
        ${rmod_serial_number}  Set Variable  ${rmod['serialNumber']}
        ${rmod_id}  Set Variable  ${rmod['id']['configuration']}
        ${rmod_internal_name}  Set Variable  ${rmod['id']['internal']}
        IF  '${rmod_serial_number}'=='${rmod_sn}'
            ${ru_distname}  Set Variable  ${rmod_id}
            ${ru_internal}  Fetch From Right  ${rmod_internal_name}  /
        END
    END

    RETURN  ${ru_distname}  ${ru_internal}


Wait For NRCELs To Reach Expected States
    [Documentation]  Description: This keyword loops over the provided cell IDs in ${cell_ids}, and checks for
    ...  a total of ${check_time}, in intervals of ${check_interval}, in order to see that the cells reach the
    ...  ${expected_operational_state} and ${expected_energysaving_state}
    [Arguments]  ${cell_ids}  ${check_time}  ${check_interval}  ${expected_operational_state}  ${expected_energysaving_state}

    ${nr_of_ids}  Get Length  ${cell_ids}
    Log  Waiting for NRCELs in NRFSOPGRP to get to desired energy saving state\n  console=true
    FOR  ${index}  IN RANGE  ${nr_of_ids}
        Wait Until Keyword Succeeds  ${check_time}  ${check_interval}  Check Power Saving for NRCEL
        ...  ${cell_ids}[${index}]  ${expected_operational_state}  ${expected_energysaving_state}
        Log  NRCEL_R-${cell_ids}[${index}] is ${expected_operational_state} / ${expected_energysaving_state}\n  console=true
    END


Wait For Specific Cell To Reach Expected States
    [Documentation]  Description: This keyword loops over the provided cell IDs in ${cell_ids}, and checks for
    ...  a total of ${check_time}, in intervals of ${check_interval}, in order to see that the cells reach the
    ...  ${expected_operational_state} and ${expected_energysaving_state}
    [Arguments]  ${cell_tehnology}  ${cell_ids}  ${check_time}  ${check_interval}  ${states_to_check}  ${expected_states}

    ${var_type}  Get Variable Type  ${cell_ids}
    IF  '${var_type}'=='list'
        ${nr_of_ids}  Get Length  ${cell_ids}
        Log  Waiting for ${cell_tehnology} to get to desired states\n  console=true
        FOR  ${index}  IN RANGE  ${nr_of_ids}
            Wait Until Keyword Succeeds  ${check_time}  ${check_interval}  Check Cell States For Specific Cell
            ...  ${cell_tehnology}  ${cell_ids}[${index}]  ${states_to_check}  ${expected_states}
        END
    ELSE
        Wait Until Keyword Succeeds  ${check_time}  ${check_interval}  Check Cell States For Specific Cell
        ...  ${cell_tehnology}  ${cell_ids}  ${states_to_check}  ${expected_states}
    END


Check If RMOD Performed Reset
    [Documentation]  This KW checks if the selected RMOD, given by ${RMOD_dist_name}, was recently restarted, by comparing
    ...  the seconds of uptime with ${uptime_limit} variable which represents the upper limit of uptime that
    ...  would be possible after a recent reset
    [Arguments]  ${RMOD_dist_name}  ${uptime_limit}

    ${rmod_measurements}  admin.Get Rmod Measurements By Id  ${RMOD_dist_name}
    ${rmod_uptime}  Set Variable  ${rmod_measurements}[uptime][seconds]
    ${rmod_uptime_seconds}  Convert To Integer  ${rmod_uptime}
    Should Be True  ${rmod_uptime_seconds}<=${uptime_limit}  RMOD is running for more than 10 minutes. Check if RMOD restarted


Get Cell List Under RMOD
    [Arguments]  ${rmod_id}

    ${cell_list}  admin.Get Cell Mapping By Module Id  ${rmod_id}
    ${list_length}  Get Length  ${cell_list}
    IF  ${list_length}==0  Fail  There are no cells available under the RMOD provided with id: ${rmod_id}
    @{cell_ids}  Create List
    FOR  ${index}  IN RANGE  ${list_length}
        ${id}  Fetch From Right  ${cell_list}[${index}]  -
        ${cell_id}  Convert To Integer  ${id}
        Append To List  ${cell_ids}  ${cell_id}
    END

    RETURN  ${cell_ids}


Check RMOD Power State
    [Documentation]  This KW uses the infomodel taf library to collect data about all RMODs, and then, based on ${serial_number},
    ...  checks whether the power state of that specific RMOD is ${expected_pm_state}
    [Arguments]  ${serial_number}  ${expected_pm_state}

    ${found_rmod_flag}  Set Variable  ${False}
    ${rmod_list}  admin.Get Frm
    FOR  ${rmod}  IN  @{rmod_list}
        ${rmod_serial_number}  Set Variable  ${rmod['serialNumber']}
        ${rmod_power_state}  Set Variable  ${rmod['status']['powerState']}
        ${found_rmod_flag}  Set Variable If  '${rmod_serial_number}'=='${serial_number}'  ${True}  ${False}
        IF  ${found_rmod_flag}
            Should Be True  '${rmod_power_state}'=='${expected_pm_state}'
            Log  RMOD power state is as expected\n  console=true
            RETURN
        END
    END
    IF  ${found_rmod_flag}==${False}  Fail  No RMOD with the serial number ${serial_number} was found. Test cannot continue\n


Check Power Saving for NRCEL
    [Documentation]  Description: Check if both cell operational state and energysaving state are as expected
    [Arguments]   ${cell}   ${expected_operational_state}  ${expected_energy_saving_state}

    ${cells_states}  admin.Get Parameters For All  NRCEL
    FOR  ${cell_state}  IN  @{cells_states}
        ${cell_id}  Set Variable  ${cell_state}[configurationId]
        ${operational_state}  Evaluate  "${cell_state.operationalState}".upper()
        ${energy_saving_state}  Evaluate  "${cell_state.energySavingState}".upper()
        IF  '${cell_id}'=='${cell}'  Should Be True
        ...  '${operational_state}'=='${expected_operational_state}' and '${energy_saving_state}'=='${expected_energy_saving_state}'
    END


Check Cell States For Specific Cell
    [Documentation]  Description: Check if the states given in the ${states_to_check} list have the same values as the
    ...  ones in the ${expected_cell_states}
    [Arguments]   ${cell_tehnology}  ${cell}  ${states_to_check}  ${expected_cell_states}

    ${cells_states}  admin.Get Parameters For All  ${cell_tehnology}
    ${id}  Set Variable  ${-1}
    ${is_targeted_cell}  Set Variable  ${FALSE}
    FOR  ${cell_state}  IN  @{cells_states}
        IF  '${cell_tehnology}'=='NRCEL'
            ${cell_id}  Set Variable  ${cell_state}[configurationId]
            ${is_targeted_cell}  Set Variable If  '${cell_id}'=='${cell}'  ${TRUE}  ${FALSE}
        ELSE IF  '${cell_tehnology}'=='LNCEL'
            ${cell_id}  Set Variable  ${cell_state}[id]
            ${id}  Split String From Right  ${cell_id}  -
            ${is_targeted_cell}  Set Variable If  '${id[-1]}'=='${cell}'  ${TRUE}  ${FALSE}
        END
        IF  ${is_targeted_cell}
            FOR  ${state}  ${expected_state}  IN ZIP  ${states_to_check}  ${expected_cell_states}
                ${status}  Run Keyword And Return Status  Dictionary Should Contain Key  ${cell_state}  ${state}
                IF  ${status}
                    ${state_value}  Evaluate  "${cell_state}[${state}]".upper()
                    ${expected_state}  Evaluate  "${expected_state}".upper()
                    Should Be True  "${state_value}"=="${expected_state}"
                ELSE IF  "${state}"!="availabilityStatus"
                    Log  Could not find the ${state} key in dictionary.\n  level=WARN  console=true
                END
            END
            Log  The following states are as expected for cell ${cell}: @{states_to_check}\n  console=true
        END
    END


Verifying Cells In NRFSOPGRP Are In Expected States
    [Documentation]  Description: This keyword checks if the cells in nrCellIdList for the NRFSOPGRPs are in the
    ...  ${expected_operational_state}, respectively ${expected_energysaving_state}
    [Arguments]  ${expected_operational_state}  ${expected_energysaving_state}

    ${nrfsopgrp_list}  admin.Get Managed Objects  NRFSOPGRP_A
    IF  ${nrfsopgrp_list}==[]
        Log  There are no existing NRFSOPGRP ojects on the BTS\n  console=true
        RETURN
    END
    FOR  ${obj}  IN  @{nrfsopgrp_list}
        ${group_cells}  Set Variable  ${obj['parameters']['nrCellIdList']}
        FOR  ${cell}  IN  @{group_cells}
            Check Power Saving for NRCEL  ${cell}  ENABLED  NOTENERGYSAVING
        END
    END


Create And Activate PSGRP For LTE1203
    [Documentation]
    ...  **Example of simple usage:**
    ...  Create And Activate PSGRP For LTE1203  ${1st_ES_LNCEL_DN}  ${1st_RES_LNCEL_DN}  ${2nd_RES_LNCEL_DN}  PSGRP-12  25min
    ...
    [Arguments]  ${1st_LNCELdistName}  ${2nd_LNCELdistName}  ${3rd_LNCELdistName}  ${PSGRP-ID}  ${lbpsDuration}

    ${1st_LNCELid}=  Evaluate  re.search(r'LNCEL_R-(\\d+)','''${1st_LNCELdistName}''').group(1)  re
    ${2nd_LNCELid}=  Evaluate  re.search(r'LNCEL_R-(\\d+)','''${2nd_LNCELdistName}''').group(1)  re
    ${3rd_LNCELid}=  Evaluate  re.search(r'LNCEL_R-(\\d+)','''${3rd_LNCELdistName}''').group(1)  re
    ${selected_cells_IDs}=  Create List  ${1st_LNCELid}  ${2nd_LNCELid}  ${3rd_LNCELid}
    ${delta_create_psgrp}=  Set Variable  psgrp_create
    ${PSGRP_DN}=  Set Variable  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}
    admin.create delta  ${delta_create_psgrp}
    admin.append managed object to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  create  ${delta_create_psgrp}
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  lbpsCSONCtlEnabled  false  ${delta_create_psgrp}
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  lbpsLastCellMinLoad  0  ${delta_create_psgrp}
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  lbpsLastCellRTXMinLoad  0  ${delta_create_psgrp}
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  lbpsLastCellSOEnabled  true  ${delta_create_psgrp}
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  lbpsMaxLoad  100  ${delta_create_psgrp}
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  lbpsMinLoad  0  ${delta_create_psgrp}
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  lbpsRTXMaxLoad  45  ${delta_create_psgrp}
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  lbpsRTXMinLoad  25  ${delta_create_psgrp}
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  lbpsPdcchLoadOffset  4  ${delta_create_psgrp}
    ${sw_splited}  Split String  ${active_sw_version}  _
    ${sw_prefix} = 	Get From List  ${sw_splited}  0
    Set Test Variable  ${sw_prefix}
    IF  '${sw_prefix}'!='SBTS23R2'
        admin.append parameter update to delta  ${PSGRP_DN}  lbpsGuardTimerNrAct  20  ${delta_create_psgrp}
        admin.append parameter update to delta  ${PSGRP_DN}  lbpsMaxLoadNrAct  40  ${delta_create_psgrp}
        admin.append parameter update to delta  ${PSGRP_DN}  lbpsMinNumEndcCapUeNrAct  0  ${delta_create_psgrp}
        admin.append parameter update to delta  ${PSGRP_DN}  lbpsMonWinNrAct  5  ${delta_create_psgrp}
        admin.append parameter update to delta  ${PSGRP_DN}  lbpsRetryTimerNrAct  5  ${delta_create_psgrp}
    END
    ${actMixedSOMethod_state}  Check parameter availability under LNBTS    actMixedSOMethod
    admin.append parameter update to delta  ${PSGRP_DN}  lbpsSOMethod
    ...  Legacy Mixed Switch Off  ${delta_create_psgrp}
    ${lbpsCellList}  Create Dictionary
    ${item}  Create List  1  100  100
    FOR  ${i}  ${cell}  IN ZIP  ${item}  ${selected_cells_IDs}
        IF  '${if_actExtCellSOMethod}'=='PASS'  Set To Dictionary  ${lbpsCellList}  lbpsUseExtConfig  false
        Set To Dictionary  ${lbpsCellList}  lbpsCellSOOrder=${i}
        Set To Dictionary  ${lbpsCellList}  lnCelId=${cell}
		Set To Dictionary  ${lbpsCellList}  lbpsUseExtConfig=false
        admin.append complex item to delta  ${PSGRP_DN}  list_name=lbpsCellList  &{lbpsCellList}  delta_id=${delta_create_psgrp}
    END
    Get Time And Date With Minute Offset  3minutes
    ${lbpsPeriodList}=  Create Dictionary
    Set To Dictionary  ${lbpsPeriodList}  lbpsDayOfWeek=${day}
    ${lbpsDuration}=  Get Regexp Matches  ${lbpsDuration}  \\d+
    Set To Dictionary  ${lbpsPeriodList}  lbpsDuration=${lbpsDuration[0]}
    Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeHour=${start_hour}
    Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeMinute=${start_minutes}
    Set To Dictionary  ${lbpsPeriodList}  lbpsSuspended=notSuspended
    admin.append complex item to delta  ${PSGRP_DN}  list_name=lbpsPeriodList  &{lbpsPeriodList}  delta_id=${delta_create_psgrp}
    admin.get delta  ${delta_create_psgrp}
    admin.save delta  ${RESULTS}/delta_create_psgrp_${PSGRP-ID}_LTE1203.json  ${delta_create_psgrp}
    Log  Activate Power Saving Group under MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  console=${true}
    admin.perform delta recommissioning  ${RESULTS}/delta_create_psgrp_${PSGRP-ID}_LTE1203.json  ${delta_create_psgrp}
    ${end_time}=  Add Time To Date  ${time_with_offset}  ${lbpsDuration[0]} minutes
    ${end_hour}=  Convert Date  ${end_time}  result_format=%H
    ${end_minutes}=  Convert Date  ${end_time}  result_format=%M
    Log  Power Saving Group time frame: ${start_hour}:${start_minutes}-${end_hour}:${end_minutes} (+${lbpsDuration[0]} minutes)  console=${true}
    Log  Affected cells in ${PSGRP-ID}:  console=${true}
    Log  - Reduced Energy Saving: LNCEL_R-${2nd_LNCELid} and LNCEL_R-${3rd_LNCELid}  console=${true}
    Log  - Energy Saving: LNCEL_R-${1st_LNCELid}  console=${true}

Create And Activate PSGRP For LTE3330
    [Documentation]
    ...  **Example of simple usage:**
    ...  Create And Activate PSGRP For LTE3330  ${bbPoolCellsList}  PSGRP-12  25min
    ...
    [Arguments]  ${bbPoolCellsList}  ${PSGRP-ID}  ${lbpsDuration}

    ${delta_create_psgrp}=  Set Variable  psgrp_create
    ${PSGRP_DN}=  Set Variable  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}
    admin.create delta  ${delta_create_psgrp}
    admin.append managed object to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  create  ${delta_create_psgrp}
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  lbpsCSONCtlEnabled  false  ${delta_create_psgrp}
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  lbpsLastCellMinLoad  0  ${delta_create_psgrp}
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  lbpsLastCellRTXMinLoad  0  ${delta_create_psgrp}
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  lbpsLastCellSOEnabled  true  ${delta_create_psgrp}
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  lbpsMaxLoad  100  ${delta_create_psgrp}
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  lbpsMinLoad  0  ${delta_create_psgrp}
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  lbpsPdcchLoadOffset  4  ${delta_create_psgrp}
    ${sw_splited}  Split String  ${active_sw_version}  _
    ${sw_prefix} = 	Get From List  ${sw_splited}  0
    Set Test Variable  ${sw_prefix}
    IF  '${if_actCo4g5g}'=='PASS' and '${sw_prefix}'!='SBTS23R2'
        admin.append parameter update to delta  ${PSGRP_DN}  lbpsGuardTimerNrAct  20  ${delta_create_psgrp}
        admin.append parameter update to delta  ${PSGRP_DN}  lbpsMaxLoadNrAct  40  ${delta_create_psgrp}
        admin.append parameter update to delta  ${PSGRP_DN}  lbpsMinNumEndcCapUeNrAct  0  ${delta_create_psgrp}
        admin.append parameter update to delta  ${PSGRP_DN}  lbpsMonWinNrAct  5  ${delta_create_psgrp}
        admin.append parameter update to delta  ${PSGRP_DN}  lbpsRetryTimerNrAct  5  ${delta_create_psgrp}
    END
    ${actMixedSOMethod_state} =  Check parameter availability under LNBTS    actMixedSOMethod
    IF  '${actMixedSOMethod_state}'=='PASS'  admin.append parameter update to delta  ${PSGRP_DN}  lbpsSOMethod
    ...  Legacy Mixed Switch Off  ${delta_create_psgrp}
    ${lbpsCellList}=  Create Dictionary
    ${qty}=  Get Length  ${bbPoolCellsList}
    FOR  ${i}  IN RANGE  ${qty}
        Set To Dictionary  ${lbpsCellList}  lbpsCellSOOrder=100
        IF  '${if_actExtCellSOMethod}'=='PASS'  Set To Dictionary  ${lbpsCellList}  lbpsUseExtConfig  false
        Set To Dictionary  ${lbpsCellList}  lnCelId=${bbPoolCellsList[${i}]}
        admin.append complex item to delta  ${PSGRP_DN}  list_name=lbpsCellList  &{lbpsCellList}  delta_id=${delta_create_psgrp}
    END
    Get Time And Date With Minute Offset  3minutes
    ${lbpsPeriodList}=  Create Dictionary
    Set To Dictionary  ${lbpsPeriodList}  lbpsDayOfWeek=${day}
    ${lbpsDuration}=  Get Regexp Matches  ${lbpsDuration}  \\d+
    Set To Dictionary  ${lbpsPeriodList}  lbpsDuration=${lbpsDuration[0]}
    Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeHour=${start_hour}
    Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeMinute=${start_minutes}
    Set To Dictionary  ${lbpsPeriodList}  lbpsSuspended=notSuspended
    admin.append complex item to delta  ${PSGRP_DN}  list_name=lbpsPeriodList  &{lbpsPeriodList}  delta_id=${delta_create_psgrp}
    admin.get delta  ${delta_create_psgrp}
    admin.save delta  ${RESULTS}/delta_create_psgrp_${PSGRP-ID}_LTE3330.json  ${delta_create_psgrp}
    Log  Activate Power Saving Group under MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  console=${true}
    admin.perform delta recommissioning  ${RESULTS}/delta_create_psgrp_${PSGRP-ID}_LTE3330.json  ${delta_create_psgrp}
    ${end_time}=  Add Time To Date  ${time_with_offset}  ${lbpsDuration[0]} minutes
    ${end_hour}=  Convert Date  ${end_time}  result_format=%H
    ${end_minutes}=  Convert Date  ${end_time}  result_format=%M
    Log To Console  Power Saving Group time frame: ${start_hour}:${start_minutes}-${end_hour}:${end_minutes} (+${lbpsDuration[0]} minutes)
    Log To Console  Affected cells in ${PSGRP-ID}:
    FOR  ${cell_id}  IN  @{bbPoolCellsList}
        Log To Console  Energy Saving: LNCEL-${cell_id}
    END

Create And Activate PSGRP For CB007416
    [Documentation]
    ...  **Example of simple usage:**
    ...  Create And Activate PSGRP For CB007416  ${1st_LNCEL_DN}  ${2nd_LNCEL_DN}  PSGRP-1  25min
    ...
    [Arguments]  ${1st_LNCELdistName}  ${2nd_LNCELdistName}  ${PSGRP-ID}  ${lbpsDuration}

    ${1st_LNCELid}=  Evaluate  re.search(r'LNCEL_R-(\\d+)','''${1st_LNCELdistName}''').group(1)  re
    ${2nd_LNCELid}=  Evaluate  re.search(r'LNCEL_R-(\\d+)','''${2nd_LNCELdistName}''').group(1)  re
    ${selected_cells_IDs}=  Create List  ${1st_LNCELid}  ${2nd_LNCELid}
    ${delta_create_psgrp}=  Set Variable  psgrp_create
    ${PSGRP_DN}=  Set Variable  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}
    admin.create delta  ${delta_create_psgrp}
    admin.append managed object to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  create  ${delta_create_psgrp}
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  lbpsCSONCtlEnabled  false  ${delta_create_psgrp}
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  lbpsLastCellMinLoad  0  ${delta_create_psgrp}
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  lbpsLastCellRTXMinLoad  0  ${delta_create_psgrp}
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  lbpsLastCellSOEnabled  true  ${delta_create_psgrp}
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  lbpsMaxLoad  100  ${delta_create_psgrp}
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  lbpsMinLoad  0  ${delta_create_psgrp}
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  lbpsPdcchLoadOffset  4  ${delta_create_psgrp}
    ${sw_splited}  Split String  ${active_sw_version}  _
    ${sw_prefix} = 	Get From List  ${sw_splited}  0
    Set Test Variable  ${sw_prefix}
    IF  '${if_actCo4g5g}'=='PASS' and '${sw_prefix}'!='SBTS23R2'
        admin.append parameter update to delta  ${PSGRP_DN}  lbpsGuardTimerNrAct  20  ${delta_create_psgrp}
        admin.append parameter update to delta  ${PSGRP_DN}  lbpsMaxLoadNrAct  40  ${delta_create_psgrp}
        admin.append parameter update to delta  ${PSGRP_DN}  lbpsMinNumEndcCapUeNrAct  0  ${delta_create_psgrp}
        admin.append parameter update to delta  ${PSGRP_DN}  lbpsMonWinNrAct  5  ${delta_create_psgrp}
        admin.append parameter update to delta  ${PSGRP_DN}  lbpsRetryTimerNrAct  5  ${delta_create_psgrp}
    END
    ${actMixedSOMethod_state} =  Check parameter availability under LNBTS    actMixedSOMethod
    IF  '${actMixedSOMethod_state}'=='PASS'  admin.append parameter update to delta  ${PSGRP_DN}  lbpsSOMethod
    ...  Legacy Mixed Switch Off  ${delta_create_psgrp}
    ${lbpsCellList}=  Create Dictionary
    ${item}=  Create List  1  2
    FOR  ${i}  ${cell}  IN ZIP  ${item}  ${selected_cells_IDs}
        IF  '${if_actExtCellSOMethod}'=='PASS'  Set To Dictionary  ${lbpsCellList}  lbpsUseExtConfig  false
        Set To Dictionary  ${lbpsCellList}  lbpsCellSOOrder=${i}
        Set To Dictionary  ${lbpsCellList}  lnCelId=${cell}
        admin.append complex item to delta  ${PSGRP_DN}  list_name=lbpsCellList  &{lbpsCellList}  delta_id=${delta_create_psgrp}
    END
    Get Time And Date With Minute Offset  3minutes
    ${lbpsPeriodList}=  Create Dictionary
    Set To Dictionary  ${lbpsPeriodList}  lbpsDayOfWeek=${day}
    ${lbpsDuration}=  Get Regexp Matches  ${lbpsDuration}  \\d+
    Set To Dictionary  ${lbpsPeriodList}  lbpsDuration=${lbpsDuration[0]}
    Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeHour=${start_hour}
    Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeMinute=${start_minutes}
    Set To Dictionary  ${lbpsPeriodList}  lbpsSuspended=notSuspended
    admin.append complex item to delta  ${PSGRP_DN}  list_name=lbpsPeriodList  &{lbpsPeriodList}  delta_id=${delta_create_psgrp}
    admin.get delta  ${delta_create_psgrp}
    admin.save delta  ${RESULTS}/delta_create_psgrp_${PSGRP-ID}_CB007416.json  ${delta_create_psgrp}
    Log  Activate Power Saving Group under MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  console=${true}
    admin.perform delta recommissioning  ${RESULTS}/delta_create_psgrp_${PSGRP-ID}_CB007416.json  ${delta_create_psgrp}
    ${end_time}=  Add Time To Date  ${time_with_offset}  ${lbpsDuration[0]} minutes
    ${end_hour}=  Convert Date  ${end_time}  result_format=%H
    ${end_minutes}=  Convert Date  ${end_time}  result_format=%M
    Log  Power Saving Group time frame: ${start_hour}:${start_minutes}-${end_hour}:${end_minutes} (+${lbpsDuration[0]} minutes)  console=${true}
    Log  Affected cells in ${PSGRP-ID}: LNCEL_R-${1stLNCELid} and LNCEL_R-${2ndLNCELid}  console=${true}


Create And Activate PSGRP For CB008800
    [Documentation]
    ...  **Example of simple usage:**
    ...  Create And Activate PSGRP For CB008800  ${1st_ES_LNCEL_DN}  ${1st_RES_LNCEL_DN}  PSGRP-12  45min  CB008800_Reconfig
    ...
    [Arguments]  ${1st_LNCELdistName}  ${2nd_LNCELdistName}  ${PSGRP-ID}  ${lbpsDuration}  ${additional_flag}

    ${1st_LNCELid}=  Evaluate  re.search(r'LNCEL_R-(\\d+)','''${1st_LNCELdistName}''').group(1)  re
    ${2nd_LNCELid}=  Evaluate  re.search(r'LNCEL_R-(\\d+)','''${2nd_LNCELdistName}''').group(1)  re
    ${selected_cells_IDs}=  Create List  ${1st_LNCELid}  ${2nd_LNCELid}
    ${delta_create_psgrp}=  Set Variable  psgrp_create
    ${PSGRP_DN}=  Set Variable  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}
    admin.create delta  ${delta_create_psgrp}
    admin.append managed object to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  create  ${delta_create_psgrp}
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  lbpsCSONCtlEnabled  false  ${delta_create_psgrp}
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  lbpsLastCellMinLoad  0  ${delta_create_psgrp}
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  lbpsLastCellRTXMinLoad  0  ${delta_create_psgrp}
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  lbpsLastCellSOEnabled  true  ${delta_create_psgrp}
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  lbpsMaxLoad  100  ${delta_create_psgrp}
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  lbpsMinLoad  0  ${delta_create_psgrp}
	admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  lbpsRTXMaxLoad  20  ${delta_create_psgrp}
	admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  lbpsRTXMinLoad  0  ${delta_create_psgrp}
	#line above added after PRPR779688 (with CB008800 lbpsRTXMaxLoad must be set)
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  lbpsPdcchLoadOffset  4  ${delta_create_psgrp}
    ${sw_splited}  Split String  ${active_sw_version}  _
    ${sw_prefix} = 	Get From List  ${sw_splited}  0
    Set Test Variable  ${sw_prefix}
    IF  '${if_actCo4g5g}'=='PASS' and '${sw_prefix}'!='SBTS23R2'
        admin.append parameter update to delta  ${PSGRP_DN}  lbpsGuardTimerNrAct  20  ${delta_create_psgrp}
        admin.append parameter update to delta  ${PSGRP_DN}  lbpsMaxLoadNrAct  40  ${delta_create_psgrp}
        admin.append parameter update to delta  ${PSGRP_DN}  lbpsMinNumEndcCapUeNrAct  0  ${delta_create_psgrp}
        admin.append parameter update to delta  ${PSGRP_DN}  lbpsMonWinNrAct  5  ${delta_create_psgrp}
        admin.append parameter update to delta  ${PSGRP_DN}  lbpsRetryTimerNrAct  5  ${delta_create_psgrp}
    END
    ${actMixedSOMethod_state} =  Check parameter availability under LNBTS    actMixedSOMethod
    IF  '${actMixedSOMethod_state}'=='PASS'  admin.append parameter update to delta  ${PSGRP_DN}  lbpsSOMethod
    ...  Legacy Mixed Switch Off  ${delta_create_psgrp}
    ${lbpsCellList}=  Create Dictionary
    ${item}=  Create List  1  2
    FOR  ${i}  ${cell}  IN ZIP  ${item}  ${selected_cells_IDs}
        Set To Dictionary  ${lbpsCellList}  lbpsUseExtConfig  true
        Set To Dictionary  ${lbpsCellList}  lbpsCellSOOrder=${i}
        Set To Dictionary  ${lbpsCellList}  lnCelId=${cell}
        admin.append complex item to delta  ${PSGRP_DN}  list_name=lbpsCellList  &{lbpsCellList}  delta_id=${delta_create_psgrp}
    END
    IF  '${additional_flag}'=='CB008800_Overlap'
        Overlapping Preiods For Same Cells  ${PSGRP-ID}
    ELSE
        Extended Load-Based Power Saving Configuration  ${additional_flag}  ${PSGRP-ID}
    END
    Get Time And Date With Minute Offset  3minutes
    ${lbpsPeriodList}=  Create Dictionary
    Set To Dictionary  ${lbpsPeriodList}  lbpsDayOfWeek=${day}
    ${lbpsDuration}=  Get Regexp Matches  ${lbpsDuration}  \\d+
    Set To Dictionary  ${lbpsPeriodList}  lbpsDuration=${lbpsDuration[0]}
    Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeHour=${start_hour}
    Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeMinute=${start_minutes}
    Set To Dictionary  ${lbpsPeriodList}  lbpsSuspended=notSuspended
    admin.append complex item to delta  ${PSGRP_DN}  list_name=lbpsPeriodList  &{lbpsPeriodList}  delta_id=${delta_create_psgrp}
    admin.get delta  ${delta_create_psgrp}
    admin.save delta  ${RESULTS}/delta_create_psgrp_${PSGRP-ID}_CB008800_${additional_flag}.json  ${delta_create_psgrp}
    Log  Activate Power Saving Group under MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  console=${true}
    admin.perform delta recommissioning  ${RESULTS}/delta_create_psgrp_${PSGRP-ID}_CB008800_${additional_flag}.json  ${delta_create_psgrp}
    ${end_time}=  Add Time To Date  ${time_with_offset}  ${lbpsDuration[0]} minutes
    ${end_hour}=  Convert Date  ${end_time}  result_format=%H
    ${end_minutes}=  Convert Date  ${end_time}  result_format=%M
    Log  Power Saving Group time frame: ${start_hour}:${start_minutes}-${end_hour}:${end_minutes} (+${lbpsDuration[0]} minutes)  console=${true}
    Log  Affected cells in ${PSGRP-ID}:  console=${true}
    Log  - Reduced Energy Saving: LNCEL_R-${2nd_LNCELid}  console=${true}
    Log  - Energy Saving: LNCEL_R-${1st_LNCELid}  console=${true}


Overlapping Preiods For Same Cells
    [Arguments]  ${PSGRP-ID}

    ${PSGRP_DN}=  Set Variable  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}
    ${delta_create_psgrp}=  Set Variable  psgrp_create
    ${lbpsCelPeriodList}=  Create Dictionary
    ${es_periods} =  Create List  5  17
    ${re_periods} =  Create List  7  19
    ${es_methods}=  Create List  Cell Switch Off  Cell Switch Off
    ${re_methods}=  Create List  Tx Paths Switch Off  Tx Paths Switch Off
    Get Time And Date With Minute Offset  3minutes
    FOR  ${es_method}  ${es_period}  IN ZIP   ${es_methods}  ${es_periods}
       Set To Dictionary  ${lbpsCelPeriodList}  lbpsCellDayOfWeek=${day}
       Set To Dictionary  ${lbpsCelPeriodList}  lbpsCellDuration=12
       Set To Dictionary  ${lbpsCelPeriodList}  lbpsCellSOMethod=${es_method}
       Get Time And Date With Minute Offset  ${es_period} minutes  12 minutes
       Set To Dictionary  ${lbpsCelPeriodList}  lbpsCellDayOfWeek=${day}
       Set To Dictionary  ${lbpsCelPeriodList}  lbpsCellStartTimeHour=${start_hour}
       Set To Dictionary  ${lbpsCelPeriodList}  lbpsCellStartTimeMinute=${start_minutes}
       Set To Dictionary  ${lbpsCelPeriodList}  lnCelId=${1st_ES_LNCEL_ID}
       Log  Power Saving for LNCEL_R-${1st_ES_LNCEL_ID} time frame: ${start_hour}:${start_minutes}-${end_hour}:${end_minutes}.  console=${true}
       Log  Switching Off Method: ${es_method}  console=${true}  console=${true}
       admin.append complex item to delta  ${PSGRP_DN}  list_name=lbpsCelPeriodList  &{lbpsCelPeriodList}  delta_id=${delta_create_psgrp}
    END
    FOR  ${re_method}  ${re_period}  IN ZIP   ${re_methods}  ${re_periods}
       Set To Dictionary  ${lbpsCelPeriodList}  lbpsCellDayOfWeek=${day}
       Set To Dictionary  ${lbpsCelPeriodList}  lbpsCellDuration=12
       Set To Dictionary  ${lbpsCelPeriodList}  lbpsCellSOMethod=${re_method}
       Get Time And Date With Minute Offset  ${re_period} minutes  12 minutes
       Set To Dictionary  ${lbpsCelPeriodList}  lbpsCellDayOfWeek=${day}
       Set To Dictionary  ${lbpsCelPeriodList}  lbpsCellStartTimeHour=${start_hour}
       Set To Dictionary  ${lbpsCelPeriodList}  lbpsCellStartTimeMinute=${start_minutes}
       Set To Dictionary  ${lbpsCelPeriodList}  lnCelId=${1st_RES_LNCEL_ID}
       Log  Power Saving for LNCEL_R-${1st_RES_LNCEL_ID} time frame: ${start_hour}:${start_minutes}-${end_hour}:${end_minutes}.  console=${true}
       Log  Switching Off Method: ${re_method}  console=${true}  console=${true}
       admin.append complex item to delta  ${PSGRP_DN}  list_name=lbpsCelPeriodList  &{lbpsCelPeriodList}  delta_id=${delta_create_psgrp}
    END


Create And Activate RMOD deepSleepTimeSchedule
    [Documentation]
    ...  **Example of simple usage:**
    ...  Create And Activate deepSleepTimeSchedule and advanceTimeForRURestore for selected RMOD
    [Arguments]  ${selected_RMOD}  ${TimeForRURestore}  ${win_duration}

    ${delta}  Set Variable  delta_create_deepSleep
    ${deepsleepschedule_DN}  Set Variable  MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/${selected_RMOD}
    admin.Create Delta  ${delta}
    admin.Append Managed Object To Delta  ${deepsleepschedule_DN}  update  ${delta}
    admin.Append Parameter Update To Delta  ${deepsleepschedule_DN}  advanceTimeForRURestore  ${TimeForRURestore}  ${delta}
    admin.Append Parameter Update To Delta  ${deepsleepschedule_DN}  energySavingMode  DEEPSLEEP  ${delta}
    Get Time And Date With Minute Offset  3minutes
    ${deepSleepTimeSchedule}  Create Dictionary
    Set To Dictionary  ${deepSleepTimeSchedule}  dayOfWeek=${day}
    Set To Dictionary  ${deepSleepTimeSchedule}  startTime=${start_hour}:${start_minutes}
    Set To Dictionary  ${deepSleepTimeSchedule}  windowDuration=${win_duration}
    admin.Append Complex Item To Delta  ${deepsleepschedule_DN}  list_name=deepSleepTimeSchedule  &{deepSleepTimeSchedule}  delta_id=${delta}
    admin.Get Delta  ${delta}
    admin.Save Delta  ${RESULTS}/delta_create_deepsleep.json  ${delta}
    Log  Activate RMOD deepSleepTimeSchedule MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${selected_RMOD}  console=true
    admin.Perform Delta Recommissioning  ${RESULTS}/delta_create_deepsleep.json  ${delta}
    ${end_time}  Add Time To Date  ${time_with_offset}  ${win_duration} minutes
    ${end_hour}  Convert Date  ${end_time}  result_format=%H
    ${end_minutes}  Convert Date  ${end_time}  result_format=%M
    Log  Power Saving Group time frame: ${start_hour}:${start_minutes}-${end_hour}:${end_minutes} (+${win_duration} minutes)  console=true


Remove RMOD deepSleepTimeSchedule
    [Documentation]
    ...  **Example of simple usage:**
    ...  Removal of deepSleepTimeSchedule and advanceTimeForRURestore for selected RMOD
    [Arguments]  ${selected_RMOD}

    ${delta}  Set Variable  delta_remove_deepSleep
    ${deepsleepschedule_DN}  Set Variable  MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/${selected_RMOD}
    admin.Create Delta  ${delta}
    admin.Append Managed Object To Delta  ${deepsleepschedule_DN}  update  ${delta}
    admin.Append Parameter Delete To Delta  ${deepsleepschedule_DN}  advanceTimeForRURestore  ${delta}
    admin.Append Parameter Delete To Delta  ${deepsleepschedule_DN}  deepSleepTimeSchedule  ${delta}
    admin.Get Delta  ${delta}
    admin.Save Delta  ${RESULTS}/delta_remove_deepsleep.json  ${delta}
    Log  Removing RMOD deepSleepTimeSchedule MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${selected_RMOD}  console=true
    admin.Perform Delta Recommissioning  ${RESULTS}/delta_remove_deepsleep.json


Check RU state for DEEPSLEEP
    [Arguments]  ${selected_rmod}  ${expected_power_state}

    ${bts_info}  admin.Get Bts Info
    FOR  ${rmod}  IN  @{bts_info['radioModules']['rmod']}
        ${rmod_states}  Get From Dictionary  ${rmod}  status
        ${operational_state}  Get From Dictionary  ${rmod_states}  operationalState
        IF  '${rmod['id']['configuration']}'=='${selected_rmod}'
            Run Keyword And Ignore Error  Should Be Equal As Strings  ${operational_state}  disabled  ignore_case=True
        ELSE
            Run Keyword And Ignore Error  Should Be Equal As Strings  ${operational_state}  enabled  ignore_case=True
        END
        ${power_state}  Get From Dictionary  ${rmod_states}  powerState
        IF  '${rmod['id']['configuration']}'=='${selected_rmod}'  Should Be Equal As Strings  ${power_state}  ${expected_power_state}
        Log To Console  State of ${rmod['id']['configuration']} is correct
    END


Change Energy Saving Mode Back To Normal
    [Documentation]  Changes energysavingmode of provided RMOD back to NORMAL. Used in CB010766.
    [Arguments]  ${selected_RMOD}

    ${deepsleepschedule_DN}  Set Variable  MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/${selected_RMOD}
    Set Feature Under Given Object  ${deepsleepschedule_DN}  energySavingMode  NORMAL


Extended Load-Based Power Saving Configuration
    [Documentation]  Handling new parameters under PSGRP introduced in CB008800.
    [Arguments]  ${additional_flag}  ${PSGRP-ID}

    ${PSGRP_DN}=  Set Variable  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}
    ${delta_create_psgrp}=  Set Variable  psgrp_create
    ${lbpsCelPeriodList}=  Create Dictionary
    ${switch_off_methods}=  Create List  Cell Switch Off  Tx Paths Switch Off
    Get Time And Date With Minute Offset  3minutes
    FOR  ${switch_off_method}  ${cell_ID}  IN ZIP  ${switch_off_methods}  ${selected_cells_IDs}
        Set To Dictionary  ${lbpsCelPeriodList}  lbpsCellDayOfWeek=${day}
        IF  '${additional_flag}'=='CB008800' or '${additional_flag}'=='Legacy'
            Set To Dictionary  ${lbpsCelPeriodList}  lbpsCellDuration=20
        ELSE IF  '${additional_flag}'=='CB008800_Reconfig'
            Set To Dictionary  ${lbpsCelPeriodList}  lbpsCellDuration=40
        END
        Set To Dictionary  ${lbpsCelPeriodList}  lbpsCellSOMethod=${switch_off_method}
        IF  ('${switch_off_method}' == 'Cell Switch Off') and ('${additional_flag}'=='CB008800' or '${additional_flag}'=='Legacy')
            Get Time And Date With Minute Offset  5 minutes  20 minutes
            Set To Dictionary  ${lbpsCelPeriodList}  lbpsCellDayOfWeek=${day}
            Set To Dictionary  ${lbpsCelPeriodList}  lbpsCellStartTimeHour=${start_hour}
            Set To Dictionary  ${lbpsCelPeriodList}  lbpsCellStartTimeMinute=${start_minutes}
            Log  Power Saving for LNCEL_R-${cell_ID} time frame: ${start_hour}:${start_minutes}-${end_hour}:${end_minutes}.  console=${true}
            Log  Switching Off Method: ${switch_off_method}  console=${true}  console=${true}
        ELSE IF  ('${switch_off_method}' == 'Tx Paths Switch Off') and ('${additional_flag}'=='CB008800' or '${additional_flag}'=='Legacy')
            Get Time And Date With Minute Offset  7 minutes  20 minutes
            Set To Dictionary  ${lbpsCelPeriodList}  lbpsCellDayOfWeek=${day}
            Set To Dictionary  ${lbpsCelPeriodList}  lbpsCellStartTimeHour=${start_hour}
            Set To Dictionary  ${lbpsCelPeriodList}  lbpsCellStartTimeMinute=${start_minutes}
            Log  Power Saving for LNCEL_R-${cell_ID} time frame: ${start_hour}:${start_minutes}-${end_hour}:${end_minutes}.  console=${true}
            Log  Switching Off Method: ${switch_off_method}  console=${true}
        ELSE IF  '${switch_off_method}' == 'Cell Switch Off' and '${additional_flag}'=='CB008800_Reconfig'
            Get Time And Date With Minute Offset  5 minutes  40 minutes
            Set To Dictionary  ${lbpsCelPeriodList}  lbpsCellDayOfWeek=${day}
            Set To Dictionary  ${lbpsCelPeriodList}  lbpsCellStartTimeHour=${start_hour}
            Set To Dictionary  ${lbpsCelPeriodList}  lbpsCellStartTimeMinute=${start_minutes}
            Log  Power Saving for LNCEL_R-${cell_ID} time frame: ${start_hour}:${start_minutes}-${end_hour}:${end_minutes}.  console=${true}
            Log  Switching Off Method: ${switch_off_method}  console=${true}  console=${true}
        ELSE IF  '${switch_off_method}' == 'Tx Paths Switch Off' and '${additional_flag}'=='CB008800_Reconfig'
            Get Time And Date With Minute Offset  7 minutes  40 minutes
            Set To Dictionary  ${lbpsCelPeriodList}  lbpsCellDayOfWeek=${day}
            Set To Dictionary  ${lbpsCelPeriodList}  lbpsCellStartTimeHour=${start_hour}
            Set To Dictionary  ${lbpsCelPeriodList}  lbpsCellStartTimeMinute=${start_minutes}
            Log  Power Saving for LNCEL_R-${cell_ID} time frame: ${start_hour}:${start_minutes}-${end_hour}:${end_minutes}.  console=${true}
            Log  Switching Off Method: ${switch_off_method}  console=${true}
        END
        Set To Dictionary  ${lbpsCelPeriodList}  lnCelId=${cell_ID}
        admin.append complex item to delta  ${PSGRP_DN}  list_name=lbpsCelPeriodList  &{lbpsCelPeriodList}  delta_id=${delta_create_psgrp}
    END


Suspend PowerSaving
    [Arguments]  ${PSGRP-ID}

    ${PSGRP_DN}=  Set Variable  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}
    ${psgrpParameters}=  admin.get managed objects  PSGRP_A
    ${lbpsPeriodListToSuspend}=  Create Dictionary
    ${delta_psgrpSuspend}=  Set Variable  psgrpSuspend
    admin.create delta  ${delta_psgrpSuspend}
    FOR  ${psgrpParameter}  IN  @{psgrpParameters}
          ${lbpsPeriodList}=  Get From Dictionary  ${psgrpParameter['parameters']}  lbpsPeriodList
          Set Test Variable   ${lbpsPeriodList}
    END
    FOR  ${parameter}  IN  @{lbpsPeriodList}
        ${lbpsDayOfWeek}=  Get From Dictionary  ${parameter}  lbpsDayOfWeek
        ${lbpsDuration}=  Get From Dictionary  ${parameter}  lbpsDuration
        ${lbpsStartTimeHour}=  Get From Dictionary  ${parameter}  lbpsStartTimeHour
        ${lbpsStartTimeMinute}=  Get From Dictionary  ${parameter}  lbpsStartTimeMinute
        Set To Dictionary  ${lbpsPeriodListToSuspend}  lbpsDayOfWeek=${lbpsDayOfWeek}
        Set To Dictionary  ${lbpsPeriodListToSuspend}  lbpsDuration=${lbpsDuration}
        Set To Dictionary  ${lbpsPeriodListToSuspend}  lbpsStartTimeHour=${lbpsStartTimeHour}
        Set To Dictionary  ${lbpsPeriodListToSuspend}  lbpsStartTimeMinute=${lbpsStartTimeMinute}
        Set To Dictionary  ${lbpsPeriodListToSuspend}  lbpsSuspended=suspended
        admin.append complex item to delta  ${PSGRP_DN}  list_name=lbpsPeriodList  &{lbpsPeriodListToSuspend}  delta_id=${delta_psgrpSuspend}
    END
    admin.get delta  ${delta_psgrpSuspend}
    admin.save delta  ${RESULTS}/delta_psgrpSuspend_CB008800.json  ${delta_psgrpSuspend}
    admin.perform delta recommissioning  ${RESULTS}/delta_psgrpSuspend_CB008800.json  ${delta_psgrpSuspend}
    Log  ${PSGRP-ID} has been suspended  console=${true}


Get LNCEL ID List
    ${lncels_params}  admin.Get Parameters For All  class_name=LNCEL
    ${lncels}  Create List
    FOR  ${cell}  IN  @{lncels_params}
        Append To List  ${lncels}  ${cell['id']}
    END

    RETURN  ${lncels}


Get LNCEL ID List Without IoT Cells
    ${lncels_params}  admin.Get Parameters For All  class_name=LNCEL
    ${lncels}  Create List
    FOR  ${lncell}  IN  @{lncels_params}
        ${cell_id}  Set Variable  ${lncell['id']}
        ${nb_iot_cell}  Set Variable  ${lncell['nbIoTCell']}
        ${is_iot_cell}  Set Variable If  ${nb_iot_cell} != None  ${TRUE}  ${FALSE}
        IF  not ${is_iot_cell}  Append To List  ${lncels}  ${cell_id}
    END

    RETURN  ${lncels}


Get NRCEL ID List Without IoT Cells
    ${nrcels_params}  admin.Get Parameters For All  class_name=NRCEL
    ${nrcels}  Create List
    FOR  ${nrcell}  IN  @{nrcels_params}
        ${cell_id}  Set Variable  ${nrcell['id']}
        ${nb_iot_cell}  Set Variable  ${nrcell['nbIoTCell']}
        ${is_iot_cell}  Set Variable If  ${nb_iot_cell} != None  ${TRUE}  ${FALSE}
        IF  not ${is_iot_cell}  Append To List  ${nrcels}  ${cell_id}
    END

    RETURN  ${nrcels}


Get Variable Type
    [Arguments]  ${variable}

    ${type}  Evaluate  type(${variable}).__name__
    ${type_to_str}  Convert To String  ${type}

    RETURN  ${type_to_str}


Get Time And Date With Minute Offset
    [Arguments]  ${increase_time}=3 minutes  ${minutes_from_increased_time}=0 minutes
    [Documentation]  Keyword returns date and time with 3 minutes offset

    ${time}  Get Time  epoch
    ${time_with_offset}  Add Time To Date  ${time}  ${increase_time}
    ${day}  Convert Date  ${time_with_offset}  result_format=%a
    ${start_hour}  Convert Date  ${time_with_offset}  result_format=%H
    ${start_minutes}  Convert Date  ${time_with_offset}  result_format=%M
    ${end_time}  Add Time To Date  ${time_with_offset}  ${minutes_from_increased_time}
    ${end_hour}  Convert Date  ${end_time}  result_format=%H
    ${end_minutes}  Convert Date  ${end_time}  result_format=%M
    Set Test Variable  ${day}
    Set Test Variable  ${start_hour}
    Set Test Variable  ${start_minutes}
    Set Test Variable  ${time_with_offset}
    Set Test Variable  ${end_time}
    Set Test Variable  ${end_hour}
    Set Test Variable  ${end_minutes}


Normalize Hour And Minutes
    [Documentation]
    ...  Given base hour (0-23), base minutes (0-59) and minutes to add, returns normalized (hour, minutes)
    ...  so that minutes are in 0-59 and hour in 0-23. E.g. 13, 55, +20 -> 14, 15 (14:15 instead of 13:75).
    [Arguments]  ${base_hour}  ${base_minutes}  ${minutes_to_add}

    ${total_minutes}  Evaluate  int(${base_minutes}) + int(${minutes_to_add})
    ${normalized_minutes}  Evaluate  ${total_minutes} % 60
    ${hour_carry}  Evaluate  ${total_minutes} // 60
    ${normalized_hour}  Evaluate  (int(${base_hour}) + int(${hour_carry})) % 24

    RETURN  ${normalized_hour}  ${normalized_minutes}


Sleep Until Given Date
    [Documentation]  This KW puts the test to sleep until the given ${sleep_end_time} is reached.
    [Arguments]  ${sleep_end_time}

    ${current_time}  Get Time  epoch
    ${remaining_sleep_time}  Subtract Date From Date  ${sleep_end_time}  ${current_time}
    IF  ${remaining_sleep_time}<=0
        Log  No sleep required as the current timestamp has passed the desired sleep end date\n  console=true
    ELSE
        Log  Test will be paused for ${remaining_sleep_time} seconds\n  console=true
        Sleep  ${remaining_sleep_time}
    END


Check Chosen Cells Administrative State
    [Documentation]  Find cells which administrative states should be checked.
    [Arguments]  ${cell_path}  ${cell_technology}  ${expected_administrative_state}

    ${cells_list_2}  Get Cell List                                     # create new list with every cell in BTS
    ${cells_on_tech}  Set Variable  ${cells_list_2}[cells][${cell_technology}]
    FOR  ${cell}  IN  @{cells_on_tech}   # get cell from given technology, e.g. lte
        IF  '${cell_path}'=='${cell['id']['internal']}'  Check If Cell Chosen State Is As Expected  ${cell}
        ...  administrativeState  ${expected_administrative_state}
    END


Check Chosen Cells Operational State
    [Documentation]  Find cells which operational states should be checked.
    [Arguments]  ${cell_path}  ${cell_technology}  ${expected_operational_state}

    ${cells_list_2}  admin.Get Cell List
    ${cells_on_tech}  Set Variable  ${cells_list_2}[cells][${cell_technology}]
    FOR  ${cell}  IN  @{cells_on_tech}
        IF  '${cell_path}'=='${cell['id']['internal']}'  Check If Cell Chosen State Is As Expected  ${cell}
        ...  operationalState  ${expected_operational_state}
    END


Check Chosen Cells Operational State multiple cells
    [Documentation]    Find cells which operational states should be checked
    [Arguments]  ${cell_path_1}  ${cell_path_2}  ${cell_technology}  ${expected_operational_state}

    ${cells_list_2}  admin.Get Cell List
    ${cells_on_tech}  Set Variable  ${cells_list_2}[cells][${cell_technology}]
    FOR  ${cell}  IN  @{cells_on_tech}
        IF  '${cell_path_1}'=='${cell['id']['internal']}'  Check If Cell Chosen State Is As Expected  ${cell}
        ...  operationalState  ${expected_operational_state}
        IF  '${cell_path_2}'=='${cell['id']['internal']}'  Check If Cell Chosen State Is As Expected  ${cell}
        ...  operationalState  ${expected_operational_state}
    END


Check If Cell Chosen State Is As Expected
    [Documentation]    Check if cells operational state is equal expected operational state.
    [Arguments]  ${cell_object}  ${state_type}  ${expected_cell_state}

    ${cell_states}  Get From Dictionary  ${cell_object}  status
    ${chosen_state}  Get From Dictionary  ${cell_states}  ${state_type}
    ${chosen_state}  Evaluate  "${cell_object['status']['${state_type}']}".upper().replace(' ','')
    Should Be Equal  ${chosen_state}  ${expected_cell_state}
    ${ignore}  ${cell_r}  Split String From Right  ${cell_object['id']['internal']}  separator=/  max_split=1
    Log  Cell ${cell_r} is as expected ${state_type}:${expected_cell_state}  console=${true}


Check If Chosen Cell State Is As Expected
    [Documentation]    Check if cells operational state is equal expected operational state.
    [Arguments]  ${cell_object}  ${state_type}  ${expected_cell_state}

    ${cell_states}  Get From Dictionary  ${cell_object}  status
    ${chosen_state}  Get From Dictionary  ${cell_states}  ${state_type}
    ${chosen_state}  Evaluate  "${cell_object['status']['${state_type}']}".upper().replace(' ','')
    Should Be Equal  ${chosen_state}  ${expected_cell_state}
    ${ignore}  ${cell}  Split String From Right  ${cell_object['id']['configuration']}  separator=/  max_split=1
    Log  Cell ${cell} is as expected ${state_type}:${expected_cell_state}  console=${true}


Check If WNCEL Is As Expected
    [Arguments]  ${WNCEL_ID}  ${state}  ${value}

    ${bts_info}=  admin.get bts info
    FOR  ${i}  IN  @{bts_info['cells']['wcdma']}
        IF  '${WNCEL_ID}'=='${i['cellId']}'  Check If Chosen Cell State Is As Expected  ${i}  ${state}  ${value}
    END

Get WNCEL IDs
    ${bts_info}=  admin.get bts info
    ${WNCEL_IDs}=  Create List
    FOR  ${i}  IN  @{bts_info['cells']['wcdma']}
        Append To List  ${WNCEL_IDs}  ${i['cellId']}
    END

    RETURN  ${WNCEL_IDs}


Check Cells Status After Expected Timer For Selected Technology
    [Documentation]  Check if cells are disabled after given time in intshut parameter
    [Arguments]  ${cell_path}  ${RAT}  ${expected_operational_state}  ${repetition}

    Wait Until keyword Succeeds  ${repetition}x  30s
    ...  Check Chosen Cell And Other Cells Operational State  ${cell_path}  ${RAT}  ${expected_operational_state}


Check Chosen Cell And Other Cells Operational State
    [Documentation]  Find cells which operational states should be checked
    [Arguments]  ${cell_path}  ${cell_RAT}  ${expected_cell_state}

    ${cells_list_2}  Get Cell List                                 # create new list with every cell in BTS
    FOR  ${cell}  IN  @{cells_list_2['cells']['${cell_RAT}']}      # get cell from given technology, e.g. lte
        IF  '${cell_path}'!='${cell['id']['internal']}' and '${cell_RAT}'!='gsm'
            Check If Cell Chosen State Is As Expected  ${cell}  operationalState  ENABLED
        ELSE
            Check If Cell Chosen State Is As Expected  ${cell}  operationalState  ${expected_cell_state}
        END
    END


#Set Parameter Under LNBTS/NRBTS
#    [Arguments]  ${object}  ${parameter}  ${value}
#    ${parameter_name_delta}=  Set Variable  ${object}_${parameter}_${value}
#    admin.create delta  ${parameter_name_delta}
#    ${distName}=  Set Variable If  '${object}'=='LNBTS'  MRBTS-${ENB_ID}/LNBTS-${ENB_ID}  '${object}'=='NRBTS'  MRBTS-${ENB_ID}/NRBTS-${ENB_ID}
#    admin.append parameter update to delta  ${distName}  ${parameter}  ${value}  ${parameter_name_delta}
#    admin.get delta  ${parameter_name_delta}
#    admin.save delta  ${RESULTS}/delta_${object}_${parameter}_${value}.json  ${parameter_name_delta}
#    admin.perform delta recommissioning  ${RESULTS}/delta_${object}_${parameter}_${value}.json  ${parameter_name_delta}


Check Power Saving
    [Documentation]  Check if both cell operational state and energysaving are as expected
    ...              EDIT: alebek 20.10.2020 - check channels state according to CAS-312587-X1G8  CAS-299342-W4J7
    ...              EDIT: alebek 13.04.2021 - refactored to switch to ute_admin library
    [Arguments]   ${cell}   ${expected_operationalState}  ${expected_energySavingState}

    ${cellsStates}  admin.get parameters for all  LNCEL
    FOR  ${cellState}  IN  @{cellsStates}
        ${cellId}  Split String  ${cellState.id}  -
        ${operationalState}  Evaluate  "${cellState.operationalState}".upper()
        ${energySavingState}  Evaluate  "${cellState.energySavingState}".upper()
        IF  '${cellId[-1]}'=='${cell}'  Should Be True
        ...  '${operationalState}'=='${expected_operationalState}' and '${energySavingState}'=='${expected_energySavingState}'
    END


Check Power Saving NR
    [Documentation]  Checks NR cell PS status
    [Arguments]   ${cell}   ${expected_operationalState}  ${expected_energySavingState}

    ${cellsStates}  Get Cells Info  nr
    FOR  ${cellState}  IN  @{cellsStates}
        ${cellId}  Set Variable  ${cellState['globalCellId']}
        ${operational_state}  Evaluate  "${cellState['status']['operationalState']}".upper()
        ${energysaving_cell_state}  Evaluate  "${cellState['energySavingState']}".upper()
        IF  '${cellId}'=='${cell}'  Should Be True
        ...  '${operational_state}'=='${expected_operationalState}' and '${energysaving_cell_state}'=='${expected_energySavingState}'
    END


Ignore IoT Cells
    [Arguments]  ${ALIAS}=default

    ${cells_list}  admin.Get Cell List  alias=${ALIAS}
    FOR  ${cell}  IN  @{cells_list['cells']['lte']}
        ${narrowbandIotMode}  Get From Dictionary  ${cell}  narrowbandIotMode
        IF  '${narrowbandIotMode}'!='disabled'  Remove Values From List  ${cells_list['cells']['lte']}  ${cell}
    END

    RETURN  ${cells_list['cells']['lte']}


Check If Not Energy Saving Cells Are Enabled
    [Documentation]  EDA Action for 01753294_ST
    [Arguments]   ${expected_operationalState}  ${expected_energysavingState}  ${cells_DNs}

    ${cells_list}  admin.get cell list
    ${cells_list['cells']['lte']}  Ignore PowerSaving IoT Cells
    ${4G_5G_cells}  Combine lists  ${cells_list['cells']['lte']}  ${cells_list['cells']['nr']}
    ${3G_2G_cells}  Combine lists  ${cells_list['cells']['wcdma']}  ${cells_list['cells']['gsm']}
    Log  \n  console=True
    FOR  ${cell}  IN  @{4G_5G_cells}
        ${cell_id}  Get from dictionary  ${cell}  id
        ${cell_path}  Get from dictionary  ${cell_id}  internal
        ${operational_state}  Evaluate  "${cell['status']['operationalState']}".upper()
        ${energy_saving_state}  Evaluate  "${cell['energySavingState']}".upper()
        Check If PS Cell  ${cell_path}  ${cells_DNs}
        Log   Cell: ${cell_path} checked if onAir    INFO   console=True
        Log   Cell: ${ps_cell_verdict}    INFO   console=True
        Log   Cell's states: ${operational_state}, ${energy_saving_state}    INFO   console=True
        IF  '${ps_cell_verdict}'=='isNotPScell'  Should Be True
        ...  '${operational_state}'=='${expected_operationalState}' and '${energy_saving_state}'=='${expected_energysavingState}'
    END
    FOR  ${cell}  IN  @{3G_2G_cells}
        ${cell_id}  Get From Dictionary  ${cell}  id
        ${cell_path}  Get From Dictionary  ${cell_id}  internal
        ${operational_state}  Evaluate  "${cell['status']['operationalState']}".upper()
        Should Be True  '${operational_state}'=='${expected_operationalState}'
    END


Check If PS Cell
    [Arguments]   ${checked_path}  ${path_list}

    ${list_length}=  Get Length  ${path_list}
    FOR  ${i}  IN RANGE  ${list_length}
        ${path}=    Get From List    ${path_list}    ${i}
        ${ps_cell_verdict}=  Set Variable If  '${path}'=='${checked_path}'  isPScell  isNotPScell
        Set Test Variable  ${ps_cell_verdict}
        Exit For Loop IF    '${ps_cell_verdict}' == 'isPScell'
    END


Set Feature Under Given Object
    [Documentation]  Keyword sets indicated valuse for chosen feature under given object, object should be given as
    ...  in the dist name form
    ...  Example of usage:
    ...  Set Feature Under Given Object  ${distName_of_the_object}  ${feature_flag}  ${feature_flag_value}
    [Arguments]  ${object_DN}  ${feature_flags}  ${value}

    ${feature_flag_delta}  Set Variable  ${feature_flags}_${value}
    admin.Create Delta  ${feature_flag_delta}
    Check Activation Flags  ${feature_flags}  ${value}  ${feature_flag_delta}  ${object_DN}
    admin.Get Delta  ${feature_flag_delta}
    admin.Save Delta  ${RESULTS}/delta_${feature_flags}_${value}.json  ${feature_flag_delta}
    admin.Perform Delta Recommissioning  ${RESULTS}/delta_${feature_flags}_${value}.json  ${SKIP_PARAMETER_RELATION_ERRORS}


Set Parameters From Dictionary Under Given Object
    [Documentation]  Sets multiple parameters under the given object using a dictionary.
    ...  Dictionary keys are parameter names, values are parameter values.
    ...  Creates a delta, applies all parameter updates, then get delta, save delta and perform delta recommissioning.
    ...  Example of usage:
    ...  ${params}=  Create Dictionary  enableGrflShdn  true  shutdownStepAmount  2  shutdownWindow  60
    ...  Set Parameters From Dictionary Under Given Object  ${LNBTS_DistName}  ${params}
    ...  Optional: Set Parameters From Dictionary Under Given Object  ${LNBTS_DistName}  ${params}  delta_lnbts_params.json
    [Arguments]  ${object_DN}  ${parameters_dict}

    ${params_delta}  Set Variable  params_dict_update
    admin.Create Delta  ${params_delta}
    FOR  ${param}  ${value}  IN  &{parameters_dict}
        Log To Console  Set ${param} = ${value} on ${object_DN}
        admin.Append Parameter Update To Delta  ${object_DN}  ${param}  ${value}  ${params_delta}
    END
    admin.Get Delta  ${params_delta}
    admin.Save Delta  ${RESULTS}/delta_params.json  ${params_delta}
    admin.Perform Delta Recommissioning  ${RESULTS}/delta_params.json  true


Check Activation Flags
    [Documentation]  The keyword checks whether a single flag or multiple flags were passed.
    ...  If a single value was passed, its type is changed to a list.
    [Arguments]  ${feature_flags}  ${value}  ${feature_flag_delta}  ${object_DN}

    ${flags_before}  Set Variable  ${feature_flags}
    ${flags}  Set Variable    ${feature_flags}
    IF  $flags.__class__ != list
        ${flags}  Evaluate  "${flags}".split()
    ELSE
        ${flags}  Set Variable  ${flags_before}
    END
    FOR  ${flag}  IN  @{flags}
        Log To Console  Set ${flag} on ${value}
        admin.Append Parameter Update To Delta  ${object_DN}  ${flag}  ${value}  ${feature_flag_delta}
    END


Set Dist Name For Objects
    Check which RAT are on given TestLine
    IF  '${IF_LTE_EXIST}'=='EXIST'  Set Test Variable  ${LNBTS_DistName}  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}
    IF  '${IF_NR_EXIST}'=='EXIST'  Set Test Variable  ${NRBTS_DistName}  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    Set Test Variable  ${FEATCADM_DistName}  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    Set Test Variable  ${FEATLADM_DistName}  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1/FEATLADM-1


Get Parameter Value Under LNBTS
    [Arguments]  ${parameter}

   ${lnbts_act_list}  admin.get managed objects  LNBTS_A
    FOR  ${act}  IN  @{lnbts_act_list}
         ${parameter_value}  Evaluate  str(${act['parameters']['${parameter}']})
        IF    '${parameter_value}' == '${True}'
            ${feature_status}  Set Variable  true
        ELSE IF    '${parameter_value}' == '${False}'
            ${feature_status}  Set Variable  false
        END
    END
    Log  Parameter ${parameter} is ${feature_status}!  console=true

    RETURN  ${feature_status}


Get Specific Parameter Value From LNBTS
    [Arguments]   ${parameter}

    ${lnbts_param_list}  admin.Get Managed Objects  LNBTS_A
    ${selected_param_value}  Get From Dictionary  ${lnbts_param_list[0]['parameters']}  ${parameter}

    RETURN  ${selected_param_value}


Get Parameter Value Under NRBTS
    [Arguments]  ${parameter}

    ${nrbts_act_list}=  admin.get managed objects  NRBTS_A
    FOR  ${act}  IN  @{nrbts_act_list}
        IF  '${act['parameters']['${parameter}']}'=='${True}'
            ${feature_status}  Set Variable  true
        ELSE IF  '${act['parameters']['${parameter}']}'=='${False}'
            ${feature_status}  Set Variable  false
        END
    END
    Log  Parameter ${parameter} is ${feature_status}!  console=true

    RETURN  ${feature_status}


Get Cells IDs From Cellmapping
    [Documentation]
    ${lnCellIds}=  Create List
    ${nrCellIds}=  Create List
    ${wnCellIds}=  Create List
    ${gnCellIds}=  Create List
    ${lncells}=  admin.get managed objects  LNCEL_A
    ${nrcells}=  admin.get managed objects  NRCELL_A
    ${wncells}=  admin.get managed objects  WNCEL_A
    ${gncells}=  admin.get managed objects  GNCEL_A
    FOR  ${cell}  IN  @{lncells}
        ${distName}=  Get From Dictionary  ${cell}  distName
        ${LNCELL_ID}=  Evaluate  re.search(r'LNCEL_A-(\\d+)','''${distName}''').group(1)  re
        Append To List  ${lnCellIds}  ${LNCELL_ID}
        Set Test Variable  ${lnCellIds}
    END
    FOR  ${cell}  IN  @{nrcells}
        ${distName}=  Get From Dictionary  ${cell}  distName
        ${NRCELL_ID}=  Evaluate  re.search(r'NRCELL_A-(\\d+)','''${distName}''').group(1)  re
        Append To List  ${nrCellIds}  ${NRCELL_ID}
        Set Test Variable  ${nrCellIds}
    END
    FOR  ${cell}  IN  @{wncells}
        ${lCelwDN}=  Get From Dictionary  ${cell['parameters']}  lCelwDN
        ${WNCELL_ID}=  Evaluate  re.search(r'LCELW_A-(\\d+)','''${lCelwDN}''').group(1)  re
        Append To List  ${wnCellIds}  ${WNCELL_ID}
        Set Test Variable  ${wnCellIds}
    END
    FOR  ${cell}  IN  @{gncells}
        ${distName}=  Get From Dictionary  ${cell}  distName
        ${GNCELL_ID}=  Evaluate  re.search(r'GNCEL_A-(\\d+)','''${distName}''').group(1)  re
        Append To List  ${gnCellIds}  ${GNCELL_ID}
        Set Test Variable  ${gnCellIds}
    END

    RETURN  ${lnCellIds}  ${nrCellIds}  ${wnCellIds}  ${gnCellIds}


Get Cells IDs From Cellmapping LTE
    [Documentation]
    ${lnCellIds}=  Create List
    ${nrCellIds}=  Create List
    ${wnCellIds}=  Create List
    ${gnCellIds}=  Create List
    ${lncells}=  admin.get managed objects  LNCEL_A
    ${nrcells}=  admin.get managed objects  NRCELL_A
    ${wncells}=  admin.get managed objects  WNCEL_A
    ${gncells}=  admin.get managed objects  GNCEL_A
    FOR  ${cell}  IN  @{lncells}
        ${distName}=  Get From Dictionary  ${cell}  distName
		${string} =    Convert To String      ${distName}
        ${distnamestr} =    Get Substring      ${string}    -1
		${integer} =    Convert To Integer      ${distnamestr}
		${distnamesubstr}=  Set Variable If  '${MRBTS_ID}'=='10812'  ${${integer} + 1}
        ...  '${MRBTS_ID}'!='10812'  ${distnamestr}
        ${LNCELL_ID}=  Evaluate  re.search(r'LNCEL_A-(\\d+)','''${distName}''').group(1)  re
        Append To List  ${lnCellIds}  ${distnamesubstr}
		#Log to console  cellmapping IDs ${lnCellIds}
        Set Test Variable  ${lnCellIds}
    END
    FOR  ${cell}  IN  @{nrcells}
        ${distName}=  Get From Dictionary  ${cell}  distName
        ${NRCELL_ID}=  Evaluate  re.search(r'NRCELL_A-(\\d+)','''${distName}''').group(1)  re
        Append To List  ${nrCellIds}  ${NRCELL_ID}
        Set Test Variable  ${nrCellIds}
    END
    FOR  ${cell}  IN  @{wncells}
        ${lCelwDN}=  Get From Dictionary  ${cell['parameters']}  lCelwDN
        ${WNCELL_ID}=  Evaluate  re.search(r'LCELW_A-(\\d+)','''${lCelwDN}''').group(1)  re
        Append To List  ${wnCellIds}  ${WNCELL_ID}
        Set Test Variable  ${wnCellIds}
    END
    FOR  ${cell}  IN  @{gncells}
        ${distName}=  Get From Dictionary  ${cell}  distName
        ${GNCELL_ID}=  Evaluate  re.search(r'GNCEL_A-(\\d+)','''${distName}''').group(1)  re
        Append To List  ${gnCellIds}  ${GNCELL_ID}
        Set Test Variable  ${gnCellIds}
    END

    RETURN  ${lnCellIds}  ${nrCellIds}  ${wnCellIds}  ${gnCellIds}


Delete IntShutdownTimeout
    [Documentation]   Keyword deleting intShutDownTimeouts for cells depending on received arguments.
    ...   Example of usage:
    ...   Delete IntShutdownTimeout  ${nrCellIds}  NR
    [Arguments]  ${listOfIds}  ${rat}

    ${distCellPath}=  Set Variable If  '${rat}'=='NR'  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR
    ...  '${rat}'=='LTE'  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL
    ...  '${rat}'=='WCDMA'  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELW
    ${delta_IntShutdownTimeout}=  Set Variable  delta_IntShutdownTimeout
    admin.create delta  ${delta_IntShutdownTimeout}
    FOR  ${cellId}  IN  @{listOfIds}
        admin.append parameter delete to delta  ${distCellPath}-${cellId}  intShutdownTimeout  ${delta_IntShutdownTimeout}
    END
    admin.get delta  ${delta_IntShutdownTimeout}
    admin.save delta  ${RESULTS}/delta_IntShutdownTimeout_${rat}.json  ${delta_IntShutdownTimeout}
    admin.perform delta recommissioning  ${RESULTS}/delta_IntShutdownTimeout_${rat}.json
    Log To Console  IntShutdownTimeout for ${rat} cells has been deleted.


Delete IntShutdownTimeout LTE
    [Documentation]   Keyword deleting intShutDownTimeouts for cells depending on received arguments.
    ...   Example of usage:
    ...   Delete IntShutdownTimeout  ${nrCellIds}  NR
    [Arguments]  ${listOfIds}  ${rat}

    ${distCellPath}=  Set Variable If  '${rat}'=='NR'  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR
    ...  '${rat}'=='LTE'  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL
    ...  '${rat}'=='WCDMA'  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELW
    ${delta_IntShutdownTimeout}=  Set Variable  delta_IntShutdownTimeout
    admin.create delta  ${delta_IntShutdownTimeout}
    FOR  ${cellId}  IN  @{listOfIds}
        ${CellIDsubstr} =  Get Substring   ${cellId}    -1
        #Log to console  distnamesubstr ${CellIDsubstr}
        admin.append parameter delete to delta  ${distCellPath}-${CellIDsubstr}  intShutdownTimeout  ${delta_IntShutdownTimeout}
    END
    admin.get delta  ${delta_IntShutdownTimeout}
    admin.save delta  ${RESULTS}/delta_IntShutdownTimeout_${rat}.json  ${delta_IntShutdownTimeout}
    admin.perform delta recommissioning  ${RESULTS}/delta_IntShutdownTimeout_${rat}.json
    Log To Console  IntShutdownTimeout for ${rat} cells has been deleted.


Get WCDMA Cells Id For Multiple Cells
    [Arguments]  ${WCDMA_cell_id}

    ${WNCELS_A}=  admin.get managed objects  WNCEL_A
    FOR  ${i}  IN  @{WNCELS_A}
        ${status}=  Run Keyword And Return Status  Evaluate  re.search(r'(${WCDMA_cell_id})','''${i['distName']}''').group(1)  re
        ${lCelwDN}  IF  ${status}  Get From Dictionary  ${i['parameters']}  lCelwDN
        Exit For Loop If  '${lCelwDN}'!='None'
    END

    RETURN  ${lCelwDN[-1]}


Set Parameter Under EAC Object
    [Documentation]
    ...  Example of usage:
    ...  Set Parameter Under EAC Object  polarity  Normally_closed
    [Arguments]  ${parameter}  ${value}

    Log  Set ${parameter} on ${value} under EAC_IN-1  console=${true}
    ${polarity_delta}=  Set Variable  ${parameter}_${value}
    admin.create delta  ${polarity_delta}
    ${EAC_DN}=  Set Variable  MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/SMOD-1/EAC_IN-1
    admin.append parameter update to delta  ${EAC_DN}  ${parameter}  ${value}  ${polarity_delta}
    admin.get delta  ${polarity_delta}
    admin.save delta  ${RESULTS}/delta_EAC_${parameter}_${value}.json  ${polarity_delta}
    admin.perform delta recommissioning  ${RESULTS}/delta_EAC_${parameter}_${value}.json


Set Parameter Under BBMOD
    [Arguments]  ${BBMOD_ID}  ${parameter}  ${value}

    ${BBMOD_DN}=  Set Variable  MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-${BBMOD_ID}
    ${delta_bbmod}=  Set Variable  delta_bbmod
    admin.create delta  ${delta_bbmod}
    admin.append parameter update to delta  ${BBMOD_DN}  ${parameter}  ${value}  ${delta_bbmod}
    admin.get delta  ${delta_bbmod}
    admin.save delta  ${RESULTS}/delta_bbmod_${BBMOD_ID}_${parameter}_${value}.json  ${delta_bbmod}
    Log To Console  Changing for BBMOD-${BBMOD_ID}: ${parameter} to ${value}
    admin.perform delta recommissioning  ${RESULTS}/delta_bbmod_${BBMOD_ID}_${parameter}_${value}.json


Set intShutdownTimeout
    [Arguments]  ${rat}  ${timeout}

    ${cell_DN}=  Set Variable If  '${rat}'=='NR'  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR
    ...  '${rat}'=='LTE'  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL
    ...  '${rat}'=='WCDMA'  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELW
    ${timeout}=  Get Regexp Matches  ${timeout}  \\d+
    ${delta_timers}=  Set Variable  delta_timers
    admin.create delta  ${delta_timers}
    IF  '${rat}'=='NR'
        admin.append parameter update to delta  ${cell_DN}-${1st_NRCELL_ID}  intShutdownTimeout  ${timeout[0]}  ${delta_timers}
    ELSE IF  '${rat}'=='LTE'
        admin.append parameter update to delta  ${cell_DN}-${1st_LNCEL_ID}  intShutdownTimeout  ${timeout[0]}  ${delta_timers}
    ELSE IF  '${rat}'=='WCDMA'
        admin.append parameter update to delta  ${cell_DN}-${1st_WNCEL_ID_A}  intShutdownTimeout  ${timeout[0]}  ${delta_timers}
    END
    admin.get delta  ${delta_timers}
    admin.save delta  ${RESULTS}/delta_${rat}_intShutdownTimeout_${timeout[0]}min.json  ${delta_timers}
    admin.perform delta recommissioning  ${RESULTS}/delta_${rat}_intShutdownTimeout_${timeout[0]}min.json
    Log To Console  Set IntShutdownTimeout for ${rat} cell on ${timeout[0]} min.


Set intShutdownTimeout LTE
    [Arguments]  ${rat}  ${timeout}

    ${cell_DN}=  Set Variable If  '${rat}'=='NR'  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR
    ...  '${rat}'=='LTE'  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL
    ...  '${rat}'=='WCDMA'  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELW
    ${timeout}=  Get Regexp Matches  ${timeout}  \\d+
    ${delta_timers}=  Set Variable  delta_timers
    admin.create delta  ${delta_timers}
	${string} =    Convert To String      ${1st_LNCEL_ID}
	${1st_LNCEL_ID_substr}=  Get Substring    ${string}    -1
	${integer} =    Convert To Integer      ${1st_LNCEL_ID_substr}
	${1st_LNCEL_ID_short}=  Set Variable If  '${MRBTS_ID}'=='10812'  ${${integer} + 1}
    ...  '${MRBTS_ID}'!='10812'  ${1st_LNCEL_ID_substr}
    IF  '${rat}'=='NR'
        admin.append parameter update to delta  ${cell_DN}-${1st_NRCELL_ID}  intShutdownTimeout  ${timeout[0]}  ${delta_timers}
    ELSE IF  '${rat}'=='LTE'
        admin.append parameter update to delta  ${cell_DN}-${1st_LNCEL_ID_short}  intShutdownTimeout  ${timeout[0]}  ${delta_timers}
    ELSE IF  '${rat}'=='WCDMA'
        admin.append parameter update to delta  ${cell_DN}-${1st_WNCEL_ID_A}  intShutdownTimeout  ${timeout[0]}  ${delta_timers}
    END
    admin.get delta  ${delta_timers}
    admin.save delta  ${RESULTS}/delta_${rat}_intShutdownTimeout_${timeout[0]}min.json  ${delta_timers}
    admin.perform delta recommissioning  ${RESULTS}/delta_${rat}_intShutdownTimeout_${timeout[0]}min.json
    Log To Console  Set IntShutdownTimeout for ${rat} cell on ${timeout[0]} min.


Select Cells And Delete IntShutdownTimeout LTE
    ${lnCellIds}  ${nrCellIds}  ${wnCellIds}  ${gnCellIds}  Get Cells IDs From Cellmapping LTE
    IF  '${IF_NR_EXIST}'=='EXIST' and '${IF_LTE_EXIST}'=='EXIST' and '${IF_WCDMA_EXIST}'=='EXIST' and '${IF_GSM_EXIST}'=='EXIST'
        Select Random NR Cell
        Log To Console  Selected NRCELL DN: ${1st_NRCELL_DN}
        Delete IntShutdownTimeout  ${nrCellIds}  NR
        Select Random LTE Cell
        Log To Console  Selected LNCEL DN: ${1st_LNCEL_DN}
        Delete IntShutdownTimeout  ${lnCellIds}  LTE
        Select Random WCDMA Cell
        Log To Console  Selected WNCEL DN: ${1st_WNCEL_DN}
        Delete IntShutdownTimeout  ${wnCellIds}  WCDMA
        Select Random GSM Cell
        Log To Console  Selected GNCEL DN: ${1st_GNCEL_DN}
    ELSE IF  '${IF_NR_EXIST}'=='EXIST' and '${IF_LTE_EXIST}'=='EXIST' and '${IF_WCDMA_EXIST}'=='NO' and '${IF_GSM_EXIST}'=='NO'
        Select Random NR Cell
        Log To Console  Selected NRCELL DN: ${1st_NRCELL_DN}
        Delete IntShutdownTimeout  ${nrCellIds}  NR
        Select Random LTE Cell
        Log To Console  Selected LNCEL DN: ${1st_LNCEL_DN}
        Delete IntShutdownTimeout  ${lnCellIds}  LTE
    ELSE IF  '${IF_NR_EXIST}'=='EXIST' and '${IF_LTE_EXIST}'=='EXIST' and '${IF_WCDMA_EXIST}'=='NO' and '${IF_GSM_EXIST}'=='EXIST'
        Select Random NR Cell
        Log To Console  Selected NRCELL DN: ${1st_NRCELL_DN}
        Delete IntShutdownTimeout  ${nrCellIds}  NR
        Select Random LTE Cell
        Log To Console  Selected LNCEL DN: ${1st_LNCEL_DN}
        Delete IntShutdownTimeout  ${lnCellIds}  LTE
        Select Random GSM Cell
    ELSE IF  '${IF_NR_EXIST}'=='EXIST' and '${IF_LTE_EXIST}'=='EXIST' and '${IF_WCDMA_EXIST}'=='EXIST' and '${IF_GSM_EXIST}'=='NO'
        Select Random NR Cell
        Log To Console  Selected NRCELL DN: ${1st_NRCELL_DN}
        Delete IntShutdownTimeout  ${nrCellIds}  NR
        Select Random LTE Cell
        Log To Console  Selected LNCEL DN: ${1st_LNCEL_DN}
        Delete IntShutdownTimeout  ${lnCellIds}  LTE
        Select Random WCDMA Cell
        Log To Console  Selected WNCEL DN: ${1st_WNCEL_DN}
        Delete IntShutdownTimeout  ${wnCellIds}  WCDMA
    ELSE IF  '${IF_NR_EXIST}'=='EXIST' and '${IF_LTE_EXIST}'=='NO' and '${IF_WCDMA_EXIST}'=='NO' and '${IF_GSM_EXIST}'=='NO'
        Select Random NR Cell
        Log To Console  Selected NRCELL DN: ${1st_NRCELL_DN}
        Delete IntShutdownTimeout  ${nrCellIds}  NR
    ELSE IF  '${IF_NR_EXIST}'=='NO' and '${IF_LTE_EXIST}'=='EXIST' and '${IF_WCDMA_EXIST}'=='NO' and '${IF_GSM_EXIST}'=='NO'
        Select Random LTE Cell
        Log To Console  Selected LNCEL DN: ${1st_LNCEL_DN}
        Delete IntShutdownTimeout  ${lnCellIds}  LTE
    END


Get Specified Duplex LNCEL List
    [Arguments]  ${duplex}

    ${lncels_param}=  admin.get parameters for all  class_name=LNCEL
    ${lncels}=  Create List
    FOR  ${cell}  IN  @{lncels_param}
        IF  '${cell['technology']}'=='${duplex}'  Append To List  ${lncels}  ${cell['id']}
    END

    RETURN  ${lncels}


Get BBPOOL List
    [Arguments]  ${bbPoolTech}

    ${BBPOOLs}=  admin.get managed objects  BBPOOL_R
    FOR  ${bbpool}  IN  @{BBPOOLs}
        IF  '${bbpool['parameters']['bbPoolTech']}'!='${bbPoolTech}'  Remove Values From List  ${BBPOOLs}  ${bbpool}
    END

    RETURN  ${BBPOOLs}


Get Cells Assigned To POWERGROUP_R-2
    [Arguments]  ${BBPOOLs}

    ${bbPoolCellsList}=  Create List
    ${BBPOOL_DN}=  Create List
    FOR  ${bbpool}  IN  @{BBPOOLs}
        ${status}=  Run Keyword And Return Status  Should Match Regexp  ${bbpool['parameters']['bbPwrGroupDNList'][0]}  .*POWERGROUP_R-2
        IF  not ${status}
            Remove Values From List  ${BBPOOLs}  ${bbpool}
        ELSE
            Append To List  ${bbPoolCellsList}  ${bbpool['parameters']['bbPoolCellsList']}
            Append To List  ${BBPOOL_DN}  ${bbpool['distName']}
        END
    END
#    ${bbPoolCellsList}=  Evaluate  [item for sublist in $bbPoolCellsList for item in (sublist if isinstance(sublist, list) else [sublist])]

    RETURN  ${bbPoolCellsList[0]}  ${BBPOOL_DN[0]}


Mapping LNCEL_A To LNCEL_R
    ${lncels}=  admin.get cells info  cell_type=lte
    ${LNCEL_A_to_LNCEL_R}=  Create Dictionary
    FOR  ${lncel}  IN  @{lncels}
        Set To Dictionary  ${LNCEL_A_to_LNCEL_R}  ${lncel['id']['configuration']}=${lncel['id']['internal']}
    END

    RETURN  ${LNCEL_A_to_LNCEL_R}


Cell Barred/NotBarred
    [Documentation]  Keyword sets cell barred flag as barred|NotBarred.
    ...  A barred cell is a cell that a UE is not allowed to camp on, not even for emergency calls.
    ...  This parameter is used in NB-IoT cell also.
    ...  Example of usage:
    ...  Cell Barred/NotBarred  barred  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-5056/LNCEL_R-1
    ...  Cell Barred/NotBarred  notBarred  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-6030/NRCELL_R-2
    ...
    [Arguments]  ${parameter}  ${internalID}  ${regex}=LNCEL|NRCELL

    ${cellType}  Should Match Regexp  ${internalID}  ${regex}
    IF  '${cellType}'=='LNCEL'
        ${distName}  Set Variable  ${internalID}/SIB-0
    ELSE IF  '${cellType}'=='NRCELL'
        ${distName}  Set Variable  ${internalID}
    END
    ${delta_barred}  Set Variable  cellBarred
    admin.create delta  ${delta_barred}
    admin.append parameter update to delta  ${distName}  cellBarred  ${parameter}  ${delta_barred}
    admin.get delta  ${delta_barred}
    ${json_path}  Set Variable  ${RESULTS}/${parameter}_${cellType}.json
    admin.save delta  ${json_path}  ${delta_barred}
    Log To Console  Set flag cellBarred as ${parameter} for ${distName}
    admin.perform delta recommissioning  ${json_path}  ${skip_parameter_relation_errors}  ${should_activate}
    Run  rm -r ${RESULTS}/${parameter}_${cellType}.json


Find Empty POWERGROUP
    [Documentation]  This KW will return POWERGROUP distName where empty bbpool object exists.

    ${empty_bbpool_objects}=  Create List
    ${bbpool_objects}=  admin.get managed objects  BBPOOL_R
    Set Test Variable  ${bbpool_objects}
    FOR  ${bbpool_object}  IN  @{bbpool_objects}
        IF  '${bbpool_object['parameters']['bbPoolCellsList']}'=='[]'  Append To List  ${empty_bbpool_objects}
        ...  ${bbpool_object['parameters']['bbPwrGroupDNList']}
    END
    Set Test Variable  ${empty_bbpool_objects}
    ${empty_bbpool_objects_length}=  Get Length  ${empty_bbpool_objects}
    IF  '${empty_bbpool_objects_length}'=='0'  Fail   message=Empty power group does not exists
    ${powergroup_dn}  Set Variable  ${empty_bbpool_objects[0]}

    RETURN  ${powergroup_dn}


Get POWERGROUP List
    ${POWERGROUP_DNs}=  Create List
    ${bbpool_objects}=  admin.get managed objects  BBPOOL_R
    FOR  ${bbpool}  IN  @{bbpool_objects}
        Append To List  ${POWERGROUP_DNs}  ${bbpool['parameters']['bbPwrGroupDNList'][0]}
    END

    RETURN  ${POWERGROUP_DNs}


Check Powergroup
    [Arguments]  ${POWERGROUP_DN}  ${expected_operationalState}

    ${bbpool_objects}=  admin.get managed objects  BBPOOL_R
    FOR  ${bbpool}  IN  @{bbpool_objects}
        ${powergroup_r}=  Get Regexp Matches  ${bbpool['parameters']['bbPwrGroupDNList'][0]}  BBMOD_R-\\d+/POWERGROUP_R-\\d+
        ${operationalState}  Evaluate  "${bbpool['parameters']['operationalState']}".upper()
        IF  '${bbpool['parameters']['bbPwrGroupDNList'][0]}'=='${POWERGROUP_DN}'
            Should Be True  '${operationalState}'=='${expected_operationalState}'
            Log To Console  ${powergroup_r[0]} operationalState: ${operationalState}
        END
    END


Set bbPoolAllocMode To Manual
    ${delta_bbpoolalloc}=  Set Variable  delta_bbpoolalloc_manual
    admin.create delta  ${delta_bbpoolalloc}
    FOR  ${LNCEL}  IN  @{LNCELs}
        ${BBPOOLALLOC_DN}=  Set Variable  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${LNCEL}/BBPOOLALLOC-0
        admin.append parameter update to delta  ${BBPOOLALLOC_DN}  bbPoolAllocMode  manual  ${delta_bbpoolalloc}
        Log To Console  Changing for ${LNCEL}: bbPoolAllocMode to manual
    END
    admin.get delta  ${delta_bbpoolalloc}
    admin.save delta  ${RESULTS}/delta_bbPoolAllocMode_automatic.json  ${delta_bbpoolalloc}
    admin.perform delta recommissioning  ${RESULTS}/delta_bbPoolAllocMode_automatic.json


Set bbPoolAllocMode To Automatic
    ${delta_bbpoolalloc}=  Set Variable  delta_bbpoolalloc_automatic
    admin.create delta  ${delta_bbpoolalloc}
    FOR  ${LNCEL}  IN  @{LNCELs}
        ${BBPOOLALLOC_DN}=  Set Variable  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${LNCEL}/BBPOOLALLOC-0
        admin.append parameter update to delta  ${BBPOOLALLOC_DN}  bbPoolAllocMode  automatic  ${delta_bbpoolalloc}
        Log To Console  Changing for ${LNCEL}: bbPoolAllocMode to automatic
    END
    admin.get delta  ${delta_bbpoolalloc}
    admin.save delta  ${RESULTS}/delta_bbPoolAllocMode_automatic.json  ${delta_bbpoolalloc}
    admin.perform delta recommissioning  ${RESULTS}/delta_bbPoolAllocMode_automatic.json


Check parameter availability under LNBTS
    [Arguments]  ${parameter}

    ${parameter_presence}  ${parameter_value}=  Run Keyword And Ignore Error  Get Parameter Value Under LNBTS  ${parameter}

    RETURN  ${parameter_presence}

Commission LoadSettings For LNCELs
    [Arguments]  ${configuration_ids}    ${nomNumPrbNonGbr}=0.01

    ${loadSettings}  Create Dictionary
    Set To Dictionary  ${loadSettings}  cellCapClass        100
    Set To Dictionary  ${loadSettings}  mlbEicicOperMode    allUes
    Set To Dictionary  ${loadSettings}  nomNumPrbNonGbr     ${nomNumPrbNonGbr}
    Set To Dictionary  ${loadSettings}  targetLoadGbrDl     50
    Set To Dictionary  ${loadSettings}  targetLoadNonGbrDl  75
    Set To Dictionary  ${loadSettings}  targetLoadPdcch     90
    Set To Dictionary  ${loadSettings}  ulCacIgnore         false
    Set To Dictionary  ${loadSettings}  ulCacSelection      ulReflectDlCac
    Set To Dictionary  ${loadSettings}  ulStaticCac         100
    ${loadSettings_delta}  Set Variable  loadSettings_add
    admin.create delta  ${loadSettings_delta}
    FOR  ${lncel}  IN  @{configuration_ids}
        admin.append complex item to delta  ${lncel}  list_name=loadSettings  &{loadSettings}  delta_id=${loadSettings_delta}
    END
    get delta  ${loadSettings_delta}
    save delta  ${RESULTS}/set_loadSettings.json  delta_id=${loadSettings_delta}
    Log To Console  Activation plan with loadSettings parameters for LNCEL(s)
    perform delta recommissioning  ${RESULTS}/set_loadSettings.json  skip_parameter_relation_errors=${True}


#----------------------------------------- CB009176 START ----------------------------------------------------
Remove RMOD dcPortWinList
    [Documentation]
    ...  **Example of simple usage:**
    ...  Removal of pwrOffDCPortTimeWinList

    ${delta}=  Set Variable  delta_remove_dcportWinList
    admin.create delta  ${delta}
    admin.append managed object to delta  ${dcport_info['distName']}  update  ${delta}
    admin.append parameter delete to delta  ${dcport_info['distName']}  advanceTimeForDCPortPwrOn  ${delta}
    admin.append parameter delete to delta  ${dcport_info['distName']}  pwrOffDCPortTimeWinList  ${delta}
    admin.append parameter delete to delta  ${dcport_info['distName']}  connectedHWDN  ${delta}
    admin.get delta  ${delta}
    admin.save delta  ${RESULTS}/delta_remove_dcportWinList.json  ${delta}
    Log  Removing RMOD pwrOffDCPortTimeWinList For MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${dcport_info['distName']}  console=${true}
    admin.perform delta recommissioning  ${RESULTS}/delta_remove_dcportWinList.json


Reconfigure DCPort Time Schedule
    [Documentation]
    ...  **Example of simple usage:**
    ...  Keyword reconfigre existing pwrOffDCPortTimeWinList

    Get Time And Date With Minute Offset  120minutes
    ${dc_dn}=  Set Variable  ${dcport_info['distName']}
    ${detlta_reconf_pwrOfTime}=  Set Variable    reconf_pwrOfTime
    admin.create delta  ${detlta_reconf_pwrOfTime}
    ${pwrOffDCPortTimeWinList}=  Create Dictionary
    ${dcpPwrDuration}=  Get Regexp Matches  60  \\d+
    Set To Dictionary  ${pwrOffDCPortTimeWinList}  dayOfWeek=${day}
    Set To Dictionary  ${pwrOffDCPortTimeWinList}  startTime=${start_hour}:${start_minutes}
    Set To Dictionary  ${pwrOffDCPortTimeWinList}  windowDuration=${dcpPwrDuration[0]}
    admin.append complex item to delta  ${dc_dn}  list_name=pwrOffDCPortTimeWinList  &{pwrOffDCPortTimeWinList}  delta_id=${detlta_reconf_pwrOfTime}
    ${end_time}=  Add Time To Date  ${time_with_offset}  ${dcpPwrDuration[0]} minutes
    ${end_hour}=  Convert Date  ${end_time}  result_format=%H
    ${end_minutes}=  Convert Date  ${end_time}  result_format=%M
    Log  New Power Off DC Port Time Frame: ${start_hour}:${start_minutes}-${end_hour}:${end_minutes} (+${dcpPwrDuration[0]} minutes)  console=${true}
    Log   Power Off DC Port Time Window Reconfigured
    admin.get delta  ${detlta_reconf_pwrOfTime}
    admin.save delta  ${RESULTS}/detlta_reconf_pwrOfTime.json  ${detlta_reconf_pwrOfTime}
    admin.perform delta recommissioning  ${RESULTS}/detlta_reconf_pwrOfTime.json  ${detlta_reconf_pwrOfTime}


Prepare To Power Off Via FPFH DC Port
    [Arguments]  ${time_window_offSet}=3 minutes  ${advanceTimeForDCPortPwrOn}=20   ${dcpPwrDuration}=35
    [Documentation]  Keyword configure feature CB009176 flag, time window, advance time to power on DC Port
    ...              before the time window end, and set RMOD Dist Name that connects to this port

    ${dc_dn}=  Set Variable  ${dcport_info['distName']}
    ${pwrOffDCPortTimeWinList}=  Create Dictionary
    Set Test Variable  ${pwrOffDCPortTimeWinList}
    ${delta_pwrOffDCPort}=  Set Variable  switch_of_dc_port
    admin.create delta  ${delta_pwrOffDCPort}
    admin.append parameter update to delta  ${dcport_info['distName']}  actAutoPwrOffForES  true  ${delta_pwrOffDCPort}
    admin.append parameter update to delta  ${dcport_info['distName']}  connectedHWDN  ${ru_info['distName']}  ${delta_pwrOffDCPort}
    admin.append parameter update to delta  ${dcport_info['distName']}  advanceTimeForDCPortPwrOn  ${advanceTimeForDCPortPwrOn}  ${delta_pwrOffDCPort}
    Get Time And Date With Minute Offset  ${time_window_offSet}  0 minutes
    Set To Dictionary  ${pwrOffDCPortTimeWinList}  dayOfWeek=${day}
    Set To Dictionary  ${pwrOffDCPortTimeWinList}  startTime=${start_hour}:${start_minutes}
    Set To Dictionary  ${pwrOffDCPortTimeWinList}  windowDuration=${dcpPwrDuration}
    admin.append complex item to delta  ${dc_dn}  list_name=pwrOffDCPortTimeWinList  &{pwrOffDCPortTimeWinList}  delta_id=${delta_pwrOffDCPort}
    ${end_time}=  Add Time To Date  ${time_with_offset}  ${dcpPwrDuration} minutes
    ${end_hour}=  Convert Date  ${end_time}  result_format=%H
    ${end_minutes}=  Convert Date  ${end_time}  result_format=%M
    Log  Power Off DC Port Time Frame: ${start_hour}:${start_minutes}-${end_hour}:${end_minutes} (+${dcpPwrDuration} minutes)  console=${true}
    ${ru_restore}=  Evaluate    ${dcpPwrDuration} - ${advanceTimeForDCPortPwrOn}
    ${end_time}=  Add Time To Date  ${time_with_offset}  ${ru_restore} minutes
    ${end_minutes}=  Convert Date  ${end_time}  result_format=%M
    Log  DC Port Should Power On At: ${end_hour}:${end_minutes}  console=${true}
    Log   Power Off DC Port Time Window Created
    admin.get delta  ${delta_pwrOffDCPort}
    admin.save delta  ${RESULTS}/delta_delta_pwrOffDCPort_CB009176.json  ${delta_pwrOffDCPort}
    admin.perform delta recommissioning  ${RESULTS}/delta_delta_pwrOffDCPort_CB009176.json  ${delta_pwrOffDCPort}


Get All Radios And Their Cells
    [Documentation]  Return list combined list of RMOD_DN and NRCELL_DN

    ${nrcells_R_list}=  admin.get managed objects  NRCELL_R
    Set Test Variable  ${nrcells_R_list}
    @{rmods_and_nrcells}=  Create List
    FOR  ${key}  IN  @{nrcells_R_list}
        ${rmod_dn_list}=  Create List
        ${nrcell_R_distName}=  Get From Dictionary  ${key}  distName
        Set Test Variable   ${nrcell_R_distName}
        ${split_for_id}=  Split String From Right  ${nrcell_R_distName}  separator=/NRCELL_R-  max_split=1

        ${nrcell_R_Id}=  Get From List  ${split_for_id}  1
        Set Test Variable   ${nrcell_R_Id}
        Append To List  ${rmod_dn_list}  ${nrcell_R_Id}
        ${rmod_distName}=  Get From Dictionary   ${key['parameters']}  frRefList
        Set Test Variable  ${rmod_distName}
        ${cells_under_rmods}  Combine lists  ${rmod_distName}  ${rmod_dn_list}
        Append To List  ${rmods_and_nrcells}  ${cells_under_rmods}
    END
    Set Test Variable  @{rmods_and_nrcells}

    RETURN  @{rmods_and_nrcells}


Get Selected RU Info
    [Documentation]
    ...  Keyword get all necessary information for the test about selected RU, 'distName', 'productCode', 'ruId'
    ...  and set it under dictionary 'ru_info'

    FOR  ${rmod}  IN  @{all_rmods}
        ${distName}=   Get From Dictionary  ${rmod}  distName
        ${productName}=  Get From Dictionary  ${rmod['parameters']}   productName
        ${configDN}=  Get From Dictionary  ${rmod['parameters']}   configDN
        IF  '${productName}'=='${rmodModel}'
            Set To Dictionary  ${ru_info}  distName  ${rmod['parameters']['configDN']}
            Set To Dictionary  ${ru_info}  productName  ${rmod['parameters']['productName']}
            Set To Dictionary  ${ru_info}  ruId  ${rmod['distName']}
            Return Proper Distname For RU  ${ru_info}
        END
    END
    ${split_id}=  Split String From Right    ${ru_info['distName']}    separator=APEQM-1/   max_split=1
    ${rmod_id}=    Get From List  ${split_id}  1
    Set Test Variable    ${rmod_id}
    FOR  ${rmod_and_nrcell}  IN  @{rmods_and_nrcells}
          IF  '${rmod_and_nrcell[0]}'=='${ru_info['distName']}'
              Set To Dictionary  ${ru_info}  cellId  ${rmod_and_nrcell[1]}
              Set To Dictionary  ${ru_info}  rmod_Id  ${rmod_id}
              Append To List  ${selected_cells_IDs}  ${ru_info['cellId']}
              Log To Console  Information About Selected Radio: \n${ru_info}
          END
    END


Return Proper Distname For RU
        [Documentation]
        ...  Keyword delete all _A, _R, from RU distaName, and return sting like: 'MRBTS-8085/EQM-1/APEQM-1/RMOD-6'
        ...  **Example of simple usage:**
        ...  Return Proper Distname For RU  ${ru_info}
        [Arguments]  ${ru_info}

        ${distName_A}=  Get From Dictionary  ${ru_info}  distName
        Set Test Variable  ${distName_A}
        ${split_ru_distName}=  Split String From Right  ${distName_A}  separator=/SCF-1/  max_split=1
        ${ru_distName}=  Get From List  ${split_ru_distName}  1
        ${ru_distName_without_R}=  Replace String  ${ru_distName}  _A  ${EMPTY}
        Set To Dictionary  ${ru_info}  distName  ${ru_distName_without_R}

        ${split_ru_infoModel}=  Split String From Right  ${distName_A}  separator=/APEQM_A-1/  max_split=1
        ${ru_infoModel}=  Get From List  ${split_ru_infoModel}  1
        ${ru_infoModel_id}=  Replace String  ${ru_infoModel}  _A  _R
        Set To Dictionary  ${ru_info}  configDn  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/${ru_infoModel_id}


Check DCPort Power State And Maintenance Mode
    [Documentation]
    ...  Keyword Checks DC Port status
    ...  **Example of simple usage:**
    ...  Check DCPort Power State And Maintenance Mode   ON  DISABLED
    [Arguments]   ${expected_powerState}  ${expected_maintenanceMode}

     ${all_dcports_R}=  admin.get managed objects  DCPORT_R
     Set Test Variable  ${all_dcports_R}
     FOR  ${dcport}  IN  @{all_dcports_R}
        ${dcPort_parameters}=  Get From Dictionary  ${dcport}  parameters
        ${dcport_full_dn}=  Get From Dictionary  ${dcPort_parameters}  configDN
        ${split_dcport_dn}=  Split String From Right   ${dcport_full_dn}  separator=/SCF-1/  max_split=1
        ${splited_dcport_dn}=  Get From List  ${split_dcport_dn}  1
        ${dcportDN_R}=  Replace String  ${splited_dcport_dn}  _A  ${EMPTY}
        ${dcPort_State}=  Get From Dictionary  ${dcPort_parameters}  powerPortState
        ${dcPort_Mode}=  Get From Dictionary  ${dcPort_parameters}  maintenanceMode
        ${dcPort_powerState}=  Evaluate  "${dcPort_State}".upper()
        ${dcPort_maintenanceMode}=  Evaluate  "${dcPort_Mode}".upper()
        IF  '${dcport_info['distName']}'=='${dcportDN_R}'
             Should Be True  '${dcPort_powerState}'=='${expected_powerState}' and '${dcPort_maintenanceMode}'=='${expected_maintenanceMode}'
             Log  DC Port Power State: ${dcPort_powerState}  console=${True}
             Log  DC Port Maintenance Mode: ${dcPort_maintenanceMode}  console=${True}
        END
     END

Check Radio State DC Port PWROFF
    [Documentation]
    ...  Keyword checks radio status after DC Port power on
    ...  **Example of simple usage:**
    ...  Check Radio State DC Port PWROFF  ${ru_info['ruId']}  AWAKE  NONE
    [Arguments]   ${ruId}   ${expected_powerState}  ${expected_availabilityStatus}

    ${all_rmods}=  admin.get managed objects  RMOD_R
    Set Test Variable  ${all_rmods}
    FOR  ${rmod}  IN  @{all_rmods}
        ${ru_Dn}=  Get From Dictionary  ${rmod}   distName
        ${power_State}=  Evaluate  "${rmod['parameters']['powerState']}".upper()
        ${availability_Status}=  Evaluate  "${rmod['parameters']['availabilityStatus']}".upper()
        IF  '${ruId}'=='${ru_Dn}'  Should Be True
        ...  '${power_State}'=='${expected_powerState}' and '${availability_Status}'=='${expected_availabilityStatus}'
    END


Create deepSleepTimeSchedule
    [Documentation]
    ...  **Example of simple usage:**
    ...  Create deepSleepTimeSchedule and advanceTimeForRURestore for selected RMOD
    ...
    [Arguments]  ${selected_RMOD}  ${win_duration}  ${TimeForRURestore}=25  ${start_offset}=3  ${second_start_offset}=28

    ${delta}=  Set Variable  delta_create_deepSleep
    ${deepsleepschedule_DN}=  Set Variable  MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/${selected_RMOD}
    admin.create delta  ${delta}
    admin.append managed object to delta  ${deepsleepschedule_DN}  update  ${delta}
    admin.append parameter update to delta  ${deepsleepschedule_DN}  advanceTimeForRURestore  ${TimeForRURestore}  ${delta}
    Get Time And Date With Minute Offset  ${start_offset}minutes
    ${deepSleepTimeSchedule}=  Create Dictionary
    Set To Dictionary  ${deepSleepTimeSchedule}  dayOfWeek=${day}
    Set To Dictionary  ${deepSleepTimeSchedule}  startTime=${start_hour}:${start_minutes}
    Set To Dictionary  ${deepSleepTimeSchedule}  windowDuration=${win_duration}
    admin.append complex item to delta  ${deepsleepschedule_DN}  list_name=deepSleepTimeSchedule  &{deepSleepTimeSchedule}  delta_id=${delta}
    ${end_time}=  Add Time To Date  ${time_with_offset}  ${win_duration} minutes
    ${end_hour}=  Convert Date  ${end_time}  result_format=%H
    ${end_minutes}=  Convert Date  ${end_time}  result_format=%M
    Log  Deep Sleep TimeSchedule: ${start_hour}:${start_minutes}-${end_hour}:${end_minutes} (+${win_duration} minutes)  console=${true}
    ${ru_restore}=  Evaluate    ${win_duration} - ${TimeForRURestore}
    ${end_time}=  Add Time To Date  ${time_with_offset}  ${ru_restore} minutes
    ${end_minutes}=  Convert Date  ${end_time}  result_format=%M
    Log  Deep Sleep TimeSchedule Should finish At: ${end_hour}:${end_minutes}  console=${true}
    Get Time And Date With Minute Offset  ${second_start_offset}minutes
    ${deepSleepTimeSchedule}=  Create Dictionary
    Set To Dictionary  ${deepSleepTimeSchedule}  dayOfWeek=${day}
    Set To Dictionary  ${deepSleepTimeSchedule}  startTime=${start_hour}:${start_minutes}
    Set To Dictionary  ${deepSleepTimeSchedule}  windowDuration=${win_duration}
    ${end_time}=  Add Time To Date  ${time_with_offset}  ${win_duration} minutes
    ${end_hour}=  Convert Date  ${end_time}  result_format=%H
    ${end_minutes}=  Convert Date  ${end_time}  result_format=%M
    Log  Second Deep Sleep TimeSchedule: ${start_hour}:${start_minutes}-${end_hour}:${end_minutes} (+${win_duration} minutes)  console=${true}
    ${ru_restore}=  Evaluate    ${win_duration} - ${TimeForRURestore}
    ${end_time}=  Add Time To Date  ${time_with_offset}  ${ru_restore} minutes
    ${end_minutes}=  Convert Date  ${end_time}  result_format=%M
    Log  Second Deep Sleep TimeSchedule Should finish At: ${end_hour}:${end_minutes}  console=${true}
    admin.append complex item to delta  ${deepsleepschedule_DN}  list_name=deepSleepTimeSchedule  &{deepSleepTimeSchedule}  delta_id=${delta}
    admin.get delta  ${delta}
    admin.save delta  ${RESULTS}/delta_create_deepsleep.json  ${delta}
    admin.perform delta recommissioning  ${RESULTS}/delta_create_deepsleep.json  ${delta}


#----------------------------------------- CB009176 END ----------------------------------------------------


#------------------------------------------ Keywords PS4ALL START ---------------------------------------
Get Lncel Ids From PSGRP
    [Documentation]  Keyword get value from lnCelId parameter in PSGRP

    ${psgrp_parameter_list}=  admin.get managed objects  PSGRP_A
    Set Test Variable  ${psgrp_parameter_list}
    ${cells_in_psgrp}=  Create List
    FOR  ${psgrp_parameter}  IN  @{psgrp_parameter_list}
      ${lbpsCellList}=  Get From Dictionary  ${psgrp_parameter['parameters']}  lbpsCellList
      Set Test Variable  ${lbpsCellList}
    END
    FOR  ${parameter}  IN  @{lbpsCellList}
        ${lnCelId}=  Get From Dictionary  ${parameter}  lnCelId
        Append To List  ${cells_in_psgrp}  LNCEL_R-${lnCelId}
    END
     Set Test Variable  ${cells_in_psgrp}


Get Nrcells Ids From NRPGRP
    [Documentation]  Keyword get value from nrCelId parameter in NRPGRP

    ${nrpgrp_parameter_list}  admin.Get Managed Objects  NRPGRP_A
    Set Test Variable  ${nrpgrp_parameter_list}
    ${cells_in_nrpgrp}  Create List
    FOR  ${nrpgrp_parameter}  IN  @{nrpgrp_parameter_list}
        ${lbpsCellList}  Get From Dictionary  ${nrpgrp_parameter['parameters']}  lbpsCellList
        Set Test Variable  ${lbpsCellList}
    END
    FOR  ${parameter}  IN  @{lbpsCellList}
        ${nrCelId}  Get From Dictionary  ${parameter}  nrCellId
        Append To List  ${cells_in_nrpgrp}  NRCELL_R-${nrCelId}
    END
    Set Test Variable  ${cells_in_nrpgrp}


Get Cell IDs From Group
    [Arguments]  ${group}  ${group_id}

    ${parameters_list}  admin.Get Managed Objects  ${group}_A
    ${cells_in_group}  Create List
    FOR  ${parameter}  IN  @{parameters_list}
        ${dist_name}  Get From Dictionary  ${parameter}  distName
        ${group_name}  Fetch From Right  ${dist_name}  /
        IF  '${group_name}'=='${group}_A-${group_id}'
            ${lbpsCellList}  Get From Dictionary  ${parameter['parameters']}  lbpsCellList
            FOR  ${element}  IN  @{lbpsCellList}
                IF  '${group}'=='PSGRP'
                    ${cell_id}  Get From Dictionary  ${element}  lnCelId
                ELSE IF  'group'='NRPGRP'
                    ${cell_id}  Get From Dictionary  ${element}  nrCellId
                END
                Append To List  ${cells_in_group}  ${cell_id}
            END
        END
    END

    RETURN  ${cells_in_group}


Return PS And Not PS LTE Cells
    [Documentation]  Keyword gets ids for all LNCEL, then compare them with ids
    ...  from cells in PSGRP, and return two separate lists

    Log To Console  Check If any LNCELs included in PSGRP
    ${LTE_DEPLOYED}=  admin.get ids for all  LNCEL
    ${LTE_DEPLOYED_IDs}=  Create List
    FOR  ${item}  IN  @{LTE_DEPLOYED}
        ${split_for_id}=  Split String From Right  ${item}  separator=/  max_split=1
        ${lncelId}=  Get From List  ${split_for_id}  1
        Append To List  ${LTE_DEPLOYED_IDs}  ${lncel_id}
    END
    Set Test Variable  ${LTE_DEPLOYED_IDs}
    Get Lncel Ids From PSGRP
    ${ps_cells_LTE}  Evaluate  [LNCEl_R for LNCEl_R in @{LTE_DEPLOYED_IDs} if LNCEl_R in ${cells_in_psgrp}]
    Set Test Variable  ${ps_cells_LTE}
    ${ps_cells_LTE}  Evaluate  [LNCEL_DN for LNCEL_DN in @{LTE_DEPLOYED} if any(LNCEl_R for LNCEl_R in ${ps_cells_LTE} if LNCEL_DN.endswith(LNCEl_R))]
    ${not_ps_cells_LTE}  Evaluate  [LNCEl_DN for LNCEl_DN in @{LTE_DEPLOYED} if LNCEl_DN not in ${ps_cells_LTE}]

    RETURN  ${not_ps_cells_LTE}  ${ps_cells_LTE}


Return PS And Not PS NR Cells
    [Documentation]  Keyword gets ids for all NRCEL, then compare them with ids
    ...  from cells in NRPGRP, and return two separate lists

    Log To Console  Check If any NRCELs included in NRPGRP
    ${NR_DEPLOYED}=  admin.get ids for all  NRCEL
    ${NR_DEPLOYED_IDs}=  Create List
    FOR  ${item}  IN  @{NR_DEPLOYED}
        ${split_for_id}=  Split String From Right  ${item}  separator=/  max_split=1
        ${nrcelId}=  Get From List  ${split_for_id}  1
        Append To List  ${NR_DEPLOYED_IDs}  ${nrcelId}
    END
    Set Test Variable  ${NR_DEPLOYED_IDs}
    Get Nrcells Ids From NRPGRP
    ${ps_cells_NR}  Evaluate  [NRCEl_R for NRCEl_R in @{NR_DEPLOYED_IDs} if NRCEl_R in ${cells_in_nrpgrp}]
    Set Test Variable  ${ps_cells_NR}
    ${ps_cells_NR}  Evaluate  [NRCEL_DN for NRCEL_DN in @{NR_DEPLOYED} if any(NRCEl_R for NRCEl_R in ${ps_cells_NR} if NRCEL_DN.endswith(NRCEl_R))]
    ${not_ps_cells_NR}  Evaluate   [NRCEL_DN for NRCEL_DN in @{NR_DEPLOYED} if NRCEL_DN not in ${ps_cells_NR}]

    RETURN  ${not_ps_cells_NR}  ${ps_cells_NR}


Get Cells From CHANNEL_A
    ${cell_split}  Split String  ${CHANNEL_NAME}  /
    ${split_length}  BuiltIn.Get Length  ${cell_split}
    ${cell_split_1}=  IF  '${split_length}'=='8'  Set variable  ${cell_split[5]}  ELSE IF  '${split_length}'!='8'  Set variable  ${cell_split[11]}
    ${cell_tech}  ${cell_id}  Split String  ${cell_split_1}  -
    FOR  ${i}  IN RANGE  0  1
        ${value}=  IF  "${cell_tech}"=="LCELL_A"  Set variable  /MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-${cell_id}
        IF  '${value}'!='None'
            Append To List  ${SELECTED_ALIAS_CELLS}  ${value}
            Append To List  ${GRACEFUL_CELLS}  ${value}
        END
        IF  "${value}"!="None"  BREAK
        ${value}=  IF  "${cell_tech}"=="LCELC_A"  Set variable  /MRBTS-${MRBTS_ID}/GNBTS-1/GNBCF-1/GNCEL-${cell_id}
        IF  '${value}'!='None'
            Append To List  ${SELECTED_ALIAS_CELLS}  ${value}
            Append To List  ${GRACEFUL_CELLS}  ${value}
            Allow Fault In Watchdog  faultID=49  #fault_name: Cell blocked, active in case of graceful for GSM
        END
        IF  "${value}"!="None"  BREAK
        ${value}=  IF  "${cell_tech}"=="LCELNR_A"  Set variable  /MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        IF  '${value}'!='None'
            Append To List  ${SELECTED_ALIAS_CELLS}  ${value}
            Append To List  ${GRACEFUL_CELLS}  ${value}
        END
        IF  "${value}"!="None"  BREAK
        IF  "${cell_tech}"=="LCELW_A"  Set WNCEL Alias ID  ${cell_id}
        ${value}=  IF  "${cell_tech}"=="LCELW_A"  Set variable  /MRBTS-${MRBTS_ID}/WNBTS-1/WNCEL-${ID}
        IF  '${value}'!='None'  Append To List  ${SELECTED_ALIAS_CELLS}  ${value}
        IF  "${value}"!="None"  BREAK
    END


Set WNCEL Alias ID
  [Arguments]  ${CELL_ID}

  FOR  ${i}  IN  @{WNCEL_A_TO_LCELW_A.keys()}
      ${status}  Run Keyword And Return Status  Should Contain  ${i}  LCELW_A-${CELL_ID}
      ${wncel_a}  Get From Dictionary  ${WNCEL_A_TO_LCELW_A}  ${i}
      ${ID}=  IF  '${status}'=='True'  Evaluate  re.search(r'WNCEL_A-(\\d+)','''${wncel_a}''').group(1)  re
      IF  '${ID}'!='None'  Set Test variable  ${ID}
  END

  RETURN  ${ID}


Mapping WNCEL_A ID From LCELW_A
    ${WNCEL_A_TO_LCELW_A}  Create Dictionary
    FOR  ${WNCEL_A}  IN  @{WNCELS_A}
        ${WNCEL_A_id}  Get From Dictionary  ${WNCEL_A}  distName
        ${LCELW_ID}  Get From Dictionary  ${WNCEL_A['parameters']}  lCelwDN
        Set To Dictionary  ${WNCEL_A_TO_LCELW_A}  ${LCELW_ID}=${WNCEL_A_id}
    END
    Set Test variable  ${WNCEL_A_TO_LCELW_A}


#------------------------------------------ Keywords PS4ALL STOP ---------------------------------------
