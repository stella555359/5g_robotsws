*** Settings ***
Documentation    Suite for Stream 4.6

Library    BuiltIn

Resource    ./st46_tls_test_cases.robot
Resource    ./st46_certificate_test_cases.robot
Resource    ./st46_hardening_test_cases.robot
Resource    resources/robot/dcap_logs_collection.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot

Suite Setup       Suite Setup
Suite Teardown    Suite Teardown

Test Setup        Test Setup
Test Teardown     Test Teardown

*** Test Cases ***
# TLS
[1]Change TLS Mode From Forced To Off
    [Tags]    Change TLS Mode From Forced To Off
    Change TLS Mode From Forced To Off

[1]Change TLS Mode From Off To Forced
    [Tags]    Change TLS Mode From Off To Forced
    Change TLS Mode From Off To Forced

[1]TLS 1.2 Enabling Disabling
    [Tags]    TLS 1.2 Enabling Disabling
    TLS 1.2 Enabling Disabling

[1]TLS 1.3 Enabling Disabling
    [Tags]    TLS 1.3 Enabling Disabling
    TLS 1.3 Enabling Disabling

[1]TLS Connection Using ECDSA Certificates
    [Tags]    TLS Connection Using ECDSA Certificates
    TLS Connection Using ECDSA Certificates

[1]TLS Connection Using RSA Certificates
    [Tags]    TLS Connection Using RSA Certificates
    TLS Connection Using RSA Certificates

[1]TLS1.3 Renegotiations
    [Tags]    TLS1.3 Renegotiations
    TLS1.3 Renegotiations

[1]TLS Authentication With ECDSA
    [Tags]    TLS Authentication With ECDSA
    TLS Authentication With ECDSA

[1]TLS Authentication With RSA
    [Tags]    TLS Authentication With RSA
    TLS Authentication With RSA

[1]TLS 1.2 Cipher Suite
    [Tags]    TLS 1.2 Cipher Suite
    TLS 1.2 Cipher Suite

[1]TLS 1.3 Cipher Suite
    [Tags]    TLS 1.3 Cipher Suite
    TLS 1.3 Cipher Suite

[1]TLS Authentication Check
    [Tags]    TLS Authentication Check
    TLS Authentication Check

[1]TLS Connection Using TLS CRL Check Validation
    [Tags]    TLS Connection Using TLS CRL Check Validation
    TLS Connection Using TLS CRL Check Validation

[1]TLS ECDHE Cipher Support
    [Tags]    TLS ECDHE Cipher Support
    TLS ECDHE Cipher Support

[1]TLS Key Renegotiation
    [Tags]    TLS Key Renegotiation
    TLS Key Renegotiation

[1]TLS Cipher Selection During The TLS
    [Tags]    TLS Cipher Selection During The TLS
    TLS Cipher Selection During The TLS

[1]TLS 1.1 Not Supported
    [Tags]    TLS 1.1 Not Supported
    TLS 1.1 Not Supported

[1]Fallback TLSv1.3 When TLSv1.2 And TLSv1.1 Are Enabled
    [Tags]    Fallback TLSv1.3 When TLSv1.2 And TLSv1.1 Are Enabled
    Fallback TLSv1.3 When TLSv1.2 And TLSv1.1 Are Enabled

[1]Only Accepts TLSv1.3 Connection When Fallback Of TLS 1.2 Is Disabled
    [Tags]    Only Accepts TLSv1.3 Connection When Fallback Of TLS 1.2 Is Disabled
    Only Accepts TLSv1.3 Connection When Fallback Of TLS 1.2 Is Disabled

[1]TLS Diffie Hellman Group Support
    [Tags]    TLS Diffie Hellman Group Support
    TLS Diffie Hellman Group Support

[1]TLS Connection Made By Unauthorized User
    [Tags]    TLS Connection Made By Unauthorized User
    TLS Connection Made By Unauthorized User

[1]Check TLS Version Used
    [Tags]    Check TLS Version Used
    Check TLS Version Used    ${PORTS}    ${MPLANE_IPV4}

[1]Hostname Checking During TLS Connection Establishment
    [Tags]    Hostname Checking During TLS Connection Establishment
    Hostname Checking During TLS Connection Establishment

# Certificate
[1]Vendor Certificate Restore In WebEM
    [Tags]    Vendor Certificate Restore In WebEM
    Vendor Certificate Restore In WebEM

[1]Operator RSA/ECDSA Certificate Initial Enrolment
    [Tags]    Operator RSA/ECDSA Certificate Initial Enrolment
    Operator RSA/ECDSA Certificate Initial Enrolment

[1]Check Certificates RSA/ECDSA Synchronization Between Active/Passive Partition
    [Tags]    Check Certificates RSA/ECDSA Synchronization Between Active/Passive Partition
    Check Certificates RSA/ECDSA Synchronization Between Active/Passive Partition

[1]Certificate RSA/ECDSA Manual Installation Via WebEM
    [Tags]    Certificate RSA/ECDSA Manual Installation Via WebEM
    Certificate RSA/ECDSA Manual Installation Via WebEM

[1]Certificate RSA/ECDSA Manual Remove Via WebEM or NMS
    [Tags]    Certificate RSA/ECDSA Manual Remove Via WebEM or NMS
    Certificate RSA/ECDSA Manual Remove Via WebEM or NMS

[1]Operator Certificate Renewal Via WebEM
    [Tags]    Operator Certificate Renewal Via WebEM
    Operator Certificate Renewal Via WebEM

[1]Triger Clear Operator Certificate RSA/ECDSA
    [Tags]    Triger Clear Operator Certificate RSA/ECDSA
    Triger Clear Operator Certificate RSA/ECDSA

[1]Trigger Upload BTS Trust Chain With ECDSA Certificate With Key Size Less Than 256-bits
    [Tags]    Trigger Upload BTS Trust Chain With ECDSA Certificate With Key Size Less Than 256-bits
    Trigger Upload BTS Trust Chain With ECDSA Certificate With Key Size Less Than 256-bits

[1]Operator RSA/ECDSA Certificate Initial Enrolment CMP init Install WebEM or NMS Failed Due To CRL Check
    [Tags]    Operator RSA/ECDSA Certificate Initial Enrolment CMP init Install WebEM or NMS Failed Due To CRL Check
    Operator RSA/ECDSA Certificate Initial Enrolment CMP init Install WebEM or NMS Failed Due To CRL Check

[1]Crypto Agent Certificates Protection Check
    [Tags]    Crypto Agent Certificates Protection Check
    Crypto Agent Certificates Protection Check

[1]Display BTS Vendor cerificate and trust chain in WebEM
    [Tags]    Display BTS Vendor cerificate and trust chain in WebEM
    Display BTS Vendor cerificate and trust chain in WebEM

[1]CRL update Via LDAP
    [Tags]    CRL update Via LDAP
    CRL update Via LDAP

[1]Certificate Renewal Requests Burst Alarm WebEM
    [Tags]    Certificate Renewal Requests Burst Alarm WebEM
    Certificate Renewal Requests Burst Alarm WebEM

[1]Error Codes While Certificate Upload
    [Tags]    Error Codes While Certificate Upload
    Error Codes While Certificate Upload

[1]CRL Failure Reasons
    [Tags]    CRL Failure Reasons
    CRL Failure Reasons

[1]BTS As Client Authentication With NMS Using ECDSA Operator Certificate
    [Tags]    BTS As Client Authentication With NMS Using ECDSA Operator Certificate
    BTS As Client Authentication With NMS Using ECDSA Operator Certificate

[1]BTS As client Authentication With NMS Using ECDSA Operator Certificate With Too Short Key
    [Tags]    BTS As client Authentication With NMS Using ECDSA Operator Certificate With Too Short Key
    BTS As client Authentication With NMS Using ECDSA Operator Certificate With Too Short Key

[1]BTS as client Authentication With NMS LDAP Using ECDSA Operator Certificate
    [Tags]    BTS as client Authentication With NMS LDAP Using ECDSA Operator Certificate
    BTS as client Authentication With NMS LDAP Using ECDSA Operator Certificate

[1]RSA And Elliptic Curve Certificate Support For TLS
    [Tags]    RSA And Elliptic Curve Certificate Support For TLS
    RSA And Elliptic Curve Certificate Support For TLS

# Hardening
[1]Incorrect Password Update
    [Tags]    Incorrect Password Update
    Incorrect Password Update

[1]Correct Password Update
    [Tags]    Correct Password Update
    Correct Password Update

[1]Incorrect Username Update
    [Tags]    Incorrect Username Update
    Incorrect Username Update

[1]Correct Username Update
    [Tags]    Correct Username Update
    Correct Username Update

[1]Check Files Permissions
    [Tags]    Check Files Permissions
    Check Files Permissions

[1]Check Event Visibility In RUEM Logs
    [Tags]    Check Event Visibility In RUEM Logs
    Check Event Visibility In RUEM Logs

[1]Check Certificates Content
    [Tags]    Check Certificates Content
    Check Certificates Content

[1]Check If Alarm Related To Security Event Is Present
    [Tags]    Check If Alarm Related To Security Event Is Present
    Check If Alarm Related To Security Event Is Present

[1]WebEM Roles Privileges
    [Tags]    WebEM Roles Privileges
    WebEM Roles Privileges

[1]Send Incorrect Traffic And Check If Is Blocked
    [Tags]    Send Incorrect Traffic And Check If Is Blocked
    Send Incorrect Traffic And Check If Is Blocked

[1]Send Correct Traffic And Check If Is Accepted
    [Tags]    Send Correct Traffic And Check If Is Accepted
    Send Correct Traffic And Check If Is Accepted

*** Keywords ***
Suite Setup
    RFRL DCAP Setup
    Create Global Directory For Gathering Logs
    Run Keyword And Continue On Failure    Wait Until BTS Reach Configured Or OnAir State
    [Teardown]        RFRL Collect Suite Logs to Specified Directory DCAP      dir_path=Suite_Setup

Suite Teardown
    Set Suite Variable    ${TEST_NAME}    ${SUITE_NAME}
    [Teardown]    RFRL Collect Suite Logs to Specified Directory DCAP      dir_path=Suite_Teardown

Test Setup
    Set Test Variable       ${TEST_OUTPUT_DIR}          ${OUTPUT_DIR}/${TEST_NAME}
    RFRL Start Collect Test Logs to Specified Directory DCAP

Test Teardown
    RFRL Stop Collect Test Logs to Specified Directory DCAP
    Run Keyword And Ignore Error    interface.Common Step Trigger
