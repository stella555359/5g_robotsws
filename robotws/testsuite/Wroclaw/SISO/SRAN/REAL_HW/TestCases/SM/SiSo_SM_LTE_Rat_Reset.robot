*** Settings ***
Documentation
...  AUTHOR-daniel.bartkowiak@nokia.com  MAINTAINER-daniel.bartkowiak@nokia.com
...
...  *****************
...  Basic information
...  *****************
...  TC for LTE RAT reset from ADMIN API. LTE Rat reset is performed in Soft/Hard mode regarding enhanced Rat reset introduced in CB008880
...  Before SBTS24R2 only Soft reset is available. Soft Reset means that isolated RAT reset is performed without SOC reset
...  (ABIC excluded from this condition). Hard Reset means that each baseband with LTE technology will be impacted by SoC reset
...  (ABIA excluded from this condition). SoC reset can have impact on RUs and further on all cells commissioned on that RU.
...  SoC reset impacts also availabilitystatus on ASOE, ASOF, ASOH, ASOG (all smods with built-in baseband).
...  Note. If exists not utizlized baseband module ABIO, ABIN, ABIP, ABIQ please set set bbmodBoardConfigType to "Auto"
...
...  ******************
...  History of changes
...  ******************
...  - 06.11.2024 - Initial creation in New Framework

Resource  ./SM_Rat_Reset.resource

*** Variables ***
${LTE_RAT_RESET_TIMEOUT}        # Timeout (in seconds) for ADMIN API LTE RAT reset. if not provided default value from varaibles file used
                                # Procedure starts with ADMIN trigger and ends when LTE RAT reset is completed

${STARTUP_TIMEOUT}=  180        # Timeout (in seconds) for RAT startup after reset. Default timeout 180s.

@{RAT_IMPACT_LIST}=  @{EMPTY}   # Allowed values:
                                # '@{EMPTY}' - if no impact on other RATs
                                # 'nrCellIdentity  cellId  gsmSectorID' - if single cells impacted other than LTE on tested BTS,
                                # each ID can be taken from runtime details side bar
                                # default value is '@{EMPTY}'
                                # NOTE. when multinode config is used, check also other nodes for possible impact

${TESTED_BTS_ID}=  ${EMPTY}     # In case of multinode config test must be executed on one node at a time with specified 'TESTED_BTS_ID'
                                # If single node config, 'TESTED_BTS_ID' is not used.

@{BB_SN_LIST}=  @{EMPTY}        # Variable can be used to set desired sync cablink on particular BB mods. If RU/FHS on your config
                                # has dual link and sync link is establishing randomly you can reset specified BB mods to force
                                # sync link on desired BB mods.

${SIMPLE_ONAIR}=  ${FALSE}      # Set to "TRUE' if 'RAT_IMPACT' is random despite using 'BB_SN_LIST' (aplicable only if no other option available)
                                # 'TRUE' means onair is validated after RAT reset without checking impact between cells in ims history,
                                # 'RAT_IMPACT' is skipped.
                                # 'FALSE' means that 'RAT_IMPACT' is verified on selected cells in ims history

*** Keywords ***
TC__STATE__LTE_RAT_reset_from_ADMIN
    Common Test Setup
    Preconditions LTE RAT Reset
    Run Keyword If
    ...  "${CFG['NODES']['${TESTED_BTS_ID}']['active_release']}"<"SBTS24R2" or "${CFG['NODES']['${TESTED_BTS_ID}']['scf_hw_release']}"!="AirScale"
    ...  Legacy LTE RAT Reset Mode
    ...  ELSE
    ...  Enhanced LTE RAT Reset Mode
    Postconditions LTE RAT Reset
    [Teardown]  Common Test Teardown

Get Soft LTE Reset Objects
    [Documentation]  KW prepares impacted/not impacted objects during soft LTE rat reset on all nodes
    ${soft_reset_dict}=  Find LTE Soft Reset Impact
    FOR  ${bts_id}  IN  @{CFG.active_bts_list}
      ${all_ln_ids}=  admin.Get Ids For All  LNCEL  search_for_iot_cells=${True}  connection=${bts_id}
      ${all_nr_ids}=  admin.Get Ids For All  NRCEL  connection=${bts_id}
      ${all_wn_ids}=  admin.Get Ids For All  WNCEL  connection=${bts_id}
      ${all_gn_ids}=  admin.Get Ids For All  GNCEL  connection=${bts_id}
      ${all_sm_ids}=  admin.Get Ids For All  SMOD  connection=${bts_id}
      ${all_bb_ids}=  admin.Get Ids For All  BBMOD  connection=${bts_id}
      ${all_ru_ids}=  admin.Get Ids For All  RMOD  connection=${bts_id}
      ${all_asir_ids}=  admin.Get Ids For All  ASIRMOD  connection=${bts_id}
      ${all_fhs_ids}=  admin.Get Ids For All  FHS  connection=${bts_id}
      ${bb_impacted_ids}=  Run Keyword If  "${bts_id}"=="${TESTED_BTS_ID}"  Get BB ABIC
      ...  ELSE  Create List
      ${impacted_list}=  Run Keyword If  "${bts_id}"=="${TESTED_BTS_ID}"
      ...  Combine Lists  ${soft_reset_dict['${TESTED_BTS_ID}']['impacted']}  ${all_ln_ids}  ${bb_impacted_ids}
      ...  ELSE  Set Variable  ${soft_reset_dict['${bts_id}']['impacted']}
      ${all_objects}=  Run Keyword If  "${bts_id}"=="${TESTED_BTS_ID}" and "${bb_impacted_ids}"!="@{EMPTY}"
      ...  Combine Lists  ${all_nr_ids}  ${all_wn_ids}  ${all_gn_ids}  ${all_sm_ids}  ${all_bb_ids}
      ...  ELSE  Combine Lists
      ...  ${all_nr_ids}  ${all_ln_ids}  ${all_wn_ids}  ${all_gn_ids}  ${all_sm_ids}
      ...  ${all_bb_ids}  ${all_ru_ids}  ${all_asir_ids}  ${all_fhs_ids}
      Remove Values From List  ${all_objects}  @{impacted_list}
      ${not_impacted_list}=  Set Variable  ${all_objects}
      Set To Dictionary  ${soft_reset_dict['${bts_id}']}  impacted=${impacted_list}  not_impacted=${not_impacted_list}
    END
    Set Test Variable  ${SOFT_RESET_DICT}  ${soft_reset_dict}

Get Hard LTE Reset Objects
    [Documentation]  KW prepares impacted/not impacted objects during hard LTE rat reset on all nodes
    ${hard_reset_dict}=  Get Hard Cells Impact
    FOR  ${bts_id}  IN  @{CFG.active_bts_list}
      ${all_ln_ids}=  admin.Get Ids For All  LNCEL  search_for_iot_cells=${True}  connection=${bts_id}
      ${all_nr_ids}=  admin.Get Ids For All  NRCEL  connection=${bts_id}
      ${all_wn_ids}=  admin.Get Ids For All  WNCEL  connection=${bts_id}
      ${all_gn_ids}=  admin.Get Ids For All  GNCEL  connection=${bts_id}
      ${all_bb_ids}=  admin.Get Ids For All  BBMOD  connection=${bts_id}
      ${all_ru_ids}=  admin.Get Ids For All  RMOD  connection=${bts_id}
      ${all_asir_ids}=  admin.Get Ids For All  ASIRMOD  connection=${bts_id}
      ${all_fhs_ids}=  admin.Get Ids For All  FHS  connection=${bts_id}
      ${all_sm_ids}=  admin.Get Ids For All  SMOD  connection=${bts_id}
      ${bb_impacted_ids}=  Run Keyword If  "${bts_id}"=="${TESTED_BTS_ID}"  Get BB For LTE Hard Reset
      ...  ELSE  Create List
      ${sm_impacted_ids}=  Run Keyword If  "${bts_id}"=="${TESTED_BTS_ID}"  Get SM For LTE Hard Reset
      ...  ELSE  Create List
      ${impacted_list}=  Run Keyword If  "${bts_id}"=="${TESTED_BTS_ID}"
      ...  Combine Lists  ${hard_reset_dict['${TESTED_BTS_ID}']['impacted']}  ${all_ln_ids}  ${bb_impacted_ids}  ${sm_impacted_ids}
      ...  ELSE  Set Variable  ${hard_reset_dict['${TESTED_BTS_ID}']['impacted']}
      ${all_objects}=  Run Keyword If  "${bts_id}"=="${TESTED_BTS_ID}" and ("${bb_impacted_ids}"!="@{EMPTY}" or "${sm_impacted_ids}"!="@{EMPTY}")
      ...  Combine Lists  ${all_nr_ids}  ${all_wn_ids}  ${all_gn_ids}  ${all_bb_ids}  ${all_sm_ids}
      ...  ELSE  Combine Lists
      ...  ${all_nr_ids}  ${all_ln_ids}  ${all_wn_ids}  ${all_gn_ids}
      ...  ${all_ru_ids}  ${all_asir_ids}  ${all_fhs_ids}  ${all_sm_ids}
      Remove Values From List  ${all_objects}  @{impacted_list}
      ${not_impacted_list}=  Set Variable  ${all_objects}
      Set To Dictionary  ${hard_reset_dict['${bts_id}']}  impacted=${impacted_list}  not_impacted=${not_impacted_list}
    END
    Set Test Variable  ${HARD_RESET_DICT}  ${hard_reset_dict}

Get BB ABIC
    [Documentation]  KW finds ABIC bb cards on tested bts.
    ...  Return:
    ...  +------------------------+-----------------------------------------------------------------------------------------+
    ...  | Return Value           | Description                                                                             |
    ...  +========================+=========================================================================================+
    ...  | abic_runtime_distnames |  runtine distnames of abil bb cards                                                     |
    ...  +------------------------+-----------------------------------------------------------------------------------------+
    ${status}  ${bb_message}=  Run Keyword And Ignore Error  admin.Assert Any  BBMOD  productName=regex"(?i)ABIC"  connection=${TESTED_BTS_ID}
    Return From Keyword If  "${status}"=="FAIL"  @{EMPTY}
    ${abic_runtime_distnames}=  Create List
    FOR  ${bb}  IN  @{bb_message}
      Run Keyword If  "${bb['productName']}"=="ABIC AirScale Capacity"  Append To List  ${abic_runtime_distnames}  ${bb['id']}
    END
    [Return]  ${abic_runtime_distnames}

Get SM For LTE Hard Reset
    [Documentation]  KW finds impacted SMODs on tested bts.
    ...  Return:
    ...  +--------------------------+-----------------------------------------------------------------------------------------+
    ...  | Return Value             | Description                                                                             |
    ...  +==========================+=========================================================================================+
    ...  | sm_impacted_runtime_list |  runtine distnames of impacted smods                                                    |
    ...  +--------------------------+-----------------------------------------------------------------------------------------+
    ${sm_tmp_config_list}=  Evaluate Xpath  ${CFG['NODES']['${TESTED_BTS_ID}']['scf_file_path']}
    ...  .//managedObject[contains(@distName, "/SMOD-")][contains(p[@name="smodBoardConfigType"], "LTE")]/@distName
    Return From Keyword If  "${sm_tmp_config_list}"=="@{EMPTY}"  @{EMPTY}
    ${sm_impacted_config_list}=  Create List
    FOR  ${sm_tmp}  IN  @{sm_tmp_config_list}
      ${sm_conf}  ${not_used}=  Split String From Right  ${sm_tmp}  /  1
      Append To List  ${sm_impacted_config_list}  ${sm_conf}
    END
    ${sm_impacted_runtime_list}=  Create List
    ${fsms_list}=  admin.Get Fsm Info  connection=${TESTED_BTS_ID}
    FOR  ${sm}  IN  @{fsms_list}
      Run Keyword If  "${sm['id']['configuration']}" in ${sm_impacted_config_list}
      ...  Append To List  ${sm_impacted_runtime_list}  ${sm['id']['internal']}
    END
    [Return]  ${sm_impacted_runtime_list}

Get BB For LTE Hard Reset
    [Documentation]  KW finds all impacted bb cards on tested bts.
    ...  Return:
    ...  +------------------------+-----------------------------------------------------------------------------------------+
    ...  | Return Value           | Description                                                                             |
    ...  +========================+=========================================================================================+
    ...  | all_impacted_bbs_list  |  runtine distnames of impacted bb cards                                                 |
    ...  +------------------------+-----------------------------------------------------------------------------------------+
    ${bb_impacted_config_list}=  Evaluate Xpath  ${CFG['NODES']['${TESTED_BTS_ID}']['scf_file_path']}
    ...  .//managedObject[contains(@distName, "/BBMOD-")][contains(p[@name="bbmodBoardConfigType"], "LTE")]/@distName
    Return From Keyword If  "${bb_impacted_config_list}"=="@{EMPTY}"  @{EMPTY}
    ${bb_impacted_runtime_list}=  Create List
    ${bbs_list}=  admin.Get Fbb Info  connection=${TESTED_BTS_ID}
    FOR  ${bb}  IN  @{bbs_list}
      Run Keyword If  "${bb['id']['configuration']}" in ${bb_impacted_config_list}
      ...  Append To List  ${bb_impacted_runtime_list}  ${bb['id']['internal']}
    END
    ${abic_runtime_distnames}=  Get BB ABIC
    ${all_impacted_bbs_list}=  Combine Lists  ${bb_impacted_runtime_list}  ${abic_runtime_distnames}
    [Return]  ${all_impacted_bbs_list}

Find LTE Soft Reset Impact
    [Documentation]  KW finds impacted nr cells for soft reset
    ...  Return:
    ...  +------------------------+-----------------------------------------------------------------------------------------+
    ...  | Return Value           | Description                                                                             |
    ...  +========================+=========================================================================================+
    ...  | impacted_nr_cells_dict |  dictionary with impacted nr cells during soft reset                                    |
    ...  +------------------------+-----------------------------------------------------------------------------------------+
    ${nr_impacted_list}=  Evaluate Xpath  ${CFG['NODES']['${TESTED_BTS_ID}']['scf_file_path']}
    ...  .//managedObject[contains(@distName, "/LNRELGNBCELL-")]/p[@name="nrCellId"]
    ${impacted_nr_cells_dict}=  Create Dictionary
    ${embedded_dict}=  Create Dictionary  impacted=@{EMPTY}
    FOR  ${bts_id}  IN  @{CFG.active_bts_list}
      Set To Dictionary  ${impacted_nr_cells_dict}  ${bts_id}=${embedded_dict}
    END
    Return From Keyword If  "${nr_impacted_list}"=="@{EMPTY}"  ${impacted_nr_cells_dict}
    FOR  ${nr_impacted}  IN  @{nr_impacted_list}
      ${nr_impacted}=  XML.Get Element Text  ${nr_impacted}
      ${nr_cell_distname}  ${bts_id}=  Search For Cell In Config LTE RAT Reset  nr_impacted=${nr_impacted}
      Append to List  ${impacted_nr_cells_dict['${bts_id}']['impacted']}  ${nr_cell_distname}
    END
    [Return]  ${impacted_nr_cells_dict}

Search For Cell In Config LTE RAT Reset
    [Arguments]  ${nr_impacted}
    [Documentation]  KW searches provided nr_impacted on tested configuration through all available NR RATs. If not found KW fails.
    ...  Arguments:
    ...  +--------------+-------+----------------------------------------------------------------------------------------+
    ...  | Argument     | Man.  | Description                                                                            |
    ...  +==============+=======+========================================================================================+
    ...  | nr_impacted  | Yes   | value of 'nrCellIdentity, eutranCellId, cellId or gsmSectorID'                         |
    ...  +--------------+-------+----------------------------------------------------------------------------------------+
    ...  Return:
    ...  +---------------------+-----------------------------------------------------------------------------------------+
    ...  | Return Value        | Description                                                                             |
    ...  +=====================+=========================================================================================+
    ...  | distname            |  runtine distname of nr_impacted cell                                                   |
    ...  +---------------------+-----------------------------------------------------------------------------------------+
    ...  | bts_id              |  bts_id of node that nr_impacted cell belongs to                                        |
    ...  +---------------------+-----------------------------------------------------------------------------------------+
    FOR  ${bts_id}  IN  @{CFG.active_bts_list}
      ${status}  ${nr_cells}=  Run Keyword And Ignore Error  admin.Assert Any  NRCEL  operationalState=enabled  connection=${bts_id}
      Continue For Loop If  "${status}"=="FAIL"
      ${nr_cell_distname}=  Cell Search  cells_details_list=${nr_cells}  cell_id=${nr_impacted}  parameter=nrCellIdentity
      Return From Keyword If  '${nr_cell_distname}'!='${EMPTY}'  ${nr_cell_distname}  ${bts_id}
    END
    Logging With Timestamp
    ...  message=NR cell with nrCellIdentity=${nr_impacted} not found in tested config.
    ...  style=ERROR
    Fail  NR cell with nrCellIdentity=${nr_impacted} not found in tested config.
