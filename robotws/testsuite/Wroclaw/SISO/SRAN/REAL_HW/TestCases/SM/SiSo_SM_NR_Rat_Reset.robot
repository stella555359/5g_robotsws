*** Settings ***
Documentation
...  AUTHOR-daniel.bartkowiak@nokia.com  MAINTAINER-daniel.bartkowiak@nokia.com
...
...  *****************
...  Basic information
...  *****************
...  TC for NR RAT reset from ADMIN API. NR Rat reset is performed in Soft/Hard mode regarding enhanced Rat reset introduced in CB008880
...  Before SBTS24R2 only Soft reset is available. Soft Reset means that isolated RAT reset is performed without SOC reset
...  (ABIL excluded from this condition). Hard Reset means that each baseband with NR technology will be impacted by SoC reset.
...  SoC reset can have impact on RUs and further on all cells commissioned on that RU.
...  SoC reset impacts also availabilitystatus on ASOE, ASOF, ASOH, ASOG (all smods with built-in baseband).
...  Note. If exists not utizlized baseband module ABIO, ABIN, ABIP, ABIQ please set bbmodBoardConfigType to "Auto"
...
...  ******************
...  History of changes
...  ******************
...  - 06.11.2024 - Initial creation in New Framework

Resource  ./SM_Rat_Reset.resource

*** Variables ***
${NR_RAT_RESET_TIMEOUT}         # Timeout (in seconds) for ADMIN API NR RAT reset. if not provided default value from varaibles file used
                                # Procedure starts with ADMIN trigger and ends when NR RAT reset is completed

${STARTUP_TIMEOUT}=  180        # Timeout (in seconds) for RAT startup after reset. Default timeout 180s.

@{RAT_IMPACT_LIST}=  @{EMPTY}   # Allowed values:
                                # '@{EMPTY}' - if no impact on other RATs
                                # 'eutranCellId  cellId  gsmSectorID' - if single cells impacted other than NR on tested BTS,
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
TC__STATE__NR_RAT_reset_from_ADMIN
    Common Test Setup  tools_to_setup=syslog_ADMIN
    Preconditions NR RAT Reset
    Run Keyword If
    ...  "${CFG['NODES']['${TESTED_BTS_ID}']['active_release']}"<"SBTS24R2" or "${CFG['NODES']['${TESTED_BTS_ID}']['scf_hw_release']}"!="AirScale"
    ...  Legacy NR RAT Reset Mode
    ...  ELSE
    ...  Enhanced NR RAT Reset Mode
    Postconditions NR RAT Reset
    [Teardown]  Common Test Teardown

Get Soft NR Reset Objects
    [Documentation]  KW prepares impacted/not impacted objects during soft NR rat reset on all nodes
    ${soft_reset_dict}=  Find NR Soft Reset Impact
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
      ${bb_impacted_ids}=  Run Keyword If  "${bts_id}"=="${TESTED_BTS_ID}"  Get BB ABIL
      ...  ELSE  Create List
      ${impacted_list}=  Run Keyword If  "${bts_id}"=="${TESTED_BTS_ID}"
      ...  Combine Lists  ${soft_reset_dict['${TESTED_BTS_ID}']['impacted']}  ${all_nr_ids}  ${bb_impacted_ids}
      ...  ELSE  Set Variable  ${soft_reset_dict['${bts_id}']['impacted']}
      ${all_objects}=  Run Keyword If  "${bts_id}"=="${TESTED_BTS_ID}" and "${bb_impacted_ids}"!="@{EMPTY}"
      ...  Combine Lists  ${all_ln_ids}  ${all_wn_ids}  ${all_gn_ids}  ${all_sm_ids}  ${all_bb_ids}
      ...  ELSE  Combine Lists
      ...  ${all_nr_ids}  ${all_ln_ids}  ${all_wn_ids}  ${all_gn_ids}  ${all_sm_ids}
      ...  ${all_bb_ids}  ${all_ru_ids}  ${all_asir_ids}  ${all_fhs_ids}
      Remove Values From List  ${all_objects}  @{impacted_list}
      ${not_impacted_list}=  Set Variable  ${all_objects}
      Set To Dictionary  ${soft_reset_dict['${bts_id}']}  impacted=${impacted_list}  not_impacted=${not_impacted_list}
    END
    Set Test Variable  ${SOFT_RESET_DICT}  ${soft_reset_dict}

Get Hard NR Reset Objects
    [Documentation]  KW prepares impacted/not impacted objects during hard NR rat reset on all nodes
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
      ${bb_impacted_ids}=  Run Keyword If  "${bts_id}"=="${TESTED_BTS_ID}"  Get BB For NR Hard Reset
      ...  ELSE  Create List
      ${sm_impacted_ids}=  Run Keyword If  "${bts_id}"=="${TESTED_BTS_ID}"  Get SM For NR Hard Reset
      ...  ELSE  Create List
      ${impacted_list}=  Run Keyword If  "${bts_id}"=="${TESTED_BTS_ID}"
      ...  Combine Lists  ${hard_reset_dict['${TESTED_BTS_ID}']['impacted']}  ${all_nr_ids}  ${bb_impacted_ids}  ${sm_impacted_ids}
      ...  ELSE  Set Variable  ${hard_reset_dict['${TESTED_BTS_ID}']['impacted']}
      ${all_objects}=  Run Keyword If  "${bts_id}"=="${TESTED_BTS_ID}" and ("${bb_impacted_ids}"!="@{EMPTY}" or "${sm_impacted_ids}"!="@{EMPTY}")
      ...  Combine Lists  ${all_ln_ids}  ${all_wn_ids}  ${all_gn_ids}  ${all_bb_ids}  ${all_sm_ids}
      ...  ELSE  Combine Lists
      ...  ${all_nr_ids}  ${all_ln_ids}  ${all_wn_ids}  ${all_gn_ids}
      ...  ${all_ru_ids}  ${all_asir_ids}  ${all_fhs_ids}  ${all_sm_ids}
      Remove Values From List  ${all_objects}  @{impacted_list}
      ${not_impacted_list}=  Set Variable  ${all_objects}
      Set To Dictionary  ${hard_reset_dict['${bts_id}']}  impacted=${impacted_list}  not_impacted=${not_impacted_list}
    END
    Set Test Variable  ${HARD_RESET_DICT}  ${hard_reset_dict}

Get BB ABIL
    [Documentation]  KW finds ABIL bb cards on tested bts.
    ...  Return:
    ...  +------------------------+-----------------------------------------------------------------------------------------+
    ...  | Return Value           | Description                                                                             |
    ...  +========================+=========================================================================================+
    ...  | abil_runtime_distnames |  runtine distnames of abil bb cards                                                     |
    ...  +------------------------+-----------------------------------------------------------------------------------------+
    ${status}  ${bb_message}=  Run Keyword And Ignore Error  admin.Assert Any  BBMOD  productName=regex"(?i)ABIL"  connection=${TESTED_BTS_ID}
    Return From Keyword If  "${status}"=="FAIL"  @{EMPTY}
    ${abil_runtime_distnames}=  Create List
    FOR  ${bb}  IN  @{bb_message}
      Run Keyword If  "${bb['productName']}"=="ABIL AirScale Capacity"  Append To List  ${abil_runtime_distnames}  ${bb['id']}
    END
    [Return]  ${abil_runtime_distnames}

Get SM For NR Hard Reset
    [Documentation]  KW finds impacted SMODs on tested bts.
    ...  Return:
    ...  +--------------------------+-----------------------------------------------------------------------------------------+
    ...  | Return Value             | Description                                                                             |
    ...  +==========================+=========================================================================================+
    ...  | sm_impacted_runtime_list |  runtine distnames of impacted smods                                                    |
    ...  +--------------------------+-----------------------------------------------------------------------------------------+
    ${sm_tmp_config_list}=  Evaluate Xpath  ${CFG['NODES']['${TESTED_BTS_ID}']['scf_file_path']}
    ...  .//managedObject[contains(@distName, "/SMOD-")][contains(p[@name="smodBoardConfigType"], "NR")]/@distName
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

Get BB For NR Hard Reset
    [Documentation]  KW finds all impacted bb cards on tested bts.
    ...  Return:
    ...  +------------------------+-----------------------------------------------------------------------------------------+
    ...  | Return Value           | Description                                                                             |
    ...  +========================+=========================================================================================+
    ...  | all_impacted_bbs_list  |  runtine distnames of impacted bb cards                                                 |
    ...  +------------------------+-----------------------------------------------------------------------------------------+
    ${bb_impacted_config_list}=  Evaluate Xpath  ${CFG['NODES']['${TESTED_BTS_ID}']['scf_file_path']}
    ...  .//managedObject[contains(@distName, "/BBMOD-")][contains(p[@name="bbmodBoardConfigType"], "NR")]/@distName
    Return From Keyword If  "${bb_impacted_config_list}"=="@{EMPTY}"  @{EMPTY}
    ${bb_impacted_runtime_list}=  Create List
    ${bbs_list}=  admin.Get Fbb Info  connection=${TESTED_BTS_ID}
    FOR  ${bb}  IN  @{bbs_list}
      Run Keyword If  "${bb['id']['configuration']}" in ${bb_impacted_config_list}
      ...  Append To List  ${bb_impacted_runtime_list}  ${bb['id']['internal']}
    END
    ${abil_runtime_distnames}=  Get BB ABIL
    ${all_impacted_bbs_list}=  Combine Lists  ${bb_impacted_runtime_list}  ${abil_runtime_distnames}
    [Return]  ${all_impacted_bbs_list}

Find NR Soft Reset Impact
    [Documentation]  KW finds impacted objects for soft reset
    ...  Return:
    ...  +------------------------+-----------------------------------------------------------------------------------------+
    ...  | Return Value           | Description                                                                             |
    ...  +========================+=========================================================================================+
    ...  | impacted_cells_dict    |  dictionary with impacted objects during soft reset                                     |
    ...  +------------------------+-----------------------------------------------------------------------------------------+
    ${impacted_cells_dict}=  Create Dictionary
    ${embedded_dict}=  Create Dictionary  impacted=@{EMPTY}
    FOR  ${bts_id}  IN  @{CFG.active_bts_list}
      Set To Dictionary  ${impacted_cells_dict}  ${bts_id}=${embedded_dict}
    END
    Return From Keyword  ${impacted_cells_dict}
