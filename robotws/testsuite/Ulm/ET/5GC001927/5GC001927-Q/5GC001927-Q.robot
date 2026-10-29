*** Settings ***

Documentation   This is a Robot Test Suite for Feature 5GC001927_Q 'Concurrency Handling'
...             Team: 'MN RAN L3 SW ULM L3NRT SQD 65'
...             Email: 'I_MN_RAN_L3_SW_ULM_SQD_65@internal.nsn.com'
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Resource        5GC001927-Q-keywords.robot

Suite Setup     Common Suite Setup
Suite Teardown  Common Suite Teardown

Test Setup      Perform Preconditions of Test Scenario
Test Teardown   Perform Postconditions of Test Scenario

*** Test Cases ***


[1] 5GC000795_Q_TC03_SgNB_Modification_for_E-RABs_Addition_when_SgNB_Modification_for_E-RABs_Addition_is_ongoing
    [Documentation]    SgNB Modification [E-RABs_Addition] is received by SgNB BEFORE
    ...                SgNB Modification Acknowledge for already ongoing SgNB Modification [E-RABs_Addition] is sent
    ...                SgNB Modification [E-RABs_Addition] message will be ignored
    [Tags]  TC3.1  CIT  CDRT
    Add Bearer and Start Traffic             bearer=4
    SgNBAddition                             bearer=2
    Bearer Stats from                        bearer=2-4
    Activate Failure Scenario                menb_forced_scenario=sgnb_mod_req_add:before_sgnb_mod_req_ack
    SgNBModification                         bearer=3  modification=bearer_to_add
    Verify Traffic On 5G only                bearer=2-3
    Verify Message Sequence for SgNBModification Before Cases


[2] 5GC000795_Q_TC03_SgNB_Modification_for_E-RABs_Addition_when_SgNB_Modification_for_E-RABs_Addition_is_ongoing
    [Documentation]    SgNB Modification [E-RABs_Addition] is received by SgNB AFTER
    ...                SgNB Modification Acknowledge for already ongoing SgNB Modification [E-RABs_Addition] is sent
    ...                The message will be queued until the procedure for SGNB Modification [Erabs To Be Added] is finished.
    ...                This means StatusTransfer and Reconfiguration Complete are received and processed accordingly.
    [Tags]  TC3.2
    Add Bearer and Start Traffic             bearer=4
    SgNBAddition                             bearer=2
    Bearer Stats from                        bearer=2-4
    Activate Failure Scenario                menb_forced_scenario=sgnb_mod_req_add:after_sgnb_mod_req_ack
    SgNBModification                         bearer=3  modification=bearer_to_add
    Verify Traffic On 5G only                bearer=2-4
    Verify Message Sequence for SgNBModification After Cases


[1] 5GC000795_Q_TC04_SgNB_Modification_for_E-RABs_Addition_when_SgNB_Modification_for_E-RABs_Deletion_is_ongoing
    [Documentation]    SgNB Modification [E-RABs_Addition] is received by SgNB BEFORE
    ...                SgNB Modification Acknowledge for already ongoing SgNB Modification [E-RABs_Deletion] is sent
    ...                SgNB Modification [E-RABs_Addition] message will be ignored
    [Tags]  TC4.1  CRT  CDRT
    SgNBAddition                             bearer=2-3
    Bearer Stats from                        bearer=2-3
    Activate Failure Scenario                menb_forced_scenario=sgnb_mod_req_add:before_sgnb_mod_req_ack
    SgNBModification                         bearer=3  modification=bearer_to_release
    Verify Traffic On 5G only                bearer=2
    Verify Message Sequence for SgNBModification Before Cases


[1] 5GC000795_Q_TC05_SgNB_Modification_for_E-RABs_Deletion_when_SgNB_Modification_for_E-RABs_Addition_is_ongoing
    [Documentation]    SgNB Modification [E-RABs_Deletion] is received by SgNB BEFORE
    ...                SgNB Modification Acknowledge for already ongoing SgNB Modification [E-RABs_Addition] is sent
    ...                SgNB Modification [E-RABs_Deletion] message will be ignored
    [Tags]  TC5.1  CRT  CDRT
    SgNBAddition                             bearer=2
    Bearer Stats from                        bearer=2-3
    Activate Failure Scenario                menb_forced_scenario=sgnb_mod_req_del:before_sgnb_mod_req_ack
    SgNBModification                         bearer=3  modification=bearer_to_add
    Verify Traffic On 5G only                bearer=2-3
    Verify Message Sequence for SgNBModification Before Cases


[2] 5GC000795_Q_TC05_SgNB_Modification_for_E-RABs_Deletion_when_SgNB_Modification_for_E-RABs_Addition_is_ongoing
    [Documentation]    SgNB Modification [E-RABs_Deletion] is received by SgNB AFTER
    ...                SgNB Modification Acknowledge for already ongoing SgNB Modification [E-RABs_Addition] is sent
    ...                The message will be queued until the procedure for SGNB Modification [Erabs To Be Added] is finished.
    ...                This means StatusTransfer and Reconfiguration Complete are received and processed accordingly.
    [Tags]  TC5.2  CRT
    Add Bearer and Start Traffic             bearer=4
    SgNBAddition                             bearer=2-3
    Bearer Stats from                        bearer=2-4
    Activate Failure Scenario                menb_forced_scenario=sgnb_mod_req_del:after_sgnb_mod_req_ack
    SgNBModification                         bearer=4  modification=bearer_to_add
    Verify Traffic On 5G only                bearer=2-3
    Verify Message Sequence for SgNBModification After Cases


[1] 5GC000795_Q_TC06_SgNB_Modification_for_E-RABs_Deletion_when_SgNB_Modification_for_E-RABs_Deletion_is_ongoing
    [Documentation]    SgNB Modification [E-RABs_Deletion] is received by SgNB BEFORE
    ...                SgNB Modification Acknowledge for already ongoing SgNB Modification [E-RABs_DELETION] is sent
    ...                SgNB Modification [E-RABs_Deletion] message will be ignored
    [Tags]  TC6.1  CRT  CDRT
    Add Bearer and Start Traffic             bearer=4
    SgNBAddition                             bearer=2-4
    Bearer Stats from                        bearer=2-4
    Activate Failure Scenario                menb_forced_scenario=sgnb_mod_req_del:before_sgnb_mod_req_ack
    SgNBModification                         bearer=3  modification=bearer_to_release
    Verify Traffic On 5G only                bearer=2
    Verify Traffic On 5G only                bearer=4
    Verify Message Sequence for SgNBModification Before Cases


[2] 5GC000795_Q_TC06_SgNB_Modification_for_E-RABs_Deletion_when_SgNB_Modification_for_E-RABs_Deletion_is_ongoing
    [Documentation]    SgNB Modification [E-RABs_Deletion] is received by SgNB AFTER
    ...                SgNB Modification Acknowledge for already ongoing SgNB Modification [E-RABs_Deletion] is sent
    ...                The message will be queued until the procedure for SGNB Modification [Erabs To Be Deleted] is finished.
    ...                This means StatusTransfer and Reconfiguration Complete are received and processed accordingly.
    [Tags]  TC6.2  CRT
    Add Bearer and Start Traffic             bearer=4
    SgNBAddition                             bearer=2-4
    Bearer Stats from                        bearer=2-4
    Activate Failure Scenario                menb_forced_scenario=sgnb_mod_req_del:after_sgnb_mod_req_ack
    SgNBModification                         bearer=4  modification=bearer_to_release
    Verify Traffic On 5G only                bearer=2
    Verify Message Sequence for SgNBModification After Cases


[1] 5GC000795_Q_TC07_MN_initiated_SgNB_Release_when_SgNB_Modification_for_E-RABs_Addition_is_ongoing
    [Documentation]    This scenario handles incoming SgNBReleaseRequest message from MeNB via X2-interface
    ...                during an already ongoing SgNBModificationRequest which adds an additional eRAB.
    ...                SgNBModification procedure will be stopped and SgNBReleaseRequest will be processed immediately.
    [Tags]  TC7.1  CRT
    SgNBAddition                             bearer=2
    Bearer Stats from                        bearer=2-3
    Activate Failure Scenario                menb_failure_scenario=sgnb_rel_request_after_sending_sgnb_mod_req  rrc_delay=100
    SgNBModification                         bearer=3  modification=bearer_to_add
    Verify Message Sequence In X2 Trace      messages=SgNBModificationRequest SgNBReleaseRequest SgNBReleaseRequestAcknowledge
    Verify Message Sequence Not In X2 Trace  messages=SgNBModificationRequestAcknowledge
