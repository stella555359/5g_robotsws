*** Settings ***
Documentation
    ...  This test case is transferred from BOAM_ET to ST_OAM_WebEM.
    ...  This test case verify different error codes via ADMIN CLI.
    ...  actCli parameter is changed to be true.
    ...  Error code 23 is verify by sending a specific command via ADMIN CLI.
    ...  Error code 24 is verify by sending a specific command via ADMIN CLI.
    ...  Error code 25 is verify by sending a specific command via ADMIN CLI.
    ...  For this error code it is necessary to have a SCF with wrong RAML schema.
    ...  Error code 27 is verify by sending a specific command via ADMIN CLI.
    ...  First step is sending a command for locking one NRCEL.
    ...  Second step is sending a command for shutting down one NRCEL and error code 27 is visible.
    ...  Third step is sending a command for unlocking this cell.
    ...  Verify if SBTS is onAir.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${SCF_WITH_FAULT}  ${EMPTY}  # Mandatory path to SCF with wrong RAML schema
${RECOVERY_TIMEOUT}  1200  # Time for SBTS to recovery.


*** Keywords ***
TC__WebEM__Command_Specific_Error_Codes_Verification
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24243
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 14.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24243 - Initial TAT creation
    ...  - 15.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24316 - Refactor WebEM TCs and resources to use KWs from ca_SBTS_general
    ...  - 23.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24351 - Variable changed to argument name
    ...  - 10.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25214 - SCF path was changed

    Set Tags  CA-WebEM  OWNER-cristina.antoci@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS23

    Step1: Change ActCli Parameter To Be true
    Step2: Get Error Code 23 Via ADMIN CLI
    Step3: Get Error Code 24 Via ADMIN CLI
    Step4: Get Error Code 25 Via ADMIN CLI
    Step5: Get Error Code 27 Via ADMIN CLI
    Step6: Change ActCli Parameter To Be false


Step${id}: Change ActCli Parameter To Be ${value}
    Log  \nStep${id}: Change actCli parameter to be ${value}  console=true
    Change ActCli Parameter  ${value}


Step2: Get Error Code 23 Via ADMIN CLI
    Log  \nStep2: Get error code 23 via ADMIN CLI  console=true
    Setup Admin CLI  ${ACTIVE_SW_VERSION}  ${MPLANE_IP}
    ${request}  Catenate  SEPARATOR=  {"requestId":1,"parameters":{"name":"recommission","parameters":{"planObjects":[{"distName":"MRBTS-${BTS_ID}
    ...  /EQM-1/APEQM-1/RMOD-1","operation":"update","parameters":[{"parameterName":"alVoltUnstableThreshold","value":"1111111","operation"
    ...  :"update"}]}],"skipParameterRelationErrors":true,"shouldBeActivated":true}}}
    Log  Sending command via Admin CLI for get error code 23...  console=true
    ${request_status}  ${error_code}  ${request_message}  Admin CLI Send Request  ${request}
    Run Keyword If  ${error_code} == 23
    ...  Log  Command sent with error code: ${error_code}![OK]  console=true
    ...  ELSE
    ...  Fail  Command sent with error code: ${error_code}![NOK]


Step3: Get Error Code 24 Via ADMIN CLI
    Log  \nStep3: Get error code 24 via ADMIN CLI  console=true
    ${request}  Catenate  SEPARATOR=  {"requestId":1,"parameters":{"name":"recommission","parameters":{"planObjects":[{"distName":"MRBTS-${BTS_ID}
    ...  /EQM-1/APEQM-1/RMOD-1","operation":"update","parameters":[{"parameterName":"alVoltUnstableThreshosld","value":"11","operation":
    ...  "update"}]}],"skipParameterRelationErrors":true,"shouldBeActivated":true}}}
    Log  Sending command via Admin CLI for get error code 24...  console=true
    ${request_status}  ${error_code}  ${request_message}  Admin CLI Send Request  ${request}
    Run Keyword If  ${error_code} == 24
    ...  Log  Command sent with error code: ${error_code}![OK]  console=true
    ...  ELSE
    ...  Fail  Command sent with error code: ${error_code}![NOK]


Step4: Get Error Code 25 Via ADMIN CLI
    Log  \nStep4: Get error code 25 via ADMIN CLI  console=true
    ${status_scf}  Run Keyword And Return Status
    ...  Should Not Be Empty  ${SCF_WITH_FAULT}
    Run Keyword If  ${status_scf}
    ...  Log  Path to SCF is provided, test should continue![OK]  console=true
    ...  ELSE
    ...  Fail  Please provide path to SCF![NOK]
    ${request}  Catenate  SEPARATOR=  {"requestId":1,"parameters":{"name":"recommission", "parameters": {"skipParameterRelationErrors":true
    ...  ,"shouldBeActivated": true}}}
    Log  Sending command via Admin CLI for get error code 25...  console=true
    ${request_status}  ${error_code}  ${request_message}  Admin CLI Send Request  ${request}  input_file=${SCF_WITH_FAULT}
    Run Keyword If  ${error_code} == 25
    ...  Log  Command sent with error code: ${error_code}![OK]  console=true
    ...  ELSE
    ...  Fail  Command sent with error code: ${error_code}![NOK]


Step5: Get Error Code 27 Via ADMIN CLI
    Log  \nStep5: Get error code 27 via ADMIN CLI  console=true
    ${nrcell_ids}  Get Ids For All  NRCEL
    ${length}  Get Length  ${nrcell_ids}
    ${nrcell}  Run Keyword If  ${length}>1
    ...  Evaluate  random.choice(${nrcell_ids})  random
    ...  ELSE
    ...  Set Variable  ${nrcell_ids}[0]
    ${nrcell_id}  Fetch From Right  ${nrcell}  NRCELL_R-
    Set Test Variable  ${NRCELL_ID}
    ${request_status_locked}  ${error_code_locked}  Changing Admin Cell State From Locked To Shutting Down Via ADMIN CLI  Locked
    Run Keyword If  '${request_status_locked}' == 'completed' and ${error_code_locked} == 0
    ...  Log  Command sent with status: ${request_status_locked} and error code: ${error_code_locked}  console=true
    ...  ELSE
    ...  Fail  Command sent with status: ${request_status_locked} and error code: ${error_code_locked}
    ${request_status_shutting}  ${error_code_shutting}  Changing Admin Cell State From Locked To Shutting Down Via ADMIN CLI  Shutting Down
    Run Keyword If  ${error_code_shutting} == 27
    ...  Log  Command sent with error code: ${error_code_shutting}![OK]  console=true
    ...  ELSE
    ...  Fail  Command sent with error code: ${error_code_shutting}![NOK]
    ${request_status_unlocked}  ${error_code_unlocked}  Changing Admin Cell State From Locked To Shutting Down Via ADMIN CLI  Unlocked
    Run Keyword If  '${request_status_unlocked}' == 'completed' and ${error_code_unlocked} == 0
    ...  Log  Command sent with status: ${request_status_unlocked} and error code: ${error_code_unlocked}  console=true
    ...  ELSE
    ...  Fail  Command sent with status: ${request_status_unlocked} and error code: ${error_code_unlocked}
    ${status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All Cells
    Run Keyword If  ${status}
    ...  Log  SBTS is OnAir![OK]  console=true
    ...  ELSE
    ...  Fail  Not all cells are Enabled![NOK]


Changing Admin Cell State From Locked To Shutting Down Via ADMIN CLI
    [Arguments]  ${value}

    ${request}  Catenate  SEPARATOR=  {"requestId":1,"parameters":{"name":"recommission","parameters":{"planObjects":[{"distName":"
    ...  MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRCELL-${NRCELL_ID}","operation":"update","parameters":[{"parameterName":"administrativeState",
    ...  "value":"${value}","operation":"update"}]}],"skipParameterRelationErrors":true,"shouldBeActivated":true}}}
    Log  Sending command via Admin CLI for ${value} cell: ${NRCELL_ID} ...  console=true
    ${request_status}  ${error_code}  ${request_message}  Admin CLI Send Request  ${request}

    [Return]  ${request_status}  ${error_code}


TC Setup
    Common Test Setup
    WebEM Setup


TC Teardown
    WebEM Teardown
    Common Test Teardown
