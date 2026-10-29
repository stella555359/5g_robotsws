*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    4G_FDD    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO_CUS
...                 release-SBTS24R1    team-VRF3_8    owner-kezhou
Resource          ../../../resources/DevHZ5_resource.robot

Documentation
...      INTRODUCTION:
...      The feature aims to add support for sending two S1 messages: PWSRestartIndication and PWSFailureIndication,
...      which are sent by eNB in certain cases related to ETWS/CMAS operations.
...
...      TEST SET NAME:
...
...      TESTING SCOPE:
...
...      CONTACTS:
...        ET:
...          Łukasz Kożuszek   lukasz.kozuszek@nokia.com
...          Jakub Grodny      jakub.grodny@nokia.com
...        EFS:
...          Marcin Biniek     marcin.biniek@nokia.com
...
...      REFERENCES:
...        CFAM: https://gates.nsn-net.net/view/00025df4#o=0
...        FTS:
...
...       HISTORY:
...               [xx.xx.2023] - Created TC
...               [xx.xx.2023] - Approved by Marcin Biniek - EFS
...                              https://wrgitlab.int.net.nokia.com/RAN/robotlte/-/merge_requests/
...               [<date>] - Test finished at SVN revision <svn_revision>
...               [<date>] - Review closed
...

*** Variables ***
####PM Counter####
@{PM_Counters}
...    LNBTS-1:${S1AP_PWS_RESTART_IND}=4
...    LNBTS-1:${S1AP_PWS_FAILURE_IND}=4

${S1AP_PWS_RESTART_IND}    M8000C50
${S1AP_PWS_FAILURE_IND}    M8000C51

#####MSG FLOW#####
@{2ndpart}
...    LNBTS:actCMAS=false
...    LNBTS:actCmasTransOptimization=false
...    LNBTS:actETWS=true
...    LNCEL-1:administrativeState=unlocked
...    LNCEL-2:emAreaIdList=2

@{lockcell1}
...    LNCEL-1:administrativeState=locked

@{lockcell2}
...    LNCEL-2:administrativeState=locked

@{unlockcell2}
...    LNCEL-2:administrativeState=unlocked

@{actPwsRstrtFlrInd}
...    LNBTS:actPwsRstrtFlrInd=true

@{addcell2toEA1}
...    LNCEL-2:emAreaIdList=1,2


${wRW1}
...    emergencyAreaID contains ('00 00 01') and
...    completedCellinEAI contains (cell-ID eq '0b0000000000000000000100000001')

${PWSFI1}
...    PWSfailedECGIList contains (cell-ID eq '0b0000000000000000000100000001') and
...    Global-ENB-ID contains (pLMNidentity contains ("0x42F480") and
...      eNB-ID contains (macroENB-ID eq "0b00000000000000000001"))

${PWSRI1}
...    ECGIListForRestart contains (cell-ID eq '0b0000000000000000000100000010') and
...    Global-ENB-ID contains (pLMNidentity contains ("0x42F480") and
...      eNB-ID contains (macroENB-ID eq "0b00000000000000000001")) and
...    TAIListForRestart contains (tAC eq "0x007B") and
...    EmergencyAreaIDListForRestart contains ("0x000001")

${wRW2}
...    emergencyAreaID-Broadcast contains (emergencyAreaID eq '0x000002') and
...    completedCellinEAI contains (cell-ID eq '0b0000000000000000000100000010')

${PWSFI2}
...    PWSfailedECGIList contains (cell-ID eq '0b0000000000000000000100000010') and
...    Global-ENB-ID contains (pLMNidentity contains ("0x42F480") and
...      eNB-ID contains (macroENB-ID eq "0b00000000000000000001"))

${PWSRI2}
...    ECGIListForRestart contains (cell-ID eq '0b0000000000000000000100000010') and
...    Global-ENB-ID contains (pLMNidentity contains ("0x42F480") and
...      eNB-ID contains (macroENB-ID eq "0b00000000000000000001")) and
...    TAIListForRestart contains (tAC eq "0x007B")

*** Test Cases ***
CB006495 Sending of PWS Restart and Failure Indication
    [Tags]
    [Documentation]
    ...     DESCRIPTION:
    ...     The test case verifies that PWSRestartIndication is sent when cell is unlocked, when cell is assigned to
    ...     a different Emergency Area List or when the eNB is restarted
    ...
    ...     PRECONDITIONS:
    ...         LNBTS.actCMAS = true
    ...         LNBTS.actCmasTransOptimization = true
    ...         LNBTS.actPwsRstrtFlrInd = false
    ...         LNBTS.warnAreaCoAllowed = true
    ...         LNBTS.cmasProlongOffsetCoeff = 1
    ...         LNBTS.cmasPagPeriod = default paging cycle
    ...         LNBTS.pwsWithEmAreaId = true
    ...         LNCEL.SIB.siWindowLen = 20ms for all cells
    ...         LNCEL.SIB.sibSchedulingList contains structures for SIB-12 for all cells
    ...         Cell 1 belongs to Emergency Area 1 (LNCEL-1.emAreaListId containing 1), while cell 2
    ...             belongs to Emergency Area 2 (LNCEL-2.emAreaListId containing 2)
    ...
    ...         MME_1 supports PLMN 244:08 and 244:09
    ...         MME_2 supports PLMN 244:08 and 244:10
    ...         MME_3 supports PLMN 244:08, 244:09 and 244:10
    ...
    ...     TEST SCENARIO:
    ...         1. CMAS transmission is started on cell-1
    ...         2. Cell-1 is locked
    ...         3. eNB sends to MME_1 and MME_2 PWSFailureIndication with PWSfailedECGIList and Global-ENB-ID containing data of cell-1
    ...         4. Cell-2 is added to Emergency Area 1
    ...         5. eNB sends to MME_1 and MME_2 PWSRestartIndication with ECGIListForRestart, Global-ENB-ID, TAIListForRestart and
    ...             EmergencyAreaIDListForRestart containing data of cell-2
    ...         6. Cell-1 is unlocked, cell-2 is removed form Emergency Area 1 and ETWS is enabled
    ...         7. ETWS transmission is started on cell-2
    ...         8. Cell-2 is locked
    ...         9. eNB sends to MME_1 and MME_2 PWSFailureIndication with PWSfailedECGIList and Global-ENB-ID containing data of cell-2
    ...         10. Cell-2 is unlocked
    ...         11. eNB sends to MME_1 and MME_2 PWSRestartIndication with ECGIListForRestart, Global-ENB-ID, TAIListForRestart
    ...              containing data of cell-2
    ...
    ...     POSTCONDITIONS:
    ...
    ...     TESTING TOOLS:  Real eNB, simulated eNB, CUS, EPCSIM, EMSSIM
    ...
    ...     TEST ENVIRONMENT:
    ...         HARDWARE ID:  AHFB
    ...
    ...     REQUIREMENTS COVERAGE:
    ...         REQUIREMENTS IN SCOPE:
    ...
    ...     BACKLOG ID:
    ...     REQUIRED LOGS:  Snapshot, IM, syslog, EPC logs
    ...     CONTACTS:  Lukasz Kozuszek   lukasz.kozuszek@nokia.com
    ...                Jakub Grodny      jakub.grodny@nokia.com
    ...
    ...     REFERENCES:
    ...
    ...     HISTORY:
    ...         [x] - Created TC
    ...         [19.09.2023] - Approved by Marcin Biniek (https://wrgitlab.int.net.nokia.com/RAN/robotlte/-/merge_requests/27744)
    ...         [x] - Test finished
    ...         [x] - Review closed

    Trigger MME_1 to send WriteReplaceWarningRequest with MessageId 4380 for CMAS for Emergency Area 1
    Lock Cell-1
    Enable PWS Restart and Failure Indications (CB006495)
    Add cell-2 to Emergency Area 1
    Unlock cell-1, enable ETWS and remove cell-2 from Emergency Area 1
    Trigger MME_1 to send WriteReplaceWarningRequest with MessageId 4380 for ETWS for Emergency Area 2
    Lock Cell-2 And Verify Relate MSGs
    Unlock Cell-1 And Verify Relate MSGs
    Check Rtpm Counter

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env    tl_type=CB006495
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create MME Alias    alias=MME_1    mme_id=1    id_type=wts
    Create MME Alias    alias=MME_2    mme_id=2    id_type=wts
    Create MME Alias    alias=MME_3    mme_id=3    id_type=wts
    Execute Egate Command    trace_sim on mme=1 protocol=s1
    Execute Egate Command    trace uec=1 protocol=rrc on

Trigger MME_1 to send WriteReplaceWarningRequest with MessageId 4380 for CMAS for Emergency Area 1
    Expect message flow
    ...    MME_1:S1AP_WriteReplaceWarningResponse (${wRW1})
    ...    alias=writeReplaceWarning    overall_timeout=20
    ${mme_warn_request_1}    catenate
    ...    mme_warn_request enb=1 mme=1 msg_id=4380 warn_msg_contents_length=320 rep_period=80 number=5
    ...    data_coding_scheme=1 eaid=000001
    Execute Egate Command    ${mme_warn_request_1}    pass_regexp=WriteReplaceWarningResponse
    Flow Occurred As Expected    alias=writeReplaceWarning

Lock Cell-1
    Delta Commission Parameters    ${lockcell1}

Enable PWS Restart and Failure Indications (CB006495)
    Expect message flow
    ...    MME_1:S1AP_PWSFailureIndication (${PWSFI1})
    ...    MME_2:S1AP_PWSFailureIndication (${PWSFI1})
    ...    alias=PWSFI    overall_timeout=40
    Delta Commission Parameters    ${actPwsRstrtFlrInd}
    Flow Occurred As Expected    alias=PWSFI

Add cell-2 to Emergency Area 1
    Expect message flow
    ...    MME_1:S1AP_PWSRestartIndication (${PWSRI1})
    ...    MME_2:S1AP_PWSRestartIndication (${PWSRI1})
    ...    alias=PWSRI    overall_timeout=40
    Delta Commission Parameters    ${addcell2toEA1}
    Flow Occurred As Expected    alias=PWSRI

Unlock cell-1, enable ETWS and remove cell-2 from Emergency Area 1
    Delta Commission Parameters    ${2ndpart}

Trigger MME_1 to send WriteReplaceWarningRequest with MessageId 4380 for ETWS for Emergency Area 2
    Expect message flow
    ...    MME_1:S1AP_WriteReplaceWarningResponse (${wRW2})
    ...    alias=writeReplaceWarning2    overall_timeout=20
    ${mme_warn_request_2}    catenate
    ...    mme_warn_request enb=1 mme=1 msg_id=4380 data_coding_scheme=1 concurrent=off warn_msg_contents=xxx
    ...    rep_period=80 number=7 eaid=000002
    Execute Egate Command    ${mme_warn_request_2}    pass_regexp=WriteReplaceWarningResponse
    Flow Occurred As Expected    alias=writeReplaceWarning2

Lock Cell-2 And Verify Relate MSGs
    Expect message flow
    ...    MME_1:S1AP_PWSFailureIndication (${PWSFI2})
    ...    MME_2:S1AP_PWSFailureIndication (${PWSFI2})
    ...    alias=PWSFI2    overall_timeout=40
    Delta Commission Parameters    ${lockcell2}
    Flow Occurred As Expected    alias=PWSFI2

Unlock Cell-1 And Verify Relate MSGs
    Expect message flow
    ...    MME_1:S1AP_PWSRestartIndication (${PWSRI2})
    ...    MME_2:S1AP_PWSRestartIndication (${PWSRI2})
    ...    alias=PWSRI2    overall_timeout=40
    Delta Commission Parameters    ${unlockcell2}
    Flow Occurred As Expected    alias=PWSRI2

Check Rtpm Counter
    sleep    15min
    Check Rtpm Counters    ${PM_Counters}
