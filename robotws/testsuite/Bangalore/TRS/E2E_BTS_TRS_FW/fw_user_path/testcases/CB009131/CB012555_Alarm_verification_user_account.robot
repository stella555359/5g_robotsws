*** Settings ***
Documentation     [Procedure]   "CMP_VDU"
...               [QC_Path]   "QC_Path in Test Plan"
...               [QC_ID]     "QC_ID in Test Lab for reporting"
...               [Validation_status]     "Passed"

Library           OperatingSystem
Library           Collections
Library           RequestsLibrary

Resource        ${CURDIR}/resources/common_keywords.robot


Suite Setup		Run Keywords	Suite Setup Preconditions
...		AND		Setup Oamops
Suite Teardown     Run Keywords		Suite Teardown Postconditions
...		AND		Teardown Oamops

*** Variables ***
${ADMIN_USER}         Nemuadmin
${ADMIN_PASS}         Nokia@123
${BTSSEC_USER}        btssec
${BTSSEC_PASS_NEW}    Btsec@123
${BTSAPP_USER}        btsapp
${BTSAPP_PASS_NEW}    Btsapp@123
${BTSREAD_USER}       btsread
${BTSREAD_PASS_NEW}   Btsread@123
${FAULT_ID}           61642
${USERNAME}          toor4nsn
${PASSWORD}          Nokia@123
${WRONG_PASSWORD}    Wrong@PDW
${JUMP_HOST}         10.58.66.35
${JUMP_PORT}         51217
${JUMP_USER}                serviceuser
${SSH_KEY_PATH}             /home/ute/keyvalue
${alarm_id}                 4772


*** Test Cases ***
[1][1.0] CB012555_To_perform_Alarm_Verification_on_cloud_BTS_Based_on_User_Login_Attempts

	Verify Alarm    faultid=61618        rat=sran5g     should_exist=${False}     occurrences=1
	Login BTS As System Admin
	Sleep   65
	Update BTS Security Password
	Sleep   65
	Update BTS Application Password
	Sleep   65
	Update BTS Read-Only Password
	Sleep   2
	Login with Wrong Password
	Sleep   30
	Verify Alarm   faultid=4776     rat=sran5g       should_exist=${True}      occurrences=1
	Wait for 4 minutes
	Login To board
	Sleep   60
	Verify Alarm   faultid=4776     rat=sran5g       should_exist=${False}      occurrences=1

*** Keywords ***
Login BTS As System Admin
    ${payload}=    Create Dictionary    username=${ADMIN_USER}    password=${ADMIN_PASS}
    Should Be Equal As Integers    ${response.status_code}    200
    Log    ? Logged in as ${ADMIN_USER}

Update BTS Security Password
    ${payload}=    Create Dictionary    currentPassword=${ADMIN_PASS}    newPassword=${BTSSEC_PASS_NEW}
    Should Be Equal As Integers    ${response.status_code}    200
    Log    ?? Updated password for ${BTSSEC_USER}

Update BTS Application Password
    ${payload}=    Create Dictionary    currentPassword=${ADMIN_PASS}    newPassword=${BTSAPP_PASS_NEW}
    Should Be Equal As Integers    ${response.status_code}    200
    Log    ?? Updated password for ${BTSAPP_USER}

Update BTS Read-Only Password
    ${payload}=    Create Dictionary    currentPassword=${ADMIN_PASS}    newPassword=${BTSREAD_PASS_NEW}
    Should Be Equal As Integers    ${response.status_code}    200
    Log    ?? Updated password for ${BTSREAD_USER}

Logout From WebEM
    Should Be Equal As Integers    ${response.status_code}    200
    Log    ?? Logged out

Login with Wrong Password
    Log    Attempting login with wrong password...
    Run Process
    ...    sshpass
    ...    -p ${WRONG_PASSWORD}
    ...    ssh
    ...    -J ${JUMP_USER}@${JUMP_HOST}:${JUMP_PORT}
    ...    -i ${SSH_KEY_PATH}
    ...    ${USERNAME}@localhost


Wait for 4 minutes
    Sleep   250

Login To board
    Log    Connecting to RANNIC with correct credentials...
    Run Process
    ...    sshpass
    ...    -p ${PASSWORD}
    ...    ssh
    ...    -J ${JUMP_USER}@${JUMP_HOST}:${JUMP_PORT}
    ...    -i ${SSH_KEY_PATH}
    ...    ${USERNAME}@localhost




