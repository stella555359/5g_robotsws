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

*** Keywords ***
# Automated__SiSo__LTE_RAT_reset_from_ADMIN_repetition
#  Run Keyword If  not ${REPETITION}  Perform_LTE_RAT_reset_from_ADMIN  ${TEST_LOGS_PATH}
#  Run Keyword If  not ${REPETITION}  Return From Keyword
#  :FOR  ${repetition_index}  IN  @{REPETITION_LIST}
#  \  ${loop_log_path}=  TC Repetition Loop Start  ${REPETITION}  ${repetition_index}
#  \  Run Keyword And Continue On Failure  Perform_LTE_RAT_reset_from_ADMIN  test_logs_path=${loop_log_path}
#  \  TC Repetition Loop Stop  ${REPETITION}  ${repetition_index}
#
# Perform_LTE_RAT_reset_from_ADMIN
#  [Arguments]  ${test_logs_path}=${TEST_LOGS_PATH}
#  Precondition Basic TC  ${test_logs_path}
#
#  Perform LTE RAT reset from ADMIN On Every Node  ${test_logs_path}
#  [Teardown]  Run Keywords
#  ...  Run Keyword If  "${RELEASE}">="SBTS24R2"  Perform Recommissioning
#  ...  index=postcondition
#  ...  value=${INIT_PARAM}
#  ...  AND  Postcondition Basic TC  ${test_logs_path}  status=${KEYWORD STATUS}

LTE RAT reset from ADMIN
  [Documentation]
  ...  TC for LTE RAT reset from ADMIN API. At first LTE RAT reset is performed (whole operation from sending trigger
  ...  request to NR reaching OnAir again). Then InfoModel log gathered from RAT reset is saved and then checked in order
  ...  to find all cells states changes.
  ...  User needs to declare global variable RAT_IMPACT in cfg dict where cell ids are provided, separated by comma.
  ...
  ...  Parameters:
  ...  Name  |  Mandatory  |  Default value  |  Description
  ...  LTE_RAT_reset_timeout  |  no  |  180  |  Timeout for NR RAT reset
  ...  RAT_IMPACT  |  no  |  n/a  |  Set if NR rat has impact on other rat - CB008880
  ...
  ...  Possible values for RAT_IMPACT - CB008880:
  ...  if variable not set, no impact for other rats
  ...  'LTE' - if only whole LTE RAT impacted
  ...  '<cell_id>,<cell_id>,<cell_id>' - impacted cell ids separated by comma
  Set Tags     AUTHOR-piotr.korczynski@nokia.com  MAINTAINER-piotr.korczynskia@nokia.com
  Common Test Setup
  Logging With Timestamp
  ...  message=Execute Recommissioning On Every Node on list : @{CFG.active_bts_list} will be executed
  ...  style=ONGOING
  FOR  ${bts}  IN  @{CFG.active_bts_list}
    Set Test Variable  ${CURRENT_NODE}  ${bts}
    Set Test Variable  ${TEST_LOGS_PATH}  ${test_logs_path}
    Check Parameter For RAT Reset
    ${LTE_RAT_reset_timeout_exist_in_cfg}=  Run keyword and return status
    ...  Variable should exist
    ...  ${LTE_RAT_reset_timeout}
    ${LTE_RAT_reset_timeout}=  Set Variable If
    ...  ${LTE_RAT_reset_timeout_exist_in_cfg}
    ...  ${LTE_RAT_reset_timeout}
    ...  180
    Set Test Variable  ${LTE_RAT_reset_timeout}  ${LTE_RAT_reset_timeout}
    Run Keyword If  "${RELEASE}"<"SBTS24R2"  Legacy LTE RAT reset  ELSE  Run Keywords
    ...  Set Test Variable  ${INIT_PARAM}  ${ACT_RAT_RESET_ENHANCEMENT}
    ...  AND  Enhanced LTE RAT reset
  END
  [Teardown]    Common Test Teardown

Perform LTE RAT reset from ADMIN On Every Node
  [Arguments]  ${test_logs_path}
  FOR  ${node}  IN  @{cfg.active_bts_list}
    Set Test Variable  ${CURRENT_NODE}  ${node}
    Set Test Variable  ${TEST_LOGS_PATH}  ${test_logs_path}
    Check Parameter For RAT Reset
    ${LTE_RAT_reset_timeout_exist_in_cfg}=  Run keyword and return status
    ...  Variable should exist
    ...  ${LTE_RAT_reset_timeout}
    ${LTE_RAT_reset_timeout}=  Set Variable If
    ...  ${LTE_RAT_reset_timeout_exist_in_cfg}
    ...  ${LTE_RAT_reset_timeout}
    ...  180
    Set Test Variable  ${LTE_RAT_reset_timeout}  ${LTE_RAT_reset_timeout}
    Run Keyword If  "${RELEASE}"<"SBTS24R2"  Legacy LTE RAT reset  ELSE  Run Keywords
    ...  Set Test Variable  ${INIT_PARAM}  ${ACT_RAT_RESET_ENHANCEMENT}
    ...  AND  Enhanced LTE RAT reset
  END

Legacy LTE RAT Reset
  Log  Performing Legacy LTE RAT Reset Scenario  console=True
  Step 1: Check If BTS OnAir
  Step 2: Perform Soft LTE RAT reset
  Step 3: Check If BTS OnAir

Enhanced LTE RAT Reset
  Log  Performing Enhanced LTE RAT Reset Scenario  console=True
  Step 1: Check If BTS OnAir
  Step 2: Perform ActRatResetEnhancement Recommissioning To false
  Step 3: Perform Soft LTE RAT reset
  Step 4: Check If BTS OnAir
  Step 5: Perform Hard LTE RAT reset
  Step 6: Check If BTS OnAir
  Step 7: Perform ActRatResetEnhancement Recommissioning To true
  Step 8: Perform Soft LTE RAT reset
  Step 9: Check If BTS OnAir
  Step 10: Perform Hard LTE RAT reset
  Step 11: Check If BTS OnAir

Step ${index}: Perform ${reset_type} LTE RAT reset
  [Timeout]  15 min
  Log  Step ${index}: Perform ${reset_type} LTE RAT reset  console=True
  Run Keyword If  "${RELEASE}">="SBTS24R2" and "${ACT_RAT_RESET_ENHANCEMENT}"=="true" and "${reset_type}"=="Soft"
  ...  Get Objects Affected By Isolated LTE Reset  ${CURRENT_NODE}
  ...  ELSE  Gather NR Cells Affected By CB008880  ${CURRENT_NODE}
  admin.Rat Reset  rat_type=LTE  reset_type=${reset_type}  timeout=${LTE_RAT_reset_timeout}  connection=${CURRENT_NODE}
  Log  LTE RAT reset has been performed via ADMIN API  console=True
  Log  Saving Infomodel log for TC checks  console=True
  Verify Multi BTS State
  admin.Collect Infomodel Log From Current Session
  ...  target_file_name=${TEST_LOGS_PATH}/IM/InfoModel_Step${index}_${reset_type}_LTE_RAT_reset.ims2
  ...  connection=${CURRENT_NODE}
  Set test variable  ${IM_LOG_PATH}  ${TEST_LOGS_PATH}/IM/InfoModel_Step${index}_${reset_type}_LTE_RAT_reset.ims2
  Log  Infomodel log saved under ${IM_LOG_PATH}  console=True

#LTE RAT reset from ADMIN
#  [Documentation]
#  ...  TC for LTE RAT reset from ADMIN API. At first LTE RAT reset is performed (whole operation from sending trigger
#  ...  request to LTE reaching OnAir again). Then InfoModel log gathered from RAT reset is saved and then checked in order
#  ...  to find all LTE DSPs and cells states changes.
#  ...
#  ...  Parameters:
#  ...  Name  |  Mandatory  |  Default value  |  Description
#  ...  LTE_RAT_reset_timeout |  no  |  180  |  Timeout for LTE RAT reset
#  ...  RAT_IMPACT  |  no  |  n/a  |  Set if LTE rat has impact on other rat - CB008880
#  ...
#  ...  Possible values for RAT_IMPACT - CB008880:
#  ...  if variable not set, no impact for other rats
#  ...  'NR' - if only whole NR RAT impacted
#  ...  '<cell_id>,<cell_id>,<cell_id>' - impacted cell ids separated by comma
#  [Arguments]  ${test_logs_path}=${TEST_LOGS_PATH}  ${alias}=${cfg.primary_node_bts_id}
#
#  Step 2: Perform LTE RAT reset  alias=${alias}
#  Step 3: Save Infomodel log for TC checks  alias=${alias}
#  Step 5: Check if LTE cells were degraded  alias=${alias}
#  Verify States When LTE RAT Reset  ${alias}  ${TEST_LOGS_PATH}

#  [Teardown]  Run Keywords
#  ...  Verify Multi BTS State
#  ...  AND  Verify Unexpected And Historical Alarms  alias=${alias}

Gather NR Cells Affected By CB008880
  [Documentation]  KW prepare list of affected cells by feature CB008880. User needs to declare global
  ...  variable RAT_IMPACT where cell ids are provided, separated by comma.
  [Arguments]  ${current_node}
  ${no_rat_impact}=  Run Keyword And Return Status  Variable Should Not Exist  ${RAT_IMPACT}
  ${affected_cells}=  Run Keyword If  ${no_rat_impact}  Create List
  ...  ELSE  Get LTE Rat Impact  ${current_node}
  ${all_ln_dists}=  admin.Get Ids For All  LNCEL  search_for_iot_cells=${True}  connection=${current_node}
  ${IMPACTED_OBJECTS}=  Combine Lists  ${affected_cells}  ${all_ln_dists}
  Remove Duplicates  ${IMPACTED_OBJECTS}
  ${NOT_IMPACTED_OBJECTS}=  Find Not Impacted Objects  ${IMPACTED_OBJECTS}
  Set Test Variable  ${NOT_IMPACTED_OBJECTS}
  Set Test Variable  ${IMPACTED_OBJECTS}

Get Objects Affected By Isolated LTE Reset
  [Arguments]  ${current_node}
  ${IMPACTED_OBJECTS}=  admin.Get Ids For All  LNCEL  search_for_iot_cells=${True}  connection=${current_node}
  ${all_ln_dists}=  admin.Get Ids For All  NRCEL  connection=${current_node}
  ${all_wn_dists}=  admin.Get Ids For All  WNCEL  connection=${current_node}
  ${all_gn_dists}=  admin.Get Ids For All  GNCEL  connection=${current_node}
  ${all_sm_dists}=  admin.Get Ids For All  SMOD  connection=${current_node}
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

Get LTE Rat Impact
  [Arguments]  ${current_node}
  ${affected_cells}=  Run Keyword If  "${RAT_IMPACT}"=="NR"  _Create_Distnames_Only_NR  ${current_node}
  ...  ELSE  _Create All Distnames  ${RAT_IMPACT}  ${current_node}
  [Return]  ${affected_cells}

_Create All Distnames
  [Arguments]  ${ids}  ${current_node}
  ${dists}=  Create List
  ${ids}=  Split String From Right  ${ids}  ,
  ${all_nr_dists}=  admin.Get Ids For All  NRCEL  connection=${current_node}
  ${all_wn_dists}=  admin.Get Ids For All  WNCEL  connection=${current_node}
  ${all_gn_dists}=  admin.Get Ids For All  GNCEL  connection=${current_node}
  ${lw_cells}=  Combine Lists  ${all_nr_dists}  ${all_wn_dists}
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

_Create_Distnames_Only_NR
  [Arguments]  ${current_node}
  Run Keyword If
  ...  "${cfg['NODES']['${current_node}']['scf_nr']}"=="False"
  ...  Fail
  ...  User Set RAT_IMPACT for all NR but no NR on NODE ${current_node}
  ${all_nr}=  admin.Get Ids For All  NRCEL  connection=${current_node}
  [Return]  ${all_nr}

Verify States When LTE RAT Reset
  [Arguments]  ${current_node}  ${test_logs_path}
  Log To Console  Checking states for not impacted objects:${\n}
  FOR  ${cell_object}  IN  @{NOT_IMPACTED_OBJECTS}
    Run Keyword And Expect Error  No change found in*  Find Parameter Change
    ...  ${test_logs_path}/RAT_Reset_InfoModel_log_from_${current_node}.ims2
    ...  ${cell_object}
    ...  availabilityStatus
    Log  ${cell_object} remained unchanged  console=${TRUE}
  END
  Log To Console  ${\n}Checking states for impacted objects:${\n}
  FOR  ${cell_object}  IN  @{IMPACTED_OBJECTS}
    Find Parameter Change
    ...  ${test_logs_path}/RAT_Reset_InfoModel_log_from_${current_node}.ims2
    ...  ${cell_object}  availabilityStatus
    ...  Regex"(?i)failed|(?i)off.*line"
    Log  ${cell_object} changed to offline  console=${TRUE}
  END

Step 1: Get all LTE DSPs dist names
  [Arguments]  ${alias}=${cfg.primary_node_bts_id}
  Log  Get all LTE DSPs dist names  console=${TRUE}
  ${dsps_dist_names}=  Create list
  ${sw_entities_objects}=  admin_im.Query Infomodel  get list //DSP_L-*/SOFTWARE_ENTITY-* is [rat="LTE"]  alias=${alias}
  FOR  ${sw_entity}  IN  @{sw_entities_objects}
    Append to list  ${dsps_dist_names}  ${sw_entity['deviceDN']}
  END
  Sort list  ${dsps_dist_names}
  Log  LTE DSPs list: ${dsps_dist_names}  console=${TRUE}
  Set test variable  ${DSPS_DIST_NAMES}  ${dsps_dist_names}

Step 2: Perform LTE RAT reset
  [Arguments]  ${alias}=${cfg.primary_node_bts_id}
  Log  Perform LTE RAT reset  console=${TRUE}
  ${LTE_RAT_reset_timeout_exist_in_cfg}=  Run keyword and return status
  ...  Variable should exist
  ...  ${LTE_RAT_reset_timeout}
  ${LTE_RAT_reset_timeout}=  Set variable if  ${LTE_RAT_reset_timeout_exist_in_cfg}  ${LTE_RAT_reset_timeout}  180
  admin.Reset Rat  LTE  timeout=${LTE_RAT_reset_timeout}  connection=${alias}
  Log  LTE RAT reset has been performed via ADMIN API  console=${TRUE}

Step 3: Save Infomodel log for TC checks
  [Arguments]  ${alias}=${cfg.primary_node_bts_id}
  Log  Save Infomodel log for TC checks  console=${TRUE}
  Sleep  120s  Wait for DSPs states save inside IM
  Save infomodel log  ${TEST_LOGS_PATH}/RAT_Reset_InfoModel_log_from_${cfg.primary_node_bts_id}.ims2  alias=${alias}
  Set test variable  ${IM_LOG_PATH}  ${TEST_LOGS_PATH}/RAT_Reset_InfoModel_log_from_${cfg.primary_node_bts_id}.ims2
  Log  Infomodel log saved under ${IM_LOG_PATH}  console=${TRUE}

Step 4: Check if LTE DSPs were restarted
  [Arguments]  ${alias}=${cfg.primary_node_bts_id}
  Log  Check if LTE DSPs were restarted  console=${TRUE}
  FOR  ${dsp_dist_name}  IN  @{DSPS_DIST_NAMES}
    Initialize ims2 validator  ${IM_LOG_PATH}  alias=${alias}
    Add expected ims2 event
    ...  change ${dsp_dist_name} [stateInfo.proceduralState: * -> Resetting] times=1
    ...  alias=${alias}
    Validate ims2  alias=${alias}
    Log  ${dsp_dist_name} was restarted  console=${TRUE}
  END
  Log  All DSPs were restarted during LTE RAT reset  console=${TRUE}

Step 5: Check if LTE cells were degraded
  [Arguments]  ${alias}=${cfg.primary_node_bts_id}
  Log  Check if LTE cells were degraded  console=${TRUE}
  ${lte_cells_objects}=  admin_im.Query Infomodel
  ...  get list /MRBTS-1/RAT-1//BBTOP_M-1/MRBTS_M-1/LNBTS_M-*/CELL_M-*
  ...  alias=${alias}
  FOR  ${cell_object}  IN  @{lte_cells_objects}
    Initialize ims2 validator  ${IM_LOG_PATH}  alias=${alias}
    Add expected ims2 event
    ...  change ${cell_object.dist_name} [stateInfo.availabilityStatus: Online -> Offline]
    ...  alias=${alias}
    Add expected ims2 event
    ...  change ${cell_object.dist_name} [stateInfo.operationalState: Enabled -> Disabled]
    ...  alias=${alias}
    Validate ims2  alias=${alias}
    Log
    ...  ${cell_object.dist_name} states changed: availabilityStatus: Online -> Offline, operationalState: Enabled -> Disabled
    ...  console=${TRUE}
    Initialize ims2 validator  ${IM_LOG_PATH}  alias=${alias}
    Add expected ims2 event  change ${cell_object.dist_name} [stateInfo.administrativeState]  alias=${alias}
    Add expected ims2 event  change ${cell_object.dist_name} [stateInfo.blockingState]  alias=${alias}
    Run keyword and expect error  InfoModelIms2ValidationException:*  Validate ims2  alias=${alias}
    Log  ${cell_object.dist_name} administrativeState and blockingState remained unchanged  console=${TRUE}
  END
  Log  All LTE cells were degraded during LTE RAT reset  console=${TRUE}

Step 6: Check if cells on other RATs were operational
  [Arguments]  ${alias}=${cfg.primary_node_bts_id}
  Log  Check if cells on other RATs were operational  console=${TRUE}
  ${rat_cell_dist}=  Set variable  /MRBTS-1/RAT-1//BBTOP_M-1/MRBTS_M-1/WNBTS_M-*/CELL_M-*
  ${cells_objects}=  admin_im.Query Infomodel  get list ${rat_cell_dist}  allow_negative_result=True  alias=${alias}
  Log  Check WCDMA cells  console=${TRUE}
  FOR  ${cell_object}  IN  @{cells_objects}
    Initialize ims2 validator  ${IM_LOG_PATH}  alias=${alias}
    Add expected ims2 event  change ${cell_object.dist_name} [stateInfo.availabilityStatus]  alias=${alias}
    Add expected ims2 event  change ${cell_object.dist_name} [stateInfo.operationalState]  alias=${alias}
    Run keyword and expect error  InfoModelIms2ValidationException:*  Validate ims2  alias=${alias}
    Log  ${cell_object.dist_name} availabilityStatus and operationalState remained unchanged  console=${TRUE}
  END
  Log  All WCDMA cells were operational according to IM log  console=${TRUE}
  ${rat_cell_dist}=  Set variable  /MRBTS-1/RAT-1//BBTOP_M-1/MRBTS_M-1/GNBTS_M-*/CELL_M-*
  ${cells_objects}=  admin_im.Query Infomodel  get list ${rat_cell_dist}  allow_negative_result=True  alias=${alias}
  Log  Check GSM cells  console=${TRUE}
  FOR  ${cell_object}  IN  @{cells_objects}
    Initialize ims2 validator  ${IM_LOG_PATH}  alias=${alias}
    Add expected ims2 event  change ${cell_object.dist_name} [stateInfo.availabilityStatus]  alias=${alias}
    Add expected ims2 event  change ${cell_object.dist_name} [stateInfo.operationalState]  alias=${alias}
    Run keyword and expect error  InfoModelIms2ValidationException:*  Validate ims2  alias=${alias}
    Log  ${cell_object.dist_name} availabilityStatus and operationalState remained unchanged  console=${TRUE}
  END
  Log  All GSM cells were operational according to IM log  console=${TRUE}
  ${rat_cell_dist}=  Set variable  /MRBTS-1/RAT-1//BBTOP_M-1/MRBTS_M-1/NRBTS_M-*/CELL_M-*
  ${cells_objects}=  admin_im.Query Infomodel  get list ${rat_cell_dist}  allow_negative_result=True  alias=${alias}
  Log  Check NR cells  console=${TRUE}
  FOR  ${cell_object}  IN  @{cells_objects}
    Initialize ims2 validator  ${IM_LOG_PATH}  alias=${alias}
    Add expected ims2 event  change ${cell_object.dist_name} [stateInfo.availabilityStatus]  alias=${alias}
    Add expected ims2 event  change ${cell_object.dist_name} [stateInfo.operationalState]  alias=${alias}
    Run keyword and expect error  InfoModelIms2ValidationException:*  Validate ims2  alias=${alias}
    Log  ${cell_object.dist_name} availabilityStatus and operationalState remained unchanged  console=${TRUE}
  END
  Log  All NR cells were operational according to IM log  console=${TRUE}

Step 7: Check if LTE cells are operational
  [Arguments]  ${alias}=${cfg.primary_node_bts_id}
  Log  Check if LTE cells are operational  console=${TRUE}
  ${node}=  Fetch from right  ${alias}  _
  ${are_lncels_online}=  Run keyword and return status  Verify Admin Every LTE Cell State  ${node}
  Should be true  ${are_lncels_online}  Not all LTE cells are online after LTE RAT reset
