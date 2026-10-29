*** Settings ***
Documentation
...    Author: Raluca Ciobanu / Adrian Cretu (raluca.ciobanu@nokia.com/adrian.1.cretu@nokia.com)
...    Maintainer: Raluca Ciobanu / Adrian Cretu (raluca.ciobanu@nokia.com/adrian.1.cretu@nokia.com)
...    RF diagnostic and RF statistics diagnostic tests. All cells shoud be up for this test.

Library    SeleniumLibrary
Library    OperatingSystem
Library    SSHLibrary
Library    String
Library    Collections
Test Setup      Login WebEM
Test Teardown   Sign Out

Resource    ./resources/6992-D.robot
Resource    ./resources/xpath_6992-D.robot

*** Test Cases ***
Test cases precheck
    Check status of radio or cells    rs    ${RMOD_COUNT}      ${VIEW}    RMOD-
    Check status of radio or cells    cs    ${NRCELL_COUNT}    ${VIEW}    NRCELL-

[1]2. RF diagnostic test can run from WebEM
    Delete Test Results    RF Diagnostic Test Results               RFREQ        rfReqId
    Start Test    ${RFDiagDropdown}     All NR cells    Start RF Diagnostic Test           RFREQ        rfReqId
    Check results    RF Diagnostic Test Results    success    pass    timeout   failed

[1]3. RF diagnostic test can run from WebEM with measurements outside thresholds
    Delete Test Results    RF Diagnostic Test Results               RFREQ        rfReqId
    M2M get token
    M2M RF Diagnostic   -100
    Sleep    60s
    Check results    RF Diagnostic Test Results    success    failed    timeout   pass

[1]4. RF diagnostic test results can be saved to local PC
    M2M get token
    M2M RF Diagnostic   -180
    Sleep    60s
    Save Test Results    RF Diagnostic Test Results    Save Cell Results    RFDiagnosticTest
    Save Test Results    RF Diagnostic Test Results    Save All Results     RFDiagnosticTest

[1]5. RF diagnostic test results can be deleted by operator
    Delete Test Results    RF Diagnostic Test Results               RFREQ        rfReqId

[1]6. Robustness_Run RF diagnostic and disconnect RU
    M2M get token
    M2M RF Diagnostic   -180
    Stop Start FHGW port    shutdown        Ethernet3
    Sleep    300s
    Start Test    ${RFDiagDropdown}     All NR cells    Start RF Diagnostic Test           RFREQ        rfReqId
    Stop Start FHGW port    startup     Ethernet3
    Sleep    300s

[1]7. ROBUSTNESS_Run RF diagnostic with one locked cell
    Get cell or radio ID    cs    NRCELL-
    M2M get token
    M2M lock unlock cell    block
    Delete Test Results    RF Diagnostic Test Results               RFREQ        rfReqId
    Start Test    ${RFDiagDropdown}     All NR cells    Start RF Diagnostic Test           RFREQ        rfReqId
    Check results    RF Diagnostic Test Results    success    pass    timeout   failed
    M2M lock unlock cell    unblock

[1]8. ROBUSTNESS_Run RF diagnostic with one locked RU
    Get cell or radio ID    rs    RMOD-
    M2M get token
    M2M lock unlock radio    locks
    Delete Test Results    RF Diagnostic Test Results               RFREQ        rfReqId
    Start Test    ${RFDiagDropdown}     All NR cells    Start RF Diagnostic Test           RFREQ        rfReqId
    Check results    RF Diagnostic Test Results    success    pass    timeout   failed
    M2M lock unlock radio    unlocks

[1]9. RF statistic diagnostic test can run from WebEM
    Delete Test Results    RF Statistics Diagnostic Test Results    RFSTATREQ    rfStatReqId
    Start Test    ${RFStatDropdown}     All radios      Start Statistics Diagnostic Test    RFSTATREQ    rfStatReqId
    Check results    RF Statistics Diagnostic Test Results    success    pass   timeout   failed

[1]10. RF statistic diagnostic test can run from WebEM with measurements outside thresholds
    Delete Test Results    RF Statistics Diagnostic Test Results    RFSTATREQ    rfStatReqId
    M2M get token
    M2M RF Statistics Diagnostic   50
    Sleep    60s
    Check results    RF Statistics Diagnostic Test Results    success    failed   timeout   pass

[1]11. RF statistic diagnostic test results can be saved to local PC
    Save Test Results    RF Statistics Diagnostic Test Results    Save Radio Results   RFStatisticsDiagnosticTest
    Save Test Results    RF Statistics Diagnostic Test Results    Save All Results      RFStatisticsDiagnosticTest

[1]12. RF statistic diagnostic test results can be deleted by operator
    Delete Test Results    RF Statistics Diagnostic Test Results    RFSTATREQ    rfStatReqId

[1]13. RF diagnostic_RF statistic diagnostic fail scenarios
    Buttons disabled without selection    Start RF Diagnostic Test
    Buttons disabled without selection    Start Statistics Diagnostic Test
    RF Diagnostic while saving thresholds
    RF Diagnostic while RF Diagnostic ongoing
    RF Diagnostic while Statistics Diagnostic ongoing
    RF Diagnostic while all readios reset
    Saving thresholds with value out of range
    RF Diagnostic while clearing results
    RF Diagnostic flag is set to false

[1]17. RFTHLD MO can be created and RF Diagnostic Test parameters in vDU can be modified via M2M interface
    M2M get token
    M2M RF Diagnostic   -180
    Sleep    60s

[1]18. RF Statistic Diagnostic test can run from M2M interface
    M2M get token
    M2M RF Statistics Diagnostic   90
    Sleep    60s
