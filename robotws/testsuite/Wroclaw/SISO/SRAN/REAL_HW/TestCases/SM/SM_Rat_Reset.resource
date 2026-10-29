*** Settings ***
Documentation  Maintainer: daniel.bartkowiak@nokia.com
...  Resource with specific KWs for following tests:
...  SiSo_SM_LTE_Rat_Reset.robot
...  SiSo_SM_NR_Rat_Reset.robot



*** Keywords ***
Preconditions ${tech} RAT Reset
    [Documentation]  KW prepares: path for ims logs depending on loop mode, checks parameter actRatResetEnhancement
    ...  and executes bb reset as helper for sync link setup
    Logging With Timestamp
    ...  message=Preconditions ${tech} RAT Reset
    ...  style=ONGOING
    ${ims_dir}=  Run Keyword If  ${ITERATION}==0  Set Variable  ${CFG.test_logs_path}
    ...  ELSE  Set Variable  ${CFG.test_logs_path}/Loop_${ITERATION}
    Set Test Variable  ${IMS_DIR}  ${ims_dir}
    Run Keyword If  "${TESTED_BTS_ID}"=="${EMPTY}" and len(${CFG['active_bts_list']})>1  Run Keywords
    ...  Logging With Timestamp
    ...  message=Multinode config detected. Please specify 'TESTED_BTS_ID' for testing.
    ...  style=ERROR
    ...  AND  Fail  Multinode config detected. Please specify 'TESTED_BTS_ID' for testing.
    ...  ELSE IF  "${TESTED_BTS_ID}"=="${EMPTY}"  Set Test Variable  ${TESTED_BTS_ID}  ${CFG['active_bts_list'][0]}
    Check Reset Enhancement Parameter
    Run Keyword If  "${ACT_RAT_RESET_ENHANCEMENT}"!="${TRUE}"  Modify Parameter For Enhanced RAT Reset  value=true
    Run Keyword If  "${BB_SN_LIST}"!="@{EMPTY}" and "${SIMPLE_ONAIR}"=="${FALSE}"  BB Reset Helper
    Logging With Timestamp
    ...  message=Preconditions ${tech} RAT Reset
    ...  style=DONE

Postconditions ${tech} RAT Reset
    [Documentation]  KW reconfigures actRatResetEnhancement if needed
    Logging With Timestamp
    ...  message=Postconditions ${tech} RAT Reset
    ...  style=ONGOING
    Run Keyword If  "${ACT_RAT_RESET_ENHANCEMENT}"!="true"  Modify Parameter For Enhanced RAT Reset  value=false
    Logging With Timestamp
    ...  message=Postconditions ${tech} RAT Reset
    ...  style=DONE

Legacy ${tech} RAT Reset Mode
    [Documentation]  KW executes steps when soft is before CB008880 or smod is FSMF
    Logging With Timestamp
    ...  message=Legacy ${tech} RAT Reset mode
    ...  style=ONGOING
    Step 1: Check If BTS OnAir For ${tech} Soft RAT Reset
    Step 2: Execute Soft ${tech} RAT reset
    Step 3: Check If BTS OnAir For ${tech} Soft RAT Reset
    Logging With Timestamp
    ...  message=Legacy ${tech} RAT Reset mode finished
    ...  style=DONE

Enhanced ${tech} RAT Reset Mode
    [Documentation]  KW executes steps when soft is after CB008880
    Logging With Timestamp
    ...  message=Enhanced ${tech} RAT Reset mode
    ...  style=ONGOING
    Step 1: Check If BTS OnAir For ${tech} Soft RAT Reset
    Step 2: Execute Soft ${tech} RAT reset
    Step 3: Check If BTS OnAir For ${tech} Soft RAT Reset
    Step 4: Execute Hard ${tech} RAT reset
    Step 5: Check If BTS OnAir For ${tech} Hard RAT Reset
    Logging With Timestamp
    ...  message=Enhanced ${tech} RAT Reset mode finished
    ...  style=DONE

Step ${index}: Execute ${reset_type} ${tech} RAT Reset
    Logging With Timestamp
    ...  message=Step ${index}: Execute ${reset_type} ${tech} RAT Reset
    ...  style=STEP
    ...  frame=${TRUE}
    Run Keyword If  "${reset_type}"=="Soft" and "${SIMPLE_ONAIR}"=="${FALSE}"
    ...  Get Soft ${tech} Reset Objects
    ...  ELSE  Get Hard ${tech} Reset Objects
    Logging With Timestamp
    ...  message=${tech} RAT reset via ADMIN API started
    ...  style=ONGOING
    Run Keyword If  "${tech}"=="NR"
    ...  admin.Rat Reset  rat_type=${tech}  reset_type=${reset_type}  timeout=${NR_RAT_RESET_TIMEOUT}  connection=${TESTED_BTS_ID}
    ...  ELSE  admin.Rat Reset  rat_type=${tech}  reset_type=${reset_type}  timeout=${LTE_RAT_RESET_TIMEOUT}  connection=${TESTED_BTS_ID}
    Logging With Timestamp
    ...  message=${tech} RAT reset via ADMIN API finished
    ...  style=DONE
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  20  STATE Verify Multi Node State  scf_check=${FALSE}
    Run Keyword If  ${SIMPLE_ONAIR}  Run Keywords  Logging With Timestamp
    ...  message=TC IS RUNNING IN SIMPLE ONAIR MODE. NO HISTORICAL STATES ARE CHECKED.
    ...  AND  Return From Keyword
    Logging With Timestamp
    ...  message=Saving infomodel log for every node
    ...  style=ONGOING
    Save Infomodel Log After RAT Reset  dir=${IMS_DIR}  reset_type=${reset_type}  tech=${tech}
    Logging With Timestamp
    ...  message=Saving infomodel log for every node completed
    ...  style=DONE

Step ${index}: Check If BTS OnAir For ${tech} ${reset_type} RAT Reset
    Logging With Timestamp
    ...  message=Step ${index}: Check If BTS OnAir For ${tech} ${reset_type} RAT Reset
    ...  style=STEP
    ...  frame=${TRUE}
    Run Keyword If  ${index}!=1 and "${SIMPLE_ONAIR}"=="${FALSE}"
    ...  Verify States Transition And Faults For All Nodes When RAT Reset  reset_type=${reset_type}  tech=${tech}
    ...  ELSE IF  ${index}!=1 and "${SIMPLE_ONAIR}"=="${TRUE}"  FM Check Unexpected And Historical Faults For All Nodes  delay=60
    ...  ELSE IF  ${index}==1 and "${BB_SN_LIST}"!="@{EMPTY}"  Run Keywords
    ...  Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  20  STATE Verify Multi Node State  scf_check=${FALSE}
    ...  AND  Logging Session Multinode Restart  logs_path=${IMS_DIR}/BTSFiles
    Logging With Timestamp
    ...  message=All states and faults are checked successfuly, test can proceed
    ...  style=DONE

Save Infomodel Log After RAT Reset
    [Arguments]  ${dir}  ${reset_type}  ${tech}
    [Documentation]  KW saves ims for further analysis
    ...    Arguments:
    ...    +--------------------+-------+--------------------------------------------------------------------------------+
    ...    | Argument           | Man.  | Description                                                                    |
    ...    +====================+=======+================================================================================+
    ...    | dir                | Yes   | Directory for ims collection                                                   |
    ...    +--------------------+-------+--------------------------------------------------------------------------------+
    ...    | reset_type         | Yes   | Soft or Hard                                                                   |
    ...    +--------------------+-------+--------------------------------------------------------------------------------+
    ...    | tech               | Yes   | LTE or NR                                                                      |
    ...    +--------------------+-------+--------------------------------------------------------------------------------+
    FOR  ${bts_id}  IN  @{CFG.active_bts_list}
      admin.Collect Infomodel Log From Current Session
      ...  target_file_name=${dir}/BTSFiles/${bts_id}/InfoModel_For_State_Check_${reset_type}_${tech}_RAT_reset.ims2
      ...  connection=${bts_id}
    END

Check Reset Enhancement Parameter
    [Documentation]  KW checks actRatResetEnhancement in TESTED_BTS_ID scf and creates to test variables:
    ...  ACT_RAT_RESET_ENHANCEMENT and DIST_NAME for further usage
    ${parameter}=  Evaluate Xpath  ${CFG['NODES']['${TESTED_BTS_ID}']['scf_file_path']}
    ...  string(.//managedObject[contains(@distName, "FEATCADM")]/p[@name="actRatResetEnhancement"])
    ${ACT_RAT_RESET_ENHANCEMENT}=  Set Variable If  "${parameter}"=="false" or "${parameter}"==""  false  true
    ${DIST_NAME}=  Evaluate Xpath  ${CFG['NODES']['${TESTED_BTS_ID}']['scf_file_path']}
    ...  string(.//managedObject[contains(@distName, "FEATCADM") and (p[@name="actRatResetEnhancement"])]/@distName)
    Set Test Variable  ${ACT_RAT_RESET_ENHANCEMENT}
    Set Test Variable  ${DIST_NAME}

Modify Parameter For Enhanced RAT Reset
    [Arguments]  ${value}
    [Documentation]  KW performs parameter actRatResetEnhancement recommissioning
    ...    Arguments:
    ...    +--------------------+-------+--------------------------------------------------------------------------------+
    ...    | Argument           | Man.  | Description                                                                    |
    ...    +====================+=======+================================================================================+
    ...    | value              | Yes   | true or false                                                                  |
    ...    +--------------------+-------+--------------------------------------------------------------------------------+
    Logging With Timestamp
    ...  message=Setting parameter actRatResetEnhancement=${value}
    ...  style=ONGOING
    ${recomm_status}=  Run Keyword And Return Status  admin.Perform Parameter Recommissioning
    ...  dist_name=${DIST_NAME}
    ...  parameter=actRatResetEnhancement
    ...  value=${value}
    ...  operation=update
    ...  connection=${TESTED_BTS_ID}
    Run Keyword If  not ${recomm_status}  Run Keywords  Logging With Timestamp
    ...  message=Parameter recommissioning actRatResetEnhancement=true failed
    ...  style=ERROR
    ...  AND  Fail  Parameter recommissioning actRatResetEnhancement=true failed
    Logging With Timestamp
    ...  message=Parameter set successfuly: actRatResetEnhancement=${value}
    ...  style=DONE

BB Reset Helper
    [Documentation]  KW performs baseband reset if user declared sn in 'BB_SN_LIST'.
    ...  KW used for establishing sync link for desired baseband module not selected in 'BB_SN_LIST'
    Logging With Timestamp
    ...  message=Baseband module reset for ${BB_SN_LIST} will be executed.
    ...  style=ONGOING
    FOR  ${bb_sn}  IN  @{BB_SN_LIST}
      ${bb_distname}=  SM_Rat_Reset.Get Baseband Module Runtime Distname  bts_id=${TESTED_BTS_ID}  bb_sn=${bb_sn}
      ${bb_reset_status}  ${bb_reset_response}=  Run Keyword And Ignore Error  admin.Reset Unit
      ...  dist_name=${bb_distname}
      ...  reset_type=Warm
      ...  detailed_output=True
      ...  timeout=${BBMOD_STARTUP_TIMEOUT}
      ...  connection=${TESTED_BTS_ID}
      Run Keyword If  '${bb_reset_status}'=='FAIL'  Run Keywords  Logging With Timestamp
      ...  message=Baseband module reset for ${bb_sn} failed. Response from API: ${bb_reset_response}
      ...  style=ERROR
      ...  AND  Fail  Baseband module reset for ${bb_sn} failed. Response from API: ${bb_reset_response}
    END
    Logging With Timestamp
    ...  message=Baseband module reset for ${BB_SN_LIST} succeeded.
    ...  style=DONE

Get Baseband Module Runtime Distname
    [Arguments]  ${bts_id}  ${bb_sn}
    [Documentation]
    ...  Description:
    ...  KW returns runtime distname of BB card with specified serial number from desired bts. KW fails when bb card not found
    ...  Arguments:
    ...  +--------------+-------+----------------------------------------------------------------------------------------+
    ...  | Argument     | Man.  | Description                                                                            |
    ...  +==============+=======+========================================================================================+
    ...  | bts_id       | Yes   | ID of desired BTS                                                                      |
    ...  +--------------+-------+----------------------------------------------------------------------------------------+
    ...  | bb_sn        | Yes   | BB card serial number to search for.                                                   |
    ...  +--------------+-------+----------------------------------------------------------------------------------------+
    ...  Return:
    ...  +---------------------+-----------------------------------------------------------------------------------------+
    ...  | Return Value        | Description                                                                             |
    ...  +=====================+=========================================================================================+
    ...  | dist_name           | String with runtime distname of BB card                                                 |
    ...  +---------------------+-----------------------------------------------------------------------------------------+

    ${bb_parameters_list}=  admin.Get Parameters For All  BBMOD  connection=${bts_id}
    FOR  ${key}  IN  @{bb_parameters_list}
      ${dist_name}=  Set Variable  ${key.id}
      Return From Keyword If  '${bb_sn}'=='${key.serialNumber}'  ${dist_name}
    END
    Logging With Timestamp
    ...  message=BBMOD ${bb_sn} not found on ${bts_id}.
    ...  style=ERROR
    Fail  BBMOD ${bb_sn} not found on ${bts_id}.

Get Hard Cells Impact
    [Documentation]  KW prepares runtime distnames of impacted cells as dictionary
    ...  Return:
    ...  +---------------------+-----------------------------------------------------------------------------------------+
    ...  | Return Value        | Description                                                                             |
    ...  +=====================+=========================================================================================+
    ...  | rat_impact_dict     | dictonary with impacted runtine cells                                                   |
    ...  +---------------------+-----------------------------------------------------------------------------------------+
    ${rat_impact_dict}=  Create Dictionary
    ${embedded_dict}=  Create Dictionary  impacted=@{EMPTY}
    FOR  ${bts_id}  IN  @{CFG.active_bts_list}
      Set To Dictionary  ${rat_impact_dict}  ${bts_id}=${embedded_dict}
    END
    Return From Keyword If  "@{RAT_IMPACT_LIST}"=="@{EMPTY}"  ${rat_impact_dict}
    FOR  ${cell}  IN  @{RAT_IMPACT_LIST}
      ${cell_distname}  ${bts_id}=  Search For User Cells  cell_id=${cell}
      Append to List  ${rat_impact_dict['${bts_id}']['impacted']}  ${cell_distname}
    END
    [Return]  ${rat_impact_dict}

Search For User Cells
    [Arguments]  ${cell_id}
    [Documentation]  KW searches provided cell_id on tested configuration through all available RATs. If not found KW fails.
    ...  Arguments:
    ...  +--------------+-------+----------------------------------------------------------------------------------------+
    ...  | Argument     | Man.  | Description                                                                            |
    ...  +==============+=======+========================================================================================+
    ...  | cell_id      | Yes   | value of 'nrCellIdentity, eutranCellId, cellId or gsmSectorID'                         |
    ...  +--------------+-------+----------------------------------------------------------------------------------------+
    ...  Return:
    ...  +---------------------+-----------------------------------------------------------------------------------------+
    ...  | Return Value        | Description                                                                             |
    ...  +=====================+=========================================================================================+
    ...  | distname            |  runtine distname of cell_id                                                            |
    ...  +---------------------+-----------------------------------------------------------------------------------------+
    ...  | bts_id              |  bts_id of node that cell_id belongs to                                                 |
    ...  +---------------------+-----------------------------------------------------------------------------------------+
    FOR  ${bts_id}  IN  @{CFG.active_bts_list}
      ${status}  ${nr_cells}=  Run Keyword And Ignore Error  admin.Assert Any  NRCEL  nrCellIdentity=${cell_id}  connection=${bts_id}
      ${nr_distname}=  Run Keyword If  "${status}"=="PASS"  Cell Search
      ...  cells_details_list=${nr_cells}
      ...  cell_id=${cell_id}
      ...  parameter=nrCellIdentity
      Return From Keyword If  "${status}"=="PASS"  ${nr_distname}  ${bts_id}
      ${wn_cells}=  admin.Get Cells Info  cell_type=wcdma  connection=${bts_id}
      ${wn_distname}=  Cell Search
      ...  cells_details_list=${wn_cells}
      ...  cell_id=${cell_id}
      ...  parameter=cellId
      Return From Keyword If  "${wn_distname}"!="${EMPTY}"  ${wn_distname}  ${bts_id}
      ${gn_cells}=  admin.Get Cells Info  cell_type=gsm  connection=${bts_id}
      ${gn_distname}=  Cell Search
      ...  cells_details_list=${gn_cells}
      ...  cell_id=${cell_id}
      ...  parameter=gsmSectorID
      Return From Keyword If  "${gn_distname}"!="${EMPTY}"  ${gn_distname}  ${bts_id}
      ${ln_cells}=  admin.Get Cells Info  cell_type=lte  connection=${bts_id}
      ${ln_distname}=  Cell Search
      ...  cells_details_list=${ln_cells}
      ...  cell_id=${cell_id}
      ...  parameter=eutranCellId
      Return From Keyword If  "${ln_distname}"!="${EMPTY}"  ${ln_distname}  ${bts_id}
    END
    Logging With Timestamp
    ...  message=Cell with id=${cell_id} not found in tested config.
    ...  style=ERROR
    Fail  Cell with id=${cell_id} not found in tested config.

Cell Search
    [Arguments]  ${cells_details_list}  ${cell_id}  ${parameter}
    [Documentation]  KW searches cell_id on specific RAT. KW returns runtime distname of cell_id or empty value.
    ...  Arguments:
    ...  +----------------------+-------+--------------------------------------------------------------------------------+
    ...  | Argument             | Man.  | Description                                                                    |
    ...  +======================+=======+================================================================================+
    ...  | cells_details_list   | Yes   | value can be provided as 'nrCellIdentity, eutranCellId, cellId or gsmSectorID' |
    ...  +----------------------+-------+--------------------------------------------------------------------------------+
    ...  | cell_id              | Yes   | value of 'nrCellIdentity, eutranCellId, cellId or gsmSectorID'                 |
    ...  +----------------------+-------+--------------------------------------------------------------------------------+
    ...  | parameter            | Yes   | parameter name 'nrCellIdentity, eutranCellId, cellId or gsmSectorID'           |
    ...  +----------------------+-------+--------------------------------------------------------------------------------+
    ...  Return:
    ...  +---------------------+-----------------------------------------------------------------------------------------+
    ...  | Return Value        | Description                                                                             |
    ...  +=====================+=========================================================================================+
    ...  | distname            |  runtine distname of cell_id                                                            |
    ...  +---------------------+-----------------------------------------------------------------------------------------+
    FOR  ${cell_details}  IN  @{cells_details_list}
      Run Keyword If  "${parameter}"=="nrCellIdentity"
      ...  Return From Keyword If  '${cell_details['${parameter}']}'=='${cell_id}'  ${cell_details['id']}
      ...  ELSE  Return From Keyword If  '${cell_details['${parameter}']}'=='${cell_id}'  ${cell_details['id']['internal']}
    END
    [Return]  ${EMPTY}

Verify States Transition And Faults For All Nodes When RAT Reset
    [Arguments]  ${reset_type}  ${tech}
    [Documentation]  KW verifies states transition of impacted and not impacted objects (cells, smods, bbmods etc). for all nodes.
    ...  KW verifies faults and restarts session for further steps
    ...  Arguments:
    ...  +----------------------+-------+--------------------------------------------------------------------------------+
    ...  | Argument             | Man.  | Description                                                                    |
    ...  +======================+=======+================================================================================+
    ...  | reset_type           | Yes   | Soft or Hard                                                                   |
    ...  +----------------------+-------+--------------------------------------------------------------------------------+
    ...  | tech                 | Yes   | LTE or NR                                                                      |
    ...  +----------------------+-------+--------------------------------------------------------------------------------+
    FOR  ${bts_id}  IN  @{CFG.active_bts_list}
      Verify States Transition And Faults When RAT Reset  bts_id=${bts_id}  reset_type=${reset_type}  tech=${tech}
    END

Verify States Transition And Faults When RAT Reset
    [Arguments]  ${bts_id}  ${reset_type}  ${tech}
    [Documentation]  KW verifies states transition of impacted and not impacted objects (cells, smods, bbmods etc). on specific bts.
    ...  KW verifies faults and restarts session for further steps on specific bts
    ...  KW also calculate KPIs for NR/LTE rat reset and prints summary
    ...  Arguments:
    ...  +----------------------+-------+--------------------------------------------------------------------------------+
    ...  | Argument             | Man.  | Description                                                                    |
    ...  +======================+=======+================================================================================+
    ...  | bts_id               | Yes   | specific bts ID                                                                |
    ...  +----------------------+-------+--------------------------------------------------------------------------------+
    ...  | reset_type           | Yes   | Soft or Hard                                                                   |
    ...  +----------------------+-------+--------------------------------------------------------------------------------+
    ...  | tech                 | Yes   | LTE or NR                                                                      |
    ...  +----------------------+-------+--------------------------------------------------------------------------------+
    ${reset_dict}=  Set Variable If  "${reset_type}"=="Soft"  ${SOFT_RESET_DICT}  ${HARD_RESET_DICT}
    Logging With Timestamp
    ...  message=Check impacted objects during ${tech} RAT Reset on BTS-${bts_id}
    ...  style=ONGOING
    FOR  ${distname}  IN  @{reset_dict['${bts_id}']['impacted']}
      ${status}  ${msg}=  Run Keyword And Ignore Error  Find Parameter Change
      ...  file_path=${IMS_DIR}/BTSFiles/${bts_id}/InfoModel_For_State_Check_${reset_type}_${tech}_RAT_reset.ims2
      ...  dist_name=${distname}
      ...  parameter=availabilityStatus
      Run Keyword If  "${status}"=="FAIL"  Run Keywords  Logging With Timestamp
      ...  message=${distname} state check failed:${\n}${msg}
      ...  style=ERROR
      ...  AND  Fail  ${distname} state check failed:${\n}${msg}
      Logging With Timestamp
      ...  message=${distname} was correctly impacted during NR RAT Reset on BTS-${bts_id}
      ...  style=DONE
    END
    Logging With Timestamp
    ...  message=Check not impacted objects during ${tech} RAT Reset
    ...  style=ONGOING
    FOR  ${distname}  IN  @{reset_dict['${bts_id}']['not_impacted']}
      ${status}=  Run Keyword And Return Status  Run Keyword And Expect Error  No change found in*  Find Parameter Change
      ...  file_path=${IMS_DIR}/BTSFiles/${bts_id}/InfoModel_For_State_Check_${reset_type}_${tech}_RAT_reset.ims2
      ...  dist_name=${distname}
      ...  parameter=availabilityStatus
      Run Keyword If  not ${status}  Run Keywords  Logging With Timestamp
      ...  message=${distname} availabilitystatus should not change, fail
      ...  style=ERROR
      ...  AND  Fail  ${distname} availabilitystatus should not change, fail
      Logging With Timestamp
      ...  message=${distname} remained unchanged
      ...  style=DONE
    END
    Run Keyword If  "${TESTED_BTS_ID}"=="${bts_id}"  Calculate KPI For Rat Reset
    ...  bts_id=${bts_id}
    ...  reset_type=${reset_type}
    ...  tech=${tech}
    Logging Session Multinode Restart  logs_path=${IMS_DIR}/BTSFiles

Calculate KPI For Rat Reset
    [Arguments]  ${bts_id}  ${reset_type}  ${tech}
    [Documentation]  KW calculates KPI7a, KPI7b, KPI10a,KPI10b and prints output.
    ...  Arguments:
    ...  +----------------------+-------+--------------------------------------------------------------------------------+
    ...  | Argument             | Man.  | Description                                                                    |
    ...  +======================+=======+================================================================================+
    ...  | bts_id               | Yes   | specific bts ID                                                                |
    ...  +----------------------+-------+--------------------------------------------------------------------------------+
    ...  | reset_type           | Yes   | Soft or Hard                                                                   |
    ...  +----------------------+-------+--------------------------------------------------------------------------------+
    ...  | tech                 | Yes   | LTE or NR                                                                      |
    ...  +----------------------+-------+--------------------------------------------------------------------------------+
    kpi.Clear Results
    ${kpi_output}=  Run Keyword If  "${reset_type}"=="Soft" and "${tech}"=="LTE"
    ...  kpi.Calculate Kpi7a
    ...  ims_file_path=${IMS_DIR}/BTSFiles/${TESTED_BTS_ID}/InfoModel_For_State_Check_${reset_type}_${tech}_RAT_reset.ims2
    ...  ELSE IF  "${reset_type}"=="Hard" and "${tech}"=="LTE"
    ...  kpi.Calculate Kpi7b
    ...  ims_file_path=${IMS_DIR}/BTSFiles/${TESTED_BTS_ID}/InfoModel_For_State_Check_${reset_type}_${tech}_RAT_reset.ims2
    ...  ELSE IF  "${reset_type}"=="Soft" and "${tech}"=="NR"
    ...  kpi.Calculate Kpi10a
    ...  ims_file_path=${IMS_DIR}/BTSFiles/${TESTED_BTS_ID}/InfoModel_For_State_Check_${reset_type}_${tech}_RAT_reset.ims2
    ...  ELSE IF  "${reset_type}"=="Hard" and "${tech}"=="NR"
    ...  kpi.Calculate Kpi10b
    ...  ims_file_path=${IMS_DIR}/BTSFiles/${TESTED_BTS_ID}/InfoModel_For_State_Check_${reset_type}_${tech}_RAT_reset.ims2
    ${keys}=  Get Dictionary Keys  ${kpi_output}
    Logging With Timestamp
    ...  message=KPI for ${reset_type} ${tech} RAT Reset: ${\n}${kpi_output['${keys[0]}'][0]['detailed_results']['${tech}']}
    ...  style=DONE
