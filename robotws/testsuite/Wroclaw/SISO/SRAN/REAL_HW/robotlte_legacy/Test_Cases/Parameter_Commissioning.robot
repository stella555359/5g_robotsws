*** Settings ***
Documentation
...  Author:  Xu.He@nokia.com
...  Maintainer:  piotr.korczynski@nokia.com

*** Keywords ***
Calculate Parameter Value Before Test
  [Arguments]  ${dist_name}  ${parameter_name}  ${class_name}

  #Get current parameter value
  ${out_parameter_value}=  Evaluate Xpath  ${SCFC_FILE_PATH}
  ...  string(.//managedObject[@class="${class_name}" and @distName="${dist_name}"]/p[@name="${parameter_name}"])

  [Return]  ${out_parameter_value}

SCFC Create Cell Id List Backup
  [Arguments]  ${scfc_file_path}  ${fr_serial_number}

  ${out_lcr_id_list_of_testing_fr}=  SCFC Create LcrId List For FR Serial Number
  ...  scfc_file_path=${scfc_file_path}
  ...  fr_serial_number=${fr_serial_number}
  ${lncel_id_testing_fr}=  SCFC Create LncelId List For LcrdId List
  ...  scfc_file_path=${scfc_file_path}
  ...  lcr_id_list=${out_lcr_id_list_of_testing_fr}
  ${lncel_id}=  Get From List  ${lncel_id_testing_fr}  0
  Set Test Variable  ${CELL_ID}  ${lncel_id}
  ${lcr_id}=  Get From List  ${out_lcr_id_list_of_testing_fr}  0
  Set Test Variable  ${LCR_ID}  ${lcr_id}

  [Return]  ${out_lcr_id_list_of_testing_fr}

Perform Parameter Commissioning Procedure
  [Arguments]  ${parameter_for_btssm}  ${dist_name}  ${parameter_name}  ${parameter_value}

  #Recommission the parameter
  Perform Parameter Recommissioning
  ...  dist_name=${dist_name}
  ...  parameter=${parameter_name}
  ...  skip_parameter_relation_errors=True
  ...  operation=update
  ...  value=${parameter_value}
  ...  alias=${BTS_ID}
  Sleep  60

Check Parameter Is Updated
  [Arguments]  ${parameter_value}  ${dist_name}  ${parameter_name}  ${class_name}
  ${downloaded_scf_file}=  admin.Get Current Scf File
  ...  local_dir_path=${test_logs_path}/
  ...  file_name=check_commission_file.xml
  ...  export_type=configurationAndRuntimeObjects
  ...  parameters_save_variant=actualValues
  ...  timeout=240
  ...  connection=${BTS_ID}
  ${file_path}=  Set Variable  ${downloaded_scf_file}
  ${check_parameter_value}=  Evaluate Xpath  ${file_path}
  ...  string(.//managedObject[@class="${class_name}" and @distName="${dist_name}"]/p[@name="${parameter_name}"])
  Run Keyword if
  ...  "${check_parameter_value}"=="${parameter_value}"
  ...  log
  ...  Cell Administrative State is updated successfully
  ...  ELSE
  ...  FAIL
#cscs
#eNB Should Be Available

  Wait Until Keyword Succeeds  60 sec  1 sec  SM Address Is Pingable  ${ENB_IP}

SM Address Is Pingable
  [Arguments]  ${ENB_IP}
  ${rc}=  Run And Return Rc  ping -c 1 ${ENB_IP}
  should be equal as integers  ${rc}  0
#cscs
Cell Should Be Unblocked Without Query Infomodel Parallel
  [Arguments]  ${lcr_id}  ${timeout}=30  ${alias}=default

  admin_im.Query Infomodel
  ...  query=${INFO_MODEL_CELL_NODE_PATH}-${lcr_id} is [stateInfo.proceduralState=OnAirDone]
  ...  timeout=${timeout}
  ...  alias=${BTS_ID}
  admin_im.Query Infomodel
  ...  query=${INFO_MODEL_CELL_NODE_PATH}-${lcr_id} is [stateInfo.operationalState=Enabled]
  ...  timeout=${timeout}
  ...  alias=${BTS_ID}
  admin_im.Query Infomodel
  ...  query=${INFO_MODEL_CELL_NODE_PATH}-${lcr_id} is [stateInfo.blockingState=Unblocked]
  ...  timeout=${timeout}
  ...  alias=${BTS_ID}


#Automated Siso Perform Parameter Commissioning With Object Lock Cell RaPreGrSize_repetition
#  Run Keyword If  not
#  ...  ${REPETITION}
#  ...  Automated Siso Perform Parameter Commissioning With Object Lock Cell RaPreGrSize
#  ...  ${cfg.test_logs_path}
#  Run Keyword If  not   ${REPETITION}  Return From Keyword
#  FOR  ${repetition_index}  IN  @{REPETITION_LIST}
#    ${loop_log_path}=  TC Repetition Loop Start  ${REPETITION}  ${repetition_index}
#    Run Keyword And Continue On Failure
#    ...  Automated Siso Perform Parameter Commissioning With Object Lock Cell RaPreGrSize
#    ...  ${loop_log_path}
#    TC Repetition Loop Stop  ${REPETITION}  ${repetition_index}
#  END

Automated Siso Perform Parameter Commissioning With Object Lock Cell RaPreGrSize
  [Arguments]  ${test_logs_path}
  Precondition Basic TC  ${test_logs_path}
  Siso Perform Parameter Commissioning With Object Lock Cell RaPreGrSize  ${test_logs_path}  ${cfg.primary_node_bts_id}
  [Teardown]  Postcondition Basic TC  ${test_logs_path}  status=${KEYWORD STATUS}

Siso Perform Parameter Commissioning With Object Lock Cell RaPreGrSize
  [Arguments]  ${test_logs_path}  ${node_id}
  FOR  ${fr_sn}  IN  @{CURRENT_FR_SERIAL_NUMBERS}
    Set Test Variable  ${CURRENT_FR_SERIAL_NUMBER}  ${fr_sn}
    Perform Parameter Commissioning With Object Lock Cell RaPreGrSize  ${test_logs_path}  ${node_id}
  END

Perform Parameter Commissioning With Object Lock Cell RaPreGrSize
  [Arguments]  ${test_logs_path}  ${node_id}
  LG Parameter Commissioning Precondition  ${node_id}  ${test_logs_path}
  #Calculate the parameter value which needs to be recommissioned
  #Get Testing RRH's LCR_ID based on SN list and then get Testing RRH's LNCEL_ID based on LCR_ID
  SCFC Create Cell Id List Backup  ${scfc_file_path}  ${CURRENT_FR_SERIAL_NUMBER}
  ${cell_rapregrsize}=  Calculate Parameter Value Before Test
  ...  dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${CELL_ID}
  ...  parameter_name=raPreGrASize
  ...  class_name=NOKLTE:LNCEL
  Set Test Variable  ${ORIGINAL_CELL_RAPREGRSIZE}  ${cell_rapregrsize}
  Run Keyword If  "${cell_rapregrsize}"=="32"  Run Keyword  Set Test Variable  ${CONFIG_CELL_RAPREGRSIZE}  16
  ...  ELSE  Set Test Variable  ${CONFIG_CELL_RAPREGRSIZE}  32
  Perform Parameter Commissioning Procedure
  ...  parameter_for_btssm=LNCEL:${CELL_ID}:raPreGrASize:${CONFIG_CELL_RAPREGRSIZE}
  ...  dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${CELL_ID}
  ...  parameter_name=raPreGrASize
  ...  parameter_value=${CONFIG_CELL_RAPREGRSIZE}
  Check Cell Rapregrsize Value is Updated  time=1
  #Recover cell rapregrsize to it's original value
  Set Test Variable  ${CONFIG_CELL_RAPREGRSIZE}  ${ORIGINAL_CELL_RAPREGRSIZE}
  Perform Parameter Commissioning Procedure
  ...  parameter_for_btssm=LNCEL:${CELL_ID}:raPreGrASize:${CONFIG_CELL_RAPREGRSIZE}
  ...  dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${CELL_ID}
  ...  parameter_name=raPreGrASize
  ...  parameter_value=${CONFIG_CELL_RAPREGRSIZE}
  Check Cell Rapregrsize Value is Updated  time=2

Check Cell Rapregrsize Value is Updated
  [Arguments]  ${time}
  #Check no eNB reset
  admin.collect_infomodel_log_from_current_session
  ...  target_file_name=${test_logs_path}/${CURRENT_FR_SERIAL_NUMBER}check_ims2.ims2
  ...  timeout=120
  ...  connection=${BTS_ID}
  ...  leave_disconnect_logs=True
  Initialize ims2 validator  ${test_logs_path}/${CURRENT_FR_SERIAL_NUMBER}check_ims2.ims2
  Add expected ims2 event  reset times=0
  Add expected ims2 event
  ...  change ${INFO_MODEL_CELL_NODE_PATH}-${LCR_ID} [stateInfo.operationalState: * -> Disabled ] times=${time}
  Validate ims2
  Check Parameter Is Updated
  ...  parameter_value=${CONFIG_CELL_RAPREGRSIZE}
  ...  dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${CELL_ID}
  ...  parameter_name=raPreGrASize
  ...  class_name=NOKLTE:LNCEL
  Cell Should Be Unblocked Without Query Infomodel Parallel  lcr_id=${LCR_ID}

#Automated Siso Perform Parameter Commissioning With ENB Reset LNBTS Active Baseband Pooling_repetition
#  Run Keyword Unless
#  ...  ${REPETITION}
#  ...  Automated Siso Perform Parameter Commissioning With ENB Reset LNBTS Active Baseband Pooling
#  ...  ${cfg.test_logs_path}
#  Run Keyword Unless  ${REPETITION}  Return From Keyword
#  FOR  ${repetition_index}  IN  @{REPETITION_LIST}
#    ${loop_log_path}=  TC Repetition Loop Start  ${REPETITION}  ${repetition_index}
#    Run Keyword And Continue On Failure
#    ...  Automated Siso Perform Parameter Commissioning With ENB Reset LNBTS Active Baseband Pooling
#    ...  ${loop_log_path}
#    TC Repetition Loop Stop  ${REPETITION}  ${repetition_index}
#  END

Automated Siso Perform Parameter Commissioning With ENB Reset LNBTS Active Baseband Pooling
  [Arguments]  ${test_logs_path}
  Precondition Basic TC  ${test_logs_path}
  Perform Parameter Commissioning With ENB Reset LNBTS Active Baseband Pooling
  ...  ${test_logs_path}
  ...  ${cfg.primary_node_bts_id}
  [Teardown]  Postcondition Basic TC  ${test_logs_path}  status=${KEYWORD STATUS}

Perform Parameter Commissioning With ENB Reset LNBTS Active Baseband Pooling
  [Arguments]  ${test_logs_path}  ${node_id}
  LG Parameter Commissioning Precondition  ${node_id}  ${test_logs_path}
  #Calculate the parameter value which needs to be recommissioned
  ${lnbts_actbbpooling}=  Calculate Parameter Value Before Test
  ...  dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}
  ...  parameter_name=actBbPooling
  ...  class_name=NOKLTE:LNBTS
  Run Keyword If  "${lnbts_actbbpooling}"=="true"  Run Keyword  Set Test Variable  ${LNBTS_ACTBBPOOLING_FLAG}  false
  Run Keyword If  "${lnbts_actbbpooling}"=="false"  Run Keyword  Set Test Variable  ${LNBTS_ACTBBPOOLING_FLAG}  true
  Perform Parameter Commissioning Procedure
  ...  parameter_for_btssm=LNBTS:${BTS_ID}:actBbPooling:${LNBTS_ACTBBPOOLING_FLAG}
  ...  dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}
  ...  parameter_name=actBbPooling
  ...  parameter_value=${LNBTS_ACTBBPOOLING_FLAG}
  Sleep  120
  Check Lnbts Bbpooling Value is Updated  time=1
  #Recover LNBTS actBbPooling value to it's original value
  Run Keyword If
  ...  "${LNBTS_ACTBBPOOLING_FLAG}"=="true"
  ...  Run Keyword
  ...  Set Test Variable
  ...  ${LNBTS_ACTBBPOOLING_FLAG}
  ...  false
  ...  ELSE
  ...  Set Test Variable
  ...  ${LNBTS_ACTBBPOOLING_FLAG}
  ...  true
  Perform Parameter Commissioning Procedure
  ...  parameter_for_btssm=LNBTS:${BTS_ID}:actBbPooling:${LNBTS_ACTBBPOOLING_FLAG}
  ...  dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}
  ...  parameter_name=actBbPooling
  ...  parameter_value=${LNBTS_ACTBBPOOLING_FLAG}
  Sleep  120
  Check Lnbts Bbpooling Value is Updated  time=2

Check Lnbts Bbpooling Value is Updated
  [Arguments]  ${time}

  #Check there is eNB reset when update actBbPooling
  admin.collect_infomodel_log_from_current_session
  ...  target_file_name=${test_logs_path}/${CURRENT_FR_SERIAL_NUMBER}check_ims2.ims2
  ...  timeout=120
  ...  connection=${BTS_ID}
  ...  leave_disconnect_logs=True
  Initialize ims2 validator  ${test_logs_path}/${CURRENT_FR_SERIAL_NUMBER}check_ims2.ims2
  #ENB won't reset on ADMIN branch, but reset on BTSSM branch. Testers should check NIDD website to get the correct eNB reaction
#  Run Keyword If  "${ENB_ACTIONS_TRIGGER}" == "BTSSM"  Run Keyword  Add expected ims2 event  reset times=${time}
  Run Keyword And Continue On Failure  Validate ims2
  Check Parameter Is Updated
  ...  parameter_value=${LNBTS_ACTBBPOOLING_FLAG}
  ...  dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}
  ...  parameter_name=actBbPooling
  ...  class_name=NOKLTE:LNBTS
  eNB Should Be Available

#Automated Perform Parameter Commissioning Without ENB Reset Cell Administrative State_repetition
#  Run Keyword Unless
#  ...  ${REPETITION}
#  ...  Automated Perform Parameter Commissioning Without ENB Reset Cell Administrative State
#  ...  ${cfg.test_logs_path}
#  Run Keyword Unless  ${REPETITION}  Return From Keyword
#  FOR  ${repetition_index}  IN  @{REPETITION_LIST}
#    ${loop_log_path}=  TC Repetition Loop Start  ${REPETITION}  ${repetition_index}
#    Run Keyword And Continue On Failure
#    ...  Automated Perform Parameter Commissioning Without ENB Reset Cell Administrative State
#    ...  ${loop_log_path}
#    TC Repetition Loop Stop  ${REPETITION}  ${repetition_index}
#  END

Automated Perform Parameter Commissioning Without ENB Reset Cell Administrative State
  [Arguments]  ${test_logs_path}
  Precondition Basic TC  ${test_logs_path}
  Siso Perform Parameter Commissioning Without ENB Reset Cell Administrative State
  ...  ${test_logs_path}
  ...  ${cfg.primary_node_bts_id}
  [Teardown]  Postcondition Basic TC  ${test_logs_path}  status=${KEYWORD STATUS}

Siso Perform Parameter Commissioning Without ENB Reset Cell Administrative State
  [Arguments]  ${test_logs_path}  ${node_id}
  LG Parameter Commissioning Precondition  ${node_id}  ${test_logs_path}
  FOR  ${fr_sn}  IN  @{CURRENT_FR_SERIAL_NUMBERS}
    Set Test Variable  ${CURRENT_FR_SERIAL_NUMBER}  ${fr_sn}
    Perform Parameter Commissioning Without ENB Reset Cell Administrative State  ${test_logs_path}  ${node_id}
  END

Perform Parameter Commissioning Without ENB Reset Cell Administrative State
  [Arguments]  ${test_logs_path}  ${node_id}


  #Calculate the parameter value which needs to be recommissioned
  #Get Testing RRH's LCR_ID based on SN list and then get Testing RRH's LNCEL_ID based on LCR_ID
  SCFC Create Cell Id List Backup  ${scfc_file_path}  ${CURRENT_FR_SERIAL_NUMBER}
  ${cell_administrative_state}=  Calculate Parameter Value Before Test
  ...  dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${CELL_ID}
  ...  parameter_name=administrativeState
  ...  class_name=NOKLTE:LNCEL
  Run Keyword If  "${cell_administrative_state}"=="locked"  Run Keyword
  ...  Set Test Variable  ${CELL_ADMINISTRATIVE_STATE_FLAG}  unlocked
  Run Keyword If  "${cell_administrative_state}"=="unlocked"  Run Keyword
  ...  Set Test Variable  ${CELL_ADMINISTRATIVE_STATE_FLAG}  locked
  Perform Parameter Commissioning Procedure
  ...  parameter_for_btssm=LNCEL:${CELL_ID}:administrativeState:${CELL_ADMINISTRATIVE_STATE_FLAG}
  ...  dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${CELL_ID}
  ...  parameter_name=administrativeState
  ...  parameter_value=${CELL_ADMINISTRATIVE_STATE_FLAG}
  Check Cell Administrative State Value is Updated
  #Recover cell administrative state to it's original value
  Run Keyword If  "${CELL_ADMINISTRATIVE_STATE_FLAG}"=="locked"  Run Keyword
  ...  Set Test Variable  ${CELL_ADMINISTRATIVE_STATE_FLAG}  unlocked
  ...  ELSE  Set Test Variable  ${CELL_ADMINISTRATIVE_STATE_FLAG}  locked
  Perform Parameter Commissioning Procedure
  ...  parameter_for_btssm=LNCEL:${CELL_ID}:administrativeState:${CELL_ADMINISTRATIVE_STATE_FLAG}
  ...  dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${CELL_ID}
  ...  parameter_name=administrativeState
  ...  parameter_value=${CELL_ADMINISTRATIVE_STATE_FLAG}
  Check Cell Administrative State Value is Updated

Check Cell Administrative State Value is Updated

  #Check no eNB reset
  admin.collect_infomodel_log_from_current_session
  ...  target_file_name=${test_logs_path}/${CURRENT_FR_SERIAL_NUMBER}check_ims2.ims2
  ...  timeout=120
  ...  connection=${BTS_ID}
  ...  leave_disconnect_logs=True
  Initialize ims2 validator  ${test_logs_path}/${CURRENT_FR_SERIAL_NUMBER}check_ims2.ims2
  Add expected ims2 event  reset times=0
  Validate ims2
  Check Parameter Is Updated
  ...  parameter_value=${CELL_ADMINISTRATIVE_STATE_FLAG}
  ...  dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${CELL_ID}
  ...  parameter_name=administrativeState
  ...  class_name=NOKLTE:LNCEL
  admin_im.Query Infomodel
  ...  query=${INFO_MODEL_CELL_NODE_PATH}-${LCR_ID} is [stateInfo.blockingState=Unblocked]
  ...  timeout=30
  ...  alias=${BTS_ID}
#
#Automated Siso Perform Parameter Commissioning 256QAM_repetition
#  Run Keyword Unless  ${REPETITION}  Automated Siso Perform Parameter Commissioning 256QAM  ${cfg.test_logs_path}
#  Run Keyword Unless  ${REPETITION}  Return From Keyword
#  FOR  ${repetition_index}  IN  @{REPETITION_LIST}
#    ${loop_log_path}=  TC Repetition Loop Start  ${REPETITION}  ${repetition_index}
#    Run Keyword And Continue On Failure  Automated Siso Perform Parameter Commissioning 256QAM  ${loop_log_path}
#    TC Repetition Loop Stop  ${REPETITION}  ${repetition_index}
#  END

Automated Siso Perform Parameter Commissioning 256QAM
  [Arguments]  ${test_logs_path}
  Precondition Basic TC  ${test_logs_path}
  Automated Perform Parameter Commissioning 256QAM  ${test_logs_path}  ${cfg.primary_node_bts_id}
  [Teardown]  Postcondition Basic TC  ${test_logs_path}  status=${KEYWORD STATUS}

Automated Perform Parameter Commissioning 256QAM
  [Arguments]  ${test_logs_path}  ${node_id}
  LG Parameter Commissioning Precondition  ${node_id}  ${test_logs_path}
  FOR  ${fr_sn}  IN  @{CURRENT_FR_SERIAL_NUMBERS}
    Set Test Variable  ${CURRENT_FR_SERIAL_NUMBER}  ${fr_sn}
    Perform Parameter Commissioning 256QAM  ${test_logs_path}
  END

Perform Parameter Commissioning 256QAM
  [Arguments]  ${test_logs_path}
  #Get Testing RRH's LCR_ID based on SN list and then get Testing RRH's LNCEL_ID based on LCR_ID
  SCFC Create Cell Id List Backup  ${SCFC_FILE_PATH}  ${CURRENT_FR_SERIAL_NUMBER}
  #STEP1: Set Modelation Scheme as 64QAM
  Set Test Variable  ${DL_MODULATION_SCHEME}  64QAM
  Set Test Variable  ${CHANNEL_QUALITY_256QAM_FLAG}  false
  Perform Parameter Commissioning Procedure In Short Time
  ...  parameter_for_btssm=LNCEL:${CELL_ID}:actDl256QamChQualEst:${CHANNEL_QUALITY_256QAM_FLAG}
  ...  dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${CELL_ID}
  ...  parameter_name=actDl256QamChQualEst
  ...  parameter_value=${CHANNEL_QUALITY_256QAM_FLAG}
  Perform Parameter Commissioning Procedure In Short Time
  ...  parameter_for_btssm=LNCEL:${CELL_ID}:actModulationSchemeDl:${DL_MODULATION_SCHEME}
  ...  dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${CELL_ID}
  ...  parameter_name=actModulationSchemeDl
  ...  parameter_value=${DL_MODULATION_SCHEME}
  Check Modulation Scheme Value is Updated
  #STEP2: Set Modelation Scheme as 256QAM
  Set Test Variable  ${DL_MODULATION_SCHEME}  256QAM
  Set Test Variable  ${CHANNEL_QUALITY_256QAM_FLAG}  true
  Perform Parameter Commissioning Procedure In Short Time
  ...  parameter_for_btssm=LNCEL:${CELL_ID}:actDl256QamChQualEst:${CHANNEL_QUALITY_256QAM_FLAG}
  ...  dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${CELL_ID}
  ...  parameter_name=actDl256QamChQualEst
  ...  parameter_value=${CHANNEL_QUALITY_256QAM_FLAG}
  Perform Parameter Commissioning Procedure In Short Time
  ...  parameter_for_btssm=LNCEL:${CELL_ID}:actModulationSchemeDl:${DL_MODULATION_SCHEME}
  ...  dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${CELL_ID}
  ...  parameter_name=actModulationSchemeDl
  ...  parameter_value=${DL_MODULATION_SCHEME}
  Check Modulation Scheme Value is Updated

Check Modulation Scheme Value is Updated

  #Check no eNB reset
  admin.collect_infomodel_log_from_current_session
  ...  target_file_name=${test_logs_path}/${CURRENT_FR_SERIAL_NUMBER}check_ims2.ims2
  ...  timeout=120
  ...  connection=${BTS_ID}
  ...  leave_disconnect_logs=True
  Initialize ims2 validator  ${test_logs_path}/${CURRENT_FR_SERIAL_NUMBER}check_ims2.ims2
  Add expected ims2 event  reset times=0
  Validate ims2
  Check Parameter Is Updated
  ...  parameter_value=${CHANNEL_QUALITY_256QAM_FLAG}
  ...  dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${CELL_ID}
  ...  parameter_name=actDl256QamChQualEst
  ...  class_name=NOKLTE:LNCEL
  Check Parameter Is Updated
  ...  parameter_value=${DL_MODULATION_SCHEME}
  ...  dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${CELL_ID}
  ...  parameter_name=actModulationSchemeDl
  ...  class_name=NOKLTE:LNCEL
  Sleep  10
  #Check cell is on air
  Cell Should Be Unblocked Without Query Infomodel Parallel  lcr_id=${LCR_ID}

Perform Parameter Commissioning Procedure In Short Time
  [Arguments]  ${parameter_for_btssm}  ${dist_name}  ${parameter_name}  ${parameter_value}

  #Recommission the parameter
  Perform Parameter Recommissioning
  ...  dist_name=${dist_name}
  ...  parameter=${parameter_name}
  ...  skip_parameter_relation_errors=True
  ...  operation=update
  ...  value=${parameter_value}
  ...  alias=${BTS_ID}
  #No eNB or cell reset procedure, use less time to wait paramter update. 60s is enough, not need 300s.
  Sleep  60

LG Parameter Commissioning Precondition
  [Arguments]  ${node_id}  ${test_logs_path}
  Set Test Variable  ${CONFIGURATION_NAME}  ${configuration_name}
  Set Test Variable  ${BTS_ID}  ${node_id}
  Set Test Variable  ${scfc_file_path}  ${CFG['NODES']['${node_id}']['scf_file_path']}
#  ${act_category_alarms}=  Get From Dictionary  ${cfg.NODES['${node_id}']}  alarms_category
#  Set Test Variable  ${ACT_CATEGORY_ALARMS}  ${act_category_alarms}
  set test variable  ${CURRENT_FR_SERIAL_NUMBERS}  ${cfg.scf_hw_all_fr_list}
  set test variable  ${CURRENT_FR_TESTED_SERIAL_NUMBERS}  ${cfg.rmods_under_test}
  set test variable  ${TEST_LOGS_PATH}  ${test_logs_path}
