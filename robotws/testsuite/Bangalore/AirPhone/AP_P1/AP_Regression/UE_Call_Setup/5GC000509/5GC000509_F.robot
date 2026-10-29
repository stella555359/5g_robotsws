*** Settings ***
Documentation     author: Venkatesh
...               contact: venkatesh.1.venkatesh@nokia.com
...               Description: Test Cases for 5GC000509: L3 Non Standalone Call with Data Transmission.
...               This Feature is includes, UE Context Setup with additional functions in Security and IP Version
...               with above and below 6Ghz band and data trnasfer at 5G side.

Resource          ./5GC000509_Keywords.robot

Suite Setup       Suite Setup    feature_folder=5GC000509_F
Suite Teardown    Suite Teardown
Test Setup        Test Setup
Test Teardown     Test Teardown

*** Variables ***
${rrcreconfig_error}        ResponseInformationSgNBReconfComp : reject-by-MeNB-SgNBReconfComp
${sgnb_release_req_wait}    5s

*** Test Cases ***
Verify UE Context Setup unsuccessful_NR RRC configuration is rejected from MeNB
    [Documentation]    This Testcase Verifies that gNB should initiate release when
    ...                SgnbReconfigurationComplete with failure is sent
    [Tags]    CRT
    Ue Attach Based with aes cipher
    Trigger MENB Failure Scenario    menb_failure_scenario=send_sgnb_reconf_complete_failure
    Sgnb Addition Should Fail    expected_error=${rrcreconfig_error}
    Wait For Sgnb Release Required
    Validate Sgnb Release Required From Pcap    cause=radioNetwork: failure-in-the-radio-interface-procedure

*** Keywords ***
Test Setup
    Create Test Case Folder
    Start pcap collection in gNB and WTS
    Prepare Environment Based On Run Type     cfg_type=custom
    Start WTS And Extablish X2 Link

Test Teardown
    UE Detach    ue_id=${UE_ID}
    Common Test Teardown

Wait For Sgnb Release Required
    Sleep    ${sgnb_release_req_wait}
