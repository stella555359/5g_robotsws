*** Settings ***
Documentation
    ...  Step.1 Setup CLI connection 443
    ...  This keyword gets the appropriate CLI version and establishes a CLI connection on the port 443
    ...  If there will be problem with get the appropriate CLI version or connection test wil fail (Snapshot is collected)
    ...  otherwise test step pass
    ...
    ...  Step.2 Verify config parameters
    ...  Checks if .yaml file exist and sets test variable CONF_SFP with keys
    ...  eg.[['RMOD_6Q181017420', 'RMOD_F7171524309', 'RMOD_F7171524314', 'SMOD_F7171804635']
    ...  Under those objects they are SFP keys with SFP data to compare versus .json file.
    ...  if there will be lack of .yaml file or data in file test will fail (Snapshot is collected), otherwise test step pass
    ...
    ...  Step.3 Get sfp data file via CLI on Port 433
    ...  Gets sfpData file from BTS via CLI and set this file to test variable CLI_FILE
    ...  Step also verify if output is right json format, and handle output errors code: 140,1,2,3,4,5,6,7,8,9
    ...  if any of above will occour test will fail (Snapshot is collected), otherwise test step pass
    ...
    ...  Step.4 Verify sfp source data
    ...  Loads and compare source sfp data from .json file with static sfp representation in .yaml file
    ...  if are incorrect test fail (Snapshot is collected), otherwise test step pass
    ...
    ...  Step.5 Verify sfp destination data
    ...  Loads and compare destination sfp data from .json file with static sfp representation in .yaml file
    ...  if are incorrect test fail, otherwise test step pass. Snapshot is collected.

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${SFP_R_QUERY}  /SFP_R-*
${SFP_L_QUERY}  /SFP_L-*


*** Keywords ***
TC__BS_SM__RP001906_SFP_speeds_in_Cli_and_Infomodel
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-4062
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...
    ...  - 13.10.2016 - https://jira3.int.net.nokia.com/browse/TAT-17081 - Initial creation
    ...  - 15.05.2020 - https://jira3.int.net.nokia.com/browse/TAT-19485 - CLI file verification changed
    ...  - 09.07.2020 - https://jira3.int.net.nokia.com/browse/TAT-19834 - deleting cli script before test
    ...  - 07.01.2021 - https://jira3.ext.net.nokia.com/browse/TAT-20722 - increase number of retries for CLI setup
    ...  - 11.03.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21025 - btsauto directory creation
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************

    Set Tags  CA-BS-SM  OWNER-robert.susz@nokia.com  AUTHOR-robert.susz@nokia.com  MAINTAINER-vlad.slivilescu@nokia.com  GROUP_IN_CHARGE-TIM_2_Vrf
    ...  PHASE-CRT  SW-SBTS18A  SW-SBTS19  SW-SBTS19A  FEATURE-RP001906

    Precondition
    Step.1 Set Up CLI Connection 443
    Step.2 Get Sfp Data File Via CLI On Port 443 And And Verify Its Content
    Step.3 Get IM SFP Parameters
    Step.4 Verify Sfp source Data
    Step.5 Verify Sfp destination Data


Precondition
    Check If Admin CLI Feature Check Is Enabled  True


Step.${n} Get IM SFP Parameters
    Log  ${\n}======================================  console=true
    Log  ***Step ${n}:Get IM SFP parameters**  console=true
    Log  ${\n}======================================  console=true
    ${sfp_r}  Query Infomodel  query=get list /${SFP_R_QUERY}  allow_negative_result=${TRUE}
    Set Test Variable  ${SFP_R}
    FOR  ${element}  IN  @{SFP_R}
        ${sfp_speed}  Get From Dictionary  ${element}  transmissionRate
        ${sfp_serial}  Get From Dictionary  ${element}  serialNumber
        ${sfp_distname}  Get From Dictionary  ${element}  dist_name
        Log To Console  ${sfp_speed}
        Log To Console  ${sfp_serial}
        Log To Console  ${sfp_distname}
    END


Step.${n} Set Up CLI Connection ${port}
    [Documentation]
    ...  This keyword gets the appropriate CLI version and establishes a CLI
    ...  connection on the port ${port}

    Log  ${\n}======================================  console=true
    Log  ***Step ${n} Setup CLI connection***  console=true
    ${sw_path_split}  Split String  ${ACTIVE_SW_VERSION}  _
    Run  mkdir /home/ute/btsauto
    ${admin_cli_directory}  OperatingSystem.List Directories In Directory  /home/ute/btsauto  *${sw_path_split}[-2]_${sw_path_split}[-1]_ADMIN_CLI
    Run Keyword If  ${admin_cli_directory}
    ...  Run  sudo rm -r /home/ute/btsauto/${admin_cli_directory}[0]
    Wait Until Keyword Succeeds  5x  15s
    ...  Setup Admin CLI  ${ACTIVE_SW_VERSION}  ${MPLANE_IP}  port=${port}
    Log  ${\n}=================PASS=================  console=true


Step.${n} Get Sfp Data File Via CLI On Port ${port} And And Verify Its Content
    [Documentation]  This keyword gets sfpData file from BTS via CLI and set this file to test variable ${cli_file}

    Log  ${\n}======================================  console=true
    Log  ***Step.${n} Get sfp data file via CLI on Port ${port} ***  console=true
    ${cli_message}  Set Variable  { "requestId": 1, "parameters": {"name": "sfpData"}}
    Send Admin CLI Request  ${cli_message}  output_json=${TEST_FILES}/cli_test.txt
    ${cli_file_content}  OperatingSystem.Get File  ${TEST_FILES}/cli_test.txt
    ${cli_file_content}  Last Root JSON Part  ${cli_file_content}
    Set Test Variable  ${CLI_FILE_CONTENT}
    Verify Cli Response Error  ${CLI_FILE_CONTENT}
    Log  ${\n}=================PASS=================  console=true


Step.${n} Verify Sfp ${source_or_destination} Data
    [Documentation]
    ...  This keyword loads and compare sfp data from .json file with static sfp representation in .yaml file
    ...  It accepts as source_or_desination variable [source = SMOD side, destination = RMOD side], dictionary with
    ...  pack of sfp data from .json file

    Log  ${\n}======================================  console=true
    Log  ***Step.${n} Verify sfp ${source_or_destination} data ***  console=true
    ${cli_file_dict}  Evaluate  json.loads('''${CLI_FILE_CONTENT}''')  json
    ${request_message}  Get From Dictionary  ${cli_file_dict}  requestMessage
    @{connected}  Get From Dictionary  ${request_message}  connected
    FOR  ${element}  IN  @{connected}
        Log To Console  ======================================
        ${connector_data}  Get From Dictionary  ${element}  ${source_or_destination}
        ${sfp_cli_derial_number}  Get From Dictionary  ${connector_data['connector']['sfp']}  serialNumber
        ${sfp_cli_trans_rate}  Get From Dictionary  ${connector_data['connector']['sfp']}  transmissionRate
        ${match}  Get Regexp Matches  ${sfp_cli_trans_rate}  ^[-]{0}\\d+[.]\\d+|^[-]\\d+[.]\\d+|^\\d+
        Log To Console  ${sfp_cli_derial_number}
        Log To Console  ${match[0]}
    END
    Log  ${\n}=================PASS=================  console=true


TC Setup
    Common Test Setup


TC Teardown
    Common Test Teardown  collect_snapshot=never
