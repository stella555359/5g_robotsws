*** Settings ***
Documentation
...  author: Casbo Xing
...  contact: casbo.xing@nokia-sbell.com
...  Mainly verify parity CB005914 for CB009514
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB005914_B/Resource/common.robot

Force Tags   HAZ3_SG06  CA_VRF_SISO   SBTS00

Suite Setup    Test Suite Setup For CB009514
Suite Teardown    Test Suite Teardown For CB009514


*** Test Cases ***
[1]CB009514-KC_CB005914_004_Trigger_ IQ_data_by_L1high_Uplink_suspicious_event_on_72e_radio
    [Documentation]
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for parity function of CB005914 on CB009514(7-2e）
    ...    The main steps performed for the test are:
    ...     - Login BTS set RAD parameter to enable NrUIPhy
    ...     - Enable L1-IQ data capture on target cell and RU
    ...     - L3call on target cell
    ...     - Check fault 8101
    ...     - Collect snapshot and check if L1 IQ data captured
    ...    Pass criteria: Fault 8101 reported and can be canceled after a snapshot collection.
    ...    L1-IQ data(with file name *fcpTriggeredCapture)
    ...    Note:Since CNI-127210, fault 8101 is hidden on EM, WA is to create MO(NOTE) to make fault visible
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 27.05.2025 - Case Draft
    ...    - 25.06.2025 - Case Review
    ...    Author: casbo.xing@nokia-sbell.com
    [Timeout]    1h
    [Setup]    Case Setup for CB009514
    Wait Until Keyword Succeeds   3x   10s    ADMIN Block NR cell and check status   cell_index=2
    Wait Until Keyword Succeeds   3x   10s   ADMIN check NR cell status    cell_index=1
    ADMIN Config RU iq Capture Update    cellid=1
    Data Transfer Conducted   direction=UL
    wait until keyword succeeds   2min    5s    Fault With Alarm Should Be Present
     ...   FaultID=8101    AlarmID=7115
    Sleep    60s
    Wait Until Keyword Succeeds   3x   5min  Catch Snapshot COAM    local_file_path=${OUTPUT_DIR}/snapshot_AVQC.zip
    Wait Until Keyword Succeeds   1min   20s    ADMIN disable L1 IQ capture
    Fault With Alarm Should Not Be Present   FaultID=8101    AlarmID=7115
    Extract and check IQ Data from on DU or RU    snapshot_path=${OUTPUT_DIR}/snapshot_AVQC.zip
    Wait Until Keyword Succeeds   3x   10s    ADMIN UnBlock NR cell and check status    cell_index=2
    Wait Until Keyword Succeeds   2min   20s    ADMIN check NR cell status    cell_index=2
    ADMIN check NR cell status    cell_index=1
    [Teardown]  Case Teardown for CB009514