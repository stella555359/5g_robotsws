*** Settings ***
Documentation
    ...  This TC execute command with DCC account.
    ...  Change parameter actCli to be true.
    ...  Change parameter actDccSupport to be true.
    ...  Check softwareUpdate command via ADMIN CLI to be send with error code 0.
    ...  Verify if software was changed.
    ...  Change parameter actCli to be false.
    ...  Change parameter actDccSupport to be false.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${PATH_TO_SW}  /media/BuildShareTimi01/SBTS/Trunk/TA_WebEM/  # Mandatory! Path to needed software
${RECOVERY_TIMEOUT}  1200  # Time for SBTS to recovery.


*** Keywords ***
TC__WebEM__CLI_shall_support_command_softwareUpdate_with_DCC_user
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24478
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 31.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24478 - Initial TAT creation
    ...  - 23.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26297 - Improve test

    Set Tags  CA-WebEM  OWNER-cristina.antoci@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS23  FEATURE-CB006577

    Step1: Change ActCli And ActDccSupport To Be true
    Step2: Sending SoftwareUpdate Command Via ADMIN CLI
    Step3: Change ActCli And ActDccSupport To Be false


Step${index}: Change ActCli And ActDccSupport To Be ${value}
    Log  \nStep${index}: Change actCli and actDccSupport to be ${value}  console=true
    Change ActCli Parameter  ${value}
    ${status}  Run Keyword And Return Status
    ...  Perform Parameter Recommissioning  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...  actDccSupport
    ...  update
    ...  ${value}
    ...  skip_parameter_relation_errors=true
    Run Keyword If  ${status}
    ...  Log  Parameter actDccSupport is set to ${value}![OK]  console=true
    ...  ELSE
    ...  Fail  Parameter actDccSupport is not set to ${value}![NOK]


Step2: Sending SoftwareUpdate Command Via ADMIN CLI
    Log  \nStep2: Sending softwareUpdate command via ADMIN CLI  console=true
    ${software_list}  OperatingSystem.List Directory  ${PATH_TO_SW}
    ${software}  Get From List  ${software_list}  -1
    Log  SW is ${software}!  console=true
    Setup Admin CLI  ${ACTIVE_SW_VERSION}  ${MPLANE_IP}  dcuser  nE&e3Q*ptK8  9020
    ${request}  Set Variable  {"requestId":1,"parameters":{"name":"softwareUpdate","parameters":{"shouldActivate":true,"shouldResetRadios":true}}}
    Log  \nSending command via Admin CLI for softwareUpdate in data collection user...  console=true
    ${request_status}  ${error_code}  ${request_message}  Admin CLI Send Request  ${request}  input_file=${PATH_TO_SW}${software}
    Run Keyword If  '${request_status}' == 'completed' and ${error_code} == 0
    ...  Log  Command softwareUpdate sent with status: ${request_status} and error code: ${error_code}  console=true
    ...  ELSE
    ...  Fail  Command softwareUpdate sent with status: ${request_status} and error code: ${error_code}
    Sleep  120s  Time for reset to be performed!
    Log  Wait for all cells to be onAir!  console=true
    ${status_cells}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All Cells
    Run Keyword If  ${status_cells}
    ...  Log  All cells are onAir!  console=true
    ...  ELSE
    ...  Fail  Cells are different than expected![NOK]
    ${software_info}  Get Software Info
    Run Keyword If  '${ACTIVE_SW_VERSION}' != '${software_info['Active SW version']}'
    ...  Log  Software update has been completed!  console=true
    ...  ELSE
    ...  Fail  Software update hasn't been completed![NOK]


TC Setup
    Common Test Setup


TC Teardown
    Common Test Teardown
