*** Settings ***
Library         DateTime
Library         ute_syslog
Library         taf.sbts.oam.coam.admin  WITH NAME  admin

Documentation
...  AUTHORS:
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
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
${SKIP_PARAMETER_RELATION_ERRORS}=  True
&{golden_loadSettings}    cellCapClass=100  mlbEicicOperMode=allUes  nomNumPrbNonGbr=0.01  targetLoadGbrDl=50  targetLoadNonGbrDl=75
                     ...  targetLoadPdcch=90  ulCacIgnore=False  ulCacSelection=ulReflectDlCac  ulStaticCac=100

*** Keywords ***
Get one cell for each technology
    [Documentation]  Returns all cells and only 4g 5g cells in 2 variables
    Check which RAT are on given TestLine
    ${cells_list}  Get cell list
    ${cells_list['cells']['lte']}  Ignore IoT Cells
    @{selected_cells}    Create List
    @{selected_4G_5G_cells}    Create List
    @{cell_tech_list}    Create List
    #part 1 4G, 5G
    Run Keyword If    '${IF_LTE_EXIST}'=='EXIST'    Append To List    ${cell_tech_list}    lte
    Run Keyword If    '${IF_NR_EXIST}'=='EXIST'    Append To List    ${cell_tech_list}    nr
    FOR    ${tech}    IN    @{cell_tech_list}
        ${cell_dict}   Evaluate  random.choice(${cells_list['cells']['${tech}']})  random
        Append To List    ${selected_4G_5G_cells}    ${cell_dict['id']['configuration']}
    END
    #part 2 all cells
    Run Keyword If    '${IF_GSM_EXIST}'=='EXIST'    Append To List    ${cell_tech_list}    gsm
    Run Keyword If    '${IF_WCDMA_EXIST}'=='EXIST'    Append To List    ${cell_tech_list}    wcdma
    FOR    ${tech}    IN    @{cell_tech_list}
        ${cell_dict}   Evaluate  random.choice(${cells_list['cells']['${tech}']})  random
        Append To List    ${selected_cells}    ${cell_dict['id']['configuration']}
    END
    [Return]    ${selected_cells}  ${selected_4G_5G_cells}

Check Syslog For Graceful Cell Shutdown Messages
    [Arguments]  ${technology}
    [Documentation]  checks if graceful massages were sent for 1 choosen technology
    FOR    ${i}  IN RANGE  0  1
        ${cell_shutdown}=  Run keyword if  "${technology}"=="lte"  Set variable  Sent msg: CellShutDownReq
        Exit For Loop If    "${cell_shutdown}"!="None"
        ${cell_shutdown}=  Run keyword if  "${technology}"=="gsm"  Set variable  Ev_TrxImBlockReq
        Exit For Loop If    "${cell_shutdown}"!="None"
        ${cell_shutdown}=  Run keyword if  "${technology}"=="nr"  Set variable  Received cprt::cm::ShutdownResp
        Exit For Loop If    "${cell_shutdown}"!="None"
        ${cell_shutdown}=  Run keyword if  "${technology}"=="wcdma"  Set variable  Performing graceful cell shutdown
        Exit For Loop If    "${cell_shutdown}"!="None"
    END
    ute_syslog.wait for message in syslog file  regexp=${cell_shutdown}  timeout=15min  alias=ute_syslog
    Log  Message ${cell_shutdown} in syslog found  console=${true}

Check cell_m operational state
    [Arguments]  ${selected_cell}  ${expected_cell_state}
    [Documentation]  Fails when cell state != expected cell state. Example ${selected_cell} = MRBTS-101047/WNBTS-1/WNCEL-10703. Used in PS.44.
    ${cells_M}  admin.get managed objects  CELL_M
    ${split_cell_dn}  Split String  ${selected_cell}  /
    ${technology}  ${cell_id}  Split String  ${split_cell_dn}[-1]  -
    FOR    ${i}  IN RANGE  0  1
        ${value}=  Run keyword if  "${technology}"=="LNCEL"  Set variable  /MRBTS-1/RAT-1/MCTRL-1/BBTOP_M-1/MRBTS_M-1/LNBTS_M-1/CELL_M-${cell_id}
        Exit For Loop If  "${value}"!="None"
        ${value}=  Run keyword if  "${technology}"=="GNCEL"  Set variable  /MRBTS-1/RAT-1/MCTRL-1/BBTOP_M-1/MRBTS_M-1/GNBTS_M-1/CELL_M-${cell_id}001
        Exit For Loop If  "${value}"!="None"
        ${value}=  Run keyword if  "${technology}"=="NRCELL"  Set variable  /MRBTS-1/RAT-1/MCTRL-1/BBTOP_M-1/MRBTS_M-1/NRBTS_M-1/CELL_M-${cell_id}
        Exit For Loop If  "${value}"!="None"
        ${value}=  Run keyword if  "${technology}"=="WNCEL"  Set variable  /MRBTS-1/RAT-1/MCTRL-1/BBTOP_M-1/MRBTS_M-1/WNBTS_M-1/CELL_M-${cell_id[-1]}
        Exit For Loop If  "${value}"!="None"
    END
    FOR    ${index}    ${item}    IN ENUMERATE    @{cells_M}
        ${correct_cell}  Run Keyword And Return Status  Dictionary Should Contain Value  ${item}  ${value}
        Run keyword if  ${correct_cell}  Should Be Equal  ${item['parameters']['stateInfo']['operationalState']}  ${expected_cell_state}
        Exit For Loop If  ${correct_cell}
    END

Get NR MIMO/NotMIMO cells and RMODS lists
    [Documentation]  this kw sets test variable of lists of MIMO and NotMIMO cells and radios
    ${cells_list}  Get cell list
    ${nr_cells_length}  Get Length  ${cells_list['cells']['nr']}
    Set test Variable  ${nr_cells_length}
    ${MIMO_cells}  Create List
    ${NOT_MIMO_cells}  Create List
    ${MIMO_RMODS}  Create List
    ${NOT_MIMO_RMODS}  Create List
    ${zero}  Convert To Integer  0
    FOR    ${i}    IN RANGE    0    ${nr_cells_length}
        ${Check_MIMO}  Set Variable  ${cells_list['cells']['nr'][${i}]['carrierList'][${zero}]['antennaLineId']['configuration']}
        ${Global_ID}  Set Variable  ${cells_list['cells']['nr'][${i}]['globalCellId']}
        ${splited_info}    Split String    ${Check_MIMO}    /
        ${cell_dedicated_rmod}    Get From List    ${splited_info}    -2
        ${Status}  Run keyword and return status  Should Contain  ${Check_MIMO}  PHYANT
        Run Keyword If  ${Status}  Append to List  ${MIMO_cells}  ${Global_ID}
        ...  ELSE  Append to List  ${NOT_MIMO_cells}  ${Global_ID}
        Run Keyword If  ${Status}  Append to List  ${MIMO_RMODS}  ${cell_dedicated_rmod}
        ...  ELSE  Append to List  ${NOT_MIMO_RMODS}  ${cell_dedicated_rmod}
    END
    ${MIMO_RMODS}=    Evaluate    list(set(${MIMO_RMODS}))
    ${NOT_MIMO_RMODS}=    Evaluate    list(set(${NOT_MIMO_RMODS}))
    Set Test Variable    ${MIMO_cells}
    Set Test Variable    ${NOT_MIMO_cells}
    Set Test Variable    ${MIMO_RMODS}
    Set Test Variable    ${NOT_MIMO_RMODS}

Get NR Cells For CB010683
    [Documentation]  this kw returns a list of 3 cells where 1st is MIMO cell and others are standard NR Cells
    Get NR MIMO/NotMIMO cells and RMODS lists
    ${selected_cells}  Create List
    Run Keyword If  ${MIMO_cells}!=[]
    ...    Append to List  ${selected_cells}  ${MIMO_cells[0]}
    ...    ELSE    Append to List  ${selected_cells}  ${NOT_MIMO_cells[2]}
    Append to List  ${selected_cells}  ${NOT_MIMO_cells[0]}
    Append to List  ${selected_cells}  ${NOT_MIMO_cells[1]}
    Set Test Variable  ${selected_cells}

Assign Chosen Cells to PSGRP
    ${selected_cells_DNs}  Create List
    Run Keyword IF    ${1st_LNCEL_ID} != 4  append to list  ${selected_cells_DNs}  ${1st_LNCEL_DN}
    Run Keyword IF    ${2nd_LNCEL_ID} != 4  append to list  ${selected_cells_DNs}  ${2nd_LNCEL_DN}
    Run Keyword IF    ${3rd_LNCEL_ID} != 4  append to list  ${selected_cells_DNs}  ${3rd_LNCEL_DN}
    Set Test Variable  ${selected_cells_DNs}
    ${cell_for_call_ID}  Create List
    Run Keyword IF    ${1st_LNCEL_ID} == 4  append to list  ${cell_for_call_ID}  ${1st_LNCEL_ID}
    Run Keyword IF    ${2nd_LNCEL_ID} == 4  append to list  ${cell_for_call_ID}  ${2nd_LNCEL_ID}
    Run Keyword IF    ${3rd_LNCEL_ID} == 4  append to list  ${cell_for_call_ID}  ${3rd_LNCEL_ID}
    Set Test Variable  ${cell_for_call_ID}
    ${cells_for_PSGRP_ID}  Create List
    Run Keyword IF    ${1st_LNCEL_ID} != 4  append to list  ${cells_for_PSGRP_ID}  ${1st_LNCEL_ID}
    Run Keyword IF    ${2nd_LNCEL_ID} != 4  append to list  ${cells_for_PSGRP_ID}  ${2nd_LNCEL_ID}
    Run Keyword IF    ${3rd_LNCEL_ID} != 4  append to list  ${cells_for_PSGRP_ID}  ${3rd_LNCEL_ID}
    Set Test Variable    ${cells_for_PSGRP_ID}
    ${cell_list_to_PSGRP}    Combine Lists    ${cells_for_PSGRP_ID}    ${cell_for_call_ID}
    Set Test Variable    ${cell_list_to_PSGRP}
    ${1st_LNCELL_CB010397}    Set Variable    @{cell_list_to_PSGRP}[0]
    Set Test Variable    ${1st_LNCELL_CB010397}
    ${2nd_LNCELL_CB010397}    Set Variable    @{cell_list_to_PSGRP}[1]
    Set Test Variable    ${2nd_LNCELL_CB010397}
    ${3rd_LNCELL_CB010397}    Set Variable    @{cell_list_to_PSGRP}[2]
    Set Test Variable    ${3rd_LNCELL_CB010397}

Create And Activate PSGRP For CB010397
    [Documentation]
    ...  **Example of simple usage:**
    ...  Create And Activate PSGRP For CB010397
    [Arguments]  ${PSGRP-ID}  ${lbpsDuration}
    ${selected_cells_IDs}=    Create List    ${1st_LNCELL_CB010397}    ${2nd_LNCELL_CB010397}    ${3rd_LNCELL_CB010397}
    ${delta_create_psgrp}=  Set Variable  psgrp_create
    ${PSGRP_DN}=  Set Variable  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}
    admin.create delta  ${delta_create_psgrp}
    admin.append managed object to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  create  ${delta_create_psgrp}
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  lbpsCSONCtlEnabled  false  ${delta_create_psgrp}
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  lbpsLastCellMinLoad  2  ${delta_create_psgrp}
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  lbpsLastCellRTXMinLoad  10  ${delta_create_psgrp}
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  lbpsLastCellSOEnabled  false  ${delta_create_psgrp}
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  lbpsMaxLoad  11  ${delta_create_psgrp}
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  lbpsMinLoad  2  ${delta_create_psgrp}
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  lbpsPdcchLoadOffset  4  ${delta_create_psgrp}
    admin.append parameter update to delta  ${PSGRP_DN}  lbpsRTXMaxLoad  40  ${delta_create_psgrp}
    admin.append parameter update to delta  ${PSGRP_DN}  lbpsRTXMinLoad  19  ${delta_create_psgrp}
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
    ${item}=  Create List  20  30  100
    FOR  ${i}  ${cell}  IN ZIP  ${item}  ${selected_cells_IDs}
        Run Keyword If  '${if_actExtCellSOMethod}'=='PASS'
        ...  Set To Dictionary  ${lbpsCellList}  lbpsUseExtConfig  false
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
    admin.save delta  ${RESULTS}/delta_create_psgrp_${PSGRP-ID}_LTE1203.json  ${delta_create_psgrp}
    Log  Activate Power Saving Group under MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  console=${true}
    admin.perform delta recommissioning  ${RESULTS}/delta_create_psgrp_${PSGRP-ID}_LTE1203.json  ${delta_create_psgrp}
    ${end_time}=  Add Time To Date  ${time_with_offset}  ${lbpsDuration[0]} minutes
    ${end_hour}=  Convert Date  ${end_time}  result_format=%H
    ${end_minutes}=  Convert Date  ${end_time}  result_format=%M
    Log  Power Saving Group time frame: ${start_hour}:${start_minutes}-${end_hour}:${end_minutes} (+${lbpsDuration[0]} minutes)  console=${true}
    Log  Affected cells in ${PSGRP-ID}:  console=${true}
    Log  - Power Saving Saving: LNCEL_R-${1st_LNCELid} and LNCEL_R-${2nd_LNCELid}  console=${true}

Create And Activate NRPGRP For CB010683
    [Documentation]
    ...  Creates and activates NRGRP.
    ...  Demands ${cell_order}  ${selected_cells}
    [Arguments]  ${lbpsDuration}=25  ${NRPGRP-ID}=13  ${test_id}=43
    ${delta_create_nrpgrp}=  Set Variable  nrpgrp_create
    ${NRPGRP_DN}=  Set Variable  MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRPGRP-${NRPGRP-ID}
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
    ${lbpsCellList}=  Create Dictionary
    FOR  ${i}  ${cell}  IN ZIP  ${cell_order}  ${selected_cells}
      Set To Dictionary  ${lbpsCellList}  lbpsCellSOOrder=${i}
      Set To Dictionary  ${lbpsCellList}  nrCellId=${cell}
      ${lbpsUseExtConfig_state}  Run Keyword If  '${i}'=='100'  Set Variable  false
      ...  ELSE  Set Variable  true
      Run Keyword If  '${if_actNrExtCellSOMethod}'=='PASS'
        ...  Set To Dictionary  ${lbpsCellList}  lbpsUseExtConfig  ${lbpsUseExtConfig_state}
      admin.append complex item to delta  ${NRPGRP_DN}  list_name=lbpsCellList  &{lbpsCellList}  delta_id=${delta_create_nrpgrp}
    END
    Log to console  Selected Cells: ${selected_cells}
    Get Time And Date With Minute Offset  9minutes  5minutes
    ${lbpsPeriodList}=  Create Dictionary
    Set To Dictionary  ${lbpsPeriodList}  lbpsDayOfWeek=${day}
    ${lbpsDuration}=  Get Regexp Matches  ${lbpsDuration}  \\d+
    Set To Dictionary  ${lbpsPeriodList}  lbpsDuration=${lbpsDuration[0]}
    Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeHour=${start_hour}
    Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeMinute=${start_minutes}
    Set To Dictionary  ${lbpsPeriodList}  lbpsSuspended=notSuspended
    admin.append complex item to delta  ${NRPGRP_DN}  list_name=lbpsPeriodList  &{lbpsPeriodList}  delta_id=${delta_create_nrpgrp}
    Log  Power Saving For NRPGRP start: ${start_hour}:${start_minutes}, duration: ${lbpsDuration[0]} minutes  console=${true}
    ${lbpsCellPeriodList}=  Create Dictionary
    Set To Dictionary  ${lbpsCellPeriodList}  lbpsCellDayOfWeek=${day}
    Set To Dictionary  ${lbpsCellPeriodList}  nrCellId=${selected_cells[0]}
    Set To Dictionary  ${lbpsCellPeriodList}  lbpsCellSOMethod  mixed switch off
    Run Keyword If  ${test_id}==43  Set To Dictionary  ${lbpsCellPeriodList}  lbpsCellDuration=${lbpsDuration[0]}
    Run Keyword If  ${test_id}==39  Set To Dictionary  ${lbpsCellPeriodList}  lbpsCellDuration=25
    Run Keyword If  ${test_id}==41  Set To Dictionary  ${lbpsCellPeriodList}  lbpsCellDuration=40
    Set To Dictionary  ${lbpsCellPeriodList}  lbpsCellStartTimeHour=${start_hour}
    Set To Dictionary  ${lbpsCellPeriodList}  lbpsCellStartTimeMinute=${start_minutes}
    admin.append complex item to delta  ${NRPGRP_DN}  list_name=lbpsCellPeriodList  &{lbpsCellPeriodList}  delta_id=${delta_create_nrpgrp}
#PS.39 only part
    ${lbpsCellPeriodList}=  Create Dictionary
    Set To Dictionary  ${lbpsCellPeriodList}  lbpsCellDayOfWeek=${day}
    Run Keyword If  ${test_id}==39  Set To Dictionary  ${lbpsCellPeriodList}  nrCellId=${selected_cells[1]}
    Set To Dictionary  ${lbpsCellPeriodList}  lbpsCellSOMethod  mixed switch off
    Run Keyword If  ${test_id}==39  Set To Dictionary  ${lbpsCellPeriodList}  lbpsCellDuration=25
    Set To Dictionary  ${lbpsCellPeriodList}  lbpsCellStartTimeHour=${start_hour}
    Set To Dictionary  ${lbpsCellPeriodList}  lbpsCellStartTimeMinute=${start_minutes}
    Run Keyword If  ${test_id}==39
    ...  admin.append complex item to delta  ${NRPGRP_DN}  list_name=lbpsCellPeriodList  &{lbpsCellPeriodList}  delta_id=${delta_create_nrpgrp}
#PS.39 only part end
    Run Keyword If  ${test_id}==39  Get Time And Date With Minute Offset  39minutes  5minutes
    ${lbpsCellPeriodList}=  Create Dictionary
    Set To Dictionary  ${lbpsCellPeriodList}  lbpsCellDayOfWeek=${day}
    Run Keyword If  ${test_id}==43  Set To Dictionary  ${lbpsCellPeriodList}  nrCellId=${selected_cells[1]}
    Run Keyword If  ${test_id}==39  Set To Dictionary  ${lbpsCellPeriodList}  nrCellId=${selected_cells[0]}
    Run Keyword If  ${test_id}==41  Set To Dictionary  ${lbpsCellPeriodList}  nrCellId=${selected_cells[1]}
    Set To Dictionary  ${lbpsCellPeriodList}  lbpsCellSOMethod  TX switch off
    Run Keyword If  ${test_id}==43  Set To Dictionary  ${lbpsCellPeriodList}  lbpsCellDuration=${lbpsDuration[0]}
    Run Keyword If  ${test_id}==39  Set To Dictionary  ${lbpsCellPeriodList}  lbpsCellDuration=20
    Run Keyword If  ${test_id}==41  Set To Dictionary  ${lbpsCellPeriodList}  lbpsCellDuration=40
    Set To Dictionary  ${lbpsCellPeriodList}  lbpsCellStartTimeHour=${start_hour}
    Set To Dictionary  ${lbpsCellPeriodList}  lbpsCellStartTimeMinute=${start_minutes}
    admin.append complex item to delta  ${NRPGRP_DN}  list_name=lbpsCellPeriodList  &{lbpsCellPeriodList}  delta_id=${delta_create_nrpgrp}
#PS.39 only part
    Run Keyword If  ${test_id}==39  Get Time And Date With Minute Offset  39minutes  5minutes
    ${lbpsCellPeriodList}=  Create Dictionary
    Set To Dictionary  ${lbpsCellPeriodList}  lbpsCellDayOfWeek=${day}
    Run Keyword If  ${test_id}==39  Set To Dictionary  ${lbpsCellPeriodList}  nrCellId=${selected_cells[1]}
    Set To Dictionary  ${lbpsCellPeriodList}  lbpsCellSOMethod  TX switch off
    Run Keyword If  ${test_id}==39  Set To Dictionary  ${lbpsCellPeriodList}  lbpsCellDuration=20
    Set To Dictionary  ${lbpsCellPeriodList}  lbpsCellStartTimeHour=${start_hour}
    Set To Dictionary  ${lbpsCellPeriodList}  lbpsCellStartTimeMinute=${start_minutes}
    Run Keyword If  ${test_id}==39
    ...  admin.append complex item to delta  ${NRPGRP_DN}  list_name=lbpsCellPeriodList  &{lbpsCellPeriodList}  delta_id=${delta_create_nrpgrp}
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
    ${delta_create_psgrp}=  Set Variable  psgrp_create
    ${PSGRP_DN}=  Set Variable  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}
    admin.create delta  ${delta_create_psgrp}
    admin.append managed object to delta  ${PSGRP_DN}  create  ${delta_create_psgrp}
    admin.append parameter update to delta  ${PSGRP_DN}  lbpsCSONCtlEnabled  false  ${delta_create_psgrp}
    admin.append parameter update to delta  ${PSGRP_DN}  lbpsLastCellMinLoad  5  ${delta_create_psgrp}
    admin.append parameter update to delta  ${PSGRP_DN}  lbpsLastCellRTXMinLoad  2  ${delta_create_psgrp}
    admin.append parameter update to delta  ${PSGRP_DN}  lbpsLastCellSOEnabled  true  ${delta_create_psgrp}
    admin.append parameter update to delta  ${PSGRP_DN}  lbpsMaxLoad  5  ${delta_create_psgrp}
    admin.append parameter update to delta  ${PSGRP_DN}  lbpsMinLoad  2  ${delta_create_psgrp}
    admin.append parameter update to delta  ${PSGRP_DN}  lbpsPdcchLoadOffset  4  ${delta_create_psgrp}
    admin.append parameter update to delta  ${PSGRP_DN}  lbpsRTXCellCapOffset  80  ${delta_create_psgrp}
    admin.append parameter update to delta  ${PSGRP_DN}  lbpsRTXMaxLoad  10  ${delta_create_psgrp}
    admin.append parameter update to delta  ${PSGRP_DN}  lbpsRTXMinLoad  5  ${delta_create_psgrp}
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
    ${gpoup_obj_all}=  admin.get managed objects  SWRESETREQ_A
    Run Keyword If  ${gpoup_obj_all}!=[]  Run Keywords
    ...  Log  SWRESETREQ object exist and will be deleted  console=${true}
    ...  AND  Delete Old SWRESETREQ Object  ${gpoup_obj_all}
    ...  ELSE  Log  There is no SWRESETREQ object on testline

Delete Old SWRESETREQ Object
    [Documentation]  Remove old SWRESETREQ object from BTS.
    [Arguments]    ${gpoup_obj_all}
    ${gpoup_path_list}=  Create List
    FOR  ${i}  IN  @{gpoup_obj_all}
        ${gpoup_distName}=  Set Variable  ${i['distName']}
        ${ignore}  ${gpoup_path}=  Split String From Right  ${gpoup_distName}  separator=SCF-1/
        ${gpoup}=  Replace String  ${gpoup_path}  search_for=_A  replace_with=
        Append To List  ${gpoup_path_list}  ${gpoup}
    END
    ${delta_gpoup_obj}=  Set Variable  gpoup_del
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
    ${delta_create_SWRESETREQ}=  Set Variable  SWRESETREQ_create
    ${SWRESETREQ_DN}=  Set Variable  MRBTS-${MRBTS_ID}/MNL-$1/CMD-1/${SWRESETREQ-ID}
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
    ${NRPGRP_DN}=  Set Variable  MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRPGRP-${nrpgrp_id}
    ${nrpgrpParameters}=  admin.get managed objects  NRPGRP_A
    ${lbpsPeriodListToSuspend}=  Create Dictionary
    ${delta_nrpgrpSuspend}=  Set Variable  nrpgrpSuspend
    ${PLANS_DIR}    Set Variable    ${RESULTS}/plans
    admin.create delta  ${delta_nrpgrpSuspend}
    FOR  ${nrpgrpParameter}  IN  @{nrpgrpParameters}
      ${lbpsPeriodList}=  Get From Dictionary  ${nrpgrpParameter['parameters']}  lbpsPeriodList
      Set Test Variable   ${lbpsPeriodList}
    END
    ${counter}=  Set Variable    ${1}
    FOR  ${parameter}  IN  @{lbpsPeriodList}
      ${lbpsDayOfWeek}=  Get From Dictionary  ${parameter}  lbpsDayOfWeek
      ${lbpsDuration}=  Get From Dictionary  ${parameter}  lbpsDuration
      ${lbpsStartTimeHour}=  Get From Dictionary  ${parameter}  lbpsStartTimeHour
      ${lbpsStartTimeMinute}=  Get From Dictionary  ${parameter}  lbpsStartTimeMinute
      ${lbpsCurrentSuspend}=  Get From Dictionary  ${parameter}  lbpsSuspended
      Set To Dictionary  ${lbpsPeriodListToSuspend}  lbpsDayOfWeek=${lbpsDayOfWeek}
      Set To Dictionary  ${lbpsPeriodListToSuspend}  lbpsDuration=${lbpsDuration}
      Set To Dictionary  ${lbpsPeriodListToSuspend}  lbpsStartTimeHour=${lbpsStartTimeHour}
      Set To Dictionary  ${lbpsPeriodListToSuspend}  lbpsStartTimeMinute=${lbpsStartTimeMinute}
      Run Keyword If  ${counter} == ${period}  Set To Dictionary  ${lbpsPeriodListToSuspend}  lbpsSuspended=${suspended}
      Run Keyword If  ${counter} != ${period}  Set To Dictionary  ${lbpsPeriodListToSuspend}  lbpsSuspended=${lbpsCurrentSuspend}
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
    ${delta_create_nrpgrp}=  Set Variable  nrpgrp_create
    ${NRPGRP_DN}=  Set Variable  MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRPGRP-${NRPGRP-ID}
    admin.create delta  ${delta_create_nrpgrp}
    admin.append managed object to delta  ${NRPGRP_DN}  create  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsCSONCtlEnabled  false  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsLastCellMinLoad  10  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsLastCellSOEnabled  false  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsLoadCalcMethod  Max(G, C, P)  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsMaxLoad  30  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsMinLoad  20  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsMonWinForCellSOff  180  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsMonWinForCellSOn  60  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsSOffTrRule  MaxValueMethod  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsPdcchLoadOffset  4  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsSOMethod  cell switch off  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsSOnTrRule  MinValueMethod  ${delta_create_nrpgrp}
    ${lbpsCellList}=  Create Dictionary
    ${item}=  Create List  1  2  3
    FOR  ${i}  ${cell}  IN ZIP  ${item}  ${selected_cells_IDs}
        Set To Dictionary  ${lbpsCellList}  lbpsCellSOOrder=${i}
        Set To Dictionary  ${lbpsCellList}  nrCellId=${cell}
        Run Keyword If  '${if_actNrExtCellSOMethod}'=='PASS'
        ...  Set To Dictionary  ${lbpsCellList}  lbpsUseExtConfig  false
        admin.append complex item to delta  ${NRPGRP_DN}  list_name=lbpsCellList  &{lbpsCellList}  delta_id=${delta_create_nrpgrp}
    END
    Get Time And Date With Minute Offset  4minutes  5minutes
    ${lbpsPeriodList}=  Create Dictionary
    Set To Dictionary  ${lbpsPeriodList}  lbpsDayOfWeek=${day}
    ${lbpsDuration}=  Get Regexp Matches  ${lbpsDuration}  \\d+
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
    ${delta_create_nrpgrp}=  Set Variable  nrpgrp_create
    ${PLANS_DIR}    Set Variable    ${RESULTS}/plans
    ${NRPGRP_DN}=  Set Variable  MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRPGRP-${nrpgrp_id}
    admin.create delta  ${delta_create_nrpgrp}
    admin.append managed object to delta  ${NRPGRP_DN}  create  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsCSONCtlEnabled  false  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsLastCellMinLoad  2  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsLastCellSOEnabled  false  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsMaxLoad  30  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsMinLoad  20  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsPdcchLoadOffset  15  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsSOMethod  cell switch off  ${delta_create_nrpgrp}
    ${lbpsCellList}=  Create Dictionary
    FOR  ${i}  ${cell}  IN ZIP  ${cell_order}  ${selected_cells}
      Set To Dictionary  ${lbpsCellList}  lbpsCellSOOrder=${i}
      Set To Dictionary  ${lbpsCellList}  nrCellId=${cell}
      Run Keyword If  '${if_actNrExtCellSOMethod}'=='PASS'
        ...  Set To Dictionary  ${lbpsCellList}  lbpsUseExtConfig  false
      admin.append complex item to delta  ${NRPGRP_DN}  list_name=lbpsCellList  &{lbpsCellList}  delta_id=${delta_create_nrpgrp}
    END
    Get Time And Date With Minute Offset  3minutes  ${duration} minutes
    ${lbpsPeriodList}=  Create Dictionary
    Set To Dictionary  ${lbpsPeriodList}  lbpsDayOfWeek=${day}
    Set To Dictionary  ${lbpsPeriodList}  lbpsDuration=${duration}
    Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeHour=${start_hour}
    Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeMinute=${start_minutes}
    Set To Dictionary  ${lbpsPeriodList}  lbpsSuspended=${suspended_1}
    admin.append complex item to delta  ${NRPGRP_DN}  list_name=lbpsPeriodList  &{lbpsPeriodList}  delta_id=${delta_create_nrpgrp}
    Log  Power Saving Group time frame: ${start_hour}:${start_minutes}-${end_hour}:${end_minutes}  console=${true}
    Get Time And Date With Minute Offset  25minutes  ${duration_2} minutes
    ${lbpsPeriodList}=  Create Dictionary
    Set To Dictionary  ${lbpsPeriodList}  lbpsDayOfWeek=${day}
    Set To Dictionary  ${lbpsPeriodList}  lbpsDuration=${duration_2}
    Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeHour=${start_hour}
    Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeMinute=${start_minutes}
    Set To Dictionary  ${lbpsPeriodList}  lbpsSuspended=${suspended_2}
    admin.append complex item to delta  ${NRPGRP_DN}  list_name=lbpsPeriodList  &{lbpsPeriodList}  delta_id=${delta_create_nrpgrp}
    Log  Power Saving Group time frame: ${start_hour}:${start_minutes}-${end_hour}:${end_minutes}  console=${true}
    Get Time And Date With Minute Offset  46minutes  ${duration_3} minutes
    ${lbpsPeriodList}=  Create Dictionary
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
    Log To Console    Wait until ${given_date}
    FOR    ${i}    IN RANGE    0    ${number_of_loops}
        ${current_date}  Get Current Date
        ${result}  Subtract Date From Date  ${given_date}  ${current_date}
        Exit For Loop If  ${result} <= 0
        Sleep  ${loop_duration} s
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
    Set Test Variable    @{selected_cells}
    Set Test Variable    @{selected_cells_paths}
    FOR    ${cell}    IN RANGE    ${nr_cells_length}
      ${cell_id}    ${cell_path}    Get Id Of Selected Cell  ${nr_cells}[${cell}]
      Append To List    ${selected_cells}  ${cell_id}
      Append To List    ${selected_cells_paths}  ${cell_path}
    END

Select Three Random LTE Cells
    ${LTE_cells}  admin.get parameters for all  LNCEL
    @{cell}  Select 3 Random LNCEL From ${LTE_cells}
    ${1st_LNCEL_ID}  ${1st_LNCEL_DN}  Get Id Of Selected Cell  @{cell}[0]
    ${2nd_LNCEL_ID}  ${2nd_LNCEL_DN}  Get Id Of Selected Cell  @{cell}[1]
    ${3rd_LNCEL_ID}  ${3rd_LNCEL_DN}  Get Id Of Selected Cell  @{cell}[2]
    Set Test Variable  ${1st_LNCEL_ID}
    Set Test Variable  ${2nd_LNCEL_ID}
    Set Test Variable  ${3rd_LNCEL_ID}
    Set Test Variable  ${1st_LNCEL_DN}
    Set Test Variable  ${2nd_LNCEL_DN}
    Set Test Variable  ${3rd_LNCEL_DN}

Remove PSGRP/NRPGRP Objects If Exist
    [Documentation]  This keyword remove PSGRP/NRPGRP objects if exist on BTS.
    [Arguments]  ${group}
    Run Keyword If  '${group}'=='PSGRP'
    ...  Remove PSGRP Objects If Exist
    ...  ELSE IF  '${group}'=='NRPGRP'
    ...  Remove NRPGRP Objects If Exist
    ...  ELSE IF  '${group}'== 'PSGRP/NRPGRP'  Run Keywords
    ...  Remove PSGRP Objects If Exist
    ...  AND  Remove NRPGRP Objects If Exist

Remove PSGRP Objects If Exist
    ${gpoup_obj_all}=  admin.get managed objects  PSGRP_A
    Run Keyword If  ${gpoup_obj_all}!=[]  Run Keywords
    ...  Log  PSGRP object exist and will be deleted  console=${true}
    ...  AND  Delete Old PSGRP/NRPGRP Objects  ${gpoup_obj_all}
    ...  ELSE  Log  There is no PSGRP objects on testline

Remove NRPGRP Objects If Exist
    ${gpoup_obj_all}=  admin.get managed objects  NRPGRP_A
    Run Keyword If  ${gpoup_obj_all}!=[]  Run Keywords
    ...  Log  NRPGRP object exist and will be deleted  console=${true}
    ...  AND  Delete Old PSGRP/NRPGRP Objects  ${gpoup_obj_all}
    ...  ELSE  Log  There is no NRPGRP objects on testline

Delete Old PSGRP/NRPGRP Objects
    [Documentation]  Remove old PSGRP/NRPGRP objects from BTS.
    [Arguments]    ${gpoup_obj_all}
    ${gpoup_path_list}=  Create List
    FOR  ${i}  IN  @{gpoup_obj_all}
        ${gpoup_distName}=  Set Variable  ${i['distName']}
        ${ignore}  ${gpoup_path}=  Split String From Right  ${gpoup_distName}  separator=SCF-1/
        ${gpoup}=  Replace String  ${gpoup_path}  search_for=_A  replace_with=
        Append To List  ${gpoup_path_list}  ${gpoup}
    END
    ${delta_gpoup_obj}=  Set Variable  gpoup_del
    admin.create delta  ${delta_gpoup_obj}
    FOR  ${i}  IN  @{gpoup_path_list}
        admin.append managed object to delta  ${i}  delete  delta_id=${delta_gpoup_obj}
    END
    admin.get delta  ${delta_gpoup_obj}
    admin.save delta  ${RESULTS}/delete_gpoup_obj.json  delta_id=${delta_gpoup_obj}
    Sleep    30s
    admin.perform delta recommissioning  ${RESULTS}/delete_gpoup_obj.json  ${SKIP_PARAMETER_RELATION_ERRORS}

Change Parameter Under LNCEL
    [Documentation]  This KW changes parameter under LNCEL object without using Netact.
	...  Example of usage:
    ...  Change Parameter Under LNCEL  administrativeState  shutting down  ${1st_CELL_ID}
    [Arguments]  ${parameter}  ${value}  ${ID}
    ${parameter_delta}=  Set Variable  lncel_${parameter}_${value}
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
    ${parameter_delta}=  Set Variable  nrcell_${parameter}_${value}
    admin.create delta  ${parameter_delta}
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${ID}  ${parameter}  ${value}  ${parameter_delta}
    admin.get delta  ${parameter_delta}
    admin.save delta  ${RESULTS}/nrcell_delta_change_admstate_${parameter}_${value}.json  ${parameter_delta}
    admin.perform delta recommissioning  ${RESULTS}/nrcell_delta_change_admstate_${parameter}_${value}.json  ${parameter_delta}

Create List Of FDD Cells
    ${lncel_param}=  admin.get parameters for all  LNCEL
    ${lncel_fdd}=  Create List
    ${lncel_fdd_ids}=  Create List
    FOR  ${ITEM}  IN  @{lncel_param}
        Run keyword If  '${item['technology']}'=='FDD'
        ...  Append To List  ${lncel_fdd}  ${item['id']}
    END
    FOR  ${cell}  IN  @{lncel_fdd_ids}
        ${id}=  Evaluate  re.search(r'LNCEL_R-(\\d+)','''${item}''').group(1)  re
        Append To List  ${lncel_fdd_ids}  ${id}
    END
    [Return]  ${lncel_fdd_ids}

Check Syslog For Gracefull Shutdown Messages
    [Documentation]  Grep syslog.
    ...  **Author:** tomasz.marchewka@nokia.com
    ...  **Example of simple usage:**
    ...   Check Syslog For Gracefull Shutdown Messages  LTE
    ...   Check Syslog For Gracefull Shutdown Messages  LTE/NR
    ...
    [Arguments]  ${rat}
    ${start_shutdown_lte}=  Set Variable If  '${rat}'=='LTE' or '${rat}'=='LTE/NR'  RromGracefulCellShutdownFsm.*Start Cell ShutDown procedure.*
    ${already_shutdown}=  Set Variable If  '${rat}'=='LTE' or '${rat}'=='LTE/NR'  RromGracefulCellShutdownFsm.*is already shutdown.*
    ${resetting_shutdown}=  Set Variable If  '${rat}'=='LTE' or '${rat}'=='LTE/NR'  RromGracefulCellShutdownFsm.*Resetting shutdown service.*
    ${pscell_shutdown}=  Set Variable If  '${rat}'=='NR' or '${rat}'=='LTE/NR'  PsCell.*QueueStateDefault.*PSCELL_DL_CELL_SHUTDOWN_REQ_MSG
    ${start_shutdown_nr}=  Set Variable If  '${rat}'=='NR' or '${rat}'=='LTE/NR'  .*slotType\/PowerReduction.*Starting cell shutdown.*
    ${cell_shutdown}=  Set Variable If  '${rat}'=='NR' or '${rat}'=='LTE/NR'  .*slotType\/PowerReduction.*Cell shutdown config.*
    Run Keyword If  '${rat}'=='LTE' or '${rat}'=='LTE/NR'  Run Keywords
    ...  ute_syslog.wait for message in syslog file  regexp=${start_shutdown_lte}  timeout=15min  alias=ute_syslog
    ...  AND  Log  Message ${start_shutdown_lte} in syslog found  console=${true}
    Run Keyword If  '${rat}'=='LTE' or '${rat}'=='LTE/NR'  Run Keywords
    ...  ute_syslog.wait for message in syslog file  regexp=${already_shutdown}  timeout=15min  alias=ute_syslog
    ...  AND  Log  Message ${already_shutdown} in syslog found  console=${true}
    Run Keyword If  '${rat}'=='LTE' or '${rat}'=='LTE/NR'  Run Keywords
    ...  ute_syslog.wait for message in syslog file  regexp=${resetting_shutdown}  timeout=15min  alias=ute_syslog
    ...  AND  Log  Message ${resetting_shutdown} in syslog found  console=${true}
    Run Keyword If  '${rat}'=='NR' or '${rat}'=='LTE/NR'  Run Keywords
    ...  ute_syslog.wait for message in syslog file  regexp=${pscell_shutdown}  timeout=15min  alias=ute_syslog
    ...  AND  Log  Message ${pscell_shutdown} in syslog found  console=${true}
    Run Keyword If  '${rat}'=='NR' or '${rat}'=='LTE/NR'  Run Keywords
    ...  ute_syslog.wait for message in syslog file  regexp=${start_shutdown_nr}  timeout=15min  alias=ute_syslog
    ...  AND  Log  Message ${start_shutdown_nr} in syslog found  console=${true}
    Run Keyword If  '${rat}'=='NR' or '${rat}'=='LTE/NR'  Run Keywords
    ...  ute_syslog.wait for message in syslog file  regexp=${cell_shutdown}  timeout=15min  alias=ute_syslog
    ...  AND  Log  Message ${cell_shutdown} in syslog found  console=${true}

Set Parameters For LTE Graceful Cell Shutdown
    [Arguments]  ${enableGrflShdn}  ${shutdownStepAmount}  ${shutdownWindow}
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    Set Feature Under Given Object  ${LNBTS_DistName}  enableGrflShdn  ${enableGrflShdn}
    Set Feature Under Given Object  ${LNBTS_DistName}  shutdownStepAmount  ${shutdownStepAmount}
    ${shutdownWindow}=  Get Regexp Matches  ${shutdownWindow}  \\d+
    Set Feature Under Given Object  ${LNBTS_DistName}  shutdownWindow  ${shutdownWindow[0]}
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    ${post_action_reset_number}=  Get Reset Counter From Blackbox
    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
    Run Keyword If  ${counter_diff}==${0}  Log  Reset Counter not incremented
    ...  ELSE IF  ${counter_diff}>${1}  Fail  msg=Reset Counter incremented (more than 1 unexpected reset)
    ...  ELSE IF  ${counter_diff}==${1}  Fail  msg=Reset Counter incremented +1

Set Parameters For NR Graceful Cell Shutdown
    [Arguments]  ${actGrflShdn}  ${shutdownStepAmount}  ${shutdownWindow}
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    Set Feature Under Given Object  ${NRBTS_DistName}  actGrflShdn  ${actGrflShdn}
    Set Feature Under Given Object  ${NRBTS_DistName}  shutdownStepAmount  ${shutdownStepAmount}
    ${shutdownWindow}=  Get Regexp Matches  ${shutdownWindow}  \\d+
    Set Feature Under Given Object  ${NRBTS_DistName}  shutdownWindow  ${shutdownWindow[0]}
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    ${post_action_reset_number}=  Get Reset Counter From Blackbox
    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
    Run Keyword If  ${counter_diff}==${0}  Log  Reset Counter not incremented
    ...  ELSE IF  ${counter_diff}>${1}  Fail  msg=Reset Counter incremented (more than 1 unexpected reset)
    ...  ELSE IF  ${counter_diff}==${1}  Fail  msg=Reset Counter incremented +1

Check which technology have to be chosen
    Run Keyword If  '${IF_GSM_EXIST}'=='EXIST' and '${IF_WCDMA_EXIST}'=='EXIST' and '${IF_LTE_EXIST}'=='EXIST' and '${IF_NR_EXIST}'=='EXIST'
    ...  Log to console    \n======= Actual Test Line RATs: NR || LTE || WCDMA || GSM =======
    ...  ELSE IF  '${IF_GSM_EXIST}'=='NO' and '${IF_WCDMA_EXIST}'=='EXIST' and '${IF_LTE_EXIST}'=='EXIST' and '${IF_NR_EXIST}'=='EXIST'
    ...  Log to console  \n======= Actual Test Line RATs: NR || LTE || WCDMA =======
    ...  ELSE IF  '${IF_GSM_EXIST}'=='NO' and '${IF_WCDMA_EXIST}'=='NO' and '${IF_LTE_EXIST}'=='EXIST' and '${IF_NR_EXIST}'=='EXIST'
    ...  Log to console  \n======= Actual Test Line RATs: NR || LTE  =======
    ...  ELSE IF  '${IF_GSM_EXIST}'=='NO' and '${IF_WCDMA_EXIST}'=='NO' and '${IF_LTE_EXIST}'=='NO' and '${IF_NR_EXIST}'=='EXIST'
    ...  Log to console  \n======= Actual Test Line RATs: NR =======
    ...  ELSE IF  '${IF_GSM_EXIST}'=='NO' and '${IF_WCDMA_EXIST}'=='NO' and '${IF_LTE_EXIST}'=='EXIST' and '${IF_NR_EXIST}'=='NO'
    ...  Log to console  \n======= Actual Test Line RATs: LTE =======
    ...  ELSE IF  '${IF_GSM_EXIST}'=='EXIST' and '${IF_WCDMA_EXIST}'=="NO' and '${IF_LTE_EXIST}'=='EXIST' and '${IF_NR_EXIST}'=='NO'
    ...  Log to console  \n======= Actual Test Line RATs: LTE || GSM =======
    ...  ELSE IF  '${IF_GSM_EXIST}'=='EXIST' and '${IF_WCDMA_EXIST}'=='NO' and '${IF_LTE_EXIST}'=='NO' and '${IF_NR_EXIST}'=='EXIST'
    ...  Log to console  \n======= Actual Test Line RATs: NR || GSM =======
    ...  ELSE IF  '${IF_GSM_EXIST}'=='NO' and '${IF_WCDMA_EXIST}'=='EXIST' and '${IF_LTE_EXIST}'=='NO' and '${IF_NR_EXIST}'=='EXIST'
    ...  Log to console  \n======= Actual Test Line RATs: NR || WCDMA =======
    ...  ELSE IF  '${IF_GSM_EXIST}'=='NO' and '${IF_WCDMA_EXIST}'=='EXIST' and '${IF_LTE_EXIST}'=='EXIST' and '${IF_NR_EXIST}'=='NO'
    ...  Log to console  \n======= Actual Test Line RATs: LTE || WCDMA =======

Check which RAT are on given TestLine
    ${GSM_DEPLOYED}=  admin.get ids for all  GNCEL
    ${WCDMA_DEPLOYED}=  admin.get ids for all  WNCEL
    ${LTE_DEPLOYED}=  admin.get ids for all  LNCEL
    ${NR_DEPLOYED}=  admin.get ids for all  NRCEL
    ${IF_GSM_EXIST}=  Set Variable If  ${GSM_DEPLOYED}!=[]  EXIST  NO
    ${IF_WCDMA_EXIST}=  Set Variable If  ${WCDMA_DEPLOYED}!=[]  EXIST  NO
    ${IF_LTE_EXIST}=  Set Variable If  ${LTE_DEPLOYED}!=[]  EXIST  NO
    ${IF_NR_EXIST}=  Set Variable If  ${NR_DEPLOYED}!=[]  EXIST  NO
    Set Suite Variable  ${IF_GSM_EXIST}
    Set Suite Variable  ${IF_WCDMA_EXIST}
    Set Suite Variable  ${IF_LTE_EXIST}
    Set Suite Variable  ${IF_NR_EXIST}

Select Two Random LTE Cells
    ${LTE_cells}  admin.get parameters for all  LNCEL
    @{cell}  Select 2 Random LNCEL From ${LTE_cells}
    ${1st_LNCEL_ID}  ${1st_LNCEL_DN}  Get Id Of Selected Cell  @{cell}[0]
    ${2nd_LNCEL_ID}  ${2nd_LNCEL_DN}  Get Id Of Selected Cell  @{cell}[1]
    Set Test Variable  ${1st_LNCEL_ID}  #1st_cell_id
    Set Test Variable  ${2nd_LNCEL_ID}  #2nd_cell_id
    Set Test Variable  ${1st_LNCEL_DN}  #1st_cell_path
    Set Test Variable  ${2nd_LNCEL_DN}  #2nd_cell_path

Select Two Random NR Cells
    ${NR_cells}  admin.get parameters for all  NRCEL
    @{cell}  Select 2 Random NRCEL From ${NR_cells}
    ${1st_NRCELL_ID}  ${1st_NRCELL_DN}  Get Id Of Selected Cell  @{cell}[0]
    ${2nd_NRCELL_ID}  ${2nd_NRCELL_DN}  Get Id Of Selected Cell  @{cell}[1]
    Set Test Variable  ${1st_NRCELL_ID}  #1st_cell_id
    Set Test Variable  ${2nd_NRCELL_ID}  #2nd_cell_id
    Set Test Variable  ${1st_NRCELL_DN}  #1st_cell_path
    Set Test Variable  ${2nd_NRCELL_DN}  #2nd_cell_pathl

Select Two Random NR Cells NSA
    [Documentation]  KW is used to select random cells from different RMODs if barring does not work for NSA NRCells
    ${NRCELLS_R}  admin.get managed objects  NRCELL_R
    Set Test Variable  ${NRCELLS_R}
    ${other_cell_ids}    Create List
    Set Test variable    ${other_cell_ids}
    ${NR_cells}  admin.get parameters for all  NRCEL
    @{cell}  Select 1 Random NRCEL From ${NR_cells}
    ${1st_NRCELL_ID}  ${1st_NRCELL_DN}  Get Id Of Selected Cell  @{cell}[0]
    Set Test Variable  ${1st_NRCELL_ID}  #1st_cell_id
    Set Test Variable  ${1st_NRCELL_DN}  #1st_cell_path
    Get RMOD of 1st cell
    Set Test Variable  ${1st_cell_RMOD}
    Find NRCELLs on the same RMOD as 1st cell
    FOR    ${NR_cell}    IN    @{NR_cells}
        ${NR_cell_id}=  Set variable  ${NR_cell['id']}
        ${cell_id2}=  Get matches   ${other_cell_ids}  ${NR_cell_id}
        Run keyword if  ${cell_id2}!=[]  Remove Values From List  ${NR_cells}  ${NR_cell}
        Set Test Variable  ${NR_cells}
    END
    Log to console    ${NR_cells}
    @{cell}  Select 1 Random NRCEL From ${NR_cells}
    ${2nd_NRCELL_ID}  ${2nd_NRCELL_DN}  Get Id Of Selected Cell  @{cell}[0]
    Set Test Variable  ${2nd_NRCELL_ID}  #2nd_cell_id
    Set Test Variable  ${2nd_NRCELL_DN}  #2nd_cell_pathl

Get RMOD of 1st cell
    FOR  ${NRCELL_R}  IN  @{NRCELLS_R}
        ${Cell_R_name}  Get From Dictionary  ${NRCELL_R}    distName
        ${Cell_R_ID}    string.Split String    ${Cell_R_name}  NRCELL_R-
        ${1st_cell_RMOD}=  Run keyword if  "${Cell_R_ID[1]}"=="${1st_NRCELL_ID}"
        ...    Get From Dictionary  ${NRCELL_R['parameters']}  frRefList
    Run keyword if  "${Cell_R_ID[1]}"=="${1st_NRCELL_ID}"
    ...    Run keywords    Log to console    NRCELL-${1st_NRCELL_ID} is deployed on ${1st_cell_RMOD}
    ...    AND    Set Test Variable    ${1st_cell_RMOD}
    END

Find NRCELLs on the same RMOD as 1st cell
    FOR  ${NRCELL_R}  IN  @{NRCELLS_R}
        ${RMOD_from_NRCELL_R}  Get From Dictionary  ${NRCELL_R['parameters']}  frRefList
        ${other_cell_id}=  Run keyword if  "${RMOD_from_NRCELL_R}"=="${1st_cell_RMOD}"
        ...    Get From Dictionary  ${NRCELL_R}    distName
        Append to list    ${other_cell_ids}    ${other_cell_id}
    END

Select Four Random LTE Cells
    ${LTE_cells}  admin.get parameters for all  LNCEL
    @{cell}  Select 4 Random LNCEL From ${LTE_cells}
    ${1st_LNCEL_ID}  ${1st_LNCEL_DN}  Get Id Of Selected Cell  @{cell}[0]
    ${2nd_LNCEL_ID}  ${2nd_LNCEL_DN}  Get Id Of Selected Cell  @{cell}[1]
    ${3rd_LNCEL_ID}  ${3rd_LNCEL_DN}  Get Id Of Selected Cell  @{cell}[2]
    ${4th_LNCEL_ID}  ${4th_LNCEL_DN}  Get Id Of Selected Cell  @{cell}[3]
    Set Test Variable  ${1st_LNCEL_ID}
    Set Test Variable  ${2nd_LNCEL_ID}
    Set Test Variable  ${3rd_LNCEL_ID}
    Set Test Variable  ${4th_LNCEL_ID}
    Set Test Variable  ${1st_LNCEL_DN}
    Set Test Variable  ${2nd_LNCEL_DN}
    Set Test Variable  ${3rd_LNCEL_DN}
    Set Test Variable  ${4th_LNCEL_DN}

Select Random LTE Cell
    ${LTE_cells}  admin.get parameters for all  LNCEL
    @{cell}  Select 2 Random LNCEL From ${LTE_cells}
    ${1st_LNCEL_ID}  ${1st_LNCEL_DN}  Get Id Of Selected Cell  @{cell}[0]
    Set Test Variable  ${1st_LNCEL_ID}  #1st_cell_id
    Set Test Variable  ${1st_LNCEL_DN}  #1st_cell_path

Select Random NR Cell
    ${1st_NRCELL_ID}  ${1st_NRCELL_DN}  Get Random Cell Id And Path  nr
    Set Test Variable  ${1st_NRCELL_DN}  #cell_path
    Set Test Variable  ${1st_NRCELL_ID}  #cell_id
#    [Return]  ${1st_NRCELL_ID}  ${1st_NRCELL_DN}

Select Random WCDMA Cell
    ${1st_WNCEL_ID}  ${1st_WNCEL_DN}  Get Random Cell Id And Path  wcdma
    Set Test Variable  ${1st_WNCEL_DN}
    Set Test Variable  ${1st_WNCEL_ID}

Select Random GSM Cell
    ${1st_GNCEL_ID}  ${1st_GNCEL_DN}  Get Random Cell Id And Path  gsm
    Set Test Variable  ${1st_GNCEL_DN}
    Set Test Variable  ${1st_GNCEL_ID}

Select Random ${moc} From ${list}
    Log  ${moc}  console=${True}
    ${chosen}   Evaluate  random.choice(${list})  random
    [Return]    ${chosen}

Select ${qty} Random ${moc} From ${list}
    Log  ${moc}  console=${True}
    ${chosen}   Evaluate  random.sample(${list}, ${qty})  random
    [Return]    ${chosen}

Get Id Of Selected Cell
    [Documentation]  Return cell id (number) and its path.
    [Arguments]   ${cell}
    ${cellId}  Split String  ${cell['id']}  -
    [Return]  ${cellId[-1]}  ${cell['id']}

Get LNCEL List Without SingleTX And mMIMO
    ${LTE_cells}  admin.get parameters for all  LNCEL
	${cells}=  Create List
	Log  Removing SingleTX cells  #console=${True}
    FOR  ${LNCEL}  IN  @{LTE_cells}
        ${dlMimoMode}  Get From Dictionary  ${LNCEL}  dlMimoMode
        Run Keyword If  '${dlMimoMode}'=='SingleTX'  Remove Values From List  ${LTE_cells}  ${LNCEL}
    END
	Log  Removing mMIMO cells  #console=${True}
	FOR  ${LNCEL}  IN  @{LTE_cells}
        ${dlMimoMode}  Get From Dictionary  ${LNCEL}  dlMimoMode
        Run Keyword If  '${dlMimoMode}'=='Closed Loop MIMO (8x4)'  Remove Values From List  ${LTE_cells}  ${LNCEL}
    END
    FOR  ${cell}  IN  @{LTE_cells}
        ${id}  Get From Dictionary  ${cell}  id
        Append To List  ${cells}  ${id}
    END
    Remove Values From List  ${cells}  ${1st_LNCEL_DN}
    [Return]  ${cells}

Select Two Random LNCEL For ReducedEnergySanving
    [Arguments]  ${LTE_cells}
    @{REScell}  Select 2 Random LNCEL From ${LTE_cells}
    ${1st_RES_LNCEL_ID}=  Evaluate  re.search(r'LNCEL_R-(\\d+)','''${REScell}[0]''').group(1)  re
    ${2nd_RES_LNCEL_ID}=  Evaluate  re.search(r'LNCEL_R-(\\d+)','''${REScell}[1]''').group(1)  re
    ${1st_RES_LNCEL_DN}=  Set Variable  ${REScell}[0]
    ${2nd_RES_LNCEL_DN}=  Set Variable  ${REScell}[1]
    [Return]  ${1st_RES_LNCEL_ID}  ${1st_RES_LNCEL_DN}  ${2nd_RES_LNCEL_ID}  ${2nd_RES_LNCEL_DN}

Select One Random LNCEL For ReducedEnergySanving
    [Arguments]  ${LTE_cells}
    @{REScell}  Select 1 Random LNCEL From ${LTE_cells}
    ${1st_RES_LNCEL_ID}=  Evaluate  re.search(r'LNCEL_R-(\\d+)','''${REScell}[0]''').group(1)  re
    ${1st_RES_LNCEL_DN}=  Set Variable  ${REScell}[0]
    [Return]  ${1st_RES_LNCEL_ID}  ${1st_RES_LNCEL_DN}

Get Random Cell Id And Path
    [Arguments]   ${cell_technology}
    ${cells_list}  Get Cell List
    ${cells_list['cells']['lte']}  Ignore PowerSaving IoT Cells
    Set Suite Variable   ${cells_list}
    ${chosen}  Evaluate  random.choice(${cells_list['cells']['${cell_technology}']})  random
    ${cell_id}=  Fetch From Right  ${chosen['id']['internal']}    -
    ${technology}  Evaluate  "${cell_technology}".upper()
#    Log   For ${technology} Cell ID:${cell_id} selected.   INFO   console=True
    [Return]  ${cell_id}  ${chosen['id']['internal']}

Ignore PowerSaving IoT Cells
    ${cells_list}  Get cell list
    FOR  ${cell}  IN  @{cells_list['cells']['lte']}
        ${technology}  Get from dictionary  ${cell}  technology
        Run Keyword If  '${technology}'=='NB-IoT-FDD'
        ...  Remove Values From List  ${cells_list['cells']['lte']}  ${cell}
    END
    [Return]  ${cells_list['cells']['lte']}

Set Feature Under NRPGRP/PSGRP Object
    [Documentation]  Keyword sets indicated values for chosen parameters under NRPGRP object
    ...  Example of usage:
    ...  Set Feature Under NRPGRP Object  lbpsLoadCalcMethod  Max(G_N_combined, P)  NRPGRP
    [Arguments]  ${feature_flag}  ${value}  ${object_name}  ${group_id}  ${group_dn}
    Log  Set Feature Under ${object_name}-${group_id}  console=${True}
    ${feature_flag_delta}=  Set Variable  ${feature_flag}_${value}
    admin.create delta  ${feature_flag_delta}
    Run Keyword If  '${object_name}'=='NRPGRP'  Run Keywords
    ...  Log  Set ${feature_flag} on ${value}  console=${true}
    ...  AND  admin.append parameter update to delta  ${group_dn}  ${feature_flag}  ${value}  ${feature_flag_delta}
    ...  ELSE IF  '${object_name}'=='PSGRP'  Run Keywords
    ...  Log  Set ${feature_flag} on ${value}  console=${true}
    ...  AND   admin.append parameter update to delta  ${group_dn}  ${feature_flag}  ${value}  ${feature_flag_delta}
    admin.get delta  ${feature_flag_delta}
    admin.save delta  ${RESULTS}/delta_${feature_flag}_${value}.json  ${feature_flag_delta}
    admin.perform delta recommissioning  ${RESULTS}/delta_${feature_flag}_${value}.json

Shift Time For PSGRP
    [Arguments]  ${PSGRP-ID}  ${duration}  ${PSGRP_DN}
    Log  Shift Time For PSGRP-${PSGRP-ID}  console=${True}
    Get Time And Date With Minute Offset  5minutes  10minutes
    ${delta_create_psgrp}=  Set Variable  psgrp_create
    admin.create delta  ${delta_create_psgrp}
    ${lbpsPeriodList}=  Create Dictionary
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
    [Arguments]  ${NRPGRP-ID}  ${duration}  ${NRPGRP_DN}
    Log  Shift Time For NRPGRP-${NRPGRP-ID}  console=${True}
    Get Time And Date With Minute Offset  5minutes
    ${delta_create_nrpgrp}=  Set Variable  nrpgrp_create
    admin.create delta  ${delta_create_nrpgrp}
    ${lbpsPeriodList}=  Create Dictionary
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
    ${1st_LNCELid}=  Evaluate  re.search(r'LNCEL_R-(\\d+)','''${1st_LNCELdistName}''').group(1)  re
    ${2nd_LNCELid}=  Evaluate  re.search(r'LNCEL_R-(\\d+)','''${2nd_LNCELdistName}''').group(1)  re
    ${selected_cells_IDs}=  Create List  ${1st_LNCELid}  ${2nd_LNCELid}
    ${delta_create_psgrp}=  Set Variable  psgrp_create
    ${PSGRP_DN}=  Set Variable  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}
    ${sw_splited}  Split String  ${active_sw_version}  _
    ${sw_prefix} = 	Get From List  ${sw_splited}  0
    Set Test Variable  ${sw_prefix}
    admin.create delta  ${delta_create_psgrp}
    admin.append managed object to delta  ${PSGRP_DN}  create  ${delta_create_psgrp}
    admin.append parameter update to delta  ${PSGRP_DN}  lbpsCSONCtlEnabled  false  ${delta_create_psgrp}
    admin.append parameter update to delta  ${PSGRP_DN}  lbpsLastCellMinLoad  10  ${delta_create_psgrp}
    admin.append parameter update to delta  ${PSGRP_DN}  lbpsLastCellRTXMinLoad  20  ${delta_create_psgrp}
    admin.append parameter update to delta  ${PSGRP_DN}  lbpsLastCellSOEnabled  false  ${delta_create_psgrp}
    admin.append parameter update to delta  ${PSGRP_DN}  lbpsLoadCalcMethod  Max(G, W, P)  ${delta_create_psgrp}
    admin.append parameter update to delta  ${PSGRP_DN}  lbpsMaxLoad  20  ${delta_create_psgrp}
    admin.append parameter update to delta  ${PSGRP_DN}  lbpsMinLoad  15  ${delta_create_psgrp}
    admin.append parameter update to delta  ${PSGRP_DN}  lbpsMonWinForCellSOff  60  ${delta_create_psgrp}
    Run Keyword if  '${sw_prefix}'=='SBTS24R3'    admin.append parameter update to delta  ${PSGRP_DN}  lbpsMonWinForCellSOn  30  ${delta_create_psgrp}
    ...  ELSE  admin.append parameter update to delta  ${PSGRP_DN}  lbpsMonWinForCellSOn  60  ${delta_create_psgrp}
    admin.append parameter update to delta  ${PSGRP_DN}  lbpsMonWinForRtxSOff  60  ${delta_create_psgrp}
    admin.append parameter update to delta  ${PSGRP_DN}  lbpsMonWinForRtxSOn  60  ${delta_create_psgrp}
    admin.append parameter update to delta  ${PSGRP_DN}  lbpsSOffTrRule  MaxValueMethod  ${delta_create_psgrp}
    admin.append parameter update to delta  ${PSGRP_DN}  lbpsPdcchLoadOffset  4  ${delta_create_psgrp}
    admin.append parameter update to delta  ${PSGRP_DN}  lbpsSOnTrRule  SlidingAverageMethod  ${delta_create_psgrp}
    admin.append parameter update to delta  ${PSGRP_DN}  lbpsRTXCellCapOffset  80  ${delta_create_psgrp}
    admin.append parameter update to delta  ${PSGRP_DN}  lbpsRTXMaxLoad  30  ${delta_create_psgrp}
    admin.append parameter update to delta  ${PSGRP_DN}  lbpsRTXMinLoad  20  ${delta_create_psgrp}
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
    ...  admin.append parameter update to delta  ${PSGRP_DN}  lbpsSOMethod  Legacy Mixed Switch Off  ${delta_create_psgrp}
    ${lbpsCellList}=  Create Dictionary
    ${item}=  Create List  1  2
    FOR  ${i}  ${cell}  IN ZIP  ${item}  ${selected_cells_IDs}
        Set To Dictionary  ${lbpsCellList}  lbpsUseExtConfig  false
        Set To Dictionary  ${lbpsCellList}  lbpsCellSOOrder=${i}
        Set To Dictionary  ${lbpsCellList}  lnCelId=${cell}
        admin.append complex item to delta  ${PSGRP_DN}  list_name=lbpsCellList  &{lbpsCellList}  delta_id=${delta_create_psgrp}
    END
    Get Time And Date With Minute Offset  4minutes
    ${lbpsPeriodList}=  Create Dictionary
    Set To Dictionary  ${lbpsPeriodList}  lbpsDayOfWeek=${day}
    ${lbpsDuration}=  Get Regexp Matches  ${lbpsDuration}  \\d+
    Set To Dictionary  ${lbpsPeriodList}  lbpsDuration=${lbpsDuration[0]}
    Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeHour=${start_hour}
    Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeMinute=${start_minutes}
    Set To Dictionary  ${lbpsPeriodList}  lbpsSuspended=notSuspended
    admin.append complex item to delta  ${PSGRP_DN}  list_name=lbpsPeriodList  &{lbpsPeriodList}  delta_id=${delta_create_psgrp}
    admin.get delta  ${delta_create_psgrp}
    admin.save delta  ${RESULTS}/delta_create_psgrp_${PSGRP-ID}_LTE1103.json  ${delta_create_psgrp}
    Log  Activate Power Saving Group under MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  console=${true}
    admin.perform delta recommissioning  ${RESULTS}/delta_create_psgrp_${PSGRP-ID}_LTE1103.json  ${delta_create_psgrp}
    ${end_time}=  Add Time To Date  ${time_with_offset}  ${lbpsDuration[0]} minutes
    ${end_hour}=  Convert Date  ${end_time}  result_format=%H
    ${end_minutes}=  Convert Date  ${end_time}  result_format=%M
    Log  Power Saving Group time frame: ${start_hour}:${start_minutes}-${end_hour}:${end_minutes} (+${lbpsDuration[0]} minutes)  console=${true}
    Log  Affected cells in ${PSGRP-ID}: LNCEL_R-${1stLNCELid} and LNCEL_R-${2ndLNCELid}  console=${true}

Create And Activate NRPGRP For CB008745
    [Documentation]
    ...  Creates and activates NRGRP.
    ...  Demands ${cell_order}  ${selected_cells}
    [Arguments]  ${1st_NRCELdistName}  ${2nd_NRCELdistName}  ${NRPGRP-ID}  ${lbpsDuration}  ${lastCellPs}=false  ${feature}='CB008745'
    Log  Selected Cells For PowerSaving ${1st_NRCELdistName} ${2nd_NRCELdistName}  console=${True}
    ${delta_create_nrpgrp}=  Set Variable  nrpgrp_create
    ${NRPGRP_DN}=  Set Variable  MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRPGRP-${NRPGRP-ID}
    ${sw_splited}  Split String  ${active_sw_version}  _
    ${sw_prefix} = 	Get From List  ${sw_splited}  0
    Set Test Variable  ${sw_prefix}
    admin.create delta  ${delta_create_nrpgrp}
    admin.append managed object to delta  ${NRPGRP_DN}  create  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsCSONCtlEnabled  false  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsLastCellMinLoad  2  ${delta_create_nrpgrp}
    Run Keyword If  '${lastCellPs}'=='true'
    ...  admin.append parameter update to delta  ${NRPGRP_DN}  lbpsLastCellSOEnabled  true  ${delta_create_nrpgrp}
    ...  ELSE  admin.append parameter update to delta  ${NRPGRP_DN}  lbpsLastCellSOEnabled  false  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsLoadCalcMethod  Max(G, C, P)  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsMaxLoad  30  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsMinLoad  20  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsMonWinForCellSOff  60  ${delta_create_nrpgrp}
    Run Keyword if  '${sw_prefix}'=='SBTS24R3'    admin.append parameter update to delta  ${NRPGRP_DN}
    ...  lbpsMonWinForCellSOn  30  ${delta_create_nrpgrp}
    ...  ELSE  admin.append parameter update to delta  ${NRPGRP_DN}  lbpsMonWinForCellSOn  60  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsSOffTrRule  MaxValueMethod  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsPdcchLoadOffset  4  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsSOMethod  cell switch off  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsSOnTrRule  SlidingAverageMethod  ${delta_create_nrpgrp}
    ${lbpsCellList}=  Create Dictionary
    ${item}=  Run Keyword If   "${feature}" == "CB009176"
    ...  Create List  1
    ...  ELSE  Create List  1  2
    FOR  ${i}  ${cell}  IN ZIP  ${item}  ${selected_cells_IDs}
        Set To Dictionary  ${lbpsCellList}  lbpsCellSOOrder=${i}
        Set To Dictionary  ${lbpsCellList}  nrCellId=${cell}
        Run Keyword If  '${if_actNrExtCellSOMethod}'=='PASS'
        ...  Set To Dictionary  ${lbpsCellList}  lbpsUseExtConfig  false
        admin.append complex item to delta  ${NRPGRP_DN}  list_name=lbpsCellList  &{lbpsCellList}  delta_id=${delta_create_nrpgrp}
    END
    Get Time And Date With Minute Offset  4minutes  5minutes
    ${lbpsPeriodList}=  Create Dictionary
    Set To Dictionary  ${lbpsPeriodList}  lbpsDayOfWeek=${day}
    ${lbpsDuration}=  Get Regexp Matches  ${lbpsDuration}  \\d+
    Set To Dictionary  ${lbpsPeriodList}  lbpsDuration=${lbpsDuration[0]}
    Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeHour=${start_hour}
    Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeMinute=${start_minutes}
    Set To Dictionary  ${lbpsPeriodList}  lbpsSuspended=notSuspended
    admin.append complex item to delta  ${NRPGRP_DN}  list_name=lbpsPeriodList  &{lbpsPeriodList}  delta_id=${delta_create_nrpgrp}
    ${end_time}=  Add Time To Date  ${time_with_offset}  ${lbpsDuration[0]} minutes
    ${end_hour}=  Convert Date  ${end_time}  result_format=%H
    ${end_minutes}=  Convert Date  ${end_time}  result_format=%M
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
    Run Keyword If  '${if_actCo4g5g}'=='PASS' and '${sw_prefix}'!='SBTS23R2'
    ...  Run Keywords  admin.append parameter update to delta  ${PSGRP_DN}  lbpsGuardTimerNrAct  20  ${delta_create_psgrp}
    ...  AND  admin.append parameter update to delta  ${PSGRP_DN}  lbpsMaxLoadNrAct  40  ${delta_create_psgrp}
    ...  AND  admin.append parameter update to delta  ${PSGRP_DN}  lbpsMinNumEndcCapUeNrAct  0  ${delta_create_psgrp}
    ...  AND  admin.append parameter update to delta  ${PSGRP_DN}  lbpsMonWinNrAct  5  ${delta_create_psgrp}
    ...  AND  admin.append parameter update to delta  ${PSGRP_DN}  lbpsRetryTimerNrAct  5  ${delta_create_psgrp}
    ${actMixedSOMethod_state} =  Check parameter availability under LNBTS    actMixedSOMethod
    Run Keyword If  '${actMixedSOMethod_state}'=='PASS'
    ...  admin.append parameter update to delta  ${PSGRP_DN}  lbpsSOMethod  Legacy Mixed Switch Off  ${delta_create_psgrp}
    ${lbpsCellList}=  Create Dictionary
    ${item}=  Create List  1  2
    FOR  ${i}  ${cell}  IN ZIP  ${item}  ${selected_cells_IDs}
        Run Keyword If  '${if_actExtCellSOMethod}'=='PASS'
        ...  Set To Dictionary  ${lbpsCellList}  lbpsUseExtConfig  false
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
    admin.save delta  ${RESULTS}/delta_create_psgrp_${PSGRP-ID}_LTE1103.json  ${delta_create_psgrp}
    Log  Activate Power Saving Group under MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  console=${true}
    admin.perform delta recommissioning  ${RESULTS}/delta_create_psgrp_${PSGRP-ID}_LTE1103.json  ${delta_create_psgrp}
    ${end_time}=  Add Time To Date  ${time_with_offset}  ${lbpsDuration[0]} minutes
    ${end_hour}=  Convert Date  ${end_time}  result_format=%H
    ${end_minutes}=  Convert Date  ${end_time}  result_format=%M
    Log  Power Saving Group time frame: ${start_hour}:${start_minutes}-${end_hour}:${end_minutes} (+${lbpsDuration[0]} minutes)  console=${true}
    Log  Affected cells in ${PSGRP-ID}: LNCEL_R-${1stLNCELid} and LNCEL_R-${2ndLNCELid}  console=${true}

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
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  lbpsPdcchLoadOffset  4  ${delta_create_psgrp}
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
    ...  admin.append parameter update to delta  ${PSGRP_DN}  lbpsSOMethod  Legacy Mixed Switch Off  ${delta_create_psgrp}
    ${lbpsCellList}=  Create Dictionary
    ${item}=  Create List  1  100  100
    FOR  ${i}  ${cell}  IN ZIP  ${item}  ${selected_cells_IDs}
        Run Keyword If  '${if_actExtCellSOMethod}'=='PASS'
        ...  Set To Dictionary  ${lbpsCellList}  lbpsUseExtConfig  false
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
    Run Keyword If  '${if_actCo4g5g}'=='PASS' and '${sw_prefix}'!='SBTS23R2'
    ...  Run Keywords  admin.append parameter update to delta  ${PSGRP_DN}  lbpsGuardTimerNrAct  20  ${delta_create_psgrp}
    ...  AND  admin.append parameter update to delta  ${PSGRP_DN}  lbpsMaxLoadNrAct  40  ${delta_create_psgrp}
    ...  AND  admin.append parameter update to delta  ${PSGRP_DN}  lbpsMinNumEndcCapUeNrAct  0  ${delta_create_psgrp}
    ...  AND  admin.append parameter update to delta  ${PSGRP_DN}  lbpsMonWinNrAct  5  ${delta_create_psgrp}
    ...  AND  admin.append parameter update to delta  ${PSGRP_DN}  lbpsRetryTimerNrAct  5  ${delta_create_psgrp}
    ${actMixedSOMethod_state} =  Check parameter availability under LNBTS    actMixedSOMethod
    Run Keyword If  '${actMixedSOMethod_state}'=='PASS'
    ...  admin.append parameter update to delta  ${PSGRP_DN}  lbpsSOMethod  Legacy Mixed Switch Off  ${delta_create_psgrp}
    ${lbpsCellList}=  Create Dictionary
    ${qty}=  Get Length  ${bbPoolCellsList}
    FOR  ${i}  IN RANGE  ${qty}
        Set To Dictionary  ${lbpsCellList}  lbpsCellSOOrder=100
        Run Keyword If  '${if_actExtCellSOMethod}'=='PASS'  Set To Dictionary  ${lbpsCellList}  lbpsUseExtConfig  false
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
    Run Keyword If  '${if_actCo4g5g}'=='PASS' and '${sw_prefix}'!='SBTS23R2'
    ...  Run Keywords  admin.append parameter update to delta  ${PSGRP_DN}  lbpsGuardTimerNrAct  20  ${delta_create_psgrp}
    ...  AND  admin.append parameter update to delta  ${PSGRP_DN}  lbpsMaxLoadNrAct  40  ${delta_create_psgrp}
    ...  AND  admin.append parameter update to delta  ${PSGRP_DN}  lbpsMinNumEndcCapUeNrAct  0  ${delta_create_psgrp}
    ...  AND  admin.append parameter update to delta  ${PSGRP_DN}  lbpsMonWinNrAct  5  ${delta_create_psgrp}
    ...  AND  admin.append parameter update to delta  ${PSGRP_DN}  lbpsRetryTimerNrAct  5  ${delta_create_psgrp}
    ${actMixedSOMethod_state} =  Check parameter availability under LNBTS    actMixedSOMethod
    Run Keyword If  '${actMixedSOMethod_state}'=='PASS'
    ...  admin.append parameter update to delta  ${PSGRP_DN}  lbpsSOMethod  Legacy Mixed Switch Off  ${delta_create_psgrp}
    ${lbpsCellList}=  Create Dictionary
    ${item}=  Create List  1  2
    FOR  ${i}  ${cell}  IN ZIP  ${item}  ${selected_cells_IDs}
        Run Keyword If  '${if_actExtCellSOMethod}'=='PASS'
        ...  Set To Dictionary  ${lbpsCellList}  lbpsUseExtConfig  false
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
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  lbpsPdcchLoadOffset  4  ${delta_create_psgrp}
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
    ...  admin.append parameter update to delta  ${PSGRP_DN}  lbpsSOMethod  Legacy Mixed Switch Off  ${delta_create_psgrp}
    ${lbpsCellList}=  Create Dictionary
    ${item}=  Create List  1  2
    FOR  ${i}  ${cell}  IN ZIP  ${item}  ${selected_cells_IDs}
        Set To Dictionary  ${lbpsCellList}  lbpsUseExtConfig  true
        Set To Dictionary  ${lbpsCellList}  lbpsCellSOOrder=${i}
        Set To Dictionary  ${lbpsCellList}  lnCelId=${cell}
        admin.append complex item to delta  ${PSGRP_DN}  list_name=lbpsCellList  &{lbpsCellList}  delta_id=${delta_create_psgrp}
    END
    Run Keyword If  '${additional_flag}'=='CB008800_Overlap'
    ...  Overlapping Preiods For Same Cells  ${additional_flag}  ${PSGRP-ID}
    ...  ELSE  Extended Load-Based Power Saving Configuration  ${additional_flag}  ${PSGRP-ID}
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
    [Arguments]  ${additional_flag}  ${PSGRP-ID}
    Log  ${additional_flag}  console=${True}
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
    ...
    [Arguments]  ${selected_RMOD}  ${TimeForRURestore}  ${win_duration}
    ${delta}=  Set Variable  delta_create_deepSleep
    ${deepsleepschedule_DN}=  Set Variable  MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/${selected_RMOD}
    admin.create delta  ${delta}
    admin.append managed object to delta  ${deepsleepschedule_DN}  update  ${delta}
    admin.append parameter update to delta  ${deepsleepschedule_DN}  advanceTimeForRURestore  ${TimeForRURestore}  ${delta}
    admin.append parameter update to delta  ${deepsleepschedule_DN}  energySavingMode  DEEPSLEEP  ${delta}
    Get Time And Date With Minute Offset  3minutes
    ${deepSleepTimeSchedule}=  Create Dictionary
    Set To Dictionary  ${deepSleepTimeSchedule}  dayOfWeek=${day}
    Set To Dictionary  ${deepSleepTimeSchedule}  startTime=${start_hour}:${start_minutes}
    Set To Dictionary  ${deepSleepTimeSchedule}  windowDuration=${win_duration}
    admin.append complex item to delta  ${deepsleepschedule_DN}  list_name=deepSleepTimeSchedule  &{deepSleepTimeSchedule}  delta_id=${delta}
    admin.get delta  ${delta}
    admin.save delta  ${RESULTS}/delta_create_deepsleep.json  ${delta}
    Log  Activate RMOD deepSleepTimeSchedule MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${selected_RMOD}  console=${true}
    admin.perform delta recommissioning  ${RESULTS}/delta_create_deepsleep.json  ${delta}
    ${end_time}=  Add Time To Date  ${time_with_offset}  ${win_duration} minutes
    ${end_hour}=  Convert Date  ${end_time}  result_format=%H
    ${end_minutes}=  Convert Date  ${end_time}  result_format=%M
    Log  Power Saving Group time frame: ${start_hour}:${start_minutes}-${end_hour}:${end_minutes} (+${win_duration} minutes)  console=${true}

Remove RMOD deepSleepTimeSchedule
    [Documentation]
    ...  **Example of simple usage:**
    ...  Removal of deepSleepTimeSchedule and advanceTimeForRURestore for selected RMOD
    ...
    [Arguments]  ${selected_RMOD}
    ${delta}=  Set Variable  delta_remove_deepSleep
    ${deepsleepschedule_DN}=  Set Variable  MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/${selected_RMOD}
    admin.create delta  ${delta}
    admin.append managed object to delta  ${deepsleepschedule_DN}  update  ${delta}
    admin.append parameter delete to delta  ${deepsleepschedule_DN}  advanceTimeForRURestore  ${delta}
    admin.append parameter delete to delta  ${deepsleepschedule_DN}  deepSleepTimeSchedule  ${delta}
    admin.get delta  ${delta}
    admin.save delta  ${RESULTS}/delta_remove_deepsleep.json  ${delta}
    Log  Removing RMOD deepSleepTimeSchedule MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${selected_RMOD}  console=${true}
    admin.perform delta recommissioning  ${RESULTS}/delta_remove_deepsleep.json

Check RU state for DEEPSLEEP
    [Arguments]  ${selected_rmod}  ${expected_power_state}
    ${bts_info}  admin.get bts info
    FOR  ${rmod}  IN  @{bts_info['radioModules']['rmod']}
        ${rmod_states}  Get From Dictionary  ${rmod}  status
        ${operational_state}  Get From Dictionary  ${rmod_states}  operationalState
        Run Keyword And Ignore Error    Run Keyword If  '${rmod['id']['configuration']}'=='${selected_rmod}'
        ...                 Should Be Equal As Strings  ${operational_state}  disabled  ignore_case=True
        ...         ELSE    Should Be Equal As Strings  ${operational_state}  enabled   ignore_case=True
        ${power_state}  Get From Dictionary  ${rmod_states}  powerState
        Run Keyword If  '${rmod['id']['configuration']}'=='${selected_rmod}'
        ...                 Should Be Equal As Strings  ${power_state}  ${expected_power_state}
        Log To Console  State of ${rmod['id']['configuration']} is correct
    END

Change energysavingmode back to NORMAL
    [Documentation]  Changes energysavingmode of provided RMOD back to NORMAL. Used in CB010766.
    [Arguments]    ${selected_RMOD}
    ${deepsleepschedule_DN}=  Set Variable  MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/${selected_RMOD}
    Set Feature Under Given Object    ${deepsleepschedule_DN}    energySavingMode    NORMAL

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
        Run Keyword If  '${additional_flag}'=='CB008800' or '${additional_flag}'=='Legacy'
        ...  Set To Dictionary  ${lbpsCelPeriodList}  lbpsCellDuration=20
        ...  ELSE IF  '${additional_flag}'=='CB008800_Reconfig'
        ...  Set To Dictionary  ${lbpsCelPeriodList}  lbpsCellDuration=40
        Set To Dictionary  ${lbpsCelPeriodList}  lbpsCellSOMethod=${switch_off_method}
        Run Keyword If  ('${switch_off_method}' == 'Cell Switch Off') and ('${additional_flag}'=='CB008800' or '${additional_flag}'=='Legacy')
        ...  Run Keywords  Get Time And Date With Minute Offset  5 minutes  20 minutes
        ...  AND  Set To Dictionary  ${lbpsCelPeriodList}  lbpsCellDayOfWeek=${day}
        ...  AND  Set To Dictionary  ${lbpsCelPeriodList}  lbpsCellStartTimeHour=${start_hour}
        ...  AND  Set To Dictionary  ${lbpsCelPeriodList}  lbpsCellStartTimeMinute=${start_minutes}
        ...  AND  Log  Power Saving for LNCEL_R-${cell_ID} time frame: ${start_hour}:${start_minutes}-${end_hour}:${end_minutes}.  console=${true}
        ...  AND  Log  Switching Off Method: ${switch_off_method}  console=${true}  console=${true}
        ...  ELSE IF  ('${switch_off_method}' == 'Tx Paths Switch Off') and ('${additional_flag}'=='CB008800' or '${additional_flag}'=='Legacy')
        ...  Run Keywords  Get Time And Date With Minute Offset  7 minutes  20 minutes
        ...  AND  Set To Dictionary  ${lbpsCelPeriodList}  lbpsCellDayOfWeek=${day}
        ...  AND  Set To Dictionary  ${lbpsCelPeriodList}  lbpsCellStartTimeHour=${start_hour}
        ...  AND  Set To Dictionary  ${lbpsCelPeriodList}  lbpsCellStartTimeMinute=${start_minutes}
        ...  AND  Log  Power Saving for LNCEL_R-${cell_ID} time frame: ${start_hour}:${start_minutes}-${end_hour}:${end_minutes}.  console=${true}
        ...  AND  Log  Switching Off Method: ${switch_off_method}  console=${true}
        ...  ELSE IF  '${switch_off_method}' == 'Cell Switch Off' and '${additional_flag}'=='CB008800_Reconfig'
        ...  Run Keywords  Get Time And Date With Minute Offset  5 minutes  40 minutes
        ...  AND  Set To Dictionary  ${lbpsCelPeriodList}  lbpsCellDayOfWeek=${day}
        ...  AND  Set To Dictionary  ${lbpsCelPeriodList}  lbpsCellStartTimeHour=${start_hour}
        ...  AND  Set To Dictionary  ${lbpsCelPeriodList}  lbpsCellStartTimeMinute=${start_minutes}
        ...  AND  Log  Power Saving for LNCEL_R-${cell_ID} time frame: ${start_hour}:${start_minutes}-${end_hour}:${end_minutes}.  console=${true}
        ...  AND  Log  Switching Off Method: ${switch_off_method}  console=${true}  console=${true}
        ...  ELSE IF  '${switch_off_method}' == 'Tx Paths Switch Off' and '${additional_flag}'=='CB008800_Reconfig'
        ...  Run Keywords  Get Time And Date With Minute Offset  7 minutes  40 minutes
        ...  AND  Set To Dictionary  ${lbpsCelPeriodList}  lbpsCellDayOfWeek=${day}
        ...  AND  Set To Dictionary  ${lbpsCelPeriodList}  lbpsCellStartTimeHour=${start_hour}
        ...  AND  Set To Dictionary  ${lbpsCelPeriodList}  lbpsCellStartTimeMinute=${start_minutes}
        ...  AND  Log  Power Saving for LNCEL_R-${cell_ID} time frame: ${start_hour}:${start_minutes}-${end_hour}:${end_minutes}.  console=${true}
        ...  AND  Log  Switching Off Method: ${switch_off_method}  console=${true}
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

Get Time And Date With Minute Offset
    [Arguments]  ${increase_time}=3 minutes  ${minutes_from_increased_time}=0 minutes
    [Documentation]  Keyword returns date and time with 3 minutes offset
    ${time}=  Get Time  epoch
    ${time_with_offset}=  Add Time To Date  ${time}  ${increase_time}
    ${day}=  Convert Date  ${time_with_offset}  result_format=%a
    ${start_hour}=  Convert Date  ${time_with_offset}  result_format=%H
    ${start_minutes}=  Convert Date  ${time_with_offset}  result_format=%M
    ${end_time}=  Add Time To Date  ${time_with_offset}  ${minutes_from_increased_time}
    ${end_hour}=  Convert Date  ${end_time}  result_format=%H
    ${end_minutes}=  Convert Date  ${end_time}  result_format=%M
    Set Test Variable  ${day}
    Set Test Variable  ${start_hour}
    Set Test Variable  ${start_minutes}
    Set Test Variable  ${time_with_offset}
    Set Test Variable  ${end_time}
    Set Test Variable  ${end_hour}
    Set Test Variable  ${end_minutes}

Check Chosen Cells Administrative State
    [Documentation]  Find cells which administrative states should be checked.
    [Arguments]  ${cell_path}  ${cell_technology}  ${expected_administrative_state}
    ${cells_list_2}  Get Cell List                                     # create new list with every cell in BTS
    FOR  ${cell}  IN  @{cells_list_2['cells']['${cell_technology}']}   # get cell from given technology, e.g. lte
        Run Keyword If  '${cell_path}'=='${cell['id']['internal']}'
        ...  Check If Cell Chosen State Is As Expected  ${cell}  administrativeState  ${expected_administrative_state}
    END

Check Chosen Cells Operational State
    [Documentation]  Find cells which operational states should be checked.
    [Arguments]  ${cell_path}  ${cell_technology}  ${expected_operational_state}
    ${cells_list_2}  admin.get cell list                                # create new list with every cell in BTS
    FOR  ${cell}  IN  @{cells_list_2['cells']['${cell_technology}']}    # get cell from given technology, e.g. lte
        Run Keyword If  '${cell_path}'=='${cell['id']['internal']}'
        ...  Check If Cell Chosen State Is As Expected  ${cell}  operationalState  ${expected_operational_state}
    END

Check Chosen Cells Operational State multiple cells
    [Documentation]    Find cells which operational states should be checked
    [Arguments]  ${cell_path_1}  ${cell_path_2}  ${cell_technology}  ${expected_operational_state}
    ${cells_list_2}  admin.get cell list                                 # create new list with every cell in BTS
    FOR  ${cell}  IN  @{cells_list_2['cells']['${cell_technology}']}     # get cell from given technology, e.g. lte
        Run Keyword If  '${cell_path_1}'=='${cell['id']['internal']}'
        ...  Check If Cell Chosen State Is As Expected  ${cell}  operationalState  ${expected_operational_state}
        Run Keyword If  '${cell_path_2}'=='${cell['id']['internal']}'
        ...  Check If Cell Chosen State Is As Expected  ${cell}  operationalState  ${expected_operational_state}
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
        Run Keyword If  '${WNCEL_ID}'=='${i['cellId']}'  Check If Chosen Cell State Is As Expected  ${i}  ${state}  ${value}
    END

Get WNCEL IDs
    ${bts_info}=  admin.get bts info
    ${WNCEL_IDs}=  Create List
    FOR  ${i}  IN  @{bts_info['cells']['wcdma']}
        Append To List  ${WNCEL_IDs}  ${i['cellId']}
    END
    [Return]  ${WNCEL_IDs}

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
        Run Keyword If  '${cell_path}'!='${cell['id']['internal']}' and '${cell_RAT}'!='gsm'
        ...  Check If Cell Chosen State Is As Expected  ${cell}  operationalState  ENABLED
        ...  ELSE  Check If Cell Chosen State Is As Expected  ${cell}  operationalState  ${expected_cell_state}
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
    [Arguments]   ${cell}   ${expected_operationalState}  ${expected_energySavingState}   ${alias}=default
    Log  ${alias}  console=${True}
    ${cellsStates}  admin.get parameters for all  LNCEL
    FOR  ${cellState}  IN  @{cellsStates}
        ${cellId}  Split String  ${cellState.id}  -
        ${operationalState}=  Evaluate  "${cellState.operationalState}".upper()
        ${energySavingState}=  Evaluate  "${cellState.energySavingState}".upper()
        Run Keyword If  '${cellId[-1]}'=='${cell}'
        ...  Should Be True  '${operationalState}'=='${expected_operationalState}' and '${energySavingState}'=='${expected_energySavingState}'
    END

Check Power Saving NR
    [Documentation]  Checks NR cell PS status
    [Arguments]   ${cell}   ${expected_operationalState}  ${expected_energySavingState}   ${alias}=default
    Log  ${alias}  console=${True}
    ${cellsStates}  Get Cells Info    nr
    FOR  ${cellState}  IN  @{cellsStates}
        ${cellId}=  Set Variable  ${cellState['globalCellId']}
        ${operational_state}=  Evaluate  "${cellState['status']['operationalState']}".upper()
        ${energysaving_cell_state}=  Evaluate  "${cellState['energySavingState']}".upper()
        Run keyword if    '${cellId}'=='${cell}'
        ...  Should Be True  '${operational_state}'=='${expected_operationalState}' and '${energysaving_cell_state}'=='${expected_energySavingState}'
    END

Check If Cells OnAir Or PowerSaving Enabled
    [Documentation]
    ...  KW checks whether cell is enabled. If not enabled, checks energy saving, if not - KW failed.
    ...  EDIT: Refactored to avoid obsolete-to-be infomodel library and allow multiRAT cells check. - author: artur.lebek@nokia.com
    [Arguments]    ${alias}=default
    ${cells_list}=  admin.get cell list  alias=${alias}
    ${lte_cells}  Set Variable   ${cells_list['cells']['lte']}
    ${cells_list['cells']['lte']}  Ignore IoT Cells    alias=${alias}
    ${4G_5G_cells}  Combine lists  ${cells_list['cells']['lte']}  ${cells_list['cells']['nr']}
    ${3G_2G_4G_cells}  Combine lists  ${cells_list['cells']['lte']}  ${cells_list['cells']['wcdma']}  ${cells_list['cells']['gsm']}
    FOR  ${cell}  IN  @{4G_5G_cells}
        ${cell_states}  Get From Dictionary  ${cell}  status
        ${operational_state}  Get From Dictionary  ${cell_states}  operationalState
        ${energy_saving_state}  Get From Dictionary  ${cell}  energySavingState
        ${operational_state}  Evaluate  "${operational_state}".upper()
        ${energy_saving_state}  Evaluate  "${energy_saving_state}".upper()
        Run Keyword If  '${operational_state}'!='1'  Should Be True  '${operational_state}'=='ENABLED' or '${energy_saving_state}'=='ENERGYSAVING'
    END
    FOR  ${cell}  IN  @{3G_2G_4G_cells}
        ${cell_states}  Get From Dictionary  ${cell}  status
        ${operational_state}  Get From Dictionary  ${cell_states}  operationalState
        ${operational_state}  Evaluate  "${operational_state}".upper()
    END

Ignore IoT Cells
    [Arguments]  ${alias}=default
    ${cells_list}=  admin.get cell list  alias=${alias}
    FOR  ${cell}  IN  @{cells_list['cells']['lte']}
        ${narrowbandIotMode}=  Get From Dictionary  ${cell}  narrowbandIotMode
        Run Keyword If  '${narrowbandIotMode}' != 'disabled'  Remove Values From List  ${cells_list['cells']['lte']}  ${cell}
    END
    [Return]  ${cells_list['cells']['lte']}

Get Cells List Without IoT
    ${cells_list}  admin.get cell list
    FOR  ${cell}  IN  @{cells_list['cells']['lte']}
        ${narrowbandIotMode}  Get From Dictionary  ${cell}  narrowbandIotMode
        Run Keyword If  '${narrowbandIotMode}'!='disabled'  Remove Values From List  ${cells_list['cells']['lte']}  ${cell}
    END
    [Return]  ${cells_list['cells']['lte']}

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
        Run Keyword If  '${ps_cell_verdict}'=='isNotPScell'
        ...  Should Be True  '${operational_state}'=='${expected_operationalState}' and '${energy_saving_state}'=='${expected_energysavingState}'
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
    ...
    [Arguments]  ${object_DN}  ${feature_flags}  ${value}
    ${feature_flag_delta}=  Set Variable  ${feature_flags}_${value}
    admin.create delta  ${feature_flag_delta}
    Check Activation Flags  ${feature_flags}  ${value}  ${feature_flag_delta}    ${object_DN}
    admin.get delta  ${feature_flag_delta}
    admin.save delta  ${RESULTS}/delta_${feature_flags}_${value}.json  ${feature_flag_delta}
    admin.perform delta recommissioning  ${RESULTS}/delta_${feature_flags}_${value}.json  ${SKIP_PARAMETER_RELATION_ERRORS}


Check Activation Flags
    [Documentation]  The keyword checks whether a single flag or multiple flags were passed.
    ...  If a single value was passed, its type is changed to a list.
    ...
    [Arguments]  ${feature_flags}  ${value}  ${feature_flag_delta}  ${object_DN}
    ${flags_before}=  Set Variable  ${feature_flags}
    ${flags}=  Set Variable    ${feature_flags}
    ${flags}=  Run Keyword If  $flags.__class__ != list  Evaluate  "${flags}".split()
    ...  ELSE  Set Variable  ${flags_before}
    FOR  ${flag}  IN  @{flags}
        Log To Console  Set ${flag} on ${value}
        admin.append parameter update to delta  ${object_DN}  ${flag}  ${value}  ${feature_flag_delta}
    END

Set Dist Name For Objects
    Check which RAT are on given TestLine
    Run Keyword If  '${IF_LTE_EXIST}'=='EXIST'
    ...  Set Test Variable  ${LNBTS_DistName}  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}
    Run Keyword If  '${IF_NR_EXIST}'=='EXIST'
    ...  Set Test Variable  ${NRBTS_DistName}  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    Set Test Variable  ${FEATCADM_DistName}  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    Set Test Variable  ${FEATLADM_DistName}  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1/FEATLADM-1

Get Parameter Value Under LNBTS
    [Arguments]  ${parameter}
    ${lnbts_act_list}=  admin.get managed objects  LNBTS_A
    FOR  ${act}  IN  @{lnbts_act_list}
        ${feature_status}=  Run Keyword If  '${act['parameters']['${parameter}']}'=='${True}'  Set Variable  true
        ...  ELSE IF  '${act['parameters']['${parameter}']}'=='${False}'  Set Variable  false
    END
    [Return]  ${feature_status}

Get Parameter Value Under NRBTS
    [Arguments]  ${parameter}
    ${nrbts_act_list}=  admin.get managed objects  NRBTS_A
    FOR  ${act}  IN  @{nrbts_act_list}
        ${feature_status}=  Run Keyword If  '${act['parameters']['${parameter}']}'=='${True}'  Set Variable  true
        ...  ELSE IF  '${act['parameters']['${parameter}']}'=='${False}'  Set Variable  false
    END
    [Return]  ${feature_status}

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
    [Return]  ${lnCellIds}  ${nrCellIds}  ${wnCellIds}  ${gnCellIds}

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

Get WCDMA Cells Id For Multiple Cells
    [Arguments]  ${WCDMA_cell_path}  ${WCDMA_cell_id}
    ${WNCELS_A}=  admin.get managed objects  WNCEL_A
    Log  WCDMA Cell Path: ${WCDMA_cell_path}  console=${True}
    FOR  ${i}  IN  @{WNCELS_A}
        ${status}=  Run Keyword And Return Status  Evaluate  re.search(r'(${WCDMA_cell_id})','''${i['distName']}''').group(1)  re
        ${lCelwDN}=  Run Keyword If  ${status}  Get From Dictionary  ${i['parameters']}  lCelwDN
        Exit For Loop If  '${lCelwDN}'!='None'
    END
    [Return]    ${lCelwDN[-1]}

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

Set Parameter Under BBPOOLALLOC
    [Documentation]
    ...  Example of usage:
    ...  Set Parameter Under BBPOOLALLOC  cell=LNCEL-1  parameter=bbPoolAllocMode  value=automatic
    ...
    [Arguments]  ${cell}  ${parameter}  ${value}
    ${BBPOOLALLOC_DN}=  Set Variable  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${cell}/BBPOOLALLOC-0
    ${delta_bbpoolalloc}=  Set Variable  delta_bbpoolalloc
    admin.create delta  ${delta_bbpoolalloc}
    admin.append parameter update to delta  ${BBPOOLALLOC_DN}  ${parameter}  ${value}  ${delta_bbpoolalloc}
    admin.get delta  ${delta_bbpoolalloc}
    admin.save delta  ${RESULTS}/delta_${cell}_${parameter}_${value}.json  ${delta_bbpoolalloc}
    Log To Console  Changing for ${cell}: ${parameter} to ${value}
    admin.perform delta recommissioning  ${RESULTS}/delta_${cell}_${parameter}_${value}.json

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
    Run Keyword If  '${rat}'=='NR'
    ...  admin.append parameter update to delta  ${cell_DN}-${1st_NRCELL_ID}  intShutdownTimeout  ${timeout[0]}  ${delta_timers}
    ...  ELSE IF  '${rat}'=='LTE'
    ...  admin.append parameter update to delta  ${cell_DN}-${1st_LNCEL_ID}  intShutdownTimeout  ${timeout[0]}  ${delta_timers}
    ...  ELSE IF  '${rat}'=='WCDMA'
    ...  admin.append parameter update to delta  ${cell_DN}-${1st_WNCEL_ID_A}  intShutdownTimeout  ${timeout[0]}  ${delta_timers}
    admin.get delta  ${delta_timers}
    admin.save delta  ${RESULTS}/delta_${rat}_intShutdownTimeout_${timeout[0]}min.json  ${delta_timers}
    admin.perform delta recommissioning  ${RESULTS}/delta_${rat}_intShutdownTimeout_${timeout[0]}min.json
    Log To Console  Set IntShutdownTimeout for ${rat} cell on ${timeout[0]} min.

Select Cells And Delete IntShutdownTimeout
    ${lnCellIds}  ${nrCellIds}  ${wnCellIds}  ${gnCellIds}  Get Cells IDs From Cellmapping
    Run Keyword If  '${IF_NR_EXIST}'=='EXIST' and '${IF_LTE_EXIST}'=='EXIST' and '${IF_WCDMA_EXIST}'=='EXIST' and '${IF_GSM_EXIST}'=='EXIST'
    ...  Run Keywords
    ...  Select Random NR Cell
    ...  AND  Log To Console  Selected NRCELL DN: ${1st_NRCELL_DN}
    ...  AND  Delete IntShutdownTimeout  ${nrCellIds}  NR
    ...  AND  Select Random LTE Cell
    ...  AND  Log To Console  Selected LNCEL DN: ${1st_LNCEL_DN}
    ...  AND  Delete IntShutdownTimeout  ${lnCellIds}  LTE
    ...  AND  Select Random WCDMA Cell
    ...  AND  Log To Console  Selected WNCEL DN: ${1st_WNCEL_DN}
    ...  AND  Delete IntShutdownTimeout  ${wnCellIds}  WCDMA
    ...  AND  Select Random GSM Cell
    ...  AND  Log To Console  Selected GNCEL DN: ${1st_GNCEL_DN}
    ...  ELSE IF  '${IF_NR_EXIST}'=='EXIST' and '${IF_LTE_EXIST}'=='EXIST' and '${IF_WCDMA_EXIST}'=='NO' and '${IF_GSM_EXIST}'=='NO'  Run Keywords
    ...  Select Random NR Cell
    ...  AND  Log To Console  Selected NRCELL DN: ${1st_NRCELL_DN}
    ...  AND  Delete IntShutdownTimeout  ${nrCellIds}  NR
    ...  AND  Select Random LTE Cell
    ...  AND  Log To Console  Selected LNCEL DN: ${1st_LNCEL_DN}
    ...  AND  Delete IntShutdownTimeout  ${lnCellIds}  LTE
    ...  ELSE IF  '${IF_NR_EXIST}'=='EXIST' and '${IF_LTE_EXIST}'=='EXIST' and '${IF_WCDMA_EXIST}'=='NO' and '${IF_GSM_EXIST}'=='EXIST'  Run Keywords
    ...  Select Random NR Cell
    ...  AND  Log To Console  Selected NRCELL DN: ${1st_NRCELL_DN}
    ...  AND  Delete IntShutdownTimeout  ${nrCellIds}  NR
    ...  AND  Select Random LTE Cell
    ...  AND  Log To Console  Selected LNCEL DN: ${1st_LNCEL_DN}
    ...  AND  Delete IntShutdownTimeout  ${lnCellIds}  LTE
    ...  AND  Select Random GSM Cell
    ...  ELSE IF  '${IF_NR_EXIST}'=='EXIST' and '${IF_LTE_EXIST}'=='EXIST' and '${IF_WCDMA_EXIST}'=='EXIST' and '${IF_GSM_EXIST}'=='NO'  Run Keywords
    ...  Select Random NR Cell
    ...  AND  Log To Console  Selected NRCELL DN: ${1st_NRCELL_DN}
    ...  AND  Delete IntShutdownTimeout  ${nrCellIds}  NR
    ...  AND  Select Random LTE Cell
    ...  AND  Log To Console  Selected LNCEL DN: ${1st_LNCEL_DN}
    ...  AND  Delete IntShutdownTimeout  ${lnCellIds}  LTE
    ...  AND  Select Random WCDMA Cell
    ...  AND  Log To Console  Selected WNCEL DN: ${1st_WNCEL_DN}
    ...  AND  Delete IntShutdownTimeout  ${wnCellIds}  WCDMA
    ...  ELSE IF  '${IF_NR_EXIST}'=='EXIST' and '${IF_LTE_EXIST}'=='NO' and '${IF_WCDMA_EXIST}'=='NO' and '${IF_GSM_EXIST}'=='NO'  Run Keywords
    ...  Select Random NR Cell
    ...  AND  Log To Console  Selected NRCELL DN: ${1st_NRCELL_DN}
    ...  AND  Delete IntShutdownTimeout  ${nrCellIds}  NR
    ...  ELSE IF  '${IF_NR_EXIST}'=='NO' and '${IF_LTE_EXIST}'=='EXIST' and '${IF_WCDMA_EXIST}'=='NO' and '${IF_GSM_EXIST}'=='NO'  Run Keywords
    ...  Select Random LTE Cell
    ...  AND  Log To Console  Selected LNCEL DN: ${1st_LNCEL_DN}
    ...  AND  Delete IntShutdownTimeout  ${lnCellIds}  LTE

Get Specified Duplex LNCEL List
    [Arguments]  ${duplex}
    ${lncels_param}=  admin.get parameters for all  class_name=LNCEL
    ${lncels}=  Create List
    FOR  ${cell}  IN  @{lncels_param}
        Run Keyword If  '${cell['technology']}'=='${duplex}'
        ...  Append To List  ${lncels}  ${cell['id']}
    END
    [Return]  ${lncels}

Get BBPOOL List
    [Arguments]  ${bbPoolTech}
    ${BBPOOLs}=  admin.get managed objects  BBPOOL_R
    FOR  ${bbpool}  IN  @{BBPOOLs}
        Run Keyword If  '${bbpool['parameters']['bbPoolTech']}'!='${bbPoolTech}'
        ...  Remove Values From List  ${BBPOOLs}  ${bbpool}
    END
    [Return]  ${BBPOOLs}

Get Cells Assigned To POWERGROUP_R-2
    [Arguments]  ${BBPOOLs}
    ${bbPoolCellsList}=  Create List
    ${BBPOOL_DN}=  Create List
    FOR  ${bbpool}  IN  @{BBPOOLs}
        ${status}=  Run Keyword And Return Status  Should Match Regexp  ${bbpool['parameters']['bbPwrGroupDNList'][0]}  .*POWERGROUP_R-2
        Run Keyword If  not ${status}  Remove Values From List  ${BBPOOLs}  ${bbpool}
        ...  ELSE  Run Keywords  Append To List  ${bbPoolCellsList}  ${bbpool['parameters']['bbPoolCellsList']}
        ...  AND  Append To List  ${BBPOOL_DN}  ${bbpool['distName']}
    END
#    ${bbPoolCellsList}=  Evaluate  [item for sublist in $bbPoolCellsList for item in (sublist if isinstance(sublist, list) else [sublist])]
    [Return]  ${bbPoolCellsList[0]}  ${BBPOOL_DN[0]}

Mapping LNCEL_A To LNCEL_R
    ${lncels}=  admin.get cells info  cell_type=lte
    ${LNCEL_A_to_LNCEL_R}=  Create Dictionary
    FOR  ${lncel}  IN  @{lncels}
        Set To Dictionary  ${LNCEL_A_to_LNCEL_R}  ${lncel['id']['configuration']}=${lncel['id']['internal']}
    END
    [Return]  ${LNCEL_A_to_LNCEL_R}

Mapping LNCEL_R To LNCEL_A
    ${lncels}=  admin.get cells info  cell_type=lte
    ${LNCEL_R_to_LNCEL_A}=  Create Dictionary
    FOR  ${lncel}  IN  @{lncels}
        Set To Dictionary  ${LNCEL_R_to_LNCEL_A}  ${lncel['id']['internal']}=${lncel['id']['configuration']}
    END
    [Return]  ${LNCEL_R_to_LNCEL_A}

Mapping NRCELL_R To NRCELL_A
    ${nrcels}=  admin.get cells info  cell_type=nr
    ${NRCELL_R_to_NRCELL_A}=  Create Dictionary
    FOR  ${nrcel}  IN  @{nrcels}
        Set To Dictionary  ${NRCELL_R_to_NRCELL_A}  ${nrcel['id']['internal']}=${nrcel['id']['configuration']}
    END
    [Return]  ${NRCELL_R_to_NRCELL_A}

Mapping NRCELL to NRCELL_R
    ${NRCELL_to_NRCELL_R}=  Create Dictionary
    ${bts_info}  admin.get bts info
    FOR  ${nrcell}  IN  @{bts_info['cells']['nr']}
        Set To Dictionary  ${NRCELL_to_NRCELL_R}  ${nrcell['id']['configuration']}=${nrcell['id']['internal']}
    END
    [Return]  ${NRCELL_to_NRCELL_R}

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
    ${distName}  Run Keyword If  '${cellType}'=='LNCEL'  Set Variable  ${internalID}/SIB-0
    ...  ELSE IF  '${cellType}'=='NRCELL'  Set Variable  ${internalID}
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
        Run Keyword If  '${bbpool_object['parameters']['bbPoolCellsList']}'=='[]'
        ...  Append To List  ${empty_bbpool_objects}  ${bbpool_object['parameters']['bbPwrGroupDNList']}
    END
    Set Test Variable  ${empty_bbpool_objects}
    ${empty_bbpool_objects_length}=  Get Length  ${empty_bbpool_objects}
    Run Keyword If  '${empty_bbpool_objects_length}'=='0'
    ...  Fail   message=Empty power group does not exists
    ${powergroup_dn}  Set Variable  ${empty_bbpool_objects[0]}
    [Return]  ${powergroup_dn}

Get POWERGROUP List
    ${POWERGROUP_DNs}=  Create List
    ${bbpool_objects}=  admin.get managed objects  BBPOOL_R
    FOR  ${bbpool}  IN  @{bbpool_objects}
        Append To List  ${POWERGROUP_DNs}  ${bbpool['parameters']['bbPwrGroupDNList'][0]}
    END
    [Return]  ${POWERGROUP_DNs}

Check Powergroup
    [Arguments]  ${POWERGROUP_DN}  ${expected_operationalState}
    ${bbpool_objects}=  admin.get managed objects  BBPOOL_R
    FOR  ${bbpool}  IN  @{bbpool_objects}
        ${powergroup_r}=  Get Regexp Matches  ${bbpool['parameters']['bbPwrGroupDNList'][0]}  BBMOD_R-\\d+/POWERGROUP_R-\\d+
        ${operationalState}  Evaluate  "${bbpool['parameters']['operationalState']}".upper()
        Run Keyword If  '${bbpool['parameters']['bbPwrGroupDNList'][0]}'=='${POWERGROUP_DN}'  Run Keywords
        ...  Should Be True  '${operationalState}'=='${expected_operationalState}'
        ...  AND  Log To Console  ${powergroup_r[0]} operationalState: ${operationalState}
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
    [Return]  ${parameter_presence}

Set Default LoadSettings For LNCELs
    ${lncel_parameters}  admin.get managed objects  LNCEL_A
    ${non_loadSettings_lncels}  Create List
    FOR  ${lncel_info}  IN  @{lncel_parameters}
        ${loadSettings_correct}  Check LoadSettings Values As Default  ${lncel_info}  ${golden_loadSettings}
        ${ignore}  ${lncel_dn}  Split String From Right  ${lncel_info['distName']}  separator=SCF-1/
        ${lncel_dn}  Replace String  ${lncel_dn}  search_for=_A  replace_with=
        Run Keyword If  not ${loadSettings_correct}  Append To List  ${non_loadSettings_lncels}  ${lncel_dn}
    END
    Run Keyword If  ${non_loadSettings_lncels}!=[]  Commission LoadSettings For LNCELs  ${non_loadSettings_lncels}

Check LoadSettings Values As Default
    [Arguments]  ${lncel_info}  ${golden_loadSettings}
    ${actual_loadSettings}  Create Dictionary
    FOR  ${key}  ${value}  IN ZIP  ${lncel_info['parameters']['loadSettings'].keys()}  ${lncel_info['parameters']['loadSettings'].values()}
        ${value}  Convert To String  ${value}
        Set To Dictionary  ${actual_loadSettings}  ${key}=${value}
    END
    ${sorted_actual_loadSettings}  Get Dictionary Items  ${actual_loadSettings}  sort_keys=True
    ${sorted_golden_loadSettings}  Get Dictionary Items  ${golden_loadSettings}  sort_keys=True
    ${status}  Run Keyword And Return Status  Lists Should Be Equal  ${sorted_actual_loadSettings}  ${sorted_golden_loadSettings}
    [Return]  ${status}

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
    admin.perform delta recommissioning  ${RESULTS}/set_loadSettings.json  skip_parameter_relation_errors=${True}


#----------------------------------------- CB009176 START ----------------------------------------------------
Remove RMOD dcPortWinList
    [Documentation]
    ...  **Example of simple usage:**
    ...  Removal of pwrOffDCPortTimeWinList
    ...
    [Arguments]  ${selected_DcPort}
    Log  Selected DC PORT: ${selected_DcPort}  console=${True}
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

Choose Matching Nrcell IDs From RMOD
    FOR  ${rmod_and_nrcell}  IN  @{rmods_and_nrcells}
          Run Keyword If  '${rmod_and_nrcell[0]}'=='${ru_info['distName']}'  Run Keywords
          ...  Set To Dictionary  ${ru_info}  cellId  ${rmod_and_nrcell[1]}
          ...  AND  Log To Console  Information About Selected Radio: \n${ru_info}
    END

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
    [Return]  @{rmods_and_nrcells}

Get Selected RU Info
    [Documentation]
    ...  Keyword get all necessary information for the test about selected RU, 'distName', 'productCode', 'ruId'
    ...  and set it under dictionary 'ru_info'
    FOR  ${rmod}  IN  @{all_rmods}
        ${distName}=   Get From Dictionary  ${rmod}  distName
        ${productName}=  Get From Dictionary  ${rmod['parameters']}   productName
        ${configDN}=  Get From Dictionary  ${rmod['parameters']}   configDN
        Run Keyword If  '${productName}'=='${rmodModel}'  Run Keywords
        ...  Set To Dictionary  ${ru_info}  distName  ${rmod['parameters']['configDN']}
        ...  AND  Set To Dictionary  ${ru_info}  productName  ${rmod['parameters']['productName']}
        ...  AND  Set To Dictionary  ${ru_info}  ruId  ${rmod['distName']}
        ...  AND  Return Proper Distname For RU  ${ru_info}
    END
    ${split_id}=  Split String From Right    ${ru_info['distName']}    separator=APEQM-1/   max_split=1
    ${rmod_id}=    Get From List  ${split_id}  1
    Set Test Variable    ${rmod_id}
    FOR  ${rmod_and_nrcell}  IN  @{rmods_and_nrcells}
          Run Keyword If  '${rmod_and_nrcell[0]}'=='${ru_info['distName']}'  Run Keywords
          ...  Set To Dictionary  ${ru_info}  cellId  ${rmod_and_nrcell[1]}
          ...  AND  Set To Dictionary  ${ru_info}  rmod_Id  ${rmod_id}
          ...  AND  Append To List  ${selected_cells_IDs}  ${ru_info['cellId']}
          ...  AND  Log To Console  Information About Selected Radio: \n${ru_info}
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
        Run Keyword If  '${dcport_info['distName']}'=='${dcportDN_R}'  Run Keywords
         ...  Should Be True  '${dcPort_powerState}'=='${expected_powerState}' and '${dcPort_maintenanceMode}'=='${expected_maintenanceMode}'
         ...  AND  Log  DC Port Power State: ${dcPort_powerState}  console=${True}
         ...  AND  Log  DC Port Maintenance Mode: ${dcPort_maintenanceMode}  console=${True}
     END

Check Radio State DC Port PWROFF
    [Documentation]
    ...  Keyword checks radio status after DC Port power on
    ...  **Example of simple usage:**
    ...  Check Radio State DC Port PWROFF  ${ru_info['ruId']}  AWAKE  NONE
    [Arguments]   ${ruId}   ${expected_powerState}  ${expected_availabilityStatus}  ${alias}=default
    Log  ${alias}  console=${True}
    ${all_rmods}=  admin.get managed objects  RMOD_R
    Set Test Variable  ${all_rmods}
    FOR  ${rmod}  IN  @{all_rmods}
        ${ru_Dn}=  Get From Dictionary  ${rmod}   distName
        ${power_State}=  Evaluate  "${rmod['parameters']['powerState']}".upper()
        ${availability_Status}=  Evaluate  "${rmod['parameters']['availabilityStatus']}".upper()
        Run Keyword If  '${ruId}'=='${ru_Dn}'
        ...  Should Be True  '${power_State}'=='${expected_powerState}' and '${availability_Status}'=='${expected_availabilityStatus}'
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
    ${nrpgrp_parameter_list}=  admin.get managed objects  NRPGRP_A
    Set Test Variable  ${nrpgrp_parameter_list}
    ${cells_in_nrpgrp}=  Create List
    FOR  ${nrpgrp_parameter}  IN  @{nrpgrp_parameter_list}
      ${lbpsCellList}=  Get From Dictionary  ${nrpgrp_parameter['parameters']}  lbpsCellList
      Set Test Variable  ${lbpsCellList}
    END
    FOR  ${parameter}  IN  @{lbpsCellList}
        ${nrCelId}=  Get From Dictionary  ${parameter}  nrCellId
        Append To List  ${cells_in_nrpgrp}  NRCELL_R-${nrCelId}
    END
     Set Test Variable  ${cells_in_nrpgrp}

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
    [Return]  ${not_ps_cells_LTE}  ${ps_cells_LTE}

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
    [Return]  ${not_ps_cells_NR}  ${ps_cells_NR}

Reselect Cells For NRPGRP
    [Documentation]   Keyword select two random NR cells, and overwrites nrcelId in NRPGRP
    ${delta_reconfig_nrpgrp}=  Set Variable  delta_reconfig_nrpgrp
    admin.create delta  ${delta_reconfig_nrpgrp}
    ${lbpsCellList}=  Create Dictionary
    ${NRPGRP_DN}=  Set Variable  MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRPGRP-1
    Select Two Random NR Cells
    ${item}=  Create List  100  100
    FOR  ${i}  ${cell}  IN ZIP  ${item}  ${selected_cells_IDs}
        Set To Dictionary  ${lbpsCellList}  lbpsCellSOOrder=${i}
        Set To Dictionary  ${lbpsCellList}  lbpsUseExtConfig  false
        Set To Dictionary  ${lbpsCellList}  nrCellId=${cell}
        admin.append complex item to delta  ${NRPGRP_DN}  list_name=lbpsCellList  &{lbpsCellList}  delta_id=${delta_reconfig_nrpgrp}
    END
    admin.get delta  ${delta_reconfig_nrpgrp}
    admin.save delta  ${RESULTS}/delta_reconfig_nrpgrp.json  ${delta_reconfig_nrpgrp}
    admin.perform delta recommissioning  ${RESULTS}/delta_reconfig_nrpgrp.json  ${delta_reconfig_nrpgrp}

Reselect Cells For PSGRP
    [Documentation]   Keyword select two random LTE cells, and overwrites lncelId in PSGRP
    ${delta_reconfig_psgrp}=  Set Variable  delta_reconfig_psgrp
    admin.create delta  ${delta_reconfig_psgrp}
    ${lbpsCellList}=  Create Dictionary
    ${PSGRP_DN}=  Set Variable  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/PSGRP-1
    Select Two Random LTE Cells
    ${item}=  Create List  100  100
    FOR  ${i}  ${cell}  IN ZIP  ${item}  ${selected_cells_IDs}
        Set To Dictionary  ${lbpsCellList}  lbpsCellSOOrder=${i}
        Set To Dictionary  ${lbpsCellList}  lbpsUseExtConfig  false
        Set To Dictionary  ${lbpsCellList}  lnCelId=${cell}
        admin.append complex item to delta  ${PSGRP_DN}  list_name=lbpsCellList  &{lbpsCellList}  delta_id=${delta_reconfig_psgrp}
    END
    admin.get delta  ${delta_reconfig_psgrp}
    admin.save delta  ${RESULTS}/delta_reconfig_psgrp.json  ${delta_reconfig_psgrp}
    admin.perform delta recommissioning  ${RESULTS}/delta_reconfig_psgrp.json  ${delta_reconfig_psgrp}


Compare current date with PSGRP/NRPGRP
    [Arguments]  ${group}
    Get Time And Date With Minute Offset
    ${psgrp_parameter_list}=  admin.get managed objects  PSGRP_A
    ${nrpgrp_parameter_list}=  admin.get managed objects  NRPGRP_A
    Set Test Variable  ${psgrp_parameter_list}
    Set Test Variable  ${nrpgrp_parameter_list}
    Run Keyword If  '${group}'=='PSGRP'  Get Day From PSGRP/NRPGRP  ${psgrp_parameter_list}  PSGRP
    ...  ELSE IF  '${group}'=='NRPGRP'  Get Day From PSGRP/NRPGRP  ${nrpgrp_parameter_list}  NRPGRP

Get Day From PSGRP/NRPGRP
    [Arguments]  ${group_parameters}  ${group}
    FOR  ${group_parameter}  IN  @{group_parameters}
      ${lbpsPeriodList}=  Get From Dictionary  ${group_parameter['parameters']}  lbpsPeriodList
      Set Test Variable  ${lbpsPeriodList}
    END
    FOR  ${parameter}  IN  @{lbpsPeriodList}
        ${lbpsDayOfWeek}=  Get From Dictionary  ${parameter}  lbpsDayOfWeek
        Set Test Variable  ${lbpsDayOfWeek}
    END
    Run Keyword If  ('${day}'!='${lbpsDayOfWeek}') and ('${group}'=='PSGRP')  Run Keywords
    ...  Log to console  Change day in PSGRP
    ...  AND  Change day in PSGRP
    ...  ELSE IF  ('${day}'!='${lbpsDayOfWeek}') and ('${group}'=='NRPGRP')  Run Keywords
    ...  Log to console  Change day in PSGRP
    ...  AND  Change day in NRPGRP
    ...  ELSE    Log to console  - Current day and day in ${group} are the same -

Change day in PSGRP
    ${delta_change_day_psgrp}=  Set Variable  psgrp_create
    ${PSGRP_DN}=  Set Variable  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/PSGRP-1
    admin.create delta  ${delta_change_day_psgrp}
    ${listOfHours}=    Create List
    FOR    ${structure}    IN RANGE    0    24
        Append To List    ${listOfHours}    ${structure}
    END
    Set Test Variable  ${listOfHours}
    FOR  ${hour}  IN  @{listOfHours}
        ${lbpsPeriodList}=  Create Dictionary
        Set To Dictionary  ${lbpsPeriodList}  lbpsDayOfWeek=${day}
        Set To Dictionary  ${lbpsPeriodList}  lbpsDuration=55
        Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeHour=${hour}
        Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeMinute=0
        Set To Dictionary  ${lbpsPeriodList}  lbpsSuspended=notSuspended
        admin.append complex item to delta  ${PSGRP_DN}  list_name=lbpsPeriodList  &{lbpsPeriodList}  delta_id=${delta_change_day_psgrp}
        admin.get delta  ${delta_change_day_psgrp}
        admin.save delta  ${RESULTS}/delta_change_day_psgrp.json  ${delta_change_day_psgrp}
    END
    admin.perform delta recommissioning  ${RESULTS}/delta_change_day_psgrp.json  ${delta_change_day_psgrp}

Change day in NRPGRP
    ${delta_change_day_nrpgrp}=  Set Variable  nrpgrp_create
    ${NRPGRP_DN}=  Set Variable  MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRPGRP-1
    admin.create delta  ${delta_change_day_nrpgrp}
    ${listOfHours}=    Create List
    FOR    ${structure}    IN RANGE    0    24
        Append To List    ${listOfHours}    ${structure}
    END
    Set Test Variable  ${listOfHours}
    FOR  ${hour}  IN  @{listOfHours}
        ${lbpsPeriodList}=  Create Dictionary
        Set To Dictionary  ${lbpsPeriodList}  lbpsDayOfWeek=${day}
        Set To Dictionary  ${lbpsPeriodList}  lbpsDuration=55
        Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeHour=${hour}
        Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeMinute=0
        Set To Dictionary  ${lbpsPeriodList}  lbpsSuspended=notSuspended
        admin.append complex item to delta  ${NRPGRP_DN}  list_name=lbpsPeriodList  &{lbpsPeriodList}  delta_id=${delta_change_day_nrpgrp}
        admin.get delta  ${delta_change_day_nrpgrp}
        admin.save delta  ${RESULTS}/delta_change_day_nrpgrp.json  ${delta_change_day_nrpgrp}
    END
    admin.perform delta recommissioning  ${RESULTS}/delta_change_day_nrpgrp.json  ${delta_change_day_nrpgrp}

Create And Activate PSGRP For Each Hour
    [Documentation]
    ...  **Example of simple usage:**
    ...  Create And Activate PSGRP For Each Hour  ${1st_LNCEL_DN}  ${2nd_LNCEL_DN}  PSGRP-11  25min
    ...
    [Arguments]  ${1st_LNCELdistName}  ${2nd_LNCELdistName}  ${PSGRP-ID}  ${lbpsDuration}
    Log  Planned Duriation Of Power Saving: ${lbpsDuration}  console=${True}
    ${1st_LNCELid}=  Evaluate  re.search(r'LNCEL_R-(\\d+)','''${1st_LNCELdistName}''').group(1)  re
    ${2nd_LNCELid}=  Evaluate  re.search(r'LNCEL_R-(\\d+)','''${2nd_LNCELdistName}''').group(1)  re
    ${selected_cells_IDs}=  Create List  ${1st_LNCELid}  ${2nd_LNCELid}
    ${delta_create_psgrp}=  Set Variable  psgrp_create
    ${PSGRP_DN}=  Set Variable  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}
    Run Keyword If  '${SMOD_COMPOSITION}'!='FSMF' and '${SMOD_COMPOSITION}'!='FSMF+FSMF'  Run Keywords
    ...  admin.create delta  ${delta_create_psgrp}
    ...  AND  admin.append managed object to delta  ${PSGRP_DN}  create  ${delta_create_psgrp}
    ...  AND  admin.append parameter update to delta  ${PSGRP_DN}  lbpsCSONCtlEnabled  false  ${delta_create_psgrp}
    ...  AND  admin.append parameter update to delta  ${PSGRP_DN}  lbpsLastCellMinLoad  10  ${delta_create_psgrp}
    ...  AND  admin.append parameter update to delta  ${PSGRP_DN}  lbpsLastCellRTXMinLoad  20  ${delta_create_psgrp}
    ...  AND  admin.append parameter update to delta  ${PSGRP_DN}  lbpsLastCellSOEnabled  true  ${delta_create_psgrp}
    ...  AND  admin.append parameter update to delta  ${PSGRP_DN}  lbpsLoadCalcMethod  Max(G, W, P)  ${delta_create_psgrp}
    ...  AND  admin.append parameter update to delta  ${PSGRP_DN}  lbpsMaxLoad  20  ${delta_create_psgrp}
    ...  AND  admin.append parameter update to delta  ${PSGRP_DN}  lbpsMinLoad  15  ${delta_create_psgrp}
    ...  AND  admin.append parameter update to delta  ${PSGRP_DN}  lbpsMonWinForCellSOff  60  ${delta_create_psgrp}
    ...  AND  admin.append parameter update to delta  ${PSGRP_DN}  lbpsMonWinForCellSOn  60  ${delta_create_psgrp}
    ...  AND  admin.append parameter update to delta  ${PSGRP_DN}  lbpsMonWinForRtxSOff  60  ${delta_create_psgrp}
    ...  AND  admin.append parameter update to delta  ${PSGRP_DN}  lbpsMonWinForRtxSOn  60  ${delta_create_psgrp}
    ...  AND  admin.append parameter update to delta  ${PSGRP_DN}  lbpsSOffTrRule  MaxValueMethod  ${delta_create_psgrp}
    ...  AND  admin.append parameter update to delta  ${PSGRP_DN}  lbpsPdcchLoadOffset  4  ${delta_create_psgrp}
    ...  AND  admin.append parameter update to delta  ${PSGRP_DN}  lbpsSOnTrRule  SlidingAverageMethod  ${delta_create_psgrp}
    ...  AND  admin.append parameter update to delta  ${PSGRP_DN}  lbpsRTXCellCapOffset  80  ${delta_create_psgrp}
    ...  AND  admin.append parameter update to delta  ${PSGRP_DN}  lbpsRTXMaxLoad  30  ${delta_create_psgrp}
    ...  AND  admin.append parameter update to delta  ${PSGRP_DN}  lbpsRTXMinLoad  20  ${delta_create_psgrp}
    ...  ELSE IF  '${SMOD_COMPOSITION}'=='FSMF' or '${SMOD_COMPOSITION}'=='FSMF+FSMF'    Run Keywords
    ...  admin.create delta  ${delta_create_psgrp}
    ...  AND  admin.append managed object to delta  ${PSGRP_DN}  create  ${delta_create_psgrp}
    ...  AND  admin.append parameter update to delta  ${PSGRP_DN}  lbpsCSONCtlEnabled  false  ${delta_create_psgrp}
    ...  AND  admin.append parameter update to delta  ${PSGRP_DN}  lbpsLastCellMinLoad  0  ${delta_create_psgrp}
    ...  AND  admin.append parameter update to delta  ${PSGRP_DN}  lbpsLastCellRTXMinLoad  0  ${delta_create_psgrp}
    ...  AND  admin.append parameter update to delta  ${PSGRP_DN}  lbpsLastCellSOEnabled  true  ${delta_create_psgrp}
    ...  AND  admin.append parameter update to delta  ${PSGRP_DN}  lbpsMaxLoad  100  ${delta_create_psgrp}
    ...  AND  admin.append parameter update to delta  ${PSGRP_DN}  lbpsMinLoad  0  ${delta_create_psgrp}
    ...  AND  admin.append parameter update to delta  ${PSGRP_DN}  lbpsPdcchLoadOffset  4  ${delta_create_psgrp}
    ${sw_splited}  Split String  ${active_sw_version}  _
    ${sw} = 	Get From List  ${sw_splited}  0
    Set Test Variable  ${sw}
    Run Keyword If  '${if_actCo4g5g}'=='PASS' and '${sw}'!='SBTS23R2'
    ...  Run Keywords  admin.append parameter update to delta  ${PSGRP_DN}  lbpsGuardTimerNrAct  20  ${delta_create_psgrp}
    ...  AND  admin.append parameter update to delta  ${PSGRP_DN}  lbpsMaxLoadNrAct  40  ${delta_create_psgrp}
    ...  AND  admin.append parameter update to delta  ${PSGRP_DN}  lbpsMinNumEndcCapUeNrAct  0  ${delta_create_psgrp}
    ...  AND  admin.append parameter update to delta  ${PSGRP_DN}  lbpsMonWinNrAct  5  ${delta_create_psgrp}
    ...  AND  admin.append parameter update to delta  ${PSGRP_DN}  lbpsRetryTimerNrAct  5  ${delta_create_psgrp}
    Run Keyword If  ('${sw}'=='SBTS24R1' or '${sw}'=='SBTS00') and ('${SMOD_COMPOSITION}'!='FSMF' and '${SMOD_COMPOSITION}'!='FSMF+FSMF')
    ...  admin.append parameter update to delta  ${PSGRP_DN}  lbpsSOMethod  Legacy Mixed Switch Off  ${delta_create_psgrp}
    ${lbpsCellList}=  Create Dictionary
    ${item}=  Create List  100  100
    FOR  ${i}  ${cell}  IN ZIP  ${item}  ${selected_cells_IDs}
        Set To Dictionary  ${lbpsCellList}  lbpsUseExtConfig  false
        Set To Dictionary  ${lbpsCellList}  lbpsCellSOOrder=${i}
        Set To Dictionary  ${lbpsCellList}  lnCelId=${cell}
        admin.append complex item to delta  ${PSGRP_DN}  list_name=lbpsCellList  &{lbpsCellList}  delta_id=${delta_create_psgrp}
    END
    Get Time And Date With Minute Offset  0minutes
    ${listOfHours}=    Create List
    FOR    ${structure}    IN RANGE    0    24
        Append To List    ${listOfHours}    ${structure}
    END
    Set Test Variable  ${listOfHours}
    FOR  ${hour}  IN  @{listOfHours}
        ${lbpsPeriodList}=  Create Dictionary
        Set To Dictionary  ${lbpsPeriodList}  lbpsDayOfWeek=${day}
    #    ${lbpsDuration}=  Get Regexp Matches  ${lbpsDuration}  \\d+
        Set To Dictionary  ${lbpsPeriodList}  lbpsDuration=55
        Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeHour=${hour}
        Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeMinute=0
        Set To Dictionary  ${lbpsPeriodList}  lbpsSuspended=notSuspended
        admin.append complex item to delta  ${PSGRP_DN}  list_name=lbpsPeriodList  &{lbpsPeriodList}  delta_id=${delta_create_psgrp}
        admin.get delta  ${delta_create_psgrp}
        admin.save delta  ${RESULTS}/delta_create_psgrp_${PSGRP-ID}_LTE1103.json  ${delta_create_psgrp}
    END
    Log  Activate Power Saving Group under MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${PSGRP-ID}  console=${true}
    admin.perform delta recommissioning  ${RESULTS}/delta_create_psgrp_${PSGRP-ID}_LTE1103.json  ${delta_create_psgrp}

Create And Activate NRPGRP For Each Hour
    [Documentation]
    ...  Create And Activate NRPGRP For Each Hour.
    ...  Demands ${cell_order}  ${selected_cells}
    [Arguments]  ${1st_NRCELdistName}  ${2nd_NRCELdistName}  ${NRPGRP-ID}  ${lbpsDuration}
    Log  Cells For PS: ${1st_NRCELdistName} ${2nd_NRCELdistName}. Duration: ${lbpsDuration}  console=${True}
    ${delta_create_nrpgrp}=  Set Variable  nrpgrp_create
    ${NRPGRP_DN}=  Set Variable  MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/${NRPGRP-ID}
    admin.create delta  ${delta_create_nrpgrp}
    admin.append managed object to delta  ${NRPGRP_DN}  create  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsCSONCtlEnabled  false  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsLastCellMinLoad  2  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsLastCellSOEnabled  true  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsLoadCalcMethod  Max(G, C, P)  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsMaxLoad  30  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsMinLoad  20  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsMonWinForCellSOff  60  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsMonWinForCellSOn  60  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsSOffTrRule  MaxValueMethod  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsPdcchLoadOffset  4  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsSOMethod  cell switch off  ${delta_create_nrpgrp}
    admin.append parameter update to delta  ${NRPGRP_DN}  lbpsSOnTrRule  SlidingAverageMethod  ${delta_create_nrpgrp}
    ${lbpsCellList}=  Create Dictionary
    ${item}=  Create List  100  100
    FOR  ${i}  ${cell}  IN ZIP  ${item}  ${selected_cells_IDs}
        Set To Dictionary  ${lbpsCellList}  lbpsCellSOOrder=${i}
        Set To Dictionary  ${lbpsCellList}  nrCellId=${cell}
        Run Keyword If  '${if_actNrExtCellSOMethod}'=='PASS'
        ...  Set To Dictionary  ${lbpsCellList}  lbpsUseExtConfig  false
        admin.append complex item to delta  ${NRPGRP_DN}  list_name=lbpsCellList  &{lbpsCellList}  delta_id=${delta_create_nrpgrp}
    END
    Get Time And Date With Minute Offset  0minutes
    ${listOfHours}=    Create List
    FOR    ${structure}    IN RANGE    0    24
        Append To List    ${listOfHours}    ${structure}
    END
    Set Test Variable  ${listOfHours}
    FOR  ${hour}  IN  @{listOfHours}
        ${lbpsPeriodList}=  Create Dictionary
        Set To Dictionary  ${lbpsPeriodList}  lbpsDayOfWeek=${day}
        Set To Dictionary  ${lbpsPeriodList}  lbpsDuration=55
        Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeHour=${hour}
        Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeMinute=0
        Set To Dictionary  ${lbpsPeriodList}  lbpsSuspended=notSuspended
        admin.append complex item to delta  ${NRPGRP_DN}  list_name=lbpsPeriodList  &{lbpsPeriodList}  delta_id=${delta_create_nrpgrp}
        admin.get delta  ${delta_create_nrpgrp}
        admin.save delta  ${RESULTS}/delta_create_nrpgrp_CB008745.json  ${delta_create_nrpgrp}
    END
    Log  Activate Power Saving Group under ${NRPGRP_DN}  console=${true}
    admin.perform delta recommissioning  ${RESULTS}/delta_create_nrpgrp_CB008745.json  ${delta_create_nrpgrp}

#------------------------------------------ Keywords PS4ALL STOP ---------------------------------------
