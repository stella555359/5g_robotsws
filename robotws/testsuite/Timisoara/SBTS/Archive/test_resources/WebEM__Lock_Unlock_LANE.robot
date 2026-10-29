*** Settings ***
Resource    ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${RECOVERY_TIMEOUT}    1200  #Time for SBTS to recover
${SCF_with_LANE}             #Mandatory path to SCF with LANE


*** Keywords ***
TC__WebEM__Lock_Unlock_LANE
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24238
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This test case is transferred from BOAM_ET to ST_OAM_WebEM.
    ...  This test lock and unlock LANE via ADMIN CLI.
    ...  SCF with LANE is upload.
    ...  actCli parameter is changed to be true.
    ...  actInternalTrace is cheanged to be true
    ...  Lock LANE command via ADMIN CLI is performed.
    ...  Verify for command to be sent with status completed and error code 0.
    ...  Verify the LANE to be locked.
    ...  Unlock LANE command via ADMIN CLI is performed.
    ...  Verify for command to be sent with status completed and error code 0.
    ...  Verify the LANE to be unlocked.
    ...  Verify all cells to be onAir.
    ...  Restore initial configuration.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 16.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24238 - Initial TAT creation
    ...  - 10.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25214 - SCF path was changed

    Set Tags    CA-WebEM    OWNER-cristina.antoci@nokia.com     AUTHOR-andreea.burtic@nokia.com
    ...    MAINTAINER-andreea.burtic@nokia.com    GROUP_IN_CHARGE-TIM_3_Vrf    PHASE-CRT    SW-SBTS23

    Step0: Upload SCF
    Step1: Change actCli parameter to be true
    Step2: Lock LANE via ADMIN CLI
    Step3: Unlock LANE via ADMIN CLI
    Step4: Change actCli parameter to be false
    Step5: Restore configuration


Step0: Upload SCF
    Log  \nStep0: Upload SCF  console=true
    ${status_scf}  Run Keyword And Return Status  Should Not Be Empty  ${SCF_with_LANE}
    Run keyword if  ${status_scf}
    ...  Log  Path to SCF is provided, test should continue![OK]  console=true
    ...  ELSE
    ...  Fail  Please provide path to SCF![NOK]
    ${status}  Run Keyword and Return Status  Admin Get bts_id and perform commissioning  ${SCF_with_LANE}
    Run keyword unless  ${status}  run keywords
    ...  Fail  Loading Scf with LANE is failed.[NOK]
    ...  AND
    ...  Return from keyword
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10  Check All Cells  ${OnAirDone_}  ${Enabled_}  ${Active_}

Step${id}: Change actCli parameter to be ${value}
    Log  \nStep${id}: Change actCli parameter to be ${value}  console=true
    Change actCli parameter  ${value}
    ${BTS_ID}  Admin Get BTS Id
    Set test variable  ${BTS_ID}

Step2: Lock LANE via ADMIN CLI
    Log  \nStep2: Lock LANE via ADMIN CLI  console=true
    ${status}  Run keyword and return status  Perform Parameter Recommissioning
    ...  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1  actInternalTrace  update  true  skip_parameter_relation_errors=True
    Run keyword if  ${status}
    ...  Log  Parameter actInternalTrace is set to true![OK]  console=true
    ...  ELSE
    ...  Fail  Parameter actInternalTrace is not set to true![NOK]
    Setup Admin CLI  ${active SW version}  ${MPLANE_IP}  ${ADMIN_CLI_KEY}
    ${request}  Catenate  SEPARATOR=  {"requestId":1,"parameters":{"name":"lock","parameters":{"distNames":
    ...  ["MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-1/SFP-1/LANE-1"]}}}
    Log  Sending command via Admin CLI for locking LANE...  console=true
    ${requestStatus}  ${errorCode}  ${requestMessage}  Admin CLI Send Request  ${request}
    Run Keyword If  '${requestStatus}' == 'completed' and ${errorCode} == 0
    ...  Log  Command sent with status: ${requestStatus} and error code: ${errorCode}  console=true
    ...  ELSE
    ...  Fail  Command sent with status: ${requestStatus} and error code: ${errorCode}
    ${DIST_NAME}  Catenate  SEPARATOR=  /MRBTS-1/RAT-1/BTS_L-1/BTS_CONF-1/NP-*/SCF-1/MRBTS_A-${BTS_ID}/EQM_A-1
    ...  /APEQM_A-1/CABINET_A-1/BBMOD_A-1/SFP_A-1/LANE_A-1
    Set Test Variable  ${DIST_NAME}
    Query Infomodel    query=every ${DIST_NAME} is [administrativeState=${Locked_}]  timeout=60

Step3: Unlock LANE via ADMIN CLI
    Log  \nStep3: Unlock LANE via ADMIN CLI  console=true
    ${request}  Catenate  SEPARATOR=  {"requestId":2,"parameters":{"name":"unlock","parameters":{"distNames":
    ...  ["MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-1/SFP-1/LANE-1"]}}}
    Log  Sending command via Admin CLI for unlocking LANE...  console=true
    ${requestStatus}  ${errorCode}  ${requestMessage}  Admin CLI Send Request  ${request}
    Run Keyword If  '${requestStatus}' == 'completed' and ${errorCode} == 0
    ...  Log  Command sent with status: ${requestStatus} and error code: ${errorCode}  console=true
    ...  ELSE
    ...  Fail  Command sent with status: ${requestStatus} and error code: ${errorCode}
    Query Infomodel    query=every ${DIST_NAME} is [administrativeState=${Unlocked_}]  timeout=60
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10  Check All Cells  ${OnAirDone_}  ${Enabled_}  ${Active_}

Step5: Restore configuration
    Log  \nStep5: Restore configuration  console=true
    Admin Get bts_id and perform commissioning  ${COMMISSIONING_PATH}
    ${cells_status}  Run keyword and return status  Wait until keyword succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All Cells  ${OnAirDone_}  ${Enabled_}  ${Active_}
    Run keyword if  ${cells_status}
    ...  Log  All cells are onAir![OK]  console=true
    ...  ELSE
    ...  Fail  Not all cells are onAir![NOK]


TC Setup
    Common test setup

TC Teardown
    Run keyword if test failed  Step5: Restore configuration
    Common test teardown


