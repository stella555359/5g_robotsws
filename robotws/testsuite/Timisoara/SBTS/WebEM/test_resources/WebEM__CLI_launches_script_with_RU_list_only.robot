*** Settings ***
Documentation
    ...  This test case is transferred from BOAM_ET to ST_OAM_WebEM.
    ...  This test launches RU Common capture register dump script via ADMIN CLI.
    ...  actCli parameter is changed to be true.
    ...  RU Common capture register dump command with all rmods is performed.
    ...  Verify for command to be sent with status completed, message launching partially succeeded and error code 0.
    ...  RU Common capture register dump command with a random rmod with 5G is performed.
    ...  Verify for command to be sent with status completed, message launching succeeded and error code 0.
    ...  RU Common capture register dump command with a rmod without 5G is performed.
    ...  Verify for command to be sent with status failed, message launching failed and error code 69.
    ...  actCli parameter is changed to be false.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Keywords ***
TC__WebEM__CLI_launches_script_with_RU_list_only
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24450
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 06.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24450 - Initial TAT creation
    ...  - 10.05.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27475 - Rmod distname fixed

    Set Tags  CA-WebEM  OWNER-cristina.antoci@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS23

    Step1: Change ActCli Parameter To Be true
    Step2: Launches Script With All RMODs Via ADMIN CLI
    Step3: Launches Script With RMOD With 5G Via ADMIN CLI
    Step4: Launches Script With RMOD Without 5G Via ADMIN CLI
    Step5: Change ActCli Parameter To Be false


Step${id}: Change ActCli Parameter To Be ${value}
    Log  \nStep${id}: Change actCli parameter to be ${value}  console=true
    Change ActCli Parameter  ${value}


Step2: Launches Script With All RMODs Via ADMIN CLI
    Log  \nStep2: Launches script with all RMODs via ADMIN CLI  console=true
    Setup Admin CLI  ${ACTIVE_SW_VERSION}  ${MPLANE_IP}
    ${all_rmods_id}  Get Ids For All  RMOD
    ${rmods_id}  Create List
    FOR  ${rmod_dn}  IN  @{all_rmods_id}
        Append To List  ${rmods_id}  ${rmod_dn}
    END
    ${all_rmods}  Set Variable
    ${last_rmod}  Get From List  ${rmods_id}  -1
    FOR  ${rmod}  IN  @{rmods_id}
        ${all_rmods}  Run Keyword If  '${rmod}'=='${last_rmod}'
        ...  Catenate  ${all_rmods}  "${rmod}"
        ...  ELSE
        ...  Catenate  ${all_rmods}  "${rmod}",
    END
    ${request}  Catenate  SEPARATOR=  {"requestId":1,"parameters":{"name":"launchTroubleshootingScript","parameters":{"scriptName":"RU_Common_
    ...  capture_register_dump","rmods":[${all_rmods}]}}}
    Log  Sending command via Admin CLI for RU common capture register dump with all RMODs...  console=true
    ${request_status}  ${error_code}  ${request_message}  Admin CLI Send Request  ${request}
    ...  output_file=${BTS_FILES}/RU_common_capture_register_dump_all_rmods.json
    Should Contain  ${request_message}  Launching partially succeeded
    Run Keyword If  '${request_status}' == 'completed' and ${error_code} == 0
    ...  Log  Command sent with status: ${request_status}, message: ${request_message} and error code: ${error_code}  console=true
    ...  ELSE
    ...  Fail  Command sent with status: ${request_status}, message: ${request_message} and error code: ${error_code}


Step3: Launches Script With RMOD With 5G Via ADMIN CLI
    Log  \nStep3: Launches script with RMOD with 5G via ADMIN CLI  console=true
    ${rmods_param}  Get Parameters For All  RMOD
    ${rmods_with_5_g}  Create List
    ${rmods_without_5_g}  Create List
    FOR  ${index}  IN  @{rmods_param}
        ${l3_protocol_status}  Run Keyword And Return Status
        ...  Should Contain  ${index}[l3Protocol]  ECPRI
        Run Keyword If  ${l3_protocol_status}
        ...  Append To List  ${rmods_with_5_g}  ${index}[id]
        ...  ELSE
        ...  Append To List  ${rmods_without_5_g}  ${index}[id]
    END
    Set Test Variable  ${RMODS_WITHOUT_5_G}
    ${rmod_id}  Get A Random RMOD Id  ${rmods_with_5_g}
    ${request}  Catenate  SEPARATOR=  {"requestId":1,"parameters":{"name":"launchTroubleshootingScript","parameters":{"scriptName":"RU_Common_
    ...  capture_register_dump","rmods":["${rmod_id}"]}}}
    Log  Sending command via Admin CLI for RU common capture register dump with 5G RMOD...  console=true
    ${request_status}  ${error_code}  ${request_message}  Admin CLI Send Request  ${request}
    ...  output_file=${BTS_FILES}/RU_common_capture_register_dump_RMOD_with_5G.json
    Should Contain  ${request_message}  Launching succeeded. Snapshot has been successfully created.
    Run Keyword If  '${request_status}' == 'completed' and ${error_code} == 0
    ...  Log  Command sent with status: ${request_status}, message: ${request_message} and error code: ${error_code}  console=true
    ...  ELSE
    ...  Fail  Command sent with status: ${request_status}, message: ${request_message} and error code: ${error_code}


Step4: Launches Script With RMOD Without 5G Via ADMIN CLI
    Log  \nStep4: Launches script with RMOD without 5G via ADMIN CLI  console=true
    ${rmod_id}  Get A Random RMOD Id  ${RMODS_WITHOUT_5_G}
    ${request}  Catenate  SEPARATOR=  {"requestId":1,"parameters":{"name":"launchTroubleshootingScript","parameters":{"scriptName":"RU_Common_
    ...  capture_register_dump","rmods":["${rmod_id}"]}}}
    Log  Sending command via Admin CLI for RU common capture register dump with RMOD without 5G...  console=true
    ${request_status}  ${error_code}  ${request_message}  Admin CLI Send Request  ${request}
    ...  output_file=${BTS_FILES}/RU_common_capture_register_dump_RMOD_without_5G.json
    Should Contain  ${request_message}  Launching failed
    Run Keyword If  '${request_status}' == 'failed' and ${error_code} == 69
    ...  Log  Command sent with status: ${request_status}, message: ${request_message} and error code: ${error_code}  console=true
    ...  ELSE
    ...  Fail  Command sent with status: ${request_status}, message: ${request_message} and error code: ${error_code}


Get A Random RMOD Id
    [Arguments]  ${rmods}

    ${length}  Get Length  ${rmods}
    ${rmod}  Run Keyword If  ${length}>1
    ...  Evaluate  random.choice(${rmods})  random
    ...  ELSE
    ...  Set Variable  ${rmods}[0]
    Log  ${rmod} will be choose!  console=true

    [Return]  ${rmod}


TC Setup
    Common Test Setup


TC Teardown
    Common Test Teardown
