*** Settings ***
Documentation
    ...  This test case gets loglinks via ADMIN CLI.
    ...  Verify all cells on SBTS to be enabled.
    ...  actCli parameter is changed to be true.
    ...  Sending command for getting all loglinks from SBTS via ADMIN CLI.
    ...  Verify for command to be sent with status completed.
    ...  Taking the number of loglinks via ADMIN CLI and infomodel.
    ...  Test will fail if the number of loglinkgs is not equal.
    ...  Taking from every loglink firstEndpointPort and secondEndpointPort via ADMIN CLI and infomodel.
    ...  Test will fail if the ones in the ADMIN CLI list are not found in the infomodel list.
    ...  actCli parameter is changed to be false.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Keywords ***
TC__WebEM__Admin_CLI_Remote_Tool_getLoglinkList
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-23546
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 22.08.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23546 - Initial TAT creation
    ...  - 25.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24131 - Refactor TCs with best practice
    ...  - 15.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24316 - Refactor WebEM TCs and resources to use KWs from ca_SBTS_general

    Set Tags  CA-WebEM  OWNER-nicolae-marcel.caragel@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS22

    Step1: Verify Cells On SBTS
    Step2: Change ActCli Parameter To Be true
    Step3: Get LogLink List Via ADMIN CLI
    Step4: Change ActCli Parameter To Be false


Step1: Verify Cells On SBTS
    Log  Step1: Verify cells on SBTS  console=true
    ${status}  Run Keyword And Return Status
    ...  Check All Cells
    Run Keyword If  ${status}
    ...  Log  SBTS is OnAir![OK]  console=true
    ...  ELSE
    ...  Fail  Not all cells are Enabled![NOK]


Step${id}: Change ActCli Parameter To Be ${value}
    Log  Step${id}: Change actCli parameter to be ${value}  console=true
    Change ActCli Parameter  ${value}


Step3: Get LogLink List Via ADMIN CLI
    Log  Step3: Get LogLink list via ADMIN CLI  console=true
    Setup Admin CLI  ${ACTIVE_SW_VERSION}  ${MPLANE_IP}
    ${request}  Set Variable  {"requestId":1,"parameters":{"name":"getLoglinkList"}}
    Log  \nSending command via Admin CLI for getLoglinkList...  console=true
    ${request_status}  ${error_code}  ${request_message}  Admin CLI Send Request  ${request}
    Run Keyword If  '${request_status}' == 'completed'
    ...  Log  Command sent with status: ${request_status}  console=true
    ...  ELSE
    ...  Fail  Command sent with status: ${request_status} and error code: ${error_code}
    ${loglinks}  Get From Dictionary  ${request_message}  loglinks
    ${loglinks_count_cli}  Get Length  ${loglinks}
    ${first_and_second_cli}  Create List
    FOR  ${index}  IN  @{loglinks}
        Append To List  ${first_and_second_cli}  ${index}[firstEndPointId]
        Append To List  ${first_and_second_cli}  ${index}[secondEndPointId]
    END
    ${loglinks_infomodel}  Query Infomodel  get list //LOGLINK_R-*
    ${loglinks_count_infomodel}  Get Length  ${loglinks_infomodel}
    ${status_loglinks}  Run Keyword And Return Status
    ...  Should Be Equal As Integers  ${loglinks_count_cli}  ${loglinks_count_infomodel}
    Run Keyword If  ${status_loglinks}
    ...  Log  The number of loglinks are the same in ADMIN CLI as in infomodel, ${loglinks_count_cli} loglinks![OK]  console=true
    ...  ELSE
    ...  Fail  The number of loglinks are not the same in ADMIN CLI(${loglinks_count_cli}) as in infomodel(${loglinks_count_infomodel})![NOK]
    ${first_and_second_infomodel}  Create List
    FOR  ${index}  IN  @{loglinks_infomodel}
        ${first_unit}  Fetch From Right  ${index}[firstEndpointDN]  /
        ${unit1}  Fetch From Left  ${first_unit}  _
        ${first_port}  Set Variable  ${index}[firstEndpointPortId]
        ${first_endpoint_port}  Run Keyword If  '${unit1}'=='BBMOD'
        ...  Create Distname  ${first_unit}  RF  ${first_port}
        ...  ELSE IF  '${unit1}'=='SMOD'
        ...  Create Distname  ${first_unit}  EIF  ${first_port}
        ...  ELSE
        ...  Create Distname  ${first_unit}  OPT_IF  ${first_port}
        Append To List  ${first_and_second_infomodel}  ${first_endpoint_port}
        ${second_unit}  Fetch From Right  ${index}[secondEndpointDN]  /
        ${unit2}  Fetch From Left  ${second_unit}  _
        ${second_port}  Set Variable  ${index}[secondEndpointPortId]
        ${second_endpoint_port}  Run Keyword If  '${unit2}'=='RMOD'
        ...  Create Distname  ${second_unit}  OPT_IF  ${second_port}
        ...  ELSE IF  '${unit2}'=='BBMOD'
        ...  Create Distname  ${second_unit}  RF  ${second_port}
        ...  ELSE
        ...  Create Distname  ${second_unit}  EIF  ${second_port}
        Append To List  ${first_and_second_infomodel}  ${second_endpoint_port}
    END
    FOR  ${link}  IN  @{first_and_second_infomodel}
        List Should Contain Value  ${first_and_second_cli}  ${link}
    END
    Log  All links are the same in ADMIN CLI as in infomodel![OK]  console=true


Create Distname
    [Arguments]  ${unit}  ${label}  ${port}

    ${endpoint_port}  Catenate  SEPARATOR=/  ${unit}  ${label}${port}

    [Return]  ${endpoint_port}


TC Setup
    Common Test Setup


TC Teardown
    Common Test Teardown
