*** Settings ***
Documentation   :copyright: Nokia
...             :authors: Marta Klukas
...             :contact: marta.klukas@nokia.com

*** Keywords ***
Set expected message flow XNAP
    [Arguments]    ${gnb_id}=2    ${timeout}=30    ${sNnodeAddPrep}=0    ${sNnodeAddPrepFail}=0    ${sNnodeReconfCompl}=0
        ...        ${sNnodeReleaseRequired}=0    ${SNodeReleaseRequest}=0    ${SNodeReleaseReject}=0    ${nNodeConfUpdate}=0
        ...        ${handoverPreparation}=0    ${handoverPreparationFail}=0    ${XNAPuECtxRelease}=0    ${XNAPerrorInd}=0    ${sNStatusTransfer}=0
        ...        ${xnUAddressInd}=0    ${activityNotification}=0    ${xnSetup}=0    ${reset}=0
    Set expected message flow XNAP sNGRAN Node    gnb_id=${gnb_id}    timeout=${timeout}     sNnodeAddPrep=${sNnodeAddPrep}
        ...        sNnodeAddPrepFail=${sNnodeAddPrepFail}    sNnodeReconfCompl=${sNnodeReconfCompl}    sNnodeReleaseRequired=${sNnodeReleaseRequired}
    Set expected message flow XNAP mNGRAN Node    gnb_id=${gnb_id}    timeout=${timeout}    SNodeReleaseRequest=${SNodeReleaseRequest}
        ...        SNodeReleaseReject=${SNodeReleaseReject}
    Set expected message flow XNAP nNGRAN Node    gnb_id=${gnb_id}    timeout=${timeout}    nNodeConfUpdate=${nNodeConfUpdate}
    Set expected message flow XNAP HO    gnb_id=${gnb_id}    timeout=${timeout}    handoverPreparation=${handoverPreparation}
        ...        handoverPreparationFail=${handoverPreparationFail}
    Set expected message flow XNAP Other messages    gnb_id=${gnb_id}    timeout=${timeout}    XNAPuECtxRelease=${XNAPuECtxRelease}
        ...        XNAPerrorInd=${XNAPerrorInd}    sNStatusTransfer=${sNStatusTransfer}    xnUAddressInd=${xnUAddressInd}
        ...        activityNotification=${activityNotification}    xnSetup=${xnSetup}    reset=${reset}

Set expected message flow XNAP sNGRAN Node
    [Arguments]    ${gnb_id}=2    ${timeout}=30    ${sNnodeAddPrep}=0    ${sNnodeAddPrepFail}=0    ${sNnodeReconfCompl}=0
        ...        ${sNnodeReleaseRequired}=0
    Run Keyword If    '${sNnodeAddPrep}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: gNB${gnb_id} XNAP ${sNnodeAddPrep}*sNGRANnodeAdditionPreparation
    Run Keyword If    '${sNnodeAddPrepFail}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: gNB${gnb_id} XNAP ${sNnodeAddPrepFail}*sNGRANnodeAdditionPreparationFailure
    Run Keyword If    '${sNnodeReconfCompl}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: gNB${gnb_id} XNAP ${sNnodeReconfCompl}*sNGRANnodeReconfigurationCompletion
    Run Keyword If    '${sNnodeReleaseRequired}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: gNB${gnb_id} XNAP ${sNnodeReleaseRequired}*sNGRANnodeinitiatedSNGRANnodeRelease

Set expected message flow XNAP mNGRAN Node
    [Arguments]    ${gnb_id}=2    ${timeout}=30    ${SNodeReleaseRequest}=0    ${SNodeReleaseReject}=0
    Run Keyword If    '${SNodeReleaseRequest}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: gNB${gnb_id} XNAP ${SNodeReleaseRequest}*mNGRANnodeinitiatedSNGRANnodeRelease
    Run Keyword If    '${SNodeReleaseReject}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: gNB${gnb_id} XNAP ${SNodeReleaseReject}*mNGRANnodeinitiatedSNGRANnodeReleaseFailure

Set expected message flow XNAP nNGRAN Node
    [Arguments]    ${gnb_id}=2    ${timeout}=30    ${nNodeConfUpdate}=0
    Run Keyword If    '${nNodeConfUpdate}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: gNB${gnb_id} XNAP ${nNodeConfUpdate}*nGRANnodeConfigurationUpdate

Set expected message flow XNAP HO
    [Arguments]    ${gnb_id}=2    ${timeout}=30    ${handoverPreparation}=0    ${handoverPreparationFail}=0
    Run Keyword If    '${handoverPreparation}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: gNB${gnb_id} XNAP ${handoverPreparation}*handoverPreparation
    Run Keyword If    '${handoverPreparationFail}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: gNB${gnb_id} XNAP ${handoverPreparationFail}*handoverPreparationFailure

Set expected message flow XNAP Other messages
    [Arguments]    ${gnb_id}=2    ${timeout}=30    ${XNAPuECtxRelease}=0    ${XNAPerrorInd}=0    ${sNStatusTransfer}=0   ${xnUAddressInd}=0
        ...        ${activityNotification}=0    ${xnSetup}=0    ${reset}=0
    Run Keyword If    '${XNAPuECtxRelease}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: gNB${gnb_id} XNAP ${XNAPuECtxRelease}*uEContextRelease
    Run Keyword If    '${XNAPerrorInd}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: gNB${gnb_id} XNAP ${XNAPerrorInd}*errorIndication
    Run Keyword If    '${sNStatusTransfer}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: gNB${gnb_id} XNAP ${sNStatusTransfer}*sNStatusTransfer
    Run Keyword If    '${xnUAddressInd}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: gNB${gnb_id} XNAP ${xnUAddressInd}*xnUAddressIndication
    Run Keyword If    '${activityNotification}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: gNB${gnb_id} XNAP ${activityNotification}*activityNotification
    Run Keyword If    '${xnSetup}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: gNB${gnb_id} XNAP ${xnSetup}*xnSetup
    Run Keyword If    '${reset}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: gNB${gnb_id} XNAP ${reset}*reset

Verify expected message flow XNAP
    [Arguments]    ${gnb_id}=2    ${timeout}=30    ${sNnodeAddPrep}=0    ${sNnodeAddPrepFail}=0    ${sNnodeReconfCompl}=0
        ...        ${sNnodeReleaseRequired}=0    ${SNodeReleaseRequest}=0    ${SNodeReleaseReject}=0    ${nNodeConfUpdate}=0
        ...        ${handoverPreparation}=0    ${handoverPreparationFail}=0    ${XNAPuECtxRelease}=0    ${XNAPerrorInd}=0    ${sNStatusTransfer}=0
        ...        ${xnUAddressInd}=0    ${activityNotification}=0    ${xnSetup}=0    ${reset}=0
    Verify expected message flow XNAP sNGRAN Node    gnb_id=${gnb_id}    timeout=${timeout}     sNnodeAddPrep=${sNnodeAddPrep}
        ...        sNnodeAddPrepFail=${sNnodeAddPrepFail}    sNnodeReconfCompl=${sNnodeReconfCompl}    sNnodeReleaseRequired=${sNnodeReleaseRequired}
    Verify expected message flow XNAP mNGRAN Node    gnb_id=${gnb_id}    timeout=${timeout}    SNodeReleaseRequest=${SNodeReleaseRequest}
        ...        SNodeReleaseReject=${SNodeReleaseReject}
    Verify expected message flow XNAP nNGRAN Node    gnb_id=${gnb_id}    timeout=${timeout}    nNodeConfUpdate=${nNodeConfUpdate}
    Verify expected message flow XNAP HO    gnb_id=${gnb_id}    timeout=${timeout}    handoverPreparation=${handoverPreparation}
        ...        handoverPreparationFail=${handoverPreparationFail}
    Verify expected message flow XNAP Other messages    gnb_id=${gnb_id}    timeout=${timeout}    XNAPuECtxRelease=${XNAPuECtxRelease}
        ...        XNAPerrorInd=${XNAPerrorInd}    sNStatusTransfer=${sNStatusTransfer}    xnUAddressInd=${xnUAddressInd}
        ...        activityNotification=${activityNotification}    xnSetup=${xnSetup}    reset=${reset}

Verify expected message flow XNAP sNGRAN Node
    [Arguments]    ${gnb_id}=2    ${timeout}=30    ${sNnodeAddPrep}=0    ${sNnodeAddPrepFail}=0    ${sNnodeReconfCompl}=0
        ...        ${sNnodeReleaseRequired}=0
    Run Keyword If    '${sNnodeAddPrep}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: gNB${gnb_id} XNAP ${sNnodeAddPrep}*sNGRANnodeAdditionPreparation
    Run Keyword If    '${sNnodeAddPrepFail}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: gNB${gnb_id} XNAP ${sNnodeAddPrepFail}*sNGRANnodeAdditionPreparationFailure
    Run Keyword If    '${sNnodeReconfCompl}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: gNB${gnb_id} XNAP ${sNnodeReconfCompl}*sNGRANnodeReconfigurationCompletion
    Run Keyword If    '${sNnodeReleaseRequired} ' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: gNB${gnb_id} XNAP ${sNnodeReleaseRequired}*sNGRANnodeinitiatedSNGRANnodeRelease

Verify expected message flow XNAP mNGRAN Node
    [Arguments]    ${gnb_id}=2    ${timeout}=30    ${SNodeReleaseRequest}=0    ${SNodeReleaseReject}=0
    Run Keyword If    '${SNodeReleaseRequest}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: gNB${gnb_id} XNAP ${SNodeReleaseRequest}*mNGRANnodeinitiatedSNGRANnodeRelease
    Run Keyword If    '${SNodeReleaseReject}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: gNB${gnb_id} XNAP ${SNodeReleaseReject}*mNGRANnodeinitiatedSNGRANnodeReleaseFailure

Verify expected message flow XNAP nNGRAN Node
    [Arguments]    ${gnb_id}=2    ${timeout}=30    ${nNodeConfUpdate}=0
    Run Keyword If    '${nNodeConfUpdate}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: gNB${gnb_id} XNAP ${nNodeConfUpdate}*nGRANnodeConfigurationUpdate

Verify expected message flow XNAP HO
    [Arguments]    ${gnb_id}=2    ${timeout}=30    ${handoverPreparation}=0    ${handoverPreparationFail}=0
    Run Keyword If    '${handoverPreparation}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: gNB${gnb_id} XNAP ${handoverPreparation}*handoverPreparation
    Run Keyword If    '${handoverPreparationFail}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: gNB${gnb_id} XNAP ${handoverPreparationFail}*handoverPreparationFailure

Verify expected message flow XNAP Other messages
    [Arguments]    ${gnb_id}=2    ${timeout}=30    ${XNAPuECtxRelease}=0    ${XNAPerrorInd}=0    ${sNStatusTransfer}=0   ${xnUAddressInd}=0
        ...        ${activityNotification}=0    ${xnSetup}=0    ${reset}=0
    Run Keyword If    '${XNAPuECtxRelease}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: gNB${gnb_id} XNAP ${XNAPuECtxRelease}*uEContextRelease
    Run Keyword If    '${XNAPerrorInd}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: gNB${gnb_id} XNAP ${XNAPerrorInd}*errorIndication
    Run Keyword If    '${sNStatusTransfer}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: gNB${gnb_id} XNAP ${sNStatusTransfer}*sNStatusTransfer
    Run Keyword If    '${xnUAddressInd}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: gNB${gnb_id} XNAP ${xnUAddressInd}*xnUAddressIndication
    Run Keyword If    '${activityNotification}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: gNB${gnb_id} XNAP ${activityNotification}*activityNotification
    Run Keyword If    '${xnSetup}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: gNB${gnb_id} XNAP ${xnSetup}*xnSetup
    Run Keyword If    '${reset}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: gNB${gnb_id} XNAP ${reset}*reset
