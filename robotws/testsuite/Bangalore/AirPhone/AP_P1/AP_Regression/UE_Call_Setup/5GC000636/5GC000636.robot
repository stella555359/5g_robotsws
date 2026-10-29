*** Settings ***
Documentation
...    author:  gopalakrishnan.n@nokia.com
...    Test cases that are selected for the CIT/CRT for AP with respect to feature 5GC000636

Resource         ../Resources/636_1336_Keywords.robot

Suite Setup       Suite Setup
Suite Teardown    Common Suite Teardown Keywords
Test Setup        Test Setup
Test Teardown     Test Teardown

*** Variables ***
${ssb_filter_TDD}               nr-rrc.ssb_PositionsInBurst==1 and nr-rrc.mediumBitmap == 80
${ssb_filter_FDD}               nr-rrc.ssb_PositionsInBurst==0 and nr-rrc.shortBitmap == 80
${mimo_filter}                  nr-rrc.maxMIMO_Layers == 2
${PCAP_WAIT_TIME}               5s

*** Test Cases ***
5GC000636-D_10_SSBPositionInBurst_medium_bitmap_IE_checks
    [Tags]    CRT
    Perform UE Attach
    Perform SgNBAdiition
    Verify CRNTI is Present In APL3 Logs
    UE Detach    ue_id=${UE_ID}
    Wait For PCAP
    Stop pcap collection in gNB and WTS
    Check SSBPosInBurst Medium Bitmap Is Present    filter=${ssb_filter}
    ...    msg_names=RRC Reconfiguration,UEContextSetupResponse

5GC000636-D_12_maxMIMO-Layers_IE_checks
    [Tags]    CRT
    Perform UE Attach
    Perform SgNBAdiition
    Verify CRNTI is Present In APL3 Logs
    UE Detach    ue_id=${UE_ID}
    Wait For PCAP
    Stop pcap collection in gNB and WTS
    Check MaxMIMO Layers IE Is Present    filter=${mimo_filter}
    ...    msg_names=RRC Reconfiguration,UEContextSetupResponse

*** Keywords ***
Suite Setup
    Suite Common Keywords    feature_folder=5GC000636
    Prepare Environment Based On Run Type
    Wait for gNB To Be Ready
    Set SSB filter based on radio technology

Test Setup
    Create Test Case Folder
    Start pcap collection in gNB and WTS
    Start and configure WTS
    Establish X2 link And Wait For Cell Setup

Test Teardown
    Run Keyword And Ignore Error    UE Detach    ue_id=${UE_ID}
    Common Test Teardown

Wait For PCAP
   Sleep   ${PCAP_WAIT_TIME}

Set SSB filter based on radio technology
    @{celltech}    Create List    cellTechnology
    ${scf_path}    admin_helper.download current scf file
    ${cell_tech_value}    scf_helper.get_feature_paramters_from_scf    ${scf_path}
    ...    ${celltech}    ${NRCELL_DISTNAME}
    ${ssb_filter}    Set Variable If    '${cell_tech_value['cellTechnology']}'=='TDD'
    ...    ${ssb_filter_TDD}    ${ssb_filter_FDD}
    Set Suite Variable    ${ssb_filter}
