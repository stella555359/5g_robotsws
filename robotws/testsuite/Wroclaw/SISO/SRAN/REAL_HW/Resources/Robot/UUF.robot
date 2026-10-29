*** Settings ***
Documentation  Maintainers: @I_SRAN_PROD_SISO_WRO_CRTDEV_GMS
...  Resource with common KW for UUF testcases

Library  taf.sbts.oam.coam.admin  WITH NAME  admin
Library  taf/rfrl/csv4all/CSV4AllTestCases.py
Library  XML  use_lxml=true
Library  OperatingSystem
Library  String
Library  Collections

#Resource  taf/rfrl/uuf4all/uuf4all_keywords.robot
Library  taf/rfrl/csv4all/resources/utilities/utilities.py

*** Variables ***
${CUSTOM_EXECUTE_UUF_UPGRADE_PROCEDURE}=   ${FALSE}
${SEND_REPETITION_REPORT}=   ${FALSE}
${CUSTOMERS}=  Generic

*** Keywords ***
UUF Create Dictionary Description For UUF Type Regular Testcases
  [Documentation]  Keyword prepare dictionary description use by E2E testcases from UUF team, this KW is use for every UUF team testcase
  ...   excluding UUF type testcase - upgrade, update ,fallback which include downgrade
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument                      | Man. | Description                                                         |
  ...  +========================+======+============================================================================+
  ...  | nodes_list                    | Yes  | BTS ID active list                                                  |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com
  [Arguments]    ${nodes_list}
  ${common_fault_ids}=   UUF Extract Fault Ids    ${GLOBAL_ALLOWED_FAULTS['common']}
  ${custom_common_fault_ids}=   UUF Extract Fault Ids    ${CUSTOM_ADDITIONAL_ALLOWED_FAULTS['common']}
  ${uuf_nodes}    Create List    @{EMPTY}
  FOR  ${node}  IN  @{nodes_list}
    ${all_fault_ids_list}=  UUF Prepare Common Combined Faults List For Each BTS    ${common_fault_ids}  ${custom_common_fault_ids}
    ${active_branch}=  Get From Dictionary  ${cfg.NODES['${node}']}  active_release
    ${active_software}=  Get From Dictionary  ${cfg.NODES['${node}']}  software_active
    ${tested_node_previous_branch}=    Get From Dictionary    ${BRANCH_UPGRADE_BUILD}    ${active_branch}
    ${trunk_status}    Run Keyword And Return Status    Should Match Regexp    ${active_software}    .*_999[0-9].*
    ${candidate_sw}=    Run Keyword If    ${trunk_status}
    ...   Replace String Using Regexp     ${active_software}    ^([A-Z]+)\\d+[A-Z]\\d?     SBTS00
    ...  ELSE  Set Variable    ${active_software}
    ${tmp_dict}=  Create Dictionary    &{EMPTY}
    ${master_sm}=  Get From Dictionary    ${CFG['NODES']['${node}']}   primary_sm
    ${slave_sm}=  Get From Dictionary    ${CFG['NODES']['${node}']}   secondary_sm
    ${master_host_ip}=  Get From Dictionary    ${CFG['NODES']['${node}']}   vm_ip_LMP_address
    ${slave_host_ip}=  Run Keyword If  '${slave_sm}'!='None'
    ...  Get From Dictionary  ${CFG['NODES']['${node}']}  secondary_sm_vm_ip_LMP_address
    ${slave_host_ip}=  Set Variable If  '${slave_sm}'!='None'  ${slave_host_ip}  ${NONE}
    Set To Dictionary   ${tmp_dict}
    ...  node_vm=${master_host_ip}
    ...  secondary_vm=${slave_host_ip}
    ...  source_sw=${tested_node_previous_branch}
    ...  target_sw=${candidate_sw}
    ...  custom_allowed_alarms=${all_fault_ids_list}
    ...  node_alias=${node}
    Append To List    ${uuf_nodes}  ${tmp_dict}
    Set Suite Variable    ${UUF_NODES}
  END
  ${UUF_ITERATIONS}=  Get Length  ${REPETITION_LIST}
  ${UUF_TESTLINE_NAME}=  Set Variable   ${TESTLINE}
  [Return]    ${UUF_NODES}  ${UUF_ITERATIONS}

UUF Create Dictionary Description For UUF Type Testcases
  [Documentation]  Keyword prepare dictionary description use by E2E testcases from UUF team including cloud execution
  ...    information, like previous software.
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument                      | Man. | Description                                                         |
  ...  +========================+======+============================================================================+
  ...  | nodes_list                    | Yes  | BTS ID active list                                                  |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com
  [Arguments]    ${nodes_list}
  ${common_fault_ids}=   UUFExtract Fault Ids    ${GLOBAL_ALLOWED_FAULTS['common']}
  ${custom_common_fault_ids}=   UUF Extract Fault Ids    ${CUSTOM_ADDITIONAL_ALLOWED_FAULTS['common']}
  ${uuf_nodes}    Create List    @{EMPTY}
  FOR  ${node}  IN  @{nodes_list}
    ${all_fault_ids_list}=  UUF Prepare Common Combined Faults List For Each BTS  ${common_fault_ids}  ${custom_common_fault_ids}
    ${active_branch}=  Get From Dictionary  ${cfg.NODES['${node}']}  active_release
    ${active_software}=  Get From Dictionary  ${cfg.NODES['${node}']}  software_active
    ${tested_node_previous_branch}=  Get From Dictionary  ${BRANCH_UPGRADE_BUILD}  ${active_branch}
    ${initial_sw}=  Run Keyword And Ignore Error  Get Source SW
    ${uuf_cloud_execution}=  Set Variable If   '${initial_sw}[0]'!='FAIL'  ${True}  ${False}
    ${initial_sw}=  Set Variable If  '${initial_sw}[0]'!='FAIL'  ${initial_sw}[1]  ${tested_node_previous_branch}
    Set Suite Variable    ${UUF_CLOUD_EXECUTION}  ${uuf_cloud_execution}
    ${candidate_sw}  Run Keyword And Ignore Error  Get Target SW
    ${candidate_sw}=   Set Variable If   '${candidate_sw}[0]'!='FAIL'  ${candidate_sw}[1]  ${active_software}
    ${trunk_status}  Run Keyword And Return Status  Should Match Regexp  ${candidate_sw}  .*_999[0-9].*
    ${candidate_sw}=  Run Keyword If  ${trunk_status}
    ...  Replace String Using Regexp  ${candidate_sw}  ^([A-Z]+)\\d+[A-Z]\\d?  SBTS00
    ...  ELSE  Set Variable    ${candidate_sw}
    ${tmp_dict}=  Create Dictionary    &{EMPTY}
    ${master_sm}=  Get From Dictionary    ${CFG['NODES']['${node}']}   primary_sm
    ${slave_sm}=  Get From Dictionary    ${CFG['NODES']['${node}']}   secondary_sm
    ${master_host_ip}=  Get From Dictionary    ${CFG['NODES']['${node}']}   vm_ip_LMP_address
    ${slave_host_ip}=  Run Keyword If  '${slave_sm}'!='None'
    ...  Get From Dictionary  ${CFG['NODES']['${node}']}  secondary_sm_vm_ip_LMP_address
    ${slave_host_ip}=  Set Variable If  '${slave_sm}'!='None'  ${slave_host_ip}  ${NONE}
    Set To Dictionary   ${tmp_dict}
    ...  node_vm=${master_host_ip}
    ...  secondary_vm=${slave_host_ip}
    ...  source_sw=${initial_sw}
    ...  target_sw=${candidate_sw}
    ...  custom_allowed_alarms=${all_fault_ids_list}
    ...  node_alias=${node}
    Append To List    ${uuf_nodes}  ${tmp_dict}
    Set Suite Variable    ${UUF_NODES}
  END
  ${UUF_ITERATIONS}=  Get Length  ${REPETITION_LIST}
  ${UUF_TESTLINE_NAME}=  Set Variable   ${TESTLINE}
  [Return]    ${UUF_NODES}  ${UUF_CLOUD_EXECUTION}  ${UUF_ITERATIONS}

UUF Prepare Common Combined Faults List For Each BTS
  [Documentation]  Procedure to prepare fault ids list combined for each BTS and common faults
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument                      | Man. | Description                                                         |
  ...  +========================+======+============================================================================+
  ...  | common_fault_ids              | Yes  | list of extracted common fault ids                                  |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | custom_common_fault_ids       | Yes  | list of extracted custom fault ids                                  |
  ...  +------------------------+------+----------------------------------------------------------------------------+

  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com
  [Arguments]  ${common_fault_ids}  ${custom_common_fault_ids}
  ${node_fault_ids_status}=  Run Keyword And Ignore Error
  ...  Get From Dictionary  ${GLOBAL_ALLOWED_FAULTS}  ${node}
  ${custom_node_fault_ids_status}=  Run Keyword And Ignore Error
  ...  Get From Dictionary  ${CUSTOM_ADDITIONAL_ALLOWED_FAULTS}  ${node}
  ${node_fault_ids}=  Run Keyword If    '${node_fault_ids_status}[0]'=='PASS'
  ...  UUF Extract Fault Ids    ${node_fault_ids_status}[1]
  ${custom_node_fault_ids}=  Run Keyword If    '${custom_node_fault_ids_status}[0]'=='PASS'
  ...  UUF Extract Fault Ids    ${custom_node_fault_ids_status}[1]
  ${combined_fault_ids_list}=  Run Keyword If    '${node_fault_ids_status}[0]'=='PASS'
  ...   Collections.Combine Lists  ${node_fault_ids_status}[1]  ${common_fault_ids}
  ${combined_custom_fault_ids_list}=  Run Keyword If    '${node_fault_ids_status}[0]'=='PASS'
  ...   Collections.Combine Lists  ${custom_node_fault_ids_status}[1]  ${custom_common_fault_ids}
  ${combined_fault_ids_list}=  Set Variable If    ${combined_fault_ids_list}
  ...  ${combined_fault_ids_list}
  ...  ${common_fault_ids}
  ${combined_custom_fault_ids_list}=  Set Variable If    ${combined_custom_fault_ids_list}
  ...  ${combined_custom_fault_ids_list}
  ...  ${custom_common_fault_ids}
  ${all_fault_ids_list}=  Collections.Combine Lists  ${combined_fault_ids_list}  ${combined_custom_fault_ids_list}
  [Return]  ${all_fault_ids_list}

UUF Extract Fault Ids
  [Documentation]  Keyword run E2E upgrade testcase prepared by UUF team to utilize 4.7 stream improvemnt action
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument                      | Man. | Description                                                         |
  ...  +========================+======+============================================================================+
  ...  | fault_list                    | Yes  | list of fault ids                                                   |
  ...  +------------------------+------+----------------------------------------------------------------------------+

  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com
  [Arguments]    ${fault_list}
  @{fault_ids}=    Create List
  FOR    ${alarm}    IN    @{fault_list}
    ${alarm_parts}=    Split String    ${alarm}    ,
    ${fault_id_part}=    Set Variable    ${alarm_parts}[0]
    @{id_pair}=    Split String    ${fault_id_part}    =
    ${id}=    Set Variable    ${id_pair}[1]
    Append To List    ${fault_ids}    ${id}
  END
  [Return]    ${fault_ids}

UUF Prepare Rmod Under Test Dictionary Description
  [Documentation]  Keyword prepares RU description for UUF testcases - under development
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument                      | Man. | Description                                                         |
  ...  +========================+======+============================================================================+
  ...  | serial_number_list            | Yes  | list of rmod under test                                             |
  ...  +------------------------+------+----------------------------------------------------------------------------+

  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com
  [Arguments]    ${serial_number_list}
  @{rmod_list_under_test}=  Create List    @{EMPTY}
  FOR  ${serial_number}  IN  @{serial_number_list}
    ${tl_status}=  Run Keyword And Return Status    Variable Should Exist    ${TL}
    ${object}=  Run Keyword If    ${tl_status}  Find Init Object Using Attribute Value  ${TL}  ${serial_number}
    ${object_status}=  Run Keyword And Return Status    Should Be True    ${object}
    ${model}  ${version}  ${addr}  ${port}=  Run Keyword If  not ${object_status}  Create PDU Description  ${serial_number}
    &{tmp_ru_dict}=  Create Dictionary   ${serial_number}=&{EMPTY}
    Run Keyword If  not ${object_status}  Set To Dictionary  ${tmp_ru_dict.${serial_number}}
    ...  host=${addr}
    ...  model=${model}
    ...  version=${version}
    ...  port=${port}
    ...  ELSE
    ...  Set To Dictionary  ${tmp_ru_dict}  ${serial_number}=${object.pdu_port}
    Append To List    ${rmod_list_under_test}  ${tmp_ru_dict}
  END
  [Return]  ${rmod_list_under_test}


#UUF Prepare Siso Configuration For UUF Testcase
#    ${UUF_NODES}  ${UUF_CLOUD_EXECUTION}=  Create Dictionary Description For UUF Type Testcases  ${cfg.active_bts_list}
#    Run Keyword If   not ${UUF_CLOUD_EXECUTION}  Branch Update Setup
#    FOR  ${node}  IN  @{cfg.active_bts_list}
#
#    Run Keyword And Continue On Failure    STATE Verify BTS states
#  ...  node_id=${bts}
#  ...  expected_BTS_status=OnAir
#  ...  HW_check=${TRUE}
#  ...  cells_check=${TRUE}
#  ...  scf_check=${FALSE}
#  ...  timeout=${CONFIGURATION_STARTUP_TIMEOUT}
#    END
#    [Return]    ${UUF_NODES}  ${UUF_CLOUD_EXECUTION}


UUF Upgrade In Case Of Upgrade Path Type Execution
  [Documentation]  Keyword prepares description for upgrade test used in 4.7 stream, used in configuration setup teardown only.

  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com
  Return From Keyword If  not ${CUSTOM_SWITCH_PERFORM_HW_SETUP}
  Return From Keyword If  not ${CUSTOM_EXECUTE_UUF_UPGRADE_PROCEDURE}
  ${UUF_NODES}  ${UUF_CLOUD_EXECUTION}  ${UUF_ITERATIONS}=  UUF Create Dictionary Description For UUF Type Testcases  ${CFG.active_bts_list}
  Return From Keyword If  not ${UUF_CLOUD_EXECUTION}
  ${uuf_update_status}=  Run Keyword And Continue On Failure  e2e_tl_upgrade_test
  ...  nodes_details=${UUF_NODES}
  ...  test_nodes_details=${UUF_NODES}
  ...  iterations_per_node=1
  ...  customers_list=${CUSTOMERS}
  ...  report=${False}
  Set Suite Variable    ${CUSTOM_EXECUTE_UUF_UPGRADE_PROCEDURE}   ${False}

#UUF Verify SW Version between BTS And CM Execution
#  ${siso_initial_build}=  Set Variable If    not ${UUF_CLOUD_EXECUTION}
#
#  ${extended_reservation_file}=  Run Keyword And Return Status
#  ...  operatingsystem.file should exist  path=/opt/ute/reservation.context.json
#  ${extended_reservation_dict}=  Run Keyword If  ${extended_reservation_file}
#  ...  Run Keyword And Continue On Failure  Load Json File As Dictionary  /opt/ute/reservation.context.json
#  ...  ELSE  Set Variable  &{EMPTY}
#  ${uuf_manual_initial_sw}=   Run Keyword If  ${extended_reservation_file}   Get Variable Value    ${uuf_manual_initial_sw}  default=${EMPTY}
#  ${uuf_manual_candidate_sw}=   Run Keyword If  ${extended_reservation_file}   Get Variable Value    ${uuf_manual_candidate_sw}  default=${EMPTY}
#
#  Set Suite Variable  ${EXTENDED_RESERVATION_DICT}  ${extended_reservation_dict}
#
#  ${CM_VARIANT}=  Get Variable Value  ${EXTENDED_RESERVATION_DICT['CM_ARTIFACTS']}   default=${CM_TOPOLOGY}

