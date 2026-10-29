*** Settings ***
Documentation
...    Author:        przemyslaw.kempa@nokia.com
...    Maintainer:    Przemysław Kempa

Resource    ../tc_scenarios.robot
Resource    resources/ca_Recovery_link_break.robot
#Resource    ../SiSo_L3_Call.robot
Library     taf.sbts.oam.sc.rest   WITH NAME  rest


*** Variables ***
${SISO_L3_CALL}          False

*** Keywords ***
TC_SiSo_RU_Lock_Unlock_ASIR_HUB_From_WebEM
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-28933
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The purpose of this scenario is to validate lock and unlock ASiR-HUB by WebEM.
    ...  We can provide S/N of tested ASIRMOD or test all of them as default
    ...  Optional variable in cfg to perform test
    ...  e.g.
    ...  ASIRMOD=NH225300251
    ...
    ...  *** Test Variable For L3 Call ***
    ...  ${SISO_L3_CALL}             False  #default value for L3 call is False, set test variable as True to perform test with L3 call
    ...  ${CELLS_YAML_PATH}                 #mandatory path for ue_config.yaml if ${SISO_L3_CALL} is True
    ...
    ...  *****************
    ...  History of change
    ...  *****************
    ...

    Set Tags	CA-CM    AUTHOR-przemyslaw.kempa@nokia.com    MAINTAINER-przemyslaw.kempa@nokia.com
    ...		    GROUP_IN_CHARGE- MN RAN Pz 4 WRO 8     PHASE-CRT  FEATURE-CB00

  Common Test Setup
  Logging With Timestamp
  ...  message=TC_SiSo_RU_Lock_Unlock_ASIR_HUB_From_WebEM will be executed
  ...  style=ONGOING
    FOR  ${node}  IN  @{cfg['active_bts_list']}
    Step 1: Lock ASIR_HUB From WebEM  alias=${node}
    Step 2: Check States After Lock ASIR_HUB  alias=${node}
    Step 3: Unlock ASIR_HUB From WebEM  alias=${node}
    Step 4: Check States After Unlock ASIR_HUB  alias=${node}
    END
  [Teardown]    Common Test Teardown


Step 1: Lock ASIR_HUB From WebEM
    [Arguments]  ${alias}=${cfg.primary_node_bts_id}
    Log  === Step 1: Lock ASIR_HUB From WebEM ===  console=${TRUE}
    Preaparing Variables Before Test Lock Unlock ASIRHUB  alias=${alias}
    Asir Check Active Alarms  ${alias}
    FOR  ${asirmod}  IN  @{TESTED_ASIRMOD_DN_LIST}
        Log To Console  ${asirmod} Lock started !!!
        ${lock_status}  Run Keyword And Return Status  Lock  ${asirmod}  timeout=120  connection=${alias}
        ${asirmod_status}  Run Keyword And Return Status  Get Cell Mapping By Module Id  ${asirmod}  connection=${alias}
        Run Keyword If  ${lock_status}  Log To Console  ${asirmod} Lock finish successfully !!!
        Run Keyword If  not ${lock_status}  Run Keyword And Continue On Failure  Fail  ${asirmod} Lock finish with error !!!
    END
    Sleep  30s

Step 2: Check States After Lock ASIR_HUB
    [Arguments]  ${alias}=${cfg.primary_node_bts_id}
    Log  === Step 2: Check States After Lock ASIR_HUB ===  console=${TRUE}
    Verify Alarms  ${alias}
    Verify Alarms In ASIR After Lock ASIR_HUB
    ASIR Check Expected States For Cells  ${AFFECTED_CELLS_DN_LIST}
    ...  operationalState=regex"(?i)Disabled", administrativeState=regex"(?i)Unlocked", availabilityStatus=regex"(?i)Dependency"  ${alias}
    ASIR Check Expected States For Cells  ${NOT_AFFECTED_CELLS_DN_LIST}
    ...  operationalState=regex"(?i)Enabled", blockingState=regex"(?i)Unblocked"  ${alias}
    Check Expected States For ASIR_HUB After Lock ASIR_HUB  ${TESTED_ASIRMOD_DN_LIST}
    ...  operationalState=regex"(?i)Enabled", administrativeState=regex"(?i)Locked", usageState=regex"(?i)Idle"  ${alias}
    Check Expected States For ASIR_HUB After Lock ASIR_HUB  ${NOT_TESTED_ASIRMOD_DN_LIST}
    ...  operationalState=regex"(?i)Enabled", administrativeState=regex"(?i)Unlocked", usageState=regex"(?i)Active"  ${alias}
    Run Keyword And Continue On Failure  Assert Every  RMOD  operationalState=regex"(?i)Enabled"  connection=${alias}
    Run Keyword And Continue On Failure  Assert Every  SMOD  operationalState=regex"(?i)Enabled"  connection=${alias}

Step 3: Unlock ASIR_HUB From WebEM
    [Arguments]  ${alias}=${cfg.primary_node_bts_id}
    Log  === Step 3: Unlock ASIR_HUB From WebEM ===  console=${TRUE}
    FOR  ${asirmod}  IN  @{TESTED_ASIRMOD_DN_LIST}
        Log To Console  ${asirmod} Unlock started !!!
        ${lock_status}  Run Keyword And Return Status  Unlock  ${asirmod}  timeout=120  connection=${alias}
        Run Keyword If  ${lock_status}  Log To Console  ${asirmod} Unlock finish successfully !!!
        Run Keyword If  not ${lock_status}  Run Keyword And Continue On Failure  Fail  ${asirmod} Unlock finish with error !!!
    END

Step 4: Check States After Unlock ASIR_HUB
    [Arguments]  ${alias}=${cfg.primary_node_bts_id}
    Log  === Step 4: Check States After Unlock ASIR_HUB ===  console=${TRUE}
    ${node}  Fetch from right  ${alias}  _
    Verify BTS State  ${node}
    Verify Alarms  ${alias}
    Asir Check Active Alarms  ${alias}
    Run Keyword If  ${SISO_L3_CALL}  Perform L3 Call For All Cells  ${cfg['test_logs_path']}  ${alias}
    ...    ELSE  Log To Console  L3 Call skipped  console=True

Preaparing Variables Before Test Lock Unlock ASIRHUB
    [Arguments]  ${alias}=${cfg.primary_node_bts_id}
    ${nrcels}  admin.Get ids for all  NRCEL  connection=${alias}
    ${lncels}  admin.Get ids for all  LNCEL  search_for_iot_cells=${True}  connection=${alias}
    ${wncels}  admin.Get ids for all  WNCEL  connection=${alias}
    ${gncels}  admin.Get ids for all  GNCEL  connection=${alias}
    ${all_cells_dn_list}  Combine Lists  ${nrcels}  ${lncels}  ${wncels}  ${gncels}
    Set Test Variable  ${ALL_CELLS_DN_LIST}  ${all_cells_dn_list}
    ${all_asirmod_dn_list}  Get Ids For All  ASIRMOD  connection=${alias}
    ${asirmod_status}  Run Keyword And Return Status  Variable Should Exist  ${cfg.ASIRMOD}
    ${provided_asirmod}  Run Keyword If  ${asirmod_status}  Changing Provided Serial Number To ASIRMOD Distname  alias=${alias}
    ${tested_asirmod_dn_list}  Set Variable If  ${asirmod_status}  ${provided_asirmod}  ${all_asirmod_dn_list}
    Set Test Variable  ${TESTED_ASIRMOD_DN_LIST}  ${tested_asirmod_dn_list}
    ${not_tested_asirmod_dn_list}  Create List  @{all_asirmod_dn_list}
    Set Test Variable  ${NOT_TESTED_ASIRMOD_DN_LIST}  ${not_tested_asirmod_dn_list}
    Remove Values From List  ${NOT_TESTED_ASIRMOD_DN_LIST}   @{TESTED_ASIRMOD_DN_LIST}
    ${affected_cells_dn_list}  Create List
    FOR  ${asirmod}  IN  @{TESTED_ASIRMOD_DN_LIST}
        ${cells}  Get Cell Mapping By Module Id  ${asirmod}  connection=${alias}
        Append To List  ${affected_cells_dn_list}  @{cells}
    END
    Set Test Variable  ${AFFECTED_CELLS_DN_LIST}  ${affected_cells_dn_list}
    ${not_affected_cells_dn_list}  Create List  @{ALL_CELLS_DN_LIST}
    Remove Values From List  ${not_affected_cells_dn_list}  @{AFFECTED_CELLS_DN_LIST}
    Set Test Variable  ${NOT_AFFECTED_CELLS_DN_LIST}  ${not_affected_cells_dn_list}

Changing Provided Serial Number To ASIRMOD Distname
    [Arguments]  ${alias}=${cfg.primary_node_bts_id}
    ${provided_asirmod}  Create List
    ${all_asir_parameters}  Get Parameters For All  ASIRMOD  connection=${alias}
    FOR  ${asirmod}  IN  @{all_asir_parameters}
        Run Keyword If  "${asirmod['serialNumber']}"=="${cfg.ASIRMOD}"  Append To List  ${provided_asirmod}  ${asirmod['id']}
        Exit For Loop If  "${asirmod['serialNumber']}"=="${cfg.ASIRMOD}"
    END
    ${empty_status}  Run Keyword And Return Status  Should Not Be Empty  ${provided_asirmod}
    Run Keyword If  not ${empty_status}  Fail  Not correct S\N of ASIRMOD -> ${cfg.ASIRMOD}
    [Return]  ${provided_asirmod}

Verify Alarms In ASIR After Lock ASIR_HUB
    ${hubmod_status}  Run Keyword And Return Status  Variable Should Exist  ${cfg.ASIRMOD}
    ${hubmod_alarms}  Asir Get Active Alarms  ${alias}
    ${all_hubmods_info}  Asir Get All Hubmod Info
    ${hubmod_list}  Get Dictionary Keys   ${all_hubmods_info}
    ${all_hubmods_uid_list}  Create List
    ${provided_hubmod_uid_list}  Create List
    FOR  ${hubmod}  IN  @{hubmod_list}
        ${uid_value}  Get From Dictionary  ${all_hubmods_info['${hubmod}']}  uid
        Append To List  ${all_hubmods_uid_list}  ${uid_value}
        Run Keyword If  ${hubmod_status}  Run Keyword If  "${all_hubmods_info['${hubmod}']['serial_number']}"=="${cfg.ASIRMOD}"
        ...  Append To List  ${provided_hubmod_uid_list}  ${uid_value}
    END
    ${tested_hubmod_uid_list}  Set Variable If  ${hubmod_status}  ${provided_hubmod_uid_list}  ${all_hubmods_uid_list}
    FOR  ${hubmod_uid}  IN  @{tested_hubmod_uid_list}
        _Check ASIR Alarm After Lock Hubmod  ${hubmod_uid}  ${hubmod_alarms}
    END

_Check ASIR Alarm After Lock Hubmod
    [Arguments]  ${hubmod_uid}  ${hubmod_alarms}
    FOR  ${alarm}  IN  @{hubmod_alarms}
        ${fault_id_status}  Set Variable If  "${alarm['fault_id']}"=="1931"  ${TRUE}  ${FALSE}
        ${fault_name_status}  Set Variable If  "${alarm['fault_name']}"=="RF Module blocked"  ${TRUE}  ${FALSE}
        ${severity_status}  Set Variable If  "${alarm['severity']}"=="major"  ${TRUE}  ${FALSE}
        ${source_uid_status}  Set Variable If  "${alarm['source_uid']}"=="${hubmod_uid}"  ${TRUE}  ${FALSE}
        ${hubmod_dn}  Get From Dictionary  ${alarm}  source_object
        ${final_status}  Evaluate  ${fault_id_status} and ${fault_name_status} and ${severity_status} and ${source_uid_status}
        Exit For Loop If  ${final_status}
    END
    Run Keyword If  ${final_status}  Log To Console  Expected fault 1931 visible for ${hubmod_dn} in WebASIR
    Run Keyword If  not ${final_status}  Run Keyword And Continue On Failure  Fail  Expected fault 1931 NOT visible for ${hubmod_dn} in WebASIR

Check Expected States For ASIR_HUB After Lock ASIR_HUB
    [Arguments]  ${asir_dn_list}  ${expected_states}  ${alias}=${cfg.primary_node_bts_id}
    FOR  ${asir}  IN  @{asir_dn_list}
      ${expexted_st}=  Run Keyword And Return Status  admin.Assert  ASIRMOD  ${asir}  ${expected_states}  connection=${alias}
      Run Keyword If  not ${expexted_st}  Run Keyword And Continue On Failure  Fail  ${asir} is NOT in expected states !!!
    END
