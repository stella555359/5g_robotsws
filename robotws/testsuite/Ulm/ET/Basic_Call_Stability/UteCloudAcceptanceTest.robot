*** Settings ***
Documentation
...    author: Ulm SQD 65
...    Team: 'MN RAN L3 SW ULM L3NRT SQD 65'
...    Email: 'I_MN_RAN_L3_SW_ULM_SQD_65@internal.nsn.com'
...    Description:

Resource          ./UteCloudAcceptanceTest_Keywords.robot

Suite Setup       Prepare TL for Ute Cloud Acceptance Test
Suite Teardown    dcap.stop dcap container for all nodes

Test Setup        Perform Preconditions of Test Case
Test Teardown     Perform Postconditions of Test Case

*** Variables ***

# UE ID delta between SA UEs and NSA UEs

${SANSADELTA}  100

# You can override it via robot command line parameter "-v SANSADELTA:x"

*** Test Cases ***

UTE Cloud Acceptance Test
    [Documentation]
    ...    Execute basic L3 call with traffic on cell 1 using first SA UE and first NSA UE as acceptance test for new UTE Cloud topology & variant
    Attach SA UEs
    Attach NSA UEs
    Start Traffic on SA UEs
    Start Traffic on NSA UEs
    Sleep  600s  reason=Apply traffic for (at least) 10 minutes
    Check Traffic for SA UEs
    Check Traffic for NSA UEs
    Stop Traffic on SA UEs
    Stop Traffic on NSA UEs
    Detach SA UEs
    Detach NSA UEs
