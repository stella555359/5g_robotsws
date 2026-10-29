*** Settings ***
Documentation
...    author: y6lu
...    contact: lu.yu@nokia-sbell.com
...    Description:


Resource          ./Resources/CNI85020_Common_KW.robot

Suite Setup          Run Keywords     Run Keyword And Ignore Error
...      robot_common_operations.Common Suite Setup
...      AND      Run Keyword And Ignore error
...      Adjust One HBTE ATT Value      PA_Info=${Block_TL926_PA}         PA_IP=${att_ipaddr}
...      HBTE_max_value=${127}
...      model=PA-16-16-6-127-0.5-B-S
Suite Teardown    Run Keyword     robot_common_operations.Common Suite Teardown

Force Tags
Test Timeout    30min

Resource    ../common/taf_coam.robot
*** Variables ***
${WEBUI_ADDR}    ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USER}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}

#${ul}    [BBMOD_R-1(ABIN)] [PCI: 112]NRCELL-2: Subcell 1
#${dl}    [BBMOD_R-1(ABIN)] [PCI: 112]NRCELL-2: Subcell 1
#
#${BBMOD}   BBMOD_R-1(ABIN)
${NRBTS_ID}           ${tl.gnbs[0].global_bts_id}
${UE_TYPE}    qct_dx50
*** Test Cases ***
#[1]CNI-85020_03_Loki_Event trigger parallel L1-L2 Mirroring snapshot to LSS
[1]CNI-85020_03_Loki_Event_trigger_parallel_L1-L2_Mirroring_snapshot_to_LSS
    [Tags]    HAZ3_T03
    [Documentation]    *****************
    ...    The purpose of this test case is to verify that L2 event trigger Snapshot includes IQ samples and BIP in parallel to LSS.
    ...    *******************
    [Setup]    Precondition
    [Teardown]    CNI85020_Common_KW.Teardown
    Step 1: config RAD parameter
    Step 2: config LSS Parameters
    Step 3: Start Parallel L1-L2 Mirroring
    Step 4: Make L3 Call To Trigger Alarm
    Step 5: Check Logs

#[1]CNI-85020_02_Loki_Start and stop parallel L1-L2 Mirroring via ADMIN CLI
[1]CNI-85020_02_Loki_Start_and_stop_parallel_L1-L2_Mirroring_via_ADMIN_CLI
    [Tags]    HAZ3_T03
    [Documentation]    *****************
    ...    The purpose of this test case is to verify that Activate and deactivate collect BIP log along with event trigger IQ snapshot via CLI.
    ...    *******************
#    [Setup]
#    Log To Console    /n tryed in case_03
    [Setup]    Precondition
    [Teardown]    CNI85020_Common_KW.Teardown
    Step 1: config RAD parameter
#    Step 2: config LSS Parameters
    Step 3: Start Parallel L1-L2 Mirroring

*** Keywords ***
Step 1: config RAD parameter
    Config Trigger Event On BBMod

Step 2: config LSS Parameters
    Config LSS parameters
    Config LSS User And Password
    config Auto Snapshot Trigger Fault
    delete snapshot files in LSS

Step 3: Start Parallel L1-L2 Mirroring
    #Start Parallel L1-L2 Mirroring From WEBUI
    Start Parallel L1-L2 Mirroring From cli

Step 4: Make L3 Call To Trigger Alarm
    Make L3 Call
    log to console    Auto Snapshot time limited
    #Wait Until Keyword Succeeds    1min    30s    Check FID:8101 Raised

Step 5: Check Logs
    Wait until keyword succeeds    1 min    30s    Check existence of remote snapshot
    #...    ${lssIPaddress}    coam    iW_K#8.ute%A10h0m0ra    /home/ute/coam/
    Wait until keyword succeeds    5 min    30s    Check Bip Contained
