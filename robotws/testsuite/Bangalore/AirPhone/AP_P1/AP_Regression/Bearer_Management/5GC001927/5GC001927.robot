*** Settings ***
Documentation     Test cases for 5GC001927 feature
Suite Setup       Suite Setup
Suite Teardown    Suite Teardown
Test Setup        Test Setup
Test Teardown     Test Teardown
Force Tags        CRT    PY310    RF50
Resource          5GC001927_Keywords.robot

*** Variables ***
${WTS_CFG_PATH}    ${CURDIR}/cfg

*** Test Cases ***
TC03.1_SgNB_Modification_for_E-RABs_Addition_when_SgNB_Modification_for_E-RABs_Addition_is_ongoing_before
    [Documentation]    SgNB Modification [E-RABs_Addition] is received by SgNB BEFORE
    ...    SgNB Modification Acknowledge for already ongoing SgNB Modification [E-RABs_Addition] is sent
    ...    SgNB Modification [E-RABs_Addition] message will be ignored
    [Tags]    CRT
    Add Bearer and start traffic    bearer=4    timeout=${timeout}
    Sgnb Addition And Wait For Data Transfer    ue_id=1    bearer=2    target_gnb=2    target_cells=2
    Bearer Stats from    bearer=2-4
    Activate Failure Scenario    menb_forced_scenario=sgnb_mod_req_add:before_sgnb_mod_req_ack
    Sgnb Modification And Wait For Data Transfer    ue_id=1    bearer=3
    Verify Traffic On 5G only    bearer_start=2    bearer_stop=3
    Verify Message Sequence for SgNBModification Before Cases

TC03.2_SgNB_Modification_for_E-RABs_Addition_when_SgNB_Modification_for_E-RABs_Addition_is_ongoing
    [Documentation]    SgNB Modification [E-RABs_Addition] is received by SgNB AFTER
    ...    SgNB Modification Acknowledge for already ongoing SgNB Modification [E-RABs_Addition] is sent
    ...    The message will be queued until the procedure for SGNB Modification [Erabs To Be Added] is finished.
    ...    This means StatusTransfer and Reconfiguration Complete are received and processed accordingly.
    [Tags]    CRT
    Add Bearer and start traffic    bearer=4    timeout=${timeout}
    Sgnb Addition And Wait For Data Transfer    ue_id=1    bearer=2    target_gnb=2    target_cells=2
    Bearer Stats from    bearer=2-4
    Activate Failure Scenario    menb_forced_scenario=sgnb_mod_req_add:after_sgnb_mod_req_ack
    Sgnb Modification And Wait For Data Transfer    ue_id=1    bearer=3
    Verify Traffic On 5G only    bearer_start=2    bearer_stop=4
    Verify Message Sequence for SgNBModification After Cases

TC04.1_SgNB_Modification_for_E-RABs_Addition_when_SgNB_Modification_for_E-RABs_Deletion_is_ongoing
    [Documentation]    SgNB Modification [E-RABs_Addition] is received by SgNB BEFORE
    ...    SgNB Modification Acknowledge for already ongoing SgNB Modification [E-RABs_Deletion] is sent
    ...    SgNB Modification [E-RABs_Addition] message will be ignored
    [Tags]    CRT
    Sgnb Addition And Wait For Data Transfer    ue_id=1    bearer=2-3    target_gnb=2    target_cells=2
    Bearer Stats from    bearer=2-3
    Activate Failure Scenario    menb_forced_scenario=sgnb_mod_req_add:before_sgnb_mod_req_ack
    Sgnb Modification And Wait For Data Transfer    ue_id=1    bearer=3    modification=bearer_to_release
    Verify Traffic On 5G only    bearer_start=2
    Verify Message Sequence for SgNBModification Before Cases

TC05.1_SgNB_Modification_for_E-RABs_Deletion_when_SgNB_Modification_for_E-RABs_Addition_is_ongoing
    [Documentation]    SgNB Modification [E-RABs_Deletion] is received by SgNB BEFORE
    ...    SgNB Modification Acknowledge for already ongoing SgNB Modification [E-RABs_Addition] is sent
    ...    SgNB Modification [E-RABs_Deletion] message will be ignored
    [Tags]    CRT
    Sgnb Addition And Wait For Data Transfer    ue_id=1    bearer=2    target_gnb=2    target_cells=2
    Bearer Stats from    bearer=2-3
    Activate Failure Scenario    menb_forced_scenario=sgnb_mod_req_del:before_sgnb_mod_req_ack
    Sgnb Modification And Wait For Data Transfer    ue_id=1    bearer=3
    Verify Traffic On 5G only    bearer_start=2    bearer_stop=3
    Verify Message Sequence for SgNBModification Before Cases

TC05.2_SgNB_Modification_for_E-RABs_Deletion_when_SgNB_Modification_for_E-RABs_Addition_is_ongoing
    [Documentation]    SgNB Modification [E-RABs_Deletion] is received by SgNB AFTER
    ...    SgNB Modification Acknowledge for already ongoing SgNB Modification [E-RABs_Addition] is sent
    ...    The message will be queued until the procedure for SGNB Modification [Erabs To Be Added] is finished.
    ...    This means StatusTransfer and Reconfiguration Complete are received and processed accordingly.
    [Tags]    CRT
    Add Bearer and start traffic    bearer=4    timeout=${timeout}
    Sgnb Addition And Wait For Data Transfer    ue_id=1    bearer=2-3    target_gnb=2    target_cells=2
    Bearer Stats from    bearer=2-4
    Activate Failure Scenario    menb_forced_scenario=sgnb_mod_req_del:after_sgnb_mod_req_ack
    Sgnb Modification And Wait For Data Transfer    ue_id=1    bearer=4
    Verify Traffic On 5G only    bearer_start=2    bearer_stop=3
    Verify Message Sequence for SgNBModification After Cases

TC06.1_SgNB_Modification_for_E-RABs_Deletion_when_SgNB_Modification_for_E-RABs_Deletion_is_ongoing
    [Documentation]    SgNB Modification [E-RABs_Deletion] is received by SgNB BEFORE
    ...    SgNB Modification Acknowledge for already ongoing SgNB Modification [E-RABs_DELETION] is sent
    ...    SgNB Modification [E-RABs_Deletion] message will be ignored
    [Tags]    CRT
    Add Bearer and start traffic    bearer=4    timeout=${timeout}
    Sgnb Addition And Wait For Data Transfer    ue_id=1    bearer=2-4    target_gnb=2    target_cells=2
    Bearer Stats from    bearer=2-4
    Activate Failure Scenario    menb_forced_scenario=sgnb_mod_req_del:before_sgnb_mod_req_ack
    Sgnb Modification And Wait For Data Transfer    ue_id=1    bearer=3    modification=bearer_to_release
    Verify Traffic On 5G only    bearer_start=2
    Verify Traffic On 5G only    bearer_start=4
    Verify Message Sequence for SgNBModification Before Cases

TC06.2_SgNB_Modification_for_E-RABs_Deletion_when_SgNB_Modification_for_E-RABs_Deletion_is_ongoing
    [Documentation]    SgNB Modification [E-RABs_Deletion] is received by SgNB AFTER
    ...    SgNB Modification Acknowledge for already ongoing SgNB Modification [E-RABs_Deletion] is sent
    ...    The message will be queued until the procedure for SGNB Modification [Erabs To Be Deleted] is finished.
    ...    This means StatusTransfer and Reconfiguration Complete are received and processed accordingly.
    [Tags]    CRT
    Add Bearer and start traffic    bearer=4    timeout=${timeout}
    Sgnb Addition And Wait For Data Transfer    ue_id=1    bearer=2-4    target_gnb=2    target_cells=2
    Bearer Stats from    bearer=2-4
    Activate Failure Scenario    menb_forced_scenario=sgnb_mod_req_del:after_sgnb_mod_req_ack
    Sgnb Modification And Wait For Data Transfer    ue_id=1    bearer=4    modification=bearer_to_release
    Verify Traffic On 5G only    bearer_start=2
    Verify Message Sequence for SgNBModification After Cases

TC07.1_MN_initiated_SgNB_Release_when_SgNB_Modification_for_E-RABs_Addition_is_ongoing
    [Documentation]    This scenario handles incoming SgNBReleaseRequest message from MeNB via X2-interface
    ...    during an already ongoing SgNBModificationRequest which adds an additional eRAB.
    ...    SgNBModification procedure will be stopped and SgNBReleaseRequest will be processed immediately.
    [Tags]    CRT    TempFix
    Sgnb Addition And Wait For Data Transfer    ue_id=1    bearer=2    target_gnb=2    target_cells=2
    Bearer Stats from    bearer=2-3
    Activate Failure Scenario    menb_failure_scenario=sgnb_rel_request_after_sending_sgnb_mod_req    rrc_delay=100
    Sgnb Modification And Wait For Data Transfer    ue_id=1    bearer=3    pass_regexp=${None}
    Stop Pcap And Convert And Store PDML
    Verify Message Sequence In X2 Trace    messages=SgNBModificationRequest SgNBReleaseRequest SgNBReleaseRequestAcknowledge
    Verify Message Sequence Not In X2 Trace    messages=SgNBModificationRequestAcknowledge
    [Teardown]        Run Keywords    Configure RRC Reconfig Param Rules    ue_id=1    rrc_delay=0
    ...    AND    Run keyword And Ignore Error    Test Teardown

*** Keywords ***
Enable MultiDRB Feature
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    delta_store.update managed object and parameter to delta    dist_name=${NRBTS_DISTNAME}    actMultiDrbNSA=true
    ${delta_store}    Collect Delta Store
    Recommission GNB With Delta    delta_file=${delta_store}    should_activate=${True}

Disable MultiDRB Feature
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    delta_store.update managed object and parameter to delta    dist_name=${NRBTS_DISTNAME}    actMultiDrbNSA=false
    ${delta_store}    Collect Delta Store
    Recommission GNB With Delta    delta_file=${delta_store}    should_activate=${True}

CleanUp
    Stop Sim
    Teardown All Aliases For Wts

Test Teardown
    Perform Postconditions of Test Scenario
    Common Test Teardown

Suite Setup
    Suite Common Keywords    feature_folder=5GC001927
    Wait for gNB To Be Ready
    Enable MultiDRB Feature
    Wait for gNB To Be Ready
    Prepare Environment Based On Run Type     cfg_type=custom

Test Setup
    Create Test Case Folder
    Start pcap collection in gNB and WTS
    Start WTS And Extablish X2 Link
    Wait for gNB To Be Ready
    Start EGATE Logs
    Attach UE and Data Transfer    ue_id=${UE_ID}
    Add Bearer and start traffic    bearer=3

Perform Postconditions of Test Scenario
    Stop Traffic
    UE Detach    ue_id=${UE_ID}

Suite Teardown
    Common Suite Teardown Keywords
    Disable MultiDRB Feature
    Wait for gNB To Be Ready
