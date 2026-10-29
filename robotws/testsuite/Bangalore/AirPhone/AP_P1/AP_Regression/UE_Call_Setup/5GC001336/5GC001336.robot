*** Settings ***
Documentation
...    author:  gopalakrishnan.n@nokia.com
...    Test cases that are selected for the CIT/CRT for AP with respect to feature 5GC001336

Resource         ../Resources/636_1336_Keywords.robot

Suite Setup      Suite Setup
Suite Teardown   Common Suite Teardown Keywords
Test Setup       Test Setup
Test Teardown    Test Teardown

*** Variables ***
${cqireport__filter}            nr-rrc.reportConfigId == 0
${data_rate}                    2
${default_log_wait_time}        5s

*** Test Cases ***
5GC001336_A_23_IE_CHECK_nrofCQIsPerReport
    [Documentation]     This case will cover 3 cases in this case from the list. We had integrated the Call and
    ...                 Data Transfer verification also into the same case.
    ...                 2 other cases are "5GC001336_A_7_UL_traffic_2Mbps_FR1" and "5GC001336_A_5_DL_traffic_2Mbps_FR1"
    [Tags]    CRT
    Perform UE Attach
    Perform SgNBAdiition
    Verify CRNTI is Present In APL3 Logs
    Start Data Transfer And Verify Throughput    ${BEARER_ID}    ${UE_ID}    ${data_rate}
    Stop All Data Transfer    ${UE_ID}    ${BEARER_ID}
    UE Detach    ue_id=${UE_ID}
    Wait For PCAP Log Collection    time=${default_log_wait_time}
    Stop pcap collection in gNB and WTS
    Check CQIsPerReport IE Is Present    filter=${cqireport__filter}
    ...    msg_names=RRC Reconfiguration,UEContextSetupResponse

*** Keywords ***
Suite Setup
    Suite Common Keywords    feature_folder=5GC0001336
    Prepare Environment Based On Run Type
    Wait for gNB To Be Ready

Test Setup
    Create Test Case Folder
    Start pcap collection in gNB and WTS
    Start and configure WTS
    Establish X2 link And Wait For Cell Setup

Test Teardown
    Run Keyword And Ignore Error    Stop All Data Transfer    ${UE_ID}    ${BEARER_ID}
    Run Keyword And Ignore Error    UE Detach    ue_id=${UE_ID}
    Common Test Teardown
