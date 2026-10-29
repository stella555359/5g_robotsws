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

Library  ../Resources/Python/siso_logger.py

*** Variables ***
${ENB_IP}=  192.168.255.129


*** Keywords ***
Calculate Parameter Value Before Test
  [Arguments]  ${dist_name}  ${parameter_name}  ${class_name}

  ${out_parameter_value}=  Evaluate Xpath  ${OUT_TESTCASE_LOGS_DIR_PATH}Scfc\-Precondition.xml
  ...  string(.//managedObject[@class="${class_name}" and @distName="${dist_name}"]/p[@name="${parameter_name}"])

  [Return]  ${out_parameter_value}

SCFC Create Cell Id List Backup
  [Arguments]  ${scfc_file_path}  ${fr_serial_number}

  ${out_lcr_id_list_of_testing_fr}=  SCFC Create LcrId List For FR Serial Number
  ...  scfc_file_path=${scfc_file_path}  fr_serial_number=${fr_serial_number}
  ${lncel_id_testing_fr}=  SCFC Create LncelId List For LcrdId List
  ...  scfc_file_path=${scfc_file_path}  lcr_id_list=${out_lcr_id_list_of_testing_fr}
  ${lncel_id}=  Get From List  ${lncel_id_testing_fr}  0
  Set Test Variable  ${CELL_ID}  ${lncel_id}
  ${lcr_id}=  Get From List  ${out_lcr_id_list_of_testing_fr}  0
  Set Test Variable  ${LCR_ID}  ${lcr_id}

  [Return]  ${out_lcr_id_list_of_testing_fr}

Perform Parameter Commissioning Procedure
  [Arguments]  ${parameter_for_btssm}  ${dist_name}  ${parameter_name}  ${parameter_value}

  # Recommission the parameter
  Run Keyword If  "${ENB_ACTIONS_TRIGGER}" == "BTSSM"  Run Keyword
  ...  Perform Parameter Commissioning  parameter=${parameter_for_btssm}
  Run Keyword If
  ...  "${ENB_ACTIONS_TRIGGER}" == "ADMIN"
  ...  Run Keyword
  ...  Perform Parameter Recommissioning
  ...  dist_name=${dist_name}
  ...  parameter=${parameter_name}
  ...  skip_parameter_relation_errors=True
  ...  operation=update
  ...  value=${parameter_value}
  Sleep  60

Check Parameter Is Updated
  [Arguments]  ${parameter_value}  ${dist_name}  ${parameter_name}  ${class_name}

  Collect SCF  target_file_name=${OUT_TESTCASE_LOGS_DIR_PATH}check_commission_file.xml
  ${file_path}=  Set Variable  ${OUT_TESTCASE_LOGS_DIR_PATH}check_commission_file.xml
  ${check_parameter_value}=  Evaluate Xpath  ${file_path}
  ...  string(.//managedObject[@class="${class_name}" and @distName="${dist_name}"]/p[@name="${parameter_name}"])
  Run Keyword if
  ...  "${check_parameter_value}"=="${parameter_value}"
  ...  log
  ...  Cell Administrative State is updated successfully
  ...  ELSE
  ...  FAIL

eNB Should Be Available
  Wait Until Keyword Succeeds  60 sec  1 sec  SM Address Is Pingable  ${ENB_IP}

SM Address Is Pingable
  [Arguments]  ${ENB_IP}
  ${rc}=  Run And Return Rc  ping -c 1 ${ENB_IP}
  should be equal as integers  ${rc}  0

Cell Should Be Unblocked Without Query Infomodel Parallel
  [Arguments]  ${lcr_id}  ${timeout}=30  ${alias}=default

  admin_im.Query Infomodel
  ...  query=${INFO_MODEL_CELL_NODE_PATH}-${lcr_id} is [stateInfo.proceduralState=OnAirDone]
  ...  timeout=${timeout}
  ...  alias=${alias}
  admin_im.Query Infomodel
  ...  query=${INFO_MODEL_CELL_NODE_PATH}-${lcr_id} is [stateInfo.operationalState=Enabled]
  ...  timeout=${timeout}
  ...  alias=${alias}
  admin_im.Query Infomodel
  ...  query=${INFO_MODEL_CELL_NODE_PATH}-${lcr_id} is [stateInfo.blockingState=Unblocked]
  ...  timeout=${timeout}
  ...  alias=${alias}

Automated Siso Perform Parameter Commissioning With Object Lock Cell RaPreGrSize
  FOR  ${fr_sn}  IN  @{OUT_CURRENT_FR_SERIAL_NUMBERS}
    Set Suite Variable  ${OUT_CURRENT_FR_SERIAL_NUMBER}  ${fr_sn}
    Logging Start Infomodel  alias=${fr_sn}
    Automated Perform Parameter Commissioning With Object Lock Cell RaPreGrSize
    Info Model Disconnect  alias=${fr_sn}
  END

Automated Perform Parameter Commissioning With Object Lock Cell RaPreGrSize
  SCFC Create Cell Id List Backup  ${OUT_SCFC_CURRENT_FILE_PATH}  ${OUT_CURRENT_FR_SERIAL_NUMBER}
  ${cell_rapregrsize}=  Calculate Parameter Value Before Test
  ...  dist_name=MRBTS-${OUT_BTS_ID}/LNBTS-${OUT_BTS_ID}/LNCEL-${CELL_ID}
  ...  parameter_name=raPreGrASize
  ...  class_name=NOKLTE:LNCEL
  Set Suite Variable  ${ORIGINAL_CELL_RAPREGRSIZE}  ${cell_rapregrsize}
  Run Keyword If  "${cell_rapregrsize}"=="32"  Run Keyword  Set Suite Variable  ${CONFIG_CELL_RAPREGRSIZE}  16
  ...  ELSE  Set Suite Variable  ${CONFIG_CELL_RAPREGRSIZE}  32
  Perform Parameter Commissioning Procedure
  ...  parameter_for_btssm=LNCEL:${CELL_ID}:raPreGrASize:${CONFIG_CELL_RAPREGRSIZE}
  ...  dist_name=MRBTS-${OUT_BTS_ID}/LNBTS-${OUT_BTS_ID}/LNCEL-${CELL_ID}
  ...  parameter_name=raPreGrASize
  ...  parameter_value=${CONFIG_CELL_RAPREGRSIZE}
  Check Cell Rapregrsize Value is Updated  time=1
  Set Suite Variable  ${CONFIG_CELL_RAPREGRSIZE}  ${ORIGINAL_CELL_RAPREGRSIZE}
  Perform Parameter Commissioning Procedure
  ...  parameter_for_btssm=LNCEL:${CELL_ID}:raPreGrASize:${CONFIG_CELL_RAPREGRSIZE}
  ...  dist_name=MRBTS-${OUT_BTS_ID}/LNBTS-${OUT_BTS_ID}/LNCEL-${CELL_ID}
  ...  parameter_name=raPreGrASize
  ...  parameter_value=${CONFIG_CELL_RAPREGRSIZE}
  Check Cell Rapregrsize Value is Updated  time=2

Check Cell Rapregrsize Value is Updated
  [Arguments]  ${time}
  Save Infomodel Log
  ...  filename=${OUT_TESTCASE_LOGS_DIR_PATH}${OUT_CURRENT_FR_SERIAL_NUMBER}check_ims2
  ...  alias=${OUT_CURRENT_FR_SERIAL_NUMBER}
  Initialize ims2 validator  ${OUT_TESTCASE_LOGS_DIR_PATH}${OUT_CURRENT_FR_SERIAL_NUMBER}check_ims2.ims2
  Add expected ims2 event  reset times=0
  Add expected ims2 event
  ...  change ${INFO_MODEL_CELL_NODE_PATH}-${LCR_ID} [stateInfo.operationalState: * -> Disabled ] times=${time}
  Validate ims2
  Check Parameter Is Updated
  ...  parameter_value=${CONFIG_CELL_RAPREGRSIZE}
  ...  dist_name=MRBTS-${OUT_BTS_ID}/LNBTS-${OUT_BTS_ID}/LNCEL-${CELL_ID}
  ...  parameter_name=raPreGrASize
  ...  class_name=NOKLTE:LNCEL
  Cell Should Be Unblocked Without Query Infomodel Parallel  lcr_id=${LCR_ID}

Automated Siso Perform Parameter Commissioning With ENB Reset LNBTS Active Baseband Pooling
  ${lnbts_actbbpooling}=  Calculate Parameter Value Before Test
  ...  dist_name=MRBTS-${OUT_BTS_ID}/LNBTS-${OUT_BTS_ID}  parameter_name=actBbPooling  class_name=NOKLTE:LNBTS
  Run Keyword If  "${lnbts_actbbpooling}"=="true"  Run Keyword  Set Suite Variable  ${LNBTS_ACTBBPOOLING_FLAG}  false
  Run Keyword If  "${lnbts_actbbpooling}"=="false"  Run Keyword  Set Suite Variable  ${LNBTS_ACTBBPOOLING_FLAG}  true
  Perform Parameter Commissioning Procedure
  ...  parameter_for_btssm=LNBTS:${OUT_BTS_ID}:actBbPooling:${LNBTS_ACTBBPOOLING_FLAG}
  ...  dist_name=MRBTS-${OUT_BTS_ID}/LNBTS-${OUT_BTS_ID}
  ...  parameter_name=actBbPooling
  ...  parameter_value=${LNBTS_ACTBBPOOLING_FLAG}
  Sleep  120
  Check Lnbts Bbpooling Value is Updated  time=1
  Run Keyword If
  ...  "${LNBTS_ACTBBPOOLING_FLAG}"=="true"
  ...  Run Keyword
  ...  Set Suite Variable
  ...  ${LNBTS_ACTBBPOOLING_FLAG}
  ...  false
  ...  ELSE
  ...  Set Suite Variable
  ...  ${LNBTS_ACTBBPOOLING_FLAG}
  ...  true
  Perform Parameter Commissioning Procedure
  ...  parameter_for_btssm=LNBTS:${OUT_BTS_ID}:actBbPooling:${LNBTS_ACTBBPOOLING_FLAG}
  ...  dist_name=MRBTS-${OUT_BTS_ID}/LNBTS-${OUT_BTS_ID}
  ...  parameter_name=actBbPooling
  ...  parameter_value=${LNBTS_ACTBBPOOLING_FLAG}
  Sleep  120
  Check Lnbts Bbpooling Value is Updated  time=2

Check Lnbts Bbpooling Value is Updated
  [Arguments]  ${time}

  # Check there is eNB reset when update actBbPooling
  Save Infomodel Log  filename=${OUT_TESTCASE_LOGS_DIR_PATH}check_ims2
  Initialize ims2 validator  ${OUT_TESTCASE_LOGS_DIR_PATH}check_ims2.ims2

  Run Keyword If  "${ENB_ACTIONS_TRIGGER}" == "BTSSM"  Run Keyword  Add expected ims2 event  reset times=${time}
  Run Keyword And Continue On Failure  Validate ims2
  Check Parameter Is Updated
  ...  parameter_value=${LNBTS_ACTBBPOOLING_FLAG}
  ...  dist_name=MRBTS-${OUT_BTS_ID}/LNBTS-${OUT_BTS_ID}
  ...  parameter_name=actBbPooling
  ...  class_name=NOKLTE:LNBTS
  eNB Should Be Available

Automated Siso Perform Parameter Commissioning Without ENB Reset Cell Administrative State
  FOR  ${fr_sn}  IN  @{OUT_CURRENT_FR_SERIAL_NUMBERS}
    Set Suite Variable  ${OUT_CURRENT_FR_SERIAL_NUMBER}  ${fr_sn}
    Automated Perform Parameter Commissioning Without ENB Reset Cell Administrative State
  END

Automated Perform Parameter Commissioning Without ENB Reset Cell Administrative State
  SCFC Create Cell Id List Backup  ${OUT_SCFC_CURRENT_FILE_PATH}  ${OUT_CURRENT_FR_SERIAL_NUMBER}
  ${cell_administrative_state}=  Calculate Parameter Value Before Test
  ...  dist_name=MRBTS-${OUT_BTS_ID}/LNBTS-${OUT_BTS_ID}/LNCEL-${CELL_ID}
  ...  parameter_name=administrativeState
  ...  class_name=NOKLTE:LNCEL
  Run Keyword If
  ...  "${cell_administrative_state}"=="locked"
  ...  Run Keyword
  ...  Set Suite Variable
  ...  ${CELL_ADMINISTRATIVE_STATE_FLAG}
  ...  unlocked
  Run Keyword If
  ...  "${cell_administrative_state}"=="unlocked"
  ...  Run Keyword
  ...  Set Suite Variable
  ...  ${CELL_ADMINISTRATIVE_STATE_FLAG}
  ...  locked
  Perform Parameter Commissioning Procedure
  ...  parameter_for_btssm=LNCEL:${CELL_ID}:administrativeState:${CELL_ADMINISTRATIVE_STATE_FLAG}
  ...  dist_name=MRBTS-${OUT_BTS_ID}/LNBTS-${OUT_BTS_ID}/LNCEL-${CELL_ID}
  ...  parameter_name=administrativeState
  ...  parameter_value=${CELL_ADMINISTRATIVE_STATE_FLAG}
  Check Cell Administrative State Value is Updated
  # Recover cell administrative state to it's original value
  Run Keyword If  "${CELL_ADMINISTRATIVE_STATE_FLAG}"=="locked"  Run Keyword
  ...  Set Suite Variable  ${CELL_ADMINISTRATIVE_STATE_FLAG}  unlocked
  ...  ELSE  Set Suite Variable  ${CELL_ADMINISTRATIVE_STATE_FLAG}  locked
  Perform Parameter Commissioning Procedure
  ...  parameter_for_btssm=LNCEL:${CELL_ID}:administrativeState:${CELL_ADMINISTRATIVE_STATE_FLAG}
  ...  dist_name=MRBTS-${OUT_BTS_ID}/LNBTS-${OUT_BTS_ID}/LNCEL-${CELL_ID}
  ...  parameter_name=administrativeState
  ...  parameter_value=${CELL_ADMINISTRATIVE_STATE_FLAG}
  Check Cell Administrative State Value is Updated

Check Cell Administrative State Value is Updated
  # Check no eNB reset
  Save Infomodel Log  filename=${OUT_TESTCASE_LOGS_DIR_PATH}check_ims2
  Initialize ims2 validator  ${OUT_TESTCASE_LOGS_DIR_PATH}check_ims2.ims2
  Add expected ims2 event  reset times=0
  Validate ims2
  Check Parameter Is Updated
  ...  parameter_value=${CELL_ADMINISTRATIVE_STATE_FLAG}
  ...  dist_name=MRBTS-${OUT_BTS_ID}/LNBTS-${OUT_BTS_ID}/LNCEL-${CELL_ID}
  ...  parameter_name=administrativeState
  ...  class_name=NOKLTE:LNCEL
  admin_im.Query Infomodel
  ...  query=${INFO_MODEL_CELL_NODE_PATH}-${LCR_ID} is [stateInfo.blockingState=Unblocked]
  ...  timeout=30

Automated Siso Perform Parameter Commissioning 256QAM
  FOR  ${fr_sn}  IN  @{OUT_CURRENT_FR_SERIAL_NUMBERS}
    Set Suite Variable  ${OUT_CURRENT_FR_SERIAL_NUMBER}  ${fr_sn}
    Automated Perform Parameter Commissioning 256QAM
  END

Automated Perform Parameter Commissioning 256QAM
  # Get Testing RRH's LCR_ID based on SN list and then get Testing RRH's LNCEL_ID based on LCR_ID
  SCFC Create Cell Id List Backup  ${OUT_SCFC_CURRENT_FILE_PATH}  ${OUT_CURRENT_FR_SERIAL_NUMBER}
  # STEP1: Set Modelation Scheme as 64QAM
  Set Suite Variable  ${DL_MODULATION_SCHEME}  64QAM
  Set Suite Variable  ${CHANNEL_QUALITY_256QAM_FLAG}  false
  Perform Parameter Commissioning Procedure In Short Time
  ...  parameter_for_btssm=LNCEL:${CELL_ID}:actDl256QamChQualEst:${CHANNEL_QUALITY_256QAM_FLAG}
  ...  dist_name=MRBTS-${OUT_BTS_ID}/LNBTS-${OUT_BTS_ID}/LNCEL-${CELL_ID}
  ...  parameter_name=actDl256QamChQualEst
  ...  parameter_value=${CHANNEL_QUALITY_256QAM_FLAG}
  Perform Parameter Commissioning Procedure In Short Time
  ...  parameter_for_btssm=LNCEL:${CELL_ID}:actModulationSchemeDl:${DL_MODULATION_SCHEME}
  ...  dist_name=MRBTS-${OUT_BTS_ID}/LNBTS-${OUT_BTS_ID}/LNCEL-${CELL_ID}
  ...  parameter_name=actModulationSchemeDl
  ...  parameter_value=${DL_MODULATION_SCHEME}
  Check Modulation Scheme Value is Updated
  # STEP2: Set Modelation Scheme as 256QAM
  Set Suite Variable  ${DL_MODULATION_SCHEME}  256QAM
  Set Suite Variable  ${CHANNEL_QUALITY_256QAM_FLAG}  true
  Perform Parameter Commissioning Procedure In Short Time
  ...  parameter_for_btssm=LNCEL:${CELL_ID}:actDl256QamChQualEst:${CHANNEL_QUALITY_256QAM_FLAG}
  ...  dist_name=MRBTS-${OUT_BTS_ID}/LNBTS-${OUT_BTS_ID}/LNCEL-${CELL_ID}
  ...  parameter_name=actDl256QamChQualEst
  ...  parameter_value=${CHANNEL_QUALITY_256QAM_FLAG}
  Perform Parameter Commissioning Procedure In Short Time
  ...  parameter_for_btssm=LNCEL:${CELL_ID}:actModulationSchemeDl:${DL_MODULATION_SCHEME}
  ...  dist_name=MRBTS-${OUT_BTS_ID}/LNBTS-${OUT_BTS_ID}/LNCEL-${CELL_ID}
  ...  parameter_name=actModulationSchemeDl
  ...  parameter_value=${DL_MODULATION_SCHEME}
  Check Modulation Scheme Value is Updated

Check Modulation Scheme Value is Updated
  # Check no eNB reset
  Save Infomodel Log  filename=${OUT_TESTCASE_LOGS_DIR_PATH}check_ims2
  Initialize ims2 validator  ${OUT_TESTCASE_LOGS_DIR_PATH}check_ims2.ims2
  Add expected ims2 event  reset times=0
  Validate ims2
  Check Parameter Is Updated
  ...  parameter_value=${CHANNEL_QUALITY_256QAM_FLAG}
  ...  dist_name=MRBTS-${OUT_BTS_ID}/LNBTS-${OUT_BTS_ID}/LNCEL-${CELL_ID}
  ...  parameter_name=actDl256QamChQualEst
  ...  class_name=NOKLTE:LNCEL
  Check Parameter Is Updated
  ...  parameter_value=${DL_MODULATION_SCHEME}
  ...  dist_name=MRBTS-${OUT_BTS_ID}/LNBTS-${OUT_BTS_ID}/LNCEL-${CELL_ID}
  ...  parameter_name=actModulationSchemeDl
  ...  class_name=NOKLTE:LNCEL
  Sleep  10
  # Check cell is on air
  Cell Should Be Unblocked Without Query Infomodel Parallel  lcr_id=${LCR_ID}

Perform Parameter Commissioning Procedure In Short Time
  [Arguments]  ${parameter_for_btssm}  ${dist_name}  ${parameter_name}  ${parameter_value}

  # Recommission the parameter
  Run Keyword If  "${ENB_ACTIONS_TRIGGER}" == "BTSSM"  Run Keyword
  ...  Perform Parameter Commissioning  parameter=${parameter_for_btssm}
  Run Keyword If  "${ENB_ACTIONS_TRIGGER}" == "ADMIN"  Run Keyword
  ...  Perform Parameter Recommissioning
  ...  dist_name=${dist_name}
  ...  parameter=${parameter_name}
  ...  skip_parameter_relation_errors=True
  ...  operation=update
  ...  value=${parameter_value}
  # No eNB or cell reset procedure, use less time to wait paramter update. 60s is enough, not need 300s.
  Sleep  60
