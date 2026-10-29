*** Settings ***
Documentation     author: Venkatesh
...               contact: venkatesh.1.venkatesh@nokia.com
...               Description:  Test Cases for 5GC000475: Successful MN initiated SgNB Release with UL& DL data when
...               DL forwarding is enabled

Resource          ./5GC000475_Keywords.robot

Suite Setup       Suite Setup
Suite Teardown    Suite Teardown
Test Setup        Test Setup
Test Teardown     Test Teardown

*** Test Cases ***
Successful MN initiated SgNB Release with UL & DL data when DL forwarding is enabled
    [Documentation]    To verify the DL data forwarding from 5g to 4g when MN initiated SgNB release happens with
    ...    continous DL & UL data
    [Tags]    CRT
    Attach To Default UE
    Start Data Transfer And Verify It is Through MCG
    Perform SGNB Addition For Bearer
    Wait After Sgnb Addition
    Store Packets Before ENDC Bearer Release
    Release 5g Bearer
    Wait After ENDC Release
    Store Packets After ENDC Bearer Release
    Verify Data Trasmission is Over 4G Network

To Verify SN addition is unsuccessful when sgnb reconf complete not sent
    [Tags]    CRT
    Update tDCoverall param in gNB
    Attach To Default UE
    Start Data Transfer And Verify It is Through MCG
    Trigger MENB Failure Scenario    enb=1    menb_failure_scenario=dont_send_sgnb_reconf_complete
    Sgnb Addition Should Fail    expected_error=radioNetwork : tDCoverall-expiry
    Wait For Sgnb Release Required
    Validate Sgnb Release Required From Pcap    cause=radioNetwork: tDCoverall-expiry

Unsuccessful completion of SgNB Addition procedure when sn status transfer not sent
    [Documentation]    To verify SN addition is unsuccessful when sn status transfer not sent
    [Tags]   SKIP
    Update tDCoverall param in gNB
    Attach To Default UE
    Start Data Transfer And Verify It is Through MCG
    Trigger MENB Failure Scenario    enb=1    menb_failure_scenario=dont_send_sn_status_transfer
    Sgnb Addition Should Fail    expected_error=radioNetwork : unspecified
    Wait For Sgnb Release Required
    Validate Sgnb Release Required From Pcap    cause=radioNetwork: unspecified
