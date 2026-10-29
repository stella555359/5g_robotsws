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
@{PARAMS_IN_SCF}
...    LNCEL-2:emAreaIdList=1
...    LNCEL:furtherPlmnIdL:mcc=244
...    LNCEL:furtherPlmnIdL:mncLength=2
...    LNCEL:furtherPlmnIdL:autoRemovalAllowed=false
...    LNCEL:furtherPlmnIdL:cellReserve=Not Reserved
...    LNCEL-3:furtherPlmnIdL:mnc=9
...    LNCEL-4:tac=124
...    LNCEL-4:furtherPlmnIdL:mnc=10
...    LNCEL-5:tac=124
...    LNCEL-5:furtherPlmnIdL:mnc=10
...    LNCEL-6:tac=124
...    LNCEL-6:furtherPlmnIdL:mnc=10

@{lockcell1_4}
...    LNCEL-1:administrativeState=locked
...    LNCEL-4:administrativeState=locked

@{actPwsRstrtFlrInd}
...    LNBTS:actPwsRstrtFlrInd=true
@{lockmme_0}
...  LNBTS/LNMME-0:administrativeState=locked

@{change_cell2and5_EA}
...    LNCEL-2:emAreaIdList=2
...    LNCEL-5:emAreaIdList=1

#####MSG FLOW#####
${wRW1}
...    emergencyAreaID contains ('00 00 01') and
...    completedCellinEAI contains (
...       cell-ID eq '0b0000000000000000000100000001',
...       cell-ID eq '0b0000000000000000000100000010',
...       cell-ID eq '0b0000000000000000000100000011'
...    )

${wRW2}
...    emergencyAreaID contains ('00 00 02') and
...    completedCellinEAI contains (
...       cell-ID eq '0b0000000000000000000100000100',
...       cell-ID eq '0b0000000000000000000100000101',
...       cell-ID eq '0b0000000000000000000100000110'
...    )

${PWSFI1and4}
...    PWSfailedECGIList contains (
...      cell-ID eq '0b0000000000000000000100000001',
...      cell-ID eq '0b0000000000000000000100000100') and
...    Global-ENB-ID contains (pLMNidentity contains ("0x42F480") and
...      eNB-ID contains (macroENB-ID eq "0b00000000000000000001"))

${PWSRI2and5}
...    ECGIListForRestart contains (
...      cell-ID eq '0b0000000000000000000100000010',
...      cell-ID eq '0b0000000000000000000100000101') and
...    Global-ENB-ID contains (pLMNidentity contains ("0x42F480") and
...      eNB-ID contains (macroENB-ID eq "0b00000000000000000001")) and
...    TAIListForRestart contains (tAC eq "0x007B", tAC eq "0x007C") and
...    EmergencyAreaIDListForRestart contains ("0x000001", "0x000002")

*** Test Cases ***
CB006495 Robustness Test 1 - multiple TACs and EAIDs configured, multiple WRWRs being broadcasted, dropping of S1 link
    [Tags]
    [Documentation]
    ...     DESCRIPTION:
    ...     The test case verifies sending of PWS Restart and Failure Indications when there are multiple WRWRs sent
    ...     by different MMEs being broadcasted and cells have different TACs and EAIDs. Additionally, one of S1 links
    ...     is dropped
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
    ...         LNCEL.SIB.sibSchedulingList contains structures for SIB-12
    ...         Cells 1-3 have furtherPlmnIdL containing 244:09, while cells 4-6 have furtherPlmnIdL containing 244:10
    ...         Cells 1-3 belong to Emergency Area 1 (they have LNCEL.emAreaListId containing 1), while cells 4-6
    ...             belong to Emergency Area 2 (they have LNCEL.emAreaListId containing 2)
    ...         Cells 1-3 have TAC 123 and cells 4-6 have TAC 124
    ...
    ...         MME_1 supports PLMN 244:08 and 244:09
    ...         MME_2 supports PLMN 244:08 and 244:10
    ...         MME_3 supports PLMN 244:08, 244:09 and 244:10
    ...
    ...     TEST SCENARIO:
    ...         1. CMAS transmission is started on cells 1-3 by MME_3
    ...         2. Another CMAS transmission is started on cells 1-3 by MME_1
    ...         3. Yet another CMAS transmission is started on cells 4-6 by MME_1
    ...         4. Cells 1 and 4 are locked
    ...         5. CB006495 is activated (LNBTS.actPwsRstrtFlrInd is set to true)
    ...         6. eNB sends to MME_1 and 2 PWSFailureIndication with PWSfailedECGIList and Global-ENB-ID containing data of cells 1 and 4
    ...         7. LNMME-0 is locked, S1 link with MME_1 is dropped
    ...         8. Cell-2 is moved to Emergency Area 2 and cell-5 is moved to Emergency Area 1 (LNCEL.emAreaLisId are
    ...            modified accordingly)
    ...         9. eNB sends to MME_2 and 3 PWSRestartIndication with ECGIListForRestart, Global-ENB-ID, TAIListForRestart and
    ...            EmergencyAreaIDListForRestart containing data of cells 2 and 5 (i.e. TACs 123 and 124, as well as EAIDs 1 and 2)
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

    Trigger MME_3 To Send WriteReplaceWarningRequest With MessageId 4380 For CMAS For Emergency Area 1
    Trigger MME_1 To Send WriteReplaceWarningRequest With MessageId 4381 For CMAS For Emergency Area 1
    Trigger MME_1 To Send WriteReplaceWarningRequest With MessageId 4382 For CMAS For Emergency Area 2
    Lock Cells 1 And 4
    Enable PWS Restart and Failure Indications (CB006495)
    Lock LNMME_0
    Move cell-2 to Emergency Area 2 and cell-5 to Emergency Area 1

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

Trigger MME_3 to send WriteReplaceWarningRequest with MessageId 4380 for CMAS for Emergency Area 1
    Expect message flow
    ...    MME_3:S1AP_WriteReplaceWarningResponse (${wRW1})
    ...    alias=writeReplaceWarning_mme3    overall_timeout=20
    ${mme_warn_request_1}    catenate
    ...    mme_warn_request enb=1 mme=3 msg_id=4380 warn_msg_contents_length=320 rep_period=80 number=5
    ...    data_coding_scheme=1 eaid=000001
    Execute Egate Command    ${mme_warn_request_1}    pass_regexp=WriteReplaceWarningResponse
    Flow Occurred As Expected    alias=writeReplaceWarning_mme3

Trigger MME_1 to send WriteReplaceWarningRequest with MessageId 4381 for CMAS for Emergency Area 1
    Expect message flow
    ...    MME_1:S1AP_WriteReplaceWarningResponse (${wRW1})
    ...    alias=writeReplaceWarning_mme1    overall_timeout=20
    ${mme_warn_request_2}    catenate
    ...    mme_warn_request enb=1 mme=1 msg_id=4381 warn_msg_contents_length=320 rep_period=80 number=5
    ...    data_coding_scheme=1 eaid=000001
    Execute Egate Command    ${mme_warn_request_2}    pass_regexp=WriteReplaceWarningResponse
    Flow Occurred As Expected    alias=writeReplaceWarning_mme1

Trigger MME_1 to send WriteReplaceWarningRequest with MessageId 4382 for CMAS for Emergency Area 2
    Expect message flow
    ...    MME_1:S1AP_WriteReplaceWarningResponse (${wRW2})
    ...    alias=writeReplaceWarning_mme1_EA2    overall_timeout=20
    ${mme_warn_request_3}    catenate
    ...    mme_warn_request enb=1 mme=1 msg_id=4382 warn_msg_contents_length=320 rep_period=80 number=5
    ...    data_coding_scheme=1 eaid=000002
    Execute Egate Command    ${mme_warn_request_3}    pass_regexp=WriteReplaceWarningResponse
    Flow Occurred As Expected    alias=writeReplaceWarning_mme1_EA2

Lock cells 1 and 4
    Delta Commission Parameters    ${lockcell1_4}


Enable PWS Restart and Failure Indications (CB006495)
    Expect message flow
    ...    MME_1:S1AP_PWSFailureIndication (${PWSFI1and4})
    ...    MME_2:S1AP_PWSFailureIndication (${PWSFI1and4})
    ...    alias=PWSFI1and4    overall_timeout=40
    Delta Commission Parameters    ${actPwsRstrtFlrInd}
    Flow Occurred As Expected    alias=PWSFI1and4

Lock LNMME_0
    Delta Commission Parameters    ${lockmme_0}


Move cell-2 to Emergency Area 2 and cell-5 to Emergency Area 1
    Expect message flow
    ...    MME_2:S1AP_PWSRestartIndication (${PWSRI2and5})
    ...    MME_3:S1AP_PWSRestartIndication (${PWSRI2and5})
    ...    alias=PWSRI2and5    overall_timeout=40
    Delta Commission Parameters    ${change_cell2and5_EA}
    Flow Occurred As Expected    alias=PWSRI2and5
