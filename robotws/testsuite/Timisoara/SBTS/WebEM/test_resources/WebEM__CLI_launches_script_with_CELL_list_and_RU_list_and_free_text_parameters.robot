*** Settings ***
Documentation
    ...  This test case is transferred from BOAM_ET to ST_OAM_WebEM.
    ...  This test launches a specific script via ADMIN CLI.
    ...  actCli parameter is changed to be true.
    ...  Script command with all NR cells and all rmods with 5G is performed.
    ...  Verify for command to be sent with status completed, message launching succeeded and error code 0.
    ...  Script command with a random NR cell and all rmods is performed.
    ...  Verify for command to be sent with status completed, message launching partially succeeded and error code 0.
    ...  Script command with a random LTE cell and all rmods is performed.
    ...  Verify for command to be sent with status failed, message launching failed and error code 69.
    ...  actCli parameter is changed to be false.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${SCRIPT}  RU_Common_capture_register_dump  # Name of the script to be testing.Default is RU_Common_capture_register_dump


*** Keywords ***
TC__WebEM__CLI_launches_script_with_CELL_list_and_RU_list_and_free_text_parameters
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24449
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 10.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24449 - Initial TAT creation
    ...  - 09.05.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27467 - Rmod distname fixed
    ...  - 08.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30275 - Change script to work only with 7.1 RMODs with 5G exclusive

    Set Tags  CA-WebEM  OWNER-cristina.antoci@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS23

    Step1: Change ActCli Parameter To Be true
    Step2: Launches Script With NR Cells And RMODs With 5G Via ADMIN CLI
    Step3: Launches Script With One NR Cell And All RMODs Via ADMIN CLI
    Step4: Launches Script With One LTE Cell And All RMODs Via ADMIN CLI
    Step5: Change ActCli Parameter To Be false


Step${id}: Change ActCli Parameter To Be ${value}
    Log  \nStep${id}: Change actCli parameter to be ${value}  console=true
    Change ActCli Parameter  ${value}


Step2: Launches Script With NR Cells And RMODs With 5G Via ADMIN CLI
    Log  \nStep2: Launches script with NR cells and RMODs with 5G via ADMIN CLI  console=true
    Setup Admin CLI  ${ACTIVE_SW_VERSION}  ${MPLANE_IP}
    ${nrbts}  Get Id For Current  NRBTS
    ${nrbts_id}  Fetch From Right  ${nrbts}  NRBTS_R-
    Set Test Variable  ${NRBTS_ID}
    ${rmods_id_list}  ${NRCELLS_ID_LIST}  Get A List With All Rmods Id With 5G Cells On And All NRCELL Ids
    Set Test Variable  ${NRCELLS_ID_LIST}
    ${all_5g_cells}  Set Variable
    FOR  ${cell}  IN  @{NRCELLS_ID_LIST}
        ${all_5g_cells}  Catenate  ${all_5g_cells}  "MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/${cell}",
    END
    ${all_5g_cells}  Get Substring  ${all_5g_cells}  0  -1
    ${all_5g_rmods}  Set Variable
    FOR  ${rmod}  IN  @{rmods_id_list}
        ${all_5g_rmods}  Catenate  ${all_5g_rmods}  "${rmod}",
    END
    ${all_5g_rmods}  Get Substring  ${all_5g_rmods}  0  -1
    ${request}  Catenate  SEPARATOR=  {"requestId":1,"parameters":{"name":"launchTroubleshootingScript","parameters":{"scriptName":"${SCRIPT}"
    ...  ,"cells":[${all_5g_cells}],"rmods":[${all_5g_rmods}],"freeTextParameters":"test"}}}
    Log  Sending command via Admin CLI for ${SCRIPT} with all NR cells and all RMODs with 5G...  console=true
    ${request_status}  ${error_code}  ${request_message}  Admin CLI Send Request  ${request}
    ...  output_file=${BTS_FILES}/${SCRIPT}_all_5G_rmods_all_cells_free_text_parameters.json
    Should Contain  ${request_message}  Launching succeeded
    IF  '${request_status}' == 'completed' and ${error_code} == 0
        Log  Command sent with status: ${request_status}, message: ${request_message} and error code: ${error_code}  console=true
    ELSE
        Fail  Command sent with status: ${request_status}, message: ${request_message} and error code: ${error_code}
    END


Step3: Launches Script With One NR Cell And All RMODs Via ADMIN CLI
    Log  \nStep3: Launches script with one NR cell and all RMODs via ADMIN CLI  console=true
    ${length}  Get Length  ${NRCELLS_ID_LIST}
    ${cell_id}  IF  ${length}>1  Evaluate  random.choice(${NRCELLS_ID_LIST})  random
    Log  ${cell_id} will be choose!  console=true
    ${rmods_id_list}  Get A List With All Rmods Id
    ${all_rmods}  Set Variable
    FOR  ${rmod}  IN  @{rmods_id_list}
        ${all_rmods}  Catenate  ${all_rmods}  "${rmod}",
    END
    ${all_rmods}  Get Substring  ${all_rmods}  0  -1
    Set Test Variable  ${ALL_RMODS}
    ${request}  Catenate  SEPARATOR=  {"requestId":1,"parameters":{"name":"launchTroubleshootingScript","parameters":{"scriptName":"${SCRIPT}"
    ...  ,"cells":["MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/${cell_id}"],"rmods":[${ALL_RMODS}],"freeTextParameters":"test"}}}
    Log  Sending command via Admin CLI for ${SCRIPT} with a random NR cell and all RMODs...  console=true
    ${request_status}  ${error_code}  ${request_message}  Admin CLI Send Request  ${request}
    ...  output_file=${BTS_FILES}/${SCRIPT}_all_rmods_one_cell_free_text_parameters.json
    Should Contain  ${request_message}  Launching partially succeeded
    IF  '${request_status}' == 'completed' and ${error_code} == 0
        Log  Command sent with status: ${request_status}, message: ${request_message} and error code: ${error_code}  console=true
    ELSE
        Fail  Command sent with status: ${request_status}, message: ${request_message} and error code: ${error_code}
    END


Step4: Launches Script With One LTE Cell And All RMODs Via ADMIN CLI
    Log  \nStep4: Launches script with one LTE cell and all RMODs via ADMIN CLI  console=true
    ${lncel_ids}  Get Ids For All  LNCEL
    ${length}  Get Length  ${lncel_ids}
    ${cell_id}  IF  ${length}>1  Evaluate  random.choice(${lncel_ids})  random
    ${id}  Fetch From Right  ${cell_id}  LNCEL_R-
    Log  LNCEL-${id} will be choose!  console=true
    ${request}  Catenate  SEPARATOR=  {"requestId":1,"parameters":{"name":"launchTroubleshootingScript","parameters":{"scriptName":"${SCRIPT}"
    ...  ,"cells":["MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${id}"],"rmods":[${ALL_RMODS}],"freeTextParameters":"test"}}}
    Log  Sending command via Admin CLI for ${SCRIPT} with a random LTE cell and all RMODs...  console=true
    ${request_status}  ${error_code}  ${request_message}  Admin CLI Send Request  ${request}
    ...  output_file=${BTS_FILES}/${SCRIPT}_all_rmods_one_LTE_cell_free_text_parameters.json
    Should Contain  ${request_message}  Launching failed
    IF  '${request_status}' == 'failed' and ${error_code} == 69
        Log  Command sent with status: ${request_status}, message: ${request_message} and error code: ${error_code}  console=true
    ELSE
        Fail  Command sent with status: ${request_status}, message: ${request_message} and error code: ${error_code}
    END


Get A List With All Rmods Id With 5G Cells On And All NRCELL Ids
    ${rmods}  Get Ids For All  RMOD
    ${rmod_with_5_g}  Create List
    ${tested_nrcells}  Create List
    FOR  ${rmod}  IN  @{rmods}
        ${parameters}  coam.Get Parameters  ${rmod}
        ${status}  Run Keyword And Return Status  Should Contain  ${parameters}[radioModuleHwReleaseCode]  7.1
        IF  not ${status}  CONTINUE
        ${cells_on_rmod}  Get Cell Mapping By Module Id  ${rmod}
        ${cells_ids}  Get Cells Id On The Specific Rmod  ${cells_on_rmod}
        ${cells_count}  Get Length  ${cells_ids}
        ${nrcell_count}  Get Match Count  ${cells_ids}  NRCELL-*
        IF  ${cells_count} == ${nrcell_count}
            Append To List  ${rmod_with_5g}  ${rmod}
            FOR  ${cell}  IN  @{cells_ids}
                Append To List  ${tested_nrcells}  ${cell}
            END
        END
    END

    RETURN  ${rmod_with_5g}  ${tested_nrcells}


Get Cells Id On The Specific Rmod
    [Arguments]  ${cells_on_rmod}

    ${cells_id}  Create List
    FOR  ${cell_dn}  IN  @{cells_on_rmod}
        ${last_part}  Fetch From Right  ${cell_dn}  /
        ${cell_id}  Remove String  ${last_part}  _R
        Append To List  ${cells_id}  ${cell_id}
    END

    RETURN  ${cells_id}


Get A List With All Rmods Id
    ${all_rmods_id}  Get Ids For All  RMOD
    ${rmods_id}  Create List
    FOR  ${rmod_dn}  IN  @{all_rmods_id}
        Append To List  ${rmods_id}  ${rmod_dn}
    END

    RETURN  ${rmods_id}


TC Setup
    Common Test Setup


TC Teardown
    Common Test Teardown
