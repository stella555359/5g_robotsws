*** Settings ***

Documentation    Description:  Cloud Library with commonly used keywords

Library    BuiltIn
Library    OperatingSystem
Library    Process
Library    String
Library    Collections
#Library    taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu
#Library    taf.gnb.oam.coam.cu.interface.cu      WITH NAME    cu

Resource    ./common_variables.robot

*** Keywords ***

Suite Precondition
    [Documentation]  Description:           List of precondition actions common for all testing suites${\n}
    ...              Return:                none${\n}
    ...              Output:                {}${\n}
    ...              Author:                x ${\n}
    ...              Maintainer:            x ${\n}
    ...              Last Modification:     23-02-2024 made by szymon.romanowski@nokia.com${\n}
    [Arguments]      ${arg1}=${EMPTY}
    ...              ${arg2}=${EMPTY}

    #Create Suite Logs Directory
    Setup Host Variables
#    Switch Power Outlet Of BTS Radio Units  #TODO: czy konieczne?

Suite Postcondition
    [Documentation]  Description:           List of postcondition actions common for all testing suites${\n}
    ...              Return:                none${\n}
    ...              Output:                {}${\n}
    ...              Author:                x ${\n}
    ...              Maintainer:            x ${\n}
    ...              Last Modification:     xx-xx-xxxx made by xx@nokia.com${\n}
    [Arguments]      ${arg1}=${EMPTY}
    ...              ${arg2}=${EMPTY}

    vDU Collect Snapshot  logs_dir_path=${SUITE_LOGS_DIR_PATH}/general_logs
    vCU Collect Snapshot  logs_dir_path=${SUITE_LOGS_DIR_PATH}/general_logs
    vDU Get Container Logs On All Pods  logs_dir_path=${SUITE_LOGS_DIR_PATH}/general_logs
    vCU Get Container Logs On All Pods  logs_dir_path=${SUITE_LOGS_DIR_PATH}/general_logs

Test Precondition
    [Documentation]  Description:           List of precondition actions common for all test cases${\n}
    ...              Return:                none${\n}
    ...              Output:                {}${\n}
    ...              Author:                x ${\n}
    ...              Maintainer:            x ${\n}
    ...              Last Modification:     xx-xx-xxxx made by xx@nokia.com${\n}
    [Arguments]      ${arg1}=${EMPTY}
    ...              ${arg2}=${EMPTY}

    Start Logging
Test Postcondition
    [Documentation]  Description:           List of postcondition actions common for all test cases${\n}
    ...              Return:                none${\n}
    ...              Output:                {}${\n}
    ...              Author:                x ${\n}
    ...              Maintainer:            x ${\n}
    ...              Last Modification:     xx-xx-xxxx made by xx@nokia.com${\n}
    [Arguments]      ${arg1}=${EMPTY}
    ...              ${arg2}=${EMPTY}

Create Suite Logs Directory
    [Documentation]  Description:           Prepares directory for all suite logs${\n}
    ...              Return:                none${\n}
    ...              Output:                {}${\n}
    ...              Author:                x ${\n}
    ...              Maintainer:            x ${\n}
    ...              Last Modification:     xx-xx-xxxx made by xx@nokia.com${\n}
    [Arguments]      ${arg1}=${EMPTY}
    ...              ${arg2}=${EMPTY}

    ${current_date}=    Get Current Date    exclude_millis=yes
    ${current_date}=    Replace String    ${current_date}    ${SPACE}    _
    ${current_date}=    Replace String    ${current_date}    :    -
    ${current_suite_name}=    Replace String    ${SUITENAME}    ${SPACE}    _
    ${SUITE_LOGS_DIR_PATH}=    Set Suite Variable    ${OUTPUT_DIR}/${current_suite_name}_${current_date}/

    [Return]    ${SUITE_LOGS_DIR_PATH}

Create Test Logs Directory
    [Documentation]  Description:           Get test logs directory from given logs directory path${\n}
    ...              Return:                Logs directory to specified test: i.e. /home/ute/MN/UTE/robotws/date_+_suite_name/test_name${\n}
    ...              Output:                { ${string} }${\n}
    ...              Author:                x@nokia.com${\n}
    ...              Maintainer:            x${\n}
    ...              Last Modification:     xx-xx-xxxx made by xx@nokia.com${\n}
    [Arguments]      ${suite_logs_path}       # path to suite logs

    ${test_name}=    Replace String    ${TESTNAME}    ${SPACE}    _
    ${test_logs_dir_path}=    Normalize Path    ${suite_logs_path}${TESTNAME}/
    ${TEST_LOGS_DIR_PATH}=    Set Test Variable    ${test_logs_dir_path}

    [Return]    ${TEST_LOGS_DIR_PATH}

Setup Host Variables
    [Documentation]  Description:           Keyword sets test suite global variables ${\n}
    ...              Return:                None ${\n}
    ...              Output:                None ${\n}
    ...              Author:                szymon.romanowski@nokia.com ${\n}
    ...              Maintainer:            szymon.romanowski@nokia.com ${\n}
    ...              Last Modification:     23-02-2024 made by szymon.romanowski@nokia.com ${\n}

    ${host_parameters}=  Get Host Parameters From Init File
    Set Suite Variable  ${UTE_SSH_IP}  ${host_parameters['ip_addr']}
    Set Suite Variable  ${UTE_SSH_USER_NAME}  ${host_parameters['username']}
    Set Suite Variable  ${UTE_SSH_PASSWORD}  ${host_parameters['password']}

Get Host Parameters From Init File
    [Documentation]  Description:           Get host parameters from TL configuration init file ${\n}
    ...              Return:                Dictionary with host parameters ${\n}
    ...              Output:                { 'ip_addr': ${ip_addr} , 'username': ${username} , 'password': ${password} } ${\n}
    ...              Author:                szymon.romanowski@nokia.com ${\n}
    ...              Maintainer:            szymon.romanowski@nokia.com ${\n}
    ...              Last Modification:     23-02-2024 made by szymon.romanowski@nokia.com ${\n}

    ${ip_addr}=  Set Variable  ${tl.test_pc.default_ssh_connection_details.addr}
    ${username}=  Set Variable  ${tl.test_pc.default_ssh_connection_details.username}
    ${password}=  Set Variable  ${tl.test_pc.default_ssh_connection_details.password}
    ${host_parameters}=  Create Dictionary
    ...  ip_addr=${ip_addr}  username=${username}  password=${password}
    [Return]  ${host_parameters}

Disconnect Interactive Connection
    [Documentation]  Description:           Keyword disconnects ssh connection ${\n}
    ...              Return:                None ${\n}
    ...              Output:                None ${\n}
    ...              Author:                szymon.romanowski@nokia.com ${\n}
    ...              Maintainer:            szymon.romanowski@nokia.com ${\n}
    ...              Last Modification:     26-02-2024 made by szymon.romanowski@nokia.com ${\n}
    [Arguments]  ${alias}=default

    Should Not Be Empty  ${alias}
    issh.disconnect  alias=${alias}
