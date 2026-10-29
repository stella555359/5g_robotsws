*** Settings ***
Documentation
...  Resource for BB hopping

Library           hran_bsc
Resource          ../../Resources/SiSo_L3_call.robot
Resource          ca_BSRF_general.robot
Resource          ca_siso_hran.robot



*** Keywords ***

Step${step_number}: Check Input Data Defined By User

    Log To Console  ${\n}----------------------------------------------------
    Log To Console    Step${step_number}: Check Input Data Defined By User
    Log To Console  ------------------------------------------------------

    hran_bsc.Bsc SSH Connection  host=${BSC['ip']}  username=${BSC['user']}  password=${BSC['password']}

    Run Keyword If    '${USER_DATA}'=='${EMPTY}'    Fail    No input data defined by user
    ${bts_list}    Split String    ${USER_DATA}    ,
    ${bcf_id}=    SiSo Get bcfId
    ${bts_ids_list_from_BCF}=    hran_bsc.Get Sectors Ids    ${bcf_id}    ${False}
    ${status}    ${bts_ids_list_check}=    Run Keyword And Ignore Error    List Should Contain Sub List    ${bts_ids_list_from_BCF}   ${bts_list}
    Run Keyword If    '${status}' == 'FAIL'    Fail    User defined incorrect BTS ID: ${bts_ids_list_check}
    ${GSM_cells_ids_list_from_BCF}=  hran_bsc.Get Gsm Cells Ids  ${bcf_id}
    ${BTS_IDS_GSM_CELLS_IDS_DICTIONARY}  Evaluate    {key: value for key, value in zip(${bts_ids_list_from_BCF}, ${GSM_cells_ids_list_from_BCF})}
    Set Test Variable  ${BTS_IDS_GSM_CELLS_IDS_DICTIONARY}
    Set Test Variable    ${BTS_IDS_LIST}  ${bts_list}
    Log To Console    List of GSM BTS sector IDs selected by user for BB hopping activation ${BTS_IDS_LIST}
    ${gsm_distnames}=    Create List
	FOR  ${bts_id}  IN  @{BTS_IDS_LIST}
      ${gsm_distnames}  ca_BSRF_BB_hopping_L3.Prepare GSM Cells Distnames For Call  ${bts_id}  ${gsm_distnames}
    END

    Set Test Variable  ${GSM_DISTNAMES}  ${gsm_distnames}
	Log To Console    List of GSM distnames selected by user for BB hopping activation ${GSM_DISTNAMES}


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

    ${bts_id_hopping_list}  create list

    FOR  ${bts_id}  IN   @{BTS_IDS_LIST}
      ${hopping_mode_HOP}=  hran_bsc.get bts parameters  ${bts_id}  IDE  HOP
      Run Keyword If  '${hopping_mode_HOP}'!='N'  append to list  ${bts_id_hopping_list}  ${bts_id}  ${hopping_mode_HOP}
      ${hopping_mode_AHOP}=  hran_bsc.get bts parameters  ${bts_id}  IDE  AHOP
      Run Keyword If  '${hopping_mode_AHOP}'!='N'  append to list  ${bts_id_hopping_list}  ${bts_id}  ${hopping_mode_AHOP}
    END

    ${bts_id_hopping_list_status}=  run keyword and return status  should be empty  ${bts_id_hopping_list}
    Run Keyword If  '${bts_id_hopping_list_status}'=='False'  Fail
    ...  User has to disable all hoppings in tested GSM cells before TC execution ${bts_id_hopping_list}
    Log to console  All hoppings are disabled in tested GSM cells.


Step${step_number}: Activate BB hopping In Tested GSM Cells

    Log To Console  ${\n}--------------------------------------------------------
    Log To Console  Step${step_number}: Activate BB hopping In Tested GSM Cells
    Log To Console  --------------------------------------------------------

    FOR  ${bts_id}  IN   @{BTS_IDS_LIST}
      Lock Sector  ${bts_id}
      hran_bsc.Write  ZEQE:BTS=${bts_id}:HOP=BB;
      Unlock Sector  ${bts_id}
      Log To Console  BB hopping was activated in GSM cell: ${BTS_IDS_GSM_CELLS_IDS_DICTIONARY['${bts_id}']} BTS sector ID: ${bts_id}
      Sleep  6s
      Run keyword if  ${SCF_COUNT_LTE}  ca_BSRF_BB_hopping_L3.Check Cells States  LTE
      Run keyword if  ${SCF_COUNT_WCDMA}  ca_BSRF_BB_hopping_L3.Check Cells States  WCDMA
      Run keyword if  ${SCF_COUNT_NR}  ca_BSRF_Antenna_hopping_L3.Check Cells States  NR
      ca_BSRF_BB_hopping_L3.Check Cells States  GSM
    END

    Sleep  60s  sleep


Step${step_number}: Check BB Hopping Activation In Tested GSM Cells

    Log To Console  ${\n}---------------------------------------------------------------
    Log To Console  Step${step_number}: Check BB Hopping Activation In Tested GSM Cells
    Log To Console  ---------------------------------------------------------------

    FOR  ${bts_id}  IN   @{BTS_IDS_LIST}
      Log To Console  Check BB hopping activation on BSC by ZEEI:BTS=${bts_id}; command output
      hran_bsc.write  ZEEI:BTS=${bts_id};
      ${ZEEI_output}=  hran_bsc.Read Until  BB/-
      ${count_BB}=  Get Count  ${ZEEI_output}  BB/-
      Run Keyword If  '${count_BB}'=='1'  Log To Console  BB/- was found in ZEEI:BTS=${bts_id} command output
       ...  ELSE  Check BB Hopping Activation On BSC By ZEEI  ${bts_id}
      Log To Console  Check BB hopping activation on BSC by ZEQO:BTS=${bts_id}:HOP; command output
      ${hopping_mode_HOP_BB}=  hran_bsc.Get Bts Parameters  ${bts_id}  HOP  HOP
      ${hopping_mode_HOP_BB}=   Evaluate   re.sub(' +',' ','${hopping_mode_HOP_BB}')  re
      Run Keyword If  '${hopping_mode_HOP_BB}'=='BB (BASEBAND HOPPING)'  Log To Console
      ...  BB (BASEBAND HOPPING) was found in ZEQO:BTS=${bts_id}:HOP; command output
      ...  ELSE  Fail  BB (BASEBAND HOPPING) wasn't found in ZEQO:BTS=${bts_id}:HOP; command output. BB hopping wasn't activated
      Log To Console  Check BB hopping activation in ADMIN in cell Details Info.
      Sleep  6s
      Check Hopping Mode In ADMIN  ${bts_id}
    END

Check BB Hopping Activation On BSC By ZEEI
  [Arguments]  ${bts_id}
    hran_bsc.write  ZEEI:BTS=${bts_id};
    ${ZEEI_output}=  hran_bsc.Read Until  BB/-
    ${count_BB}=  Get Count  ${ZEEI_output}  BB/-
    Run Keyword If  '${count_BB}'=='1'  Log To Console  BB/- was found in ZEEI:BTS=${bts_id} command output
    ...  ELSE  Fail  BB/- wasn't found in ZEEI:BTS=${bts_id} command output. BB hopping wasn't activated

Check Hopping Mode In ADMIN
  [Arguments]  ${bts_id}
   ${get_cell_list_output}=  admin.Get Cell List  connection=${connection}
   ${all_RATs_cells_list}=  Get From Dictionary  ${get_cell_list_output}  cells
   ${gsm_cells}=  Get From Dictionary  ${all_RATs_cells_list}  gsm

  FOR  ${cell}  IN  @{gsm_cells}
    Run Keyword If  ${cell['gsmSectorID']}==${bts_id}  Run Keywords
    ...  Run Keyword If  '${cell['hoppingMode']}'=='BbHopping'   Log To Console
    ...  BbHopping was found in cell Details Info in ADMIN for GSM cell: ${BTS_IDS_GSM_CELLS_IDS_DICTIONARY['${bts_id}']} BTS sector: ${bts_id}
    ...  AND  Run Keyword If   '${cell['hoppingMode']}'=='NoHopping'  Fail
    ...  BbHopping still active in cell Details Info in ADMIN for GSM cell: ${BTS_IDS_GSM_CELLS_IDS_DICTIONARY['${bts_id}']} BTS sector: ${bts_id}
  END


Step${step_number}: Make Voice Call/Data Transfer In Tested GSM Cells
    Log To Console  ${\n}--------------------------------------------------------------------
    Log To Console  Step${step_number}: Make Voice Call/Data Transfer In Tested GSM Cells
    Log To Console  ----------------------------------------------------------------------
    Set Test Variable  ${LOGS_DIR}  ${BTS Files}
	Set Test Variable  ${SELECTED_CELLS}  ${GSM_DISTNAMES}
    SiSo L3 Call

Deactivate BB Hopping
   Log To Console  Deactivate BB hopping in all tested GSM cells

    FOR  ${bts_id}  IN   @{BTS_IDS_LIST}
      Lock Sector  ${bts_id}
      hran_bsc.Write  ZEQE:BTS=${bts_id}:HOP=N;
      Unlock Sector  ${bts_id}
      Log To Console  BB hopping was deactivated in GSM cell:${BTS_IDS_GSM_CELLS_IDS_DICTIONARY['${bts_id}']} BTS sector ID ${bts_id}
      Sleep  6s
      Run keyword if  ${SCF_COUNT_LTE}  ca_BSRF_BB_hopping_L3.Check Cells States  LTE
      Run keyword if  ${SCF_COUNT_WCDMA}  ca_BSRF_BB_hopping_L3.Check Cells States  WCDMA
      Run keyword if  ${SCF_COUNT_NR}  ca_BSRF_Antenna_hopping_L3.Check Cells States  NR
      ca_BSRF_BB_hopping_L3.Check Cells States  GSM
    END


Step${step_number}: Deactivate BB Hopping In Tested GSM Cells

    Log To Console  ${\n}---------------------------------------------------------
    Log To Console  Step${step_number}: Deactivate BB Hopping In Tested GSM Cells
    Log To Console  ---------------------------------------------------------

    FOR  ${bts_id}  IN   @{BTS_IDS_LIST}
      Lock Sector  ${bts_id}
      hran_bsc.Write  ZEQE:BTS=${bts_id}:HOP=N;
      Unlock Sector  ${bts_id}
      Log To Console  BB hopping was deactivated in GSM cell: ${BTS_IDS_GSM_CELLS_IDS_DICTIONARY['${bts_id}']} BTS sector ID ${bts_id}
      Sleep  6s
      Run keyword if  ${SCF_COUNT_LTE}  ca_BSRF_BB_hopping_L3.Check Cells States  LTE
      Run keyword if  ${SCF_COUNT_WCDMA}  ca_BSRF_BB_hopping_L3.Check Cells States  WCDMA
      Run keyword if  ${SCF_COUNT_NR}  ca_BSRF_Antenna_hopping_L3.Check Cells States  NR
      ca_BSRF_BB_hopping_L3.Check Cells States  GSM
      ${hopping_mode_HOP}=  hran_bsc.Get Bts Parameters  ${bts_id}  IDE  HOP
      Run Keyword If  '${hopping_mode_HOP}'=='N'  Log To Console
      ...  BB hopping was properly deactivated in GSM cell: ${BTS_IDS_GSM_CELLS_IDS_DICTIONARY['${bts_id}']} BTS sector ID: ${bts_id}. Checked on BSC
      ...  ELSE  Fail  BB was found in ZEEI:BTS=${bts_id}:IDE; command output. BB hopping wasn't deactivated
      Sleep  6s
      ca_BSRF_BB_hopping_L3.Check Deactivation Of Hopping Mode In ADMIN  ${bts_id}
    END

Check Deactivation Of Hopping Mode In ADMIN
  [Arguments]  ${bts_id}
   ${get_cell_list_output}=  admin.Get Cell List  connection=${connection}
   ${all_RATs_cells_list}=  Get From Dictionary  ${get_cell_list_output}  cells
   ${gsm_cells}=  Get From Dictionary  ${all_RATs_cells_list}  gsm

   FOR  ${cell}  IN  @{gsm_cells}
    Run Keyword If  ${cell['gsmSectorID']}==${bts_id}  Run Keywords
    ...  Run Keyword If  '${cell['hoppingMode']}'=='NoHopping'   Log To Console
    ...  BbHopping was deactivated in GSM cell: ${BTS_IDS_GSM_CELLS_IDS_DICTIONARY['${bts_id}']} BTS sector ID: ${bts_id}. Checked in ADMIN  AND
    ...  Run Keyword If   '${cell['hoppingMode']}'=='BbHopping'  Fail
    ...  BbHopping still active in cell Details Info in ADMIN, GSM cell: ${BTS_IDS_GSM_CELLS_IDS_DICTIONARY['${bts_id}']} BTS sector ID: ${bts_id}.
   END


Check Cells States
     [Arguments]  ${RAT}

     Log To Console  ${RAT} cell(s) states checking.
     Run Keyword If  '${RAT}'=='LTE'    Check If All Cells For RAT Are OnAir  LTE  timeout=10
     Run Keyword If  '${RAT}'=='WCDMA'  Check If All Cells For RAT Are OnAir  WCDMA  timeout=10
     Run Keyword If  '${RAT}'=='NR'     Check If All Cells For RAT Are OnAir  NR  timeout=10
     Run Keyword If  '${RAT}'=='GSM'    Check If All Cells For RAT Are OnAir  GSM  timeout=180
     Log To Console  ${RAT} cell(s) are in expected states.
