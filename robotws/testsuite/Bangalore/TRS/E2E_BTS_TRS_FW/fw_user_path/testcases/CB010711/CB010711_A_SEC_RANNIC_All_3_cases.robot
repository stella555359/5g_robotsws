*** Settings ***
Documentation     [Procedure]   "CMP_VDU"
...               [QC_Path]   "QC_Path in Test Plan"
...               [QC_ID]     "QC_ID in Test Lab for reporting"
...               [Validation_status]     "Passed"

Library           OperatingSystem
Library           Collections

Resource          ../resources/common_keywords.robot

Suite Setup       Setup Oamops    dut=vdu_10424
Suite Teardown    Teardown Oamops    dut=vdu_10424

*** Variables ***
${RANNIC_JUMP_HOST}         10.58.66.35
${RANNIC_JUMP_PORT}         51217
${RANNIC_USERNAME}          toor4nsn
${RANNIC_PASSWORD}          Nokia@123
${RANNIC_WRONG_PASSWORD}    Wrong@PDW
${JUMP_USER}                serviceuser
${SSH_KEY_PATH}             /home/ute/keyvalue
${alarm_id}                 4772

*** Test Cases ***
[1][1.0] CB010711_A__01_SEC_RANNIC_event_log_activity_ssh_user

    Perform Commissioning    dut=vdu_10424     scf_file=${vdu_base_scf}    skip_parameter_relation_errors=${True}    timeout=300
    Sleep   200

    Login To RANNIC
    Sleep   60

    Logout From RANNIC
    Sleep   30

    Login To RANNIC With Wrong Password
    Sleep   30


[1][1.0] CB010711_A__02_SEC_RANNIC_event_log_configuration_change
    [Documentation]    Validates RANNIC security log on successful and failed login and file modification
    Login To RANNIC
    Sleep   60

    View Security File
    Sleep   30

    Write Into The Security File
    Sleep   30

    Login To RANNIC With Wrong Password
    Sleep   30


[1][1.0] CB010711_A__03_SEC_RANNIC_ssh_user_authentication_limit

    Login To RANNIC
    Sleep   60

    Login To RANNIC With Wrong Password
    Sleep   30

    Login To RANNIC With Wrong Password
    Sleep   30

    Login To RANNIC With Wrong Password
    Sleep   30

    Login To RANNIC With Wrong Password
    Sleep   30
    Verify Alarm    faultid=4776    rat=sran5g      should_exist=${True}    occurrences=1

    Wait for 4 minutes
    Verify Alarm    faultid=4776    rat=sran5g      should_exist=${False}    occurrences=1

    Login To RANNIC
    Sleep   60

    Verify Alarm      faultid=4776      occurrences=1       should_exist=${False}      alarm_type=active
    sleep   10

    Login To RANNIC

***keywords ***

Login To RANNIC
    Log    Connecting to RANNIC with correct credentials...
    Run Process
    ...    sshpass
    ...    -p ${RANNIC_PASSWORD}
    ...    ssh
    ...    -J ${JUMP_USER}@${RANNIC_JUMP_HOST}:${RANNIC_JUMP_PORT}
    ...    -i ${SSH_KEY_PATH}
    ...    ${RANNIC_USERNAME}@localhost

Login To RANNIC With Wrong Password
    Log    Attempting login with wrong password...
    Run Process
    ...    sshpass
    ...    -p ${RANNIC_WRONG_PASSWORD}
    ...    ssh
    ...    -J ${JUMP_USER}@${RANNIC_JUMP_HOST}:${RANNIC_JUMP_PORT}
    ...    -i ${SSH_KEY_PATH}
    ...    ${RANNIC_USERNAME}@localhost

Logout From RANNIC
    Log    Logging out from RANNIC...
    Run Process
    ...    sshpass
    ...    -p ${RANNIC_PASSWORD}
    ...    ssh
    ...    -J ${JUMP_USER}@${RANNIC_JUMP_HOST}:${RANNIC_JUMP_PORT}
    ...    -i ${SSH_KEY_PATH}
    ...    ${RANNIC_USERNAME}@localhost
    ...    exit
    ...    shell=True

View Security File
    Log    Viewing /etc/passwd
    Run Process    cat    /etc/passwd    shell=True

Write Into The Security File
    Log    Writing to /etc/passwd
    Run Process
    ...    bash
    ...    -c
    ...    echo "OverWritten" | sudo tee -a /etc/passwd

Wait for 4 minutes
    Sleep   240
