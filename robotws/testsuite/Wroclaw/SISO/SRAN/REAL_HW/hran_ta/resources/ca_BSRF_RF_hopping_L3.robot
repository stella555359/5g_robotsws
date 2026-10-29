*** Settings ***
Documentation
...  Resource for antenna hopping

Library           hran_bsc
Resource          ca_BSRF_general.robot
Resource          ca_siso_hran.robot
Resource          ../../Resources/SiSo_L3_call.robot

*** Keywords ***

Step${step_number}: Check Input Data Defined By User

    Log To Console  ${\n}-------------------------------------------------------
    Log To Console    Step${step_number}: Check Input Data Defined By User
    Log To Console  --------------------------------------------------------

    hran_bsc.Bsc SSH Connection  host=${BSC['ip']}  username=${BSC['user']}  password=${BSC['password']}

    Run Keyword If    '${USER_DATA}'=='${EMPTY}'    Fail    No input data defined by user
    ${bts_mal_list}    Split String    ${USER_DATA}    ,
    ${BTS_MAL_DICTIONARY}  Create Dictionary

    FOR    ${bts_mal_item}   IN    @{bts_mal_list}
        ${bts_mal_item}=    Split String    ${bts_mal_item}   =
        Set To Dictionary    ${BTS_MAL_DICTIONARY}    ${bts_mal_item[0]}    ${bts_mal_item[1]}
    END

    Set Test Variable    ${BTS_MAL_DICTIONARY}
    ${bcf_id}=    SiSo Get bcfId
    ${BTS_IDS_LIST}=    Get Dictionary Keys    ${BTS_MAL_DICTIONARY}
    ${bts_ids_list_from_BCF}=    hran_bsc.Get Sectors Ids    ${bcf_id}    ${False}
    ${status}    ${bts_ids_list_check}=    Run Keyword And Ignore Error    List Should Contain Sub List    ${bts_ids_list_from_BCF}  ${BTS_IDS_LIST}
    Run Keyword If    '${status}' == 'FAIL'    Fail    User defined incorrect BTS ID: ${bts_ids_list_check}
    ${GSM_cells_ids_list_from_BCF}=  hran_bsc.Get Gsm Cells Ids  ${bcf_id}
    ${BTS_IDS_GSM_CELLS_IDS_DICTIONARY}  Evaluate    {key: value for key, value in zip(${bts_ids_list_from_BCF}, ${GSM_cells_ids_list_from_BCF})}
    Set Test Variable  ${BTS_IDS_GSM_CELLS_IDS_DICTIONARY}
    Set Test Variable    ${BTS_IDS_LIST}
    Log To Console    List of GSM BTS sector IDs selected by user for RF hopping activation ${BTS_IDS_LIST}

    ${gsm_distnames}=    Create List
    FOR  ${bts_id}  IN  @{BTS_IDS_LIST}
      ${gsm_distnames}  ca_BSRF_RF_hopping_L3.Prepare GSM Cells Distnames For Call  ${bts_id}  ${gsm_distnames}
    END

    Set Test Variable  ${GSM_DISTNAMES}  ${gsm_distnames}
	Log To Console    List of GSM distnames selected by user for RF hopping activation ${GSM_DISTNAMES}

Prepare GSM Cells Distnames For Call
    [Arguments]  ${bts_id}  ${gsm_distnames}

    ${get_cell_list_output}=  admin.Get Cell List  connection=${connection}
    ${all_RATs_cells_list}=  Get From Dictionary  ${get_cell_list_output}  cells
    ${gsm_cells}=  Get From Dictionary  ${all_RATs_cells_list}  gsm

    FOR  ${cell}  IN  @{gsm_cells}
      Continue For Loop If  ${cell['gsmSectorID']}!=${bts_id}
      Append To List  ${gsm_distnames}  ${cell['id']['internal']}
    END

    [Return]  ${gsm_distnames}


Step${step_number}: Check If All Hopping Modes Are Disabled In Tested GSM Cells

    Log To Console  ${\n}----------------------------------------------------------------------------
    Log To Console  Step${step_number}: Check If All Hopping Modes Are Disabled In Tested GSM Cells
    Log To Console  ----------------------------------------------------------------------------

    ${bts_id_hopping_list}  Create List

    FOR  ${bts_id}  IN   @{BTS_IDS_LIST}
      ${hopping_mode_HOP}=  hran_bsc.Get Bts Parameters  ${bts_id}  IDE  HOP
      Run Keyword If  '${hopping_mode_HOP}'!='N'  Append To List  ${bts_id_hopping_list}  ${bts_id}  ${hopping_mode_HOP}
      ${hopping_mode_AHOP}=  hran_bsc.Get Bts Parameters  ${bts_id}  IDE  AHOP
      Run Keyword If  '${hopping_mode_AHOP}'!='N'  Append To List  ${bts_id_hopping_list}  ${bts_id}  ${hopping_mode_AHOP}
    END

    ${bts_id_hopping_list_status}=  Run Keyword And Return Status  Should Be Empty  ${bts_id_hopping_list}
    Run Keyword If  '${bts_id_hopping_list_status}'=='False'
    ...  Fail  User has to disable all hoppings in tested GSM cells before TC execution ${bts_id_hopping_list}
    Log To Console  All hoppings are disabled in tested GSM cells.

Step${step_number}: Activate RF hopping In Tested GSM Cells

    Log To Console  ${\n}--------------------------------------------------------
    Log To Console  Step${step_number}: Activate RF hopping In Tested GSM Cells
    Log To Console  --------------------------------------------------------

    FOR  ${bts_id}  IN   @{BTS_IDS_LIST}
      Lock Sector  ${bts_id}
      hran_bsc.Write  ZEQE:BTS=${bts_id}:HOP=RF;
      hran_bsc.Write  ZEQA:BTS=${bts_id}:MAL=${BTS_MAL_DICTIONARY['${bts_id}']};
      Unlock Sector  ${bts_id}
      Log To Console  RF hopping was activated in GSM cell: ${BTS_IDS_GSM_CELLS_IDS_DICTIONARY['${bts_id}']} BTS sector ID: ${bts_id}
      Sleep  6s
      Run keyword if  ${SCF_COUNT_LTE}  ca_BSRF_RF_hopping_L3.Check Cells States  LTE
      Run keyword if  ${SCF_COUNT_WCDMA}  ca_BSRF_RF_hopping_L3.Check Cells States  WCDMA
      Run keyword if  ${SCF_COUNT_NR}  ca_BSRF_Antenna_hopping_L3.Check Cells States  NR
      ca_BSRF_RF_hopping_L3.Check Cells States  GSM
    END
    Sleep  60s  sleep

Step${step_number}: Check RF Hopping Activation In Tested GSM Cells

    Log To Console  ${\n}---------------------------------------------------------------
    Log To Console  Step${step_number}: Check RF Hopping Activation In Tested GSM Cells
    Log To Console  ---------------------------------------------------------------

    FOR  ${bts_id}  IN   @{BTS_IDS_LIST}
      Log To Console  Check RF hopping activation on BSC by ZEEI:BTS=${bts_id}; command output
      hran_bsc.write  ZEEI:BTS=${bts_id};
      ${ZEEI_output}=  hran_bsc.Read Until  RF/-
      ${count_RF}=  Get Count  ${ZEEI_output}  RF/-
      Run Keyword If  '${count_RF}'=='1'  Log To Console  RF/- was found in ZEEI:BTS=${bts_id} command output
       ...  ELSE  Check RF Hopping Activation On BSC By ZEEI  ${bts_id}
      Log To Console  Check RF hopping activation on BSC by ZEQO:BTS=${bts_id}:HOP; command output
      ${hopping_mode_HOP_RF}=  hran_bsc.Get Bts Parameters  ${bts_id}  HOP  HOP
      ${hopping_mode_HOP_RF}=   Evaluate   re.sub(' +',' ','${hopping_mode_HOP_RF}')  re
      Run Keyword If  '${hopping_mode_HOP_RF}'=='RF (RF HOPPING)'
       ...  Log To Console  RF (RF HOPPING) was found in ZEQO:BTS=${bts_id}:HOP; command output
       ...  ELSE  Fail  RF (RF HOPPING) wasn't found in ZEQO:BTS=${bts_id}:HOP; command output. RF hopping wasn't activated
      Log To Console  Check RF hopping activation in ADMIN in cell Details Info.
      Sleep  6s
      Check RF Hopping Mode In ADMIN  ${bts_id}
      Log To Console  Check if MA list was properly set on BSC
      ${hopping_mode_HOP_MAL}=  hran_bsc.Get Bts Parameters  ${bts_id}  HOP  MAL
      Run Keyword If  '${hopping_mode_HOP_MAL}'=='${BTS_MAL_DICTIONARY['${bts_id}']}'
       ...  Log To Console   MA list for GSM BTS sector ID: ${bts_id} was properly set to ${BTS_MAL_DICTIONARY['${bts_id}']}
       ...  ELSE  Fail   MA list for GSM BTS sector ID: ${bts_id} was set to ${hopping_mode_HOP_MAL} instead of ${BTS_MAL_DICTIONARY['${bts_id}']}
    END

Check RF Hopping Activation On BSC By ZEEI
    [Arguments]  ${bts_id}
    hran_bsc.write  ZEEI:BTS=${bts_id};
    ${ZEEI_output}=  hran_bsc.Read Until  RF/-
    ${count_RF}=  Get Count  ${ZEEI_output}  RF/-
    Run Keyword If  '${count_RF}'=='1'  Log To Console  RF/- was found in ZEEI:BTS=${bts_id} command output
      ...  ELSE  Fail  -/RF wasn't found in ZEEI:BTS=${bts_id} command output. RF hopping wasn't activated

Check RF Hopping Mode In ADMIN
    [Arguments]  ${bts_id}
    ${get_cell_list_output}=  admin.Get Cell List  connection=${connection}
    ${all_RATs_cells_list}=  Get From Dictionary  ${get_cell_list_output}  cells
    ${gsm_cells}=  Get From Dictionary  ${all_RATs_cells_list}  gsm

    FOR  ${cell}  IN  @{gsm_cells}
      Run Keyword If  ${cell['gsmSectorID']}==${bts_id}  Run Keywords
      ...  Run Keyword If  '${cell['hoppingMode']}'=='RfHopping'   Log To Console
      ...  RfHopping was found in cell Details Info in ADMIN for GSM cell: ${BTS_IDS_GSM_CELLS_IDS_DICTIONARY['${bts_id}']} BTS sector: ${bts_id}
      ...  AND  Run Keyword If   '${cell['hoppingMode']}'=='NoHopping'  Fail
      ...  RfHopping wasn't found in cell Details Info in ADMIN for GSM cell: ${BTS_IDS_GSM_CELLS_IDS_DICTIONARY['${bts_id}']} BTS sector: ${bts_id}
    END

Step${step_number}: Make Voice Call/Data Transfer In Tested GSM Cells
    Log To Console  ${\n}--------------------------------------------------------------------
    Log To Console  Step${step_number}: Make Voice Call/Data Transfer In Tested GSM Cells
    Log To Console  ----------------------------------------------------------------------
    Set Test Variable  ${LOGS_DIR}  ${BTS Files}
	Set Test Variable  ${SELECTED_CELLS}  ${GSM_DISTNAMES}
    SiSo L3 Call


Deactivate RF Hopping
    [Documentation]    This KW is used only in TC Teardown.
    ...  It deactivates RF hopping in all tested (selected by user at the beginning) GSM cells.

    Log To Console  Deactivate RF hopping in all tested GSM cells

    FOR  ${bts_id}  IN   @{BTS_IDS_LIST}
      Lock Sector  ${bts_id}
      hran_bsc.Write  ZEQE:BTS=${bts_id}:HOP=N;
      Unlock Sector  ${bts_id}
      Log To Console  RF hopping was deactivated in GSM cell:${BTS_IDS_GSM_CELLS_IDS_DICTIONARY['${bts_id}']} BTS sector ID ${bts_id}
      Sleep  6s
      Run keyword if  ${SCF_COUNT_LTE}  ca_BSRF_RF_hopping_L3.Check Cells States  LTE
      Run keyword if  ${SCF_COUNT_WCDMA}  ca_BSRF_RF_hopping_L3.Check Cells States  WCDMA
      Run keyword if  ${SCF_COUNT_NR}  ca_BSRF_Antenna_hopping_L3.Check Cells States  NR
      ca_BSRF_RF_hopping_L3.Check Cells States  GSM
    END


Step${step_number}: Deactivate RF Hopping In Tested GSM Cells

    Log To Console  ${\n}---------------------------------------------------------
    Log To Console  Step${step_number}: Deactivate RF Hopping In Tested GSM Cells
    Log To Console  ---------------------------------------------------------

    FOR  ${bts_id}  IN   @{BTS_IDS_LIST}
      Lock Sector  ${bts_id}
      hran_bsc.Write  ZEQE:BTS=${bts_id}:HOP=N;
      Unlock Sector  ${bts_id}
      Log To Console  RF hopping was deactivated in GSM cell: ${BTS_IDS_GSM_CELLS_IDS_DICTIONARY['${bts_id}']} BTS sector ID ${bts_id}
      Sleep  6s
      Run keyword if  ${SCF_COUNT_LTE}  ca_BSRF_RF_hopping_L3.Check Cells States  LTE
      Run keyword if  ${SCF_COUNT_WCDMA}  ca_BSRF_RF_hopping_L3.Check Cells States  WCDMA
      Run keyword if  ${SCF_COUNT_NR}  ca_BSRF_Antenna_hopping_L3.Check Cells States  NR
      ca_BSRF_RF_hopping_L3.Check Cells States  GSM
      ${hopping_mode_HOP}=  hran_bsc.Get Bts Parameters  ${bts_id}  IDE  HOP
      Run Keyword If  '${hopping_mode_HOP}'=='N'  Log To Console
      ...  RF hopping was properly deactivated in GSM cell: ${BTS_IDS_GSM_CELLS_IDS_DICTIONARY['${bts_id}']} BTS sector ID: ${bts_id}. Checked on BSC
      ...  ELSE  Fail  RF was found in ZEEI:BTS=${bts_id}:IDE; command output. RF hopping wasn't deactivated
      Sleep  6s
      ca_BSRF_RF_hopping_L3.Check Deactivation Of RF Hopping Mode In ADMIN  ${bts_id}
    END

Check Deactivation Of RF Hopping Mode In ADMIN
    [Arguments]  ${bts_id}
    ${get_cell_list_output}=  admin.Get Cell List  connection=${connection}
    ${all_RATs_cells_list}=  Get From Dictionary  ${get_cell_list_output}  cells
    ${gsm_cells}=  Get From Dictionary  ${all_RATs_cells_list}  gsm

    FOR  ${cell}  IN  @{gsm_cells}
      Run Keyword If  ${cell['gsmSectorID']}==${bts_id}  Run Keywords
      ...  Run Keyword If  '${cell['hoppingMode']}'=='NoHopping'   Log To Console
      ...  RfHopping was deactivated in GSM cell: ${BTS_IDS_GSM_CELLS_IDS_DICTIONARY['${bts_id}']} BTS sector ID: ${bts_id}. Checked in ADMIN  AND
      ...  Run Keyword If   '${cell['hoppingMode']}'=='RfHopping'  Fail
      ...  RfHopping was found in cell Details Info in ADMIN, GSM cell: ${BTS_IDS_GSM_CELLS_IDS_DICTIONARY['${bts_id}']} BTS sector ID: ${bts_id}.
    END


Check Cells States
    [Arguments]  ${RAT}

    Log To Console  ${RAT} cell(s) states checking.
    Run Keyword If  '${RAT}'=='LTE'    Check If All Cells For RAT Are OnAir  LTE  timeout=10
    Run Keyword If  '${RAT}'=='WCDMA'  Check If All Cells For RAT Are OnAir  WCDMA  timeout=10
    Run Keyword If  '${RAT}'=='NR'     Check If All Cells For RAT Are OnAir  NR  timeout=10
    Run Keyword If  '${RAT}'=='GSM'    Check If All Cells For RAT Are OnAir  GSM  timeout=180
    Log To Console  ${RAT} cell(s) are in expected states.
