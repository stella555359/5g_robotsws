*** Settings ***
Documentation     author: Venkatesh
...               contact: venkatesh.1.venkatesh@nokia.com
...               Description: verifiation of 5GC000511 PRACH Control- PRACH configuration options for the cell              .
...               PRACH is configured with cell setup & cell reconfiguration procedures.
...               NodeOAM directly sends PRACH configuration to gNB-DU, which performs the cell setup/reconfiguration.
...               This feature also provides the PRACH configuration to UE via MeNB during the SgNB addition request procedure.
...               PRACH-Config IE is within RRCReconfiguration message inside SCG-Config IE in SgNBAdditionRequestAcknowledge msg.

Resource          ./511_CIT_Keywords.robot
Resource          ./5GC000511_ConfigManagement_Admin.robot

Suite Setup       Suite Setup
Suite Teardown    Suite Teardown
Test Setup        Create Test Case Folder
Test Teardown     Test Teardown

*** Test Cases ***
Verify Provision of PRACH configuration for cell activation is successful
    [Documentation]    param update and sgNBAttach
    [Tags]    CRT
    Update PRACH params in gNB       key=TC_1
    Reboot GNB and Airphone
    Prepare Environment Based On Run Type
    Update PRACH params in WTS xml   msgFreq=0    RootIndex=20    z=13    preamblesPerSsb=64
    ...                                  powerRampingStep=2    preambleMax=7    contention=8
    ...                                  ssbThreshold=11    power=-118
    Check GNB Status before WTS Start
    Start WTS With Configuration
    Establish X2 link And Wait For Cell Setup
    UE Attach   ue_id=${UE_ID}   profile_id=${PROFILE_ID}
    SGNB Addition For Bearer   ue_id=${UE_ID}   target_gnb=${GNB_ID}    target_cells=${CELL_ID}   bearer=${BEARER_ID}
    Start Data Transfer And Verify Throughput   bearer=${BEARER_ID}    ue_id=${UE_ID}
    Stop All Data Transfer    ${UE_ID}   bearer=${BEARER_ID}
    UE Detach   ${UE_ID}

Verify delivery of PRACH configuration via MeNB to UE during Secondary Node Addition procedure without continuous DL data transmission
    [Documentation]    param update and sgNBAttach
    [Tags]    CRT
    Update PRACH params in gNB       key=TC_2
    Reboot GNB and Airphone
    Prepare Environment Based On Run Type
    Update PRACH params in WTS xml   msgFreq=6    RootIndex=100    z=6    preamblesPerSsb=12
    ...                                  powerRampingStep=4    preambleMax=3    contention=3
    ...                                  ssbThreshold=35    power=-74
    Check GNB Status before WTS Start
    Start WTS With Configuration
    Establish X2 link And Wait For Cell Setup
    UE Attach   ue_id=${UE_ID}   profile_id=${PROFILE_ID}
    SGNB Addition For Bearer   ue_id=${UE_ID}   target_gnb=${GNB_ID}    target_cells=${CELL_ID}   bearer=${BEARER_ID}
    Start Data Transfer And Verify Throughput   bearer=${BEARER_ID}    ue_id=${UE_ID}
    Stop All Data Transfer    ${UE_ID}   bearer=${BEARER_ID}
    UE Detach   ${UE_ID}

Verify Airphone is able to accept the RACH configuration parameters coming in RRCReconfiguration message
    [Documentation]    param update and sgNBAttach
    [Tags]    CRT
    Update PRACH params in gNB       key=TC_3
    Reboot GNB and Airphone
    Prepare Environment Based On Run Type
    Update PRACH params in WTS xml   msgFreq=18    RootIndex=40    z=5    preamblesPerSsb=36
    ...                                  powerRampingStep=1    preambleMax=10    contention=1
    ...                                  ssbThreshold=60    power=-170
    Check GNB Status before WTS Start
    Start WTS With Configuration
    Establish X2 link And Wait For Cell Setup
    UE Attach   ue_id=${UE_ID}   profile_id=${PROFILE_ID}
    SGNB Addition For Bearer   ue_id=${UE_ID}   target_gnb=${GNB_ID}    target_cells=${CELL_ID}   bearer=${BEARER_ID}
    Start Data Transfer And Verify Throughput   bearer=${BEARER_ID}    ue_id=${UE_ID}
    Stop All Data Transfer    ${UE_ID}   bearer=${BEARER_ID}
    UE Detach   ${UE_ID}

*** Keywords ***
Test Teardown
    Run Keyword And Ignore Error    UE Detach   ${UE_ID}
    WTS Teardown Keywords
