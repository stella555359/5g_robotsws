*** Settings ***
Documentation  Maintainers: @I_SRAN_PROD_SISO_WRO_CRTDEV_GMS

Resource    ../Resources/Setup/setup_and_teardown.robot
Resource  ./common_setup.robot
Resource  ./site_operations.robot
Resource  ./site_verifications.robot
Resource  ./variables.robot


Library  BuiltIn
Library  Collections
Library  String
Library  robot.libraries.DateTime
Library  taf.sbts.oam.coam.admin    WITH NAME    admin
Library  ute_admin_infomodel    WITH NAME    admin_im

Resource  ./lte_rat_reset.robot
Resource  ./nr_rat_reset.robot


*** Keywords ***

# NR RAT reset from ADMIN_repetition
#  Run Keyword If  not ${REPETITION}  NR RAT reset from ADMIN  ${TEST_LOGS_PATH}
#  Run Keyword If  not ${REPETITION}  Return From Keyword
#  FOR  ${repetition_index}  IN  @{REPETITION_LIST}
#  ${loop_log_path}=  TC Repetition Loop Start  ${REPETITION}  ${repetition_index}
#  Run Keyword And Continue On Failure  NR RAT reset from ADMIN  ${loop_log_path}
#  TC Repetition Loop Stop  ${REPETITION}  ${repetition_index}
#  END
#
# NR RAT reset from ADMIN
#  [Arguments]  ${test_logs_path}=${TEST_LOGS_PATH}
#  Precondition Basic TC  ${test_logs_path}
#  Perform NR RAT reset from ADMIN On Every Node  ${test_logs_path}
#  [Teardown]  Logging Multinode Stop  ${test_logs_path}  status=${KEYWORD STATUS}


NR RAT reset from ADMIN
  Set Tags     AUTHOR-piotr.korczynski@nokia.com  MAINTAINER-piotr.korczynskia@nokia.com
  Common Test Setup
  Logging With Timestamp
  ...  message=Execute Recommissioning On Every Node on list : @{CFG.active_bts_list} will be executed
  ...  style=ONGOING
  FOR  ${bts}  IN  @{CFG.active_bts_list}
    Continue For Loop If  "${cfg['NODES']['${bts}']['scf_nr']}"=="False"
    Set Test Variable  ${CURRENT_NODE}  ${bts}
    Set Test Variable  ${TEST_LOGS_PATH}  ${test_logs_path}
    Execute NR RAT reset from ADMIN
  END
  [Teardown]    Common Test Teardown

Execute NR RAT reset from ADMIN
  [Documentation]
  ...  TC for NR RAT reset from ADMIN API. At first NR RAT reset is performed (whole operation from sending trigger
  ...  request to NR reaching OnAir again). Then InfoModel log gathered from RAT reset is saved and then checked in order
  ...  to find all cells states changes.
  ...  User needs to declare global variable RAT_IMPACT in cfg dict where cell ids are provided, separated by comma.
  ...
  ...  Parameters:
  ...  Name  |  Mandatory  |  Default value  |  Description
  ...  NR_RAT_RESET_TIMEOUT  |  no  |  180  |  Timeout for NR RAT reset
  ...  RAT_IMPACT  |  no  |  n/a  |  Set if NR rat has impact on other rat - CB008880
  ...
  ...  Possible values for RAT_IMPACT - CB008880:
  ...  if variable not set, no impact for other rats
  ...  'LTE' - if only whole LTE RAT impacted
  ...  '<cell_id>,<cell_id>,<cell_id>' - impacted cell ids separated by comma
  Preconditions
  Run Keyword If  "${RELEASE}"<"SBTS24R2"  Legacy NR RAT Reset  ELSE  Run Keywords
  ...  Set Test Variable  ${INIT_PARAM}  ${ACT_RAT_RESET_ENHANCEMENT}
  ...  AND  Enhanced NR RAT Reset
  Postconditions

Gather Cells Affected By CB008880
  [Documentation]  KW prepare list of affected objects by feature CB008880. User needs to declare global
  ...  variable RAT_IMPACT where cell ids are provided, separated by comma.
  ${no_rat_impact}=  Run Keyword And Return Status  Variable Should Not Exist  ${RAT_IMPACT}
  ${affected_cells}=  Run Keyword If  ${no_rat_impact}  Create List
  ...  ELSE  Get Rat Impact
  ${all_nr_dists}=  admin.Get Ids For All  NRCEL  connection=${CURRENT_NODE}
  ${IMPACTED_OBJECTS}=  Combine Lists  ${affected_cells}  ${all_nr_dists}
  Remove Duplicates  ${IMPACTED_OBJECTS}
  ${NOT_IMPACTED_OBJECTS}=  Find Not Impacted Objects  ${IMPACTED_OBJECTS}
  Set Test Variable  ${NOT_IMPACTED_OBJECTS}
  Set Test Variable  ${IMPACTED_OBJECTS}

Get Rat Impact
  ${affected_cells}=  Run Keyword If  "${RAT_IMPACT}"=="LTE"  _Create_Distnames_Only_LTE
  ...  ELSE  _Create Distnames  ${RAT_IMPACT}
  [Return]  ${affected_cells}

Get Objects Affected By Isolated Reset
  ${IMPACTED_OBJECTS}=  admin.Get Ids For All  NRCEL  connection=${CURRENT_NODE}
  ${all_ln_dists}=  admin.Get Ids For All  LNCEL  connection=${CURRENT_NODE}
  ${all_wn_dists}=  admin.Get Ids For All  WNCEL  connection=${CURRENT_NODE}
  ${all_gn_dists}=  admin.Get Ids For All  GNCEL  connection=${CURRENT_NODE}
  ${all_sm_dists}=  admin.Get Ids For All  SMOD  connection=${CURRENT_NODE}
  ${abil_stat}  ${bb_message}=  Run Keyword And Ignore Error  admin.Assert Any
  ...  class_name=BBMOD
  ...  parameters=productName=regex"(?i)ABIL"
  ...  connection=${CURRENT_NODE}
  ${all_hw_dists}=  Run Keyword If
  ...  "${abil_stat}"=="FAIL"
  ...  _Get HW Ids
  ...  ELSE
  ...  _Get BBMOD Ids With Abil Excluded
  ...  ${bb_message}
  ${NOT_IMPACTED_OBJECTS}=  Combine Lists
  ...  ${all_ln_dists}  ${all_wn_dists}  ${all_gn_dists}  ${all_hw_dists}  ${all_sm_dists}
  Set Test Variable  ${NOT_IMPACTED_OBJECTS}
  Set Test Variable  ${IMPACTED_OBJECTS}

_Get HW Ids
  ${all_asrf_dists}=  admin.Get Ids For All  ASIRMOD  connection=${CURRENT_NODE}
  ${all_rf_dists}=  admin.Get Ids For All  RMOD  connection=${CURRENT_NODE}
  ${all_bb_dists}=  admin.Get Ids For All  BBMOD  connection=${CURRENT_NODE}
  ${all_hw_dists}=  Combine Lists  ${all_asrf_dists}  ${all_rf_dists}  ${all_bb_dists}
  [Return]  ${all_hw_dists}

_Get BBMOD Ids With Abil Excluded
  [Arguments]  ${bb_message}
  ${abil_excl_bb_list}=  Create List
  FOR  ${item}  IN  @{bb_message}
    Run Keyword If
    ...  "${item['productName']}"!="ABIL AirScale Capacity"
    ...  Append To List
    ...  ${abil_excl_bb_list}
    ...  ${item['id']}
  END
  [Return]  ${abil_excl_bb_list}

_Create Distnames
  [Arguments]  ${ids}
  ${dists}=  Create List
  ${ids}=  Split String From Right  ${ids}  ,
  ${all_ln_dists}=  admin.Get Ids For All  LNCEL  search_for_iot_cells=${True}  connection=${CURRENT_NODE}
  ${all_wn_dists}=  admin.Get Ids For All  WNCEL  connection=${CURRENT_NODE}
  ${all_gn_dists}=  admin.Get Ids For All  GNCEL  connection=${CURRENT_NODE}
  ${lw_cells}=  Combine Lists  ${all_ln_dists}  ${all_wn_dists}
  FOR  ${id}  IN  @{ids}
    ${lw_matches}=  Get Matches  ${lw_cells}  regexp=.*-${id}$
    ${match_status}=  Run Keyword And Return Status  Should Not Be Empty  ${lw_matches}
    Run Keyword If  ${match_status}  Run Keywords  Append To List  ${dists}  ${lw_matches[0]}
    ...  AND  Continue For Loop
    ${g_matches}=  Get Matches  ${all_gn_dists}  regexp=.*M-${id}\/.*
    ${match_status}=  Run Keyword And Return Status  Should Not Be Empty  ${g_matches}
    Run Keyword If  ${match_status}  Append To List  ${dists}  ${g_matches[0]}
    ...  ELSE  Fail  Cell with id=${id} provided by user not found on BTS
  END
  [Return]  ${dists}

_Create_Distnames_Only_LTE
  Run Keyword If  "${cfg['NODES']['${${CURRENT_NODE}}']['scf_lte']}"=="False"
  ...  Fail  User Set RAT_IMPACT for all LTE but no LTE on NODE ${CURRENT_NODE}
  ${all_lte}=  admin.Get Ids For All  LNCEL  search_for_iot_cells=${True}  connection=${CURRENT_NODE}
  [Return]  ${all_lte}

Find Not Impacted Objects
  [Documentation]  KW prepares objects not impacted by LTE RAT Reset
  [Arguments]  ${impacted_cells}
  ${all_objs}=  Gather All Objects
  FOR  ${cell}  IN  @{impacted_cells}
    Remove Values From List  ${all_objs}  ${cell}
  END
  [Return]  ${all_objs}

Gather All Objects
  ${all_nr_dists}=  admin.Get Ids For All  NRCEL  connection=${CURRENT_NODE}
  ${all_ln_dists}=  admin.Get Ids For All  LNCEL  search_for_iot_cells=${True}  connection=${CURRENT_NODE}
  ${all_wn_dists}=  admin.Get Ids For All  WNCEL  connection=${CURRENT_NODE}
  ${all_gn_dists}=  admin.Get Ids For All  GNCEL  connection=${CURRENT_NODE}
  ${all_sm_dists}=  admin.Get Ids For All  SMOD  connection=${CURRENT_NODE}
  ${all_objs}=  Combine Lists  ${all_nr_dists}  ${all_ln_dists}  ${all_wn_dists}  ${all_gn_dists}  ${all_sm_dists}
  [Return]  ${all_objs}

Check Parameter For RAT Reset
  admin.Get Current Scf File
  ...  local_dir_path=${TEST_LOGS_PATH}
  ...  timeout=30
  ...  file_name=scf_${CURRENT_NODE}.xml
  ...  connection=${CURRENT_NODE}
  ${parameter}=  Evaluate Xpath  ${TEST_LOGS_PATH}/scf_${CURRENT_NODE}.xml
  ...  string(.//managedObject[contains(@distName, "FEATCADM")]/p[@name="actRatResetEnhancement"])
  ${ACT_RAT_RESET_ENHANCEMENT}=  Set Variable If  "${parameter}"=="false" or "${parameter}"==""  false  true
  ${DIST_NAME}=  Evaluate Xpath  ${TEST_LOGS_PATH}/scf_${CURRENT_NODE}.xml
  ...  string(.//managedObject[contains(@distName, "FEATCADM") and (p[@name="actRatResetEnhancement"])]/@distName)
  Set Test Variable  ${ACT_RAT_RESET_ENHANCEMENT}
  Set Test Variable  ${DIST_NAME}

Perform Recommissioning
  [Arguments]  ${index}  ${value}
  Run Keyword If
  ...  "${ACT_RAT_RESET_ENHANCEMENT}"!="${value}"
  ...  Perform Parameter Recommissioning
  ...  dist_name=${DIST_NAME}
  ...  parameter=actRatResetEnhancement
  ...  value=${value}
  ...  operation=update
  ...  connection=${CURRENT_NODE}
  ...  ELSE
  ...  Run Keywords
  ...  Log
  ...  Parameter actRatResetEnhancement has expected value=${value}, recommissioning not needed
  ...  console=True
  ...  AND
  ...  Return From Keyword
  admin.Get Current Scf File
  ...  local_dir_path=${TEST_LOGS_PATH}
  ...  timeout=30
  ...  file_name=scf_${CURRENT_NODE}_Step_${index}.xml
  ...  connection=${CURRENT_NODE}
  ${parameter}=  Evaluate Xpath  ${TEST_LOGS_PATH}/scf_${CURRENT_NODE}_Step_${index}.xml
  ...  string(.//managedObject[contains(@distName, "FEATCADM")]/p[@name="actRatResetEnhancement"])
  Run Keyword If
  ...  "${parameter}"=="${value}"
  ...  Log
  ...  Parameter actRatResetEnhancement successfuly set to ${value}
  ...  console=True
  ...  ELSE
  ...  Fail
  ...  Parameter actRatResetEnhancement=${parameter}, test failed
  Set Test Variable  ${ACT_RAT_RESET_ENHANCEMENT}  ${parameter}

Preconditions
  Check Parameter For RAT Reset
  ${NR_RAT_reset_timeout_exist_in_cfg}=  Run keyword and return status
  ...  Variable should exist
  ...  ${NR_RAT_RESET_TIMEOUT}
  ${NR_RAT_RESET_TIMEOUT}=  Set Variable If  ${NR_RAT_reset_timeout_exist_in_cfg}  ${NR_RAT_RESET_TIMEOUT}  180
  Set Test Variable  ${NR_RAT_RESET_TIMEOUT}  ${NR_RAT_RESET_TIMEOUT}

Postconditions
  Run Keyword If  "${RELEASE}">="SBTS24R2"  Perform Recommissioning
  ...  index=postcondition
  ...  value=${INIT_PARAM}

Legacy NR RAT Reset
  Log  Performing Legacy NR RAT Reset Scenario  console=True
  Step 1: Check If BTS OnAir
  Step 2: Perform Soft NR RAT reset
  Step 3: Check If BTS OnAir

Enhanced NR RAT Reset
  Log  Performing Enhanced NR RAT Reset Scenario  console=True
  Step 1: Check If BTS OnAir
  Step 2: Perform ActRatResetEnhancement Recommissioning To false
  Step 3: Perform Soft NR RAT reset
  Step 4: Check If BTS OnAir
  Step 5: Perform Hard NR RAT reset
  Step 6: Check If BTS OnAir
  Step 7: Perform ActRatResetEnhancement Recommissioning To true
  Step 8: Perform Soft NR RAT reset
  Step 9: Check If BTS OnAir
  Step 10: Perform Hard NR RAT reset
  Step 11: Check If BTS OnAir

Step ${index}: Check If BTS OnAir
  Log  Step ${index}: Check If BTS OnAir  console=True
  Run Keyword If  ${index}!=1  Verify States And Faults
  Log  All states and faults are checked successfuly, test can proceed  console=True

Verify States And Faults
  Log  Check if expected cells were degraded  console=True
  FOR  ${cell_object}  IN  @{IMPACTED_OBJECTS}
    Find Parameter Change  ${IM_LOG_PATH}  ${cell_object}  availabilityStatus  Regex"(?i)off.*line"
    Log  ${cell_object} changed to offline  console=${TRUE}
  END
  Log  All expected cells were degraded during NR RAT reset  console=True
  Log  Check if rest of expected runtime objects were operational  console=True
  FOR  ${cell_object}  IN  @{NOT_IMPACTED_OBJECTS}
    Run Keyword And Expect Error
    ...  No change found in*
    ...  Find Parameter Change
    ...  ${IM_LOG_PATH}
    ...  ${cell_object}
    ...  availabilityStatus
    Log  ${cell_object} remained unchanged  console=${TRUE}
  END
  Verify Unexpected And Historical Alarms  alias=${CURRENT_NODE}
  Reset Admin  connection=${CURRENT_NODE}

Step ${index}: Perform ${reset_type} NR RAT reset
  [Timeout]  15 min
  Log  Step ${index}: Perform ${reset_type} NR RAT reset  console=True
  Run Keyword If  "${RELEASE}">="SBTS24R2" and "${ACT_RAT_RESET_ENHANCEMENT}"=="true" and "${reset_type}"=="Soft"
  ...  Get Objects Affected By Isolated Reset
  ...  ELSE  Gather Cells Affected By CB008880
  admin.Rat Reset  rat_type=NR  reset_type=${reset_type}  timeout=${NR_RAT_RESET_TIMEOUT}  connection=${CURRENT_NODE}
  Log  NR RAT reset has been performed via ADMIN API  console=True
  Log  Saving Infomodel log for TC checks  console=True
  Verify Multi BTS State
  admin.Collect Infomodel Log From Current Session
  ...  target_file_name=${TEST_LOGS_PATH}/IM/InfoModel_Step${index}_${reset_type}_NR_RAT_reset.ims2
  ...  connection=${CURRENT_NODE}
  Set test variable  ${IM_LOG_PATH}  ${TEST_LOGS_PATH}/IM/InfoModel_Step${index}_${reset_type}_NR_RAT_reset.ims2
  Log  Infomodel log saved under ${IM_LOG_PATH}  console=True

Step ${index}: Perform ActRatResetEnhancement Recommissioning To ${value}
  Log  Step ${index}: Perform ActRatResetEnhancement Recommissioning To ${value}  console=True
  Perform Recommissioning  index=${index}  value=${value}
