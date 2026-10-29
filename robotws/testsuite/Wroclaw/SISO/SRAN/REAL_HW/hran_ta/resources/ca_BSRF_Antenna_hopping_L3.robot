*** Settings ***
Documentation
...  Resource for antenna hopping

Library           hran_bsc
Resource          ca_BSRF_general.robot
Resource          ca_siso_hran.robot
Resource          ../../Resources/SiSo_L3_call.robot



*** Keywords ***

Step${step_number}: Check Input Data Defined By User

    Log To Console  ${\n}----------------------------------------------------
    Log To Console    Step${step_number}: Check Input Data Defined By User
    Log To Console  -------------------------------------------------------


    hran_bsc.Bsc SSH Connection  host=${BSC['ip']}  username=${BSC['user']}  password=${BSC['password']}

    Run Keyword If    '${USER_DATA}'=='${EMPTY}'    Fail    No input data defined by user
    ${bts_list}    Split String    ${USER_DATA}    ,
    ${bcf_id}=    SiSo Get bcfId
    ${bts_ids_list_from_BCF}=    hran_bsc.Get Sectors Ids    ${bcf_id}    ${False}
    ${status}    ${bts_ids_list_check}=    Run Keyword And Ignore Error    List Should Contain Sub List    ${bts_ids_list_from_BCF}  ${bts_list}
    Run Keyword If    '${status}' == 'FAIL'    Fail    User defined incorrect BTS ID: ${bts_ids_list_check}
    ${GSM_cells_ids_list_from_BCF}=  hran_bsc.Get Gsm Cells Ids  ${bcf_id}
    ${BTS_IDS_GSM_CELLS_IDS_DICTIONARY}  Evaluate    {key: value for key, value in zip(${bts_ids_list_from_BCF}, ${GSM_cells_ids_list_from_BCF})}
    Set Test Variable  ${BTS_IDS_GSM_CELLS_IDS_DICTIONARY}
    Set Test Variable    ${BTS_IDS_LIST}    ${bts_list}
    Log To Console    List of GSM BTS sector IDs selected by user for antenna hopping activation ${BTS_IDS_LIST}
    ${gsm_distnames}=    Create List
    FOR  ${bts_id}  IN  @{BTS_IDS_LIST}
      ${gsm_distnames}  ca_BSRF_Antenna_hopping_L3.Prepare GSM Cells Distnames For Call  ${bts_id}  ${gsm_distnames}
    END

    Set Test Variable  ${GSM_DISTNAMES}  ${gsm_distnames}
	Log To Console    List of GSM distnames selected by user for antenna hopping activation ${GSM_DISTNAMES}

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
    Run Keyword If  '4${bts_id_hopping_list_status}'=='False'
    ...  Fail    User has to disable all hoppings in tested GSM cells before TC execution ${bts_id_hopping_list}
    Log To Console  All hoppings are disabled in tested GSM cells.

Step${step_number}: Activate Antenna Hopping In Tested GSM Cells

    Log To Console  ${\n}------------------------------------------------------------
    Log To Console  Step${step_number}: Activate Antenna Hopping In Tested GSM Cells
    Log To Console  ------------------------------------------------------------

    FOR  ${bts_id}  IN   @{BTS_IDS_LIST}
      Lock Sector  ${bts_id}
      hran_bsc.Write  ZEQE:BTS=${bts_id}:AHOP=Y;
      Unlock Sector  ${bts_id}
      Log To Console  Antenna hopping was activated in GSM cell: ${BTS_IDS_GSM_CELLS_IDS_DICTIONARY['${bts_id}']} BTS sector ID: ${bts_id}
      Sleep  6s
      Run keyword if  ${SCF_COUNT_LTE}  ca_BSRF_Antenna_hopping_L3.Check Cells States  LTE
      Run keyword if  ${SCF_COUNT_WCDMA}  ca_BSRF_Antenna_hopping_L3.Check Cells States  WCDMA
      Run keyword if  ${SCF_COUNT_NR}  ca_BSRF_Antenna_hopping_L3.Check Cells States  NR
      ca_BSRF_Antenna_hopping_L3.Check Cells States  GSM
    END
    Sleep  60s  sleep

Step${step_number}: Check Antenna Hopping Activation In Tested GSM Cells

    Log To Console  ${\n}--------------------------------------------------------------------
    Log To Console  Step${step_number}: Check Antenna Hopping Activation In Tested GSM Cells
    Log To Console  --------------------------------------------------------------------

    FOR  ${bts_id}  IN   @{BTS_IDS_LIST}
      Log To Console  Check Antenna hopping activation on BSC by ZEQO:BTS=${bts_id}:IDE; command output
      ${hopping_mode_AHOP}=  hran_bsc.Get Bts Parameters  ${bts_id}  IDE  AHOP
      Run Keyword If  '${hopping_mode_AHOP}'=='Y'  Log To Console  ANTENNA HOPPING Y was found in ZEQO:BTS=${bts_id}:IDE; command output
       ...  ELSE  Fail  ANTENNA HOPPING Y wasn't found in ZEQO:BTS=${bts_id}:HOP; command output. Antenna hopping wasn't activated
      Log To Console  Check Antenna hopping activation in ADMIN in cell Details Info.
      Sleep  6s
      Check Antenna Hopping Mode In ADMIN  ${bts_id}
    END

Check Antenna Hopping Mode In ADMIN
  [Arguments]  ${bts_id}
   ${get_cell_list_output}=  admin.Get Cell List  connection=${connection}
   ${all_RATs_cells_list}=  Get From Dictionary  ${get_cell_list_output}  cells
   ${gsm_cells}=  Get From Dictionary  ${all_RATs_cells_list}  gsm

   FOR  ${cell}  IN  @{gsm_cells}
    Run Keyword If  ${cell['gsmSectorID']}==${bts_id}  Run Keywords
    ...  Run Keyword If  '${cell['hoppingMode']}'=='AntennaHopping'
    ...  Log To Console  AntennaHopping was found in cell Details Info in ADMIN for GSM cell: ${BTS_IDS_GSM_CELLS_IDS_DICTIONARY['${bts_id}']}  AND
    ...  Run Keyword If  '${cell['hoppingMode']}'=='AntennaHopping'  Log To Console  BTS sector ID: ${bts_id}  AND
    ...  Run Keyword If   '${cell['hoppingMode']}'=='NoHopping'  Fail
    ...  AntennaHopping wasn't found in cell Details Info in ADMIN for GSM cell: ${BTS_IDS_GSM_CELLS_IDS_DICTIONARY['${bts_id}']}  AND
    ...  Run Keyword If   '${cell['hoppingMode']}'=='NoHopping'  Fail  BTS sector ID: ${bts_id}. Antenna hopping wasn't activated
   END

Step${step_number}: Make Voice Call/Data Transfer In Tested GSM Cells

    Log To Console  ${\n}---------------------------------------------------
    Log To Console  Step${step_number}: Make Voice Call/Data Transfer In Tested GSM Cells
    Log To Console  ---------------------------------------------------
    Set Test Variable  ${LOGS_DIR}  ${BTS Files}
	Set Test Variable  ${SELECTED_CELLS}  ${GSM_DISTNAMES}
    SiSo L3 Call

Deactivate Antenna Hopping
    [Documentation]    This KW is used only in TC Teardown.
    ...  It deactivates antenna hopping in all tested (selected by user at the beginning) GSM cells.

   Log To Console  Deactivate Antenna hopping in all tested GSM cells

    FOR  ${bts_id}  IN   @{BTS_IDS_LIST}
      Lock Sector  ${bts_id}
      hran_bsc.Write  ZEQE:BTS=${bts_id}:AHOP=N;
      Unlock Sector  ${bts_id}
      Log To Console  Antenna hopping was deactivated in GSM cell:${BTS_IDS_GSM_CELLS_IDS_DICTIONARY['${bts_id}']} BTS sector ID ${bts_id}
      Sleep  6s
      Run keyword if  ${SCF_COUNT_LTE}  ca_BSRF_Antenna_hopping_L3.Check Cells States  LTE
      Run keyword if  ${SCF_COUNT_WCDMA}  ca_BSRF_Antenna_hopping_L3.Check Cells States  WCDMA
      Run keyword if  ${SCF_COUNT_NR}  ca_BSRF_Antenna_hopping_L3.Check Cells States  NR
      ca_BSRF_Antenna_hopping_L3.Check Cells States  GSM
    END


Step${step_number}: Deactivate Antenna Hopping In Tested GSM Cells

    Log To Console  ${\n}--------------------------------------------------------------
    Log To Console  Step${step_number}: Deactivate Antenna Hopping In Tested GSM Cells
    Log To Console  --------------------------------------------------------------

    FOR  ${bts_id}  IN   @{BTS_IDS_LIST}
      Lock Sector  ${bts_id}
      hran_bsc.Write  ZEQE:BTS=${bts_id}:AHOP=N;
      Unlock Sector  ${bts_id}
      Log To Console  Antenna hopping was deactivated in GSM cell: ${BTS_IDS_GSM_CELLS_IDS_DICTIONARY['${bts_id}']} BTS sector ID ${bts_id}
      Sleep  6s
      Run keyword if  ${SCF_COUNT_LTE}  ca_BSRF_Antenna_hopping_L3.Check Cells States  LTE
      Run keyword if  ${SCF_COUNT_WCDMA}  ca_BSRF_Antenna_hopping_L3.Check Cells States  WCDMA
      Run keyword if  ${SCF_COUNT_NR}  ca_BSRF_Antenna_hopping_L3.Check Cells States  NR
      ca_BSRF_Antenna_hopping_L3.Check Cells States  GSM
      ${hopping_mode_HOP}=  hran_bsc.Get Bts Parameters  ${bts_id}  IDE  AHOP
      Run Keyword If  '${hopping_mode_HOP}'=='N'  Log To Console
      ...  Antenna hopping was deactivated in GSM cell: ${BTS_IDS_GSM_CELLS_IDS_DICTIONARY['${bts_id}']} BTS sector ID: ${bts_id}. Checked on BSC
      ...  ELSE  Fail  ANTENNA HOPPING Y was found in ZEEI:BTS=${bts_id}:IDE; command output. Antenna hopping wasn't deactivated
      Sleep  10s
      ca_BSRF_Antenna_hopping_L3.Check Deactivation Of Antenna Hopping Mode In ADMIN  ${bts_id}
    END

Check Deactivation Of Antenna Hopping Mode In ADMIN
  [Arguments]  ${bts_id}
   ${get_cell_list_output}=  admin.Get Cell List  connection=${connection}
   ${all_RATs_cells_list}=  Get From Dictionary  ${get_cell_list_output}  cells
   ${gsm_cells}=  Get From Dictionary  ${all_RATs_cells_list}  gsm

   FOR  ${cell}  IN  @{gsm_cells}
    Run Keyword If  ${cell['gsmSectorID']}==${bts_id}  Run Keywords
    ...  Run Keyword If  '${cell['hoppingMode']}'=='NoHopping'   Log To Console
    ...  AntennaHopping was deactivated in GSM cell: ${BTS_IDS_GSM_CELLS_IDS_DICTIONARY['${bts_id}']} BTS sector ID: ${bts_id}. Checked in ADMIN  AND
    ...  Run Keyword If   '${cell['hoppingMode']}'=='AntennaHopping'  Fail
    ...  AntennaHopping still active in cell Details Info in ADMIN, GNCELL: ${BTS_IDS_GSM_CELLS_IDS_DICTIONARY['${bts_id}']} BTS sector ID: ${bts_id}
   END

Check Cells States
     [Arguments]  ${RAT}

     Log To Console  ${RAT} cell(s) states checking.
     Run Keyword If  '${RAT}'=='LTE'    Check If All Cells For RAT Are OnAir  LTE  timeout=10
     Run Keyword If  '${RAT}'=='WCDMA'  Check If All Cells For RAT Are OnAir  WCDMA  timeout=10
     Run Keyword If  '${RAT}'=='NR'     Check If All Cells For RAT Are OnAir  NR  timeout=10
     Run Keyword If  '${RAT}'=='GSM'    Check If All Cells For RAT Are OnAir  GSM  timeout=180
     Log To Console  ${RAT} cell(s) are in expected states.
