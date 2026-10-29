*** Settings ***
Documentation
...  Author:  izabela.wencel@nokia.com
...  Maintainer:  izabela.wencel@nokia.com

Resource  ../tc_scenarios.robot
Resource  ../variables.robot
Resource  ../site_operations.robot
Resource  ./check_linkSpeed_FHS.robot
Resource  ./link_break_resources.robot
Library  ../../../resources/ims2_parser.py

Library  String
Library  Collections
Library  taf.sbts.oam.coam.admin  WITH NAME  admin

*** Variables ***

${swconfig_test}=  /home/ute/MN/UTE/robotlte/testsuite/WMP/GVe/Wroclaw/AiFSiteS/resources/swconfig

*** Keywords ***
FHS Reset
  [Documentation]
  ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-33651
  ...
  ...  *****************
  ...  Basic information
  ...  *****************
  ...  The purpose of this Test Case is to check whether RMODs get back on_air after an FHS reset.
  ...  FHSs will be tested one by one.
  ...  Test line under test may include 1 or more BTSs.
  ...  Test line under test may include 1 or more FHSs.
  ...  Test Case requires setting syncSigTxMode for shared cells to TxDiv for 4003 to be raised.
  ...
  ...  **Input Parameters:**
  ...
  ...  +--------------------------------------------------------------------------+
  ...  | Parameter     | Man.  | Description                                      |
  ...  +=======================+======+===========================================+
  ...  | @{FHS_SNs}    | No    | SN000000001  SN000000002  SN000000003            |
  ...  +-----------------------+------+-------------------------------------------+
  ...  Meaning serial numbers of FHSs in the testline chosen for testing.
  ...  If left empty, ALL FHSs in the testline will be tested
  ...
  ...  ******************
  ...  History of changes
  ...  ******************
  ...  26.09.2023 - Initial creation - https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-33651
  ...  13.02.2024 - Possibility of choosing @{FHS_SNs} and failing historical alarms added - Izabela Wencel
  ...  12.03.2024 - Updates due to ticket https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-45226 - Izabela Wencel

  Set Tags  CA-REC  OWNER-izabela.wencel@nokia.com  AUTHOR-izabela.wencel@nokia.com
  ...  MAINTAINER-izabela.wencel@nokia.com  PHASE-CRT
  ...  FEATURE-CNI-96032
  Logging With Timestamp
  ...  message=FHS Reset: @{CFG.active_bts_list} will be executed
  ...  style=ONGOING
  Common Test Setup
  Preconditions For CNI-127210
  ${release}  admin.Get Sw Release Name  connection=${cfg.primary_node_bts_id}
  ${proper_sw}  Run Keyword If  "${release}"=="SBTS24R3" and ${PRECOND_FOR_CNI}
  ...  Check If Current Build Is Newer Than  SBTS24R3_ENB_0000_000602_000000  alias=${cfg.primary_node_bts_id}
  ...  ELSE IF  ${PRECOND_FOR_CNI}
  ...  Check If Current Build Is Newer Than  SBTS25R1_ENB_9999_240929_000023  alias=${cfg.primary_node_bts_id}
  Run Keyword If   ${proper_sw}  Set Test Variable  ${PRECOND_FOR_CNI}  False

  Execute FHS Reset On Every Node
  Execute Check Link Speed Under FHS On Every Node
  [Teardown]  Common Test Teardown

Execute FHS Reset On Every Node
  step1: FHS Reset Preconditions
  step2: FHS Reset Preparation and Execution

step1: FHS Reset Preconditions
  Log  --------------------${\n}step1: FHS Reset Preconditions${\n}--------------------${\n}  console=True
  @{all_fhs_list}=  Create List
  @{all_fhs_sns}=  Create List
  &{all_items}=  Create Dictionary
  Set Test Variable  ${ALL_ITEMS}  ${all_items}
  @{all_rmods}=  Create List
  Set Test Variable  ${ALL_RMODS}  ${all_rmods}
  FOR  ${bts_node}  IN  @{cfg.NODES}
    ${fhs_list}=  admin.Get FHS List  timeout=1200  connection=${bts_node}
    ${all_fhs_list}=  Combine Lists  ${fhs_list}  ${all_fhs_list}
    Set Test Variable  ${ALL_FHS_LIST}  ${all_fhs_list}
    ${node_items}=  Prepare All Items  ${bts_node}
    Set To Dictionary  ${ALL_ITEMS}  ${bts_node}=${node_items}
    ${rmods}=  admin.Get IDs For All  RMOD  connection=${bts_node}
    ${all_rmods}=  Combine Lists  ${all_rmods}  ${rmods}
    Remove Duplicates  ${all_rmods}
    Append To List  ${all_fhs_sns}  ${cfg.NODES['${bts_node}']['scf_hw_fhs_list']}
    Set Test Variable  ${ALL_FHS_SNS}  ${all_fhs_sns}
  END
  Log  ${all_rmods}  console=True
  Should Not Be Empty  ${ALL_FHS_LIST}  msg=Test Line without FHS. FHS reset cannot be tested on this test line.
  ${fhs_sns_exists}=  Run Keyword And Return Status  Variable Should Exist  ${FHS_SNs}
  ${fhs_sns_not_empty}=  Run Keyword And Return Status  Should Not Be Empty  ${FHS_SNs}
  ${fhs_sns_in_tl}=  Run Keyword And Return Status  Run Keyword If  ${fhs_sns_not_empty}
  ...  List Should Contain Sub List  ${ALL_FHS_SNS[0]}  ${FHS_SNs}
  ...  msg=The SN from the list is not found in the test line. Check variable FHS_SNs.
  @{CHOSEN_FHSS_DICT}=  Create List
  FOR  ${fhs_dict}  IN  @{ALL_FHS_LIST}
    ${fhs_in_the_list}=  Run Keyword If  ${fhs_sns_not_empty}==True and ${fhs_sns_in_tl}==True
    ...  Extract Tested FHSs Serial Numbers  ${fhs_dict}
    Run Keyword If  ${fhs_in_the_list}==False  Continue For Loop
    ...  ELSE  Append To List  ${CHOSEN_FHSS_DICT}  ${fhs_dict}
  END
  Log  ${CHOSEN_FHSS_DICT}  console=True
  Set Test Variable  ${ALL_FHS_LIST}  ${CHOSEN_FHSS_DICT}


step2: FHS Reset Preparation and Execution
  Log  --------------------${\n}step2: FHS Reset${\n}--------------------${\n}  console=True
  FOR  ${fhs}  IN  @{ALL_FHS_LIST}
    Loop Through Chosen FHSs  ${fhs}
  END

Prepare All Items
  [Arguments]  ${tmp_btsid}
  ${smods}=  admin.Get IDs For All  SMOD  connection=${tmp_btsid}
  ${bbmods}=  admin.Get IDs For All  BBMOD  connection=${tmp_btsid}
  ${fhss}=  admin.Get IDs For All  FHS  connection=${tmp_btsid}
  ${rmods}=  admin.Get IDs For All  RMOD  connection=${tmp_btsid}
  ${cells_nr}=  admin.Get IDs For All  NRCEL  connection=${tmp_btsid}
  ${cells_lte}=  admin.Get IDs For All  LNCEL  search_for_iot_cells=${True}  connection=${tmp_btsid}
  ${cells_wcdma}=  admin.Get IDs For All  WNCEL  connection=${tmp_btsid}
  ${cells_gsm}=  admin.Get IDs For All  GNCEL  connection=${tmp_btsid}
  ${node_items}=  Combine Lists
  ...  ${smods}
  ...  ${bbmods}
  ...  ${fhss}
  ...  ${rmods}
  ...  ${cells_nr}
  ...  ${cells_lte}
  ...  ${cells_wcdma}
  ...  ${cells_gsm}
  [Return]  ${node_items}

Extract Tested FHSs Serial Numbers
  [Arguments]  ${fhs}
  ${fhs_in_the_list}=  Set Variable  False
  @{fhs_sns_temp}=  Set Variable  ${FHS_SNs}
  FOR  ${fhs_under_test}  IN  @{fhs_sns_temp}
    Set Test Variable  ${FHS_SN}  ${fhs_under_test}
    Run Keyword If  '${FHS_SN}'!='${fhs['serialNumber']}'  Continue For Loop
    Remove Values From List  ${fhs_sns_temp}  ${fhs_under_test}
    ${fhs_in_the_list}=  Set Variable  True
  END
  [Return]  ${fhs_in_the_list}

Loop Through Chosen FHSs
  [Arguments]  ${fhs}
  Set Start Timestamp In IMS For CNI-127210
  ${mrbts_id}=  Extract Bts Id  ${fhs['id']['runtime']}
  Logging Additional Admin Session Start
  ...  logs_dir_path=${cfg.test_logs_path}/logs_for_autoanalysis
  ...  timeout=120
  ...  connection=fhs_${fhs['serialNumber']}_${mrbts_id}
  ...  bts_id=${mrbts_id}
  Prepare RMOD Connections Dictionary  ${mrbts_id}  ${fhs['serialNumber']}
  ${rmod_affected_chain}=  Prepare List of Affected Chain RMODs  ${cfg}  ${rmod_affected_dn_sn}
  ${list_of_all_affected_rmod_dn}=  Combine Affected RMOD DistNames  ${rmod_affected_dn_sn}  ${rmod_affected_chain}
  ${cells_affected_dn}=  Prepare Cells Connections List  ${mrbts_id}  ${list_of_all_affected_rmod_dn}
  ${all_affected_items}  ${not_affected_items}=  Prepare Lists For IMS Parsing  ${list_of_all_affected_rmod_dn}
  ...  ${cells_affected_dn}  ${fhs}  ${mrbts_id}
  Log  \n----- All affected items:\n ${all_affected_items}  console=True
  Log  \n----- All not affected items:\n ${not_affected_items}  console=True
  ${alarm_status}=  Find Cells Shared Between FHSs  ${cells_affected_dn}  ${mrbts_id}
  ...  ${rmod_affected_dn_sn}
  Log  \n----- FHS ${fhs['serialNumber']} ${fhs['id']['internal']} reset started ----\n  console=True
  ${reset_status}=  Run Keyword And Return Status
  ...  admin.Reset Unit  ${fhs['id']['runtime']}  timeout=300  connection=${mrbts_id}
  Run Keyword If  ${reset_status}  Log To Console  Reset FHS successful  ELSE  Run Keywords
  ...  Log To Console  Reset FHS failed
  ...  AND  Fail  Reset FHS failed
  admin.Assert Every  FHS  operationalState=regex"(?i)Enabled"  timeout=50  connection=${mrbts_id}
  Verify Multi BTS State
  Sleep  30  waiting for 4003 to be cleared
  Verify Whether 4589 Allowed  ${rmod_affected_dn_sn.values()}  ${mrbts_id}
  Verify Alarms On All Nodes
  Verify Unexpected And Historical Alarms  alias=${mrbts_id}
  ${temp_historic_alarms_list}=  admin.Get Alarm History
  ...  connection=fhs_${fhs['serialNumber']}_${mrbts_id}
  ...  detailed_output=True
  Run Keyword If  ${alarm_status}  Verify Alarms 4003  ${temp_historic_alarms_list}
  Run Keyword If  ${alarm_status} and ${PRECOND_FOR_CNI}  Check Active Fault In IMS For CNI-127210  fault_id=4003  severity=Minor
  admin.Collect Infomodel Log From Current Session
  ...  ${cfg.test_logs_path}/logs_for_autoanalysis/InfoModel_fhs_${fhs['serialNumber']}.ims2
  ...  connection=fhs_${fhs['serialNumber']}_${mrbts_id}
  Calculate KPI53a  ${cfg.test_logs_path}/logs_for_autoanalysis/InfoModel_fhs_${fhs['serialNumber']}.ims2
  Check availabilityStatus For Affected And Not Affected Items  ${all_affected_items}  ${not_affected_items}
  ...  ${cfg.test_logs_path}/logs_for_autoanalysis/InfoModel_fhs_${fhs['serialNumber']}.ims2
  [Teardown]  Run Keyword And Ignore Error  Teardown Admin  alias=fhs_${fhs['serialNumber']}_${mrbts_id}

Prepare RMOD Connections Dictionary
  [Arguments]  ${mrbts_id}  ${fhs_sn}
  ${sfp_links}=  admin.Get Sfp Links  connection=${mrbts_id}
  Find RMOD Relations  ${sfp_links}  ${fhs_sn}

Find RMOD Relations
  [Arguments]  ${sfp_links}  ${fhs_sn}
  &{rmod_affected_dn_sn}=  Create Dictionary
  Set Test Variable  ${RMOD_AFFECTED_DN_SN}  ${rmod_affected_dn_sn}
  FOR  ${link}  IN  @{sfp_links['connected']}
    Continue For Loop If  "${fhs_sn}"!="${link['parent']['destination']['parameters']['serialNumber']}"
    Set To Dictionary  ${rmod_affected_dn_sn}
    ...  ${link['parent']['source']['distName']}=${link['parent']['source']['parameters']['serialNumber']}
  END

Prepare List of Affected Chain RMODs
  [Arguments]  ${cfg}  ${rmod_affected_dn_sn}
  @{all_rf_chaining_list}=  Create List
  FOR  ${ru_item}  IN  @{rmod_affected_dn_sn.values()}
    ${chain_rmod_affected_list}=  Get From Dictionary  ${cfg.RF_INFO['${ru_item}']}  scf_chain_fr_affected_list
    ${chain_status}=  Run Keyword And Return Status  Should Not Be Empty  ${chain_rmod_affected_list}
    ${single_rf_chaining_list}=  Run Keyword If  ${chain_status}  Prepare RMOD in Chain distName List
    ...  ${chain_rmod_affected_list}
    ...  ELSE  Create List
    ${all_rf_chaining_list}=  Combine Lists  ${all_rf_chaining_list}  ${single_rf_chaining_list}
  END
  [Return]  ${all_rf_chaining_list}

Prepare RMOD in Chain distName List
  [Arguments]  ${chain_rmod_affected_list}
  @{chaining_list}=  Create List
  FOR  ${ru_sn}  IN  @{chain_rmod_affected_list}
    ${ru_bts_id}  ${ru_dist_name}=  Get RU Node Data  ${ru_sn}
    Append To List  ${chaining_list}  ${ru_dist_name}
  END
  [Return]  ${chaining_list}

Combine Affected RMOD DistNames
  [Arguments]  ${rmod_affected_dn_sn}  ${rmod_affected_chain}
  ${rmod_affected_dn}=  Get Dictionary Keys  ${rmod_affected_dn_sn}
  ${list_of_affected_rmod_dn}=  Combine Lists  ${rmod_affected_dn}  ${rmod_affected_chain}
  ${list_of_all_affected_rmod_dn}=  Remove Duplicates  ${list_of_affected_rmod_dn}
  [Return]  ${list_of_all_affected_rmod_dn}

Prepare Cells Connections List
  [Arguments]  ${mrbts_id}  ${list_of_all_affected_rmod_dn}
  ${cells_affected_dn}=  Find Cells Relations  ${list_of_all_affected_rmod_dn}  ${mrbts_id}
  [Return]  ${cells_affected_dn}

Find Cells Relations
  [Arguments]  ${rmod_affected_dn}  ${mrbts_id}
  ${cells_affected_dn}=  Create List
  FOR  ${rmod}  IN  @{rmod_affected_dn}
    ${cells_affected}=  admin.Get Cell Mapping By Module ID  ${rmod}  connection=${mrbts_id}
    ${cells_affected_dn}=  Combine Lists  ${cells_affected_dn}  ${cells_affected}
  END
  Remove Duplicates  ${cells_affected_dn}
  [Return]  ${cells_affected_dn}

Prepare Lists For IMS Parsing
  [Arguments]  ${list_of_all_affected_rmod_dn}  ${cells_affected_dn}  ${fhs}  ${mrbts_id}
  @{all_items_copy}=  Copy List  ${all_items['${mrbts_id}']}
  @{all_affected_items}=  Combine Lists  ${list_of_all_affected_rmod_dn}  ${cells_affected_dn}
  Append To List  ${all_affected_items}  ${fhs['id']['internal']}
  FOR  ${affected_item}  IN  @{all_affected_items}
    Remove Values From List  ${all_items_copy}  ${affected_item}
  END
  [Return]  ${all_affected_items}  ${all_items_copy}

Find Cells Shared Between FHSs
  [Arguments]  ${cells_affected_dn}  ${mrbts_id}  ${rmod_affected_dn_sn}
  FOR  ${cell_affected_dn}  IN  @{cells_affected_dn}
    ${info_cell}=  admin.Get Cell Specific Info  ${cell_affected_dn}  connection=${mrbts_id}
    ${cell_technology}  ${cell_physical_id}=  Extract Cell Technology And PhysicalId  ${info_cell}
    ${cell_rmods_count}=  Get Length
    ...  ${cfg.NODES['${mrbts_id}']['${cell_technology}']['${cell_physical_id}']['scf_ru_list']}
    Run Keyword If  ${cell_rmods_count}==1  Continue For Loop
    ${status_fid_4003}=  Get SerialNumber of RMODs With Shared Cells
    ...  ${mrbts_id}
    ...  ${cell_technology}
    ...  ${cell_physical_id}
    ...  ${rmod_affected_dn_sn}
    Return From Keyword If  ${status_fid_4003}  ${TRUE}
  END
  Return From Keyword  ${FALSE}

Extract Cell Technology And PhysicalId
  [Arguments]  ${info_cell}
  ${cell_id}=  Fetch From Right  ${info_cell['id']['configuration']}  marker=/
  ${cell_technology_temp}=  Fetch From Left  ${cell_id}  marker=-
  ${cell_technology}=  Get Substring  ${cell_technology_temp}  0  5
  ${cell_physical_id}=  Fetch From Right  ${cell_id}  marker=-
  [Return]  ${cell_technology}  ${cell_physical_id}

Get SerialNumber of RMODs With Shared Cells
  [Arguments]  ${mrbts_id}  ${cell_technology}  ${cell_physical_id}  ${list_of_all_affected_rmod_dn}
  @{temp_list_of_rmods_for_shared_cells}=  Create List
  FOR  ${dn_of_affected_rmod}  IN  @{list_of_all_affected_rmod_dn}
    ${rmod_param}=  admin.Get Parameters  ${dn_of_affected_rmod}  connection=${mrbts_id}
    ${rmod_sn}=  Set Variable  ${rmod_param['serialNumber']}
    ${cell_tech_lower}=  Convert To Lower Case  ${cell_technology}
    ${cell_tech_id}=  Set Variable  scf_cellid_primary
    ${cells_ids}=  Set Variable  ${cfg.RF_INFO['${rmod_sn}']['${cell_technology}']['${cell_tech_id}']}
    ${status}=  Run Keyword and Return Status  List Should Contain Value  ${cells_ids}  ${cell_physical_id}
    Run Keyword If  ${status}  Append To List  ${temp_list_of_rmods_for_shared_cells}  ${rmod_sn}
    ...  ELSE  Continue For Loop
    Log  ${temp_list_of_rmods_for_shared_cells}  console=True
    ${rmods_count}=  Get Length  ${temp_list_of_rmods_for_shared_cells}
    Run Keyword If  ${rmods_count}==2  Return From Keyword  ${FALSE}
  END
  ${status_fid_4003}=  Set Variable If  ${rmods_count}==1  ${TRUE}
  [Return]  ${status_fid_4003}

Verify Whether 4589 Allowed
  [Arguments]  ${all_affected_rmods_sns}  ${ru_bts_id}
  FOR  ${affected_rmod_sn}  IN  @{all_affected_rmods_sns}
    ${unexpected_historical_alarms_list}=  admin.Get Unexpected Historical Alarms  connection=${ru_bts_id}
    Run Keyword If  ${unexpected_historical_alarms_list} is not None
    ...  Check For Alarm 4589  ${ru_bts_id}  ${affected_rmod_sn}  ${unexpected_historical_alarms_list}
  END

Verify Alarms 4003
  [Arguments]  ${temp_historic_alarms_list}
  ${alarm_4003_found}=  Set Variable  ${FALSE}
  FOR  ${alarm}  IN  @{temp_historic_alarms_list['requestMessage']}[0]
    Continue For Loop If  '${alarm['additionalFaultID']}'!='4003'
    ${alarm_4003_found}=  Set Variable  ${TRUE}
    Exit For Loop
  END
  Run Keyword If  ${alarm_4003_found}  Log to Console  FID 4003 Found - success
  ...  ELSE  Run Keywords  Log To Console  FID 4003 Not Found - test failed
  ...  AND  Fail  FID 4003 Not Found - test failed
