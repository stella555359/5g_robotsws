*** Settings ***
Documentation
...  Author:
...  Maintainer:  piotr.korczynski@nokia.com

Library  Collections
Library  OperatingSystem
Library  Process
Library  robot.libraries.DateTime
Library  SSHLibrary
Library  String
#Library  ta_kiss_files

Library  ../rf_alarms_operations.py
Library  ../operations.py
#Resource  ../../../../../../../resources/WMP/GVe/Wroclaw/bts_scfc.robot


*** Keywords ***
Automated_SiSo_Fault_Managament_PIMc_Alarm_Trigerring_on_RF_module
  [Documentation]
  ...  Purpose of this test is checking if RET unit is correctly detected
  ...
  ...  Parameters:
  ...  Name  |  Mandatory  |  Default value  |  Description
  ...  test_logs_path  |  no  |  cfg.test_logs_path  |  Path to test logs
  ...
  Common Test Setup
  Logging With Timestamp
  ...  message=Automated_SiSo_Fault_Managament_PIMc_Alarm_Trigerring_on_RF_module
  ...  style=ONGOING
  SiSo_Fault_Managament_PIMc_Alarm_Trigerring_on_RF_module
  [Teardown]    Common Test Teardown


Automated__SiSo_Fault_Managament_PIMc_enabling_on_unsupported_radio_module
  [Documentation]
  ...  Purpose of this test is checking if RET unit is correctly detected
  ...
  ...  Parameters:
  ...  Name  |  Mandatory  |  Default value  |  Description
  ...  test_logs_path  |  no  |  cfg.test_logs_path  |  Path to test logs
  Common Test Setup
  Logging With Timestamp
  ...  message=Automated__SiSo_Fault_Managament_PIMc_enabling_on_unsupported_radio_module
  ...  style=ONGOING
  SiSo_Fault_Managament_PIMc_enabling_on_unsupported_radio_module
  [Teardown]    Common Test Teardown


SiSo_Fault_Managament_PIMc_enabling_on_unsupported_radio_module
  [Arguments]  ${test_logs_path}=${cfg.test_logs_path}
  [Documentation]  User needs to provide global variable with FID for unsupported PIMC on tested radio.
  ...  Currently 2901/2902 where selected for usage. Before TC execution add correct FID.
  ${unsupported_fault_exist}=  Run Keyword And Return Status  Should Not Be Empty  ${UNSUPPORTED_FID}
  Run Keyword If
  ...  not ${unsupported_fault_exist}
  ...  Fail
  ...  User should provide FID for unsupported PIMC depending on Radio Unit
  Create CS PIMc Unsported Radio Related Variables For RFV
  admin.Perform Delta Recommissioning  ${SCFC_WITH_PIMC_FILE_PATH}  alias=${TC_ALIAS}
  Set To Dictionary  ${ALARMS['fr_under_test_and_related']}  im_alarm_list=@{EMPTY}
  Wait For Alarms And Check PIMc Unsupported Radio Unit  ${UNSUPPORTED_FID}
  Sleep  180s  Waiting for stabilization before commissining to avoid "Cplane is busy"
  Verify Alarms On All Nodes
  Run Keyword If  "${ALARM_state}"=="FAIL"  Fail  Alarms Check failed.
  Perform Commissioning From File  ${SCFC_REFERENCE_FILE_PATH}  alias=${TC_ALIAS}
  Verify Multi BTS State
  ${inactve_2901}=  Run Keyword And Return Status  admin.Assert Alarm Inactive
  ...  faultId=${UNSUPPORTED_FID}
  ...  timeout=90
  ...  connection=${TC_ALIAS}
  Run Keyword If  not ${inactve_2901}  Run Keywords
  ...  Log To Console  FaultID 2901 not cleared, fail.
  ...  AND  Fail  FaultID 2901 not cleared, fail.
  [Teardown]  Run Keyword If  '${KEYWORD STATUS}'=='FAIL'  Perform Commissioning From File  ${SCFC_REFERENCE_FILE_PATH}  alias=${TC_ALIAS}

SiSo_Fault_Managament_PIMc_Alarm_Trigerring_on_RF_module
  Create CS PIMc Related Variables For RFV
  Generate Minor PIMc Alarm
  Reset RFM While Minor PIMc Alarm Is Active
  Generate Minor And Major PIMc Alarm
  Cancel PIMc Alarms
  [Teardown]  Run Keyword If  '${KEYWORD STATUS}'!= 'PASS'  Set PIMC Alarm Thresholds  minor=-31  major=-30

Create CS PIMc Related Variables For RFV
  [Arguments]
  Set Library Search Order    PIMC_cs
  ${ru_bts_id}  ${ru_dist_name}=  Get RU Node Data  ${CUSTOM_RADIO_UNIT_LIST[0]}
  Verify Unexpected And Historical Alarms
  ...  alias=${ru_bts_id}

  Set Test Variable  ${BTS_ID}  ${ru_bts_id}
  Set Test Variable  ${scfc_file_path}  ${CFG['NODES']['${ru_bts_id}']['scf_file_path']}
  Set Test Variable  ${SCFC_REFERENCE_FILE_PATH}  ${CFG['NODES']['${ru_bts_id}']['scf_file_path']}
  Set Test Variable  ${FR_UNDER_TEST_SERIAL_NUMBER}  ${CUSTOM_RADIO_UNIT_LIST[0]}
  Set Test Variable  ${TC_ALIAS}  ${ru_bts_id}
  ${act_category_alarms}=  Get From Dictionary  ${cfg.NODES['${BTS_ID}']}  alarms_category
  Set Test Variable  ${ACT_CATEGORY_ALARMS}  ${act_category_alarms}
  Optimized RF Variant Preparation  alias=${ru_bts_id}
  Set Alarm Information Dictionary  ${FR_UNDER_TEST_SERIAL_NUMBER}  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}


  Get Cells That Can Be Affected By PIMC  ${SCFC_REFERENCE_FILE_PATH}  ${FR_UNDER_TEST_SERIAL_NUMBER}
  Commission PIMC Parameters  ${SCFC_REFERENCE_FILE_PATH}  ${FR_UNDER_TEST_SERIAL_NUMBER}  ${ru_bts_id}
  Wait Until PIMC Feature Is Activated On RMOD
  ${scfc_with_pimc}=  Create SCFC File With Activated PIMC For FR Serial Number
  Set Test Variable  ${SCFC_WITH_PIMC_FILE_PATH}  ${scfc_with_pimc}


Create CS PIMc Unsported Radio Related Variables For RFV
  [Arguments]
  ${ru_bts_id}  ${ru_dist_name}=  Get RU Node Data  ${CUSTOM_RADIO_UNIT_LIST[0]}
  Verify Unexpected And Historical Alarms
  ...  alias=${ru_bts_id}

  Set Test Variable  ${BTS_ID}  ${ru_bts_id}
  Set Test Variable  ${scfc_file_path}  ${CFG['NODES']['${ru_bts_id}']['scf_file_path']}
  Set Test Variable  ${SCFC_REFERENCE_FILE_PATH}  ${CFG['NODES']['${ru_bts_id}']['scf_file_path']}
  Set Test Variable  ${FR_UNDER_TEST_SERIAL_NUMBER}  ${CUSTOM_RADIO_UNIT_LIST[0]}
  Set Test Variable  ${TC_ALIAS}  ${ru_bts_id}
  ${act_category_alarms}=  Get From Dictionary  ${cfg.NODES['${BTS_ID}']}  alarms_category
  Set Test Variable  ${ACT_CATEGORY_ALARMS}  ${act_category_alarms}
  Optimized RF Variant Preparation  alias=${ru_bts_id}
  Set Alarm Information Dictionary  ${FR_UNDER_TEST_SERIAL_NUMBER}  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
  Set Cell Information Dictionary
  ...  lncel_id_list=${cfg.RF_INFO['${FR_UNDER_TEST_SERIAL_NUMBER}']['LNCEL']['scf_cellid_primary']}
  ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
  ...  alias=${ru_bts_id}


  ${scfc_with_pimc}=  Create SCFC File With Activated PIMC For FR Serial Number
  Set Test Variable  ${SCFC_WITH_PIMC_FILE_PATH}  ${scfc_with_pimc}


Generate Minor PIMc Alarm
  Log To Console  > Step 1 - Generate Minor PIMc Alarm
  Set PIMC Alarm Thresholds  minor=-180  major=-30
  Wait For Alarms And Check  1999  antenna_alarm=TXRX  cell_list=${CELLS_AFFECTED_BY_PIMC}
  FR Should Reach OnAir  fr_serial_number=${FR_UNDER_TEST_SERIAL_NUMBER}
  ...  fr_lncel_id_list=${cfg.RF_INFO['${FR_UNDER_TEST_SERIAL_NUMBER}']['LNCEL']['scf_cellid_primary']}
  ...  alias=${TC_ALIAS}

Reset RFM While Minor PIMc Alarm Is Active
  Log To Console  > Step 2 - Reset RFM
  HW Unit Reset  ${FR_UNDER_TEST_SERIAL_NUMBER}
  ...  alias=${TC_ALIAS}
  Wait For Alarms And Check  1999  antenna_alarm=TXRX  cell_list=${CELLS_AFFECTED_BY_PIMC}
  FR Should Reach OnAir  fr_serial_number=${FR_UNDER_TEST_SERIAL_NUMBER}
  ...  fr_lncel_id_list=${cfg.RF_INFO['${FR_UNDER_TEST_SERIAL_NUMBER}']['LNCEL']['scf_cellid_primary']}
  ...  alias=${TC_ALIAS}

Generate Minor And Major PIMc Alarm
  Log To Console  > Step 3 - Generate Minor And Major PIMc Alarm
  Set PIMC Alarm Thresholds  minor=-180  major=-179
  Wait For Alarms And Check  1999 2900  antenna_alarm=TXRX  cell_list=${CELLS_AFFECTED_BY_PIMC}


Cancel PIMc Alarms
  Log To Console  > Step 4 - Cancel PIMc Alarms
  Set PIMC Alarm Thresholds  minor=-31  major=-30
  admin.Assert Alarm Inactive  faultId=regex"1999|2900"
  ...  timeout=600
  ...  alias=${TC_ALIAS}
  FR Should Reach OnAir  fr_serial_number=${FR_UNDER_TEST_SERIAL_NUMBER}
  ...  fr_lncel_id_list=${cfg.RF_INFO['${FR_UNDER_TEST_SERIAL_NUMBER}']['LNCEL']['scf_cellid_primary']}
  ...  alias=${TC_ALIAS}
  Mandatory And Allowed Alarms Should Be As Expected
  ...  mandatory=${ALARMS['fr_under_test_and_related']['im_alarm_list']}
  ...  alias=${TC_ALIAS}
  Verify Unexpected And Historical Alarms
  ...  alias=${TC_ALIAS}


Set PIMC Alarm Thresholds
  [Arguments]  ${scfc_file_path}=${SCFC_REFERENCE_FILE_PATH}  ${fr_serial_number}=${FR_UNDER_TEST_SERIAL_NUMBER}
  ...  ${log_dir_path}=${TEST_LOGS_DIR_PATH}  ${minor}=-31  ${major}=-30  ${alias}=${TC_ALIAS}
  Log To Console  Performimng delta commissioning to set PIMC MINOR threshold to ${minor} and MAJOR to ${major}
  ${rmod_id}=  SCFC Get RmodId For FR Serial Number  ${scfc_file_path}  ${fr_serial_number}
    ${object_1}=  Set Variable  .//managedObject[substring(@distName, string-length(@distName) - string-length(${rmod_id}) + 1) = '${rmod_id}']
    ${object_2}=  Set Variable  [p[@name='pimCancellingEnabled']]/@distName
    ${sum_object}=  Set Variable  ${object_1}${object_2}
  ${rmod_dn}=  Evaluate Xpath
  ...  ${scfc_file_path}
  ...  ${sum_object}
  ${rmod_dn}=  Convert To String  ${rmod_dn[0]}
  admin.Create Delta
  admin.Append Parameter Update To Delta  ${rmod_dn}  intPIMLevelMeasurementMajorThreshold  ${major}
  admin.Append Parameter Update To Delta  ${rmod_dn}  intPIMLevelMeasurementMinorThreshold  ${minor}
  Create Directory  ${log_dir_path}/PIMC/
  admin.Save Delta  ${log_dir_path}/PIMC/minor_${minor}_major_${major}_delta.json
  admin.Perform Delta Recommissioning  ${log_dir_path}/PIMC/minor_${minor}_major_${major}_delta.json
  ...  skip_parameter_relation_errors=True
  ...  alias=${alias}
  [Teardown]  Teardown Delta Recommissioning  ${KEYWORD_STATUS}

Activate PIMC For FR Serial Number
  [Arguments]  ${scfc_file_path}=${SCFC_REFERENCE_FILE_PATH}  ${fr_serial_number}=${FR_UNDER_TEST_SERIAL_NUMBER}
  ...  ${fr_cell_list}=${cfg.RF_INFO['${FR_UNDER_TEST_SERIAL_NUMBER}']['LNCEL']['scf_cellid_primary']}
  ...  ${log_dir_path}=${TEST_LOGS_DIR_PATH}  ${alias}=${TC_ALIAS}
  Log To Console  Performimng delta commissioning to activate PIMC for ${fr_serial_number}
  ${rmod_id}=  SCFC Get RmodId For FR Serial Number  ${scfc_file_path}  ${fr_serial_number}
    ${object_1}=  Set Variable  .//managedObject[substring(@distName, string-length(@distName) - string-length(${rmod_id}) + 1) = '${rmod_id}']
    ${object_2}=  Set Variable  [p[@name='pimCancellingEnabled']]/@distName
    ${sum_object}=  Set Variable  ${object_1}${object_2}
  ${rmod_dn}=  Evaluate Xpath
  ...  ${scfc_file_path}
  ...  ${sum_object}
  ${rmod_dn}=  Convert To String  ${rmod_dn[0]}
  admin.Create Delta
  Run Keyword If  '${cfg.RF_INFO['${FR_UNDER_TEST_SERIAL_NUMBER}']['scf_variant']}' == 'AHPMDA'
  ...  admin.Append Parameter Update To Delta  ${rmod_dn}  pimDiplexerModeEnabled  true
  admin.Append Parameter Update To Delta  ${rmod_dn}  pimCancellingEnabled  true
  admin.Append Parameter Update To Delta  ${rmod_dn}  actPimCancellation  true
  admin.Append Parameter Update To Delta  ${rmod_dn}  intPIMLevelMeasurementMajorThreshold  -30
  admin.Append Parameter Update To Delta  ${rmod_dn}  intPIMLevelMeasurementMinorThreshold  -31
  FOR  ${lcr_id}  IN  @{fr_cell_list}
    ${cell_dn}=  SCFC Get DistName For LcrId  ${scfc_file_path}  ${lcr_id}
    ${cell_dn}=  Convert To String  ${cell_dn}
    admin.Append Parameter Update To Delta  ${cell_dn}  dlInterferenceEnable  true
    admin.Append Parameter Update To Delta  ${cell_dn}  dlInterferenceLevel  100
  END
  Create Directory  ${log_dir_path}/PIMC/
  admin.Save Delta  ${log_dir_path}/PIMC/activate_PIMC.json
  admin.Perform Delta Recommissioning  ${log_dir_path}/PIMC/activate_PIMC.json
  ...  skip_parameter_relation_errors=True
  ...  alias=${alias}
  [Teardown]  Teardown Delta Recommissioning  ${KEYWORD_STATUS}

Activate 1dB Fault Pipe Overheating Parameter
  [Arguments]  ${scfc_file_path}=${SCFC_REFERENCE_FILE_PATH}  ${fr_serial_number}=${FR_UNDER_TEST_SERIAL_NUMBER}
  ...  ${log_dir_path}=${TEST_LOGS_DIR_PATH}  ${alias}=${TC_ALIAS}
  Log To Console  Performimng delta commissioning to activate 1dB power reduction fault
  ${fmcadm_dn}=  Evaluate Xpath  ${scfc_file_path}  .//managedObject[contains(@class, "FMCADM")]/@distName
  ${fmcadm_dn}=  Convert To String  ${fmcadm_dn[0]}
  Create Delta
  Append Parameter Update To Delta  ${fmcadm_dn}  actPipePowerDecreased1dBFaults  true
  Create Directory  ${log_dir_path}/Pipe_Overheating/
  Save Delta  ${log_dir_path}/Pipe_Overheating/delta.json
  Perform Delta Recommissioning  ${log_dir_path}/Pipe_Overheating/delta.json
  ...  skip_parameter_relation_errors=True
  ...  alias=${alias}
  [Teardown]  Teardown Delta Recommissioning  ${KEYWORD_STATUS}

Backup Files
  [Arguments]  ${files_path}  ${files}=*
  ${files}=  Run Keyword If  "${files}"=="*"  List Files In Directory  ${files_path}
  ...  ELSE  Set Variable  ${files}
  FOR  ${file}  IN  @{files}
    Copy File  ${files_path}${file}  ${files_path}/ORIGINAL_${file}
  END

Wait Until PIMC Feature Is Activated On RMOD
  [Arguments]  ${timeout}=60  ${check_adaptation_attempts}=False
  Wait Until Keyword Succeeds
  ...  ${timeout}
  ...  5
  ...  PIMC Feature Should Be Activated On RMOD
  ...  check_adaptation_attempts=${check_adaptation_attempts}
  admin.Assert Alarm Inactive  faultId=regex"1999|2900"
  ...  timeout=600
  ...  alias=${TC_ALIAS}
  [Teardown]  Run Keyword If  "${KEYWORD_STATUS}"=="FAIL"  Log
  ...  PIMC has not been activated on RMOD. Check if your EARFCN on TX's can create Passive InterModulation on RX!  ERROR

PIMC Feature Should Be Activated On RMOD
  [Arguments]  ${check_adaptation_attempts}=False
  Open Connection To Radio Module With Serial Number
  ...  rmod_serial_number=${FR_UNDER_TEST_SERIAL_NUMBER}
  ...  alias=${TC_ALIAS}
  ${output}=  Send Command and return output
  ...  command=pimc -stat
  ...  prompt=~#
  Run Keyword If  ${check_adaptation_attempts}  Should Match Regexp  ${output}  adaptationAttempts = [1-9]
  Should Contain  ${output}  state = running
  ...  msg=${output} should have at least one state = running!

Wait For Alarms And Check PIMc Unsupported Radio Unit
  [Arguments]  ${fault_ids}  ${fr_serial_number_list}=${FR_UNDER_TEST_SERIAL_NUMBER}  ${cell_list}=${EMPTY}
  ...  ${antenna_alarm}=False  ${timeout}=600  ${alias}=${TC_ALIAS}  ${verbose}=True
  [Documentation]  ${fault_ids} can be a list or a string of fault id's separated with spaces.
  ${input_type}=  Evaluate  type($fault_ids).__name__
  ${fault_id_list}=  Run Keyword If  "${input_type}"!="list"  Split String  ${fault_ids}
  ...  ELSE  Set Variable  ${fault_ids}
  ${mandatory}=  Copy List  ${ALARMS['fr_under_test_and_related']['im_alarm_list']}
  FOR  ${fault_id}  IN  @{fault_id_list}
    Log  Waiting for fault ${fault_id}  console=${verbose}
    ${ant_mandatory}=  Create Mandatory Alarms List FV  ${ENB_MANAGER}
  ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
  ...  fr_serial_number_list=${fr_serial_number_list}
  ...  fault_scheme=${FAULT_${fault_id}_SCHEME}
  ...  act_category_alarms=${ACT_CATEGORY_ALARMS}
  ...  lcr_id_list=${cell_list}
  ...  antenna_alarm=${antenna_alarm}
    ${mandatory}=  Combine Lists  ${ant_mandatory}  ${mandatory}
    ${fault_count}=  Get Length  ${ant_mandatory}
    Info Model Wait For Alarm  fault_id=${fault_id}
  ...  fault_count=${fault_count}
  ...  timeout=${timeout}
  ...  act_category_alarms=${ACT_CATEGORY_ALARMS}
  ...  alias=${alias}
  END
  ${tmp_alarm_list}=  Create List
  FOR  ${id}  IN  @{fault_id_list}
    Append To List  ${tmp_alarm_list}  faultId=${id}
  END
  ${GLO_ADMIN_ALLOWED_ALARMS}=  Combine Lists  ${GLO_ADMIN_ALLOWED_ALARMS}  ${tmp_alarm_list}
  Set Test Variable  ${GLO_ADMIN_ALLOWED_ALARMS}  ${GLO_ADMIN_ALLOWED_ALARMS}
  [Teardown]  Run Keyword If  "${KEYWORD_STATUS}"=="PASS"
  ...  Log  All alarms raised as expected  console=${verbose}
  ...  ELSE  Log  Alarms NOT as expected  console=${verbose}

Wait For Alarms And Check
  [Arguments]  ${fault_ids}  ${fr_serial_number_list}=${FR_UNDER_TEST_SERIAL_NUMBER}  ${cell_list}=${EMPTY}
  ...  ${antenna_alarm}=False  ${timeout}=600  ${alias}=${TC_ALIAS}  ${verbose}=True
  [Documentation]  ${fault_ids} can be a list or a string of fault id's separated with spaces.
  ${input_type}=  Evaluate  type($fault_ids).__name__
  ${fault_id_list}=  Run Keyword If  "${input_type}"!="list"  Split String  ${fault_ids}
  ...  ELSE  Set Variable  ${fault_ids}
  ${mandatory}=  Copy List  ${ALARMS['fr_under_test_and_related']['im_alarm_list']}
  FOR  ${fault_id}  IN  @{fault_id_list}
    Log  Waiting for fault ${fault_id}  console=${verbose}
    ${ant_mandatory}=  Create Mandatory Alarms List FV  ${ENB_MANAGER}
  ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
  ...  fr_serial_number_list=${fr_serial_number_list}
  ...  fault_scheme=${FAULT_${fault_id}_SCHEME}
  ...  act_category_alarms=${ACT_CATEGORY_ALARMS}
  ...  lcr_id_list=${cell_list}
  ...  antenna_alarm=${antenna_alarm}
    ${mandatory}=  Combine Lists  ${ant_mandatory}  ${mandatory}
    ${fault_count}=  Get Length  ${ant_mandatory}
    Info Model Wait For Alarm  fault_id=${fault_id}
  ...  fault_count=${fault_count}
  ...  timeout=${timeout}
  ...  act_category_alarms=${ACT_CATEGORY_ALARMS}
  ...  alias=${alias}
  END
  Info Model Wait For Alarm  fault_id=10
  ...  fault_count=${ALARMS['fr_under_test_and_related']['fault_10_count']}
  ...  timeout=${FAULT_10_TIMEOUT}
  ...  act_category_alarms=${ACT_CATEGORY_ALARMS}
  ...  alias=${TC_ALIAS}
  Mandatory And Allowed Alarms Should Be As Expected
  ...  mandatory=${mandatory}
  ...  alias=${alias}
  ${tmp_alarm_list}=  Create List
  FOR  ${id}  IN  @{fault_id_list}
    Append To List  ${tmp_alarm_list}  faultId=${id}
  END
  ${GLO_ADMIN_ALLOWED_ALARMS}=  Combine Lists  ${GLO_ADMIN_ALLOWED_ALARMS}  ${tmp_alarm_list}
  Set Test Variable  ${GLO_ADMIN_ALLOWED_ALARMS}  ${GLO_ADMIN_ALLOWED_ALARMS}
  [Teardown]  Run Keyword If  "${KEYWORD_STATUS}"=="PASS"
  ...  Log  All alarms raised as expected  console=${verbose}
  ...  ELSE  Log  Alarms NOT as expected  console=${verbose}

Check If Fault 1972 Should Appear
  [Arguments]  ${fr_serial_number}=${FR_UNDER_TEST_SERIAL_NUMBER}  ${alias}=${TC_ALIAS}
  Return From Keyword If  '${SW_RELEASE}'=='SBTS20A'
  ...  False
  ${fr_release}=  Info Model Get RF Radio Module Release  ${fr_serial_number}  ${alias}
  Return From Keyword If  '${fr_release}' not in ${1972_SUPP_RELEASE}
  ...  False
  Return From Keyword If
  ...  '${cfg.RF_INFO['${FR_UNDER_TEST_SERIAL_NUMBER}']['scf_variant']}' in ${1972_RF_EXCEPTION_LIST}
  ...  False
  ${rf_variant}=  Evaluate    ${cfg.RF_INFO['${FR_UNDER_TEST_SERIAL_NUMBER}']['scf_variant']}
  Return From Keyword If
  ...  '${rf_variant}' in ${1972_RF_TDD_LIST} and int('${fr_serial_number[2:4]}')<18 and int('${fr_serial_number[4:6]}')<31
  ...  False
  ${1972_on}=  Set Variable  True
  [Return]  ${1972_on}

Setup Fault 1937
  [Arguments]  ${fr_serial_number}=${FR_UNDER_TEST_SERIAL_NUMBER}
  ...  ${scfc_file_path}=${SCFC_REFERENCE_FILE_PATH}
  ...  ${act_category_alarms}=${ACT_CATEGORY_ALARMS}
  ${enb_alarms_fault_1972_fr_under_test}=  Create Mandatory Alarms List FV  ${ENB_MANAGER}
  ...  scfc_file_path=${scfc_file_path}
  ...  fr_serial_number_list=${fr_serial_number}
  ...  fault_scheme=${FAULT_1972_SCHEME}
  ...  act_category_alarms=${act_category_alarms}
  ${im_alarms_fault_1972_fr_under_test}=  Create Mandatory Alarms List FV  Info Model
  ...  scfc_file_path=${scfc_file_path}
  ...  fr_serial_number_list=${fr_serial_number}
  ...  fault_scheme=${FAULT_1972_SCHEME}
  ...  act_category_alarms=${act_category_alarms}
  ${fault_1972_count}=  Get Length  ${im_alarms_fault_1972_fr_under_test}
  ${infomodel_mandatory_alarms_under_test}=  Combine Lists
  ...  ${im_alarms_fault_1972_fr_under_test}
  ...  ${ALARMS['fr_related']['im_alarm_list']}
  ${btssm_mandatory_alarms_under_test}=  Combine Lists
  ...  ${enb_alarms_fault_1972_fr_under_test}
  ...  ${ALARMS['fr_related']['enb_mng_alarm_list']}
  [Return]  ${infomodel_mandatory_alarms_under_test}  ${btssm_mandatory_alarms_under_test}  ${fault_1972_count}

Set Fault 1972 Variables
  [Arguments]  ${infomodel_mandatory_alarms_under_test}  ${btssm_mandatory_alarms_under_test}  ${fault_1972_count}
  Set Test Variable  ${ALARMS['fr_related']['im_alarm_list']}  ${infomodel_mandatory_alarms_under_test}
  Set Test Variable  ${ALARMS['fr_related']['enb_mng_alarm_list']}  ${btssm_mandatory_alarms_under_test}
  Set Test Variable  ${FAULT_1972_COUNT}  ${fault_1972_count}

HW Unit Reset
  [Arguments]  ${serial_number}  ${timeout}=300  ${verbose}=true  ${alias}=default
  [Documentation]  Supported HW:  RMOD, FHS
  Log  Performing ${serial_number} unit reset.  console=${verbose}
  ${rmod_l_dn}=  Info Model Get HW Distname  ${serial_number}  alias=${alias}
  ${rmod_r_ref}=  admin_im.Query Infomodel  query=get object //APEQM_R-1//REF-1 is [distName="${rmod_l_dn}"]  alias=${alias}
  ${rmod_r_dn}=  Replace String Using Regexp  ${rmod_r_ref.dist_name}  /REF-1$  ${EMPTY}
  admin.Reset Unit
  ...  dist_name=${rmod_r_dn}
  ...  reset_type=Hard
  ...  timeout=${timeout}
  ...  alias=${alias}

FR Should Reach OnAir
  [Arguments]  ${fr_serial_number}  ${fr_lncel_id_list}=${cfg.RF_INFO['${fr_serial_number}']['LNCEL']['scf_cellid_primary']}
  ...  ${verbose}=false  ${alias}=default
  Run Keyword If  not ${fr_lncel_id_list}  Run Keywords
  ...  Log  No cells to check onAir!  ERROR  AND
  ...  Return From Keyword
  Log  Waiting for FR to reach onAir  console=${verbose}
#  ${timeout}=  Get FR OnAir Timeout  ${fr_serial_number}  alias=${alias}
  ${cells}=  Convert To String  ${fr_lncel_id_list}
  ${cells}=  Remove String  ${cells}  '  u  ${SPACE}
  admin_im.Query Infomodel Parallel
  ...  query1=//LNCEL_R-${cells} is [stateInfo.availabilityStatus=regex"(?i)Online"]
  ...  query2=//LNCEL_R-${cells} is [availabilityStatus=regex"(?i)None"]
  ...  timeout=150
  ...  alias=${alias}
  ...  assertion_method=any
  admin_im.Query Infomodel Parallel
  ...  query1=every //LNCEL_R-${cells} is [stateInfo.availabilityStatus=regex"(?i)Online"]
  ...  query2=every //LNCEL_R-${cells} is [availabilityStatus=regex"(?i)None"]
  ...  timeout=300
  ...  alias=${alias}
  ...  assertion_method=any
  Log  OnAir done  console=${verbose}

Create Mandatory Alarms List FV
  [Arguments]  ${tool}  ${scfc_file_path}  ${fr_serial_number_list}  ${fault_scheme}
  ...  ${act_category_alarms}=False  ${lcr_id_list}=${EMPTY}  ${antenna_alarm}=False
  [Documentation]  Keyword creates list of mandatory alarms for defined lncelId list and fault scheme.
  ...  Mandatory arguments:
  ...  tool - Info Model, ADMIN or BTSSM
  ...  scfc_file_path - example: /home/ute/robotlte/config/Wroclaw/1_16_CLOUD3822/node1/BTS_CLOUD_RF_FCC_CRT_16_CHM_12_FL18SP.xml
  ...  fr_serial_number_list - pretty self explanatory argument
  ...  fault_scheme - dictionary with optional alarmDetail, faultId, alarmSeverity keys.
  ...  At least one key/value pair other than distName or impactedCells key has to be defined
  ...  (regex is supported in dictionary values)
  @{mandatory_alarms_list}=  Create List
  ${fr_serial_number_list}=  Convert Item To Single Element List  ${fr_serial_number_list}
  ${fault_scheme_tmp}=  Evaluate  ${fault_scheme}
  FOR  ${fr_serial_number}  IN  @{fr_serial_number_list}
    ${alarm_list_for_rmod}=  Run keyword if  '2900' not in '${fault_scheme_tmp['faultId']}'
  ...  Create Mandatory Alarms For RMOD
  ...  ${tool}  ${scfc_file_path}  ${fr_serial_number}  ${fault_scheme}
  ...  ${act_category_alarms}  ${lcr_id_list}  ${antenna_alarm}
  ...  ELSE
  ...  Create Mandatory Alarms For AntennaLine
  ...  ${tool}  ${scfc_file_path}  ${fr_serial_number}  ${fault_scheme}
  ...  ${act_category_alarms}  ${lcr_id_list}  ${antenna_alarm}
    ${mandatory_alarms_list}=  Combine Lists  ${mandatory_alarms_list}  ${alarm_list_for_rmod}
  END
  [Return]  ${mandatory_alarms_list}

Mandatory And Allowed Alarms Should Be As Expected
  [Arguments]
  ...  ${mandatory}=${EMPTY}
  ...  ${btssm_mandatory}=${EMPTY}
  ...  ${allowed}=@{EMPTY}
  ...  ${btssm_alarms_file_name}=BtsSmAlarms.xml
  ...  ${alias}=default
  ${allowed}=  Combine Lists  ${GLO_ALLOWED_ALARMS}  ${allowed}
  Run Keyword And Continue On Failure
  ...  Info Model Alarms Get And Check
  ...  allowed=${allowed}
  ...  mandatory=${mandatory}
  ...  alias=${alias}
  Sleep  2  # WORKAROUND TO BAD ADMIN TIMESTAMPS PR313277
  Run Keyword And Continue On Failure
  ...  Admin Alarms Get And Check  allowed=${allowed}  mandatory=${mandatory}  alias=${alias}

Create Mandatory Alarms For AntennaLine
  [Arguments]  ${tool}  ${scfc_file_path}  ${fr_serial_number}  ${fault_scheme}
  ...  ${act_category_alarms}=False  ${lcr_id_list}=${EMPTY}  ${antenna_alarm}=False
  ${fault_scheme}=  Evaluate  ${fault_scheme}
  ${lcr_id_list}=  Set Variable If  "${lcr_id_list}" is "${EMPTY}"
  ...  ${cfg.RF_INFO['${fr_serial_number}']['LNCEL']['scf_cellid_primary']}  ${lcr_id_list}
  # WORKAROUND FOR IOT CELLS!!!!
  ${all_legacy_standalone_cell_count}=  Set Variable  ${ALL_CELLS_COUNT}
  ${tmp_lcr_id_list}=  Copy List  ${lcr_id_list}
  FOR  ${lcr_id}  IN  @{lcr_id_list}
    ${object_1}=  Set Variable  "${CFG['NODES']['${BTS_ID}']['LNCEL']['${lcr_id}']['scf_type']}"!="legacy"
    ${object_2}=  Set Variable  "${CFG['NODES']['${BTS_ID}']['LNCEL']['${lcr_id}']['scf_type']}"!="standalone"
    ${sum_object}=  Evaluate    ${object_1} and ${object_2}
       Run Keyword If  ${sum_object}
  ...  Remove Values From List
  ...  ${tmp_lcr_id_list}
  ...  ${lcr_id}
  ...  ${all_legacy_standalone_cell_count}=
       Run Keyword If   ${sum_object}
  ...  Evaluate
  ...  ${all_legacy_standalone_cell_count}-1
  ...  ELSE
  ...  Set Variable
  ...  ${all_legacy_standalone_cell_count}
  END
  ${lcr_id_list}=  Copy List  ${tmp_lcr_id_list}
  ${attribute_name}=  Set Attribute Name In Mandatory Alarms  ${tool}  ${act_category_alarms}
  ${cell_antennas}=  Create Dictionary
  FOR  ${lcr_id}  IN  @{lcr_id_list}
    ${lcr_id}=  Convert To String  ${lcr_id}
    ${antennas}=  SCFC Create Antl List For LcrId List  ${scfc_file_path}  ${lcr_id}
    Set To Dictionary  ${cell_antennas}  ${lcr_id}=${antennas}
  END
  ${antenna_cells}=  Turn Dictionary Of Lists Inside Out  ${cell_antennas}
  @{attribute_values_list}=  Create List
  FOR  ${antenna}  IN  @{antenna_cells.keys()}
    ${antenna_lcr_id_list}=  Get From Dictionary  ${antenna_cells}  ${antenna}
    ${attribute_values}=  Run Keyword If  ${act_category_alarms}
  ...  Set Attribute Value In Mandatory Category Alarms  ${scfc_file_path}
  ...  ${fr_serial_number}
  ...  ${antenna_lcr_id_list}
  ...  ${tool}
  ...  all_cells_count=${all_legacy_standalone_cell_count}
  ...  antenna_alarm=${antenna_alarm}
  ...  ELSE
  ...  Set Attribute Value In Mandatory Legacy Alarms  ${scfc_file_path}
  ...  ${fr_serial_number}
  ...  ${antenna_lcr_id_list}
  ...  ${tool}
  ...  antenna_alarm=${antenna_alarm}
    Append to List  ${attribute_values_list}  ${attribute_values[0]}
  END
  ${mandatory_alarms_list}=  Create Mandatory Alarms List For RMOD
  ...  ${attribute_name}  ${attribute_values_list}  ${fault_scheme}
  [Return]  ${mandatory_alarms_list}

Create Mandatory Alarms For RMOD
  [Arguments]  ${tool}  ${scfc_file_path}  ${fr_serial_number}  ${fault_scheme}
  ...  ${act_category_alarms}=False  ${lcr_id_list}=${EMPTY}  ${antenna_alarm}=False
  ${fault_scheme}=  Evaluate  ${fault_scheme}
  ${lcr_id_list}=  Set Variable If  "${lcr_id_list}" is "${EMPTY}"
  ...  ${cfg.RF_INFO['${fr_serial_number}']['LNCEL']['scf_cellid_primary']}  ${lcr_id_list}
  # WORKAROUND FOR IOT CELLS!!!!
  ${all_legacy_standalone_cell_count}=  Set Variable  ${cfg.RF_INFO['${fr_serial_number}']['LNCEL']['scf_cell_count_primary']}
  ${tmp_lcr_id_list}=  Copy List  ${lcr_id_list}
  FOR  ${lcr_id}  IN  @{lcr_id_list}
    ${object_1}=  Set Variable  "${CFG['NODES']['${BTS_ID}']['LNCEL']['${lcr_id}']['scf_type']}"!="legacy"
    ${object_2}=  Set Variable  "${CFG['NODES']['${BTS_ID}']['LNCEL']['${lcr_id}']['scf_type']}"!="standalone"
    ${sum_object}=  Evaluate    ${object_1} and ${object_2}
  Run Keyword If  ${sum_object}
  ...  Remove Values From List
  ...  ${tmp_lcr_id_list}
  ...  ${lcr_id}
  ...  ${all_legacy_standalone_cell_count}=
  Run Keyword If  ${sum_object}
  ...  Evaluate
  ...  ${all_legacy_standalone_cell_count}-1
  ...  ELSE
  ...  Set Variable
  ...  ${all_legacy_standalone_cell_count}
  END
  ${lcr_id_list}=  Copy List  ${tmp_lcr_id_list}
  ${attribute_name}=  Set Attribute Name In Mandatory Alarms  ${tool}  ${act_category_alarms}
  ${attribute_values}=  Run Keyword If  ${act_category_alarms}
  ...  Set Attribute Value In Mandatory Category Alarms  ${scfc_file_path}
  ...  ${fr_serial_number}
  ...  ${FR_INFO['${fr_serial_number}']['scf_cellid_primary']}
  ...  ${tool}
  ...  all_cells_count=${all_legacy_standalone_cell_count}
  ...  antenna_alarm=${antenna_alarm}
  ...  ELSE
  ...  Set Attribute Value In Mandatory Legacy Alarms  ${scfc_file_path}
  ...  ${fr_serial_number}
  ...  ${FR_INFO['${fr_serial_number}']['scf_cellid_primary']}
  ...  ${tool}
  ...  antenna_alarm=${antenna_alarm}
  ${mandatory_alarms_list}=  Create Mandatory Alarms List For RMOD
  ...  ${attribute_name}  ${attribute_values}  ${fault_scheme}
  [Return]  ${mandatory_alarms_list}

Set Attribute Name In Mandatory Alarms
  [Arguments]  ${tool}  ${act_category_alarms}
  ${attr}=  Run Keyword If  "${act_category_alarms}"=="True"
  ...  Set Variable  impactedCells
  ...  ELSE IF  "${tool}"=="Info Model"
  ...  Set Variable  distName
  ...  ELSE
  ...  Set Variable  lncelId
  [Return]  ${attr}

Set Attribute Value In Mandatory Category Alarms
  [Arguments]  ${scfc_file_path}  ${fr_serial_number}  ${lcr_id_list}  ${tool}
  ...  ${all_cells_count}=${ALL_CELLS_COUNT}  ${antenna_alarm}=False
  ${lncel_id_list}=  SCFC Create LncelId List For LcrdId List  ${scfc_file_path}  ${lcr_id_list}
  ${value}=  Set Variable  (?s)
  ${lncel_count}=  Get Length  ${lncel_id_list}
  ${all_cells_are_impacted}=  Set Variable If  '${lncel_count}'=='${all_cells_count}'  ${True}  ${False}
  FOR  ${cell}  IN  @{lncel_id_list}
    ${value}=  Catenate  SEPARATOR=${EMPTY}  ${value}  (?=.*LNCEL(_[LR])?-${cell}($|\\D).*)
  END
  ${value}=  Run Keyword If  ${all_cells_are_impacted} and "${tool}"=="ADMIN"
  ...  Set Variable  .*All.*
  ...  ELSE IF  ${all_cells_are_impacted} and "${tool}"=="Info Model"
  ...  Set Variable  @{EMPTY}
  ...  ELSE
  ...  Set Variable  ${value}
  ${values}=  Create List  ${value}
  Return From Keyword If  "${antenna_alarm}"=="False"  ${values}
  ${antl_list}=  SCFC Create Antl List For LcrId List
  ...  ${scfc_file_path}
  ...  ${lcr_id_list}
  ...  ${fr_serial_number}
  ...  antl_direction=${antenna_alarm}
  ${antl_count}=  Get Length  ${antl_list}
  Repeat Keyword  ${antl_count-1}  Append To List  ${values}  ${value}
  [Return]  ${values}

Set Attribute Value In Mandatory Legacy Alarms
  [Arguments]  ${scfc_file_path}  ${fr_serial_number}  ${lcr_id_list}  ${tool}
  ...  ${antenna_alarm}=False
  @{values}=  Create List
  FOR  ${cell}  IN  @{lcr_id_list}
    ${lncel_id}=  SCFC Get LncelId For LcrId  ${scfc_file_path}  ${cell}
    ${antl_list}=  SCFC Create Antl List For LcrId List
  ...  ${scfc_file_path}
  ...  ${cell}
  ...  ${fr_serial_number}
  ...  antl_direction=${antenna_alarm}
    ${antl_count}=  Get Length  ${antl_list}
    ${alarm_copies}=  Set Variable If  "${antenna_alarm}"!="False"  ${antl_count}  1
    Run Keyword If  "${tool}"=="Info Model"  Repeat Keyword  ${alarm_copies}
  ...  Append To List  ${values}  .*/?LNCEL(_L)?-${lncel_id}($|\\D).*
    Run Keyword If  "${tool}"=="BTSSM" or "${tool}"=="ADMIN"  Repeat Keyword  ${alarm_copies}
  ...  Append To List  ${values}  ${lncel_id}
  END
  [Return]  ${values}

Create Mandatory Alarms List For RMOD
  [Arguments]  ${attribute_name}  ${attribute_values}  ${fault_scheme}
  ${alarm_severity}=  Set Variable  ${fault_scheme['alarmSeverity']}
  @{mandatory_alarms_list}=  Create List
  FOR  ${value}  IN  @{attribute_values}
    ${value}=  Set Variable If  "Minor" in "${alarm_severity}"  .*  ${value}
    Set To Dictionary  ${fault_scheme}  ${attribute_name}  ${value}
    ${scheme_copy}=  Copy Dictionary  ${fault_scheme}
    Append To List  ${mandatory_alarms_list}  ${scheme_copy}
  END
  [Return]  ${mandatory_alarms_list}

Create SCFC File With Activated PIMC For FR Serial Number
  [Arguments]  ${scfc_file_path}=${SCFC_REFERENCE_FILE_PATH}  ${fr_serial_number}=${FR_UNDER_TEST_SERIAL_NUMBER}
  ${rmod_id}=  SCFC Get RmodId For FR Serial Number  ${scfc_file_path}  ${fr_serial_number}
    ${object_1}=  Set Variable  .//managedObject[substring(@distName, string-length(@distName) - string-length(${rmod_id}) + 1) = '${rmod_id}']
    ${object_2}=  Set Variable  [p[@name='pimCancellingEnabled']]/@distName
    ${sum_object}=  Set Variable  ${object_1}${object_2}
  ${rmod_dn}=  Evaluate Xpath
  ...  ${scfc_file_path}
  ...  ${sum_object}
  @{pimc_scfc_parameters}=  Create List
  ...  .//managedObject[@distName='${rmod_dn[0]}']/p[@name="pimCancellingEnabled"]:true
  ...  .//managedObject[@distName='${rmod_dn[0]}']/p[@name="actPimCancellation"]:true
  admin.Create Delta
  admin.Append Parameter Update To Delta   ${rmod_dn}  pimCancellingEnabled   true
  admin.Append Parameter Update To Delta   ${rmod_dn}  actPimCancellation   true

  FOR  ${lcr_id}  IN  @{FR_INFO['${fr_serial_number}']['cell_list']}
    ${cell_dn}=  SCFC Get DistName For LcrId  ${scfc_file_path}  ${lcr_id}
    admin.Append Parameter Update To Delta   ${cell_dn}  dlInterferenceEnable   true
    admin.Append Parameter Update To Delta   ${cell_dn}  dlInterferenceLevel   100
#    Append To List  ${pimc_scfc_parameters}
#  ...  .//managedObject[@distName='${cell_dn}']/p[@name="dlInterferenceEnable"]:true
#  ...  .//managedObject[@distName='${cell_dn}']/p[@name="dlInterferenceLevel"]:100
  END
  admin.Save Delta  ${scfc_file_path}_PIMC
#  SCFC Create Modified SCFC With Given Parameters
#  ...  ${scfc_file_path}  ${pimc_scfc_parameters}  modified_scfc_suffix=_PIMC  ${rmod_dn}
  [Return]  ${scfc_file_path}_PIMC

#SCFC Create Modified SCFC With Given Parameters
#  [Arguments]  ${scfc_original}  ${parameters}  ${modified_scfc_suffix}=_2  ${rmod_dn}
#  ta_kiss_files.Setup Xml  src_file=${scfc_original}  save_path=${scfc_original}${modified_scfc_suffix}
#  ta_kiss_files.Modify Xml Text  @{parameters}
#  ta_kiss_files.Teardown Xml
#
#  admin.Create Delta
#  admin.Append Parameter Update To Delta   ${rmod_dn}  ${parameters}
#  Save Delta     ${modified_scfc_suffix}




#  [Return]  ${scfc_original}${modified_scfc_suffix}

Get Cells That Can Be Affected By PIMC
  [Arguments]  ${scfc_file_path}=${SCFC_REFERENCE_FILE_PATH}  ${fr_serial_number}=${FR_UNDER_TEST_SERIAL_NUMBER}
  ${cell_antennas}=  Create Dictionary
  FOR  ${lncel_id}  IN  @{cfg.RF_INFO['${fr_serial_number}']['LNCEL']['scf_cellid_primary']}
    ${lcr_id}=  Get From Dictionary  ${cfg.NODES['${BTS_ID}']['LNCEL']['${lncel_id}']}  scf_cellid_primary
    ${lcr_id}=  Convert To String  ${lcr_id}
    ${antennas}=  SCFC Create Antl List For LcrId List  ${scfc_file_path}  ${lcr_id}
    Set To Dictionary  ${cell_antennas}  ${lcr_id}=${antennas}
    ${antenna_cells}=  Turn Dictionary Of Lists Inside Out  ${cell_antennas}
    ${cell_list_with_pimc}=  Create List
  END
  FOR  ${antenna}  IN  @{antenna_cells.keys()}
    ${cell_list}=  Get From Dictionary  ${antenna_cells}  ${antenna}
    ${antl_cell_list_with_pimc}=  Filter Out Cells Not Affected By PIM  ${cell_list}  ${CELL_INFO}
    ${cell_list_with_pimc}=  Combine Lists  ${cell_list_with_pimc}  ${antl_cell_list_with_pimc}
  END
  ${cell_list_with_pimc}=  Remove Duplicates  ${cell_list_with_pimc}
  Run Keyword If  "${cell_list_with_pimc}"=="@{EMPTY}"  Fail  Cells EARFCN are improperly commissioned for PIMC!
  Set Test Variable  ${CELLS_AFFECTED_BY_PIMC}  ${cell_list_with_pimc}

Commission PIMC Parameters
  [Arguments]  ${scfc_file_path}=${SCFC_REFERENCE_FILE_PATH}  ${fr_serial_number}=${FR_UNDER_TEST_SERIAL_NUMBER}
  ...  ${alias}=${TC_ALIAS}
  Activate PIMC For FR Serial Number

Perform Commissioning From File
  [Arguments]  ${scfc_file_path}  ${bts_id}=${BTS_ID}  ${enb_manager}=${ENB_MANAGER}  ${alias}=default
  ...  ${skip_parameter_relation_errors}=True
  Log  Commissioning from ${scfc_file_path}  console=yes
  admin.perform_commissioning  ${bts_id}  ${scfc_file_path}
  ...  skip_parameter_relation_errors=${skip_parameter_relation_errors}  should_activate=True  timeout=1000
  ...  alias=${alias}
