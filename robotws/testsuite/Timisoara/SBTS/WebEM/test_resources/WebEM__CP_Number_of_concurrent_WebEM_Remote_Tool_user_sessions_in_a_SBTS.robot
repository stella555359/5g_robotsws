*** Settings ***
Documentation
    ...  This test case sends 6 commands off unitReset at the same time.
    ...  The BTS/DU shall support 5 concurrent WebEM Remote Tool user sessions without noticeable impact in performance.
    ...  Whend 6'th command is send the limit has been reached and message 'Number of sessions exceeded' appears.


Resource  ../../common_resources/ca_WebEM_general.robot


*** Keywords ***
TC__WebEM__CP_Number_of_concurrent_WebEM_Remote_Tool_user_sessions_in_a_SBTS
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-29866
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  02.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29866 - Initial TAT creation

    Set Tags  CA-WebEM  OWNER-lucian.ivanescu@nokia.com  AUTHOR-cristina.adam@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf  SW-SBTS26  FEATURE-C&P

    Step1: Sending UnitReset Commands
    Step2: Check Outputs From UnitReset Commands


Step1: Sending UnitReset Commands
    Log  \nStep1: Sending CheckHw Commands  console=true
    ${rmods_id}  Get All RMODs Ids
    ${length}  Get Length  ${rmods_id}
    IF  ${length} >= 6
        Log  On Bts there are at least 6 RMODs. The test will continue...  console=true
    ELSE
        Fail  This SBTS doesn't have 6 RMODs, please perform the test on an SBTS with at least 6 RMODs!
    END
    ${PROCESS_LIST}  Create List
    Set Test Variable  ${PROCESS_LIST}
    ${admin_cli_path}  Setup Admin CLI  ${ACTIVE_SW_VERSION}  ${MPLANE_IP}
    FOR  ${index}  IN RANGE  0  6
        ${command}  Catenate  SEPARATOR=  ${admin_cli_path}/admin-cli.sh --bts-username\=Nemuadmin --bts-password\=nemuuser --bts-host\=
        ...  ${MPLANE_IP} --bts-port\=443 --data\='{"requestId":23,"parameters":{"name":"unitReset","parameters":
        ...  {"id":"/MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${rmods_id}[${index}]"}}}'
        ${process}  Start Process  ${command}  shell=True
        Log  The unitReset command for RMOD-${rmods_id}[${index}] is running in background...  console=true
        Append To List  ${PROCESS_LIST}  ${process}
    END


Step2: Check Outputs From UnitReset Commands
    Log  \nStep2: Check Outputs From UnitReset Commands  console=true
    ${request}  Set Variable  ${EMPTY}
    FOR  ${process}  IN  @{PROCESS_LIST}
        ${result}  Wait For Process  ${process}
        ${request}  Catenate  SEPARATOR=${SPACE}  ${request}  ${result.stdout}
    END
    ${status}  Run Keyword And Return Status  Should Contain  ${request}  "requestMessage":"Number of sessions exceeded"
    IF  ${status}
        Log  'Number of sessions exceeded' message request appears![OK]  console=true
    ELSE
        Fail  More than 5 sessions are currently open![NOK]
    END


TC Setup
    Common Test Setup
    WebEM Setup
    Change ActCli Parameter  true


TC Teardown
    Change ActCli Parameter  false
    WebEM Teardown
    Common Test Teardown
