*** Settings ***
Documentation  Maintainers: @I_SRAN_PROD_SISO_WRO_CRTDEV_GMS
...  Library contains keywords for creating logical description.

Library    Collections
Library    OperatingSystem
Library    Process
Library    DateTime
Library    SSHLibrary
Library    String

Resource  ./../Robot/scfc.robot
Resource  ./../../../resources/bts_scfc.robot

*** Keywords ***

Define Each Node Logical Description Based On Reference Files
  [Documentation]
  ...  Description:
  ...  Prepares logical description of each BTS ID from testing set of configuration. It add to CFG variable detailed description of cell setup,
  ...   radio and other units relations.
  ...  In case configuration was described the variable  ${CFG_CREATION_NOT_NEEDED} disable this kewyword.
  ...  In case there is no need to make Hardware refactoring by variable ${RECONFIGURATION_NOT_NEEDED}, it also will be disbaled.
  ...  In situation it is the first testcase in suite, keyword will be  executed. This is control by  ${CFG_CREATION_NOT_NEEDED}.
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  Return From Keyword If  ${RECONFIGURATION_NOT_NEEDED} and ${CFG_CREATION_NOT_NEEDED}
  Set to Dictionary  ${CFG}  RF_INFO=&{EMPTY}
  Set to Dictionary  ${CFG}  ASIR_INFO=&{EMPTY}
  Prepare Reference File Parameters
  Prepare Reference File Parameters For Radios
  Combine NR NSA cells with thier LTE parents cells
  [Teardown]  Create RMOD Under Test List

Prepare Reference File Parameters For Radios
  [Documentation]  KW for preparing Radio units (RMOD/ASIRMOD) information from specific BTS ID. KW also supports RF sharing.
  FOR  ${bts_id}  IN  @{CFG.NODES}
    ${full_neighbour_dict}=  Prepare Neighbour Dictionary For RUs  ${bts_id}
    ${chain_affected_dict}=  Prepare Chain Affested Dictionary For RUs  ${full_neighbour_dict}
    Set Test Variable  ${CHAIN_AFFECTED_DICT}  ${chain_affected_dict}
    Get Configured RMOD Relation On ${bts_id} Node
    Get Configured ASIRMOD Relation On ${bts_id} Node
  END
Prepare Reference File Parameters
  [Documentation]
  ...  Description:
  ...  Prepares logical description of specific BTS ID from testing set of configuration. It add to CFG variable detailed description of cell setup,
  ...  radio and other units relations.
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com
  FOR  ${bts_id}  IN  @{CFG.NODES}
    Parse SCF File To Variable   ${cfg.NODES['${bts_id}']}
    ${node_cfg}=  Get SCFC Serial Numbers lists To Dictionary  ${cfg.NODES['${bts_id}']}
    SCF Prepare Configuration Description  ${cfg.NODES['${bts_id}']}
    Count HW On Node  ${bts_id}
  END

Current Configuration Check DualCore
  [Arguments]  ${scf_file_path}
  [Documentation]
  ...  Description:
  ...  Check if configuration is fullrack, Returns boolean status for fullrack, active and passive sm serial number for each SM in fullrack
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | scfc_file_path         | Yes  | Path to scf file                                                   |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  ${smod_count_tmp}=  Evaluate Xpath  ${scf_file_path}  count(.//managedObject[@class="com.nokia.srbts.eqmr:SMOD_R"])
  ${smod_count_tmp}=  Convert To Integer  ${smod_count_tmp}
  ${smod_role_types}=  Evaluate Xpath  ${scf_file_path}
  ...  .//managedObject[@class="com.nokia.srbts.eqmr:SMOD_R"]/p[@name="activeRole"]/text()
  ${dualcore}=  Set Variable If  'Secondary' in ${smod_role_types}  True  False
  ${active_sm}=  Run Keyword If  ${dualcore}
  ...  Get Element Text  ${scf_file_path}
  ...  xpath=//managedObject[@class='com.nokia.srbts.eqmr:SMOD_R'][p[@name="activeRole"]='Primary']/p[@name="serialNumber"]
  ...  ELSE   Get Element Text  ${scf_file_path}
  ...  xpath=//managedObject[@class='com.nokia.srbts.eqmr:SMOD_R']/p[@name="serialNumber"]
  ${passive_sm}=  Run Keyword If   ${dualcore}
  ...  Get Element Text  ${scf_file_path}
  ...  xpath=//managedObject[@class='com.nokia.srbts.eqmr:SMOD_R'][p[@name="activeRole"]='Secondary']/p[@name="serialNumber"]
  [Return]  ${dualcore}  ${active_sm}  ${passive_sm}

Create RMOD Under Test List
  [Documentation]
  ...  Description:
  ...  Check if RF key was provided by setup keyword. It defines specific radio unit for testing purpose
  ...  and set it to CFG variable as rmods_under_test   key
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  ${rmod_status}=  Run Keyword And Return Status  Get from dictionary  ${cfg}  RF
  ${rmods_under test}=  Run keyword If  ${rmod_status}==True  Set Variable  ${cfg['RF']}
  ...  ELSE  Set Variable  ${cfg['scf_hw_all_fr_list']}
  Set to Dictionary  ${cfg}  scf_rmods_under_test  ${rmods_under test}

Parse SCF File To Variable
  [Arguments]  ${node_cfg}
  [Documentation]
  ...  Description:
  ...  Parse scf file as variable to be used as scf source. Such method speed up parsing process.
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | node_cfg               | Yes  | specific dictionary from BTS ID                                    |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  ${parsed_scf}  Parse XML  ${node_cfg.scf_file_path}
  Set To Dictionary  ${node_cfg}  parsed_scf=${parsed_scf}

Get SCFC Serial Numbers lists To Dictionary
  [Arguments]  ${node_cfg}
  [Documentation]
  ...  Description:
  ...  Check Serial number of each object in scf and set it to specific NODE dictionary.
  ...  Creates list of all object from all BTS ID's and add its to main CFG variable level
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | node_cfg               | Yes  | specific dictionary from BTS ID                                    |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  ${hw_fr_sn_list}=  SCFC Create FR Serial Number List  ${node_cfg.parsed_scf}
  ${hw_fhs_sn_list}=  SCFC Create FHS Serial Number List  ${node_cfg.parsed_scf}
  ${hw_bbmod_sn_list}=  SCFC Create BBMOD Serial Number List  ${node_cfg.parsed_scf}
  ${hw_sm_sn_list}=  SCFC Create SM Serial Number List  ${node_cfg.parsed_scf}
  ${hw_asir_sn_list}=  SCFC Create ASIRMOD Serial Number List  ${node_cfg.parsed_scf}
  ${hw_ald_sn_list}=  SCFC Create ALD Serial Number List  ${node_cfg.parsed_scf}
  Set To Dictionary  ${node_cfg}
  ...  scf_hw_sm_list=${hw_sm_sn_list}
  ...  scf_hw_fr_list=${hw_fr_sn_list}
  ...  scf_hw_bbmod_list=${hw_bbmod_sn_list}
  ...  scf_hw_fhs_list=${hw_fhs_sn_list}
  ...  scf_hw_asir_list=${hw_asir_sn_list}
  ...  scf_hw_ald_list=${hw_ald_sn_list}
  ${sm_list_status}=  Run Keyword And Return Status  Variable Should Exist  ${cfg.scf_hw_all_sm_list}
  ${fr_list_status}=  Run Keyword And Return Status  Variable Should Exist  ${cfg.scf_hw_all_fr_list}
  ${bbmod_list_status}=  Run Keyword And Return Status  Variable Should Exist  ${cfg.scf_hw_all_bbmod_list}
  ${fhs_list_status}=  Run Keyword And Return Status  Variable Should Exist  ${cfg.scf_hw_all_fhs_list}
  ${asir_list_status}=  Run Keyword And Return Status  Variable Should Exist  ${cfg.scf_hw_all_asir_list}
  ${ald_list_status}=  Run Keyword And Return Status  Variable Should Exist  ${cfg.scf_hw_all_ald_list}
  ${tmp_sm_list}=  Create List  @{hw_sm_sn_list}
  ${tmp_fr_list}=  Create List  @{hw_fr_sn_list}
  ${tmp_bbmod_list}=  Create List  @{hw_bbmod_sn_list}
  ${tmp_fhs_list}=  Create List  @{hw_fhs_sn_list}
  ${tmp_asir_list}=  Create List  @{hw_asir_sn_list}
  ${tmp_ald_list}=  Create List  @{hw_ald_sn_list}
  Run Keyword If  ${sm_list_status}
  ...  Append To List  ${tmp_sm_list}  @{CFG.scf_hw_all_sm_list}
  Run Keyword If  ${fr_list_status}
  ...  Append To List  ${tmp_fr_list}  @{CFG.scf_hw_all_fr_list}
  Run Keyword If    ${bbmod_list_status}
  ...  Append To List  ${tmp_bbmod_list}  @{CFG.scf_hw_all_bbmod_list}
  Run Keyword If  ${fhs_list_status}
  ...  Append To List  ${tmp_fhs_list}  @{CFG.scf_hw_all_fhs_list}
  ${tmp_sm_list}=  Remove Duplicates  ${tmp_sm_list}
  ${tmp_fr_list}=  Remove Duplicates  ${tmp_fr_list}
  ${tmp_bbmod_list}=  Remove Duplicates  ${tmp_bbmod_list}
  ${tmp_fhs_list}=  Remove Duplicates  ${tmp_fhs_list}
  ${tmp_asir_list}=  Remove Duplicates  ${tmp_asir_list}
  ${tmp_ald_list}=  Remove Duplicates  ${tmp_ald_list}
  Set To Dictionary  ${CFG}
  ...  scf_hw_all_sm_list=${tmp_sm_list}
  ...  scf_hw_all_fr_list=${tmp_fr_list}
  ...  scf_hw_all_bbmod_list=${tmp_bbmod_list}
  ...  scf_hw_all_fhs_list=${tmp_fhs_list}
  ...  scf_hw_all_asir_list=${tmp_asir_list}
  ...  scf_hw_all_ald_list=${tmp_ald_list}
  [Return]     ${node_cfg}

SCF Prepare Configuration Description
  [Arguments]  ${cfg}
  [Documentation]
  ...  Description:
  ...  Get active nodeId value from configuration file
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | cfg                    | Yes  | specific dictionary from BTS ID, it contains sub dictionary        |
  ...  |                        |      | for particular  BTS ID, cfg here is local dictionary.              |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  Get BTS Configured Parameters  ${cfg}
  Get Configured RAT's  ${cfg}
  Get Configured CELL For Each RAT  ${cfg}
  Log Dictionary  ${cfg}

Get BTS Configured Parameters
  [Arguments]  ${cfg}
  [Documentation]
  ...  Description:
  ...  Gather from scf file specific configuration parmaeters:
  ...  active node = 1 or 4
  ...  bts_id = MRBTS id
  ...  alarms category
  ...  hw_release = Airscale, FSMF
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | cfg                    | Yes  | specific dictionary from BTS ID, it contains sub dictionary        |
  ...  |                        |      | for particular  BTS ID, cfg here is local dictionary.              |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  ${active_node}=  SCFC Get Airscale Active NodeId  ${cfg.parsed_scf}
  ${bts_id}=  SCFC Get BtsId  ${cfg.parsed_scf}
  ${alarms_category}=  SCFC Get Activate Category Alarms Value  ${cfg.parsed_scf}
  ${hw_release}=  SCFC Get Enb Hw Release  ${cfg.parsed_scf}
  Set To Dictionary  ${cfg}  scf_active_node=${active_node}
  ...  scf_bts_id=${bts_id}
  ...  scf_alarms_category=${alarms_category}
  ...  scf_hw_release=${hw_release}
  [Return]  ${cfg}

Get Configured RAT's
  [Arguments]  ${cfg}
  [Documentation]
  ...  Description:
  ...  Check which RAT is defianed in specific BTS ID. IN case of LTE also FDD or TDD are checked
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | cfg                    | Yes  | specific dictionary from BTS ID, it contains sub dictionary        |
  ...  |                        |      | for particular  BTS ID, cfg here is local dictionary.              |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  ${lte_configured}=  SCF Check LTE Existence  ${cfg.parsed_scf}
  ${wcdma_configured}=  SCF Check WCDMA Existence  ${cfg.parsed_scf}
  ${gsm_configured}=  SCF Check GSM Existence  ${cfg.parsed_scf}
  ${nr_configured}=  SCF Check 5G Existence  ${cfg.parsed_scf}
  ${fdd_result}  ${tdd_result}=  Run Keyword If  ${lte_configured}
  ...  SCF Check LTE Variant  ${cfg.parsed_scf}
  ${lte_variant}=  Set Variable If  ${fdd_result} and not ${tdd_result}  fdd
  ...  not ${fdd_result} and ${tdd_result}  tdd
  ...  ${fdd_result} and ${tdd_result}  both
  Set To Dictionary  ${cfg}  scf_lte=${lte_configured}
  ...  scf_wcdma=${wcdma_configured}
  ...  scf_gsm=${gsm_configured}
  ...  scf_nr=${nr_configured}
  ...  scf_lte_variant=${lte_variant}
  [Return]  ${cfg}

Get Configured CELL For Each RAT
  [Arguments]  ${cfg}
  [Documentation]
  ...  Description:
  ...  GAther parameters for all cells from each RAT, also provides information about number of all cells.
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | cfg                    | Yes  | specific dictionary from BTS ID, it contains sub dictionary        |
  ...  |                        |      | for particular  BTS ID, cfg here is local dictionary.              |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  Set To Dictionary  ${CFG}  scf_cell_count=&{EMPTY}
  SCF Get LTE Cell Parameters  ${cfg.parsed_scf}  ${cfg}
  SCF Get WCDMA Cell Parameters  ${cfg.parsed_scf}  ${cfg}
  SCF Get GSM Cell Parameters  ${cfg.parsed_scf}  ${cfg}
  SCF Get 5G Cell Parameters  ${cfg.parsed_scf}  ${cfg}
  ${site_cell_count}=  Evaluate  ${cfg.scf_cell_count.LTE}+${cfg.scf_cell_count.WCDMA}+${cfg.scf_cell_count.GSM}+${cfg.scf_cell_count.NR}
  Set To Dictionary  ${cfg.scf_cell_count}  ALL=${site_cell_count}

Get Configured ${class} Relation On ${bts_id} Node
  [Documentation]
  ...  Description:
  ...  Check Radio units information from specific BTS ID. Gathers information about cell, other RU relations
  ...  variant, software release.
  ...  Allowed "class" argument are RMOD/ASIRMOD
  ...  "bts_id" argument is aa ID of current BTS
  ...
  ...  Author: daniel.bartkowiak@nokia.com
  ...  Maintainer: daniel.bartkowiak@nokia.com

  ${mod_sn_list}=  Set Variable If  "${class}"=="RMOD"  ${cfg.NODES['${bts_id}']['scf_hw_fr_list']}  ${cfg.NODES['${bts_id}']['scf_hw_asir_list']}
  FOR  ${serial_number}  IN  @{mod_sn_list}
    ${mod_exists_cfg}=  Run Keyword If  "${class}"=="RMOD"
	...  Run Keyword And Return Status  Dictionary Should Contain Key  ${cfg['RF_INFO']}  ${serial_number}
	...  ELSE
	...  Run Keyword And Return Status  Dictionary Should Contain Key  ${cfg['ASIR_INFO']}  ${serial_number}
    Continue For Loop If  ${mod_exists_cfg}
    ${scfc}=  Set Variable  ${cfg.NODES['${bts_id}']['parsed_scf']}
    ${fr_info}=  Create Dictionary
    ${sharing_status}=  SCFC Get RF Sharing Status  ${scfc}  ${serial_number}  ${class}
    ${fr_dist_name}=  Run Keyword If  ${sharing_status}
	...  SCFC Get RF DistName For Serial Number When Rfsharing  ${serial_number}  ${class}
    ...  ELSE
	...  SCFC Get RMOD DistName For FR Serial Number  ${scfc}  ${serial_number}
    ${fr_btsid}=  Run Keyword If  ${sharing_status}
	...  Get Bts Ids For FR When Rfsharing  ${fr_dist_name}
	...  ELSE  Set Variable  ${bts_id}
    ${fr_cablinks}=  Run Keyword If  ${sharing_status}
	...  SCFC Get Cablink DistNames For FR When Rfsharing  ${fr_dist_name}
    ...  ELSE
	...  SCFC Get Cablink DistName For FR Serial Number  ${scfc}  ${serial_number}  ${class}
    ${variant}=  SCFC Get Product Name For FR Serial Number  ${scfc}  ${serial_number}
    ${release_code}=  SCFC Get Product Release Code For FR Serial Number  ${scfc}  ${serial_number}
    ${lte_cells}=  Run Keyword If  ${sharing_status}
	...  Get FR Cells Info When Rfsharing  ${fr_dist_name}  ${fr_btsid}  LNCEL
    ...  ELSE
	...  Get RMOD LNCEL Cells Info  ${fr_dist_name}  ${cfg.NODES['${bts_id}']}  ${scfc}
    ${wcdma_cells}=  Run Keyword If  ${sharing_status}
	...  Get FR Cells Info When Rfsharing  ${fr_dist_name}  ${fr_btsid}  WNCEL
    ...  ELSE
	...  Get RMOD WNCEL Cells Info  ${fr_dist_name}  ${cfg.NODES['${bts_id}']}  ${scfc}
    ${gsm_cells}=  Run Keyword If  ${sharing_status}
	...  Get FR Cells Info When Rfsharing  ${fr_dist_name}  ${fr_btsid}  GNCEL
    ...  ELSE
	...  Get RMOD GSM Cells Info  ${serial_number}  ${fr_dist_name}  ${cfg.NODES['${bts_id}']}  ${scfc}
    ${5g_cells}=  Run Keyword If  ${sharing_status}
	...  Get FR Cells Info When Rfsharing  ${fr_dist_name}  ${fr_btsid}  NRCEL
    ...  ELSE
	...  Get RMOD NRCEL Cells Info  ${fr_dist_name}  ${cfg.NODES['${bts_id}']}  ${scfc}
    Set To Dictionary  ${fr_info}  scf_rfsharing  ${sharing_status}
    Run Keyword If  ${sharing_status}  Set To Dictionary  ${fr_info}
    ...  scf_dist_name_primary=${fr_dist_name['primary_dn'][0]}
    ...  scf_dist_name_secondary=${fr_dist_name['secondary_dn']}
    ...  ELSE  Set To Dictionary  ${fr_info}
    ...  scf_dist_name_primary=${fr_dist_name}
    ...  scf_dist_name_secondary=@{EMPTY}
    Run Keyword If  ${sharing_status}  Set To Dictionary  ${fr_info}
    ...  scf_btsid_primary=${fr_bts_id['scf_primary_id'][0]}
    ...  scf_btsid_secondary=${fr_bts_id['scf_secondary_id']}
    ...  ELSE  Set To Dictionary  ${fr_info}
    ...  scf_btsid_primary=${fr_bts_id}
    ...  scf_btsid_secondary=@{EMPTY}
    Run Keyword If  ${sharing_status}  Set To Dictionary  ${fr_info}
    ...  scf_cablink_primary=${fr_cablinks['primary_link']}
    ...  scf_cablink_secondary=${fr_cablinks['secondary_link']}
    ...  ELSE  Set To Dictionary  ${fr_info}
    ...  scf_cablink_primary=${fr_cablinks}
    ...  scf_cablink_secondary=@{EMPTY}
    Set To Dictionary  ${fr_info}  scf_variant  ${variant}
    Set To Dictionary  ${fr_info}  scf_release_code  ${release_code}
	Set To Dictionary  ${fr_info}  scf_chain_fr_affected_list=${CHAIN_AFFECTED_DICT['${serial_number}']}
    Set To Dictionary  ${fr_info}  LNCEL  ${lte_cells}
    Set To Dictionary  ${fr_info}  WNCEL  ${wcdma_cells}
    Set To Dictionary  ${fr_info}  GNCEL  ${gsm_cells}
    Set To Dictionary  ${fr_info}  NRCEL  ${5g_cells}
    Run Keyword If  "${class}"=="RMOD"
	...  Set To Dictionary  ${cfg['RF_INFO']}  ${serial_number}  ${fr_info}
    ...  ELSE
	...  Set To Dictionary  ${cfg['ASIR_INFO']}  ${serial_number}  ${fr_info}
  END

SCFC Create SM Serial Number List
  [Arguments]  ${scf_file}
  [Documentation]
  ...  Description:
  ...  Gather system module serial numbers list
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | scf_file               | Yes  | Path to scf file                                                   |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  ${sm_sn_list}=  Evaluate Xpath  ${scf_file}
  ...  .//managedObject[contains(@class, 'SMOD_R')]/p[@name='serialNumber']/text()
  [Return]  @{sm_sn_list}

SCFC Create FHS Serial Number List
  [Arguments]  ${scf_file}
  [Documentation]
  ...  Description:
  ...  Returns list of serial numbers for all FHSs defined in given SCFC file stored on local Robot PC.
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  |  scf_file              | Yes  | Path to scf file                                                   |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  ${fhs_sn_list}=  Evaluate Xpath  ${scf_file}
  ...  .//managedObject[contains(@class, 'FHS_R')]/p[@name='serialNumber']/text()
  [Return]  @{fhs_sn_list}

SCFC Create BBMOD Serial Number List
  [Arguments]  ${scf_file}
  [Documentation]
  ...  Description:
  ...   Returns list of serial numbers for all BBMODs defined in given SCFC file stored on local Robot PC.
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | scf_file               | Yes  | Path to scf file                                                   |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  ${bbmod_sn_list}=  Evaluate Xpath  ${scf_file}
  ...  .//managedObject[contains(@class, 'BBMOD_R')]/p[@name='serialNumber']/text()
  [Return]  @{bbmod_sn_list}

SCF Get LTE Cell Parameters
  [Arguments]  ${scf_file}  ${cfg}
  [Documentation]
  ...  Description:
  ...  Gathers all needed inforamtion for each cell for LTE RAT.
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | scf_file               | Yes  | Path to scf file                                                   |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | cfg                    | Yes  | specific dictionary from BTS ID, it contains sub dictionary        |
  ...  |                        |      | for particular  BTS ID, cfg here is local dictionary.              |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  ${lncel_list}=  SCFC Create LncelId List  ${scf_file}
  Set To Dictionary  ${cfg}  LNCEL=&{EMPTY}
  FOR  ${lncel_id}  IN  @{lncel_list}
    ${lncel_id_dict}  Create Dictionary
    ${lcr_id}=  Scfc Get Lcrid For Lncelid  ${scf_file}  ${lncel_id}
    ${type}=  SCFC Get Cell Type  ${scf_file}  ${lcr_id}
    ${eutra}=  SCFC Get EutraCelId For LncelId  ${scf_file}  ${lncel_id}
    ${mimo_mode}=  SCFC Get dlMimoMode For LcrId  ${scf_file}  ${lcr_id}
    ${dist_name}=  SCFC Get DistName For LcrId  ${scf_file}  ${lcr_id}
    ${actCombSuperCell}=  SCFC Get Attribute Value  ${scf_file}  LNCEL-${lncel_id}  actCombSuperCell
    ${actCombSuperCell}=  Set Variable If  '${actCombSuperCell}' == 'false'  False  True
    ${ru_shared_status}  ${ru_shared_list}=  Check Cell Tx Shared Channels  ${scf_file}  ${lcr_id}  LCELL
    ${cell_2T2R_shared}=  Verify Cell Shared Type  ${ru_shared_status}  ${mimo_mode}  ${actCombSuperCell}
    ${object_1}=  Set Variable  .//managedObject[(contains(@class, "NOKLTE:LNCEL_") or contains(@class, "NOKLTE:NBIOT_"))
    ${object_2}=  Set Variable  contains(@distName, "LNCEL-${lncel_id}/")]/p[(@name="standaloneEarfcnDL")
    ${object_3}=  Set Variable  (@name="earfcn") or (@name="earfcnDL")]/text()
    ${xpath_query}=  Set Variable  ${object_1} and ${object_2} or ${object_3}
    IF  $type=='standalone' or $type=='legacy'
      ${tx_earfcn}  Evaluate Xpath  ${scf_file}  ${xpath_query}
      ${tx_earfcn}  Set Variable  ${tx_earfcn[0]}
    ELSE IF  $type=='inband' or $type=='guardband' or $type=='guardband-NR'
      ${nbiotclass}  Set Variable  NOKLTE:ANBIOTCARR
      ${tx_earfcn}  Evaluate Xpath  ${scf_file}
      ...  string(.//managedObject[contains(@class, "${nbiotclass}") and contains(@distName, "LNCEL-${lncel_id}/")]/p[(@name="assignedEarfcnDL")])
    END
    ${object_1}=  Set Variable  .//managedObject[(contains(@class, "NOKLTE:LNCEL_")
    ${object_2}=  Set Variable  contains(@class, "NOKLTE:NBIOT_"))
    ${object_3}=  Set Variable  contains(@distName, "LNCEL-${lncel_id}/")]/p[@name="dlChBw" or @name="chBw"]/text()
    ${xpath_query}=  Set Variable  ${object_1} or ${object_2} and ${object_3}
    ${dlChBw}=  Run Keyword If  $type=='standalone' or $type=='legacy' or $type=='inband' or $type=='guardband'
    ...  Get Element  ${scf_file}   ${xpath_query}
    ${object_1}=  Set Variable  .//managedObject[(contains(@class, "NOKLTE:LNCEL_")
    ${object_2}=  Set Variable  contains(@class, "NOKLTE:NBIOT_"))
    ${object_3}=  Set Variable  contains(@distName, "LNCEL-${lncel_id}/")]/p[@name="ulChBw" or @name="chBw"]/text()
    ${xpath_query}=  Set Variable  ${object_1} or ${object_2} and ${object_3}
    ${ulChBw}=  Run Keyword If  $type=='standalone' or $type=='legacy' or $type=='inband' or $type=='guardband'
    ...  Get Element  ${scf_file}  ${xpath_query}
    ${tx_status}  ${tx_frequency}=  Run Keyword And Ignore Error  Convert EARFCN To MHz  ${tx_earfcn}
    ${band_id}=  Run Keyword If  "${tx_status}"=="PASS"  Get Band For EARFCN  ${tx_earfcn}
    ${alloc_cell_mode}=  Run Keyword And Continue On Failure  Evaluate Xpath  ${scf_file}
    ...  string(.//managedObject[@class='NOKLTE:BBPOOLALLOC' and contains (@distName, "${distName}/")]/p[@name="bbPoolAllocMode"])
    ${nr_nsa_childs_cells}=    Get Elements Texts    ${scf_file}
    ...  .//managedObject[@class="NOKLTE:LNRELGNBCELL" and contains(@distName, "LNCEL-${lncel_id}/LNRELGNBCELL-")]/p[@name="nrCellId"]
    Set To Dictionary  ${lncel_id_dict}  scf_lcr_id=${lcr_id}
    ...  scf_type=${type}
    ...  scf_eutra_id=${eutra}
    ...  scf_dl_mimo_mode=${mimo_mode}
    ...  scf_dist_name=${dist_name}
    ...  scf_earfcn=${tx_earfcn}
    ...  scf_band=${band_id}
    ...  scf_dl_bw=${dlChBw}
    ...  scf_ul_bw=${ulChBw}
    ...  scf_cell_ru_shared=${ru_shared_status}
    ...  scf_cell_2T2R_shared=${cell_2T2R_shared}
    ...  scf_ru_list=${ru_shared_list}
    ...  scf_actCombSuperCell=${actCombSuperCell}
    ...  scf_alloc_mode=${alloc_cell_mode}
    ...  scf_nr_nsa_childs_cells=${nr_nsa_childs_cells}
    Set To Dictionary  ${cfg.LNCEL}  ${lncel_id}=${lncel_id_dict}
  END
  ${lncel_count}=  Get Length   ${lncel_list}
  Set To Dictionary  ${cfg.scf_cell_count}  LTE=${lncel_count}

SCFC Get LncelId Bandwidth And Frequency
  [Arguments]  ${scfc_file_path}  ${lncel_id}
  [Documentation]
  ...  Description:
  ...  Returns Bandwith and frequency information for specific LNCELL.
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | scfc_file_path         | Yes  | Path to scf file                                                   |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | lncel_id               | Yes  | lncel id for tested cell                                           |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com
  ${tx_earfcn}=  Get Element  ${scfc_file_path}
  ...  .//managedObject[contains(@class, "NOKLTE:LNCEL_") and contains(@distName, "LNCEL-${lncel_id}/")]/p[@name="earfcnDL"]/text()
  ${rx_earfcn}=  Get Element  ${scfc_file_path}
  ...  .//managedObject[contains(@class, "NOKLTE:LNCEL_") and contains(@distName, "LNCEL-${lncel_id}/")]/p[@name="earfcnUL"]/text()
  ${bw}=  Get Element  ${scfc_file_path}
  ...  .//managedObject[contains(@class, "NOKLTE:LNCEL_") and contains(@distName, "LNCEL-${lncel_id}/")]/p[@name="dlChBw"]/text()
  ${bw}=  Evaluate  "${bw[:-3]}".replace('_','.')
  ${tx_status}  ${tx_frequency}=  Run Keyword And Ignore Error  Convert EARFCN To MHz  ${tx_earfcn}
  ${rx_status}  ${rx_frequency}=  Run Keyword And Ignore Error  Convert EARFCN To MHz  ${rx_earfcn}

  ${band_id}=  Run Keyword If  "${tx_status}"=="PASS"
  ...  Get Band For EARFCN    ${tx_earfcn}
  ${ul_frequency}=  Get Band Info  ${band_id}  freq_ul_low

  Run Keyword If  ("${tx_status}"=="FAIL" or "${rx_status}"=="FAIL") and "${ul_frequency}"!="-1"
  ...  Log  Script had trouble calculating frequencies for LNCEL-${lncel_id}: ${tx_frequency}  WARN
  ${tx_frequency}=  Set Variable If  "${tx_status}"=="FAIL"  unknown  ${tx_frequency}
  ${rx_frequency}=  Set Variable If  "${ul_frequency}"=="-1"  N/A
  ...  "${rx_status}"=="FAIL"  unknown  ${rx_frequency}
  [Return]  ${band_id}  ${tx_frequency}  ${rx_frequency}

SCF Get WCDMA Cell Parameters
  [Arguments]  ${scf_file}  ${cfg}
  [Documentation]
  ...  Description:
  ...  Gathers all needed inforamtion for each cell for WCDMA RAT.
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | scf_file               | Yes  | Path to scf file                                                   |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | cfg                    | Yes  | specific dictionary from BTS ID, it contains sub dictionary        |
  ...  |                        |      | for particular  BTS ID, cfg here is local dictionary.              |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com
    ${wncel_list}=  Get Elements  ${scf_file}  .//managedObject[contains(@class, "WNCEL") and p[@name="lCelwDN"]]/@distName
    Set To Dictionary  ${cfg}  WNCEL=&{EMPTY}
    FOR  ${wncel_id}  IN  @{wncel_list}
      ${wncel_id_dict}  Create Dictionary
      ${dist_name}=  Evaluate Xpath  ${scf_file}
      ...  string(.//managedObject[contains(@class, "WNCEL") and contains(@distName, "${wncel_id}")]/@distName)
      ${wncel}=  Get Regexp Matches  ${dist_name}  .*\/WNCEL-(\\d+).*   1
      ${lcelw_dist_name}=  Evaluate Xpath  ${scf_file}
      ...  string(.//managedObject[contains(@class, "WNCEL") and contains(@distName, "${wncel_id}")]/p[@name="lCelwDN"])
      ${lcelw_id}=  Get Regexp Matches  ${lcelw_dist_name}  .*\/LCELW-(\\d+).*  1
      ${eutra}=  Evaluate Xpath  ${scf_file}
      ...  string(.//managedObject[contains(@class, "WNCEL") and contains(@distName, "${wncel_id}")]/p[@name="defaultCarrier"])
      ${mimo_mode}=   Evaluate Xpath  ${scf_file}
      ...  string(.//managedObject[contains(@class, "WNCEL") and contains(@distName, "${wncel_id}")]/p[@name="mimoType"])
      ${alloc_cell_mode}=   Run Keyword And Continue On Failure  Evaluate Xpath    ${scf_file}
      ...  string(.//managedObject[@class='NOKLTE:BBPOOLALLOC' and contains (@distName, "${distName}/")]/p[@name="bbPoolAllocMode"])
      ${ru_shared_status}  ${ru_shared_list}=  Check Cell Rx Shared Channels  ${scf_file}  ${lcelw_id[0]}  LCELW
      ${ru_tx_shared_status}  ${ru_tx_shared_list}=  Check Cell Tx Shared Channels  ${scf_file}  ${lcelw_id[0]}  LCELW
      ${cell_2T2R_shared}=  Verify Cell Shared Type  ${ru_shared_status}  ${mimo_mode}
      Set To Dictionary  ${wncel_id_dict}  scf_lcelw_id=${lcelw_id[0]}
  ...  scf_type=wncel
  ...  scf_eutra_id=${eutra}
  ...  scf_dl_mimo_mode=${mimo_mode}
  ...  scf_dist_name=${dist_name}
  ...  scf_cell_ru_shared=${ru_shared_status}
  ...  scf_ru_list=${ru_shared_list}
  ...  scf_cell_2T2R_shared=${cell_2T2R_shared}
  ...  scf_alloc_mode=${alloc_cell_mode}
    Set To Dictionary  ${cfg.WNCEL}  ${wncel[0]}=${wncel_id_dict}
  END
  ${wncel_count}=  Get Length  ${wncel_list}
  Set To Dictionary  ${cfg.scf_cell_count}  WCDMA=${wncel_count}

SCF Get GSM Cell Parameters
  [Arguments]  ${scf_file}  ${cfg}
  [Documentation]
  ...  Description:
  ...  Gathers all needed inforamtion for each cell for GSM RAT.
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | scf_file               | Yes  | Path to scf file                                                   |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | cfg                    | Yes  | specific dictionary from BTS ID, it contains sub dictionary        |
  ...  |                        |      | for particular  BTS ID, cfg here is local dictionary.              |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  ${gncel_list}=  Get Elements  ${scf_file}  .//managedObject[contains(@class, "GNCEL") and p[@name="lcelcId"]]/@distName
  Set To Dictionary  ${cfg}  GNCEL=&{EMPTY}
  FOR  ${gncel_id}  IN  @{gncel_list}
    ${gncel_id_dict}  Create Dictionary
    ${dist_name}=  Evaluate Xpath  ${scf_file}
    ...  string(.//managedObject[contains(@class, "GNCEL") and contains(@distName, "${gncel_id}")]/@distName)
    ${lcelcId}=  Evaluate Xpath  ${scf_file}
    ...  string(.//managedObject[contains(@class, "GNCEL") and contains(@distName, "${gncel_id}")]/p[@name="lcelcId"])
    ${gncel_id}=  Get Regexp Matches  ${dist_name}  .*\/GNCEL-(\\d+).*   1
    ${band_nr}=   Evaluate Xpath  ${scf_file}
    ...  string(.//managedObject[contains(@class, "LCELC") and contains(@distName, "${lcelcId}")]/p[@name="bandNumber"])
    ${ru_shared_status}  ${ru_shared_list}=  Check Cell Tx Shared Channels  ${scf_file}  ${lcelcId}  LCELC
    ${cell_2T2R_shared}=   Verify Cell Shared Type  ${ru_shared_status}  2
    ${alloc_cell_mode}=  Run Keyword And Continue On Failure  Evaluate Xpath  ${scf_file}
    ...  string(.//managedObject[@class='NOKLTE:BBPOOLALLOC' and contains (@distName, "${distName}/")]/p[@name="bbPoolAllocMode"])
    Set To Dictionary  ${gncel_id_dict}  scf_lcelcId_id=${lcelcId}
    ...  scf_dist_name=${dist_name}
    ...  scf_band=${band_nr}
    ...  scf_cell_ru_shared=${ru_shared_status}
    ...  scf_ru_list=${ru_shared_list}
    ...  scf_cell_2T2R_shared=${cell_2T2R_shared}
    ...  scf_alloc_mode=${alloc_cell_mode}
    Set To Dictionary  ${cfg.GNCEL}  ${gncel_id[0]}=${gncel_id_dict}
  END
  ${gncel_count}=  Get Length  ${gncel_list}
  Set To Dictionary  ${cfg.scf_cell_count}  GSM=${gncel_count}

SCF Get 5G Cell Parameters
  [Arguments]  ${scf_file}  ${cfg}
  [Documentation]
  ...  Description:
  ...  Gathers all needed inforamtion for each cell for 5G RAT.
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | scf_file               | Yes  | Path to scf file                                                   |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | cfg                    | Yes  | specific dictionary from BTS ID, it contains sub dictionary        |
  ...  |                        |      | for particular  BTS ID, cfg here is local dictionary.              |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Maintainer: piotr.korczynski@nokia.com

  ${nrcel_list}=  SCFC Create NRcelId List  ${scf_file}
  Set To Dictionary  ${cfg}  NRCEL=&{EMPTY}
  FOR  ${nrcel_id}  IN  @{nrcel_list}
    ${nrcel_id_dict}  Create Dictionary
    ${lcr_id}=  Scfc Get Lcrid For NRcelid  ${scf_file}  ${nrcel_id}
    ${cellTechnology}=  Evaluate Xpath  ${scf_file}
    ...  string(.//managedObject[(@class='com.nokia.srbts.nrbts:NRCELL') and contains(@distName, "NRCELL-${nrcel_id}")]/p[@name="cellTechnology"])
    ${type}=    Set Variable If
    ...  '${cellTechnology}'=='FDD'  legacy
    ...  '${cellTechnology}'=='TDD'  legacy
    ${eutra}=  Evaluate Xpath  ${scf_file}
    ...  string(.//managedObject[(@class='com.nokia.srbts.nrbts:NRCELL') and contains(@distName, "NRCELL-${nrcel_id}")]/p[@name="nrCellIdentity"])
    ${dl_mimo_mode}=  Evaluate Xpath  ${scf_file}
    ...  string(.//managedObject[(@class='com.nokia.srbts.nrbts:NRCELL') and contains(@distName, "NRCELL-${nrcel_id}")]/p[@name="dlMimoMode"])
    ${ul_mimo_mode}=  Evaluate Xpath  ${scf_file}
    ...  string(.//managedObject[(@class='com.nokia.srbts.nrbts:NRCELL') and contains(@distName, "NRCELL-${nrcel_id}")]/p[@name="ulMimoMode"])
    ${dist_name}=  Evaluate Xpath  ${scf_file}
    ...  string(.//managedObject[(@class='com.nokia.srbts.nrbts:NRCELL') and p[@name="lcrId"]='${lcr_id}']/@distName)
    ${alloc_cell_mode}=  Run Keyword And Continue On Failure  Evaluate Xpath  ${scf_file}
    ...  string(.//managedObject[@class='NOKLTE:BBPOOLALLOC' and contains (@distName, "${distName}/")]/p[@name="bbPoolAllocMode"])
    ${ru_shared_status}  ${ru_shared_list}=  Check Cell Tx Shared Channels  ${scf_file}  ${lcr_id}  LCELNR
    ${cell_2T2R_shared}=  Verify Cell Shared Type  ${ru_shared_status}  ${dl_mimo_mode}
    ${tx_earfcn}=  Evaluate Xpath  ${scf_file}
    ...  string(.//managedObject[@class='com.nokia.srbts.nrbts:NRCELL_FDD' and contains(@distName, "NRCELL-${nrcel_id}")]/p[@name="nrarfcnDl"])
    ${band_id}=  Evaluate Xpath  ${scf_file}
    ...  string(.//managedObject[@class='com.nokia.srbts.nrbts:NRCELL' and contains(@distName, "NRCELL-${nrcel_id}")]/p[@name="freqBandIndicatorNR"])
    ${tx_earfcn}=  Evaluate Xpath  ${scf_file}
    ...  string(.//managedObject[@class='com.nokia.srbts.nrbts:NRCELL_FDD' and contains(@distName, "NRCELL-${nrcel_id}")]/p[@name="nrarfcnDl"])
    ${dlChBw}=  Evaluate Xpath  ${scf_file}
    ...  string(.//managedObject[@class='com.nokia.srbts.nrbts:NRCELL_FDD' and contains(@distName, "NRCELL-${nrcel_id}")]/p[@name="chBwDl"])
    ${ulChBw}=  Evaluate Xpath  ${scf_file}
    ...  string(.//managedObject[@class='com.nokia.srbts.nrbts:NRCELL_FDD' and contains(@distName, "NRCELL-${nrcel_id}")]/p[@name="chBwUl"])
    ${dep_type}=  Evaluate Xpath  ${scf_file}
    ...  string(.//managedObject[@class='com.nokia.srbts.nrbts:NRCELL' and contains(@distName, "NRCELL-${nrcel_id}")]/p[@name="cellDepType"])
    ${parent_bts_id}=  Run Keyword If  '${dep_type}'=='NSA'  Evaluate Xpath  ${scf_file}
    ...  string(.//managedObject[@class='com.nokia.srbts.nrbts:NRRELLTE' and contains(@distName, "NRCELL-${nrcel_id}")]/p[@name="eNodeBId"])
    ...  ELSE  Set Variable  ${None}
    Set To Dictionary  ${nrcel_id_dict}
    ...  scf_lcr_id=${lcr_id}
    ...  scf_type=${type}
    ...  scf_eutra_id=${eutra}
    ...  scf_dl_mimo_mode=${dl_mimo_mode}
    ...  scf_ul_mimo_mode=${ul_mimo_mode}
    ...  scf_dist_name=${dist_name}
    ...  scf_earfcn=${tx_earfcn}
    ...  scf_band=${band_id}
    ...  scf_dl_bw=${dlChBw}
    ...  scf_ul_bw=${ulChBw}
    ...  scf_cell_ru_shared=${ru_shared_status}
    ...  scf_cell_2T2R_shared=${cell_2T2R_shared}
    ...  scf_ru_list=${ru_shared_list}
    ...  scf_alloc_mode=${alloc_cell_mode}
    ...  scf_dep_type=${dep_type}
    ...  scf_parent_bts_id=${parent_bts_id}
    Set To Dictionary  ${cfg.NRCEL}  ${nrcel_id}=${nrcel_id_dict}
  END
  ${nrcel_count}=   Get Length  ${nrcel_list}
  Set To Dictionary  ${cfg.scf_cell_count}  NR=${nrcel_count}

Verify Cell Shared Type
  [Arguments]  ${ru_shared_status}  ${mimo_mode}  ${actCombSuperCell}=None
  [Documentation]
  ...  Description:
  ...  Verify if cell is shared and requires 4003 fault to check
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | ru_shared_status       | Yes  | status if cell is shared between radio units                       |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | mimo_mode              | Yes  | type of mimo mode, 2T2R, 4T4R                                      |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | actCombSuperCell       | No   | status if Combine Super Cell is activated                          |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Maintainer: piotr.korczynski@nokia.com

  ${4_tx_shared}=  Evaluate  '4' in '${mimo_mode}'
  ${cell_2T2R_shared}=  Run Keyword If  '${actCombSuperCell}'=='${EMPTY}'
  ...  Set Variable If  ${ru_shared_status} and not ${4_tx_shared}  True  False
  ...  ELSE
  ...  Set Variable If  ${ru_shared_status} and not ${4_tx_shared} and not ${actCombSuperCell}    True    False
  [Return]  ${cell_2T2R_shared}

Get RMOD LNCEL Cells Info
  [Arguments]  ${rmod_dist_name}  ${cfg}  ${scf_file}
  [Documentation]
  ...  Description:
  ...  GAther Lncell information for radio unit
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | rmod_dist_name         | Yes  | Radio unit distname                                                |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | cfg                    | Yes  | RF_INFO dictionary object                                          |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | scf_file               | Yes  | Path to scf file                                                   |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Maintainer: piotr.korczynski@nokia.com

  ${lte}=  Set Variable  ${cfg.scf_lte}
  ${lte_info}=  Run keyword if  ${lte}==False  Create Dictionary  scf_cellid_primary=${NONE}  scf_cell_count_primary=0
  Return From Keyword If  ${lte}==False   ${lte_info}
  ${fr_lncel_list}=   Get RMOD LTE Cell List  ${rmod_dist_name}  ${cfg}  ${scf_file}
  ${lte_cell_count}=  Get RMOD cell count  ${fr_lncel_list}
  ${lte_info}=  Create Dictionary  scf_cellid_primary=${fr_lncel_list}  scf_cell_count_primary=${lte_cell_count}
  [Return]  ${lte_info}

Get RMOD WNCEL Cells Info
  [Arguments]  ${rmod_dist_name}  ${cfg}  ${scf_file}
  [Documentation]
  ...  Description:
  ...  Gather Wncell information for radio unit
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | rmod_dist_name         | Yes  | Radio unit distname                                                |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | cfg                    | Yes  | RF_INFO dictionary object                                          |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | scf_file               | Yes  | Path to scf file                                                   |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Maintainer: piotr.korczynski@nokia.com

  ${wcdma}=  Set Variable  ${cfg.scf_wcdma}
  ${wcdma_info}=  Run keyword if  ${wcdma}==False  Create Dictionary  scf_cellid_primary=${NONE}  scf_cell_count_primary=0
  Return From Keyword If  ${wcdma}==False  ${wcdma_info}
  ${rmod_wncel_list}=  Get RMOD Wcdma Cell List  ${rmod_dist_name}  ${cfg}  ${scf_file}
  ${wcdma_cell_count}=  Get RMOD cell count  ${rmod_wncel_list}
  ${wcdma_info}=  Create Dictionary  scf_cellid_primary=${rmod_wncel_list}  scf_cell_count_primary=${wcdma_cell_count}
  [Return]  ${wcdma_info}

Get RMOD GSM Cells Info
  [Arguments]  ${serial_number}  ${rmod_dist_name}  ${cfg}  ${scf_file}
  [Documentation]
  ...  Description:
  ...  Gather GSM cell information for radio unit
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | rmod_dist_name         | Yes  | Radio unit distname                                                |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | cfg                    | Yes  | RF_INFO dictionary object                                          |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | scf_file               | Yes  | Path to scf file                                                   |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Maintainer: piotr.korczynski@nokia.com

  ${gsm}=  Set Variable  ${cfg.scf_gsm}
  ${gsm_info}=  Run keyword if  ${gsm}==False  Create Dictionary  scf_cellid_primary=${NONE}  scf_cell_count_primary=0
  Return From Keyword If  ${gsm}==False   ${gsm_info}
  ${rmod_gncel_list}=  Get RMOD Gsm Cell List  ${serial_number}  ${rmod_dist_name}  ${cfg}  ${scf_file}
  ${gsm_cell_count}=  Get RMOD cell count  ${rmod_gncel_list}
  ${gsm_info}=  Create Dictionary  scf_cellid_primary=${rmod_gncel_list}  scf_cell_count_primary=${gsm_cell_count}
  [Return]  ${gsm_info}

Get RMOD NRCEL Cells Info
  [Arguments]  ${rmod_dist_name}  ${cfg}  ${scf_file}
  [Documentation]
  ...  Description:
  ...  Gather NRcell information for radio unit
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | rmod_dist_name         | Yes  | Radio unit distname                                                |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | cfg                    | Yes  | RF_INFO dictionary object                                          |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | scf_file               | Yes  | Path to scf file                                                   |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Maintainer: piotr.korczynski@nokia.com

  ${5g}=  Set Variable    ${cfg.scf_nr}
  ${5g_info}=   Run keyword if  ${5g}==False  Create Dictionary  scf_cellid_primary=${NONE}  scf_cell_count_primary=0
  Return From Keyword If  ${5g}==False  ${5g_info}
  ${rmod_nrcel_list}=  Get RMOD NRCEL Cell List  ${rmod_dist_name}  ${cfg}  ${scf_file}
  ${5g_cell_count}=  Get RMOD cell count   ${rmod_nrcel_list}
  ${5g_info}=  Create Dictionary  scf_cellid_primary=${rmod_nrcel_list}  scf_cell_count_primary=${5g_cell_count}
  [Return]  ${5g_info}

Get RMOD cell count
  [Arguments]  ${rmod_cell_list}
  [Documentation]
  ...  Description:
  ...  Checks number of cells on radio unit
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | rmod_cell_list         | Yes  | list of cell for radio unit                                        |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Maintainer: piotr.korczynski@nokia.com

  Return From Keyword If  ${rmod_cell_list}==None   0
  ${cell_count}=  get length  ${rmod_cell_list}
  [Return]  ${cell_count}

Get RMOD LTE Cell List
  [Arguments]  ${rmod}  ${cfg}  ${scf_file}
  [Documentation]
  ...  Description:
  ...  Prepares list of LNCELL for specific Radio unit
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | rmod                   | Yes  | radio unit distname                                                |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | cfg                    | Yes  | partial NODE dictionary                                            |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | scf_file               | Yes  | Path to scf file                                                   |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Maintainer: piotr.korczynski@nokia.com

  ${lncel_list}=  Get Dictionary Keys  ${cfg.LNCEL}
  ${_}  ${rmod}=   Split String From Right  ${rmod}  /  1
  ${rmod_lncel_list}=   Create List
  FOR  ${lncel}  IN  @{lncel_list}
       ${lcr_id}=  Get from dictionary  ${cfg.LNCEL['${lncel}']}  scf_lcr_id
       ${status}=  Check RMOD LTE Cell  ${lcr_id}  ${rmod}  ${scf_file}
       Run Keyword If  ${status} == True  append to list   ${rmod_lncel_list}  ${lncel}
  END
  ${rmod_lncel_list}  Remove Duplicates  ${rmod_lncel_list}
  ${rmod_lncel_list}=  Set Variable if  not ${rmod_lncel_list}  None  ${rmod_lncel_list}
  [Return]      ${rmod_lncel_list}

Get RMOD Gsm Cell List
  [Arguments]  ${serial_number}  ${rmod}  ${cfg}  ${scf_file}
  [Documentation]
  ...  Description:
  ...  Prepares list of GSM cell for specific Radio unit
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | scf_file               | Yes  | Path to scf file                                                   |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  ${gncel_list}=  Get Dictionary Keys  ${cfg.GNCEL}
  ${_}  ${rmod}=  Split String From Right  ${rmod}  /  1
  ${rmod_gncel_list}=  Create List
  FOR  ${gncel}  IN  @{gncel_list}
    ${lcelcId}=  Get from dictionary  ${cfg.GNCEL['${gncel}']}  scf_lcelcId_id
    ${object_1}=  Set Variable  boolean(.//managedObject[contains(@distName,"RMOD_R")]
    ${object_2}=  Set Variable  [p[@name="serialNumber"]='${serial_number}']/list[@name="activeGsmCellsList"][p='${lcelcId}'])
    ${xpath_query}=  Set Variable  ${object_1}${object_2}
    ${gsm_cell_rmod}=  Evaluate Xpath  ${scf_file}  ${xpath_query}
   Run Keyword If  ${gsm_cell_rmod} == True  append to list  ${rmod_gncel_list}  ${gncel}
  END
  ${rmod_gncel_list}  Remove Duplicates  ${rmod_gncel_list}
  ${rmod_gncel_list}=  Set Variable if  not ${rmod_gncel_list}  None  ${rmod_gncel_list}
  [Return]  ${rmod_gncel_list}

Get RMOD Wcdma Cell List
  [Arguments]  ${rmod}  ${cfg}  ${scf_file}
  [Documentation]
  ...  Description:
  ...  Prepares list of WNCEL for specific Radio unit
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | scf_file               | Yes  | Path to scf file                                                   |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  ${wncel_list}=  Get Dictionary Keys  ${cfg.WNCEL}
  ${_}  ${rmod}=  Split String From Right  ${rmod}  /  1
  ${rmod_wncel_list}=  Create List
  FOR  ${wncel}  IN  @{wncel_list}
     ${lcelw}=  Get from dictionary  ${cfg.WNCEL['${wncel}']}  scf_lcelw_id
     ${status}=  Check RMOD WCDMA Cell  ${lcelw}  ${rmod}  ${scf_file}
     Run Keyword If  ${status} == True  append to list  ${rmod_wncel_list}  ${wncel}
  END
  ${rmod_wncel_list}  Remove Duplicates  ${rmod_wncel_list}
  ${rmod_wncel_list}=  Set Variable if  not ${rmod_wncel_list}  None  ${rmod_wncel_list}
  [Return]  ${rmod_wncel_list}

Get RMOD NRCEL Cell List
    [Arguments]  ${rmod}  ${cfg}  ${scf_file}
    [Documentation]
  ...  Description:
  ...  Prepares list of NRCELL for specific Radio unit
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | scf_file               | Yes  | Path to scf file                                                   |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  ${nrcel_list}=  Get Dictionary Keys  ${cfg.NRCEL}
  ${_}  ${rmod}=  Split String From Right  ${rmod}  /  1
  ${rmod_nrcel_list}=   Create List
  FOR  ${nrcel}  IN  @{nrcel_list}
       ${lcr_id}=   Get from dictionary  ${cfg.NRCEL['${nrcel}']}  scf_lcr_id
       ${status}=  Check RMOD NRCEL Cell  ${lcr_id}  ${rmod}  ${scf_file}
       Run Keyword If  ${status} == True  append to list  ${rmod_nrcel_list}  ${nrcel}
  END
  ${rmod_nrcel_list}  Remove Duplicates  ${rmod_nrcel_list}
  ${rmod_nrcel_list}=  Set Variable if  not ${rmod_nrcel_list}  None  ${rmod_nrcel_list}
  [Return]  ${rmod_nrcel_list}

Check Cell Tx Shared Channels
  [Arguments]  ${scf_file}  ${lcrid}  ${cell_type}
  [Documentation]
  ...  Description:
  ...  Check status of shared cell and provides antl list using TX direction.
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | scf_file               | Yes  | Path to scf file                                                   |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | lcrid                  | Yes  | lcr id number of checked cell                                      |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | cell_type              | Yes  | RAT technology of tested cell                                      |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Maintainer: piotr.korczynski@nokia.com

  ${object_1}=  Set Variable  //managedObject[@class='com.nokia.srbts.mnl:CHANNEL' and contains(@distName,"${cell_type}-${lcrid}/")]
  ${object_2}=  Set Variable  [p[@name='direction']='TX']/p[@name="antlDN"]
  ${xpath_query}=  Set Variable    ${object_1}${object_2}
  ${xpath_query}=  Convert To String    ${xpath_query}
  ${lcell_tx_antlDN_number}=    Get Elements Texts   ${scf_file}  xpath=${xpath_query}
  ${antl_list}=  Create List
  FOR  ${id}  IN  @{lcell_tx_antlDN_number}
    ${rmod_list}=  Get Regexp Matches	  ${id}  ASIRMOD\\-(\\d+)|RMOD\\-(\\d+)
    Append To List  ${antl_list}  ${rmod_list}
  END
  ${antl_list}=  Remove Duplicates  ${antl_list}
  ${count}=  Get Length  ${antl_list}
  ${lcrid_tmp_list}=  Create List  ${lcrid}
  ${tx_status}=  Set Variable If  ${count} > 1  True  False
  [Return]  ${tx_status}  ${antl_list}

Check Cell Rx Shared Channels
  [Arguments]  ${scf_file}  ${lcrid}  ${cell_type}
  [Documentation]
  ...  Description:
  ...  Check status of shared cell and provides antl list using RX direction.
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | scf_file               | Yes  | Path to scf file                                                   |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | lcrid                  | Yes  | lcr id number of checked cell                                      |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | cell_type              | Yes  | RAT technology of tested cell                                      |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Maintainer: piotr.korczynski@nokia.com

  ${object_1}=  Set Variable  //managedObject[@class='com.nokia.srbts.mnl:CHANNEL'
  ${object_2}=  Set Variable  contains(@distName,"${cell_type}-${lcrid}/")][p[@name='direction']='RX']/p[@name="antlDN"]
  ${xpath_query}=  Set Variable  ${object_1} and ${object_2}
  ${xpath_query}=  Convert To String  ${xpath_query}
  ${lcell_tx_antlDN_number}=  Get Elements Texts  ${scf_file}  xpath=${xpath_query}
  ${antl_list}=  Create List
  FOR  ${id}  IN  @{lcell_tx_antlDN_number}
    ${rmod_list}=  Get Regexp Matches	 ${id}  RMOD\\-(\\d+)
    Append To List  ${antl_list}  ${rmod_list}
  END
  ${antl_list}=  Remove Duplicates  ${antl_list}
  ${count}=  Get Length  ${antl_list}
  ${lcrid_tmp_list}=  Create List   ${lcrid}
  ${tx_status}=  Set Variable If  ${count} > 1  True  False
  [Return]  ${tx_status}  ${antl_list}

Combine NR NSA cells with thier LTE parents cells
  [Documentation]
  ...  Description:
  ...  Keyword creates relation between 5G cell and 4G cell.
  ...
  ...  Maintainer: piotr.korczynski@nokia.com
  ${nrcels_parents_list}=  Loop By All Nodes And Get LNCELs Childs
  Run Keyword And Ignore Error  Loop By All Nodes And Assign Parent LNCEL To NSA NRCEL  ${nrcels_parents_list}

Loop By All Nodes And Get LNCELs Childs
  [Documentation]
  ...  Description:
  ...  Check in each BTS ID description, LNCEL relation to NR cell
  ...  Arguments:
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  ${nrcels_parents_list}=  Create List
  ${cfg_nodes}=  Get From Dictionary  ${cfg}  NODES
  FOR  ${node}  IN  @{cfg_nodes}
    ${node_dict}=  Get From Dictionary  ${cfg_nodes}  ${node}
    ${node_lncel}=  Get From Dictionary  ${node_dict}  LNCEL
    ${node_lncel_len}=  Get Length  ${node_lncel}
    ${single_node_nrcels_parents_list}=  Run Keyword If  ${node_lncel_len} > 0
    ...  Loop By Provided LNCEL Dict And Get LNCELs Childs  ${node_lncel}
    Continue For Loop If  ${single_node_nrcels_parents_list} is ${None}
    ${nrcels_parents_list}=  Evaluate  ${nrcels_parents_list} + ${single_node_nrcels_parents_list}
  END
  [Return]  ${nrcels_parents_list}

Loop By Provided LNCEL Dict And Get LNCELs Childs
  [Arguments]  ${node_lncel}
  [Documentation]
  ...  Description:
  ...  Gather information of NRCELL parents cell using LNCELL information from one BTS NODE
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | node_lncel             | Yes  | part of subdictionary from CFG.NODES containing LNCELL             |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Maintainer: piotr.korczynski@nokia.com

  ${nrcels_parents_list}=  Create List
  FOR  ${lncel}  IN  @{node_lncel}
    ${lncel_dict}=  Get From Dictionary  ${node_lncel}  ${lncel}
    ${lncel_eutra}=  Get From Dictionary  ${lncel_dict}  scf_eutra_id
    ${lncel_childs}=  Get From Dictionary  ${lncel_dict}  scf_nr_nsa_childs_cells
    ${lncel_childs_len}=  Get Length  ${lncel_childs}
    ${single_lncel_nrcels_parents_list}=  Run Keyword If  ${lncel_childs_len} > 0
    ...  Create List Of NRCEL And LNCER Pairs  ${lncel_eutra}  ${lncel_childs}
    Continue For Loop If  ${single_lncel_nrcels_parents_list} is ${None}
    ${nrcels_parents_list}=  Evaluate  ${nrcels_parents_list} + ${single_lncel_nrcels_parents_list}
  END
  [Return]  @{nrcels_parents_list}

Loop By All Nodes And Assign Parent LNCEL To NSA NRCEL
  [Arguments]  ${nrcels_parents_list}
  [Documentation]
  ...  Description:
  ...  Returns list of serial numbers for all BBMODs defined in given SCFC file stored on local Robot PC.
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | nrcels_parents_list    | Yes  | List of NRcell parents cell.                                       |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Maintainer: piotr.korczynski@nokia.com

  ${cfg_nodes}=  Get From Dictionary  ${CFG}  NODES
  FOR  ${node}  IN  @{cfg_nodes}
    ${node_dict}=  Get From Dictionary  ${cfg_nodes}  ${node}
    ${node_nrcel}=  Get From Dictionary  ${node_dict}  NRCEL
    ${node_nrcel_len}=  Get Length  ${node_nrcel}
    Continue For Loop If  ${node_nrcel_len} <= 0
    ${updated_node_nrcel}=  Assign Parent LNCEL To Provided NRCELs  ${node_nrcel}  ${nrcels_parents_list}
    Remove From Dictionary  ${CFG}[NODES][${node}]  NRCEL
    Set To Dictionary  ${CFG}[NODES][${node}]  NRCEL  ${updated_node_nrcel}
  END

Assign Parent LNCEL To Provided NRCELs
  [Arguments]  ${node_nrcel}  ${nrcels_parents_list}
  [Documentation]
  ...  Description:
  ...   Returns list of serial numbers for all BBMODs defined in given SCFC file stored on local Robot PC.
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | node_nrcel             | Yes  | part of subdictionary from CFG.NODES containing LNCELL             |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | nrcels_parents_list    | Yes  | List of NRcell parents cell.                                       |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Maintainer: piotr.korczynski@nokia.com

  FOR  ${nrcel}  IN  @{node_nrcel}
    ${nrcel_dict}=  Get From Dictionary  ${node_nrcel}  ${nrcel}
    ${nrcel_dict_deptype}=  Get From Dictionary  ${nrcel_dict}  scf_dep_type
    ${nrcel_dict_eutra}=  Get From Dictionary  ${nrcel_dict}  scf_eutra_id
    Run Keyword If  "${nrcel_dict_deptype}" != "NSA"  Run Keywords
    ...  Set To Dictionary  ${node_nrcel}[${nrcel}]  scf_parent_cell  ${None}  AND
    ...  Continue For Loop
    ${parent_cell}=  Search For Parent LNCEL  ${nrcels_parents_list}  ${nrcel_dict_eutra}
    Set To Dictionary  ${node_nrcel}[${nrcel}]  scf_parent_cell  ${parent_cell}
  END
  [Return]   ${node_nrcel}

Search For Parent LNCEL
  [Arguments]  ${nrcels_parents_list}  ${nrcel_dict_eutra}
  [Documentation]
  ...  Description:
  ...  Returns list of serial numbers for all BBMODs defined in given SCFC file stored on local Robot PC.
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | nrcels_parents_list    | Yes  | List of NRcell parents cell.                                       |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | nrcel_dict_eutra       | Yes  | EUTRA list of cells gathered from tested configuration             |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Maintainer: piotr.korczynski@nokia.com

  ${nrcels_parents_range}=  Evaluate  range(len(${nrcels_parents_list}))
  FOR  ${d}  IN  @{nrcels_parents_range}
    ${d_keys}=  Get Dictionary Keys  ${nrcels_parents_list}[${d}]
    ${d_value}=  Get From Dictionary  ${nrcels_parents_list}[${d}]  ${d_keys}[0]
    Continue For Loop If  ${d_keys}[0] != ${nrcel_dict_eutra}
    Log  Found maching parent LNCEL (${d_value}) for NRCEL (${nrcel_dict_eutra})
    ${parent_cell}=  Get From Dictionary  ${nrcels_parents_list}[${d}]  ${nrcel_dict_eutra}
    Exit For Loop
  END
  [Return]  ${parent_cell}

Create List Of NRCEL And LNCER Pairs
  [Arguments]  ${lncel_eutra}  ${lncel_childs}
  [Documentation]
  ...  Description:
  ...  Returns status if provided RU serial number contains provided NR cell
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | lncel_eutra            | Yes  | eutra_id value of verify cell pair                                                   |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | lncel_childs           | Yes  | list of cells described by nr_nsa_childs_cells value               |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Maintainer: piotr.korczynski@nokia.com

  ${nrcels_parents_list}=  Create List
  FOR  ${nrcel_eutra}  IN  @{lncel_childs}
    ${nrcel_lncel_eutra_pair}=  Create Dictionary  ${nrcel_eutra}  ${lncel_eutra}
    Append To List  ${nrcels_parents_list}  ${nrcel_lncel_eutra_pair}
  END
  [Return]  @{nrcels_parents_list}

Get Bts Ids For FR When Rfsharing
    [Arguments]  ${fr_dist_name_rfs}
    [Documentation]    Returns bts_id for RF when rfsharing defined in given SCFC file stored on local Robot PC.
    ...    Author:      daniel.bartkowiak@nokia.com
    ...    Maintainer:  Author
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | Argument           | Man.  | Description                                                                                   |
    ...    +====================+=======+===============================================================================================+
    ...    | fr_dist_name_rfs   | Yes   | Output dictionary from 'SCFC Get RF DistName For Serial Number When Rfsharing'                |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...
    ...    +--------------------+-------------------------------------------------------------------------------------------------------+
    ...    | Return Value       | Description                                                                                           |
    ...    +====================+=======================================================================================================+
    ...    | bts_id_rfs         | Rfs primary/secondary bts_id dictionary                                                                |
    ...    +--------------------+-------------------------------------------------------------------------------------------------------+
    ${bts_id_rfs}=  Create Dictionary  scf_primary_id=@{EMPTY}  scf_secondary_id=@{EMPTY}
    ${match}=  Get Regexp Matches  ${fr_dist_name_rfs['primary_dn'][0]}  (?<=MRBTS-)(\\d+)
    Append To List  ${bts_id_rfs['scf_primary_id']}  ${match[0]}
    FOR  ${secondary_dn}  IN  @{fr_dist_name_rfs['secondary_dn']}
      ${match}=  Get Regexp Matches  ${secondary_dn}  (?<=MRBTS-)(\\d+)
      Append To List  ${bts_id_rfs['scf_secondary_id']}  ${match[0]}
    END
    [Return]  ${bts_id_rfs}

Get FR Cells Info When Rfsharing
    [Arguments]  ${fr_dist_name_rfs}  ${bts_id_rfs}  ${cell_class}
    [Documentation]  Returns cells for RF when rfsharing defined in given SCFC file stored on local Robot PC.
    ...    Author:      daniel.bartkowiak@nokia.com
    ...    Maintainer:  Author
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | Argument           | Man.  | Description                                                                                   |
    ...    +====================+=======+===============================================================================================+
    ...    | fr_dist_name_rfs   | Yes   | Output dictionary from 'SCFC Get RF DistName For Serial Number When Rfsharing'                |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | bts_id_rfs         | Yes   | Output dictionary from 'SCFC Get Bts Ids For FR When Rfsharing'                               |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | cell_class         | Yes   | Calss from range: NRCEL, LNCEL, WNCEL, GNCEL                                                  |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...
    ...    +--------------------+-------------------------------------------------------------------------------------------------------+
    ...    | Return Value       | Description                                                                                           |
    ...    +====================+=======================================================================================================+
    ...    | cell_info_rfs      | Rfs cells dictionary for desired ${cell_class}                                                        |
    ...    +--------------------+-------------------------------------------------------------------------------------------------------+
    ${primary_id}=  Set Variable  ${bts_id_rfs['scf_primary_id'][0]}
    ${secondary_id_list}=  Set Variable  ${bts_id_rfs['scf_secondary_id']}
    ${primary_cell_status}=  Run Keyword And Return Status  Should Be Empty  ${cfg['NODES']['${primary_id}']['${cell_class}']}
    ${cell_info_rfs}=  Run Keyword If  ${primary_cell_status}  Create Dictionary  scf_cellid_primary=${None}  scf_cell_count_primary=0
    ...  ELSE  _Get Cells From Primary Rfs  ${fr_dist_name_rfs}  ${primary_id}  ${cell_class}
    ${cell_secondary_list}=  Create List
    FOR  ${secondary_id}  IN  @{secondary_id_list}
      ${secondary_cell_status}=  Run Keyword And Return Status  Should Be Empty  ${cfg['NODES']['${secondary_id}']['${cell_class}']}
      Continue For Loop If  ${secondary_cell_status}
      ${tmp_secondary_cells}=  _Get Cells From Secondary Rfs  ${fr_dist_name_rfs}  ${secondary_id}  ${cell_class}
      ${cell_secondary_list}=  Combine Lists  ${cell_secondary_list}  ${tmp_secondary_cells}
    END
    ${cell_secondary_list}=  Remove Duplicates  ${cell_secondary_list}
    ${cell_secondary_count}=  Get Length  ${cell_secondary_list}
    Set To Dictionary  ${cell_info_rfs}  scf_cellid_secondary=${cell_secondary_list}  scf_cell_count_secondary=${cell_secondary_count}
    [Return]  ${cell_info_rfs}

_Get Cells From Primary Rfs
  [Arguments]  ${fr_dist_name_rfs}  ${primary_id}  ${cell_class}
  [Documentation]  Returns dictionary of cells for RF from master node when rfsharing defined in cfg dictionary.
  ...    Author:      daniel.bartkowiak@nokia.com
  ...    Maintainer:  Author
  ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
  ...    | Argument           | Man.  | Description                                                                                   |
  ...    +====================+=======+===============================================================================================+
  ...    | fr_dist_name_rfs   | Yes   | Output dictionary from 'SCFC Get RF DistName For Serial Number When Rfsharing'                |
  ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
  ...    | primary_id         | Yes   | Rfs master node id; can be found in output from 'SCFC Get Bts Ids For FR When Rfsharing'      |
  ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
  ...    | cell_class         | Yes   | Calss from range: NRCEL, LNCEL, WNCEL, GNCEL                                                  |
  ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
  ...
  ...    +--------------------+-------------------------------------------------------------------------------------------------------+
  ...    | Return Value       | Description                                                                                           |
  ...    +====================+=======================================================================================================+
  ...    | tmp_cell_info_rfs  | Rfs primary node cells dictionary for desired ${cell_class}                                            |
  ...    +--------------------+-------------------------------------------------------------------------------------------------------+
  ${cell_primary_list}=  Create List
  ${rf}=  Get Regexp Matches  ${fr_dist_name_rfs['primary_dn'][0]}  ASIRMOD-\\d+|RMOD-\\d+
  ${cfg_cell_dict}=  Set Variable  ${cfg['NODES']['${primary_id}']['${cell_class}']}
  FOR  ${id}  IN  @{cfg_cell_dict}
    ${is_cell_on_ru}=
    ...  Evaluate  ['pass' for scf_ru_list in ${cfg_cell_dict['${id}']['scf_ru_list']} if scf_ru_list.count("${rf[0]}") != 0].count("pass")
    Run Keyword If  ${is_cell_on_ru}  Append To List  ${cell_primary_list}  ${id}
  END
  ${cell_primary_list}=  Remove Duplicates  ${cell_primary_list}
  ${cell_primary_count}=  Get Length  ${cell_primary_list}
  ${tmp_primary_cells_dict}=  Create Dictionary  scf_cellid_primary=${cell_primary_list}  scf_cell_count_primary=${cell_primary_count}
  [Return]  ${tmp_primary_cells_dict}

_Get Cells From Secondary Rfs
    [Arguments]  ${fr_dist_name_rfs}  ${secondary_id}  ${cell_class}
    [Documentation]  Returns list of cells for RF from secondary node when rfsharing defined in cfg dictionary.
    ...    Author:      daniel.bartkowiak@nokia.com
    ...    Maintainer:  Author
    ...    +-----------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | Argument              | Man.  | Description                                                                                   |
    ...    +=======================+=======+===============================================================================================+
    ...    | fr_dist_name_rfs      | Yes   | Output dictionary from 'SCFC Get RF DistName For Serial Number When Rfsharing'                |
    ...    +-----------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | secondary_id          | Yes   | Rfs master node id; can be found in output from 'SCFC Get Bts Ids For FR When Rfsharing'      |
    ...    +-----------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | cell_class            | Yes   | Calss from range: NRCEL, LNCEL, WNCEL, GNCEL                                                  |
    ...    +-----------------------+-------+-----------------------------------------------------------------------------------------------+
    ...
    ...    +-----------------------+-------------------------------------------------------------------------------------------------------+
    ...    | Return Value          | Description                                                                                           |
    ...    +=======================+=======================================================================================================+
    ...    | tmp_slave_cells_list  | Rfs secondary node cells list for desired ${cell_class}                                               |
    ...    +-----------------------+-------------------------------------------------------------------------------------------------------+
    ${tmp_secondary_cells_list}=  Create List
    ${rf_dn}=  Get Matches  ${fr_dist_name_rfs['secondary_dn']}  MRBTS-${secondary_id}*
    ${rf}=  Get Regexp Matches  ${rf_dn[0]}  ASIRMOD-\\d+|RMOD-\\d+
    ${cfg_cell_dict}=  Set Variable  ${cfg['NODES']['${secondary_id}']['${cell_class}']}
    FOR  ${id}  IN  @{cfg_cell_dict}
      ${is_cell_on_ru}=
      ...   Evaluate  ['pass' for scf_ru_list in ${cfg_cell_dict['${id}']['scf_ru_list']} if scf_ru_list.count("${rf[0]}") != 0].count("pass")
      Run Keyword If  ${is_cell_on_ru}  Append To List  ${tmp_secondary_cells_list}  ${id}
    END
    [Return]  ${tmp_secondary_cells_list}

Count HW On Node
    [Arguments]  ${bts_id}
    [Documentation]  KW creates dictionary of counted HW on actual node and sets it to CFG.
    ...    Author:      daniel.bartkowiak@nokia.com
    ...    Maintainer:  Author
    ...    +-----------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | Argument              | Man.  | Description                                                                                   |
    ...    +=======================+=======+===============================================================================================+
    ...    | bts_id                | Yes   | id of current BTS                                                                             |
    ...    +-----------------------+-------+-----------------------------------------------------------------------------------------------+

    ${sm_num}=  Get Length  ${cfg['NODES']['${bts_id}']['scf_hw_sm_list']}
    ${fr_num}=  Get Length  ${cfg['NODES']['${bts_id}']['scf_hw_fr_list']}
    ${bbmod_num}=  Get Length  ${cfg['NODES']['${bts_id}']['scf_hw_bbmod_list']}
    ${fhs_num}=  Get Length  ${cfg['NODES']['${bts_id}']['scf_hw_fhs_list']}
    ${asir_num}=  Get Length  ${cfg['NODES']['${bts_id}']['scf_hw_asir_list']}
    ${ald_num}=  Get Length  ${cfg['NODES']['${bts_id}']['scf_hw_ald_list']}
    ${cablink_num}=  SCFC Get Cablink Count  ${cfg['NODES']['${bts_id}']['scf_file_path']}
    Set To Dictionary  ${cfg['NODES']['${bts_id}']}  scf_hw_count=&{EMPTY}
    Set To Dictionary  ${cfg['NODES']['${bts_id}']['scf_hw_count']}
    ...  SMOD=${sm_num}
    ...  RMOD=${fr_num}
    ...  BBMOD=${bbmod_num}
    ...  FHS=${fhs_num}
    ...  ASIRMOD=${asir_num}
    ...  ALD=${ald_num}
    ...  CABLINK=${cablink_num}

SCFC Get BBMOD Position Id
  [Arguments]  ${scf_file}  ${serial_number}
  [Documentation]
  ...  Description:
  ...   Returns list of serial numbers for all BBMODs defined in given SCFC file stored on local Robot PC.
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | scf_file               | Yes  | Path to scf file                                                   |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | serial_number          | Yes  | serial nuymber of tested BBMOD                                     |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  ${horizontalPosition}=  Evaluate Xpath  ${scf_file}
  ...  string(.//managedObject[contains(@class, "BBMOD_R")][p[@name='serialNumber']='${serial_number}']/p[(@name="horizontalPosition")])
  ${verticalPosition}=  Evaluate Xpath  ${scf_file}
  ...  string(.//managedObject[contains(@class, "BBMOD_R")][p[@name='serialNumber']='${serial_number}']/p[(@name="verticalPosition")])
  [Return]  ${horizontalPosition}  ${verticalPosition}

Prepare Neighbour Dictionary For RUs
    [Arguments]  ${bts_id}
    [Documentation]
    ...  Description:
    ...  KW prepares full dict of RMODs/ASIRMODs with theirs neighbours. Returned dictionary is used directly in setup
    ...  to create chain affected list of RMODs/ASIRMODs for each module.
    ...  Arguments:
    ...  +========================+======+====================================================================+
    ...  | Argument               | Man. | Description                                                        |
    ...  +========================+======+====================================================================+
    ...  | bts_id                 | Yes  | id of current BTS                                                  |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...
    ...  +-----------------------+-------------------------------------------------------------------------------+
    ...  | Return Value          | Description                                                                   |
    ...  +=======================+===============================================================================+
    ...  | full_neighbour_dict   | full dict RMOD/ASIRMOD with neighbours                                        |
    ...  +-----------------------+-------------------------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: Author
    ${scfc}=  Set Variable  ${cfg.NODES['${bts_id}']['parsed_scf']}
    ${asir_dict}=  Get Neighbours For  ${bts_id}  ${scfc}  ASIRMOD
    ${rmod_dict}=  Get Neighbours For  ${bts_id}  ${scfc}  RMOD
    ${full_neighbour_dict}=  Create Dictionary  &{asir_dict}  &{rmod_dict}
    [Return]  ${full_neighbour_dict}

Get Neighbours For
    [Arguments]  ${bts_id}  ${scfc}  ${class}
    [Documentation]
    ...  Description:
    ...  KW iterates through all class objects (RMOD/ASIRMOD). Based on cablinks on selected RU where RU exists as secondEndPoint
    ...  or firstEndPoint there is prepared dictionary where each key (RU) contains embedded dictionary with its neighbouring
    ...  RUs placed before/after on tested BTS. If RU doesn't have before/after neighbours it gets None in dict. Dictionary is used
    ...  further chain dicovery. Dictionary is created based on SCFC file stored in CFG.
    ...  Arguments:
    ...  +========================+======+====================================================================+
    ...  | Argument               | Man. | Description                                                        |
    ...  +========================+======+====================================================================+
    ...  | bts_id                 | Yes  | id of current BTS                                                  |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | scfc                   | Yes  | parsed scf file                                                    |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | class                  | Yes  | possible RMOD/ASIRMOD                                              |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...
    ...  +--------------------+-------------------------------------------------------------------------------+
    ...  | Return Value       | Description                                                                   |
    ...  +====================+===============================================================================+
    ...  | final_dict         | dict with all RUs and its neiiiighbours                                       |
    ...  +--------------------+-------------------------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: Author
    ${final_dict}=  Create Dictionary
    ${mod_sn_list}=  Set Variable If  "${class}"=="RMOD"  ${cfg.NODES['${bts_id}']['scf_hw_fr_list']}  ${cfg.NODES['${bts_id}']['scf_hw_asir_list']}
    FOR  ${serial_number}  IN  @{mod_sn_list}
      Set To Dictionary  ${final_dict}  ${serial_number}=&{EMPTY}
      ${ru_dn}=  SCFC Get RU Distname By Serial Number For Chaining  ${scfc}  ${class}  ${serial_number}
	  ${first_end_point_cablinks}  ${sec_end_point_cablinks}=  SCFC Get Cablinks DistNames By RU Serial Number For Chaining
	  ...  ${scfc}  ${ru_dn}
	  ${ru_after_list}=  Create List
	  ${ru_before_list}=  Create List
	  FOR  ${first_end_point_cablink}  IN  @{first_end_point_cablinks}
	    ${mo_class_condition}=  Set Variable  contains(@distName, '${first_end_point_cablink}') and not(contains(@class, '_R'))
	    ${ru_after_dn}=  Evaluate Xpath  ${scfc}
        ...  string(.//managedObject[${mo_class_condition}]/p[@name='secondEndpointDN']/text())
        ${ru_after_sn}=  Evaluate Xpath  ${scfc}
        ...  string(.//managedObject[contains(@class, ':${class}_R') and (p[@name='configDN']='${ru_after_dn}')]/p[@name='serialNumber']/text())
        Append To List  ${ru_after_list}  ${ru_after_sn}
      END
      FOR  ${sec_end_point_cablink}  IN  @{sec_end_point_cablinks}
	    ${mo_class_condition}=  Set Variable  contains(@distName, '${sec_end_point_cablink}') and not(contains(@class, '_R'))
	    ${ru_before_dn}=  Evaluate Xpath  ${scfc}
        ...  string(.//managedObject[${mo_class_condition}]/p[@name='firstEndpointDN']/text())
        Continue For Loop If  'RMOD' not in '${ru_before_dn}'
        ${ru_before_sn}=  Evaluate Xpath  ${scfc}
        ...  string(.//managedObject[contains(@class, ':${class}_R') and (p[@name='configDN']='${ru_before_dn}')]/p[@name='serialNumber']/text())
        Append To List  ${ru_before_list}  ${ru_before_sn}
      END
      Remove Duplicates  ${ru_after_list}
      ${after_tmp_list}=  Set Variable If  "${ru_after_list}"=="@{EMPTY}"  ${NONE}  ${ru_after_list}
      ${before_tmp}=  Set Variable If  "${ru_before_list}"=="@{EMPTY}"  ${NONE}  ${ru_before_list}
      Set To Dictionary  ${final_dict['${serial_number}']}  before=${before_tmp}  after=${after_tmp_list}
    END
    [Return]  ${final_dict}

Prepare Chain Affested Dictionary For RUs
    [Arguments]  ${full_neighbour_dict}
    [Documentation]
    ...  Description:
    ...  KW iterates through 'full_neighbour_dict' to find each module that is last in chain.
    ...  Even single module is treated as separate chain without neighbours. If last module is found (key 'after' is None)
    ...  another loop starts to look before actual module and creates affected ru list for each one
    ...  until first chain module detected (key 'before' is None). Single modules have always None in 'after' and 'before' key.
    ...  Chains with branches are also supported.
    ...  Arguments:
    ...  +========================+======+====================================================================+
    ...  | Argument               | Man. | Description                                                        |
    ...  +========================+======+====================================================================+
    ...  | full_neighbour_dict    | Yes  | dictionary with RUs and its 'after'/'before' neighbours            |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...
    ...  +---------------------------+-------------------------------------------------------------------------------+
    ...  | Return Value              | Description                                                                   |
    ...  +===========================+===============================================================================+
    ...  | rus_affected_chains_dict  | dictionary with RUs and their affected modules lists                          |
    ...  +---------------------------+-------------------------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: Author
    ${rus_affected_chains_dict}=  Create Dictionary
    FOR  ${current_radio}  IN  @{full_neighbour_dict}
      Continue For Loop If  "${full_neighbour_dict['${current_radio}']['after']}"!="${NONE}"
      ${affected_rus_tmp_list}=  Create List
      Set To Dictionary  ${rus_affected_chains_dict}  ${current_radio}=@{EMPTY}
      ${chain_radio}=  Set Variable  ${current_radio}
      WHILE  "${full_neighbour_dict['${chain_radio}']['before']}"!="${NONE}"
        Append To List  ${affected_rus_tmp_list}  ${chain_radio}
        ${is_ru_in_dict}=  Run Keyword And Return Status  Dictionary Should Contain Key
        ...  ${rus_affected_chains_dict}
        ...  ${full_neighbour_dict['${chain_radio}']['before'][0]}
        IF  ${is_ru_in_dict}
          ${joined_list}=  Combine Lists
          ...  ${rus_affected_chains_dict['${full_neighbour_dict['${chain_radio}']['before'][0]}']}
          ...  ${affected_rus_tmp_list[:]}
          Set To Dictionary  ${rus_affected_chains_dict}  ${full_neighbour_dict['${chain_radio}']['before'][0]}=${joined_list}
        ELSE
          Set To Dictionary  ${rus_affected_chains_dict}  ${full_neighbour_dict['${chain_radio}']['before'][0]}=${affected_rus_tmp_list[:]}
        END
        ${chain_radio}=  Set Variable  ${full_neighbour_dict['${chain_radio}']['before'][0]}
      END
      IF  "${full_neighbour_dict['${chain_radio}']['before']}"=="${NONE}" and "${full_neighbour_dict['${chain_radio}']['after']}"=="${NONE}"
        Set To Dictionary  ${rus_affected_chains_dict}  ${chain_radio}=@{EMPTY}
      END
    END
    FOR  ${radio}  IN  @{rus_affected_chains_dict}
      ${unique_list}=  Remove Duplicates  ${rus_affected_chains_dict['${radio}']}
      Set To Dictionary  ${rus_affected_chains_dict}  ${radio}=${unique_list}
    END
    Log  ${rus_affected_chains_dict}
    [Return]  ${rus_affected_chains_dict}

