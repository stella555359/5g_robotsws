*** Settings ***
Documentation
    ...  This TC send different CLI commands with troubleshooting script for many cases.
    ...  Changing actCli parameter to be true.
    ...  Perform setup Admin CLI and open Diagnostic tab with Troubleshooting Script menu.
    ...  "getAllTroubleshootingScripts" command is verified. Compare script name, owner, description and
    ...  free text parameter from WebEM to all of this from Admin CLI.
    ...  "getTroubleshootingScriptByName" command is verified. Compare script name from WebEM with script name from Admin CLI.
    ...  Verify the first script with random cells. For each free text (1, 2, 3) a random cell will be choose. Output is saved in BTSFiles.
    ...  Verify the second script with a random BBMOD. Output is saved in BTSFiles.
    ...  Verify the third script with random cell and BBMOD. Output is saved in BTSFiles.
    ...  Verify the first script with all cells and all BBMODs. Output is saved in BTSFiles.
    ...  Verify the warning case with one cell and 2 BBMODs. Output is saved partially in BTSFiles.
    ...  Verify the error case with one cell and error text in free text parameters. This command needs to be failed.
    ...  Change actCli parameter to be false.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Keywords ***
TC__WebEM__Troubleshooting_scripts_cli
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-23251
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 09.06.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23251 - Initial TAT creation
    ...  - 25.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24131 - Refactor TCs with best practice
    ...  - 15.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24316 - Refactor WebEM TCs and resources to use KWs from ca_SBTS_general

    Set Tags  CA-WebEM  OWNER-cristina.antoci@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS22

    Step1: Change ActCli Parameter To Be true
    Step2: Open Troubleshooting Scripts Tab
    Step3: Verify The Details From Every Script Via WebEM And Admin CLI
    Step4: Verify GetTroubleshootingScriptByName Command Admin CLI
    Step5: Verify The First Script With Random Cells
    Step6: Verify The Second Script With A Random BBMOD
    Step7: Verify The Third Script With A Random Cell And BBMOD
    Step8: Verify The First Script With All Cells And All BBMODs
    Step9: Verify The Warning Case With One Cell And Two BBMODs
    Step10: Verify The Error Case With One Cell And Error Text
    Step11: Change ActCli Parameter To Be false


Step${id}: Change ActCli Parameter To Be ${value}
    Log  Step${id}: Change actCli parameter to be ${value}  console=true
    Change ActCli Parameter  ${value}


Step2: Open Troubleshooting Scripts Tab
    Log  Step2: Open Troubleshooting Scripts tab  console=true
    Setup Admin CLI  ${ACTIVE_SW_VERSION}  ${MPLANE_IP}
    Open Diagnostic Menu
    Click Element  xpath://*[contains(text(), "Troubleshooting Scripts")]
    Log  Troubleshooting Scripts is open!  console=true
    Log  Waiting for text "Fetching succeeded" to appear!  console=true
    ${status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  300  5
    ...  Element Should Be Visible  //*[contains(text(), 'Fetching succeeded')]
    Run Keyword If  ${status}
    ...  Log  Text "Fetching succeeded" appeard![OK]  console=true
    ...  ELSE
    ...  Set Test Restriction  Text "Fetching succeeded" is not appeard![NOK]


Step3: Verify The Details From Every Script Via WebEM And Admin CLI
    Log  Step3: Verify the details from every script via WebEM and Admin CLI  console=true
    Log  Open Details tab...  console=true
    ${status}  Run Keyword And Return Status
    ...  Element Should Be Visible  //h1[contains(text(), 'Details')]
    Run Keyword If  ${status}==${FALSE}
    ...  Wait Until Element Is Clicked  //*[contains(@class, 'details-panel-container')]/ui-button/button/i  120
    Log  Details tab is opened!  console=true
    ${script_name_bun}  ${script_owner_bun}  ${script_description_bun}  ${free_text_values_bun}  Get Details For The Specific Script  l1_lnr_col_bun
    ${script_name_hdr}  ${script_owner_hdr}  ${script_description_hdr}  ${free_text_values_hdr}  Get Details For The Specific Script  l1_lnr_col_hdr
    ${script_name_reg}  ${script_owner_reg}  ${script_description_reg}  ${free_text_values_reg}  Get Details For The Specific Script  l1_lnr_col_reg
    ${name_web_em_list}  Create List  ${script_name_bun}  ${script_name_hdr}  ${script_name_reg}
    ${owner_web_em_list}  Create List  ${script_owner_bun}  ${script_owner_hdr}  ${script_owner_reg}
    ${description_web_em_list}  Create List  ${script_description_bun}  ${script_description_hdr}  ${script_description_reg}
    ${request}  Set Variable  {"requestId":1,"parameters":{"name":"getAllTroubleshootingScripts","parameters":{"scriptOwnerModule":"SMOD"}}}
    Log  Sending command via Admin CLI for getting all Troubleshooting Scripts...  console=true
    ${request_status}  ${error_code}  ${request_message}  Admin CLI Send Request  ${request}
    Run Keyword If  '${request_status}' == 'completed'
    ...  Log  Command sent with status: ${request_status}  console=true
    ...  ELSE
    ...  Fail  Command sent with status: ${request_status} and error code: ${error_code}
    ${name_admin_cli_list}  Create List
    ${owner_admin_cli_list}  Create List
    ${description_admin_cli_list}  Create List
    ${freetext_admin_cli_list}  Create List
    FOR  ${index}  IN  @{request_message}
        Append To List  ${name_admin_cli_list}  ${index}[scriptName]
        Append To List  ${owner_admin_cli_list}  ${index}[scriptOwnerModule]
        Append To List  ${description_admin_cli_list}  ${index}[scriptDescription]
        ${free_text_param_list}  Set Variable  ${index}[freeTextParameters]
        Append To List  ${freetext_admin_cli_list}  @{free_text_param_list}
    END
    ${freetextparameter_list}  Create List
    FOR  ${index}  IN  @{freetext_admin_cli_list}
        ${status}  Run Keyword And Return Status
        ...  Should Be Empty  ${index}
        Run Keyword If  ${status}
        ...  Append To List  ${FREE_TEXT_PARAMETER}  ${index}
        ...  ELSE
        ...  Append To List  ${freetextparameter_list}  ${index}[name]
    END
    Set Test Variable  ${FREETEXTPARAMETER_LIST}
    Verify If Lists Are Equal  ${name_admin_cli_list}  ${name_web_em_list}  Scripts name
    Verify If Lists Are Equal  ${owner_admin_cli_list}  ${owner_web_em_list}  Scripts owner
    Verify If Lists Are Equal  ${description_admin_cli_list}  ${description_web_em_list}  Scripts description
    Verify If Lists Are Equal  ${FREETEXTPARAMETER_LIST}  ${free_text_values_bun}  Free Text Parameter


Step4: Verify GetTroubleshootingScriptByName Command Admin CLI
    Log  Step4: Verify getTroubleshootingScriptByName command Admin CLI  console=true
    Sending GetTroubleshootingScriptByName Command And Verify Script Name  l1_lnr_col_bun
    Sending GetTroubleshootingScriptByName Command And Verify Script Name  l1_lnr_col_hdr
    Sending GetTroubleshootingScriptByName Command And Verify Script Name  l1_lnr_col_reg


Step5: Verify The First Script With Random Cells
    Log  Step5: Verify the first script with random cells  console=true
    Get NRCEL IDs And NRBTS ID
    FOR  ${index}  IN  @{FREETEXTPARAMETER_LIST}
        ${cell_id}  Get A Random NRCEL Id
        Sending Command For The First Script With A Random Cell And Different FreeTextParameter  ${cell_id}  ${index}
    END


Step6: Verify The Second Script With A Random BBMOD
    Log  Step6: Verify the second script with a random BBMOD  console=true
    ${bbmods_id_list}  Get A List With All Bbmods With 5G Cells On
    ${length}  Get Length  ${bbmods_id_list}
    ${bbmod_id}  Run Keyword If  ${length}>1
    ...  Evaluate  random.choice(${bbmods_id_list})  random
    ...  ELSE
    ...  Set Variable  ${bbmods_id_list}[0]
    Log  ${bbmod_id} will be choose!  console=true
    ${request}  Catenate  SEPARATOR=  {"requestId":1,"parameters":{"name":"launchTroubleshootingScript","parameters":{"scriptName":
    ...  "l1_lnr_col_hdr","bbmods":["MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/${bbmod_id}"]}}}
    Log  Sending command via Admin CLI for getting 'l1_lnr_col_hdr' troubleshooting Script for ${bbmod_id}...  console=true
    ${current_time}  DateTime.Get Current Date  result_format=%Y.%m.%d-%H:%M  exclude_millis=true
    ${request_status}  ${error_code}  ${request_message}  Admin CLI Send Request  ${request}
    ...  output_file=${BTS_FILES}/l1_lnr_col_hdr_${bbmod_id}_${current_time}.zip
    Run Keyword If  '${request_status}' == 'completed'
    ...  Log  Command sent with status: ${request_status}  console=true
    ...  ELSE
    ...  Fail  Command sent with status: ${request_status} and error code: ${error_code}
    Log  Script result 'l1_lnr_col_hdr_${bbmod_id}_${current_time}' saved in BTSFiles!  console=true


Step7: Verify The Third Script With A Random Cell And BBMOD
    Log  Step7: Verify the third script with a random cell and BBMOD  console=true
    ${cell_id}  Get A Random NRCEL Id
    ${bbmod_id}  Get Bbmod Id  ${cell_id}
    Log  Cell ${cell_id} and ${bbmod_id} will be choose!  console=true
    ${request}  Catenate  SEPARATOR=  {"requestId":1,"parameters":{"name":"launchTroubleshootingScript","parameters":{"scriptName":
    ...  "l1_lnr_col_reg","cells":["MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}"],"bbmods":
    ...  ["MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/${bbmod_id}"]}}}
    Log  Sending command via Admin CLI for getting 'l1_lnr_col_reg' troubleshooting Script for NRCELL-${cell_id} and ${bbmod_id}...  console=true
    ${current_time}  DateTime.Get Current Date  result_format=%Y.%m.%d-%H:%M  exclude_millis=true
    ${request_status}  ${error_code}  ${request_message}  Admin CLI Send Request  ${request}
    ...  output_file=${BTS_FILES}/l1_lnr_col_reg_NRCELL-${cell_id}_${bbmod_id}_${current_time}.zip
    Run Keyword If  '${request_status}' == 'completed'
    ...  Log  Command sent with status: ${request_status}  console=true
    ...  ELSE
    ...  Fail  Command sent with status: ${request_status} and error code: ${error_code}
    Log  Script result 'l1_lnr_col_reg_NRCELL-${cell_id}_${bbmod_id}_${current_time}' saved in BTSFiles!  console=true


Step8: Verify The First Script With All Cells And All BBMODs
    Log  Step8: Verify the first script with all cells and all BBMODs  console=true
    ${all_cells}  Set Variable
    ${last_cell}  Get From List  ${NRCEL_IDS_LIST}  -1
    FOR  ${cell}  IN  @{NRCEL_IDS_LIST}
        ${all_cells}  Run Keyword If  ${cell}==${last_cell}
        ...  Catenate  ${all_cells}  "MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell}"
        ...  ELSE
        ...  Catenate  ${all_cells}  "MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell}",
    END
    ${bbmods_id_list}  Get A List With All Bbmods With 5G Cells On
    ${all_bbmods}  Set Variable
    ${last_bbmod}  Get From List  ${bbmods_id_list}  -1
    FOR  ${bbmod}  IN  @{bbmods_id_list}
        ${all_bbmods}  Run Keyword If  '${bbmod}'=='${last_bbmod}'
        ...  Catenate  ${all_bbmods}  "MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/${bbmod}"
        ...  ELSE
        ...  Catenate  ${all_bbmods}  "MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/${bbmod}",
    END
    ${request}  Catenate  SEPARATOR=  {"requestId":1,"parameters":{"name":"launchTroubleshootingScript","parameters":{"scriptName":
    ...  "l1_lnr_col_bun","cells":[${all_cells}],"bbmods":[${all_bbmods}]}}}
    Log  Sending command via Admin CLI for getting 'l1_lnr_col_bun' troubleshooting Script for all cells and all bbmods...  console=true
    ${request_status}  ${error_code}  ${request_message}  Admin CLI Send Request  ${request}
    ...  output_file=${BTS_FILES}/l1_lnr_col_bun_all_cells_all_bbmods.zip
    Run Keyword If  '${request_status}' == 'completed'
    ...  Log  Command sent with status: ${request_status}  console=true
    ...  ELSE
    ...  Fail  Command sent with status: ${request_status} and error code: ${error_code}
    Log  Script result 'l1_lnr_col_bun_all_cells_all_bbmods' saved in BTSFiles!  console=true


Step9: Verify The Warning Case With One Cell And Two BBMODs
    Log  Step9: Verify the warning case with one cell and two BBMODs  console=true
    ${cell_id}  Get A Random NRCEL Id
    ${bbmod_id}  Get Bbmod Id  ${cell_id}
    ${bbmods_id_list}  Get A List With All Bbmods With 5G Cells On
    Remove Values From List  ${bbmods_id_list}  ${bbmod_id}
    ${request}  Catenate  SEPARATOR=  {"requestId":1,"parameters":{"name":"launchTroubleshootingScript","parameters":{"scriptName":
    ...  "l1_lnr_col_bun","cells":["MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}"],"bbmods":
    ...  ["MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/${bbmod_id}", "MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/${bbmods_id_list}[0]"]}}}
    ${log}  Catenate  SEPARATOR=  Sending command via Admin CLI for getting 'l1_lnr_col_bun' troubleshooting Script for NRCELL
    ...  -${cell_id} and BBMODs:${bbmod_id} and ${bbmods_id_list}[0]...
    Log  ${log}  console=true
    ${current_time}  DateTime.Get Current Date  result_format=%Y.%m.%d-%H:%M  exclude_millis=true
    ${request_status}  ${error_code}  ${request_message}  Admin CLI Send Request  ${request}
    ...  output_file=${BTS_FILES}/l1_lnr_col_bun_NRCELL-${cell_id}_${bbmod_id}_${bbmods_id_list}[0]_warning_${current_time}.zip
    ${status_message}  Run Keyword And Return Status
    ...  Should Contain  ${request_message}  Launching partially succeeded
    Run Keyword If  '${request_status}' == 'completed' and ${status_message}
    ...  Log  Command sent with status: ${request_status} and message ${request_message}!  console=true
    ...  ELSE
    ...  Fail  Command sent with status: ${request_status} and error code: ${error_code}!
    Log  Script result 'l1_lnr_col_bun_NRCELL-${cell_id}_${bbmod_id}_${bbmods_id_list}[0]_warning_${current_time}' saved in BTSFiles!  console=true


Step10: Verify The Error Case With One Cell And Error Text
    Log  Step10: Verify the error case with one cell and error text  console=true
    ${cell_id}  Get A Random NRCEL Id
    ${request}  Catenate  SEPARATOR=  {"requestId":1,"parameters":{"name":"launchTroubleshootingScript","parameters":{"scriptName":
    ...  "l1_lnr_col_bun","cells":["MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}"],"freeTextParameters":"error"}}}
    Log  Sending command via Admin CLI for getting 'l1_lnr_col_bun' troubleshooting Script with freeText 'error' for cell ${cell_id}...  console=true
    ${request_status}  ${error_code}  ${request_message}  Admin CLI Send Request  ${request}
    ...  output_file=${BTS_FILES}/l1_lnr_col_bun_NRCELL-${cell_id}_error.zip
    ${status_message}  Run Keyword And Return Status
    ...  Should Contain  ${request_message}  Launching failed
    Run Keyword If  '${request_status}' == 'failed' and ${status_message}
    ...  Log  Command sent with status: ${request_status} and message ${request_message}!  console=true
    ...  ELSE
    ...  Fail  Command sent with status: ${request_status} and error code: ${error_code}!


Sending GetTroubleshootingScriptByName Command And Verify Script Name
    [Arguments]  ${script_name}

    ${request}  Set Variable  {"requestId":1,"parameters":{"name":"getTroubleshootingScriptByName","parameters":{"scriptName":"${script_name}"}}}
    Log  Sending command via Admin CLI for getting '${script_name}' Troubleshooting Script...  console=true
    ${request_status}  ${error_code}  ${request_message}  Admin CLI Send Request  ${request}
    Run Keyword If  '${request_status}' == 'completed'
    ...  Log  Command sent with status: ${request_status}  console=true
    ...  ELSE
    ...  Fail  Command sent with status: ${request_status} and error code: ${error_code}
    ${script_name_message}  Get From Dictionary  ${request_message}  scriptName
    ${status}  Run Keyword And Return Status
    ...  Should Be Equal As Strings  ${script_name_message}  ${script_name}
    Run Keyword If  ${status}
    ...  Log  Script name "${script_name_message}" is correct in Admin CLI![OK]  console=true
    ...  ELSE
    ...  Fail  Script name "${script_name_message}" is not correct in Admin CLI![NOK]


Verify If Lists Are Equal
    [Arguments]  ${admin_cli_list}  ${webem_list}  ${parameter}

    ${status}  Run Keyword And Return Status
    ...  Lists Should Be Equal  ${admin_cli_list}  ${webem_list}
    Run Keyword If  ${status}
    ...  Log  ${parameter} are the same in WebEM as in Admin CLI![OK]  console=true
    ...  ELSE
    ...  Fail  ${parameter} from CLI are ${admin_cli_list} whitch are not the same with ${parameter} from WebEM ${webem_list}!


Get Details For The Specific Script
    [Arguments]  ${script}

    Click Element  xpath=//*[contains(@aria-label, '${script}')]
    ${script_name}  Get Text  //*[contains(@class, 'p-element details-table')]/div/div/table/tbody/tr[1]/td[2]
    ${script_owner}  Get Text  //*[contains(@class, 'p-element details-table')]/div/div/table/tbody/tr[2]/td[2]
    ${script_description}  Get Text  //*[contains(@class, 'p-element details-table')]/div/div/table/tbody/tr[4]/td[2]
    ${free_text_values}  Get Values For Free Text
    ${free_text_list_length}  Get Length  ${free_text_values}

    [Return]  ${script_name}  ${script_owner}  ${script_description}  ${free_text_values}


Get Values For Free Text
    ${free_text_values}  Create List
    ${status}  Run Keyword And Return Status
    ...  Element Should Be Visible  //p-table[@class='p-element script-parameters-table']//td[contains(text(), 'No data available')]
    Run Keyword If  ${status}
    ...  Return From Keyword  ${free_text_values}
    ${free_text_names}  SeleniumLibrary.Get WebElements  //p-table[@class='p-element script-parameters-table']//tr[@class='ng-star-inserted']/td[1]
    FOR  ${name}  IN  @{free_text_names}
        ${value}  Get Text  ${name}
        Append To List  ${free_text_values}  ${value}
    END

    [Return]  ${free_text_values}


Sending Command For The First Script With A Random Cell And Different FreeTextParameter
    [Arguments]  ${cell_id}  ${free_text}

    ${request}  Catenate  SEPARATOR=  {"requestId":1,"parameters":{"name":"launchTroubleshootingScript","parameters":{"scriptName":
    ...  "l1_lnr_col_bun","cells":["MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}"],"freeTextParameters":"${free_text}"}}}
    Log  Sending command via Admin CLI for getting 'l1_lnr_col_bun' troubleshooting Script with freeText ${free_text} for cell ${cell_id}...
    ...  console=true
    ${current_time}  DateTime.Get Current Date  result_format=%Y.%m.%d-%H:%M  exclude_millis=true
    ${request_status}  ${error_code}  ${request_message}  Admin CLI Send Request  ${request}
    ...  output_file=${BTS_FILES}/l1_lnr_col_bun_freeText_${free_text}_NRCELL-${cell_id}_${current_time}.zip
    Run Keyword If  '${request_status}' == 'completed'
    ...  Log  Command sent with status: ${request_status}  console=true
    ...  ELSE
    ...  Fail  Command sent with status: ${request_status} and error code: ${error_code}
    Log  Script result 'l1_lnr_col_bun_freeText_${free_text}_NRCELL-${cell_id}_${current_time}' saved in BTSFiles!  console=true


Get NRCEL Ids And NRBTS Id
    ${nrcel_ids_list}  Create List
    ${nrce_lids}  Get Ids For All  NRCEL
    FOR  ${index}  IN  @{nrce_lids}
        ${id}  Fetch From Right  ${index}  NRCELL_R-
        Append To List  ${nrcel_ids_list}  ${id}
    END
    ${nrbts}  Get_id_for_current  NRBTS
    ${nrbts_id}  Fetch From Right  ${nrbts}  NRBTS_R-
    Set Test Variable  ${NRCEL_IDS_LIST}
    Set Test Variable  ${NRBTS_ID}


Get A Random NRCEL Id
    ${length}  Get Length  ${NRCEL_IDS_LIST}
    ${cell_id}  Run Keyword If  ${length}>1
    ...  Evaluate  random.choice(${NRCEL_IDS_LIST})  random
    ...  ELSE
    ...  Set Variable  ${NRCEL_IDS_LIST}[0]
    Log  Cell ${cell_id} will be choose!  console=true

    [Return]  ${cell_id}


Get Bbmod Id
    [Arguments]  ${cell_id}

    ${bbmod_ids}  Get Ids For All  BBMOD
    FOR  ${bbmod_id}  IN  @{bbmod_ids}
        ${cells_on_bbmod}  Get_cell_mapping_by_module_id  ${bbmod_id}
        ${cells_ids}  Get Cells Id On The Specific BBMOD  ${cells_on_bbmod}
        ${status}  Run Keyword And Return Status
        ...  List Should Contain Value  ${cells_ids}  NRCELL-${cell_id}
        Run Keyword If  ${status}
        ...  Exit For Loop
    END
    ${bbmod_r_id}  Fetch From Right  ${bbmod_id}  /
    ${bbmod_id}  Remove String  ${bbmod_r_id}  _R

    [Return]  ${bbmod_id}


Get A List With All Bbmods With 5G Cells On
    ${bbmod_ids}  Get Ids For All  BBMOD
    ${bbmod_with_5_g}  Create List
    FOR  ${bbmod_id}  IN  @{bbmod_ids}
        ${cells_on_bbmod}  Get_cell_mapping_by_module_id  ${bbmod_id}
        ${cells_ids}  Get Cells Id On The Specific BBMOD  ${cells_on_bbmod}
        ${status}  Run Keyword And Return Status
        ...  Should Contain Match  ${cells_ids}  NRCEL*
        Run Keyword If  ${status}
        ...  Append To List  ${bbmod_with_5_g}  ${bbmod_id}
    END
    ${bbmods_id}  Create List
    FOR  ${bbmod_dn}  IN  @{bbmod_with_5_g}
        ${last_part}  Fetch From Right  ${bbmod_dn}  /
        ${bbmod_id}  Remove String  ${last_part}  _R
        Append To List  ${bbmods_id}  ${bbmod_id}
    END

    [Return]  ${bbmods_id}


Get Cells Id On The Specific BBMOD
    [Arguments]  ${cells_on_bbmod}

    ${cells_id}  Create List
    FOR  ${cell_dn}  IN  @{cells_on_bbmod}
        ${last_part}  Fetch From Right  ${cell_dn}  /
        ${cell_id}  Remove String  ${last_part}  _R
        Append To List  ${cells_id}  ${cell_id}
    END

    [Return]  ${cells_id}


TC Setup
    Common Test Setup
    WebEM Setup


TC Teardown
    WebEM Teardown
    Common Test Teardown
