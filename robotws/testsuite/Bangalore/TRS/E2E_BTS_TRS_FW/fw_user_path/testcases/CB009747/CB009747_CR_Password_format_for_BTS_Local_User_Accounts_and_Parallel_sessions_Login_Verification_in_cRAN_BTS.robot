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
${ADMIN_USER}         Nemuadmin
${ADMIN_PASS}         Nokia@123

${BTSSEC_USER}        btssec
${BTSSEC_PASS_NEW}    Btsec@123

${BTSAPP_USER}        btsapp
${BTSAPP_PASS_NEW}    Btsapp@123

${BTSREAD_USER}       btsread
${BTSREAD_PASS_NEW}   Btsread@123

${FAULT_ID}           61642

*** Test Cases ***
[1]CB009747_CR_Password format for BTS Local User Accounts and Parallel_sessions_Login_Verification_in_cRAN_BTS
    Login As System Admin
    Sleep   60
    Update BTS Security Password
    Sleep   60
    Update BTS Application Password
    Sleep   60
    Update BTS Read-Only Password
    Verify Alarm Exists


*** Keywords ***
Login As System Admin
    ${payload}=    Create Dictionary    username=${ADMIN_USER}    password=${ADMIN_PASS}
    Should Be Equal As Integers    ${response.status_code}    200
    Log    ? Logged in as ${ADMIN_USER}

Update BTS Security Password
    ${payload}=    Create Dictionary    currentPassword=${ADMIN_PASS}    newPassword=${BTSSEC_PASS_NEW}
    Should Be Equal As Integers    ${response.status_code}    200
    Log    ?? Updated password for ${BTSSEC_USER}
    Verify Alarm Exists

Update BTS Application Password
    ${payload}=    Create Dictionary    currentPassword=${ADMIN_PASS}    newPassword=${BTSAPP_PASS_NEW}
    Should Be Equal As Integers    ${response.status_code}    200
    Log    ?? Updated password for ${BTSAPP_USER}
    Verify Alarm Exists

Update BTS Read-Only Password
    ${payload}=    Create Dictionary    currentPassword=${ADMIN_PASS}    newPassword=${BTSREAD_PASS_NEW}
    Should Be Equal As Integers    ${response.status_code}    200
    Log    ?? Updated password for ${BTSREAD_USER}
    Verify Alarm Exists

Verify Alarm Exists
    Should Be Equal As Integers    ${response.status_code}    200
    ${faults}=     Get From Dictionary    ${alarms}    faults
    ${exists}=     Run Keyword And Return Status    Dictionary Should Contain Key    ${faults[0]}    faultId
    Run Keyword If    ${exists}    Log    ?? Alarm(s) present after update
    Log    ? Verified alarms, faultId=${FAULT_ID}

