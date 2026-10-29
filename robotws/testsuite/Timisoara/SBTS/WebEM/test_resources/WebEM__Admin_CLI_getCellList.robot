*** Settings ***
Documentation
    ...  This test case gets cell list via ADMIN CLI.
    ...  actCli parameter is changed to be true.
    ...  Check getCellList command via ADMIN CLI to be send with error code 0.
    ...  Check cells configuration id from WebEM to be the same as in CLI response.
    ...  actCli parameter is changed to be false.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Keywords ***
TC__WebEM__Admin_CLI_getCellList
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26243
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 25.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26243 - Initial TAT creation
    ...  - 01.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26373 - Fix returned list

    Set Tags  CA-WebEM  OWNER-mihnea.spineanu@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS24  FEATURE-CB010545

    Step1: Sending GetCellList Command Via ADMIN CLI
    Step2: Check Output From GetCellList Command


Step1: Sending GetCellList Command Via ADMIN CLI
    Log  \nStep1: Sending getCellList command via ADMIN CLI  console=true
    Setup Admin CLI  ${ACTIVE_SW_VERSION}  ${MPLANE_IP}
    Log  \nSending command via Admin CLI for getCellList...  console=true
    ${request_status}  ${error_code}  ${request_message}  Admin CLI Send Request  {"requestId":1,"parameters":{"name":"getCellList"}}
    Run Keyword If  '${request_status}' == 'completed' and ${error_code} == 0
    ...  Log  Command sent with status: ${request_status} and error code: ${error_code}![OK]  console=true
    ...  ELSE
    ...  Fail  Command sent with status: ${request_status} and error code: ${error_code}![NOK]
    ${cells_info_dict_cli}  Get From Dictionary  ${request_message}  cells
    ${cells_info_cli}  Convert To String  ${cells_info_dict_cli}
    ${bts_id_cli}  Get From Dictionary  ${request_message}  btsId
    Log  BTS id from cli response is ${bts_id_cli}!  console=true
    ${bts_name_cli}  Get From Dictionary  ${request_message}  btsName
    Log  BTS name from cli response is ${bts_name_cli}!  console=true
    Set Test Variable  ${BTS_ID_CLI}
    Set Test Variable  ${BTS_NAME_CLI}
    Set Test Variable  ${CELLS_INFO_CLI}


Step2: Check Output From GetCellList Command
    Log  \nStep2: Check output from getCellList command  console=true
    ${bts_name}  Get Bts Name
    ${cells_configuration_id_list}  Get Cells Id Configuration List
    Run Keyword If  '${BTS_ID}' == '${BTS_ID_CLI}' and '${bts_name}' == '${BTS_NAME_CLI}'
    ...  Log  BTS id and name from WebEM are the same as in cli response![OK]  console=true
    ...  ELSE
    ...  Fail  BTS id and name from WebEM are not the same as in cli response![NOK]
    FOR  ${cell}  IN  @{cells_configuration_id_list}
        Should Contain  ${CELLS_INFO_CLI}  ${cell}  Cell configuration id from cli response is not the same as in WebEM![NOK]
    END
    Log  Cells configuration id from cli response are the same as in WebEM![OK]  console=true


Get Cells Id Configuration List
    ${all_cells}  Create List
    ${configuration_ids}  Create List
    ${all_cells}  Run Keyword If  ${SCF_COUNT_GSM}
    ...  Get Cells List From Specific Tehnology  ${all_cells}  gsm
    ${all_cells}  Run Keyword If  ${SCF_COUNT_WCDMA}
    ...  Get Cells List From Specific Tehnology  ${all_cells}  wcdma
    ${all_cells}  Run Keyword If  ${SCF_COUNT_LTE}
    ...  Get Cells List From Specific Tehnology  ${all_cells}  lte
    ${all_cells}  Run Keyword If  ${SCF_COUNT_NR}
    ...  Get Cells List From Specific Tehnology  ${all_cells}  nr
    FOR  ${cell}  IN  @{all_cells}
        Append To List  ${configuration_ids}  ${cell}[id][configuration]
    END

    [Return]  ${configuration_ids}


Get Cells List From Specific Tehnology
    [Arguments]  ${all_cells}  ${tehnology}

    ${cells}  Get Cells Info  ${tehnology}
    ${cells_list}  Run Keyword If  ${all_cells} != ${None}
    ...  Combine Lists  ${all_cells}  ${cells}
    ...  ELSE
    ...  Return From Keyword  @{cells}
    Return From Keyword  @{cells_list}


TC Setup
    Common Test Setup
    Change ActCli Parameter  true


TC Teardown
    Change ActCli Parameter  false
    Common Test Teardown
