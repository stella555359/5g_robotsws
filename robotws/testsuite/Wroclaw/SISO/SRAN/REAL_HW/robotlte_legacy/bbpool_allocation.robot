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

Library  XML  use_lxml=true
Library  ute_admin_infomodel
Library  taf.config.scf  WITH NAME  scf


*** Variables ***
${ABIO_delta_directory_path}  /home/ute/MN/UTE/bbpool
${ABIO_product_code}  475266
${MAKE_CALL}  ${FALSE}  # Set this variable to turn on/of call procedure
@{SELECTED_CELLS}  @{EMPTY}  # Set list of cells id for call
@{BB_LIST}

*** Keywords ***
Execute ABIO L1 Balanced Cell Test On Every Node
  [Documentation]  User has possibility to turn on/off call procedure by setting test variable \${MAKE_CALL} True/False
  ...  If call procedure is on, \@{SELECTED_CELLS} list needs to contain called cells.
  ...  Correct cells input: nrCellIdentity, eutranCellId, cellId or gsmSectorID. Each cell id have to be separated by double space.
  ...  Before performing call, UEPC should be prepared according to:
  ...  https://confluence.ext.net.nokia.com/display/mnsranprodsisopz/L3+Call+for+testauto+-+PROXY+solution
  [Arguments]  ${cfg}  ${bts_id}  ${test_logs_path}
  SCFC Get Bbpool Alloc Mode  ${test_logs_path}  ${bts_id}
  ${bbmod_sn_cablinks}=  Check Hardware Connection Cell On ABIO  ${cfg.NODES['${bts_id}']['scf_file_path']}  ${bts_id}
  ${cell_mapping}=  Check Cells Allocation On ABIO  ${bbmod_sn_cablinks}  ${bts_id}
  Verify Automatic Mode  ${cell_mapping}  ${bbmod_sn_cablinks}
  Run Keyword If  ${MAKE_CALL}  Run Keywords
  ...  Log  ${\n}==========Trying to perform call==========${\n}  console=True
  ...  AND  SiSo L3 Call Procedure  ${test_logs_path}/Call_TC_Start
  Perform Delta ABIO Commissioning  mode=automatic_l1balanced  bts_id=${bts_id}
  ${cell_mapping}=  Check Cells Allocation On ABIO  ${bbmod_sn_cablinks}  ${bts_id}
  Verify Automatic Mode With l1 balanced  ${cell_mapping}  ${bbmod_sn_cablinks}
  Perform Delta ABIO Commissioning  mode=automatic_lgid  bts_id=${bts_id}
  ${cell_mapping}=  Check Cells Allocation On ABIO  ${bbmod_sn_cablinks}  ${bts_id}
  Verify Automatic Mode With logical group identifier  ${cell_mapping}  ${bbmod_sn_cablinks}  ${bts_id}
  Perform Delta ABIO Commissioning  mode=automatic_lgid_l1balanced  bts_id=${bts_id}
  ${cell_mapping}=  Check Cells Allocation On ABIO  ${bbmod_sn_cablinks}  ${bts_id}
  Verify Automatic Mode With logical group identifier and with l1 balanced
  ...  ${bbmod_sn_cablinks}
  ...  ${bts_id}
  Run Keyword If  ${MAKE_CALL}  Run Keywords
  ...  Log  ${\n}==========Trying to perform call==========${\n}  console=True
  ...  AND  SiSo L3 Call Procedure  ${test_logs_path}/Call_TC_End

Verify Automatic Mode
  [Arguments]  ${cell_mapping}  ${bbmod_sn_cablinks}
  Log Dictionary  ${cell_mapping}
  Log Dictionary  ${bbmod_sn_cablinks}
  ${private_bb_list_status}=  Run Keyword And Return Status  Variable Should Exist ${BB_LIST}
  ${abio_list}=  Get Dictionary Keys  ${bbmod_sn_cablinks}
  ${bb_new_list}=  Set Variable If  ${private_bb_list_status} ${BB_LIST}  ${abio_list}
  FOR  ${ABIO}  IN  @{bb_new_list}
    ${status}=  Run Keyword And Return Status  Should Be Empty  ${cell_mapping.${ABIO}}
    Continue For Loop If  ${status}
    ${lncel_var_1_status}=  Run Keyword And Return Status  Should Not Be Empty  ${cell_mapping.${ABIO}.lncel.lncel_1}

    ${lncel_var_2_status}=  Run Keyword And Return Status  Should Not Be Empty  ${cell_mapping.${ABIO}.lncel.lncel_2}

    ${nrcel_var_1_status}=  Run Keyword And Return Status  Should Not Be Empty  ${cell_mapping.${ABIO}.nrcel.nrcel_1}

    ${nrcel_var_2_status}=  Run Keyword And Return Status  Should Not Be Empty  ${cell_mapping.${ABIO}.nrcel.nrcel_2}

    Run Keyword And Continue On Failure
    ...  Run Keyword If
    ...  ${lncel_var_1_status}
    ...  Run Keyword And Continue On Failure
    ...  Automatic Mode Compare Cell List
    ...  ${cell_mapping.${ABIO}.lncel.lncel_1}
    ...  ${cell_mapping.${ABIO}.lncel.lncel_2}
    ...  ${bbmod_sn_cablinks.${ABIO}.lncel_1}
    Run Keyword And Continue On Failure
    ...  Run Keyword If
    ...  ${nrcel_var_1_status}
    ...  Run Keyword And Continue On Failure
    ...  Automatic Mode Compare Cell List
    ...  ${cell_mapping.${ABIO}.nrcel.nrcel_1}
    ...  ${cell_mapping.${ABIO}.nrcel.nrcel_2}
    ...  ${bbmod_sn_cablinks.${ABIO}.nrcel_1}
    Run Keyword And Continue On Failure
    ...  Run Keyword If
    ...  ${lncel_var_2_status}
    ...  Run Keyword And Continue On Failure
    ...  Automatic Mode Compare Cell List
    ...  ${cell_mapping.${ABIO}.lncel.lncel_2}
    ...  ${cell_mapping.${ABIO}.lncel.lncel_1}
    ...  ${bbmod_sn_cablinks.${ABIO}.lncel_2}
    Run Keyword And Continue On Failure
    ...  Run Keyword If
    ...  ${nrcel_var_2_status}
    ...  Run Keyword And Continue On Failure
    ...  Automatic Mode Compare Cell List
    ...  ${cell_mapping.${ABIO}.nrcel.nrcel_2}
    ...  ${cell_mapping.${ABIO}.nrcel.nrcel_1}
    ...  ${bbmod_sn_cablinks.${ABIO}.nrcel_2}
  END
  Logging With Timestamp
  ...  message=Verify Automatic Mode Finished

Automatic Mode Compare Cell List
  [Arguments]  ${list_1}  ${list_2}  ${list_3}
  Run Keyword And Continue On Failure
  ...  Lists Should Be Equal  ${list_1}  ${list_3}  msg=Loki_1 not proper layout
  ${duplication_status_1}=  Run Keyword And Continue On Failure
  ...  Evaluate  any(item in ${list_1} for item in ${list_2})
  ${duplication_status_2}=  Run Keyword And Continue On Failure
  ...  Evaluate  any(item in ${list_2} for item in ${list_1})
  Run Keyword And Continue On Failure  Should Not Be True  ${duplication_status_1} or ${duplication_status_2}
  ...  msg=Cell duplicated within bbpools 1 and 2

Check Cell Duplication List
  [Arguments]  ${list_1}  ${list_2}
  ${duplication_status_1}=  Run Keyword And Return Status
  ...  Evaluate  any(item in ${list_1} for item in ${list_2})
  ${duplication_status_2}=  Run Keyword And Return Status
  ...  Evaluate  any(item in ${list_2} for item in ${list_1})
  Run Keyword And Continue On Failure  Should Not Be True  ${duplication_status_1} or ${duplication_status_2}
  ...  msg=Cell duplicated within bbpools 1 and 2

Verify Automatic Mode With logical group identifier
  [Arguments]  ${cell_mapping}  ${bbmod_sn_cablinks}  ${bts_id}
  ${lg_mode_dict}=  Get Bbpool Logical Group  ${bbmod_sn_cablinks}  ${bts_id}
  Compare Cell Mapping List For Logical Group Identifier
  ...  ${lg_mode_dict}
  ...  ${cell_mapping}
  ...  ${bbmod_sn_cablinks}
  ...  ${bts_id}

Verify Automatic Mode With l1 balanced
  [Arguments]  ${cell_mapping}  ${bbmod_sn_cablinks}
  Log Dictionary  ${cell_mapping}
  Log Dictionary  ${bbmod_sn_cablinks}
  ${private_bb_list_status}=  Run Keyword And Return Status  Variable Should Exist ${BB_LIST}
  ${abio_list}=  Get Dictionary Keys  ${bbmod_sn_cablinks}
  ${bb_new_list}=  Set Variable If  ${private_bb_list_status} ${BB_LIST}  ${abio_list}
  FOR  ${ABIO}  IN  @{bb_new_list}
    ${loki_1_cell_list}=  Get Length  ${bbmod_sn_cablinks.${ABIO}.lncel_1}
    ${loki_2_cell_list}=  Get Length  ${bbmod_sn_cablinks.${ABIO}.lncel_2}
    ${loki_cm_1_cell_list}=  Get Length  ${cell_mapping.${ABIO}.lncel.lncel_1}
    ${loki_cm_2_cell_list}=  Get Length  ${cell_mapping.${ABIO}.lncel.lncel_1}
    ${sum_cell}=  Evaluate  ${loki_1_cell_list}+${loki_2_cell_list}
    ${equable_value}=  Evaluate  ${sum_cell} // 2
    ${div_value}=  Evaluate  (${loki_cm_1_cell_list} - ${loki_cm_2_cell_list}) <= abs(1)
    Run Keyword And Continue On Failure
    ...  Should Be True  (${equable_value} == ${loki_cm_1_cell_list})
    Run Keyword And Continue On Failure
    ...  Should Be True  (${equable_value} == ${loki_cm_2_cell_list})
    Run Keyword And Continue On Failure
    ...  Should Be True  (${loki_cm_1_cell_list} <= ${equable_value+1})
    Run Keyword And Continue On Failure
    ...  Should Be True  (${loki_cm_2_cell_list} <= ${equable_value+1})
  END
  Logging With Timestamp
  ...  message=Verify Automatic Mode With l1 balanced

Verify Automatic Mode With logical group identifier and with l1 balanced
  [Arguments]  ${bbmod_sn_cablinks}  ${bts_id}
  ${lg_mode_dict}=  Get Bbpool Logical Group  ${bbmod_sn_cablinks}  ${bts_id}
#  Compare Cell Mapping List For Manual And Logical Group Identifier  ${lg_mode_dict}  ${cell_mapping}  ${bbmod_sn_cablinks}  ${bts_id}

Perform Delta ABIO Commissioning
  [Arguments]  ${mode}  ${bts_id}
  ${delta_file_path}=  Set Variable  ${ABIO_delta_directory_path}/${mode}.json
  Logging With Timestamp
  ...  messag=Perform Delta ABIO Commissioning on bts_id node=${bts_id} for ${mode}started.
  Run Keyword And Continue On Failure  Perform Delta Recommissioning
  ...  delta_file=${delta_file_path}
  ...  skip_parameter_relation_errors=False
  ...  should_activate=True
  ...  timeout=300
  ...  connection=${bts_id}
  Logging With Timestamp
  ...  message=Perform Delta ABIO Commissioning on bts_id node=${bts_id} finished.
  Verify BTS State  ${bts_id}  ${HARDWARE_DETECTION_TIME}
  Wait Until Keyword Succeeds  120 sec  5 sec  Verify Alarms  alias=${bts_id}

Check Hardware Connection Cell On ABIO
  [Arguments]  ${scfc_file}  ${bts_id}
  scf.load scf  ${scfc_file}
  ${abio_list}=  Evaluate Xpath
  ...  ${scfc_file}
  ...  .//managedObject[contains (@class, 'BBMOD_R') and (p[@name="productCode" and contains(text(), "${ABIO_product_code}")])]/@distName
  ${bbmod_connections}=  Create Dictionary  &{EMPTY}
  FOR  ${abio}  IN  @{abio_list}
    ${abio_sn}=  scf.Get All Values From Scf  dist_name=${abio}  p_name=serialNumber
    Set To Dictionary  ${bbmod_connections}  ${abio_sn[0]}=${abio}
  END
  ${bb_list}=  Get Dictionary Keys  ${bbmod_connections}
  FOR  ${abio_ru_sn}  IN  @{bb_list}
    ${bbmod_sn_cablinks}=  Get BB Cablinks  ${bbmod_connections}  ${bts_id}  ${scfc_file}
    Set To Dictionary  ${bbmod_sn_cablinks['${abio_ru_sn}']}  distName=${bbmod_connections.${abio_ru_sn}}
  END
  Log Dictionary  ${bbmod_sn_cablinks}
  Set Test Variable  ${bbmod_sn_cablinks}
  [Return]  ${bbmod_sn_cablinks}

Check Hardware Connection Cell On Any BB
  [Arguments]  ${scfc_file}  ${bts_id}
  scf.load scf  ${scfc_file}
  ${abio_list}=  Evaluate Xpath  ${scfc_file}
  ...  .//managedObject[contains (@class, 'BBMOD_R')]/@distName
  ${bbmod_connections}=  Create Dictionary  &{EMPTY}
  FOR  ${abio}  IN  @{abio_list}
    ${abio_sn}=  scf.Get All Values From Scf  dist_name=${abio}  p_name=serialNumber
    Set To Dictionary  ${bbmod_connections}  ${abio_sn[0]}=${abio}
  END
  ${bb_list}=  Get Dictionary Keys  ${bbmod_connections}
  FOR  ${abio_ru_sn}  IN  @{bb_list}
    ${bbmod_sn_cablinks}=  Get BB Cablinks  ${bbmod_connections}  ${bts_id}  ${scfc_file}
    Set To Dictionary  ${bbmod_sn_cablinks['${abio_ru_sn}']}  distName=${bbmod_connections.${abio_ru_sn}}
  END
  Log Dictionary  ${bbmod_sn_cablinks}
  Set Test Variable  ${bbmod_sn_cablinks}
  [Return]  ${bbmod_sn_cablinks}

Get BB Cablinks
  [Arguments]  ${bbmod_connections}  ${bts_id}  ${scfc_file}=${cfg.NODES['${bts_id}']['scf_file_path']}
  ${bbmod_sn_cablinks}=  create Dictionary  &{EMPTY}
  FOR  ${bb}  IN  @{bbmod_connections}
    ${tmp_bbmod_connections}=  create Dictionary  &{EMPTY}
    ${cablink_bb_list}=  Evaluate Xpath
    ...  ${scfc_file}
    ...  .//managedObject[contains (@class, 'CABLINK_R') and p[@name="firstEndpointDN"]="${bbmod_connections.${bb}}"]/@distName
    ${abio_info}=  admin_im.Query Infomodel  get object //BBMOD_R-* is [serialNumber=${bb}]  alias=${bts_id}
    ${dn}  ${abio_number}=  Split String From Right  string=${abio_info.configDN}  separator=-  max_split=1
    ${tmp_bbmod_cablinks}=  Get BB Cablink Description  ${cablink_bb_list}
    Set To Dictionary  ${tmp_bbmod_cablinks}  bb_card_id=${abio_number}
    Set To Dictionary  ${bbmod_sn_cablinks}
    ...  ${bb}=${tmp_bbmod_cablinks}
  END
  [Return]  ${bbmod_sn_cablinks}

Get BB Cablink Description
  [Arguments]  ${cablink_bb_list}
  ${bbmod_cablinks}=  Create Dictionary  &{EMPTY}
  ${LOKI_cell_dict}=  Create Dictionary  &{EMPTY}
  ${bb_cell_list}=  Create Dictionary  &{EMPTY}
  ${Loki_1_cell_list_LTE}=  Create List  @{EMPTY}
  ${Loki_1_cell_list_5G}=  Create List  @{EMPTY}
  ${tmp_cell_lncell_list}=  Create List  @{EMPTY}
  ${tmp_cell_nrcell_list}=  Create List  @{EMPTY}
  ${Loki_2_cell_list_LTE}=  Create List  @{EMPTY}
  ${Loki_2_cell_list_5G}=  Create List  @{EMPTY}
  FOR  ${cablink}  IN  @{cablink_bb_list}
    ${tmp_bbmod_cablinks}=  create Dictionary  &{EMPTY}
    ${secondEndpointDN}=  scf.Get Value From Scf  dist_name=${cablink}  p_name=secondEndpointDN
    ${firstEndpointPortId}=  scf.Get Value From Scf  dist_name=${cablink}  p_name=firstEndpointPortId
    ${configDN}=  scf.Get Value From Scf  dist_name=${secondEndpointDN}  p_name=configDN
    ${serialNumber}=  scf.Get Value From Scf  dist_name=${secondEndpointDN}  p_name=serialNumber
    ${LOKI_number}=  Set Variable If  '${firstEndpointPortId}' in '1 2 3 4 5 6'  1  2
    Set To Dictionary
    ...  ${tmp_bbmod_cablinks}
    ...  secondEndpointDN=${secondEndpointDN}
    ...  firstEndpointPortId=${firstEndpointPortId}
    ...  configDN=${configDN}
    ...  serialNumber=${serialNumber}
    ...  LOKI_number=${LOKI_number}
    ${gncell_dict}=  Get From Dictionary  ${cfg['RF_INFO']['${serial_number}']}  GNCEL
    ${wncell_dict}=  Get From Dictionary  ${cfg['RF_INFO']['${serial_number}']}  WNCEL
    ${lncell_dict}=  Get From Dictionary  ${cfg['RF_INFO']['${serial_number}']}  LNCEL
    ${nrcell_dict}=  Get From Dictionary  ${cfg['RF_INFO']['${serial_number}']}  NRCEL
    Set To Dictionary
    ...  ${tmp_bbmod_cablinks}
    ...  GNCEL=${gncell_dict}
    ...  WNCEL=${wncell_dict}
    ...  LNCEL=${lncell_dict}
    ...  NRCEL=${nrcell_dict}
    Run Keyword If  not ${tmp_bbmod_cablinks}==&{EMPTY}  Run Keyword And Ignore Error
    ...  Append To List  ${tmp_cell_lncell_list}  @{lncell_dict.lncelid}
    Run Keyword If  not ${tmp_bbmod_cablinks}==&{EMPTY}  Run Keyword And Ignore Error
    ...  Append To List  ${tmp_cell_nrcell_list}  @{nrcell_dict.nrcelid}
    ${tmp_cell_lncell_list}=  Remove Duplicates  ${tmp_cell_lncell_list}
    ${tmp_cell_nrcell_list}=  Remove Duplicates  ${tmp_cell_nrcell_list}

    Run Keyword If   not ${tmp_bbmod_cablinks}==&{EMPTY}  Set To Dictionary  ${bbmod_cablinks}
    ...  lncel_${LOKI_number}=${lncell_dict.lncelid}
    ...  gncel=${gncell_dict.gncelid}
    ...  wncel=${wncell_dict.wncelid}
    ...  nrcel_${LOKI_number}=${nrcell_dict.nrcelid}
    Run Keyword If
    ...  '${LOKI_number}'=='1'
    ...  Run Keyword And Ignore Error
    ...  Append To List
    ...  ${Loki_1_cell_list_LTE}
    ...  @{lncell_dict.lncelid}
    Run Keyword If
    ...  '${LOKI_number}'=='1'
    ...  Run Keyword And Ignore Error
    ...  Append To List
    ...  ${Loki_1_cell_list_5G}
    ...  @{nrcell_dict.nrcelid}
    Run Keyword If
    ...  '${LOKI_number}'=='2'
    ...  Run Keyword And Ignore Error
    ...  Append To List
    ...  ${Loki_2_cell_list_LTE}
    ...  @{lncell_dict.lncelid}
    Run Keyword If
    ...  '${LOKI_number}'=='2'
    ...  Run Keyword And Ignore Error
    ...  Append To List
    ...  ${Loki_2_cell_list_5G}
    ...  @{nrcell_dict.nrcelid}
    ${Loki_1_cell_list_LTE}=  Remove Duplicates  ${Loki_1_cell_list_LTE}
    ${Loki_1_cell_list_5G}=  Remove Duplicates  ${Loki_1_cell_list_5G}
    ${Loki_2_cell_list_LTE}=  Remove Duplicates  ${Loki_2_cell_list_LTE}
    ${Loki_2_cell_list_5G}=  Remove Duplicates  ${Loki_2_cell_list_5G}
    Set To Dictionary  ${bbmod_cablinks}
    ...  ${cablink}=${tmp_bbmod_cablinks}
    ...  loki_1=${Loki_1_cell_list_LTE}
    ...  loki_2=${Loki_2_cell_list_LTE}
    ...  lncel_1=${Loki_1_cell_list_LTE}
    ...  lncel_2=${Loki_2_cell_list_LTE}
    ...  nrcel_1=${Loki_1_cell_list_5G}
    ...  nrcel_2=${Loki_2_cell_list_5G}
    ...  lncel=${tmp_cell_lncell_list}
    ...  nrcel=${tmp_cell_nrcell_list}
  END
  [Return]  ${bbmod_cablinks}

Remove IoT Cells From BB List
  [Arguments]  ${cell_list}
  FOR  ${cell}  IN  @{cell_list}
    check amplifier
  END
  [Return]  ${cell_list}

Get BB Cells Per Port ID
  [Arguments]  ${bbmod_sn_cablinks}  ${abio_sn}
  ${abio_list}=  Get Dictionary Keys  ${bbmod_sn_cablinks}
  ${abio_list}=  Run Keyword If  ${abio_sn}  Create List  ${abio_sn}
  ...  ELSE  Create List  @{abio_list}
  FOR  ${abio}  IN  @{abio_list}
    ${abio_cablinks}=  Get Dictionary Keys  ${bbmod_sn_cablinks.${abio}}
    ${abio_port_cell_list}=  Get Cablink Cell List  ${abio_cablinks}
    Set To Dictionary  ${bbmod_sn_cablinks.${abio}}  ${abio_port_cell_list}
  END

Check Cells Allocation On ABIO
  [Arguments]  ${bbmod_sn_cablinks}  ${bts_id}=${cfg.primary_node_bts_id}
  ${cell_mapping}=  Group Cell By ABIO With BbPoolId  ${bbmod_sn_cablinks}  ${bts_id}
  Set Test Variable  ${CELL_MAPPING}  ${cell_mapping}
  [Return]  ${cell_mapping}

Group Cell By ABIO With BbPoolId
  [Arguments]  ${bbmod_sn_cablinks}  ${bts_id}
  ${bb_list}=  Get Dictionary Keys  ${bbmod_sn_cablinks}
  ${cell_mapping}=  Create Dictionary  &{EMPTY}

  FOR  ${bb}  IN  @{bb_list}
    ${cell_mapping_dict_ln}=  Create Dictionary  &{EMPTY}
    ${cell_mapping_dict_nr}=  Create Dictionary  &{EMPTY}
    ${cell_mapping_dict_tmp}=  Create Dictionary  &{EMPTY}
    ${abio_lncell_list}=  Get Variable Value  ${bbmod_sn_cablinks.${bb}.lncel}
    ${abio_nrcell_list}=  Get Variable Value  ${bbmod_sn_cablinks.${bb}.nrcel}
    ${abio_bb_card_id}=  Get Variable Value  ${bbmod_sn_cablinks.${bb}.bb_card_id}
    ${cell_mapping_dict_ln}=  Run Keyword If  ${abio_lncell_list}
    ...  Get Cell List Mapping  ${abio_lncell_list}  ${abio_bb_card_id}  LNCEL  ${bts_id}
    ...  ELSE  Set Variable  &{EMPTY}
    ${cell_mapping_dict_nr}=  Run Keyword If  ${abio_nrcell_list}
    ...  Get Cell List Mapping  ${abio_nrcell_list}  ${abio_bb_card_id}  NRCEL  ${bts_id}
    ...  ELSE  Set Variable  &{EMPTY}

    Set To Dictionary  ${cell_mapping_dict_tmp}  lncel=${cell_mapping_dict_ln}  nrcel=${cell_mapping_dict_nr}
    Set To Dictionary  ${cell_mapping}  ${bb}=${cell_mapping_dict_tmp}
  END
  Logging With Timestamp
  ...  message=Step - Group Cell By ABIO With BbPoolId on bts_id node=${bts_id} finished. ${cell_mapping}
  [Return]  ${cell_mapping}

Get Cell List Mapping
  [Arguments]  ${abio_lncell_list}  ${abio_bb_card_id}  ${technology}  ${bts_id}

  ${tmp_cell_dict}=  Create Dictionary  &{EMPTY}
  ${tmp_Loki_1_list}=  Create List  @{EMPTY}
  ${tmp_Loki_2_list}=  Create List  @{EMPTY}

  FOR  ${cell}  IN  @{abio_lncell_list}
    Continue For Loop If  'band' in '${cfg.NODES['${bts_id}']['${technology}']['${cell}']['scf_type']}'
    ${tmp_dict}=  Create Dictionary  &{EMPTY}
    ${rat_type}=  Set Variable If  '${technology}'=='LNCEL'  LTE  NR
    ${cell_type_rat}=  Set Variable If  '${technology}'=='LNCEL'  lncel  nrcel
    ${cell_id}=  Get Cell Id By Configuration Id  ${rat_type}  ${cell}  20  alias=${bts_id}
    ${object_im}=  Run Keyword And Continue On Failure
    ...  admin_im.Query Infomodel  get object //CELL_M-*/REF-1 is [distName=regex"(.+${cell}$)"]  alias=${bts_id}
    ${cell_ref_distName}=  Split String From Right
    ...  string=${object_im.dist_name}
    ...  separator=CELL_M-
    ...  max_split=1
    ${cell_ref_distName}=  Split String From Right
    ...  string=${cell_ref_distName[1]}
    ...  separator=/
    ...  max_split=1
    ${object_im_dn}=  Set Variable  ${cell_ref_distName[0]}
    ${bbpool_dist_name}=  Get Cell M List From BBpool  ${object_im_dn}  ${bts_id}
    ${hostingBbPoolId}=  Split String From Right
    ...  string=${bbpool_dist_name}
    ...  separator=-
    ...  max_split=1
    Set To Dictionary  ${tmp_dict}
    ...  hostingBbPoolId=${hostingBbPoolId[1]}
    Run Keyword If  ${hostingBbPoolId[1]}==1 or ${hostingBbPoolId[1]}==${abio_bb_card_id}1
    ...  Append To List  ${tmp_Loki_1_list}  ${cell}
    Run Keyword If  ${hostingBbPoolId[1]}==2 or ${hostingBbPoolId[1]}==${abio_bb_card_id}2
    ...  Append To List  ${tmp_Loki_2_list}  ${cell}
    Set To Dictionary  ${tmp_cell_dict}  ${cell}=${tmp_dict}
  END
  Set To Dictionary
  ...  ${tmp_cell_dict}
  ...  loki_1=${tmp_Loki_1_list}
  ...  loki_2=${tmp_Loki_2_list}
  ...  ${cell_type_rat}_1=${tmp_Loki_1_list}
  ...  ${cell_type_rat}_2=${tmp_Loki_2_list}
  [Return]  ${tmp_cell_dict}

Get Cell M List From BBpool
  [Arguments]  ${cell_id}  ${bts_id}
  ${object_im}=  Run Keyword And Continue On Failure
  ...  admin_im.Query Infomodel
  ...  query=get list /MRBTS-*/RAT-*/MCTRL-*/BBTOP_M-1/LAYOUT_MAP-1/BBPOOL_L-*
  ...  alias=${bts_id}
  FOR  ${item}  IN  @{object_im}
    ${cell_object}=  Set Variable  ${item.assignedLCellsDNs}
    Continue For Loop If  not ${cell_object}
    ${status}=  Get Cell BBpool Distname  ${cell_object}  ${cell_id}
    Exit For Loop If  ${status}
  END
  [Return]  ${item.dist_name}

Get Cell BBpool Distname
  [Arguments]  ${cell_object}  ${cell_id}
  FOR  ${item}  IN  @{cell_object}
    ${status}=  Run Keyword And Return Status  Should Match Regexp  ${item}  \.\+M-${cell_id}\$
    Exit For Loop If  ${status}
  END
  [Return]  ${status}

Get Cell Power Group
  [Arguments]  ${cell_id}  ${bts_id}  ${rat_type}=LNBTS
  ${object_im}=  Run Keyword And Continue On Failure
  ...  query infomodel
  ...  get object //BBTOP_M-1/MRBTS_M-1/${rat_type}_M-1/CELL_M-*/REF-1 is [distName=regex"(.+-${cell_id}$)"]
  ...  alias=${bts_id}
  ${cell_ref_distName}=  Split String From Right
  ...  string=${object_im.dist_name}
  ...  separator=/
  ...  max_split=1
  ${object_im_dn}=  Set Variable  ${cell_ref_distName[0]}
  ${bbu_poprDDN_list}=  Create List  @{EMPTY}
  ${object_im}=  Run Keyword And Continue On Failure
  ...  admin_im.Query Infomodel  query=get list ${object_im_dn}/CHANNEL_GROUP_M-1/CHANNEL_M-*/PATH-1  alias=${bts_id}
  FOR  ${channel}  IN  @{object_im}
    ${object_im_dn}=  Set Variable  ${channel.processingDeviceDNs}
    Append To List  ${bbu_poprDDN_list}  @{object_im_dn}
  END
  ${pg_number}=  Create List  @{EMPTY}
  FOR  ${element}  IN  @{bbu_poprDDN_list}
    ${status}=  Run Keyword And Return Status  Should Match Regexp  ${element}  .?POWER_GROUP_L-*.?  msg=Fail
    Run Keyword If  '${status}'=='False'  Remove Values From List  ${bbu_poprDDN_list}  ${element}
    ${pg_number_tmp}=  Run Keyword If  '${status}'!='False'
    ...  Should Match Regexp  ${element}  .?POWER_GROUP_L-(\\d+).?
    Run Keyword If  '${status}'!='False'  Append To List  ${pg_number}  ${pg_number_tmp[1]}
  END
  ${pg_number}=  Remove Duplicates  ${pg_number}
  Log List  ${bbu_poprDDN_list}
  [Return]  ${bbu_poprDDN_list}  ${cell_ref_distName[0]}  ${pg_number}

Get BBSWITCH Group
  [Arguments]  ${cell_id}  ${bts_id}  ${rat_type}=LNBTS
  ${object_im}=  Run Keyword And Continue On Failure
  ...  admin_im.query infomodel
  ...  get object //BBTOP_M-1/MRBTS_M-1/${rat_type}_M-1/CELL_M-*/REF-1 is [distName=regex"(.+-${cell_id}$)"]
  ...  alias=${bts_id}
  ${cell_ref_distName}=  Split String From Right
  ...  string=${object_im.dist_name}
  ...  separator=/
  ...  max_split=1
  ${object_im_dn}=  Set Variable  ${cell_ref_distName[0]}
  ${bbu_poprDDN_list}=  Create List  @{EMPTY}
  ${object_im}=  Run Keyword And Continue On Failure
  ...  admin_im.Query Infomodel  query=get list ${object_im_dn}/CHANNEL_GROUP_M-1/CHANNEL_M-*/PATH-1  alias=${bts_id}
  FOR  ${channel}  IN  @{object_im}
    ${object_im_dn}=  Set Variable  ${channel.processingDeviceDNs}
    Append To List  ${bbu_poprDDN_list}  @{object_im_dn}
  END
  ${pg_number}=  Create List  @{EMPTY}
  FOR  ${element}  IN  @{bbu_poprDDN_list}
    ${status}=  Run Keyword And Return Status  Should Match Regexp  ${element}  .?RU_L-.?\/BBSWITCH_L-*.?  msg=Fail
    Run Keyword If  '${status}'=='False'  Remove Values From List  ${bbu_poprDDN_list}  ${element}
    ${pg_number_tmp}=  Run Keyword If  '${status}'!='False'
    ...  Should Match Regexp  ${element}  .?RU_L-.?\/BBSWITCH_L-(\\d+).?
    Run Keyword If  '${status}'!='False'  Append To List  ${pg_number}  ${pg_number_tmp[1]}
  END
  ${pg_number}=  Remove Duplicates  ${pg_number}
  Log List  ${bbu_poprDDN_list}
  [Return]  ${bbu_poprDDN_list}  ${cell_ref_distName[0]}  ${pg_number}

SCFC Get Bbpool Alloc Mode
  [Arguments]  ${scfc_file}  ${bts_id}
  ${scfc_file}=  scf.load scf  ${cfg.NODES['${bts_id}']['scf_file_path']}
  ${out_lcr_id_list}=  SCFC Create LcrId List  ${cfg.NODES['${bts_id}']['scf_file_path']}
  ${cell_on_tested_ABIO}=  SCFC Create LncelId List For LcrdId List
  ...  ${cfg.NODES['${bts_id}']['scf_file_path']}
  ...  ${out_lcr_id_list}
  ${cell_mode_dict}=  Create Dictionary
  FOR  ${cell}  IN  @{cell_on_tested_ABIO}
    ${distName}=  Get From Dictionary  ${cfg.NODES['${bts_id}']['LNCEL']['${cell}']}  scf_dist_name
    ${cell_mode}=  Run Keyword And Continue On Failure
    ...  Evaluate Xpath
    ...  ${cfg.NODES['${bts_id}']['scf_file_path']}
    ...  string(.//managedObject[@class='NOKLTE:BBPOOLALLOC' and contains (@distName, "${distName}/")]/p[@name="bbPoolAllocMode"])
    ${cell_mode}=  Run Keyword And Continue On Failure  Set Variable If  '${cell_mode}'!='[]'  ${cell_mode}  ${EMPTY}
    Set To Dictionary  ${cell_mode_dict}  ${cell}=${cell_mode}
  END
  Logging With Timestamp
  ...  message=SCFC Get Bbpool Alloc Mode on bts_id node=${bts_id} finished. ${cell_mode_dict}

Get Bbpool Logical Group
  [Arguments]  ${bbmod_sn_cablinks}  ${bts_id}
  ${lg_mode_dict}=  Create Dictionary
  ${abio_list}=  Get Dictionary Keys  ${bbmod_sn_cablinks}
  FOR  ${abio}  IN  @{abio_list}
    ${abio_lncels_dict}=  Get Cell Bbpool Id  ${bbmod_sn_cablinks.${abio}.lncel}  ${bts_id}
    Set To Dictionary  ${lg_mode_dict}  ${abio}=${abio_lncels_dict}
  END
  Logging With Timestamp
  ...  message=SCFC Get Bbpool Alloc Mode on bts_id node=${bts_id} finished. ${lg_mode_dict}
  [Return]  ${lg_mode_dict}

Compare Cell Mapping List For Logical Group Identifier
  [Arguments]  ${lg_mode_dict}  ${cell_mapping}  ${bbmod_sn_cablinks}  ${bts_id}
  ${allocCriterion}  ${allocPriority}=  SCFC Get Alloc First List Value  ${bts_id}
  ${private_bb_list_status}=  Run Keyword And Return Status  Variable Should Exist ${BB_LIST}
  ${abio_list}=  Get Dictionary Keys  ${bbmod_sn_cablinks}
  ${bb_new_list}=  Set Variable If  ${private_bb_list_status} ${BB_LIST}  ${abio_list}
  FOR  ${ABIO}  IN  @{bb_new_list}
    Run Keyword And Continue On Failure
    ...  Run Keyword If
    ...  "${allocPriority}"=="2"
    ...  Run Keywords
    ...  List Should Contain Sub List
    ...  ${cell_mapping.${ABIO}.lncel.lncel_2}
    ...  ${lg_mode_dict['${abio}']['1']}
    ...  AND
    ...  List Should Contain Sub List
    ...  ${cell_mapping.${ABIO}.lncel.lncel_1}
    ...  ${lg_mode_dict['${abio}']['2']}
    ...  AND
    ...  Run Keyword And Ignore Error
    ...  Remove Values From List
    ...  ${cell_mapping.${ABIO}.lncel.lncel_2}
    ...  ${lg_mode_dict['${abio}']['1']}
    ...  AND
    ...  Run Keyword And Ignore Error
    ...  Remove Values From List
    ...  ${cell_mapping.${ABIO}.lncel.lncel_1}
    ...  ${lg_mode_dict['${abio}']['2']}
    Run Keyword And Continue On Failure
    ...  Run Keyword If
    ...  "${allocPriority}"=="1"
    ...  Run Keywords
    ...  List Should Contain Sub List
    ...  ${cell_mapping.${ABIO}.lncel.lncel_2}
    ...  ${lg_mode_dict['${abio}']['2']}
    ...  AND
    ...  List Should Contain Sub List
    ...  ${cell_mapping.${ABIO}.lncel.lncel_1}
    ...  ${lg_mode_dict['${abio}']['1']}
    ...  AND
    ...  Run Keyword And Ignore Error
    ...  Remove Values From List
    ...  ${cell_mapping.${ABIO}.lncel.lncel_2}
    ...  ${lg_mode_dict['${abio}']['2']}
    ...  AND
    ...  Run Keyword And Ignore Error
    ...  Remove Values From List
    ...  ${cell_mapping.${ABIO}.lncel.lncel_1}
    ...  ${lg_mode_dict['${abio}']['1']}
  END

Compare Cell Mapping List For Manual And Logical Group Identifier
  [Arguments]  ${lg_mode_dict}  ${cell_mapping}  ${bbmod_sn_cablinks}  ${bts_id}
  ${alloc_dict}=  SCFC Get Alloc List Value  ${bts_id}
#  ${manual_alloc_cell_list}=  Create manual Alloc Cell List  ${alloc_dict}
#  ${balanced_alloc_cell_list}=  Create manual Alloc Balanced List  ${alloc_dict}
  ${abio_list}=  Get Dictionary Keys  ${bbmod_sn_cablinks}
  FOR  ${abio}  IN  @{abio_list}
    Run Keyword And Continue On Failure
    ...  Run Keyword If
    ...  "${allocPriority}"=="2"
    ...  Run Keywords
    ...  List Should Contain Sub List
    ...  ${cell_mapping['${abio}']['loki_2']}
    ...  ${lg_mode_dict['${abio}']['1']}
    ...  AND
    ...  List Should Contain Sub List
    ...  ${cell_mapping['${abio}']['loki_1']}
    ...  ${lg_mode_dict['${abio}']['2']}
    ...  AND
    ...  Run Keyword And Ignore Error
    ...  Remove Values From List
    ...  ${cell_mapping['${abio}']['loki_2']}
    ...  ${lg_mode_dict['${abio}']['1']}
    ...  AND
    ...  Run Keyword And Ignore Error
    ...  Remove Values From List
    ...  ${cell_mapping['${abio}']['loki_1']}
    ...  ${lg_mode_dict['${abio}']['2']}
    Run Keyword And Continue On Failure
    ...  Run Keyword If
    ...  "${allocPriority}"=="1"
    ...  Run Keywords
    ...  List Should Contain Sub List
    ...  ${cell_mapping['${abio}']['loki_2']}
    ...  ${lg_mode_dict['${abio}']['2']}
    ...  AND
    ...  List Should Contain Sub List
    ...  ${cell_mapping['${abio}']['loki_1']}
    ...  ${lg_mode_dict['${abio}']['1']}
    ...  AND
    ...  Run Keyword And Ignore Error
    ...  Remove Values From List
    ...  ${cell_mapping['${abio}']['loki_2']}
    ...  ${lg_mode_dict['${abio}']['2']}
    ...  AND
    ...  Run Keyword And Ignore Error
    ...  Remove Values From List
    ...  ${cell_mapping['${abio}']['loki_1']}
    ...  ${lg_mode_dict['${abio}']['1']}
  END

SCFC Get Alloc First List Value
  [Arguments]  ${bts_id}
  ${bts_conf}=  Run Keyword And Continue On Failure
  ...  admin_im.query infomodel  get object //MRBTS_A-${bts_id}/LNBTS_A-${bts_id}  alias=${bts_id}
  ${bbPoolAllocPrioList}=  Set Variable  ${bts_conf.bbPoolAllocPrioList}
  ${allocCriterion}=  Get From Dictionary  ${bbPoolAllocPrioList[0]}  allocCriterion
  ${allocPriority}=  Get From Dictionary  ${bbPoolAllocPrioList[0]}  allocPriority
  [Return]  ${allocCriterion}  ${allocPriority}

SCFC Get Alloc List Value
  [Arguments]  ${bts_id}
  ${bts_conf}=  Run Keyword And Continue On Failure
  ...  admin_im.query infomodel  get object //MRBTS_A-${bts_id}/LNBTS_A-${bts_id}  alias=${bts_id}
  ${bbPoolAllocPrioList}=  Set Variable  ${bts_conf.bbPoolAllocPrioList}
  ${list_range}=  Get Length  ${bbPoolAllocPrioList}
  ${alloc_dict}=  Create Dictionary  &{EMPTY}
  FOR  ${item}  IN RANGE  ${list_range}
    ${allocCriterion}=  Get From Dictionary  ${bbPoolAllocPrioList[${item}]}  allocCriterion
    ${allocPriority}=  Get From Dictionary  ${bbPoolAllocPrioList[${item}]}  allocPriority
    ${alloc_item_dict}=  Create Dictionary  &{EMPTY}
    Set To Dictionary  ${alloc_item_dict}  allocCriterion=${allocCriterion}  allocPriority=${allocPriority}
    Set To Dictionary  ${alloc_dict}  position_${item}=${alloc_item_dict}
  END
  [Return]  ${alloc_dict}

Get Cell Bbpool Id
  [Arguments]  ${abio_lncels}  ${bts_id}
  ${lg_1}=  Create List  @{EMPTY}
  ${lg_2}=  Create List  @{EMPTY}
  ${lg_A}=  Create List  @{EMPTY}
  ${tmp_lg_mode_dict}=  Create Dictionary  &{EMPTY}
  FOR  ${cell}  IN  @{abio_lncels}
    ${distName}=  Get From Dictionary  ${cfg.NODES['${bts_id}']['LNCEL']['${cell}']}  scf_dist_name
    ${cell_id}=  Get Cell Id By Configuration Id  LTE  ${cell}  20  alias=${bts_id}
    ${cell_conf_im}=  Run Keyword And Continue On Failure
    ...  admin_im.query infomodel  get object ${cell_id}/CONF_REF-1  alias=${bts_id}
    ${cell_conf_im}=  Run Keyword And Continue On Failure
    ...  admin_im.query infomodel  get object ${cell_conf_im.distName}/BBPOOLALLOC_A-0  alias=${bts_id}
    ${conf_lg_id}=  Set Variable  ${cell_conf_im.bbPoolLogicalGroupId}
    ${conf_lg_id}=  Convert To String  ${conf_lg_id}
    Run Keyword If  '${conf_lg_id}'=='1'
    ...  Append To List  ${lg_1}  ${cell}
    ...  ELSE IF  '${conf_lg_id}'=='2'
    ...  Append To List  ${lg_2}  ${cell}
    ...  ELSE  Append To List  ${lg_A}  ${cell}
  END
  Set To Dictionary  ${tmp_lg_mode_dict}  1=${lg_1}  2=${lg_2}  automatic=${lg_A}
  [Return]  ${tmp_lg_mode_dict}

SCFC Get ABIO Cell List
  [Arguments]  ${scfc_file}
  ${abio_cell_dict}=  Create Dictionary  &{EMPTY}
  ${abio_list}=  Create List  @{EMPTY}
  ${abio_list}=  Evaluate Xpath  ${scfc_file}
  ...  .//managedObject[p[contains(@name, "prodCodePlanned") and contains(text(), "475266A")]]/@distName
  FOR  ${bbmod}  IN  @{abio_list}
    Run Keyword And Continue On Failure  scf.Is Element In Object  dist_name=${bbmod}  p_name=bbCardUsage
    Run Keyword And Continue On Failure  scf.Get All Values From Scf  dist_name=${bbmod}  p_name=bbCardUsage
  END
