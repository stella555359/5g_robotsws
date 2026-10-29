*** Settings ***
Documentation
    ...  This test case gets SW versions via ADMIN CLI.
    ...  actCli parameter is changed to be true.
    ...  Check getSwVersionStatus command via ADMIN CLI to be send with error code 0.
    ...  Check btsId, btsName, activeSoftwareVersion and passiveSoftwareVersion.
    ...  actCli parameter is changed to be false.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Keywords ***
TC__WebEM__Admin_CLI_getSwVersionStatus
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26242
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 24.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26242 - Initial TAT creation

    Set Tags  CA-WebEM  OWNER-mihnea.spineanu@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS24  FEATURE-CB010545

    Step1: Sending GetSwVersionStatus Command Via ADMIN CLI
    Step2: Check Output From GetSwVersionStatus Command


Step1: Sending GetSwVersionStatus Command Via ADMIN CLI
    Log  \nStep1: Sending getSwVersionStatus command via ADMIN CLI  console=true
    Setup Admin CLI  ${ACTIVE_SW_VERSION}  ${MPLANE_IP}
    Log  \nSending command via Admin CLI for getSwVersionStatus...  console=true
    ${request_status}  ${error_code}  ${request_message}  Admin CLI Send Request  {"requestId":1,"parameters":{"name":"getSwVersionStatus"}}
    Run Keyword If  '${request_status}' == 'completed' and ${error_code} == 0
    ...  Log  Command sent with status: ${request_status} and error code: ${error_code}![OK]  console=true
    ...  ELSE
    ...  Fail  Command sent with status: ${request_status} and error code: ${error_code}![NOK]
    ${bts_id_cli}  Get From Dictionary  ${request_message}  btsId
    Log  BTS id from cli response is ${bts_id_cli}!  console=true
    ${bts_name_cli}  Get From Dictionary  ${request_message}  btsName
    Log  BTS name from cli response is ${bts_name_cli}!  console=true
    ${active_version_cli}  Get From Dictionary  ${request_message}  activeSoftwareVersion
    Log  Active SW from cli response is ${active_version_cli}!  console=true
    ${passive_version_cli}  Get From Dictionary  ${request_message}  passiveSoftwareVersion
    Log  Passive SW from cli response is ${passive_version_cli}!  console=true
    Set Test Variable  ${ACTIVE_VERSION_CLI}
    Set Test Variable  ${PASSIVE_VERSION_CLI}
    Set Test Variable  ${BTS_ID_CLI}
    Set Test Variable  ${BTS_NAME_CLI}


Step2: Check Output From GetSwVersionStatus Command
    Log  \nStep2: Check output from getSwVersionStatus command  console=true
    ${bts_name}  Get Bts Name
    Run Keyword If  '${BTS_ID}' == '${BTS_ID_CLI}' and '${bts_name}' == '${BTS_NAME_CLI}'
    ...  Log  BTS id and name from WebEM are the same as in cli response![OK]  console=true
    ...  ELSE
    ...  Fail  BTS id and name from WebEM are not the same as in cli response![NOK]
    Run Keyword If  '${ACTIVE_SW_VERSION}' == '${ACTIVE_VERSION_CLI}' and '${PASSIVE_SW_VERSION}' == '${PASSIVE_VERSION_CLI}'
    ...  Log  Active and passive SW versions from WebEM are the same as in cli response![OK]  console=true
    ...  ELSE
    ...  Fail  Active and passive SW versions from WebEM are not the same as in cli response![NOK]


TC Setup
    Common Test Setup
    Change ActCli Parameter  true


TC Teardown
    Change ActCli Parameter  false
    Common Test Teardown
