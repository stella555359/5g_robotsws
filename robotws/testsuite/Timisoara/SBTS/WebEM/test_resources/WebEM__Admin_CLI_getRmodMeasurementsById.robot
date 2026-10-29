*** Settings ***
Documentation
    ...  This test case gets temperature for all RMODs via ADMIN CLI.
    ...  Verify all cells on SBTS to be enabled.
    ...  actCli parameter is changed to be true.
    ...  Taking ids from all RMODs.
    ...  Verify for command to be sent with status completed.
    ...  Taking temperature value for all RMODs.
    ...  If at least one value is N/A or -, the test will be failed.
    ...  actCli parameter is changed to be false.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Keywords ***
TC__WebEM__Admin_CLI_getRmodMeasurementsById
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-21621
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 20.07.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-21621 - Initial TAT creation
    ...  - 10.05.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23095 - Improve test for CIT
    ...  - 25.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24131 - Refactor TCs with best practice
    ...  - 15.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24316 - Refactor WebEM TCs and resources to use KWs from ca_SBTS_general
    ...  - 03.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30273 - Fix rmod distname

    Set Tags  CA-WebEM  OWNER-nicolae-marcel.caragel@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS22

    Step1: Verify Cells On SBTS
    Step2: Change ActCli Parameter To Be true
    Step3: Get Rmod Measurements Via ADMIN CLI
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


Step3: Get Rmod Measurements Via ADMIN CLI
    Log  Step3: Get rmod measurements via ADMIN CLI  console=true
    ${all_rmods_partial_distname}  Create List
    ${rmods_ids}  Get Ids For All  RMOD
    FOR  ${index}  IN  @{rmods_ids}
        ${distname}  Fetch From Right  ${index}  /EQM_R-
        Append To List  ${all_rmods_partial_distname}  ${distname}
    END
    Setup Admin CLI  ${ACTIVE_SW_VERSION}  ${MPLANE_IP}
    FOR  ${dn}  IN  @{all_rmods_partial_distname}
        ${request}  Set Variable
        ...  {"requestId":1,"parameters":{"name":"getRmodMeasurementsById","parameters":{"id":"/MRBTS-${BTS_ID}/EQM_R-${dn}"}}}
        Log  \nSending command via Admin CLI for getRmodMeasurementsById...  console=true
        ${request_status}  ${error_code}  ${request_message}  Admin CLI Send Request  ${request}
        Run Keyword If  '${request_status}' == 'completed'
        ...  Log  Command sent with status: ${request_status}  console=true
        ...  ELSE
        ...  Fail  Command sent with status: ${request_status} and error code: ${error_code}
        ${temp}  Get From Dictionary  ${request_message}  temp
        ${values}  Get All Values From Dictionary  ${temp}
        ${status_n/a}  Run Keyword And Return Status
        ...  List Should Not Contain Value  ${values}  N/A
        ${status}  Run Keyword And Return Status
        ...  List Should Not Contain Value  ${values}  -
        ${id}  Fetch From Right  ${dn}  RMOD_R-
        Log  Temperature values list for RMOD-${id}: ${values}  console=true
        Run Keyword If  ${status_n/a} and ${status}
        ...  Log  All temperature values for RMOD-${id} are OK![OK]  console=true
        ...  ELSE
        ...  Fail  Not all temperature values for RMOD-${id} are OK, a value/values is/are 'N/A' or '-'![NOK]
    END


Get All Values From Dictionary
    [Arguments]  ${temp}

    ${values}  Create List
    FOR  ${index}  IN  @{temp}
        Append To List  ${values}  ${index}[value]
    END

    [Return]  ${values}


TC Setup
    Common Test Setup


TC Teardown
    Common Test Teardown
