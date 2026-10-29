*** Settings ***
Documentation     author: Sangeetha M
...               contact: m.sangeetha@nokia.com

Resource          ./5GC000738_ConfigManagement_Admin.robot

Suite Setup       Suite Setup
Suite Teardown    Suite Teardown
Test Setup        Test Setup
Test Teardown     Test Teardown

*** Variables ***
${MCC}     555
${MNC1}    10
${MNC2}    20

*** Test Cases ***
PLMN selection during SgNB Addition and Modification
    [Tags]    CRT
    Attach to Default UE
    Set PLMN Values    mcc=${MCC}     mnc=${MNC1}
    SGNB Addition For Default Bearer
    Set PLMN Values    mcc=${MCC}    mnc=${MNC2}
    Sgnb Modification for Default UE
    Start Data Transfer on Default UE
    Wait before Validation
    Validate PLMN in SgNBModificationReq msg From Pcap

*** Keywords ***
Test Teardown
    UE Detach   ${UE_ID}
    Common Test Teardown

