*** Settings ***
Documentation  Maintainers: @I_SRAN_PROD_SISO_WRO_CRTDEV_GMS

Resource    ../Resources/Setup/setup_and_teardown.robot
Resource  ./variables.robot


Library  BuiltIn
Library  Collections
Library  String
Library  robot.libraries.DateTime
Library  taf.sbts.oam.coam.admin    WITH NAME    admin
Library  ute_admin_infomodel    WITH NAME    admin_im

Resource    ./Test_Cases/RFV_cs.robot
Resource    ./Test_Cases/PIMC_cs.robot
Resource    ./site_operations.robot
Resource    ./site_verifications.robot
Resource    ./common_setup.robot




*** Variables ***
&{RU_MHA}=    L123456=30

*** Keywords ***

Automated SiSo_Antenna Line Management_Overcurrent_alarm_with_MHA
  [Documentation]
  ...  Purpose of this test is checking if RET unit is correctly detected
  ...
  ...  Parameters:
  ...  Name  |  Mandatory  |  Default value  |  Description
  ...  test_logs_path  |  no  |  cfg.test_logs_path  |  Path to test logs
  ...
  Common Test Setup
  SiSo_Antenna Line Management_Overcurrent_alarm_with_MHA
  [Teardown]  Common Test Teardown

SiSo_Antenna Line Management_Overcurrent_alarm_with_MHA
  Create CS MHA Related Variables For RFV
  Set Overcurrent Variables  ${RU_UNDER_TEST_SERIAL_NUMBER}
  ${ru_bts_id}  ${ru_dist_name}=  Get RU Node Data  ${RU_UNDER_TEST_SERIAL_NUMBER}
  FR Should Reach OnAir  fr_serial_number=${RU_UNDER_TEST_SERIAL_NUMBER}
  ...  fr_lncel_id_list=${FR_INFO['${RU_UNDER_TEST_SERIAL_NUMBER}']['lncel_id_list']}
  ...  alias=${TC_ALIAS}
  Check MHA Mode And Availability
  Set FEG and LNA Related Values
  LNA And FEG Value With MHA Should Be Correct
  Overcurrent Alarm Is Generated Via MHA
  Alarm 1836 Is Present  fr_lcr_id_list=${FR_INFO['${RU_UNDER_TEST_SERIAL_NUMBER}']['cell_list']}
  MHA Should Be In Operational State  Disabled
  LNA And FEG Value Without MHA Should Be Correct
  Perform RU Block  ${ru_bts_id}  ${RU_UNDER_TEST_SERIAL_NUMBER}  ${ru_dist_name}  90
  Perform RU Unblock  ${ru_bts_id}  ${RU_UNDER_TEST_SERIAL_NUMBER}  ${ru_dist_name}  360
  Alarm 1836 Is Present  fr_lcr_id_list=${FR_INFO['${RU_UNDER_TEST_SERIAL_NUMBER}']['cell_list']}
  MHA Should Be In Operational State  Disabled
  LNA And FEG Value Without MHA Should Be Correct
  Remove Short Circuit From Bias-T
  Perform RU Block  ${ru_bts_id}  ${RU_UNDER_TEST_SERIAL_NUMBER}  ${ru_dist_name}  90
  Perform RU Unblock  ${ru_bts_id}  ${RU_UNDER_TEST_SERIAL_NUMBER}  ${ru_dist_name}  360
  MHA Should Be In Operational State  Enabled
  LNA And FEG Value With MHA Should Be Correct
  Overcurrent Alarm Is Generated Via MHA
  Alarm 1836 Is Present  fr_lcr_id_list=${FR_INFO['${RU_UNDER_TEST_SERIAL_NUMBER}']['cell_list']}
  MHA Should Be In Operational State  Disabled
  LNA And FEG Value Without MHA Should Be Correct
  Reset BTS And Wait Until FR Is Available  alias=${TC_ALIAS}
  Alarm 1836 Is Present  fr_lcr_id_list=${FR_INFO['${RU_UNDER_TEST_SERIAL_NUMBER}']['cell_list']}
  MHA Should Be In Operational State  Disabled
  LNA And FEG Value Without MHA Should Be Correct
  Remove Short Circuit From Bias-T
  Reset BTS And Wait Until FR Is Available  alias=${TC_ALIAS}
  Alarm 1836 Is Not Present
  MHA Should Be In Operational State  Enabled
  LNA And FEG Value With MHA Should Be Correct
  FR Should Reach OnAir  fr_serial_number=${RU_UNDER_TEST_SERIAL_NUMBER}
  ...  fr_lncel_id_list=${FR_INFO['${RU_UNDER_TEST_SERIAL_NUMBER}']['lncel_id_list']}
  ...  alias=${TC_ALIAS}
  Verify Alarms  alias=${TC_ALIAS}
  [Teardown]  MHA PDU Off  ${MHA_TYPE}  ${MHA_IP}  ${MHA_PORT}

Create CS MHA Related Variables For RFV
  ${ru_bts_id}  ${ru_dist_name}=  Get RU Node Data  ${CUSTOM_RADIO_UNIT_LIST}[0]
  Verify Unexpected And Historical Alarms
  ...  alias=${ru_bts_id}
  Set Overcurrent Variables  ${CUSTOM_RADIO_UNIT_LIST}[0]
  Set Test Variable  ${BTS_ID}  ${ru_bts_id}
  Set Test Variable  ${scfc_file_path}  ${CFG['NODES']['${ru_bts_id}']['scf_file_path']}
  Set Test Variable  ${SCFC_REFERENCE_FILE_PATH}  ${CFG['NODES']['${ru_bts_id}']['scf_file_path']}
  Set Test Variable  ${RU_UNDER_TEST_SERIAL_NUMBER}  ${CUSTOM_RADIO_UNIT_LIST}[0]
  Set Test Variable  ${TC_ALIAS}  ${ru_bts_id}
  ${act_category_alarms}=  Get From Dictionary  ${cfg.NODES['${BTS_ID}']}  scf_alarms_category
  Set Test Variable  ${ACT_CATEGORY_ALARMS}  ${act_category_alarms}
  Optimized RF Variant Preparation  alias=${ru_bts_id}
  Set Alarm Information Dictionary  ${RU_UNDER_TEST_SERIAL_NUMBER}  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}

SiSo__FV_Testing_MHA_status
  ${ru_bts_id}  ${ru_dist_name}=  Get RU Node Data  ${RU_UNDER_TEST_SERIAL_NUMBER}
  Set Test Variable  ${BTS_ID}  ${ru_bts_id}
  Info Model Check MHA Quantity, States And Properties For FR Serial Number
  ...  fr_serial_number=${RU_UNDER_TEST_SERIAL_NUMBER}
  ...  scfc_file_path=${cfg['NODES']['${ru_bts_id}']['scf_file_path']}
  ...  alias=${ru_bts_id}
  Check Front End Gain For FR Serial Number
  ...  fr_serial_number=${RU_UNDER_TEST_SERIAL_NUMBER}
  ...  scfc_file_path=${cfg['NODES']['${ru_bts_id}']['scf_file_path']}
  ...  logs_dir_path=${TEST_LOGS_DIR_PATH}
  ...  feg_without_mha=${RU_MHA['${RU_UNDER_TEST_SERIAL_NUMBER}']}
  ...  alias=${ru_bts_id}

Info Model Check MHA Quantity, States And Properties For FR Serial Number
  [Arguments]  ${fr_serial_number}  ${scfc_file_path}  ${alias}=default
  ${ref_rmod_id}=  SCFC Get RmodId For FR Serial Number  ${scfc_file_path}  ${fr_serial_number}
  ${ref_rmod_antl_list}=  SCFC Create Antl List For RmodId  ${scfc_file_path}  ${ref_rmod_id}
  ${ref_mha_properties_list}=  SCFC Create MHA Properties List For FR Serial Number
  ...  ${scfc_file_path}
  ...  ${fr_serial_number}
  ${ref_mha_serial_number_list}=  SCFC Create Unique MHA Serial Number List For FR Serial Number
  ...  ${scfc_file_path}
  ...  ${fr_serial_number}
  Log
  ...  Reference SCFC file (btsId ${BTS_ID}) contains definition of FR's MHA(s): ${ref_mha_serial_number_list}
  ...  console=yes
  ${ru_bts_id}  ${ru_dist_name}=  Get RU Node Data  ${fr_serial_number}
  Info Model MHAs From List Should Be Online And Operational
  ...  ${ref_mha_serial_number_list}
  ...  timeout=120
  ...  alias=${alias}
  ${act_mha_properties_list}=  Info Model LNAs Of MHA List Should Be Online, Configured And Enabled
  ...  ${ref_mha_serial_number_list}  ${ref_mha_properties_list}  alias=${alias}
  MHA Actual Properties Should Match Reference
  ...  actual_values=${act_mha_properties_list}
  ...  reference_values=${ref_mha_properties_list}
  [Return]  ${act_mha_properties_list}

SCFC Create MHA Properties List For FR Serial Number
  [Arguments]  ${scfc_file_path}  ${fr_serial_number}  ${feg}=False
  ${antl_dist_name_list}=  Create List
  ${lna_dist_name_list}=  Create List
  ${mha_properties_list}=  Create List
  ${rmod_id}=  SCFC Get RmodId For FR Serial Number  ${scfc_file_path}  ${fr_serial_number}
  ${antl_list}=  SCFC Create Antl List For RmodId  ${scfc_file_path}  ${rmod_id}
  FOR  ${antl}  IN  @{antl_list}
    ${object_1}=  Set Variable
    ...  .//managedObject[@class="com.nokia.srbts.eqm:ANTL" and contains(@distName, "/ANTL-${antl}")
    ${object_2}=  Set Variable
    ...  and contains(@distName, "RMOD-${rmod_id}/") and substring-after(@distName, "/ANTL-${antl}")=""]/@distName
    ${sum_object}=  Set Variable  ${object_1} ${object_2}
    ${antl_dist_name}=  Evaluate Xpath  ${scfc_file_path}
    ...  ${sum_object}
    Append To List  ${antl_dist_name_list}  @{antl_dist_name}
  END
  FOR  ${antl_dist_name}  IN  @{antl_dist_name_list}
    ${object_1}=  Set Variable
    ...  .//managedObject[@class="com.nokia.srbts.eqm:LOGLINK" and p[@name="secondEndpointDN"]="${antl_dist_name}"]
    ${object_2}=  Set Variable  /p[@name="firstEndpointDN" and (contains(text(), "/LNA-"))]/text()
    ${sum_object}=  Set Variable  ${object_1}${object_2}
    ${first_end_point_dn_list}=  Evaluate Xpath  ${scfc_file_path}
    ...  ${sum_object}
    ${object_1}=  Set Variable
    ...  .//managedObject[@class="com.nokia.srbts.eqm:LOGLINK" and p[@name="firstEndpointDN"]="${antl_dist_name}"]
    ${object_2}=  Set Variable  /p[@name="secondEndpointDN" and (contains(text(), "/LNA-"))]/text()
    ${sum_object}=  Set Variable  ${object_1}${object_2}
    ${second_end_point_dn_list}=  Evaluate Xpath  ${scfc_file_path}
    ...  ${sum_object}
    Append To List  ${lna_dist_name_list}  @{first_end_point_dn_list}
    Append To List  ${lna_dist_name_list}  @{second_end_point_dn_list}
    ${lna_dist_name_list}=  Remove Duplicates  ${lna_dist_name_list}
  END
  FOR  ${lna_dist_name}  IN  @{lna_dist_name_list}
    ${ald_dist_name}=  Should Match Regexp  ${lna_dist_name}  .*ALD-\\d+
    ${mha_serial_number}=  Evaluate Xpath
    ...  ${scfc_file_path}
    ...  string(.//managedObject[@class="com.nokia.srbts.eqm:ALD" and @distName="${ald_dist_name}"]/p[@name="serialNumber"])
    ${mha_prod_code}=  Evaluate Xpath
    ...  ${scfc_file_path}
    ...  string(.//managedObject[@class="com.nokia.srbts.eqm:ALD" and @distName="${ald_dist_name}"]/p[@name="productCode"])
    ${mha_gain}=  Evaluate Xpath  ${scfc_file_path}
    ...  string(.//managedObject[@class="com.nokia.srbts.eqm:LNA" and @distName="${lna_dist_name}"]/p[@name="gain"])
    ${mha_lna}=  Should Match Regexp  ${lna_dist_name}  LNA-(\\d+)
    ${object_1}=  Set Variable
    ...  string(.//managedObject[@class="com.nokia.srbts.eqm:LOGLINK" and p[@name="secondEndpointDN"]
    ${object_2}=  Set Variable
    ...  ="${lna_dist_name}" and p[@name="linkModeData"]="true"]/p[@name="firstEndpointDN" and (contains(text(), "ANTL-"))]/text())
    ${sum_object}=  Set Variable  ${object_1}${object_2}
    ${first_end_point_dn}=  Evaluate Xpath  ${scfc_file_path}
    ...  ${sum_object}
    ${object_1}=  Set Variable
    ...  string(.//managedObject[@class="com.nokia.srbts.eqm:LOGLINK" and p[@name="firstEndpointDN"]
    ${object_2}=  Set Variable
    ...  ="${lna_dist_name}" and p[@name="linkModeData"]="true"]/p[@name="secondEndpointDN" and (contains(text(), "ANTL-"))]/text())
    ${sum_object}=  Set Variable  ${object_1}${object_2}
    ${second_end_point_dn}=  Evaluate Xpath  ${scfc_file_path}
    ...  ${sum_object}
    ${end_point_dn}=  Set Variable  ${first_end_point_dn}${second_end_point_dn}
    ${ant_id}=  Evaluate Xpath
    ...  ${scfc_file_path}
    ...  string(.//managedObject[@class="com.nokia.srbts.eqm:ANTL" and @distName="${end_point_dn}"]/p[@name="antPortId"])
    ${mha_serial_number}=  Convert To String  ${mha_serial_number}
    ${mha_lna_number}=  Evaluate Xpath
    ...  ${scfc_file_path}
    ...  string(.//managedObject[@class="com.nokia.srbts.eqmr:LNA_R" and p[@name="configDN"]="${lna_dist_name}"]/p[@name="subunitNumber"])
    ${mha_prod_code}=  Convert To String  ${mha_prod_code}
    ${mha_gain}=  Run Keyword If  '${mha_gain}'!=''  Convert To Integer  ${mha_gain}
    ${mha_is_active}=  Convert To Boolean  True
    ${ant_id}=  Convert To String  ${ant_id}
    ${mha_antl_id}=  Should Match Regexp  ${end_point_dn}  ANTL-(\\d+)
    ${mha_property}=  Run Keyword If  "${feg}" != "True"
    ...  Create Dictionary  serNum=${mha_serial_number}
    ...  lnaNumber=${mha_lna_number}
    ...  prodCode=${mha_prod_code}
    ...  mhaGain=${mha_gain}
    ...  active=${mha_is_active}
    ...  ELSE  Create Dictionary  serNum=${mha_serial_number}
    ...  lnaNumber=${mha_lna_number}
    ...  antId=ANT${ant_id}
    ...  antl=${mha_antl_id[1]}
    Run Keyword If  '${mha_serial_number}'!=''  Append To List  ${mha_properties_list}  ${mha_property}
  END
  [Return]  ${mha_properties_list}

Info Model LNAs Of MHA List Should Be Online, Configured And Enabled
  [Arguments]  ${mha_serial_number_list}  ${mha_nodes_list}  ${timeout}=5  ${alias}=default
  ${mha_properties}=  create list
  FOR  ${mha_serial_number}  IN  @{mha_serial_number_list}
    ${mha_properties_tmp}=  create list
    ${mha_properties_tmp}=  Info Model LNAs Of MHA Should Be Online, Configured And Enabled
    ...  mha_serial_number=${mha_serial_number}
    ...  mha_nodes_list=${mha_nodes_list}
    ...  timeout=${timeout}
    ...  alias=${alias}
    append to list  ${mha_properties}  @{mha_properties_tmp}
  END
  [Return]  ${mha_properties}

Create MHA Properties List Based On MHA And LNA Nodes List
  [Arguments]  ${mha_node_list}  ${lna_node_list}  ${lna_number_object}  ${alias}=default
  ${mha_properties_list}=  create list
  ${mha_serial_number}=  convert to string  ${mha_node_list[0]['serialNumber']}
  ${mha_product_code}=  convert to string  ${mha_node_list[0]['productCode']}
  ${mha_is_active}=  Info Model Is MHA Active  ${mha_node_list[0]}  alias=${alias}
  FOR  ${lna_node}  IN  @{lna_node_list}
    ${lna_number}=  Convert To String  ${lna_node['${lna_number_object}']}
    ${lna_number}=  Strip String  ${lna_number}  characters=LNA
    ${lna_gain}=  Evaluate  int(${lna_node['gain']}*100)
    ${mha_property}=  Create Dictionary  serNum=${mha_serial_number}
    ...  lnaNumber=${lna_number}
    ...  prodCode=${mha_product_code}
    ...  mhaGain=${lna_gain}
    ...  active=${mha_is_active}
    append to list  ${mha_properties_list}  ${mha_property}
  END
  [Return]  ${mha_properties_list}

Info Model Is MHA Active
  [Documentation]  Returns boolean describing if MHA is active (that is if it has a separate cabling for power and data flow)
  ...  Author:
  ...  Maintainer:  Author
  [Arguments]  ${mha_node}  ${alias}=default
  ${mha_is_active_1}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${mha_node}  active
  ${mha_is_active_2}=  Run Keyword And Return Status
  ...  admin_im.Query Infomodel
  ...  query=/MRBTS-1/RAT-1//APEQM_A-*/ALD_A-* is [serialNumber="${mha_node['serialNumber']}", controlProtocol=regex"AISG(...)"]
  ...  alias=${alias}
  ${mha_is_active}=  Set Variable If  ${mha_is_active_1} or ${mha_is_active_2}  True  False
  ${mha_is_active}=  Convert To Boolean  ${mha_is_active}
  [Return]  ${mha_is_active}

MHA Actual Properties Should Match Reference
  [Arguments]  ${actual_values}  ${reference_values}
  ${mha_actual_count}=  get length  ${actual_values}
  run keyword if  '${mha_actual_count}'=='0'  LOG  ! There are no active MHA devices  level=WARN
  ${actual_values}=  evaluate  sorted($actual_values, key=lambda x: x['serNum'])
  ${reference_values}=  evaluate  sorted($reference_values, key=lambda x: x['serNum'])
  lists should be equal  ${actual_values}  ${reference_values}
  ...  msg=Actual MHA(s) Properties differ from the ones from reference SCFC - Test FAILED
  LOG  + Actual MHA(s) Properties match the ones from reference SCFC  console=yes

Info Model LNAs Of MHA Should Be Online, Configured And Enabled
  [Arguments]  ${mha_serial_number}  ${mha_nodes_list}  ${timeout}=5  ${alias}=default
  ${mha_properties}=  create list
  ${mha_object}=  Info Model Get MHA Object Name  ${mha_serial_number}  alias=${alias}
  ${mha_node_list}=  admin_im.Query Infomodel  query=get list //EQM_L-1/${mha_object} is [serialNumber="${mha_serial_number}"]
  ...  timeout=${timeout}
  ...  alias=${alias}
  ${mha_dist_name}=  Get From Dictionary  ${mha_node_list}[0]  dist_name
  ${lna_list_for_mha}=  Create LnaNumber List for MHA Serial Number
  ...  mha_nodes_list=${mha_nodes_list}
  ...  mha_serial_number=${mha_serial_number}
  ${lna_number_object}=  Info Model Check LNA Number Object Name  ${mha_dist_name}  alias=${alias}
  FOR  ${lna_number}  IN  @{lna_list_for_mha}
    ${lna_number}=  Strip String  ${lna_number}  characters=LNA
    ${mha_properties_tmp}=  create list
    ${object_1}=  Set Variable
    ...  query=get list ${mha_dist_name}/LNA_L-* is [${lna_number_object}=regex"\\b${lna_number}",
    ${object_2}=  Set Variable
    ...  stateInfo.availabilityStatus=Online, stateInfo.proceduralState=regex"Configured|Configuring|Initialized",
    ${object_2}=  Set Variable  stateInfo.operationalState=Enabled]
    ${sum_object}=  Set Variable  ${object_1} ${object_2} ${object_2}
    ${lna_node_list}=  admin_im.Query Infomodel  ${sum_object}
    ...  timeout=${timeout}  alias=${alias}
    LOG  + FR's MHA ${mha_serial_number} ${lna_number} is in Online, Configured and Enabled state  console=yes
    ${mha_properties_tmp}=  Create MHA Properties List Based On MHA And LNA Nodes List
    ...  mha_node_list=${mha_node_list}
    ...  lna_node_list=${lna_node_list}
    ...  lna_number_object=${lna_number_object}
    ...  alias=${alias}
    append to list  ${mha_properties}  @{mha_properties_tmp}
  END
  [Return]  ${mha_properties}

Info Model Check LNA Number Object Name
  [Documentation]  Returns object that stores lna number, depending on SW release.
  ...  Author:
  ...  Maintainer:  Author
  [Arguments]  ${mha_dist_name}  ${alias}=default
  ${lna_number_is_stored_in_lnanumber}=  Run Keyword And Return Status
  ...  admin_im.Query Infomodel  query=${mha_dist_name}/LNA_L-* is [lnaNumber!=empty]  alias=${alias}
  ${lna_number_is_stored_in_id}=  Run Keyword And Return Status
  ...  admin_im.Query Infomodel  query=${mha_dist_name}/LNA_L-* is [subunitNumber!=empty]  alias=${alias}
  ${lna_number_object}=  Set Variable If  ${lna_number_is_stored_in_lnanumber}  lnaNumber
  ${lna_number_object}=  Set Variable If  ${lna_number_is_stored_in_id}  subunitNumber
  [Return]  ${lna_number_object}

Check Front End Gain For FR Serial Number
  [Arguments]
  ...  ${fr_serial_number}
  ...  ${scfc_file_path}
  ...  ${logs_dir_path}
  ...  ${feg_without_mha}
  ...  ${timeout}=5
  ...  ${alias}=default
  ${logs_dir_path}=  Set Variable  ${logs_dir_path}
  ${ref_rmod_id}=  SCFC Get RmodId For FR Serial Number  ${scfc_file_path}  ${fr_serial_number}
  ${ref_rmod_antl_list}=  SCFC Create Antl List For RmodId  ${scfc_file_path}  ${ref_rmod_id}
  ${ref_mha_properties_list}=  SCFC Create MHA Properties List For FR Serial Number
  ...  ${scfc_file_path}
  ...  ${fr_serial_number}
  ...  feg=True
  ${fr_ip_addr}=  Info Model Get IP For FR Serial Number  ${fr_serial_number}  alias=${alias}
  ${rmod_a_id}=  Info Model Get SRAN RMOD_A Id For FR Serial Number  ${fr_serial_number}  alias=${alias}
  FOR  ${element}  IN  @{ref_mha_properties_list}
    ${lna_id}=  Strip String  ${element['lnaNumber']}  characters=LNA
    ${rmod_a_antl_node}=  admin_im.Query Infomodel  query=get object //RMOD_A-${rmod_a_id}/ANTL_A-${element['antl']}
    ...  timeout=${timeout}  alias=${alias}
    ${antenna_total_loss_object}=  Get Matches  ${rmod_a_antl_node}  regexp=[AnteaT]*otalLoss.*
    ${feg_of_ant_id}=  FR Get Front End Gain For FR AntId  ${fr_ip_addr}  ${element['antId']}  alias=${alias}
    ${mha_object}=  Info Model Get MHA Object Name  ${element['serNum']}  alias=${alias}
    ${mha_node_list}=  admin_im.Query Infomodel  query=get list //EQM_L-1/${mha_object} is [serialNumber="${element['serNum']}"]
    ...  timeout=${timeout}  alias=${alias}
    ${mha_dist_name}=  Convert To String  ${mha_node_list[0]['dist_name']}
    ${lna_number_object}=  Info Model Check LNA Number Object Name  ${mha_dist_name}  alias=${alias}
    ${lna_node_list}=  admin_im.Query Infomodel
    ...  query=get list ${mha_dist_name}/LNA_L-* is [${lna_number_object}=regex"\\b${lna_id}"]
    ...  timeout=${timeout}
    ...  alias=${alias}
    ${act_feg_computed}=  evaluate
    ...  ${feg_of_ant_id}+${lna_node_list[0]['gain']}-abs(${rmod_a_antl_node.${antenna_total_loss_object[0]}})
    run keyword and continue on failure  Compare Front End Gain Values  fr_serial_number=${fr_serial_number}
    ...  feg_computed=${act_feg_computed}
    ...  feg_without_mha=${feg_without_mha}
    ...  mha_node=${element}
  END

Info Model Get SRAN RMOD_A Id For FR Serial Number
  [Documentation]  Returns RMOD_A Id ("x" from "RMOD_A-x") of the first found //RMOD_A-* IM node that matches given FR serial number.
  ...  Author:
  ...  Maintainer:
  [Arguments]  ${fr_serial_number}  ${timeout}=5  ${alias}=default
  ${out_rmod_dist_name}=  Info Model Get Rmod DistName For FR Serial Number  ${fr_serial_number}  alias=${alias}
  ${out_rmod_r_node}=  admin_im.Query Infomodel  query=get object //RMOD_R-*/REF-1 is [distName="${out_rmod_dist_name}"]
  ...  timeout=${timeout}  alias=${alias}
  ${out_rmod_r_id}=  Should Match Regexp  ${out_rmod_r_node.dist_name}  RMOD_R-(\\d+)
  ${out_rmod_a_node}=  admin_im.Query Infomodel  query=get object //RMOD_R-${out_rmod_r_id[1]}
  ...  timeout=${timeout}  alias=${alias}
  ${out_rmod_a_id}=  Should Match Regexp  ${out_rmod_a_node.configDN}  RMOD_A-(\\d+)
  [Return]  ${out_rmod_a_id[1]}

Compare Front End Gain Values
  [Documentation]  Compares two values of Fron End Gain. Dictionary ${mha_node} should consist of 'serNum', 'antId' and 'lnaNumber' keys.
  [Arguments]  ${fr_serial_number}  ${feg_computed}  ${feg_without_mha}  ${mha_node}
  ${object_1}=  Set Variable
  ...  Total FEG For FR=${fr_serial_number} ${mha_node['antId']} with MHA=${mha_node['serNum']} ${mha_node['lnaNumber']}
  ${object_2}=  Set Variable  is ${feg_computed} whilst expected is ${feg_without_mha} - Test FAILED
  ${sum_object}=  Set Variable  ${object_1}${object_2}
  should be equal as numbers  ${feg_computed}  ${feg_without_mha}
  ...  msg=${sum_object}
  LOG
  ...  + Total FEG For FR=${fr_serial_number} ${mha_node['antId']} before and after connecting MHA is equal to ${feg_without_mha}
  ...  console=yes

########################################################################################################################
####################################################  R E T ############################################################
########################################################################################################################

Check RET RF status
  ${ru_bts_id}  ${ru_dist_name}=  Get RU Node Data  ${RU_UNDER_TEST_SERIAL_NUMBER}
  Set Test Variable  ${BTS_ID}  ${ru_bts_id}
  ${REF_RET_PROPERTIES}=  SCFC Get RET Properties For FR
  ...  ${RU_UNDER_TEST_SERIAL_NUMBER}
  ...  ${cfg['NODES']['${ru_bts_id}']['scf_file_path']}
  Info Model RETs Should Be Online And Working
  ...  ${REF_RET_PROPERTIES}
  ...  alias=${ru_bts_id}
  ${ACT_RET_PROPERTIES}=  Info Model Get RET Properties For FR
  ...  ${RU_UNDER_TEST_SERIAL_NUMBER}
  ...  alias=${ru_bts_id}
  RET Actual Properties Should Match Reference
  ...  ${ACT_RET_PROPERTIES}
  ...  ${REF_RET_PROPERTIES}

SCFC Get RET Properties For FR
  [Arguments]  ${fr_serial_number}  ${scfc_file_path}
  OperatingSystem.File Should Exist  ${scfc_file_path}
  ${ret_list}=  SCFC Create RET Serial Number List For FR Serial Number  ${scfc_file_path}  ${fr_serial_number}
  ${ret_properties}=  SCFC Create RET Properties Dict For RET Serial Number List  ${scfc_file_path}  ${ret_list}
  LOG  + Reference SCFC file contains definition of FR's RETs: ${ret_list}  console=yes
  [Return]  ${ret_properties}

SCFC Create RET Properties Dict For RET Serial Number List
  [Arguments]  ${scfc_file_path}  ${ret_serial_number_list}
  ${result}=  Evaluate Xpath  ${scfc_file_path}  boolean(.//managedObject[@class="RET"])
  ${ret_properties_list}=  SCFC Create RET Properties Dict For RET Serial Number List New
  ...  ${scfc_file_path}
  ...  ${ret_serial_number_list}
  [Return]  ${ret_properties_list}

SCFC Create RET Properties Dict For RET Serial Number List New
  [Arguments]  ${scfc_file_path}  ${ret_serial_number_list}
  ${ret_properties}=  Create Dictionary
  FOR  ${ret_serial_number}  IN  @{ret_serial_number_list}
  ...  ${ret_prod_code}=
  ...  Evaluate Xpath
  ...  ${scfc_file_path}
  ...  string(.//managedObject[@class="com.nokia.srbts.eqm:ALD" and p[@name="serialNumber"]="${ret_serial_number}"]/p[@name="productCode"])
  ...  ${ald_dist_name}=
  ...  Evaluate Xpath
  ...  ${scfc_file_path}
  ...  string(.//managedObject[@class="com.nokia.srbts.eqm:ALD" and p[@name="serialNumber"]='${ret_serial_number}']/@distName)
  ...  ${first_end_point_dn}=
  ...  Evaluate Xpath
  ...  ${scfc_file_path}
  ...  string(.//managedObject[@class="com.nokia.srbts.eqm:LOGLINK" and p[@name="secondEndpointDN"]="${ald_dist_name}"]/p[@name="firstEndpointDN"])
  ...  ${second_end_point_dn}=
  ...  Evaluate Xpath
  ...  ${scfc_file_path}
  ...  string(.//managedObject[@class="com.nokia.srbts.eqm:LOGLINK" and p[@name="firstEndpointDN"]="${ald_dist_name}"]/p[@name="secondEndpointDN"])
    ${end_point_dn}=  Set Variable  ${first_end_point_dn}${second_end_point_dn}
    ${ant_port_id}=  Evaluate Xpath
    ...  ${scfc_file_path}
    ...  string(.//managedObject[@class="com.nokia.srbts.eqm:ANTL" and @distName="${end_point_dn}"]/p[@name="antPortId"])
    ${ret_property}=  Create Dictionary  serNum=${ret_serial_number}
    ...  prodCode=${ret_prod_code}
    Set To Dictionary  ${ret_properties}  ANT${ant_port_id}  ${ret_property}
  END
  [Return]  ${ret_properties}

Info Model RETs Should Be Online And Working
  [Arguments]  ${ret_properties_reference_dict}  ${alias}=default
  ${keys}=  Get Dictionary Keys  ${ret_properties_reference_dict}
  FOR  ${ret}  IN  @{keys}
    ${ret_serial_number}=  Get From Dictionary
    ...  ${ret_properties_reference_dict['${ret}']}
    ...  serNum
    ${ret_node_set}=   admin_im.Get Infomodel Object
    ...  //BTS_L-*/EQM_L-1/ALD_L-* is [serialNumber="${ret_serial_number}"]
    ...  alias=${alias}
    admin_im.Query Infomodel
    ...  query=${ret_node_set.dist_name} is [stateInfo.availabilityStatus=Online, stateInfo.operationalState=Enabled]
    ...  alias=${alias}
    ...  timeout=120
    admin_im.Query Infomodel
    ...  query=${ret_node_set.dist_name}/RETU_L-1 is [stateInfo.availabilityStatus=Online, stateInfo.operationalState=Enabled]
    ...  alias=${alias}
    ...  timeout=120
    LOG  + FR's RET ${ret_serial_number} is in Online and Enabled state  console=yes
  END

Info Model Get RET Properties For FR
  [Arguments]  ${fr_serial_number}  ${alias}=default
  ${ret_list}=  Info Model Get RET Nodes List For FR Serial Number  ${fr_serial_number}  alias=${alias}
  ${ret_properties}=  Info Model Create RET Properties Dict For RET Nodes List  ${ret_list}  alias=${alias}
  [Return]  ${ret_properties}

Info Model Create RET Properties Dict For RET Nodes List
  [Arguments]  ${ret_dist_name_list}  ${alias}=default
  ${ret_properties}=  Create Dictionary
  FOR  ${ret_dist_name}  IN  @{ret_dist_name_list}
    ${ret_node}=  admin_im.Get Infomodel Object  ${ret_dist_name}  alias=${alias}
    ${ret_serial_number}=  Set Variable  ${ret_node.serialNumber}
    ${ret_prod_code}=  Set Variable  ${ret_node.productCode}
    ${ret_antl_id}=  Info Model Get RET Physical Antl Id  ${ret_dist_name}  alias=${alias}
    ${ret_property}=  Create Dictionary  serNum=${ret_serial_number}
    ...  prodCode=${ret_prod_code}
    Set To Dictionary  ${ret_properties}  ${ret_antl_id}  ${ret_property}
  END
  [Return]  ${ret_properties}

Info Model Get RET Physical Antl Id
  [Arguments]  ${ret_dist_name}  ${alias}=default
  ${ald_ref}=  admin_im.Get Infomodel Object
  ...  //RUNTIME_VIEW-*/MRBTS_R-*/EQM_R-*/APEQM_R-*/ALD_R-*/REF-1 is [distName=${ret_dist_name}]  alias=${alias}
  ${ald_r_dist_name}=  Replace String Using Regexp  ${ald_ref.dist_name}  /REF-1  ${EMPTY}
  ${status_1}=  Run Keyword And Return Status  admin_im.Get Infomodel Object
  ...  //EQM_R-*/HWTOP_R-*/LOGLINK_R-* is [firstEndpointDN=${ald_r_dist_name}, linkModeDC=true]  alias=${alias}
  ${ald_connector_r_object}=  Run Keyword If
  ...  '${status_1}'=='True'
  ...  admin_im.Get Infomodel Object
  ...  //EQM_R-*/HWTOP_R-*/LOGLINK_R-* is [firstEndpointDN=${ald_r_dist_name}, linkModeDC=true]
  ...  timeout=1
  ...  alias=${alias}
  ...  ELSE
  ...  admin_im.Get Infomodel Object
  ...  //EQM_R-*/HWTOP_R-*/LOGLINK_R-* is [secondEndpointDN=${ald_r_dist_name}, linkModeDC=true]
  ...  timeout=1
  ...  alias=${alias}
  ${ret_physical_antl_r_distname}=  Set Variable If  '${status_1}'=='True'
  ...  ${ald_connector_r_object.secondEndpointDN}
  ...  ${ald_connector_r_object.firstEndpointDN}
  ${ret_connector_object}=  admin_im.Get Infomodel Object  ${ret_physical_antl_r_distname}/ANTL_CONF_M-1  alias=${alias}
  [Return]  ANT${ret_connector_object.antPortId}

RET Actual Properties Should Match Reference
  [Arguments]  ${actual_values}  ${reference_values}
  ${ret_actual_count}=  Get Length  ${actual_values}
  Run Keyword If  '${ret_actual_count}'=='0'  LOG  ! There are no active RET devices  level=WARN
  Dictionaries Should Be Equal  ${actual_values}  ${reference_values}
  ...  msg=Actual RET(s) Properties differ from the ones from reference SCFC - Test FAILED
  LOG  + RET(s) Online match RET(s) in template SCFC - Test PASSED  console=yes

########################################################################################################################
#################################################### O V E R C U R R E N T #############################################
########################################################################################################################

Check MHA Mode And Availability
  Check MHA Mode
  Check MHA Availability  regex"Online|None"

Check MHA Mode
  Run Keyword And Continue On Failure
  ...  admin_im.Query Infomodel
  ...  query=/MRBTS-*/RAT-*/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-*/EQM_A-*/APEQM_A-*/ALD_A-* is [controlProtocol=regex"AISG(...)"]
  ...  timeout=120
  ...  alias=${TC_ALIAS}
  Log To Console  MHA is in correct, AISG mode

Check MHA Availability
  [Arguments]  ${availability_status}
  ${ald_l_id}=  admin_im.Query Infomodel
  ...  query=get object /MRBTS-*/RAT-*/BTS_L-*/EQM_L-*/ALD_L-* is [deviceType="MHA"]
  ...  alias=${TC_ALIAS}
  ${ald_l_id}=  Fetch From Right  ${ald_l_id.dist_name}  -
  Set Test Variable  ${ALD_ID}  ${ald_l_id}
  Run Keyword And Continue On Failure
  ...  admin_im.Query Infomodel Parallel
  ...  query1=/MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/EQM_R-*/APEQM_R-*/ALD_R-${ALD_ID} is [stateInfo.availabilityStatus=${availability_status}]
  ...  query2=/MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/EQM_R-*/APEQM_R-*/ALD_R-${ALD_ID} is [availabilityStatus=${availability_status}]
  ...  assertion_method=any
  ...  alias=${TC_ALIAS}
  ...  timeout=120

Overcurrent Alarm Is Generated Via MHA
  MHA PDU ON  ${MHA_TYPE}  ${MHA_IP}  ${MHA_PORT}

Alarm 1836 Is Present
  [Arguments]  ${fr_lcr_id_list}
  ${cell_count}=  Get Length  ${fr_lcr_id_list}
  ${fault_1836_count}=  Set Variable If  ${ACT_CATEGORY_ALARMS}  1  ${cell_count}
  Info Model Wait For Alarm  fault_id=1836
  ...  fault_count=${fault_1836_count}
  ...  timeout=200
  ...  act_category_alarms=${ACT_CATEGORY_ALARMS}
  ...  alias=${TC_ALIAS}

Alarm 1836 Is Not Present
  Info Model Wait For Alarm  fault_id=1836
  ...  fault_count=0
  ...  timeout=200
  ...  act_category_alarms=${ACT_CATEGORY_ALARMS}
  ...  alias=${TC_ALIAS}

MHA Should Be In Operational State
  [Arguments]  ${operational_state}
  Run Keyword And Continue On Failure
  ...  admin_im.Query Infomodel Parallel
  ...  query1=/MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/EQM_R-*/APEQM_R-*/ALD_R-${ALD_ID} is [stateInfo.operationalState=${operational_state}]
  ...  query2=/MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/EQM_R-*/APEQM_R-*/ALD_R-${ALD_ID} is [operationalState=regex"(?i)${operational_state}"]
  ...  assertion_method=any
  ...  timeout=120
  ...  alias=${TC_ALIAS}

Remove Short Circuit From Bias-T
  MHA PDU Off  ${MHA_TYPE}  ${MHA_IP}  ${MHA_PORT}

LNA And FEG Value With MHA Should Be Correct
  ${lna_val_mha}=  Evaluate  ${TOTAL_GAIN}-${GAIN}+${TOTAL_LOSS}
  ${lna_val_mha}=  Convert To Integer  ${lna_val_mha}
  ${MHA_LNA}=  Convert To Integer  ${MHA_LNA}
  Run Keyword And Continue On Failure  Should Be Equal  ${MHA_FEG}  ${FEG_WITH_MHA}
  Run Keyword And Continue On Failure  Should Be Equal  ${lna_val_mha}  ${MHA_LNA}

LNA And FEG Value Without MHA Should Be Correct
  ${lna_val_mha}=  Evaluate  ${TOTAL_GAIN}+${TOTAL_LOSS}
  ${lna_val_mha}=  Convert To Integer  ${lna_val_mha}
  ${WITHOUT_MHA_LNA}=  Convert To Integer  ${WITHOUT_MHA_LNA}
  Run Keyword And Continue On Failure  Should Be Equal  ${WITHOUT_MHA_FEG}  ${FEG_GAIN_VAL_WITHOUT_MHA}
  Run Keyword And Continue On Failure  Should Be Equal  ${lna_val_mha}  ${WITHOUT_MHA_LNA}

Set FEG and LNA Related Values
  [Arguments]  ${alias}=default
  ${alias}=  Set Variable  ${alias}
  ${rmod_l_id}=  Info Model Get Rmod Id For FR Serial Number  ${RU_UNDER_TEST_SERIAL_NUMBER}  alias=${TC_ALIAS}
  ${rmod_a_id}=  Info Model Get SRAN RMOD_A Id For FR Serial Number  ${RU_UNDER_TEST_SERIAL_NUMBER}  alias=${TC_ALIAS}
  ${fr_parameters}=  admin_im.Query Infomodel
  ...  query=get list /MRBTS-*/RAT-*/BTS_L-*/EQM_L-*/RMOD_L-${rmod_l_id}/RU_L-*/LNARU_L-1
  ...  timeout=120
  ...  alias=${TC_ALIAS}
  ${lna_parameters}=  admin_im.Query Infomodel  query=get list /MRBTS-*/RAT-*/BTS_L-*/EQM_L-*/ALD_L-${ALD_ID}/LNA_L-*
  ...  timeout=120  alias=${TC_ALIAS}
  ${ant_parameters}=  admin_im.Query Infomodel
  ...  query=get list /MRBTS-*/RAT-*/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-*/EQM_A-*/APEQM_A-*/RMOD_A-${rmod_a_id}/ANTL_A-*
  ...  timeout=120
  ...  alias=${TC_ALIAS}
  ${total_gain1}=  Get From List  ${fr_parameters}  0
  ${total_gain}=  Get From Dictionary  ${total_gain1}  totalGain
  ${external_gain}=  Get From Dictionary  ${total_gain1}  externalGain
  ${gain}=  Get From List  ${lna_parameters}  0
  ${gain}=  Get From Dictionary  ${gain}  gain
  ${total_loss}=  Get From List  ${ant_parameters}  0
  ${total_loss}=  Get From Dictionary  ${total_loss}  totalLoss
  Convert To Integer  ${gain}
  Convert To Integer  ${total_gain}
  Convert To Integer  ${external_gain}
  Convert To Integer  ${total_loss}
  ${feg_gain_val_without_mha}=  Evaluate  ${gain}+${total_gain}
  Set Test Variable  ${TOTAL_GAIN}  ${total_gain}
  Set Test Variable  ${FEG_WITH_MHA}  ${TOTAL_GAIN}
  Set Test Variable  ${FEG_GAIN_VAL_WITHOUT_MHA}  ${feg_gain_val_without_mha}
  Set Test Variable  ${EXTERNAL_GAIN}  ${external_gain}
  Set Test Variable  ${GAIN}  ${gain}
  Set Test Variable  ${TOTAL_LOSS}  ${total_loss}


MHA PDU ON
  [Arguments]    ${MHA_TYPE}  ${MHA_IP}  ${MHA_PORT}
  pdu.Setup Pdu
  ...  model=${MHA_TYPE}
  ...  host=${MHA_IP}
  ...  alias=pdu
  pdu.Power On
  ...  port=${MHA_PORT}
  ...  pdu_device=pdu
  pdu.Teardown Pdu  pdu_device=pdu


MHA PDU Off
  [Arguments]    ${MHA_TYPE}  ${MHA_IP}  ${MHA_PORT}
  pdu.Setup Pdu
  ...  model=${MHA_TYPE}
  ...  host=${MHA_IP}
  ...  alias=pdu
  pdu.Power Off
  ...  port=${MHA_PORT}
  ...  pdu_device=pdu
  pdu.Teardown Pdu  pdu_device=pdu
