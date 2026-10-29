*** Settings ***
Documentation     author: Sangeetha M
...               contact: m.sangeetha@nokia.com

Resource          ./5GC001301_Keywords.robot

Suite Setup       Suite Setup
Suite Teardown    Suite Teardown
Test Setup        Create Test Case Folder
Test Teardown     Test Teardown

*** Test Cases ***
Verify PRACH format C2 with 30kHz scs 100MHz bandwith 1208 frame structure
    [Documentation]    SWConfig File is updated to Set AP Framestructure to 1208
    [Tags]    CRT
    Set Configuration for 1208 Framestructure
    Start WTS With Configuration
    Establish X2 link And Wait For Cell Setup
    UE Attach   ue_id=${UE_ID}   profile_id=${PROFILE_ID}
    SGNB Addition For Bearer   ue_id=${UE_ID}   target_gnb=${GNB_ID}    target_cells=${CELL_ID}   bearer=${BEARER_ID}
    Wait before Validation
    Validate Prachconfigindex in SgNBadditionReqAck msg From Pcap    prach_config_index=196

Verify PRACH format C2 with 30kHz scs 100MHz bandwith 1070 frame structure
    [Documentation]    SWConfig File is updated to Set AP Framestructure to 1070
    [Tags]    CRT
    Set Configuration for 1070 Framestructure
    Start WTS With Configuration
    Establish X2 link And Wait For Cell Setup
    UE Attach   ue_id=${UE_ID}   profile_id=${PROFILE_ID}
    SGNB Addition For Bearer   ue_id=${UE_ID}   target_gnb=${GNB_ID}    target_cells=${CELL_ID}   bearer=${BEARER_ID}
    Wait before Validation
    Validate Prachconfigindex in SgNBadditionReqAck msg From Pcap    prach_config_index=196

*** Keywords ***
Test Teardown
    UE Detach   ${UE_ID}
    Common Test Teardown
