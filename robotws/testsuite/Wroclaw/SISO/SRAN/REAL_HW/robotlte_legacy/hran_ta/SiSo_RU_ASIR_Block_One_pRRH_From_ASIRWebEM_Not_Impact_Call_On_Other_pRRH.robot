*** Settings ***
Documentation
...    Author:        przemyslaw.kempa@nokia.com
...    Maintainer:    Przemysław Kempa

Resource    ../tc_scenarios.robot
Resource    resources/ca_Recovery_link_break.robot
#Resource    ../SiSo_L3_Call.robot
Library     taf.sbts.oam.sc.rest   WITH NAME  rest


*** Keywords ***
TC_SiSo_RU_ASIR_Block_One_pRRH_From_ASIRWebEM_Not_Impact_Call_On_Other_pRRH
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-28933
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Purpose of this scenario is to block one pRRH and verify not impact call on the other pRRH
    ...  We can provide S/N of tested pRRH or test will choose randomly one which will block
    ...  Optional variable in cfg to perform test
    ...  e.g.
    ...  pRRH=NH230800640
    ...
    ...  *** Test Variable For L3 Call ***
    ...  ${CELLS_YAML_PATH}                 #mandatory path for ue_config.yaml
    ...
    ...  *****************
    ...  History of change
    ...  *****************
    ...

    Set Tags	CA-CM    AUTHOR-przemyslaw.kempa@nokia.com    MAINTAINER-przemyslaw.kempa@nokia.com
    ...		    GROUP_IN_CHARGE- MN RAN Pz 4 WRO 8     PHASE-CRT  FEATURE-CB00
  Common Test Setup
  Logging With Timestamp
  ...  message=TC_SiSo_RU_ASIR_Block_One_pRRH_From_ASIRWebEM_Not_Impact_Call_On_Other_pRRH will be executed
  ...  style=ONGOING

    FOR  ${node}  IN  @{cfg['active_bts_list']}
    Step 1: Make Call On pRRH  alias=${node}
    Step 2: ASIR Block One pRRH From ASIRWebEM  alias=${node}
    Step 3: Make Call And Check States After Block One pRRH  alias=${node}
    Step 4: ASIR Unblock One pRRH From ASIRWebEM  alias=${node}
    Step 5: Check States After Unblock One pRRH  alias=${node}
    END
  [Teardown]    Common Test Teardown


Step 1: Make Call On pRRH
    [Arguments]  ${alias}=${cfg.primary_node_bts_id}
    Log  === Step 1: Make Call On pRRH ===  console=${TRUE}
    Preaparing Variables Before Test ASIR Block Unblock One pRRH  alias=${alias}
    Asir Check Active Alarms  ${alias}
    Perform L3 Call For All Cells  ${cfg['test_logs_path']}  ${alias}

Step 2: ASIR Block One pRRH From ASIRWebEM
    [Arguments]  ${alias}=${cfg.primary_node_bts_id}
    Log  === Step 2: ASIR Block One pRRH From ASIRWebEM  console=${TRUE}
    Asir Block Unit  ASI-1/${TESTED_ANTMOD}  alias=${alias}
    FOR  ${cell_cfg_dn}  IN  @{AFFECTED_CELLS_CFG_LIST}
        Append To List  ${GLO_ADMIN_ALLOWED_ALARMS}  faultId=4479, severity=Critical, configObjectName=regex".*${cell_cfg_dn}"
    END
    Sleep  10s

Step 3: Make Call And Check States After Block One pRRH
    [Arguments]  ${alias}=${cfg.primary_node_bts_id}
    Log  === Step 3: Make Call And Check States After Block One pRRH ===  console=${TRUE}
    Verify Alarms  ${alias}
    ${asir_alarms}  Asir Get Active Alarms  ${alias}
    FOR  ${alarm}  IN  @{asir_alarms}
        ${fault_id_status}  Set Variable If  "${alarm['fault_id']}"=="4348"  ${TRUE}  ${FALSE}
        ${fault_name_status}  Set Variable If  "${alarm['fault_name']}"=="Ant Blocked"  ${TRUE}  ${FALSE}
        ${severity_status}  Set Variable If  "${alarm['severity']}"=="major"  ${TRUE}  ${FALSE}
        ${source_uid_status}  Set Variable If  "${alarm['source_uid']}"=="${ALL_ANTMODS_DICT['${TESTED_ANTMOD}']['uid']}"  ${TRUE}  ${FALSE}
        ${final_status}  Evaluate  ${fault_id_status} and ${fault_name_status} and ${severity_status} and ${source_uid_status}
        Exit For Loop If  ${final_status}
    END
    Run Keyword If  ${final_status}  Log To Console  Expected fault 4349 visible for ${TESTED_ANTMOD} in WebASIR
    Run Keyword If  not ${final_status}  Run Keyword And Continue On Failure  Fail  Expected fault 4349 NOT visible for ${TESTED_ANTMOD} in WebASIR
    ASIR Check Expected States For Cells  ${AFFECTED_CELLS_DN_LIST}
    ...  operationalState=regex"(?i)Disabled", administrativeState=regex"(?i)Unlocked", availabilityStatus=regex"[Ff]ailed"  ${alias}
    ASIR Check Expected States For Cells  ${NOT_AFFECTED_CELLS_DN_LIST}
    ...  operationalState=regex"(?i)Enabled", blockingState=regex"(?i)Unblocked"  ${alias}
    Log To Console  \nL3 call started !!!  console=True
    ${l3call_status}  Run Keyword And Return Status  SiSo L3 Call  ${NOT_AFFECTED_ASIRMODS_CELLS_RUNTIME_LIST}
    Run Keyword If  ${l3call_status}  Log To Console  L3 Call finish with success
    Run Keyword If  not ${l3call_status}  Run Keyword And Continue On Failure  Fail  L3 Call finish with error !!!

Step 4: ASIR Unblock One pRRH From ASIRWebEM
    [Arguments]  ${alias}=${cfg.primary_node_bts_id}
    Log  === Step 4: ASIR Unblock One pRRH From ASIRWebEM ===  console=${TRUE}
    Asir Unblock Unit  ASI-1/${TESTED_ANTMOD}  alias=${alias}

Step 5: Check States After Unblock One pRRH
    [Arguments]  ${alias}=${cfg.primary_node_bts_id}
    Log  === Step 5: Check States After Unblock One pRRH ===  console=${TRUE}
    ${node}  Fetch from right  ${alias}  _
    Verify BTS State  ${node}
    Verify Alarms  ${alias}
    Asir Check Active Alarms  ${alias}

Preaparing Variables Before Test ASIR Block Unblock One pRRH
    [Arguments]  ${alias}=${cfg.primary_node_bts_id}
    ${all_antmods_dict}  Asir Get All Antmods Info  alias=${alias}
    Set Test Variable  ${ALL_ANTMODS_DICT}    ${all_antmods_dict}
    ${all_antmods_list}  Get Dictionary Keys  ${all_antmods_dict}
    ${provided_antmod_exist}   Run Keyword And Return Status  Variable Should Exist  ${cfg.pRRH}
    FOR  ${antmod}  IN  @{all_antmods_list}
        Exit For Loop If   not ${provided_antmod_exist}
        ${provided_antmod}  Run Keyword If  "${all_antmods_dict['${antmod}']['serial_number_pRRH']}"=="${cfg.pRRH}"  Set Variable  ${antmod}
        Exit For Loop If  "${all_antmods_dict['${antmod}']['serial_number_pRRH']}"=="${cfg.pRRH}"
    END
    ${empty_status}  Run Keyword If  ${provided_antmod_exist}  Run Keyword And Return Status  Should Not Be Empty  ${provided_antmod}
    Run Keyword If  ${provided_antmod_exist}  Run Keyword If  not ${empty_status}  Fail  Not correct S\N of pRRH -> ${cfg.pRRH}
    ${random_antmod_list_index}  Evaluate  random.randint(0,len(${all_antmods_list})-1)  random
    ${random_antmod}  Get From List  ${all_antmods_list}  ${random_antmod_list_index}
    ${tested_antmod}  Set Variable If  ${provided_antmod_exist}  ${provided_antmod}  ${random_antmod}
    Set Test Variable  ${TESTED_ANTMOD}  ${tested_antmod}
    ${affected_cells_cfg_list}  Get From Dictionary  ${all_antmods_dict['${tested_antmod}']}    cells_list_cfg
    Set Test Variable  ${AFFECTED_CELLS_CFG_LIST}  ${affected_cells_cfg_list}
    ${nrcels}  admin.Get ids for all  NRCEL  connection=${alias}
    ${lncels}  admin.Get ids for all  LNCEL  search_for_iot_cells=${True}  connection=${alias}
    ${wncels}  admin.Get ids for all  WNCEL  connection=${alias}
    ${gncels}  admin.Get ids for all  GNCEL  connection=${alias}
    ${all_cells_dn_list}  Combine Lists  ${nrcels}  ${lncels}  ${wncels}  ${gncels}
    ${affected_cells_runtime_list}  Create List
    FOR  ${cell_id}   IN  @{AFFECTED_CELLS_CFG_LIST}
        ${id}  Fetch From Right  ${cell_id}  L-
        ${nr_status}  Run Keyword And Return Status  Should Match Regexp  ${cell_id}  NRCELL
        ${lte_status}  Run Keyword And Return Status  Should Match Regexp  ${cell_id}  LNCEL
        ${wcdma_status}  Run Keyword And Return Status  Should Match Regexp  ${cell_id}  LNCEL
        ${gsm_status}  Run Keyword And Return Status  Should Match Regexp  ${cell_id}  LNCEL
        ${rat_type}=   Set Variable If   '${lte_status}' == 'True'  LTE
        ...                              '${gsm_status}' == 'True'  GSM
        ...                              '${wcdma_status}' == 'True'  WCDMA
        ...                               '${nr_status}' == 'True'  NR
        ${cell_id_runtime}  Get Cell Id By Configuration Id  ${rat_type}  ${id}  connection=${alias}
        Append To List  ${affected_cells_runtime_list}  ${cell_id_runtime}
    END
    ${all_artmods_cells_cfg}  Create List
    FOR  ${antmod}  IN  @{all_antmods_list}
        ${cells_cfg_list}  Get From Dictionary  ${all_antmods_dict['${antmod}']}    cells_list_cfg
        Append To List  ${all_artmods_cells_cfg}  @{cells_cfg_list}
    END
    ${all_asirmods_cells_runtime_list}  Create List
    FOR  ${cell_id}   IN  @{all_artmods_cells_cfg}
        ${id}  Fetch From Right  ${cell_id}  L-
        ${nr_status}  Run Keyword And Return Status  Should Match Regexp  ${cell_id}  NRCELL
        ${lte_status}  Run Keyword And Return Status  Should Match Regexp  ${cell_id}  LNCEL
        ${wcdma_status}  Run Keyword And Return Status  Should Match Regexp  ${cell_id}  LNCEL
        ${gsm_status}  Run Keyword And Return Status  Should Match Regexp  ${cell_id}  LNCEL
        ${rat_type}=   Set Variable If   '${lte_status}' == 'True'  LTE
        ...                              '${gsm_status}' == 'True'  GSM
        ...                              '${wcdma_status}' == 'True'  WCDMA
        ...                               '${nr_status}' == 'True'  NR
        ${cell_id_runtime}  Get Cell Id By Configuration Id  ${rat_type}  ${id}  connection=${alias}
        Append To List  ${all_asirmods_cells_runtime_list}  ${cell_id_runtime}
    END

    Set Test Variable  ${AFFECTED_CELLS_DN_LIST}  ${affected_cells_runtime_list}
    Set Test Variable  ${ALL_ASIRMODS_CELLS_RUNTIME_LIST}  ${all_asirmods_cells_runtime_list}
    Set Test Variable  ${NOT_AFFECTED_ASIRMODS_CELLS_RUNTIME_LIST}  ${all_asirmods_cells_runtime_list}
    Remove Values From List  ${NOT_AFFECTED_ASIRMODS_CELLS_RUNTIME_LIST}  ${AFFECTED_CELLS_DN_LIST}
    Set Test Variable  ${NOT_AFFECTED_CELLS_DN_LIST}  ${all_cells_dn_list}
    Remove Values From List  ${NOT_AFFECTED_CELLS_DN_LIST}  @{AFFECTED_CELLS_DN_LIST}
